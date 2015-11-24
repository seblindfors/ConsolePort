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
		elseif Keyboard.Focus and not Keyboard.Focus:IsVisible() then
			Keyboard:CLOSE()
		end
	end
end

function Keyboard:SetEnabled(newstate)
	isEnabled = newstate
	if not isEnabled and Keyboard.Focus then
		Keyboard:CLOSE()
	end
end

ConsolePort:AddUpdateSnippet(UpdateKeyboardFocus)