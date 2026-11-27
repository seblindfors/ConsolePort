local env, db = CPAPI.GetEnv(...)
local FadeIn, FadeOut, CancelFade = db.Alpha.FadeIn, db.Alpha.FadeOut, db.Alpha.CancelFade;
local IsSecret, SmoothStep = CPAPI.IsSecret, env.SmoothStep;
local GetTime, Lerp, UnitExists = GetTime, Lerp, UnitExists;
local cos, sin, floor, max, rad = math.cos, math.sin, math.floor, math.max, math.rad;
---------------------------------------------------------------
local CLUSTER, CLUSTER_DESIGN = env.Const.Cluster, env.Const.ClusterDesign;
local ASSETS               = CLUSTER.Assets;
local PET_STATUS_TEXTURE   = ASSETS.PetStatusFill;
local PET_STATE_MASK       = ASSETS.PetStateMask;
local PET_STATE_OUTLINE    = ASSETS.PetStateOutline;
local PET_STATE_PULSE      = ASSETS.PetStatePulse;
local PET_COOLDOWN_SWIPE   = ASSETS.PetCooldownSwipe;
local PET_HALF_PLANE_MASK  = env.GetAsset([[Textures\Masks\PetPowerMask]]);
local PET_RING_TEXTURE_SET = CLUSTER.AssetFormats.PetRing;
local MASK_WRAP_MODE       = 'CLAMPTOBLACKADDITIVE';
---------------------------------------------------------------
local SLOT_RADIUS              = 68;
local SLOT_AT_THREE_OCLOCK     = 4;
local SLOT_OVERLAY_OUTSET      = 6;
local RIM_MASK_OUTSET          = 2;
local ICON_LEVELS_BELOW_WHEEL  = 3;
local SWIPE_LEVELS_BELOW_WHEEL = 2;
local GLOW_LEVELS_BELOW_WHEEL  = 1;
local COOLDOWN_SIZE            = 48;
local COOLDOWN_SHADE_ALPHA     = CLUSTER.CooldownShadeAlpha;
local SWIPE_ATLAS_GRID_SIZE    = 4;
local TEXTURED_RIM_BRIGHTNESS  = CLUSTER.RimBrightness;
local PUSHED_RIM_BRIGHTNESS    = 0.6;
local HOVER_RIM_ALPHA          = 0.55;
local UPDATE_INTERVAL          = 0.1;
---------------------------------------------------------------
local AUTOCAST_GLOW         = {1; 240 / 255; 77 / 255;};
local ACTIVE_GLOW           = {CLUSTER.AmberColor:GetRGB()};
local ACTION_GLOW           = {1; 0.93; 0.72;};
local GLOW_FADE_IN          = CLUSTER.GlowFadeIn;
local GLOW_FADE_OUT         = CLUSTER.GlowFadeOut;
local PULSE_DURATION        = 0.48;
local PULSE_PEAK_PROGRESS   = 0.23;
local PULSE_MIN_SIZE        = 10.4;
local PULSE_MAX_SIZE        = 55;
local STATE_PULSE_ALPHA     = 0.72;
local ACTION_PULSE_ALPHA    = 0.54;
local ACTION_PULSE_DEBOUNCE = 0.12;
---------------------------------------------------------------
local getCombatEvent = not CPAPI.IsModernVersion and CombatLogGetCurrentEventInfo;

local function getPetRingTextures(style)
	return {
		Portrait = PET_RING_TEXTURE_SET:format(style, 'Portrait');
		Wheel    = PET_RING_TEXTURE_SET:format(style, 'Wheel');
		Status   = PET_RING_TEXTURE_SET:format(style, 'Status');
		Slot     = PET_RING_TEXTURE_SET:format(style, 'Slot');
	};
end

local PET_RING_TEXTURES = {};
do  local texturesByStyle = {};
	for design, info in pairs(CLUSTER.Designs) do
		local style = info.PetRing;
		texturesByStyle[style] = texturesByStyle[style] or getPetRingTextures(style);
		PET_RING_TEXTURES[design] = texturesByStyle[style];
	end
