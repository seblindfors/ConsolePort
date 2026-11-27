local env = CPAPI.GetEnv(...)
---------------------------------------------------------------
local _, _, CLUSTER_BUTTON = env.Const.Cluster.Types();
local Cooldowns = {}; env.ClusterCooldownMixin = Cooldowns;
---------------------------------------------------------------
local CreateFrame, CreateColor, Mixin = CreateFrame, CreateColor, Mixin;
local GetTime, GetActionInfo, GetCVarBool = GetTime, GetActionInfo, GetCVarBool;
local abs, max, min, next, type, wipe = math.abs, math.max, math.min, next, type, wipe;
local IsSecret, Index, Next = CPAPI.IsSecret, CPAPI.Index, CPAPI.Next;
local ProxyCooldown = env.ProxyCooldown;

local SHORT_COOLDOWN_LIMIT  = 2;
local TIMING_TOLERANCE      = 0.001;
local GCD_WHEN_UNKNOWN      = false;
local GCD_SPELL_ID          = (CPAPI.IsAnniVersion or CPAPI.IsCamelotVersion or CPAPI.IsClassicEraVersion or CPAPI.IsWrathVersion)
	and 29515 or 61304;
local FULL_ROTATION         = 2 * math.pi;
local MS_PER_SECOND         = 1000;
local LOSS_OF_CONTROL_RED   = 0.17;
local DEFAULT_SWIPE_ALPHA   = env.Const.Cluster.CooldownShadeAlpha;
local COOLDOWN_SWIPE_SCALE  = 0.50 / DEFAULT_SWIPE_ALPHA;
local COOLDOWN_SHADOW_ALPHA = 0.81;
local SWING_EDGE_SCALE      = 1.26;
local SWING_BURST_DURATION  = env.ClusterBurstDuration;

local LOCKOUT_EDGE_TEXTURE  = CPAPI.IsModernVersion and [[Interface\Cooldown\UI-HUD-ActionBar-LoC]]
	or [[Interface\Cooldown\edge-LoC]];
local CHARGE_EDGE_TEXTURE   = env.Const.Cluster.Assets.ChargeEdge;
local SWING_EDGE_TEXTURE    = env.Const.Cluster.Assets.SwingEdge;
local COOLDOWN_SHADOW_PATH  = env.Const.Cluster.AssetFormats.CooldownShadow;

local SWING_TYPES           = CPAPI.IsCamelotVersion and C_SwingTimer and CPAPI.IsEventValid('PLAYER_SWING')
	and Enum.PlayerSwingType;
local EDGE_ROTATION         = C_CurveUtil and C_CurveUtil.CreateCurve and C_CurveUtil.CreateCurve();
if EDGE_ROTATION then
	EDGE_ROTATION:AddPoint(0, 0)
	EDGE_ROTATION:AddPoint(1, -FULL_ROTATION)
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
local GetActionCooldownDuration = CPAPI.GetActionCooldownDuration;
local GetSpellCooldownDuration  = CPAPI.GetSpellCooldownDuration;
local GetItemCooldown           = CPAPI.GetItemCooldown;
local EvaluateColorFromBoolean  = C_CurveUtil and C_CurveUtil.EvaluateColorFromBoolean;
local GetActionLockoutInfo      = C_ActionBar and C_ActionBar.GetActionLossOfControlCooldownInfo;
local HAS_FOREVER_LOCKOUT       = CPAPI.IsCamelotVersion and GetActionLockoutInfo
	and C_ActionBar.GetActionLossOfControlCooldownDuration;

local getGlobalCooldownTimes = nop;
if ( C_Spell and C_Spell.GetSpellCooldown ) then
	local GetSpellCooldownInfo = C_Spell.GetSpellCooldown;

	function getGlobalCooldownTimes()
		local gcd = GetSpellCooldownInfo(GCD_SPELL_ID);
		if ( not IsSecret(gcd) and gcd ) then
			return gcd.startTime, gcd.duration;
		end
	end
elseif GetSpellCooldown then
	local GetSpellCooldown = GetSpellCooldown;

	function getGlobalCooldownTimes()
		return GetSpellCooldown(GCD_SPELL_ID);
	end
end

local function getForeverLossOfControlInfo(button)
	if ( button._state_type == 'action' ) then
		return GetActionLockoutInfo(button._state_action);
	end
	return Index(button).GetLoCCooldownInfo(button);
end

local Supports = {};

