local _, db = ...

-- local Frame = CreateFrame("FRAME", "ConsolePortUI", UIParent, "SecureHandlerBaseTemplate")
-- Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
-- ConsolePort:CreateAtlasTexture(Frame, "Frame", "Main", "BACKGROUND", nil, true)

-- Frame.Exit = CreateFrame("BUTTON", nil, Frame, "SecureActionButtonTemplate");
-- Frame.Exit:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -6, 20)
-- ConsolePort:CreateAtlasButton(Frame.Exit, "Frame", "Exit", true, "DISABLE", true)

-- Frame:WrapScript(Frame.Exit, "OnClick", [[
-- 	self:GetParent():Hide();
-- ]]);



local f = CreateFrame("Frame", "ConsolePortUI", UIParent)
local x = CreateFrame("Frame", nil, f)
local z = CreateFrame("Frame", nil, f)
local m = ConsolePort

f.Sidebar = x
f.Main = z

f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f:SetSize(1000, 700)

x:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -80)
x:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 150, 0)

z:SetPoint("TOPLEFT", x, "TOPRIGHT", -15, 0)
z:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

f:SetBackdrop(m:G().Atlas.Backdrops.ShadowBorder)
x:SetBackdrop(m:G().Atlas.Backdrops.Inset)
z:SetBackdrop(m:G().Atlas.Backdrops.SimpleBorder)

x.Blacken = x.Blacken or x:CreateTexture()
x.Blacken:SetPoint("TOPLEFT", x, "TOPLEFT", 8, -8)
x.Blacken:SetPoint("BOTTOMRIGHT", x, "BOTTOMRIGHT", -8, 8)
x.Blacken:SetTexture(0,0,0)
x.Blacken:SetAlpha(0.5)

z.Blacken = z.Blacken or z:CreateTexture()
z.Blacken:SetPoint("TOPLEFT", z, "TOPLEFT", 8, -8)
z.Blacken:SetPoint("BOTTOMRIGHT", z, "BOTTOMRIGHT", -8, 8)
z.Blacken:SetTexture(0,0,0)
z.Blacken:SetAlpha(0.25)

z.Inset = z.Inset or CreateFrame("Frame", nil, z)
z.Inset:SetBackdrop(m:G().Atlas.Backdrops.ShadowBorder)
z.Inset:SetPoint("TOPLEFT", z, "TOPLEFT", 10, -10)
z.Inset:SetSize(300, 600)


local manage = f.Manage or m:CreateAtlasTexture(f, "BNetGradientMain", "Manage", "OVERLAY", "Manage")

manage:ClearAllPoints()
manage:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -20)
manage:SetPoint("BOTTOMLEFT", f, "TOPRIGHT", -100, -36)
manage:SetAlpha(0.5)


local left = f.TopLeft or m:CreateAtlasTexture(f, "BNetGradientMain", "TopBarLeft", "OVERLAY", "TopLeft")
local right = f.TopRight or m:CreateAtlasTexture(f, "BNetGradientMain", "TopBarRight", "OVERLAY", "TopRight")
local mid = f.TopMid or m:CreateAtlasTexture(f, "BNetGradientMain", "TopBarMid", "OVERLAY", "TopMid")
local line = f.TopLine or f:CreateTexture(nil, "BACKGROUND")

f.TopLine = line

line:SetTexture(0.05,0.05,0.05)
line:SetPoint("TOPLEFT", left, "TOPLEFT", 1, 1)
line:SetPoint("TOPRIGHT", right, "TOPRIGHT", -1, 1)
line:SetPoint("BOTTOMLEFT", left, "TOPLEFT", 0, 0)
line:SetPoint("BOTTOMRIGHT", right, "TOPRIGHT", 0, 0)

left:ClearAllPoints()
left:SetPoint("TOPLEFT", f, "TOPLEFT", 145, -4)
left:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", 160, -24)

right:ClearAllPoints()
right:SetPoint("TOPRIGHT", f, "TOPRIGHT", -145, -4)
right:SetPoint("BOTTOMLEFT", f, "TOPRIGHT", -160, -24)

mid:ClearAllPoints()
mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)



