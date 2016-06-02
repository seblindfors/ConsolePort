---------------------------------------------------------------
-- Init.lua: Main frame creation, version checking, slash cmd
---------------------------------------------------------------
-- Create the main frame and check all loaded settings.
-- Validate compatibility with older versions.
-- Create the slash handler function.

local addOn, db = ...
---------------------------------------------------------------
-- Create main frame (not visible to user)
---------------------------------------------------------------
local ConsolePort = CreateFrame("FRAME", "ConsolePort")
---------------------------------------------------------------
-- CRITICALUPDATE: flag when old settings are incompatible. 
---------------------------------------------------------------
local CRITICALUPDATE = false
---------------------------------------------------------------
-- VERSION: generate a comparable integer from addon metadata 
---------------------------------------------------------------
local v1, v2, v3 = strsplit("%d+.", GetAddOnMetadata(addOn, "Version"))
local VERSION = v1*10000+v2*100+v3
---------------------------------------------------------------
local newChar
---------------------------------------------------------------
-- Initialize crucial addon-wide tables
---------------------------------------------------------------
db.ICONS 	= {}
db.TEXTURE 	= {}
db.SECURE 	= {}
db.PANELS 	= {}
db.PLUGINS 	= {}

---------------------------------------------------------------
local function ResetAllSettings()
	if not InCombatLockdown() then
		for binding in ConsolePort:GetBindings() do
			local key1, key2 = GetBindingKey(binding)
			if key1 then SetBinding(key1) end
			if key2 then SetBinding(key2) end
		end
		SaveBindings(GetCurrentBindingSet())
		ConsolePortBindingSet = nil
		ConsolePortMouse = nil
		ConsolePortSettings = nil
		ConsolePortCharacterSettings = nil
		ReloadUI()
	else
		print(db.TUTORIAL.SLASH.COMBAT)
	end
end

local function LoadDefaultBindings()
	ConsolePortConfig:Show()
	ConsolePortConfigContainerBinds:Default()
end

function ConsolePort:LoadSettings()

	local fullReset

	if not ConsolePortSettings then
		fullReset = true
		ConsolePortSettings = self:GetDefaultAddonSettings()
		self:SelectController()
	-- compatibility fix:
	elseif ConsolePortSettings.shift then
		ConsolePortSettings = self:GetDefaultAddonSettings()
	end

	db.Settings = ConsolePortSettings

	self:LoadLookup()

	-----------------------------------------------------------
	-- Set/load binding table
	-----------------------------------------------------------
	if not ConsolePortBindingSet then
		if not fullReset and not db.Settings.newController then
			newChar = true
		end
		ConsolePortBindingSet = {}
	else
		-- compatibility fix: convert binding tables from old format (0.14.5) to new (1.*.*)
		-- remove in a future patch.
		local convertModifier = {
			action 	= "",
			shift 	= "SHIFT-",
			ctrl 	= "CTRL-",
			ctrlsh 	= "CTRL-SHIFT-",
		}
		local convertButton = {
			CP_C_OPTION = "CP_X_CENTER",
			CP_L_OPTION = "CP_X_LEFT",
			CP_R_OPTION = "CP_X_RIGHT",
			CP_TR1 = "CP_T1",
			CP_TR2 = "CP_T2",
			CP_TR3 = "CP_T_R3",
			CP_TL3 = "CP_T_L3",
		}
		for button, subSet in pairs(ConsolePortBindingSet) do
			local newSubset
			for modifier, binding in pairs(subSet) do
				local converted = convertModifier[modifier]
				if converted then
					if not newSubset then
						newSubset = {}
					end
					newSubset[converted] = binding
				end
			end
			button = convertButton[button] or button
			ConsolePortBindingSet[button] = newSubset or subSet
		end
	end

	-----------------------------------------------------------
	-- Set/load mouse settings
	-----------------------------------------------------------
	if not ConsolePortMouse then
		ConsolePortMouse = {
			Events = self:GetDefaultMouseEvents(),
			Cursor = self:GetDefaultMouseCursor(),
		}
	end

	-----------------------------------------------------------
	-- Extra features
	-----------------------------------------------------------
	-- Use these frames in the virtual cursor stack
	if not ConsolePortUIFrames then
		ConsolePortUIFrames = self:GetDefaultUIFrames()
	end

	-- Use this table to populate radial action bar
	if not ConsolePortUtility then
		ConsolePortUtility = {}
	end

	----------------------------------------------------------

	db.Bindings = ConsolePortBindingSet
	db.UIStack = ConsolePortUIFrames
	db.Mouse = ConsolePortMouse

	----------------------------------------------------------

	-- Load the calibration wizard if a button does not have a registered mock binding
	if 	self:CheckCalibration() then
		self:CalibrateController()
	end

	-- Slash handler and stuff related to that
	local SLASH = db.TUTORIAL.SLASH

	local function ShowSplash() ConsolePort:SelectController() end
	local function ShowBinds() ConsolePortConfig:OpenCategory(2) end

	local function ResetAll()
		if not InCombatLockdown() then
			for binding in ConsolePort:GetBindings() do
				local key1, key2 = GetBindingKey(binding)
				if key1 then SetBinding(key1) end
				if key2 then SetBinding(key2) end
			end
			SaveBindings(GetCurrentBindingSet())
			ConsolePortBindingSet = nil --ConsolePort:GetDefaultBindingSet()
			ConsolePortUIFrames = nil
			ConsolePortSettings = nil
			ConsolePortUtility = nil
			ConsolePortMouse = nil
			ReloadUI()
		else
			print("|cffffe00aConsolePort|r:", SLASH.COMBAT)
		end
	end

	local instructions = {
		["type"] = {desc = SLASH.TYPE, func = ShowSplash},
		["binds"] = {desc = SLASH.BINDS, func = ShowBinds},
		["resetall"] = {desc = SLASH.RESET, func = ResetAll},
	}

	SLASH_CONSOLEPORT1, SLASH_CONSOLEPORT2 = "/cp", "/consoleport"
	SlashCmdList["CONSOLEPORT"] = function(msg, editBox)
		if instructions[msg] then
			instructions[msg].func()
		else
			print("|cffffe00aConsolePort|r:")
			for k, v in pairs(instructions) do
				print(format("|cff69ccf0/cp %s|r: %s", k, v.desc))
			end
		end
	end
	self.LoadSettings = nil