local function resolveWidgetSupport(button)
	if Supports.Resolved then return end;
	local cooldown = button.cooldown;
	Supports.Resolved       = true;
	Supports.NumberGetter   = cooldown.GetHideCountdownNumbers ~= nil;
	Supports.ParentLevel    = cooldown.SetUsingParentLevel ~= nil;
	Supports.DurationObject = cooldown.SetCooldownFromDurationObject ~= nil;
	Supports.SecretGcd      = EvaluateColorFromBoolean and cooldown.SetAlphaFromBoolean ~= nil;
	Supports.SecretAlpha    = button.SetAlphaFromBoolean ~= nil;
end

---------------------------------------------------------------
-- Timer comparison
---------------------------------------------------------------
local function hasCooldownTiming(start, duration)
	return not IsSecret(start) and not IsSecret(duration)
		and start and duration and start > 0 and duration > 0;
end

local function matchesCooldownTiming(start, duration, otherStart, otherDuration)
	return hasCooldownTiming(start, duration) and hasCooldownTiming(otherStart, otherDuration)
		and abs(start - otherStart) <= TIMING_TOLERANCE and abs(duration - otherDuration) <= TIMING_TOLERANCE;
end

---------------------------------------------------------------
-- @return gcd : true or false when comparable, nil when unknown
local function matchesGlobalCooldown(start, duration)
	if not hasCooldownTiming(start, duration) then return end;
	local gcdStart, gcdDuration = getGlobalCooldownTimes();
	if ( IsSecret(gcdStart) or IsSecret(gcdDuration) or not gcdStart or not gcdDuration ) then return end;
	return matchesCooldownTiming(start, duration, gcdStart, gcdDuration);
end

local function isGlobalCooldownTiming(start, duration)
	local gcd = matchesGlobalCooldown(start, duration);
	if ( gcd == nil ) then return GCD_WHEN_UNKNOWN end;
	return gcd;
end

local function outlastsGlobalCooldown(start, duration)
	local gcd = matchesGlobalCooldown(start, duration);
	if ( gcd ~= nil ) then return not gcd end;
	return not IsSecret(duration) and duration > SHORT_COOLDOWN_LIMIT;
end

local function isClassicLockout(cooldown)
	return COOLDOWN_TYPE_LOSS_OF_CONTROL and cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL;
end

---------------------------------------------------------------
-- Flyout visibility
---------------------------------------------------------------
local function isCooldownShown(cooldown)
	local shown = cooldown and cooldown:IsShown();
	return not IsSecret(shown) and shown;
end

local function timerCanReveal(cooldown)
	if not cooldown then return false end;
	local shown = cooldown:IsShown();
	if IsSecret(shown) then return cooldown.flyoutTimerSet end;
	return shown;
end

local function updateCooldownVisibility(button)
	button.cooldownVisibilityPending = nil;
	local normal        = button.cooldown;
	local wasRestricted = IsSecret(button.flyoutCooldownZero);
	local zero          = normal.flyoutCooldownZero;
	local restricted    = IsSecret(zero);
	local show = timerCanReveal(button.chargeCooldown) or timerCanReveal(button.lossOfControlCooldown);
	button.flyoutCooldownZero = nil;
	if timerCanReveal(normal) then
		if restricted then
			button.flyoutCooldownZero = zero;
		elseif ( zero == false ) then
			show = true;
		end
	end
	local flag = button.AlphaState.OnCooldown;
	if ( flag(button.alpha, show) ~= button.alpha or ( button.alpha == 0 and ( wasRestricted or restricted ) ) ) then
		button:UpdateAlpha(flag, show)
	end
end

local function queueCooldownVisibility(cooldown)
	local button = cooldown:GetParent();
	if button.cooldownVisibilityPending then return end;
	button.cooldownVisibilityPending = true;
	Next(updateCooldownVisibility, button)
end

local function clearFlyoutTimer(cooldown)
	cooldown.flyoutTimerSet, cooldown.flyoutCooldownZero = nil, nil;
end

local function onWatchedCooldownHide(cooldown)
	local shown = cooldown:IsShown();
	if ( not IsSecret(shown) and not shown ) then
		clearFlyoutTimer(cooldown)
	end
	queueCooldownVisibility(cooldown)
end

local function setNumericFlyoutTimer(cooldown, start, duration)
	cooldown.flyoutCooldownZero = not ( outlastsGlobalCooldown(start, duration) or isClassicLockout(cooldown) );
	queueCooldownVisibility(cooldown)
end

