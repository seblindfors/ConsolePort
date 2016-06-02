---------------------------------------------------------------
-- General.lua: Base config, reset buttons, triggers, cvars
---------------------------------------------------------------
-- Creates the base config panel and account-wide cvar options.

local addOn, db = ...
local TUTORIAL, TEXTURE, ICONS = db.TUTORIAL, db.TEXTURE, db.ICONS
local FadeIn, FadeOut = db.UIFrameFadeIn, db.UIFrameFadeOut
local spairs = db.table.spairs
local WindowMixin, Settings = {}
---------------------------------------------------------------
-- Config: Account-wide addon CVars.
---------------------------------------------------------------
local function GetAddonSettings()
	return {		
		{	cvar = "actionCam",
			desc = TUTORIAL.CONFIG.ACTIONCAM,
			toggle = Settings.actionCam,
		},
		{	cvar = "turnCharacter",
			desc = TUTORIAL.CONFIG.TURNMOVE,
			toggle = Settings.turnCharacter,
			needReload = true, 
		},
		{
			cvar = "preventMouseDrift",
			desc = TUTORIAL.CONFIG.MOUSEDRIFTING,
			toggle = Settings.preventMouseDrift,
		},
		{
			cvar = "doubleModTap",
			desc = format(TUTORIAL.CONFIG.DOUBLEMODTAP, ICONS.CP_M1, ICONS.CP_M2),
			toggle = Settings.doubleModTap,
		},
		{	cvar = "disableSmartMouse",
			desc = TUTORIAL.CONFIG.DISABLEMOUSE,
			toggle = Settings.disableSmartMouse,
		},
		{	cvar = "autoExtra",
			desc = TUTORIAL.CONFIG.AUTOEXTRA,
			toggle = Settings.autoExtra,
		},
		{
			cvar = "cameraDistanceMoveSpeed",
			desc = TUTORIAL.CONFIG.FASTCAM,
			toggle = Settings.cameraDistanceMoveSpeed,
		},
		{
			cvar = "autoLootDefault",
			desc = TUTORIAL.CONFIG.AUTOLOOT,
			toggle = Settings.autoLootDefault,
		},
		-- Mouse "events" to the user, but cvars internally
		{
			mouse = true,
			cvar = "mouseOnJump",
			desc = TUTORIAL.MOUSE.JUMPING,
			toggle = Settings.mouseOnJump,
		},
		{
			mouse = true,
			cvar = "mouseOnCenter",
			desc = TUTORIAL.MOUSE.CENTERCURSOR,
			toggle = Settings.mouseOnCenter,
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
			toggle 	= db.Mouse.Events["PLAYER_STARTED_MOVING"]
		},
		{ 	event	= {"PLAYER_TARGET_CHANGED"},
			desc 	= TUTORIAL.MOUSE.TARGET_CHANGED,
			toggle 	= db.Mouse.Events["PLAYER_TARGET_CHANGED"]
		},
		{	event 	= {"CURRENT_SPELL_CAST_CHANGED"},
			desc 	= TUTORIAL.MOUSE.DIRECT_SPELL_CAST,
			toggle 	= db.Mouse.Events["CURRENT_SPELL_CAST_CHANGED"]
		},
		{	event 	= {	"GOSSIP_SHOW", "GOSSIP_CLOSED",
						"MERCHANT_SHOW", "MERCHANT_CLOSED",
						"TAXIMAP_OPENED", "TAXIMAP_CLOSED",
						"QUEST_GREETING", "QUEST_DETAIL",
						"QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED",
						"SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"},
			desc 	= TUTORIAL.MOUSE.NPC_INTERACTION,
			toggle 	= db.Mouse.Events["GOSSIP_SHOW"]
		},
		{ 	event	= {"QUEST_AUTOCOMPLETE"},
			desc 	= TUTORIAL.MOUSE.QUEST_AUTOCOMPLETE,
			toggle 	= db.Mouse.Events["QUEST_AUTOCOMPLETE"]
		},
		{	event	= {"LOOT_OPENED", "LOOT_CLOSED"},
			desc 	= TUTORIAL.MOUSE.LOOTING,
			toggle 	= db.Mouse.Events["LOOT_OPENED"]
		}
	}
