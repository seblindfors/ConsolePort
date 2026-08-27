---------------------------------------------------------------
-- Target frame
---------------------------------------------------------------
-- Unit frame for the unit hovered on the target ring, hanging
-- off the active slice label: portrait, health, power and auras.

local Ring, Unitframe = ConsolePortTargetRing, {};

local FRAME_WIDTH, PORTRAIT_SIZE, LABEL_OFFSET = 180, 36, 4;
local LINE_CLEARANCE = 8;
local BAR_GAP, HEALTH_HEIGHT, POWER_HEIGHT    = 4, 12, 6;
local AURA_SIZE, AURA_GAP, AURA_MAX           = 16, 2, 7;
local BAR_INSET    = PORTRAIT_SIZE + BAR_GAP;
local BAR_WIDTH    = FRAME_WIDTH - BAR_INSET;
local BARS_HEIGHT  = 2 + HEALTH_HEIGHT + 2 + POWER_HEIGHT;
local AURAS_TOP    = BARS_HEIGHT + BAR_GAP;
local FRAME_HEIGHT = AURAS_TOP + AURA_SIZE * 2 + AURA_GAP;
local BAR_TEXTURE   = [[Interface\TargetingFrame\UI-StatusBar]];
local PORTRAIT_MASK = [[Interface\CharacterFrame\TempPortraitAlphaMask]];
local PREDICTION_COLOR = CreateColor(0.2, 0.8, 0.3, 0.6);
local EASE = Enum.StatusBarInterpolation.ExponentialEaseOut;
local SNAP = Enum.StatusBarInterpolation.Immediate;
local UNIT_EVENTS = {
	'UNIT_HEALTH';
	'UNIT_MAXHEALTH';
	'UNIT_HEAL_PREDICTION';
	'UNIT_CONNECTION';
	'UNIT_POWER_FREQUENT';
	'UNIT_MAXPOWER';
	'UNIT_DISPLAYPOWER';
	'UNIT_PORTRAIT_UPDATE';
};

-- Power type is secret for PvP restricted units, which have no
-- power bar as a result.
local function GetPowerColor(unit)
	local powerType, powerToken, r, g, b = UnitPowerType(unit)
	if CPAPI.IsSecret(powerType) then return end;
	return PowerBarColor[CPAPI.Scrub(powerToken)]
		or PowerBarColor[powerType]
		or CreateColor(r, g, b);
end

---------------------------------------------------------------
-- Frame
---------------------------------------------------------------
local function CreateBar(parent, height)
	local bar = CreateFrame('StatusBar', nil, parent)
	bar:SetSize(BAR_WIDTH, height)
	bar:SetStatusBarTexture(BAR_TEXTURE)
	bar:SetMinMaxValues(0, 1)
	return bar;
end

local function AddBackground(bar)
	bar.Background = bar:CreateTexture(nil, 'BACKGROUND')
	bar.Background:SetAllPoints()
	bar.Background:SetColorTexture(0, 0, 0, 0.5)
end

function Ring:CreateUnitframe()
	local frame = Mixin(CreateFrame('Frame', '$parentUnitframe', self), Unitframe)
	frame:OnLoad()
	return frame;
end

