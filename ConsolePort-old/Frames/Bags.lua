local _, db = ...;
local KEY = db.KEY;
local 	Inventory, GridItem, ListItem, List, GridIterator,
		VisibleGridItems, GridMod, GridButtons,
		ItemButtons, CategoryButtons = nil, nil, nil, nil, 1, 0, 8, {}, {}, {};
local Container;

local NUM_LIST_BUTTONS = 12;
local LIST_BUTTON_HEIGHT = 44;

for i=1, 13 do
	_G["ContainerFrame"..i]:HookScript("OnShow", function(self)
		if self:GetID() <= 4 then
			self:Hide();
		end
	end);
end

for i=0, 3 do
	_G["CharacterBag"..i.."Slot"]:SetScript("OnClick", function(...) ToggleAllBags() end);
end

MainMenuBarBackpackButton:SetScript("OnClick", function (...) ToggleAllBags() end);

hooksecurefunc("ToggleAllBags", function(...)
	if not Container then
		ConsolePort:CreateContainerFrame();
		if ConsolePortSettings.showGrid then
			Container.GridView:Show()
		else
			Container.ListView:Show()
		end
	elseif Container:IsVisible() then
		Container:Hide();
	else
		Container:Show();
	end
end);

function ConsolePort:CleanBags() 
	local quality;
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			quality = select(4, GetContainerItemInfo(bag, slot));
			if quality and quality == 0 then
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

local function GetInventory()
	local _, _free, _used, _special = GetSlotCount();
	local inventory = {	Slots = {free = _free, used = _used, special = _special, categories = 0}, All = {}};
	local texture, itemCount, locked, quality, readable, lootable, itemLink, item, itemType;
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			if GetContainerItemInfo(bag, slot) then
				texture, itemCount, locked, quality,readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
				itemType = lootable and "Lootable" or readable and "Readable" or select(6, GetItemInfo(itemLink));
				if not inventory[itemType] then
					inventory[itemType] = {};
					inventory.Slots.categories = inventory.Slots.categories + 1;
				end
				item = {
					icon = texture,
					link = itemLink,
					count = itemCount,
					isLoot = lootable,
					index = {bag = bag, slot = slot}
				};
				tinsert(inventory[itemType], item);
				tinsert(inventory.All, item);
			end
		end
	end
	return inventory;
end

local function SetCategory(category, index)
	local button = CategoryButtons[index%13];
	if button then
		return button:SetCategory(category);
	end
end

local function SetItem(bag, slot, index)
	local button = ItemButtons[index%13];
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

local function ClearTypes()
	for i, button in pairs(CategoryButtons) do
		button:SetCategory();
	end
end

local function SetIndex(self, bag, slot)
	if 	bag and slot then
		self.bagID = bag;
		self.slotID = slot;
		self.bag:SetID(bag);
		self.itemBtn:SetID(slot);
		self:UpdateItem(true);
		return true;
	else
		self.bagID = -100;
		self.slotID = -100;
		self.bag:SetID(-100);
		self.itemBtn:SetID(-100);
		self:UpdateItem();
	end
end

local function UpdateItem(self, updateCooldown)
	local itemBtn = self.itemBtn;
	local slotID = self.slotID or itemBtn:GetID();
	local bagID = self.bagID or self:GetID();
	local texture, count, locked, quality, _, _, link =  GetContainerItemInfo(bagID, slotID);
	local isQuestItem, questID, isActive = GetContainerItemQuestInfo(bagID, slotID);
	local time, cooldown = GetContainerItemCooldown(bagID, slotID);
	itemBtn.Cooldown:SetCooldown(time, cooldown);
	if 	updateCooldown and not self.isListItem then
		return;
	end
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
	if self.isListItem then
		if link then
			self.title:SetText(link:gsub("|H(.-)|h%[(.-)%]|h", "|H%1|h%2|h"));
			self:Show();
		else
			self:Hide();
		end
	end
end

