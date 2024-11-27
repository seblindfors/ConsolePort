---------------------------------------------------------------
-- Mouse state handler
---------------------------------------------------------------
-- Used to control mouse state depending on different scenarios
-- and allows customization to how the mouse and camera should
-- behave.

local _, db = ...;
local Mouse = db:Register('Mouse', CPAPI.CreateEventHandler({'Frame', '$parentMouseHandler', ConsolePort}, {
	'ACTIONBAR_HIDEGRID';
	'ACTIONBAR_SHOWGRID';
	'CURSOR_CHANGED';
	'GOSSIP_SHOW';
	'LOOT_OPENED';
	'PLAYER_STARTED_MOVING';
	'QUEST_GREETING';
	'UPDATE_BINDINGS';
}))

---------------------------------------------------------------
-- Upvalues since these will be called/checked frequently
---------------------------------------------------------------
local GameTooltip, UIParent, WorldFrame = GameTooltip, UIParent, WorldFrame;
local GetBindingAction, CreateKeyChord = GetBindingAction, CPAPI.CreateKeyChord;
local After, NewTimer, UnitExists = C_Timer.After, C_Timer.NewTimer, UnitExists;

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local MOUSEOVER_THROTTLE = 0.1;
local LCLICK_BINDING     = 'CAMERAORSELECTORMOVE';
local RCLICK_BINDING     = 'TURNORACTION';


---------------------------------------------------------------
-- Helpers: predicate evaluators
---------------------------------------------------------------
-- Args: button ID, followed by list of predicates.

local function is(_, pred, ...)
	if pred == nil then return true end
	return pred(_) and is(_, ...)
end

local function isnt(...)
	return not is(...)
end

local function either(_, pred,  ...)
	if pred == nil then return end
	return pred(_) or either(_, ...)
end

---------------------------------------------------------------
-- Timer
---------------------------------------------------------------
function Mouse:SetTimer(callback, time)
	self:ClearTimer(callback)
	if ( time > 0 ) then
		self[callback] = NewTimer(time, function()
			callback(self)
		end)
	end
end

function Mouse:ClearTimer(callback)
	if self[callback] then
		self[callback]:Cancel()
		self[callback] = nil;
	end
end

---------------------------------------------------------------
-- Console variables
---------------------------------------------------------------
local CVar_Sticks = db.Data.Cvar('GamePadCursorAutoDisableSticks')
local CVar_Target = db.Data.Cvar('GamePadCursorForTargeting')
local CVar_Center = db.Data.Cvar('GamePadCursorCentering')
local CVar_LClick = db.Data.Cvar('GamePadCursorLeftClick')
local CVar_RClick = db.Data.Cvar('GamePadCursorRightClick')
local Keys_Escape = db.Data.Select()

---------------------------------------------------------------
-- Predicates (should always return boolean)
---------------------------------------------------------------
local GamePadControl = IsGamePadFreelookEnabled;
local CursorControl  = IsGamePadCursorControlEnabled;
local MenuFrameOpen  = IsOptionFrameOpen;
local SpellTargeting = SpellIsTargeting;
---------------------------------------------------------------
local reverseMouseHandling = false;
local showMouseOverTooltip = true;

local GetClickCvar = function(isLeftClick)
	if reverseMouseHandling then
		isLeftClick = not isLeftClick;
	end
	return isLeftClick and CVar_LClick or CVar_RClick;
end
local GetClickBinding = function(isLeftClick)
	if reverseMouseHandling then
		isLeftClick = not isLeftClick;
	end
	return isLeftClick and LCLICK_BINDING or RCLICK_BINDING;
end
local IsClickAction = function(button, binding)
	local action = GetBindingAction(CreateKeyChord(button))
	return (action == '' or action == binding)
end
local IsAction = function(button, binding)
	return GetBindingAction(CreateKeyChord(button), true) == binding;
end
local LeftClick = function(button)
	local cvar, binding = GetClickCvar(true), GetClickBinding(true)
	if cvar:IsValue(button) then
		return IsClickAction(button, binding)
	end
	return IsAction(button, binding)
end;
local RightClick = function(button)
	local cvar, binding = GetClickCvar(false), GetClickBinding(false)
	if cvar:IsValue(button) then
		return IsClickAction(button, binding)
	end
	return IsAction(button, binding)
end
---------------------------------------------------------------
local MenuBinding    = function(button) return Keys_Escape:IsOption(CreateKeyChord(button)) end;
local CursorCentered = function() return CVar_Center:Get(true) end;
local TooltipShowing = function() return GameTooltip:IsOwned(UIParent) and GameTooltip:GetAlpha() == 1 end;
local IsMouseOver    = function() return UnitExists('mouseover') end;
local IsWorldFocus   = function() return WorldFrame:IsMouseMotionFocus() end;
local WorldInteract  = function() return TooltipShowing() and IsWorldFocus() end;
local WorldObjFocus  = function() return IsMouseOver() or WorldInteract() end;