end

local ROUND_SILVER_TEXTURES = PET_RING_TEXTURES[CLUSTER_DESIGN.Original];

---------------------------------------------------------------
-- Client capabilities
---------------------------------------------------------------
local setOwnFrameLevel, setCooldownSwipe, disablePixelSnapping;
do  local probe    = CreateFrame('Cooldown');
	local Cooldown = getmetatable(probe).__index;
	local Texture  = getmetatable(probe:CreateTexture()).__index;

	if Cooldown.SetUsingParentLevel then
		function setOwnFrameLevel(cooldown, level)
			cooldown:SetUsingParentLevel(false)
			cooldown:SetFrameLevel(level)
		end
	else
		function setOwnFrameLevel(cooldown, level)
			cooldown:SetFrameLevel(level)
		end
	end

	if Cooldown.SetTexCoordRange then
		function setCooldownSwipe(cooldown, button, index, level)
			local column = (index - 1) % SWIPE_ATLAS_GRID_SIZE;
			local row    = floor((index - 1) / SWIPE_ATLAS_GRID_SIZE);
			cooldown:ClearAllPoints()
			cooldown:SetPoint('CENTER', button)
			cooldown:SetSize(COOLDOWN_SIZE, COOLDOWN_SIZE)
			setOwnFrameLevel(cooldown, level)
			cooldown:SetSwipeTexture(PET_COOLDOWN_SWIPE, 0, 0, 0, COOLDOWN_SHADE_ALPHA)
			cooldown:SetTexCoordRange(
				{x = column / SWIPE_ATLAS_GRID_SIZE; y = row / SWIPE_ATLAS_GRID_SIZE;},
				{x = (column + 1) / SWIPE_ATLAS_GRID_SIZE; y = (row + 1) / SWIPE_ATLAS_GRID_SIZE;})
			cooldown:SetDrawSwipe(true)
		end
	else
		function setCooldownSwipe(cooldown)
			cooldown:SetDrawSwipe(false)
		end
	end

	if Texture.SetTexelSnappingBias and Texture.SetSnapToPixelGrid then
		function disablePixelSnapping(region)
			region:SetTexelSnappingBias(0)
			region:SetSnapToPixelGrid(false)
		end
	else
		disablePixelSnapping = nop;
	end
end

---------------------------------------------------------------
CPPetRingButton = Mixin({
---------------------------------------------------------------
	ActiveIconVertex   = CreateColor(1.0, 1.0, 1.0);
	InactiveIconVertex = CreateColor(0.4, 0.4, 0.4);
}, CPActionButtonMixin);

---------------------------------------------------------------
-- State glow
---------------------------------------------------------------
local function easeOutQuad(progress)
	return 1 - (1 - progress) ^ 2;
end

local function stopGlowPulse(glow)
	glow.pulseStart, glow.pulseColor, glow.pulseAlpha = nil, nil, nil;
	glow.Pulse:Hide()
	glow:SetScript('OnUpdate', nil)
end

local function animateGlowPulse(glow)
	local progress = (GetTime() - glow.pulseStart) / PULSE_DURATION;
	if ( progress >= 1 ) then
		return stopGlowPulse(glow);
	end
	local intensity = progress < PULSE_PEAK_PROGRESS
		and SmoothStep(progress / PULSE_PEAK_PROGRESS)
		or  SmoothStep((1 - progress) / (1 - PULSE_PEAK_PROGRESS));
	local size = Lerp(PULSE_MIN_SIZE, PULSE_MAX_SIZE, easeOutQuad(progress));
	glow.Pulse:SetSize(size, size)
	glow.Pulse:SetAlpha(glow.pulseAlpha * intensity)
end

local function playGlowPulse(glow, color, peakAlpha)
	glow.pulseStart, glow.pulseColor, glow.pulseAlpha = GetTime(), color, peakAlpha;
	glow.Pulse:SetVertexColor(unpack(color))
	glow.Pulse:Show()
	glow:SetScript('OnUpdate', animateGlowPulse)
	animateGlowPulse(glow)
