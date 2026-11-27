local CPAPI, env = CPAPI, CPAPI.GetEnv(...);
local CreateFrame, GenerateClosure, GetTime, Lerp = CreateFrame, GenerateClosure, GetTime, Lerp;
local ipairs, next, pairs, select, type, unpack = ipairs, next, pairs, select, type, unpack;
local max, min, huge = math.max, math.min, math.huge;
local nop, pcall, wipe = nop, pcall, wipe;
local _, _, CLUSTER_BUTTON = env.Const.Cluster.Types();
---------------------------------------------------------------
-- Cluster spellcast and channel effects
---------------------------------------------------------------
local CAST, CHANNEL, EMPOWER, ANY_CAST = 1, 2, 3, false;
local CAST_START_RETRY_DELAY   = 0.12;
local CAST_RESULT_GRACE        = 0.5;
local SENT_CAST_LIFETIME       = 5;
local CHANNEL_END_TOLERANCE_MS = 150;
local NULL_GUID_PATTERN        = '^0?x?[0%-]*$';
local CAST_FRAME_TEMPLATE      = 'ActionButtonCastingAnimFrameTemplate';
local CAST_FILL_START_OFFSET   = 45;
local CAST_FILL_TRAVEL         = 43;
local CAST_TINT                = {1; 0.78; 0.34; 0.12};
local CHANNEL_TINT             = {0.55; 0.92; 0.24; 0.12};

local GLOW_ATLAS_WIDTH         = 512;
local GLOW_ATLAS_HEIGHT        = 256;
local GLOW_CELL_SIZE           = 64;
local GLOW_TEXEL_CENTER        = 0.5;
local TARGETING_PULSE_FROM     = 0.40;
local TARGETING_PULSE_TO       = 0.90;
local TARGETING_PULSE_DURATION = 0.6;
local TOGGLE_FADE_IN           = env.Const.Cluster.GlowFadeIn;
local TOGGLE_FADE_OUT          = env.Const.Cluster.GlowFadeOut;

local EMPOWER_BLEND_MS         = 220;
local EMPOWER_FLARE_MS         = 350;
local EMPOWER_FLARE_PEAK_MS    = 80;
local EMPOWER_FLARE_DECAY      = 1.55;
local EMPOWER_FLARE_WIDTH      = 0.89;
local EMPOWER_FLARE_WIDEN      = 0.29;
local EMPOWER_FLARE_HEIGHT     = 0.32;
local EMPOWER_FLARE_HEIGHTEN   = 0.25;
local EMPOWER_FLARE_MAX_RISE   = 0.92;
local EMPOWER_FLARE_WHITE_MIX  = 0.55;
local EMPOWER_FLARE_MIN_ALPHA  = 0.73;
local EMPOWER_FILL_WIDTH       = 1.13;
local EMPOWER_FILL_HEIGHT      = 1.24;
local EMPOWER_FRONT_ANCHOR     = 0.42;
local EMPOWER_FRONT_TRAVEL     = 1.08;
local EMPOWER_FRONT_START      = 0.55;
local EMPOWER_TINT_ALPHA       = 0.14;
local EMPOWER_TINT_RAMP        = 10;

local BURST_DURATION           = 0.42;
local BURST_SCALE              = 1.24;
local BURST_ALPHA              = 0.70;
local INTERRUPT_DURATION       = 0.20;
local INTERRUPT_ALPHA          = 0.55;

local MATCH_CAST_BY_NAME       = CPAPI.IsClassicVersion;
local MATCH_SLOT_BY_NAME       = CPAPI.IsCamelotVersion or CPAPI.IsClassicVersion;
local CAN_EMPOWER              = GetUnitEmpowerStageDuration and GetUnitEmpowerHoldAtMaxTime
	and C_Texture and C_Texture.GetAtlasInfo and true or nil;

local function canCreateCastFrame()
	if not ActionButtonCastingAnimFrameMixin then return false end;
	if ( C_XMLUtil and C_XMLUtil.GetTemplateInfo ) then
		local found, info = pcall(C_XMLUtil.GetTemplateInfo, CAST_FRAME_TEMPLATE);
		return found and info ~= nil;
	end
	local created, probe = pcall(CreateFrame, 'Frame', nil, nil, CAST_FRAME_TEMPLATE);
	if created then
		probe:SetScript('OnHide', nil)
		probe:Hide()
	end
	return created;
end

local CAN_CREATE_CAST_FRAME = canCreateCastFrame();

local GetBaseSpell, GetOverrideSpell = CPAPI.GetBaseSpell, CPAPI.GetOverrideSpell;
local GetSpellName, GetSpellTexture  = CPAPI.GetSpellName, CPAPI.GetSpellTexture;
local GetItemSpell, IsCurrentAction  = CPAPI.GetItemSpell, CPAPI.IsCurrentAction;
local IsAttackAction                 = CPAPI.IsAttackAction;
local IsAutoCastPetAction            = CPAPI.IsAutoCastPetAction;
local IsAutoAttackSpell              = CPAPI.IsAutoAttackSpell;
local IsAutoRepeatSpell              = CPAPI.IsAutoRepeatSpell;
local GetActionSpell                 = C_ActionBar and C_ActionBar.GetSpell or nop;
local SmoothStep                     = env.SmoothStep;

local activeCast, pendingCast, activeTarget, activeFormSpell;
local sentCasts = {};

---------------------------------------------------------------
-- Cast identity and timing
---------------------------------------------------------------
local function publicCastValue(value)
	if not CPAPI.IsSecret(value) then return value end;
end

local function matchesSpellID(left, right)
	if not ( left and right ) then return false end;
	if ( left == right ) then return true end;
	local leftBase  = publicCastValue(GetBaseSpell(left));
	local rightBase = publicCastValue(GetBaseSpell(right));
	leftBase  = leftBase and leftBase > 0 and leftBase or left;
	rightBase = rightBase and rightBase > 0 and rightBase or right;
	if ( leftBase == rightBase ) then return true end;
	return publicCastValue(GetOverrideSpell(left)) == right
		or publicCastValue(GetOverrideSpell(right)) == left;
end

local function matchesSpellNameAndIcon(spellID, name, icon)
	if not ( MATCH_CAST_BY_NAME and spellID and name and icon ) then return false end;
	if ( publicCastValue((GetSpellName(spellID))) ~= name ) then return false end;
	local texture, original = GetSpellTexture(spellID);
	return publicCastValue(texture) == icon or publicCastValue(original) == icon;
end

local function sameCastIdentity(cast, guid, castBarID)
	if cast.castBarID and castBarID then return cast.castBarID == castBarID end;
	if cast.guid and guid then return cast.guid == guid end;
