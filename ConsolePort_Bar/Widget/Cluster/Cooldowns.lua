local env = CPAPI.GetEnv(...)
---------------------------------------------------------------
local _, _, CLUSTER_BUTTON = env.Const.Cluster.Types();
local Cooldowns = {}; env.ClusterCooldownMixin = Cooldowns;
---------------------------------------------------------------
local SHORT_COOLDOWN_LIMIT = 2; -- Ignore GCD-length numeric timers when the client cannot separate them.
local LOSS_OF_CONTROL_RED   = 0.17; -- LAB uses this red channel for the Classic lockout swipe.
local LOCKOUT_EDGE_TEXTURE = CPAPI.IsModernVersion and [[Interface\Cooldown\UI-HUD-ActionBar-LoC]]
	or [[Interface\Cooldown\edge-LoC]];
local CHARGE_EDGE_TEXTURE  = env.GetAsset[[Textures\Cluster\ChargeEdge.png]];
local COOLDOWN_SHADOW_PATH = [[Textures\Masks\CooldownShadows\%s.png]];
local COOLDOWN_SHADOW_ALPHA = .81; -- Fixed black rim opacity. The texture supplies its inward falloff.
local COOLDOWN_SWIPE_SCALE  = .50 / (163 / 255); -- 50% at the default swipe opacity.
-- Query the client's GCD reference spell to classify numeric timers.
local GCD_SPELL_ID         = (CPAPI.IsAnniVersion or CPAPI.IsClassicEraVersion or CPAPI.IsWrathVersion) and 29515 or 61304;
local FULL_ROTATION        = 2 * math.pi;
local SWING_EDGE_TEXTURE   = env.GetAsset[[Textures\Cluster\SwingEdge.png]];
local SWING_EDGE_SCALE     = 1.26; -- Extend the steel-blue streak to the rim before clipping.
local swingTypes           = CPAPI.IsCamelotVersion and C_SwingTimer and CPAPI.IsEventValid('PLAYER_SWING')
	and Enum.PlayerSwingType;
local selectSwipeColor     = C_CurveUtil and C_CurveUtil.EvaluateColorFromBoolean;
local edgeRotation         = C_CurveUtil and C_CurveUtil.CreateCurve and C_CurveUtil.CreateCurve();
if edgeRotation then
	edgeRotation:AddPoint(0, 0)
	edgeRotation:AddPoint(1, -FULL_ROTATION)
end

---------------------------------------------------------------
-- Timer setup and flyout visibility
---------------------------------------------------------------

local function isCooldownShown(cooldown)
	local shown = cooldown and cooldown:IsShown();
	return not CPAPI.IsSecret(shown) and shown;
end

function Cooldowns:HasVisibleCooldownNumbers()
	local normal, swing = self.cooldown, self.swingCooldown;
	local enabled;
	if normal.GetHideCountdownNumbers then
		enabled = not normal:GetHideCountdownNumbers();
	else
		enabled = GetCVarBool('countdownForCooldowns');
	end
	return enabled and (isCooldownShown(normal) or (isCooldownShown(swing) and swing:GetAlpha() > 0));
end

local function getForeverLossOfControlInfo(button)
	if button._state_type == 'action' then
		return C_ActionBar.GetActionLossOfControlCooldownInfo(button._state_action);
	end
	return CPAPI.Index(button).GetLoCCooldownInfo(button);
end

function Cooldowns:GetCooldownWithoutGCD()
	local kind, action = self._state_type, self._state_action;
	if ( kind == 'action' and C_ActionBar and C_ActionBar.GetActionCooldownDuration ) then
		return C_ActionBar.GetActionCooldownDuration(action, true);
	elseif ( kind == 'spell' and C_Spell and C_Spell.GetSpellCooldownDuration ) then
		return C_Spell.GetSpellCooldownDuration(action, true);
	end
end

local function timerCanReveal(cooldown)
	if not cooldown then return false end;
	local shown = cooldown:IsShown();
	if CPAPI.IsSecret(shown) then return cooldown.flyoutTimerSet end;
	return shown;
