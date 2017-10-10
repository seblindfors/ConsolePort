---------------------------------------------------------------
-- Map.lua: Nodes and relevant scripts for UI cursor
---------------------------------------------------------------

---- World map nodes:
-- Since the map is one big button with an update script,
-- the map is scanned as a grid for zone information which
-- is then used to generate nodes that can be targeted by the
-- UI cursor. These nodes provide the same functionality as
-- clicking the zones on the map with an actual mouse.

local zones, mapNodes, node = {}, {}

local function UpdateMap(self)
	if node then
		local zone = node.info
		local textureX, textureY, scrollChildX, scrollChildY
		local width, height = self:GetSize()
		if 	zone then 
			WorldMapHighlight:SetTexCoord(0, zone.tPX, 0, zone.tPY)
			WorldMapHighlight:SetTexture("Interface\\WorldMap\\"..zone.fN.."\\"..zone.fN.."Highlight")
			WorldMapFrameAreaLabel:SetText(node.name)
			textureX = zone.tX * width
			textureY = zone.tY * height
			scrollChildX = zone.sX * width
			scrollChildY = -zone.sY * height
			if 	textureX > 0 and textureY > 0 then
				WorldMapHighlight:SetWidth(textureX)
				WorldMapHighlight:SetHeight(textureY)
				WorldMapHighlight:SetPoint("TOPLEFT", "WorldMapButton", "TOPLEFT", scrollChildX, scrollChildY)
				WorldMapHighlight:Show()
			end
			if 	node.name and zone.min and zone.max and zone.min > 0 and zone.max > 0 then
				local playerLevel = UnitLevel("player")
				local color
				if 	playerLevel < zone.min then
					color = GetQuestDifficultyColor(zone.min)
				elseif playerLevel > zone.max then
					color = GetQuestDifficultyColor(zone.max - 2)
				else
					color = QuestDifficultyColors["difficult"]
				end
				color = ConvertRGBtoColorString(color)
				if zone.min ~= zone.max then
					WorldMapFrameAreaLabel:SetText(WorldMapFrameAreaLabel:GetText()..color.." ("..zone.min.."-"..zone.max..")|r")
				else
					WorldMapFrameAreaLabel:SetText(WorldMapFrameAreaLabel:GetText()..color.." ("..zone.max..")|r")
				end
			end
		end
	end
end

local function EnterNode(self)
	node = self
end

local function LeaveNode(self)
	node = nil
end

local function ClickMapNode(self)
	ProcessMapClick(self.info.X, self.info.Y)
end

local function CreateMapNode()
	local node = CreateFrame("Button", "MapNode"..#mapNodes+1, WorldMapScrollFrame)
	node:SetScript("OnEnter", EnterNode)
	node:SetScript("OnLeave", LeaveNode)
	node:SetScript("OnClick", ClickMapNode)
	node:SetSize(4,4)
	mapNodes[#mapNodes + 1] = node
	return node
end

local function DrawMapNodes()
	local count = 0
	for i, node in pairs(mapNodes) do
		node:Hide()
	end
	local width, height = WorldMapScrollFrame:GetSize()
	for name, info in pairs(zones) do
		count = count + 1

		local node = mapNodes[count] or CreateMapNode()
		node.name = name
		node.info = info
		node:SetPoint("TOPLEFT", WorldMapScrollFrame, info.X*width, -info.Y*height)
		node:SetFrameStrata("TOOLTIP")
		node:Show()
	end
end


function ConsolePort:GetMapNodes()
	wipe(zones)
	for x=0, 1, 0.02 do
		for y=0, 1, 0.02 do
			local zoneName, fileName,
				texPctX, texPctY,
				texX, texY,
				scrollX, scrollY,
				minLevel, maxLevel = UpdateMapHighlight(x, y)
			if zoneName and fileName and not zones[zoneName] then
				local posX = scrollX+(texX/2)
				local posY = scrollY+(texY/2)
				zones[zoneName] = {
					fN 	= fileName,
					X 	= posX,			Y 	= posY,
					tPX = texPctX,		tPY = texPctY,
					tX 	= texX,			tY 	= texY,
					sX	= scrollX,		sY 	= scrollY,
					min = minLevel,		max = maxLevel,
				}
			end
		end
	end
	DrawMapNodes()
end

WorldMapButton:HookScript("OnUpdate", UpdateMap)


