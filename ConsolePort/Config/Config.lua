local addOn, db = ...
local TUTORIAL = db.TUTORIAL.CONFIG
---------------------------------------------------------------
-- Config: Panel table used for modular config creation
---------------------------------------------------------------
db.Panels = {}

local function GetAddonSettings()
	return {
		{	cvar = "autoExtra",
			desc = TUTORIAL.AUTOEXTRA,
			toggle = ConsolePortSettings.autoExtra,
		}
	}
end

---------------------------------------------------------------
-- Config: Save general addon cvars
---------------------------------------------------------------
local function SaveGeneralConfig(self)
	for i, Check in pairs(self.General) do
		ConsolePortSettings[Check.Cvar] = Check:GetChecked()
	end
	for i, Check in pairs(self.Triggers) do
		ConsolePortSettings[Check.Cvar] = Check.Value or ConsolePortSettings[Check.Cvar]
	end
end

---------------------------------------------------------------
-- Config: Reset buttons
---------------------------------------------------------------
local function ResetControllerOnClick(self)
	InterfaceOptionsFrame:Hide()
	ConsolePort:CreateSplashFrame()
end

local function ResetBindingsOnClick(self)
	if not InCombatLockdown() then
		InterfaceOptionsFrame:Hide()
		local bindings = ConsolePort:GetBindingNames()
		for i, binding in pairs(bindings) do
			local key1, key2 = GetBindingKey(binding)
			if key1 then SetBinding(key1) end
			if key2 then SetBinding(key2) end
		end
		SaveBindings(GetCurrentBindingSet())
		ConsolePort:CreateBindingWizard()
	end
end

local function ResetAllOnClick(self)
	self:SetText(TUTORIAL.CONFIRMRESET)
	self:SetScript("OnClick", function(self)
		SlashCmdList["CONSOLEPORT"]("resetAll")
	end)
end

---------------------------------------------------------------
-- Config: Create panel and children 
---------------------------------------------------------------
db.CreatePanel = function(parent, name, title, header, okay, cancel, default)
	local panel = CreateFrame("FRAME", addOn.."ConfigFrame"..name, parent)

	panel.name = title
	panel.okay = okay
	panel.cancel = cancel
	panel.default = default
	panel.parent = parent.name

	panel.Header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	panel.Header:SetText(header)
	panel.Header:SetPoint("TOPLEFT", panel, 16, -16)

	InterfaceOptions_AddCategory(panel)
	return panel
end

tinsert(db.Panels, {"InterfaceOptionsFramePanelContainer", "Config", addOn, addOn, SaveGeneralConfig, false, false, function(self, Config)

	local function CreateButton(name, text, OnClick, point)
		local button = CreateFrame("Button", "$parent"..name, Config, "UIPanelButtonTemplate")
		button:SetPoint(unpack(point))
		button:SetWidth(160)
		button:SetText(text)
		button:SetScript("OnClick", OnClick)
		return button
	end

	Config.ResetController = CreateButton("ResetController", TUTORIAL.CONTROLLER, ResetControllerOnClick, {"TOPRIGHT", -16, -44})
	Config.ResetBindings = CreateButton("ResetBindings", TUTORIAL.BINDRESET, ResetBindingsOnClick, {"TOP", Config.ResetController, "BOTTOM", 0, -2})
	Config.ResetAll = CreateButton("ResetAll", TUTORIAL.FULLRESET, ResetAllOnClick, {"TOP", Config.ResetBindings, "BOTTOM", 0, -2})
	Config.ShowSlash = CreateButton("ShowSlash", TUTORIAL.SHOWSLASH, SlashCmdList["CONSOLEPORT"], {"TOP", Config.ResetAll, "BOTTOM", 0, -2})

	Config.General = {}
	for i, setting in pairs(GetAddonSettings()) do
		local check = CreateFrame("CheckButton", "$parentGeneralSetting"..i, Config, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Description = text
		check.Cvar = setting.cvar
		check:SetPoint("TOPLEFT", 16, -30*i-10)
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		tinsert(Config.General, check)
	end

	Config.TriggerHeader = Config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.TriggerHeader:SetText(TUTORIAL.TRIGGERHEADER)
	Config.TriggerHeader:SetPoint("TOPLEFT", Config, 16, -420)

	Config.Triggers = {}

	local triggerGraphics = {
		["Shift"] 	= {offset = 16, cvar = "shift"},
		["Ctrl"] 	= {offset = 16+140, cvar = "ctrl"},
		["1st"] 	= {offset = 16+280, cvar = "trigger1"},
		["2nd"] 	= {offset = 16+420, cvar = "trigger2"},
	}

	for name, info in pairs(triggerGraphics) do
		local trigger = Config:CreateTexture(nil, "ARTWORK")
		trigger:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
		trigger:SetSize(76, 101)
		trigger:SetTexCoord(0.154296875, 0.30078125, 0.80078125, 1)
		trigger:SetPoint("TOPLEFT", Config, "TOPLEFT", info.offset, -450)
		trigger.Value = ConsolePortSettings[info.cvar]
		trigger.Cvar = info.cvar

		local triggerText = Config:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		triggerText:SetText(name)
		triggerText:SetPoint("CENTER", trigger, 0, 20)
		triggerText:SetTextColor(1, 0, 0, 1)

		tinsert(Config.Triggers, trigger)

		Config[name] = trigger
	end

	local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Textures\\Buttons\\%s\\%s"
	local triggers = {
		CP_TL1 = format(TEXTURE_PATH, ConsolePortSettings.type, "CP_TL1"),
		CP_TL2 = format(TEXTURE_PATH, ConsolePortSettings.type, "CP_TL2"),
		CP_TR1 = format(TEXTURE_PATH, ConsolePortSettings.type, "CP_TR1"),
		CP_TR2 = format(TEXTURE_PATH, ConsolePortSettings.type, "CP_TR2"),
	}

	local RadioButtons = {
		{parent = Config["Shift"],	default = ConsolePortSettings.shift},
		{parent = Config["Ctrl"], 	default = ConsolePortSettings.ctrl},
		{parent = Config["1st"], 	default = ConsolePortSettings.trigger1},
		{parent = Config["2nd"], 	default = ConsolePortSettings.trigger2},
	}

	local function CheckOnClick(self)
		for i, button in pairs(self.set) do
			button:SetChecked(false)
		end
		self:SetChecked(true)
		self.parent.Value = self.name
	end

	for i, radio in pairs(RadioButtons) do
		local num = 1
		local radioset = {}
		for name, texture in db.pairsByKeys(triggers) do
			local button = CreateFrame("CheckButton", "$parentTrigger"..i..name, Config, "UIRadioButtonTemplate")
			button.set = radioset
			button.name = name
			button.parent = radio.parent
			button.text = _G[button:GetName().."Text"]
			button.text:SetText(format("|T%s:24:24:0:0|t", texture))
			button:SetPoint("TOPLEFT", radio.parent, "TOPRIGHT", 5, -24*(num-1)-8)
			if name == radio.default then
				radio.parent.Value = name
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end
			tinsert(radioset, button)
			button:SetScript("OnClick", CheckOnClick)
			num = num + 1
		end
	end

end})

function ConsolePort:CreateConfigPanel()
	for i, panel in pairs(db.Panels) do
		local parentName, name, sideHeader, bigHeader, okay, cancel, default, configure = unpack(panel)
		local panel = db.CreatePanel(_G[parentName], name, sideHeader, bigHeader, okay, cancel, default)
		configure(self, panel)
		db[name] = panel
	end

	db.Panels = nil
	self.CreateConfigPanel = nil
end