end

local function updateCooldownVisibility(button)
	button.cooldownVisibilityPending = nil;
	local normal = button.cooldown;
	local wasRestricted = CPAPI.IsSecret(button.flyoutCooldownZero);
	local zero = normal.flyoutCooldownZero;
	local restricted = CPAPI.IsSecret(zero);
	local show = timerCanReveal(button.chargeCooldown) or timerCanReveal(button.lossOfControlCooldown);
	button.flyoutCooldownZero = nil;
	if timerCanReveal(normal) then
		if restricted then
			-- The native alpha setter can display this slot's cooldown even during combat.
			button.flyoutCooldownZero = zero;
		elseif zero == false then
			show = true;
		end
	end
	local flag = button.AlphaState.OnCooldown;
	if flag(button.alpha, show) ~= button.alpha or (button.alpha == 0 and (wasRestricted or restricted)) then
		button:UpdateAlpha(flag, show)
	end
end

local function queueCooldownVisibility(cooldown)
	local button = cooldown:GetParent();
	if button.cooldownVisibilityPending then return end;
	button.cooldownVisibilityPending = true;
	-- LAB updates the three timers in sequence. Check visibility after all three settle.
	CPAPI.Next(updateCooldownVisibility, button)
end

local function isClassicLockout(cooldown)
	return COOLDOWN_TYPE_LOSS_OF_CONTROL and cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL;
end

local function onNumericCooldownSet(cooldown, _, duration)
	local longCooldown = not CPAPI.IsSecret(duration) and duration > SHORT_COOLDOWN_LIMIT;
	cooldown.flyoutCooldownZero = not (longCooldown or isClassicLockout(cooldown));
	queueCooldownVisibility(cooldown)
end

local function hasCooldownTiming(start, duration)
	return not CPAPI.IsSecret(start) and not CPAPI.IsSecret(duration)
		and start and duration and start > 0 and duration > 0;
end

local function matchesCooldownTiming(start, duration, otherStart, otherDuration)
	-- The action and spell APIs report seconds. Allow a millisecond of rounding in either timestamp.
	return hasCooldownTiming(start, duration) and hasCooldownTiming(otherStart, otherDuration)
		and math.abs(start - otherStart) <= 0.001 and math.abs(duration - otherDuration) <= 0.001;
end

local function matchesGlobalCooldown(start, duration)
	if not hasCooldownTiming(start, duration) then return false end;

	-- Compare the actual timer on clients that expose numeric cooldowns.
	local gcdStart, gcdDuration;
	if C_Spell and C_Spell.GetSpellCooldown then
		local gcd = C_Spell.GetSpellCooldown(GCD_SPELL_ID);
		if not CPAPI.IsSecret(gcd) and gcd then
			gcdStart, gcdDuration = gcd.startTime, gcd.duration;
		end
	elseif GetSpellCooldown then
		gcdStart, gcdDuration = GetSpellCooldown(GCD_SPELL_ID);
	end
	if CPAPI.IsSecret(gcdStart) or CPAPI.IsSecret(gcdDuration) or not gcdStart or not gcdDuration then return end;
	return matchesCooldownTiming(start, duration, gcdStart, gcdDuration);
end

local function isItemFlyoutReady(button)
	if not (C_Item and C_Item.GetItemCooldown) then return end;
	local kind, item = button._state_type, button._state_action;
	if CPAPI.IsSecret(item) then return end;
	if kind == 'action' then
		local actionType, id, subType = GetActionInfo(item);
		if CPAPI.IsSecret(actionType) or CPAPI.IsSecret(subType) then return end;
		if actionType ~= 'item' and actionType ~= 'toy' and not (actionType == 'macro' and subType == 'item') then return end;
		item = id;
	elseif kind ~= 'item' then
		return;
	end
	if CPAPI.IsSecret(item) or not item then return end;
	-- An item slot can show a swipe for another spell's GCD. Only the item's own timer reveals the flyout.
	local start, duration, enabled = C_Item.GetItemCooldown(item);
	if CPAPI.IsSecret(start) or CPAPI.IsSecret(duration) or CPAPI.IsSecret(enabled) or not duration then return end;
	if not enabled or not hasCooldownTiming(start, duration) or start + duration <= GetTime() then return true end;
	-- If the GCD timestamps are restricted, keep ambiguous short item swipes faded.
	return duration <= SHORT_COOLDOWN_LIMIT and matchesGlobalCooldown(start, duration) ~= false;
