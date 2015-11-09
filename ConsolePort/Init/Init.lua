local addOn, db = ...
-- Main
local ConsolePort = CreateFrame("FRAME", addOn)

local CRITICALUPDATE = false
local VERSION = gsub(GetAddOnMetadata(addOn, "Version"), "%.", "")
VERSION = tonumber(VERSION)

-- Tables
db.TEXTURE 	= {}
db.SECURE 	= {}
db.UIControls = {}
db.ButtonGuides  = {}

local KEY = db.KEY

-- Sort table by non-numeric key
db.pairsByKeys = function (t,f)
	local a = {}
	for n in pairs(t) do tinsert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local function iter()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

function ConsolePort:DB()
	return db
end

function ConsolePort:GetDefaultAddonSettings()
	return {
		["type"] = "PS4",
		["autoExtra"] = true,
		["flipMod"] = false,
		["version"] = VERSION,
	}
end

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

 function ConsolePort:LoadSettings()
    if not ConsolePortBindingSet then
    	ConsolePortBindingSet = self:GetDefaultBindingSet()
    end

    if not ConsolePortBindingButtons then
    	ConsolePortBindingButtons = self:GetDefaultBindingButtons()
    end

    if not ConsolePortMouse then
    	ConsolePortMouse = {
    		Events = self:GetDefaultMouseEvents(),
    		Cursor = self:GetDefaultMouseCursor(),
    	}
    end

    if not ConsolePortSettings then
    	ConsolePortSettings = self:GetDefaultAddonSettings()
    	self:CreateSplashFrame()
    end

    if not ConsolePortUIFrames then
    	ConsolePortUIFrames = self:GetDefaultUIFrames()
    end

    if 	self:CheckUnassignedBindings() then
    	self:CreateBindingWizard()
    end

    SLASH_CONSOLEPORT1, SLASH_CONSOLEPORT2 = "/cp", "/consoleport"
    local function SlashHandler(msg, editBox)
    	if msg == "type" or msg == "controller" then
    		ConsolePort:CreateSplashFrame()
    	elseif msg == "resetAll" and not InCombatLockdown() then
    		local bindings = ConsolePort:GetBindingNames()
    		for i, binding in pairs(bindings) do
    			local key1, key2 = GetBindingKey(binding)
    			if key1 then SetBinding(key1) end
    			if key2 then SetBinding(key2) end
    		end
    		SaveBindings(GetCurrentBindingSet())
    		ConsolePortBindingSet = ConsolePort:GetDefaultBindingSet()
    		ConsolePortBindingButtons = ConsolePort:GetDefaultBindingButtons()
    		ConsolePortSettings = nil
    		ReloadUI()
    	elseif 	msg == "resetAll" then print(db.TUTORIAL.SLASH.COMBAT)
    	elseif 	msg == "binds" or
    			msg == "binding" or
    			msg == "bindings" then
    		InterfaceOptionsFrame_OpenToCategory(db.Binds)
			InterfaceOptionsFrame_OpenToCategory(db.Binds)
    	else
    		local instruction = "|cff69ccf0%s|r: %s"
    		print("|cffffe00aConsolePort|r:")
    		print(format(instruction, "/cp type", db.TUTORIAL.SLASH.TYPE))
    		print(format(instruction, "/cp resetAll", db.TUTORIAL.SLASH.TYPE))
    		print(format(instruction, "/cp binds", db.TUTORIAL.SLASH.TYPE))
    	end
    end
    SlashCmdList["CONSOLEPORT"] = SlashHandler
end

function ConsolePort:CheckLoadedSettings()
    if 	(ConsolePortSettings and not ConsolePortSettings.version) or 
		(ConsolePortSettings.version < VERSION and CRITICALUPDATE) then
		StaticPopupDialogs["CONSOLEPORT_CRITICALUPDATE"] = {
			text = format(db.TUTORIAL.SLASH.CRITICALUPDATE, GetAddOnMetadata(addOn, "Version")),
			button1 = "Yes (recommended)",
			button2 = "Cancel",
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
	end
end

function ConsolePort:CreateMouseLooker()
	local MouseLook = CreateFrame("Frame", "ConsolePortMouseLook", UIParent)
--	MouseLook.hoverButton = MouseLook:CreateTexture(nil, "BACKGROUND")
	MouseLook:SetPoint("CENTER", p, 0, -50)
	MouseLook:SetWidth(70)
	MouseLook:SetHeight(180)
	MouseLook:SetAlpha(0)
	MouseLook:Show()
	return MouseLook
end

function ConsolePort:CreateActionButtons()
	local keys = ConsolePortBindingButtons
	local y = 1
	table.sort(keys)
	for name, key in db.pairsByKeys(keys) do
		self:CreateSecureButton(name, "_NOMOD",	key.action,	key.ui)
		self:CreateSecureButton(name, "_SHIFT", key.shift, 	key.ui)
		self:CreateSecureButton(name, "_CTRL",  key.ctrl, 	key.ui)
		self:CreateSecureButton(name, "_CTRLSH",key.ctrlsh, key.ui)
		self:CreateConfigButton(name, "_NOMOD", 0)
		self:CreateConfigButton(name, "_SHIFT", 1)
		self:CreateConfigButton(name, "_CTRL",  2)
		self:CreateConfigButton(name, "_CTRLSH",3)
	end
end

