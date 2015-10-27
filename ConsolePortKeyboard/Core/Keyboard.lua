local addOn, Language = ...
local class = select(2, UnitClass("player"))
local cc = RAID_CLASS_COLORS[class]

local Keyboard = CreateFrame("Frame", addOn, UIParent)
local DIR, Current = 0
local db = ConsolePort:DB()

local KEY = {
	RIGHT = false,
	LEFT = false,
	DOWN = false,
	UP = false,
}

local CMD = {
	CP_L_UP = "UP",
	CP_L_LEFT = "LEFT",
	CP_L_RIGHT = "RIGHT",
	CP_L_DOWN = "DOWN",
	CP_TR2 = "ENTER",
	CP_TR1 = "SPACE",
	CP_C_OPTION = "CLOSE",
	CP_R_OPTION = "NEXT",
	CP_L_OPTION = "PREV",
	CP_R_LEFT = "INPUT",
	CP_R_RIGHT = "INPUT",
	CP_R_DOWN = "INPUT",
	CP_R_UP = "INPUT",
}

local CLICK = {
	CP_R_UP = 1,
	CP_R_LEFT = 2,
	CP_R_DOWN = 3,
	CP_R_RIGHT = 4,
}

local DIRKEY = {
	UP = true,
	DOWN = true,
	LEFT = true,
	RIGHT = true,
	W = true,
	A = true,
	S = true,
	D = true,
}

local MODKEY = {
	SHIFT = true,
	LSHIFT = true,
	RSHIFT = true,
	CTRL = true,
	LCTRL = true,
	RCTRL = true,
	ALT = true,
	LALT = true,
	RALT = true,
}

function Keyboard:OMIT()
end

function Keyboard:CLOSE()
	self.Focus:ClearFocus()
	self.Focus:EnableKeyboard(true)
end

function Keyboard:LEFT()
	local text = self.Focus:GetText()
	local pos = self.Focus:GetCursorPosition()
	local marker = text:sub(pos-4, pos):find("{rt%d}")
	self.Focus:SetCursorPosition(marker and pos-5 or pos-1)
end

function Keyboard:RIGHT()
	local text = self.Focus:GetText()
	local pos = self.Focus:GetCursorPosition()
	local marker = text:sub(pos, pos+5):find("{rt%d}")
	self.Focus:SetCursorPosition(marker and pos+5 or pos+1)
end

function Keyboard:INPUT(input)
	local index = CLICK[input]
	if Current then
		Current.Buttons[index]:Click()
	end
end

function Keyboard:ERASE()
	local pos = self.Focus:GetCursorPosition()
	if pos ~= 0 then 
		local text = self.Focus:GetText()
		local offset

		for marker in pairs(Language.Markers) do
			offset = 	text:sub(pos-marker:len()-1, pos):find(marker) and marker:len() or
						text:sub(pos-marker:trim():len()-1, pos):find(marker:trim()) and marker:trim():len()
			if offset then
				break
			end
		end

		local first, second = text:sub(0, offset and pos-offset or pos-1), text:sub(pos+1)
		self.Focus:SetText(first..second)
		self.Focus:SetCursorPosition(offset and pos-offset or pos-1)
	end
end

function Keyboard:SPACE()
	if self.Focus:HasScript("OnSpacePressed") then
		self.Focus:GetScript("OnSpacePressed")(self.Focus)
	end
	self.Focus:Insert(" ")
end

function Keyboard:ENTER()
	if self.Focus:HasScript("OnEnterPressed") then
		self.Focus:GetScript("OnEnterPressed")(self.Focus)
	else
		self.Focus:Insert("\n")
	end
end

function Keyboard:SelectSet()
	DIR = KEY.UP and KEY.LEFT and 8 or 
	KEY.UP and KEY.RIGHT and 2 or
	KEY.DOWN and KEY.LEFT and 6 or
	KEY.DOWN and KEY.RIGHT and 4 or
	KEY.LEFT and 7 or
	KEY.RIGHT and 3 or
	KEY.UP and 1 or
	KEY.DOWN and 5 or 9

	if Current then
		Current:Leave()
	end

	if self.Sets[DIR] then
		self.Sets[DIR]:Enter()
		Current = self.Sets[DIR]
	else
		Current = nil
	end
	return DIR
end

