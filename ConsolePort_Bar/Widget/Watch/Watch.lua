local _, env, db = ...; db = env.db;
---------------------------------------------------------------
CPStatusTrackingBarMixin = {};
---------------------------------------------------------------

function CPStatusTrackingBarMixin:GetPriority()
	return self.priority;
end

function CPStatusTrackingBarMixin:Update()
    --Override this in your bar.lua function
	error('Implement an update function on your bar')
end

function CPStatusTrackingBarMixin:UpdateTick()
    --Override this to update the bar tick (if the bar has one)
    --Called when the bar is resized (RightBottomBar enabled/disabled)
end

function CPStatusTrackingBarMixin:UpdateAll()
	self:Update()
	self:UpdateTick()
	self:UpdateTextVisibility()
end

function CPStatusTrackingBarMixin:SetBarText(barText)
	self.OverlayFrame.Text:SetText(barText)
end

function CPStatusTrackingBarMixin:ShowText()
	self:SetTextLocked(true)
end

function CPStatusTrackingBarMixin:HideText()
	self:SetTextLocked(false)
end

function CPStatusTrackingBarMixin:SetBarValues(currentValue, minBar, maxBar, level)
	self.StatusBar:SetAnimatedValues(currentValue, minBar, maxBar, level)
end

function CPStatusTrackingBarMixin:SetBarColor(r, g, b)
	self.StatusBar:SetStatusBarColor(r, g, b)
	self.StatusBar:SetAnimatedTextureColors(r, g, b)
end

function CPStatusTrackingBarMixin:ShouldBarTextBeDisplayed()
	return GetCVarBool('xpBarText') or self.textLocked or self:GetParent():IsTextLocked()
end

function CPStatusTrackingBarMixin:SetTextLocked(locked)
	if ( self.textLocked ~= locked ) then
		self.textLocked = locked;
		self:UpdateTextVisibility()
	end
end

function CPStatusTrackingBarMixin:UpdateTextVisibility()
	self.OverlayFrame.Text:SetShown(self:ShouldBarTextBeDisplayed())
end

---------------------------------------------------------------
CPExpBarMixin = CreateFromMixins(CPStatusTrackingBarMixin)
---------------------------------------------------------------
local XP_STATUS_BAR_TEXT = 'XP: %d/%d';

CPExpBarMixin.Events = {
	'PLAYER_ENTERING_WORLD';
	'PLAYER_XP_UPDATE';
	'CVAR_UPDATE';
};

function CPExpBarMixin:GetPriority()
	return self.priority
end

function CPExpBarMixin:ShouldBeVisible()
	return not IsPlayerAtEffectiveMaxLevel() and not CPAPI.IsXPUserDisabled()
end

function CPExpBarMixin:Update()
	local currXP = UnitXP('player')
	local nextXP = UnitXPMax('player')
	local level = UnitLevel('player')

	local minBar, maxBar = 0, nextXP;

	local isCapped = false
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData()
		if UnitLevel('player') >= rLevel then
			isCapped = true
			self:SetBarValues(1, 0, 1, level)
			self.StatusBar:ProcessChangesInstantly()
			self:SetBarColor(0.58, 0.0, 0.55, 1.0)
		end
	end
	if (not isCapped) then
		self:SetBarValues(currXP, minBar, maxBar, level)
	end

	self.currXP = currXP;
	self.maxBar = maxBar;

	self:UpdateCurrentText()
end

function CPExpBarMixin:UpdateCurrentText()
	local currXP = self.currXP;
	local maxBar = self.maxBar;
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData()
		if (UnitLevel('player') >= rLevel) then
			currXP = UnitTrialXP('player')
		end
	end
	self:SetBarText(XP_STATUS_BAR_TEXT:format(currXP, maxBar))
end

function CPExpBarMixin:OnLoad()
	TextStatusBar_Initialize(self)
	self:Update()
	CPAPI.RegisterFrameForEvents(self, self.Events)
	self.priority = 3;
end

function CPExpBarMixin:OnEvent(event, ...)
	if( event == 'CVAR_UPDATE') then
		local cvar = ...
		if( cvar == 'XP_BAR_TEXT' ) then
			self:UpdateTextVisibility()
		end
	elseif ( event == 'PLAYER_XP_UPDATE' or event == 'PLAYER_ENTERING_WORLD' ) then
		self:Update()
	end
