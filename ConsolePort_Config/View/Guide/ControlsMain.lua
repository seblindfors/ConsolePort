local DP, env, db, _, L = 1, CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local CONTENT_WIDTH = 460;
local LAYOUT_FRAME_WIDTH = 330;
local Gamepad = db.Gamepad;

local function ModifyListSetting(self)
	self:SetWidth(self:GetParent():GetWidth())
	self.Text:SetPoint('LEFT', 8, 0)
	if self.Input then
		self.Input:SetWidth(min(self.Input:GetWidth(), self:GetWidth() * 0.4))
		self.Input:SetPoint('RIGHT', 4, 0)
	end
	if self.Icon then
		self.Icon:ClearAllPoints()
		self.Icon:SetPoint('RIGHT', 4, 0)
		if self.Slug then
			self.Slug:SetPoint('RIGHT', self.Icon, 'LEFT', -8, 0)
		end
	end

	local normalTexture = self:GetNormalTexture()
	normalTexture:SetPoint('TOPLEFT', -8, 0)
	normalTexture:SetPoint('BOTTOMRIGHT', 8, 0)
	local hiliteTexture = self:GetHighlightTexture()
	hiliteTexture:SetPoint('TOPLEFT', -8, 0)
	hiliteTexture:SetPoint('BOTTOMRIGHT', 8, 0)
end

---------------------------------------------------------------
local SchemeButton = {};
---------------------------------------------------------------

function SchemeButton:OnLoad()
	self.InnerContent.Selected:SwapAtlas('glues-characterselect-card-glow')
	self.InnerContent.SelectedHighlight:SwapAtlas('glues-characterselect-card-glow')
end

function SchemeButton:OnEnter()
	CPCardSmallMixin.OnEnter(self)
	env:TriggerEvent('Controls.ShowInformation', true, self.row, self.col)
end

function SchemeButton:OnLeave()
	CPCardSmallMixin.OnLeave(self)
	env:TriggerEvent('Controls.ShowInformation', false, self.row, self.col)
end

function SchemeButton:SetData(data, row, col)
	Mixin(self, data)
	self.row, self.col = row, col;
	self.Text:SetText(data.text)
end

---------------------------------------------------------------
local SchemeSelect = CreateFromMixins(SchemeButton);
---------------------------------------------------------------

function SchemeSelect:SetData(data, row, col)
	SchemeButton.SetData(self, data, row, col)
	self.init = self.init or nop;
	self:OnShow()
	self:Update()
end

function SchemeSelect:OnShow()
	self:init()
	if self.subscribe then
		for _, event in ipairs(self.subscribe) do
			db:RegisterCallback(event, self.Update, self)
		end
	end
end

function SchemeSelect:OnHide()
	if self.subscribe then
		for _, event in ipairs(self.subscribe) do
			db:UnregisterCallback(event, self)
		end
	end
	if self.textures then
		for texture in pairs(self.textures) do
			self.txPool:Release(texture);
		end
		self.textures = nil;
	end
end

function SchemeSelect:OnClick()
	self:execute()
end

function SchemeSelect:Update()
	self:SetChecked(self.predicate())
end

function SchemeSelect:AcquireTexture()
	self.textures = self.textures or {};
	local texture = self.txPool:Acquire();
	self.textures[texture] = true;
	texture:SetParent(self)
	texture:SetDrawLayer('ARTWORK', 1)
	texture:SetDesaturated(false)
	texture:Show()
	return texture;
end

function SchemeSelect:GetDevice()
	return Gamepad.Active;
end

---------------------------------------------------------------
local ControlsReport = {
---------------------------------------------------------------
	State = {
		Default = 'common-icon-forwardarrow';
		Failure = 'common-icon-redx';
		Success = 'common-icon-checkmark';
		Warning = 'common-icon-checkmark-yellow';
	};
};

function ControlsReport:OnLoad()
	self.BG:SetPoint('LEFT', 50, 0)
	for i, label in ipairs({
		L'Sensors';
		L'Buttons';
		L'Validation';
	}) do
		self.Reports[i].Text:SetText(label)
	end
