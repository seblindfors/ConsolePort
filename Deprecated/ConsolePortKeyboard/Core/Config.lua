local addOn, Language = ...
---------------------------------------------------------------
local db = ConsolePort:GetData()
local Copy, pairsByKeys, Hex2RGB = db.table.copy, db.table.spairs, db.Hex2RGB
---------------------------------------------------------------
local Keyboard = ConsolePortKeyboard
local NewLayout
---------------------------------------------------------------
local colors = {
	db.COLOR.UP,
	db.COLOR.LEFT,
	db.COLOR.DOWN,
	db.COLOR.RIGHT,
}
---------------------------------------------------------------
local WindowMixin = {}

function WindowMixin:Save()
	ConsolePortKeyboardLayout = NewLayout and Copy(NewLayout) or ConsolePortKeyboardLayout
	db.Settings.disableKeyboard = not self.ToggleKeyboard:GetChecked()
	Keyboard:SetLayout()
	Keyboard:SetEnabled(not db.Settings.disableKeyboard)
end

function WindowMixin:Default()
	ConsolePortKeyboardLayout = nil
	Keyboard:LoadSettings()
end

function WindowMixin:Cancel()
	NewLayout = nil
end

---------------------------------------------------------------
local function CreateLanguageButton(parent, num)
	local button = CreateFrame("Button", "$parentButton"..num, parent, "OptionsListButtonTemplate")
	button:SetHeight(24)
	button.text:ClearAllPoints()
	button.text:SetPoint("LEFT", 24, 0)
	tinsert(parent.Buttons, button)
	if num == 1 then
		button:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, 0)
		button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, 0)
	else
		button:SetPoint("TOPLEFT", parent.Buttons[num-1], "BOTTOMLEFT")
		button:SetPoint("TOPRIGHT", parent.Buttons[num-1], "BOTTOMRIGHT")
	end
	return button
end

local function LanguageButtonOnClick(self)
	NewLayout = Copy(self.layout)
	self.parent:UpdateFields()
end

local function RefreshLanguageList(self)
	local num = 0
	for name, layout in pairsByKeys(Language) do
		if name ~= "Default" and name ~= "Markers" then
			num = num + 1
			local button
			if not self.Buttons[num] then
				button = CreateLanguageButton(self, num)
				button.parent = self.parent
			else
				button = self.Buttons[num]
			end
			button.layout = layout
			button.name = name
			button:SetText(name)
			button:SetScript("OnClick", LanguageButtonOnClick)
		end
	end
	self:SetHeight(num*24)
