local env, db, _, L = CPAPI.GetEnv(...)
local WATCH_TEXT_SLOTS = {
	top = {visibility = 'watchTopTextVisibility'; format = 'watchTopTextFormat'};
	bottom = {visibility = 'watchBottomTextVisibility'; format = 'watchBottomTextFormat'};
};

local function getWatchTextSlot(bar)
	return bar.watchTextSlot or WATCH_TEXT_SLOTS.bottom;
end

local function getProgressPercent(value, maximum)
	if maximum <= 0 then return 0 end;
	return math.ceil(value * 100 / maximum);
end

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

local function shouldShowWatchBarText(visibility, isHovered)
	if visibility == 'always' then
		return true;
	elseif visibility == 'hidden' then
		return false;
	end
	return not not isHovered;
end

function CPStatusTrackingBarMixin:ShouldBarTextBeDisplayed()
	return shouldShowWatchBarText(env(getWatchTextSlot(self).visibility), self.textLocked);
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
-- Watch bar text
---------------------------------------------------------------
local WATCH_TEXT_FORMATTERS = {
	progress = function(value, maximum)
		return L('%s / %s', BreakUpLargeNumbers(value), BreakUpLargeNumbers(maximum));
	end;
	percent = function(_, _, progressPercent)
		return L('%d%%', progressPercent);
	end;
	both = function(value, maximum, progressPercent)
		return L('%s / %s (%d%%)', BreakUpLargeNumbers(value), BreakUpLargeNumbers(maximum), progressPercent);
	end;
	remaining = function(value, maximum)
		local remaining = math.max(0, maximum - value);
		return L('%s remaining', BreakUpLargeNumbers(remaining));
	end;
};

local function formatWatchBarText(name, textFormat, value, maximum)
	local formatter = WATCH_TEXT_FORMATTERS[textFormat] or WATCH_TEXT_FORMATTERS.progress;
	local progressPercent = math.min(getProgressPercent(value, maximum), 100);
	return L('%s: %s', name, formatter(value, maximum, progressPercent));
end

---------------------------------------------------------------
CPExpBarMixin = CreateFromMixins(CPStatusTrackingBarMixin)
---------------------------------------------------------------
CPExpBarMixin.Events = {
	'PLAYER_ENTERING_WORLD';
	'PLAYER_XP_UPDATE';
	'UPDATE_EXHAUSTION';
};

function CPExpBarMixin:GetPriority()
	return self.priority
end

function CPExpBarMixin:ShouldBeVisible()
	return not CPAPI.IsPlayerAtEffectiveMaxLevel() and not CPAPI.IsXPUserDisabled()
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
	local text = formatWatchBarText(L'XP', env(getWatchTextSlot(self).format), currXP, maxBar);
	local restedPercent = getProgressPercent(GetXPExhaustion() or 0, maxBar);
	if restedPercent > 0 then
		text = L('%s (+%d%%)', text, restedPercent);
	end
	self:SetBarText(text)
end

function CPExpBarMixin:OnLoad()
	self.StatusBar:InitializeTextStatusBar()
	self:Update()
	CPAPI.RegisterFrameForEvents(self, self.Events)
	self.priority = 4;
end

function CPExpBarMixin:OnEvent(event)
	if ( event == 'PLAYER_XP_UPDATE' or event == 'PLAYER_ENTERING_WORLD' ) then
		self:Update()
	elseif ( event == 'UPDATE_EXHAUSTION' ) then
		self:UpdateCurrentText()
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
	self.ExhaustionTick:UpdateTick()
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
	local percentXP = math.min(getProgressPercent(currXP, nextXP), 100)
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
	if IsLoggedIn() then
		self:PLAYER_ENTERING_WORLD()
	end
end