end

function ControlsReport:SetData(reports)
	if not reports then
		return self.Status:SetAtlas(self.State.Default);
	end

	local states, state = self.State;
	local function GetReportState(report)
		if not report.success then
			return states.Failure;
		elseif report.warning then
			return states.Warning;
		end
		return states.Success;
	end

	local function UpdateFinalReportState(rstate)
		if rstate == states.Failure then
			state = states.Failure;
		elseif rstate == states.Warning
		and state ~= states.Failure then
			state = states.Warning;
		elseif rstate == states.Success
		and state ~= states.Failure
		and state ~= states.Warning then
			state = states.Success;
		end
	end

	CPAPI.Log('Device test concluded.')
	local validationState = states.Success;
	for i, report in ipairs(reports) do
		local reportState = GetReportState(report)
		UpdateFinalReportState(reportState)
		self.Reports[i].Status:SetAtlas(reportState)
		if #report.errors > 0 then
			validationState = states.Failure;
		end
		if report.message then
			CPAPI.Log(report.message)
		end
	end

	self.Validation.Status:SetAtlas(validationState);
	self.Status:SetAtlas(state);
end

---------------------------------------------------------------
local ControlsTest = CreateFromMixins(SchemeButton, env.ControlsTest);
---------------------------------------------------------------

function ControlsTest:OnLoad()
	SchemeButton.OnLoad(self)
	env.ControlsTest.OnLoad(self)
	CPAPI.SpecializeOnce(self.Report, ControlsReport)
	self.InnerContent:SetScale(0.5)
	-- For the interface cursor, set the anchor to the bottom right
	-- so it doesn't get in the way of the test feedback.
	self.customCursorAnchor = { 'CENTER', self, 'BOTTOMRIGHT', -24, 24 };
	self:ToggleReport(true)
	self.Text:Hide()
end

function ControlsTest:OnClick()
	self:SetChecked(false)
	self:ToggleReport(false)
	self:StartOrProgressTest()
end

function ControlsTest:OnSuiteCompleted(reports)
	self:ToggleReport(true, reports)
end

function ControlsTest:ToggleReport(enabled, reports)
	self.Report:SetShown(enabled)
	self.Report:SetData(reports)
end

---------------------------------------------------------------
local Cvar = CreateFromMixins(env.Elements.Cvar);
---------------------------------------------------------------

function Cvar:OnAcquire(...)
	env.Elements.Cvar.OnAcquire(self, ...);
	CPAPI.Next(ModifyListSetting, self)
end

---------------------------------------------------------------
local Setting = CreateFromMixins(env.Elements.Setting);
---------------------------------------------------------------

function Setting:OnAcquire(...)
	env.Elements.Setting.OnAcquire(self, ...);
	CPAPI.Next(ModifyListSetting, self)
end

---------------------------------------------------------------
local Binding = CreateFromMixins(env.Elements.Binding);
---------------------------------------------------------------

function Binding:OnAcquire(...)
	env.Elements.Binding.OnAcquire(self, ...);
	CPAPI.Next(ModifyListSetting, self)
end

---------------------------------------------------------------
local InfoContainer = {};
---------------------------------------------------------------

function InfoContainer:OnLoad()
	self.Title = Guide.CreateHeader(self, LAYOUT_FRAME_WIDTH);
	self.Label = Guide.CreateText(self, LAYOUT_FRAME_WIDTH);
	self.Title.layoutIndex = 1;
	self.Label.layoutIndex = 2;
end

function InfoContainer:SetTexts(title, label)
	self.Title:SetText(Guide.CreateInfoMarkup(title))
	self.Label:SetText(CPAPI.FormatLongText(label))
end

function InfoContainer:SetData(data, ref)
	self:SetTexts(data and INFO or CONTROLS_LABEL, data and data.desc or L.CONTROLS_GENERAL_INFO)
	self:UpdatePosition(ref)
end

function InfoContainer:UpdatePosition(ref)
	self:ClearAllPoints()
	self:SetPoint(self.pntAnchor, ref, self.relAnchor, self.xOffset, self.yOffset)
	self:Layout()