local function CreateListCategory(index, scrollFrame)
	local f,p,a,x,y 	= CreateFrame("Button", "ConsolePortContainerListType"..index, scrollFrame);
	if 	CategoryButtons[index-1] then
		p,a,x,y = CategoryButtons[index-1], "BOTTOMLEFT", 0, 0;
	else
		p,a,x,y = scrollFrame, "TOPLEFT", 0, 4;
	end
	f.bg 			= f:CreateTexture(nil, "ARTWORK");
	f.highlight 	= f:CreateTexture(nil, "OVERLAY");
	f.title 		= f:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText");
	f.SetText = function(self, str) self.title:SetText(str); end;
	f.GetText = function(self) return self.title:GetText(); end;
	f.SetCategory = function(self, category) self:SetText(category); self.category = category; end;
	f:RegisterForClicks("AnyUp");

	f:SetScript("OnClick", function(self)
		local category = self.category;
		if category then
			local itemScrollFrame = scrollFrame:GetParent().ItemScrollFrame;
			itemScrollFrame:UpdateListScrollFrame(nil, category, true);
		end
	end);

	f.title:SetWordWrap(true);
	f.bg:SetAtlas("PetList-ButtonBackground");
	f.highlight:SetAtlas("PetList-ButtonSelect");

	f.bg:SetAllPoints(f);
	f.highlight:SetAllPoints(f);

	f.bg:SetAlpha(0.75);
	f.highlight:SetAlpha(0);

	f:SetScript("OnEnter", function(s)
		if s.category then
			Fade(s.highlight, true);
		end
	end);
	f:SetScript("OnLeave", function(s) Fade(s.highlight, false); end);

	f.Enter = f:GetScript("OnEnter");
	f.Leave = f:GetScript("OnLeave");

	f:SetSize(222, 44);
	f.title:SetWidth(200);

	f:SetPoint("TOPLEFT", p, a, x, y);
	f.title:SetPoint("LEFT", f, "LEFT", 10, 0);
	f.title:Show();
	return f;
end

local function CreateListItem(index, scrollFrame)
	local f,p,a,x,y 	= CreateFrame("Frame", "ConsolePortContainerListItem"..index, scrollFrame);
	if 	ItemButtons[index-1] then
		p,a,x,y = ItemButtons[index-1], "BOTTOMRIGHT", 0, 0;
	else
		p,a,x,y = scrollFrame, "TOPRIGHT", 4, 4;
	end 
	f.bag 			= CreateFrame("Frame", nil, f);
	f.itemBtn 		= CreateFrame("Button", f:GetName().."Button", f.bag, "ContainerFrameItemButtonTemplate");
	f.bg 			= f:CreateTexture(nil, "ARTWORK");
	f.highlight 	= f:CreateTexture(nil, "OVERLAY");
	f.title 		= f:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText");
	f.bagID = -1;
	f.slotID = -1;
	f.isListItem = true;
	f.bag:SetID(f.bagID);
	f.itemBtn:SetID(f.slotID);
--	f:RegisterForClicks("AnyUp");
	
	f.title:SetWordWrap(true);

	f.bg:SetAtlas("PetList-ButtonBackground");
	f.highlight:SetAtlas("PetList-ButtonSelect");

	f.bg:SetAllPoints(f);
	f.highlight:SetAllPoints(f);

	f.bg:SetAlpha(0.75);
	f.highlight:SetAlpha(0);

	local Enter = function()
		local typeFrame = Container.ListView.TypeScrollFrame;
		local model = Container.Model;
		local tooltip = Container.Tooltip;
		local item = GetContainerItemLink(f.bagID, f.slotID);
		tooltip:SetBagItem(f, f.bagID, f.slotID);
		model:TryOn(item);
		Container:SetWidth(floor(tooltip:GetWidth())+348);
		Fade(f.highlight, true);
		Fade(typeFrame, false);
	end
	local Leave = function()
		local typeFrame = Container.ListView.TypeScrollFrame;
		local model = Container.Model;
		local tooltip = Container.Tooltip;
		Container:ResetSize();
		Fade(f.highlight, false);
		Fade(typeFrame, true);
		model:Hide();
		tooltip:Hide();
	end

	f.itemBtn.Enter = Enter;
	f.itemBtn.Leave = Leave;
	f:SetScript("OnEnter", Enter);
	f:SetScript("OnLeave", Leave);
	f.itemBtn:SetScript("OnEnter", Enter);
	f.itemBtn:SetScript("OnLeave", Leave);

	f.SetIndex = SetIndex;
	f.UpdateItem = UpdateItem;
	f.itemBtn.Enter = f.itemBtn:GetScript("OnEnter");
	f.itemBtn.Leave = f.itemBtn:GetScript("OnLeave");

	f:RegisterEvent("BAG_UPDATE");
	f:RegisterEvent("BAG_UPDATE_COOLDOWN");
	f:SetScript("OnEvent", function(s, e) s:UpdateItem((e=="BAG_UPDATE_COOLDOWN")); end);

	f.itemBtn:SetHighlightTexture(nil);
	f.itemBtn:GetPushedTexture():SetAtlas("PetList-ButtonHighlight");
	
	f.itemBtn.BattlepayItemTexture:Hide();
	
	f.itemBtn.Cooldown = _G[f.itemBtn:GetName().."Cooldown"];
	f.itemBtn.QuestTexture = _G[f.itemBtn:GetName().."IconQuestTexture"];
	f.itemBtn.NormalTexture = f.itemBtn:GetNormalTexture();

	f.itemBtn:ClearAllPoints();
	f.itemBtn.icon:ClearAllPoints();
	f.itemBtn.Cooldown:ClearAllPoints();
	f.itemBtn.IconBorder:ClearAllPoints();
	f.itemBtn.QuestTexture:ClearAllPoints();
	f.itemBtn.NormalTexture:ClearAllPoints();
	
	f:SetSize(310, 44);
	f.bag:SetSize(36,36);
	f.title:SetWidth(280);
	f.itemBtn:SetSize(300, 36);
	f.itemBtn.icon:SetSize(36,36);
	f.itemBtn.Cooldown:SetSize(36,36);

	f:SetPoint("TOPRIGHT", p, a, x, y);
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

