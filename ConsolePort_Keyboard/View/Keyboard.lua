local Keyboard, env, db = CPAPI.EventHandler(ConsolePortKeyboard, {'PLAYER_LOGOUT'}), CPAPI.GetEnv(...);
Mixin(Keyboard, CPPropagationMixin, db.Radial.CalcMixin)

local function SetCursorControl(enabled)
	SetGamePadFreeLook(not enabled)
	SetGamePadCursorControl(enabled)
	SetCursor(enabled and 'Interface/Cursor/UI-Cursor-SizeLeft.crosshair' or nil)
end

---------------------------------------------------------------
-- Hardware events
---------------------------------------------------------------
local VALID_VEC_LEN, VALID_DSP_LEN = 0.5, 0.15;

function Keyboard:Left(x, y, len)
	self:ReflectStickPosition(x, y, len, len > VALID_VEC_LEN)

	local oldFocusSet = self.focusSet;
	self.focusSet = len > VALID_VEC_LEN and
		self.Registry[self:GetIndexForPos(x, y, len, self.numSets)]

	local isNewFocusSet = oldFocusSet ~= self.focusSet;
	local hasFocusset   = not not self.focusSet;

	if oldFocusSet and isNewFocusSet then
		oldFocusSet:OnStickChanged(0, 0, 0, false)
		oldFocusSet:SetHighlight(false)
	end
	if isNewFocusSet and hasFocusset then
		self.focusSet:SetHighlight(true)
		SetCursorControl(false)
	end
	self.Controls:SetHighlight(not hasFocusset)

	return false;
end

function Keyboard:Right(x, y, len)
	if self.focusSet then
		self.focusSet:OnStickChanged(x, y, len, len > VALID_DSP_LEN)
	else
		SetCursorControl(true)
	end
	if not self.inputLock and len > VALID_VEC_LEN then
		self.inputLock = true;
		self:Insert()
	elseif len <= VALID_VEC_LEN then
		self.inputLock = false;
	end

	return false;
end

function Keyboard:Cursor()
	if self.focusSet then return true end;
	self:MoveToCursor()
	return true;
end

function Keyboard:OnGamePadStick(stick, x, y, len)
	local propagate = false;
	if self[stick] then
		propagate = self[stick](self, x, y, len)
	end
	self:SetPropagation(propagate)
end

function Keyboard:OnGamePadButtonDown(button)
	local callback = self.commands[button];
	if callback then
		callback(self, button)
		return self:SetPropagation(false)
	end
	self:SetPropagation(true)
end

function Keyboard:OnFocusChanged(frame)
	self:SetShown(frame)
	self.focusFrame = frame;
	self:UpdateSpline()
end

function Keyboard:SetState(state)
	if not self:IsShown() then return end
	if self.state == state then return end

	self.state = state;
	for widget in self:EnumerateActive() do
		widget:SetState(state)
	end
end

---------------------------------------------------------------
-- Input scripts
---------------------------------------------------------------
local utf8 = env.utf8;

function Keyboard:GetFocusKey(index)
	if not self.focusSet then return end;
	return self.focusSet:GetKeyByIndex(index);
end

function Keyboard:Stroke(index)
	local key = self:GetFocusKey(index);
	if not key then
		self.Controls:GetKeyByIndex(index):Flash()
		return false;
	end
	key:Flash()
	self:Insert(key)
	return true;
end

function Keyboard:Insert(key)
	key = key or self.focusSet and self.focusSet.focusKey;
	if key then
		self.focusFrame:Insert(key:GetText())
	end
end

function Keyboard:Escape()
	if self:Stroke(1) then return end;
	ExecuteFrameScript(self.focusFrame, 'OnEscapePressed')
	self:OnFocusChanged(nil)
end

function Keyboard:Enter()
	if self:Stroke(2) then return end;
	ExecuteFrameScript(self.focusFrame, 'OnEnterPressed')
	if self.cachedFocusText then
		env.DictHandler:Update(env.Dictionary, self.cachedFocusText)
		self.cachedFocusText = nil;
	end
end

function Keyboard:Space()
	if self:Stroke(3) then return end;
	ExecuteFrameScript(self.focusFrame, 'OnSpacePressed')
	self.focusFrame:Insert(' ')
end

