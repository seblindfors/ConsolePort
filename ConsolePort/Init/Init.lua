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
local CRITICALUPDATE, NOBINDINGS, NEWCALIBRATION
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
-- Popup functions 
---------------------------------------------------------------
local function LoadDefaultBindings()
	ConsolePortConfig:Show()
	ConsolePortConfigContainerBinds:Default()
	ConsolePort:CheckLoadedSettings()
end	

local function LoadWoWmapper()
	db.Settings.calibration = db.table.copy(WoWmapper.Keys)
	for k, v in pairs(WoWmapper.Settings) do
		db.Settings[k] = v
	end
	db.Settings.type = db.Settings.forceController or db.Settings.type
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

local function CancelPopup()
	ConsolePort:ClearPopup()
	ConsolePort:CheckLoadedSettings()
end

---------------------------------------------------------------

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
		if not db.Settings.calibration then
			LoadWoWmapper()
		else
			local cs, ws = db.Settings, WoWmapper.Settings
			local cb, wk = cs.calibration, WoWmapper.Keys
			for k, v in pairs(cb) do
				if wk[k] ~= v then
					NEWCALIBRATION = true
					break
				end
			end
			for k, v in pairs(ws) do
				if k ~= "type" and cs[k] ~= v then
					NEWCALIBRATION = true
					break
				end
			end
		end
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

	local function ShowSplash(...)
		local controller = ...
		controller = controller and strupper(controller)
		if db.Controllers[controller] then
			db.Settings.type = controller

			for key, value in pairs(db.Controllers[controller].Settings) do
				db.Settings[key] = value
			end

			db.Settings.newController = true
			db.Settings.forceController = controller

			PlaySound("GLUEENTERWORLDBUTTON")
			ReloadUI()
		else
			ConsolePort:SelectController()
		end
	end
	local function ShowBinds() ConsolePortConfig:OpenCategory(2) end
	local function ShowConfig() ConsolePortConfig:Show() end
	local function ShowCalibration() if ConsolePortConfig:IsVisible() then ConsolePortConfig:Hide() end ConsolePort:CalibrateController(true) end

	local instructions = {
		["type"] = {desc = SLASH.TYPE, func = ShowSplash},
		["config"] = {desc = SLASH.CONFIG, func = ShowConfig},
		["binds"] = {desc = SLASH.BINDS, func = ShowBinds},
		["recalibrate"] = {desc = SLASH.RECALIBRATE, func = ShowCalibration},
		["resetall"] = {desc = SLASH.RESET, func = ResetAll},
	}

	SLASH_CONSOLEPORT1, SLASH_CONSOLEPORT2 = "/cp", "/consoleport"
	SlashCmdList["CONSOLEPORT"] = function(msg, editBox)
		local inputs = {}
		for word in msg:gmatch("%w+") do
			inputs[#inputs + 1] = word
		end
		local funcName = inputs[1]
		if funcName and instructions[funcName] then
			tremove(inputs, 1)
			instructions[funcName].func(unpack(inputs))
		else
			print( "|T" .. ( db.TEXTURE.CP_X_CENTER or "" ) .. ":32:32:0:0|t |cffffe00aConsolePort|r:")
			for k, v in pairs(instructions) do
				print(format("|cff69ccf0/cp %s|r: %s", k, v.desc))
			end
		end
	end
	self.LoadSettings = nil
end

function ConsolePort:LoadActionBar()
	if db.Settings.actionBarTest and IsAddOnLoadOnDemand("ConsolePortBar") then
		LoadAddOn("ConsolePortBar")
	end
end

function ConsolePort:CheckLoadedSettings()
	local settings = ConsolePortSettings
    if 	(settings and not settings.version) or 
		(settings.version < VERSION and CRITICALUPDATE) then
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
			OnCancel = CancelPopup,
		}
		self:ShowPopup("CONSOLEPORT_CRITICALUPDATE")
	elseif settings then
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
			OnCancel = CancelPopup,
		}
		StaticPopupDialogs["CONSOLEPORT_IMPORTBINDINGS"] = bindingPopup
		if settings.newController then
			bindingPopup.text = db.TUTORIAL.SLASH.NEWCONTROLLER
			self:ShowPopup("CONSOLEPORT_IMPORTBINDINGS")
			settings.newController = nil
		elseif NOBINDINGS then
			NOBINDINGS = nil
			bindingPopup.text = db.TUTORIAL.SLASH.NOBINDINGS
			self:ShowPopup("CONSOLEPORT_IMPORTBINDINGS")
		elseif NEWCALIBRATION and ( not settings.id or settings.id ~= WoWmapper.Settings.id ) then
			NEWCALIBRATION = nil
			settings.id = WoWmapper.Settings.id
			StaticPopupDialogs["CONSOLEPORT_CALIBRATIONUPDATE"] = {
				text = db.TUTORIAL.SLASH.CALIBRATIONUPDATE,
				button1 = db.TUTORIAL.SLASH.ACCEPT,
				button2 = db.TUTORIAL.SLASH.CANCEL,
				showAlert = true,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
				enterClicksFirstButton = true,
				exclusive = true,
				OnAccept = function()
					LoadWoWmapper()
					ReloadUI()
				end,
				OnCancel = CancelPopup,
			}
			self:ShowPopup("CONSOLEPORT_CALIBRATIONUPDATE")
		end
	end
end

function ConsolePort:CreateActionButtons()
	for name in self:GetBindings() do
		for modifier in self:GetModifiers() do
			local secure = self:CreateSecureButton(name, modifier, self:GetUIControlKey(name))
			self:CreateConfigButton(name, modifier, secure)
		end
	end
	db.Binds.Rebind:Refresh()
	db.Binds.Rebind.ShortcutScroll:Refresh()
	self.CreateActionButtons = nil
end