end

local function onDurationCooldownSet(cooldown, duration)
	local button = cooldown:GetParent();
	-- LAB sets duration objects only for active timers and clears them when inactive.
	cooldown.flyoutTimerSet = true;
	if cooldown == button.cooldown then
		local ready = isItemFlyoutReady(button);
		if ready ~= nil then
			cooldown.flyoutCooldownZero = ready;
			return queueCooldownVisibility(cooldown);
		end
		local actual = button:GetCooldownWithoutGCD();
		if actual then
			local zero = actual:IsZero();
			if button.SetAlphaFromBoolean or not CPAPI.IsSecret(zero) then
				cooldown.flyoutCooldownZero = zero;
				return queueCooldownVisibility(cooldown);
			end
		end
		if not duration:HasSecretValues() then
			return onNumericCooldownSet(cooldown, nil, duration:GetTotalDuration());
		end
		cooldown.flyoutCooldownZero = nil;
	end
	queueCooldownVisibility(cooldown)
end

local function onCooldownCleared(cooldown)
	cooldown.flyoutTimerSet, cooldown.flyoutCooldownZero = nil, nil;
	queueCooldownVisibility(cooldown)
end

local function watchCooldownVisibility(cooldown)
	cooldown:HookScript('OnShow', queueCooldownVisibility)
	cooldown:HookScript('OnHide', queueCooldownVisibility)
	cooldown:HookScript('OnCooldownDone', onCooldownCleared)
	hooksecurefunc(cooldown, 'Clear', onCooldownCleared)
	if cooldown.SetCooldownFromDurationObject then
		hooksecurefunc(cooldown, 'SetCooldownFromDurationObject', onDurationCooldownSet)
	end
end

local function initializeChargeCooldown(button)
	if not button.chargeCooldown then
		-- On Classic, use LAB's native layout so the first recharge can be masked.
		local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate');
		cooldown:SetHideCountdownNumbers(true)
		cooldown:SetDrawSwipe(false)
		cooldown:SetPoint('TOPLEFT', button.icon, 'TOPLEFT', 2, -2)
		cooldown:SetPoint('BOTTOMRIGHT', button.icon, 'BOTTOMRIGHT', -2, 2)
		cooldown:SetFrameLevel(button:GetFrameLevel())
		button.chargeCooldown = cooldown;
	end
end

function Cooldowns:InitializeCooldowns()
	initializeChargeCooldown(self)
	-- LAB skips action-slot lockouts on Forever, where current clients supply them.
	if ( CPAPI.IsCamelotVersion and self.lossOfControlCooldown and C_ActionBar
		and C_ActionBar.GetActionLossOfControlCooldownInfo and C_ActionBar.GetActionLossOfControlCooldownDuration ) then
		self.GetLoCCooldownInfo = getForeverLossOfControlInfo;
	end
	self.clusterCooldowns = {self.cooldown; self.chargeCooldown; self.lossOfControlCooldown;};
	if swingTypes then self:WatchSwing() end;
end

function Cooldowns:WatchCooldownVisibility()
	watchCooldownVisibility(self.cooldown)
	watchCooldownVisibility(self.chargeCooldown)
	if self.lossOfControlCooldown then
		watchCooldownVisibility(self.lossOfControlCooldown)
	end
	hooksecurefunc(self.cooldown, 'SetCooldown', onNumericCooldownSet)
end

