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
local ConsolePort = CreateFrame("FRAME", addOn)
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
db.TEXTURE 	= {}
db.SECURE 	= {}
db.PANELS 	= {}
---------------------------------------------------------------
-- Plug-in access to addon table
---------------------------------------------------------------
function ConsolePort:DB() return db end

local function ResetAllSettings()
	if not InCombatLockdown() then
		local bindings = ConsolePort:GetBindingNames()
		for i, binding in pairs(bindings) do
			local key1, key2 = GetBindingKey(binding)
			if key1 then SetBinding(key1) end
			if key2 then SetBinding(key2) end
		end
		SaveBindings(GetCurrentBindingSet())
		ConsolePortBindingSet = nil
		ConsolePortBindingButtons = nil
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
		self:CreateSplashFrame()
	end

	db.Settings = ConsolePortSettings

	self:LoadLookup()

	if not ConsolePortBindingSet then
		if not fullReset and not db.Settings.newController then
			newChar = true
		end
		ConsolePortBindingSet = {} --self:GetDefaultBindingSet()
	end

	-- Interface binding buttons and interface commands.
	if not ConsolePortBindingButtons then
		ConsolePortBindingButtons = self:GetDefaultUIBindingRefs()
	end

	if not ConsolePortMouse then
		ConsolePortMouse = {
			Events = self:GetDefaultMouseEvents(),
			Cursor = self:GetDefaultMouseCursor(),
		}
	end

	-- Use these frames in the virtual cursor stack
	if not ConsolePortUIFrames then
		ConsolePortUIFrames = self:GetDefaultUIFrames()
	end

	-- Use this table to populate radial action bar
	if not ConsolePortUtility then
		ConsolePortUtility = {}
	end

	db.Bindings = ConsolePortBindingSet
	db.Bindbtns = ConsolePortBindingButtons
	db.UIStack = ConsolePortUIFrames
	db.Mouse = ConsolePortMouse

	-- Compatibility fixes.
	if db.Settings.mouseOnCenter == nil then
		db.Settings.mouseOnCenter = true
	end

	if db.Settings.shift == nil or db.Settings.ctrl == nil then
		db.Settings.shift = "CP_TL1"
		db.Settings.ctrl = "CP_TL2"
	end

	-- Load the binding wizard if a button does not have a registered mock binding
	if 	self:CheckUnassignedBindings() then
		self:CreateBindingWizard()
	end


	-- Slash handler and stuff related to that
	local SLASH = db.TUTORIAL.SLASH

	local function ShowSplash() ConsolePort:CreateSplashFrame() end
	local function ShowBinds() for i=1, 2 do ConsolePortConfig:OpenCategory(2) end end

	local function ResetAll()
		if not InCombatLockdown() then
			local bindings = ConsolePort:GetBindingNames()
			for i, binding in pairs(bindings) do
				local key1, key2 = GetBindingKey(binding)
				if key1 then SetBinding(key1) end
				if key2 then SetBinding(key2) end
			end
			SaveBindings(GetCurrentBindingSet())
			ConsolePortBindingSet = nil --ConsolePort:GetDefaultBindingSet()
			ConsolePortBindingButtons = nil -- ConsolePort:GetDefaultUIBindingRefs()
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
	local function SlashHandler(msg, editBox)
		if instructions[msg] then
			instructions[msg].func()
		else
			print("|cffffe00aConsolePort|r:")
			for k, v in pairs(instructions) do
				print(format("|cff69ccf0/cp %s|r: %s", k, v.desc))
			end
		end
	end
	SlashCmdList["CONSOLEPORT"] = SlashHandler
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
		}
		StaticPopup_Show("CONSOLEPORT_CRITICALUPDATE")
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
		}
		StaticPopup_Show("CONSOLEPORT_NEWCONTROLLER")
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
		}
		StaticPopup_Show("CONSOLEPORT_NEWCHARACTER")
	end
	self.CheckLoadedSettings = nil
end

function ConsolePort:CreateActionButtons()
	local keys = ConsolePortBindingButtons
	local buttons = db.Controllers[db.Settings.type].Buttons
	for _, name in pairs(buttons) do
		local key = keys[name]
		local ui = key and key.ui
		self:CreateSecureButton(name, "_NOMOD",	 key and key.action,	ui)
		self:CreateSecureButton(name, "_SHIFT",  key and key.shift, 	ui)
		self:CreateSecureButton(name, "_CTRL",   key and key.ctrl, 		ui)
		self:CreateSecureButton(name, "_CTRLSH", key and key.ctrlsh, 	ui)
		self:CreateConfigButton(name, "_NOMOD", 0)
		self:CreateConfigButton(name, "_SHIFT", 1)
		self:CreateConfigButton(name, "_CTRL",  2)
		self:CreateConfigButton(name, "_CTRLSH",3)
	end
	self.CreateActionButtons = nil
end

-- hooksecurefunc("CreateFrame", function(...) 
-- 	local type, name, parent, template = ...
-- 	if template and template:match("SecureActionButtonTemplate") then
-- 		print(name, parent, template)
-- 	end
-- end)