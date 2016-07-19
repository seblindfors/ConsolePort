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
local CRITICALUPDATE, NOBINDINGS
---------------------------------------------------------------
-- VERSION: generate a comparable integer from addon metadata 
---------------------------------------------------------------
local v1, v2, v3 = strsplit("%d+.", GetAddOnMetadata(addOn, "Version"))
local VERSION = v1*10000+v2*100+v3
---------------------------------------------------------------
-- Initialize addon tables
---------------------------------------------------------------
db.ICONS 	= {}
db.TEXTURE 	= {}
db.SECURE 	= {}
db.PANELS 	= {}
db.PLUGINS 	= {}

---------------------------------------------------------------
local function LoadDefaultBindings()
	ConsolePortConfig:Show()
	ConsolePortConfigContainerBinds:Default()
end	

local function ResetAll()
	if not InCombatLockdown() then
		ConsolePortBindingSet = nil
		ConsolePortUIFrames = nil
		ConsolePortSettings = nil
		ConsolePortUtility = nil
		ConsolePortMouse = nil
		ReloadUI()
	else
		print("|cffffe00aConsolePort|r:", SLASH.COMBAT)
	end
end

function ConsolePort:LoadSettings()

	local fullReset, selectController

	-----------------------------------------------------------
	-- Set/load addon settings
	-----------------------------------------------------------
	if not ConsolePortSettings then
		fullReset, selectController = true, true
		ConsolePortSettings = self:GetDefaultAddonSettings()
	end

	db.Settings = ConsolePortSettings

	-----------------------------------------------------------
	-- Load exported WoWmapper settings
	-----------------------------------------------------------
	if WoWmapper then
		db.Settings.calibration = db.table.copy(WoWmapper.Keys)
		for k, v in pairs(WoWmapper.Settings) do
			db.Settings[k] = v
		end
		db.Settings.type = db.Settings.forceController or db.Settings.type
		selectController = false
	end

	-----------------------------------------------------------
	-- Set/load binding table
	-----------------------------------------------------------

	if not ConsolePortBindingSet or not next(ConsolePortBindingSet) then
		NOBINDINGS = true
		ConsolePortBindingSet = {}
	end

	-----------------------------------------------------------
	-- Load controller splash if no preference exists
	-----------------------------------------------------------

	if selectController then
		NOBINDINGS = false
		self:SelectController()
	end

	self:LoadLookup()

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

	if not db.Settings.disableMenu then
		self:SetCustomMenu()
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
	local function ShowConfig() ConsolePortConfig:Show() end

	local instructions = {
		["type"] = {desc = SLASH.TYPE, func = ShowSplash},
		["config"] = {desc = SLASH.CONFIG, func = ShowConfig},
		["binds"] = {desc = SLASH.BINDS, func = ShowBinds},
		["resetall"] = {desc = SLASH.RESET, func = ResetAll},
	}

	SLASH_CONSOLEPORT1, SLASH_CONSOLEPORT2 = "/cp", "/consoleport"
	SlashCmdList["CONSOLEPORT"] = function(msg, editBox)
		if instructions[msg] then
			instructions[msg].func()
		else
			print( ( BINDING_NAME_CP_X_CENTER or "" ) .. " |cffffe00aConsolePort|r:")
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
			OnAccept = ResetAll,
			OnCancel = self.ClearPopup,
		}
		self:ShowPopup("CONSOLEPORT_CRITICALUPDATE")
	elseif ConsolePortSettings then
		local bindingPopup = {
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
		StaticPopupDialogs["CONSOLEPORT_IMPORTBINDINGS"] = bindingPopup
		if ConsolePortSettings.newController then
			bindingPopup.text = db.TUTORIAL.SLASH.NEWCONTROLLER
			self:ShowPopup("CONSOLEPORT_IMPORTBINDINGS")
			ConsolePortSettings.newController = nil
		elseif NOBINDINGS then
			bindingPopup.text = db.TUTORIAL.SLASH.NOBINDINGS
			self:ShowPopup("CONSOLEPORT_IMPORTBINDINGS")
		else
			StaticPopupDialogs["CONSOLEPORT_IMPORTBINDINGS"] = nil
		end
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