local function isItemFlyoutReady(button)
	local kind, item = button._state_type, button._state_action;
	if IsSecret(item) then return end;
	if ( kind == 'action' ) then
		local actionType, id, subType = GetActionInfo(item);
		if ( IsSecret(actionType) or IsSecret(subType) ) then return end;
		local holdsItem = actionType == 'item' or actionType == 'toy'
			or ( actionType == 'macro' and subType == 'item' );
		if not holdsItem then return end;
		item = id;
	elseif ( kind ~= 'item' ) then
		return;
	end
	if ( IsSecret(item) or not item ) then return end;
	local start, duration, enabled = GetItemCooldown(item);
	if ( IsSecret(start) or IsSecret(duration) or IsSecret(enabled) or not duration ) then return end;
	if ( not enabled or not hasCooldownTiming(start, duration) or start + duration <= GetTime() ) then
		return true;
	end
	return duration <= SHORT_COOLDOWN_LIMIT and isGlobalCooldownTiming(start, duration);
end

local function watchCooldownVisibility(cooldown)
	cooldown.flyoutWatched = true;
	ProxyCooldown.OnLoad(cooldown)
	cooldown:HookScript('OnShow', queueCooldownVisibility)
	cooldown:HookScript('OnHide', onWatchedCooldownHide)
end

---------------------------------------------------------------
-- Swipe tint
---------------------------------------------------------------
local function isSwipeHidden(cooldown, isLossOfControl)
	return cooldown.clusterSwipeHidden or ( cooldown.clusterCasting and not isLossOfControl );
end

local function getConfiguredSwipeColor()
	return env:GetColorRGBA('clusterSwipeColor');
end

local function getSwipeTint(cooldown, isLossOfControl)
	if isSwipeHidden(cooldown, isLossOfControl) then return 0, 0, 0, 0 end;
	if isLossOfControl then return LOSS_OF_CONTROL_RED, 0, 0, 0.64 end;
	return getConfiguredSwipeColor();
end

local function applySwipeTint(cooldown, isLossOfControl)
	local r, g, b, alpha = getSwipeTint(cooldown, isLossOfControl);
	local shadow = cooldown.clusterRimShadow;
	if shadow then
		local gcd = cooldown.clusterGcd;
		if ( isLossOfControl or isSwipeHidden(cooldown, isLossOfControl) or cooldown.clusterShowsEdge ) then
			shadow:SetAlpha(0)
		elseif IsSecret(gcd) then
			local color = EvaluateColorFromBoolean(gcd, env:GetColor('clusterGcdSwipeColor'),
				CreateColor(r, g, b, alpha * COOLDOWN_SWIPE_SCALE));
			r, g, b, alpha = color:GetRGBA();
			shadow:SetAlphaFromBoolean(gcd, 0, 1)
		elseif ( gcd == false ) then
			shadow:SetAlpha(1)
			alpha = alpha * COOLDOWN_SWIPE_SCALE;
		else
			if gcd then r, g, b, alpha = env:GetColorRGBA('clusterGcdSwipeColor') end;
			shadow:SetAlpha(0)
		end
	end
	Index(cooldown).SetSwipeColor(cooldown, r, g, b, alpha)
end

local function onSwipeColorSet(cooldown, red, _, _, alpha)
	cooldown.clusterSwipeHidden = not IsSecret(alpha) and alpha == 0;
	applySwipeTint(cooldown, not IsSecret(red) and red == LOSS_OF_CONTROL_RED)
end

local function refreshSwipeTint(button)
	applySwipeTint(button.cooldown, isClassicLockout(button.cooldown))
end

local function refreshSwipeColor(button)
	refreshSwipeTint(button)
	if button.swingCooldown then
		button.swingCooldown:SetSwipeColor(getConfiguredSwipeColor())
	end
end

local function refreshCooldownAfterCast(button)
	if button.cooldown.clusterCasting then return end;
	Index(button).UpdateAlpha(button)
end

---------------------------------------------------------------
-- Masked edges
---------------------------------------------------------------
local function setCooldownBounds(cooldown, mask)
	cooldown:ClearAllPoints()
	cooldown:SetAllPoints(mask)
end

local function setCooldownFrameLevel(cooldown, level)
	if Supports.ParentLevel then
		cooldown:SetUsingParentLevel(false)
	end
	cooldown:SetFrameLevel(level)
end

local function isGlobalCooldown(cooldown, start, duration)
	local timer = cooldown.clusterEdgeDuration;
	if timer then
		local actual = cooldown:GetParent():GetCooldownWithoutGCD();
		if actual then return actual:IsZero() end;
		start, duration = timer:GetStartTime(), timer:GetTotalDuration();
	end
	return isGlobalCooldownTiming(start, duration);
end

