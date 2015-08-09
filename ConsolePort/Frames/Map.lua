local _, db = ...;
local KEY = db.KEY;
local iterator = 1;
local zones = {};
local zcount = 0;
local item = nil;

QuestScrollFrame:HookScript("OnHide", function(self)
	if item then
		item:GetScript("OnLeave")(item);
	end
end);

local function MapFindClosestZone(key, zones)
	local this 	= zones[iterator];
	local nodeY = 1;
	local nodeX = 1;
	local swap 	= false;
	for i, dest in ipairs(zones) do
		local diffY = abs(this.Y-dest.Y);
		local diffX = abs(this.X-dest.X);
		local total = diffX + diffY;
		if total < nodeX + nodeY then
			if 	key == KEY.DOWN then
				if 	diffY > diffX and 	-- up/down
					dest.Y > this.Y then 	-- up
					swap = true;
				end
			elseif key == KEY.UP then
				if 	diffY > diffX and 	-- up/down
					dest.Y < this.Y then 	-- down
					swap = true;
				end
			elseif key == KEY.LEFT then
				if 	diffY < diffX and 	-- left/right
					dest.X < this.X then 	-- left
					swap = true;
				end
			elseif key == KEY.RIGHT then
				if 	diffY < diffX and 	-- left/right
					dest.X > this.X then 	-- right
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

function ConsolePort:Map(key, state)
	local titles 	= QuestScrollFrame.Contents.Titles;
	local headers 	= QuestScrollFrame.Contents.Headers;
	local icons 	= QuestScrollFrame.Contents.poiTable;
	local q_count 	= 0;
	local h_count	= 0;
	local quests 	= {};
	local zones 	= {};
	for i, quest in pairs(titles) do
		if quest:IsVisible() then
			tinsert(quests, quest);
			quest:GetScript("OnLeave")(quest);
			q_count = q_count + 1;
		end
	end
	for i, header in pairs(headers) do
		if header:IsVisible() then
			tinsert(zones, header);
			header:GetScript("OnLeave")(header);
			h_count = h_count + 1;
		end
	end
	table.sort(quests, function(a,b) return a:GetTop()>b:GetTop() end);
	quests[0] = QuestScrollFrame.ViewAll;
	zones[0]  = QuestScrollFrame.ViewAll;
	HelpPlate_Hide(true);
	if QuestMapDetailsScrollFrame:IsVisible() then
		ConsolePort:MapQuestDetail(key, state);
	elseif QuestScrollFrame:GetAlpha() == 1 then
		if h_count > 0 then ConsolePort:MapQuest(key, state, h_count, zones, icons);
		else ConsolePort:MapQuest(key, state, q_count, quests, icons); end;
	else
		ConsolePort:MapZone(key, state);
	end
end

function ConsolePort:MapQuestDetail(key, state)
	if 		key == KEY.UP then
		ConsolePort:Button(QuestMapDetailsScrollFrameScrollBarScrollUpButton, state);
	elseif	key == KEY.DOWN then
		ConsolePort:Button(QuestMapDetailsScrollFrameScrollBarScrollDownButton, state);
	elseif 	key == KEY.TRIANGLE then
		ConsolePort:Button(QuestMapFrame.DetailsFrame.BackButton, state);
		ConsolePort:Map("right", "up");
	elseif	key == KEY.SQUARE then
		ConsolePort:Button(QuestMapFrame.DetailsFrame.AbandonButton, state);
	elseif 	key == KEY.CIRCLE then
		if QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:IsVisible() then
			ConsolePort:Button(QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton, state);
		else
			ConsolePort:Button(QuestMapFrame.DetailsFrame.TrackButton, state);
		end
	end
end

function ConsolePort:MapQuest(key, state, count, items, icons)
	if 		key == KEY.PREPARE then iterator = 1;
	elseif 	key == KEY.UP		 and state == KEY.STATE_DOWN and iterator > 0 		then iterator = iterator - 1;
	elseif 	key == KEY.DOWN	 and state == KEY.STATE_DOWN and iterator < count 	then iterator = iterator + 1; end;
	if 	iterator == 0 then
		QuestScrollFrame.ViewAll:LockHighlight();
		QuestScrollFrame.ViewAll:SetAlpha(1);
	else
		QuestScrollFrame.ViewAll:UnlockHighlight();
		QuestScrollFrame.ViewAll:SetAlpha(0.5);
	end
	item = items[iterator];
	if item then
		if 		item:GetTop()-item:GetHeight() < QuestScrollFrameScrollBarScrollDownButton:GetTop() then
			QuestScrollFrameScrollBarScrollDownButton:Click();
		elseif 	item:GetTop() > QuestScrollFrameScrollBarScrollUpButton:GetTop() or
				iterator == 1 then
			QuestScrollFrameScrollBarScrollUpButton:Click();
		end
		item:GetScript("OnEnter")(item);
		if key == KEY.CIRCLE then
			local button = nil;
			for i, icon in pairs(icons.numeric) do
				if icon.parent == item then
					button = icon;
				end
			end
			for i, icon in pairs(icons.completed) do
				if icon.parent == item then
					button = icon;
				end
			end
			if button then
				ConsolePort:Button(button, state);
			else
				ConsolePort:Button(item, state);
				if state == KEY.STATE_UP then
					ConsolePort:Map(KEY.PREPARE, state);
				end
			end
		elseif key == KEY.SQUARE then
			ConsolePort:Button(item, state);
			if state == KEY.STATE_UP then
				item:GetScript("OnLeave")(item);
			end
		end
	end
	if key == KEY.TRIANGLE and state == KEY.STATE_UP then
		QuestScrollFrame:SetAlpha(0.5);
		WorldMapFrameTutorialButton:GetChildren():Show();
		if item then item:GetScript("OnLeave")(item); end;
		ConsolePort:Map(KEY.PREPARE, state);
	end
