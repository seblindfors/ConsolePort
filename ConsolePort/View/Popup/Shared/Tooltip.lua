---------------------------------------------------------------
-- Tooltip hacks
---------------------------------------------------------------
local Tooltip = ConsolePortPopupMenuTooltip;

function Tooltip:GetTooltipStrings(index)
	local name = self:GetName()
	return _G[name .. 'TextLeft' .. index], _G[name .. 'TextRight' .. index]
end

function Tooltip:Readjust()
	self.NineSlice:Hide()
	self:SetWidth(self:GetParent():GetWidth() - 100)
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
	self:GetParent():FixHeight()
end

function Tooltip:OnUpdate(elapsed)
	self.tooltipUpdate = self.tooltipUpdate + elapsed
	if self.tooltipUpdate > 0.25 then
		self:Readjust()
		self.tooltipUpdate = 0
	end
end

Tooltip.tooltipUpdate = 0
Tooltip:HookScript('OnUpdate', Tooltip.OnUpdate)
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
	local function ReadjustWrapper(self)
		if not (self == Tooltip) then return end
		self:Readjust()
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ReadjustWrapper)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, ReadjustWrapper)
else
	Tooltip:HookScript('OnTooltipSetItem', Tooltip.Readjust)
	Tooltip:HookScript('OnTooltipSetSpell', Tooltip.Readjust)
end