local function isRechargeCooldown(cooldown, start, duration)
	local charge = cooldown:GetParent():GetChargeInfo();
	if ( IsSecret(charge) or not charge ) then return false end;
	local maxCharges = charge.maxCharges;
	if ( IsSecret(maxCharges) or not maxCharges or maxCharges <= 1 ) then return false end;
	local timer = cooldown.clusterEdgeDuration;
	if timer then start, duration = timer:GetStartTime(), timer:GetTotalDuration() end;
	return matchesCooldownTiming(start, duration, charge.cooldownStartTime, charge.cooldownDuration);
end

---------------------------------------------------------------
-- @return texture : edge texture, nil for the rim shadow
-- @return gcd     : boolean, possibly secret
local function getNormalEdge(cooldown, start, duration)
	if isClassicLockout(cooldown) then
		return LOCKOUT_EDGE_TEXTURE, false;
	end

	local gcd = isGlobalCooldown(cooldown, start, duration);
	if IsSecret(gcd) then
		return nil, gcd;
	end
	if ( not gcd and isRechargeCooldown(cooldown, start, duration) ) then
		return CHARGE_EDGE_TEXTURE, false;
	end
	return nil, gcd == true;
end

local function isEdgeHidden(cooldown)
	return cooldown.clusterShowsEdge == false or cooldown.clusterSwipeHidden
		or ( cooldown.clusterCasting and not isClassicLockout(cooldown) );
end

local function updateCooldownEdge(cooldown)
	local edge, duration = cooldown.clusterEdge, cooldown.clusterEdgeDuration;
	if isEdgeHidden(cooldown) then
		if edge:IsShown() then edge:Hide() end;
		return;
	end
	local rotation;
	if duration then
		rotation = duration:EvaluateElapsedPercent(EDGE_ROTATION);
	else
		local start, total;
		if cooldown.swing then
			start, total = cooldown.swing.start * MS_PER_SECOND, cooldown.swing.duration * MS_PER_SECOND;
		else
			start, total = cooldown:GetCooldownTimes();
		end
		if ( IsSecret(start) or IsSecret(total) or not start or not total or total <= 0 ) then
			return edge:Hide();
		end
		rotation = -FULL_ROTATION * max(0, min(1, (GetTime() * MS_PER_SECOND - start) / total));
	end
	edge:SetRotation(rotation)
	edge:Show()
end

local function hideCooldownEdge(cooldown)
	cooldown.clusterEdge:Hide()
end

local function maskCooldownEdge(cooldown, parent, mask, texture)
	local edge = parent:CreateTexture(nil, parent == cooldown and 'OVERLAY' or 'ARTWORK', nil, 1);
	edge:SetAllPoints(mask)
	edge:SetTexture(texture)
	edge:AddMaskTexture(mask)
	edge:Hide()
	cooldown.clusterEdge = edge;

	cooldown:SetDrawEdge(false)
	cooldown:SetDrawBling(false)
	cooldown:HookScript('OnUpdate', updateCooldownEdge)
	cooldown:HookScript('OnHide', hideCooldownEdge)
end

local function extendCooldownEdge(cooldown, mask, scale)
	local width, height = mask:GetSize();
	if ( width <= 0 or height <= 0 ) then return end;
	local edge = cooldown.clusterEdge;
	edge:ClearAllPoints()
	edge:SetPoint('CENTER', mask, 'CENTER')
	edge:SetSize(width * scale, height * scale)
end

local function maskCooldownEdges(button, mask)
	maskCooldownEdge(button.chargeCooldown, button, mask, CHARGE_EDGE_TEXTURE)
	maskCooldownEdge(button.cooldown, button.cooldown, mask, nil)

	local lockout = button.lossOfControlCooldown;
	if lockout then
		maskCooldownEdge(lockout, lockout, mask, LOCKOUT_EDGE_TEXTURE)
	end
end

local function createRimShadow(cooldown)
	local shadow = CreateFrame('Cooldown', nil, cooldown, 'CooldownFrameTemplate');
	if Supports.ParentLevel then
		shadow:SetUsingParentLevel(true)
	else
		shadow:SetFrameLevel(cooldown:GetFrameLevel())
	end
	shadow:SetAllPoints(cooldown)
	shadow:SetHideCountdownNumbers(true)
	shadow:SetDrawEdge(false)
	shadow:SetDrawBling(false)
	shadow:SetDrawSwipe(true)
	shadow:SetAlpha(0)
	cooldown.clusterRimShadow = shadow;
end

