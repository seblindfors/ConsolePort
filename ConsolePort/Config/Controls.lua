---------------------------------------------------------------
-- Controls.lua: Base config, reset buttons, triggers, cvars
---------------------------------------------------------------
-- Creates the base config panel and account-wide cvar options.

local _, db = ...
---------------------------------------------------------------
		-- Resource tables.
local 	Settings, TUTORIAL, TEXTURE, ICONS,
		-- Fade wrappers
		FadeIn, FadeOut,
		-- Table functions
		Mixin, spairs,
		-- Mixins
		Catcher, CheckButton, PopupMixin, WindowMixin = 
		-------------------------------------
		nil, db.TUTORIAL, db.TEXTURE, db.ICONS,
		db.UIFrameFadeIn, db.UIFrameFadeOut,
		db.table.mixin, db.table.spairs,
		{}, {}, {}, {}
---------------------------------------------------------------
-- Controls: Account-wide addon CVars.
---------------------------------------------------------------
local function GetAddonSettings()
	local L = TUTORIAL.CONFIG
	return {
		{	desc = L.MOUSEHANDLE },
		{	cvar = 'turnCharacter',
			desc = L.TURNMOVE,
			state = db('turnCharacter'),
			needReload = true, 
		},
		{	cvar = 'doubleModTap',
			desc = L.DOUBLEMODTAP:format(ICONS.CP_M1, ICONS.CP_M2),
			state = db('doubleModTap'),
		},
		{	cvar = 'disableSmartMouse',
			desc = L.DISABLEMOUSE,
			state = db('disableSmartMouse'),
		},
		{	cvar = 'mouseInvertPitch',
			desc = L.INVERTPITCH,
			state = db('mouseInvertPitch'),
		},
		{	cvar = 'mouseInvertYaw',
			desc = L.INVERTYAW,
			state = db('mouseInvertYaw'),
		},
		{	desc = L.TARGETING },
		{	cvar = 'raidCursorDirect',
			desc = L.RAIDCURSORDIRECT,
			state = db('raidCursorDirect'),
		},
		{
			cvar = 'TargetNearestUseNew',
			desc = L.TARGETALGORITHM,
			state = db('TargetNearestUseNew'),
		},
		{	desc = L.CONVENIENCE },
		{	cvar = 'autoExtra',
			desc = L.AUTOEXTRA,
			state = db('autoExtra'),
		},
		{	cvar = 'autoLootDefault',
			desc = L.AUTOLOOT,
			state = db('autoLootDefault'),
		},
		{	cvar = 'autoSellJunk',
			desc = L.AUTOSELL,
			state = db('autoSellJunk'),
		},
		{	cvar = 'disableHints',
			desc = TUTORIAL.HINTS.DISABLE,
			state = db('disableHints'),
		},
		{	cvar = 'disableSmartBind',
			desc = L.DISABLEBINDHELP,
			state = db('disableSmartBind'),
		},
		{	desc = L.FIXES },
		{	cvar = 'UIdisableHoldRepeat',
			desc = L.DISABLEHOLDREPEAT,
			state = db('UIdisableHoldRepeat'),
			needReload = true,
		},
		{	cvar = 'skipCalibration',
			desc = L.SKIPCALIBRATION,
			state = db('skipCalibration'),
		},
		-- Mouse 'events' to the user, but cvars internally
		{	mouse = true,
			cvar = 'mouseOnJump',
			desc = TUTORIAL.MOUSE.JUMPING,
			state = db('mouseOnJump'),
		},
		{	mouse = true,
			cvar = 'mouseOnCenter',
			desc = TUTORIAL.MOUSE.CENTERCURSOR,
			state = db('mouseOnCenter'),
		},
		{	mouse = true,
			cvar = 'preventMouseDrift',
			desc = L.MOUSEDRIFTING,
			state = db('preventMouseDrift'),
		},
	}
end
---------------------------------------------------------------
-- Mouse: Returns events for mouselook
---------------------------------------------------------------
local function GetMouseSettings()
	local L = TUTORIAL.MOUSE
	return {
		{ 	event 	= {'PLAYER_STARTED_MOVING'},
			desc 	= L.STARTED_MOVING,
			state 	= db('Mouse/Events/PLAYER_STARTED_MOVING'),
		},
		{ 	event	= {'PLAYER_TARGET_CHANGED'},
			desc 	= L.TARGET_CHANGED,
			state 	= db('Mouse/Events/PLAYER_TARGET_CHANGED'),
		},
		{	event 	= {'UNIT_SPELLCAST_SENT', 'UNIT_SPELLCAST_FAILED'},
			desc 	= L.DIRECT_SPELL_CAST,
			state 	= db('Mouse/Events/UNIT_SPELLCAST_SENT')
		},
		{	event 	= {	'GOSSIP_SHOW', 'GOSSIP_CLOSED',
						'MERCHANT_SHOW', 'MERCHANT_CLOSED',
						'TAXIMAP_OPENED', 'TAXIMAP_CLOSED',
						'QUEST_GREETING', 'QUEST_DETAIL',
						'QUEST_PROGRESS', 'QUEST_COMPLETE', 'QUEST_FINISHED',
						'SHIPMENT_CRAFTER_OPENED', 'SHIPMENT_CRAFTER_CLOSED'},
			desc 	= L.NPC_INTERACTION,
			state 	= db('Mouse/Events/GOSSIP_SHOW'),
		},
		{ 	event	= {'QUEST_AUTOCOMPLETE'},
			desc 	= L.QUEST_AUTOCOMPLETE,
			state 	= db('Mouse/Events/QUEST_AUTOCOMPLETE'),
		},
		{	event	= {'LOOT_OPENED', 'LOOT_CLOSED'},
			desc 	= L.LOOTING,
			state 	= db('Mouse/Events/LOOT_OPENED'),
		}
	}