---------------------------------------------------------------
-- Swipe tint and masked edges
---------------------------------------------------------------

local function isSwipeHidden(cooldown, isLossOfControl)
	return cooldown.clusterSwipeHidden or (cooldown.clusterCasting and not isLossOfControl);
end

local function getConfiguredSwipeColor()
	return env:GetColorRGBA('clusterSwipeColor');
end

local function getSwipeTint(cooldown, isLossOfControl)
	if isSwipeHidden(cooldown, isLossOfControl) then return 0, 0, 0, 0 end;
	-- Lockouts keep LAB's dark red at 64% opacity across designs.
	if isLossOfControl then return LOSS_OF_CONTROL_RED, 0, 0, 0.64 end;
	return getConfiguredSwipeColor();
end

local function applySwipeTint(cooldown, isLossOfControl)
	local r, g, b, alpha = getSwipeTint(cooldown, isLossOfControl);
	local shadow = cooldown.clusterRimShadow;
	if shadow then
		local gcd = cooldown.clusterGcd;
		if isLossOfControl or isSwipeHidden(cooldown, isLossOfControl) or cooldown.clusterShowsEdge then
			shadow:SetAlpha(0)
		elseif CPAPI.IsSecret(gcd) then
			local color = selectSwipeColor(gcd, env:GetColor('clusterGcdSwipeColor'),
				CreateColor(r, g, b, alpha * COOLDOWN_SWIPE_SCALE));
			r, g, b, alpha = color:GetRGBA();
			shadow:SetAlphaFromBoolean(gcd, 0, 1)
		elseif gcd == false then
			shadow:SetAlpha(1)
			alpha = alpha * COOLDOWN_SWIPE_SCALE;
		else
			if gcd then r, g, b, alpha = env:GetColorRGBA('clusterGcdSwipeColor') end;
			shadow:SetAlpha(0)
		end
	end
	-- Call the native method directly to avoid invoking the LAB color hook again.
	CPAPI.Index(cooldown).SetSwipeColor(cooldown, r, g, b, alpha)
end

local function onSwipeColorChanged(cooldown, red, _, _, alpha)
	cooldown.clusterSwipeHidden = alpha == 0;
	-- Classic LAB sets the lockout red before updating the cooldown type.
	applySwipeTint(cooldown, red == LOSS_OF_CONTROL_RED)
end

local function refreshCooldownAfterCast(button)
	if button.cooldown.clusterCasting then return end;
	-- LAB's base UpdateAlpha refreshes the timers, while flyouts override it for fading.
	CPAPI.Index(button).UpdateAlpha(button)
end

function Cooldowns:SetCastingSwipe(casting)
	local cooldown = self.cooldown;
	local wasCasting = cooldown.clusterCasting;
	cooldown.clusterCasting = casting;
	applySwipeTint(cooldown, isClassicLockout(cooldown))
	if wasCasting and not casting then
		CPAPI.Next(refreshCooldownAfterCast, self)
	end
end

local function setCooldownBounds(cooldown, mask)
	cooldown:ClearAllPoints()
	cooldown:SetAllPoints(mask)
end

local function isGlobalCooldown(cooldown, start, duration)
	local timer = cooldown.clusterEdgeDuration;
	if timer then
		local actual = cooldown:GetParent():GetCooldownWithoutGCD();
		if actual then return actual:IsZero() end;
		start, duration = timer:GetStartTime(), timer:GetTotalDuration();
	end
	return matchesGlobalCooldown(start, duration);
end

local function isRechargeCooldown(cooldown, start, duration)
	-- When all charges are spent, the normal timer can represent the same recharge.
	local charge = cooldown:GetParent():GetChargeInfo();
	if CPAPI.IsSecret(charge) or not charge then return false end;
	local maxCharges = charge.maxCharges;
	if CPAPI.IsSecret(maxCharges) or not maxCharges or maxCharges <= 1 then return false end;
	local timer = cooldown.clusterEdgeDuration;
	if timer then start, duration = timer:GetStartTime(), timer:GetTotalDuration() end;
	return matchesCooldownTiming(start, duration, charge.cooldownStartTime, charge.cooldownDuration);
