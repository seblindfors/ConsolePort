local _, db = ...;
local Crosshair = CPAPI.EventHandler(ConsolePortCrosshair)

---------------------------------------------------------------
-- Predicates
---------------------------------------------------------------
local CVAR_CENTER    = 'GamePadCursorCentering';
local GetCVarBool    = GetCVarBool;
local GamePadControl = IsGamePadFreelookEnabled;
local CursorControl  = IsGamePadCursorControlEnabled;
function Crosshair:ShouldDraw()
	return GamePadControl() and not CursorControl() and not GetCVarBool(CVAR_CENTER)
end

---------------------------------------------------------------
-- Move crosshair to position offset
---------------------------------------------------------------
local GetScaledCursorPosition, SetPoint = GetScaledCursorPosition, PixelUtil.SetPoint;
local UIParent, select = UIParent, select;

function Crosshair:Move()
	SetPoint(self, 'CENTER', UIParent, 'BOTTOM', 0, select(2,  GetScaledCursorPosition()))
end

---------------------------------------------------------------
-- Update script
---------------------------------------------------------------
local Clamp, multiplier, timer, throttle, drawn = Clamp, 30, 0, 0.1;
function Crosshair:OnUpdate(elapsed)
	timer = timer + elapsed;
	if (timer > throttle) then
		timer, drawn = 0, self:ShouldDraw()
		self:SetAlpha(Clamp(self:GetAlpha() + (drawn and elapsed*multiplier or -elapsed*multiplier), 0, 1))
		if drawn then
			self:Move()
		end
	end
end

---------------------------------------------------------------
-- Visual settings
---------------------------------------------------------------
function Crosshair:OnDataLoaded()
	local enabled = db('crosshairEnable')
	if not enabled then
		return self:Hide()
	end

	local w, h = db('crosshairSizeX'), db('crosshairSizeY')
	self:SetSize(w, h)

	local c = db('crosshairCenter')
	self.Top:SetEndPoint('CENTER', 0, (w * c))
	self.Left:SetEndPoint('CENTER', -(w * c), 0)
	self.Right:SetEndPoint('CENTER', (w * c), 0)
	self.Bottom:SetEndPoint('CENTER', 0, -(w * c))

	local thickness = db('crosshairThickness')
	local r, g, b, a = CPAPI.CreateColorFromHexString(db('crosshairColor')):GetRGBA()

	for _, obj in ipairs({'Top', 'Left', 'Right', 'Bottom'}) do
		local line = self[obj]
		line:SetThickness(thickness)
		line:SetStartPoint(obj, 0, 0)
		line:SetColorTexture(r, g, b, a)
	end

	self:SetScript('OnUpdate', self.OnUpdate)
	self:Show()
end

db:RegisterCallbacks(Crosshair.OnDataLoaded, Crosshair,
	'Settings/crosshairEnable',
	'Settings/crosshairSizeX',
	'Settings/crosshairSizeY',
	'Settings/crosshairColor',
	'Settings/crosshairCenter',
	'Settings/crosshairThickness'
);