end

local function getEmpowerStages(numStages)
	if CPAPI.IsSecret(numStages) or not numStages or numStages <= 0 then return end;
	local hold = GetUnitEmpowerHoldAtMaxTime('player');
	if CPAPI.IsSecret(hold) or not hold or hold < 0 then return end;
	local stages, total = {}, 0;
	for rank = 1, numStages do
		local duration = GetUnitEmpowerStageDuration('player', rank - 1);
		if CPAPI.IsSecret(duration) or not duration or duration < 0 then return end;
		total = total + duration;
		stages[rank] = total;
	end
	if ( total > 0 ) then return stages, hold end;
end

local function readClusterCast(cast)
	local _;
	local name, icon, startTime, endTime, guid, spellID, castBarID, empowered, numStages;
	if ( cast.castType == CAST ) then
		name, _, icon, startTime, endTime, _, guid, _, spellID, castBarID = UnitCastingInfo('player');
	else
		name, _, icon, startTime, endTime, _, _, spellID, empowered, numStages, castBarID = UnitChannelInfo('player');
	end
	if CPAPI.IsSecret(startTime) or CPAPI.IsSecret(endTime) then return end;
	if not ( startTime and endTime and endTime > startTime ) then return end;
	if ( cast.castType == CHANNEL and publicCastValue(empowered) ) then return end;

	guid, spellID, castBarID = publicCastValue(guid), publicCastValue(spellID), publicCastValue(castBarID);
	name, icon = publicCastValue(name), publicCastValue(icon);
	local sameCast   = sameCastIdentity(cast, guid, castBarID);
	local knownSpell = cast.spellID or cast.eventSpellID;
	if ( sameCast == false ) then return end;
	if ( not sameCast and knownSpell and spellID and not matchesSpellID(knownSpell, spellID)
		and not matchesSpellNameAndIcon(knownSpell, name, icon) ) then return end;
	if ( cast.castType == CAST and not (guid or castBarID or cast.guid or cast.castBarID) ) then return end;
	if not ( spellID or knownSpell ) then return end;
	if not ( knownSpell or sameCast ) then return end;

	if ( cast.castType == EMPOWER ) then
		local stages, hold = getEmpowerStages(numStages);
		if not stages then return end;
		cast.stages  = stages;
		cast.holdEnd = max(endTime, startTime + stages[#stages]) + hold;
	end
	cast.startTime, cast.endTime = startTime, endTime;
	cast.guid, cast.castBarID    = cast.guid or guid, cast.castBarID or castBarID;
	cast.spellID                 = spellID or knownSpell;
	cast.name, cast.icon         = name, icon;
	return true;
end

---------------------------------------------------------------
-- Action matching
---------------------------------------------------------------
local function getClusterCastAction(button)
	local kind   = publicCastValue(button:GetAttribute('type')) or button._state_type;
	local action = kind == button._state_type and publicCastValue(button._state_action) or nil;
	if ( kind == 'action' ) then
		action = publicCastValue(button:GetAttribute('action')) or action;
		if ( type(action) ~= 'number' or action < 1 ) then return kind end;
	end
	return kind, action;
end

local function getClusterCastSpell(button, kind, action)
	if ( kind == 'action' and not action ) then return end;
	if ( kind == button._state_type and action == publicCastValue(button._state_action) ) then
		local spellID = publicCastValue(button:GetSpellId());
		if spellID then return spellID end;
	end
	if not action then return end;
	local item;
	if ( kind == 'action' ) then
		local actionType, id, subType = GetActionInfo(action);
		if CPAPI.IsSecret(actionType) or CPAPI.IsSecret(id) or CPAPI.IsSecret(subType) then return end;
		if ( actionType == 'spell' or (actionType == 'macro' and subType == 'spell') ) then
			return id;
		elseif ( actionType == 'item' or (actionType == 'macro' and subType == 'item') ) then
			item = id;
		elseif ( actionType == 'macro' and id and not subType ) then
			local spellID = publicCastValue((GetMacroSpell(id)));
			if spellID then return spellID end;
			item = select(2, GetMacroItem(id));
		end
	elseif ( kind == 'item' ) then
		item = action;
	elseif ( kind == 'macro' ) then
		item = select(2, GetMacroItem(action));
	end
	if CPAPI.IsSecret(item) or not item then return end;
	return publicCastValue((select(2, GetItemSpell(item))));
end

local function matchesCastSpell(cast, spellID)
	return matchesSpellID(spellID, cast.spellID)
		or (cast.eventSpellID ~= cast.spellID and matchesSpellID(spellID, cast.eventSpellID))
		or matchesSpellNameAndIcon(spellID, cast.name, cast.icon);
end

local function matchButtonSpell(button, cast, kind, action)
	local spellID = getClusterCastSpell(button, kind, action);
	if matchesCastSpell(cast, spellID) then return spellID, true end;
	if ( kind == 'action' and action ) then
		local slotSpell = publicCastValue(GetActionSpell(action));
		if ( slotSpell and slotSpell > 0 and matchesCastSpell(cast, slotSpell) ) then
			return slotSpell, true;
		end
	end
	return spellID, false;
end

local function matchesCurrentSlot(cast, spellID, slot)
	if ( MATCH_SLOT_BY_NAME and slot and spellID and cast.spellID
		and publicCastValue(IsCurrentAction(slot)) ) then
		local name = publicCastValue((GetSpellName(spellID)));
		return name and name == publicCastValue((GetSpellName(cast.spellID)));
	end
end

---------------------------------------------------------------
-- Masked icon effects
---------------------------------------------------------------
local TARGETING_COLOR     = {0; 1; 0; 1};
local TOGGLE_COLOR        = {env.Const.Cluster.AmberColor:GetRGB()}; TOGGLE_COLOR[4] = 0.60;
local ATTACK_TOGGLE_COLOR = {1; 1; 1; 0.60};
local PULSE_TEXTURE       = env.Const.Cluster.Assets.TargetingGlow;
local TOGGLE_TEXTURE      = env.Const.Cluster.Assets.ToggleGlow;
local PULSE_COORDS        = {};
do  local rows = {
		{'Round'; 'HexMain'; 'HexFlyout'; 'HexSidewaysMain'; 'HexSidewaysFlyout'; 'SquaredMain'; 'SquaredFlyout'};
		{'M1_DOWN'; 'M1_LEFT'; 'M1_RIGHT'; 'M1_UP'};
		{'M2_DOWN'; 'M2_LEFT'; 'M2_RIGHT'; 'M2_UP'};
		{'M3_DOWN'; 'M3_LEFT'; 'M3_RIGHT'; 'M3_UP'};
	};
	for row, shapes in ipairs(rows) do
		local top = (row - 1) * GLOW_CELL_SIZE;
		for column, shape in ipairs(shapes) do
			local left = (column - 1) * GLOW_CELL_SIZE;
			PULSE_COORDS[shape] = {
				(left + GLOW_TEXEL_CENTER) / GLOW_ATLAS_WIDTH;
				(left + GLOW_CELL_SIZE - GLOW_TEXEL_CENTER) / GLOW_ATLAS_WIDTH;
				(top + GLOW_TEXEL_CENTER) / GLOW_ATLAS_HEIGHT;
				(top + GLOW_CELL_SIZE - GLOW_TEXEL_CENTER) / GLOW_ATLAS_HEIGHT;
			};
		end
	end
end

local nextSwingSpells, scanTooltip = {};

-----------------------------------------------------------
-- @param spellID : public spell ID
-- @return found      : a public line equals the next swing label
-- @return conclusive : the result can be cached
local scanNextSwingLabel;
if ( C_TooltipInfo and C_TooltipInfo.GetSpellByID ) then
	function scanNextSwingLabel(spellID)
		local data  = publicCastValue(C_TooltipInfo.GetSpellByID(spellID));
		local lines = data and publicCastValue(data.lines);
		if not lines then return false, false end;
		local conclusive = #lines > 0;
		for _, line in ipairs(lines) do
			local left, right = line.leftText, line.rightText;
			if ( publicCastValue(left) == SPELL_ON_NEXT_SWING
				or publicCastValue(right) == SPELL_ON_NEXT_SWING ) then
				return true, true;
			end
			conclusive = conclusive and not ( CPAPI.IsSecret(left) or CPAPI.IsSecret(right) );
		end
		return false, conclusive;
	end
else
	function scanNextSwingLabel(spellID)
		scanTooltip = scanTooltip
			or CreateFrame('GameTooltip', 'ConsolePortClusterSpellScan', UIParent, 'GameTooltipTemplate');
		scanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		scanTooltip:ClearLines()
		scanTooltip:SetSpellByID(spellID)
		local found, hasText, hasSecret = false, false, false;
		for _, region in ipairs({scanTooltip:GetRegions()}) do
			if ( region:IsObjectType('FontString') and region:IsShown() ) then
				local text = region:GetText();
				if CPAPI.IsSecret(text) then
					hasSecret = true;
				elseif ( text == SPELL_ON_NEXT_SWING ) then
					found = true;
					break;
				elseif text then
					hasText = true;
				end
			end
		end
		scanTooltip:Hide()
		return found, found or (hasText and not hasSecret);
	end
end

local isNextSwingSpell = nop;
if SPELL_ON_NEXT_SWING then
	function isNextSwingSpell(spellID)
		if not spellID then return end;
		local cached = nextSwingSpells[spellID];
		if ( cached ~= nil ) then return cached end;
		local found, conclusive = scanNextSwingLabel(spellID);
		if conclusive then nextSwingSpells[spellID] = found end;
		return found;
	end
end

local function getClusterToggleColor(button, kind, action)
	local spellID = action;
	if ( kind == 'action' and action ) then
		local actionType, id, subType = GetActionInfo(action);
		if publicCastValue(actionType) ~= 'spell' or CPAPI.IsSecret(subType) then return end;
		spellID = publicCastValue(id);
		if ( subType == 'pet' ) then
			if not publicCastValue(IsCurrentAction(action)) then return nil, spellID end;
			local attack   = IsAttackAction(action);
			local autoCast = IsAutoCastPetAction(action);
			if not ( CPAPI.IsSecret(attack) or attack or CPAPI.IsSecret(autoCast) or autoCast ) then
				return TOGGLE_COLOR, spellID;
			end
			return nil, spellID;
		end
		if ( publicCastValue(IsCurrentAction(action))
			and (publicCastValue(IsAttackAction(action)) or isNextSwingSpell(spellID)) ) then
			return ATTACK_TOGGLE_COLOR, spellID;
		end
	elseif ( kind ~= 'spell' ) then
		return;
	elseif ( spellID and publicCastValue(button:IsCurrentlyActive())
		and (publicCastValue(button:IsAttack()) or isNextSwingSpell(spellID)) ) then
		return ATTACK_TOGGLE_COLOR, spellID;
	end
	if ( activeFormSpell and spellID == activeFormSpell ) then return TOGGLE_COLOR, spellID end;
	return nil, spellID;
end

local function createClusterGlow(button)
	local mask = env.LIB.SkinUtility.GetIconMask(button);
	local glow = button:CreateTexture(nil, 'ARTWORK', nil, 1);
	glow:SetAllPoints(mask)
	glow:AddMaskTexture(mask)
	glow:SetAlpha(0)
	button.clusterPulseGlow = glow;
	return glow;
end

local function createTargetingPulse(glow)
	local group = glow:CreateAnimationGroup();
	local pulse = group:CreateAnimation('Alpha');
	pulse:SetFromAlpha(TARGETING_PULSE_FROM)
	pulse:SetToAlpha(TARGETING_PULSE_TO)
	pulse:SetDuration(TARGETING_PULSE_DURATION)
	pulse:SetSmoothing('IN_OUT')
	group:SetLooping('BOUNCE')
	return group;
end

local function updateToggleFades(self)
	local now, glows = GetTime(), self.glows;
	for glow in pairs(glows) do
		local progress = min(1, (now - glow.fadeStart) / glow.fadeDuration);
		glow:SetAlpha(Lerp(glow.fadeFrom, glow.fadeTo, SmoothStep(progress)))
		if ( progress == 1 ) then
			glows[glow] = nil;
			glow:SetShown(glow.fadeTo > 0)
		end
	end
	if not next(glows) then self:Hide() end;
end

local ToggleFader = CreateFrame('Frame');
ToggleFader.glows = {};
ToggleFader:Hide()
ToggleFader:SetScript('OnUpdate', updateToggleFades)

local function setToggleGlowAlpha(glow, show, instant)
	local from, to = glow:GetAlpha(), show and 1 or 0;
	if ( instant or from == to ) then
		ToggleFader.glows[glow] = nil;
		glow:SetAlpha(to)
		glow:SetShown(show)
		return;
	end
	glow.fadeStart    = GetTime();
	glow.fadeDuration = show and TOGGLE_FADE_IN or TOGGLE_FADE_OUT;
	glow.fadeFrom     = from;
	glow.fadeTo       = to;
	ToggleFader.glows[glow] = true;
	glow:Show()
	ToggleFader:Show()
end

local function syncClusterPulse(button)
	local color, kind, action, spellID;
	if ( button.clusterPulseCoords and button:IsVisible() ) then
		kind, action = getClusterCastAction(button);
		color, spellID = getClusterToggleColor(button, kind, action);
		if activeTarget then
			local _, matches = matchButtonSpell(button, activeTarget, kind, action);
			if matches then color = TARGETING_COLOR end;
		end
	end
	local actionChanged = kind ~= button.clusterPulseActionType or action ~= button.clusterPulseAction
		or spellID ~= button.clusterPulseSpell;
	button.clusterPulseActionType, button.clusterPulseAction, button.clusterPulseSpell = kind, action, spellID;
	local previous, glow = button.clusterPulseColor, button.clusterPulseGlow;
	local restyle = actionChanged and glow and glow:IsShown() and color ~= TARGETING_COLOR;
	if ( color == previous and not restyle ) then return end;
	local targeting, wasTargeting = color == TARGETING_COLOR, previous == TARGETING_COLOR;
	button.clusterPulseColor = color;
	if wasTargeting then button.clusterPulseAnim:Stop() end;
	if color then
		glow = glow or createClusterGlow(button);
		glow:SetTexture(targeting and PULSE_TEXTURE or TOGGLE_TEXTURE)
		glow:SetTexCoord(unpack(button.clusterPulseCoords))
		glow:SetVertexColor(unpack(color))
		if targeting then
			setToggleGlowAlpha(glow, true, true)
			button.clusterPulseAnim = button.clusterPulseAnim or createTargetingPulse(glow);
			button.clusterPulseAnim:Play()
		else
			setToggleGlowAlpha(glow, true, actionChanged or wasTargeting)
		end
	else
		setToggleGlowAlpha(glow, false, actionChanged or wasTargeting)
	end
	if ( button.AlphaState and targeting ~= wasTargeting ) then
		button:UpdateAlpha(button.AlphaState.Targeting, targeting)
	end
end

local function syncClusterPulses()
	env:Map(CLUSTER_BUTTON, nil, syncClusterPulse)
end

local function syncClusterForm()
	local form    = publicCastValue(GetShapeshiftForm());
	local spellID = form and form > 0 and publicCastValue((select(4, GetShapeshiftFormInfo(form)))) or nil;
	if ( spellID == activeFormSpell ) then return end;
	activeFormSpell = spellID;
	syncClusterPulses()
end

local function updateTargetingButtons(target)
	if ( target ~= activeTarget ) then return end;
	syncClusterPulses()
end

local function clearClusterTargeting(spellID)
	if not activeTarget or (spellID and spellID ~= activeTarget.spellID) then return end;
	activeTarget = nil;
	updateTargetingButtons()
end

local function clearSentTargeting(target)
	if ( activeTarget == target and not SpellIsTargeting() ) then
		clearClusterTargeting(target.spellID)
	end
end

---------------------------------------------------------------
-- Awaited cast result
---------------------------------------------------------------
local function expireAwaitedCast(frame)
	frame.clusterAwaitedCast, frame.clusterAwaitTimer = nil, nil;
	frame.clusterCastSpell, frame.clusterCastAction, frame.clusterCastActionType = nil, nil, nil;
end

local function cancelAwaitedCast(frame)
	if not frame.clusterAwaitedCast then return end;
	frame.clusterAwaitedCast = nil;
	frame.clusterAwaitTimer  = frame.clusterAwaitTimer:Cancel();
end

local function awaitCastResult(frame)
	local cast = frame.clusterCast;
	local spellID, action, kind = frame.clusterCastSpell, frame.clusterCastAction, frame.clusterCastActionType;
	cancelAwaitedCast(frame)
	frame:Hide()
	if ( not cast or cast ~= activeCast ) then return end;
	frame.clusterCastSpell, frame.clusterCastAction, frame.clusterCastActionType = spellID, action, kind;
	frame.clusterAwaitedCast = cast;
	frame.clusterAwaitTimer  = C_Timer.NewTimer(CAST_RESULT_GRACE, GenerateClosure(expireAwaitedCast, frame));
end

---------------------------------------------------------------
-- Empower animation
---------------------------------------------------------------
local VIOLET = {0.70; 0.34; 1};
local EMBER  = {1; 0.43; 0.17};
local GOLD   = {1; 0.80; 0.34};

local function empowerRank(cast, elapsed)
	local rank = #cast.stages;
	while rank > 0 and elapsed < cast.stages[rank] do rank = rank - 1 end;
	return rank;
end

local function empowerColor(rank, count)
	if ( rank > 0 and rank == count ) then return unpack(GOLD) end;
	if ( rank < 2 ) then return unpack(VIOLET) end;
	local blend = (rank - 2) / (count - 2);
	return Lerp(EMBER[1], GOLD[1], blend), Lerp(EMBER[2], GOLD[2], blend), Lerp(EMBER[3], GOLD[3], blend);
end

local function stopClusterEmpower(frame)
	local effect = frame.clusterEmpower;
	if not effect then return end;
	frame:SetScript('OnUpdate', nil)
	effect.Fill:Hide()
	effect.Inner:Hide()
	effect.Pulse:Hide()
end

local function updateClusterEmpower(frame)
	local cast, effect = frame.clusterCast, frame.clusterEmpower;
	local now = GetTime() * 1000;
	if ( now > cast.holdEnd + CHANNEL_END_TOLERANCE_MS ) then return awaitCastResult(frame) end;

	local count     = #cast.stages;
	local elapsed   = max(0, now - cast.startTime);
	local total     = cast.stages[count];
	local rank      = empowerRank(cast, elapsed);
	local stageTime = cast.stages[rank];
	local age       = stageTime and elapsed - stageTime or huge;
	local progress  = min(1, elapsed / total);
	local r, g, b   = empowerColor(rank, count);
	if ( rank > 0 and age < EMPOWER_BLEND_MS ) then
		local pr, pg, pb = empowerColor(rank - 1, count);
		local blend      = SmoothStep(age / EMPOWER_BLEND_MS);
		r, g, b = Lerp(pr, r, blend), Lerp(pg, g, blend), Lerp(pb, b, blend);
	end

	local mask          = effect.Mask;
	local scale         = frame:GetScale();
	local width, height = mask:GetSize();
	local button        = frame:GetParent();
	local shape         = button.clusterShape;
	local inset         = not button.layoutData.Prefix and shape and shape.MainHitInset or 0;
	local iconToFrame   = (1 - 2 * inset) / scale;
	width, height       = width * iconToFrame, height * iconToFrame;
	local fillHeight    = height * EMPOWER_FILL_HEIGHT;
	local front         = height * (EMPOWER_FRONT_TRAVEL * progress - EMPOWER_FRONT_START);
	effect.Fill:SetSize(width * EMPOWER_FILL_WIDTH, fillHeight)
	effect.Fill:SetPoint('CENTER', mask, 'CENTER', 0, front - fillHeight * EMPOWER_FRONT_ANCHOR)
	effect.Fill:SetVertexColor(r, g, b)
	effect.Inner:SetVertexColor(r, g, b, EMPOWER_TINT_ALPHA * min(1, progress * EMPOWER_TINT_RAMP))

	local flare = effect.Pulse;
	flare:SetShown(age < EMPOWER_FLARE_MS)
	if flare:IsShown() then
		local spread = age / EMPOWER_FLARE_MS;
		local peak   = age < EMPOWER_FLARE_PEAK_MS and age / EMPOWER_FLARE_PEAK_MS
			or ((EMPOWER_FLARE_MS - age) / (EMPOWER_FLARE_MS - EMPOWER_FLARE_PEAK_MS)) ^ EMPOWER_FLARE_DECAY;
		local rise   = min(EMPOWER_FLARE_MAX_RISE, stageTime / total);
		local nr, ng, nb = empowerColor(rank, count);
		flare:SetSize(
			width * (EMPOWER_FLARE_WIDTH + spread * EMPOWER_FLARE_WIDEN),
			height * (EMPOWER_FLARE_HEIGHT + spread * EMPOWER_FLARE_HEIGHTEN))
		flare:SetPoint('CENTER', mask, 'CENTER', 0, height * (rise - 0.5))
		flare:SetVertexColor(
			Lerp(nr, 1, EMPOWER_FLARE_WHITE_MIX),
			Lerp(ng, 1, EMPOWER_FLARE_WHITE_MIX),
			Lerp(nb, 1, EMPOWER_FLARE_WHITE_MIX))
		flare:SetAlpha(peak * Lerp(EMPOWER_FLARE_MIN_ALPHA, 1, rank / count))
	end
end

local function createEmpowerTexture(frame, mask, subLevel)
	local texture = frame:CreateTexture(nil, 'ARTWORK', nil, subLevel);
	texture:SetBlendMode('ADD')
	texture:SetDesaturated(true)
	texture:AddMaskTexture(mask)
	return texture;
end

local function startClusterEmpower(button, frame, cast)
	local effect = frame.clusterEmpower;
	if not effect then
		local atlas = C_Texture.GetAtlasInfo('UI-HUD-ActionBar-Cast-Fill');
		if not atlas then return end;
		local mask = env.LIB.SkinUtility.GetIconMask(button);
		effect = {
			Mask  = mask;
			Fill  = createEmpowerTexture(frame, mask, 1);
			Inner = createEmpowerTexture(frame, mask, 0);
			Pulse = createEmpowerTexture(frame, mask, 2);
		};
		local left, right = atlas.leftTexCoord, atlas.rightTexCoord;
		local top, bottom = atlas.topTexCoord, atlas.bottomTexCoord;
		effect.Fill:SetTexture(atlas.file or atlas.filename)
		effect.Fill:SetTexCoord(right, top, left, top, right, bottom, left, bottom)
		effect.Inner:SetColorTexture(1, 1, 1, 1)
		effect.Inner:SetAllPoints(mask)
		effect.Pulse:SetAtlas('cast-empowered-pipflare')
		frame.clusterEmpower = effect;
	end
	frame.clusterCast = cast;
	frame.Fill.CastingAnim:Stop()
	frame.EndBurst.FinishCastAnim:Stop()
	frame.Fill:Hide()
	frame.EndBurst:Hide()
	effect.Fill:Show()
	effect.Inner:Show()
	frame:SetScript('OnUpdate', updateClusterEmpower)
	updateClusterEmpower(frame)
	frame:Show()
end

---------------------------------------------------------------
-- Button animation
---------------------------------------------------------------
local function createClusterBurst(parent, mask, red, green, blue)
	local glow = parent:CreateTexture(nil, 'ARTWORK', nil, 2);
	glow:SetAllPoints(mask)
	glow:AddMaskTexture(mask)
	glow:SetAtlas('UI-HUD-ActionBar-Casting-Complete-Glow', false)
	glow:SetDesaturated(true)
	glow:SetVertexColor(red, green, blue)
	glow:SetBlendMode('ADD')

	local group = glow:CreateAnimationGroup();
	local scale = group:CreateAnimation('Scale');
	scale:SetOrigin('CENTER', 0, 0)
	scale:SetScale(BURST_SCALE, BURST_SCALE)
	scale:SetDuration(BURST_DURATION)
	scale:SetSmoothing('OUT')

	local fade = group:CreateAnimation('Alpha');
	fade:SetFromAlpha(BURST_ALPHA)
	fade:SetToAlpha(0)
	fade:SetDuration(BURST_DURATION)
	fade:SetSmoothing('IN_OUT')
	local hide = GenerateClosure(glow.Hide, glow);
	group:SetScript('OnFinished', hide)
	group:SetScript('OnStop', hide)
	return group;
end

local function createInterruptFlash(button)
	local mask = env.LIB.SkinUtility.GetIconMask(button);
	local glow = button:CreateTexture(nil, 'ARTWORK', nil, 2);
	glow:SetAllPoints(mask)
	glow:AddMaskTexture(mask)
	glow:SetColorTexture(1, 1, 1, 1)
	glow:SetBlendMode('BLEND')

	local group = glow:CreateAnimationGroup();
	local fade  = group:CreateAnimation('Alpha');
	fade:SetFromAlpha(INTERRUPT_ALPHA)
	fade:SetToAlpha(0)
	fade:SetDuration(INTERRUPT_DURATION)
	fade:SetSmoothing('OUT')
	return group;
end

local function hideClusterFeedback(group)
	local button = group.button;
	group:GetParent():Hide()
	button.clusterCastFeedback = nil;
	if button.AlphaState then button:UpdateAlpha(button.AlphaState.CastFeedback, false) end;
end

local function stopClusterFeedback(button)
	if button.clusterCastFeedback then button.clusterCastFeedback:Stop() end;
end

local function playClusterFeedback(button, group, actionType, action)
	stopClusterFeedback(button)
	if not group.button then
		group.button = button;
		group:SetScript('OnFinished', hideClusterFeedback)
		group:SetScript('OnStop', hideClusterFeedback)
	end
	group.actionType, group.action = actionType, action;
	button.clusterCastFeedback = group;
	group:GetParent():Show()
	if button.AlphaState then button:UpdateAlpha(button.AlphaState.CastFeedback, true) end;
	group:Play()
end

local function playClusterInstant(button, cast)
	if not ( button.clusterSkinLayered and button:IsVisible() ) then return end;
	local kind, action = getClusterCastAction(button);
	local _, matches = matchButtonSpell(button, cast, kind, action);
	if not matches then return end;
	if ( kind == 'action' and action and publicCastValue(IsAttackAction(action)) ) then return end;
	local burst = button.clusterInstantBurst;
	if not burst then
		local mask = env.LIB.SkinUtility.GetIconMask(button);
		burst = createClusterBurst(button, mask, 248 / 255, 236 / 255, 181 / 255);
		button.clusterInstantBurst = burst;
	end
	playClusterFeedback(button, burst, kind, action)
end

local function syncClusterCast(button, timingChanged, checkLive)
	local frame     = button.SpellCastAnimFrame;
	local shownCast = frame and frame.clusterCast;
	local cast      = activeCast or shownCast;
	if not ( frame and cast and button:IsVisible() ) then return end;
	local kind, action = getClusterCastAction(button);
	local slot         = kind == 'action' and action or nil;
	local buttonSpell, matches = matchButtonSpell(button, cast, kind, action);
	local sameButton = shownCast == cast and frame.clusterCastSpell == buttonSpell
		and frame.clusterCastAction == action and frame.clusterCastActionType == kind;
	matches = matches or sameButton or matchesCurrentSlot(cast, buttonSpell, slot);
	if ( shownCast and (shownCast ~= cast or not matches) ) then
		frame:Hide()
	end
	if not ( activeCast and matches ) then return end;
	if ( checkLive and not sameButton and not readClusterCast(cast) ) then return end;

	local now = GetTime();
	if ( now * 1000 >= (cast.holdEnd or cast.endTime) ) then return end;
	local starting = frame.clusterCast ~= cast;
	if starting then
		stopClusterFeedback(button)
		cancelAwaitedCast(frame)
	end
	frame.clusterCastSpell, frame.clusterCastAction, frame.clusterCastActionType = buttonSpell, action, kind;
	if ( cast.castType == EMPOWER ) then
		if starting then startClusterEmpower(button, frame, cast) end;
		return;
	end
	if not ( starting or timingChanged ) then return end;
	if starting then
		frame.clusterCast = cast;
		frame.EndBurst.FinishCastAnim:Stop()
		frame.EndBurst:Hide()
		local fill      = frame.Fill;
		local isChannel = cast.castType == CHANNEL;
		local direction = isChannel and -1 or 1;
		fill.CastFill:ClearAllPoints()
		fill.CastFill:SetAtlas(isChannel and 'UI-HUD-ActionBar-Channel-Fill' or 'UI-HUD-ActionBar-Cast-Fill', true)
		fill.InnerGlowTexture:SetColorTexture(unpack(isChannel and CHANNEL_TINT or CAST_TINT))
		fill.CastFill:SetPoint('CENTER', -CAST_FILL_START_OFFSET * direction, 0)
		fill.CastingAnim.CastFillTranslation:SetOffset(CAST_FILL_TRAVEL * direction, 0)
		fill:Show()
		frame:Show()
	end

	local animation = frame.Fill.CastingAnim;
	animation:Stop()
	animation.CastFillTranslation:SetDuration((cast.endTime - cast.startTime) / 1000)
	animation:Play(false, max(0, now - cast.startTime / 1000))
end

local function refreshClusterAction(button)
	local feedback = button.clusterCastFeedback;
	if feedback then
		local kind, action = getClusterCastAction(button);
		if ( kind ~= feedback.actionType or action ~= feedback.action ) then feedback:Stop() end;
	end
	syncClusterCast(button, false, true)
	syncClusterPulse(button)
end

local function runQueuedRefresh(button)
	button.clusterRefreshQueued = nil;
	refreshClusterAction(button)
end

local function playCastBurst(frame, cast)
	if frame.EndBurst:IsShown() then return end;
	if ( cast.castType == EMPOWER ) then
		stopClusterEmpower(frame)
		local ring = frame.EndBurst.GlowRing;
		local rank = empowerRank(cast, GetTime() * 1000 - cast.startTime);
		ring:SetDesaturated(true)
		ring:SetVertexColor(empowerColor(rank, #cast.stages))
	end
	frame:FinishAnimAndPlayBurst()
	frame.Fill:Hide()
end

local function finishAwaitedCast(button, frame, cast, transition)
	cancelAwaitedCast(frame)
	local kind, action = getClusterCastAction(button);
	if ( transition == 'finish' and button:IsVisible()
		and kind == frame.clusterCastActionType and action == frame.clusterCastAction ) then
		frame.clusterCast = cast;
		frame.Fill:Hide()
		frame:Show()
		return playCastBurst(frame, cast);
	end
	frame.clusterCastSpell, frame.clusterCastAction, frame.clusterCastActionType = nil, nil, nil;
end

local function finishClusterCast(button, cast, transition)
	local frame = button.SpellCastAnimFrame;
	if not frame then return end;
	if ( frame.clusterAwaitedCast == cast ) then return finishAwaitedCast(button, frame, cast, transition) end;
	if ( frame.clusterCast ~= cast ) then return end;
	if ( transition == 'interrupt' and button:IsVisible() ) then
		local kind, action = getClusterCastAction(button);
		if ( kind == frame.clusterCastActionType and action == frame.clusterCastAction ) then
			button.clusterInterruptFlash = button.clusterInterruptFlash or createInterruptFlash(button);
			playClusterFeedback(button, button.clusterInterruptFlash, kind, action)
		end
	end
	if ( transition ~= 'finish' ) then return frame:Hide() end;
	playCastBurst(frame, cast)
end

---------------------------------------------------------------
-- Player cast tracker
---------------------------------------------------------------
local function isNullGUID(value)
	return type(value) == 'string' and value:find(NULL_GUID_PATTERN) ~= nil;
end

local function isInterruptSource(value)
	return type(value) == 'string' and not value:find(NULL_GUID_PATTERN);
end

local function matchesCastEvent(cast, castType, guid, spellID, castBarID)
	if not cast or (castType and cast.castType ~= castType) then return false end;
	local sameCast = sameCastIdentity(cast, guid, castBarID);
	if ( sameCast ~= nil ) then return sameCast end;
	return matchesCastSpell(cast, spellID);
end

local function playConfirmedInstant(guid, spellID, castBarID)
	local sentAt = sentCasts[guid];
	sentCasts[guid] = nil;
	if not sentAt or GetTime() - sentAt > SENT_CAST_LIFETIME then return end;
	if ( matchesCastEvent(pendingCast, nil, guid, spellID, castBarID)
		or matchesCastEvent(activeCast, nil, guid, spellID, castBarID) ) then return end;
	if ( publicCastValue(IsAutoAttackSpell(spellID))
		or publicCastValue(IsAutoRepeatSpell(spellID)) ) then return end;
	env:Map(CLUSTER_BUTTON, nil, playClusterInstant, {spellID = spellID;})
end

local function applyClusterCast(cast)
	if ( cast ~= activeCast and cast ~= pendingCast ) then return end;
	local startTime, endTime = cast.startTime, cast.endTime;
	if not readClusterCast(cast) then return end;
	if ( pendingCast == cast ) then pendingCast = nil end;
	if ( activeCast and activeCast ~= cast ) then
		env:Map(CLUSTER_BUTTON, nil, finishClusterCast, activeCast)
	end
	activeCast = cast;
	env:Map(CLUSTER_BUTTON, nil, syncClusterCast, startTime ~= cast.startTime or endTime ~= cast.endTime)
end

local function clearClusterCast(cast, transition)
	if ( activeCast ~= cast ) then return end;
	activeCast = nil;
	env:Map(CLUSTER_BUTTON, nil, finishClusterCast, cast, transition)
end

-----------------------------------------------------------
-- @param castType    : CAST, CHANNEL, EMPOWER or ANY_CAST
-- @param transition  : start, update, stop, finish, cancel, interrupt
-- @param barPosition : index of castBarID after spellID
local function onPlayerCastEvent(castType, transition, barPosition, _, guid, spellID, ...)
	guid, spellID = publicCastValue(guid), publicCastValue(spellID);
	local castBarID      = publicCastValue((select(barPosition, ...)));
	local matchesPending = matchesCastEvent(pendingCast, castType, guid, spellID, castBarID);
	local matchesActive  = matchesCastEvent(activeCast, castType, guid, spellID, castBarID);
	if guid and sentCasts[guid] then
		if ( castType == CAST and transition == 'finish' and type(spellID) == 'number' and spellID > 0
			and not (matchesPending or matchesActive) ) then
			CPAPI.Next(playConfirmedInstant, guid, spellID, castBarID)
		elseif ( transition ~= 'stop' ) then
			sentCasts[guid] = nil;
		end
	end
	if ( transition == 'start' or transition == 'update' ) then
		local existing = matchesPending and pendingCast or matchesActive and activeCast;
		if existing then return applyClusterCast(existing) end;
		if ( transition == 'update' and activeCast ) then return end;
		if not ( guid or spellID or castBarID ) then return end;
		local cast = {
			castType     = castType;
			guid         = guid;
			eventSpellID = spellID;
			castBarID    = castBarID;
		};
		pendingCast = cast;
		applyClusterCast(cast)
		CPAPI.Next(applyClusterCast, cast)
		C_Timer.After(CAST_START_RETRY_DELAY, GenerateClosure(applyClusterCast, cast))
		return;
	end

	if matchesPending then pendingCast = nil end;
	if not matchesActive then return end;
	local cast   = activeCast;
	local result = ...;
	if ( castType == EMPOWER ) then
		local interrupted = isInterruptSource(publicCastValue((select(2, ...))));
		transition = interrupted and 'interrupt' or publicCastValue(result) == true and 'finish' or 'cancel';
	elseif ( castType == CHANNEL ) then
		local source   = publicCastValue(result);
		local natural  = not CPAPI.IsSecret(result) and (not source or isNullGUID(source));
		local complete = natural and GetTime() * 1000 + CHANNEL_END_TOLERANCE_MS >= cast.endTime;
		transition = isInterruptSource(source) and 'interrupt' or complete and 'finish' or 'cancel';
	end
	if ( transition == 'stop' or transition == 'cancel' ) then
		return CPAPI.Next(clearClusterCast, cast);
	end
	clearClusterCast(cast, transition)
end

local function unregisterEvents(frame, events)
	for _, event in pairs(events) do
		if CPAPI.IsEventValid(event) then
			frame:UnregisterEvent(event)
		end
	end
end

local function hasActiveButton()
	local active = false;
	env:Map(CLUSTER_BUTTON, nil, function() active = true; end)
	return active;
end

---------------------------------------------------------------
-- Event handler
---------------------------------------------------------------
local CastHandler = CPAPI.CreateEventHandler({'Frame'}, nil, {
	Events = {
		'ACTIONBAR_UPDATE_STATE';
		'PET_BAR_UPDATE';
		'PLAYER_ENTER_COMBAT';
		'PLAYER_ENTERING_WORLD';
		'PLAYER_LEAVE_COMBAT';
		'UNIT_SPELLCAST_SENT';
		'UPDATE_SHAPESHIFT_FORM';
	};
	PlayerEvents = {
		'UNIT_PET';
		'UNIT_SPELLCAST_CHANNEL_START';
		'UNIT_SPELLCAST_CHANNEL_STOP';
		'UNIT_SPELLCAST_CHANNEL_UPDATE';
		'UNIT_SPELLCAST_DELAYED';
		'UNIT_SPELLCAST_FAILED';
		'UNIT_SPELLCAST_INTERRUPTED';
		'UNIT_SPELLCAST_RETICLE_CLEAR';
		'UNIT_SPELLCAST_RETICLE_TARGET';
		'UNIT_SPELLCAST_START';
		'UNIT_SPELLCAST_STOP';
		'UNIT_SPELLCAST_SUCCEEDED';
		CAN_EMPOWER and 'UNIT_SPELLCAST_EMPOWER_START';
		CAN_EMPOWER and 'UNIT_SPELLCAST_EMPOWER_STOP';
		CAN_EMPOWER and 'UNIT_SPELLCAST_EMPOWER_UPDATE';
	};
	isTracking = false;
});

function CastHandler:SetTracking(enabled)
	if ( self.isTracking == enabled ) then return end;
	self.isTracking = enabled;
	if enabled then
		CPAPI.RegisterFrameForEvents(self, self.Events)
		CPAPI.RegisterFrameForUnitEvents(self, self.PlayerEvents, 'player')
		return syncClusterForm();
	end
	unregisterEvents(self, self.Events)
	unregisterEvents(self, self.PlayerEvents)
	activeCast, pendingCast, activeTarget = nil, nil, nil;
	wipe(sentCasts)
end

function CastHandler:ACTIONBAR_UPDATE_STATE()
	local cast = pendingCast or activeCast;
	if cast then applyClusterCast(cast) end;
	syncClusterPulses()
end

function CastHandler:PET_BAR_UPDATE()
	syncClusterPulses()
end

function CastHandler:PLAYER_ENTER_COMBAT()
	syncClusterPulses()
end

function CastHandler:PLAYER_LEAVE_COMBAT()
	syncClusterPulses()
end

function CastHandler:UNIT_PET()
	syncClusterPulses()
end

function CastHandler:PLAYER_ENTERING_WORLD()
	syncClusterForm()
end

function CastHandler:UPDATE_SHAPESHIFT_FORM()
	syncClusterForm()
end

function CastHandler:UNIT_SPELLCAST_SENT(unit, _, guid, spellID)
	if ( unit ~= 'player' ) then return end;
	guid = publicCastValue(guid);
	if guid then
		local now = GetTime();
		for key, sentAt in pairs(sentCasts) do
			if ( now - sentAt > SENT_CAST_LIFETIME ) then sentCasts[key] = nil end;
		end
		sentCasts[guid] = now;
	end
	local target = activeTarget;
	if not target or publicCastValue(spellID) ~= target.spellID then return end;
	CPAPI.Next(clearSentTargeting, target)
end

function CastHandler:UNIT_SPELLCAST_RETICLE_TARGET(_, _, spellID)
	spellID = publicCastValue(spellID);
	if not spellID or (activeTarget and activeTarget.spellID == spellID) then return end;
	local target = {spellID = spellID;};
	activeTarget = target;
	updateTargetingButtons(target)
	CPAPI.Next(updateTargetingButtons, target)
end

function CastHandler:UNIT_SPELLCAST_RETICLE_CLEAR(_, _, spellID)
	clearClusterTargeting(publicCastValue(spellID))
end

function CastHandler:UNIT_SPELLCAST_START(...)
	onPlayerCastEvent(CAST, 'start', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_DELAYED(...)
	onPlayerCastEvent(CAST, 'update', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_STOP(...)
	onPlayerCastEvent(CAST, 'stop', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_SUCCEEDED(...)
	onPlayerCastEvent(CAST, 'finish', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_FAILED(...)
	onPlayerCastEvent(CAST, 'cancel', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_INTERRUPTED(...)
	onPlayerCastEvent(ANY_CAST, 'interrupt', 2, ...)
end

function CastHandler:UNIT_SPELLCAST_CHANNEL_START(...)
	onPlayerCastEvent(CHANNEL, 'start', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(...)
	onPlayerCastEvent(CHANNEL, 'update', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_CHANNEL_STOP(...)
	onPlayerCastEvent(CHANNEL, 'finish', 2, ...)
end

function CastHandler:UNIT_SPELLCAST_EMPOWER_START(...)
	onPlayerCastEvent(EMPOWER, 'start', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_EMPOWER_UPDATE(...)
	onPlayerCastEvent(EMPOWER, 'update', 1, ...)
end

function CastHandler:UNIT_SPELLCAST_EMPOWER_STOP(...)
	onPlayerCastEvent(EMPOWER, 'finish', 3, ...)
end

---------------------------------------------------------------
-- Button and cast frame scripts
---------------------------------------------------------------
local function setCasting(button, casting)
	button:SetCastingSwipe(casting)
	if button.AlphaState then button:UpdateAlpha(button.AlphaState.Casting, casting) end;
end

local function onCastFrameShow(frame)
	setCasting(frame:GetParent(), true)
end

local function onCastFrameHide(frame)
	if frame.clusterEmpower then
		stopClusterEmpower(frame)
		frame.EndBurst.GlowRing:SetDesaturated(false)
		frame.EndBurst.GlowRing:SetVertexColor(1, 1, 1)
		frame.EndBurst:Hide()
	end
	frame.Fill.CastingAnim:Stop()
	frame.EndBurst.FinishCastAnim:Stop()
	frame.clusterCast, frame.clusterCastSpell = nil, nil;
	frame.clusterCastAction, frame.clusterCastActionType = nil, nil;
	frame:Hide()
	setCasting(frame:GetParent(), false)
end

local function onCastFillFinished(animation)
	awaitCastResult(animation:GetParent():GetParent())
end

local function onCastBurstFinished(animation)
	animation:GetParent():GetParent():Hide()
end

local function onButtonShow()
	CastHandler:SetTracking(true)
end

local function onButtonHide(button)
	if env:IsActive(button) or hasActiveButton() then return end;
	CastHandler:SetTracking(false)
end

local function onActionAttributeChanged(button, attribute)
	if button.clusterRefreshQueued or not ( attribute == 'type' or attribute == 'action' ) then return end;
	if ( activeCast or button.clusterPulseCoords or button.clusterCastFeedback ) then
		button.clusterRefreshQueued = true;
		CPAPI.Next(runQueuedRefresh, button)
	end
end

---------------------------------------------------------------
-- Cluster effects API
---------------------------------------------------------------
env.ClusterBurstDuration = BURST_DURATION;

function env:CreateClusterBurst(parent, mask, red, green, blue)
	return createClusterBurst(parent, mask, red, green, blue);
end

function env:SetClusterPulseShape(button, shape)
	local coords = PULSE_COORDS[shape];
	button.clusterPulseCoords = coords;
	local glow = button.clusterPulseGlow;
	if coords and glow then
		glow:SetTexCoord(unpack(coords))
	end
	syncClusterPulse(button)
end

function env:InitializeClusterCast(button)
	local frame = button.SpellCastAnimFrame;
	if ( not frame and CAN_CREATE_CAST_FRAME ) then
		frame = CreateFrame('Frame', nil, button, CAST_FRAME_TEMPLATE);
		frame:SetScript('OnHide', nil)
		frame:Hide()
		button.SpellCastAnimFrame = frame;
	end
	if frame then
		frame:SetScript('OnShow', onCastFrameShow)
		frame:SetScript('OnHide', onCastFrameHide)
		frame.Fill.CastingAnim:SetScript('OnFinished', onCastFillFinished)
		frame.EndBurst.FinishCastAnim:SetScript('OnFinished', onCastBurstFinished)
	end
	hooksecurefunc(button, 'UpdateAction', refreshClusterAction)
	hooksecurefunc(button, 'OnActionBarSlotChanged', refreshClusterAction)
	button:HookScript('OnShow', onButtonShow)
	button:HookScript('OnShow', refreshClusterAction)
	button:HookScript('OnHide', syncClusterPulse)
	button:HookScript('OnHide', stopClusterFeedback)
	button:HookScript('OnHide', onButtonHide)
	button:HookScript('OnAttributeChanged', onActionAttributeChanged)
	CastHandler:SetTracking(true)
end
