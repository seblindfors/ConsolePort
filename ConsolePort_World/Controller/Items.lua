local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local ITEMS_ROW_INDEX = env.QMenuID();
---------------------------------------------------------------
local Item = {};
---------------------------------------------------------------
function Item:OnLoad()
	self.Icon = self.icon; -- since "icon" is mixed in by CPAPI.GetItemInfoInstant.
	self:SetAttribute(CPAPI.ActionTypePress, 'item')
	self:SetAttribute(CPAPI.ActionUseOnKeyDown, true)
	self:RegisterForClicks('AnyDown')

	-- LAB API hack
	setmetatable(self, env.ActionButton:GetTypeMetaMap().item)
	env.QMenu:Hook(self, 'PostClick', [[
		if button == 'LeftButton' then
			owner::Disable()
		end
	]])
end

function Item:SetData(data)
	Mixin(self, data)
	self.iconFileID = data.icon;
	self.icon = self.Icon;

	self:SetAttribute('bag', data.bagID)
	self:SetAttribute('slot', data.slotIndex)
	self:SetID(data.itemID)

	-- LAB API data
	self._state_type   = 'item';
	self._state_action = ('item:%s'):format(data.itemID);
	self:Update()
end

function Item:GetAction()
	return self._state_type, self._state_action;
end

function Item:Update()
	self:UpdateCooldown()
	self:SetIcon(self.iconFileID)
	self:SetCount(self:GetCount())
end

function Item:UpdateCooldown()
	local start, duration, enable, modRate = self:GetCooldown()
	CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate)
end

function Item:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
	self:LockHighlight()
end

function Item:UpdateTooltip()
	GameTooltip:SetBagItem(self:GetBagAndSlot())
	if self:IsUsable() then
		local hasAddedLine, text = false, env:GetTooltipPromptForClick('LeftButton', ('%s & %s'):format(USE_ITEM or USE, CLOSE))
		if text then
			hasAddedLine = true;
			GameTooltip:AddLine(text, 1, 1, 1)
		end
		text = env:GetTooltipPromptForClick('RightButton', USE_ITEM or USE)
		if text then
			GameTooltip:AddLine(text, 1, 1, 1)
		end
		if hasAddedLine then
			GameTooltip:Show()
		end
	end
end

function Item:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

---------------------------------------------------------------
local ItemManager = { query = {}, items = {}, types = {} };
---------------------------------------------------------------
-- Layout constants
local BUTTON_SIZE   = 48;
local BUTTON_STRIDE = 52;
local ROW_STRIDE    = 52;
local TITLE_HEIGHT  = 20;
local WRAP_AFTER    = 10;
local BUTTON_GAP    = BUTTON_STRIDE - BUTTON_SIZE;

function ItemManager:OnLoad()
	function self.InventoryIterator(item)
		local itemID = CPAPI.GetContainerItemID(item:GetBagAndSlot())
		if CPAPI.IsUsableItem(itemID) then
			tinsert(self.query, Mixin(item, CPAPI.GetItemInfoInstant(itemID)))
		end
	end;
	local QMenu = self:GetParent();
	self.numButtons = CreateCounter()
	self.buttonPool = CreateObjectPool(function()
		return CreateFrame('Button', '$parentItemSlot'..self.numButtons(), QMenu, 'CPWorldSecureButtonBaseTemplate')
	end, Pool_HideAndClearAnchors)

	self:SetAttribute('nodepass', true)
	self:Hide()
	QMenu:AddFrame(self, ITEMS_ROW_INDEX, true)

	for _, settingID in pairs(self.types) do
		db:RegisterSafeCallback('Settings/'..settingID, self.UpdateAllItems, self)
	end
end

function ItemManager:UpdateAllItems()
	if InCombatLockdown() then self.dirty = true return end;
	CPAPI.IteratePlayerInventory(self.InventoryIterator)
	self:ProcessResults()
	self:RenderItems()
end

