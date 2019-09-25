local _, ab = ...
---------------------------------------------------------------
CPStatusTrackingBarMixin = { } 

function CPStatusTrackingBarMixin:GetPriority()
	return self.priority
end

--Override this in your bar.lua function 
function CPStatusTrackingBarMixin:Update()
	error("Implement an update function on your bar")
end

--Override this to update the bar tick (if the bar has one) 
--Called when the bar is resized (RightBottomBar enabled/disabled)
function CPStatusTrackingBarMixin:UpdateTick()

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
	return GetCVarBool("xpBarText") or self.textLocked or self:GetParent():IsTextLocked()
end

function CPStatusTrackingBarMixin:SetTextLocked(locked)
	if ( self.textLocked ~= locked ) then
		self.textLocked = locked
		self:UpdateTextVisibility()
	end
end

function CPStatusTrackingBarMixin:UpdateTextVisibility()
	self.OverlayFrame.Text:SetShown(self:ShouldBarTextBeDisplayed())
end

---------------------------------------------------------------
CPExpBarMixin = CreateFromMixins(CPStatusTrackingBarMixin)

local XP_STATUS_BAR_TEXT = 'XP: %d/%d'

function CPExpBarMixin:GetPriority()
	return self.priority 
end

function CPExpBarMixin:ShouldBeVisible()
	return not IsPlayerAtEffectiveMaxLevel() and not CPAPI:IsXPUserDisabled()
end

function CPExpBarMixin:Update() 
	local currXP = UnitXP("player")
	local nextXP = UnitXPMax("player")
	local level = UnitLevel("player")

	local minBar, maxBar = 0, nextXP
	
	local isCapped = false
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData()
		if UnitLevel("player") >= rLevel then
			isCapped = true
			self:SetBarValues(1, 0, 1, level)
			self.StatusBar:ProcessChangesInstantly()
			self:SetBarColor(0.58, 0.0, 0.55, 1.0)
		end
	end
	if (not isCapped) then
		self:SetBarValues(currXP, minBar, maxBar, level)
	end

	self.currXP = currXP 
	self.maxBar = maxBar

	self:UpdateCurrentText()
end

function CPExpBarMixin:UpdateCurrentText()
	local currXP = self.currXP
	local maxBar = self.maxBar
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData()
		if (UnitLevel("player") >= rLevel) then
			currXP = UnitTrialXP("player")
		end
	end
	self:SetBarText(XP_STATUS_BAR_TEXT:format(currXP, maxBar)) 
end

function CPExpBarMixin:OnLoad()
	TextStatusBar_Initialize(self)
	
	self:Update()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("CVAR_UPDATE")
	self.priority = 3 
end