local function initializeChargeCooldown(button)
	if not button.chargeCooldown then
		local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate');
		cooldown:SetHideCountdownNumbers(true)
		cooldown:SetDrawSwipe(false)
		cooldown:SetPoint('TOPLEFT', button.icon, 'TOPLEFT', 2, -2)
		cooldown:SetPoint('BOTTOMRIGHT', button.icon, 'BOTTOMRIGHT', -2, 2)
		cooldown:SetFrameLevel(button:GetFrameLevel())
		button.chargeCooldown = cooldown;
	end
end

---------------------------------------------------------------
local EdgeCooldown = CreateFromMixins(ProxyCooldown, {OnEdgeTimerSet = nop;});
---------------------------------------------------------------

function EdgeCooldown:SetCooldown(...)
	ProxyCooldown.SetCooldown(self, ...)
	if self.clusterEdge then
		self.clusterEdgeDuration = nil;
		self:OnEdgeTimerSet(...)
	end
end

function EdgeCooldown:Clear(...)
	ProxyCooldown.Clear(self, ...)
	local edge, shadow = self.clusterEdge, self.clusterRimShadow;
	if edge then
		self.clusterEdgeDuration = nil;
		edge:Hide()
		if shadow then shadow:Clear() end;
	end
end

function EdgeCooldown:SetDrawEdge(enabled, ...)
	if ( enabled and self.clusterEdge ) then enabled = false end;
	Index(self).SetDrawEdge(self, enabled, ...)
end

---------------------------------------------------------------
local DurationCooldown = {};
---------------------------------------------------------------

function DurationCooldown:SetCooldownFromDurationObject(...)
	Index(self).SetCooldownFromDurationObject(self, ...)
	local duration, clearIfZero = ...;
	self:GetParent():OnDurationCooldownSet(self, duration)
	if ( EDGE_ROTATION and self.clusterEdge ) then
		self.clusterEdgeDuration = duration;
		self:OnEdgeTimerSet(nil, nil, clearIfZero)
	end
end

---------------------------------------------------------------
local NormalCooldown = CreateFromMixins(EdgeCooldown, {UpdateModifierIcons = nop;});
---------------------------------------------------------------

function NormalCooldown:SetSwipeColor(...)
	Index(self).SetSwipeColor(self, ...)
	if self.clusterEdge then
		onSwipeColorSet(self, ...)
	end
end

if not CPAPI.IsModernVersion then
	function NormalCooldown:SetDrawBling(enabled, ...)
		if ( enabled and self.clusterEdge ) then enabled = false end;
		Index(self).SetDrawBling(self, enabled, ...)
	end
end

function NormalCooldown:OnEdgeTimerSet(start, duration, modRateOrClearIfZero)
	local shadow = self.clusterRimShadow;
	local texture, gcd = getNormalEdge(self, start, duration);
	local restricted = IsSecret(gcd);
	if ( restricted and not Supports.SecretGcd ) then
		gcd, restricted = true, false;
	end
	self.clusterGcd = gcd;
	self.clusterShowsEdge = texture ~= nil;
	self.clusterEdge:SetTexture(texture)
	applySwipeTint(self, isClassicLockout(self))

	if ( not texture and ( restricted or not gcd ) ) then
		local timer = self.clusterEdgeDuration;
		if timer then
			return shadow:SetCooldownFromDurationObject(timer, modRateOrClearIfZero ~= false);
		elseif hasCooldownTiming(start, duration) then
			return shadow:SetCooldown(start, duration, modRateOrClearIfZero or 1);
		end
	end
	shadow:Clear()
end

local function mixinCooldown(cooldown, mixin)
	Mixin(cooldown, mixin)
	if Supports.DurationObject then
		Mixin(cooldown, DurationCooldown)
	end
	return cooldown;
end

---------------------------------------------------------------
-- Forever swing timer
---------------------------------------------------------------
Cooldowns.WatchSwing = nop;

