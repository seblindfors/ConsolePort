local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------

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
		local text = env:GetTooltipPromptForClick('LeftButton', USE)
		if text then
			GameTooltip:AddLine(text, 1, 1, 1)
			GameTooltip:Show()
		end
	end
end

function Item:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

---------------------------------------------------------------
local ItemManager = { query = {}, items = {} };
---------------------------------------------------------------

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
end

function ItemManager:BAG_UPDATE_DELAYED()
	if InCombatLockdown() then self.dirty = true return end;
	CPAPI.IteratePlayerInventory(self.InventoryIterator)
	self:ProcessResults()
	self:RenderItems()
end

function ItemManager:PLAYER_REGEN_ENABLED()
	if not self.dirty then return end;
	self.dirty = self:BAG_UPDATE_DELAYED()
end

function ItemManager:SPELL_UPDATE_COOLDOWN()
	for button in self.buttonPool:EnumerateActive() do
		button:UpdateCooldown()
	end
end

function ItemManager:ProcessResults()
	local query = self.query;
	local items = wipe(self.items);

	-- Filter unique items into categories.
	local unique = {};
	for _, item in ipairs(query) do
		if not unique[item.itemID] then
			local category = item.classID == Enum.ItemClass.Consumable and item.itemSubType or item.itemType;
			items[category] = items[category] or {};
			tinsert(items[category], item);
			unique[item.itemID] = true;
		end
	end

	-- Consolidate categories with only one item.
	local variousName, variousItems = {}, {};
	for category, itemList in env.table.spairs(items) do
		if #itemList == 1 then
			tinsert(variousItems, itemList[1]);
			tinsert(variousName, category);
		end
	end
	for _, name in ipairs(variousName) do
		items[name] = nil;
	end
	if #variousItems > 0 then
		variousName = #variousName > 4 and INVENTORY_TOOLTIP or table.concat(variousName, ' | ');
		items[variousName] = variousItems;
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

function ItemManager:RenderItems()
	self:ReleaseAll()

	local items, index = self.items, CreateCounter();
	for category, itemList in env.table.spairs(items) do
		local header = self:AcquireHeader(index());
		header:SetTitle(category)
		header:SetItems(itemList)
		header:LayoutItems()
		header:Show()
	end
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
		local QMenu = self:GetParent();
		header = CreateFrame('Frame', '$parentItems'..i, QMenu, 'QMenuRow')
		CPAPI.Specialize(header, env.QMenuRow)
		header:SetPool(self.buttonPool)
		header:SetMixin(Item)
		QMenu:AddFrame(header, env.QMenuID())
		self[i] = header;
	end
	return header;
end

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:RegisterSafeCallback('QMenu.Loaded', function(QMenu)
	local manager = CPAPI.CreateEventHandler({'Frame', '$parentItems', QMenu}, {
		'PLAYER_REGEN_ENABLED';
		'BAG_UPDATE_DELAYED';
		'SPELL_UPDATE_COOLDOWN';
	});
	CPAPI.Specialize(manager, ItemManager);
end)