end

-- Eats a lot of memory, only run on event WORLD_MAP_UPDATE
function ConsolePort:MapGetZones()
	local zone = {};
	local count = 0;
	for x=0, 1, 0.05 do
	   for y=0, 1, 0.05 do
	      local zoneName, fileName,
	      		texPctX, texPctY,
	      		texX, texY,
	      		scrollX, scrollY,
	      		minLevel, maxLevel = UpdateMapHighlight(x, y);
	      if zoneName and fileName then
	         local ZoneIsCounted = false;
	         for i, counted in pairs(zones) do
	            if counted.name == zoneName then
	               ZoneIsCounted = true;
	            end
	         end
	         if not ZoneIsCounted then
	            local posX = scrollX+(texX/2);
	            local posY = scrollY+(texY/2);
	            count = count + 1;
	            zone[count] = { 
	            	name = zoneName,	fN 	= fileName,
	            	X 	= posX,			Y 	= posY,
	            	tPX = texPctX,		tPY = texPctY,
	            	tX 	= texX,			tY 	= texY,
	            	sX	= scrollX,		sY 	= scrollY,
	            	min = minLevel,		max = maxLevel
	            };
	         end
	      end
	   end
	end
	if zones then
		zones = zone;
	end
	if zcount then
		zcount = count;
	end
	return zone;
end

function ConsolePort:MapZone(key, state)
	if 	key == KEY.TRIANGLE and state == KEY.STATE_UP then
		WorldMapHighlight:Hide();
		QuestScrollFrame:SetAlpha(1);
		WorldMapFrameTutorialButton:GetChildren():Hide();
		iterator = 0;
		return;
	end
	if not AzerothButton:IsVisible() then
		if state == KEY.STATE_DOWN then
			if 	key == KEY.PREPARE then
				--
			elseif	key == KEY.CIRCLE and zones[iterator] then
				WorldMapHighlight:Hide();
				ProcessMapClick(zones[iterator].X, zones[iterator].Y);
				iterator = floor((zcount/2)+1);
			elseif	key == KEY.SQUARE then
				WorldMapHighlight:Hide();
				WorldMapButton_OnClick(WorldMapButton, "RightButton");
				iterator = floor((zcount/2)+1);
			elseif zones[iterator] then
				MapFindClosestZone(key, zones);
			end
		end
	elseif state == KEY.STATE_DOWN then
		-- Hacky fix
		if key == KEY.RIGHT then
			AzerothButton:Click();
		elseif key == KEY.LEFT then
			OutlandButton:Click();
		elseif key == KEY.UP then
			DraenorButton:Click();
		end
	end
end

function ConsolePort:MapHighlight(_, elapsed)
	local self = WorldMapButton;
	if (not MouseIsOver(self) or
		IsMouselooking()) and
	 	zones[iterator] and
		QuestScrollFrame:GetAlpha() ~= 1 and not
		QuestMapDetailsScrollFrame:IsVisible() then
		if 	zones[iterator].fN then
			local zone = zones[iterator];
			local textureX, textureY, scrollChildX, scrollChildY;
			local width, height = self:GetSize();
			if 	zone then 
				WorldMapHighlight:SetTexCoord(0, zone.tPX, 0, zone.tPY);
				WorldMapHighlight:SetTexture("Interface\\WorldMap\\"..zone.fN.."\\"..zone.fN.."Highlight");
				WorldMapFrameAreaLabel:SetText(zone.name);
				textureX = zone.tX * width;
				textureY = zone.tY * height;
				scrollChildX = zone.sX * width;
				scrollChildY = -zone.sY * height;
				if 	textureX > 0 and textureY > 0 then
					WorldMapHighlight:SetWidth(textureX);
					WorldMapHighlight:SetHeight(textureY);
					WorldMapHighlight:SetPoint("TOPLEFT", "WorldMapButton", "TOPLEFT", scrollChildX, scrollChildY);
					WorldMapHighlight:Show();
				end
				if 	zone.name and zone.min and zone.max and zone.min > 0 and zone.max > 0 then
					local playerLevel = UnitLevel("player");
					local color;
					if 	playerLevel < zone.min then
						color = GetQuestDifficultyColor(zone.min);
					elseif playerLevel > zone.max then
						color = GetQuestDifficultyColor(zone.max - 2); 
					else
						color = QuestDifficultyColors["difficult"];
					end
					color = ConvertRGBtoColorString(color);
					if zone.min ~= zone.max then
						WorldMapFrameAreaLabel:SetText(WorldMapFrameAreaLabel:GetText()..color.." ("..zone.min.."-"..zone.max..")"..FONT_COLOR_CODE_CLOSE);
					else
						WorldMapFrameAreaLabel:SetText(WorldMapFrameAreaLabel:GetText()..color.." ("..zone.max..")"..FONT_COLOR_CODE_CLOSE);
					end
				end
			end
		else
			WorldMapHighlight:Hide();
		end
	end
end


