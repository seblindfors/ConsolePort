local _, db = ...;
local ESCAPE_KEY, MouseHandle = {}, CPAPI.CreateEventHandler({'Frame', '$parentMouseHandle', ConsolePort}, {
	'UPDATE_BINDINGS';
})

local function is(_, pred, ...)
	if pred == nil then return true end
	return pred(_) and is(_, ...)
end

local function isnt(...)
	return not is(...)
end

local function either(_, pred,  ...)
	if pred == nil then return true end
	return pred(_) or either(_, ...)
end


local GetCVar, GetCVarBool, SetCVar = GetCVar, GetCVarBool, SetCVar;
local CreateKeyChordString = CreateKeyChordStringUsingMetaKeyState;
local SetGamePadCursorControl = SetGamePadCursorControl;

function MouseHandle:UPDATE_BINDINGS()
	wipe(ESCAPE_KEY)
	for _, binding in ipairs({db('Gamepad'):GetBindingKey('TOGGLEGAMEMENU')}) do
		ESCAPE_KEY[binding] = true
	end

end
---------------------------------------------------------------
local CameraControl   = IsGamePadFreelookEnabled;
local CursorControl   = IsGamePadCursorControlEnabled;
local MenuFrameOpen   = IsOptionFrameOpen;
local SpellTargeting  = SpellIsTargeting;
local LeftClick       = function(button) return button == GetCVar('GamePadCursorLeftClick') end;
local RightClick      = function(button) return button == GetCVar('GamePadCursorRightClick') end;
local MenuBinding     = function(button) return ESCAPE_KEY[CreateKeyChordString(button)] end;
local CursorCentered  = function() return GetCVarBool('GamePadCursorCentering') end;
local WorldInteract   = function() return (GameTooltip:IsOwned(UIParent) and GameTooltip:GetAlpha() == 1 and GetMouseFocus() == WorldFrame) end;
local MouseOver       = function() return (UnitExists('mouseover') or WorldInteract()) end;
---------------------------------------------------------------

-- Compounded queries:
function MouseHandle:ShouldSetCenteredCursor(_)
	return is(_, RightClick, CameraControl) and isnt(_, CursorCentered)
end

function MouseHandle:ShouldClearCenteredCursor(_)
	return is(_, RightClick, CameraControl, CursorCentered) and isnt(_, MouseOver)
end

function MouseHandle:ShouldFreeCenteredCursor(_)
	return is(_, MenuBinding, CameraControl, CursorCentered) and isnt(_, MouseOver)
end

function MouseHandle:ShouldSetCursorWhenMenuIsOpen(_)
	return is(_, MenuBinding, MenuFrameOpen) and isnt(_, CursorControl)
end

function MouseHandle:ShouldSetFreeCursor(_)
	return is(_, LeftClick) and isnt(_, SpellIsTargeting) and either(_, CameraControl, CursorCentered)
end

-- Base control functions: (there seems to be bugs with these functions)
function MouseHandle:SetCentered(enabled)
	SetCVar('GamePadCursorCentering', enabled)
	return self
end

function MouseHandle:SetCursorControl(enabled)
	SetGamePadCursorControl(enabled)
	return self
end

function MouseHandle:SetFreeLook(enabled)
	SetGamePadFreeLook(enabled)
	return self
end

function MouseHandle:SetPropagation(enabled)
	self:SetPropagateKeyboardInput(enabled)
	return self
end

-- Compounded control functions:
function MouseHandle:SetFreeCursor()
	return self
		:SetCentered(false)
		:SetFreeLook(false)
		:SetCursorControl(true)
end

function MouseHandle:SetCenteredCursor()
	return self
		:SetCentered(true)
		:SetFreeLook(false)
		:SetCursorControl(false)
end

function MouseHandle:ClearCenteredCursor()
	--print('===== STATE =====')
	return self
		:SetCentered(false)
		:SetFreeLook(false)
end

-- Handlers:
function MouseHandle:OnGamePadButtonDown(button)
	if self:ShouldSetFreeCursor(button) then
		return self:SetFreeCursor()
	end
	-- TODO: check bugs with blizz, expand on concept
	if self:ShouldSetCenteredCursor(button) then
		return self:SetCenteredCursor()
	end
	if self:ShouldClearCenteredCursor(button) then
		return self:ClearCenteredCursor()
	end--[[
	if self:ShouldFreeCenteredCursor(button) then
		return self:SetCentered(false):SetCursorControl(true)
	end
	if self:ShouldSetCursorWhenMenuIsOpen(button) then
		return self:SetPropagation(false):SetCursorControl(true)
	end]]
	return self:SetPropagation(true)
end

function MouseHandle:OnGamePadButtonUp(button)
	return self:SetPropagation(true)
end

function MouseHandle:SetEnabled(enabled)
	self:EnableGamePadButton(enabled)
	if enabled then
		SetCVar('GamePadCursorAutoEnable', 0)
	end
end

function MouseHandle:OnDataLoaded()
	self:SetEnabled(db('mouseHandlingEnabled'))
end

db:RegisterVarCallback('Settings/mouseHandlingEnabled', MouseHandle.SetEnabled, MouseHandle)
CPAPI.Start(MouseHandle)
MouseHandle:EnableGamePadButton(false)
MouseHandle:SetPropagation(true)