end

local function createStateGlow(button)
	local wheel = button:GetParent().Ring;
	local glow  = CreateFrame('Frame', nil, button);
	glow:SetAllPoints(button)
	glow:SetFrameLevel(wheel:GetFrameLevel() - GLOW_LEVELS_BELOW_WHEEL)

	local mask = glow:CreateMaskTexture(nil, 'ARTWORK');
	mask:SetAllPoints(wheel.Mask)
	mask:SetTexture(PET_STATE_MASK, MASK_WRAP_MODE, MASK_WRAP_MODE)
	mask:SetRotation(button.wedgeRotation)

	local outline = glow:CreateTexture(nil, 'ARTWORK', nil, 1);
	outline:SetAllPoints(wheel.Mask)
	outline:SetTexture(PET_STATE_OUTLINE, MASK_WRAP_MODE, MASK_WRAP_MODE)
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

function CPPetRingButton:PlayActionPulse()
	if not self:IsVisible() then return end;
	local now, last = GetTime(), self.lastActionPulse;
	if ( last and now - last < ACTION_PULSE_DEBOUNCE ) then return end;
	self.lastActionPulse = now;
	playGlowPulse(self.StateGlow or createStateGlow(self), ACTION_GLOW, ACTION_PULSE_ALPHA)
end

function CPPetRingButton:UpdateStateGlow(color, actionChanged)
	local glow = self.StateGlow;
	if not ( color or glow ) then return end;
	glow = glow or createStateGlow(self);
	if ( glow.color == color and not actionChanged ) then return end;
	glow.color = color;
	if color then
		glow.Outline:SetVertexColor(unpack(color))
	end

	local outline = glow.Outline;
	local alpha   = outline:GetAlpha();
	if ( actionChanged or not self:IsVisible() or IsSecret(alpha) ) then
		stopGlowPulse(glow)
		CancelFade(outline)
		return outline:SetAlpha(color and 1 or 0);
	end
	if not color then
		return FadeOut(outline, GLOW_FADE_OUT, alpha, 0);
	end
	FadeIn(outline, GLOW_FADE_IN, alpha, 1)
	if ( glow.pulseColor ~= ACTION_GLOW ) then
		playGlowPulse(glow, color, STATE_PULSE_ALPHA)
	end
end

---------------------------------------------------------------
-- Button setup
---------------------------------------------------------------
local function createWedgeRim(button, wheel, slotAngle)
	local rim = button:CreateTexture(nil, 'BACKGROUND');
	rim:SetAllPoints(wheel)
	local halfSlot = slotAngle / 2;
	for _, halfPlaneRotation in ipairs({-halfSlot; math.pi + halfSlot}) do
		local mask = button:CreateMaskTexture(nil, 'ARTWORK');
		mask:SetPoint('TOPLEFT', wheel, 'TOPLEFT', -RIM_MASK_OUTSET, RIM_MASK_OUTSET)
		mask:SetPoint('BOTTOMRIGHT', wheel, 'BOTTOMRIGHT', RIM_MASK_OUTSET, -RIM_MASK_OUTSET)
		mask:SetTexture(PET_HALF_PLANE_MASK, MASK_WRAP_MODE, MASK_WRAP_MODE)
		mask:SetRotation(button.wedgeRotation + halfPlaneRotation)
		rim:AddMaskTexture(mask)
	end
	return rim;
end

local function moveIconBelowWheel(button, wheel)
	local iconFrame = CreateFrame('Frame', nil, button);
	iconFrame:SetAllPoints(button)
	iconFrame:SetFrameLevel(wheel:GetFrameLevel() - ICON_LEVELS_BELOW_WHEEL)

	local icon = button.icon;
	icon:SetParent(iconFrame)
	icon:SetDrawLayer('BACKGROUND')
	icon:AddMaskTexture(wheel.Mask)
	icon:SetRotation(button.textureRotation)
	icon:SetAllPoints()
end

