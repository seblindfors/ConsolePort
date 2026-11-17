if not C_GamepadTargeting then return end;
local _, db = ...;
local Indicator = CPAPI.DataHandler(ConsolePortAimIndicator)

---------------------------------------------------------------
-- Aim indicator
---------------------------------------------------------------
-- Shown while a native targeting button is held and the right stick
-- is deflected. An arrow on the ground from the character toward
-- the stick's angle, redrawn on stick events, fading in over FADE_IN
-- seconds so a nudge of the stick barely shows. Ground points pass
-- through a camera pitched by the ground tilt setting, so the arrow
-- shortens toward the horizon and its lines thin and dim with depth.
-- The arrow floats above a shadow on the ground. The head is a
-- filled triangle of lines fanned from the tip to its base. Arrow
-- colour follows the reaction of the current target.

local UnitExists, UnitReaction = UnitExists, UnitReaction;
local Clamp, sqrt = Clamp, math.sqrt;
local Scrub, SetPoint = CPAPI.Scrub, PixelUtil.SetPoint;

local FADE_IN, FADE_OUT, DEADZONE, STICK = 0.4, 0.15, 0.2, 'Right';
local RADIUS_FACTOR = 0.26;
local ARROW_THICKNESS, HEAD_LENGTH, HEAD_HALF_WIDTH, HATCH = 0.06, 0.20, 0.12, 40;
local CAMERA_DISTANCE, LIFT, SHADOW_ALPHA, FAR_DIM = 2.5, 0.08, 0.5, 0.3;
local LINE_TEXTURE  = CPAPI.GetAsset([[Textures\Cursor\SoftLine]]);
local SHAFT_TEXTURE = CPAPI.GetAsset([[Textures\Cursor\SoftLineFade]]);

local REACTION_COLORS = {
	[1] = CreateColor(0.85, 0.20, 0.20); -- hated
	[2] = CreateColor(0.85, 0.20, 0.20); -- hostile
	[3] = CreateColor(0.85, 0.20, 0.20); -- unfriendly
	[4] = CreateColor(1.00, 0.81, 0.00); -- neutral
	[5] = CreateColor(0.20, 0.80, 0.20); -- friendly
	[6] = CreateColor(0.20, 0.80, 0.20); -- honored
	[7] = CreateColor(0.20, 0.80, 0.20); -- revered
	[8] = CreateColor(0.20, 0.80, 0.20); -- exalted
};

---------------------------------------------------------------
-- Geometry
---------------------------------------------------------------
function Indicator:Move()
	SetPoint(self, 'CENTER', UIParent, 'CENTER', 0, 0)
	local radius = UIParent:GetHeight() * RADIUS_FACTOR;
	if ( radius ~= self.radius ) then
		self.radius = radius;
		self:Redraw()
	end
end

function Indicator:CreateLines()
	self.radius = UIParent:GetHeight() * RADIUS_FACTOR;
	self.Lines, self.Shadows = {}, {};
	for i = 1, HATCH + 1 do
		local texture = ( i == 1 ) and SHAFT_TEXTURE or LINE_TEXTURE;
		local line, shadow = self:CreateLine(nil, 'ARTWORK'), self:CreateLine(nil, 'BACKGROUND')
		line:SetTexture(texture)
		shadow:SetTexture(texture)
		self.Lines[i], self.Shadows[i] = line, shadow;
	end
end

-- @param gx, gy: ground point in radii, x right, y away from the camera
-- @return x, y: offset from the centre
-- @return depth: 1 at the character, smaller further away
function Indicator:Project(gx, gy)
	local tilt = self.tilt;
	local depth = CAMERA_DISTANCE / (CAMERA_DISTANCE + gy * sqrt(1 - tilt * tilt));
	local radius = self.radius * depth;
	return gx * radius, gy * tilt * radius, depth;
end

function Indicator:DrawLine(index, x1, y1, d1, x2, y2, d2, thickness)
	local line, shadow = self.Lines[index], self.Shadows[index];
	local depth, strength = (d1 + d2) / 2, self.strength or 0;
	local lift = self.radius * LIFT * sqrt(1 - self.tilt ^ 2);
	local brightness = 1 - FAR_DIM * (1 - depth);
	local r, g, b = self.arrowColor:GetRGB()
	thickness = thickness * depth;
	shadow:SetThickness(thickness)
	shadow:SetStartPoint('CENTER', self, x1, y1)
	shadow:SetEndPoint('CENTER', self, x2, y2)
	shadow:SetVertexColor(0, 0, 0, SHADOW_ALPHA * strength)
	line:SetThickness(thickness)
	line:SetStartPoint('CENTER', self, x1, y1 + lift * d1)
	line:SetEndPoint('CENTER', self, x2, y2 + lift * d2)
	line:SetVertexColor(r * brightness, g * brightness, b * brightness, strength)
