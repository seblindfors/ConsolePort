local _, db = ...;
local Crosshair = CPAPI.DataHandler(ConsolePortCrosshair)

---------------------------------------------------------------
-- Predicates
---------------------------------------------------------------
local CVAR_CENTER    = 'GamePadCursorCentering';
local RadialShown    = false;
local PopupShown     = false;
local GetCVarBool    = GetCVarBool;
local GamePadControl = IsGamePadFreelookEnabled;
local CursorControl  = IsGamePadCursorControlEnabled;
function Crosshair:ShouldDraw()
	return  GamePadControl()
		and not CursorControl()
		and not GetCVarBool(CVAR_CENTER)
		and not RadialShown
		and not PopupShown;
end

---------------------------------------------------------------
-- Move crosshair to position offset
---------------------------------------------------------------
local GetScreenHeight, SetPoint = GetScreenHeight, PixelUtil.SetPoint;
local UIParent, GetCVar, tonumber = UIParent, GetCVar, tonumber;

function Crosshair:Move()
	SetPoint(self, 'CENTER', UIParent, 'BOTTOM', 0, GetScreenHeight() * tonumber(GetCVar('CursorCenteredYPos')))
end

---------------------------------------------------------------
-- Update script
---------------------------------------------------------------
local Clamp, multiplier, timer, throttle, drawn = Clamp, 30, 0, 0.1;
local NativeReticle = GamepadReticle;
local LINES = {'Top', 'Left', 'Right', 'Bottom'};

-- Blizzard's reticle and its swing timer are driven with widget calls
-- only: Show, Hide, SetAlpha, Recenter, RegisterEvent. Every field
-- their handlers read is written by Blizzard's own code, so those
-- handlers keep running securely. Calling their methods or writing
-- their fields from here would taint them.
local SWING_EVENTS = {'PLAYER_SWING', 'WEAPON_SLOT_CHANGED', 'PLAYER_ENTERING_WORLD'};
local DOT_DEFAULT_SIZE = 4;

function Crosshair:UsesNativeReticle()
	return self.style == 'Reticle' and NativeReticle ~= nil;
end

function Crosshair:DriveNativeReticle(alpha)
	if CPAPI.IsNativeNavigationActive() then
		if ( NativeReticle:GetAlpha() ~= 1 ) then
			NativeReticle:SetAlpha(1)
		end
		return;
	end
	if not NativeReticle:IsShown() then
		NativeReticle:Recenter()
		NativeReticle:Show()
	end
	NativeReticle:SetAlpha(alpha)
end

function Crosshair:ReleaseNativeReticle()
	if not NativeReticle or CPAPI.IsNativeNavigationActive() then return end;
	self:SetNativeSwingTimer(false)
	self:SetNativeDot(DOT_DEFAULT_SIZE, 1, 1, 1, 1)
	NativeReticle:SetAlpha(1)
	NativeReticle:Hide()
end

function Crosshair:SetNativeDot(size, r, g, b, a)
	local dot = NativeReticle and NativeReticle.Icons and NativeReticle.Icons.StandardIcon;
	if not dot then return end;
	dot:SetSize(size, size)
	dot:SetVertexColor(r, g, b, a)
end

-- The Gamepad style registers these itself and unregisters them on
-- the way out, so this runs again on every return to the Mkb style.
function Crosshair:SetNativeSwingTimer(enabled)
	local timer = NativeReticle and NativeReticle.SwingTimer;
	if not timer or CPAPI.IsNativeNavigationActive() then return end;
	for _, event in ipairs(SWING_EVENTS) do
		if enabled then timer:RegisterEvent(event) else timer:UnregisterEvent(event) end
	end
	if enabled then
		timer:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player')
	else
		timer:UnregisterEvent('UNIT_INVENTORY_CHANGED')
		timer:Hide()
	end
end

function Crosshair:OnNativeNavigationChanged(active)
	if not active and self:UsesNativeReticle() then
		self:SetNativeSwingTimer(db('reticleSwingTimer'))
	end
end

function Crosshair:OnUpdate(elapsed)
	timer = timer + elapsed;
	if (timer > throttle) then
		timer, drawn = 0, self:ShouldDraw()
		local alpha = Clamp(self:GetAlpha() + ((drawn and 1 or -1) * (elapsed*multiplier)), 0, 1);
		self:SetAlpha(alpha)
		if drawn then
			self:Move()
		end
		if self:UsesNativeReticle() then
			self:DriveNativeReticle(alpha)
		end
	end
end

---------------------------------------------------------------
-- Visual settings
---------------------------------------------------------------
function Crosshair:OnDataLoaded()
	local enabled = db('crosshairEnable')
	self.style = db('crosshairStyle')
	if not enabled then
		self:Hide()
		self:ReleaseNativeReticle()
		return CPAPI.KeepMeForLater;
	end

	local useNative = self:UsesNativeReticle()
	for _, obj in ipairs(LINES) do
		self[obj]:SetShown(not useNative)
	end
	local r, g, b, a = CPAPI.CreateColorFromHexString(db('crosshairColor')):GetRGBA()
	if useNative then
		self:SetNativeSwingTimer(db('reticleSwingTimer'))
		self:SetNativeDot(db('crosshairDotSize'), r, g, b, a)
	else
		self:ReleaseNativeReticle()
	end

	local w, h = db('crosshairSizeX'), db('crosshairSizeY')
	self:SetSize(w, h)

	local c = db('crosshairCenter')
	self.Top:SetEndPoint('CENTER', 0, (w * c))
	self.Left:SetEndPoint('CENTER', -(w * c), 0)
	self.Right:SetEndPoint('CENTER', (w * c), 0)
	self.Bottom:SetEndPoint('CENTER', 0, -(w * c))

	local thickness = db('crosshairThickness')

	for _, obj in ipairs(LINES) do
		local line = self[obj]
		line:SetThickness(thickness)
		line:SetStartPoint(obj, 0, 0)
		line:SetColorTexture(r, g, b, a)
	end

	self:SetScript('OnUpdate', self.OnUpdate)
	self:Show()
	return CPAPI.KeepMeForLater;
end

db:RegisterCallbacks(Crosshair.OnDataLoaded, Crosshair,
	'Settings/crosshairEnable',
	'Settings/crosshairStyle',
	'Settings/reticleSwingTimer',
	'Settings/crosshairSizeX',
	'Settings/crosshairSizeY',
	'Settings/crosshairDotSize',
	'Settings/crosshairColor',
	'Settings/crosshairCenter',
	'Settings/crosshairThickness'
);
db:RegisterCallback('OnRadialShown', function(_, shown) RadialShown = shown end)
db:RegisterCallback('OnPopupShown', function(_, shown) PopupShown = shown end)
db:RegisterCallback('OnNativeNavigationChanged', Crosshair.OnNativeNavigationChanged, Crosshair)
