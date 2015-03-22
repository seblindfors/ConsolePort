local _
local _, G = ...;
local iterator = 1;

function ConsolePort:Gossip (key, state)
	local options = { GossipGreetingScrollChildFrame:GetChildren() };
	local count = GetNumGossipOptions() + GetNumGossipActiveQuests() + GetNumGossipAvailableQuests();
	local valid = {};
	for i, item in ipairs(options) do
		if item:IsShown() and item:IsObjectType("BUTTON") then
			tinsert(valid, i);
		end
	end
	if  key == G.PREPARE then
		iterator = 1;
		options[1]:LockHighlight();
		for i=2, 30 do
			options[i]:UnlockHighlight();
		end
	elseif key == G.UP and state == G.STATE_DOWN then
		iterator = iterator - 1;
		if iterator < 1 then iterator = count end
		if count > 0 then
			ConsolePort:Highlight(valid[iterator], options);
		end 
	elseif key == G.DOWN and state == G.STATE_DOWN then 
		iterator = iterator + 1;
		if iterator > count then iterator = 1 end
		if count > 0 then
			ConsolePort:Highlight(valid[iterator], options);
		end 
	elseif key == G.CIRCLE and state == G.STATE_UP and options[valid[iterator]] then
		options[valid[iterator]]:Click();
	elseif key == G.TRIANGLE then
		ConsolePort:Button(GossipFrameGreetingGoodbyeButton, state);
	end
end