---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Mouse:UPDATE_BINDINGS()
	Keys_Escape:SetOptions(db.Gamepad:GetBindingKey('TOGGLEGAMEMENU'))
end

function Mouse:CURRENT_SPELL_CAST_CHANGED()
	if SpellTargeting() then
		if (self.reticleOverride == nil) and (db('mouseFreeCursorReticle') ~= 0) then
			self.reticleOverride = CVar_Sticks:Get()
			CVar_Sticks:Set(0)
			self:SetFreeCursor()
		end
	elseif (self.reticleOverride ~= nil) then
		CVar_Sticks:Set(self.reticleOverride)
		self.reticleOverride = nil;
		self:SetCameraControl()
	end
end

function Mouse:PLAYER_STARTED_MOVING()
	if db('mouseHideCursorOnMovement') and self:ShouldClearCursorOnMovement() then
		self:SetCameraControl()
	end
end

do local function OnModifierUpdate(self, elapsed)
		self.tapTimer = self.tapTimer + elapsed;
		if self.tapNum > 1 then
			self.tapNum = 0;
			if CursorControl() then
				self:SetCenteredCursor()
			else
				self:SetFreeCursor()
			end
		end
		if self.tapTimer > self.tapWindow then
			self.tapNum = Clamp(self.tapNum - 1, 0, self.tapNum)
			self.tapTimer = self.tapTimer - self.tapWindow;
		end
	end

	function Mouse:MODIFIER_STATE_CHANGED(modifier, down)
		if (down == 1) and modifier:match(self.tapModifier) then
			self.tapTimer = 0;
			self.tapNum = self.tapNum + 1;
			self:SetScript('OnUpdate', OnModifierUpdate)
		end
	end
end

do local FreeCursorOnPickup = {
		[Enum.UICursorType.Flyout]   = true;
		[Enum.UICursorType.Item]     = true;
		[Enum.UICursorType.Macro]    = true;
		[Enum.UICursorType.Merchant] = true;
		[Enum.UICursorType.Mount]    = true;
		[Enum.UICursorType.Pet]      = true;
		[Enum.UICursorType.Spell]    = true;
		[Enum.UICursorType.Toy]      = true;
	};

	function Mouse:CURSOR_CHANGED(isDefault, cursorType, oldCursorType)
		if not db('mouseAutoControlPickup') then return end;

		if isDefault then
			if ( oldCursorType == self.cursorItemType ) and CursorControl() then
				self:SetCameraControl()
			end
			self.cursorItemType = nil;
		elseif FreeCursorOnPickup[cursorType] and GamePadControl() then
			self.cursorItemType = cursorType;
			self:SetFreeCursor()
		end

		db:TriggerEvent('OnCursorChanged', isDefault, cursorType, oldCursorType)
	end
end


-- Direct function calls from events
Mouse.ACTIONBAR_HIDEGRID = Mouse.SetCameraControl;
Mouse.ACTIONBAR_SHOWGRID = Mouse.SetFreeCursor;

Mouse.GOSSIP_SHOW        = Mouse.SetCameraControl;
Mouse.LOOT_OPENED        = Mouse.SetCameraControl;
Mouse.QUEST_GREETING     = Mouse.SetCameraControl;

---------------------------------------------------------------
-- Compounded queries
---------------------------------------------------------------
function Mouse:ShouldSetFreeCursor(_)
	return is(_, LeftClick) and isnt(_, SpellTargeting) and either(_, GamePadControl, CursorCentered)
end

function Mouse:ShouldSetCenteredCursor(_)
	return is(_, RightClick, GamePadControl) and isnt(_, CursorCentered)
end

function Mouse:ShouldSetCameraControl(_)
	return is(_, RightClick, GamePadControl, CursorCentered) and isnt(_, WorldObjFocus)
end

function Mouse:ShouldFreeCenteredCursor(_)
	return is(_, MenuBinding, GamePadControl, CursorCentered) and isnt(_, WorldObjFocus)
end

function Mouse:ShouldSetCursorWhenMenuIsOpen(_)
	return is(_, MenuBinding, MenuFrameOpen) and isnt(_, CursorControl)
end

function Mouse:ShouldClearCursorOnMovement()
	return is(nil, GamePadControl, CursorControl, IsWorldFocus)
end

---------------------------------------------------------------
-- Base control functions
---------------------------------------------------------------
function Mouse:SetCentered(enabled)
	CVar_Center:Set(db('mouseAlwaysCentered') or enabled)
	return self
end

function Mouse:SetCursorControl(enabled)
	-- We have to use a timer in order to not trigger a race condition between
	-- treating the left click as a button press and a mouse click.
	if enabled then
		if (self.cursorOverride == nil) then
			self.cursorOverride = self.reticleOverride or CVar_Sticks:Get()
		end
		CVar_Sticks:Set(0)
		After(db('mouseFreeCursorEnableTime'), function()
			SetGamePadCursorControl(true)
			if (self.cursorOverride) then
				CVar_Sticks:Set(self.cursorOverride)
				self.cursorOverride = nil;
			end
		end)
	else
		SetGamePadCursorControl(false)
		if (self.cursorOverride) then
			CVar_Sticks:Set(self.cursorOverride)
			self.cursorOverride = nil;
		end
	end
	return self