function ItemManager:ProcessResults()
	local query = self.query;
	local items = wipe(self.items);
	local types = (function(rawTypes)
		local activeTypes = {};
		for classID, settingID in pairs(rawTypes) do
			if db(settingID) then
				activeTypes[classID] = true;
			end
		end
		return activeTypes;
	end)(self.types)

	-- Sort unique items into categories.
	local unique = {};
	for _, item in ipairs(query) do
		if not unique[item.itemID] then
			local category = item.classID == Enum.ItemClass.Consumable and item.itemSubType or item.itemType;
			if types[item.classID] then
				items[category] = items[category] or {};
				tinsert(items[category], item);
			end
			unique[item.itemID] = true;
		end
	end

	-- Consolidate categories into "Items" to reduce clutter.
	local variousName, variousItems = {}, {};
	for category, itemList in env.table.spairs(items) do
		-- Single items get consolidated by default.
		if ( #itemList == 1 ) then
			local item = itemList[1];
			-- Quest items should always be distinguished, so
			-- only consolidate non-quest items with unique categories.
			if item.classID ~= Enum.ItemClass.Questitem then
				tinsert(variousItems, item);
				tinsert(variousName, category);
			end
		-- "Other" consumables and "Miscellaneous" items are not
		-- meaningfully distinguished, so consolidate them by default.
		elseif ( category == MISCELLANEOUS or category == OTHER ) then
			for _, item in ipairs(itemList) do
				tinsert(variousItems, item);
			end
			tinsert(variousName, category);
		end
	end
	for _, name in ipairs(variousName) do
		items[name] = nil;
	end
	if #variousItems > 0 then
		items[ITEMS] = variousItems;
	end

	-- Sort items by bag and slot index.
	for _, itemList in pairs(items) do
		table.sort(itemList, function(a, b)
			if a.bagID == b.bagID then
				return a.slotIndex < b.slotIndex;
			end
			return a.bagID < b.bagID;
		end)
	end

	wipe(query);
end

function ItemManager:PackRows(categoryList)
	-- Sort categories largest-first for better bin packing
	table.sort(categoryList, function(a, b) return #a.items > #b.items end);

	-- Compute target width from total item count to approximate a square
	local totalItems = 0;
	for _, cat in ipairs(categoryList) do
		totalItems = totalItems + #cat.items;
	end
	local targetWidth = math.min(math.ceil(math.sqrt(totalItems)), WRAP_AFTER);

	-- Compute natural dimensions for each category against targetWidth
	for _, cat in ipairs(categoryList) do
		local n = #cat.items;
		if n > targetWidth then
			local numRows = math.ceil(n / targetWidth);
			cat.wrapAfter = math.ceil(n / numRows);
		else
			cat.wrapAfter = n;
		end
		cat.numRows = math.ceil(n / cat.wrapAfter);
	end

	-- First-fit-decreasing bin packing: prefer targetWidth, allow up to WRAP_AFTER
	local rows = {};
	for _, cat in ipairs(categoryList) do
		local placed = false;
		-- First pass: try to fit within targetWidth
		for _, row in ipairs(rows) do
			if row.usedWidth + cat.wrapAfter <= targetWidth then
				tinsert(row.categories, cat);
				row.usedWidth = row.usedWidth + cat.wrapAfter;
				row.maxNumRows = math.max(row.maxNumRows, cat.numRows);
				placed = true;
				break;
			end
		end
		-- Second pass: allow overflow up to WRAP_AFTER
		if not placed then
			for _, row in ipairs(rows) do
				if row.usedWidth + cat.wrapAfter <= WRAP_AFTER then
					tinsert(row.categories, cat);
					row.usedWidth = row.usedWidth + cat.wrapAfter;
					row.maxNumRows = math.max(row.maxNumRows, cat.numRows);
					placed = true;
					break;
				end
			end
		end
		if not placed then
			tinsert(rows, {
				categories = { cat },
				usedWidth  = cat.wrapAfter,
				maxNumRows = cat.numRows,
			});
		end
	end

	-- Reshape categories to match their row's height for grid-like fill
	for _, row in ipairs(rows) do
		for _, cat in ipairs(row.categories) do
			if cat.numRows < row.maxNumRows and #cat.items > 1 then
				local newWrap = math.max(1, math.ceil(#cat.items / row.maxNumRows));
				cat.wrapAfter = newWrap;
				cat.numRows = math.ceil(#cat.items / cat.wrapAfter);
			end
		end
	end

	return rows;
end

function ItemManager:RenderItems()
	self:ReleaseAll()

	local items = self.items;
	local categoryList = {};

	for category, itemList in env.table.spairs(items) do
		tinsert(categoryList, {
			category = category,
			items    = itemList,
		});
	end

	if #categoryList == 0 then
		self:Hide()
		return;
	end

	local rows = self:PackRows(categoryList);

	local yCursor, maxRowWidth, count = -TITLE_HEIGHT, 0, CreateCounter();
	for _, row in ipairs(rows) do
		local xCursor = 0;
		local rowPixelHeight = BUTTON_SIZE + (row.maxNumRows - 1) * ROW_STRIDE;

		for _, cat in ipairs(row.categories) do
			local header = self:AcquireHeader(count());
			header:SetTitle(cat.category)
			header:SetItems(cat.items)
			header.titleText:SetText(cat.category)

			local catWidth  = (cat.wrapAfter - 1) * BUTTON_STRIDE + BUTTON_SIZE;
			local catHeight = BUTTON_SIZE + (cat.numRows - 1) * ROW_STRIDE;

			header:SetAttribute('wrapAfter', cat.wrapAfter)
			header:ClearAllPoints()
			header:SetPoint('TOPLEFT', self, 'TOPLEFT', xCursor, -(yCursor + TITLE_HEIGHT))
			header:SetSize(catWidth, catHeight)
			header:LayoutItems()
			header:Show()

			xCursor = xCursor + catWidth + BUTTON_GAP;
		end

		maxRowWidth = math.max(maxRowWidth, xCursor - BUTTON_GAP);
		yCursor = yCursor + TITLE_HEIGHT + rowPixelHeight + BUTTON_GAP;
	end

	self:SetSize(math.max(1, maxRowWidth), math.max(1, yCursor - BUTTON_GAP))
	self:Show()
end

---------------------------------------------------------------
-- Widget management
---------------------------------------------------------------
function ItemManager:ReleaseAll()
	for i = 1, #self do
		self[i]:Hide()
	end
	self.buttonPool:ReleaseAll()
end

function ItemManager:AcquireHeader(i)
	local header = self[i];
	if not header then
		header = CreateFrame('Frame', '$parentItemsGroup'..i, self, 'QMenuRowAttributes')
		CPAPI.Specialize(header, env.QMenuRow)
		header:SetPool(self.buttonPool)
		header:SetMixin(Item)

		local title = env.QMenu:CreateTitle(header)
		title:SetPoint('BOTTOMRIGHT', header, 'TOPRIGHT', 0, 4)

		self[i] = header;
	end
	return header;
end

---------------------------------------------------------------
-- Filters
---------------------------------------------------------------
do local _, Data = CPAPI.Define, db.Data;
	local itemCollectionSettings = {_('Quick Menu', INTERFACE_LABEL)};
	for i = 0, Enum.ItemClassMeta.NumValues-1 do
		local name = C_Item.GetItemClassInfo(i)
		if name and not name:match('%b()') then -- exclude (OBSOLETE)
			local settingID = 'QMenuCollectionItemType'..i;
			itemCollectionSettings[settingID] = _{Data.Bool(true);
				name = name;
				desc = 'Show item type in the quick menu.';
				list = ITEMS;
				advd = true;
			};
			ItemManager.types[i] = settingID;
		end
	end
	ConsolePort:AddVariables(itemCollectionSettings)
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
ItemManager.BAG_UPDATE_DELAYED = ItemManager.UpdateAllItems;
ItemManager.PLAYER_ALIVE       = ItemManager.UpdateAllItems;
ItemManager.PLAYER_UNGHOST     = ItemManager.UpdateAllItems;

function ItemManager:PLAYER_REGEN_ENABLED()
	if self.dirty then
		self.dirty = self:UpdateAllItems()
	end
end

function ItemManager:SPELL_UPDATE_COOLDOWN()
	for button in self.buttonPool:EnumerateActive() do
		button:UpdateCooldown()
	end
end

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:RegisterSafeCallback('QMenu.Loaded', function(QMenu)
	local manager = CPAPI.CreateEventHandler({'Frame', '$parentItems', QMenu, 'SecureHandlerBaseTemplate'}, {
		'BAG_UPDATE_DELAYED';
		'PLAYER_ALIVE';
		'PLAYER_REGEN_ENABLED';
		'PLAYER_UNGHOST';
		'SPELL_UPDATE_COOLDOWN';
	});
	CPAPI.Specialize(manager, ItemManager);
end)