if SWING_TYPES then
	local MAIN_HAND, RANGED = SWING_TYPES.MainHand, SWING_TYPES.Ranged;
	local IsAttackAction, IsAutoRepeatAction = C_ActionBar.IsAttackAction, C_ActionBar.IsAutoRepeatAction;
	local IsAutoAttackSpell, IsRangedAutoAttackSpell = C_Spell.IsAutoAttackSpell, C_Spell.IsRangedAutoAttackSpell;
	local swings, latestSwingType = {};

	local SwingHandler = CPAPI.CreateEventHandler({'Frame'}, {
		'PLAYER_SWING';
		'ACTIONBAR_UPDATE_STATE';
		'PLAYER_ENTERING_WORLD';
		'PLAYER_DEAD';
		'WEAPON_SLOT_CHANGED';
	});
	SwingHandler.Buttons = {};
	SwingHandler:UnregisterAllEvents()

	local function isPublicTrue(value)
		return not IsSecret(value) and value == true;
	end

	local function getActiveSwing(swingType, now)
		local swing = swings[swingType];
		if ( swing and now - swing.start < swing.duration ) then return swing end;
	end

	local function isRangedSpellAction(actionType, id)
		return not IsSecret(actionType) and actionType == 'spell'
			and not IsSecret(id) and type(id) == 'number' and id > 0
			and isPublicTrue(IsRangedAutoAttackSpell(id));
	end

	local function getButtonSwing(button, now)
		local attack, ranged = getActiveSwing(latestSwingType, now), getActiveSwing(RANGED, now);
		if not ( attack or ranged ) then return end;
		local kind, action = button._state_type, button._state_action;
		if ( IsSecret(action) or type(action) ~= 'number' or action <= 0 ) then return end;
		if ( kind == 'action' ) then
			local isAttack = isPublicTrue(IsAttackAction(action));
			if not ( isAttack or ranged ) then return end;
			local actionType, id, subType = GetActionInfo(action);
			if ( IsSecret(subType) or subType == 'pet' ) then return end;
			if isAttack then return attack end;
			if isPublicTrue(IsAutoRepeatAction(action)) then return ranged end;
			if isRangedSpellAction(actionType, id) then return ranged end;
		elseif ( kind == 'spell' ) then
			if ( attack and isPublicTrue(IsAutoAttackSpell(action)) ) then return attack end;
			if ( ranged and isPublicTrue(IsRangedAutoAttackSpell(action)) ) then return ranged end;
		end
	end

	local function setSwingFlyout(cooldown, show)
		local button = cooldown:GetParent();
		local flag   = button.AlphaState and button.AlphaState.Swing;
		if ( flag and flag(button.alpha, show) ~= button.alpha ) then
			button:UpdateAlpha(flag, show)
		end
		button.cooldown:UpdateModifierIcons()
	end

	local function updateSwingAlpha(cooldown)
		local button  = cooldown:GetParent();
		local covered = button.cooldown.clusterCasting or isCooldownShown(button.cooldown)
			or isCooldownShown(button.lossOfControlCooldown) or isCooldownShown(button.chargeCooldown);
		local alpha = covered and 0 or 1;
		if ( cooldown:GetAlpha() == alpha ) then return end;
		cooldown:SetAlpha(alpha)
		button.cooldown:UpdateModifierIcons()
	end

	local function onSwingShow(cooldown)
		updateSwingAlpha(cooldown)
		setSwingFlyout(cooldown, true)
	end

	local function onSwingHide(cooldown)
		cooldown.swing = nil;
		if cooldown.swingBurst then cooldown.swingBurst:Stop() end;
		setSwingFlyout(cooldown, false)
	end

	local function createSwingBurst(cooldown)
		local button = cooldown:GetParent();
		local mask   = env.LIB.SkinUtility.GetIconMask(button);
		local group  = env:CreateClusterBurst(button, mask, 0.46, 0.70, 0.96);
		cooldown.swingBurst = group;
		return group;
	end

	local function createSwingCooldown(button)
		local normal   = button.cooldown;
		local mask     = env.LIB.SkinUtility.GetIconMask(button);
		local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate');
		mixinCooldown(cooldown, EdgeCooldown)
		cooldown:SetUsingParentLevel(false)
		cooldown:SetFrameLevel(normal:GetFrameLevel() - 1)
		cooldown:SetMinimumCountdownDuration(0)
		cooldown:GetCountdownFontString():SetFont(normal:GetCountdownFontString():GetFont())
		cooldown:SetHideCountdownNumbers(normal:GetHideCountdownNumbers())
		cooldown:SetDrawSwipe(true)
		cooldown:SetSwipeTexture(button.swingSwipeTexture, getConfiguredSwipeColor())
		setCooldownBounds(cooldown, mask)
		maskCooldownEdge(cooldown, cooldown, mask, SWING_EDGE_TEXTURE)
		extendCooldownEdge(cooldown, mask, SWING_EDGE_SCALE)
		cooldown.clusterEdge:SetBlendMode('ADD')
		cooldown:HookScript('OnUpdate', updateSwingAlpha)
		cooldown:HookScript('OnShow', onSwingShow)
		cooldown:HookScript('OnHide', onSwingHide)
		cooldown:SetScript('OnCooldownDone', cooldown.Hide)
		button.swingCooldown = cooldown;
		return cooldown;
	end

	local function refreshSwing(button)
		if not ( button.swingSwipeTexture and button:IsVisible() ) then return end;
		local now = GetTime();
		local swing, cooldown = getButtonSwing(button, now), button.swingCooldown;
		if not swing then
			if cooldown then cooldown:Hide() end;
			return;
		end
		cooldown = cooldown or createSwingCooldown(button);
		if ( cooldown.swing ~= swing ) then
			local elapsed = now - swing.start;
			local burst   = cooldown.swingBurst;
			if burst then burst:Stop() end;
			cooldown:SetCooldown(swing.start, swing.duration)
			cooldown.swing = swing;
			cooldown:Show()
			if ( elapsed < SWING_BURST_DURATION ) then
				burst = burst or createSwingBurst(cooldown);
				burst:GetParent():Show()
				burst:Play(false, elapsed)
			end
		end
	end

	local function refreshSwingButtons()
		env:Map(CLUSTER_BUTTON, nil, refreshSwing)
	end

	local function forgetSwings()
		latestSwingType = nil;
		wipe(swings)
	end

	local function onSwingButtonShow(button)
		SwingHandler:TrackButton(button, true)
		refreshSwing(button)
	end

	local function onSwingButtonHide(button)
		SwingHandler:TrackButton(button, false)
	end

	function NormalCooldown:SetHideCountdownNumbers(hide, ...)
		Index(self).SetHideCountdownNumbers(self, hide, ...)
		local swing = self:GetParent().swingCooldown;
		if swing then
			swing:SetHideCountdownNumbers(hide)
		end
	end

	function SwingHandler:TrackButton(button, visible)
		local buttons     = self.Buttons;
		local wasTracking = next(buttons) ~= nil;
		buttons[button]   = visible or nil;
		local isTracking  = next(buttons) ~= nil;
		if ( wasTracking == isTracking ) then return end;
		if isTracking then
			CPAPI.RegisterFrameForEvents(self, self.Events)
		else
			self:UnregisterAllEvents()
		end
	end

	function SwingHandler:PLAYER_SWING(duration, swingType)
		if ( IsSecret(swingType) or ( swingType ~= MAIN_HAND and swingType ~= RANGED ) ) then return end;
		if ( IsSecret(duration) or not duration or duration <= 0 ) then return end;
		swings[swingType] = {start = GetTime(); duration = duration;};
		latestSwingType = swingType;
		refreshSwingButtons()
	end

	function SwingHandler:ACTIONBAR_UPDATE_STATE()
		refreshSwingButtons()
	end

	function SwingHandler:PLAYER_ENTERING_WORLD()
		forgetSwings()
		refreshSwingButtons()
	end

	SwingHandler.PLAYER_DEAD         = SwingHandler.PLAYER_ENTERING_WORLD;
	SwingHandler.WEAPON_SLOT_CHANGED = SwingHandler.PLAYER_ENTERING_WORLD;

	function Cooldowns:WatchSwing()
		hooksecurefunc(self, 'UpdateAction', refreshSwing)
		hooksecurefunc(self, 'OnActionBarSlotChanged', refreshSwing)
		self:HookScript('OnShow', onSwingButtonShow)
		self:HookScript('OnHide', onSwingButtonHide)
		if self:IsVisible() then
			SwingHandler:TrackButton(self, true)
		end
	end
