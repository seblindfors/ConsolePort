local _, G = ...;
local 	Inventory, GridItem, ListItem, GridIterator, ListIterator,
		VisibleGridItems, GridMod, GridButtons,
		ItemButtons, ItemTypeButtons = nil, nil, nil, 1, 1, 0, 8, {}, {}, {};
local Container;


for i=1, 5 do
	_G["ContainerFrame"..i]:SetScript("OnShow", function(self)
		self:Hide();
	end);
end

for i=0, 3 do
	_G["CharacterBag"..i.."Slot"]:SetScript("OnClick", function(...) ToggleAllBags() end);
end

MainMenuBarBackpackButton:SetScript("OnClick", function (...) ToggleAllBags() end);

hooksecurefunc("ToggleAllBags", function(...)
	if not ConsolePortContainerFrame then
		Container = ConsolePort:CreateContainerFrame();
		Container.GridView:Show();
	elseif Container:IsVisible() then
		Container:Hide();
	else
		Container:Show();
	end
end);

function ConsolePort:CleanBags() 
	local i, item;
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			i = { GetContainerItemInfo(bag, slot) };
			item = i[7];
			if item and string.find(item,"9d9d9d") then
				UseContainerItem(bag, slot);
			end
		end
	end
end

local function GetSlotCount()
	local total, free, used, special = 0, 0, 0, 0;
	for bag=0,4 do
		local numSlots = GetContainerNumSlots(bag);
		local numFreeSlots = GetContainerNumFreeSlots(bag);
		free = free + numFreeSlots;
		used = used + (numSlots-numFreeSlots);
	end
	total = free + used;
	return total, free, used, special;
end

local function SetItem(self, bag, slot, index)
	local button = ItemButtons[index];
	if 	button then
		return button:SetIndex(bag, slot);
	end
end

local function Fade(self, fadeIn)
	local endAlpha = fadeIn and 1 or 0;
	UIFrameFadeIn(self, 0.15, self:GetAlpha(), endAlpha);
end

local function ClearList()
	for i, button in pairs(ItemButtons) do
		button:SetIndex();
	end
end

local function SetIndex(self, bag, slot)
	if 	bag and slot then
		self.bagID = bag;
		self.slotID = slot;
		self.bag:SetID(bag);
		self.itemBtn:SetID(slot);
		self:UpdateItem();
		return true;
	else
		self.bagID = -1;
		self.slotID = -1;
		self.bag:SetID(-1);
		self.itemBtn:SetID(-1);
		self:UpdateItem();
	end
end

local function UpdateItem(self, updateCooldown)
	local bagID, slotID = self.bagID, self.slotID;
	local link =  GetContainerItemLink(bagID, slotID);
	if 	link then
		if 	updateCooldown then
			local time, cooldown, _ = GetContainerItemCooldown(bagID, slotID);
			self.itemBtn.Cooldown:SetCooldown(time, cooldown);
		else
			local _, count = GetContainerItemInfo(bagID, slotID);
			if count > 1 then
				self.itemBtn.Count:SetText(count);
				self.itemBtn.Count:Show();
			else
				self.itemBtn.Count:Hide();
			end
		end
		self.link = link;
		self.itemBtn.icon:SetTexture(GetContainerItemInfo(bagID, slotID));
		self.title:SetText(link:gsub("|H(.-)|h%[(.-)%]|h", "|H%1|h%2|h"));
		self:Show();
	else
		self:Hide();
	end
end