end

function Mouse:SetFreeLook(enabled)
	SetGamePadFreeLook(enabled)
	return self
end

---------------------------------------------------------------
-- Compounded control functions
---------------------------------------------------------------
function Mouse:SetFreeCursor()
	return self
		:SetFreeLook(false)
		:SetCentered(false)
		:SetCursorControl(true)
end

function Mouse:SetCenteredCursor()
	self:SetTimer(self.AttemptSetCameraControl, db('mouseAutoClearCenter'))
	return self
		:SetFreeLook(true)
		:SetCentered(true)
		:SetCursorControl(false)
end

function Mouse:SetCameraControl()
	self:ClearTimer(self.AttemptSetCameraControl)
	return self
		:SetFreeLook(true)
		:SetCentered(false)
		:SetCursorControl(false)
end

function Mouse:AttemptSetCameraControl(_)
	-- TODO: timeout should happen after mouseover ends
	if is(_, WorldObjFocus) then
		return self:SetTimer(self.AttemptSetCameraControl, db('mouseAutoClearCenter'))
	end
	return self:SetCameraControl()
end

---------------------------------------------------------------
-- Handlers
---------------------------------------------------------------
function Mouse:OnGamePadButtonDown(button)
	if self:ShouldSetFreeCursor(button) then
		return self:SetFreeCursor()
	end
	if self:ShouldSetCenteredCursor(button) then
		return self:SetCenteredCursor()
	end
	if self:ShouldSetCameraControl(button) then
		return self:SetCameraControl()
	end
	return self
end

function Mouse:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed;
	if self.elapsed > MOUSEOVER_THROTTLE then
		self.elapsed = 0;
		return
	end
	if showMouseOverTooltip and is(_, IsMouseOver, CursorCentered) then
		local guid = UnitGUID('mouseover')
		if ( self.mouseOverGUID ~= guid ) then
			self.mouseOverGUID = guid;
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip:SetUnit('mouseover')
		end
	elseif GameTooltip:IsOwned(self) then
		self.mouseOverGUID = nil;
		GameTooltip:Hide()
	end
end

---------------------------------------------------------------
-- Handler on/off
---------------------------------------------------------------
function Mouse:SetEnabled(enabled)
	self:EnableGamePadButton(enabled)
	if enabled then
		db:SetCVar('GamePadCursorAutoEnable', 0)
		db:SetCVar('CursorFreelookStartDelta', 0.001)
		db:SetCVar('GamePadCursorCenteredEmulation', 0)
	end
	(enabled and FrameUtil.RegisterFrameForEvents or FrameUtil.UnregisterFrameForEvents)(self, self.Events);
end

function Mouse:OnDataLoaded()
	self:SetEnabled(db('mouseHandlingEnabled'))
	self:OnVariableChanged()
end

function Mouse:OnVariableChanged()
	local modTapModifier = db('doubleTapModifier')
	if not modTapModifier:match('none') then
		self:RegisterEvent('MODIFIER_STATE_CHANGED')
		self.tapWindow = db('doubleTapTimeout')
		self.tapModifier = modTapModifier;
		self.tapTimer = 0;
		self.tapNum = 0;
	else
		self:UnregisterEvent('MODIFIER_STATE_CHANGED')
	end

	local useCursorReticleTargeting = db('mouseFreeCursorReticle')
	if (useCursorReticleTargeting ~= 0) then
		self:RegisterEvent('CURRENT_SPELL_CAST_CHANGED')
	else
		self:UnregisterEvent('CURRENT_SPELL_CAST_CHANGED')
	end
	CVar_Target:Set(useCursorReticleTargeting)
	reverseMouseHandling = db('mouseHandlingReversed')
	showMouseOverTooltip = db('mouseShowCenterTooltip')
end

function Mouse:OnHintsFocus(_, disableMouseHandling)
	if db('mouseHandlingEnabled') and not disableMouseHandling then
		self:SetCameraControl()
	end
end

db:RegisterCallback('Settings/mouseHandlingEnabled', Mouse.SetEnabled, Mouse)
db:RegisterCallback('OnHintsFocus', Mouse.OnHintsFocus, Mouse)
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
db:RegisterCallbacks(Mouse.OnVariableChanged, Mouse,
	'Settings/doubleTapModifier',
	'Settings/doubleTapTimeout',
	'Settings/mouseFreeCursorReticle',
	'Settings/mouseHandlingReversed',
	'Settings/mouseShowCenterTooltip'
);
---------------------------------------------------------------
Mouse:SetScript('OnGamePadButtonDown', Mouse.OnGamePadButtonDown)
Mouse:SetScript('OnUpdate', Mouse.OnUpdate)
Mouse:EnableGamePadButton(false)
Mouse:SetPropagateKeyboardInput(true)