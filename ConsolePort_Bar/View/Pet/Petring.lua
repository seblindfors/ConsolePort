local env, db = CPAPI.GetEnv(...)
local FadeIn, FadeOut = db.Alpha.FadeIn, db.Alpha.FadeOut;
local IsSecret = CPAPI.IsSecret;
---------------------------------------------------------------
local PET_STATUS_TEXTURE      = env.GetAsset[[Textures\PetRing\StatusFill.png]];
local PET_STATE_MASK          = env.GetAsset[[Textures\PetRing\StateMask.png]];
local PET_STATE_OUTLINE       = env.GetAsset[[Textures\PetRing\StateOutline.png]];
local PET_STATE_PULSE         = env.GetAsset[[Textures\PetRing\StatePulse.png]];
local PET_COOLDOWN_SWIPE      = env.GetAsset[[Textures\PetRing\CooldownSwipe.png]];
local HALF_MASK               = env.GetAsset[[Textures\Masks\PetPowerMask]];
local PET_COOLDOWN_ALPHA      = 163 / 255; -- Fixed black shading for pet slots.
local COOLDOWN_SIZE           = 48;
local SWIPE_ATLAS_GRID_SIZE   = 4;
local TEXTURED_RIM_BRIGHTNESS = 0.86; -- Resting brightness of the gold and beveled rims.
local UPDATE_INTERVAL         = 0.1; -- Refresh status and check for expired wedge cooldowns ten times per second.
-- Autocast is yellow, an active command is amber, and a pet action briefly flashes pale gold.
local AUTOCAST_GLOW                 = {1; 240 / 255; 77 / 255;};
local ACTIVE_GLOW                   = {1; 214 / 255; 125 / 255;};
local ACTION_GLOW                   = {1; .93; .72;};
-- Outline fades are in seconds. The expanding pulse lasts 0.48 s and peaks 23% of the way through.
local GLOW_FADE_IN, GLOW_FADE_OUT   = .18, .38;
local PULSE_DURATION, PULSE_PEAK    = .48, .23;
local PULSE_MIN_SIZE, PULSE_MAX_SIZE = 10.4, 55; -- Pulse size in UI units before the wedge mask clips it.
-- State changes have a stronger flash than individual casts or attacks.
local STATE_PULSE_ALPHA, ACTION_PULSE_ALPHA = .72, .54;
local ACTION_PULSE_INTERVAL         = .12; -- Seconds to suppress duplicate action events.
local getCombatEvent = not CPAPI.IsModernVersion and CombatLogGetCurrentEventInfo;

local function getPetRingTextures(style)
	local path = env.GetAsset([[Textures\PetRing\%s]], style);
	return {
		Portrait = path .. 'Portrait.png';
		Wheel    = path .. 'Wheel.png';
		Status   = path .. 'Status.png';
		Slot     = path .. 'Slot.png';
	};
end

local PET_RING_TEXTURES = {
	Original = getPetRingTextures('RoundSilver');
	Beveled  = getPetRingTextures('BeveledSilver');
	Gold     = getPetRingTextures('Gold');
};
---------------------------------------------------------------
CPPetRingButton = Mixin({
---------------------------------------------------------------
	ActiveIconVertex   = CreateColor(1.0, 1.0, 1.0);
	InactiveIconVertex = CreateColor(0.4, 0.4, 0.4);
}, CPActionButtonMixin);
---------------------------------------------------------------

local function animateStateGlow(glow)
	local now = GetTime();
	if glow.fadeStart then
		local enabled  = glow.color ~= nil;
		local duration = enabled and GLOW_FADE_IN or GLOW_FADE_OUT;
		local progress = math.min(1, (now - glow.fadeStart) / duration);
		glow.Outline:SetAlpha(Lerp(glow.startAlpha, enabled and 1 or 0, env.SmoothStep(progress)))
		if progress == 1 then glow.fadeStart = nil end;
	end
	if glow.pulseStart then
		local progress = (now - glow.pulseStart) / PULSE_DURATION;
		if progress >= 1 then
			glow.pulseStart, glow.pulseColor = nil, nil;
			glow.Pulse:Hide()
		else
			local intensity = progress < PULSE_PEAK and env.SmoothStep(progress / PULSE_PEAK)
				or env.SmoothStep((1 - progress) / (1 - PULSE_PEAK));
			-- Quadratic ease-out makes the pulse expand quickly, then settle against the rim.
			local size  = Lerp(PULSE_MIN_SIZE, PULSE_MAX_SIZE, 1 - (1 - progress) ^ 2);
			local alpha = glow.pulseColor == ACTION_GLOW and ACTION_PULSE_ALPHA or STATE_PULSE_ALPHA;
			glow.Pulse:SetSize(size, size)
			glow.Pulse:SetAlpha(alpha * intensity)
		end
	end
	if not (glow.fadeStart or glow.pulseStart) then
		glow:SetScript('OnUpdate', nil)
	end
