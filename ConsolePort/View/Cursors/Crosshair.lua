local _, db = ...;
local Crosshair = CPAPI.EventHandler(ConsolePortCrosshair)
local CVAR_CENTER = 'GamePadCursorCentering';

---------------------------------------------------------------
-- Predicates
---------------------------------------------------------------
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
local timer, throttle, drawn = 0, 0.125;
function Crosshair:OnUpdate(elapsed)
	timer = timer + elapsed;
	if (timer > throttle) then
		timer, drawn = 0, self:ShouldDraw()
		self:SetAlpha(drawn and 1 or 0)
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
	local r, g, b, a = CreateColorFromHexString(db('crosshairColor')):GetRGBA()

	for _, obj in ipairs({'Top', 'Left', 'Right', 'Bottom'}) do
		local line = self[obj]
		line:SetThickness(thickness)
		line:SetStartPoint(obj, 0, 0)
		line:SetColorTexture(r, g, b, a)
	end

	self:SetScript('OnUpdate', self.OnUpdate)
	self:Show()
end

db:RegisterCallback('Settings/crosshairEnable', Crosshair.OnDataLoaded, Crosshair)
db:RegisterCallback('Settings/crosshairSizeX', Crosshair.OnDataLoaded, Crosshair)
db:RegisterCallback('Settings/crosshairSizeY', Crosshair.OnDataLoaded, Crosshair)
db:RegisterCallback('Settings/crosshairColor', Crosshair.OnDataLoaded, Crosshair)
db:RegisterCallback('Settings/crosshairCenter', Crosshair.OnDataLoaded, Crosshair)
db:RegisterCallback('Settings/crosshairThickness', Crosshair.OnDataLoaded, Crosshair)