local _, L = ...
local MerchantItem = {}
L.MerchantItemMixin = MerchantItem

function MerchantItem:UpdateItem(...)
	local name, texture, price, quantity, numAvailable, isUsable, extendedCost = ...
--	print(name, texture, price)

	self.name:SetText(name)
	self.icon:SetTexture(texture)

	MoneyFrame_Update(self.money, price)
end