end

local function createStateGlow(button)
	local wheel = button:GetParent().Ring;
	local glow  = CreateFrame('Frame', nil, button);
	glow:SetAllPoints(button)
	glow:SetFrameLevel(wheel:GetFrameLevel() - 1)
	-- Both wedge textures use the right-hand slot in the wheel's coordinate space.
	local mask = glow:CreateMaskTexture(nil, 'ARTWORK');
	mask:SetAllPoints(wheel.Mask)
	mask:SetTexture(PET_STATE_MASK, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	mask:SetRotation(button.wedgeRotation)

	local outline = glow:CreateTexture(nil, 'ARTWORK', nil, 1);
	outline:SetAllPoints(wheel.Mask)
	outline:SetTexture(PET_STATE_OUTLINE, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	outline:SetRotation(button.wedgeRotation)
	outline:SetBlendMode('BLEND')
	outline:SetAlpha(0)

	local pulse = glow:CreateTexture(nil, 'ARTWORK', nil, 2);
	pulse:SetPoint('CENTER')
	pulse:SetTexture(PET_STATE_PULSE)
	pulse:SetBlendMode('ADD')
	pulse:AddMaskTexture(mask)
	pulse:Hide()

	glow.Outline, glow.Pulse, button.StateGlow = outline, pulse, glow;
	return glow;
end

local function playGlowPulse(glow, color)
	glow.pulseStart, glow.pulseColor = GetTime(), color;
	glow.Pulse:SetVertexColor(unpack(color))
	glow.Pulse:Show()
	glow:SetScript('OnUpdate', animateStateGlow)
	animateStateGlow(glow)
end

function CPPetRingButton:PlayActionPulse()
	if not self:IsVisible() then return end;
	local now = GetTime();
	-- A cast can be reported by both the unit event and the classic combat log.
	if self.lastActionPulse and now - self.lastActionPulse < ACTION_PULSE_INTERVAL then return end;
	self.lastActionPulse = now;
	playGlowPulse(self.StateGlow or createStateGlow(self), ACTION_GLOW)
end

function CPPetRingButton:UpdateStateGlow(color, actionChanged)
	local glow = self.StateGlow;
	if not (color or glow) then return end;
	glow = glow or createStateGlow(self);
	if glow.color == color and not actionChanged then return end;
	glow.color = color;
	if color then
		glow.Outline:SetVertexColor(unpack(color))
	end
	if actionChanged or not self:IsVisible() then
		glow.fadeStart, glow.pulseStart, glow.pulseColor = nil, nil, nil;
		glow:SetScript('OnUpdate', nil)
		glow.Outline:SetAlpha(color and 1 or 0)
		glow.Pulse:Hide()
		return;
	end
	glow.fadeStart, glow.startAlpha = GetTime(), glow.Outline:GetAlpha();
	glow:SetScript('OnUpdate', animateStateGlow)
	if color and glow.pulseColor ~= ACTION_GLOW then playGlowPulse(glow, color) end;
end

function CPPetRingButton:Init(i)
	local radius = 68;
	-- Slot four is at three o'clock. Advance clockwise by one wedge per slot.
	local slotAngle = rad(360 / NUM_PET_ACTION_SLOTS);
	local angle = (i - 4) * slotAngle;

	self.textureRotation = rad(270) - angle;
	self.wedgeRotation    = -angle;
	self:SetAttribute('action', i)
	self:SetPoint('CENTER', radius * math.cos(angle), -radius * math.sin(angle))

	local name = self:GetName()
	self.cooldown       = self.cooldown or _G[name..'Cooldown'];
	self.NormalTexture  = self.NormalTexture or _G[name..'NormalTexture']
	self.NormalTexture2 = _G[name..'NormalTexture2'] or self.NormalTexture

	if self.SlotBackground then
		self.SlotBackground:SetTexture(nil)
		self.SlotBackground:ClearAllPoints()
		self.SlotBackground:Hide()
	end

	self.HotKey:SetAlpha(0)

	if self.IconMask then
		self.icon:RemoveMaskTexture(self.IconMask)
	end
	local wheel = self:GetParent().Ring;
	-- Keep the wheel art aligned across buttons. Two half-plane masks meet at the
	-- slot boundaries, so this button's alpha fades exactly its own piece of the rim.
	local rim = self:CreateTexture(nil, 'BACKGROUND');
	rim:SetAllPoints(wheel)
	local halfSlot = slotAngle / 2;
	for _, rotation in ipairs({-halfSlot; math.pi + halfSlot}) do
		local mask = self:CreateMaskTexture(nil, 'ARTWORK');
		-- Extend the rotated mask past the wheel's antialiased outer edge.
		mask:SetPoint('TOPLEFT', wheel, 'TOPLEFT', -2, 2)
		mask:SetPoint('BOTTOMRIGHT', wheel, 'BOTTOMRIGHT', 2, -2)
		mask:SetTexture(HALF_MASK, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		mask:SetRotation(self.wedgeRotation + rotation)
		rim:AddMaskTexture(mask)
	end
	self.Rim = rim;

	-- Stack the icon, swipe, glow, and wheel rim in that order.
	local iconFrame = CreateFrame('Frame', nil, self);
	iconFrame:SetAllPoints(self)
	iconFrame:SetFrameLevel(wheel:GetFrameLevel() - 3)
	self.icon:SetParent(iconFrame)
	self.icon:SetDrawLayer('BACKGROUND')
	self.icon:AddMaskTexture(wheel.Mask)
	self.icon:SetRotation(self.textureRotation)
	self.icon:SetAllPoints()

	local autocastable = self.AutoCastable or _G[name..'AutoCastable'];
	local shine       = self.Shine or self.AutoCastShine or _G[name..'Shine'];
	if autocastable then autocastable:Hide() end;
	if shine then shine:Hide() end;
	if self.AutoCastOverlay then self.AutoCastOverlay:Hide() end;

	self.NormalTexture:SetTexture(nil)
	self.NormalTexture:ClearAllPoints()
	self.NormalTexture:SetPoint('CENTER', 0, 0)

	self.NormalTexture2:SetTexture(nil)
	self.NormalTexture2:ClearAllPoints()
	self.NormalTexture2:SetPoint('CENTER', 0, 0)

	self.PushedTexture    = self:GetPushedTexture()
	self.HighlightTexture = self:GetHighlightTexture()
	self:GetCheckedTexture():SetTexture(nil)

	self.PushedTexture:SetPoint('TOPLEFT', -6, 6)
	self.PushedTexture:SetPoint('BOTTOMRIGHT', 6, -6)
	self.PushedTexture:SetRotation(self.textureRotation)
	self.PushedTexture:SetBlendMode('BLEND')

	self.HighlightTexture:SetPoint('TOPLEFT', -6, 6)
	self.HighlightTexture:SetPoint('BOTTOMRIGHT', 6, -6)
	self.HighlightTexture:SetRotation(self.textureRotation)
	self.HighlightTexture:SetBlendMode('ADD')

	local cooldown = self.cooldown;
	local canMask = cooldown.SetTexCoordRange ~= nil;
	if canMask then
		-- Each cell covers a 48-unit square centered on its pet action slot.
		local x = (i - 1) % SWIPE_ATLAS_GRID_SIZE;
		local y = math.floor((i - 1) / SWIPE_ATLAS_GRID_SIZE);
		cooldown:ClearAllPoints()
		cooldown:SetPoint('CENTER', self)
		cooldown:SetSize(COOLDOWN_SIZE, COOLDOWN_SIZE)
		if cooldown.SetUsingParentLevel then cooldown:SetUsingParentLevel(false) end;
		cooldown:SetFrameLevel(wheel:GetFrameLevel() - 2)
		cooldown:SetSwipeTexture(PET_COOLDOWN_SWIPE, 0, 0, 0, PET_COOLDOWN_ALPHA)
		cooldown:SetTexCoordRange(
			{x = x / SWIPE_ATLAS_GRID_SIZE; y = y / SWIPE_ATLAS_GRID_SIZE;},
			{x = (x + 1) / SWIPE_ATLAS_GRID_SIZE; y = (y + 1) / SWIPE_ATLAS_GRID_SIZE;})
	end
	cooldown:SetDrawSwipe(canMask)
	cooldown:SetDrawBling(false)
	cooldown:SetHideCountdownNumbers(false)
end

function CPPetRingButton:UpdateEmptySlotColor(goldBorders)
	if self.hasPetAction then return end;
	local color = goldBorders and env.Const.Cluster.GoldEmptySlotColor or self.ActiveIconVertex;
	self.icon:SetVertexColor(color:GetRGBA())
end

function CPPetRingButton:OnEnter()
	self:GetParent():UpdateFade()
	if not self.tooltipName then return end;
	local uber = GetCVarBool('UberTooltips')
	if not uber then
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		local bindingText = GetBindingText(GetBindingKey('BONUSACTIONBUTTON'..self:GetID()))
		if ( bindingText and bindingText ~= '' ) then
			GameTooltip:SetText(self.tooltipName..NORMAL_FONT_COLOR_CODE..' ('..bindingText..')'..FONT_COLOR_CODE_CLOSE, 1.0, 1.0, 1.0)
		else
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0)
		end
		GameTooltip:Show()
		self.UpdateTooltip = nil;
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if ( GameTooltip:SetPetAction(self:GetID()) ) then
			self.UpdateTooltip = self.OnEnter;
		else
			self.UpdateTooltip = nil;
		end
	end
end

function CPPetRingButton:OnLeave()
	self:GetParent():UpdateFade()
end

function CPPetRingButton:OnSizeChanged(width, height)
	local normalX, normalY = width * (46/32), height * (46/32);
	self.PushedTexture:SetSize(normalX, normalY)
	self.NormalTexture:SetSize(normalX, normalY)
	self.NormalTexture2:SetSize(normalX, normalY)
end

function CPPetRingButton:Update()
	local i = self:GetID()
	local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
	local actionChanged = name ~= self.petActionName or texture ~= self.petActionTexture;
	self.petActionName, self.petActionTexture = name, texture;
	if actionChanged then self.lastActionPulse = nil end;
	self.hasPetAction = not not texture;
	if ( not isToken ) then
		self:SetIcon(texture)
		self.tooltipName = name;
	else
		self:SetIcon(_G[texture])
		self.tooltipName = _G[name];
	end
	self:SetChecked(not not isActive)
	local color = texture and (autoCastAllowed and autoCastEnabled and AUTOCAST_GLOW or isActive and ACTIVE_GLOW);
	self:UpdateStateGlow(color or nil, actionChanged)
	if ( texture ) then
		local color = GetPetActionSlotUsable(i) and self.ActiveIconVertex or self.InactiveIconVertex;
		self.icon:SetVertexColor(color:GetRGBA())
	else
		self:UpdateEmptySlotColor(env:IsGoldClusterDesign())
	end
	self:UpdateCooldown()
end

function CPPetRingButton:UpdateFade(duration)
	local show = self:GetParent().showAll or self.cooldownEnd ~= nil;
	if self.fadeShown == show then return end;
	self.fadeShown = show;
	local fade = show and FadeIn or FadeOut;
	fade(self, duration, self:GetAlpha(), show and 1 or 0)
end

local function GetCooldownEnd(start, duration, enable, time)
	if IsSecret(start) or IsSecret(duration) or IsSecret(enable) then return end;
	if not enable or enable == 0 or not start or not duration then return end;
	if ( start <= 0 or duration <= 0 ) then return end;
	local expires = start + duration;
	return expires > time and expires or nil;
end

function CPPetRingButton:UpdateCooldown(time)
	local start, duration, enable = GetPetActionCooldown(self:GetID())
	CooldownFrame_Set(self.cooldown, start, duration, enable)
	self.cooldownEnd = GetCooldownEnd(start, duration, enable, time or GetTime())
	self:UpdateFade(0.1)
	if GameTooltip:IsOwned(self) then
		self:OnEnter()
	end
end

---------------------------------------------------------------
CPPetRingPower = {};
---------------------------------------------------------------
local SQRT2 = 2 ^ 0.5;
local PI    = math.pi;
local HALF  = PI / 2;

function CPPetRingPower:SetFillTexture(texture)
	self.Fill:SetTexture(texture)
	local width, height = self:GetSize()
	-- Size the rotating square masks to the diagonal so their corners always cover the ring.
	local maskSize = math.max(width, height) * SQRT2;
	self.HalfMask:SetSize(maskSize, maskSize)
	self.FillMask:SetSize(maskSize, maskSize)
end

function CPPetRingPower:SetHalfRotation(rotation)
	self.HalfMask:SetRotation(rotation)
end

function CPPetRingPower:SetFillColor(r, g, b, a)
	self.Fill:SetVertexColor(r, g, b, a or 1)
end

function CPPetRingPower:SetValue(rotation)
	self.FillMask:SetRotation(rotation)
end

---------------------------------------------------------------
CPPetRing = Mixin({
---------------------------------------------------------------
	OnEvent = CPAPI.EventMixin.OnEvent;
	Events  = {
		'PLAYER_REGEN_ENABLED';
		'PET_BAR_UPDATE_COOLDOWN';
		'PET_ATTACK_START';
		'PET_BAR_UPDATE';
		'PET_BAR_UPDATE_USABLE';
		'PET_UI_UPDATE';
		'PET_SPECIALIZATION_CHANGED';
		'PLAYER_CONTROL_GAINED';
		'PLAYER_CONTROL_LOST';
		'PLAYER_FARSIGHT_FOCUS_CHANGED';
	};
	PetEvents = {
		'UNIT_AURA';
		'UNIT_FLAGS';
		'UNIT_PORTRAIT_UPDATE';
		'UNIT_SPELLCAST_SUCCEEDED';
	};
	PlayerEvents = {
		'UNIT_PET';
	};
}, env.ConfigurableWidgetMixin);

function CPPetRing:OnLoad()
	CPAPI.RegisterFrameForEvents(self, self.Events)
	CPAPI.RegisterFrameForUnitEvents(self, self.PetEvents, 'pet')
	CPAPI.RegisterFrameForUnitEvents(self, self.PlayerEvents, 'player')

	for i, button in ipairs(self.Buttons) do
		button:Init(i)
	end

	self.Power:SetFillTexture(PET_STATUS_TEXTURE)
	self.Health:SetFillTexture(PET_STATUS_TEXTURE)

	self.Health:SetHalfRotation(HALF)
	self.Power:SetHalfRotation(-HALF)

	self:UpdatePowerType()
	self.Health:SetFillColor(0, 1, 0, 1)

	env:RegisterCallbacks(self.OnVariableChanged, self,
		'Settings/borderColor',
		'Settings/clusterDesign'
	);
end

function CPPetRing:SetProps(props)
	self:SetDynamicProps(props)

	local showStatus = props.status;
	local hri = showStatus and -4 or 0;
	self:SetHitRectInsets(hri, hri, hri, hri)
	self.Power:SetShown(showStatus)
	self.Health:SetShown(showStatus)
	self.Background:SetShown(showStatus)
	self.Center.Separator:SetShown(showStatus)
	self.Center.OuterBorder:SetShown(showStatus)
	self:SetScript('OnUpdate', (showStatus or props.fade) and self.OnUpdate or nil)

	db.Layers:RegisterStateDriver(self, 'visibility', env.ConvertDriver(
		(not props.vehicle and '[vehicleui] hide; ' or '') .. props.visibility));

	self:Update()
	self:OnVariableChanged()
	self:UpdateFade()
end

function CPPetRing:OnPropsUpdated()
	self:SetProps(self.props)
end

local function setRimTexture(region, texture, r, g, b, a)
	region:SetTexture(texture)
	region:SetVertexColor(r, g, b, a)
	if region.SetTexelSnappingBias and region.SetSnapToPixelGrid then
		region:SetTexelSnappingBias(0)
		region:SetSnapToPixelGrid(false)
	end
end

function CPPetRing:OnVariableChanged()
	local goldBorders = env:IsGoldClusterDesign();
	local beveled     = env('clusterDesign') == env.Const.ClusterDesign.Beveled;
	local textures    = goldBorders and PET_RING_TEXTURES.Gold or beveled and PET_RING_TEXTURES.Beveled or PET_RING_TEXTURES.Original;
	local r, g, b, a  = env:GetColorRGBA('borderColor');
	local rest = (goldBorders or beveled) and TEXTURED_RIM_BRIGHTNESS or 1;
	local rimR, rimG, rimB = r * rest, g * rest, b * rest;
	setRimTexture(self.Center.InnerBorder, textures.Portrait, rimR, rimG, rimB, a)
	setRimTexture(self.Center.OuterBorder, textures.Status, rimR, rimG, rimB, a)

	local background = self.Background.Background;
	if goldBorders then
		background:SetVertexColor(env.Const.Cluster.GoldEmptySlotColor:GetRGBA())
	else
		background:SetVertexColor(0.5, 0.5, 0.5, 1)
	end
	for _, button in ipairs(self.Buttons) do
		setRimTexture(button.Rim, textures.Wheel, rimR, rimG, rimB, a)
		-- Press darkens the rim to 60% brightness. Hover overlays the rim at 55% of its alpha.
		setRimTexture(button.PushedTexture, textures.Slot, r * 0.60, g * 0.60, b * 0.60, a)
		setRimTexture(button.HighlightTexture, textures.Slot, r, g, b, a * 0.55)
		button:UpdateEmptySlotColor(goldBorders)
	end
end

function CPPetRing:OnShow()
	if getCombatEvent then self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED') end;
	self:UNIT_PORTRAIT_UPDATE()
	if self.props then
		self:UpdateCooldowns()
		self:UpdateFade()
	end
	FadeIn(self, 0.2, 0, 1)
end

function CPPetRing:OnHide()
	if getCombatEvent then self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED') end;
end

function CPPetRing:OnEnter()
	UnitFrame_UpdateTooltip(self)
	self:UpdateFade()
end

function CPPetRing:OnLeave()
	self.UpdateTooltip = nil;
	GameTooltip:Hide()
	self:UpdateFade()
end

do local UnitExists = UnitExists;
	function CPPetRing:OnUpdate(elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed;
		if self.elapsed < UPDATE_INTERVAL then return end;
		self.elapsed = self.elapsed % UPDATE_INTERVAL;
		if self.props.fade and self.showAll then
			-- The editor can close or move the ring before mouse focus settles.
			self:UpdateFade()
		end
		if not self.showAll then
			local time = GetTime();
			for _, button in ipairs(self.Buttons) do
				if button.cooldownEnd and button.cooldownEnd <= time then
					button:UpdateCooldown(time)
				end
			end
		end
		if not self.props.status then return end;
		local unit, powerType = self.unit, self.powerType;
		if not UnitExists(unit) then return end;
		self:UpdateHealth(unit)
		if not powerType then return end;
		self:UpdatePower(unit, powerType)
	end
end

if CPAPI.IsModernVersion then
	local UnitHealthPercent, UnitPowerPercent = UnitHealthPercent, UnitPowerPercent;

	local healthCurve = C_CurveUtil.CreateCurve();
	healthCurve:SetType(Enum.LuaCurveType.Linear);
	healthCurve:AddPoint(0.0, PI + HALF);
	healthCurve:AddPoint(1.0, HALF);

	local powerCurve = C_CurveUtil.CreateCurve();
	powerCurve:SetType(Enum.LuaCurveType.Linear);
	powerCurve:AddPoint(0.0, -PI - HALF);
	powerCurve:AddPoint(1.0, -HALF);

	function CPPetRing:UpdateHealth(unit)
		local usePredicted = false;
		local health = UnitHealthPercent(unit, usePredicted, healthCurve)
		self.Health:SetValue(health)
	end

	function CPPetRing:UpdatePower(unit, powerType)
		local unmodified = false;
		local power = UnitPowerPercent(unit, powerType, unmodified, powerCurve)
		self.Power:SetValue(power)
	end
else
	local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax;
	local UnitPower,  UnitPowerMax  = UnitPower, UnitPowerMax;

	function CPPetRing:UpdateHealth(unit)
		local health = UnitHealth(unit) / UnitHealthMax(unit);
		if ( self.health ~= health ) then
			self.health = health;
			self.Health:SetValue(HALF + PI * (1 - health))
		end
	end

	function CPPetRing:UpdatePower(unit, powerType)
		local maxPower = UnitPowerMax(unit, powerType)
		local curPower = UnitPower(unit, powerType);
		local power = maxPower > 0 and curPower / maxPower or 1;
		if ( self.power ~= power ) then
			self.power = power;
			self.Power:SetValue(-HALF - PI * (1 - power))
		end
	end
end

function CPPetRing:OnRelease()
	db.Layers:UnregisterStateDriver(self, 'visibility')
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function CPPetRing:Update()
	for _, button in ipairs(self.Buttons) do
		button:Update()
	end
end

CPPetRing.PET_BAR_UPDATE               = CPPetRing.Update;
CPPetRing.PET_BAR_UPDATE_USABLE        = CPPetRing.Update;
CPPetRing.PET_UI_UPDATE                = CPPetRing.Update;
CPPetRing.PET_SPECIALIZATION_CHANGED   = CPPetRing.Update;
CPPetRing.PLAYER_CONTROL_GAINED        = CPPetRing.Update;
CPPetRing.PLAYER_CONTROL_LOST          = CPPetRing.Update;
CPPetRing.PLAYER_FARSIGHT_FOCUS_CHANGED = CPPetRing.Update;
CPPetRing.UNIT_AURA                    = CPPetRing.Update;
CPPetRing.UNIT_FLAGS                   = CPPetRing.Update;

function CPPetRing:UpdateCooldowns()
	local time = GetTime()
	for _, button in ipairs(self.Buttons) do
		button:UpdateCooldown(time)
	end
end

function CPPetRing:UpdatePowerType()
	local powerType = UnitPowerType(self.unit)
	if not powerType then return end;

	local powerColor = PowerBarColor[powerType];
	self.powerType = powerType;
	self.Power:SetFillColor(powerColor.r, powerColor.g, powerColor.b, 1)
end

function CPPetRing:UNIT_PORTRAIT_UPDATE()
	SetPortraitTexture(self.Center.Portrait, 'pet')
end

CPPetRing.PET_BAR_UPDATE_COOLDOWN = CPPetRing.UpdateCooldowns;
CPPetRing.PLAYER_REGEN_ENABLED    = CPPetRing.UpdateCooldowns;

function CPPetRing:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if unit ~= 'pet' or CPAPI.IsSecret(spellID) or not spellID or spellID <= 0 then return end;
	for _, button in ipairs(self.Buttons) do
		local _, texture, _, _, _, _, petSpellID = GetPetActionInfo(button:GetID());
		if not CPAPI.IsSecret(petSpellID) and texture and petSpellID == spellID then
			button:PlayActionPulse()
		end
	end
end

function CPPetRing:PET_ATTACK_START()
	for _, button in ipairs(self.Buttons) do
		if IsPetAttackAction(button:GetID()) then
			button:PlayActionPulse()
		end
	end
end

function CPPetRing:COMBAT_LOG_EVENT_UNFILTERED()
	local _, event, _, source, _, _, _, _, _, _, _, spellID = getCombatEvent();
	local swing = event == 'SWING_DAMAGE' or event == 'SWING_MISSED';
	if not (swing or event == 'SPELL_CAST_SUCCESS') then return end;
	if not source or source ~= UnitGUID('pet') then return end;
	if swing then
		self:PET_ATTACK_START()
	else
		self:UNIT_SPELLCAST_SUCCEEDED('pet', nil, spellID)
	end
end

function CPPetRing:UNIT_PET()
	self:UNIT_PORTRAIT_UPDATE()
	self:Update()
	self:UpdatePowerType()
end

---------------------------------------------------------------
-- Display
---------------------------------------------------------------
function CPPetRing:UpdateFade()
	if not self.props then return end;
	local editor = env.Config and env.Config.SettingsContainer.ScrollChild.Loadout;
	local showAll = not self.props.fade or (editor and editor:IsVisible()) or self:IsMouseMotionFocus();
	if not showAll then
		for _, button in ipairs(self.Buttons) do
			if button:IsMouseMotionFocus() then
				showAll = true;
				break;
			end
		end
	end
	if self.showAll == showAll then return end;
	self.showAll = showAll;
	for _, button in ipairs(self.Buttons) do
		button:UpdateFade(0.2)
	end
end

env:RegisterCallback('OnLoadoutConfigShown', function()
	env:Map('Petring', nil, CPPetRing.UpdateFade)
end, CPPetRing)

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:AddFactory('Petring', function(id)
	local name = ConsolePortBarPetRing and env.MakeID('ConsolePortBarPetRing%s', id) or 'ConsolePortBarPetRing';
	return CreateFrame('Button', name, env.Manager, 'CPPetRing')
end, env.Interface.Petring)
