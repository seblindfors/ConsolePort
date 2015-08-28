local _, db = ...;
local time = 0;
local hold = 0;
local keyDown = false;
local keyHeldDown = false;

local Left = StackSplitLeftButton
local Right = StackSplitRightButton


StackSplitFrame:HookScript("OnUpdate", function(self,elapsed)
	hold = hold + elapsed
	if Left:GetButtonState() == "PUSHED" then
		keyDown = Left
	elseif Right:GetButtonState() == "PUSHED" then
		keyDown = Right
	else
		keyDown = nil
	end
	if 	keyDown and
		hold >= 0.3 then
		keyHeldDown = true
	elseif not keyDown then
		keyHeldDown = false
		hold = 0
	end
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