end

local function getNormalEdge(cooldown, start, duration)
	if isClassicLockout(cooldown) then
		return LOCKOUT_EDGE_TEXTURE, false;
	end

	local gcd = isGlobalCooldown(cooldown, start, duration);
	if CPAPI.IsSecret(gcd) then
		return nil, gcd;
	end
	if not gcd and isRechargeCooldown(cooldown, start, duration) then
		return CHARGE_EDGE_TEXTURE, false;
	end
	return nil, gcd == true;
end

local function setNormalEdge(cooldown, start, duration, modRateOrClearIfZero)
	local shadow = cooldown.clusterRimShadow;
	local texture, gcd = getNormalEdge(cooldown, start, duration);
	local restricted = CPAPI.IsSecret(gcd);
	if restricted and not (selectSwipeColor and shadow.SetAlphaFromBoolean) then
		gcd, restricted = true, false;
	end
	cooldown.clusterGcd = gcd;
	cooldown.clusterShowsEdge = texture ~= nil;
	cooldown.clusterEdge:SetTexture(texture)
	applySwipeTint(cooldown, isClassicLockout(cooldown))

	if not texture and (restricted or not gcd) then
		local timer = cooldown.clusterEdgeDuration;
		if timer then
			return shadow:SetCooldownFromDurationObject(timer, modRateOrClearIfZero ~= false);
		elseif hasCooldownTiming(start, duration) then
			return shadow:SetCooldown(start, duration, modRateOrClearIfZero or 1);
		end
	end
	shadow:Clear()
end

local function updateCooldownEdge(cooldown)
	local edge, duration = cooldown.clusterEdge, cooldown.clusterEdgeDuration;
	if cooldown.clusterShowsEdge == false or isSwipeHidden(cooldown, isClassicLockout(cooldown)) then
		if edge:IsShown() then edge:Hide() end;
		return;
	end
	local rotation;
	if duration then
		rotation = duration:EvaluateElapsedPercent(edgeRotation);
	else
		local start, total;
		if cooldown.swing then
			start, total = cooldown.swing.start * 1000, cooldown.swing.duration * 1000;
		else
			start, total = cooldown:GetCooldownTimes();
		end
		if CPAPI.IsSecret(start) or CPAPI.IsSecret(total) or not start or not total or total <= 0 then
			return edge:Hide();
		end
		-- The numeric API reports milliseconds. One elapsed fraction turns the edge clockwise through a full circle.
		rotation = -FULL_ROTATION * math.max(0, math.min(1, (GetTime() * 1000 - start) / total));
	end
	edge:SetRotation(rotation)
	edge:Show()
end

local function hideCooldownEdge(cooldown)
	cooldown.clusterEdge:Hide()
end

local function maskCooldownEdge(cooldown, parent, mask, texture, setEdge)
	local edge = parent:CreateTexture(nil, parent == cooldown and 'OVERLAY' or 'ARTWORK', nil, 1);
	edge:SetAllPoints(mask)
	edge:SetTexture(texture)
	edge:AddMaskTexture(mask)
	edge:Hide()
	cooldown.clusterEdge = edge;

	-- Keep LAB's timer and use the stock edge art on a maskable texture.
	cooldown:SetDrawEdge(false)
	cooldown:SetDrawBling(false)
	hooksecurefunc(cooldown, 'SetDrawEdge', function(frame, enabled)
		if enabled then frame:SetDrawEdge(false) end;
	end)
	cooldown:HookScript('OnUpdate', updateCooldownEdge)
	cooldown:HookScript('OnHide', hideCooldownEdge)
	hooksecurefunc(cooldown, 'Clear', function(frame)
		frame.clusterEdgeDuration = nil;
		hideCooldownEdge(frame)
		if frame.clusterRimShadow then frame.clusterRimShadow:Clear() end;
	end)
	hooksecurefunc(cooldown, 'SetCooldown', function(frame, start, duration, modRate)
		frame.clusterEdgeDuration = nil;
		if setEdge then setEdge(frame, start, duration, modRate) end;
	end)
	if edgeRotation and cooldown.SetCooldownFromDurationObject then
		hooksecurefunc(cooldown, 'SetCooldownFromDurationObject', function(frame, duration, clearIfZero)
			frame.clusterEdgeDuration = duration;
			if setEdge then setEdge(frame, nil, nil, clearIfZero) end;
		end)
	end