local function hideAutoCastArt(button, name)
	local autocastable = button.AutoCastable or _G[name..'AutoCastable'];
	local shine        = button.Shine or button.AutoCastShine or _G[name..'Shine'];
	if autocastable then autocastable:Hide() end;
	if shine then shine:Hide() end;
	if button.AutoCastOverlay then button.AutoCastOverlay:Hide() end;
end

local function clearNormalTexture(texture)
	texture:SetTexture(nil)
	texture:ClearAllPoints()
	texture:SetPoint('CENTER', 0, 0)
end

local function setSlotOverlay(texture, rotation, blendMode)
	texture:SetPoint('TOPLEFT', -SLOT_OVERLAY_OUTSET, SLOT_OVERLAY_OUTSET)
	texture:SetPoint('BOTTOMRIGHT', SLOT_OVERLAY_OUTSET, -SLOT_OVERLAY_OUTSET)
	texture:SetRotation(rotation)
	texture:SetBlendMode(blendMode)
end

function CPPetRingButton:Init(i)
	local slotAngle = rad(360 / NUM_PET_ACTION_SLOTS);
	local angle     = (i - SLOT_AT_THREE_OCLOCK) * slotAngle;

	self.textureRotation = rad(270) - angle;
	self.wedgeRotation   = -angle;
	self:SetAttribute('action', i)
	self:SetPoint('CENTER', SLOT_RADIUS * cos(angle), -SLOT_RADIUS * sin(angle))

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
	self.Rim = createWedgeRim(self, wheel, slotAngle);
	moveIconBelowWheel(self, wheel)
	hideAutoCastArt(self, name)

	clearNormalTexture(self.NormalTexture)
	clearNormalTexture(self.NormalTexture2)

	self.PushedTexture    = self:GetPushedTexture()
	self.HighlightTexture = self:GetHighlightTexture()
	self:GetCheckedTexture():SetTexture(nil)

	setSlotOverlay(self.PushedTexture, self.textureRotation, 'BLEND')
	setSlotOverlay(self.HighlightTexture, self.textureRotation, 'ADD')

	local cooldown = self.cooldown;
	setCooldownSwipe(cooldown, self, i, wheel:GetFrameLevel() - SWIPE_LEVELS_BELOW_WHEEL)
	cooldown:SetDrawBling(false)
	cooldown:SetHideCountdownNumbers(false)
end

function CPPetRingButton:UpdateEmptySlotColor(goldBorders)
	if self.hasPetAction then return end;
	local color = goldBorders and CLUSTER.GoldEmptySlotColor or self.ActiveIconVertex;
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
			local binding = NORMAL_FONT_COLOR_CODE..' ('..bindingText..')'..FONT_COLOR_CODE_CLOSE;
			GameTooltip:SetText(self.tooltipName..binding, 1.0, 1.0, 1.0)
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

---------------------------------------------------------------
-- Button state
---------------------------------------------------------------
local function hasActionChanged(self, name, texture)
	if IsSecret(name) or IsSecret(texture) then return false end;
	local changed = name ~= self.petActionName or texture ~= self.petActionTexture;
	self.petActionName, self.petActionTexture = name, texture;
	return changed;
end

local function showActionIcon(self, texture, isToken)
	if IsSecret(texture) then
		self.hasPetAction = true;
		self.icon:SetDesaturated(false)
		return self.icon:SetTexture(texture);
	end
	self.hasPetAction = not not texture;
	if IsSecret(isToken) or not isToken then
		return self:SetIcon(texture);
	end
	self:SetIcon(_G[texture])
end

local function setTooltipName(self, name, isToken)
	if IsSecret(name) or IsSecret(isToken) then return end;
	if ( not isToken ) then
		self.tooltipName = name;
	else
		self.tooltipName = _G[name];
	end
end

local function showActionState(self, isActive, autoCastAllowed, autoCastEnabled, actionChanged)
	if IsSecret(isActive) then
		return self:SetChecked(isActive);
	end
	self:SetChecked(not not isActive)
	if IsSecret(autoCastAllowed) or IsSecret(autoCastEnabled) then return end;
	local color = autoCastAllowed and autoCastEnabled and AUTOCAST_GLOW or isActive and ACTIVE_GLOW;
	self:UpdateStateGlow(self.hasPetAction and color or nil, actionChanged)