function CPExhaustionTickMixin:UpdateTickPosition()
	local playerCurrXP = UnitXP('player')
	local playerMaxXP = UnitXPMax('player')
	local exhaustionThreshold = GetXPExhaustion()
	local parent = self:GetParent()

	if ( not exhaustionThreshold or exhaustionThreshold <= 0 or playerMaxXP <= 0
		or CPAPI.IsPlayerAtEffectiveMaxLevel() or CPAPI.IsXPUserDisabled() ) then
		self:Hide()
		parent.ExhaustionLevelFillBar:Hide()
		return;
	end

	local width = parent:GetWidth();
	local exhaustionFillFraction = math.max((playerCurrXP + exhaustionThreshold) / playerMaxXP, 0);
	local exhaustionTickSet = exhaustionFillFraction * width;
	self:ClearAllPoints()

	if exhaustionFillFraction > 1 then
		self:Hide()
	else
		self:SetPoint('CENTER', parent, 'LEFT', exhaustionTickSet, 0)
		self:Show()
	end

	local fill = parent.ExhaustionLevelFillBar;
	local fillFraction = math.min(exhaustionFillFraction, 1);
	fill:SetTexture(parent.StatusBar:GetStatusBarTexture():GetTexture())
	fill:SetTexCoord(0, fillFraction, 0, 1)
	fill:SetPoint('TOPRIGHT', parent, 'TOPLEFT', fillFraction * width, 0)
	fill:Show()
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

function CPExhaustionTickMixin:UpdateTick()
	self:UpdateTickPosition()
	self:UpdateExhaustionColor()
end

CPExhaustionTickMixin.PLAYER_XP_UPDATE      = CPExhaustionTickMixin.UpdateTickPosition;
CPExhaustionTickMixin.PLAYER_LEVEL_UP       = CPExhaustionTickMixin.UpdateTickPosition;
CPExhaustionTickMixin.PLAYER_ENTERING_WORLD = CPExhaustionTickMixin.UpdateTick;
CPExhaustionTickMixin.UPDATE_EXHAUSTION     = CPExhaustionTickMixin.UpdateTick;
CPExhaustionTickMixin.PLAYER_UPDATE_RESTING = CPExhaustionTickMixin.UpdateTick;

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
local MAX_STANDARD_REPUTATION_REACTION = 8;

function CPReputationBarMixin:GetPriority()
	return self.priority
end

function CPReputationBarMixin:UpdateCurrentText()
	if not self.name then return end;
	if self.isCapped then
		self:SetBarText(self.name)
		return;
	end
	self:SetBarText(formatWatchBarText(self.name, env(getWatchTextSlot(self).format), self.value, self.max))
end

function CPReputationBarMixin:ShouldBeVisible()
	local watchedFactionData = C_Reputation.GetWatchedFactionData()
	return watchedFactionData and watchedFactionData.factionID ~= 0;
end

