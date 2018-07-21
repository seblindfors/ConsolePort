-- This was mostly stolen from Bartender4.
-- This code snippet hides and modifies the default action bars.

local _, ab = ...
local Bar = ab.bar
local red, green, blue = ab.data.Atlas.GetCC()

do
	-- Hidden parent frame
	local UIHider = CreateFrame('Frame')
	local FadeIn, FadeOut = ab.data.UIFrameFadeIn, ab.data.UIFrameFadeOut

	-------------------------------------------
	---		UI hider -> dispose of blizzbars
	-------------------------------------------

	UIHider:Hide()
	Bar.UIHider = UIHider

	for _, bar in pairs({
		MainMenuBarArtFrame,
	--	MultiBarLeft,
	--	MultiBarRight,
		MultiBarBottomLeft,
		MultiBarBottomRight }) do
		bar:SetParent(UIHider)
	end

	MainMenuBarArtFrame:Hide()

	-- Hide MultiBar Buttons, but keep the bars alive
	for _, n in pairs({
		'ActionButton',	
	--	'MultiBarLeftButton',
	--	'MultiBarRightButton',
		'MultiBarBottomLeftButton',
		'MultiBarBottomRightButton'	}) do
		for i=1, 12 do
			local b = _G[n .. i]
			b:Hide()
			b:UnregisterAllEvents()
			b:SetAttribute('statehidden', true)
		end
	end

	UIPARENT_MANAGED_FRAME_POSITIONS['MainMenuBar'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['PossessBarFrame'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = nil

	MainMenuBar:EnableMouse(false)
	MicroButtonAndBagsBar:Hide()
	StatusTrackingBarManager:Hide()

	local animations = {MainMenuBar.slideOut:GetAnimations()}
	animations[1]:SetOffset(0,0)

	-------------------------------------------
	---		Watch bar container
	-------------------------------------------
	function Bar:OnStatusBarsUpdated()
	end


	local WBC = CreateFrame('Frame', '$parentWatchBars', Bar, 'StatusTrackingBarManagerTemplate')
	WBC:SetPoint('BOTTOMLEFT', 90, 0) 
	WBC:SetPoint('BOTTOMRIGHT',-90, 0)
	WBC:SetHeight(16)
	WBC:SetFrameStrata('LOW')

	for i, region in pairs({WBC:GetRegions()}) do
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

	Bar.WatchBarContainer = WBC

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

	local xpBar = WBC:AddBarFromTemplate('FRAME', 'ExpStatusBarTemplate')
	xpBar.ExhaustionLevelFillBar:SetTexture([[Interface\AddOns\ConsolePortBar\Textures\XPBar]])

	WBC:SetScript('OnShow', function(self)
		if ab.cfg and ab.cfg.watchbars then
			FadeIn(self, 0.2, self:GetAlpha(), 1)
		else
			self:SetAlpha(0)
		end
	end)

	-------------------------------------------
	--- 	Special action bars
	-------------------------------------------

	for _, bar in pairs({
		StanceBarFrame,
		PossessBarFrame,
		PetActionBarFrame	}) do
		bar:UnregisterAllEvents()
		bar:SetParent(UIHider)
		bar:Hide()
	end

	-------------------------------------------
	--- 	Casting bar modified
	-------------------------------------------

	local castBar, overrideCastBarPos = CastingBarFrame
	local castBarAnchor = {'BOTTOM', Bar,  'BOTTOM', 0, 0}

	hooksecurefunc(castBar, 'SetPoint', function(self, point, region, relPoint, x, y)
		if overrideCastBarPos and region ~= castBarAnchor[2] then
			self:SetPoint(unpack(castBarAnchor))
		end
	end)

	local function ModifyCastingBarFrame(self, isOverrideBar)
		CastingBarFrame_SetLook(self, isOverrideBar and 'CLASSIC' or 'UNITFRAME')
		self.Border:SetShown(isOverrideBar)
		if isOverrideBar then
			return
		end
		-- Text anchor
		self.Text:SetPoint('TOPLEFT', 0, 0)
		self.Text:SetPoint('TOPRIGHT', 0, 0)
		-- Flash at the end of a cast
		self.Flash:SetTexture('Interface\\QUESTFRAME\\UI-QuestLogTitleHighlight')
		self.Flash:SetAllPoints()
		-- Border shield for uninterruptible casts
		self.BorderShield:ClearAllPoints()
		self.BorderShield:SetTexture('Interface\\CastingBar\\UI-CastingBar-Arena-Shield')
		self.BorderShield:SetPoint('CENTER', self.Icon, 'CENTER', 10, 0)
		self.BorderShield:SetSize(49, 49)

		local r, g, b = ab:GetRGBColorFor('exp')
		CastingBarFrame_SetStartCastColor(self, r or 1.0, g or 0.7, b or 0.0)
	end

	local function MoveCastingBarFrame()
		local cfg = ab.cfg
		if cfg and cfg.disableCastBarHook then
			overrideCastBarPos = false
		elseif OverrideActionBar:IsShown() or (cfg and cfg.defaultCastBar) then
			ModifyCastingBarFrame(castBar, true)
			overrideCastBarPos = false
		else
			castBarAnchor[4] = ( cfg and cfg.castbarxoffset or 0 )
			castBarAnchor[5] = ( cfg and cfg.castbaryoffset or 0 )
			ModifyCastingBarFrame(castBar, false)
			castBar:ClearAllPoints()
			castBar:SetPoint(unpack(castBarAnchor))
			castBar:SetSize(
				(cfg and cfg.castbarwidth) or (Bar:GetWidth() - 280),
				(cfg and cfg.castbarheight) or 14)
			overrideCastBarPos = true
		end
	end

	Bar:HookScript('OnSizeChanged', MoveCastingBarFrame)
	Bar:HookScript('OnShow', MoveCastingBarFrame)
	Bar:HookScript('OnHide', MoveCastingBarFrame)
	OverrideActionBar:HookScript('OnShow', MoveCastingBarFrame)
	OverrideActionBar:HookScript('OnHide', MoveCastingBarFrame) 

	-------------------------------------------
	--- 	Misc changes
	-------------------------------------------

	ObjectiveTrackerFrame:SetPoint('TOPRIGHT', MinimapCluster, 'BOTTOMRIGHT', -100, -132)
	AlertFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 200)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	else
		hooksecurefunc('TalentFrame_LoadUI', function() PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED') end)
	end

	-- Replace spell push animations. 
	IconIntroTracker:HookScript('OnEvent', function(self, event, ...)
		local anim = ConsolePortSpellHelperFrame
		if anim and event == 'SPELL_PUSHED_TO_ACTIONBAR' then
			for _, icon in pairs(self.iconList) do
				icon:ClearAllPoints()
				icon:SetAlpha(0)
			end

			local spellID, slotIndex, slotPos = ...
			local page = math.floor((slotIndex - 1) / NUM_ACTIONBAR_BUTTONS) + 1
			local currentPage = GetActionBarPage()
			local bonusBarIndex = GetBonusBarIndex()
			if (HasBonusActionBar() and bonusBarIndex ~= 0) then
				currentPage = bonusBarIndex
			end

			if (page ~= currentPage and page ~= MULTIBOTTOMLEFTINDEX) then
				return
			end
			
			local _, _, icon = GetSpellInfo(spellID)
			local actionID = ((page - 1) * NUM_ACTIONBAR_BUTTONS) + slotPos

			anim:OnActionPlaced(actionID, icon)
		end
	end)
end