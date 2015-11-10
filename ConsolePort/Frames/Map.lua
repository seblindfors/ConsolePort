local zones = {}
local nodes = {}
local node

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

local function ClickNode(self)
	ProcessMapClick(self.info.X, self.info.Y)
end

local function CreateNode()
	local node = CreateFrame("Button", "MapNode"..#nodes+1, WorldMapScrollFrame)
	node:SetScript("OnEnter", EnterNode)
	node:SetScript("OnLeave", LeaveNode)
	node:SetScript("OnClick", ClickNode)
	node:SetSize(4,4)
	tinsert(nodes, node)
	return node
end

local function DrawNodes()
	local count = 0
	for i, node in pairs(nodes) do
		node:Hide()
	end
	for name, info in pairs(zones) do
		count = count + 1

		local node = nodes[count] or CreateNode()
		local width, height = WorldMapScrollFrame:GetSize()
		node.name = name
		node.info = info
		node:SetPoint("TOPLEFT", WorldMapScrollFrame, info.X*width, -info.Y*height)
		node:SetFrameStrata("TOOLTIP")
		node:Show()
	end
end


function ConsolePort:GetMapNodes()
	wipe(zones)
	for x=0, 1, 0.05 do
		for y=0, 1, 0.05 do
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
	DrawNodes()
end

WorldMapButton:HookScript("OnUpdate", UpdateMap)