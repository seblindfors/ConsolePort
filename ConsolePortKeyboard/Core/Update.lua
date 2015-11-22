---------------------------------------------------------------
-- UpdateDispatcher
---------------------------------------------------------------
local addOn = ...
local UpdateDispatcher = CreateFrame("Frame", addOn.."Dispatcher")
local Keyboard = ConsolePortKeyboard
local focus

function UpdateDispatcher:OnUpdate(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		focus = GetCurrentKeyBoardFocus()
		if focus and focus:IsObjectType("EditBox") and Keyboard.Focus ~= focus then
			Keyboard:SetFocus(focus)
		elseif Keyboard.Focus and not Keyboard.Focus:IsVisible() then
			Keyboard:CLOSE()
		end
		self.Timer = self.Timer - 0.1
	end
end

UpdateDispatcher.Timer = 0
UpdateDispatcher:SetScript("OnUpdate", UpdateDispatcher.OnUpdate)