end

---------------------------------------------------------------
-- Config: Reset buttons
---------------------------------------------------------------
local function ResetControllerOnClick(self)
	self:GetParent():GetParent():Hide()
	ConsolePort:SelectController()
end

local function ResetBindingsOnClick(self)
	if not InCombatLockdown() then
		self:GetParent():GetParent():Hide()
		for binding in ConsolePort:GetBindings() do
			local key1, key2 = GetBindingKey(binding)
			if key1 then SetBinding(key1) end
			if key2 then SetBinding(key2) end
		end
		SaveBindings(GetCurrentBindingSet())
		ConsolePort:CalibrateController()
	end
end

local function ResetAllOnClick(self)
	self:SetText(TUTORIAL.CONFIG.CONFIRMRESET)
	self:SetScript("OnClick", function(self)
		SlashCmdList["CONSOLEPORT"]("resetall")
	end)
end

---------------------------------------------------------------
-- Binds: Bind catcher
---------------------------------------------------------------
local function BindCatcherOnKey(self, key)
	FadeIn(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 1)
	self:SetScript("OnKeyUp", nil)
	self:EnableKeyboard(false)
	local action = key and GetBindingAction(key)
	if action and action:match("CP_*") then
		self.CurrentButton = action
		if self.CurrentButton then
			self:SetText(format(TUTORIAL.CONFIG.INTERACTASSIGNED, db.TEXTURE[action]))
		end
	elseif key then
		self:SetText(TUTORIAL.CONFIG.INTERACTCATCHER)
	end
end

local function BindCatcherOnClick(self)
	self:EnableKeyboard(true)
	self:SetScript("OnKeyUp", BindCatcherOnKey)
	FadeOut(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 0)
	self:SetText(TUTORIAL.BIND.CATCHER)
end

local function BindCatcherOnHide(self)
	BindCatcherOnKey(self)
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

local function BindCatcherOnShow(self)
	self.CurrentButton = Settings.interactWith
	if self.CurrentButton then
		self:SetText(format(TUTORIAL.CONFIG.INTERACTASSIGNED, db.TEXTURE[self.CurrentButton]))
	else
		self:SetText(TUTORIAL.CONFIG.INTERACTCATCHER)
	end
	FadeIn(self, 0.2, self:GetAlpha(), 1)
end

local function InteractModuleOnShow(self)
	if self.Enable:GetChecked() then
		FadeOut(self.Hand, 0.5, 1, 0.1)
		FadeOut(self.Dude, 0.5, 1, 0.1)
		self.MouseOver:Show()
		self.BindWrapper:Show()
	else
		self.MouseOver:Hide()
		self.BindWrapper:Hide()
		FadeIn(self.Hand, 0.5, 0.1, 1)
		FadeIn(self.Dude, 0.5, 0.1, 1)
	end
end

function WindowMixin:Save()
	local needReload
	for i, Check in pairs(self.General) do
		local old = Settings[Check.Cvar]
		Settings[Check.Cvar] = Check:GetChecked()
		if Check.Reload and Check:GetChecked() ~= old then
			needReload = true
		end
	end
	for i, Check in pairs(self.Triggers) do
		if Check.Value and Check.Value ~= Settings[Check.Cvar] then
			Settings[Check.Cvar] = Check.Value
			needReload = true
		end
	end

	ConsolePort:UpdateCVars()
	ConsolePort:UpdateSmartMouse()

	for i, Check in pairs(self.Events) do
		for i, Event in pairs(Check.Events) do
			db.Mouse.Events[Event] = Check:GetChecked()
		end
	end

	if self.InteractModule.Enable:GetChecked() and self.InteractModule.BindCatcher.CurrentButton then
		Settings.interactWith = self.InteractModule.BindCatcher.CurrentButton
		Settings.mouseOverMode = self.InteractModule.MouseOver:GetChecked()
	else
		Settings.interactWith = false
		Settings.mouseOverMode = false
	end

	ConsolePortSettings = db.Settings
	ConsolePortMouse = db.Mouse

	ConsolePort:LoadEvents()
	ConsolePort:LoadControllerTheme()
	ConsolePort:UpdateMouseDriver()
	ConsolePort:SetupUtilityBelt()
	return needReload