end

function CPExpBarMixin:OnShow()
	self:UpdateTextVisibility()
end

function CPExpBarMixin:OnEnter()
	TextStatusBar_UpdateTextString(self)
	self:ShowText(self)
	self:UpdateCurrentText()
	self.ExhaustionTick.timer = 1;
	local label = XPBAR_LABEL

	if ( GameLimitedMode_IsActive() ) then
		local rLevel = GetRestrictedAccountData()
		if UnitLevel('player') >= rLevel then
			local trialXP = UnitTrialXP('player')
			local bankedLevels = UnitTrialBankedLevels('player')
			if (trialXP > 0) then
				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				local text = TRIAL_CAP_BANKED_XP_TOOLTIP
				if (bankedLevels > 0) then
					text = TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(bankedLevels)
				end
				GameTooltip:SetText(text, nil, nil, nil, nil, true)
				GameTooltip:Show()
				if (IsTrialAccount()) then
					MicroButtonPulse(StoreMicroButton)
				end
				return
			else
				label = label..' '..RED_FONT_COLOR_CODE..CAP_REACHED_TRIAL..'|r';
			end
		end
	end

	GameTooltip.canAddRestStateLine = 1
	self.ExhaustionTick:ExhaustionToolTipText()
end

function CPExpBarMixin:OnLeave()
	self:HideText()
	GameTooltip:Hide()
	self.ExhaustionTick.timer = nil
end

function CPExpBarMixin:OnUpdate(elapsed)
	self.ExhaustionTick:OnUpdate(elapsed)
end

function CPExpBarMixin:OnValueChanged()
	if ( not self:IsShown() ) then
		return
	end
	self:Update()
end

function CPExpBarMixin:UpdateTick()
	self.ExhaustionTick:UpdateTickPosition()
	self.ExhaustionTick:UpdateExhaustionColor()
end

---------------------------------------------------------------
CPExhaustionTickMixin = {};
---------------------------------------------------------------
CPExhaustionTickMixin.Events = {
	'PLAYER_ENTERING_WORLD';
	'PLAYER_LEVEL_UP';
	'PLAYER_UPDATE_RESTING';
	'PLAYER_XP_UPDATE';
	'UPDATE_EXHAUSTION';
};

function CPExhaustionTickMixin:ExhaustionToolTipText()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)

	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
	local exhaustionCurrXP, exhaustionMaxXP
	local exhaustionThreshold = GetXPExhaustion()
	local exhaustionCountdown = nil

	exhaustionStateMultiplier = exhaustionStateMultiplier * 100

	if ( GetTimeToWellRested() ) then
		exhaustionCountdown = GetTimeToWellRested() / 60
	end

	local currXP = UnitXP('player')
	local nextXP = UnitXPMax('player')
	local percentXP = math.ceil(currXP/nextXP*100)
	local XPText = format( XP_TEXT, BreakUpLargeNumbers(currXP), BreakUpLargeNumbers(nextXP), percentXP )
	local tooltipText = XPText..format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier)
	local append = nil

	if ( IsResting() ) then
		if ( exhaustionThreshold and exhaustionCountdown ) then
			append = format(EXHAUST_TOOLTIP4, exhaustionCountdown)
		end
	elseif ( (exhaustionStateID == 4) or (exhaustionStateID == 5) ) then
		append = EXHAUST_TOOLTIP2
	end

	if ( append ) then
		tooltipText = tooltipText..append
	end

	if ( SHOW_NEWBIE_TIPS ~= '1' ) then
		GameTooltip:SetText(tooltipText)
	else
		if ( GameTooltip.canAddRestStateLine ) then
			GameTooltip:AddLine('\n'..tooltipText)
			GameTooltip:Show()
			GameTooltip.canAddRestStateLine = nil
		end
	end
end

function CPExhaustionTickMixin:OnLoad()
	CPAPI.RegisterFrameForEvents(self, self.Events)
end

