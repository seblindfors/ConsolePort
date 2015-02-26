local _
local _, G = ...;
local iterator = 1;

function ConsolePort:TaxiFindClosest(key, nodes)
	local this 	= nodes[iterator];
	local thisY = this:GetTop();
	local thisX = this:GetLeft();
	local nodeY = 1000;
	local nodeX = 1000;
	local swap 	= false;
	for i, destination in ipairs(nodes) do
		local destY = destination:GetTop();
		local destX = destination:GetLeft();
		local diffY = abs(thisY-destY);
		local diffX = abs(thisX-destX);
		local total = diffX + diffY;
		if total < nodeX + nodeY then
			if 	key == G.UP then
				if 	diffY > diffX and 	-- up/down
					destY > thisY then 	-- up
					swap = true;
				end
			elseif key == G.DOWN then
				if 	diffY > diffX and 	-- up/down
					destY < thisY then 	-- down
					swap = true;
				end
			elseif key == G.LEFT then
				if 	diffY < diffX and 	-- left/right
					destX < thisX then 	-- left
					swap = true;
				end
			elseif key == G.RIGHT then
				if 	diffY < diffX and 	-- left/right
					destX > thisX then 	-- right
					swap = true;
				end
			end
		end
		if swap then
			nodeX = diffX;
			nodeY = diffY;
			iterator = i;
			swap = false;
		end
	end
end

function ConsolePort:Taxi (key, state)
	local options = { TaxiFrame:GetChildren() };
	local nodes = {};
	for i, node in ipairs(options) do
		if 	node:IsObjectType("Button") and
			node:IsShown() and 
			i ~= 1 then
			table.insert(nodes, node);
		end
	end
	if 	key == G.PREPARE then
		for i, node in ipairs(nodes) do
			if TaxiNodeGetType(node:GetID()) == "CURRENT" then
				iterator = i;
			end
		end
	elseif	key == G.CIRCLE and state == G.STATE_DOWN then
		nodes[iterator]:Click();
	elseif	(key == G.TRIANGLE or key == G.SQUARE) and state == G.STATE_DOWN then
		CloseTaxiMap();
		return;
	elseif state == G.STATE_DOWN then
		ConsolePort:TaxiFindClosest(key, nodes);
	end
	if key ~= G.CIRCLE and key ~= G.TRIANGLE then
		ConsolePort:Highlight(iterator, nodes);
		nodes[iterator]:GetScript("OnEnter")(nodes[iterator]);
		if TaxiNodeGetType(nodes[iterator]:GetID()) ~= "CURRENT" then
			GameTooltip:AddLine(CLICK_TAKETAXI, 1,1,1);
			GameTooltip:Show();
		end
	end
end