local function SortInventoryTable(a, b)
	local aName = GetItemInfo(a.link);
	local bName = GetItemInfo(b.link);
	if aName == bName then
		return a.count < b.count;
	else
		return aName < bName;
	end
end

local function UpdateListScrollFrame(scrollFrame, delta, newFilter, forceRefresh, updateHeight)
	local inv, tbl, count;
	local needsRefresh = forceRefresh or scrollFrame.forceRefresh;
	local isCategory = scrollFrame.isCategory;
	local slider = scrollFrame.scrollBar;
	
	if isCategory then
		inv = GetInventory();
		tbl = db.pairsByKeys;
		count = inv.Slots.categories;
		inv.Slots = nil;
		ClearTypes();
	else
		local filter = newFilter or scrollFrame.filter;
		inv = newFilter and GetInventory()[filter] or scrollFrame.list;
		tbl = pairs;
		count = inv and #inv or 0;
		scrollFrame.list = inv;
		scrollFrame.filter = filter;
		ClearList();
		if inv then
			sort(inv, SortInventoryTable);
		end
	end
	if 	needsRefresh or updateHeight then
		scrollFrame:Refresh(count, count*LIST_BUTTON_HEIGHT, scrollFrame:GetHeight(), needsRefresh);
	end
	if inv then
		local slotOffset = floor(slider:GetValue()/LIST_BUTTON_HEIGHT);
		local i = 1;
		for x, slot in tbl(inv) do
			local item = isCategory and slot or slot.index;
			if i > slotOffset+NUM_LIST_BUTTONS then
				break;
			elseif i >= slotOffset and isCategory then
				SetCategory(x, i-slotOffset);
			elseif i >= slotOffset then
				SetItem(item.bag, item.slot, i-slotOffset);
			end
			i = i + 1;
		end
	end
end

local function CreateListScrollFrame(list, name, anchor, isCategory)
	local scrollAnchor = (anchor == "RIGHT") and
					{	"TOPRIGHT", "TOPRIGHT", -32, -8,
						"BOTTOMLEFT", "BOTTOMRIGHT", -338, 0} or
					{	"TOPLEFT", "TOPLEFT", 32, -8,
						"BOTTOMRIGHT", "BOTTOMRIGHT", -346, 0};
	local sliderAnchor = (anchor == "RIGHT") and
					{	"TOPLEFT", "TOPRIGHT", 4, -13,
						"BOTTOMLEFT", "BOTTOMRIGHT", 4, 13} or
					{	"TOPLEFT", "TOPLEFT", -24, -13,
						"BOTTOMLEFT", "BOTTOMLEFT", -24, 13};
	local f = CreateFrame("ScrollFrame", name.."ScrollFrame", list, "HybridScrollFrameTemplate");
	f:SetPoint(scrollAnchor[1], list, scrollAnchor[2], scrollAnchor[3], scrollAnchor[4]);
	f:SetPoint(scrollAnchor[5], list, scrollAnchor[6], scrollAnchor[7], scrollAnchor[8]);
	f:SetFrameLevel(list:GetFrameLevel()+1);
	f:EnableMouse(true);
	local s = CreateFrame("Slider", name.."ScrollBar", f, "HybridScrollBarTemplate");
	s:SetPoint(sliderAnchor[1], f, sliderAnchor[2], sliderAnchor[3], sliderAnchor[4]);
	s:SetPoint(sliderAnchor[5], f, sliderAnchor[6], sliderAnchor[7], sliderAnchor[8]);
	s.doNotHide = true;
	f.scrollBar = s;
	f.isCategory = isCategory;
	f.iterator = 1;
	f.forceRefresh = true;
	f.UpdateListScrollFrame = UpdateListScrollFrame;
	f.Scroll = HybridScrollFrame_OnMouseWheel;

	f.Update = HybridScrollFrame_Update;
	f.Refresh = function(self, numButtons, totalHeight, displayedHeight, resetSlider)
		self:Update(totalHeight, displayedHeight);
		self.numButtons = numButtons;
		self.forceRefresh = nil;
		if resetSlider then
			self.scrollBar:SetValue(0);
		end
	end;

	local buttonTable = isCategory and CategoryButtons or ItemButtons;
	local buttonCreate = isCategory and CreateListCategory or CreateListItem;

	for i=1, NUM_LIST_BUTTONS do
		local button = buttonCreate(i, f);
		tinsert(buttonTable, button);
	end
	f.buttons = buttonTable;
	f.buttonHeight = LIST_BUTTON_HEIGHT;

	f:HookScript("OnMouseWheel", UpdateListScrollFrame);
	s:HookScript("OnValueChanged", function(self, value)
		UpdateListScrollFrame(f);
	end);

	f:Refresh(0, 0, f:GetHeight(), true);
	return f;
