---------------------------------------------------------------
-- UpdateDispatcher
---------------------------------------------------------------
local addOn = ...
local UpdateDispatcher = CreateFrame("Frame", addOn.."Dispatcher")
local Keyboard = ConsolePortKeyboard
local KeyBoardFocus

function UpdateDispatcher:OnUpdate(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		KeyBoardFocus = GetCurrentKeyBoardFocus()
		if KeyBoardFocus and KeyBoardFocus:GetObjectType() == "EditBox" and Keyboard.Focus ~= KeyBoardFocus then
			KeyBoardFocus:SetAutoFocus(false)
			Keyboard:SetFocus(KeyBoardFocus)
		elseif Keyboard.Focus and not Keyboard.Focus:IsVisible() then
			Keyboard.Focus = nil
			Keyboard:Hide()
		end
		self.Timer = self.Timer - 0.1
	end
end

UpdateDispatcher.Timer = 0
UpdateDispatcher:SetScript("OnUpdate", UpdateDispatcher.OnUpdate)