local function CreateListItem(index)
	if ConsolePortContainerFrame then
		local f,p,a,o 	= CreateFrame("Button", "ConsolePortContainerListItem"..index, ConsolePortContainerFrame.ListView);
		if 	ItemButtons[index-1] then
			p,a,o = ItemButtons[index-1], "BOTTOMRIGHT", 0;
		else
			p,a,o = ConsolePortContainerFrame, "TOPRIGHT", -4;
		end 
		f.bag 			= CreateFrame("Frame", nil, f);
		f.itemBtn 		= CreateFrame("Button", nil, f.bag, "ContainerFrameItemButtonTemplate");
		f.bg 			= f:CreateTexture(nil, "ARTWORK");
		f.highlight 	= f:CreateTexture(nil, "OVERLAY");
		f.title 		= f:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText");
		f.bagID = -1;
		f.slotID = -1;
		f:SetAttribute("type", "click");
		f:SetAttribute("clickbutton", f.itemBtn);
		f:RegisterForClicks("AnyUp");
		
		f.title:SetWordWrap(true);

		f.bg:SetAtlas("PetList-ButtonBackground");
		f.highlight:SetAtlas("PetList-ButtonSelect");

		f.bg:SetAllPoints(f);
		f.highlight:SetAllPoints(f);

		f.bg:SetAlpha(0.75);
		f.highlight:SetAlpha(0);

		f:SetScript("OnEnter", function(s) Fade(s.highlight, true) end);
		f:SetScript("OnLeave", function(s) Fade(s.highlight, false) end);
		f.itemBtn:HookScript("OnEnter", function() Fade(f.highlight, true) end);
		f.itemBtn:HookScript("OnLeave", function() Fade(f.highlight, false) end);

		f.SetIndex = SetIndex;
		f.UpdateItem = UpdateItem;
		f.itemBtn.Enter = f.itemBtn:GetScript("OnEnter");
		f.itemBtn.Leave = f.itemBtn:GetScript("OnLeave");
		f.itemBtn.isListItem = true;

		f:RegisterEvent("BAG_UPDATE");
		f:RegisterEvent("BAG_UPDATE_COOLDOWN");
		f:SetScript("OnEvent", function(s, e) s:UpdateItem((e=="BAG_UPDATE_COOLDOWN")); end);

		f.itemBtn:SetHighlightTexture(nil);
		f.itemBtn:GetPushedTexture():SetAtlas("PetList-ButtonHighlight");
		
		f.itemBtn.BattlepayItemTexture:Hide();
		
		f.itemBtn.Cooldown = _G[f:GetName().."Cooldown"];
		f.itemBtn.QuestTexture = _G[f:GetName().."IconQuestTexture"];
		f.itemBtn.NormalTexture = f.itemBtn:GetNormalTexture();

		f.itemBtn:ClearAllPoints();
		f.itemBtn.icon:ClearAllPoints();
		f.itemBtn.Cooldown:ClearAllPoints();
		f.itemBtn.IconBorder:ClearAllPoints();
		f.itemBtn.QuestTexture:ClearAllPoints();
		f.itemBtn.NormalTexture:ClearAllPoints();
		
		f:SetSize(310, 44);
		f.bag:SetSize(36,36);
		f.title:SetWidth(300);
		f.itemBtn:SetSize(300, 36);
		f.itemBtn.icon:SetSize(36,36);
		f.itemBtn.Cooldown:SetSize(36,36);

		f:SetPoint("TOPRIGHT", p, a, o, o);
		f.bag:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4);
		f.title:SetPoint("LEFT", f.bag, "RIGHT", 4, 0);
		f.itemBtn:SetPoint("LEFT", f.bag, "LEFT", 0, 0);
		f.itemBtn.icon:SetPoint("CENTER", f.bag, "CENTER");
		f.itemBtn.Cooldown:SetPoint("CENTER", f.bag, "CENTER");
		f.itemBtn.IconBorder:SetPoint("CENTER", f.bag, "CENTER");
		f.itemBtn.QuestTexture:SetPoint("CENTER", f.bag, "CENTER");
		f.itemBtn.NormalTexture:SetPoint("CENTER", f.bag, "CENTER");

		f.bag:Show();
		f.title:Show();
		f.itemBtn:Show();
		f:UpdateItem();
		return f;
	end
end