end

local function extendCooldownEdge(cooldown, mask, scale)
	-- The streak fades before the texture ends. Extend it past the inner
	-- rim so the mask can clip it cleanly, even near the square corners.
	local width, height = mask:GetSize();
	if width <= 0 or height <= 0 then return end;
	local edge = cooldown.clusterEdge;
	edge:ClearAllPoints()
	edge:SetPoint('CENTER', mask, 'CENTER')
	edge:SetSize(width * scale, height * scale)
end

local function maskCooldownEdges(button, mask)
	maskCooldownEdge(button.chargeCooldown, button, mask, CHARGE_EDGE_TEXTURE)
	maskCooldownEdge(button.cooldown, button.cooldown, mask, nil, setNormalEdge)

	local lockout = button.lossOfControlCooldown;
	if lockout then
		maskCooldownEdge(lockout, lockout, mask, LOCKOUT_EDGE_TEXTURE)
	end
	hooksecurefunc(button.cooldown, 'SetSwipeColor', onSwipeColorChanged)

	if not CPAPI.IsModernVersion then
		-- Classic LAB re-enables bling when refreshing the normal timer.
		hooksecurefunc(button.cooldown, 'SetDrawBling', function(cooldown, enabled)
			if enabled then cooldown:SetDrawBling(false) end;
		end)
	end
end

-- Regular cooldown rim shadow. A native swipe clips the inward fade to the remaining sector.
local function createRimShadow(cooldown)
	local shadow = CreateFrame('Cooldown', nil, cooldown, 'CooldownFrameTemplate');
	if shadow.SetUsingParentLevel then
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

function Cooldowns:SetCooldownSwipeTexture(texture)
	local normal, lockout = self.cooldown, self.lossOfControlCooldown;
	normal:SetSwipeTexture(texture)
	applySwipeTint(normal, isClassicLockout(normal))
	if lockout then
		lockout:SetSwipeTexture(texture, getSwipeTint(lockout, true))
	end
	if swingTypes then
		self.swingSwipeTexture = texture;
		if self.swingCooldown then
			self.swingCooldown:SetSwipeTexture(texture, getConfiguredSwipeColor())
		end
	end
end

function Cooldowns:SetCooldownFrameLevel(level)
	for _, cooldown in ipairs({self.cooldown; self.lossOfControlCooldown;}) do
		if cooldown.SetUsingParentLevel then
			cooldown:SetUsingParentLevel(false)
		end
		cooldown:SetFrameLevel(level)
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
	cooldown.clusterRimShadow:SetSwipeTexture(env.GetAsset(COOLDOWN_SHADOW_PATH, maskShape), 0, 0, 0, COOLDOWN_SHADOW_ALPHA)
	if edgeScale then
		for _, cooldown in ipairs(self.clusterCooldowns) do
			extendCooldownEdge(cooldown, mask, edgeScale)
		end
	end
	if self.swingCooldown then
		extendCooldownEdge(self.swingCooldown, mask, SWING_EDGE_SCALE)
	end
end

local function refreshSwipeTint(button)
	applySwipeTint(button.cooldown, isClassicLockout(button.cooldown))
end

env:RegisterCallback('Settings/clusterSwipeColor', function()
	env:Map(CLUSTER_BUTTON, nil, function(button)
		refreshSwipeTint(button)
		if button.swingCooldown then
			button.swingCooldown:SetSwipeColor(getConfiguredSwipeColor())
		end
	end)
end)

