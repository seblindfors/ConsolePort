local _, G = ...;
local KEY = G.KEY;
local currentInput = nil;
local keyDown = false;
local keyHeldDown = false;
local time = 0;
local hold = 0;

StackSplitFrame:HookScript("OnUpdate", function(self,elapsed)
	if self:IsVisible() then
		hold = hold + elapsed;
		if 	keyDown and
			hold >= 0.3 then
			keyHeldDown = true;
		elseif not keyDown then
			keyHeldDown = false;
			hold = 0;
		end
		local exponent = math.exp(math.floor(hold));
		if keyHeldDown then
			time = time + elapsed;
			while time > 0.1 do
				if 	currentInput == KEY.RIGHT then
					for i=1, exponent do
						StackSplitRightButton:Click();
					end
				elseif currentInput == KEY.LEFT then
					for i=1, exponent do
						StackSplitLeftButton:Click();
					end
				end
				time = time - 0.1;
			end
		end
	end
end);

function ConsolePort:Stack (key, state)
	currentInput = key;
	keyDown = (state == KEY.STATE_DOWN);
	if 		key == KEY.RIGHT then
		ConsolePort:Button(StackSplitRightButton, state);
	elseif	key == KEY.LEFT then
		ConsolePort:Button(StackSplitLeftButton, state);
	elseif	key == KEY.SQUARE then
		ConsolePort:Button(StackSplitOkayButton, state);
		if state == KEY.STATE_UP then MouselookStop(); end;
	elseif	key == KEY.CIRCLE then
		ConsolePort:Button(StackSplitCancelButton, state);
	end
end