function Keyboard:Erase()
	if self:Stroke(4) then return end;
	if IsControlKeyDown() then
		return self.focusFrame:SetText('')
	end
	local pos = self.focusFrame:GetUTF8CursorPosition()
	if pos ~= 0 then
		local text, offset = (self.focusFrame:GetText())
		-- TODO: handle markers

		local newText =
			utf8.sub(text, 0, offset and pos - offset or pos - 1) .. -- prefix
			utf8.sub(text, pos + 1, utf8.len(text) - pos);           -- suffix
		self.focusFrame:SetText(newText)
		self.focusFrame:SetCursorPosition(utf8.pos(newText, offset and pos - offset or pos - 1))
	end
end

function Keyboard:MoveLeft()
	local text, pos = self.focusFrame:GetText(), self.focusFrame:GetUTF8CursorPosition()
	local marker = text:sub(pos - 4, pos):find('{rt%d}')
	self.focusFrame:SetCursorPosition(utf8.pos(text, marker and pos - 5 or pos - 1))
end

function Keyboard:MoveRight()
	local text, pos = self.focusFrame:GetText(), self.focusFrame:GetUTF8CursorPosition()
	local marker = text:sub(pos, pos + 5):find('{rt%d}')
	self.focusFrame:SetCursorPosition(utf8.pos(text, marker and pos + 5 or pos + 1))
end

function Keyboard:PrevWord()
	self.WordSuggester:SetDelta(-1)
end

function Keyboard:NextWord()
	self.WordSuggester:SetDelta(1)
end

function Keyboard:AutoCorrect()
	local word = self.WordSuggester:GetSuggestion()
	if word then
		local text = self.focusFrame:GetText()
		local _, startPos, endPos = utf8.getword(text, self.focusFrame:GetUTF8CursorPosition())
		if text and word and startPos and endPos then
			self.focusFrame:SetText(text:sub(0, startPos - 1) .. word .. text:sub(endPos + 1))
			CPAPI.Next(ExecuteFrameScript, self.focusFrame, 'OnTextChanged', true)
		end
	end
end

function Keyboard:MoveToCursor()
	local x, y = GetScaledCursorPosition()
	self:ClearAllPoints()
	self:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT',
		x - self:GetWidth() * 0.5, y - self:GetHeight() * 0.5)
	self:OnMoveComplete(x, y)
end

function Keyboard:StopMoving()
	self:StopMovingOrSizing()
	self:OnMoveComplete(GetScaledCursorPosition())
end

function Keyboard:OnMoveComplete(x)
	-- Move the WordSuggester to the side of the keyboard based
	-- on whether the keyboard is to the left or right of UIParent
	self.WordSuggester:ClearAllPoints()
	if x < UIParent:GetWidth() * 0.5 then
		self.WordSuggester:SetPoint('LEFT', self, 'RIGHT', 40, 0)
	else
		self.WordSuggester:SetPoint('RIGHT', self, 'LEFT', -40, 0)
	end
	self:UpdateSpline()
end

---------------------------------------------------------------
-- Spline line effects
---------------------------------------------------------------
Mixin(Keyboard, db.SplineLine)
db.SplineLine.OnLoad(Keyboard)
Keyboard:SetLineOrigin('BOTTOMLEFT', UIParent)
Keyboard:SetLineDrawLayer('BACKGROUND', 0)
Keyboard:SetLineSegments(100)
Keyboard:SetLineOwner(Keyboard)

function Keyboard:UpdateSpline()
    self:ClearLinePoints()
    if not self.focusFrame then return end;

    local kX, kY = self:GetCenter()
    local tX, tY = self.focusFrame:GetCenter()
    local midY = Lerp(kY, tY, 0.5)
    self:AddLinePoint(kX, kY)
    self:AddLinePoint(Lerp(kX, tX, 1/3), midY)
    self:AddLinePoint(Lerp(kX, tX, 2/3), midY)
    self:AddLinePoint(tX, tY)
    self:DrawLine(function(bit, _, i, numSegments)
		local t = (i - 1) / (numSegments - 1)
    	local alpha = EasingUtil.InQuadratic(0 + 0.5 * math.sin(math.pi * t))
    	bit:SetAlpha(alpha)
	end)
end

---------------------------------------------------------------
-- Data handling
---------------------------------------------------------------

function Keyboard:OnTextChanged(text, pos, focus)
	local word = utf8.getword(text, pos);
	self.WordSuggester:OnWordChanged(word, focus)
	self.cachedFocusText = text; -- cache for dictionary