function CPReputationBarMixin:GetMaxLevel()
	local watchedFactionData = C_Reputation.GetWatchedFactionData()
	if not watchedFactionData or watchedFactionData.factionID == 0 then
		return nil;
	end

	local factionID = watchedFactionData.factionID;
	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		return nil;
	end

	if C_Reputation.IsMajorFaction(factionID) then
		local renownLevelsInfo = CPAPI.GetRenownLevels(factionID)
		return renownLevelsInfo[#renownLevelsInfo].level;
	end

	local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
	local friendshipID = reputationInfo.friendshipFactionID;
	if friendshipID and friendshipID > 0 then
		local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
		return repRankInfo.maxLevel;
	end

	return MAX_STANDARD_REPUTATION_REACTION;
end

function CPReputationBarMixin:Update()
	local watchedFactionData = C_Reputation.GetWatchedFactionData()
	if not watchedFactionData or watchedFactionData.factionID == 0 then
		return;
	end

	local reaction = watchedFactionData.reaction;
	local colorIndex = reaction;
	local overrideUseBlueBar = false;

	local factionID = watchedFactionData.factionID;
	local isShowingNewFaction = self.factionID ~= factionID;
	if isShowingNewFaction then
		local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		self.factionID = factionID;
		self.friendshipID = reputationInfo.friendshipFactionID;
	end

	local level, rank;
	local maxLevel = self:GetMaxLevel()
	local isMajorFaction = C_Reputation.IsMajorFaction(factionID);
	local majorFactionData = isMajorFaction and CPAPI.GetMajorFactionData(factionID);
	if majorFactionData and majorFactionData.renownLevel then
		rank = RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel);
	end

	local minBar, maxBar, value = watchedFactionData.currentReactionThreshold, watchedFactionData.nextReactionThreshold, watchedFactionData.currentStanding;
	local paragonValue, paragonThreshold, _, hasRewardPending;
	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		paragonValue, paragonThreshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
	end
	if ( paragonValue and paragonThreshold and paragonThreshold > 0 ) then
		minBar, maxBar = 0, paragonThreshold;
		value = paragonValue % paragonThreshold;
		level = maxLevel;
		if hasRewardPending then
			value = value + paragonThreshold;
		end
		if isMajorFaction then
			overrideUseBlueBar = true;
		elseif self.friendshipID and self.friendshipID > 0 then
			rank = C_GossipInfo.GetFriendshipReputation(factionID).reaction;
		end
	elseif majorFactionData then
		minBar, maxBar = 0, majorFactionData.renownLevelThreshold;
		value = majorFactionData.renownReputationEarned or value;
		level = majorFactionData.renownLevel;
		overrideUseBlueBar = true;
	elseif self.friendshipID and self.friendshipID > 0 then
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
		level = repRankInfo.currentLevel;
		rank = repInfo.reaction;
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

	local name = watchedFactionData.name;
	local needsAccountWideLabel = C_Reputation.IsAccountWideReputation(factionID)
	if needsAccountWideLabel then
		name = name .. " " .. REPUTATION_STATUS_BAR_LABEL_ACCOUNT_WIDE;
	end
	if ( not rank and reaction and reaction >= 1 and reaction <= MAX_STANDARD_REPUTATION_REACTION ) then
		rank = GetText('FACTION_STANDING_LABEL'..reaction, UnitSex('player'));
	end
	if rank and rank ~= '' then
		name = L('%s (%s)', name, rank);
	end

	self.name     = name;
	self.value    = value;
	self.max      = maxBar;
	self.isCapped = isCapped;
	self:UpdateCurrentText()

	local color = overrideUseBlueBar and BLUE_FONT_COLOR or FACTION_BAR_COLORS[colorIndex];
	self:SetBarColor(color.r, color.g, color.b, 1)

	-- When showing new faction, force status bar to update instantly
	if isShowingNewFaction then
		self.StatusBar:ProcessChangesInstantly()
	end
end

function CPReputationBarMixin:OnLoad()
	self.priority = 1
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
	'MAJOR_FACTION_RENOWN_LEVEL_CHANGED';
	'ENABLE_XP_GAIN';
	'DISABLE_XP_GAIN';
	'CVAR_UPDATE';
	'UPDATE_EXPANSION_LEVEL';
	'PLAYER_ENTERING_WORLD';
	'HONOR_XP_UPDATE';
	'ZONE_CHANGED';
	'ZONE_CHANGED_NEW_AREA';
	'UNIT_INVENTORY_CHANGED';
	'PLAYER_EQUIPMENT_CHANGED';
	'PLAYER_MAX_LEVEL_UPDATE';
	'ARTIFACT_XP_UPDATE';
	'AZERITE_ITEM_EXPERIENCE_CHANGED';
	'TRACKED_HOUSE_CHANGED';
};

function CPWatchBarContainerMixin:OnLoad()
	self.bars = {};
	env:RegisterCallbacks(self.UpdateBarVisibility, self, 'Settings/watchTopTextVisibility', 'Settings/watchBottomTextVisibility')
	env:RegisterCallbacks(self.UpdateBarTexts, self, 'Settings/watchTopTextFormat', 'Settings/watchBottomTextFormat')

	CPAPI.RegisterFrameForEvents(self, self.Events)
	self:RegisterUnitEvent('UNIT_LEVEL', 'player')

	self:SetInitialBarSize()
	self:UpdateBarsShown()
	self:Init()
end

function CPWatchBarContainerMixin:OnEvent(event)
	if ( event == 'TRACKED_HOUSE_CHANGED' and self.houseFavorBar ) then
		local bar = self.houseFavorBar;
		bar.houseLevelFavor = nil;
		bar:Hide() -- OnShow requests favor for the newly tracked house.
	end
	self:UpdateBarsShown()
end

function CPWatchBarContainerMixin:OnShow()
	self.fadeShown = nil;
	self:UpdateFade()
end