end

local function UpdateGridItemPosition(index)
	local f = _G["ConsolePortContainerGridItem"..index];
	if f then
		if 	index == 1 then
			f:SetPoint("TOPLEFT", Container.GridView, "TOPLEFT", 4, -4);
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
	local f = _G["ConsolePortContainerGridItem"..index] or CreateFrame("Frame", "ConsolePortContainerGridItem"..index, Container.GridView);
	f:SetSize(40,40);
	f.itemBtn = CreateFrame("Button", f:GetName().."Button", f, "ContainerFrameItemButtonTemplate");
	f.itemBtn:SetPoint("CENTER", f, "CENTER");
	f.itemBtn.Cooldown = _G[f.itemBtn:GetName().."Cooldown"];
	f.itemBtn.QuestTexture = _G[f.itemBtn:GetName().."IconQuestTexture"];
	f.itemBtn.Enter = f.itemBtn:GetScript("OnEnter");
	f.itemBtn.Leave = f.itemBtn:GetScript("OnLeave");
	f.itemBtn.BattlepayItemTexture:Hide();
	UpdateGridItemPosition(index);
	return f;
end

local function UpdateGridView(self, updateCooldown)
	local slotsTotal = GetSlotCount();
	local index, newGrid, button, itemBtn, texture, count, locked, quality, isQuestItem, questID, isActive, time, cooldown = 1;
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			button = GridButtons[index];
			itemBtn = button.itemBtn;
			index = index + 1;
			button:SetID(bag);
			itemBtn:SetID(slot);
			if not button:IsVisible() then
				button:Show();
			end
			UpdateItem(button, updateCooldown);
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
			self.GridView.height = 26+40*(ceil(slotsTotal/GridMod));
			self.GridView.width = GridMod*40+10;
			self:ResetSize();
		end
	end
end

local function BagIconUpdate(self, _, updateID)
	local ID = self:GetID();
	if GetContainerNumSlots(ID) == 0 then
		self:Hide();
		return;
	end
	if ID == updateID then
		SetBagPortraitTexture(self.Portrait, ID);
		self:Show();
		self.Filter:Hide();
		if ID ~= 0 and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(ID)) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if 	GetBagSlotFlag(ID, i) then
					self.Filter:SetAtlas(BAG_FILTER_ICONS[i], true);
					self.FlagText = BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]);
					self.Filter:Show();
					break;
				else
					self.FlagText = nil;
				end
			end
		end
	end 
end

local function AppendFilterFlag(self)
	local ID = self:GetID();
	GameTooltip:AddLine("Bag size: |cffffffff"..GetContainerNumSlots(ID).."|r");
	if self.localFlag and BAG_FILTER_LABELS[self.localFlag] then
		GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[self.localFlag]));
	elseif not self.localFlag then
		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			local active = false;
			if  ID > NUM_BAG_SLOTS then
				active = GetBankBagSlotFlag(ID - NUM_BAG_SLOTS, i);
			else
				active = GetBagSlotFlag(ID, i);
			end
			if 	active then
				GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]));
				break;
			end
		end
	end
end

local function BagIconEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	local ID = self:GetID();
	if  ID == 0 then
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0);
		GameTooltip:AddLine("Bag size: |cffffffff"..GetContainerNumSlots(ID).."|r");
	else
		local link = GetInventoryItemLink("player", ContainerIDToInventoryID(ID));
		local name, _, quality = GetItemInfo(link);
		local r, g, b = GetItemQualityColor(quality);
		GameTooltip:SetText(name, r, g, b);
		AppendFilterFlag(self);
	end
	GameTooltip:AddLine(CLICK_BAG_SETTINGS);
	GameTooltip:Show();
	local slotOffset = 0;
	for i=1, ID do
		slotOffset = slotOffset + GetContainerNumSlots(i-1);
	end
	for i=slotOffset+1, slotOffset+GetContainerNumSlots(ID) do
		GridButtons[i].itemBtn:LockHighlight();
	end
end

local function BagIconLeave(self)
	GameTooltip:Hide();
	local ID = self:GetID();
	local slotOffset = 0;
	for i=1, ID do
		slotOffset = slotOffset + GetContainerNumSlots(i-1);
	end
	for i=slotOffset+1, slotOffset+GetContainerNumSlots(ID) do
		GridButtons[i].itemBtn:UnlockHighlight();
	end
	GridButtons[GridIterator].itemBtn:LockHighlight();
end

local function BagIconClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	ToggleDropDownMenu(1, nil, self.DropDown, self, 0, 0);
end

