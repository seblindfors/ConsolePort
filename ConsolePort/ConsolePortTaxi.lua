local _
local _, G = ...;
local iterator = 1;
local nodes = {};
local points = {};

TaxiFrame:HookScript("OnHide", function()
	nodes = {}; points = {};
end);

local function TaxiFindClosestNode(key)
	local this 	= nodes[iterator];
	local thisY = points[iterator].Y;
	local thisX = points[iterator].X;
	local nodeY = 1000;
	local nodeX = 1000;
	local swap 	= false;
	for i, destination in ipairs(nodes) do
		local destY = points[i].Y;
		local destX = points[i].X;
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
	if 	key == G.PREPARE then 
		for i, node in ipairs({TaxiFrame:GetChildren()}) do
			if 	node:IsObjectType("Button") and
				node:IsShown() and 
				i ~= 1 then
				table.insert(nodes, node);
				table.insert(points, {X = node:GetLeft(), Y = node:GetTop()});
			end
		end
		for i, node in ipairs(nodes) do
			if TaxiNodeGetType(node:GetID()) == "CURRENT" then
				iterator = i;
			end
		end
	elseif	key == G.CIRCLE then
		if state == G.STATE_DOWN then
			nodes[iterator]:Click();
		end
		return;
	elseif	(key == G.TRIANGLE or key == G.SQUARE) and state == G.STATE_DOWN then
		CloseTaxiMap();
		return;
	elseif state == G.STATE_DOWN then
		TaxiFindClosestNode(key);
	end
	ConsolePort:Highlight(iterator, nodes);
	nodes[iterator]:GetScript("OnEnter")(nodes[iterator]);
	if TaxiNodeGetType(nodes[iterator]:GetID()) ~= "CURRENT" then
		GameTooltip:AddLine(G.CLICK_TAKETAXI, 1,1,1);
		GameTooltip:Show();
	end
end