end

---------------------------------------------------------------
local OptionsContainer = CreateFromMixins(InfoContainer);
---------------------------------------------------------------

function OptionsContainer:OnLoad()
	InfoContainer.OnLoad(self)
	CPScrollBoxSettingsTree.InitDefault(self.Settings)
end

function OptionsContainer:ToggleSettings(enabled)
	self.Settings:SetShown(enabled)
	self.Label:SetShown(not enabled)
	if not enabled then
		self.Settings:GetDataProvider():Flush()
	end
end

function OptionsContainer:SetData(data, ref, shouldShow)
	-- This means we triggered the OnLeave when moving from the
	-- scheme button to the list of options, so we want to noop.
	if not shouldShow and self.variableRef then return end;

	self:Reset()
	self:SetShown(not not data)
	if not self:IsShown() then return end;

	local desc = data.desc;
	if type(desc) == 'function' then
		desc = desc()
	end
	if data.recommend then
		desc = ('%s\n\n%s'):format(desc, Guide.CreateCheckmarkMarkup(RECOMMENDED))
	elseif data.advanced then
		desc = ('%s\n\n%s'):format(desc, Guide.CreateAdvancedMarkup(ADVANCED_LABEL))
	end

	self:ToggleSettings(false)
	self:SetTexts(data.text, desc)
	self:UpdatePosition(ref)
end

function OptionsContainer:SetVariables(variables, ref)
	self:Show()
	self:Reset()
	self:UpdatePosition(ref)
	self:ToggleSettings(true)

	self.variableRef = ref;
	local dataProvider, layoutIndex = self.Settings:GetDataProvider(), 2;
	dataProvider:Flush()

	for i, variable in ipairs(variables) do
		if variable.cvar then
			self:InsertCvar(dataProvider, variable, layoutIndex + i)
		elseif variable.binding then
			self:InsertBinding(dataProvider, variable, layoutIndex + i)
		elseif variable[DP] then
			self:InsertSetting(dataProvider, variable, layoutIndex + i)
		else
			dataProvider:Insert(variable, layoutIndex + i)
		end
	end
	self:Layout()
end

function OptionsContainer:InsertCvar(dataProvider, variable, layoutIndex)
	dataProvider:Insert(Cvar:New({
		varID = variable.cvar;
		field = variable;
		sort = layoutIndex;
	}))
end

function OptionsContainer:InsertBinding(dataProvider, variable, layoutIndex)
	dataProvider:Insert(Binding:New({
		sort     = layoutIndex;
		binding  = variable.binding;
		readonly = variable.readonly or nop;
		field    = {
			name = variable.name;
			list = KEY_BINDING;
		};
	}))
end

function OptionsContainer:InsertSetting(dataProvider, variable, layoutIndex)
	dataProvider:Insert(env.Elements.Setting:New({
		varID = variable.varID;
		field = variable;
		sort  = layoutIndex;
	}))
end

function OptionsContainer:Reset()
	self.variableRef = nil;
end

