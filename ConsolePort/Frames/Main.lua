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



local f = Test or CreateFrame("Frame", "Test", UIParent)
local x = Testy or CreateFrame("Frame", "Testy", Test)
local z = Testr or CreateFrame("Frame", "Testr", Test)
local m = ConsolePort
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
z.Inset:SetSize(200, 100)


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


-- Weird ass character stand 
local Stand = f.Stand or m:CreateAtlasTexture(f, "BNetGradientMain", "Stand", "OVERLAY")
Stand:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
Stand:SetPoint("TOPLEFT", f, "BOTTOMRIGHT", -475-8, 69+8)
Stand:SetGradientAlpha("VERTICAL", 1,1,1,1, cc.r,cc.g,cc.b, 0.75)



local Dress = f.Dress or CreateFrame("DressUpModel", nil, f)
f.Dress = Dress

f.Val = (race == "BloodElf" or race == "Scourge") and 193 or 0


Dress:SetAllPoints(f)
Dress:SetPoint("TOPLEFT", f, "TOPRIGHT", -550, 0)
Dress:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 150, 0)
Dress:SetUnit("player")
Dress:SetAnimation(f.Val)
Dress:UndressSlot(16)
Dress:UndressSlot(17)
Dress:SetAlpha(1)
Dress:SetScale(1)
Dress:SetLight(1, 0, -100, -120, 120, 0.25, cc.r, cc.g, cc.b, 100, 1,1,1)
Dress:SetFacing(-0.10*math.pi)

Dress.Settings = db.Atlas.Model

Dress:SetScript("OnShow", function(self)
	self:SetUnit("player")
	self:SetAnimation(self.Settings.Animation[race][sex])
	self:SetFacing(self.Settings.Facing[race][sex])
	self:UndressSlot(16)
	self:UndressSlot(17)
end)

Dress:SetScript("OnEnter", function(self)
	self:SetAnimation(15)
	self:SetFacing(0)
end)

Dress:SetScript("OnLeave", function(self)
	self:SetAnimation(self.Settings.Animation[race][sex])
	self:SetFacing(self.Settings.Facing[race][sex])
end)

Dress:SetScript("OnMouseWheel", function(self, delta)
	if self:GetFacing() > 0 then
		self:SetFacing(0)
	else
		self:SetFacing(math.pi)
	end
end)


function f:Toggle()
	if f:IsVisible() then
		f:Hide()
	else
		f:Show()
	end
end

tinsert(UISpecialFrames, "Test")