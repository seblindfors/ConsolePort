local CPAPI, env = CPAPI, CPAPI.GetEnv(...);
local CreateFrame, GenerateClosure = CreateFrame, GenerateClosure;
local _, _, CLUSTER_BUTTON = env.Const.Cluster.Types();
---------------------------------------------------------------
-- Cluster spellcast and channel effects
---------------------------------------------------------------
local CAST, CHANNEL, EMPOWER   = 1, 2, 3;
local CAST_START_RETRY_DELAY   = .12; -- Seconds for the live cast and action slot to settle.
local CHANNEL_END_TOLERANCE_MS = 150; -- Grace period for channel completion and empower cleanup.
local CAST_TINT                = {1; .78; .34; .12}; -- Amber inner wash at 12% opacity.
local CHANNEL_TINT             = {.55; .92; .24; .12}; -- Green inner wash at the same opacity.
local getItemSpell             = C_Item and C_Item.GetItemSpell or GetItemSpell;
local getBaseSpell             = C_Spell and C_Spell.GetBaseSpell
	or C_SpellBook and C_SpellBook.FindBaseSpellByID or FindBaseSpellByID;
local getOverrideSpell         = C_Spell and C_Spell.GetOverrideSpell
	or C_SpellBook and C_SpellBook.FindSpellOverrideByID or FindSpellOverrideByID;
local getSpellName             = C_Spell and C_Spell.GetSpellName or GetSpellInfo;
local getSpellTexture          = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture;
local isCurrentAction          = C_ActionBar and C_ActionBar.IsCurrentAction or IsCurrentAction;
local isAttackAction           = C_ActionBar and C_ActionBar.IsAttackAction or IsAttackAction;
local isAutoCastPetAction      = C_ActionBar and C_ActionBar.IsAutoCastPetAction or IsAutoCastPetAction;
local isAutoRepeatSpell        = C_Spell and C_Spell.IsAutoRepeatSpell or IsAutoRepeatSpell;
local isAutoAttackSpell        = C_Spell and C_Spell.IsAutoAttackSpell;

-- Cast type (false for any), transition, and position of castBarID after the spell ID.
local CAST_EVENTS = {
	UNIT_SPELLCAST_START          = {CAST; 'start'};
	UNIT_SPELLCAST_DELAYED        = {CAST; 'update'};
	UNIT_SPELLCAST_STOP           = {CAST; 'stop'};
	UNIT_SPELLCAST_SUCCEEDED      = {CAST; 'finish'};
	UNIT_SPELLCAST_FAILED         = {CAST; 'cancel'};
	UNIT_SPELLCAST_INTERRUPTED    = {false; 'interrupt'; 2};
	UNIT_SPELLCAST_CHANNEL_START  = {CHANNEL; 'start'};
	UNIT_SPELLCAST_CHANNEL_UPDATE = {CHANNEL; 'update'};
	UNIT_SPELLCAST_CHANNEL_STOP   = {CHANNEL; 'finish'; 2};
	UNIT_SPELLCAST_EMPOWER_START  = {EMPOWER; 'start'};
	UNIT_SPELLCAST_EMPOWER_UPDATE = {EMPOWER; 'update'};
	UNIT_SPELLCAST_EMPOWER_STOP   = {EMPOWER; 'finish'; 3};
};
local activeCast, pendingCast, activeTarget;
local sentCasts = {};
local SENT_CAST_LIFETIME = 5; -- Seconds to pair a sent cast with its instant success.

---------------------------------------------------------------
-- Cast identity and timing
---------------------------------------------------------------
local function publicCastValue(value)
	if not CPAPI.IsSecret(value) then return value end;
end

local function matchesSpellID(left, right)
	if not (left and right) then return false end;
	if left == right then return true end;
	-- A temporary override can expire as the channel starts.
	if getBaseSpell then
		local leftBase = publicCastValue(getBaseSpell(left));
		local rightBase = publicCastValue(getBaseSpell(right));
		leftBase = leftBase and leftBase > 0 and leftBase or left;
		rightBase = rightBase and rightBase > 0 and rightBase or right;
		if leftBase == rightBase then return true end;
	end
	return getOverrideSpell and (publicCastValue(getOverrideSpell(left)) == right
		or publicCastValue(getOverrideSpell(right)) == left);
end

local function matchesSpellNameAndIcon(spellID, name, icon)
	-- MoP can restore the base action before the replacement finishes casting.
	if not (CPAPI.IsClassicVersion and spellID and name and icon and getSpellName and getSpellTexture) then return false end;
	if publicCastValue((getSpellName(spellID))) ~= name then return false end;
	local texture, original = getSpellTexture(spellID);
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
	if total > 0 then return stages, hold end;
end