---------------------------------------------------------------
local SchemeContent = {}; do
---------------------------------------------------------------
	local function HasCVars(cvars, cmp)
		for i, cvar in ipairs(cvars) do
			if db:GetCVar(cvar, cmp[i]) ~= cmp[i] then
				return false;
			end
		end
		return true;
	end

	local function SetCVars(cvars, values)
		for i, cvar in ipairs(cvars) do
			db:SetCVar(cvar, values[i]);
		end
	end

	local function AddIconTexture(delta, size, offX, offY, self)
		local texture = self:AcquireTexture();
		texture:SetPoint('CENTER', delta * offX, offY)
		texture:SetSize(size, size)
		return texture;
	end

	local AddLeftIcon  = GenerateClosure(AddIconTexture, -1, 40, 24, 8);
	local AddRightIcon = GenerateClosure(AddIconTexture,  1, 40, 24, 8);

	local function GetModifierCVars()
		return { 'GamePadEmulateShift', 'GamePadEmulateCtrl', 'GamePadEmulateAlt', 'GamePadEmulateTapWindowMs' };
	end

	local HasModifiers = GenerateClosure(HasCVars, GetModifierCVars());
	local SetModifiers = GenerateClosure(SetCVars, GetModifierCVars());

	local LeftHandModifiers = { 'PADLSHOULDER', 'PADLTRIGGER',  'none', 350 };
	local TriggerModifiers  = { 'PADLTRIGGER',  'PADRTRIGGER',  'none', 350 };
	local NewUserModifiers  = { 'PADLTRIGGER',  'PADLSHOULDER', 'none', 350 };

	tinsert(SchemeContent, {
		-- Row 1: Modifiers
		text = L'Modifiers';
		desc = L.CONTROLS_MODIFIERS_DESC;
		type = SchemeSelect;
		{ -- 1.1 Left handed modifiers
			text      = L'Left';
			desc      = L.CONTROLS_MODIFIERS_LEFT;
			recommend = true;
			subscribe = GetModifierCVars();
			predicate = GenerateClosure(HasModifiers, LeftHandModifiers);
			execute   = GenerateClosure(SetModifiers, LeftHandModifiers);
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLSHOULDER');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADLTRIGGER');
			end;
		};
		{ -- 1.2 Trigger modifiers
			text      = L'Triggers';
			desc      = L.CONTROLS_MODIFIERS_TRIGGERS;
			subscribe = GetModifierCVars();
			predicate = GenerateClosure(HasModifiers, TriggerModifiers);
			execute   = GenerateClosure(SetModifiers, TriggerModifiers);
			init = function(self)
				local LT = AddLeftIcon(self);
				Gamepad.SetIconToTexture(LT, 'PADLTRIGGER');

				local RT = AddRightIcon(self);
				Gamepad.SetIconToTexture(RT, 'PADRTRIGGER');
			end;
		};
		{ -- 1.3 Custom modifiers
			text      = CUSTOM;
			desc      = L.CONTROLS_MODIFIERS_CUSTOM;
			advanced  = true;
			subscribe = GetModifierCVars();
			predicate = function()
				return  not HasModifiers(LeftHandModifiers)
					and not HasModifiers(TriggerModifiers)
					and not HasModifiers(NewUserModifiers);
			end;
			execute = function(self)
				self:SetChecked(self.predicate())
				local variables = GetModifierCVars()
				for i, cvar in ipairs(variables) do
					variables[i] = db.Console:GetMetadata(cvar);
				end
				env:TriggerEvent('Controls.ShowVariables', variables, self.row);
			end;
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLTRIGGER');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADRTRIGGER');

				local LB = self:AcquireTexture();
				LB:SetPoint('CENTER', 0, 20)
				LB:SetSize(40, 40)
				LB:SetDrawLayer('ARTWORK', -1)
				Gamepad.SetIconToTexture(LB, 'PADLSHOULDER');

				local PC = self:AcquireTexture();
				PC:SetPoint('CENTER', 0, -4)
				PC:SetSize(60, 30)
				PC:SetDrawLayer('ARTWORK', 2)
				PC:SetDesaturated(true)
				PC:SetTexture([[Interface\AddOns\ConsolePort_Config\Assets\master]])
			end;
		}
	});

	local function GetMouseButtonCVars()
		return { 'GamePadCursorLeftClick', 'GamePadCursorRightClick' };
	end

	local HasMouseButtons = GenerateClosure(HasCVars, GetMouseButtonCVars());
	local SetMouseButtons = GenerateClosure(SetCVars, GetMouseButtonCVars());

	local RegularMouseSetup  = { 'PADLSTICK',   'PADRSTICK' };
	local InvertedMouseSetup = { 'PADRSTICK',   'PADLSTICK' };
	local NewUserMouseSetup  = { 'PADRTRIGGER', 'PADRSHOULDER' };

	tinsert(SchemeContent, {
		-- Row 2: Mouse buttons
		text = MOUSE_LABEL;
		desc = L.CONTROLS_MOUSE_BUTTONS_DESC;
		type = SchemeSelect;
		{ -- 2.1 Inverted mouse setup
			text      = L'Inverted';
			desc      = L.CONTROLS_MOUSE_INVERTED;
			subscribe = GetMouseButtonCVars();
			predicate = GenerateClosure(HasMouseButtons, InvertedMouseSetup);
			execute   = GenerateClosure(SetMouseButtons, InvertedMouseSetup);
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADRSTICK');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADLSTICK');
			end;
		};
		{ -- 2.2 Regular mouse setup
			text      = L'Regular';
			desc      = L.CONTROLS_MOUSE_REGULAR;
			subscribe = GetMouseButtonCVars();
			predicate = GenerateClosure(HasMouseButtons, RegularMouseSetup);
			execute   = GenerateClosure(SetMouseButtons, RegularMouseSetup);
			recommend = true;
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLSTICK');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADRSTICK');
			end;
		};
		{ -- 2.3 Custom mouse setup
			text      = CUSTOM;
			desc      = L.CONTROLS_MOUSE_CUSTOM;
			advanced  = true;
			subscribe = GetMouseButtonCVars();
			predicate = function()
				return  not HasMouseButtons(RegularMouseSetup)
					and not HasMouseButtons(InvertedMouseSetup)
					and not HasMouseButtons(NewUserMouseSetup);
			end;
			execute = function(self)
				self:SetChecked(self.predicate())

				local variables = GetMouseButtonCVars()
				for i, cvar in ipairs(variables) do
					variables[i] = db.Console:GetMetadata(cvar);
				end

				local bindings = db.Bindings;
				tAppendAll(variables, {
					env.Elements.Title:New(KEY_BINDINGS_MAC);
					bindings:GetCustomBindingInfo(bindings.Proxied.LeftMouseButton);
					bindings:GetCustomBindingInfo(bindings.Proxied.RightMouseButton);
				})

				env:TriggerEvent('Controls.ShowVariables', variables, self.row);
			end;
			init = function(self)
				local M1 = AddLeftIcon(self)
				M1:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\LMB]])

				local M2 = AddRightIcon(self)
				M2:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\RMB]])

				local PC = self:AcquireTexture();
				PC:SetPoint('CENTER', 0, -4)
				PC:SetSize(60, 30)
				PC:SetDrawLayer('ARTWORK', 2)
				PC:SetDesaturated(true)
				PC:SetTexture([[Interface\AddOns\ConsolePort_Config\Assets\master]])
			end;
		};
	})

	tinsert(SchemeContent, {
		-- Row 3: Gamepad tester
		text = L'Test Device';
		desc = L.CONTROLS_GAMEPAD_TESTER_DESC;
		type = ControlsTest;
		acquire = function(self)
			if not self.GamepadTester then
				self.GamepadTester = CreateFrame('CheckButton', nil, self.Browser.ScrollChild, 'CPControlsGamepadTester')
				return self.GamepadTester, true;
			end
			return self.GamepadTester, false;
		end;
		{
			text = L'Run Tests';
			desc = function()
				local desc = L.CONTROLS_GAMEPAD_TESTER_ACTION;
				local connected = db.Gamepad:GetConnectedDevices()
				if not next(connected) then
					return desc;
				end

				desc = desc .. '\n\n' .. L'Connected device(s):'
				local uniques = {};
				for _, device in ipairs(connected) do
					uniques[device.name] = (uniques[device.name] or 0) + 1;
				end
				for name, count in env.table.spairs(uniques) do
					local label = name;
					if count > 1 then
						label = label .. ORANGE_FONT_COLOR:WrapTextInColorCode((' (%dx)'):format(count))
					end
					desc = desc .. '\n\n • ' .. YELLOW_FONT_COLOR:WrapTextInColorCode(label)
				end
				return desc;
			end;
			recommend = true;
		};
	});
