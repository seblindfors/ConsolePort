---------------------------------------------------------------
-- General.lua: Base config, reset buttons, triggers, cvars
---------------------------------------------------------------
-- Creates the base config panel and account-wide cvar options.

local addOn, db = ...
local TUTORIAL = db.TUTORIAL
local TEXTURE  = db.TEXTURE
---------------------------------------------------------------
-- Config: Account-wide addon CVars.
---------------------------------------------------------------
local function GetAddonSettings()
	return {		
		{	cvar = "autoInteract",
			desc = TUTORIAL.CONFIG.CLICKTOMOVE,
			toggle = ConsolePortSettings.autoInteract,
		},
		{
			cvar = "mouseOverMode",
			desc = TUTORIAL.CONFIG.MOUSEOVERMODE,
			toggle = ConsolePortSettings.mouseOverMode,
		},
		{	cvar = "turnCharacter",
			desc = TUTORIAL.CONFIG.TURNMOVE,
			toggle = ConsolePortSettings.turnCharacter,
			needReload = true, 
		},
		{	cvar = "disableSmartMouse",
			desc = TUTORIAL.CONFIG.DISABLEMOUSE,
			toggle = ConsolePortSettings.disableSmartMouse,
		},
		{	cvar = "autoExtra",
			desc = TUTORIAL.CONFIG.AUTOEXTRA,
			toggle = ConsolePortSettings.autoExtra,
		},
		{
			cvar = "cameraDistanceMoveSpeed",
			desc = TUTORIAL.CONFIG.FASTCAM,
			toggle = ConsolePortSettings.cameraDistanceMoveSpeed,
		},
		{
			cvar = "autoLootDefault",
			desc = TUTORIAL.CONFIG.AUTOLOOT,
			toggle = ConsolePortSettings.autoLootDefault,
		},
		{
			cvar = "blockTrades",
			desc = TUTORIAL.CONFIG.AUTOBLOCK,
			toggle = ConsolePortSettings.blockTrades,
		},
	}
end
---------------------------------------------------------------
-- Mouse: Returns events for mouselook
---------------------------------------------------------------
local function GetMouseSettings()
	return {
		{ 	event 	= {"PLAYER_STARTED_MOVING"},
			desc 	= TUTORIAL.MOUSE.STARTED_MOVING,
			toggle 	= ConsolePortMouse.Events["PLAYER_STARTED_MOVING"]
		},
		{ 	event	= {"PLAYER_TARGET_CHANGED"},
			desc 	= TUTORIAL.MOUSE.TARGET_CHANGED,
			toggle 	= ConsolePortMouse.Events["PLAYER_TARGET_CHANGED"]
		},
		{	event 	= {"CURRENT_SPELL_CAST_CHANGED"},
			desc 	= TUTORIAL.MOUSE.DIRECT_SPELL_CAST,
			toggle 	= ConsolePortMouse.Events["CURRENT_SPELL_CAST_CHANGED"]
		},
		{	event 	= {	"GOSSIP_SHOW", "GOSSIP_CLOSED",
						"MERCHANT_SHOW", "MERCHANT_CLOSED",
						"TAXIMAP_OPENED", "TAXIMAP_CLOSED",
						"QUEST_GREETING", "QUEST_DETAIL",
						"QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED"},
			desc 	= TUTORIAL.MOUSE.NPC_INTERACTION,
			toggle 	= ConsolePortMouse.Events["GOSSIP_SHOW"]
		},
		{ 	event	= {"QUEST_AUTOCOMPLETE"},
			desc 	= TUTORIAL.MOUSE.QUEST_AUTOCOMPLETE,
			toggle 	= ConsolePortMouse.Events["QUEST_AUTOCOMPLETE"]
		},
		{ 	event 	= {"SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"},
			desc 	= TUTORIAL.MOUSE.GARRISON_ORDER,
			toggle 	= ConsolePortMouse.Events["SHIPMENT_CRAFTER_OPENED"]
		},
		{	event	= {"LOOT_OPENED"},
			desc 	= TUTORIAL.MOUSE.LOOT_OPENED,
			toggle 	= ConsolePortMouse.Events["LOOT_OPENED"]
		},
		{	event	= {"LOOT_CLOSED"},
			desc 	= TUTORIAL.MOUSE.LOOT_CLOSED,
			toggle 	= ConsolePortMouse.Events["LOOT_CLOSED"]
		}
	}
end