function CPWatchBarContainerMixin:UpdateFade()
	local shown = not env('fadeXPBar');
	if not shown then
		for _, bar in self:Enumerate() do
			if ( bar:IsShown() and bar:IsMouseOver() ) then
				shown = true;
				break;
			end
		end
	end
	if ( self.fadeShown ~= shown ) then
		self.fadeShown = shown;
		db.Alpha.Fader.Toggle(self, 0.2, shown, true)
	end
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
		if bar:IsShown() then
			bar:UpdateTextVisibility()
		end
	end
end

function CPWatchBarContainerMixin:UpdateBarTexts()
	for _, bar in self:Enumerate() do
		if ( bar:IsShown() and bar.UpdateCurrentText ) then
			bar:UpdateCurrentText()
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
		if bar:IsShown() then
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

	table.sort(visibleBars, function(left, right) return left:GetPriority() > right:GetPriority() end)
	self:LayoutBars(visibleBars)
end

function CPWatchBarContainerMixin:HideBarBackdrops()
	self.SingleBarSmall:Hide()
	self.SingleBarLarge:Hide()
	self.SingleBarSmallUpper:Hide()
	self.SingleBarLargeUpper:Hide()
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

function CPWatchBarContainerMixin:LayoutBar(bar, barWidth, isSecondary, isDouble)
	local inverted = not not self.inverted;
	local isTopSlot = isDouble and (isSecondary ~= inverted);
	bar.watchTextSlot = isTopSlot and WATCH_TEXT_SLOTS.top or WATCH_TEXT_SLOTS.bottom;
	bar:Update()
	bar:ClearAllPoints()

	local normalTexture = self.inverted and XP_BAR_TEXTURE_INVERTED or XP_BAR_TEXTURE_NORMAL;
	local invertTexture = self.inverted and XP_BAR_TEXTURE_NORMAL or XP_BAR_TEXTURE_INVERTED;
	local anchor = self.inverted and 'TOP' or 'BOTTOM';
	local offset = self.inverted and -18 or 18;

	if ( isDouble ) then
		if ( isSecondary ) then
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
	bar:Show()
	bar:UpdateTextVisibility()
end

function CPWatchBarContainerMixin:SetXPBarColor(r, g, b)
	if self.experienceBar then
		self.experienceBar:SetBarColor(r, g, b)
	end
end

