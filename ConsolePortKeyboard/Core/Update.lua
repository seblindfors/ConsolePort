---------------------------------------------------------------
-- Update handler to grab the current keyboard focus
---------------------------------------------------------------
local Keyboard = ConsolePortKeyboard
local GetFocus = GetCurrentKeyBoardFocus
local isEnabled = true
local focus

local function UpdateKeyboardFocus(self, elapsed)
	if isEnabled then
		focus = GetFocus()
		if focus and focus:IsObjectType("EditBox") and Keyboard.Focus ~= focus then
			Keyboard:SetFocus(focus)
		elseif not focus and Keyboard.Focus then
			Keyboard:CLOSE()
		end
	end
end

function Keyboard:SetEnabled(state)
	isEnabled = state
	if isEnabled then
		ConsolePort:AddUpdateSnippet(UpdateKeyboardFocus)
	else
		ConsolePort:RemoveUpdateSnippet(UpdateKeyboardFocus)
		if Keyboard.Focus then
			Keyboard:CLOSE()
		end
	end
end