end

function ConsolePort:CheckLoadedSettings()
    if 	(ConsolePortSettings and not ConsolePortSettings.version) or 
		(ConsolePortSettings.version < VERSION and CRITICALUPDATE) then
		StaticPopupDialogs["CONSOLEPORT_CRITICALUPDATE"] = {
			text = format(db.TUTORIAL.SLASH.CRITICALUPDATE, GetAddOnMetadata(addOn, "Version")),
			button1 = db.TUTORIAL.SLASH.ACCEPT,
			button2 = db.TUTORIAL.SLASH.CANCEL,
			showAlert = true,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			enterClicksFirstButton = true,
			exclusive = true,
			OnAccept = ResetAllSettings,
			OnCancel = self.ClearPopup,
		}
		self:ShowPopup("CONSOLEPORT_CRITICALUPDATE")
	elseif ConsolePortSettings and ConsolePortSettings.newController then
		StaticPopupDialogs["CONSOLEPORT_NEWCONTROLLER"] = {
			text = db.TUTORIAL.SLASH.NEWCONTROLLER,
			button1 = db.TUTORIAL.SLASH.ACCEPT,
			button2 = db.TUTORIAL.SLASH.CANCEL,
			showAlert = true,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			enterClicksFirstButton = true,
			exclusive = true,
			OnAccept = LoadDefaultBindings,
			OnCancel = self.ClearPopup,
		}
		self:ShowPopup("CONSOLEPORT_NEWCONTROLLER")
		ConsolePortSettings.newController = nil
	elseif ConsolePortSettings and newChar then
		StaticPopupDialogs["CONSOLEPORT_NEWCHARACTER"] = {
			text = db.TUTORIAL.SLASH.NEWCHARACTER,
			button1 = db.TUTORIAL.SLASH.ACCEPT,
			button2 = db.TUTORIAL.SLASH.CANCEL,
			showAlert = true,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			enterClicksFirstButton = true,
			exclusive = true,
			OnAccept = LoadDefaultBindings,
			OnCancel = self.ClearPopup,
		}
		self:ShowPopup("CONSOLEPORT_NEWCHARACTER")
	end
	self.CheckLoadedSettings = nil
end

function ConsolePort:CreateActionButtons()
	for name in self:GetBindings() do
		local i = 0
		for modifier in self:GetModifiers() do
			local secure = self:CreateSecureButton(name, modifier, self:GetUIControlKey(name))
			self:CreateConfigButton(name, modifier, secure)
			i = i + 1
		end
	end
	db.Binds.Rebind:Refresh()
	db.Binds.Rebind.ShortcutScroll:Refresh()
	self.CreateActionButtons = nil
end