---------------------------------------------------------------
-- Update handler to grab the current keyboard focus
---------------------------------------------------------------
local Keyboard = ConsolePortKeyboard
local isEnabled = true
local focus

local function UpdateKeyboardFocus(self, elapsed)
	if isEnabled then
		focus = GetCurrentKeyBoardFocus()
		if focus and focus:IsObjectType("EditBox") and Keyboard.Focus ~= focus then
			Keyboard:SetFocus(focus)
		elseif not focus and Keyboard.Focus then
			Keyboard:CLOSE()
		end
	end
end

function Keyboard:SetEnabled(newstate)
	isEnabled = newstate
	if isEnabled then
		ConsolePort:AddUpdateSnippet(UpdateKeyboardFocus)
	else
		ConsolePort:RemoveUpdateSnippet(UpdateKeyboardFocus)
		if Keyboard.Focus then
			Keyboard:CLOSE()
		end
	end
end