-- This was mostly stolen from Bartender4.
-- This code snippet hides and modifies the default action bars.

local addOn, ab = ...
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
		MultiBarLeft,
		MultiBarRight,
		MultiBarBottomLeft,
		MultiBarBottomRight }) do
		bar:SetParent(UIHider)
	end

	MainMenuBarArtFrame:Hide()

	-- Hide MultiBar Buttons, but keep the bars alive
	for _, n in pairs({
		'ActionButton',	
		'MultiBarLeftButton',
		'MultiBarRightButton',
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

	local animations = {MainMenuBar.slideOut:GetAnimations()}
	animations[1]:SetOffset(0,0)

	-------------------------------------------
	---		Watch bars
	-------------------------------------------

	local XP, Rep, Honor, Artifact = MainMenuExpBar, ReputationWatchBar, HonorWatchBar, ArtifactWatchBar

	Bar.WatchBarContainer = CreateFrame('Frame', '$parentWatchBars', Bar)
	Bar.WatchBarContainer:SetPoint('BOTTOM', 0, 0)
	Bar.WatchBarContainer:SetSize(1024, 16)
	Bar.WatchBarContainer.BGLeft = Bar.WatchBarContainer:CreateTexture('BACKGROUND')
	Bar.WatchBarContainer.BGRight = Bar.WatchBarContainer:CreateTexture('BACKGROUND')

	Bar.WatchBarContainer.BGLeft:SetPoint('TOPLEFT')
	Bar.WatchBarContainer.BGLeft:SetPoint('BOTTOMRIGHT', Bar.WatchBarContainer, 'BOTTOM', 0, 0)
	Bar.WatchBarContainer.BGLeft:SetColorTexture(0, 0, 0, 1)
	Bar.WatchBarContainer.BGLeft:SetGradientAlpha('HORIZONTAL', 0, 0, 0, 0, 0, 0, 0, 1)

	Bar.WatchBarContainer.BGRight:SetColorTexture(0, 0, 0, 1)
	Bar.WatchBarContainer.BGRight:SetPoint('TOPRIGHT')
	Bar.WatchBarContainer.BGRight:SetPoint('BOTTOMLEFT', Bar.WatchBarContainer, 'BOTTOM', 0, 0)
	Bar.WatchBarContainer.BGRight:SetGradientAlpha('HORIZONTAL', 0, 0, 0, 1, 0, 0, 0, 0)

	Bar.WatchBarContainer:HookScript('OnShow', function(self)
		if ab.cfg and ab.cfg.watchbars then
			FadeIn(self, 0.2, self:GetAlpha(), 1)
		else
			self:SetAlpha(0)
		end
	end)
	Bar.WatchBarContainer.Update = function(self)
		local visible = {}
		for _, bar in pairs(self.WatchBars) do
			if bar:IsVisible() then
				visible[#visible + 1] = bar
			end
		end
		for i, bar in pairs(visible) do
			local statusBar = bar.StatusBar or bar
			bar.forcedUpdate = true
			statusBar.forcedUpdate = true
			bar:SetSize(self:GetWidth() / #visible, self:GetHeight())
			bar:ClearAllPoints()
			bar:SetPoint('LEFT', visible[i-1] or self, visible[i-1] and 'RIGHT' or 'LEFT', 0, 0)
			if bar.StatusBar then
				statusBar:SetAllPoints()
				bar.OverlayFrame.Text:SetPoint('CENTER', bar.OverlayFrame, 'CENTER', 0, 1)
			end
			if #visible == 1 then
				if ab.cfg and ab.cfg.expRGB then
					statusBar:SetStatusBarColor(unpack(ab.cfg.expRGB))
				else
					statusBar:SetStatusBarColor(red, green, blue)
				end
			else
				statusBar:SetStatusBarColor(bar.red, bar.green, bar.blue, bar.alpha)
			end
			bar.forcedUpdate = nil
			statusBar.forcedUpdate = nil
		end
	end

	local function UpdateWatchBar(self)
		if not self.forcedUpdate then
			Bar.WatchBarContainer:Update()
		end
	end

	Bar.Elements.WatchBars = {XP, Rep, Honor, Artifact}
	Bar.WatchBarContainer.WatchBars = Bar.Elements.WatchBars
	for _, bar in pairs(Bar.Elements.WatchBars) do
		local r, g, b, a
		bar:SetParent(Bar.WatchBarContainer)
		bar:SetFrameStrata('HIGH')
		bar.Container = Bar.WatchBarContainer
		bar:HookScript('OnShow', function(self)
			self.Container:Update()
		end)
		bar:HookScript('OnHide', function(self)
			self.forcedUpdate = nil
			self.Container:Update()
		end)	
		bar:HookScript('OnEnter', function(self) 
			FadeIn(self.Container, 0.2, self.Container:GetAlpha(), 1)
		end)
		bar:HookScript('OnLeave', function(self)
			if (ab.cfg and not ab.cfg.watchbars) or not ab.cfg then
				FadeOut(self.Container, 0.2, self.Container:GetAlpha(), 0)
			end
		end)
		hooksecurefunc(bar, 'SetPoint', UpdateWatchBar)
		hooksecurefunc(bar, 'SetSize', UpdateWatchBar)
		hooksecurefunc(bar, 'SetWidth', UpdateWatchBar)
		hooksecurefunc(bar, 'SetHeight', UpdateWatchBar)

		for _, region in pairs({bar:GetRegions()}) do
			if region:IsObjectType('Texture') then
				region:ClearAllPoints()
				region:Hide()
			end
		end

		if bar.StatusBar then
			r, g, b, a = bar.StatusBar:GetStatusBarColor()
			for i=0, 3 do
				bar.StatusBar['WatchBarTexture'..i]:Hide()
				bar.StatusBar['WatchBarTexture'..i]:ClearAllPoints()
				bar.StatusBar['XPBarTexture'..i]:Hide()
				bar.StatusBar['XPBarTexture'..i]:ClearAllPoints()
			end
			bar.StatusBar.Background:Hide()
			bar.StatusBar.Background:ClearAllPoints()
			hooksecurefunc(bar.StatusBar, 'SetStatusBarColor', UpdateWatchBar)
		else
			r, g, b, a = bar:GetStatusBarColor()
			hooksecurefunc(bar, 'SetStatusBarColor', UpdateWatchBar)
		end
		bar.red = r
		bar.green = g
		bar.blue = b
		bar.alpha = a
	end

	Bar.WatchBarContainer:Update()

	-------------------------------------------
	---		XP / rep bars
	-------------------------------------------

	MainMenuBarPerformanceBar:SetParent(UIHider)
	MainMenuBarPerformanceBar:ClearAllPoints()

	for i=1, 19 do
		_G['MainMenuXPBarDiv'..i]:SetAlpha(0.5)
	end

	MainMenuBarMaxLevelBar:Hide()
	MainMenuBarMaxLevelBar:SetParent(UIHider)

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
	--- 	Misc changes
	-------------------------------------------

	ObjectiveTrackerFrame:SetPoint('TOPRIGHT', MinimapCluster, 'BOTTOMRIGHT', -100, -132)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	else
		hooksecurefunc('TalentFrame_LoadUI', function() PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED') end)
	end

	-- Keep casting bar from obscuring action bar.
	CastingBarFrame:ClearAllPoints()
	hooksecurefunc(CastingBarFrame, 'SetPoint', function(self, anchor, relative, relRegion)
		if anchor ~= 'BOTTOM' or relative ~= Bar or relRegion ~= 'TOP' then
			self:SetPoint('BOTTOM', Bar, 'TOP', 0, 50)
		end
	end)

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

-- This is a workaround for the problem with the current internal implementation of texture masking.
-- At random times, a masked texture entity that updates to a new texture in combat will trigger the 'script ran too long' error,
-- which pops up and covers the screen for no good reason except to interrupt the game. While this particular error might warrant
-- some cause for concern in certain cases, this handler will omit all such errors until texture masking is fixed internally by Blizzard.
if geterrorhandler() == _ERRORMESSAGE then
	-- Replace the lua error handler if it isn't already custom
	local function errorGrabber(message)
		debuginfo() -- Debugging information for internal use.

		-- Omit the error and return without action
		if message:match('script ran too long') then return end
		
		-- ..otherwise proceed as normal 
		LoadAddOn('Blizzard_DebugTools')
		local loaded = IsAddOnLoaded('Blizzard_DebugTools')
		
		if ( GetCVarBool('scriptErrors') ) then
			if ( not loaded or DEBUG_DEBUGTOOLS ) then
				BasicScriptErrorsText:SetText(message)
				BasicScriptErrors:Show()
				if ( DEBUG_DEBUGTOOLS ) then
					ScriptErrorsFrame_OnError(message)
				end
			else
				ScriptErrorsFrame_OnError(message)
			end
		elseif ( loaded ) then
			local HIDE_ERROR_FRAME = true
			ScriptErrorsFrame_OnError(message, false, HIDE_ERROR_FRAME)
		end
		
		-- Show a warning if there are too many errors
		_ERROR_COUNT = _ERROR_COUNT + 1
		if ( _ERROR_COUNT == _ERROR_LIMIT ) then
			StaticPopup_Show('TOO_MANY_LUA_ERRORS')
		end

		return message
	end
	seterrorhandler(errorGrabber)
end