env:RegisterCallback('Settings/clusterGcdSwipeColor', function()
	env:Map(CLUSTER_BUTTON, nil, refreshSwipeTint)
end)

---------------------------------------------------------------
-- Forever swing timer
---------------------------------------------------------------
if not swingTypes then return end;

local SwingHandler, latestSwingType;
local swings = {};
local MAIN_HAND, RANGED = swingTypes.MainHand, swingTypes.Ranged;
local SWING_BURST_DURATION = env.ClusterBurstDuration;

local function isPublicTrue(value)
	return not CPAPI.IsSecret(value) and value == true;
end

local function getActiveSwing(swingType, now)
	local swing = swings[swingType];
	if swing and now - swing.start < swing.duration then return swing end;
end

local function getButtonSwing(button, now)
	-- Attack follows the latest swing type. Auto Shot always uses the ranged timer.
	local attack, ranged = getActiveSwing(latestSwingType, now), getActiveSwing(RANGED, now);
	if not (attack or ranged) then return end;
	local kind, action = button._state_type, button._state_action;
	if CPAPI.IsSecret(action) or type(action) ~= 'number' or action <= 0 then return end;
	if kind == 'action' then
		local isAttack = isPublicTrue(C_ActionBar.IsAttackAction(action));
		if not (isAttack or ranged) then return end;
		-- Blizzard's attack predicate includes pet commands placed on player bars.
		local actionType, id, subType = GetActionInfo(action);
		if CPAPI.IsSecret(subType) or subType == 'pet' then return end;
		if isAttack then return attack end;
		if isPublicTrue(C_ActionBar.IsAutoRepeatAction(action)) then return ranged end;
		if not CPAPI.IsSecret(actionType) and actionType == 'spell'
			and not CPAPI.IsSecret(id) and type(id) == 'number' and id > 0
			and isPublicTrue(C_Spell.IsRangedAutoAttackSpell(id)) then
			return ranged;
		end
	elseif kind == 'spell' then
		if attack and isPublicTrue(C_Spell.IsAutoAttackSpell(action)) then return attack end;
		if ranged and isPublicTrue(C_Spell.IsRangedAutoAttackSpell(action)) then return ranged end;
	end
end

local function updateSwingModifierIcons(button)
	if button.cooldown.UpdateModifierIcons then
		button.cooldown:UpdateModifierIcons()
	end
end

local function setSwingFlyout(cooldown, show)
	local button = cooldown:GetParent();
	local flag   = button.AlphaState and button.AlphaState.Swing;
	if flag and flag(button.alpha, show) ~= button.alpha then
		button:UpdateAlpha(flag, show)
	end
	updateSwingModifierIcons(button)
end

local function updateSwingAlpha(cooldown)
	local button = cooldown:GetParent();
	local covered = button.cooldown.clusterCasting or isCooldownShown(button.cooldown)
		or isCooldownShown(button.lossOfControlCooldown) or isCooldownShown(button.chargeCooldown);
	local alpha = covered and 0 or 1;
	if cooldown:GetAlpha() == alpha then return end;
	cooldown:SetAlpha(alpha)
	updateSwingModifierIcons(button)
end

local function createSwingBurst(cooldown)
	local button = cooldown:GetParent();
	local mask   = env.LIB.SkinUtility.GetIconMask(button);
	-- The steel-blue burst matches the swing streak. Keep it visible below the rim while a GCD hides the timer.
	local group = env:CreateClusterBurst(button, mask, .46, .70, .96);
	cooldown.swingBurst = group;
	return group;
end