function CPExhaustionTickMixin:UpdateTickPosition()
	local playerCurrXP = UnitXP('player')
	local playerMaxXP = UnitXPMax('player')
	local exhaustionThreshold = GetXPExhaustion()
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
	local parent = self:GetParent()

	if ( exhaustionStateID and exhaustionStateID >= 3 ) then
		self:SetPoint('CENTER', parent , 'RIGHT', 0, 0)
	end

	if ( not exhaustionThreshold ) then
		self:Hide()
		parent.ExhaustionLevelFillBar:Hide()
	else
		local exhaustionFillFraction = max(((playerCurrXP + exhaustionThreshold) / playerMaxXP), 0)
		local exhaustionTickSet = max(exhaustionFillFraction * parent:GetWidth(), 0)
		self:ClearAllPoints()

		if ( exhaustionTickSet > parent:GetWidth() ) then
			self:Hide()
		else
			self:Show()
			self:SetPoint('CENTER', parent, 'LEFT', exhaustionTickSet, 0)
		end

		exhaustionFillFraction = Clamp(exhaustionFillFraction, 0, 1)

		parent.ExhaustionLevelFillBar:Show()
		parent.ExhaustionLevelFillBar:SetTexture(parent.StatusBar:GetStatusBarTexture():GetTexture())
		parent.ExhaustionLevelFillBar:SetTexCoord(0, exhaustionFillFraction, 0, 1)

		if (exhaustionFillFraction == 1) then
			parent.ExhaustionLevelFillBar:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 0, 0)
		else
			parent.ExhaustionLevelFillBar:SetPoint('TOPRIGHT', parent, 'TOPLEFT', exhaustionTickSet, 0)
		end
	end

	-- Hide exhaustion tick if player is max level or XP is turned off
	if ( IsPlayerAtEffectiveMaxLevel() or CPAPI.IsXPUserDisabled() ) then
		self:Hide()
	end
end

function CPExhaustionTickMixin:UpdateExhaustionColor()
	local exhaustionStateID = GetRestState()
	local parent = self:GetParent()
	if ( exhaustionStateID == 1 ) then
		parent.ExhaustionLevelFillBar:SetVertexColor(0.0, 0.39, 0.88, 0.5)
		self.Highlight:SetVertexColor(0.0, 0.39, 0.88)
	elseif ( exhaustionStateID == 2 ) then
		parent.ExhaustionLevelFillBar:SetVertexColor(0.58, 0.0, 0.55, 0.25)
		self.Highlight:SetVertexColor(0.58, 0.0, 0.55)
	end
	parent:SetBarColor(env:GetColorRGB('xpBarColor'))
end

function CPExhaustionTickMixin:OnUpdate(elapsed)
	if ( self.timer ) then
		if ( self.timer < 0 ) then
			self:ExhaustionToolTipText()
			self.timer = nil
		else
			self.timer = self.timer - elapsed
		end
	end
end

CPExhaustionTickMixin.PLAYER_XP_UPDATE      = CPExhaustionTickMixin.UpdateTickPosition;
CPExhaustionTickMixin.UPDATE_EXHAUSTION     = CPExhaustionTickMixin.UpdateTickPosition;
CPExhaustionTickMixin.PLAYER_LEVEL_UP       = CPExhaustionTickMixin.UpdateTickPosition;
CPExhaustionTickMixin.UPDATE_EXHAUSTION     = CPExhaustionTickMixin.UpdateExhaustionColor;

function CPExhaustionTickMixin:PLAYER_ENTERING_WORLD()
	self:UpdateTickPosition()
	self:UpdateExhaustionColor()
end

function CPExhaustionTickMixin:OnEvent(event, ...)
	if (IsRestrictedAccount()) then
		local rlevel = GetRestrictedAccountData()
		if (UnitLevel('player') >= rlevel) then
			self:GetParent():SetBarColor(env:GetColorRGB('xpBarColor'))
			self:Hide()
			self:GetParent().ExhaustionLevelFillBar:Hide()
			self:UnregisterAllEvents()
			return;
		end
	end
	if self[event] then
		self[event](self, event, ...)
	end
	if ( not self:IsShown() ) then
		self:Hide()
	end
end

---------------------------------------------------------------
CPReputationBarMixin = CreateFromMixins(CPStatusTrackingBarMixin)
---------------------------------------------------------------

function CPReputationBarMixin:GetPriority()
	return self.priority
end

function CPReputationBarMixin:UpdateCurrentText()
	if ( self.isCapped ) then
		self:SetBarText(self.name)
	else
		self:SetBarText(self.name:format(self.value, self.max))
	end