function CPWatchBarContainerMixin:LayoutBars(visBars)
	local width = self:GetWidth()
	self:HideBarBackdrops()
	for _, bar in self:Enumerate() do
		if ( bar:IsShown() and bar ~= visBars[1] and bar ~= visBars[2] ) then
			bar:Hide()
		end
	end

	local SECONDARY, IS_DOUBLE = true, true;
	if ( #visBars > 1 ) then
		self:LayoutBar(visBars[1], width, not SECONDARY, IS_DOUBLE)
		self:LayoutBar(visBars[2], width, SECONDARY, IS_DOUBLE)
	elseif( #visBars == 1 ) then
		self:LayoutBar(visBars[1], width, SECONDARY, not IS_DOUBLE)
	end
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
	local function configureNativeWatchText(bar, name)
		function bar:ShouldBarTextBeDisplayed()
			return shouldShowWatchBarText(env(getWatchTextSlot(self).visibility), self:IsMouseOver());
		end

		bar:HookScript('OnUpdate', function(self)
			if ( env(getWatchTextSlot(self).visibility) == 'hover'
				and self.OverlayFrame.Text:IsShown() ~= self:ShouldBarTextBeDisplayed() ) then
				self:UpdateTextVisibility()
			end
		end)

		if not name then
			-- Refresh Blizzard's label when ConsolePort reveals it.
			if bar.UpdateOverlayFrameText then
				hooksecurefunc(bar, 'UpdateTextVisibility', bar.UpdateOverlayFrameText)
			end
			return;
		end

		function bar:UpdateCurrentText()
			if self.watchTextValue then
				local text = formatWatchBarText(name, env(getWatchTextSlot(self).format), self.watchTextValue, self.watchTextMaximum);
				CPStatusTrackingBarMixin.SetBarText(self, text)
			end
		end

		hooksecurefunc(bar, 'SetBarValues', function(self, value, minimum, maximum)
			if ( CPAPI.IsSecret(value) or CPAPI.IsSecret(minimum) or CPAPI.IsSecret(maximum)
				or type(value) ~= 'number' or type(minimum) ~= 'number' or type(maximum) ~= 'number' ) then
				self.watchTextValue = nil;
				return;
			end
			self.watchTextValue = value - minimum;
			self.watchTextMaximum = maximum - minimum;
			self:UpdateCurrentText()
		end)
		hooksecurefunc(bar, 'SetBarText', bar.UpdateCurrentText)
		if bar.UpdateOverlayFrameText then
			hooksecurefunc(bar, 'UpdateOverlayFrameText', bar.UpdateCurrentText)
		end
	end

	function CPWatchBarContainerMixin:AddBarFromTemplate(template, showPredicate, getPriority, textName)
		local bar = CreateFrame('Frame', nil, self, template)
		local statusBar = bar.StatusBar;
		table.insert(self.bars, bar)
		if template == 'CPExpStatusBarTemplate' then
			self.experienceBar = bar;
		elseif ( textName or template == 'HouseFavorBarTemplate' ) then
			configureNativeWatchText(bar, textName and L(textName))
		end

		statusBar.Background:Hide()
		statusBar.BarTexture:SetTexture(XP_BAR_TEXTURE_NORMAL)
		statusBar.BarTexture:SetSnapToPixelGrid(true)
		statusBar.BarTexture:SetTexelSnappingBias(0)

		if not bar.CurrentXPTick then
			bar.CurrentXPTick = CreateFrame('Button', nil, bar, 'CPWatchBarProgressTickTemplate')
			bar.CurrentXPTick:SetPoint('CENTER', statusBar.BarTexture, 'RIGHT')
		end
		local tick = bar.CurrentXPTick;
		local function updateProgressTick(self)
			local value = self:GetValue();
			local _, maximum = self:GetMinMaxValues();
			if ( CPAPI.IsSecret(value) or CPAPI.IsSecret(maximum) ) then return end;
			tick:SetShown(value < maximum)
		end
		statusBar:HookScript('OnValueChanged', updateProgressTick)
		statusBar:HookScript('OnMinMaxChanged', updateProgressTick)
		updateProgressTick(statusBar)

		local overlay = bar.OverlayFrame;
		overlay:SetFrameStrata(bar:GetFrameStrata())
		overlay:SetFrameLevel(math.max(statusBar:GetFrameLevel(), tick:GetFrameLevel()) + 1)

		bar.ShouldBeVisible = showPredicate or bar.ShouldBeVisible or nop;
		bar.GetPriority     = getPriority or bar.GetPriority;

		self:UpdateBarsShown()
		return bar;
	end
end

local OPTIONAL_WATCH_BAR_TEMPLATES = {
	{'Honor', 'HonorStatusBarTemplate', 'Honor'};
	{'Artifact', 'ArtifactStatusBarTemplate', 'Artifact Power'};
	{'Azerite', 'AzeriteBarTemplate', 'Azerite'};
};

function CPWatchBarContainerMixin:Init()
	local manager = StatusTrackingManagerMixin;
	local barIDs = StatusTrackingBarInfo and StatusTrackingBarInfo.BarsEnum;
	if not ( manager and manager.CanShowBar and manager.GetBarPriority and barIDs ) then
		self:AddBarFromTemplate('CPReputationStatusBarTemplate')
		self:AddBarFromTemplate('CPExpStatusBarTemplate')
		return;
	end

	local function addBar(template, barID, textName)
		if not barID then return end;
		return self:AddBarFromTemplate(template,
			GenerateClosure(manager.CanShowBar, manager, barID),
			GenerateClosure(manager.GetBarPriority, manager, barID), textName)
	end

	addBar('CPReputationStatusBarTemplate', barIDs.Reputation)
	local hasTemplate = C_XMLUtil and C_XMLUtil.GetTemplateInfo or DoesTemplateExist;
	if hasTemplate then
		for _, entry in ipairs(OPTIONAL_WATCH_BAR_TEMPLATES) do
			local barType, template, textName = unpack(entry);
			if hasTemplate(template) then
				addBar(template, barIDs[barType], textName)
			end
		end
		if ( C_Housing and C_Housing.GetTrackedHouseGuid and hasTemplate('HouseFavorBarTemplate') ) then
			self.houseFavorBar = addBar('HouseFavorBarTemplate', barIDs.HouseFavor);
		end
	end
	addBar('CPExpStatusBarTemplate', barIDs.Experience)
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
