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
	'CURRENT_SPELL_CAST_CHANGED';
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
local NewTimer, GetMouseFocus = C_Timer.NewTimer, GetMouseFocus;
local UnitExists, GetSpellInfo = UnitExists, GetSpellInfo;
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo;

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local CAST_INFO_SPELLID_OFFSET = 9;
local SPELLID_CAST_TIME_OFFSET = 4;
local ALWAYS_TURN_CAMERA_VALUE = 2;
local LCLICK_BINDING = 'CAMERAORSELECTORMOVE';
local RCLICK_BINDING = 'TURNORACTION';


---------------------------------------------------------------
-- Helpers: predicate evaluators
---------------------------------------------------------------
-- These functions are used to write clear, dynamic statements
-- on combinations of different events. Without these, compound
-- boolean expressions would be hard to understand.
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
local CVar_Camera = db.Data.Cvar('GamePadTurnWithCamera')
local CVar_Follow = db.Data.Cvar('CameraFollowOnStick')
local CVar_Sticks = db.Data.Cvar('GamePadCursorAutoDisableSticks')
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
local IsClickAction = function(button, binding)
	local action = GetBindingAction(CreateKeyChord(button))
	return (action == '' or action == binding)
end
local IsAction = function(button, binding)
	return GetBindingAction(CreateKeyChord(button), true) == binding;
end
local LeftClick = function(button)
	if CVar_LClick:IsValue(button) then
		return IsClickAction(button, LCLICK_BINDING)
	end
	return IsAction(button, LCLICK_BINDING)
end;
local RightClick = function(button)
	if CVar_RClick:IsValue(button) then
		return IsClickAction(button, RCLICK_BINDING)
	end
	return IsAction(button, RCLICK_BINDING)
end
---------------------------------------------------------------
local MenuBinding    = function(button) return Keys_Escape:IsOption(CreateKeyChord(button)) end;
local CursorCentered = function() return CVar_Center:Get(true) end;
local TooltipShowing = function() return GameTooltip:IsOwned(UIParent) and GameTooltip:GetAlpha() == 1 end;
local IsWorldFocus   = function() return GetMouseFocus() == WorldFrame end;
local WorldInteract  = function() return TooltipShowing() and IsWorldFocus() end;
local MouseOver      = function() return UnitExists('mouseover') or WorldInteract() end;


---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Mouse:UPDATE_BINDINGS()
	Keys_Escape:SetOptions(db.Gamepad:GetBindingKey('TOGGLEGAMEMENU'))
end

-- Temporary solution to fix problems with casters unable to face
-- their intended target because of face movement.
function Mouse:UNIT_SPELLCAST_START()
	if self.fmVehicleOverride then return end;
	if (self.fmSpellOverride == nil) then
		self.fmSpellOverride = CVar_Camera:Get()
		CVar_Camera:Set(ALWAYS_TURN_CAMERA_VALUE)
	end
end

function Mouse:UNIT_SPELLCAST_STOP()
	if self.fmVehicleOverride then return end;
	if (self.fmSpellOverride ~= nil) then
		CVar_Camera:Set(self.fmSpellOverride)
		self.fmSpellOverride = nil;
	end
end

function Mouse:UNIT_ENTERING_VEHICLE()
	if (self.fmVehicleOverride == nil) then
		self:UNIT_SPELLCAST_STOP()
		self.fmVehicleOverride = CVar_Camera:Get()
		CVar_Camera:Set(ALWAYS_TURN_CAMERA_VALUE)
	end
end

function Mouse:UNIT_EXITING_VEHICLE()
	if (self.fmVehicleOverride ~= nil) then
		CVar_Camera:Set(self.fmVehicleOverride)
		self.fmVehicleOverride = nil;
	end
end

Mouse.UNIT_SPELLCAST_CHANNEL_START = Mouse.UNIT_SPELLCAST_START;
Mouse.UNIT_SPELLCAST_CHANNEL_STOP  = Mouse.UNIT_SPELLCAST_STOP;

function Mouse:CURRENT_SPELL_CAST_CHANGED()
	if SpellTargeting() then
		if (self.reticleOverride == nil) and db('mouseFreeCursorReticle') then
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

function Mouse:PLAYER_MOUNT_DISPLAY_CHANGED()
	local isMounted = IsMounted()
	if (isMounted ~= self.mountedState) then
		CVar_Follow:Set(isMounted and 1 or 0)
		self.mountedState = isMounted;
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
	return is(_, RightClick, GamePadControl, CursorCentered) and isnt(_, MouseOver)
end

function Mouse:ShouldFreeCenteredCursor(_)
	return is(_, MenuBinding, GamePadControl, CursorCentered) and isnt(_, MouseOver)
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
	SetGamePadCursorControl(enabled)
	return self
end

function Mouse:SetFreeLook(enabled)
	SetGamePadFreeLook(enabled)
	return self
end

function Mouse:SetPropagation(enabled)
	self:SetPropagateKeyboardInput(enabled)
	return self
end

---------------------------------------------------------------
-- Compounded control functions
---------------------------------------------------------------
function Mouse:SetFreeCursor()
	return self
		:SetFreeLook(true)
		:SetCentered(false)
		:SetCursorControl(true)
		:SetPropagation(false)
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
	if is(_, MouseOver) then
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
	--[[
	if self:ShouldFreeCenteredCursor(button) then
		return self:SetCentered(false):SetCursorControl(true)
	end
	if self:ShouldSetCursorWhenMenuIsOpen(button) then
		return self:SetPropagation(false):SetCursorControl(true)
	end]]
	return self:SetPropagation(true)
end

---------------------------------------------------------------
-- Handler on/off
---------------------------------------------------------------
function Mouse:SetEnabled(enabled)
	self:EnableGamePadButton(enabled)
	if enabled then
		SetCVar('GamePadCursorAutoEnable', 0)
		SetCVar('CursorFreelookStartDelta', 0.001)
		SetCVar('GamePadCursorCenteredEmulation', 0)
	end
	(enabled and FrameUtil.RegisterFrameForEvents or FrameUtil.UnregisterFrameForEvents)(self, self.Events);
end

function Mouse:OnDataLoaded()
	self:SetEnabled(db('mouseHandlingEnabled'))
	for i, event in ipairs({
		'UNIT_SPELLCAST_CHANNEL_START';
		'UNIT_SPELLCAST_CHANNEL_STOP';
		'UNIT_SPELLCAST_START';
		'UNIT_SPELLCAST_STOP';
		'UNIT_ENTERING_VEHICLE';
		'UNIT_EXITING_VEHICLE';
	}) do self:RegisterUnitEvent(event, 'player') end
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

	if db('mouseFollowOnStickMounted') then
		self.mountedState = nil;
		self:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
		self:PLAYER_MOUNT_DISPLAY_CHANGED()
	else
		self:UnregisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
	end
end

db:RegisterCallback('Settings/mouseHandlingEnabled', Mouse.SetEnabled, Mouse)
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
db:RegisterCallbacks(Mouse.OnVariableChanged, Mouse, 
	'Settings/mouseFollowOnStickMounted',
	'Settings/doubleTapModifier',
	'Settings/doubleTapTimeout'
);
---------------------------------------------------------------
Mouse:SetScript('OnGamePadButtonDown', Mouse.OnGamePadButtonDown)
Mouse:EnableGamePadButton(false)
Mouse:SetPropagation(true)