local _, L = ...
local Merchant = {}
local db = ConsolePort:GetData()
local UI = ConsolePortUI
local KEY = db.KEY
local Control = UI:GetControlHandle()
L.MerchantMixin = Merchant


--function CreateFramePool(frameType, parent, frameTemplate, resetterFunc)

function Merchant:OnShow()
	self:GetParent():SetUnitPortrait('npc')
	PanelTemplates_TabResize(self.ItemTab, 0, nil, 100, 200, 100)
	PanelTemplates_TabResize(self.BuybackTab, 0, nil, 100, 200, 100)
	PanelTemplates_TabResize(self.FilterTab, 0, nil, 100, 200, 100)

	PanelTemplates_DeselectTab(self.BuybackTab)
	PanelTemplates_DeselectTab(self.FilterTab)

	self:ShowItems()
end

function Merchant:ResetElements()
	self.itemPool:ReleaseAll()
end

function Merchant:ShowItems()
	self:ResetElements()
	local childHeight, prevButton = 0
	for i=1, GetMerchantNumItems() do
		local button = self.itemPool:Acquire()

		button:UpdateItem(GetMerchantItemInfo(i))

		if prevButton then
			button:SetPoint('TOP', prevButton, 'BOTTOM', 0, -2)
		else
			button:SetPoint('TOPLEFT', 16, 0)
		end
		button:Show()
		childHeight = childHeight + button:GetHeight()
		prevButton = button
	end

	self.Items.Child:SetWidth(500)
	self.Items.Child:SetHeight(childHeight)
end

function Merchant:OnHide()
	if self.itemPool then
		self.itemPool:ReleaseAll()
	end
end

function Merchant:MERCHANT_UPDATE()

end


function Merchant:OnLoad()
	self.itemPool = UI:CreateFramePool('Button', self.Items.Child, 'CPUIMerchantItemTemplate', L.MerchantItemMixin)
	self.OnLoad = nil
end

function Merchant:OnInput(key, down)
	
end