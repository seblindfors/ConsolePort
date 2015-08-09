local _, db = ...;
local KEY = db.KEY;
local iterator = 1;
local nodes = {};
local points = {};

TaxiFrame:HookScript("OnHide", function()
	nodes = {}; points = {};
end);

-- BUG: attempt to index nil value at line 13
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
			if 	key == KEY.UP then
				if 	diffY > diffX and 	-- up/down
					destY > thisY then 	-- up
					swap = true;
				end
			elseif key == KEY.DOWN then
				if 	diffY > diffX and 	-- up/down
					destY < thisY then 	-- down
					swap = true;
				end
			elseif key == KEY.LEFT then
				if 	diffY < diffX and 	-- left/right
					destX < thisX then 	-- left
					swap = true;
				end
			elseif key == KEY.RIGHT then
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
	if 	key == KEY.PREPARE then 
		for i, node in ipairs({TaxiFrame:GetChildren()}) do
			if 	node:IsObjectType("Button") and
				node:IsShown() and 
				i ~= 1 then
				tinsert(nodes, node);
				tinsert(points, {X = node:GetLeft(), Y = node:GetTop()});
			end
		end
		for i, node in ipairs(nodes) do
			if TaxiNodeGetType(node:GetID()) == "CURRENT" then
				iterator = i;
			end
		end
	elseif	key == KEY.CIRCLE then
		if state == KEY.STATE_DOWN then
			nodes[iterator]:Click();
		end
		return;
	elseif	(key == KEY.TRIANGLE or key == KEY.SQUARE) and state == KEY.STATE_DOWN then
		CloseTaxiMap();
		return;
	elseif state == KEY.STATE_DOWN then
		TaxiFindClosestNode(key);
	end
	ConsolePort:Highlight(iterator, nodes);
	nodes[iterator]:GetScript("OnEnter")(nodes[iterator]);
	if TaxiNodeGetType(nodes[iterator]:GetID()) ~= "CURRENT" then
		GameTooltip:AddLine(db.CLICK.TAKETAXI, 1,1,1);
		GameTooltip:Show();
	end
end