---------------------------------------------------------------
-- Tooltip hacks
---------------------------------------------------------------
local Tooltip, _, db = ConsolePortPopupMenuTooltip, ...;
local STATUSBAR_Y_OFFSET = 21;
local STATUSBAR_X_OFFSET = 16;

function Tooltip:GetTooltipStrings(index)
	local name = self:GetName()
	return _G[name .. 'TextLeft' .. index], _G[name .. 'TextRight' .. index]
end

function Tooltip:GetStatusBar()
	local name = self:GetName()
	return _G[name .. 'StatusBar'];
end

function Tooltip:Readjust()
	self.NineSlice:Hide()
	self:SetWidth(self:GetParent():GetWidth() - 100)
	self:GetTooltipStrings(1):Hide()
	self:SetHeight(max(36, self:GetHeight()))
	local i, left, right = 2, self:GetTooltipStrings(2)
	while left and right do
		right:ClearAllPoints()
		right:SetPoint('LEFT', left, 'RIGHT', 0, 0)
		right:SetPoint('RIGHT', -32, 0)
		right:SetJustifyH('RIGHT')
		i = i + 1
		left, right = self:GetTooltipStrings(i)
	end
	local statusBar = self:GetStatusBar()
	if statusBar:IsVisible() then
		statusBar:ClearAllPoints()
		statusBar:SetPoint('TOPLEFT', self, 'TOPLEFT',
			-self:GetOwner().tooltipOffsetX + STATUSBAR_X_OFFSET,
			STATUSBAR_Y_OFFSET + statusBar.offset);
		statusBar:SetPoint('TOPRIGHT', self, 'TOPRIGHT',
			STATUSBAR_X_OFFSET + 4, STATUSBAR_Y_OFFSET + statusBar.offset)
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

Tooltip.tooltipUpdate = 0;
Tooltip:HookScript('OnUpdate', Tooltip.OnUpdate)

do -- Configure status bar
	local statusBar = Tooltip:GetStatusBar()
	statusBar:Hide()
	statusBar.offset = 0;

	function statusBar:SetColor(color)
		self.color = color;
		if color then
			self:SetStatusBarColor(color:GetRGBA())
		end
	end

	function statusBar:SetOffset(offset)
		self.offset = offset;
		self:GetParent():Readjust()
	end

	statusBar:HookScript('OnValueChanged', function(self)
		if self.color then
			self:SetStatusBarColor(self.color:GetRGBA())
		end
	end)

	local barMask = statusBar:CreateMaskTexture()
	barMask:SetSize(72, 72)
	barMask:SetTexture(CPAPI.GetAsset([[Textures\Button\Icon_Mask64_Reverse]]), 'CLAMPTOWHITE')
	barMask:SetPoint('TOPLEFT', statusBar, 'TOPLEFT', -22, 2)

	local barTexture = statusBar:GetStatusBarTexture()
	barTexture:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\XPBar_Inverted]])
	barTexture:AddMaskTexture(barMask)

	local barBG = statusBar:CreateTexture(nil, 'BACKGROUND')
	barBG:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\XPBar_Inverted]])
	barBG:SetAllPoints()
	barBG:SetVertexColor(0.15, 0.15, 0.15, 1)
	barBG:AddMaskTexture(barMask)
end

-- Readjust tooltip after information has been added
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
	local function ReadjustWrapper(self)
		if not (self == Tooltip) then return end;
		self:Readjust()
		db.Alpha.FadeIn(self:GetStatusBar(), 1, 0, 1)
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,  ReadjustWrapper)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, ReadjustWrapper)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit,  ReadjustWrapper)
else
	Tooltip:HookScript('OnTooltipSetItem', Tooltip.Readjust)
	Tooltip:HookScript('OnTooltipSetSpell', Tooltip.Readjust)
	Tooltip:HookScript('OnTooltipSetUnit', Tooltip.Readjust)
end