end

local function showActionUsable(self, usable)
	if IsSecret(usable) then return end;
	local color = usable and self.ActiveIconVertex or self.InactiveIconVertex;
	self.icon:SetVertexColor(color:GetRGBA())
end

function CPPetRingButton:Update()
	local i = self:GetID()
	local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
	local actionChanged = hasActionChanged(self, name, texture);
	if actionChanged then self.lastActionPulse = nil end;
	showActionIcon(self, texture, isToken)
	setTooltipName(self, name, isToken)
	showActionState(self, isActive, autoCastAllowed, autoCastEnabled, actionChanged)
	if self.hasPetAction then
		showActionUsable(self, GetPetActionSlotUsable(i))
	else
		self:UpdateEmptySlotColor(env:IsGoldClusterDesign())
	end
	self:UpdateCooldown()
end

function CPPetRingButton:UpdateFade(duration)
	local show = self:GetParent().showAll or self.cooldownEnd ~= nil;
	if self.fadeShown == show then return end;
	self.fadeShown = show;
	local alpha = self:GetAlpha();
	if IsSecret(alpha) then
		CancelFade(self)
		return self:SetAlpha(show and 1 or 0);
	end
	local fade = show and FadeIn or FadeOut;
	fade(self, duration, alpha, show and 1 or 0)
end

local function getCooldownEnd(start, duration, enable, time)
	if IsSecret(start) or IsSecret(duration) or IsSecret(enable) then return end;
	if not enable or enable == 0 or not start or not duration then return end;
	if ( start <= 0 or duration <= 0 ) then return end;
	local expires = start + duration;
	return expires > time and expires or nil;
end

function CPPetRingButton:UpdateCooldown(time)
	local start, duration, enable = GetPetActionCooldown(self:GetID())
	CooldownFrame_Set(self.cooldown, start, duration, enable)
	self.cooldownEnd = getCooldownEnd(start, duration, enable, time or GetTime())
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
	local maskSize = max(width, height) * SQRT2;
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

	env:RegisterCallback('OnLoadoutConfigShown', self.OnLoadoutConfigShown, self)
	self.isLoadoutConfigShown = env:IsLoadoutConfigShown();
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
	disablePixelSnapping(region)
end

function CPPetRing:OnVariableChanged()
	local goldBorders = env:IsGoldClusterDesign();
	local textures    = PET_RING_TEXTURES[env('clusterDesign')] or ROUND_SILVER_TEXTURES;
	local brightness  = textures == ROUND_SILVER_TEXTURES and 1 or TEXTURED_RIM_BRIGHTNESS;
	local r, g, b, a  = env:GetColorRGBA('borderColor');
	local rimR, rimG, rimB = r * brightness, g * brightness, b * brightness;
	setRimTexture(self.Center.InnerBorder, textures.Portrait, rimR, rimG, rimB, a)
	setRimTexture(self.Center.OuterBorder, textures.Status, rimR, rimG, rimB, a)

	local background = self.Background.Background;
	if goldBorders then
		background:SetVertexColor(CLUSTER.GoldEmptySlotColor:GetRGBA())
	else
		background:SetVertexColor(CLUSTER.EmptySlotColor:GetRGBA())
	end
	for _, button in ipairs(self.Buttons) do
		setRimTexture(button.Rim, textures.Wheel, rimR, rimG, rimB, a)
		setRimTexture(button.PushedTexture, textures.Slot,
			r * PUSHED_RIM_BRIGHTNESS, g * PUSHED_RIM_BRIGHTNESS, b * PUSHED_RIM_BRIGHTNESS, a)
		setRimTexture(button.HighlightTexture, textures.Slot, r, g, b, a * HOVER_RIM_ALPHA)
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

local function updateExpiredCooldowns(self)
	local time = GetTime();
	for _, button in ipairs(self.Buttons) do
		if ( button.cooldownEnd and button.cooldownEnd <= time ) then
			button:UpdateCooldown(time)
		end
	end
