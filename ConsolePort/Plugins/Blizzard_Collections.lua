-- Workaround for the wardrobe collection models, which behave as buttons
-- using OnMouseDown, making the interface cursor dismiss the objects as
-- regular unclickable frames. 
local _, db = ...

ConsolePort:AddPlugin('Blizzard_Collections', function(self)
	if UIPanelWindows.WardrobeFrame then
		UIPanelWindows.WardrobeFrame.area = 'center'
	end

	local function TransmogNodeOnClick(self, button)
		self:GetParent():OnMouseDown(button)
	end

	local function TransmogNodeOnEnter(self)
		self:GetParent():OnEnter()
	end

	local function TransmogNodeOnLeave(self)
		self:GetParent():OnLeave()
	end

	for i, model in ipairs(WardrobeCollectionFrame.ItemsCollectionFrame.Models) do
		local node = CreateFrame('Button', 'TransmogModelNode'..i, model)
		node:SetScript('OnClick', TransmogNodeOnClick)
		node:SetScript('OnEnter', TransmogNodeOnEnter)
		node:SetScript('OnLeave', TransmogNodeOnLeave)
		node:SetSize(4, 4)
		node:SetPoint('BOTTOM', 0, 10)
		model.includeChildren = true
	end
end)