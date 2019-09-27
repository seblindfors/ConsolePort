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

function Inventory:OnShow()
end

function Inventory:OnHide()
	wipe(self.Active)
end

function Inventory:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Inventory:OnButtonShow(name)
	local button = _G[name]
	self.Active[#self.Active + 1] = button
end

local focusButton

function Inventory:OnButtonFocused(name)
	local button = _G[name]
	if focusButton then
		focusButton:SetButtonState('NORMAL')
		focusButton:OnFocusLost()
		focusButton:UnlockHighlight()
	end
	focusButton = button
	if button then
		button:OnFocusGained()
		button:LockHighlight()
		if GetContainerItemInfo(button:GetBagSlotIndex()) then
			Control:AddHint(KEY.CIRCLE, NPE_MOVE .. ' / ' .. db.TOOLTIP.PICKUP_ITEM)
			Control:AddHint(KEY.CROSS, USE)
		else
			Control:RemoveHint(KEY.CIRCLE)
			Control:RemoveHint(KEY.CROSS)
		end
	end
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
	PickupContainerItem(button:GetAttribute('bag'), button:GetAttribute('slot'))
end

function Inventory:MoveItem(fromSlot, toSlot)
	if fromSlot and toSlot then
		ClearCursor()
		PickupContainerItem(_G[fromSlot]:GetBagSlotIndex())
		PickupContainerItem(_G[toSlot]:GetBagSlotIndex())
	end
end

function Inventory:OnButtonPressed()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
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