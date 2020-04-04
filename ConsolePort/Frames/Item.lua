---------------------------------------------------------------
-- Item.lua: Popup menu for managing container items
---------------------------------------------------------------
local _, db = ...
local Core, ItemMenu, ItemMenuButtonMixin = ConsolePort, ConsolePortItemMenu, {}
---------------------------------------------------------------
local INDEX_BAGS_COUNT = 2
local INDEX_BAGS_NOVAL = 9
---------------------------------------------------------------
local INDEX_INFO_ILINK = 2
local INDEX_INFO_STACK = 8
local INDEX_INFO_EQLOC = 9
local INDEX_INFO_CLASS = 12
---------------------------------------------------------------
local COMMAND_OPT_ICON = {
	Default   = [[Interface\QuestFrame\UI-Quest-BulletPoint]];
	Sell      = [[Interface\GossipFrame\BankerGossipIcon]];
	Split     = [[Interface\Cursor\UI-Cursor-SizeLeft]];
	Equip     = [[Interface\GossipFrame\transmogrifyGossipIcon]];
	Pickup    = [[Interface\Cursor\openhand]];
	Delete    = [[Interface\Buttons\UI-GroupLoot-Pass-Up]];
	QuickBind = [[Interface\Buttons\UI-AttributeButton-Encourage-Up]];
}
local INV_EQ_LOCATIONS = {
	INVTYPE_WEAPON  = {INVSLOT_MAINHAND, INVSLOT_OFFHAND};
	INVTYPE_FINGER  = {INVSLOT_FINGER1,  INVSLOT_FINGER2};
	INVTYPE_TRINKET = {INVSLOT_TRINKET1, INVSLOT_TRINKET2};
	INVTYPE_WEAPONMAINHAND = {INVSLOT_MAINHAND};
	INVTYPE_WEAPONOFFHAND  = {INVSLOT_OFFHAND};
	INVTYPE_BAG = { 20, 21, 22, 23 };
}
local QUICK_BIND_TYPES = {
	[LE_ITEM_CLASS_CONSUMABLE] = true;
	[LE_ITEM_CLASS_QUESTITEM]  = true;
	[LE_ITEM_CLASS_WEAPON]     = true;
}
---------------------------------------------------------------

function ItemMenu:SetItem(bagID, slotID)
	self:SetBagAndSlot(bagID, slotID)
	self:SetItemLocation(self)

	if self:IsItemEmpty() then
		return self:Hide()
	end

	local count = self:GetCount()
	self.Count:SetText(count > 1 and ('x'..count) or '')
	self.Icon:SetTexture(self:GetItemIcon())
	self.Name:SetText(self:GetItemName())
	self.Name:SetTextColor(self:GetItemQualityColor().color:GetRGB())

	self:SetTooltip()
	self:SetCommands()
	self:FixSize()
	self:Show()
	self:RedirectCursor()
end

function ItemMenu:FixSize()
	local lastItem = self.itemPool:GetObjectByIndex(self.itemPool:GetNumActive())
	if lastItem then
		local height = self:GetHeight() or 0
		local bottom = self:GetBottom() or 0
		local anchor = lastItem:GetBottom() or 0
		self:SetHeight(height + bottom - anchor + 16)
	end
end

function ItemMenu:RedirectCursor()
	self.returnToNode = self.returnToNode or Core:GetCurrentNode()
	Core:SetCurrentNode(self.itemPool:GetObjectByIndex(1))
end

function ItemMenu:SetCommands()
	self.itemPool:ReleaseAll()

	if self:IsEquippableItem() then
		self:AddEquipCommands()
	end

	if self:IsQuickBindItem() and (self:IsUsableItem() or self:IsEquippableItem()) then
		self:AddCommand(db('TOOLTIP/ADD_TO_EXTRA'), 'QuickBind')
	end

	if self:IsSellableItem() then
		self:AddCommand('Sell', 'Sell')
	end

	if self:IsSplittableItem() then
		self:AddCommand(db('TOOLTIP/STACK_SPLIT'), 'Split')
	end

	self:AddCommand(db('TOOLTIP/PICKUP'), 'Pickup')
	self:AddCommand(DELETE, 'Delete')
