---------------------------------------------------------------
-- Spellhelper.lua: Flyout / spellbook helper frames
---------------------------------------------------------------
-- Adds custom frames to deal with multi-choice spell-casting,
-- such as portals/teleports, totems, pets, etc. 

local _, db = ...

local Flyout = SpellFlyout
local GameTooltip = GameTooltip
local FadeIn = db.UIFrameFadeIn

Flyout.ignoreNode = true
Flyout:SetAlpha(0)

local Selector = CreateFrame("Button", "ConsolePortSpellFlyout", UIParent, "SecureHandlerBaseTemplate, SecureActionButtonTemplate")

local SelectMouse = CreateFrame("Button", "$parentMouse", Selector, "SecureActionButtonTemplate")
SelectMouse:SetAllPoints()
SelectMouse:SetAttribute("type", "click")
SelectMouse:RegisterForClicks("AnyUp", "AnyDown")
SelectMouse:SetAttribute("clickbutton", Selector)
SelectMouse:SetFrameLevel(20)

---------------------------------------------------------------
local Buttons = {
	Up 		= "CP_L_UP",
	Down 	= "CP_L_DOWN",
	Left 	= "CP_L_LEFT",
	Right 	= "CP_L_RIGHT",
}
---------------------------------------------------------------
Selector:Execute([[
	Index = 1
	DPAD = newtable()
]])

for name, binding in pairs(Buttons) do
	Selector:Execute(format("DPAD.%s = \"%s\"", binding, name))
end

Selector:RegisterForClicks("AnyUp", "AnyDown")
Selector:SetAttribute("type", "macro")

Selector:SetFrameRef("Flyout", Flyout)
Selector:SetPoint("CENTER", 0, -200)

Selector:Execute([[
	Spells = newtable()
	Flyout = self:GetFrameRef("Flyout")
	Selector = self
]])

Selector:SetAttribute("SelectSpell", [[
	local key = ...
	if key == "Up" or key == "Down" then
		self:SetAttribute("macrotext", "/click "..Spells[Index]:GetName())
	elseif key == "Left" then
		Index = Index > 1 and Index - 1 or Index
	elseif key == "Right" then
		Index = Index < #Spells and Index + 1 or Index
	end
	self:SetAttribute("index", Index)
]])

Selector:SetAttribute("ShowSpells", [[
	Spells = newtable(Flyout:GetChildren())
	self:SetWidth(#Spells * 74)
	if not Spells[Index]:IsVisible() then
		Index = 1
	end
]])

Selector:WrapScript(Flyout, "OnShow", [[
	Selector:SetAttribute("macrotext", nil)
	Selector:Show()
	Flyout:ClearAllPoints()
	for binding, name in pairs(DPAD) do
		local key = GetBindingKey(binding)
		if key then
			Selector:SetBindingClick(true, key, Selector, name)
		end
	end
	Selector:RunAttribute("ShowSpells")
]])
Selector:WrapScript(Flyout, "OnHide", [[
	Selector:ClearBindings()
	Selector:Hide()
]])
Selector:WrapScript(Selector, "PreClick", [[
	if button == "LeftButton" then
		local x = self:GetMousePosition()
		local width = self:GetWidth()
		Index = math.floor(1 + ((x * width) / 74))
		self:SetAttribute("index", Index)
		self:SetAttribute("macrotext", "/click "..Spells[Index]:GetName())
	elseif down then
		self:RunAttribute("SelectSpell", button)
	end
]])

Selector.Buttons = {}
Selector:Hide()
Selector:SetHeight(100)

local red, green, blue = db.Atlas.GetCC()

Selector.BG = Selector:CreateTexture(nil, "BACKGROUND")
Selector.BG:SetPoint("TOPLEFT", Selector, "TOPLEFT", 16, -16)
Selector.BG:SetPoint("BOTTOMRIGHT", Selector, "BOTTOMRIGHT", -16, 16)
Selector.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Selector.BG:SetBlendMode("ADD")
Selector.BG:SetVertexColor(red, green, blue, 0.25)

Selector.TopLine = Selector:CreateTexture(nil, "BORDER")
Selector.TopLine:SetTexture("Interface\\LevelUp\\LevelUpTex")
Selector.TopLine:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500)
Selector.TopLine:SetHeight(7)
Selector.TopLine:SetPoint("TOPLEFT", 0, -9)
Selector.TopLine:SetPoint("TOPRIGHT", 0, -9)
Selector.TopLine:SetVertexColor(red, green, blue, 1)

Selector.BottomLine = Selector:CreateTexture(nil, "BORDER")
Selector.BottomLine:SetTexture("Interface\\LevelUp\\LevelUpTex")
Selector.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500)
Selector.BottomLine:SetHeight(7)
Selector.BottomLine:SetPoint("BOTTOMLEFT", 0, 16)
Selector.BottomLine:SetPoint("BOTTOMRIGHT", 0, 16)
Selector.BottomLine:SetVertexColor(red, green, blue, 1)


local function ShowFlyoutTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
	GameTooltip:SetSpellByID(self.spellID)
end