end

function CPReputationBarMixin:ShouldBeVisible()
	local name = GetWatchedFactionInfo()
	return name ~= nil;
end

function CPReputationBarMixin:GetMaxLevel()
	local _, _, _, _, _, factionID = GetWatchedFactionInfo()
	if not factionID or factionID == 0 then
		return nil;
	end

	if CPAPI.IsFactionParagon(factionID) then
		return nil;
	end

	if CPAPI.IsMajorFaction(factionID) then
		local renownLevelsInfo = CPAPI.GetRenownLevels(factionID)
		return renownLevelsInfo[#renownLevelsInfo].level;
	end

	local reputationInfo = CPAPI.GetFriendshipReputation(factionID)
	local friendshipID = reputationInfo.friendshipFactionID;
	if friendshipID and friendshipID > 0 then
		local repRankInfo = CPAPI.GetFriendshipReputationRanks(factionID)
		return repRankInfo.maxLevel;
	end

	return MAX_REPUTATION_REACTION;
end

function CPReputationBarMixin:Update()
	local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo();
	if not factionID or factionID == 0 then
		return;
	end

	local colorIndex = reaction;
	local overrideUseBlueBar = false;

	local isShowingNewFaction = self.factionID ~= factionID;
	if isShowingNewFaction then
		local reputationInfo = CPAPI.GetFriendshipReputation(factionID)
		self.factionID = factionID;
		self.friendshipID = reputationInfo.friendshipFactionID;
	end

	-- do something different for friendships
	local level;
	local maxLevel = self:GetMaxLevel()

	if CPAPI.IsFactionParagon(factionID) then
		local currentValue, threshold, _, hasRewardPending = CPAPI.GetFactionParagonInfo(factionID);
		minBar, maxBar  = 0, threshold;
		value = currentValue % threshold;
		level = maxLevel;
		if hasRewardPending then
			value = value + threshold;
		end
		if CPAPI.IsMajorFaction(factionID) then
			overrideUseBlueBar = true;
		end
	elseif CPAPI.IsMajorFaction(factionID) then
		local majorFactionData = CPAPI.GetMajorFactionData(factionID);
		minBar, maxBar = 0, majorFactionData.renownLevelThreshold;
		level = majorFactionData.renownLevel;
		overrideUseBlueBar = true;
	elseif self.friendshipID and self.friendshipID > 0 then
		local repInfo = CPAPI.GetFriendshipReputation(factionID)
		local repRankInfo = CPAPI.GetFriendshipReputationRanks(factionID)
		level = repRankInfo.currentLevel;
		if repInfo.nextThreshold then
			minBar, maxBar, value = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
		else
			-- max rank, make it look like a full bar
			minBar, maxBar, value = 0, 1, 1;
		end
		colorIndex = 5; -- Friendships always use same
	else
		level = reaction;
	end

	local isCapped = (level and maxLevel) and level >= maxLevel;

	-- Normalize values
	maxBar = maxBar - minBar;
	value = value - minBar;
	if isCapped and maxBar == 0 then
		maxBar = 1;
		value = 1;
	end
	minBar = 0;

	self:SetBarValues(value, minBar, maxBar, level, maxLevel)

	if isCapped then
		self:SetBarText(name);
	else
		name = name..' %d / %d';
		self:SetBarText(name:format(value, maxBar))
	end

	local color = overrideUseBlueBar and BLUE_FONT_COLOR or FACTION_BAR_COLORS[colorIndex];
	self:SetBarColor(color.r, color.g, color.b, 1)

	self.name = name;
	self.value = value;
	self.max = maxBar;

	-- When showing new faction, force status bar to update instantly
	if isShowingNewFaction then
		self.StatusBar:ProcessChangesInstantly()
	end
end

function CPReputationBarMixin:OnLoad()
	self:RegisterEvent('CVAR_UPDATE')
	self.priority = 1
end

function CPReputationBarMixin:OnEvent(event, ...)
	if( event == 'CVAR_UPDATE') then
		local cvar = ...
		if( cvar == 'XP_BAR_TEXT' ) then
			self:UpdateTextVisibility()
		end
	end
end

function CPReputationBarMixin:OnEnter()
	self:ShowText()
	self:UpdateCurrentText()
	if ReputationParagonWatchBar_OnEnter then
		ReputationParagonWatchBar_OnEnter(self)
	end
end

function CPReputationBarMixin:OnShow()
	self:UpdateTextVisibility()
end

function CPReputationBarMixin:OnLeave()
	self:HideText()
	if ReputationParagonWatchBar_OnLeave then
		ReputationParagonWatchBar_OnLeave(self)
	end
end

---------------------------------------------------------------
CPWatchBarContainerMixin = {};
---------------------------------------------------------------
local XP_BAR_TEXTURE_NORMAL   = env.GetAsset([[Textures\XPBar]])
local XP_BAR_TEXTURE_INVERTED = env.GetAsset([[Textures\XPBar_Inverted]])
local MAX_BARS_VISIBLE = 2;

CPWatchBarContainerMixin.Events = {
	'UPDATE_FACTION';
	'ENABLE_XP_GAIN';
	'DISABLE_XP_GAIN';
	'CVAR_UPDATE';
	'UPDATE_EXPANSION_LEVEL';
	'PLAYER_ENTERING_WORLD';
	'HONOR_XP_UPDATE';
	'ZONE_CHANGED';
	'ZONE_CHANGED_NEW_AREA';
	'UNIT_INVENTORY_CHANGED';
	'ARTIFACT_XP_UPDATE';
};

function CPWatchBarContainerMixin:OnLoad()
	self.bars = {};

	CPAPI.RegisterFrameForEvents(self, self.Events)
	self:RegisterUnitEvent('UNIT_LEVEL', 'player')

	self:SetInitialBarSize()
	self:UpdateBarsShown()
	self:Init()
end

function CPWatchBarContainerMixin:OnEvent(event)
	if ( event == 'CVAR_UPDATE' ) then
		self:UpdateBarVisibility()
	end
	self:UpdateBarsShown()
end

function CPWatchBarContainerMixin:OnShow()
	db.Alpha.Fader.Toggle(self, 0.2, not env('fadeXPBar'), true)
end

function CPWatchBarContainerMixin:Enumerate()
	return ipairs(self.bars)
end

function CPWatchBarContainerMixin:SetTextLocked(isLocked)
	if ( self.textLocked ~= isLocked ) then
		self.textLocked = isLocked
		self:UpdateBarVisibility()
	end
end

function CPWatchBarContainerMixin:GetNumberVisibleBars()
	local numVisBars = 0;
	for _, bar in self:Enumerate() do
		if bar:ShouldBeVisible() then
			numVisBars = numVisBars + 1;
		end
	end
	return math.min(MAX_BARS_VISIBLE, numVisBars)
end

function CPWatchBarContainerMixin:IsTextLocked()
	return self.textLocked;
end

function CPWatchBarContainerMixin:UpdateBarVisibility()
	for _, bar in self:Enumerate() do
		if bar:ShouldBeVisible() then
			bar:UpdateTextVisibility()
		end
	end
end

function CPWatchBarContainerMixin:SetBarAnimation(Animation)
	for _, bar in self:Enumerate() do
		bar.StatusBar:SetDeferAnimationCallback(Animation)
	end
end

function CPWatchBarContainerMixin:UpdateBarTicks()
	for _, bar in self:Enumerate() do
		if bar:ShouldBeVisible() then
			bar:UpdateTick()
		end
	end
end

function CPWatchBarContainerMixin:ShowVisibleBarText()
	for _, bar in self:Enumerate() do
		if bar:ShouldBeVisible() then
			bar:ShowText()
		end
	end
end

function CPWatchBarContainerMixin:HideVisibleBarText()
	for _, bar in self:Enumerate() do
		if bar:ShouldBeVisible() then
			bar:HideText()
		end
	end
end

function CPWatchBarContainerMixin:SetBarSize(largeSize)
	self.largeSize = largeSize;
	self:UpdateBarsShown()
end

function CPWatchBarContainerMixin:UpdateBarsShown()
	local visibleBars = {};
	for _, bar in self:Enumerate() do
		if bar:ShouldBeVisible() then
			table.insert(visibleBars, bar)
		end
	end

	table.sort(visibleBars, function(left, right) return left:GetPriority() < right:GetPriority() end)
	self:LayoutBars(visibleBars)
end

function CPWatchBarContainerMixin:HideStatusBars()
	self.SingleBarSmall:Hide()
	self.SingleBarLarge:Hide()
	self.SingleBarSmallUpper:Hide()
	self.SingleBarLargeUpper:Hide()
	for _, bar in self:Enumerate() do
		bar:Hide()
	end
end

function CPWatchBarContainerMixin:SetInitialBarSize()
	self.barHeight = self.SingleBarLarge:GetHeight()
end

function CPWatchBarContainerMixin:GetInitialBarHeight()
	return self.barHeight;
end

-- Sets the bar size depending on whether the bottom right multi-bar is shown.
-- If the multi-bar is shown, a different texture needs to be displayed that is smaller.
function CPWatchBarContainerMixin:SetDoubleBarSize(bar, width)
	local textureHeight = self:GetInitialBarHeight()
	local statusBarHeight = textureHeight - 0;
	if( self.largeSize ) then
		self.SingleBarLargeUpper:SetSize(width, statusBarHeight)
		self.SingleBarLargeUpper:SetPoint('CENTER', bar, 0, 4)
		self.SingleBarLargeUpper:Show()

		self.SingleBarLarge:SetSize(width, statusBarHeight)
		self.SingleBarLarge:SetPoint('CENTER', bar, 0, -9)
		self.SingleBarLarge:Show()
	else
		self.SingleBarSmallUpper:SetSize(width, statusBarHeight)
		self.SingleBarSmallUpper:SetPoint('CENTER', bar, 0, 4)
		self.SingleBarSmallUpper:Show()

		self.SingleBarSmall:SetSize(width, statusBarHeight)
		self.SingleBarSmall:SetPoint('CENTER', bar, 0, -9)
		self.SingleBarSmall:Show()
	end

	local progressWidth = width - self:GetEndCapWidth() * 2;
	bar.StatusBar:SetSize(progressWidth, statusBarHeight)
	bar:SetSize(progressWidth, statusBarHeight)
end

--Same functionality as previous function except shows only one bar.
function CPWatchBarContainerMixin:SetSingleBarSize(bar, width)
	local textureHeight = self:GetInitialBarHeight()
	if( self.largeSize ) then
		self.SingleBarLarge:SetSize(width, textureHeight)
		self.SingleBarLarge:SetPoint('CENTER', bar, 0, 0)
		self.SingleBarLarge:Show()
	else
		self.SingleBarSmall:SetSize(width, textureHeight)
		self.SingleBarSmall:SetPoint('CENTER', bar, 0, 0)
		self.SingleBarSmall:Show()
	end
	local progressWidth = width - self:GetEndCapWidth() * 2;
	bar.StatusBar:SetSize(progressWidth, textureHeight)
	bar:SetSize(progressWidth, textureHeight)
end

function CPWatchBarContainerMixin:LayoutBar(bar, barWidth, isTopBar, isDouble)
	bar:Update()
	bar:Show()
	bar:ClearAllPoints()

	if ( isDouble ) then
		if ( isTopBar ) then
			bar:SetPoint('BOTTOM', self:GetParent(), 0, 18)
			bar.StatusBar.BarTexture:SetTexture(XP_BAR_TEXTURE_INVERTED)
		else
			bar:SetPoint('BOTTOM', self:GetParent(), 0, 0)
			bar.StatusBar.BarTexture:SetTexture(XP_BAR_TEXTURE_NORMAL)
		end
		self:SetDoubleBarSize(bar, barWidth)
	else
		bar:SetPoint('BOTTOM', self:GetParent(), 0, 0)
		bar.StatusBar.BarTexture:SetTexture(XP_BAR_TEXTURE_NORMAL)
		self:SetSingleBarSize(bar, barWidth)
	end
end

function CPWatchBarContainerMixin:SetMainBarColor(r, g, b)
	if self.mainBar then
		self.mainBar:SetBarColorRaw(r, g, b)
	end
end

function CPWatchBarContainerMixin:LayoutBars(visBars)
	local width = self:GetWidth()
	self:HideStatusBars()

	local TOP_BAR, IS_DOUBLE = true, true;
	if ( #visBars > 1 ) then
		self:LayoutBar(visBars[1], width, not TOP_BAR, IS_DOUBLE)
		self:LayoutBar(visBars[2], width, TOP_BAR, IS_DOUBLE)
	elseif( #visBars == 1 ) then
		self:LayoutBar(visBars[1], width, TOP_BAR, not IS_DOUBLE)
	end
	self.mainBar = visBars and visBars[1];
	self:UpdateBarTicks()
end

function CPWatchBarContainerMixin:GetEndCapWidth()
	return self.endCapWidth;
end

function CPWatchBarContainerMixin:SetEndCapWidth(width)
	self.endCapWidth = width;
end

do -- Bar setup
	local function BarColorOverride(self)
		if ( self:GetParent().mainBar == self ) then
			self:SetBarColorRaw(env:GetColorRGB('xpBarColor'))
		end
	end

	local function BarColorRaw(self, r, g, b, a)
		self.StatusBar.BarTexture:SetVertexColor(r, g, b, a)
	end

	function CPWatchBarContainerMixin:AddBarFromTemplate(template, showPredicate, getPriority)
		local bar = CreateFrame('Frame', nil, self, template)
		local statusBar = bar.StatusBar;
		table.insert(self.bars, bar)

		statusBar.Background:Hide()
		statusBar.BarTexture:SetTexture(XP_BAR_TEXTURE_NORMAL)
		statusBar.BarTexture:SetSnapToPixelGrid(true)
		statusBar.BarTexture:SetTexelSnappingBias(0)

		bar.SetBarColorRaw  = bar.SetBarColor or BarColorRaw;
		bar.ShouldBeVisible = bar.ShouldBeVisible or showPredicate or nop;
		bar.GetPriority     = bar.GetPriority or getPriority;

		bar:HookScript('OnEnter', function()
			db.Alpha.FadeIn(self, 0.2, self:GetAlpha(), 1)
		end)

		bar:HookScript('OnLeave', function()
			if env('fadeXPBar') then
				db.Alpha.FadeOut(self, 0.2, self:GetAlpha(), 0)
			end
		end)

		bar:HookScript('OnShow', BarColorOverride)
		if bar.SetBarColor then
			hooksecurefunc(bar, 'SetBarColor', BarColorOverride)
		end

		self:UpdateBarsShown()
		return bar;
	end
end

do -- Initialize bars
	if CPAPI.IsRetailVersion then
		-- See FrameXML\StatusTrackingManager.lua
		local BarsEnum = {
			None       = -1;
			Reputation =  1;
			Honor      =  2;
			Artifact   =  3;
			Experience =  4;
			Azerite    =  5;
		};
		local BarPriorities = {
			[BarsEnum.Azerite]    = 0;
			[BarsEnum.Reputation] = 1;
			[BarsEnum.Honor]      = 2;
			[BarsEnum.Artifact]   = 3;
			[BarsEnum.Experience] = 4;
		};

		function CPWatchBarContainerMixin:Init()
			local CanShowBar, GetBarPriority = StatusTrackingManagerMixin.CanShowBar, StatusTrackingManagerMixin.GetBarPriority;
			local __ = function(f, ...) return GenerateClosure(f, WBC, ...) end;

			self:AddBarFromTemplate('CP_ReputationStatusBarTemplate', __(CanShowBar, BarsEnum.Reputation), __(GetBarPriority, BarPriorities[BarsEnum.Reputation]) )
			self:AddBarFromTemplate('HonorStatusBarTemplate',         __(CanShowBar, BarsEnum.Honor),      __(GetBarPriority, BarPriorities[BarsEnum.Honor])      )
			self:AddBarFromTemplate('ArtifactStatusBarTemplate',      __(CanShowBar, BarsEnum.Artifact),   __(GetBarPriority, BarPriorities[BarsEnum.Artifact])   )
			self:AddBarFromTemplate('AzeriteBarTemplate',             __(CanShowBar, BarsEnum.Azerite),    __(GetBarPriority, BarPriorities[BarsEnum.Azerite])    )
			self:AddBarFromTemplate('CP_ExpStatusBarTemplate',        __(CanShowBar, BarsEnum.Experience), __(GetBarPriority, BarPriorities[BarsEnum.Experience]) )
		end
	else
		function CPWatchBarContainerMixin:Init()
			self:AddBarFromTemplate('CP_ReputationStatusBarTemplate')
			self:AddBarFromTemplate('CP_ExpStatusBarTemplate')
		end
	end
end