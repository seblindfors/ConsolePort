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
			state = Settings.turnCharacter,
			needReload = true, 
		},
		{	cvar = 'doubleModTap',
			desc = L.DOUBLEMODTAP:format(ICONS.CP_M1, ICONS.CP_M2),
			state = Settings.doubleModTap,
		},
		{	cvar = 'disableSmartMouse',
			desc = L.DISABLEMOUSE,
			state = Settings.disableSmartMouse,
		},
		{	desc = L.TARGETING },
		{	cvar = 'raidCursorDirect',
			desc = L.RAIDCURSORDIRECT,
			state = Settings.raidCursorDirect,
			needReload = true,
		},
		{
			cvar = 'TargetNearestUseNew',
			desc = L.TARGETALGORITHM,
			state = Settings.TargetNearestUseNew,
		},
		{	desc = L.CONVENIENCE },
		{	cvar = 'autoExtra',
			desc = L.AUTOEXTRA,
			state = Settings.autoExtra,
		},
		{	cvar = 'autoLootDefault',
			desc = L.AUTOLOOT,
			state = Settings.autoLootDefault,
		},
		{	cvar = 'autoSellJunk',
			desc = L.AUTOSELL,
			state = Settings.autoSellJunk,
		},
		{	cvar = 'disableHints',
			desc = TUTORIAL.HINTS.DISABLE,
			state = Settings.disableHints,
		},
		{	cvar = 'disableSmartBind',
			desc = L.DISABLEBINDHELP,
			state = Settings.disableSmartBind,
		},
		{	desc = L.FIXES },
		{	cvar = 'UIdisableHoldRepeat',
			desc = L.DISABLEHOLDREPEAT,
			state = Settings.UIdisableHoldRepeat,
			needReload = true,
		},
		{	cvar = 'skipCalibration',
			desc = L.SKIPCALIBRATION,
			state = Settings.skipCalibration,
		},
		-- Mouse 'events' to the user, but cvars internally
		{	mouse = true,
			cvar = 'mouseOnJump',
			desc = TUTORIAL.MOUSE.JUMPING,
			state = Settings.mouseOnJump,
		},
		{	mouse = true,
			cvar = 'mouseOnCenter',
			desc = TUTORIAL.MOUSE.CENTERCURSOR,
			state = Settings.mouseOnCenter,
		},
		{	mouse = true,
			cvar = 'preventMouseDrift',
			desc = L.MOUSEDRIFTING,
			state = Settings.preventMouseDrift,
		},
	}
