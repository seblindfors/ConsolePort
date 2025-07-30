local env, db, _, L = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local GetTime, Gamepad = GetTime, db.Gamepad;

local function GetRandomColorValue()
	return Clamp(random(100) / 100, 0.5, 1)
end

local function GetRandomColor(index)
	local classFile = (C_CreatureInfo.GetClassInfo(index) or {}).classFile;
	if classFile then
		return CPAPI.GetClassColorObject(classFile):GetRGB()
	end
	return GetRandomColorValue(), GetRandomColorValue(), GetRandomColorValue();
end

local function GetTrackerOffset(index)
	local col = math.floor((index - 1) / 4)
	local row = (index - 1) % 4;
	return (col * 170) + 24, -row * 12;
end

local function FormatAxisReading(x, y)
	local function sign(v)
		return v < 0 and '-' or '+'
	end
	return ('%s%.2f, %s%.2f'), sign(x), math.abs(x), sign(y), math.abs(y);
end


---------------------------------------------------------------
local Test = {};
---------------------------------------------------------------
local function OnTimerExpired(self, ...)
	self:GetParent():OnExpired(...)
end

function Test:OnLoad()
	self:ResetReport()
	self.timer = CreateFrame('Cooldown', nil, self, 'CPHintTimerTemplate')
	self.timer:SetUsingParentLevel(true)
	self.timer:SetAllPoints(self.BG)
	self.timer:SetScript('OnCooldownDone', OnTimerExpired)
end

function Test:SetTimer(duration)
	local startTime = GetTime();
	CooldownFrame_Set(self.timer, startTime, duration, 1, false)
	return startTime;
end

function Test:ClearTimer()
	CooldownFrame_Clear(self.timer)
end

function Test:SetDuration(duration)
	self.testDuration = duration;
end

function Test:StartTimeout()
	if not self.timeout then
		self.timeout = self:SetTimer(self.testDuration or 5)
	end
end

function Test:StopTimeout()
	if self.timeout then
		self.timeout = self:ClearTimer()
	end
end

function Test:OnTestCompleted()
	return self:GetParent():OnTestCompleted(self, self:CompleteReport())
end

function Test:CompleteReport()
	return self.report;
end

function Test:ResetReport()
	self.report = {
		inputs  = {};
		errors  = {};
		message = nil;
		success = false;
		warning = false;
	};
end

function Test:OnHide()
	self:ResetReport()
	self:StopTimeout()
end

---------------------------------------------------------------
local AxisTracker = CreateFromMixins(ColorMixin, Vector4DMixin)
---------------------------------------------------------------

function AxisTracker:Init(index, point, label, value, anchor, stick, x, y, len)
	self:SetXYZW(x, y, x, y)
	self:SetRGB(GetRandomColor(index))

	point:SetVertexColor(self:GetRGB())
	point:SetPoint('CENTER', anchor, 0, 0)
	self.point = point;

	label:SetTextColor(self:GetRGB())
	label:SetText(stick)
	label:SetPoint('TOPLEFT', anchor, 'TOPRIGHT', GetTrackerOffset(index))
	self.label = label;

	value:SetTextColor(self:GetRGB())
	value:SetPoint('TOPLEFT', anchor, 'TOPRIGHT', GetTrackerOffset(index))
	self.value = value;

	self.radius = (anchor:GetSize() / 2) * 0.875;
	self.anchor = anchor;
	self:Update(x, y, len)
end

function AxisTracker:Update(x, y, len) len = tonumber(len) or 0;
	local alpha = Clamp(len * 0.25 + 0.75, 0.75, 1)
	self:SetXYZW(x, y, self.x, self.y)
	self.point:SetPoint('CENTER', self.anchor, 'CENTER', x * self.radius, y * self.radius)
	self.point:SetAlpha(alpha)
	self.label:SetAlpha(alpha)
	self.value:SetAlpha(alpha)
	self.value:SetFormattedText(FormatAxisReading(x, y))
end

function AxisTracker:IsIdle()
	local isEqual, epsilon = ApproximatelyEqual, 0.01;
	local isIdle = isEqual(self.x, self.z, epsilon) and isEqual(self.y, self.w, epsilon)
	self:SetXYZW(self.x, self.y, self.x, self.y) -- force it to be idle on the next check.
	return isIdle;
end

---------------------------------------------------------------
local AxisTest = CreateFromMixins(Test, env.Mixin.UpdateStateTimer)
---------------------------------------------------------------

function AxisTest:OnLoad()
	Test.OnLoad(self)
	self.dots     = CreateTexturePool(self, 'ARTWORK', 3, 'CPControlsTestAxis')
	self.texts    = CreateFontStringPool(self, 'ARTWORK', 3, 'GameFontNormalSmall')
	self.trackers = {};
	self:SetScript('OnGamePadStick', self.OnGamePadStick)
	self:SetUpdateStateDuration(1)

	self.Text:SetText(('%s\n\n• %s\n• %s'):format(
		L'No axis input detected yet.',
		L'Connect your controller.',
		L'Move one of the sticks.'
	))