---------------------------------------------------------------
-- Config/Mouse: Save general addon CVars.
---------------------------------------------------------------
local function SaveGeneralConfig(self)
	local needReload = false
	for i, Check in pairs(self.General) do
		local old = ConsolePortSettings[Check.Cvar]
		ConsolePortSettings[Check.Cvar] = Check:GetChecked()
		if Check.Reload and Check:GetChecked() ~= old then
			needReload = true
		end
	end
	for i, Check in pairs(self.Triggers) do
		if Check.Value and Check.Value ~= ConsolePortSettings[Check.Cvar] then
			ConsolePortSettings[Check.Cvar] = Check.Value
			needReload = true
		end
	end
	if needReload and not InCombatLockdown() then
		ReloadUI()
	end
	ConsolePort:UpdateCVars()
	ConsolePort:UpdateSmartMouse()

	for i, Check in pairs(self.Events) do
		for i, Event in pairs(Check.Events) do
			ConsolePortMouse.Events[Event] = Check:GetChecked()
		end
	end
	ConsolePortMouse.Cursor.Left = self.LeftClick.button
	ConsolePortMouse.Cursor.Right = self.RightClick.button
	ConsolePortMouse.Cursor.Scroll = self.ScrollClick.button
	ConsolePort:LoadEvents()
	ConsolePort:SetupCursor()
	ConsolePort:LoadControllerTheme()
	ConsolePort:UpdateStateDriver()
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
	self:SetText(TUTORIAL.CONFIG.CONFIRMRESET)
	self:SetScript("OnClick", function(self)
		SlashCmdList["CONSOLEPORT"]("resetAll")
	end)
end