local function UpdateGridItemPosition(index)
	local f = _G["ConsolePortContainerGridItem"..index];
	if f then
		if 	index == 1 then
			f:SetPoint("TOPLEFT", ConsolePortContainerFrame.GridView, "TOPLEFT", 4, -46);
		elseif index%GridMod == 1 then
			f:SetPoint("TOPLEFT", GridButtons[index-GridMod], "BOTTOMLEFT", 0, 0);
		else
			f:SetPoint("TOPLEFT", GridButtons[index-1], "TOPRIGHT", 0, 0);
		end
		f:Show();
		f.itemBtn:Show();
	end
end

local function CreateGridItem(index)
	if ConsolePortContainerFrame then
		local f = _G["ConsolePortContainerGridItem"..index] or CreateFrame("Frame", "ConsolePortContainerGridItem"..index, ConsolePortContainerFrame.GridView);
		f:SetSize(40,40);
		f.itemBtn = CreateFrame("Button", nil, f, "ContainerFrameItemButtonTemplate");
		f.itemBtn:SetPoint("CENTER", f, "CENTER");
		f.itemBtn.Cooldown = _G[f:GetName().."Cooldown"];
		f.itemBtn.QuestTexture = _G[f:GetName().."IconQuestTexture"];
		f.itemBtn.Enter = f.itemBtn:GetScript("OnEnter");
		f.itemBtn.Leave = f.itemBtn:GetScript("OnLeave");
		f.itemBtn.BattlepayItemTexture:Hide();
		UpdateGridItemPosition(index);
		return f;
	end
end

-- This is the correct way of updating items
local function UpdateGridView(self, updateCooldown)
	local slotsTotal = GetSlotCount();
	local index, newGrid, button, itemBtn, texture, count, locked, quality, isQuestItem, questID, isActive, time, cooldown = 1;
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			button = GridButtons[index];
			itemBtn = button.itemBtn;
			index = index + 1;
			if not button:IsVisible() then
				button:Show();
			end
			if  updateCooldown then
				time, cooldown = GetContainerItemCooldown(bag, slot);
				itemBtn.Cooldown:SetCooldown(time, cooldown);
			else
				texture, count, locked, quality = GetContainerItemInfo(bag, slot);
				isQuestItem, questID, isActive = GetContainerItemQuestInfo(bag, slot);
				button:SetID(bag);
				itemBtn:SetID(slot);
				SetItemButtonTexture(itemBtn, texture);
				SetItemButtonCount(itemBtn, count);
				SetItemButtonDesaturated(itemBtn, locked);
				if questID and not isActive then
					itemBtn.QuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
					itemBtn.QuestTexture:Show();
				elseif questID or isQuestItem then
					itemBtn.QuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
					itemBtn.QuestTexture:Show();
				else
					itemBtn.QuestTexture:Hide();
				end
				if quality then
					if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
						itemBtn.IconBorder:Show();
						itemBtn.IconBorder:SetVertexColor(
							BAG_ITEM_QUALITY_COLORS[quality].r,
							BAG_ITEM_QUALITY_COLORS[quality].g,
							BAG_ITEM_QUALITY_COLORS[quality].b);
					else
						itemBtn.IconBorder:Hide();
					end
				else
					itemBtn.IconBorder:Hide();
				end
			end
		end
	end
	if 	not updateCooldown then
		if slotsTotal ~= VisibleGridItems then
			for i=slotsTotal+1, 180 do
				GridButtons[i]:Hide();
			end
			VisibleGridItems = slotsTotal;
		end
		if slotsTotal >= 160 then
			newGrid = 16;
		elseif slotsTotal >= 120 then
			newGrid = 12;
		elseif slotsTotal >= 100 then
			newGrid = 10;
		else
			newGrid = 8;
		end
		if newGrid == GridMod then
			newGrid = nil;
		end
		if 	newGrid or self:GetHeight() ~= self.GridView.height or self:GetWidth() ~= self.GridView.width then
			if newGrid then
				GridMod = newGrid;
				for i=1, slotsTotal do
					UpdateGridItemPosition(i);
				end
			end
			self.GridView.height = 68+40*(ceil(slotsTotal/GridMod));
			self.GridView.width = GridMod*40+10;
			self:SetHeight(self.GridView.height);
			self:SetWidth(self.GridView.width);
		end
	end