end

function ItemMenu:GetEquipCommand(invSlot, i, numSlots)
	local item = GetInventoryItemID('player', invSlot)
	local link = item and select(INDEX_INFO_ILINK, GetItemInfo(item))
	return {
		text =  link and (REPLACE..' '..link)
				or numSlots > 1 and EQUIPSET_EQUIP .. (' (%s/%s %s)'):format(i, numSlots, SLOT_ABBR)
				or EQUIPSET_EQUIP;
		data = invSlot;
		free = not link;
	}
end

function ItemMenu:AddEquipCommands()
	local slots = INV_EQ_LOCATIONS[self:GetInventoryLocation()] or {self:GetInventoryType()}
	local commands = {}
	local foundFree = false

	for i, slot in ipairs(slots) do
		local command = self:GetEquipCommand(slot, i, #slots)
		if ( command.free and not foundFree ) then
			foundFree = true
			tinsert(commands, 1, command)
		else
			tinsert(commands, command)
		end
	end
	-- add in order (make sure 'Equip' comes first)
	for i, command in ipairs(commands) do
		self:AddCommand(command.text, 'Equip', command.data)
	end
end

function ItemMenu:AddCommand(text, command, data)
	local option = self.itemPool:Acquire()
	local anchor = self.itemPool:GetObjectByIndex(self.itemPool:GetNumActive()-1)
	
	option:SetCommand(text, command, data)
	option:SetPoint('TOPLEFT', anchor or self.Tooltip, 'BOTTOMLEFT', anchor and 0 or 8, anchor and 0 or -16)
	option:Show()
end

---------------------------------------------------------------
-- Tooltip hacks
---------------------------------------------------------------
function ItemMenu.Tooltip:GetTooltipStrings(index)
	local name = self:GetName()
	return _G[name .. 'TextLeft' .. index], _G[name .. 'TextRight' .. index]
end

function ItemMenu.Tooltip:Readjust()
	self:SetBackdrop(nil)
	self:SetWidth(340)
	self:GetTooltipStrings(1):Hide()
	local i, left, right = 2, self:GetTooltipStrings(2)
	while left and right do
		right:ClearAllPoints()
		right:SetPoint('LEFT', left, 'RIGHT', 0, 0)
		right:SetPoint('RIGHT', -32, 0)
		right:SetJustifyH('RIGHT')
		i = i + 1
		left, right = self:GetTooltipStrings(i)
	end
	self:GetParent():FixSize()
end

function ItemMenu.Tooltip:OnUpdate(elapsed)
	self.tooltipUpdate = self.tooltipUpdate + elapsed
	if self.tooltipUpdate > 0.25 then
		self:Readjust()
		self.tooltipUpdate = 0
	end
end

function ItemMenu:SetTooltip()
	local tooltip = self.Tooltip
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetBagItem(self:GetBagAndSlot())
	tooltip:Show()
	tooltip:ClearAllPoints()
	tooltip:SetPoint('TOPLEFT', 80, -16)
end

function ItemMenu:ClearTooltip()
	self.Tooltip:Hide()
end

ItemMenu.Tooltip.tooltipUpdate = 0
ItemMenu.Tooltip:HookScript('OnUpdate', ItemMenu.Tooltip.OnUpdate)
ItemMenu.Tooltip:HookScript('OnTooltipSetItem', ItemMenu.Tooltip.Readjust)

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function ItemMenu:GetSpellID()
	return GetItemSpell(self:GetItemID())
end

function ItemMenu:GetCount()
	return select(INDEX_BAGS_COUNT, GetContainerItemInfo(self:GetBagAndSlot()))
end

function ItemMenu:GetStackCount()
	return select(INDEX_INFO_STACK, GetItemInfo(self:GetItemID()))
end

function ItemMenu:GetInventoryLocation()
	return select(INDEX_INFO_EQLOC, GetItemInfo(self:GetItemID()))
end

function ItemMenu:HasNoValue()
	return select(INDEX_BAGS_NOVAL, GetContainerItemInfo(self:GetBagAndSlot()))
end

function ItemMenu:IsQuickBindItem()
	return QUICK_BIND_TYPES[select(INDEX_INFO_CLASS, GetItemInfo(self:GetItemID()))]
end

function ItemMenu:IsSplittableItem()
	return self:GetStackCount() > 1 and self:GetCount() > 1
end

function ItemMenu:IsEquippableItem()
	return IsEquippableItem(self:GetItemID())
end

function ItemMenu:IsUsableItem()
	return self:GetSpellID() and true
end

function ItemMenu:IsSellableItem()
	return self.merchantAvailable and not self:HasNoValue()
end

---------------------------------------------------------------
-- Commands
---------------------------------------------------------------
function ItemMenu:Pickup()
	PickupContainerItem(self:GetBagAndSlot())
	self:Hide()
end

function ItemMenu:Delete()
	PickupContainerItem(self:GetBagAndSlot())
	DeleteCursorItem()
	self:Hide()
end

function ItemMenu:Equip(slot)
	if self:IsEquippableItem() then
		PickupContainerItem(self:GetBagAndSlot())
		EquipCursorItem(slot or self:GetInventoryType())
	end
	self:Hide()
end

function ItemMenu:Sell()
	-- confirm to ensure item isn't used
	if self:IsSellableItem() then
		UseContainerItem(self:GetBagAndSlot())
	end
	self:Hide()
end

function ItemMenu:Split()
	CPAPI:OpenStackSplitFrame(self:GetCount(), self, 'TOP', 'BOTTOM')
end

function ItemMenu:SplitStack(count)
	local bagID, slotID = self:GetBagAndSlot()
	SplitContainerItem(bagID, slotID, count)
	self:Hide()
end

function ItemMenu:QuickBind()
	Core:AddUtilityAction('item', self:GetItemID())
	self:Hide()
end

---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
function ItemMenuButtonMixin:OnClick()
	if self.command then
		self:GetParent()[self.command](self:GetParent(), self.data)
	end
end

function ItemMenuButtonMixin:SpecialClick()
	self:OnClick()
end

function ItemMenuButtonMixin:SetCommand(text, command, data)
	self.data = data
	self.command = command
	self.Icon:SetTexture(COMMAND_OPT_ICON[command] or COMMAND_OPT_ICON.Default)
	self:SetText(text)
end

---------------------------------------------------------------
-- Handlers and init
---------------------------------------------------------------
function ItemMenu:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function ItemMenu:OnHide()
	if self.returnToNode then
		Core:SetCurrentNode(self.returnToNode)
		self.returnToNode = nil
	end
end

function ItemMenu:MERCHANT_SHOW()
	self.merchantAvailable = true
end

function ItemMenu:MERCHANT_CLOSED()
	self.merchantAvailable = false
end

function ItemMenu:PLAYER_REGEN_DISABLED()
	self:Hide()
end

function ItemMenu:BAG_UPDATE_DELAYED()
	if self:IsShown() then
		self:SetItem(self.bagID, self.slotIndex)
	end
end

---------------------------------------------------------------
for _, event in ipairs({
	'MERCHANT_SHOW',
	'MERCHANT_CLOSED',
	'BAG_UPDATE_DELAYED',
	'PLAYER_REGEN_DISABLED',
}) do ItemMenu:RegisterEvent(event) end

ItemMenu:SetScript('OnEvent', ItemMenu.OnEvent)
ItemMenu:SetScript('OnHide', ItemMenu.OnHide)
ItemMenu.itemPool = ConsolePortUI:CreateFramePool(
	'Button', ItemMenu,
	'ConsolePortPopupButtonTemplate',
	ItemMenuButtonMixin
);
Core:AddFrame(ItemMenu)