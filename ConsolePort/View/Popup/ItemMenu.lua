---------------------------------------------------------------
-- Item.lua: Popup menu for managing container items
---------------------------------------------------------------
local _, db, L = ...; L = db.Locale;
local ItemMenu = db:Register('ItemMenu', CPAPI.EventHandler(ConsolePortItemMenu, {
	'MERCHANT_SHOW';
	'MERCHANT_CLOSED';
	'BAG_UPDATE_DELAYED';
	'PLAYER_REGEN_DISABLED';
}))
---------------------------------------------------------------
local INDEX_INFO_ILINK = 2
local INDEX_INFO_ITEMQ = 3
local INDEX_INFO_STACK = 8
local INDEX_INFO_EQLOC = 9
local INDEX_INFO_CLASS = 12
---------------------------------------------------------------
local QUALITY_STANDARD = Enum.ItemQuality.Standard or Enum.ItemQuality.Common;
local INV_EQ_LOCATIONS = {
	INVTYPE_WEAPON  = {INVSLOT_MAINHAND, INVSLOT_OFFHAND};
	INVTYPE_FINGER  = {INVSLOT_FINGER1,  INVSLOT_FINGER2};
	INVTYPE_TRINKET = {INVSLOT_TRINKET1, INVSLOT_TRINKET2};
	INVTYPE_WEAPONMAINHAND = {INVSLOT_MAINHAND};
	INVTYPE_WEAPONOFFHAND  = {INVSLOT_OFFHAND};
	INVTYPE_BAG = { 20, 21, 22, 23 };
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
	self:FixHeight()
	self:Show()
	self:RedirectCursor()
end

function ItemMenu:FixHeight()
	local lastItem = self:GetObjectByIndex(self:GetNumActive())
	if lastItem then
		local height = self:GetHeight() or 0
		local bottom = self:GetBottom() or 0
		local anchor = lastItem:GetBottom() or 0
		self:SetHeight(height + bottom - anchor + 16)
	end
end

function ItemMenu:RedirectCursor()
	self.returnToNode = self.returnToNode or ConsolePortCursor:GetCurrentNode()
	ConsolePortCursor:SetCurrentNode(self:GetObjectByIndex(1))
end

function ItemMenu:ReturnCursor()
	if self.returnToNode then
		ConsolePortCursor:SetCurrentNode(self.returnToNode)
		self.returnToNode = nil
	end
end

---------------------------------------------------------------
-- Add item commands
---------------------------------------------------------------
function ItemMenu:SetCommands()
	self:ReleaseAll()

	if self:IsEquippableItem() then
		self:AddEquipCommands()
	end

	if self:IsUsableItem() or self:IsEquippableItem() then
		self:AddUtilityRingCommand()
	end

	if self:IsSellableItem() then
		self:AddCommand('Sell', 'Sell')
	end

	if self:IsSplittableItem() then
		self:AddCommand(L'Split stack', 'Split')
	end

	self:AddCommand(L'Pick up', 'Pickup')
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

function ItemMenu:AddUtilityRingCommand()
	local link = self:GetLink()
	local action = {
		type = 'item';
		item = link;
		link = link;
	};

	if db.Utility:SetPendingAction(1, action) then
		self:AddCommand(L'Add to Utility Ring', 'RingBind')
	else
		local _, existingIndex = db.Utility:IsUniqueAction(1, action)
		if existingIndex then
			db.Utility:SetPendingRemove(1, action)
			self:AddCommand(L'Remove from Utility Ring', 'RingClear')
		end
	end
end

function ItemMenu:AddCommand(text, command, data)
	local widget, newObj = self:Acquire(self:GetNumActive() + 1)
	local anchor = self:GetObjectByIndex(self:GetNumActive() - 1)

	if newObj then
		widget:SetScript('OnClick', widget.OnClick)
	end
	
	widget:SetCommand(text, command, data)
	widget:SetPoint('TOPLEFT', anchor or self.Tooltip, 'BOTTOMLEFT', anchor and 0 or 8, anchor and 0 or -16)
	widget:Show()
end

---------------------------------------------------------------
-- Tooltip
---------------------------------------------------------------
ItemMenu.Tooltip = ConsolePortPopupMenuTooltip;

function ItemMenu:SetTooltip()
	local tooltip = self.Tooltip
	tooltip:SetParent(self)
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetBagItem(self:GetBagAndSlot())
	tooltip:Show()
	tooltip:ClearAllPoints()
	tooltip:SetPoint('TOPLEFT', 80, -16)
end

function ItemMenu:ClearTooltip()
	self.Tooltip:Hide()
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function ItemMenu:GetSpellID()
	return GetItemSpell(self:GetItemID())
end

function ItemMenu:GetLink()
	return (select(INDEX_INFO_ILINK, GetItemInfo(self:GetItemID())))
end

function ItemMenu:GetQuality()
	return (select(INDEX_INFO_ITEMQ, GetItemInfo(self:GetItemID())))
end

function ItemMenu:GetCount()
	return CPAPI.GetContainerItemInfo(self:GetBagAndSlot()).stackCount;
end

function ItemMenu:GetStackCount()
	return select(INDEX_INFO_STACK, GetItemInfo(self:GetItemID()))
end

function ItemMenu:GetInventoryLocation()
	return select(INDEX_INFO_EQLOC, GetItemInfo(self:GetItemID()))
end

function ItemMenu:HasNoValue()
	return CPAPI.GetContainerItemInfo(self:GetBagAndSlot()).hasNoValue;
end

function ItemMenu:IsSplittableItem()
	return self:GetStackCount() > 1 and self:GetCount() > 1
end

function ItemMenu:IsEquippableItem()
	return IsEquippableItem(self:GetItemID())
end

function ItemMenu:IsUsableItem()
	return self:GetSpellID() and true;
end

function ItemMenu:IsSellableItem()
	return self.merchantAvailable and not self:HasNoValue()
end

---------------------------------------------------------------
-- Commands
---------------------------------------------------------------
function ItemMenu:Pickup()
	CPAPI.PickupContainerItem(self:GetBagAndSlot())
	self:Hide()
end

function ItemMenu:Delete()
	CPAPI.PickupContainerItem(self:GetBagAndSlot())
	local link, quality, hasSpellID = self:GetLink(), self:GetQuality(), self:GetSpellID();
	self:Hide()
	-- show confirm popup for good+ and usable items
	if hasSpellID or ( quality > QUALITY_STANDARD ) then
		StaticPopup_Show('DELETE_ITEM', link)
	else
		DeleteCursorItem()
	end
end

function ItemMenu:Equip(slot)
	if self:IsEquippableItem() then
		CPAPI.PickupContainerItem(self:GetBagAndSlot())
		EquipCursorItem(slot or self:GetInventoryType())
	end
	self:Hide()
end

function ItemMenu:Sell()
	-- confirm to ensure item isn't used
	if self:IsSellableItem() then
		CPAPI.UseContainerItem(self:GetBagAndSlot())
	end
	self:Hide()
end

function ItemMenu:Split()
	CPAPI.OpenStackSplitFrame(self:GetCount(), self, 'TOP', 'BOTTOM')
end

function ItemMenu:SplitStack(count)
	local bagID, slotID = self:GetBagAndSlot()
	CPAPI.SplitContainerItem(bagID, slotID, count)
	self:Hide()
end

function ItemMenu:RingBind()
	if db.Utility:HasPendingAction() then
		db.Utility:PostPendingAction()
	end
	self:Hide()
end

ItemMenu.RingClear = ItemMenu.RingBind;


---------------------------------------------------------------
-- Handlers and init
---------------------------------------------------------------
function ItemMenu:OnHide()
	self:ReturnCursor()
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
ItemMenu:SetScript('OnHide', ItemMenu.OnHide)
Mixin(ItemMenu, CPIndexPoolMixin):OnLoad()
ItemMenu:CreateFramePool('Button', 'CPPopupButtonTemplate', db.PopupMenuButton)
db.Stack:AddFrame(ItemMenu)