end
---------------------------------------------------------------
local function ConfigureConfig(Config, self)
	Config:SetScript("OnShow", function(self)
		Keyboard:SetEnabled(false)
	end)

	Config:SetScript("OnHide", function(self)
		Keyboard:SetEnabled(not db.Settings.disableKeyboard)
	end)

	function Config:UpdateFields()
		local layout = NewLayout or ConsolePortKeyboardLayout
		for i, Field in pairs(self.Fields) do
			Field:Update(layout)
		end
	end

	Config.Fields = {}

	local function UpdateField(self, layout)
		self:SetText(layout[self.Index[1]][self.Index[2]][self.Index[3]])
		self:SetCursorPosition(0)
	end

	local function TextChanged(self, userInput)
		if userInput then
			if not NewLayout then
				NewLayout = Copy(ConsolePortKeyboardLayout)
			end
			NewLayout[self.Index[1]][self.Index[2]][self.Index[3]] = self:GetText()
		end
	end

	for setIndex, buttonSet in ipairs(ConsolePortKeyboardLayout) do
		for btnIndex, button in ipairs(buttonSet) do
			for index, string in pairs(button) do
				local Field = CreateFrame("EditBox", "$parentField"..setIndex..btnIndex..index, Config)
				local red, green, blue = Hex2RGB(colors[btnIndex], true)
				local point, anchor, relativePoint, xOffset, yOffset = Keyboard.Sets[setIndex]:GetPoint()
				-- offset the points in a circular fashion
				Field:SetPoint(point, Config, relativePoint,
					floor( (116+(xOffset)+(index-2)*60) + 0.5 ),
					floor( (60+(yOffset*((setIndex == 1 or setIndex == 5) and 1.125 or 0.8))-btnIndex*24) + 0.5))
				Field:SetSize(72, 36)
				Field:SetBackdrop(db.Atlas.Backdrops.FullSmall)
				------------------------------------------
				Field:SetJustifyH("CENTER")
				Field.Index = {setIndex, btnIndex, index}
				Field.Update = UpdateField
				Field:SetAutoFocus(false)
				Field:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 14)
				Field:SetTextColor(red, green, blue, 1)
				Field:SetText(string)
				Field:SetCursorPosition(0)
				Field:SetScript("OnTextChanged", TextChanged)
				tinsert(Config.Fields, Field)
			end
		end
	end

	local instructions = {
		"|T"..db.TEXTURE.CP_M1..":0|t "..KEY_SPACE,
		"|T"..db.TEXTURE.CP_M2..":0|t "..COMPLETE,
	}
	local tutString = Config:CreateFontString(nil, "BACKGROUND", "Game18Font")
	tutString:SetPoint("CENTER", Config, "CENTER", 146, 0)
	tutString:SetJustifyH("LEFT")
	tutString:SetText(table.concat(instructions, "\n"))

	Config.LanguageList = CreateFrame("Frame", "$parentLanguageList", Config)
	Config.LanguageList:SetSize(260, 1000)
	Config.LanguageList.parent = Config
	Config.LanguageList.Buttons = {}
	Config.LanguageList:SetScript("OnShow", RefreshLanguageList)

	Config.LanguageScroll = CreateFrame("ScrollFrame", "$parentLanguageScrollFrame", Config, "UIPanelScrollFrameTemplate")
	Config.LanguageScroll:SetPoint("TOPLEFT", Config, "TOPLEFT", 24, -40)
	Config.LanguageScroll:SetPoint("BOTTOMLEFT", Config, "BOTTOMLEFT", 24, 40)
	Config.LanguageScroll:SetWidth(260)
	Config.LanguageScroll:SetScrollChild(Config.LanguageList)

	Config.LanguageScroll.ScrollBar.scrollStep = 64
	Config.LanguageScroll.ScrollBar:ClearAllPoints()
	Config.LanguageScroll.ScrollBar:SetPoint("TOPLEFT", Config.LanguageScroll, "TOPRIGHT", 0, 0)
	Config.LanguageScroll.ScrollBar:SetPoint("BOTTOMLEFT", Config.LanguageScroll, "BOTTOMRIGHT", 0, 0)
	Config.LanguageScroll.ScrollBar.Thumb = Config.LanguageScroll.ScrollBar:GetThumbTexture()
	Config.LanguageScroll.ScrollBar.Thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	Config.LanguageScroll.ScrollBar.Thumb:SetTexCoord(0, 1, 0, 1)
	Config.LanguageScroll.ScrollBar.Thumb:SetSize(18, 34)
	Config.LanguageScroll.ScrollBar.ScrollUpButton:SetAlpha(0)
	Config.LanguageScroll.ScrollBar.ScrollDownButton:SetAlpha(0)

	Config.ScrollWrap = CreateFrame("Frame", "$parentScrollFrameWrap", Config)
	Config.ScrollWrap:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.ScrollWrap:SetPoint("TOPLEFT", Config, "TOPLEFT", 8, -24)
	Config.ScrollWrap:SetPoint("BOTTOMLEFT", Config, "BOTTOMLEFT", 8, 40)
	Config.ScrollWrap:SetWidth(316)

	Config.LanguageListText = Config:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	Config.LanguageListText:SetPoint("BOTTOMLEFT", Config.ScrollWrap, "TOPLEFT", 16, -8)
	Config.LanguageListText:SetText(db.TUTORIAL.CONFIG.KEYBOARDLANG)

	Config.ToggleKeyboard = CreateFrame("CheckButton", "$parentToggleButton", Config, "ChatConfigCheckButtonTemplate")
	Config.ToggleKeyboard.Text = Config.ToggleKeyboard:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	Config.ToggleKeyboard.Text:SetText("Enable keyboard")
	Config.ToggleKeyboard.Text:SetPoint("LEFT", 30, 1)
	Config.ToggleKeyboard:SetPoint("BOTTOMLEFT", 24, 24)
	Config.ToggleKeyboard:SetChecked(not db.Settings.disableKeyboard)
	Config.ToggleKeyboard:SetScript("OnShow", function(self)
		self:SetChecked(not db.Settings.disableKeyboard)
	end)

	Keyboard:SetEnabled(not db.Settings.disableKeyboard)
end
---------------------------------------------------------------
function Keyboard:CreateConfig()
	ConsolePortOldConfig:AddPanel({
		name = "Keyboard", 
		header = "Keyboard", 
		mixin = WindowMixin, 
		onCreate = ConfigureConfig
	})
end