end

function Indicator:Redraw()
	local dx, dy = self.aimX or 0, self.aimY or 1;
	local bx, by = dx * (1 - HEAD_LENGTH), dy * (1 - HEAD_LENGTH);
	local ox, oy, od = self:Project(0, 0)
	local tx, ty, td = self:Project(dx, dy)
	local sx, sy, sd = self:Project(bx + dx * ARROW_THICKNESS, by + dy * ARROW_THICKNESS)
	local lx, ly, ld = self:Project(bx - dy * HEAD_HALF_WIDTH, by + dx * HEAD_HALF_WIDTH)
	local rx, ry, rd = self:Project(bx + dy * HEAD_HALF_WIDTH, by - dx * HEAD_HALF_WIDTH)
	self:DrawLine(1, ox, oy, od, sx, sy, sd, self.radius * ARROW_THICKNESS)
	local thickness = sqrt((rx - lx) ^ 2 + (ry - ly) ^ 2) / (HATCH - 1) * 1.6 / ((ld + rd) / 2);
	for i = 1, HATCH do
		local t = (i - 1) / (HATCH - 1);
		self:DrawLine(i + 1, tx, ty, td, lx + (rx - lx) * t, ly + (ry - ly) * t, ld + (rd - ld) * t, thickness)
	end
end

---------------------------------------------------------------
-- Input and state
---------------------------------------------------------------
function Indicator:SetStick(x, y, len)
	if ( len > DEADZONE ) then
		local norm = sqrt(x * x + y * y);
		self.aimX, self.aimY = x / norm, y / norm;
	end
	self.strength = Clamp((len - DEADZONE) / (0.8 - DEADZONE), 0, 1);
	self:Redraw()
end

function Indicator:OnGamePadStick(stick, x, y, len)
	if ( stick == STICK ) then
		self:SetStick(x, y, len)
	end
end

function Indicator:OnUpdate(elapsed)
	local alpha, target = self:GetAlpha(), ( (self.strength or 0) > 0 ) and 1 or 0;
	local step = elapsed / ( target > alpha and FADE_IN or FADE_OUT );
	self:SetAlpha(Clamp(alpha + Clamp(target - alpha, -step, step), 0, 1))
end

function Indicator:UpdateTargetColor()
	local color = self.baseColor;
	if UnitExists('target') then
		local reaction = Scrub(UnitReaction('player', 'target'))
		color = REACTION_COLORS[reaction] or color;
	end
	self.arrowColor = color;
	self:Redraw()
end

function Indicator:PLAYER_TARGET_CHANGED()
	self:UpdateTargetColor()
end

function Indicator:OnAimHold(held)
	if not ( held and self.enabled ) then
		return self:Hide()
	end
	self.strength = 0;
	self:SetAlpha(0)
	self:Move()
	self:UpdateTargetColor()
	self:Show()
end

function Indicator:OnShow()
	self:EnableGamePadStick(true)
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
end

function Indicator:OnHide()
	self:EnableGamePadStick(false)
	self:UnregisterEvent('PLAYER_TARGET_CHANGED')
end

function Indicator:OnEvent(event)
	self[event](self)
end

function Indicator:OnDataLoaded()
	self.baseColor = CPAPI.CreateColorFromHexString(db('crosshairColor'))
	self.enabled   = db('aimIndicatorEnable')
	self.tilt      = db('aimIndicatorTilt')
	if not self.Lines then
		self:CreateLines()
	end
	if not self.enabled then
		self:Hide()
	end
	self:UpdateTargetColor()
	return CPAPI.KeepMeForLater;
end

Indicator:SetPropagateKeyboardInput(true)
Indicator:EnableGamePadStick(false)
Indicator:SetScript('OnUpdate', Indicator.OnUpdate)
Indicator:SetScript('OnGamePadStick', Indicator.OnGamePadStick)
Indicator:SetScript('OnShow', Indicator.OnShow)
Indicator:SetScript('OnHide', Indicator.OnHide)
Indicator:SetScript('OnEvent', Indicator.OnEvent)
db:RegisterCallback('OnAimHold', Indicator.OnAimHold, Indicator)
db:RegisterCallbacks(Indicator.OnDataLoaded, Indicator,
	'Settings/crosshairColor',
	'Settings/aimIndicatorEnable',
	'Settings/aimIndicatorTilt'
);
