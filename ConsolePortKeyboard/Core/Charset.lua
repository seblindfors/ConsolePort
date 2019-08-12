local addOn, Language = ...

local Keyboard = ConsolePortKeyboard

local db = ConsolePort:GetData()
local cR, cG, cB = db.Atlas.GetNormalizedCC()

local colors = {
	db.COLOR.UP,
	db.COLOR.LEFT,
	db.COLOR.DOWN,
	db.COLOR.RIGHT,
}

local function Hex2RGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

local function CharSetEnter(self)
	self.FadeIn(self.RingHiLite, 0.1, self.RingHiLite:GetAlpha(), 1)
	self.FadeIn(self.RingBrighten, 0.1, self.RingBrighten:GetAlpha(), 1)
	self.FadeOut(self.RingInsetBrighten, 0.1, self.RingInsetBrighten:GetAlpha(), 0.25)
end

local function CharSetLeave(self)
	self.FadeOut(self.RingHiLite, 0.1, self.RingHiLite:GetAlpha(), 0)
	self.FadeOut(self.RingBrighten, 0.1, self.RingBrighten:GetAlpha(), 0)
	self.FadeIn(self.RingInsetBrighten, 0.1, self.RingInsetBrighten:GetAlpha(), 0.5)
end

local function CharSetShow(self)
	local i = 5
	self:SetPoint("CENTER", Keyboard, 0, 0)
	self:SetScript("OnUpdate", function(self, elapsed)
		i = i - 1
		if i == 0 then
			self:SetScript("OnUpdate", nil)
			self:SetPoint("CENTER", Keyboard, self.xOff, self.yOff)
		else
			self:SetPoint("CENTER", Keyboard, self.xOff/i, self.yOff/i)
		end
	end)
end

local function CharSetChar(self, index)
	self.Index = index
	self.Text:SetText(Language.Markers[self.Set[index]] or self.Set[index])
end

local function CharClick(self)
	db.UIFrameFadeOut(self.RingHiLite, 0.2, 1, 0)
	db.UIFrameFadeOut(self.RingBrighten, 0.2, 1, 0)
	Keyboard.Focus:Insert(self.Set[self.Index])
end


function Keyboard:CreateCharset(i)
	local x, y, r, inner  = 0, 0, 200, 24
	local angle = (i+1) * (360 / 8) * math.pi / 180
	local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )

	local Charset = CreateFrame("Frame", "$parentCharSet"..i, self)
	Charset.xOff = -ptx
	Charset.yOff = pty
	Charset:SetSize(r/3,r/3)
	Charset:SetPoint("CENTER", self, "CENTER", -ptx, pty)
	Charset:SetScript("OnShow", CharSetShow)

	Charset.FadeIn, Charset.FadeOut = db.GetFaders()
	Charset.Enter = CharSetEnter
	Charset.Leave = CharSetLeave

	Charset.RingNormal = Charset:CreateTexture(nil, "BACKGROUND", nil, 0)
	Charset.RingNormal:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleBorder")
	Charset.RingNormal:SetPoint("CENTER", Charset, 0, 0)
	Charset.RingNormal:SetSize(r/2, r/2)

	Charset.RingHiLite = Charset:CreateTexture(nil, "BACKGROUND", nil, 1)
	Charset.RingHiLite:SetBlendMode("ADD")
	Charset.RingHiLite:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleBorder")
	Charset.RingHiLite:SetPoint("CENTER", Charset, 0, 0)
	Charset.RingHiLite:SetSize(r/2, r/2)

	Charset.RingBrighten = Charset:CreateTexture(nil, "BACKGROUND", nil, 2)
	Charset.RingBrighten:SetBlendMode("ADD")
	Charset.RingBrighten:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleBorder")
	Charset.RingBrighten:SetPoint("CENTER", Charset, 0, 0)
	Charset.RingBrighten:SetSize(r/2, r/2)

	Charset.RingInset = Charset:CreateTexture(nil, "ARTWORK", nil, 0)
	Charset.RingInset:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleCenter")
	Charset.RingInset:SetPoint("CENTER", Charset, 0, 0)
	Charset.RingInset:SetSize(r/2, r/2)

	Charset.RingInsetBrighten = Charset:CreateTexture(nil, "ARTWORK", nil, 1)
	Charset.RingInsetBrighten:SetBlendMode("ADD")
	Charset.RingInsetBrighten:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleCenter")
	Charset.RingInsetBrighten:SetPoint("CENTER", Charset, 0, 0)
	Charset.RingInsetBrighten:SetSize(r/2, r/2)
	-- test
	Charset.RingHiLite:SetVertexColor(cR, cG, cB, 1)
	Charset.RingBrighten:SetVertexColor(cR, cG, cB, 1)

	Charset.RingBrighten:SetAlpha(0)
	Charset.RingHiLite:SetAlpha(0)

	Charset.Buttons = {}

	for char=1, 4 do
		local angle = (char) * (360 / 4) * math.pi / 180
		local ptx, pty = x + inner * math.cos( angle ), y + inner * math.sin( angle )
		local Char = CreateFrame("Button", "$parentButton"..char, Charset)
		Char:SetSize(inner, inner)
		Char:SetPoint("CENTER", Charset, "CENTER", ptx, pty)

		Char.Ring = Char:CreateTexture(nil, "BACKGROUND", nil, 2)
		Char.Ring:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleBorder")
		Char.Ring:SetSize(31, 31)
		Char.Ring:SetPoint("CENTER", Char, 0, 0)

		Char.RingHiLite = Char:CreateTexture(nil, "BACKGROUND", nil, 3)
		Char.RingHiLite:SetBlendMode("ADD")
		Char.RingHiLite:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleBorder")
		Char.RingHiLite:SetSize(31, 31)
		Char.RingHiLite:SetPoint("CENTER", Char, 0, 0)

		Char.RingHiLite:SetVertexColor(cR, cG, cB, 1)
		Char.RingHiLite:SetAlpha(0)

		Char.RingBrighten = Char:CreateTexture(nil, "BACKGROUND", nil, 3)
		Char.RingBrighten:SetBlendMode("ADD")
		Char.RingBrighten:SetTexture("Interface\\AddOns\\ConsolePortKeyboard\\Textures\\CircleBorder")
		Char.RingBrighten:SetSize(31, 31)
		Char.RingBrighten:SetPoint("CENTER", Char, 0, 0)

		Char.RingBrighten:SetVertexColor(cR, cG, cB, 1)
		Char.RingBrighten:SetAlpha(0)

		local red, green, blue = Hex2RGB(colors[char])
		Char.Index = 2
		Char.Set = ConsolePortKeyboardLayout[i] and ConsolePortKeyboardLayout[i][char]
		Char.Text = Char:CreateFontString(nil, "ARTWORK")
		Char.Text:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 18)
		Char.Text:SetTextColor(red/255, green/255, blue/255, 1)
		Char.Text:SetText(Char.Set and Char.Set[2])
		Char.Text:SetPoint("CENTER", Char, 0, 0)

		Char.SetChar = CharSetChar
		Char.Click = CharClick

		Char:SetScript("OnClick", Char.Click)

		tinsert(Charset.Buttons, Char)
	end

	return Charset
end