end


local function GetInventory()
	local _, _free, _used, _special = GetSlotCount();
	local inventory = {Slots = {free = _free, used = _used, special = _special, categories = 0}};
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			if GetContainerItemInfo(bag, slot) then
				local 	texture,
						itemCount,
						locked,
						quality,
						readable,
						lootable,
						itemLink = GetContainerItemInfo(bag, slot);
				local 	type = select(6, GetItemInfo(itemLink));
				if not inventory[type] then
					inventory[type] = {};
					inventory.Slots.categories = inventory.Slots.categories + 1;
				end
				tinsert(inventory[type], {
					icon = texture,
					link = itemLink,
					count = itemCount,
					isLoot = lootable,
					index = {bag = bag, slot = slot}});
			end
		end
	end
	return inventory;
end

function ConsolePort:CreateContainerFrame()
	if not ConsolePortContainerFrame then
		local backdrop = {
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			edgeSize = 16,
			tileSize = 16,
			insets = {
				left = 5, right = 5, top = 5, bottom = 5
			}
		}
		local name = "ConsolePortContainerFrame";
		local f = CreateFrame("Frame", name, UIParent);
		f.ListView = CreateFrame("Frame", nil, f);
		f.GridView = CreateFrame("Frame", nil, f);
		f.Header = CreateFrame("Button", nil, f);
		f.Header:SetSize(40,40);
		f.Header.BagIcon = f.Header:CreateTexture(nil, "ARTWORK");
		f.Header.BagIcon:SetTexture("Interface\\Buttons\\Button-Backpack-Up");
		f.Header.BagIcon:SetSize(38,38);
		f.Header.BagIconFrame = f.Header:CreateTexture(nil, "OVERLAY");
		f.Header.BagIconFrame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
		f.Header.BagIconFrame:SetTexCoord(0, 0.5625, 0, 0.5625);
		f.Header.BagIconFrame:SetSize(44, 44);
		f.Header.TitleBar = f.Header:CreateTexture(nil, "BACKGROUND");
		f.Header.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Background");
		f.Header.TitleBar:SetSize(170, 32);
		f.Header.TitleBar:SetTexCoord(0, 0.6640625, 0, 1);
		f.Header.TitleText = f.Header:CreateFontString(nil, "ARTWORK", "GameFontNormalLeftBottom");
		f.Header.TitleText:SetText("Inventory");

		f.AutoSort = CreateFrame("Button", name.."AutoSort", f);
		f.CurrencyFrame = CreateFrame("Frame", name.."CurrencyFrame", f);
		f.MoneyFrame = CreateFrame("Frame", name.."MoneyFrame", f.CurrencyFrame, "SmallMoneyFrameTemplate");
		f.SlotsUsed = f.Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
		f.SetItem = SetItem;
		f.ClearList = ClearList;
		f.GetInventory = GetInventory;

		local n, p = f.AutoSort:CreateTexture(nil, "ARTWORK"), f.AutoSort:CreateTexture(nil, "ARTWORK");
		local nName, _, _, nL, nR, nT, nB = GetAtlasInfo("bags-button-autosort-up");
		local pName, _, _, pL, pR, pT, pB = GetAtlasInfo("bags-button-autosort-down");
		n:SetTexture(nName);
		n:SetTexCoord(nL, nR, nT, nB);
		n:SetAllPoints(f.AutoSort);
		p:SetTexture(pName);
		p:SetTexCoord(pL, pR, pT, pB);
		p:SetAllPoints(f.AutoSort);

		f.AutoSort:SetSize(28,26);
		f.AutoSort:SetNormalTexture(n);
		f.AutoSort:SetPushedTexture(p);
		f.AutoSort:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
		f.AutoSort:SetScript("OnClick", function()
			PlaySound("UI_BagSorting_01");
			SortBags();
		end);
		f.AutoSort:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self);
			GameTooltip:SetText(BAG_CLEANUP_BAGS);
			GameTooltip:Show();
		end);

		f.GridView:SetScript("OnShow", function(s)
			f.ListView:Hide();
			UpdateGridView(f);
			UpdateGridView(f, true);
		end);
		f.ListView:SetScript("OnShow", function(s)
			f:SetSize(600, 550);
			f.CurrencyFrame:SetWidth(600);
			f.GridView:Hide();
		end);

		f.UpdateGridView = UpdateGridView;

		f:SetSize(600, 550);
		f.CurrencyFrame:SetHeight(20);

		f.ListView:Hide();
		f.GridView:Hide();

		for i=1, 3 do
			f["Token"..i] = _G["BackpackTokenFrameToken"..i];
			f["Token"..i]:SetParent(f);
			f["Token"..i]:ClearAllPoints();
		end

		local Corner, Vertical, Horizontal, TL, TR, BL, BR =
			"Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner",
			"Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Left",
			"Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Top",
			"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT";

		local Borders = {
			Right = {	width = 12, height = 0,
						anchor1 = {TR, f, TR, 5, 0},	anchor2 = {BR, f, BR},
						texture = Vertical,  coord = {1, 0, 0.87, 0}, parent = f,
			},
			Left = 	{	width = 12, height = 0,
						anchor1 = {TL, f, TL,-5, 0},	anchor2 = {BL, f, BL},
						texture = Vertical, coord = {0, 1, 0, 0.87}, parent = f,
			},
			Bottom = {	width = 0, height = 12,
						anchor1 = {BL, f, BL, 0, -5},	anchor2 = {BR, f, BR, 0, -5},
						texture = Horizontal, coord = {0, 0.87, 1, 0}, parent = f,
			},
			Top = {		width = 0, height = 12,
						anchor1 = {TL, f, TL, 0, 5},	anchor2 = {TR, f, TR, 0, 5},
						texture = Horizontal, coord = {0.87, 0, 0, 1}, parent = f,
			},
			TopLeft = {	width = 38, height = 38,
						anchor1 = {TL, f, TL, -4, 4},
						texture = Corner, coord = {0, 1, 0, 1}, parent = f, level = 7,
			},
			TopRight = {width = 38, height = 38,
						anchor1 = {TR, f, TR, 4, 4},
						texture = Corner, coord = {1, 0, 0, 1}, parent = f, level = 7,
			},
			BottomRight = {	width = 38, height = 38,
						anchor1 = {BR, f.CurrencyFrame, BR, 8, -5},
						texture = Corner, coord = {1, 0, 1, 0}, parent = f.CurrencyFrame, level = 7,
			},
			BottomLeft = {	width = 38, height = 38,
						anchor1 = {BL, f.CurrencyFrame, BL, -8, -5},
						texture = Corner, coord = {0, 1, 1, 0}, parent = f.CurrencyFrame, level = 7,
			},
			IconBL = {	width = 38, height = 38,
						anchor1 = {BL, f.Header, BL, -3, -3},
						texture = Corner, coord = {0, 1, 1, 0}, parent = f.Header, level = 7,
			},			
			IconBR = {	width = 38, height = 38,
						anchor1 = {BR, f.Header, BR, 3, -3},
						texture = Corner, coord = {1, 0, 1, 0}, parent = f.Header, level = 7,
			},
			IconTR = {	width = 38, height = 38,
						anchor1 = {TR, f.Header, TR, 3, 3},
						texture = Corner, coord = {1, 0, 0, 1}, parent = f.Header, level = 7,
			},
			IconTL = {	width = 38, height = 38,
						anchor1 = {TL, f.Header, TL, -3, 3},
						texture = Corner, coord = {0, 1, 0, 1}, parent = f.Header, level = 7,
			},
			HeaderTL = {width = 30, height = 30,
						anchor1 = {TL, f.Header, TL, -158, -12},
						texture = Corner, coord = {0, 1, 0, 1}, parent = f.Header, level = 7,
			},
			HeaderBL = {width = 30, height = 30,
						anchor1 = {BL, f.Header, BL, -158, -2},
						texture = Corner, coord = {0, 1, 1, 0}, parent = f.Header, level = 7,
			},
			HeaderBorder = { width = 150, height = 12,
						anchor1 = {TR, f.Header, TL, -2, -12},
						texture = Horizontal, coord = {0.87, 0, 0, 1}, parent = f.Header
			},
			GridSeparator = { width = 0, height = 12,
						anchor1 = {TL, f.GridView, TL, 2, -42}, anchor2 = {TR, f.GridView, TR, -2, -42},
						texture = Horizontal, coord = {0.87, 0, 0, 1}, parent = f.GridView
			},
		}

		for name, b in pairs(Borders) do
			local t = b.parent:CreateTexture(nil, "ARTWORK", nil, b.level);
			f["Border"..name] = t;
			t:SetTexture(b.texture);
			t:SetSize(b.width, b.height);
			t:SetPoint(b.anchor1[1], b.anchor1[2], b.anchor1[3], b.anchor1[4], b.anchor1[5]);
			if b.anchor2 then
				t:SetPoint(b.anchor2[1], b.anchor2[2], b.anchor2[3], b.anchor2[4], b.anchor2[5]);
			end
			if b.coord then
				t:SetTexCoord(b.coord[1], b.coord[2], b.coord[3], b.coord[4]);
			end
		end

		local Points = {
			{f, 				"BOTTOMRIGHT", 	UIParent, 			"BOTTOMRIGHT", -93, 130},
			{f.Header,			"TOPLEFT",		f, 					"TOPRIGHT", -22, 42},
			{f.Header.BagIcon,	"CENTER", 		f.Header,			"CENTER", -1, 2},
			{f.Header.BagIconFrame, "CENTER",	f.Header,			"CENTER"},
			{f.Header.TitleBar,	"TOPRIGHT",		f.Header, 			"TOPLEFT", 10, -14},
			{f.Header.TitleText,"CENTER", 		f.Header.TitleBar, 	"CENTER", -24, 2},
			{f.AutoSort,		"TOPRIGHT", 	f,					"TOPRIGHT", -10, -10},
			{f.ListView, 		"TOPLEFT", 		f, 					"TOPLEFT"},
			{f.ListView, 		"BOTTOMRIGHT", 	f, 					"BOTTOMRIGHT", 0, 20},
			{f.GridView, 		"TOPLEFT", 		f, 					"TOPLEFT"},
			{f.GridView, 		"BOTTOMRIGHT", 	f,					"BOTTOMRIGHT", 0, 20},
			{f.CurrencyFrame, 	"TOPLEFT", 		f, 					"BOTTOMLEFT", 0, 20},
			{f.CurrencyFrame, 	"TOPRIGHT", 	f, 					"BOTTOMRIGHT", 0, 20},
			{f.SlotsUsed, 		"CENTER", 		f.Header.TitleBar, 	"CENTER", 40, 2},
			{f.MoneyFrame, 		"RIGHT", 		f.CurrencyFrame, 	"RIGHT"},
			{f.Token1, 			"LEFT", 		f.CurrencyFrame, 	"LEFT"},
			{f.Token2, 			"LEFT", 		f.Token1, 			"RIGHT"},
			{f.Token3, 			"LEFT", 		f.Token2, 			"RIGHT"},
		}

		for i, point in pairs(Points) do
			point[1]:SetPoint(point[2], point[3], point[4], point[5], point[6]);
		end

		f:SetBackdrop(backdrop);
		f.CurrencyFrame:SetBackdrop(backdrop);
		f:SetBackdropBorderColor(1, 0.675, 0.125, 1);
		f.CurrencyFrame:SetBackdropBorderColor(1, 0.675, 0.125, 1);

		f:EnableMouse(true);
		f:SetMovable(true);
		f:RegisterForDrag("LeftButton");

		f:SetScript("OnDragStart", f.StartMoving);
		f:SetScript("OnDragStop", f.StopMovingOrSizing);

		f:RegisterEvent("BAG_UPDATE");
		f:RegisterEvent("BAG_UPDATE_COOLDOWN");
		f:SetScript("OnEvent", function(s,e,...)
			if s:IsVisible() then
				Inventory = s:GetInventory();
				if s.GridView:IsVisible() then
					s:UpdateGridView((e=="BAG_UPDATE_COOLDOWN"));
				end
				local free, used = Inventory.Slots.free, Inventory.Slots.used;
				local percentUsed = used/(free+used);
				if percentUsed < 0.5 then
					s.SlotsUsed:SetTextColor(percentUsed*2, 1, 0, 1);
				else
					s.SlotsUsed:SetTextColor(1, 1-(percentUsed), 0, 1);
				end
				s.SlotsUsed:SetText(used.." / "..(free+used));
			end
		end);
		f:Show();
		for i=1, 12 do
			local listItem = CreateListItem(i);
			tinsert(ItemButtons, listItem);
		end
		for i=1, 180 do
			local gridItem = CreateGridItem(i);
			tinsert(GridButtons, gridItem);
		end
		tinsert(UISpecialFrames, name);
		self:ADDON_LOADED("ConsolePort_Container");
		return f;
	elseif ConsolePortContainerFrame:IsVisible() then
		ConsolePortContainerFrame:Hide();
	else
		ConsolePortContainerFrame:Show();
	end