local function FilterDropDown(self, level)
	local frame = self:GetParent();
	local ID = frame:GetID();

	local info = UIDropDownMenu_CreateInfo();	

	if ID > 0 and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(ID)) then
		info.text = BAG_FILTER_ASSIGN_TO;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info.isTitle = nil;
		info.notCheckable = nil;
		info.tooltipWhileDisabled = 1;
		info.tooltipOnButton = 1;

		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			if  i ~= LE_BAG_FILTER_FLAG_JUNK  then
				info.text = BAG_FILTER_LABELS[i];
				info.func = function(_, _, _, value)
					value = not value;
					if ID > NUM_BAG_SLOTS then
						SetBankBagSlotFlag(ID - NUM_BAG_SLOTS, i, value);
					else
						SetBagSlotFlag(ID, i, value);
					end
					if 	value then
						frame.localFlag = i;
						frame.Filter:SetAtlas(BAG_FILTER_ICONS[i]);
						frame.Filter:Show();
					else
						frame.Filter:Hide();
						frame.localFlag = -1;						
					end
				end;
				if 	frame.localFlag then
					info.checked = frame.localFlag == i;
				else
					if 	ID > NUM_BAG_SLOTS then
						info.checked = GetBankBagSlotFlag(ID - NUM_BAG_SLOTS, i);
					else
						info.checked = GetBagSlotFlag(ID, i);
					end
				end
				info.disabled = nil;
				info.tooltipTitle = nil;
				UIDropDownMenu_AddButton(info);
			end
		end
	end

	info.text = BAG_FILTER_CLEANUP;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.disabled = nil;

	info.text = BAG_FILTER_IGNORE;
	info.func = function(_, _, _, value)
		if 	ID == -1 then
			SetBankAutosortDisabled(not value);
		elseif ID == 0 then
			SetBackpackAutosortDisabled(not value);
		elseif ID > NUM_BAG_SLOTS then
			SetBankBagSlotFlag(ID - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value);
		else
			SetBagSlotFlag(ID, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value);
		end
	end;
	if 	ID == -1 then
		info.checked = GetBankAutosortDisabled();
	elseif ID == 0 then
		info.checked = GetBackpackAutosortDisabled();
	elseif ID > NUM_BAG_SLOTS then
		info.checked = GetBankBagSlotFlag(ID - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP);
	else
		info.checked = GetBagSlotFlag(ID, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP);
	end
	UIDropDownMenu_AddButton(info);
end