end

---------------------------------------------------------------
-- Config: Create panel and children 
---------------------------------------------------------------
db.PANELS[#db.PANELS + 1] = {"Config", CONTROLS_LABEL, false, WindowMixin, function(self, Config)

	Settings = db.Settings

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

	------------------------------------------------------------------------------------------------------------------------------

	Config.InteractModule = CreateFrame("Frame", nil, Config)
	Config.InteractModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.InteractModule:SetPoint("TOPRIGHT", -302, -8)
	Config.InteractModule:SetSize(308, 308)
	Config.InteractModule:SetScript("OnShow", InteractModuleOnShow)

	Config.MouseModule = CreateFrame("Frame", nil, Config)
	Config.MouseModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.MouseModule:SetPoint("TOPRIGHT", -8, -8)
	Config.MouseModule:SetSize(316, 308)

	Config.GeneralModule = CreateFrame("Frame", nil, Config)
	Config.GeneralModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.GeneralModule:SetPoint("TOPLEFT", 8, -8)
	Config.GeneralModule:SetSize(388, 308)

	------------------------------------------------------------------------------------------------------------------------------
	Config.InteractModule.Header = Config.InteractModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.InteractModule.Header:SetText(TUTORIAL.CONFIG.INTERACTHEADER)
	Config.InteractModule.Header:SetPoint("TOPLEFT", 24, -24)

	Config.InteractModule.Dude = Config.InteractModule:CreateTexture(nil, "BACKGROUND", nil, 1)
	Config.InteractModule.Dude:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver")
	Config.InteractModule.Dude:SetPoint("CENTER", 0, 0)
	Config.InteractModule.Dude:SetSize(128, 128)

	Config.InteractModule.Hand = Config.InteractModule:CreateTexture(nil, "BACKGROUND", nil, 2)
	Config.InteractModule.Hand:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-GloveCursor")
	Config.InteractModule.Hand:SetPoint("CENTER", 16, -40)
	Config.InteractModule.Hand:SetSize(64, 64)

	Config.InteractModule.Description = Config.InteractModule:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	Config.InteractModule.Description:SetPoint("BOTTOM", 0, 32)
	Config.InteractModule.Description:SetText(TUTORIAL.CONFIG.INTERACTDESC)
	Config.InteractModule.Description:SetJustifyH("CENTER")

	Config.InteractModule.BindWrapper = db.Atlas.GetGlassWindow("$parentBindWrapper", Config.InteractModule, nil, true)
	Config.InteractModule.BindWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.InteractModule.BindWrapper:SetPoint("CENTER", 0, 8)
	Config.InteractModule.BindWrapper:SetSize(256, 140)
	Config.InteractModule.BindWrapper.Close:Hide()
	Config.InteractModule.BindWrapper:Hide()

	Config.InteractModule.BindCatcher = db.Atlas.GetFutureButton("$parentBindCatcher", Config.InteractModule.BindWrapper, nil, nil, 200)
	Config.InteractModule.BindCatcher.HighlightTexture:ClearAllPoints()
	Config.InteractModule.BindCatcher.HighlightTexture:SetAllPoints(Config.InteractModule.BindCatcher)
	Config.InteractModule.BindCatcher:SetHeight(108)
	Config.InteractModule.BindCatcher:SetPoint("CENTER", 0, 0)
	Config.InteractModule.BindCatcher:SetScript("OnClick", BindCatcherOnClick)
	Config.InteractModule.BindCatcher:SetScript("OnHide", BindCatcherOnHide)
	Config.InteractModule.BindCatcher:SetScript("OnShow", BindCatcherOnShow)
	Config.InteractModule.BindCatcher.Cover:Hide()
	-- Show it once to populate settings
	BindCatcherOnShow(Config.InteractModule.BindCatcher)

	Config.InteractModule.Enable = CreateFrame("CheckButton", nil, Config.InteractModule, "ChatConfigCheckButtonTemplate")
	Config.InteractModule.Enable:SetPoint("TOPLEFT", 24, -48)
	Config.InteractModule.Enable:SetChecked(Settings.interactWith)
	Config.InteractModule.Enable:SetScript("OnClick", function(self) InteractModuleOnShow(self:GetParent()) end)

	Config.InteractModule.Enable.Text = Config.InteractModule.Enable:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	Config.InteractModule.Enable.Text:SetText(TUTORIAL.CONFIG.INTERACTCHECK)
	Config.InteractModule.Enable.Text:SetPoint("LEFT", 30, 0)

	Config.InteractModule.MouseOver = CreateFrame("CheckButton", nil, Config.InteractModule, "ChatConfigCheckButtonTemplate")
	Config.InteractModule.MouseOver:SetPoint("BOTTOMLEFT", 24, 64)
	Config.InteractModule.MouseOver:SetChecked(Settings.mouseOverMode)
	Config.InteractModule.MouseOver:SetScript("OnClick", function(self) InteractModuleOnShow(self:GetParent()) end)

	Config.InteractModule.MouseOver.Text = Config.InteractModule.MouseOver:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	Config.InteractModule.MouseOver.Text:SetText(TUTORIAL.CONFIG.MOUSEOVERMODE)
	Config.InteractModule.MouseOver.Text:SetPoint("LEFT", 30, 0)

	------------------------------------------------------------------------------------------------------------------------------
	Config.MouseModule.Header = Config.MouseModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.MouseModule.Header:SetText(TUTORIAL.CONFIG.MOUSEHEADER)
	Config.MouseModule.Header:SetPoint("TOPLEFT", 24, -24)

	Config.Events = {}
	for i, setting in pairs(GetMouseSettings()) do
		local check = CreateFrame("CheckButton", "$parentMouseEvent"..i, Config.MouseModule, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Events = setting.event
		check.Description = text
		check:SetPoint("TOPLEFT", 24, -30*i-18)
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		tinsert(Config.Events, check)
	end

	------------------------------------------------------------------------------------------------------------------------------
	Config.GeneralModule.Header = Config.GeneralModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.GeneralModule.Header:SetText(TUTORIAL.CONFIG.GENERALHEADER)
	Config.GeneralModule.Header:SetPoint("TOPLEFT", 24, -24)

	local mouseCvarOffset = #Config.Events
	Config.General = {}
	for i, setting in pairs(GetAddonSettings()) do
		local check = CreateFrame("CheckButton", "$parentGeneralSetting"..i, Config.GeneralModule, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Description = text
		check.Cvar = setting.cvar
		check.Reload = setting.needReload
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		if setting.mouse then
			mouseCvarOffset = mouseCvarOffset + 1
			check:SetPoint("TOPLEFT", Config.MouseModule, "TOPLEFT", 24, -30*mouseCvarOffset-18)
		else
			check:SetPoint("TOPLEFT", 24, -30*i-18)
		end
		tinsert(Config.General, check)
	end

	------------------------------------------------------------------------------------------------------------------------------

	local function CheckOnClick(self)
		local parent = self.parent
		local oldVal = parent.Index
		local allSets = parent.AllSets
		parent.Index = self.num
		parent.Value = self.name
		if allSets then
			for x, trigger in pairs(allSets) do
				if trigger ~= parent then
					for i, button in pairs(trigger.Set) do
						if i == self.num and button:GetChecked() then
							button:SetChecked(false)
							local swapTo = trigger.Set[oldVal]
							swapTo:SetChecked(true)
							trigger.Value = swapTo.name
							trigger.Index = swapTo.num
						end
					end
				end
			end
		end
		for i, button in pairs(self.set) do
			button:SetChecked(false)
		end
		self:SetChecked(true)
	end
	------------------------------------------------------------------------------------------------------------------------------

	local red, green, blue = db.Atlas.GetCC()

	Config.MultiChoiceModule = CreateFrame("Frame", nil, Config)
	Config.MultiChoiceModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Config.MultiChoiceModule:SetPoint("BOTTOMLEFT", 8, 8)
	Config.MultiChoiceModule:SetSize(508, 284)

	Config.TriggerHeader = Config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Config.TriggerHeader:SetText(TUTORIAL.CONFIG.TRIGGERHEADER)
	Config.TriggerHeader:SetPoint("TOPLEFT", Config.MultiChoiceModule, 24, -138)

	Config.Triggers = {}

	local triggerGraphics = {
		[TUTORIAL.BIND.SHIFT] 	= {offset = 0, cvar = "CP_M1"},
		[TUTORIAL.BIND.CTRL] 	= {offset = 1, cvar = "CP_M2"},
		[TUTORIAL.BIND.T1] 		= {offset = 2, cvar = "CP_T1"},
		[TUTORIAL.BIND.T2] 		= {offset = 3, cvar = "CP_T2"},
	}

	for name, info in pairs(triggerGraphics) do
		local trigger = Config:CreateTexture("$parent"..name, "ARTWORK")
		trigger:SetSize(76, 50)
		trigger:SetPoint("TOPLEFT", Config.TriggerHeader, "TOPLEFT", info.offset * 110 + 38, -24)
		trigger.AllSets = Config.Triggers
		trigger.Value = Settings[info.cvar]
		trigger.Cvar = info.cvar

		local triggerText = Config:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		triggerText:SetText(name)
		triggerText:SetPoint("CENTER", trigger, 0, 20)
		triggerText:SetTextColor(0.5, 0.5, 0.5)

		tinsert(Config.Triggers, trigger)

		Config[name] = trigger
	end

	local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Controllers\\%s\\Icons32\\%s"
	local triggers = {
		CP_TL1 = format(TEXTURE_PATH, Settings.type, "CP_TL1"),
		CP_TL2 = format(TEXTURE_PATH, Settings.type, "CP_TL2"),
		CP_TR1 = format(TEXTURE_PATH, Settings.type, "CP_TR1"),
		CP_TR2 = format(TEXTURE_PATH, Settings.type, "CP_TR2"),
	}

	local radioButtons = {
		{parent = Config[TUTORIAL.BIND.SHIFT],	default = Settings.CP_M1},
		{parent = Config[TUTORIAL.BIND.CTRL], 	default = Settings.CP_M2},
		{parent = Config[TUTORIAL.BIND.T1], 	default = Settings.CP_T1},
		{parent = Config[TUTORIAL.BIND.T2], 	default = Settings.CP_T2},
	}

	for i, radio in pairs(radioButtons) do
		local num = 1
		radio.parent.Set = {}
		for name, texture in spairs(triggers) do
			local button = CreateFrame("CheckButton", "$parentTrigger"..i..name, Config)

			button:SetBackdrop(db.Atlas.Backdrops.BorderSmall)

			button:SetHighlightTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Gradient")
			button:SetCheckedTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Checked")

			button.Checked = button:GetCheckedTexture()
			button.Highlight = button:GetHighlightTexture()

			button.Checked:SetTexCoord(0, 1, 1, 0)
			button.Highlight:SetTexCoord(0, 1, 1, 0)

			button.Checked:ClearAllPoints()
			button.Checked:SetPoint("CENTER", 0, 0)
			button.Checked:SetSize(84, 8)
			button.Checked:SetVertexColor(red, green, blue)

			button.Highlight:ClearAllPoints()
			button.Highlight:SetPoint("CENTER", 0, 0)
			button.Highlight:SetSize(84, 8)

			button:SetSize(100, 20)

			button.num = num
			button.set = radio.parent.Set
			button.name = name
			button.parent = radio.parent
			if i == 1 then
				button.text = button:CreateTexture(nil, "OVERLAY")
				button.text:SetTexture(texture)
				button.text:SetPoint("RIGHT", button, "LEFT", 0, 0)
				button.text:SetSize(32, 32)
			end
			button:SetPoint("TOP", radio.parent, "TOP", 0, -24*(num-1)-12)
			if name == radio.default then
				radio.parent.Index = num
				radio.parent.Value = name
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end
			tinsert(radio.parent.Set, button)
			button:SetScript("OnClick", CheckOnClick)
			num = num + 1
		end
	end

end}