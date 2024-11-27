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
local INV_EQ_LOCATIONS = {
	INVTYPE_RANGED         = CPAPI.IsClassicVersion and {'RANGEDSLOT'};
	INVTYPE_CLOAK          = {'BACKSLOT'};
	INVTYPE_FINGER         = {'FINGER0SLOT',  'FINGER1SLOT'};
	INVTYPE_TRINKET        = {'TRINKET0SLOT', 'TRINKET1SLOT'};
	INVTYPE_WEAPON         = {'MAINHANDSLOT', 'SECONDARYHANDSLOT'};
	INVTYPE_WEAPONMAINHAND = {'MAINHANDSLOT'};
	INVTYPE_2HWEAPON       = {'MAINHANDSLOT'};
	INVTYPE_WEAPONOFFHAND  = {'SECONDARYHANDSLOT'};
	INVTYPE_SHIELD         = {'SECONDARYHANDSLOT'};
	INVTYPE_BAG            = {'BAG0SLOT', 'BAG1SLOT', 'BAG2SLOT', 'BAG3SLOT'};
}; for _, slots in pairs(INV_EQ_LOCATIONS) do
	for i, slot in ipairs(slots) do
		slots[i] = GetInventorySlotInfo(slot);
	end
end
---------------------------------------------------------------
local QUALITY_STANDARD = Enum.ItemQuality.Standard or Enum.ItemQuality.Common;
local QUALITY_GOOD     = Enum.ItemQuality.Uncommon or Enum.ItemQuality.Good;
local BORDER_ATLAS = CPAPI.Proxy({
	[Enum.ItemQuality.Poor]      = 'auctionhouse-itemicon-border-gray';
	[Enum.ItemQuality.Rare]      = 'auctionhouse-itemicon-border-blue';
	[Enum.ItemQuality.Epic]      = 'auctionhouse-itemicon-border-purple';
	[Enum.ItemQuality.Legendary] = 'auctionhouse-itemicon-border-orange';
	[Enum.ItemQuality.Artifact]  = 'auctionhouse-itemicon-border-artifact';
	[Enum.ItemQuality.Heirloom]  = 'auctionhouse-itemicon-border-account';
	[Enum.ItemQuality.WoWToken]  = 'auctionhouse-itemicon-border-account';
	[QUALITY_STANDARD]           = 'auctionhouse-itemicon-border-white';
	[QUALITY_GOOD]               = 'auctionhouse-itemicon-border-green';
}, 'auctionhouse-itemicon-border-gray')
---------------------------------------------------------------
local DEFAULT_BUTTON_INIT = function(self) self:SetAttribute('type', nil) end;

function ItemMenu:SetItem(bagID, slotID)
	self:SetBagAndSlot(bagID, slotID)
	self:SetItemLocation(self)

	if self:IsItemEmpty() then
		return self:Hide()
	end

	self.Icon:SetTexture(self:GetItemIcon())
	self.Name:SetText(self:GetItemName())
	self.Name:SetTextColor(self:GetItemQualityColor().color:GetRGB())
	self.Border:SetAtlas(BORDER_ATLAS[self:GetQuality()])

	self:ClearPickup()
	self:SetTooltip()
	self:SetCommands()
	self:FixHeight()
	self:Show()
	self:RedirectCursor()
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
		self:AddCommand(L'Sell', 'Sell')
	end

	if self:IsSplittableItem() then
		local count, stackCount = self:GetCount(), self:GetStackCount();
		local color = count == stackCount and GREEN_FONT_COLOR or ORANGE_FONT_COLOR;
		local countText = color:WrapTextInColorCode((' (%d / %d)'):format(count, stackCount))
		self:AddCommand(L'Split stack' .. countText, 'Split')
	end

	if self:IsDisenchantableItem() then	
		self:AddCommand(L'Disenchant', 'Disenchant', {self:GetBagAndSlot()}, nil, function(self)
			local bagID, slotID = unpack(self.data)
			self:SetAttribute('type', 'macro')
			self:SetAttribute('macrotext', '/cast Disenchant\n/use '..bagID..' '..slotID)
		end)
	end

	self:AddCommand(L'Pick up', 'Pickup')
	self:AddCommand(DELETE, 'Delete')
end