function Unitframe:OnLoad()
	Ring.flatLineLength = FRAME_WIDTH;
	self:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	self:SetFrameLevel(10)
	self:Hide()

	self.Portrait = self:CreateTexture(nil, 'ARTWORK')
	self.Portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	self.PortraitMask = self:CreateMaskTexture()
	self.PortraitMask:SetTexture(PORTRAIT_MASK, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	self.PortraitMask:SetAllPoints(self.Portrait)
	self.Portrait:AddMaskTexture(self.PortraitMask)

	self.Border = self:CreateTexture(nil, 'OVERLAY')
	self.Border:SetSize(PORTRAIT_SIZE * (110 / 64), PORTRAIT_SIZE * (110 / 64))
	self.Border:SetPoint('CENTER', self.Portrait, 'CENTER', -1, 0)
	CPAPI.SetAtlas(self.Border, 'ring-metallight')

	-- The prediction bar sits between the health background and
	-- the health fill, so only the predicted excess shows.
	self.Prediction = CreateBar(self, HEALTH_HEIGHT)
	self.Health     = CreateBar(self, HEALTH_HEIGHT)
	self.Power      = CreateBar(self, POWER_HEIGHT)
	AddBackground(self.Prediction)
	AddBackground(self.Power)
	self.Health:SetFrameLevel(self.Prediction:GetFrameLevel() + 1)
	self.Prediction:SetAllPoints(self.Health)
	self.Prediction:GetStatusBarTexture():SetVertexColor(PREDICTION_COLOR:GetRGBA())

	self.Buffs   = Ring.CreateAuraContainer(self, 'HELPFUL', AURA_SIZE, AURA_GAP, AURA_MAX)
	self.Debuffs = Ring.CreateAuraContainer(self, 'HARMFUL', AURA_SIZE, AURA_GAP, AURA_MAX)

	self:SetScript('OnEvent', self.OnEvent)
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self:SetMirrored(false)
end

function Unitframe:SetMirrored(mirrored)
	if ( self.mirrored == mirrored ) then return end;
	self.mirrored = mirrored;
	local near, far = mirrored and 'RIGHT' or 'LEFT', mirrored and 'LEFT' or 'RIGHT';
	local inset = mirrored and -BAR_INSET or BAR_INSET;

	self.Portrait:ClearAllPoints()
	self.Portrait:SetPoint('TOP'..near)
	self.Health:ClearAllPoints()
	self.Health:SetPoint('TOP'..far, 0, -2)
	self.Power:ClearAllPoints()
	self.Power:SetPoint('TOP'..far, self.Health, 'BOTTOM'..far, 0, -2)
	for _, bar in ipairs({self.Health, self.Prediction, self.Power}) do
		bar:SetReverseFill(mirrored)
	end
	self.Buffs:ClearAllPoints()
	self.Buffs:SetPoint('TOP'..near, self, 'TOP'..near, inset, -AURAS_TOP)
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint('TOP'..near, self, 'TOP'..near, inset, -(AURAS_TOP + AURA_SIZE + AURA_GAP))
	Ring.SetAuraContainerMirrored(self.Buffs, mirrored)
	Ring.SetAuraContainerMirrored(self.Debuffs, mirrored)
end

function Unitframe:SetUnit(unit)
	local slice = Ring.ActiveSlice;
	local side, labelOffset = slice.labelSide or 'LEFT', slice.labelOffset or 0;
	self.unit = unit;
	self:SetMirrored(side == 'RIGHT')
	self:ClearAllPoints()
	if ( labelOffset > 0 ) then
		self:SetPoint('TOP'..side, slice.Text, side, 0, -(labelOffset + LINE_CLEARANCE))
	else
		self:SetPoint('TOP'..side, slice.Text, 'BOTTOM'..side, 0, -LABEL_OFFSET)
	end

	self:UnregisterAllEvents()
	for _, event in ipairs(UNIT_EVENTS) do
		self:RegisterUnitEvent(event, unit)
	end
	SetPortraitTexture(self.Portrait, unit)
	local color = Ring:GetUnitColor(unit)
	self.Border:SetVertexColor(color:GetRGB())
	slice:SetLineColorOverride(color)
	self.Buffs:SetUnit(unit)
	self.Debuffs:SetUnit(unit)
	self:UpdateHealth(true)
	self:UpdatePower(true)
	self:Show()
end

function Unitframe:ClearUnit()
	self.unit = nil;
	Ring.ActiveSlice:SetLineColorOverride(nil)
	self:UnregisterAllEvents()
	self:Hide()
end

function Unitframe:UpdateHealth(snap)
	local unit, interpolation = self.unit, snap and SNAP or EASE;
	self.Health:SetValue(UnitHealthPercent(unit, false), interpolation)
	self.Prediction:SetValue(UnitHealthPercent(unit, true), interpolation)
	self.Health:GetStatusBarTexture():SetVertexColor(Ring:GetHealthBarColor(unit):GetRGB())
end

function Unitframe:UpdatePower(snap)
	local color = GetPowerColor(self.unit)
	self.Power:SetShown(color ~= nil)
	if not color then return end;
	self.Power:SetValue(UnitPowerPercent(self.unit), snap and SNAP or EASE)
	self.Power:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
end

function Unitframe:OnEvent(event)
	if ( event == 'UNIT_PORTRAIT_UPDATE' ) then
		SetPortraitTexture(self.Portrait, self.unit)
	elseif event:find('POWER') then
		self:UpdatePower()
	else
		self:UpdateHealth()
	end
end

function Unitframe:OnShow()
	self.Buffs:SetEnabled(true)
	self.Debuffs:SetEnabled(true)
end

function Unitframe:OnHide()
	self.Buffs:SetEnabled(false)
	self.Debuffs:SetEnabled(false)
	self:UnregisterAllEvents()
	self:Hide()
end