function Keyboard:SetLayout()
	local layout = ConsolePortKeyboardSettings.Layout
	for i, Set in pairs(self.Sets) do
		for j, Char in pairs(Set.Buttons) do
			Char.Set[1] = layout[i][j][1]
			Char.Set[2] = layout[i][j][2]
			Char.Set[3] = layout[i][j][3]
			Char.Set[4] = layout[i][j][4]
		end
	end
end

function Keyboard:RunCommand(input)
	if not DIRKEY[input] and not MODKEY[input] then
		local action = GetBindingAction(input)
		if action and CMD[action] and self[CMD[action]] then
			self[CMD[action]](self, action)
		else
			self:Timeout(2)
		end
	end
end

function Keyboard:OnKeyDown(input)
	if not self:GetPropagateKeyboardInput() then
		KEY.UP = input == "UP" or input == "W" or KEY.UP
		KEY.DOWN = input == "DOWN" or input == "S" or KEY.DOWN
		KEY.LEFT = input == "LEFT" or input == "A" or KEY.LEFT
		KEY.RIGHT = input == "RIGHT" or input == "D" or KEY.RIGHT
		self:SelectSet()
		self:CheckModifier()
	end
	self:RunCommand(input)
end

function Keyboard:OnKeyUp(input)
	if not self:GetPropagateKeyboardInput() then
		if input == "UP" or input == "W" then
			KEY.UP = false
		elseif input == "DOWN" or input == "S" then
			KEY.DOWN = false
		elseif input == "LEFT" or input == "A" then
			KEY.LEFT = false
		elseif input == "RIGHT" or input == "D" then
			KEY.RIGHT = false
		end
		self:SelectSet()
		self:CheckModifier()
	end
end


function Keyboard:LoadFrame()
	for i=1, 8 do
		tinsert(self.Sets, self:CreateCharset(i))
	end

	local CenterSet = self:CreateCharset(9)
	tinsert(self.Sets, CenterSet)

	for i, Char in ipairs(CenterSet.Buttons) do
		Char.Set = {"{ck"..i.."}", "{ck"..i.."}", "{ck"..i.."}", "{ck"..i.."}"}
	end

	CenterSet:ClearAllPoints()
	CenterSet:SetPoint("CENTER", self, 0, 0)
	CenterSet:SetScript("OnShow", nil)

	local function Flash(self)
		db.UIFrameFadeOut(self.RingHiLite, 0.2, 1, 0)
		db.UIFrameFadeOut(self.RingBrighten, 0.2, 1, 0)
	end

	local function Space(self) Flash(self) Keyboard:SPACE() end
	local function Erase(self) Flash(self) Keyboard:ERASE() end
	local function Close(self) Flash(self) Keyboard:CLOSE() end
	local function Enter(self) Flash(self) Keyboard:ENTER() end

	CenterSet.Buttons[1].Click = Space
	CenterSet.Buttons[1]:SetScript("OnClick", Space)

	CenterSet.Buttons[2].Click = Erase
	CenterSet.Buttons[2]:SetScript("OnClick", Erase)

	CenterSet.Buttons[3].Click = Close
	CenterSet.Buttons[3]:SetScript("OnClick", Close)	

	CenterSet.Buttons[4].Click = Enter
	CenterSet.Buttons[4]:SetScript("OnClick", Enter)

	self:SelectSet()
	self:CheckModifier()
end

function Keyboard:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Keyboard:SetFocus(newFocus)
	if self.Focus then
		self.Focus:EnableKeyboard(true)
	end
	self.Focus = newFocus
	self.Focus:EnableKeyboard(false)
	self:SetParent(self.Focus)
	self:Show()
end


function Keyboard:LoadSettings()
	if not ConsolePortKeyboardSettings then
		local locale = GetLocale()
		ConsolePortKeyboardSettings = {
			Layout = Language[Language.Default[locale]] or Language.English,
			Language = Language[Language.Default[locale]] and Language.Default[locale] or "English",
		}
	end
end

function Keyboard:ADDON_LOADED(...)
	local name = ...
	if name == addOn then
		self:UPDATE_BINDINGS()
		self:LoadSettings()
		self:LoadFrame()
		self:CreateConfig()
	end
end

function Keyboard:UPDATE_BINDINGS()
	self.Bindings = {}
	for i, binding in pairs(ConsolePort:GetBindingNames()) do
		local key1, key2 = GetBindingKey(binding)
		if key1 then
			self.Bindings[key1] = binding
		end
		if key2 then
			self.Bindings[key2] = binding
		end
	end