end
---------------------------------------------------------------
-- Mouse: Returns events for mouselook
---------------------------------------------------------------
local function GetMouseSettings()
	return {
		{ 	event 	= {'PLAYER_STARTED_MOVING'},
			desc 	= TUTORIAL.MOUSE.STARTED_MOVING,
			state 	= db.Mouse.Events['PLAYER_STARTED_MOVING']
		},
		{ 	event	= {'PLAYER_TARGET_CHANGED'},
			desc 	= TUTORIAL.MOUSE.TARGET_CHANGED,
			state 	= db.Mouse.Events['PLAYER_TARGET_CHANGED']
		},
		{	event 	= {'UNIT_SPELLCAST_SENT', 'UNIT_SPELLCAST_FAILED'},
			desc 	= TUTORIAL.MOUSE.DIRECT_SPELL_CAST,
			state 	= db.Mouse.Events['UNIT_SPELLCAST_SENT']
		},
		{	event 	= {	'GOSSIP_SHOW', 'GOSSIP_CLOSED',
						'MERCHANT_SHOW', 'MERCHANT_CLOSED',
						'TAXIMAP_OPENED', 'TAXIMAP_CLOSED',
						'QUEST_GREETING', 'QUEST_DETAIL',
						'QUEST_PROGRESS', 'QUEST_COMPLETE', 'QUEST_FINISHED',
						'SHIPMENT_CRAFTER_OPENED', 'SHIPMENT_CRAFTER_CLOSED'},
			desc 	= TUTORIAL.MOUSE.NPC_INTERACTION,
			state 	= db.Mouse.Events['GOSSIP_SHOW']
		},
		{ 	event	= {'QUEST_AUTOCOMPLETE'},
			desc 	= TUTORIAL.MOUSE.QUEST_AUTOCOMPLETE,
			state 	= db.Mouse.Events['QUEST_AUTOCOMPLETE']
		},
		{	event	= {'LOOT_OPENED', 'LOOT_CLOSED'},
			desc 	= TUTORIAL.MOUSE.LOOTING,
			state 	= db.Mouse.Events['LOOT_OPENED']
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
		{	cvar 	= 'test_cameraLockedTargetFocusing',
			desc 	= L.TARGETFOCUS,
			value 	= 1,
			default = 0,
		},
		{	cvar 	= 'calculateYaw',
			desc 	= L.TARGETYAW,
			value 	= true,
			default = false,
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
	local popup, config = ConsolePortPopup, ConsolePortConfig
	if not self.dontHide then
		popup:Hide()
		config:Hide()
	end
end

local function ResetBindingsOnClick(self)
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
	ConsolePortConfig:ToggleShortcuts(true)
	self:SetScript('OnKeyUp', nil)
	self:EnableKeyboard(false)
	local action = key and GetBindingAction(key)
	if action and action:match('CP_*') then
		self.CurrentButton = action
		if self.CurrentButton then
			self:SetFormattedText(TUTORIAL.CONFIG.INTERACTASSIGNED, db.TEXTURE[action])
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
	ConsolePortConfig:ToggleShortcuts(false)
	self:SetText(TUTORIAL.BIND.CATCHER)
end

function Catcher:OnHide()
	self:Catch()
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Catcher:OnShow()
	self.CurrentButton = Settings[self.cvar]
	if self.CurrentButton then
		self:SetFormattedText(TUTORIAL.CONFIG.INTERACTASSIGNED, db.TEXTURE[self.CurrentButton])
	else
		self:SetText(TUTORIAL.CONFIG.INTERACTCATCHER)
	end
	FadeIn(self, 0.2, self:GetAlpha(), 1)
end

---------------------------------------------------------------
-- Checkbutton wrapper
---------------------------------------------------------------
function CheckButton:OnClick()
	for i, button in pairs(self.set) do
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
	for i, Check in pairs(self.General) do
		local old = Settings[Check.Cvar]
		Settings[Check.Cvar] = Check:GetChecked()
		if Check.Reload and Check:GetChecked() ~= old then
			needReload = true
		end
	end
	-- trigger textures
	for i, Check in pairs(self.Triggers) do
		if Check.Value and Check.Value ~= Settings[Check.Cvar] then
			Settings[Check.Cvar] = Check.Value
			needReload = true
		end
	end

	-- target highlight
	Settings.alwaysHighlight = self.AssistModule.Mode


	-- camera settings
	if not db.Mouse.Camera then
		db.Mouse.Camera = {}
	end
	for i, Check in pairs(self.Camera) do
		if Check.GetChecked then
			db.Mouse.Camera[Check.Cvar] = Check:GetChecked() and Check.Value or Check.Default
		else
			for i, Sub in pairs(Check) do
				if Sub:GetChecked() then
					db.Mouse.Camera[Sub.Cvar] = Sub.Value
					break
				end
			end
		end
	end

	ConsolePort:UpdateCVars()
	ConsolePort:UpdateCameraDriver()

	-- mouse events
	for i, Check in pairs(self.Events) do
		for i, Event in pairs(Check.Events) do
			db.Mouse.Events[Event] = Check:GetChecked()
		end
	end

	-- interact button
	if self.InteractModule.Enable:GetChecked() and self.InteractModule.BindCatcher.CurrentButton then
		Settings.interactWith = self.InteractModule.BindCatcher.CurrentButton
		Settings.mouseOverMode = self.InteractModule.MouseOver:GetChecked()
		Settings.interactNPC = self.InteractModule.NPC:GetChecked()
		Settings.interactAuto = self.InteractModule.Auto:GetChecked()
	else
		Settings.interactWith = false
		Settings.mouseOverMode = false
		Settings.interactNPC = false
		Settings.interactAuto = false
	end

	-- loot button
	if 	( self.LootModule.Enable:GetChecked() ) and 
		( self.LootModule.BindCatcher.CurrentButton ) and
		( self.LootModule.BindCatcher.CurrentButton ~= self.InteractModule.BindCatcher.CurrentButton ) then
		Settings.lootWith = self.LootModule.BindCatcher.CurrentButton
	else
		self.LootModule.Enable:SetChecked(false)
		Settings.lootWith = false
	end

	ConsolePortSettings = db.Settings
	ConsolePortMouse = db.Mouse

	ConsolePort:LoadEvents()
	ConsolePort:LoadControllerTheme()
	ConsolePort:LoadCameraSettings()
	ConsolePort:UpdateMouseDriver()
	ConsolePort:SetupUtilityBelt()
	return needReload, 'MouseEvent', (not db.table.compare(db.Mouse.Events, ConsolePort:GetDefaultMouseEvents()) and db.Mouse.Events)
end

---------------------------------------------------------------
-- Controls: Create panel and children 
---------------------------------------------------------------

db.PANELS[#db.PANELS + 1] = {name = 'Controls', header = SETTINGS, mixin = WindowMixin, onLoad = function(Controls, self)
	local red, green, blue = db.Atlas.GetCC()

	Settings = db.Settings
--("$parentHeader"..id, self, nil, bannerAtlas, 125, 32, true
	Controls.Controller = db.Atlas.GetFutureButton('$parentController', Controls)

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
		ExtraButton:SetPoint('LEFT', ConsolePortConfigDefault, 'RIGHT', 0, 0)
		ExtraButton:SetText(TUTORIAL.CONFIG.CONTROLLERBUTTON)
		ExtraButton:SetScript('OnClick', function(self)
			self.Popup:SetPopup(self:GetText(), self.Container, nil, nil, 400, 850)
		end)

		ExtraButton.Container = CreateFrame('Frame', '$parentPopup', ExtraButton)

		Controls.ResetController = CreateButton('ResetController', TUTORIAL.CONFIG.CONTROLLER, ConsolePort.SelectController, {'TOPLEFT', 40, -16})
		Controls.ResetBindings = CreateButton('ResetBindings', TUTORIAL.CONFIG.BINDRESET, ResetBindingsOnClick, {'LEFT', Controls.ResetController, 'RIGHT', 2, 0})
		Controls.ResetAll = CreateButton('ResetAll', TUTORIAL.CONFIG.FULLRESET, ResetAllOnClick, {'TOPRIGHT', -40, -16}, true)
		Controls.ShowSlash = CreateButton('ShowSlash', TUTORIAL.CONFIG.SHOWSLASH, SlashCmdList['CONSOLEPORT'], {'RIGHT', Controls.ResetAll, 'LEFT', -2, 0}, true)

		ExtraButton.Icon:SetTexture('Interface\\AddOns\\ConsolePort\\Controllers\\'..Settings.type..'\\Front')
		ExtraButton.Icon:SetTexCoord(32/512, 256/512, 52/512, 328/512, 460/512, 136/512, 480/512, 210/512)
		ExtraButton.Icon:SetAlpha(0.25)
		ExtraButton.Icon:SetSize(232, 40)
	end

	------------------------------------------------------------------------------------------------------------------------------

	-- Create all the separate config modules

	for _, setup in pairs({
		{'Interact', {308, 340}, {'TOPRIGHT', -302, -8}, TUTORIAL.CONFIG.INTERACTHEADER},
		{'Loot', 	{308, 176}, {'CENTER', 36, -82}, 	TUTORIAL.CONFIG.LOOTHEADER},
		{'Mouse', 	{316, 340}, {'TOPRIGHT', -8, -8}, 	TUTORIAL.CONFIG.MOUSEHEADER},
		{'General', {388, 570}, {'TOPLEFT', 8, -8}, 	TUTORIAL.CONFIG.GENERALHEADER},
		{'Assist', 	{308, 176}, {'BOTTOM', 36, 8}, 		TUTORIAL.CONFIG.TARGETHEADER},
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
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, 'ANCHOR_TOP')
			GameTooltip:SetText(self.Text)
			GameTooltip:Show()
		end)
		parent.HelpButton:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)
		return parent.HelpButton
	end

	------------------------------------------------------------------------------------------------------------------------------
	do local InteractModule = Controls.InteractModule

		function InteractModule:OnShow()
			if self.Enable:GetChecked() then
				FadeOut(self.Hand, 0.5, 1, 0.1)
				FadeOut(self.Dude, 0.5, 1, 0.1)
				self.MouseOver:Show()
				self.Auto:Show()
				self.NPC:Show()
				self.BindWrapper:Show()
			else
				self.MouseOver:Hide()
				self.Auto:Hide()
				self.NPC:Hide()
				self.BindWrapper:Hide()
				FadeIn(self.Hand, 0.5, 0.1, 1)
				FadeIn(self.Dude, 0.5, 0.1, 1)
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
				self.Description:SetText(L.INTERACTDESC)
			end
		end

		Mixin(InteractModule, InteractModule)

		InteractModule.Dude = InteractModule:CreateTexture(nil, 'BACKGROUND', nil, 1)
		InteractModule.Dude:SetTexture('Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver')
		InteractModule.Dude:SetPoint('CENTER', 0, 0)
		InteractModule.Dude:SetSize(128, 128)

		InteractModule.Hand = InteractModule:CreateTexture(nil, 'BACKGROUND', nil, 2)
		InteractModule.Hand:SetTexture('Interface\\TutorialFrame\\UI-TutorialFrame-GloveCursor')
		InteractModule.Hand:SetPoint('CENTER', 16, -40)
		InteractModule.Hand:SetSize(64, 64)

		InteractModule.Description = InteractModule:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		InteractModule.Description:SetPoint('BOTTOM', 0, 32)

		InteractModule.BindWrapper = db.Atlas.GetGlassWindow('$parentBindWrapper', InteractModule, nil, true)
		InteractModule.BindWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
		InteractModule.BindWrapper:SetPoint('BOTTOM', 0, 90)
		InteractModule.BindWrapper:SetSize(256, 90)
		InteractModule.BindWrapper.Close:Hide()
		InteractModule.BindWrapper:Hide()

		InteractModule.BindCatcher = db.Atlas.GetFutureButton('$parentBindCatcher', InteractModule.BindWrapper, nil, nil, 200)
		InteractModule.BindCatcher.HighlightTexture:ClearAllPoints()
		InteractModule.BindCatcher.HighlightTexture:SetAllPoints(InteractModule.BindCatcher)
		InteractModule.BindCatcher:SetHeight(60)
		InteractModule.BindCatcher:SetPoint('CENTER', 0, 0)
		InteractModule.BindCatcher.Cover:Hide()

		InteractModule.BindCatcher.cvar = 'interactWith'

		Mixin(InteractModule.BindCatcher, Catcher)
		InteractModule.BindCatcher:OnShow()

		GetHelpButton(InteractModule, TUTORIAL.CONFIG.INTERACTHELP)


		local function InteractCheckButton(name, point, label, setting)
			local button = CreateFrame('CheckButton', nil, InteractModule, 'ChatConfigCheckButtonTemplate')
			local text = button:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
			button.Text = text

			text:SetPoint('LEFT', 30, 0)
			text:SetText(label)

			button:SetPoint(unpack(point))
			button:SetChecked(setting)
			button:SetScript('OnClick', function(self) self:GetParent():OnShow() end)

			InteractModule[name] = button
		end

		local interactButtons = {
			{name = 'Enable', point = {'TOPLEFT', 24, -48}, label = TUTORIAL.CONFIG.INTERACTCHECK, setting = Settings.interactWith},
			{name = 'MouseOver', point = {'TOPLEFT', 24, -78}, label = TUTORIAL.CONFIG.MOUSEOVERMODE, setting = Settings.mouseOverMode},
			{name = 'NPC', point = {'TOPLEFT', 24, -108}, label = TUTORIAL.CONFIG.INTERACTNPC, setting = Settings.interactNPC},
			{name = 'Auto', point = {'TOPLEFT', 24, -138}, label = TUTORIAL.CONFIG.INTERACTAUTO, setting = Settings.interactAuto},
		}

		for _, setup in pairs(interactButtons) do
			InteractCheckButton(setup.name, setup.point, setup.label, setup.setting)
		end
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
					check:SetPoint('TOPLEFT', 24, -30*i-12)
				end
				tinsert(Controls.General, check)
			else
				local text = GeneralModule:CreateFontString('$parentGeneralSetting'..i, 'OVERLAY', 'GameFontNormalLeftOrange')
				text:SetText(setting.desc)
				text:SetPoint('TOPLEFT', 24, -30*i-24)
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
	--	AssistModule:SetPoint('TOPLEFT', Controls.InteractModule, 'BOTTOMLEFT', 0, 20)
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
	do local LootModule = Controls.LootModule

		LootModule.BindWrapper = db.Atlas.GetGlassWindow('$parentBindWrapper', LootModule, nil, true)
		LootModule.BindWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
		LootModule.BindWrapper:SetPoint('BOTTOM', 0, 16)
		LootModule.BindWrapper:SetSize(256, 90)
		LootModule.BindWrapper.Close:Hide()

		LootModule.BindCatcher = db.Atlas.GetFutureButton('$parentBindCatcher', LootModule.BindWrapper, nil, nil, 200)
		LootModule.BindCatcher.HighlightTexture:ClearAllPoints()
		LootModule.BindCatcher.HighlightTexture:SetAllPoints(LootModule.BindCatcher)
		LootModule.BindCatcher:SetHeight(60)
		LootModule.BindCatcher:SetPoint('CENTER', 0, 0)
		LootModule.BindCatcher.Cover:Hide()

		LootModule.Enable = CreateFrame('CheckButton', nil, LootModule, 'ChatConfigCheckButtonTemplate')
		LootModule.Enable.Text = LootModule.Enable:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		LootModule.Enable.Text:SetPoint('LEFT', 30, 0)
		LootModule.Enable.Text:SetText(TUTORIAL.CONFIG.INTERACTCHECK)
		LootModule.Enable:SetChecked(Settings.lootWith)
		LootModule.Enable:SetPoint('TOPLEFT', 24, -48)
		LootModule.Enable:SetScript('OnClick', function(self) self:GetParent():OnShow() end)

		function LootModule:OnShow()
			if self.Enable:GetChecked() then
				self.BindWrapper:Show()
			else
				self.BindWrapper:Hide()
			end
		end

		Mixin(LootModule, LootModule)

		LootModule.Dude = LootModule:CreateTexture(nil, 'BACKGROUND', nil, 1)
		LootModule.Dude:SetTexture('Interface\\TutorialFrame\\UI-TutorialFrame-LootCorpse')
		LootModule.Dude:SetPoint('CENTER', 0, -16)
		LootModule.Dude:SetSize(200, 200)
		LootModule.Dude:SetAlpha(0.1)

		LootModule.BindCatcher.cvar = 'lootWith'

		Mixin(LootModule.BindCatcher, Catcher)
		LootModule.BindCatcher:OnShow()

		GetHelpButton(LootModule, TUTORIAL.CONFIG.LOOTHELP)
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