end

function Keyboard:OnDataLoaded(...)
	local defaultLayout = env:GetDefaultLayout()
	if not ConsolePort_KeyboardLayout
	or not env:ValidateLayout(ConsolePort_KeyboardLayout, defaultLayout) then
		ConsolePort_KeyboardLayout = defaultLayout;
	end
	if not ConsolePort_KeyboardMarkers then
		ConsolePort_KeyboardMarkers = {};
	end
	if not ConsolePort_KeyboardDictionary then
		ConsolePort_KeyboardDictionary = env.DictHandler:Generate()
	end

	env.Layout     = ConsolePort_KeyboardLayout;
	env.Markers    = CPAPI.Proxy(ConsolePort_KeyboardMarkers, env.DefaultMarkers);
	env.Dictionary = ConsolePort_KeyboardDictionary;

	env:ToggleObserver(true)
	self:OnVariableChanged()
	self:OnLayoutChanged()

	self:SetScript('OnDragStart', self.StartMoving)
	self:SetScript('OnDragStop', self.StopMoving)

	return CPAPI.BurnAfterReading;
end

function Keyboard:OnShow()
	if not IsGamePadFreelookEnabled() then
		return self:OnFocusChanged(nil)
	end
	SetCursorControl(true)  -- to snapshot the cursor position,
	self:MoveToCursor()     -- move to the cursor position,
	SetCursorControl(false) -- now we can disable it.
	self.Controls:SetHighlight(true)
end

function Keyboard:OnClick()
	self:OnFocusChanged(nil)
end

function Keyboard:OnLayoutChanged()
	self:ReleaseAll()
	self.numSets = #ConsolePort_KeyboardLayout;
	for i, set in ipairs(ConsolePort_KeyboardLayout) do
		local widget, newObj = self:Acquire(i)
		if newObj then
			widget:OnLoad()
			widget:SetFrameStrata(self:GetFrameStrata())
		end
		widget:SetPoint(self:GetPointForIndex(i, self.numSets, self:GetSize() * 0.62))
		widget:SetData(set)
		widget:Show()
	end
end

function Keyboard:OnVariableChanged()
	self.commands = {
		[db('keyboardEnterButton')]     = self.Enter;
		[db('keyboardEraseButton')]     = self.Erase;
		[db('keyboardSpaceButton')]     = self.Space;
		[db('keyboardEscapeButton')]    = self.Escape;
		[db('keyboardMoveLeftButton')]  = self.MoveLeft;
		[db('keyboardMoveRightButton')] = self.MoveRight;
		[db('keyboardNextWordButton')]  = self.NextWord;
		[db('keyboardPrevWordButton')]  = self.PrevWord;
		[db('keyboardAutoCorrButton')]  = self.AutoCorrect;
	};
	self.Controls:SetData({
		{ env.Cmd.Escape, };
		{ env.Cmd.Enter,  };
		{ env.Cmd.Space,  };
		{ env.Cmd.Erase,  };
	})
	self.Controls:SetState(1)
	-- update dictionary settings
	env.DictMatchPattern  = db('keyboardDictPattern');
	env.DictMatchAlphabet = db('keyboardDictAlphabet');
end

db:RegisterCallbacks(Keyboard.OnVariableChanged, Keyboard,
	'Settings/keyboardEraseButton',
	'Settings/keyboardEnterButton',
	'Settings/keyboardSpaceButton',
	'Settings/keyboardEscapeButton',
	'Settings/keyboardDictPattern',
	'Settings/keyboardDictAlphabet'
);

function Keyboard:PLAYER_LOGOUT()
	env.DictHandler:Normalize(env.Dictionary)
end

---------------------------------------------------------------
-- Init
---------------------------------------------------------------
Keyboard.Fill:SetVertexColor(0.12, 0.12, 0.12, .75)
Keyboard.Edge:SetVertexColor(0.35, 0.35, 0.35, .75)
Keyboard.Donut:SetVertexColor(0.35, 0.35, 0.35, .75)

Keyboard:EnableGamePadStick(true)
Keyboard:SetClampRectInsets(-70, 70, 70, -70)
CPAPI.Start(Keyboard)
CPAPI.Specialize(Keyboard.Controls, env.CharsetMixin)
CPFocusPoolMixin.CreateFramePool(Keyboard, 'PieMenu', 'CPKeyboardSet', env.CharsetMixin)