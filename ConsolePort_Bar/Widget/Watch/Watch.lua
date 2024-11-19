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
	self.StatusBar:InitializeTextStatusBar()
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
	self.StatusBar:UpdateTextString()
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
	local exhaustionThreshold = GetXPExhaustion()
	local exhaustionCountdown = nil

	exhaustionStateMultiplier = exhaustionStateMultiplier * 100

	local timeToWellRested = GetTimeToWellRested and GetTimeToWellRested()
	if ( timeToWellRested ) then
		exhaustionCountdown = timeToWellRested / 60;
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
	local watchedFactionData = CPAPI.GetWatchedFactionData()
	return watchedFactionData and watchedFactionData.factionID ~= 0;
end

function CPReputationBarMixin:GetMaxLevel()
	local watchedFactionData = CPAPI.GetWatchedFactionData()
	if not watchedFactionData or watchedFactionData.factionID == 0 then
		return nil;
	end

	local factionID = watchedFactionData.factionID;
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
	local watchedFactionData = CPAPI.GetWatchedFactionData()
	if not watchedFactionData or watchedFactionData.factionID == 0 then
		return;
	end

	local colorIndex = watchedFactionData.reaction;
	local overrideUseBlueBar = false;

	local factionID = watchedFactionData.factionID;
	local isShowingNewFaction = self.factionID ~= factionID;
	if isShowingNewFaction then
		local reputationInfo = CPAPI.GetFriendshipReputation(factionID)
		self.factionID = factionID;
		self.friendshipID = reputationInfo.friendshipFactionID;
	end

	-- do something different for friendships
	local level;
	local maxLevel = self:GetMaxLevel()

	local minBar, maxBar, value = watchedFactionData.currentReactionThreshold, watchedFactionData.nextReactionThreshold, watchedFactionData.currentStanding;
	if CPAPI.IsFactionParagon(factionID) then
		local currentValue, threshold, _, hasRewardPending = CPAPI.GetFactionParagonInfo(factionID)
		minBar, maxBar = 0, threshold;
		value = currentValue % threshold;
		level = maxLevel;
		if hasRewardPending then
			value = value + threshold;
		end
		if CPAPI.IsMajorFaction(factionID) then
			overrideUseBlueBar = true;
		end
	elseif CPAPI.IsMajorFaction(factionID) then
		local majorFactionData = CPAPI.GetMajorFactionData(factionID)
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
		level = watchedFactionData.reaction;
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

	local name = watchedFactionData.name;
	local needsAccountWideLabel = CPAPI.IsAccountWideReputation(factionID)
	if needsAccountWideLabel then
		name = name .. " " .. REPUTATION_STATUS_BAR_LABEL_ACCOUNT_WIDE;
	end

	if isCapped then
		self:SetBarText(name)
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

	local normalTexture = self.inverted and XP_BAR_TEXTURE_INVERTED or XP_BAR_TEXTURE_NORMAL;
	local invertTexture = self.inverted and XP_BAR_TEXTURE_NORMAL or XP_BAR_TEXTURE_INVERTED;
	local anchor = self.inverted and 'TOP' or 'BOTTOM';
	local offset = self.inverted and -18 or 18;

	if ( isDouble ) then
		if ( isTopBar ) then
			bar:SetPoint(anchor, self:GetParent(), 0, offset)
			bar.StatusBar.BarTexture:SetTexture(invertTexture)
		else
			bar:SetPoint(anchor, self:GetParent(), 0, 0)
			bar.StatusBar.BarTexture:SetTexture(normalTexture)
		end
		self:SetDoubleBarSize(bar, barWidth)
	else
		bar:SetPoint(anchor, self:GetParent(), 0, 0)
		bar.StatusBar.BarTexture:SetTexture(normalTexture)
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

	local SECONDARY, IS_DOUBLE = true, true;
	if ( #visBars > 1 ) then
		self:LayoutBar(visBars[1], width, not SECONDARY, IS_DOUBLE)
		self:LayoutBar(visBars[2], width, SECONDARY, IS_DOUBLE)
	elseif( #visBars == 1 ) then
		self:LayoutBar(visBars[1], width, SECONDARY, not IS_DOUBLE)
	end
	self.mainBar = visBars and visBars[1];
	self:UpdateBarTicks()
end

function CPWatchBarContainerMixin:SetInversion(inverted)
	self.inverted = inverted;
	self:UpdateBarsShown()
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
			local __ = function(f, ...) return GenerateClosure(f, nil, ...) end;

			self:AddBarFromTemplate('CPReputationStatusBarTemplate', __(CanShowBar, BarsEnum.Reputation), __(GetBarPriority, BarPriorities[BarsEnum.Reputation]) )
			self:AddBarFromTemplate('HonorStatusBarTemplate',        __(CanShowBar, BarsEnum.Honor),      __(GetBarPriority, BarPriorities[BarsEnum.Honor])      )
			self:AddBarFromTemplate('ArtifactStatusBarTemplate',     __(CanShowBar, BarsEnum.Artifact),   __(GetBarPriority, BarPriorities[BarsEnum.Artifact])   )
			self:AddBarFromTemplate('AzeriteBarTemplate',            __(CanShowBar, BarsEnum.Azerite),    __(GetBarPriority, BarPriorities[BarsEnum.Azerite])    )
			self:AddBarFromTemplate('CPExpStatusBarTemplate',        __(CanShowBar, BarsEnum.Experience), __(GetBarPriority, BarPriorities[BarsEnum.Experience]) )
		end
	else
		function CPWatchBarContainerMixin:Init()
			self:AddBarFromTemplate('CPReputationStatusBarTemplate')
			self:AddBarFromTemplate('CPExpStatusBarTemplate')
		end
	end
end


---------------------------------------------------------------
CPTextStatusBarMixin = {};
---------------------------------------------------------------
if TextStatusBarMixin then
	Mixin(CPTextStatusBarMixin, TextStatusBarMixin)
	return; -- see TextStatusBar.lua
end

local STATUS_TEXT_DISPLAY_MODE = {
	NUMERIC = 'NUMERIC';
	PERCENT = 'PERCENT';
	BOTH    = 'BOTH';
	NONE    = 'NONE';
};

function CPTextStatusBarMixin:InitializeTextStatusBar()
	self:RegisterEvent('CVAR_UPDATE')
	self.lockShow = 0;

	local function OnStatusTextSettingChanged()
		self:UpdateTextString()
	end

	Settings.SetOnValueChangedCallback('PROXY_STATUS_TEXT', OnStatusTextSettingChanged)
end

function CPTextStatusBarMixin:SetBarText(text)
	if ( not text ) then
		return
	end
	self.TextString = text;
end

function CPTextStatusBarMixin:TextStatusBarOnEvent(event, ...)
	if ( event == 'CVAR_UPDATE' ) then
		local cvar, value = ...;
		if ( self.cvar and cvar == self.cvar ) then
			if ( self.TextString ) then
				if ( (value == '1' and self.textLockable) or self.forceShow ) then
					self.TextString:Show()
				elseif ( self.lockShow == 0 ) then
					self.TextString:Hide()
				end
			end
			self:UpdateTextString()
		end
	end
end

function CPTextStatusBarMixin:UpdateTextString()
	local textString = self.TextString;
	if(textString) then
		local value = self:GetValue()
		local valueMin, valueMax = self:GetMinMaxValues()
		self:UpdateTextStringWithValues(textString, value, valueMin, valueMax)
	end
end

function CPTextStatusBarMixin:UpdateTextStringWithValues(textString, value, valueMin, valueMax)
	if( self.LeftText and self.RightText ) then
		self.LeftText:SetText('')
		self.RightText:SetText('')
		self.LeftText:Hide()
		self.RightText:Hide()
	end

	-- Max value is valid and updates aren't paused
	if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( self.pauseUpdates ) ) then
		self:Show()

		if ( (self.cvar and GetCVar(self.cvar) == '1' and self.textLockable) or self.forceShow ) then
			textString:Show()
		elseif ( self.lockShow > 0 and (not self.forceHideText) ) then
			textString:Show()
		else
			textString:SetText('')
			textString:Hide()
			return;
		end

		-- Display zero text
		if ( value == 0 and self.zeroText ) then
			textString:SetText(self.zeroText)
			self.isZero = 1;
			textString:Show()
			return;
		end

		self.isZero = nil;

		local valueDisplay = value;
		local valueMaxDisplay = valueMax;

		-- If custom text transform func provided, use that
		if ( self.numericDisplayTransformFunc ) then
			valueDisplay, valueMaxDisplay = self.numericDisplayTransformFunc(value, valueMax)
		-- Otherwise just the usual large number handling
		else
			if ( self.capNumericDisplay ) then
				valueDisplay = AbbreviateLargeNumbers(value)
				valueMaxDisplay = AbbreviateLargeNumbers(valueMax)
			else
				valueDisplay = BreakUpLargeNumbers(value)
				valueMaxDisplay = BreakUpLargeNumbers(valueMax)
			end
		end

		local shouldUsePrefix = self.prefix and (self.alwaysPrefix or not (self.cvar and GetCVar(self.cvar) == '1' and self.textLockable) )

		local displayMode = GetCVar('statusTextDisplay')
		-- Evaluate display mode overrides in priority order
		if ( self.showNumeric ) then
			displayMode = STATUS_TEXT_DISPLAY_MODE.NUMERIC;
		elseif ( self.showPercentage ) then
			displayMode = STATUS_TEXT_DISPLAY_MODE.PERCENT;
		end

		-- If percent-only mode and percentages disabled, fall back on numeric-only
		if ( self.disablePercentages and displayMode == STATUS_TEXT_DISPLAY_MODE.PERCENT ) then
			displayMode = STATUS_TEXT_DISPLAY_MODE.NUMERIC;
		end

		-- Numeric only
		if ( valueMax <= 0 or displayMode == STATUS_TEXT_DISPLAY_MODE.NUMERIC or displayMode == STATUS_TEXT_DISPLAY_MODE.NONE) then
			if ( shouldUsePrefix ) then
				textString:SetText(self.prefix..' '..valueDisplay..' / '..valueMaxDisplay)
			else
				textString:SetText(valueDisplay..' / '..valueMaxDisplay)
			end
		-- Numeric + Percentage
		elseif ( displayMode == STATUS_TEXT_DISPLAY_MODE.BOTH ) then
			if ( self.LeftText and self.RightText ) then
				-- Unless explicitly disabled, only display percentage on left if displaying mana or a non-power value (legacy behavior that should eventually be revisited)
				if ( not self.disablePercentages and (not self.powerToken or self.powerToken == 'MANA') ) then
					self.LeftText:SetText(math.ceil((value / valueMax) * 100) .. '%')
					self.LeftText:Show()
				end
				self.RightText:SetText(valueDisplay)
				self.RightText:Show()
				textString:Hide()
			else
				valueDisplay = valueDisplay .. ' / ' .. valueMaxDisplay;
				if ( not self.disablePercentages ) then
					valueDisplay = '(' .. math.ceil((value / valueMax) * 100) .. '%) ' .. valueDisplay;
				end
			end
			textString:SetText(valueDisplay)
		-- Percentage Only
		elseif ( displayMode == STATUS_TEXT_DISPLAY_MODE.PERCENT ) then
			valueDisplay = math.ceil((value / valueMax) * 100) .. '%';
			if ( shouldUsePrefix ) then
				textString:SetText(self.prefix .. ' ' .. valueDisplay)
			else
				textString:SetText(valueDisplay)
			end
		end
	-- Max value is invalid or updates are paused
	else
		textString:Hide()
		textString:SetText('')
		if ( not self.alwaysShow ) then
			self:Hide()
		else
			self:SetValue(0)
		end
	end
end

function CPTextStatusBarMixin:OnStatusBarEnter()
	self:ShowStatusBarText()
	self:UpdateTextString()
end

function CPTextStatusBarMixin:OnStatusBarLeave()
	self:HideStatusBarText()
	GameTooltip:Hide()
end

function CPTextStatusBarMixin:OnStatusBarValueChanged()
	self:UpdateTextString()
end

function CPTextStatusBarMixin:OnStatusBarMinMaxChanged(min, max)
end

function CPTextStatusBarMixin:SetBarTextPrefix(prefix)
	if ( self.TextString ) then
		self.prefix = prefix;
	end
end

function CPTextStatusBarMixin:SetBarTextZeroText(zeroText)
	if ( self.TextString ) then
		self.zeroText = zeroText;
	end
end

function CPTextStatusBarMixin:ShowStatusBarText()
	if ( self and self.TextString ) then
		if ( not self.lockShow ) then
			self.lockShow = 0;
		end
		if ( not self.forceHideText ) then
			self.TextString:Show()
		end
		self.lockShow = self.lockShow + 1;
		self:UpdateTextString()
	end
end

function CPTextStatusBarMixin:HideStatusBarText()
	if ( self and self.TextString ) then
		if ( not self.lockShow ) then
			self.lockShow = 0;
		end
		if ( self.lockShow > 0 ) then
			self.lockShow = self.lockShow - 1;
		end
		if ( self.lockShow > 0 or self.isZero == 1) then
			self.TextString:Show()
		elseif ( (self.cvar and GetCVarBool(self.cvar) and self.textLockable) or self.forceShow ) then
			self.TextString:Show()
		else
			self.TextString:Hide()
		end
		self:UpdateTextString()
	end
end