end

function CPPetRing:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed;
	if ( self.elapsed < UPDATE_INTERVAL ) then return end;
	self.elapsed = self.elapsed % UPDATE_INTERVAL;
	if ( self.props.fade and self.showAll ) then
		self:UpdateFade()
	end
	if not self.showAll then
		updateExpiredCooldowns(self)
	end
	if not self.props.status then return end;
	local unit, powerType = self.unit, self.powerType;
	local exists = UnitExists(unit);
	if IsSecret(exists) or not exists then return end;
	self:UpdateHealth(unit)
	if not powerType then return end;
	self:UpdatePower(unit, powerType)
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

CPPetRing.PET_BAR_UPDATE                = CPPetRing.Update;
CPPetRing.PET_BAR_UPDATE_USABLE         = CPPetRing.Update;
CPPetRing.PET_UI_UPDATE                 = CPPetRing.Update;
CPPetRing.PET_SPECIALIZATION_CHANGED    = CPPetRing.Update;
CPPetRing.PLAYER_CONTROL_GAINED         = CPPetRing.Update;
CPPetRing.PLAYER_CONTROL_LOST           = CPPetRing.Update;
CPPetRing.PLAYER_FARSIGHT_FOCUS_CHANGED = CPPetRing.Update;
CPPetRing.UNIT_AURA                     = CPPetRing.Update;
CPPetRing.UNIT_FLAGS                    = CPPetRing.Update;

function CPPetRing:UpdateCooldowns()
	local time = GetTime()
	for _, button in ipairs(self.Buttons) do
		button:UpdateCooldown(time)
	end
end

function CPPetRing:UpdatePowerType()
	local powerType = UnitPowerType(self.unit)
	if IsSecret(powerType) or not powerType then return end;

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
	if IsSecret(unit) or IsSecret(spellID) then return end;
	if ( unit ~= 'pet' or not spellID or spellID <= 0 ) then return end;
	for _, button in ipairs(self.Buttons) do
		local _, texture, _, _, _, _, petSpellID = GetPetActionInfo(button:GetID());
		if ( not IsSecret(petSpellID) and petSpellID == spellID and ( IsSecret(texture) or texture ) ) then
			button:PlayActionPulse()
		end
	end
end

function CPPetRing:PET_ATTACK_START()
	for _, button in ipairs(self.Buttons) do
		local isAttack = IsPetAttackAction(button:GetID());
		if ( not IsSecret(isAttack) and isAttack ) then
			button:PlayActionPulse()
		end
	end
end

function CPPetRing:COMBAT_LOG_EVENT_UNFILTERED()
	local _, event, _, source, _, _, _, _, _, _, _, spellID = getCombatEvent();
	local swing = event == 'SWING_DAMAGE' or event == 'SWING_MISSED';
	if not ( swing or event == 'SPELL_CAST_SUCCESS' ) then return end;
	if ( not source or source ~= UnitGUID('pet') ) then return end;
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
local function hasMouseFocus(self)
	if self:IsMouseMotionFocus() then return true end;
	for _, button in ipairs(self.Buttons) do
		if button:IsMouseMotionFocus() then return true end;
	end
	return false;
end

function CPPetRing:UpdateFade()
	if not self.props then return end;
	local showAll = not self.props.fade or self.isLoadoutConfigShown or hasMouseFocus(self);
	if ( self.showAll == showAll ) then return end;
	self.showAll = showAll;
	for _, button in ipairs(self.Buttons) do
		button:UpdateFade(0.2)
	end
end

function CPPetRing:OnLoadoutConfigShown(shown)
	self.isLoadoutConfigShown = shown == true;
	self:UpdateFade()
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:AddFactory('Petring', function(id)
	local name = ConsolePortBarPetRing and env.MakeID('ConsolePortBarPetRing%s', id) or 'ConsolePortBarPetRing';
	return CreateFrame('Button', name, env.Manager, 'CPPetRing')
end, env.Interface.Petring)