end -- SchemeContent

---------------------------------------------------------------
local Controls = {};
---------------------------------------------------------------

function Controls:OnLoad()
	local canvas = self:GetCanvas();
	self:SetAllPoints(canvas)

	local scrollChild = self.Browser.ScrollChild;
	self.RowInfo    = scrollChild.RowInfo;
	self.ColInfo    = scrollChild.ColInfo;
	self.buttonPool = CreateFramePool('CheckButton', scrollChild, 'CPControlSchemeButton')
	self.txPool     = CreateTexturePool(scrollChild, 'ARTWORK')

	CPAPI.Specialize(self.RowInfo, InfoContainer)
	CPAPI.Specialize(self.ColInfo, OptionsContainer)

	-- Position scheme buttons
	local function CalculateButtonOffset(col, numColumns)
		return (col - 1) * (CONTENT_WIDTH / numColumns)
			- (CONTENT_WIDTH / 2)
			+ (CONTENT_WIDTH / (2 * numColumns))
			, -10;
	end

	-- Set up scheme content
	self.headers = {};
	local topOffset = -80;
	for row, dataRows in ipairs(SchemeContent) do
		local header = Guide.CreateHeader(scrollChild, CONTENT_WIDTH)
		header.Text:SetText(dataRows.text)
		header:SetPoint('TOP', 0, topOffset)
		self.headers[row] = header;

		local numColumns = #dataRows;
		for col, data in ipairs(dataRows) do
			local button, newObj;
			if dataRows.acquire then
				button, newObj = dataRows.acquire(self)
			else
				button, newObj = self.buttonPool:Acquire()
			end
			if newObj then
				CPAPI.Specialize(button, dataRows.type)
				button.txPool = self.txPool;
			end
			button:SetData(data, row, col)
			button:SetPoint('TOP', header, 'BOTTOM', CalculateButtonOffset(col, numColumns))
			button:Show()
			data.object = button;
		end
		topOffset = topOffset - 200;
	end

	local spacer = CreateFrame('Frame', nil, scrollChild)
	spacer:SetSize(CONTENT_WIDTH, 200)
	spacer:SetPoint('TOP', 0, topOffset)

	CPAPI.Next(function()
		scrollChild:SetMinimumWidth(self.Browser:GetWidth())
		scrollChild:SetHeightPadding(100)
		scrollChild:Layout()
	end)