function ItemMenu:GetEquipCommand(invSlot, i, numSlots)
	local item = GetInventoryItemID('player', invSlot)
	local link = item and CPAPI.GetItemInfo(item).itemLink;
	return {
		text =  link and (REPLACE..' '..link)
				or numSlots > 1 and EQUIPSET_EQUIP .. (' (%s/%s %s)'):format(i, numSlots, SLOT_ABBR)
				or EQUIPSET_EQUIP;
		data = invSlot;
		free = not link;
		handlers = {
			OnEnter = function(self)
				GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
				GameTooltip:SetInventoryItem('player', invSlot)
				GameTooltip:Show()
				self:LockHighlight()
			end;
			OnLeave = function(self)
				GameTooltip:Hide()
				self:UnlockHighlight()
			end;
		};
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
		self:AddCommand(command.text, 'Equip', command.data, command.handlers)
	end
end

function ItemMenu:AddUtilityRingCommand()
	local link = self:GetLink()
	local action = {
		type = 'item';
		item = link;
		link = link;
	};

	for key in db.table.spairs(db.Utility.Data) do
		local isUniqueAction, existingIndex = db.Utility:IsUniqueAction(key, action)
		if isUniqueAction then
			self:AddCommand(L('Add to %s', db.Utility:ConvertSetIDToDisplayName(key)), 'RingBind', {key, action})
		elseif existingIndex then
			self:AddCommand(L('Remove from %s', db.Utility:ConvertSetIDToDisplayName(key)), 'RingClear', {key, action})
		end
	end
end

function ItemMenu:AddCommand(text, command, data, handlers, init)
	local widget, newObj = self:Acquire(self:GetNumActive() + 1)
	local anchor = self:GetObjectByIndex(self:GetNumActive() - 1)

	if newObj then
		widget:OnLoad()
	end

	widget:SetCommand(text, command, data, handlers, init or DEFAULT_BUTTON_INIT)
	widget:SetPoint('TOPLEFT', anchor or self.Tooltip, 'BOTTOMLEFT', anchor and 0 or self.buttonOffsetX, anchor and 1 or -16)
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
	tooltip:SetPoint('TOPLEFT', self.tooltipOffsetX, -16)
	db.Alpha.FadeIn(self.Tooltip, 0.25, 0, 1)
	if tooltip.TopOverlay and tooltip.TopOverlay:IsShown() then
		tooltip.TopOverlay:ClearAllPoints()
		tooltip.TopOverlay:SetPoint('BOTTOM', self, 'TOP', 0, -16)
	end
	if tooltip.BottomOverlay and tooltip.BottomOverlay:IsShown() then
		tooltip.BottomOverlay:ClearAllPoints()
		tooltip.BottomOverlay:SetPoint('TOP', self, 'BOTTOM', 0, 30)
	end
end

function ItemMenu:ClearTooltip()
	self.Tooltip:Hide()
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function ItemMenu:GetSpellID()
	return CPAPI.GetItemSpell(self:GetItemID())
end

function ItemMenu:GetLink()
	return CPAPI.GetItemInfo(self:GetItemID()).itemLink;
end

function ItemMenu:GetQuality()
	return CPAPI.GetItemInfo(self:GetItemID()).itemQuality;
end

function ItemMenu:GetCount()
	return CPAPI.GetContainerItemInfo(self:GetBagAndSlot()).stackCount;
end

function ItemMenu:GetStackCount()
	return CPAPI.GetItemInfo(self:GetItemID()).itemStackCount;
end

function ItemMenu:GetInventoryLocation()
	return CPAPI.GetItemInfo(self:GetItemID()).itemEquipLoc;
end

function ItemMenu:HasNoValue()
	return CPAPI.GetContainerItemInfo(self:GetBagAndSlot()).hasNoValue;
end

function ItemMenu:IsSplittableItem()
	return self:GetStackCount() > 1 and self:GetCount() > 1
end

function ItemMenu:IsEquippableItem()
	return CPAPI.IsEquippableItem(self:GetItemID())
end

function ItemMenu:IsUsableItem()
	return self:GetSpellID() and true;
end

function ItemMenu:IsSellableItem()
	return self.merchantAvailable and not self:HasNoValue()
end

function ItemMenu:IsDisenchantableItem()
	return CPAPI.CanPlayerDisenchantItem(self:GetItemID())
end

---------------------------------------------------------------
-- Commands
---------------------------------------------------------------
function ItemMenu:Pickup()
	CPAPI.PickupContainerItem(self:GetBagAndSlot())
	self:Hide()
end

function ItemMenu:Disenchant()
	-- Execution handled by macro
	self:Hide()
end

function ItemMenu:Delete()
	CPAPI.PickupContainerItem(self:GetBagAndSlot())
	local link, quality, hasSpellID = self:GetLink(), self:GetQuality(), self:GetSpellID();
	local returnToNode = self.returnToNode;
	self:Hide()
	-- show confirm popup for good+ and usable items
	if hasSpellID or ( quality > QUALITY_STANDARD ) then
		-- HACK: set returnToNode to trick the cursor into returning to the
		-- item trigger itself, instead of the delete button on the popup.
		ConsolePort:SetCursorNode(returnToNode, false, true)
		local popup = StaticPopup_Show('DELETE_ITEM', link)
		if popup then
			ConsolePort:SetCursorNode(popup.button1, false, true)
		end
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

function ItemMenu:RingBind(data)
	local setID, action = unpack(data)
	if db.Utility:SetPendingAction(setID, action) then
		db.Utility:PostPendingAction()
	end
	self:Hide()
end

function ItemMenu:RingClear(data)
	local setID, action = unpack(data)
	if db.Utility:SetPendingRemove(setID, action) then
		db.Utility:PostPendingAction()
	end
	self:Hide()
end

---------------------------------------------------------------
-- Handlers and init
---------------------------------------------------------------
function ItemMenu:Refresh()
	if self:IsShown() then
		self:SetItem(self.bagID, self.slotIndex)
	end
end

function ItemMenu:ClearPickup()
	CPAPI.ClearCursor()
end

function ItemMenu:MERCHANT_SHOW()
	self.merchantAvailable = true;
	self:Refresh()
end

function ItemMenu:MERCHANT_CLOSED()
	self.merchantAvailable = false;
	self:Refresh()
end

function ItemMenu:PLAYER_REGEN_DISABLED()
	self:Hide()
end

function ItemMenu:BAG_UPDATE_DELAYED()
	self:Refresh()
end

---------------------------------------------------------------
ItemMenu:SetAttribute('nodepass', true)
ItemMenu:CreateFramePool('Button', 'CPPopupButtonTemplate', db.PopupMenuButton)
---------------------------------------------------------------
GameMenuFrame:HookScript('OnShow', GenerateClosure(ItemMenu.Hide, ItemMenu))