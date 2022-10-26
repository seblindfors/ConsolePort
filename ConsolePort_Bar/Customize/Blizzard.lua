-- This was mostly stolen from Bartender4.
-- This code snippet hides and modifies the default action bars.

local _, env = ...
local Bar = env.bar
local red, green, blue = CPAPI.GetClassColor()

do
	-- Hidden parent frame
	local UIHider = CreateFrame('Frame')

	-------------------------------------------
	---		UI hider -> dispose of blizzbars
	-------------------------------------------

	UIHider:Hide()
	Bar.UIHider = UIHider

	local hide = function(_, frame)
		if frame then
			frame:Hide()
			frame:SetParent(UIHider)
		end
	end

	foreach({
		MainMenuBarArtFrame,
	--	MultiBarLeft,
	--	MultiBarRight,
		MultiBarBottomLeft,
		MultiBarBottomRight,
		MainMenuExpBar,
		MainMenuBarPerformanceBar,
		ReputationWatchBar,
		MainMenuBarMaxLevelBar,
		MainMenuBar and MainMenuBar.EndCaps,
		MainMenuBar and MainMenuBar.BorderArt,
		MainMenuBar and MainMenuBar.Background,
	}, hide)
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

	if UIPARENT_MANAGED_FRAME_POSITIONS then 
		UIPARENT_MANAGED_FRAME_POSITIONS['MainMenuBar'] = nil
		UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil
		UIPARENT_MANAGED_FRAME_POSITIONS['PossessBarFrame'] = nil
		UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = nil
		UIPARENT_MANAGED_FRAME_POSITIONS['MultiCastActionBarFrame'] = nil
	end

	if MainMenuBar then
		MainMenuBar:EnableMouse(false)
		if MainMenuBar.slideOut then
			local animations = {MainMenuBar.slideOut:GetAnimations()}
			animations[1]:SetOffset(0,0)
		end
	end

	if StatusTrackingBarManager then StatusTrackingBarManager:Hide() end

	-------------------------------------------
	--- 	Special action bars
	-------------------------------------------

	for _, name in pairs({
		'StanceBarFrame',
		'PossessBarFrame',
		'PetActionBar',
		'PetActionBarFrame'
	}) do
		local frame = _G[name]
		if frame then
			frame:UnregisterAllEvents()
			frame:SetParent(UIHider)
			frame:Hide()
		end
	end

	if MultiCastActionBarFrame then
		MultiCastActionBarFrame:SetScript('OnUpdate', nil)
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetPoint('BOTTOM', Bar, 'BOTTOM', 0, 120)
	end

	-------------------------------------------
	--- 	Casting bar modified
	-------------------------------------------

	local castBar, overrideCastBarPos = CastingBarFrame
	local castBarAnchor = {'BOTTOM', Bar,  'BOTTOM', 0, 0}

	if castBar then
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

			local r, g, b = env:GetRGBColorFor('exp')
			CastingBarFrame_SetStartCastColor(self, r or 1.0, g or 0.7, b or 0.0)
		end

		local function MoveCastingBarFrame()
			local cfg = env.cfg
			if cfg and cfg.disableCastBarHook then
				overrideCastBarPos = false
			elseif OverrideActionBar and OverrideActionBar:IsShown() or (cfg and cfg.defaultCastBar) then
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

		if OverrideActionBar then
			OverrideActionBar:HookScript('OnShow', MoveCastingBarFrame)
			OverrideActionBar:HookScript('OnHide', MoveCastingBarFrame)
		end 
	end

	-------------------------------------------
	--- 	Misc changes
	-------------------------------------------
	AlertFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 200)

	if CPAPI.IsRetailVersion then
		if PlayerTalentFrame then
			PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		else
			hooksecurefunc('TalentFrame_LoadUI', function()
				if PlayerTalentFrame then
					PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
				end 
			end)
		end
	end

	if MainMenuBarVehicleLeaveButton and MainMenuBarVehicleLeaveButton_Update then
		hooksecurefunc('MainMenuBarVehicleLeaveButton_Update', function()
			MainMenuBarVehicleLeaveButton:ClearAllPoints()
			MainMenuBarVehicleLeaveButton:SetPoint('BOTTOM', Bar.Eye, 'TOP', 0, 0)
		end)
	end

	if MainMenuBar and MainMenuBar.ActionBarPageNumber then
		MainMenuBar.ActionBarPageNumber:ClearAllPoints()
		MainMenuBar.ActionBarPageNumber:SetPoint('CENTER', Bar, 'CENTER', 0, 16)
	end

	-- Replace spell push animations. 
	if IconIntroTracker then
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
end