function Selector:SetSelection(index)
	for i, button in pairs(self.Buttons) do
		button:UnlockHighlight()
		FadeIn(button, 0.2, button:GetAlpha(), 1 - (abs(i - index) / #self.Buttons))
	--	button:SetAlpha(1 - (abs(i - index) / #self.Buttons))
	end
	local selected = self.Buttons[index]
	if selected then
		selected:LockHighlight()
		ShowFlyoutTooltip(selected)
	end
end

function Selector:OnShow()
	ActionStatus_DisplayMessage(format(db.TOOLTIP.CLICK.FLYOUT, BINDING_NAME_CP_L_UP, BINDING_NAME_CP_L_DOWN), true)
	for i, spell in pairs({Flyout:GetChildren()}) do
		local button = self.Buttons[i]
		if not button then
			button = db.Atlas.GetRoundActionButton("$parentFlyoutButton"..i, false, self, nil, nil, true)
			button:SetButtonState("DISABLED")
			button:SetID(i)
			self.Buttons[i] = button
		end
		button.icon:SetTexture(spell.icon:GetTexture())
		button.spellID = spell.spellID
		button:SetPoint("LEFT", (i-1) * 74, 0)
	end
	self:SetSelection(self:GetAttribute("index") or 1)
end

function Selector:OnHide()
	GameTooltip:Hide()
end

function Selector:OnAttributeChanged(attribute, detail)
	if attribute == "index" then
		self:SetSelection(detail)
	end
end

Selector:SetScript("OnShow", Selector.OnShow)
Selector:SetScript("OnHide", Selector.OnHide)
Selector:SetScript("OnAttributeChanged", Selector.OnAttributeChanged)

Selector:SetBackdrop({
	edgeFile 	= "Interface\\AddOns\\ConsolePort\\Textures\\Window\\EdgeFileNosides",
	edgeSize 	= 32,
	insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
})



---------------------------------------------------------------



local SpellWheel = CreateFrame("Button", "ConsolePortSpellWheel", UIParent, "SecureHandlerBaseTemplate, SecureActionButtonTemplate, SecureHandlerShowHideTemplate, SecureHandlerMouseWheelTemplate")
local red, green, blue = db.Atlas.GetCC()
SpellWheel:SetPoint("CENTER")
SpellWheel:SetSize(140, 140)
SpellWheel:EnableMouseWheel(true)
SpellWheel:SetAttribute("position", -1)
SpellWheel:SetAttribute("spellpos", 0)
SpellWheel:RegisterForClicks("AnyUp", "AnyDown")

SpellWheel.Bubble = SpellWheel:CreateTexture(nil, "BACKGROUND")
SpellWheel.Bubble:SetTexture("Interface\\Addons\\ConsolePort\\Textures\\Button\\Normal")
SpellWheel.Bubble:SetPoint("CENTER")
SpellWheel.Bubble:SetSize(180, 180)
SpellWheel.Bubble:SetAlpha(0.75)

SpellWheel.Separator = SpellWheel:CreateTexture(nil, "BORDER")
SpellWheel.Separator:SetTexture("Interface\\LevelUp\\LevelUpTex")
SpellWheel.Separator:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500)
SpellWheel.Separator:SetSize(160, 16)
SpellWheel.Separator:SetPoint("CENTER", 0)
SpellWheel.Separator:SetVertexColor(red, green, blue, 1)

SpellWheel.Letter = SpellWheel:CreateFontString("$parentLetterPos", "BACKGROUND", "SystemFont_Shadow_Outline_Huge2")
SpellWheel.Letter:SetPoint("CENTER", 0, 16)
SpellWheel.Letter:SetFont("Fonts\\FRIZQT__.TTF", 500, "OUTLINE")

SpellWheel.Spell = SpellWheel:CreateFontString("$parentSpellName", "BACKGROUND", "GameFontHighlight")
SpellWheel.Spell:SetPoint("CENTER", 0, -20)

SpellWheel:SetAttribute("type", "spell")
SpellWheel:Execute([[
	---------------------------------------------------------------
	Direction = false
	Buttons = newtable()
	Keys = newtable()
	Sub = newtable()
	Add = newtable()
	---------------------------------------------------------------
	Keys.UP 	= "UP"
	Keys.LEFT 	= "LEFT"
	Keys.DOWN 	= "DOWN"
	Keys.RIGHT 	= "RIGHT"
	---------------------------------------------------------------
	Keys.W 		= "UP"
	Keys.A 		= "LEFT"
	Keys.S 		= "DOWN"
	Keys.D 		= "RIGHT"
	---------------------------------------------------------------
	Sub.UP 		= "LEFT"
	Sub.LEFT 	= "DOWN"
	Sub.DOWN 	= "RIGHT"
	Sub.RIGHT 	= "UP"
	---------------------------------------------------------------
	Add.UP 		= "RIGHT"
	Add.RIGHT 	= "DOWN"
	Add.DOWN 	= "LEFT"
	Add.LEFT 	= "UP"
	---------------------------------------------------------------
]])
SpellWheel:SetAttribute("spellupdate", [[
	self:SetAttribute("position", -1)
	self:SetAttribute("spellpos", #SPELLS - 10)
]])
SpellWheel:SetAttribute("spellusable", true)
SpellWheel:SetAttribute("spellsorted", true)
ConsolePort:RegisterSpellbook(SpellWheel)

function SpellWheel:OnAttributeChanged(attribute, detail)
	if attribute == "showspell" then
		local name = GetSpellInfo(detail)
		if name then
			self.Letter:SetText(name:sub(1, 1))
			self.Spell:SetText(name)
		end
		self.Group:Play()
	end
end

SpellWheel:WrapScript(SpellWheel, "PreClick", [[
	local toggle
	if not self:IsVisible() and not down then
		self:Show()
		self:SetAttribute("spell", nil)
		toggle = true
	end
	if self:IsVisible() then
		if down and Keys[button] then
			self:SetAttribute("spell", nil)
			if Sub[button] == Direction then
				self:RunAttribute("_onwheel", 1)
			elseif Add[button] == Direction then
				self:RunAttribute("_onwheel", -1)
			end
			Direction = button
		elseif down and not Keys[button] then
			self:SetAttribute("spell", nil)
		elseif not toggle and not down and not Keys[button] then
			self:SetAttribute("spell", self:GetFrameRef("focused"):GetAttribute("spell"))
			self:Hide()
		end
	end
]])

SpellWheel:WrapScript(SpellWheel, "PostClick", [[
	if not down then
		self:SetAttribute("spell", nil)
	end
]])

SpellWheel:SetAttribute("_onshow" ,[[
	for key, value in pairs(Keys) do
		self:SetBindingClick(true, key, self, value)
	end
	self:RunAttribute("_onwheel", 0)
]])

SpellWheel:SetAttribute("_onhide", [[
	self:ClearBindings()
]])

SpellWheel:SetAttribute("_onwheel", [[
	local delta = ...

	self:SetAttribute("position", self:GetAttribute("position") + delta)
	self:SetAttribute("spellpos", self:GetAttribute("spellpos") + delta)

	if self:GetAttribute("position") % 16 == 0 then
		self:SetAttribute("position", 0)
	end

	if self:GetAttribute("spellpos") > #SPELLS then
		self:SetAttribute("spellpos", 0)
	elseif self:GetAttribute("spellpos") < 1 then
		self:SetAttribute("spellpos", #SPELLS)
	end

	local offset = self:GetAttribute("position")
	local sOffset = self:GetAttribute("spellpos")

	for idx, button in pairs(Buttons) do
		local i = idx + 11
		local spellID = ((idx + sOffset) % #SPELLS) + 1

		local x, y = 0, 0
		local r = (i * 10) - (i^2 / 10)
		local offset = i + offset
		local angle = offset * (360 / 16) * math.pi / 180
		local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )

		button:SetAttribute("delta", delta)
		button:SetAttribute("spell", SPELLS[spellID])
		button:SetPoint("CENTER", self, "CENTER", -ptx, pty)
	end
	self:SetAttribute("showspell", self:GetFrameRef("focused"):GetAttribute("spell"))
]])

SpellWheel:SetAttribute("_onmousewheel", [[
	self:RunAttribute("_onwheel", delta)
]])

SpellWheel:HookScript("OnAttributeChanged", SpellWheel.OnAttributeChanged)
SpellWheel:Hide()

local NUM_SPELL_POS = 42
local NUM_LOOP_RESET = 16
local INDEX_MID = NUM_SPELL_POS/2

local function ButtonAttributeChanged(self, attribute, detail)
	if attribute == "spell" then
		self.icon:SetTexture(GetSpellTexture(detail))
		if self.Group then
			self.Group:Play()
		end
	end
end

SpellWheel.Group = SpellWheel:CreateAnimationGroup()

for i=1, NUM_SPELL_POS do
	if i >= 12 and i <= 30 then
		local idx = i - 11
		local button 
		if i == INDEX_MID then
			button = db.Atlas.GetRoundActionButton("$parentButton"..idx, false, SpellWheel, 64 + i)
			button:LockHighlight()
			button:SetAlpha(1)
			button:SetFrameLevel(2)
			button.Group = SpellWheel.Group
			button.Scale = button.Group:CreateAnimation("Scale")
			button.Scale:SetChildKey("Button"..idx)
			button.Scale:SetDuration(0.2)
			button.Scale:SetToScale(1, 1)
			button.Scale:SetFromScale(0.65, 0.65)
			button.Scale:SetOrigin("CENTER", 0, 0)

			SpellWheel:SetFrameRef("focused", button)
		else
			button = db.Atlas.GetRoundActionButton("$parentButton"..idx, false, SpellWheel, 28 + i)
			button:SetAlpha( 0.9 - (abs(i-INDEX_MID) * 0.05))
		end

		SpellWheel["Button"..idx] = button

		button:SetAttribute("type", "spell")
		button:SetScript("OnAttributeChanged", ButtonAttributeChanged)
		SpellWheel:SetFrameRef("newbutton", button)
		SpellWheel:Execute(format([[
			Buttons[%d] = self:GetFrameRef("newbutton")
		]], idx))
	end
end