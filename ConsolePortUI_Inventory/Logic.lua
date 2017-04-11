local _, L = ...
local Inventory = {}
local UI = ConsolePortUI
local KEY = ConsolePort:GetData().KEY
local Control = UI:GetControlHandle()
L.InventoryMixin = Inventory

function Inventory:OnShow()
	Control:AddHint(KEY.CROSS, USE)
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
		focusButton:UnlockHighlight()
	end
	focusButton = button
	if button then
		button:LockHighlight()
	end
end

function Inventory:Update()
	for idx, button in pairs(self.Active) do
		local bag, slot = button:GetAttribute('bag'), button:GetAttribute('slot')
		local	texture, itemCount, locked,
				quality, readable, _, _,
				isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(bag, slot)

		SetItemButtonTexture(button, texture)
		SetItemButtonQuality(button, quality, itemID)
		SetItemButtonCount(button, itemCount)
		SetItemButtonDesaturated(button, locked)
	end

end

function Inventory:Close()
	CloseAllBags()
end

function Inventory:OnButtonPressed()
	PlaySound('igMainMenuOptionCheckBoxOn')
end