end

local function GetCameraSettings()
	local Camset = db.Mouse.Camera
	local L = TUTORIAL.CONFIG
	return {
		{	cvar 	= 'cameraZoomSpeed',
			desc 	= L.FASTCAM,
			value 	= 50,
			default = 20,
		},
		{	cvar 	= 'test_cameraDynamicPitch',
			desc 	= L.DYNPITCH,
			value 	= 1,
			default = 0,
		},
		{	cvar 	= 'calculateYaw',
			desc 	= L.TARGETYAW,
			value 	= true,
			default = false,
		},
		{	cvar 	= 'test_cameraTargetFocusEnemyEnable',
			desc 	= L.TARGETFOCUS,
			value 	= 1,
			default = 0,
		},
		{	cvar 	= 'test_cameraTargetFocusInteractEnable',
			desc 	= L.TARGETFOCUSNPC,
			value 	= 1,
			default = 0,
		},
		{	cvar 	= 'lookAround',
			desc 	= L.LOOKAROUND:format(ICONS.CP_T_L3),
			value 	= true,
			default = false,
		},
		{	cvar 	= 'test_cameraOverShoulder',
			desc 	= L.OVERSHOULDER,
			value 	= {-1, 1},
			default = 0,
			[1] 	= L.LEFT,
			[2]		= L.RIGHT,
			[3]		= OFF,
		},
	}
end

---------------------------------------------------------------
-- Controls: Reset buttons
---------------------------------------------------------------

function PopupMixin:OnClick()
	local popup, config = ConsolePortPopup, ConsolePortOldConfig
	if not self.dontHide then
		popup:Hide()
		config:Hide()
	end
end

local function ResetCalibrationOnClick(self)
	if not InCombatLockdown() then
		self:GetParent():GetParent():Hide()
		ConsolePort:CalibrateController(true)
	end
end

local function ResetAllOnClick(self)
	self:SetText(TUTORIAL.CONFIG.CONFIRMRESET)
	self:SetScript('OnClick', function(self)
		SlashCmdList['CONSOLEPORT']('resetall')
	end)
end

---------------------------------------------------------------
-- Bind catcher
---------------------------------------------------------------
function Catcher:Catch(key)
	FadeIn(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 1)
	ConsolePortOldConfig:ToggleShortcuts(true)
	self:SetScript('OnKeyUp', nil)
	self:EnableKeyboard(false)
	local action = key and GetBindingAction(key)
	if action and action:match('CP_*') then
		self.CurrentButton = action
		if self.CurrentButton then
			self:SetFormattedText(self.formatLine, db.TEXTURE[action])
			self:GetParent():GetParent():OnShow()
		end
	elseif key then
		self:SetText(TUTORIAL.CONFIG.INTERACTCATCHER)
	end
end

function Catcher:OnClick()
	self:EnableKeyboard(true)
	self:SetScript('OnKeyUp', self.Catch)
	FadeOut(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 0)
	ConsolePortOldConfig:ToggleShortcuts(false)
	self:SetText(TUTORIAL.BIND.CATCHER)
end

function Catcher:OnHide()
	self:Catch()
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Catcher:OnShow()
	self.CurrentButton = Settings[self.cvar]
	if self.CurrentButton then
		self:SetFormattedText(self.formatLine, db.TEXTURE[self.CurrentButton])
	else
		self:SetText(TUTORIAL.CONFIG.INTERACTCATCHER)
	end
	FadeIn(self, 0.2, self:GetAlpha(), 1)
end

---------------------------------------------------------------
-- Checkbutton wrapper
---------------------------------------------------------------
function CheckButton:OnClick()
	for _, button in ipairs(self.set) do
		button:SetChecked(false)
	end
	self:SetChecked(true)
end

---------------------------------------------------------------
-- WindowMixin
---------------------------------------------------------------
function WindowMixin:Save()
	local needReload
	-- general settings
	for _, Check in ipairs(self.General) do
		local old = db(Check.Cvar)
		db(Check.Cvar, Check:GetChecked())
		if Check.Reload and Check:GetChecked() ~= old then
			needReload = true
		end
	end
	-- trigger textures
	for _, Check in ipairs(self.Triggers) do
		if Check.Value and Check.Value ~= db(Check.Cvar) then
			db(Check.Cvar, Check.Value)
			needReload = true
		end
	end

	-- target highlight
	db('alwaysHighlight', self.AssistModule.Mode)

	-- camera settings
	db('Mouse/Camera', db('Mouse/Camera') or {})

	local camera = db('Mouse/Camera')
	for _, Check in ipairs(self.Camera) do
		if Check.GetChecked then
			camera[Check.Cvar] = Check:GetChecked() and Check.Value or Check.Default
		else
			for _, Sub in ipairs(Check) do
				if Sub:GetChecked() then
					camera[Sub.Cvar] = Sub.Value
					break
				end
			end
		end
	end

	-- mouse events
	for _, check in ipairs(self.Events) do
		for _, event in ipairs(check.Events) do
			db('Mouse/Events/'..event, check:GetChecked())
		end
	end

	-- interact button full
	if self.IBFullModule.Enable:GetChecked() and self.IBFullModule.BindCatcher.CurrentButton then
		db('interactWith', self.IBFullModule.BindCatcher.CurrentButton)
		db('interactNPC',  self.IBFullModule.NPC:GetChecked())
	else
		db('interactWith', false)
		db('interactNPC', false)
	end

	-- interact button lite
	if 	( not self.IBFullModule.Enable:GetChecked() ) and
		( self.IBLiteModule.Enable:GetChecked() ) and 
		( self.IBLiteModule.BindCatcher.CurrentButton ) then
		db('lootWith', self.IBLiteModule.BindCatcher.CurrentButton)
	else
		self.IBLiteModule.Enable:SetChecked(false)
		db('lootWith', false)
	end

	-- smart interaction
	if db('interactWith') or db('lootWith') then
		db('interactCache',     self.SmartInteract.Enable:GetChecked())
		db('interactScrape',    self.SmartInteract.Scrape:GetChecked())
		db('nameplateNameOnly', self.SmartInteract.Plates:GetChecked())
	else
		db('interactCache', false)
		db('interactScrape', false)
		db('nameplateNameOnly', false)
	end

	-- toggle nameplates for guid scraping
	local scrape  = db('interactScrape')
	db('nameplateShowAll', scrape or nil)
	db('nameplateShowFriends', scrape or nil)
	db('nameplateShowFriendlyNPCs', scrape or nil)

	ConsolePortSettings = db.Settings
	ConsolePortMouse = db.Mouse

	-- dispatch full update of everything related to this tab
	ConsolePort:UpdateCVars()
	ConsolePort:UpdateCameraDriver()
	ConsolePort:LoadEvents()
	ConsolePort:LoadControllerTheme()
	ConsolePort:LoadCameraSettings()
	ConsolePort:LoadRaidCursor()
	ConsolePort:UpdateMouseDriver()
	ConsolePort:SetupUtilityRing()
	return needReload, 'MouseEvent', (not db.table.compare(db.Mouse.Events, ConsolePort:GetDefaultMouseEvents()) and db.Mouse.Events)
