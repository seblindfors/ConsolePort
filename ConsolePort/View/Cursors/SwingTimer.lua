if not C_SwingTimer then return end;
local _, db = ...;
local Timer = CPAPI.DataHandler(ConsolePortSwingTimer)

---------------------------------------------------------------
-- Swing timer
---------------------------------------------------------------
-- A thin ring just outside the crosshair that fills over each auto
-- attack swing, cut by radial progress on one ring texture. Dual
-- wield splits it: right half main hand, left half off hand, both
-- filling from the bottom up. Colour dims while the target is out
-- of swing range. Shown only while a swing is running. The radial
-- cut is set from Lua since older clients reject it in XML.

local GetTime, UnitAttackSpeed = GetTime, UnitAttackSpeed;
local GetScreenHeight, GetCVar, tonumber = GetScreenHeight, GetCVar, tonumber;
local Clamp, max, SetPoint = Clamp, math.max, PixelUtil.SetPoint;
local Crosshair = ConsolePortCrosshair;

local RING_TEXTURE = CPAPI.GetAsset([[Textures\Cursor\Ring]]);
local PADDING, FEATHER, TOP = 6, 0.02, 0.5; -- radial offsets count from the bottom
local FADE_SPEED, LINGER, DIM, OUT_OF_RANGE = 8, 0.75, 0.25, 0.45;

local MainHand = Enum.PlayerSwingType.MainHand;
local OffHand  = Enum.PlayerSwingType.OffHand;
local Ranged   = Enum.PlayerSwingType.Ranged;

---------------------------------------------------------------
-- Progress
---------------------------------------------------------------
local function Progress(swing, now)
	if not swing then return 0 end;
	return Clamp((now - swing.start) / swing.duration, 0, 1);
end

function Timer:SetFill(texture, swingType, now)
	local r, g, b = self.baseColor:GetRGB()
	local brightness = ( self.inRange[swingType] == false ) and OUT_OF_RANGE or 1;
	texture:SetRadialProgressBarPercent(Progress(self.swings[swingType], now))
	texture:SetVertexColor(r * brightness, g * brightness, b * brightness, 1)
end

function Timer:Draw(now)
	if self.hasOffHand then
		self:SetFill(self.Right, MainHand, now)
		self:SetFill(self.Left, OffHand, now)
	else
		self:SetFill(self.Full, self.hasRanged and Ranged or MainHand, now)
	end
end

function Timer:IsSwinging(now)
	for _, swing in pairs(self.swings) do
		if ( now - swing.start < swing.duration + LINGER ) then
			return true;
		end
	end
end

function Timer:OnUpdate(elapsed)
	local now = GetTime()
	local active = self:IsSwinging(now) and Crosshair:ShouldDraw();
	local target = active and 1 or 0;
	local alpha = Clamp(self:GetAlpha() + (target - self:GetAlpha()) * Clamp(elapsed * FADE_SPEED, 0, 1), 0, 1)
	self:SetAlpha(alpha)
	if active then
		self:Draw(now)
	elseif ( alpha <= 0.01 ) then
		self:SetAlpha(0)
		self:Hide()
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Timer:PLAYER_SWING(duration, swingType)
	self.swings[swingType] = { start = GetTime(), duration = max(duration, 0.1) };
	self.hasRanged = ( swingType == Ranged );
	if not self:IsShown() then
		self:Move()
		self:Show()
	end
end

function Timer:PLAYER_SWING_RANGE_UPDATE(swingType, isInRange, checksRange)
	self.inRange[swingType] = checksRange and isInRange or nil;
end

function Timer:RefreshWeapons()
	local _, offHandSpeed = UnitAttackSpeed('player')
	self.hasOffHand = ( offHandSpeed ~= nil and offHandSpeed > 0 );
	self.Full:SetShown(not self.hasOffHand)
	self.Left:SetShown(self.hasOffHand)
	self.Right:SetShown(self.hasOffHand)
end

Timer.WEAPON_SLOT_CHANGED   = Timer.RefreshWeapons;
Timer.PLAYER_ENTERING_WORLD = Timer.RefreshWeapons;

function Timer:UNIT_INVENTORY_CHANGED(unit)
	if ( unit == 'player' ) then
		self:RefreshWeapons()
	end
end

function Timer:OnEvent(event, ...)
	self[event](self, ...)
end

---------------------------------------------------------------
-- Settings
---------------------------------------------------------------
function Timer:SetEnabled(enabled)
	local register = enabled and self.RegisterEvent or self.UnregisterEvent;
	register(self, 'PLAYER_SWING')
	register(self, 'PLAYER_SWING_RANGE_UPDATE')
	register(self, 'WEAPON_SLOT_CHANGED')
	register(self, 'PLAYER_ENTERING_WORLD')
	if enabled then
		self:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player')
	else
		self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
		wipe(self.swings)
		self:Hide()
	end
	for _, swingType in ipairs({MainHand, OffHand, Ranged}) do
		C_SwingTimer.EnableRangeCheck(swingType, enabled)
	end
end

function Timer:Move()
	SetPoint(self, 'CENTER', UIParent, 'BOTTOM', 0, GetScreenHeight() * tonumber(GetCVar('CursorCenteredYPos')))
end

function Timer:Layout()
	local size = max(db('crosshairSizeX'), db('crosshairSizeY')) + PADDING;
	self:SetSize(size, size)
	local r, g, b = self.baseColor:GetRGB()
	self.Track:SetVertexColor(r * DIM, g * DIM, b * DIM, 1)
end

function Timer:OnDataLoaded()
	self.baseColor = CPAPI.CreateColorFromHexString(db('crosshairColor'))
	self.swings    = self.swings or {};
	self.inRange   = self.inRange or {};
	if not self.textured then
		self.textured = true;
		for _, texture in ipairs({self.Track, self.Full, self.Left, self.Right}) do
			texture:SetTexture(RING_TEXTURE)
		end
		for _, texture in ipairs({self.Full, self.Left, self.Right}) do
			texture:SetRadialProgressBarFeather(FEATHER)
		end
		self.Full:SetRadialProgressBarStartOffset(TOP)
		self.Left:SetRadialProgressBarEndOffset(TOP)
		self.Right:SetRadialProgressBarEndOffset(TOP)
		self.Right:SetRadialProgressBarReverse(true)
	end
	self:Layout()
	self:RefreshWeapons()
	local nativeTimer = ( db('crosshairStyle') == 'Reticle' and GamepadReticle ~= nil );
	self:SetEnabled(db('reticleSwingTimer') and not nativeTimer)
	return CPAPI.KeepMeForLater;
end

Timer:SetScript('OnUpdate', Timer.OnUpdate)
Timer:SetScript('OnEvent', Timer.OnEvent)
db:RegisterCallbacks(Timer.OnDataLoaded, Timer,
	'Settings/crosshairColor',
	'Settings/crosshairStyle',
	'Settings/crosshairSizeX',
	'Settings/crosshairSizeY',
	'Settings/reticleSwingTimer'
);