end

function ConsolePort:Bags (key, state)
	if 		key == G.PREPARE and GridIterator > GetSlotCount() then
		GridIterator = GetSlotCount();
	end
	if 	GridItem then
		GridItem:UnlockHighlight();
		GridItem = nil;
	end
	if Container.GridView:IsVisible() then
		local bag = GridButtons[GridIterator];
		local slot = bag.itemBtn;
		slot:LockHighlight();
		slot:Enter();
		if not InCombatLockdown() then
			if not MerchantFrame:IsVisible() then
				CP_R_RIGHT_NOMOD:SetAttribute("type", "item");
				CP_R_RIGHT_NOMOD:SetAttribute("item", bag:GetID().." "..slot:GetID());
			else
				CP_R_RIGHT_NOMOD:SetAttribute("type", "Bags");
			end
		end
		if key == G.CIRCLE then
			UseContainerItem(bag:GetID(), slot:GetID());
		elseif key == G.TRIANGLE and state == G.STATE_DOWN then
			local link = GetContainerItemLink(bag:GetID(), slot:GetID());
			self:UpdateExtraButton(GetItemSpell(link) and link);
		elseif key == G.SQUARE then
			if state == G.STATE_DOWN then
				PickupContainerItem(bag:GetID(), slot:GetID());
			end
			if CursorHasItem() then
				MouselookStop();
			end
		elseif state == G.STATE_DOWN then
			GridItem = slot;
			local change;
			local count = GetSlotCount();
			if 		key == G.UP 	then change = -GridMod;
			elseif 	key == G.DOWN 	then change = GridMod;
			elseif 	key == G.LEFT 	then change = -1;
			elseif 	key == G.RIGHT 	then change = 1;
			end
			GridIterator = GridIterator + change;
			if 		GridIterator > count 	then GridIterator = GridIterator - count;
			elseif 	GridIterator < 1 		then GridIterator = GridIterator + count;
			end
		end
	end
end