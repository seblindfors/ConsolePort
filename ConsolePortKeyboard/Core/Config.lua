local addOn, Language = ...

local db = ConsolePort:DB()

local Keyboard = ConsolePortKeyboard
local NewLayout, NewLanguage

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

local function SaveKeyboardConfig()
	ConsolePortKeyboardSettings.Layout = NewLayout and db.Copy(NewLayout) or ConsolePortKeyboardSettings.Layout
	ConsolePortKeyboardSettings.Language = NewLanguage or ConsolePortKeyboardSettings.Language
	Keyboard:SetLayout()
end

local function LoadDefaultKeyboardConfig()
	ConsolePortKeyboardSettings = nil
	Keyboard:LoadSettings()
end

local function DiscardKeyboardConfig()
	NewLanguage = nil
	NewLayout = nil
end

function Keyboard:CreateConfig()
	local Config = db.CreatePanel(ConsolePortConfigFrameConfig, "Keyboard", "Keyboard", "Keyboard settings", SaveKeyboardConfig, DiscardKeyboardConfig, LoadDefaultKeyboardConfig)

	Config.Dispatcher = ConsolePortKeyboardDispatcher

	Config:SetScript("OnShow", function(self)
		self.Dispatcher:SetScript("OnUpdate", nil)
	end)

	Config:SetScript("OnHide", function(self)
		self.Dispatcher:SetScript("OnUpdate", self.Dispatcher.OnUpdate)
	end)

	function Config:UpdateFields()
		local layout = NewLayout or ConsolePortKeyboardSettings.Layout
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
				NewLayout = db.Copy(ConsolePortKeyboardSettings.Layout)
				NewLanguage = ConsolePortKeyboardSettings.Language
			end
			NewLayout[self.Index[1]][self.Index[2]][self.Index[3]] = self:GetText()
		end
	end

	for setIndex, buttonSet in ipairs(ConsolePortKeyboardSettings.Layout) do
		for btnIndex, button in ipairs(buttonSet) do
			for index, string in pairs(button) do
				local Field = CreateFrame("EditBox", "$parentField"..setIndex..btnIndex..index, Config, "InputBoxTemplate")
				local red, green, blue = Hex2RGB(colors[btnIndex])
				Field.Index = {setIndex, btnIndex, index}
				Field.Update = UpdateField
				Field:SetSize(50, 16)
				Field:SetAutoFocus(false)
				Field:SetPoint("TOPRIGHT", Config, "TOPRIGHT", ((index-1)*60)-184, -((setIndex-1)*4*17.5 + btnIndex*16)+10)
				Field:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 14)
				Field:SetTextColor(red/255, green/255, blue/255, 1)
				Field:SetText(string)
				Field:SetCursorPosition(0)
				Field:SetScript("OnTextChanged", TextChanged)
				tinsert(Config.Fields, Field)
			end
		end
	end

	local instructions = {
		"|T"..db.TEXTURE.LONE..":0|t "..KEY_SPACE,
		"|T"..db.TEXTURE.LTWO..":0|t "..COMPLETE,
		"\n1: |T"..db.TEXTURE.RONE..":0|t",
		"2: |cFF757575<"..strlower(CHAT_DEFAULT)..">|r",
		"3: |T"..db.TEXTURE.RTWO..":0|t",
		"4: |T"..db.TEXTURE.RONE..":0|t|T"..db.TEXTURE.RTWO..":0|t",
	}
	-- alpha stuff
	local tutString = Config:CreateFontString(nil, "BACKGROUND", "Game18Font")
	tutString:SetPoint("TOPLEFT", Config, "TOPLEFT", 16, -100)
	tutString:SetJustifyH("LEFT")
	tutString:SetText(table.concat(instructions, "\n"))

	Config.dropdown = CreateFrame("BUTTON", "$parentDropdown", Config, "UIDropDownMenuTemplate")
	Config.dropdown:SetPoint("TOPLEFT", Config, "TOPLEFT", 0, -44)
	Config.dropdown.middle = _G[Config.dropdown:GetName().."Middle"]
	Config.dropdown.middle:SetWidth(150)
	Config.dropdown:SetWidth(200)
	Config.dropdown.text = _G[Config.dropdown:GetName().."Text"]
	Config.dropdown.text:SetText(ConsolePortKeyboardSettings.Language)
	Config.dropdown.info = {}
	Config.dropdown:EnableMouse(false)
	Config.dropdown.initialize = function(self)
		wipe(self.info)
		for name, layout in pairs(Language) do
			if name ~= "Default" and name ~= "Markers" then
				self.info.text = name
				self.info.value = name
				self.info.func = function(item)
					self.selectedID = item:GetID()
					self.text:SetText(name)
					NewLayout = db.Copy(layout)
					NewLanguage = name
					Config:UpdateFields()
				end
				self.info.checked = self.info.text == NewLanguage or self.info.text ==  ConsolePortKeyboardSettings.Language
				UIDropDownMenu_AddButton(self.info, 1)
			end
		end
	end
end