local function createSwingCooldown(button)
	local normal   = button.cooldown;
	local mask     = env.LIB.SkinUtility.GetIconMask(button);
	local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate');
	cooldown:SetUsingParentLevel(false)
	cooldown:SetFrameLevel(normal:GetFrameLevel() - 1)
	cooldown:SetMinimumCountdownDuration(0)
	cooldown:GetCountdownFontString():SetFont(normal:GetCountdownFontString():GetFont())
	cooldown:SetHideCountdownNumbers(normal:GetHideCountdownNumbers())
	hooksecurefunc(normal, 'SetHideCountdownNumbers', function(_, hide)
		cooldown:SetHideCountdownNumbers(hide)
	end)
	cooldown:SetDrawSwipe(true)
	cooldown:SetSwipeTexture(button.swingSwipeTexture, getConfiguredSwipeColor())
	setCooldownBounds(cooldown, mask)
	maskCooldownEdge(cooldown, cooldown, mask, SWING_EDGE_TEXTURE)
	extendCooldownEdge(cooldown, mask, SWING_EDGE_SCALE)
	cooldown.clusterEdge:SetBlendMode('ADD')
	cooldown:HookScript('OnUpdate', updateSwingAlpha)
	cooldown:HookScript('OnShow', function(frame)
		updateSwingAlpha(frame)
		setSwingFlyout(frame, true)
	end)
	cooldown:HookScript('OnHide', function(frame)
		frame.swing = nil;
		if frame.swingBurst then frame.swingBurst:Stop() end;
		setSwingFlyout(frame, false)
	end)
	cooldown:SetScript('OnCooldownDone', cooldown.Hide)
	button.swingCooldown = cooldown;
	return cooldown;
end

local function refreshSwing(button)
	if not (button.swingSwipeTexture and button:IsVisible()) then return end;
	local now = GetTime();
	local swing, cooldown = getButtonSwing(button, now), button.swingCooldown;
	if not swing then
		if cooldown then cooldown:Hide() end;
		return;
	end
	cooldown = cooldown or createSwingCooldown(button);
	if cooldown.swing ~= swing then
		local elapsed = now - swing.start;
		local burst = cooldown.swingBurst;
		if burst then burst:Stop() end;
		cooldown:SetCooldown(swing.start, swing.duration)
		cooldown.swing = swing;
		cooldown:Show()
		if elapsed < SWING_BURST_DURATION then
			-- A button revealed mid-swing can show the remainder of the burst.
			burst = burst or createSwingBurst(cooldown);
			burst:GetParent():Show()
			burst:Play(false, elapsed)
		end
	end
end

local function refreshSwingButtons()
	env:Map(CLUSTER_BUTTON, nil, refreshSwing)
end

local function onPlayerSwing(_, duration, swingType)
	if CPAPI.IsSecret(swingType) or (swingType ~= MAIN_HAND and swingType ~= RANGED) then return end;
	if CPAPI.IsSecret(duration) or not duration or duration <= 0 then return end;
	swings[swingType] = {start = GetTime(); duration = duration;};
	latestSwingType = swingType;
	refreshSwingButtons()
end

local function clearSwings()
	latestSwingType = nil;
	wipe(swings)
	refreshSwingButtons()
end

function Cooldowns:WatchSwing()
	hooksecurefunc(self, 'UpdateAction', refreshSwing)
	hooksecurefunc(self, 'OnActionBarSlotChanged', refreshSwing)
	self:HookScript('OnShow', refreshSwing)
	if SwingHandler then return end;

	SwingHandler = CPAPI.CreateEventHandler({'Frame'});
	SwingHandler.PLAYER_SWING           = onPlayerSwing;
	SwingHandler.ACTIONBAR_UPDATE_STATE = refreshSwingButtons;
	SwingHandler.PLAYER_ENTERING_WORLD  = clearSwings;
	SwingHandler.PLAYER_DEAD            = clearSwings;
	SwingHandler.WEAPON_SLOT_CHANGED    = clearSwings;
	-- Let a recorded swing finish even if auto-attack is toggled off mid-countdown.
	CPAPI.RegisterFrameForEvents(SwingHandler, {
		'PLAYER_SWING'; 'ACTIONBAR_UPDATE_STATE';
		'PLAYER_ENTERING_WORLD'; 'PLAYER_DEAD'; 'WEAPON_SLOT_CHANGED';
	})
end
