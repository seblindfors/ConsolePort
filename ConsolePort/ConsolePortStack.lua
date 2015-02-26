local _
local _, G = ...;
function ConsolePort:Stack (key, state)
	if 		key == G.RIGHT then
		ConsolePort:Button(StackSplitRightButton, state);
	elseif	key == G.LEFT then
		ConsolePort:Button(StackSplitLeftButton, state);
	elseif	key == G.SQUARE then
		ConsolePort:Button(StackSplitOkayButton, state);
		if state == G.STATE_UP then MouselookStop(); end;
	elseif	key == G.CIRCLE then
		ConsolePort:Button(StackSplitCancelButton, state);
	end
end