end

---------------------------------------------------------------
-- Button interface
---------------------------------------------------------------
function Cooldowns:InitializeCooldowns()
	resolveWidgetSupport(self)
	initializeChargeCooldown(self)
	if ( HAS_FOREVER_LOCKOUT and self.lossOfControlCooldown ) then
		self.GetLoCCooldownInfo = getForeverLossOfControlInfo;
	end
	self.clusterCooldowns = {self.cooldown; self.chargeCooldown; self.lossOfControlCooldown;};
	mixinCooldown(self.cooldown, NormalCooldown)
	mixinCooldown(self.chargeCooldown, EdgeCooldown)
	if self.lossOfControlCooldown then
		mixinCooldown(self.lossOfControlCooldown, EdgeCooldown)
	end
	self:WatchSwing()
end

function Cooldowns:WatchCooldownVisibility()
	watchCooldownVisibility(self.cooldown)
	watchCooldownVisibility(self.chargeCooldown)
	if self.lossOfControlCooldown then
		watchCooldownVisibility(self.lossOfControlCooldown)
	end
end

function Cooldowns:LayoutCooldowns(mask, edgeScale, maskShape)
	local cooldown = self.cooldown;
	setCooldownBounds(cooldown, mask)
	if self.lossOfControlCooldown then
		setCooldownBounds(self.lossOfControlCooldown, mask)
	end
	if not cooldown.clusterEdge then
		createRimShadow(cooldown)
		maskCooldownEdges(self, mask)
	end
	local shadowTexture = COOLDOWN_SHADOW_PATH:format(maskShape);
	cooldown.clusterRimShadow:SetSwipeTexture(shadowTexture, 0, 0, 0, COOLDOWN_SHADOW_ALPHA)
	if edgeScale then
		for _, timer in ipairs(self.clusterCooldowns) do
			extendCooldownEdge(timer, mask, edgeScale)
		end
	end
	if self.swingCooldown then
		extendCooldownEdge(self.swingCooldown, mask, SWING_EDGE_SCALE)
	end