end

function AxisTest:AcquireText(justifyH)
	local label, newObj = self.texts:Acquire()
	if newObj then
		label:SetWidth(140)
	end
	label:SetJustifyH(justifyH or 'LEFT')
	label:Show()
	return label;
end

function AxisTest:AcquireDot()
	local dot = self.dots:Acquire()
	dot:Show()
	return dot;
end

function AxisTest:UpdateReport(stick)
	tinsert(self.report.inputs, stick)
	self.report.success = true;
end

function AxisTest:OnGamePadStick(stick, x, y, len)
	self:ToggleNoInputDetected(false)
	local tracker, newObj = self.trackers[stick], false;
	if not tracker then
		local numActive = self.dots:GetNumActive()
		if numActive >= 8 then return end;

		tracker, newObj = CreateAndInitFromMixin(AxisTracker, numActive + 1,
			self:AcquireDot(),
			self:AcquireText('LEFT'),
			self:AcquireText('RIGHT'),
			self.BG,
			stick, x, y, len
		), true;
		self.trackers[stick] = tracker;
	end

	tracker:Update(x, y, len)
	if tracker:IsIdle() then
		self:StartTimeout()
	else
		self:StopTimeout()
	end

	if newObj then
		self:UpdateReport(stick)
	end
end

function AxisTest:OnExpired()
	self:SetScript('OnGamePadStick', nil)
	C_Timer.After(1, GenerateClosure(self.OnTestCompleted, self))
end

function AxisTest:OnShow()
	db.Alpha.FadeIn(self, 0.5, 0, 1)
	self:ToggleNoInputDetected(true)
	self:SetScript('OnGamePadStick', self.OnGamePadStick)
end

function AxisTest:OnHide()
	self.dots:ReleaseAll()
	self.texts:ReleaseAll()
	self:CancelUpdateStateTimer()
	wipe(self.trackers)
	Test.OnHide(self)
end

function AxisTest:ToggleNoInputDetected(show)
	self:SetDuration(show and 15 or 5)
	self:SetUpdateStateTimer(function()
		self:StopTimeout()
		self:StartTimeout()
	end)
	self.Text:SetShown(show)
end

function AxisTest:CompleteReport()
	local report  = Test.CompleteReport(self);
	if #report.inputs > 0 then
		local separator = '\n• ';
		report.message = table.concat({
			Guide.CreateCheckmarkMarkup(L'Sensors', 14), '\n',
			L('Detected %d out of 8 possible sensors.', #report.inputs),
			separator,
			table.concat(report.inputs, separator)
		})
	else
		report.message = ('%s\n%s'):format(
			Guide.CreateAtlasMarkup(L'Sensors', 'common-icon-redx', RED_FONT_COLOR, 14),
			L'No sensors were detected.'
		);
	end
	return report;
end

---------------------------------------------------------------
local ButtonTest = CreateFromMixins(Test, CPButtonCatcherMixin)
---------------------------------------------------------------

function ButtonTest:OnLoad()
	Test.OnLoad(self)
	self:SetScript('OnKeyDown', self.OnKeyDown)
	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)
	self.icons = CreateTexturePool(self, 'ARTWORK')
	self.texts = CreateFontStringPool(self, 'ARTWORK', 3, 'GameFontNormalSmall')

	self.Text:SetText(('%s\n\n• %s\n• %s'):format(
		L'No button input detected yet.',
		L'Connect your controller.',
		L'Press your gamepad buttons to test them.'
	))
end

function ButtonTest:AcquireIcon()
	local numActive = self.icons:GetNumActive()
	local icon = self.icons:Acquire()
	local iconsPerRow, spacing = 8, 24;
	local col = (numActive % iconsPerRow)
	local row = math.floor(numActive / iconsPerRow)
	icon:ClearAllPoints()
	icon:SetPoint('TOPLEFT', self.BG, 'TOPRIGHT', (col + 1) * spacing, -row * spacing)
	icon:Show()
	return icon;
end

function ButtonTest:AcquireText()
	local numActive = self.texts:GetNumActive()
	local text = self.texts:Acquire()
	local textsPerRow, spacing = 6, 20;
	local col = (numActive % textsPerRow)
	local row = math.floor(numActive / textsPerRow)
	text:ClearAllPoints()
	text:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -16 - (col * spacing), -16 -(row * spacing))
	text:Show()
	return text;
end

function ButtonTest:OnShow()
	db.Alpha.FadeIn(self, 0.5, 0, 1)
	env.Frame:PauseCatcher()
	self:CatchAll(self.OnButtonPressed, self)
	self:ToggleNoInputDetected(true)
	self:StartTimeout()
	self.Icon:SetAtlas('common-icon-zoomin-disable')

	local is, as = 24, 18;
	self.iSize = { is, is };
	self.aSize = { as, as };