local function readClusterCast(cast)
	local _;
	local name, icon, startTime, endTime, guid, spellID, castBarID, empowered, numStages;
	if cast.castType == CAST then
		name, _, icon, startTime, endTime, _, guid, _, spellID, castBarID = UnitCastingInfo('player');
	else
		name, _, icon, startTime, endTime, _, _, spellID, empowered, numStages, castBarID = UnitChannelInfo('player');
	end
	if CPAPI.IsSecret(startTime) or CPAPI.IsSecret(endTime) then return end;
	if not (startTime and endTime and endTime > startTime) then return end;
	if cast.castType == CHANNEL and publicCastValue(empowered) then return end;

	guid, spellID, castBarID = publicCastValue(guid), publicCastValue(spellID), publicCastValue(castBarID);
	name, icon = publicCastValue(name), publicCastValue(icon);
	local sameCast = sameCastIdentity(cast, guid, castBarID);
	local knownSpell = cast.spellID or cast.eventSpellID;
	if sameCast == false then return end;
	if ( not sameCast and knownSpell and spellID and not matchesSpellID(knownSpell, spellID)
		and not matchesSpellNameAndIcon(knownSpell, name, icon) ) then return end;
	if cast.castType == CAST and not (guid or castBarID or cast.guid or cast.castBarID) then return end;
	if not (spellID or knownSpell) then return end;
	-- A missing event spell can only be recovered from a matching live cast.
	if not (knownSpell or sameCast) then return end;

	if cast.castType == EMPOWER then
		local stages, hold = getEmpowerStages(numStages);
		if not stages then return end;
		cast.stages  = stages;
		cast.holdEnd = math.max(endTime, startTime + stages[#stages]) + hold;
	end
	cast.startTime, cast.endTime = startTime, endTime;
	cast.guid, cast.castBarID    = cast.guid or guid, cast.castBarID or castBarID;
	cast.spellID                = spellID or knownSpell;
	cast.name, cast.icon        = name, icon;
	return true;
end

---------------------------------------------------------------
-- Action matching
---------------------------------------------------------------
local function getClusterCastAction(button)
	-- The secure slot can change before LAB updates its cached action.
	local kind   = publicCastValue(button:GetAttribute('type')) or button._state_type;
	local action = kind == button._state_type and publicCastValue(button._state_action) or nil;
	if kind == 'action' then
		action = publicCastValue(button:GetAttribute('action')) or action;
		if type(action) ~= 'number' or action < 1 then return kind end;
	end
	return kind, action;
end

local function getClusterCastSpell(button, kind, action)
	if kind == 'action' and not action then return end;
	if kind == button._state_type and action == publicCastValue(button._state_action) then
		local spellID = publicCastValue(button:GetSpellId());
		if spellID then return spellID end;
	end
	if not action then return end;
	local item;
	if kind == 'action' then
		local actionType, id, subType = GetActionInfo(action);
		if CPAPI.IsSecret(actionType) or CPAPI.IsSecret(id) or CPAPI.IsSecret(subType) then return end;
		if actionType == 'spell' or (actionType == 'macro' and subType == 'spell') then
			return id;
		elseif actionType == 'item' or (actionType == 'macro' and subType == 'item') then
			item = id;
		elseif actionType == 'macro' and id and not subType then
			-- Older clients can report a macro index instead of the resolved item.
			local spellID = publicCastValue((GetMacroSpell(id)));
			if spellID then return spellID end;
			item = select(2, GetMacroItem(id));
		end
	elseif kind == 'item' then
		item = action;
	elseif kind == 'macro' then
		item = select(2, GetMacroItem(action));
	end
	if not getItemSpell or CPAPI.IsSecret(item) or not item then return end;
	return publicCastValue((select(2, getItemSpell(item))));
end

local function matchesCastSpell(cast, spellID)
	return matchesSpellID(spellID, cast.spellID)
		or (cast.eventSpellID ~= cast.spellID and matchesSpellID(spellID, cast.eventSpellID))
		or matchesSpellNameAndIcon(spellID, cast.name, cast.icon);
end

local function matchButtonSpell(button, cast, kind, action)
	local spellID = getClusterCastSpell(button, kind, action);
	if matchesCastSpell(cast, spellID) then return spellID, true end;
	if ( kind == 'action' and action and C_ActionBar and C_ActionBar.GetSpell ) then
		-- The client can resolve a spell from this slot differently from GetActionInfo.
		local slotSpell = publicCastValue(C_ActionBar.GetSpell(action));
		if slotSpell and slotSpell > 0 and matchesCastSpell(cast, slotSpell) then
			return slotSpell, true;
		end
	end
	return spellID, false;
end

local function matchesCurrentSlot(cast, spellID, slot)
	-- Ranks and temporary replacements can share a name on Classic.
	if (CPAPI.IsCamelotVersion or CPAPI.IsClassicVersion) and slot and spellID and cast.spellID
		and isCurrentAction and getSpellName and publicCastValue(isCurrentAction(slot)) then
		local name = publicCastValue((getSpellName(spellID)));
		return name and name == publicCastValue((getSpellName(cast.spellID)));
	end
end

---------------------------------------------------------------
-- Masked icon effects
---------------------------------------------------------------
-- Ground-targeting animation: green while placing a spell.
local TARGETING_COLOR = {0; 1; 0; 1};
-- Active-toggle glow: Pet Ring amber with a short fade when the state changes.
local TOGGLE_COLOR = {1; 214 / 255; 125 / 255; .60};
-- Attack and queued next-swing abilities share a white glow at 60% opacity.
local ATTACK_TOGGLE_COLOR = {1; 1; 1; .60};
local TOGGLE_FADE_IN, TOGGLE_FADE_OUT = .18, .38; -- Seconds to light up and fade back out.
local PULSE_TEXTURE = env.GetAsset([[Textures\Cluster\Glow\Targeting]]);
-- Same atlas cells as Targeting.png, with a tighter alpha falloff baked in.
local TOGGLE_TEXTURE = env.GetAsset([[Textures\Cluster\Glow\Toggle]]);
local PULSE_COORDS = {};
local activeFormSpell;
do -- Each cell is an inward fade traced from its corresponding icon mask.
	local rows = {
		{'Round'; 'HexMain'; 'HexFlyout'; 'HexSidewaysMain'; 'HexSidewaysFlyout'; 'SquaredMain'; 'SquaredFlyout'};
		{'M1_DOWN'; 'M1_LEFT'; 'M1_RIGHT'; 'M1_UP'};
		{'M2_DOWN'; 'M2_LEFT'; 'M2_RIGHT'; 'M2_UP'};
		{'M3_DOWN'; 'M3_LEFT'; 'M3_RIGHT'; 'M3_UP'};
	};
	-- Both atlases are 512 x 256 pixels, with 64 x 64 cells. Sample from the first
	-- to the last pixel center (.5 to 63.5) so filtering cannot pull in the next shape.
	for row, shapes in ipairs(rows) do
		local y = (row - 1) * 64;
		for col, shape in ipairs(shapes) do
			local x = (col - 1) * 64;
			PULSE_COORDS[shape] = {(x + .5) / 512; (x + 63.5) / 512; (y + .5) / 256; (y + 63.5) / 256};
		end
	end
end

local nextSwingSpells, scanTooltip = {};
local function isNextSwingSpell(spellID)
	if not spellID or not SPELL_ON_NEXT_SWING then return end;
	if nextSwingSpells[spellID] then return true end;
	-- Only a checked spell needs classification. Match Blizzard's localized cast-time label.
	if C_TooltipInfo and C_TooltipInfo.GetSpellByID then
		local data = publicCastValue(C_TooltipInfo.GetSpellByID(spellID));
		local lines = data and publicCastValue(data.lines);
		if not lines then return end;
		for _, line in ipairs(lines) do
			if publicCastValue(line.leftText) == SPELL_ON_NEXT_SWING
				or publicCastValue(line.rightText) == SPELL_ON_NEXT_SWING then
				nextSwingSpells[spellID] = true;
				return true;
			end
		end
	else
		scanTooltip = scanTooltip or CreateFrame('GameTooltip', 'ConsolePortClusterSpellScan', UIParent, 'GameTooltipTemplate');
		scanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		scanTooltip:ClearLines()
		scanTooltip:SetSpellByID(spellID)
		for _, region in ipairs({scanTooltip:GetRegions()}) do
			if region:IsObjectType('FontString') and region:IsShown() and publicCastValue(region:GetText()) == SPELL_ON_NEXT_SWING then
				nextSwingSpells[spellID] = true;
				break;
			end
		end
		scanTooltip:Hide()
		return nextSwingSpells[spellID];
	end
end

local function getClusterToggleColor(button, kind, action)
	local spellID = action;
	if kind == 'action' and action then
		local actionType, id, subType = GetActionInfo(action);
		if publicCastValue(actionType) ~= 'spell' or CPAPI.IsSecret(subType) then return end;
		spellID = publicCastValue(id);
		if subType == 'pet' then
			if not isCurrentAction or not publicCastValue(isCurrentAction(action)) then return nil, spellID end;
			-- Pet Attack and autocast abilities have their own feedback.
			local attack = isAttackAction and isAttackAction(action);
			local autoCast = isAutoCastPetAction and isAutoCastPetAction(action);
			if not (CPAPI.IsSecret(attack) or attack or CPAPI.IsSecret(autoCast) or autoCast) then
				return TOGGLE_COLOR, spellID;
			end
			return nil, spellID;
		end
		if isCurrentAction and publicCastValue(isCurrentAction(action))
			and ((isAttackAction and publicCastValue(isAttackAction(action))) or isNextSwingSpell(spellID)) then
			return ATTACK_TOGGLE_COLOR, spellID;
		end
	elseif kind ~= 'spell' then
		return;
	elseif spellID and publicCastValue(button:IsCurrentlyActive())
		and (publicCastValue(button:IsAttack()) or isNextSwingSpell(spellID)) then
		return ATTACK_TOGGLE_COLOR, spellID;
	end
	if activeFormSpell and spellID == activeFormSpell then return TOGGLE_COLOR, spellID end;
	return nil, spellID;
end

-- Clip both effects to the icon and keep them beneath the rim.
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
	-- Each half of the targeting pulse takes 0.6 seconds, between 40% and 90% opacity.
	pulse:SetFromAlpha(.40)
	pulse:SetToAlpha(.90)
	pulse:SetDuration(.6)
	pulse:SetSmoothing('IN_OUT')
	group:SetLooping('BOUNCE')
	return group;
end

local toggleFades, toggleFadeFrame = {};

local function updateToggleFades(frame)
	local now = GetTime();
	for glow, fade in pairs(toggleFades) do
		local progress = math.min(1, (now - fade.start) / fade.duration);
		glow:SetAlpha(Lerp(fade.from, fade.to, env.SmoothStep(progress)))
		if progress == 1 then
			toggleFades[glow] = nil;
			glow:SetShown(fade.to > 0)
		end
	end
	if not next(toggleFades) then frame:Hide() end;
end

-- Active-toggle animation: apply the Pet Ring's easing directly to the glow.
local function setToggleGlowAlpha(glow, show, instant)
	local from = glow:GetAlpha();
	local to = show and 1 or 0;
	if instant or from == to then
		toggleFades[glow] = nil;
		glow:SetAlpha(to)
		glow:SetShown(show)
		return;
	end
	if not toggleFadeFrame then
		toggleFadeFrame = CreateFrame('Frame');
		toggleFadeFrame:SetScript('OnUpdate', updateToggleFades)
	end
	toggleFades[glow] = {start = GetTime(); duration = show and TOGGLE_FADE_IN or TOGGLE_FADE_OUT; from = from; to = to;};
	glow:Show()
	toggleFadeFrame:Show()
end

local function syncClusterPulse(button)
	local color, kind, action, spellID;
	if button.clusterPulseCoords and button:IsVisible() then
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
	local previous = button.clusterPulseColor;
	local glow = button.clusterPulseGlow;
	if color == previous and not (actionChanged and glow and glow:IsShown() and color ~= TARGETING_COLOR) then return end;
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
	if button.AlphaState and targeting ~= wasTargeting then
		button:UpdateAlpha(button.AlphaState.Targeting, targeting)
	end
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

local function syncClusterPulses()
	env:Map(CLUSTER_BUTTON, nil, syncClusterPulse)
end

local function syncClusterForm()
	-- The checked border can also mean a queued cast. Read the actual player form.
	local form = publicCastValue(GetShapeshiftForm());
	local spellID = form and form > 0 and publicCastValue((select(4, GetShapeshiftFormInfo(form)))) or nil;
	if spellID == activeFormSpell then return end;
	activeFormSpell = spellID;
	syncClusterPulses()
end

local function updateTargetingButtons(target)
	if target ~= activeTarget then return end;
	syncClusterPulses()
end

local function clearClusterTargeting(spellID)
	if not activeTarget or (spellID and spellID ~= activeTarget.spellID) then return end;
	activeTarget = nil;
	updateTargetingButtons()
end

---------------------------------------------------------------
-- Empower animation
---------------------------------------------------------------
-- Start violet, transition from ember toward gold at intermediate ranks, and hold gold at max rank.
local VIOLET = {.70; .34; 1};
local EMBER  = {1; .43; .17};
local GOLD   = {1; .80; .34};
-- After a rank change, crossfade the fill for 220 ms. The 350 ms flare peaks at 80 ms.
local EMPOWER_BLEND_MS, EMPOWER_PULSE_MS, EMPOWER_PULSE_PEAK_MS = 220, 350, 80;

local function empowerRank(cast, elapsed)
	local rank = #cast.stages;
	while rank > 0 and elapsed < cast.stages[rank] do rank = rank - 1 end;
	return rank;
end

local function empowerColor(rank, count)
	if rank > 0 and rank == count then return unpack(GOLD) end;
	if rank < 2 then return unpack(VIOLET) end;
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
	if now > cast.holdEnd + CHANNEL_END_TOLERANCE_MS then return frame:Hide() end;

	local elapsed = math.max(0, now - cast.startTime);
	local total = cast.stages[#cast.stages];
	local rank = empowerRank(cast, elapsed);
	local stageTime = cast.stages[rank];
	local age = stageTime and elapsed - stageTime or math.huge;
	local progress = math.min(1, elapsed / total);
	local r, g, b = empowerColor(rank, #cast.stages);
	if rank > 0 and age < EMPOWER_BLEND_MS then
		local pr, pg, pb = empowerColor(rank - 1, #cast.stages);
		local t = age / EMPOWER_BLEND_MS;
		local blend = env.SmoothStep(t);
		r, g, b = Lerp(pr, r, blend), Lerp(pg, g, blend), Lerp(pb, b, blend);
	end

	local mask          = effect.Mask;
	local scale         = frame:GetScale();
	local width, height = mask:GetSize();
	local button        = frame:GetParent();
	local shape         = button.clusterShape;
	local inset         = not button.layoutData.Prefix and shape and shape.MainHitInset or 0;
	-- Convert the visible icon bounds into cast-frame units, trimming the square rim padding on both sides.
	local geometry      = (1 - 2 * inset) / scale;
	width, height       = width * geometry, height * geometry;
	-- Oversize the sprite to fill the corners. Its bright front sits 42% of its height
	-- above center and travels from just below the icon to just above it.
	local fillHeight = height * 1.24;
	local front      = height * (1.08 * progress - .55);
	effect.Fill:SetSize(width * 1.13, fillHeight)
	effect.Fill:SetPoint('CENTER', mask, 'CENTER', 0, front - fillHeight * .42)
	effect.Fill:SetVertexColor(r, g, b)
	-- Bring in the 14% background tint over the first tenth of the cast.
	effect.Inner:SetVertexColor(r, g, b, .14 * math.min(1, progress * 10))

	local pulse = effect.Pulse;
	pulse:SetShown(age < EMPOWER_PULSE_MS)
	if pulse:IsShown() then
		-- Expand the flare at the crossed threshold. Cap its height at 92% of the icon
		-- so the final flare stays visible, and mix white into the rank color for contrast.
		local spread = age / EMPOWER_PULSE_MS;
		local peak = age < EMPOWER_PULSE_PEAK_MS and age / EMPOWER_PULSE_PEAK_MS
			or ((EMPOWER_PULSE_MS - age) / (EMPOWER_PULSE_MS - EMPOWER_PULSE_PEAK_MS)) ^ 1.55;
		local nr, ng, nb = empowerColor(rank, #cast.stages);
		pulse:SetSize(width * (.89 + spread * .29), height * (.32 + spread * .25))
		pulse:SetPoint('CENTER', mask, 'CENTER', 0, height * (math.min(.92, stageTime / total) - .5))
		pulse:SetVertexColor(Lerp(nr, 1, .55), Lerp(ng, 1, .55), Lerp(nb, 1, .55))
		pulse:SetAlpha(peak * Lerp(.73, 1, rank / #cast.stages))
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
		-- Map the atlas's bright right edge to the top without shrinking the sprite.
		local l, r, t, b = atlas.leftTexCoord, atlas.rightTexCoord, atlas.topTexCoord, atlas.bottomTexCoord;
		effect.Fill:SetTexture(atlas.file or atlas.filename)
		effect.Fill:SetTexCoord(r, t, l, t, r, b, l, b)
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

-- Swing and instant success share a 0.42-second burst that expands 24% and fades from 70% opacity.
env.ClusterBurstDuration = .42;

function env:CreateClusterBurst(parent, mask, red, green, blue)
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
	scale:SetScale(1.24, 1.24)
	scale:SetDuration(self.ClusterBurstDuration)
	scale:SetSmoothing('OUT')

	local fade = group:CreateAnimation('Alpha');
	fade:SetFromAlpha(.70)
	fade:SetToAlpha(0)
	fade:SetDuration(self.ClusterBurstDuration)
	fade:SetSmoothing('IN_OUT')
	local hide = GenerateClosure(glow.Hide, glow);
	group:SetScript('OnFinished', hide)
	group:SetScript('OnStop', hide)
	return group;
end

-- Interrupt flash fades a 55% white overlay to clear in 0.20 seconds inside the icon mask.
local INTERRUPT_DURATION = .20;

local function createInterruptFlash(button)
	local mask = env.LIB.SkinUtility.GetIconMask(button);
	local glow = button:CreateTexture(nil, 'ARTWORK', nil, 2);
	glow:SetAllPoints(mask)
	glow:AddMaskTexture(mask)
	glow:SetColorTexture(1, 1, 1, 1)
	glow:SetBlendMode('BLEND')

	local group = glow:CreateAnimationGroup();
	local fade = group:CreateAnimation('Alpha');
	fade:SetFromAlpha(.55)
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

-- Instant-cast success burst: draw above the sweeps and below the rim.
local function playClusterInstant(button, cast)
	if not (button.clusterSkinLayered and button:IsVisible()) then return end;
	local kind, action = getClusterCastAction(button);
	local _, matches = matchButtonSpell(button, cast, kind, action);
	if not matches or (kind == 'action' and action and isAttackAction and publicCastValue(isAttackAction(action))) then
		return;
	end
	local burst = button.clusterInstantBurst;
	if not burst then
		local mask = env.LIB.SkinUtility.GetIconMask(button);
		-- Keep the warm yellow finish tint used by instant casts.
		burst = env:CreateClusterBurst(button, mask, 248 / 255, 236 / 255, 181 / 255);
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
	local sameButton = shownCast == cast and frame.clusterCastSpell == buttonSpell and frame.clusterCastAction == action
		and frame.clusterCastActionType == kind;
	matches = matches or sameButton or matchesCurrentSlot(cast, buttonSpell, slot);
	if ( shownCast and (shownCast ~= cast or not matches) ) then
		frame:Hide()
	end
	if not (activeCast and matches) then return end;
	if checkLive and not sameButton and not readClusterCast(cast) then return end;

	local now = GetTime();
	if now * 1000 >= (cast.holdEnd or cast.endTime) then return end;
	local starting = frame.clusterCast ~= cast;
	if starting then stopClusterFeedback(button) end;
	frame.clusterCastSpell, frame.clusterCastAction, frame.clusterCastActionType = buttonSpell, action, kind;
	if cast.castType == EMPOWER then
		if starting then startClusterEmpower(button, frame, cast) end;
		return;
	end
	if not (starting or timingChanged) then return end;
	if starting then
		frame.clusterCast = cast;
		frame.EndBurst.FinishCastAnim:Stop()
		frame.EndBurst:Hide()
		-- Match Blizzard's stock art and travel using the same cast snapshot
		-- for every button, including buttons that become visible mid-cast.
		local fill      = frame.Fill;
		local isChannel = cast.castType == CHANNEL;
		local direction = isChannel and -1 or 1;
		fill.CastFill:ClearAllPoints()
		fill.CastFill:SetAtlas(isChannel and 'UI-HUD-ActionBar-Channel-Fill' or 'UI-HUD-ActionBar-Cast-Fill', true)
		fill.InnerGlowTexture:SetColorTexture(unpack(isChannel and CHANNEL_TINT or CAST_TINT))
		fill.CastFill:SetPoint('CENTER', -45 * direction, 0)
		fill.CastingAnim.CastFillTranslation:SetOffset(43 * direction, 0)
		fill:Show()
		frame:Show()
	end

	local animation = frame.Fill.CastingAnim;
	animation:Stop()
	animation.CastFillTranslation:SetDuration((cast.endTime - cast.startTime) / 1000)
	animation:Play(false, math.max(0, now - cast.startTime / 1000))
end

local function refreshClusterAction(button)
	local feedback = button.clusterCastFeedback;
	if feedback then
		local kind, action = getClusterCastAction(button);
		if kind ~= feedback.actionType or action ~= feedback.action then feedback:Stop() end;
	end
	syncClusterCast(button, false, true)
	syncClusterPulse(button)
end

local function onActionAttributeChanged(button, attribute)
	if (activeCast or button.clusterPulseCoords or button.clusterCastFeedback) and (attribute == 'type' or attribute == 'action') then
		CPAPI.Next(refreshClusterAction, button)
	end
end

local function finishClusterCast(button, cast, transition)
	local frame = button.SpellCastAnimFrame;
	if not frame or frame.clusterCast ~= cast then return end;
	if transition == 'interrupt' and button:IsVisible() then
		local kind, action = getClusterCastAction(button);
		if kind == frame.clusterCastActionType and action == frame.clusterCastAction then
			button.clusterInterruptFlash = button.clusterInterruptFlash or createInterruptFlash(button);
			playClusterFeedback(button, button.clusterInterruptFlash, kind, action)
		end
	end
	if transition ~= 'finish' then return frame:Hide() end;
	if frame.EndBurst:IsShown() then return end;
	if cast.castType == EMPOWER then
		stopClusterEmpower(frame)
		local ring = frame.EndBurst.GlowRing;
		local rank = empowerRank(cast, GetTime() * 1000 - cast.startTime);
		ring:SetDesaturated(true)
		ring:SetVertexColor(empowerColor(rank, #cast.stages))
	end
	frame:FinishAnimAndPlayBurst()
	frame.Fill:Hide()
end

---------------------------------------------------------------
-- Player cast events
---------------------------------------------------------------
local function matchesCastEvent(cast, castType, guid, spellID, castBarID)
	if not cast or (castType and cast.castType ~= castType) then return false end;
	local sameCast = sameCastIdentity(cast, guid, castBarID);
	if sameCast ~= nil then return sameCast end;
	return matchesCastSpell(cast, spellID);
end

local function playConfirmedInstant(guid, spellID, castBarID)
	local sentAt = sentCasts[guid];
	sentCasts[guid] = nil;
	if not sentAt or GetTime() - sentAt > SENT_CAST_LIFETIME then return end;
	if matchesCastEvent(pendingCast, nil, guid, spellID, castBarID)
		or matchesCastEvent(activeCast, nil, guid, spellID, castBarID) then return end;
	if (isAutoAttackSpell and publicCastValue(isAutoAttackSpell(spellID)))
		or (isAutoRepeatSpell and publicCastValue(isAutoRepeatSpell(spellID))) then return end;
	env:Map(CLUSTER_BUTTON, nil, playClusterInstant, {spellID = spellID;})
end

local function applyClusterCast(cast)
	-- A queued retry can outlive the cast that scheduled it.
	if cast ~= activeCast and cast ~= pendingCast then return end;
	local startTime, endTime = cast.startTime, cast.endTime;
	if not readClusterCast(cast) then return end;
	if pendingCast == cast then pendingCast = nil end;
	if activeCast and activeCast ~= cast then
		env:Map(CLUSTER_BUTTON, nil, finishClusterCast, activeCast)
	end
	activeCast = cast;
	env:Map(CLUSTER_BUTTON, nil, syncClusterCast, startTime ~= cast.startTime or endTime ~= cast.endTime)
end

local function onActionBarUpdateState()
	local cast = pendingCast or activeCast;
	if cast then applyClusterCast(cast) end;
	syncClusterPulses()
end

local function clearClusterCast(cast, transition)
	if activeCast ~= cast then return end;
	activeCast = nil;
	env:Map(CLUSTER_BUTTON, nil, finishClusterCast, cast, transition)
end

local function onClusterCastEvent(info, _, _, guid, spellID, ...)
	guid, spellID = publicCastValue(guid), publicCastValue(spellID);
	local castType, transition, barPosition = unpack(info);
	local castBarID = publicCastValue((select(barPosition or 1, ...)));
	local matchesPending = matchesCastEvent(pendingCast, castType, guid, spellID, castBarID);
	local matchesActive = matchesCastEvent(activeCast, castType, guid, spellID, castBarID);
	if guid and sentCasts[guid] then
		if castType == CAST and transition == 'finish' and type(spellID) == 'number' and spellID > 0
			and not (matchesPending or matchesActive) then
			-- A channel can send SUCCEEDED immediately before its start event.
			CPAPI.Next(playConfirmedInstant, guid, spellID, castBarID)
		elseif transition ~= 'stop' then
			sentCasts[guid] = nil;
		end
	end
	if transition == 'start' or transition == 'update' then
		local existing = matchesPending and pendingCast or matchesActive and activeCast;
		if existing then return applyClusterCast(existing) end;
		if transition == 'update' and activeCast then return end;
		if not (guid or spellID or castBarID) then return end;
		local cast = {
			castType     = castType;
			guid         = guid;
			eventSpellID = spellID;
			castBarID    = castBarID;
		};
		pendingCast = cast;
		applyClusterCast(cast)
		-- The live cast and action slots can settle after the event.
		CPAPI.Next(applyClusterCast, cast)
		C_Timer.After(CAST_START_RETRY_DELAY, GenerateClosure(applyClusterCast, cast))
		return;
	end

	if matchesPending then pendingCast = nil end;
	if not matchesActive then return end;
	local cast = activeCast;
	local result = ...;
	if castType == EMPOWER then
		local interruptedBy = publicCastValue((select(2, ...)));
		transition = type(interruptedBy) == 'string' and 'interrupt'
			or publicCastValue(result) == true and 'finish' or 'cancel';
	elseif castType == CHANNEL then
		local interruptedBy = publicCastValue(result);
		local complete = not CPAPI.IsSecret(result) and not result
			and GetTime() * 1000 + CHANNEL_END_TOLERANCE_MS >= cast.endTime;
		transition = type(interruptedBy) == 'string' and 'interrupt' or complete and 'finish' or 'cancel';
	end
	if transition == 'stop' or transition == 'cancel' then
		-- A success or explicit interruption can follow a generic stop in the same frame.
		return CPAPI.Next(clearClusterCast, cast);
	end
	clearClusterCast(cast, transition)
end

local function onReticleTarget(_, _, _, spellID)
	spellID = publicCastValue(spellID);
	if not spellID or (activeTarget and activeTarget.spellID == spellID) then return end;
	local target = {spellID = spellID;};
	activeTarget = target;
	updateTargetingButtons(target)
	CPAPI.Next(updateTargetingButtons, target)
end

local function onReticleClear(_, _, _, spellID)
	clearClusterTargeting(publicCastValue(spellID))
end

local function onCastSent(_, unit, _, guid, spellID)
	if unit ~= 'player' then return end;
	guid = publicCastValue(guid);
	if guid then
		local now = GetTime();
		for key, sentAt in pairs(sentCasts) do
			if now - sentAt > SENT_CAST_LIFETIME then sentCasts[key] = nil end;
		end
		sentCasts[guid] = now;
	end
	local target = activeTarget;
	if not target or publicCastValue(spellID) ~= target.spellID then return end;
	CPAPI.Next(function()
		if activeTarget == target and not SpellIsTargeting() then
			clearClusterTargeting(target.spellID)
		end
	end)
end

local CastHandler;
local function initializeCastHandler()
	if CastHandler then return end;
	CastHandler = CPAPI.CreateEventHandler({'Frame'});
	CastHandler.UNIT_SPELLCAST_RETICLE_TARGET = onReticleTarget;
	CastHandler.UNIT_SPELLCAST_RETICLE_CLEAR  = onReticleClear;
	CastHandler.UNIT_SPELLCAST_SENT           = onCastSent;
	CastHandler.ACTIONBAR_UPDATE_STATE        = onActionBarUpdateState;
	CastHandler.PLAYER_ENTER_COMBAT           = syncClusterPulses;
	CastHandler.PLAYER_LEAVE_COMBAT           = syncClusterPulses;
	CastHandler.PET_BAR_UPDATE               = syncClusterPulses;
	CastHandler.UNIT_PET                     = syncClusterPulses;
	CastHandler.PLAYER_ENTERING_WORLD        = syncClusterForm;
	CastHandler.UPDATE_SHAPESHIFT_FORM       = syncClusterForm;
	CPAPI.RegisterFrameForEvents(CastHandler, {
		'UNIT_SPELLCAST_SENT'; 'ACTIONBAR_UPDATE_STATE'; 'PET_BAR_UPDATE'; 'PLAYER_ENTERING_WORLD'; 'UPDATE_SHAPESHIFT_FORM';
		'PLAYER_ENTER_COMBAT'; 'PLAYER_LEAVE_COMBAT';
	})
	CPAPI.RegisterFrameForUnitEvents(CastHandler, {'UNIT_PET'}, 'player')
	local events = {'UNIT_SPELLCAST_RETICLE_TARGET'; 'UNIT_SPELLCAST_RETICLE_CLEAR';};
	local canEmpower = GetUnitEmpowerStageDuration and GetUnitEmpowerHoldAtMaxTime and C_Texture and C_Texture.GetAtlasInfo;
	for event, info in pairs(CAST_EVENTS) do
		if ( info[1] ~= EMPOWER or canEmpower ) then
			CastHandler[event] = GenerateClosure(onClusterCastEvent, info);
			events[#events + 1] = event;
		end
	end
	CPAPI.RegisterFrameForUnitEvents(CastHandler, events, 'player')
	syncClusterForm()
end

---------------------------------------------------------------
-- Button initialization
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

local function onCastAnimationFinished(animation)
	animation:GetParent():GetParent():Hide()
end

function env:InitializeClusterCast(button)
	local frame = button.SpellCastAnimFrame;
	-- Classic loads the shared template, but its action buttons do not inherit it.
	if not frame and ActionButtonCastingAnimFrameMixin then
		frame = CreateFrame('Frame', nil, button, 'ActionButtonCastingAnimFrameTemplate');
		frame:SetScript('OnHide', nil)
		frame:Hide()
		button.SpellCastAnimFrame = frame;
	end
	if frame then
		frame:SetScript('OnShow', onCastFrameShow)
		frame:SetScript('OnHide', onCastFrameHide)
		-- The native fill normally starts a finish burst on its own. Only play it
		-- from the confirmed finish path so an interrupted cast can't flash late.
		frame.Fill.CastingAnim:SetScript('OnFinished', onCastAnimationFinished)
		frame.EndBurst.FinishCastAnim:SetScript('OnFinished', onCastAnimationFinished)
	end
	hooksecurefunc(button, 'UpdateAction', refreshClusterAction)
	hooksecurefunc(button, 'OnActionBarSlotChanged', refreshClusterAction)
	button:HookScript('OnShow', refreshClusterAction)
	button:HookScript('OnHide', syncClusterPulse)
	button:HookScript('OnHide', stopClusterFeedback)
	button:HookScript('OnAttributeChanged', onActionAttributeChanged)
	initializeCastHandler()
end