end

function Cooldowns:SetCooldownFrameLevel(level)
	setCooldownFrameLevel(self.cooldown, level)
	if self.lossOfControlCooldown then
		setCooldownFrameLevel(self.lossOfControlCooldown, level)
	end
end

function Cooldowns:SetCooldownSwipeTexture(texture)
	local normal, lockout = self.cooldown, self.lossOfControlCooldown;
	normal:SetSwipeTexture(texture)
	applySwipeTint(normal, isClassicLockout(normal))
	if lockout then
		lockout:SetSwipeTexture(texture, getSwipeTint(lockout, true))
	end
	if SWING_TYPES then
		self.swingSwipeTexture = texture;
		if self.swingCooldown then
			self.swingCooldown:SetSwipeTexture(texture, getConfiguredSwipeColor())
		end
	end
end

function Cooldowns:SetCastingSwipe(casting)
	local cooldown   = self.cooldown;
	local wasCasting = cooldown.clusterCasting;
	cooldown.clusterCasting = casting;
	applySwipeTint(cooldown, isClassicLockout(cooldown))
	if ( wasCasting and not casting ) then
		Next(refreshCooldownAfterCast, self)
	end
end

function Cooldowns:HasVisibleCooldownNumbers()
	local normal, swing = self.cooldown, self.swingCooldown;
	local enabled;
	if Supports.NumberGetter then
		enabled = not normal:GetHideCountdownNumbers();
	else
		enabled = GetCVarBool('countdownForCooldowns');
	end
	return enabled and ( isCooldownShown(normal) or ( isCooldownShown(swing) and swing:GetAlpha() > 0 ) );
end

function Cooldowns:GetCooldownWithoutGCD()
	local kind, action = self._state_type, self._state_action;
	if ( kind == 'action' ) then
		return GetActionCooldownDuration(action, true);
	elseif ( kind == 'spell' ) then
		return GetSpellCooldownDuration(action, true);
	end
end

---------------------------------------------------------------
-- Cooldown frame notifications
---------------------------------------------------------------
function Cooldowns:OnCooldownSet(cooldown, start, duration)
	if ( cooldown.flyoutWatched and cooldown == self.cooldown ) then
		setNumericFlyoutTimer(cooldown, start, duration)
	end
end

function Cooldowns:OnDurationCooldownSet(cooldown, duration)
	if not cooldown.flyoutWatched then return end;
	cooldown.flyoutTimerSet = true;
	if ( cooldown == self.cooldown ) then
		local ready = isItemFlyoutReady(self);
		if ( ready ~= nil ) then
			cooldown.flyoutCooldownZero = ready;
			return queueCooldownVisibility(cooldown);
		end
		local actual = self:GetCooldownWithoutGCD();
		if actual then
			local zero = actual:IsZero();
			if ( Supports.SecretAlpha or not IsSecret(zero) ) then
				cooldown.flyoutCooldownZero = zero;
				return queueCooldownVisibility(cooldown);
			end
		end
		if not duration:HasSecretValues() then
			return setNumericFlyoutTimer(cooldown, duration:GetStartTime(), duration:GetTotalDuration());
		end
		cooldown.flyoutCooldownZero = nil;
	end
	queueCooldownVisibility(cooldown)
end

function Cooldowns:OnCooldownClear(cooldown)
	if not cooldown.flyoutWatched then return end;
	clearFlyoutTimer(cooldown)
	queueCooldownVisibility(cooldown)
end

---------------------------------------------------------------
-- Settings
---------------------------------------------------------------
local function onSwipeColorSetting()
	env:Map(CLUSTER_BUTTON, nil, refreshSwipeColor)
end

local function onGcdSwipeColorSetting()
	env:Map(CLUSTER_BUTTON, nil, refreshSwipeTint)
end

env:RegisterCallback('Settings/clusterSwipeColor', onSwipeColorSetting, Cooldowns)
env:RegisterCallback('Settings/clusterGcdSwipeColor', onGcdSwipeColorSetting, Cooldowns)
