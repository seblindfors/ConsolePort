local addOn, db = ...
---------------------------------------------------------------
-- Config: Panel table
---------------------------------------------------------------
db.Panels = {}

local function GetAddonSettings()
	return {
		{	cvar = "flipMod",
			desc = "Flip modifiers (requires reload)",
			toggle = ConsolePortSettings.flipMod,
		},
		{	cvar = "autoExtra",
			desc = "Auto bind appropriate quest items",
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
end

local function ResetControllerOnClick(self)
	InterfaceOptionsFrame:Hide()
	ConsolePort:CreateSplashFrame()
	ConsolePort:UIControl(KEY.PREPARE, KEY.STATE_DOWN)
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

local function ConfigurePanelConfig(self, Config)
	Config.ResetController = CreateFrame("BUTTON", addOn.."ResetController", Config, "UIPanelButtonTemplate")
	Config.ResetController:SetWidth(150)
	Config.ResetController:SetText("Change controller")
	Config.ResetController:SetPoint("TOPRIGHT", -16, -44)
	Config.ResetController:SetScript("OnClick", ResetControllerOnClick)

	Config.ResetBindings = CreateFrame("BUTTON", addOn.."ResetController", Config, "UIPanelButtonTemplate")
	Config.ResetBindings:SetWidth(150)
	Config.ResetBindings:SetText("Reset bindings")
	Config.ResetBindings:SetPoint("TOP", Config.ResetController, "BOTTOM", 0, -2)
	Config.ResetBindings:SetScript("OnClick", ResetBindingsOnClick)

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
end

tinsert(db.Panels, {"InterfaceOptionsFramePanelContainer", "Config", addOn, addOn, SaveGeneralConfig, false, false, ConfigurePanelConfig})

function ConsolePort:CreateConfigPanel()
	if not db.Config then

		for i, panel in pairs(db.Panels) do
			local parentName, name, sideHeader, bigHeader, okay, cancel, default, configure = unpack(panel)
			local panel = db.CreatePanel(_G[parentName], name, sideHeader, bigHeader, okay, cancel, default)
			configure(self, panel)
			db[name] = panel
		end

	end
end