end

---------------------------------------------------------------
-- Controls: Create panel and children 
---------------------------------------------------------------

db.PANELS[#db.PANELS + 1] = {name = 'Controls', header = SETTINGS, mixin = WindowMixin, onCreate = function(Controls, self)
	local red, green, blue = db.Atlas.GetCC()

	Settings = db.Settings
	-- Controller settings popup
	Controls.Controller = db.Atlas.GetFutureButton('$parentController', Controls)

	-- SmartInteract free floating frame
	local SmartInteract = CreateFrame('Frame', nil, Controls)
	Controls.SmartInteract = SmartInteract

	do local ExtraButton = Controls.Controller
		local function CreateButton(name, text, OnClick, point, dontHide)
			local button = db.Atlas.GetFutureButton('$parent'..name, ExtraButton.Container, nil, nil, 178, 32)
			button:SetPoint(unpack(point))
			button:SetText(text)
			button:SetScript('OnClick', OnClick)
			Mixin(button, PopupMixin)
			button.dontHide = dontHide
			return button
		end

		ExtraButton.Popup = ConsolePortPopup
		ExtraButton:SetPoint('LEFT', ConsolePortOldConfigDefault, 'RIGHT', 0, 0)
		ExtraButton:SetText(TUTORIAL.CONFIG.CONTROLLERBUTTON)
		ExtraButton:SetScript('OnClick', function(self)
			self.Popup:SetPopup(self:GetText(), self.Container, nil, nil, 400, 850)
		end)

		ExtraButton.Container = CreateFrame('Frame', '$parentPopup', ExtraButton)

		Controls.ResetController = CreateButton('ResetController', TUTORIAL.CONFIG.CONTROLLER, ConsolePort.SelectController, {'TOPLEFT', 40, -16})
		Controls.ResetCalibration = CreateButton('ResetCalibration', TUTORIAL.CONFIG.BINDRESET, ResetCalibrationOnClick, {'LEFT', Controls.ResetController, 'RIGHT', 2, 0})
		Controls.ResetAll = CreateButton('ResetAll', TUTORIAL.CONFIG.FULLRESET, ResetAllOnClick, {'TOPRIGHT', -40, -16}, true)
		Controls.ShowSlash = CreateButton('ShowSlash', TUTORIAL.CONFIG.SHOWSLASH, SlashCmdList['CONSOLEPORT'], {'RIGHT', Controls.ResetAll, 'LEFT', -2, 0}, true)

		ExtraButton.Icon:SetTexture('Interface\\AddOns\\ConsolePort\\Controllers\\'..db('type')..'\\Front')
		ExtraButton.Icon:SetTexCoord(32/512, 256/512, 52/512, 328/512, 460/512, 136/512, 480/512, 210/512)
		ExtraButton.Icon:SetAlpha(0.25)
		ExtraButton.Icon:SetSize(232, 40)
	end

	------------------------------------------------------------------------------------------------------------------------------

	-- Create all the separate config modules

	for _, setup in ipairs({
		{'IBFull', {308, 270}, {'TOPRIGHT', -302, -8}, TUTORIAL.CONFIG.IBFULLHEADER},
		{'IBLite', 	{308, 256}, {'TOPRIGHT', -302, -256}, TUTORIAL.CONFIG.IBLITEHEADER},
		{'Mouse', 	{316, 340}, {'TOPRIGHT', -8, -8}, 	TUTORIAL.CONFIG.MOUSEHEADER},
		{'General', {388, 570}, {'TOPLEFT', 8, -8}, 	TUTORIAL.CONFIG.GENERALHEADER},
		{'Assist', 	{308, 166}, {'BOTTOM', 36, 8}, 		TUTORIAL.CONFIG.TARGETHEADER},
		{'Camera', {316, 332}, {'BOTTOMRIGHT', -8, 8}, 	TUTORIAL.CONFIG.CAMERAHEADER},
		{'Trigger', {820, 230}, {'BOTTOM', Controls.Controller.Container, 'BOTTOM', 0, 0},TUTORIAL.CONFIG.TRIGGERHEADER},
	}) do
		local name, size, point, header = unpack(setup)
		local subFrame = CreateFrame('Frame', nil, Controls)
		subFrame:SetSize(unpack(size))
		subFrame:SetPoint(unpack(point))
		subFrame:SetBackdrop(db.Atlas.Backdrops.Border)
		subFrame.Header = subFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
		subFrame.Header:SetText(header)
		subFrame.Header:SetPoint('TOPLEFT', 24, -24)
		Controls[name..'Module'] = subFrame
	end

	local function GetHelpButton(parent, text)
		parent.HelpButton = CreateFrame('Button', '$parentHelpButton', parent)
		parent.HelpButton:SetSize(64, 64)
		parent.HelpButton.Text = text
		parent.HelpButton:SetNormalTexture('Interface\\Common\\help-i')
		parent.HelpButton:SetHighlightTexture('Interface\\Common\\help-i')
		parent.HelpButton:SetPoint('TOPRIGHT', -4, -4)
		parent.HelpButton:SetScript('OnEnter', function(self)
			self.defaultBackdrop = GameTooltip:GetBackdrop()
			GameTooltip:Hide()
			GameTooltip:SetBackdrop(db.Atlas.Backdrops.TooltipBorder)
			GameTooltip:SetOwner(self, 'ANCHOR_TOP')
			GameTooltip:SetText(self.Text)
			GameTooltip:Show()
		end)
		parent.HelpButton:SetScript('OnLeave', function(self)
			if self.defaultBackdrop then
				GameTooltip:SetBackdrop(self.defaultBackdrop)
			end
			GameTooltip:Hide()
		end)
		parent.HelpButton:SetScript('OnHide', function(self)
			if self.defaultBackdrop then
				GameTooltip:SetBackdrop(self.defaultBackdrop)
			end
			GameTooltip:Hide()
		end)
		return parent.HelpButton
	end

	local function GetCheckButton(parent, name, point, label, setting, func)
		local button = CreateFrame('CheckButton', nil, parent, 'ChatConfigCheckButtonTemplate')
		local text = select(6, button:GetRegions())
		button.Text = text

		text:SetPoint('LEFT', 30, 0)
		text:SetText(label)

		GetHelpButton(SmartInteract, TUTORIAL.CONFIG.TARGETAIHELP):SetSize(52, 52)

		button:SetPoint(unpack(point))
		button:SetChecked(setting)
		button.func = func or function(self) if parent.OnShow then parent:OnShow() end end

		parent[name] = button
		return button
	end

	------------------------------------------------------------------------------------------------------------------------------
	do 	local function SmartEnableToggle(self)
			local scrape = self:GetParent().Scrape
			if self:GetChecked() then
				scrape:SetButtonState('NORMAL')
				scrape:SetAlpha(1)
			else
				scrape:SetChecked(false)
				scrape:SetButtonState('DISABLED')
				scrape:SetAlpha(.5)
			end
			scrape.func(scrape)
		end

		local function SmartScrapeToggle(self)
			local plates = self:GetParent().Plates
			if self:GetChecked() then
				plates:SetButtonState('NORMAL')
				plates:SetAlpha(1)
			else
				plates:SetChecked(false)
				plates:SetButtonState('DISABLED')
				plates:SetAlpha(.5)
			end
		end

		local SmartEnable = GetCheckButton(SmartInteract, 'Enable', {'TOPLEFT', 24, -38}, TUTORIAL.CONFIG.INTERACTCACHE, Settings.interactCache, SmartEnableToggle)
		--[[NPC nameplate]] GetCheckButton(SmartInteract, 'Scrape', {'TOPLEFT', 24, -68}, TUTORIAL.CONFIG.INTERACTSCRAPE, Settings.interactScrape, SmartScrapeToggle)
		--[[Nameonly mode]] GetCheckButton(SmartInteract, 'Plates', {'TOPLEFT', 24, -98}, TUTORIAL.CONFIG.INTERACTNAMEONLY, Settings.nameplateNameOnly)

		SmartInteract:SetSize(292, 142)
		SmartInteract:SetBackdrop(db.Atlas.Backdrops.Border)
		SmartInteract:Hide()
		SmartEnableToggle(SmartEnable)

		local text = SmartInteract:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLeftOrange')
		text:SetText(TUTORIAL.CONFIG.TARGETAIHEADER)
		text:SetPoint('TOPLEFT', 24, -24)

		function SmartInteract:SetAnchor(parent, offset)
			self:ClearAllPoints()
			self:SetPoint('TOPLEFT', parent, 8, offset)
			self:Show()
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local IBFullModule = Controls.IBFullModule

		function IBFullModule:OnShow()
			if self.Enable:GetChecked() then
				FadeOut(self.Hand, .3, self.Hand:GetAlpha(), 0)
				FadeOut(self.Dude, .3, self.Dude:GetAlpha(), 0)
				self.NPC:Show()
				self.BindWrapper:Show()
				self:SetHeight(270 + 234)
				self.Recommend:Show()
				SmartInteract:SetAnchor(self, -100)
				Controls.IBLiteModule:Hide()
			else
				self.NPC:Hide()
				self.BindWrapper:Hide()
				self:SetHeight(270)
				self.Recommend:Hide()
				FadeIn(self.Hand, .3, self.Hand:GetAlpha(), 1)
				FadeIn(self.Dude, .3, self.Dude:GetAlpha(), 1)
				SmartInteract:Hide()
				Controls.IBLiteModule:Show()
			end

			-- approximate the behaviour of the interact button here.
			local L = TUTORIAL.CONFIG
			local text, name
			if self.Enable:GetChecked() then
				local button = self.BindCatcher.CurrentButton or Settings[self.BindCatcher.cvar]
				local bindings = db.Bindings
				local binding = bindings and bindings[button] and bindings[button]['']
				local INFOA, INFOB  = L.INTERACT_CURRENT_A, L.INTERACT_CURRENT_B
				local harmful, helpful = false, false
				if binding then
					local id = ConsolePort:GetActionID(binding)
					if id then
						local mainType, id, subType = GetActionInfo(id)
						if mainType == 'spell' and subType == 'spell' then
							name = GetSpellInfo(id)
							if name then
								harmful, helpful = IsHarmfulSpell(name), IsHelpfulSpell(name)
							end
						elseif mainType == 'item' then
							name = GetItemInfo(id)
							if name then
								harmful, helpful = IsHarmfulItem(name), IsHelpfulItem(name)
							end
						end
					else
						name = _G['BINDING_NAME_' .. binding]
					end
				end
				if harmful and helpful then
					text = INFOA:format(L.INTERACT_NOTARGET, L.INTERACT_TARGET)
				elseif harmful then
					text = INFOB:format(L.INTERACT_NOTARGET, L.INTERACT_HELPFUL, L.INTERACT_HARMFUL)
				elseif helpful then
					text = INFOB:format(L.INTERACT_NOTARGET, L.INTERACT_HARMFUL, L.INTERACT_HELPFUL)
				else
					text = INFOA:format(L.INTERACT_NOTARGET, L.INTERACT_TARGET)
				end
			end
			if text then
				self.Description:SetJustifyH('LEFT')
				self.Description:SetText(L.INTERACT_ORIGINAL:format(name or 'N/A', text))
			else
				self.Description:SetJustifyH('CENTER')
				self.Description:SetText(L.IBFULLDESC)
			end
		end

		Mixin(IBFullModule, IBFullModule)

		IBFullModule.Dude = IBFullModule:CreateTexture(nil, 'BACKGROUND', nil, 1)
		IBFullModule.Dude:SetTexture('Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver')
		IBFullModule.Dude:SetPoint('TOP', 0, -60)
		IBFullModule.Dude:SetSize(128, 128)

		IBFullModule.Hand = IBFullModule:CreateTexture(nil, 'BACKGROUND', nil, 2)
		IBFullModule.Hand:SetTexture('Interface\\TutorialFrame\\UI-TutorialFrame-GloveCursor')
		IBFullModule.Hand:SetPoint('TOP', 16, -120)
		IBFullModule.Hand:SetSize(64, 64)

		IBFullModule.Description = IBFullModule:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		IBFullModule.Description:SetPoint('BOTTOM', 0, 32)

		IBFullModule.BindWrapper = db.Atlas.GetGlassWindow('$parentBindWrapper', IBFullModule, nil, true)
		IBFullModule.BindWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
		IBFullModule.BindWrapper:SetPoint('BOTTOM', 0, 80)
		IBFullModule.BindWrapper:SetSize(292, 100)
		IBFullModule.BindWrapper.Close:Hide()
		IBFullModule.BindWrapper:Hide()

		IBFullModule.BindCatcher = db.Atlas.GetFutureButton('$parentBindCatcher', IBFullModule.BindWrapper, nil, nil, 260)
		IBFullModule.BindCatcher.HighlightTexture:ClearAllPoints()
		IBFullModule.BindCatcher.HighlightTexture:SetAllPoints(IBFullModule.BindCatcher)
		IBFullModule.BindCatcher:SetHeight(70)
		IBFullModule.BindCatcher:SetPoint('CENTER', 0, 0)
		IBFullModule.BindCatcher.Cover:Hide()

		IBFullModule.BindCatcher.cvar = 'interactWith'
		IBFullModule.BindCatcher.formatLine = TUTORIAL.CONFIG.INTERACTASSIGNED

		IBFullModule.Recommend = IBFullModule:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		IBFullModule.Recommend:SetPoint('BOTTOMLEFT', IBFullModule.BindWrapper, 'TOPLEFT', 24, 10)
		IBFullModule.Recommend:SetJustifyH('LEFT')
		IBFullModule.Recommend:SetText(TUTORIAL.CONFIG.IBFULLREC)

		Mixin(IBFullModule.BindCatcher, Catcher)
		IBFullModule.BindCatcher:OnShow()

		GetHelpButton(IBFullModule, TUTORIAL.CONFIG.IBFULLHELP)


		local interactButtons = {
			{name = 'Enable', point = {'TOPLEFT', 24, -48}, label = TUTORIAL.CONFIG.INTERACTCHECK, setting = Settings.interactWith},
			{name = 'NPC', point = {'TOPLEFT', 24, -78}, label = TUTORIAL.CONFIG.INTERACTNPC, setting = Settings.interactNPC},
		}

		for _, setup in pairs(interactButtons) do
			GetCheckButton(IBFullModule, setup.name, setup.point, setup.label, setup.setting)
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local IBLiteModule = Controls.IBLiteModule

		IBLiteModule.BindWrapper = db.Atlas.GetGlassWindow('$parentBindWrapper', IBLiteModule, nil, true)
		IBLiteModule.BindWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
		IBLiteModule.BindWrapper:SetPoint('BOTTOM', 0, 6)
		IBLiteModule.BindWrapper:SetSize(292, 76)
		IBLiteModule.BindWrapper.Close:Hide()

		IBLiteModule.Description = IBLiteModule:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		IBLiteModule.Description:SetPoint('BOTTOM', 0, 40)
		IBLiteModule.Description:SetText(TUTORIAL.CONFIG.IBLITEDESC)

		IBLiteModule.BindCatcher = db.Atlas.GetFutureButton('$parentBindCatcher', IBLiteModule.BindWrapper, nil, nil, 260)
		IBLiteModule.BindCatcher.HighlightTexture:ClearAllPoints()
		IBLiteModule.BindCatcher.HighlightTexture:SetAllPoints(IBLiteModule.BindCatcher)
		IBLiteModule.BindCatcher:SetHeight(46)
		IBLiteModule.BindCatcher:SetPoint('CENTER', 0, 0)
		IBLiteModule.BindCatcher.Cover:Hide()

		IBLiteModule.Enable = CreateFrame('CheckButton', nil, IBLiteModule, 'ChatConfigCheckButtonTemplate')
		IBLiteModule.Enable.Text = IBLiteModule.Enable:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		IBLiteModule.Enable.Text:SetPoint('LEFT', 30, 0)
		IBLiteModule.Enable.Text:SetText(TUTORIAL.CONFIG.INTERACTCHECK)
		IBLiteModule.Enable:SetChecked(Settings.lootWith)
		IBLiteModule.Enable:SetPoint('TOPLEFT', 24, -48)
		IBLiteModule.Enable:SetScript('OnClick', function(self) self:GetParent():OnShow() end)

		function IBLiteModule:OnShow()
			if self.Enable:GetChecked() then
				FadeOut(self.Dude, 0.5, self.Dude:GetAlpha(), 0.1)
				self.Description:Hide()
				self.BindWrapper:Show()
				SmartInteract:SetAnchor(self, -60)
			else
				FadeIn(self.Dude, 0.5, self.Dude:GetAlpha(), .35)
				self.Description:Show()
				self.BindWrapper:Hide()
				SmartInteract:Hide()
			end
		end

		Mixin(IBLiteModule, IBLiteModule)

		IBLiteModule.Dude = IBLiteModule:CreateTexture(nil, 'BACKGROUND', nil, 1)
		IBLiteModule.Dude:SetTexture('Interface\\TutorialFrame\\UI-TutorialFrame-LootCorpse')
		IBLiteModule.Dude:SetPoint('CENTER', 0, -16)
		IBLiteModule.Dude:SetSize(200, 200)
		IBLiteModule.Dude:SetAlpha(0.25)

		IBLiteModule.BindCatcher.cvar = 'lootWith'
		IBLiteModule.BindCatcher.formatLine = TUTORIAL.CONFIG.INTERACTASSIGNED_B

		Mixin(IBLiteModule.BindCatcher, Catcher)
		IBLiteModule.BindCatcher:OnShow()

		GetHelpButton(IBLiteModule, TUTORIAL.CONFIG.IBLITEHELP)
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local MouseModule = Controls.MouseModule
		Controls.Events = {}
		for i, setting in pairs(GetMouseSettings()) do
			local check = CreateFrame('CheckButton', '$parentMouseEvent'..i, MouseModule, 'ChatConfigCheckButtonTemplate')
			local text = check:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
			text:SetText(setting.desc)
			check:SetChecked(setting.state)
			check.Events = setting.event
			check.Description = text
			check:SetPoint('TOPLEFT', 24, -30*i-18)
			text:SetPoint('LEFT', check, 30, 0)
			check:Show()
			text:Show()
			tinsert(Controls.Events, check)
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local GeneralModule = Controls.GeneralModule

		local mouseCvarOffset = #Controls.Events
		local padding = 28
		Controls.General = {}
		for i, setting in pairs(GetAddonSettings()) do
			if setting.cvar then
				local check = CreateFrame('CheckButton', '$parentGeneralSetting'..i, GeneralModule, 'ChatConfigCheckButtonTemplate')
				local text = check:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
				text:SetText(setting.desc)
				check:SetChecked(setting.state)
				check.Description = text
				check.Cvar = setting.cvar
				check.Reload = setting.needReload
				text:SetPoint('LEFT', check, 30, 0)
				if setting.mouse then
					mouseCvarOffset = mouseCvarOffset + 1
					check:SetPoint('TOPLEFT', Controls.MouseModule, 'TOPLEFT', 24, -30*mouseCvarOffset-18)
				else
					check:SetPoint('TOPLEFT', 24, -padding*i-12)
				end
				tinsert(Controls.General, check)
			else
				local text = GeneralModule:CreateFontString('$parentGeneralSetting'..i, 'OVERLAY', 'GameFontNormalLeftOrange')
				text:SetText(setting.desc)
				text:SetPoint('TOPLEFT', 24, -padding*i-24)
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local TriggerModule = Controls.TriggerModule

		local function TriggerClick(self)
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
		end

		GetHelpButton(TriggerModule, TUTORIAL.CONFIG.TRIGGERHELP)
		TriggerModule:SetParent(Controls.Controller.Container)

		Controls.Triggers = {}

		local triggerGraphics = {
			[TUTORIAL.BIND.SHIFT] 	= {offset = 0, cvar = 'CP_M1'},
			[TUTORIAL.BIND.CTRL] 	= {offset = 1, cvar = 'CP_M2'},
			[TUTORIAL.BIND.T1] 		= {offset = 2, cvar = 'CP_T1'},
			[TUTORIAL.BIND.T2] 		= {offset = 3, cvar = 'CP_T2'},
			[TUTORIAL.BIND.T3] 		= {offset = 4, cvar = 'CP_T3'},
			[TUTORIAL.BIND.T4] 		= {offset = 5, cvar = 'CP_T4'},
		}

		for name, info in pairs(triggerGraphics) do
			local trigger = Controls:CreateTexture('$parent'..info.cvar, 'ARTWORK')
			trigger:SetSize(76, 50)
			trigger:SetPoint('TOPLEFT', TriggerModule.Header, 'TOPLEFT', info.offset * 120 + 60, -24)
			trigger.AllSets = Controls.Triggers
			trigger.Value = Settings[info.cvar]
			trigger.Cvar = info.cvar

			local triggerText = TriggerModule:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
			triggerText:SetText(name)
			triggerText:SetPoint('CENTER', trigger, 0, 20)
			triggerText:SetTextColor(0.5, 0.5, 0.5)

			tinsert(Controls.Triggers, trigger)

			Controls[name] = trigger
		end

		local TEXTURE_PATH = 'Interface\\AddOns\\ConsolePort\\Controllers\\%s\\Icons32\\%s'
		local triggers = {
			CP_TL1 = format(TEXTURE_PATH, Settings.type, 'CP_TL1'),
			CP_TL2 = format(TEXTURE_PATH, Settings.type, 'CP_TL2'),
			CP_TR1 = format(TEXTURE_PATH, Settings.type, 'CP_TR1'),
			CP_TR2 = format(TEXTURE_PATH, Settings.type, 'CP_TR2'),
			CP_L_GRIP = format(TEXTURE_PATH, 'Shared', 'CP_L_GRIP'),
			CP_R_GRIP = format(TEXTURE_PATH, 'Shared', 'CP_R_GRIP'),
		}

		local radioButtons = {
			{parent = Controls[TUTORIAL.BIND.SHIFT],	default = Settings.CP_M1},
			{parent = Controls[TUTORIAL.BIND.CTRL], 	default = Settings.CP_M2},
			{parent = Controls[TUTORIAL.BIND.T1], 		default = Settings.CP_T1},
			{parent = Controls[TUTORIAL.BIND.T2], 		default = Settings.CP_T2},
			{parent = Controls[TUTORIAL.BIND.T3], 		default = Settings.CP_T3},
			{parent = Controls[TUTORIAL.BIND.T4], 		default = Settings.CP_T4},
		}

		for i, radio in pairs(radioButtons) do
			local num = 1
			radio.parent.Set = {}
			for name, texture in spairs(triggers) do
				local button = CreateFrame('CheckButton', '$parentTrigger'..i..name, TriggerModule)

				button:SetBackdrop(db.Atlas.Backdrops.BorderSmall)

				button:SetHighlightTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Checked')
				button:SetCheckedTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Checked')

				button.Checked = button:GetCheckedTexture()
				button.Highlight = button:GetHighlightTexture()

				button.Checked:SetTexCoord(0, 1, 1, 0)
				button.Highlight:SetTexCoord(0, 1, 1, 0)

				button.Checked:ClearAllPoints()
				button.Checked:SetPoint('CENTER', 0, 0)
				button.Checked:SetSize(104, 16)
				button.Checked:SetVertexColor(red, green, blue)

				button.Highlight:ClearAllPoints()
				button.Highlight:SetPoint('CENTER', 0, 0)
				button.Highlight:SetSize(104, 16)

				button:SetSize(120, 32)

				button.num = num
				button.set = radio.parent.Set
				button.name = name
				button.parent = radio.parent
				if i == 1 then
					button.text = button:CreateTexture(nil, 'OVERLAY')
					button.text:SetTexture(texture)
					button.text:SetPoint('RIGHT', button, 'LEFT', 0, 0)
					button.text:SetSize(32, 32)
					button.text:SetAlpha(db.Layout and db.Layout[name] and 1 or 0.25)
				end
				button:SetPoint('TOP', radio.parent, 'TOP', 0, -24*(num-1)-12)
				if name == radio.default then
					radio.parent.Index = num
					radio.parent.Value = name
					button:SetChecked(true)
				else
					button:SetChecked(false)
				end
				tinsert(radio.parent.Set, button)
				button:SetScript('OnClick', TriggerClick)
				Mixin(button, CheckButton)
				num = num + 1
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local AssistModule = Controls.AssistModule
		-- Correct the anchor point 
	--	AssistModule:SetPoint('TOPLEFT', Controls.IBFullModule, 'BOTTOMLEFT', 0, 20)
		local radioButtons = {
			{name = TUTORIAL.CONFIG.TARGETSCAN},
			{name = TUTORIAL.CONFIG.TARGETNONE, value = 1},
			{name = TUTORIAL.CONFIG.TARGETALWAYS, value = 2},
		}

		AssistModule.Set = {}

		GetHelpButton(AssistModule, TUTORIAL.CONFIG.HIGHLIGHTHELP)

		local function AssistClick(self)
			self:GetParent().Mode = self.Value
		end

		for i, radio in pairs(radioButtons) do
			local check = CreateFrame('CheckButton', '$parentRadio'..i, AssistModule, 'UIRadioButtonTemplate')			
			local text = check:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
			text:SetText(radio.name)
			check:SetChecked(Settings.alwaysHighlight == radio.value)
			check.Value = radio.value
			text:SetPoint('LEFT', check, 20, 0)
			check:SetPoint('TOPLEFT', 20, -30*i-30)
			check.set = Controls.AssistModule.Set
			tinsert(check.set, check)
			check:SetScript('OnClick', AssistClick)
			Mixin(check, CheckButton)
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local CameraModule = Controls.CameraModule
		local function CreateCheckButton(i, cvar, desc, state, value, default)
			local check = CreateFrame('CheckButton', '$parentSetting'..i, CameraModule, 'ChatConfigCheckButtonTemplate')
			local text = check:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
			text:SetText(desc)
			check:SetChecked(state)
			check.Description = text
			check.Cvar = cvar
			check.Value = value
			check.Default = default
			text:SetPoint('LEFT', check, 30, 0)
			return check
		end

		local function CheckOnClick(self)
			for _, button in pairs(self.checks) do
				button:SetChecked(false)
			end
			self:SetChecked(true)
		end

		-- Spaghetti code, cba to fix
		Controls.Camera = {}
		local offsetY = 0
		local camvals = db.Mouse and db.Mouse.Camera
		for i, setting in pairs(GetCameraSettings()) do
			if type(setting.value) ~= 'table' then
				offsetY = offsetY + 1
				local state = tostring(setting.value) == tostring(camvals and camvals[setting.cvar] or '')
				local check = CreateCheckButton(i, setting.cvar, setting.desc, state, setting.value, setting.default)
				check:SetPoint('TOPLEFT', 24, -30 * offsetY - 18)
				tinsert(Controls.Camera, check)
			else
				offsetY = offsetY + 2
				local text = CameraModule:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
				text:SetText(setting.desc)
				text:SetPoint('TOPLEFT', 24, -30 * ( offsetY - 1 ) - 24)
				local checks = {}
				local state = camvals and tostring(camvals[setting.cvar] or '')
				for j, val in pairs(setting.value) do
					local check = CreateCheckButton(i..j, setting.cvar, setting[j], state == tostring(val), val)
					if checks[j - 1] then
						check:SetPoint('LEFT', checks[j-1].Description, 'RIGHT', 8, 0)
					else
						check:SetPoint('TOPLEFT', 24, -30 * offsetY - 18)
					end
					tinsert(checks, check)
				end
				local check = CreateCheckButton(i.. #setting.value + 1, setting.cvar, setting[#setting.value+1], state == tostring(setting.default), setting.default)
				check:SetPoint('LEFT', checks[#checks].Description, 'RIGHT', 8, 0)
				tinsert(checks, check)
				for _, check in pairs(checks) do
					check.checks = checks
					check:SetHitRectInsets(0, 0, 0, 0)
					check:SetScript('OnClick', CheckOnClick)
				end
				tinsert(Controls.Camera, checks)
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	-- Add link buttons
	do 	local count = 0
		local BASE_ALPHA = 0.25
		local BASE_INSET = 12
		local L = TUTORIAL.CONFIG
		local function OnEnter(self)
			GameTooltip:SetOwner(self, 'ANCHOR_TOP')
			GameTooltip:SetText(self.tooltipText)
			FadeIn(self, 0.2, self:GetAlpha(), 1)
			self:SetSize(66, 66)
		end

		local function OnLeave(self)
			GameTooltip:Hide()
			FadeOut(self, 0.2, self:GetAlpha(), BASE_ALPHA)
			self:SetSize(64, 64)
		end

		local function OnClick(self)
			StaticPopupDialogs['CONSOLEPORT_EXTERNALLINK'] = {
				text = db.TUTORIAL.SLASH.EXTERNALLINK:format(self.tooltipText),
				button1 = CLOSE,
				showAlert = true,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
				hasEditBox = 1,
				enterClicksFirstButton = true,
				exclusive = true,
				OnAccept = ConsolePort.ClearPopup,
				OnCancel = ConsolePort.ClearPopup,
				OnShow = function(self, data)
					self.editBox:SetText(data)
				end,
			}
			ConsolePort:ShowPopup('CONSOLEPORT_EXTERNALLINK', nil, nil, self.link)
		end

		local first, last

		for i, info in pairs({
			{'CP', L.LINK_CP, 'http://www.consoleport.net'},
			{'WM', L.LINK_WM, 'https://github.com/topher-au/WoWmapper/releases/latest'},
			{'Discord', L.LINK_DISCORD, 'https://discord.gg/AWeHd48'},
			{'Patreon', L.LINK_PATREON, 'https://www.patreon.com/consoleport'},
		})
		do
			local id, tooltip, link = unpack(info)
			local button = CreateFrame('Button', nil, Controls)

			if not first then first = button end
			last = button

			button:SetScript('OnEnter', OnEnter)
			button:SetScript('OnLeave', OnLeave)
			button:SetScript('OnClick', OnClick)
			button:SetSize(64, 64)
			button:SetAlpha(BASE_ALPHA)
			button.ignoreNode = true
			button.tooltipText = tooltip
			button.link = link
			button:SetNormalTexture('Interface\\AddOns\\ConsolePort\\Textures\\Logos\\'..id)
			button:SetPoint('BOTTOMLEFT', (i * 72) - BASE_INSET, 26)
			count = count + 1
		end

		Controls.LinkHilite = Controls:CreateTexture(nil, 'BACKGROUND')
		Controls.LinkHilite:SetPoint('LEFT', first, 0, 0)
		Controls.LinkHilite:SetPoint('RIGHT', last, 0, 0)
		Controls.LinkHilite:SetHeight(72)
		Controls.LinkHilite:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight')
		Controls.LinkHilite:SetBlendMode('ADD')
		Controls.LinkHilite:SetVertexColor(red, green, blue, 0.05)

		Controls.TopLine = Controls:CreateTexture(nil, 'BORDER')
		Controls.TopLine:SetTexture('Interface\\LevelUp\\LevelUpTex')
		Controls.TopLine:SetTexCoord(0.00195313, 0.81835938, 0.013671875, 0.017578125)
		Controls.TopLine:SetHeight(1)
		Controls.TopLine:SetPoint('TOPLEFT', Controls.LinkHilite, 0, 0)
		Controls.TopLine:SetPoint('TOPRIGHT', Controls.LinkHilite, 0, 0)
		Controls.TopLine:SetVertexColor(red, green, blue, 1)

		Controls.BottomLine = Controls:CreateTexture(nil, 'BORDER')
		Controls.BottomLine:SetTexture('Interface\\LevelUp\\LevelUpTex')
		Controls.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.013671875, 0.017578125)
		Controls.BottomLine:SetHeight(1)
		Controls.BottomLine:SetPoint('BOTTOMLEFT', Controls.LinkHilite, 0, 0)
		Controls.BottomLine:SetPoint('BOTTOMRIGHT', Controls.LinkHilite, 0, 0)
		Controls.BottomLine:SetVertexColor(red, green, blue, 1)
	end
end}