function ConsolePort:CreateContainerFrame()
	if not ConsolePortContainer then
		-----------------------------------
		-- Create main bag frame wrapper --
		-----------------------------------
		local CLICK = db.CLICK;
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
		local name = "ConsolePortContainer";
		local f = CreateFrame("Frame", name, UIParent);
		Container = f;
		f.GetInventory = GetInventory;
		f.UpdateGridView = UpdateGridView;
		f:SetSize(600, 550);
		f:Show();
		f.ResetSize = function(self)
			if 	self.GridView:IsVisible() then
				self:SetSize(self.GridView.width, self.GridView.height);
			else
				self:SetSize(600, 550);
			end
		end
		----------------------
		-- View mode frames --
		----------------------
		f.ListView = CreateFrame("Frame", nil, f);
		f.GridView = CreateFrame("Frame", nil, f);
		f.ListView.ItemScrollFrame = CreateListScrollFrame(f.ListView, name.."Item", "RIGHT", false);
		f.ListView.TypeScrollFrame = CreateListScrollFrame(f.ListView, name.."Type", "LEFT", true);
		f.ListView.ItemScrollFrame.NextList = f.ListView.TypeScrollFrame;
		f.ListView.TypeScrollFrame.NextList = f.ListView.ItemScrollFrame;
		f.GridView:SetScript("OnShow", function(s)
			ConsolePortSettings.showGrid = true
			f.ListView:Hide();
			UpdateGridView(f);
			UpdateGridView(f, true);
		end);
		f.ListView:SetScript("OnShow", function(s)
			ConsolePortSettings.showGrid = false
			s.ItemScrollFrame:UpdateListScrollFrame();
			s.TypeScrollFrame:UpdateListScrollFrame();
			f.CurrencyFrame:SetWidth(600);
			f.GridView:Hide();
			f:ResetSize();
		end);
		f.ListView:Hide();
		f.GridView:Hide();
		List = f.ListView.TypeScrollFrame; -- set default list
		-------------------------
		-- Custom game tooltip --
		-------------------------
		f.Tooltip = CreateFrame("GameTooltip", name.."Tooltip", f, "GameTooltipTemplate");
		f.Tooltip:SetBackdrop(nil);
		f.Tooltip.shoppingTooltips = GameTooltip.shoppingTooltips;
		f.Tooltip.CompareItem = GameTooltip_ShowCompareItem;
		f.Tooltip.AddBagItem = f.Tooltip.SetBagItem;
		f.Tooltip.SetBagItem = function(self, owner, bagID, slotID)
			local yOffset = (f:GetTop()-owner:GetTop())+42;
			self:SetOwner(owner);
			self:SetAnchorType("ANCHOR_BOTTOMLEFT", -8, yOffset);
			local cooldown = self:AddBagItem(bagID, slotID);
		end
		f.Tooltip:HookScript("OnTooltipSetItem", function(self)
			self:SetMinimumWidth(232);
			local item = self:GetItem();
			if not InCombatLockdown() then
				local clickString = MerchantFrame:IsVisible() 	and CLICK.SELL or
									IsEquippableItem(item) 		and CLICK.EQUIP or
									GetItemSpell(item) 			and CLICK.USE;
				self:AddDoubleLine(	clickString,
									(clickString == CLICK.USE) and CLICK.ADD_TO_EXTRA or
									(clickString == CLICK.EQUIP) and CLICK.COMPARE, 1, 1, 1);
			end
		end);
		f.Tooltip:HookScript("OnEvent", function(self, event, ...)
			self[event](self, ...);
		end);
		f.Tooltip.MODIFIER_STATE_CHANGED = function(self, ...)
			local modifier, down = ...;
			if 	IsShiftKeyDown() then
				self:CompareItem();
			else
				self.shoppingTooltips[1]:Hide();
				self.shoppingTooltips[2]:Hide();
			end
		end
		f.Tooltip.UpdateItem = function(self)
			local owner = self:GetOwner();
			local bagID, slotID = owner and owner.bagID, owner and owner.slotID;
			if owner and not owner:IsVisible() or not bagID or not slotID then
				self:Hide();
			else
				self:SetBagItem(owner, bagID, slotID);
			end
		end
		f.Tooltip.BAG_UPDATE = f.Tooltip.UpdateItem;
		f.Tooltip.BAG_UPDATE_COOLDOWN = f.Tooltip.UpdateItem;
		f.Tooltip:RegisterEvent("BAG_UPDATE");
		f.Tooltip:RegisterEvent("BAG_UPDATE_COOLDOWN");
		f.Tooltip:RegisterEvent("MODIFIER_STATE_CHANGED");
		--------------------------------
		-- Header frames and textures --
		--------------------------------
		f.Header = CreateFrame("Button", nil, f);
		f.Header:SetSize(40,40);
		f.Header:SetScript("OnClick", function() f:Hide(); end);
		f.Header.BagIcon = f.Header:CreateTexture(nil, "ARTWORK");
		f.Header.BagIcon:SetTexture("Interface\\Buttons\\Button-Backpack-Up");
		f.Header.BagIcon:SetSize(38,38);
		f.Header.BagIconFrame = f.Header:CreateTexture(nil, "OVERLAY");
		f.Header.BagIconFrame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
		f.Header.BagIconFrame:SetTexCoord(0, 0.5625, 0, 0.5625);
		f.Header.BagIconFrame:SetSize(44, 44);
		f.Header.BagIconFrame:SetDesaturated(1);
		f.Header.TitleBar = f.Header:CreateTexture(nil, "BACKGROUND");
		f.Header.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Background");
		f.Header.TitleBar:SetDesaturated(1);
		f.Header.TitleBar:SetHeight(52);
		f.Header.TitleBar:SetTexCoord(0, 0.6640625, 0, 1);
		f.Header.TitleText = f.Header:CreateFontString(nil, "ARTWORK", "GameFontNormalLeftBottom");
		f.Header.TitleText:SetText("Inventory");
		-----------------------------------------
		-- Dress up model for previewing items --
		-----------------------------------------
		f.Model = CreateFrame("DressUpModel", name.."Model", f.ListView);
		f.Model:SetWidth(250);
		f.Model:SetAllPoints(f.ListView.TypeScrollFrame);
		f.Model:SetPoint("BOTTOMLEFT", f.ListView.TypeScrollFrame, "BOTTOMLEFT", -32, 0);
		f.Model:SetPoint("BOTTOMRIGHT", f.ListView.TypeScrollFrame, "BOTTOMRIGHT", 0, 0);
		f.Model:SetPoint("TOPLEFT", f.ListView.TypeScrollFrame, "TOPLEFT", -32, -270);
		f.Model:SetPoint("TOPRIGHT", f.ListView.TypeScrollFrame, "TOPRIGHT", 0, -270);
		f.Model:SetUnit("player");
		f.Model.rotation = 0;
		f.Model:Hide();
		f.Model.TryOnItem = f.Model.TryOn;
		f.Model.TryOn = function(self, item)
			if IsDressableItem(item) then
				self:Show();
				self:Dress();
				self:TryOnItem(item);
				UIFrameFadeIn(self, 2, 0, 0.5);
			else
				self:Hide();
			end
		end
		f.Model:SetScript("OnUpdate", function(s, e)
			s.rotation = s.rotation >= 2 and 0 or s.rotation + 0.0025;
			s:SetFacing(math.pi*s.rotation);
		end);
		------------------------
		-- Background texture --
		------------------------
		local bg = f:CreateTexture(nil, "BACKGROUND");
		bg:SetAtlas("QuestLogBackground");
		bg:SetAllPoints(f);
		bg:SetAlpha(0.5);
		--------------------------------------
		-- Currency frames and sort buttons --
		--------------------------------------
		f.ToggleView = CreateFrame("Button", name.."ToggleView", f);
		f.AutoSort = CreateFrame("Button", name.."AutoSort", f);
		f.CurrencyFrame = CreateFrame("Frame", name.."CurrencyFrame", f);
		f.CurrencyFrame:SetHeight(20);
		f.MoneyFrame = CreateFrame("Frame", name.."MoneyFrame", f.CurrencyFrame, "SmallMoneyFrameTemplate");
		f.SlotsUsed = f.Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
		------------------------
		-- View toggler setup --
		------------------------
		f.ToggleView:SetSize(32, 32);
		f.ToggleView:SetNormalTexture("Interface\\Buttons\\UI-Panel-BiggerButton-Up");
		f.ToggleView:SetPushedTexture("Interface\\Buttons\\UI-Panel-BiggerButton-Down");
		f.ToggleView:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD");
		f.ToggleView:SetScript("OnClick", function(self)
			if f.GridView:IsVisible() then f.ListView:Show(); else f.GridView:Show(); end
		end);
		----------------------
		-- Auto sort button --
		----------------------
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
		f.AutoSort:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end);
		------------------------------
		-- Container filter buttons --
		------------------------------
		for i=0, 4 do
			local p = CreateFrame("BUTTON", nil, f);
			local pD = CreateFrame("FRAME", name.."Portrait"..i.."DropDown", p, "UIDropDownMenuTemplate");
			local pB = p:CreateTexture(nil, "ARTWORK", nil, 1);
			local pT = p:CreateTexture(nil, "ARTWORK", nil, 2);
			local pO = p:CreateTexture(nil, "OVERLAY", nil, 1);
			local pF = p:CreateTexture(nil, "OVERLAY", nil, 3);
			local pH = p:CreateTexture(nil, "OVERLAY", nil, 2);
			f.GridView["PortraitButton"..i] = p;
			p:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 30*i+30, 10);
			p:SetID(i);
			p:SetSize(22,22);
			pT:SetAllPoints(p);
			SetBagPortraitTexture(pT, i);
			pB:SetAllPoints(p);
			pB:SetTexture("Interface\\Buttons\\Button-Backpack-Up");
			pO:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder.blp");
			pO:SetPoint("TOPLEFT", p, db.GUIDE.BORDER_X_LARGE, db.GUIDE.BORDER_Y_SMALL);
			pO:SetSize(db.GUIDE.BORDER_S_SMALL, db.GUIDE.BORDER_S_SMALL);
			pO:SetDesaturated(1);
			pF:SetAtlas("bags-icon-consumables");
			pF:SetPoint("TOPLEFT", p, "TOPLEFT", 6, -6);
			pF:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", 8, -8);
			pH:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");
			pH:SetAllPoints(p);
			p:SetHighlightTexture(pH);
			p.DropDown = pD;
			p.Portrait = pT;
			p.Border = pO;
			p.Filter = pF;
			p:RegisterEvent("BAG_UPDATE");
			p:SetScript("OnEvent", BagIconUpdate);
			p:SetScript("OnEnter", BagIconEnter);
			p:SetScript("OnLeave", BagIconLeave);
			p:SetScript("OnClick", BagIconClick);
			BagIconUpdate(p, nil, i);
			UIDropDownMenu_Initialize(pD, FilterDropDown, "MENU");
		end
		----------------------------------------
		-- Hijack and move token to bag frame --
		----------------------------------------
		for i=1, 3 do
			f["Token"..i] = _G["BackpackTokenFrameToken"..i];
			f["Token"..i]:SetParent(f);
			f["Token"..i]:ClearAllPoints();
		end
		------------------------------------------
		-- Frame border textures and properties --
		------------------------------------------
		local Corner, Vertical, Horizontal, Lion, TL, TR, BL, BR =
			"Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner",
			"Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Left",
			"Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Top",
			"Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human",
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
			HeaderBorder = { width = 0, height = 12,
						anchor1 = {TR, f.Header, TL, -2, 0},
						anchor2 = {BL, f, TL, 30, 30},
						texture = Horizontal, coord = {0.87, 0, 0, 1}, parent = f.Header, level = 1;
			},
			LionTL = {	width = 80, height = 80,
						anchor1 = {BR, f, TL, 40, 0},
						texture = Lion, parent = f.Header, level = 7,
			},
			ListSeparator = {	width = 12, height = 0,
						anchor1 = {TR, f.ListView.ItemScrollFrame, TL, 0, 4},
						anchor2 = {BR, f.ListView.ItemScrollFrame, BL, 0, 0},
						texture = Vertical,  coord = {1, 0, 0.87, 0}, parent = f.ListView,
			},
		}

		for name, b in pairs(Borders) do
			local t = b.parent:CreateTexture(nil, "ARTWORK", nil, b.level);
			f["Border"..name] = t;
			t:SetTexture(b.texture);
			t:SetSize(b.width, b.height);
			t:SetPoint(unpack(b.anchor1));
			if b.anchor2 then
				t:SetPoint(unpack(b.anchor2));
			end
			if b.coord then
				t:SetTexCoord(unpack(b.coord));
			end
		end
		-------------------------------------------------
		-- Set points for container frame and children --
		-------------------------------------------------
		local Points = {
			{f, 				"BOTTOMRIGHT", 	UIParent, 			"BOTTOMRIGHT", -93, 130},
			{f.Header,			"TOPLEFT",		f, 					"TOPRIGHT", -24, 42},
			{f.Header.BagIcon,	"CENTER", 		f.Header,			"CENTER", -1, 2},
			{f.Header.BagIconFrame, "CENTER",	f.Header,			"CENTER"},
			{f.Header.TitleBar,	"BOTTOMRIGHT",	f, 					"TOPRIGHT", 24, -10},
			{f.Header.TitleBar,	"BOTTOMLEFT",	f, 					"TOPLEFT", -24, -10},
			{f.Header.TitleText,"LEFT", 		f.Header.TitleBar, 	"RIGHT", -166, 4},
			{f.ToggleView,		"TOP", 			f.AutoSort,			"BOTTOM", 0, 0},
			{f.AutoSort,		"TOPRIGHT", 	f,					"TOPLEFT", -4, 0},
			{f.ListView, 		"TOPLEFT", 		f, 					"TOPLEFT"},
			{f.ListView, 		"BOTTOMRIGHT", 	f, 					"BOTTOMRIGHT", 0, 20},
			{f.GridView, 		"TOPLEFT", 		f, 					"TOPLEFT"},
			{f.GridView, 		"BOTTOMRIGHT", 	f,					"BOTTOMRIGHT", 0, 20},
			{f.CurrencyFrame, 	"TOPLEFT", 		f, 					"BOTTOMLEFT", 0, 20},
			{f.CurrencyFrame, 	"TOPRIGHT", 	f, 					"BOTTOMRIGHT", 0, 20},
			{f.SlotsUsed, 		"LEFT", 		f.Header.TitleText, "RIGHT", 4, 0},
			{f.MoneyFrame, 		"RIGHT", 		f.CurrencyFrame, 	"RIGHT"},
			{f.Token1, 			"LEFT", 		f.CurrencyFrame, 	"LEFT"},
			{f.Token2, 			"LEFT", 		f.Token1, 			"RIGHT"},
			{f.Token3, 			"LEFT", 		f.Token2, 			"RIGHT"},
		}

		for i, point in pairs(Points) do
			point[1]:SetPoint(point[2], point[3], point[4], point[5], point[6]);
		end
		----------------------------
		-- Add backdrop to frames --
		----------------------------
		f:SetBackdrop(backdrop);
		f.CurrencyFrame:SetBackdrop(backdrop);
		f:SetBackdropBorderColor(1, 0.675, 0.125, 1);
		f.CurrencyFrame:SetBackdropBorderColor(1, 0.675, 0.125, 1);
		--------------------------
		-- Frame re-positioning --
		--------------------------
		f:EnableMouse(true);
		f:SetMovable(true);
		f:RegisterForDrag("LeftButton");

		f:SetScript("OnDragStart", f.StartMoving);
		f:SetScript("OnDragStop", f.StopMovingOrSizing);
		-------------------
		-- Event handler --
		-------------------
		f:RegisterEvent("BAG_UPDATE");
		f:RegisterEvent("BAG_UPDATE_COOLDOWN");
		f:SetScript("OnEvent", function(s,e,...)
			if s:IsVisible() then
				Inventory = s:GetInventory();
				if 	s.GridView:IsVisible() then
					s:UpdateGridView((e=="BAG_UPDATE_COOLDOWN"));
				else
					s.ListView.TypeScrollFrame:UpdateListScrollFrame(nil, nil, true);
					s.ListView.ItemScrollFrame:UpdateListScrollFrame(nil, s.ListView.ItemScrollFrame.filter, false, true);
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
		----------------------------------
		-- Create the grid view buttons --
		----------------------------------
		for i=1, 180 do -- each bag has 36 potential slots so create 5*36 = 180 (backpack only has 16 but w/e)
			local gridItem = CreateGridItem(i);
			tinsert(GridButtons, gridItem);
		end
		------------------------------------------------------------------
		-- Declare the frame special and hook it to binding redirection --
		------------------------------------------------------------------
		tinsert(UISpecialFrames, name);
		self:ADDON_LOADED("ConsolePort_Container");
	elseif ConsolePortContainer:IsVisible() then
		ConsolePortContainer:Hide();
	else
		ConsolePortContainer:Show();
	end
end