function CPExpBarMixin:OnEvent(event, ...) 
	if( event == "CVAR_UPDATE") then
		local cvar = ...
		if( cvar == "XP_BAR_TEXT" ) then
			self:UpdateTextVisibility()
		end
	elseif ( event == "PLAYER_XP_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
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
	self.ExhaustionTick.timer = 1
	local label = XPBAR_LABEL
	
	if ( GameLimitedMode_IsActive() ) then
		local rLevel = GetRestrictedAccountData()
		if UnitLevel("player") >= rLevel then
			local trialXP = UnitTrialXP("player")
			local bankedLevels = UnitTrialBankedLevels("player")
			if (trialXP > 0) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
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
				label = label.." "..RED_FONT_COLOR_CODE..CAP_REACHED_TRIAL.."|r"
			end
		end
	end

	GameTooltip_AddNewbieTip(self, label, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_XPBAR, 1)
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
CPExhaustionTickMixin = { }
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
	
	local currXP = UnitXP("player")
	local nextXP = UnitXPMax("player")
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

	if ( SHOW_NEWBIE_TIPS ~= "1" ) then
		GameTooltip:SetText(tooltipText)
	else
		if ( GameTooltip.canAddRestStateLine ) then
			GameTooltip:AddLine("\n"..tooltipText)
			GameTooltip:Show()
			GameTooltip.canAddRestStateLine = nil
		end
	end
end

function CPExhaustionTickMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("UPDATE_EXHAUSTION")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
end

function CPExhaustionTickMixin:UpdateTickPosition()
	local playerCurrXP = UnitXP("player")
	local playerMaxXP = UnitXPMax("player")
	local exhaustionThreshold = GetXPExhaustion()
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
		
	if ( exhaustionStateID and exhaustionStateID >= 3 ) then
		self:SetPoint("CENTER", self:GetParent() , "RIGHT", 0, 0)
	end

	if ( not exhaustionThreshold ) then
		self:Hide()
		self:GetParent().ExhaustionLevelFillBar:Hide()
	else
		local exhaustionTickSet = max(((playerCurrXP + exhaustionThreshold) / playerMaxXP) * (self:GetParent():GetWidth()), 0)
		self:ClearAllPoints()
		
		if ( exhaustionTickSet > self:GetParent():GetWidth() ) then
			self:Hide()
			self:GetParent().ExhaustionLevelFillBar:Hide()
		else
			self:Show()
			self:SetPoint("CENTER", self:GetParent(), "LEFT", exhaustionTickSet, 2)
			self:GetParent().ExhaustionLevelFillBar:Show()
			self:GetParent().ExhaustionLevelFillBar:SetPoint("TOPRIGHT", self:GetParent(), "TOPLEFT", exhaustionTickSet, 0)
		end
	end

	-- Hide exhaustion tick if player is max level or XP is turned off
	if ( IsPlayerAtEffectiveMaxLevel() or CPAPI:IsXPUserDisabled() ) then
		self:Hide()
	end			
end

function CPExhaustionTickMixin:UpdateExhaustionColor()
	local exhaustionStateID = GetRestState()
	if ( exhaustionStateID == 1 ) then
		self:GetParent():SetBarColor(0.0, 0.39, 0.88, 1.0)
		self:GetParent().ExhaustionLevelFillBar:SetVertexColor(0.0, 0.39, 0.88, 0.25)
		self.Highlight:SetVertexColor(0.0, 0.39, 0.88)
	elseif ( exhaustionStateID == 2 ) then
		self:GetParent():SetBarColor(ab:GetRGBColorFor('exp'))
		self:GetParent().ExhaustionLevelFillBar:SetVertexColor(0.58, 0.0, 0.55, 0.25)
		self.Highlight:SetVertexColor(0.58, 0.0, 0.55)
	end
end

function CPExhaustionTickMixin:OnEvent(event, ...)
	if (IsRestrictedAccount()) then
		local rlevel = GetRestrictedAccountData()
		if (UnitLevel("player") >= rlevel) then
			self:GetParent():SetBarColor(ab:GetRGBColorFor('exp'))
			self:Hide()
			self:GetParent().ExhaustionLevelFillBar:Hide()
			self:UnregisterAllEvents()	
			return
		end
	end
	if ( event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION" or event == "PLAYER_LEVEL_UP" ) then
		self:UpdateTickPosition() 
	end
	
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_EXHAUSTION" ) then
		self:UpdateExhaustionColor()
	end
	
	if ( not self:IsShown() ) then
		self:Hide()
	end
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

---------------------------------------------------------------
CPReputationBarMixin = CreateFromMixins(CPStatusTrackingBarMixin)

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
	local name, reaction, minFaction, maxFaction, value, factionID = GetWatchedFactionInfo()
	return name ~= nil
end

function CPReputationBarMixin:Update() 
	local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo()
	local colorIndex = reaction
	local isCapped
	local friendshipID = CPAPI:GetFriendshipReputation(factionID)
	
	if ( self.factionID ~= factionID ) then
			self.factionID = factionID
			self.friendshipID = CPAPI:GetFriendshipReputation(factionID)
		end
	
	-- do something different for friendships
	local level
	
	if ( friendshipID ) then
		local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
		level = GetFriendshipReputationRanks(factionID)
		if ( nextFriendThreshold ) then
			minBar, maxBar, value = friendThreshold, nextFriendThreshold, friendRep
		else
			-- max rank, make it look like a full bar
			minBar, maxBar, value = 0, 1, 1
			isCapped = true
		end
		colorIndex = 5		-- always color friendships green
		
	elseif ( C_Reputation and C_Reputation.IsFactionParagon(factionID) ) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
		minBar, maxBar  = 0, threshold
		value = currentValue % threshold
		if ( hasRewardPending ) then 
			value = value + threshold
		end
	else
		level = reaction
		if ( reaction == MAX_REPUTATION_REACTION ) then
			isCapped = true
		end
	end
	
	-- Normalize values
	maxBar = maxBar - minBar
	value = value - minBar
	if ( isCapped and maxBar == 0 ) then
		maxBar = 1
		value = 1
	end
	minBar = 0
	
	self:SetBarValues(value, minBar, maxBar, level) 
	
	if ( isCapped ) then
		self:SetBarText(name)
	else
		name = name.." %d / %d"
		self:SetBarText(name:format(value, maxBar)) 
	end
	
	local color = FACTION_BAR_COLORS[colorIndex]
	
	self:SetBarColor(color.r, color.g, color.b, 1) 
	
	self.isCapped = isCapped 
	self.name = name
	self.value = value 
	self.max = maxBar 
end

function CPReputationBarMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE")
	self.priority = 1 
end

function CPReputationBarMixin:OnEvent(event, ...)
	if( event == "CVAR_UPDATE") then
		local cvar = ...
		if( cvar == "XP_BAR_TEXT" ) then
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