---------------------------------------------------------------
-- Config: Create panel and children 
---------------------------------------------------------------
tinsert(db.PANELS, {"Config", "General", false, SaveGeneralConfig, false, false, function(self, Config)

	local function CreateButton(name, text, OnClick, point)
		local button = db.Atlas.GetFutureButton("$parent"..name, Config)
		button:SetPoint(unpack(point))
		button:SetText(text)
		button:SetScript("OnClick", OnClick)
		return button
	end

	Config.ResetController = CreateButton("ResetController", TUTORIAL.CONFIG.CONTROLLER, ResetControllerOnClick, {"RIGHT", -40, -64})
	Config.ResetBindings = CreateButton("ResetBindings", TUTORIAL.CONFIG.BINDRESET, ResetBindingsOnClick, {"TOP", Config.ResetController, "BOTTOM", 0, -2})
	Config.ResetAll = CreateButton("ResetAll", TUTORIAL.CONFIG.FULLRESET, ResetAllOnClick, {"TOP", Config.ResetBindings, "BOTTOM", 0, -2})
	Config.ShowSlash = CreateButton("ShowSlash", TUTORIAL.CONFIG.SHOWSLASH, SlashCmdList["CONSOLEPORT"], {"TOP", Config.ResetAll, "BOTTOM", 0, -2})

	Config.GeneralWrapper = CreateFrame("Frame", nil, Config)
	Config.GeneralWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.GeneralWrapper:SetPoint("TOPLEFT", 8, -8)
	Config.GeneralWrapper:SetSize(674, 300)

	Config.GeneralHeader = Config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.GeneralHeader:SetText(TUTORIAL.CONFIG.GENERALHEADER)
	Config.GeneralHeader:SetPoint("TOPLEFT", Config.GeneralWrapper, 16, -16)

	Config.General = {}
	for i, setting in pairs(GetAddonSettings()) do
		local check = CreateFrame("CheckButton", "$parentGeneralSetting"..i, Config.GeneralWrapper, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Description = text
		check.Cvar = setting.cvar
		check.Reload = setting.needReload
		check:SetPoint("TOPLEFT", 16, -30*i-10)
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		tinsert(Config.General, check)
	end

	Config.RadioWrapper = CreateFrame("Frame", nil, Config)
	Config.RadioWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.RadioWrapper:SetPoint("BOTTOMLEFT", 8, 8)
	Config.RadioWrapper:SetSize(674, 276)

	Config.TriggerHeader = Config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.TriggerHeader:SetText(TUTORIAL.CONFIG.TRIGGERHEADER)
	Config.TriggerHeader:SetPoint("TOPLEFT", Config.RadioWrapper, 16, -138)

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
		trigger:SetPoint("TOPLEFT", Config.TriggerHeader, "TOPLEFT", info.offset, -24)
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
			button:SetPoint("TOPLEFT", radio.parent, "TOPRIGHT", 8, -24*(num-1)-8)
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


	Config.CursorHeader = Config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.CursorHeader:SetText(TUTORIAL.CONFIG.VIRTUALCURSOR)
	Config.CursorHeader:SetPoint("TOPLEFT", Config.RadioWrapper, 16, -16)

	Config.LeftClick = Config:CreateTexture()
	Config.LeftClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Config.LeftClick:SetSize(76*0.75, 101*0.75)
	Config.LeftClick:SetTexCoord(0.0019531, 0.1484375, 0.4257813, 0.6210938)
	Config.LeftClick:SetPoint("TOPLEFT", Config.CursorHeader, "TOPLEFT", 16, -24)

	Config.RightClick = Config:CreateTexture()
	Config.RightClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Config.RightClick:SetSize(76*0.75, 101*0.75)
	Config.RightClick:SetTexCoord(0.0019531, 0.1484375, 0.6269531, 0.8222656)
	Config.RightClick:SetPoint("LEFT", Config.LeftClick, "RIGHT", 85, 0)

	Config.SpecialClick = Config:CreateTexture()
	Config.SpecialClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Config.SpecialClick:SetSize(76*0.75, 101*0.75)
	Config.SpecialClick:SetTexCoord(0.1542969, 0.3007813, 0.2246094, 0.4199219)
	Config.SpecialClick:SetPoint("LEFT", Config.RightClick, "RIGHT", 85, 0)

	Config.ScrollClick = Config:CreateTexture()
	Config.ScrollClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Config.ScrollClick:SetSize(76*0.75, 101*0.75)
	Config.ScrollClick:SetTexCoord(0.0019531, 0.1484375, 0.2246094, 0.4199219)
	Config.ScrollClick:SetPoint("LEFT", Config.SpecialClick, "RIGHT", 85, 0)

	local clickButtons 	= {
		CP_R_RIGHT 	= TEXTURE.CP_R_RIGHT,
		CP_R_LEFT 	= TEXTURE.CP_R_LEFT,
		CP_R_UP		= TEXTURE.CP_R_UP,
		CP_R_DOWN	= TEXTURE.CP_R_DOWN,
	}

	local scrollButtons = {
		CP_TL1 		= TEXTURE.CP_TL1,
		CP_TL2 		= TEXTURE.CP_TL2,
	}

	local RadioButtons = {
		{parent = Config.LeftClick, 	selection = clickButtons,	default = ConsolePortMouse.Cursor.Left},
		{parent = Config.RightClick, 	selection = clickButtons,	default = ConsolePortMouse.Cursor.Right},
		{parent = Config.SpecialClick, 	selection = clickButtons, 	default = ConsolePortMouse.Cursor.Special},
		{parent = Config.ScrollClick, 	selection = scrollButtons,	default = ConsolePortMouse.Cursor.Scroll},
	}

	for i, radio in pairs(RadioButtons) do
		local num = 1
		local radioSet = {}
		for name, texture in pairs(radio.selection) do
			local button = CreateFrame("CheckButton", addOn.."VirtualClick"..i..num, Config, "UIRadioButtonTemplate")
			button.text = _G[button:GetName().."Text"]
			button.text:SetText(format("|T%s:24:24:0:0|t", texture))

			button:SetPoint("TOPLEFT", radio.parent, "TOPRIGHT", 24, -24*(num-1))
			if name == radio.default then
				radio.parent.button = name
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end
			tinsert(radioSet, button)
			button:SetScript("OnClick", function(self)
				for i, button in pairs(radioSet) do
					button:SetChecked(false)
				end
				self:SetChecked(true)
				radio.parent.button = name
			end)
			num = num + 1
		end
	end

	Config.MouseWrapper = CreateFrame("Frame", nil, Config)
	Config.MouseWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.MouseWrapper:SetPoint("TOPRIGHT", -8, -8)
	Config.MouseWrapper:SetSize(300, 300)

	Config.MouseHeader = Config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.MouseHeader:SetText(TUTORIAL.CONFIG.MOUSEHEADER)
	Config.MouseHeader:SetPoint("TOPLEFT", Config.MouseWrapper, 16, -16)

	Config.Events = {}
	for i, setting in pairs(GetMouseSettings()) do
		local check = CreateFrame("CheckButton", "ConsolePortMouseEvent"..i, Config.MouseWrapper, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Events = setting.event
		check.Description = text
		check:SetPoint("TOPLEFT", 16, -30*i-10)
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		tinsert(Config.Events, check)
	end

end})