end

function Keyboard:CheckModifier(...)
	local SetIndex = IsShiftKeyDown() and IsControlKeyDown() and 4 or IsShiftKeyDown() and 1 or IsControlKeyDown() and 3 or 2
	for i, Set in pairs(self.Sets) do
		for i, Char in pairs(Set.Buttons) do
			Char:SetChar(SetIndex)
		end
	end
end

function Keyboard:OnUpdate(elapsed)
	self.Timer = self.Timer + elapsed
	if self.Timer > 0.1 then
		if self.Focus then
			local text = self.Focus:GetText()
			if text ~= self.Mime:GetText() then
				self.Mime:SetText(text)
				self.Mime:SetTextColor(self.Focus:GetTextColor())
			end
		else
			self.Mime:SetText("")
		end
		self.Timer = 0
	end
end

function Keyboard:Timeout(time)
	db.UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0.25)
	for i, region in pairs({self:GetRegions()}) do
		db.UIFrameFadeOut(region, 0.2, region:GetAlpha(), 0)
	end
	self:SetPropagateKeyboardInput(true)
	self.Focus:EnableKeyboard(true)
	self.Timer = 0
	self:SetScript("OnUpdate", function(self, elapsed)
		self.Timer = self.Timer + elapsed
		if self.Timer > time then
			db.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
			for i, region in pairs({self:GetRegions()}) do
				db.UIFrameFadeIn(region, 0.2, region:GetAlpha(), 1)
			end
			self.Focus:EnableKeyboard(false)
			self:SetPropagateKeyboardInput(false)
			self:SetScript("OnUpdate", self.OnUpdate)
			self.Timer = 0
		end		
	end)
end

function Keyboard:OnHide()
	self.Mime:SetText("")
	for key, state in pairs(KEY) do
		KEY[key] = false
	end
end

---------------------------------------------------------------
-- Keyboard regions
---------------------------------------------------------------
Keyboard:SetPoint("CENTER", UIParent, 0, 0)
Keyboard:SetSize(300, 300)
Keyboard:Hide()

Keyboard.Backdrop = Keyboard:CreateTexture(nil, "BACKGROUND")
Keyboard.Backdrop:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Keyboard.Backdrop:SetBlendMode("ADD")
Keyboard.Backdrop:SetVertexColor(cc.r, cc.g, cc.b, 1)
Keyboard.Backdrop:SetPoint("CENTER", Keyboard, 0, 0)
Keyboard.Backdrop:SetSize(300, 30)

Keyboard.Gradient1 = Keyboard:CreateTexture(nil, "BACKGROUND")
Keyboard.Gradient1:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Keyboard.Gradient1:SetBlendMode("ADD")
Keyboard.Gradient1:SetVertexColor(cc.r, cc.g, cc.b, 1)
Keyboard.Gradient1:SetGradientAlpha("VERTICAL", cc.r, cc.g, cc.b, 0.5, 0, 0, 0, 0)
Keyboard.Gradient1:SetPoint("BOTTOM", Keyboard.Backdrop, "TOP", 0, 0)
Keyboard.Gradient1:SetSize(400, 128)

Keyboard.Gradient2 = Keyboard:CreateTexture(nil, "BACKGROUND")
Keyboard.Gradient2:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Keyboard.Gradient2:SetBlendMode("ADD")
Keyboard.Gradient2:SetVertexColor(cc.r, cc.g, cc.b, 1)
Keyboard.Gradient2:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, cc.r, cc.g, cc.b, 0.5)
Keyboard.Gradient2:SetPoint("TOP", Keyboard.Backdrop, "BOTTOM", 0, 0)
Keyboard.Gradient2:SetSize(400, 128)

Keyboard.Sets = {}

---------------------------------------------------------------
-- Keyboard scripts and events
---------------------------------------------------------------
Keyboard.Timer = 0
Keyboard:RegisterEvent("ADDON_LOADED")
Keyboard:RegisterEvent("UPDATE_BINDINGS")

Keyboard:SetScript("OnHide", Keyboard.OnHide)
Keyboard:SetScript("OnUpdate", Keyboard.OnUpdate)
Keyboard:SetScript("OnEvent", Keyboard.OnEvent)
Keyboard:SetScript("OnKeyDown", Keyboard.OnKeyDown)
Keyboard:SetScript("OnKeyUp", Keyboard.OnKeyUp)