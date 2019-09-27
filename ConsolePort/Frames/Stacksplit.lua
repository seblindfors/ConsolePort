---------------------------------------------------------------
-- Stacksplit.lua: Stack splitting convenience script
---------------------------------------------------------------
-- Removes the need to keep spam clicking the increase/decrease
-- buttons on the stack split frame. The user may instead hold
-- the button to adjust the value. Longer hold time increases
-- the value amount ticked per operation.

local time, hold = 0, 0
local keyDown, keyHeldDown = false, false
local Left  = StackSplitFrame.LeftButton or StackSplitLeftButton
local Right = StackSplitFrame.RightButton or StackSplitRightButton

local oldNode

StackSplitFrame:HookScript('OnShow', function(self)
	oldNode = ConsolePort:GetCurrentNode()
	ConsolePort:SetCurrentNode(StackSplitCancelButton)
end)

StackSplitFrame:HookScript('OnHide', function(self)
	if oldNode then
		ConsolePort:SetCurrentNode(oldNode)
		oldNode = nil
	end
end)

if Left and Right then
	StackSplitFrame:HookScript('OnUpdate', function(self,elapsed)
		keyDown = Left:GetButtonState() == 'PUSHED' and Left or Right:GetButtonState() == 'PUSHED' and Right
		hold = keyDown and hold + elapsed or 0
		keyHeldDown = keyDown and hold >= 0.3
		local exponent = math.exp(math.floor(hold))
		if keyHeldDown then
			time = time + elapsed
			while time > 0.1 do
				for i=1, exponent do
					keyDown:Click()
				end
				time = time - 0.1
			end
		end
	end)
end