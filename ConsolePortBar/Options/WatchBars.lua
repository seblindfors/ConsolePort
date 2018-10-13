local _, ab = ...
local FadeIn, FadeOut = ab.data.UIFrameFadeIn, ab.data.UIFrameFadeOut

-------------------------------------------
---		Watch bar container
-------------------------------------------
function ab.bar:OnStatusBarsUpdated()
	-- do nothing atm, but necessary for Blizzard code to not go pear-shaped
end


local WBC = CreateFrame('Frame', '$parentWatchBars', ab.bar, 'StatusTrackingBarManagerTemplate')
WBC:SetPoint('BOTTOMLEFT', 90, 0) 
WBC:SetPoint('BOTTOMRIGHT',-90, 0)
WBC:SetHeight(16)
WBC:SetFrameStrata('LOW')

for i, region in pairs({WBC:GetRegions()}) do
	-- get rid of all the textures that come with the template
	region:SetTexture(nil)
end

WBC.BGLeft = WBC:CreateTexture(nil, 'BACKGROUND')
WBC.BGLeft:SetPoint('TOPLEFT')
WBC.BGLeft:SetPoint('BOTTOMRIGHT', WBC, 'BOTTOM', 0, 0)
WBC.BGLeft:SetColorTexture(0, 0, 0, 1)
WBC.BGLeft:SetGradientAlpha('HORIZONTAL', 0, 0, 0, 0, 0, 0, 0, 1)

WBC.BGRight = WBC:CreateTexture(nil, 'BACKGROUND')
WBC.BGRight:SetColorTexture(0, 0, 0, 1)
WBC.BGRight:SetPoint('TOPRIGHT')
WBC.BGRight:SetPoint('BOTTOMLEFT', WBC, 'BOTTOM', 0, 0)
WBC.BGRight:SetGradientAlpha('HORIZONTAL', 0, 0, 0, 1, 0, 0, 0, 0)

ab.bar.WatchBarContainer = WBC

local function BarColorOverride(self)
	if (ab.cfg and ab.cfg.expRGB) and (WBC.mainBar == self) then
		self:SetBarColorRaw(unpack(ab.cfg.expRGB))
	end
end

function WBC:AddBarFromTemplate(frameType, template)
	local bar = CreateFrame(frameType, nil, self, template)
	table.insert(self.bars, bar)
	bar.StatusBar.Background:Hide()
	bar.StatusBar.BarTexture:SetTexture([[Interface\AddOns\ConsolePortBar\Textures\XPBar]])
	bar.SetBarColorRaw = bar.SetBarColor

	bar:HookScript('OnEnter', function()
		FadeIn(self, 0.2, self:GetAlpha(), 1)
	end)

	bar:HookScript('OnLeave', function()
		if (ab.cfg and not ab.cfg.watchbars) or not ab.cfg then
			FadeOut(self, 0.2, self:GetAlpha(), 0)
		end
	end)

	bar:HookScript('OnShow', BarColorOverride)
	hooksecurefunc(bar, 'SetBarColor', BarColorOverride)

	self:UpdateBarsShown()
	return bar
end

function WBC:LayoutBar(bar, barWidth, isTopBar, isDouble)
	bar:Update()
	bar:Show()
	bar:ClearAllPoints()
	
	if ( isDouble ) then
		if ( isTopBar ) then
			bar:SetPoint("BOTTOM", self:GetParent(), 0, 14)
		else
			bar:SetPoint("BOTTOM", self:GetParent(), 0, 2)
		end
		self:SetDoubleBarSize(bar, barWidth)
	else 
		bar:SetPoint("BOTTOM", self:GetParent(), 0, 0)
		self:SetSingleBarSize(bar, barWidth)
	end
end

function WBC:SetMainBarColor(r, g, b)
	if self.mainBar then
		self.mainBar:SetBarColorRaw(r, g, b)
	end
end

function WBC:LayoutBars(visBars)
	local width = self:GetWidth()
	self:HideStatusBars()

	local TOP_BAR, IS_DOUBLE = true, true
	if ( #visBars > 1 ) then
		self:LayoutBar(visBars[1], width, not TOP_BAR, IS_DOUBLE)
		self:LayoutBar(visBars[2], width, TOP_BAR, IS_DOUBLE)
	elseif( #visBars == 1 ) then 
		self:LayoutBar(visBars[1], width, TOP_BAR, not IS_DOUBLE)
	end
	self.mainBar = visBars and visBars[1]
	self:GetParent():OnStatusBarsUpdated()
	self:UpdateBarTicks()
end

WBC:AddBarFromTemplate('FRAME', 'ReputationStatusBarTemplate')
WBC:AddBarFromTemplate('FRAME', 'HonorStatusBarTemplate')
WBC:AddBarFromTemplate('FRAME', 'ArtifactStatusBarTemplate')
WBC:AddBarFromTemplate('FRAME', 'AzeriteBarTemplate')

do 	local xpBar = WBC:AddBarFromTemplate('FRAME', 'ExpStatusBarTemplate')
	xpBar.ExhaustionLevelFillBar:SetTexture([[Interface\AddOns\ConsolePortBar\Textures\XPBar]])
end

WBC:SetScript('OnShow', function(self)
	if ab.cfg and ab.cfg.watchbars then
		FadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self:SetAlpha(0)
	end
end)