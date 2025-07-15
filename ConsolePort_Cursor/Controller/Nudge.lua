---------------------------------------------------------------
-- Nudge controller
---------------------------------------------------------------
-- Nudges the cursor position using a combination of a modifier
-- and the directional pad.

local Nudge, Node, Lerp, sqrt, band, env, db =
	CPAPI.CreateEventHandler({'Frame', '$parentUINudgeHandler', ConsolePort}),
	LibStub('ConsolePortNode'),
	FrameDeltaLerp, sqrt, bit.band,
	CPAPI.GetEnv(...);

---------------------------------------------------------------
-- Controls
---------------------------------------------------------------
Nudge.Predicates = {
	SHIFT = IsShiftKeyDown;
	CTRL  = IsControlKeyDown;
	ALT   = IsAltKeyDown;
};

Nudge.Direction = {
	PADDUP    = 0x01;
	PADDRIGHT = 0x02;
	PADDDOWN  = 0x04;
	PADDLEFT  = 0x08;
};

Nudge.Flags = CPAPI.CreateFlagClosures(Nudge.Direction);

---------------------------------------------------------------
-- Initialization
---------------------------------------------------------------
function Nudge:OnDataLoaded()
	Mixin(self, Vector2DMixin)
	self.Cursor = env.Cursor;
	self.Cursor:HookScript('OnHide', GenerateClosure(self.OnCursorHide, self))
	self.Cursor:HookScript('OnShow', GenerateClosure(self.OnCursorShow, self))
	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)
	self:SetScript('OnGamePadButtonUp',   self.OnGamePadButtonUp)
	self:OnCursorHide()
	self:OnVariablesChanged()
	return CPAPI.BurnAfterReading;
end

function Nudge:OnVariablesChanged()
	local modifier = db('UImodifierNudge');
	self.IsEnabled = CPAPI.Static(db('UImodifierCommands') ~= modifier);
	self.IsActive  = self.Predicates[modifier] or CPAPI.Static(false);
end

db:RegisterCallbacks(Nudge.OnVariablesChanged, Nudge,
	'Settings/UImodifierCommands',
	'Settings/UImodifierNudge'
);

---------------------------------------------------------------
-- Handlers
---------------------------------------------------------------
function Nudge:OnCursorShow()
	if self:IsEnabled() then
		self:RegisterEvent('MODIFIER_STATE_CHANGED')
	end
end

function Nudge:OnCursorHide()
	self:UnregisterAllEvents()
	self:EnableGamePadButton(false)
	self:Reset()
end

function Nudge:IsAnyButtonDown()
	return self.input ~= 0;
end

function Nudge:OnGamePadButtonDown(button)
	local closure = self.Flags[button];
	if not closure then return self:SetPropagateKeyboardInput(true) end;
	self:UpdateInput(closure, true);
	self:SetScript('OnUpdate', self.UpdatePosition)
	self:SetPropagateKeyboardInput(false)
end

function Nudge:OnGamePadButtonUp(button)
	local closure = self.Flags[button];
	if not closure then return end;
	self:UpdateInput(closure, false)
	if not self:IsAnyButtonDown() then
		self:Reset()
	end
end

function Nudge:Reset()
	self.input = 0;
	self:SetXY(0, 0)
	self:SetScript('OnUpdate', nil)
end

---------------------------------------------------------------
-- Movement
---------------------------------------------------------------
function Nudge:UpdateInput(direction, isDown)
	self.input = direction(self.input, isDown);
end

function Nudge:UpdatePosition()
	local cursor = self.Cursor;
	if self:IsAnyButtonDown() and cursor:IsVisible() then
		local nX, nY = self:GetDirectionVector(self.input)
		nX = Lerp(self.x, nX, .075);
		nY = Lerp(self.y, nY, .075);
		self:SetXY(nX, nY)

		local delta  = self:GetDelta()
		local cX, cY = Node.GetCenter(cursor)
		local tX, tY = cX + (nX * delta), cY + (nY * delta);

		local customAnchor, forceAnchor = cursor:GetCustomAnchor()
		if not customAnchor or not forceAnchor then
			customAnchor = {'CENTER', UIParent, 'BOTTOMLEFT', tX, tY};
		else
			customAnchor[4], customAnchor[5] = tX, tY;
		end
		cursor:SetCustomAnchor(customAnchor, true)
	end
end

function Nudge:GetDelta()
	local x, y = UIParent:GetSize()
	return sqrt(x * y) * 0.0025;
end

function Nudge:GetDirectionVector(i)
	local d = self.Direction;
	local x = (band(i, d.PADDRIGHT) > 0 and 1 or 0) - (band(i, d.PADDLEFT) > 0 and 1 or 0)
	local y = (band(i, d.PADDUP)    > 0 and 1 or 0) - (band(i, d.PADDDOWN) > 0 and 1 or 0)
	return x, y;
end

function Nudge:MODIFIER_STATE_CHANGED()
	local isActive = self.IsActive()
	self:EnableGamePadButton(isActive)

	if isActive then return end;

	local cursor = self.Cursor;
	if not cursor:GetCustomAnchor() then return end;

	local cX, cY = Node.GetCenter(cursor)
	cursor:ScanUI()
	cursor:SetCustomAnchor(nil)

	local target = Node.NavigateToArbitraryCandidate(nil, nil, cX, cY, true)
	if target then
		cursor:SetCurrent(target)
		cursor:SelectAndPosition(cursor:GetSelectParams(target, true, true))
	end
	self:Reset()
end