local Spec = f.Spec or f:CreateTexture(nil, "ARTWORK")
local overlays = "Interface\\TALENTFRAME\\"
local OLtable = m:G().Atlas.Overlays
local class = select(2, UnitClass("player"))
local race = select(2, UnitRace("player"))
local sex = UnitSex("player")
--local specTexture = OLtable[class][GetSpecializationInfo(GetSpecialization())]
f.Spec = Spec

local specTexture = OLtable.Predefined[class]

Spec:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -8)
Spec:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
Spec:SetTexture(overlays..specTexture)
Spec:SetTexCoord(unpack(m:G().Atlas.Overlays.Coords))
Spec:SetBlendMode("BLEND")
Spec:SetAlpha(1)

------- CLASS
local cc = RAID_CLASS_COLORS[class]
Spec:SetGradientAlpha("VERTICAL", 1,1,1,1, cc.r,cc.g,cc.b, 0.5)

local gradient = {
   "VERTICAL",
   cc.r, cc.g, cc.b, 1,
   cc.r*0.85, cc.g*0.85, cc.b*0.85, 1,
}


mid:SetGradientAlpha(unpack(gradient))
left:SetGradientAlpha(unpack(gradient))
right:SetGradientAlpha(unpack(gradient))

-----------------
-- MODEL STUFF --
-----------------

local interval = 0.05
local function UpdateLighting(self, elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > interval do
		local cursorX, cursorY = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		local modelX, modelY = self:GetCenter()
		local x, y = modelX - (cursorX/scale), modelY - (cursorY/scale)
		self:SetLight(1, 0, -200, x, y,  0.25, cc.r, cc.g, cc.b, self.Intensity, 1, 1, 1)
		if self.xVal then
			self.xVal:SetText("X: "..x)
			self.yVal:SetText("Y: "..y)
		end
		self.Timer = self.Timer - interval
	end
end

local function RefreshModel(self)
	local Settings 	= self.Settings
	local Position 	= Settings.Zoom[race][sex]
	local Animation = Settings.Animation[race][sex]
	local Facing 	= Settings.Facing[race][sex]
	-- have to run twice to position and scale correctly
	for i=1, 2 do
		self:SetUnit("player")
		self:SetPosition(unpack(Position))
		self:SetAnimation(Animation)
		self:SetFacing(Facing)
	end
end

-- CHARACTER STAND
local BG = CreateFrame("PlayerModel", nil, f)
f.Stand = BG
BG:SetFrameStrata("MEDIUM")
BG:SetPoint("TOPLEFT", f, "TOPRIGHT", -392, 0)
BG:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 10)
BG:SetCamDistanceScale(1)
BG:SetDisplayInfo(43367)
BG:SetAlpha(1)
BG:SetAnimation(0)
BG:SetPosition(1, 0.1, -0.75)
BG.Timer = 0
BG.Intensity = 1
BG:SetScript("OnUpdate", UpdateLighting)

-- DRESS UP MODEL
local Dress = f.Dress or CreateFrame("DressUpModel", nil, f)
f.Dress = Dress
Dress:SetPoint("TOPLEFT", f, "TOPRIGHT", -750, 0)
Dress:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 350, 8)
Dress:SetLight(1, 0, -100, -120, 120, 0.25, cc.r, cc.g, cc.b, 100, 1,1,1)
Dress.Settings = db.Atlas.Model
Dress.Timer = 0
Dress.Intensity = 1
Dress.xVal 	= Dress:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Dress.yVal 	= Dress:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Dress.xVal:SetPoint("TOPLEFT", Dress, "BOTTOM", -100, -10)
Dress.yVal:SetPoint("TOPLEFT", Dress, "BOTTOM", -100, -25)
Dress.RefreshModel = RefreshModel
Dress.UpdateLighting = UpdateLighting

Dress:SetScript("OnShow", RefreshModel)
Dress:SetScript("OnUpdate", UpdateLighting)

function f:Toggle()
	if f:IsVisible() then
		f:Hide()
	else
		f:Show()
	end
end


--BG:SetScript("OnUpdate", UpdateLighting)

tinsert(UISpecialFrames, "ConsolePortUI")



-- Rune		: 38068
-- Ulduar 	: 43367
-- HordeS	: 49254
-- Broken 	: 62294

-- CoolOrb 	: 53737
-- Flower 	: 40113

-- BannerA	: 64790
-- BannerH	: 64791
-- 49789



-- 60925

-- 59305