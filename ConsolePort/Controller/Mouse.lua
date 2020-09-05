local _, db = ...;
local ESCAPE_KEY, MouseHandle = {}, CPAPI.CreateEventHandler({'Frame', '$parentMouseHandle', ConsolePort}, {
	'UPDATE_BINDINGS';
})

local GetCVar, GetCVarBool, SetCVar = GetCVar, GetCVarBool, SetCVar;
local CreateKeyChordString = CreateKeyChordStringUsingMetaKeyState;
local IsOptionFrameOpen = IsOptionFrameOpen;
local IsGamePadCursorControlEnabled = IsGamePadCursorControlEnabled;
local IsGamePadFreelookEnabled = IsGamePadFreelookEnabled;
local SetGamePadCursorControl = SetGamePadCursorControl;

function MouseHandle:UPDATE_BINDINGS()
	wipe(ESCAPE_KEY)
	for _, binding in ipairs({db('Gamepad'):GetBindingKey('TOGGLEGAMEMENU')}) do
		ESCAPE_KEY[binding] = true
	end
end

function MouseHandle:IsRightClick(button)
	return button == GetCVar('GamePadCursorRightClick')
end

function MouseHandle:IsMenuButton(button)
	return ESCAPE_KEY[CreateKeyChordString(button)]
end

function MouseHandle:IsCursorControl()
	return IsGamePadCursorControlEnabled()
end

function MouseHandle:IsCameraControl()
	return IsGamePadFreelookEnabled()
end

function MouseHandle:IsAutoCentered()
	return GetCVarBool('GamePadCursorCentering')
end

function MouseHandle:IsMenuOpen()
	return IsOptionFrameOpen()
end

function MouseHandle:SetCentered(enabled)
	SetCVar('GamePadCursorCentering', enabled)
	return self
end

function MouseHandle:SetCursorControl(enabled)
	SetGamePadCursorControl(enabled)
	return self
end

function MouseHandle:SetPropagation(enabled)
	self:SetPropagateKeyboardInput(enabled)
	return self
end

function MouseHandle:OnGamePadButtonDown(button)
	-- TODO: check bugs with blizz, expand on concept
	if self:IsRightClick(button) and self:IsCameraControl() and not self:IsAutoCentered() then
		return self:SetCentered(true):SetCursorControl(false)
	end
	if self:IsMenuButton(button) and self:IsCameraControl() and self:IsAutoCentered() then
		return self:SetCentered(false):SetCursorControl(true)
	end
	if self:IsMenuButton(button) and self:IsMenuOpen() and not self:IsCameraControl() then
		return self:SetPropagation(false):SetCursorControl(true)
	end
	return self:SetPropagation(true)
end

MouseHandle:EnableGamePadButton(true)
MouseHandle:SetPropagateKeyboardInput(true)
CPAPI.Start(MouseHandle)

--SetGamePadCursorControl(true)