end

function Controls:OnShow()
	env:RegisterCallback('Controls.ShowInformation', self.ShowInformation, self)
	env:RegisterCallback('Controls.ShowVariables', self.ShowVariables, self)
	for _, rows in ipairs(SchemeContent) do
		for _, col in ipairs(rows) do
			if col.recommend and col.predicate and not col.predicate() then
				return ConsolePort:SetCursorNodeIfActive(col.object)
			end
		end
	end
end

function Controls:OnHide()
	env:UnregisterCallback('Controls.ShowInformation', self)
	env:UnregisterCallback('Controls.ShowVariables', self)
end

function Controls:ShowInformation(shouldShow, row, col)
	local rowInfo = SchemeContent[row];
	local colInfo = rowInfo and rowInfo[col];
	row = row or 1;

	local ref = self.headers[row];
	self.RowInfo:SetData(rowInfo, ref, shouldShow)
	self.ColInfo:SetData(colInfo, ref, shouldShow)
end

function Controls:ShowVariables(variables, row)
	self.ColInfo:SetVariables(variables, self.headers[row])
end

---------------------------------------------------------------
-- Add controls to guide content
---------------------------------------------------------------
do local TutorialIncomplete, HasActiveDevice = env.TutorialPredicate('ControlScheme'), env.HasActiveDevice();

	local function ShowControlsPredicate()
		return not HasActiveDevice() or TutorialIncomplete();
	end

	Guide:AddContent('Controls', ShowControlsPredicate,
	function(canvas, GetCanvas)
		if not canvas.Controls then
			canvas.Controls = CreateFrame('Frame', nil, canvas, 'CPControlsPanel')
			canvas.Controls.GetCanvas = GetCanvas;
			CPAPI.SpecializeOnce(canvas.Controls, Controls)
		end
		canvas.Controls:Show()
	end, function(canvas)
		if not canvas.Controls then return end;
		canvas.Controls:Hide()
	end, env.HasActiveDevice())
end