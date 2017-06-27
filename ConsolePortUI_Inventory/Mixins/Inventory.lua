local _, L = ...
local Inventory = {}
local db = ConsolePort:GetData()
local UI = ConsolePortUI
local KEY = db.KEY
local Control = UI:GetControlHandle()
L.InventoryMixin = Inventory

function Inventory:OnLoad()
	for _, event in pairs({
		-------------------------
		'BAG_UPDATE',
		-------------------------
	}) do self:RegisterEvent(event) end
end


function Inventory:OnHide()
	wipe(self.Active)
end

function Inventory:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Inventory:OnShow()
	self:GetParent():SetIcon([[Interface\Icons\INV_Misc_Bag_29]])
	self:GetParent():SetTitle(INVENTORY_TOOLTIP)
end

function Inventory:OnButtonShow(name)
	local button = _G[name]
	self.Active[#self.Active + 1] = button
end

function Inventory:Update()
	self:BAG_UPDATE()
	self:BAG_UPDATE_COOLDOWN()
end

function Inventory:SortBags()
	BagItemAutoSortButton:Click()
end

function Inventory:PickupItem(name)
	local button = _G[name]
	PickupContainerItem(button:GetBagSlotIndex())
end

function Inventory:MoveItem(fromSlot, toSlot)
	if fromSlot and toSlot then
		ClearCursor()
		PickupContainerItem(_G[fromSlot]:GetBagSlotIndex())
		PickupContainerItem(_G[toSlot]:GetBagSlotIndex())
	end
end

function Inventory:OnButtonPressed()
	PlaySound('igMainMenuOptionCheckBoxOn')
end
		
-------------------------
-- Events
-------------------------

function Inventory:BAG_UPDATE()
	for idx, button in pairs(self.Active) do
		button:Update()
	end
	if focusButton then
		self:OnButtonFocused(focusButton:GetName())
	end
end

function Inventory:BAG_UPDATE_COOLDOWN()
	for idx, button in pairs(self.Active) do
		button:UpdateCooldown()
	end
end