end

function ButtonTest:OnHide()
	env.Frame:ResumeCatcher()
	self:ReleaseClosures()
	self.icons:ReleaseAll()
	self.texts:ReleaseAll()
	Test.OnHide(self)
end

function ButtonTest:OnExpired()
	self:ReleaseClosures()
	C_Timer.After(1, GenerateClosure(self.OnTestCompleted, self))
end

function ButtonTest:ToggleNoInputDetected(show)
	self:SetDuration(show and 15 or 5)
	self.Text:SetShown(show)
	self.Icon:SetShown(show)
	self.Key:SetShown(not show)
end

function ButtonTest:GetButtonEmulation(button)
	local cvar = db.Gamepad.Index.Modifier.Cvars[button:gsub('^R', '')];
	if cvar then -- emulated modifiers use e.g. RSHIFT or RCTRL.
		local emulation = db:GetCVar(cvar);
		if emulation and emulation:match('PAD') then
			return emulation;
		end
	end
	return db.Paddles:GetEmulatedButton(button) or button;
end

function ButtonTest:IsButtonValid(button)
	return true; -- always return true for testing.
end

function ButtonTest:OnButtonPressed(button)
	self:ToggleNoInputDetected(false)

	local isValid = self:Validate(button)
	self.Icon:SetShown(isValid)
	self.Key:SetShown(not isValid)
	if isValid and Gamepad.SetIconToTexture(self.Icon, button) then
		return self:AddValidButton(button)
	end
	self.Key:SetText(button:sub(1, 3):upper())
	self:AddInvalidButton(button)
end

function ButtonTest:Validate(button)
	return IsBindingForGamePad(button)
end

function ButtonTest:AddValidButton(button)
	local numEntries = tInsertUnique(self.report.inputs, button)
	if numEntries and numEntries < 25 then
		local icon = self:AcquireIcon()
		Gamepad.SetIconToTexture(icon, button, 32, self.iSize, self.aSize)
	end

	self.report.success = true;
	self:StopTimeout()
	self:StartTimeout()
end

function ButtonTest:AddInvalidButton(button)
	local numEntries = tInsertUnique(self.report.errors, button)
	if numEntries and numEntries < 25 then
		local text = self:AcquireText()
		text:SetText(button:sub(1, 2):upper())
	end
	self.report.warning = true;
	self:StopTimeout()
	self:StartTimeout()
end

function ButtonTest:CompleteReport()
	local report = Test.CompleteReport(self);
	local separator = '\n• ';

	local hasValid   = #report.inputs > 0;
	local hasInvalid = #report.errors > 0;

	local color = RED_FONT_COLOR;
	local atlas = 'common-icon-redx';

	if hasValid and not hasInvalid then
		color = GREEN_FONT_COLOR;
		atlas = 'common-icon-checkmark';
	elseif hasValid and hasInvalid then
		color = ORANGE_FONT_COLOR;
		atlas = 'common-icon-checkmark-yellow';
	end

	local content = { Guide.CreateAtlasMarkup(L'Buttons', atlas, color, 14), '\n' };
	if hasValid then
		tinsert(content, L('Detected %d valid button(s).', #report.inputs))
		if hasInvalid then tinsert(content, '\n') end;
	end
	if hasInvalid then
		tinsert(content, L('Unmapped keyboard key(s) detected:'))
		tinsert(content, separator)
		tinsert(content, table.concat(report.errors, separator))
	end
	if not hasValid and not hasInvalid then
		tinsert(content, L'No buttons were detected during the test.')
	end

	report.message = table.concat(content)
	return report;
end

---------------------------------------------------------------
local TestSuite = {}; env.ControlsTest = TestSuite;
---------------------------------------------------------------

function TestSuite:OnLoad()
	CPAPI.Specialize(self.AxisTest, AxisTest)
	CPAPI.Specialize(self.ButtonTest, ButtonTest)
	self.reports = {};
end

function TestSuite:GetTestIndex(test)
	for i, t in ipairs(self.Tests) do
		if t == test then return i end;
	end
	return 0;
end

function TestSuite:OnTestCompleted(completed, report)
	local index = self:GetTestIndex(completed)
	self.reports[index] = report or {};
	self:SetTest(index + 1)
end

function TestSuite:SetTest(testIndex)
	if self.currentTest then
		self.currentTest:Hide()
	end
	self.currentTest = self.Tests[testIndex];
	if self.currentTest then
		return self.currentTest:Show()
	end
	return self:OnSuiteCompleted(self.reports)
end

function TestSuite:ProgressSuite()
	self.currentTest:StopTimeout()
	self.currentTest:OnTestCompleted()
end

function TestSuite:IsTestInProgress()
	return not not self.currentTest;
end

function TestSuite:StartOrProgressTest()
	if not self:IsTestInProgress() then
		wipe(self.reports)
		return self:SetTest(1)
	end
	self:ProgressSuite()
end