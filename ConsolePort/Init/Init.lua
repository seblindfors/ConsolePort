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

-- Interaction keys
db.KEY = {
	CIRCLE  						= 1,
	SQUARE 							= 2,
	TRIANGLE 						= 3,
	UP								= 4,
	DOWN							= 5,
	LEFT							= 6,
	RIGHT							= 7,
	CROSS 							= 8,
	SHARE 							= 9,
	OPTIONS 						= 10,
	CENTER 							= 11,
	PREPARE 						= 12,
	STATE_UP 						= "up",
	STATE_DOWN						= "down",
}

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

-- debug tool
function ConsolePort:G()
	return db
end

function ConsolePort:GetBindingNames()
	return {
		"CP_R_UP",
		"CP_R_DOWN",
		"CP_R_LEFT",
		"CP_R_RIGHT",
		"CP_L_LEFT",
		"CP_L_UP",
		"CP_L_RIGHT",
		"CP_L_DOWN",
		"CP_TR1",
		"CP_TR2",
		"CP_L_OPTION",
		"CP_C_OPTION",
		"CP_R_OPTION",
	}
end

function ConsolePort:GetDefaultBindingSet()
	local bindingSet = {}
	local Buttons = self:GetBindingNames()
	for _, Button in ipairs(Buttons) do
		bindingSet[Button] = self:GetDefaultBinding(Button)
	end
	return bindingSet
end

function ConsolePort:GetDefaultBindingButtons()
	local bindingSet = {}
	for _, Button in ipairs(self:GetBindingNames()) do
		bindingSet[Button] = self:GetDefaultButton(Button)
	end
	return bindingSet
end


function ConsolePort:GetDefaultBinding(key)
	local nomod, modshift, modctrl, shiftctrl
	-- Right side
	if 		key == "CP_R_DOWN" then
		nomod 		= "JUMP"
		modshift 	= "TARGETNEARESTENEMY"
		modctrl  	= "INTERACTMOUSEOVER"
		shiftctrl 	= "TARGETPREVIOUSENEMY"
	-- Utility Buttons
	elseif 	key == "CP_L_OPTION" then
		nomod 		= "OPENALLBAGS"
		modshift 	= "TOGGLECHARACTER0"
		modctrl 	= "TOGGLESPELLBOOK"
		shiftctrl 	= "TOGGLETALENTS"
	elseif 	key == "CP_C_OPTION" then
		nomod 		= "TOGGLEGAMEMENU"
		modshift 	= "EXTRAACTIONBUTTON1"
		modctrl 	= "TOGGLEAUTORUN"
		shiftctrl 	= "FOLLOWTARGET"
	elseif 	key == "CP_R_OPTION" then
		nomod 		= "TOGGLEWORLDMAP"
		modshift 	= "CP_CAMZOOMOUT"
		modctrl 	= "CP_CAMZOOMIN"
		shiftctrl 	= "SETVIEW1"
	-- Actionbuttons
	elseif 	key == "CP_R_LEFT" 	or 
			key == "CP_R_UP" 	or
			key == "CP_R_RIGHT" or
			key == "CP_TR1" 	or
			key == "CP_TR2" 	or 
			key == "CP_L_DOWN" 	or 
			key == "CP_L_LEFT" 	or 
			key == "CP_L_UP" 	or 
			key == "CP_L_RIGHT" then
		nomod 		= "CLICK "..key.."_NOMOD:LeftButton"
		modshift 	= "CLICK "..key.."_SHIFT:LeftButton"
		modctrl 	= "CLICK "..key.."_CTRL:LeftButton"
		shiftctrl 	= "CLICK "..key.."_CTRLSH:LeftButton"
	end
	local binding = {
		action 	= nomod,
		shift 	= modshift,
		ctrl 	= modctrl,
		ctrlsh 	= shiftctrl
	}
	return binding
end

function ConsolePort:GetDefaultButton(key)
	local keys = {
		CP_R_UP = 	{
			ui			= KEY.TRIANGLE,
			action 		= "ActionButton2",
			shift 		= "ActionButton7",
			ctrl 		= "MultiBarBottomLeftButton2",
			ctrlsh 		= "MultiBarBottomLeftButton7",
		},
		CP_R_DOWN = {
			ui 			= KEY.CROSS,
		},
		CP_R_LEFT = {
			ui			= KEY.SQUARE,
			action 		= "ActionButton1",
			shift 		= "ActionButton6",
			ctrl 		= "MultiBarBottomLeftButton1",
			ctrlsh 		= "MultiBarBottomLeftButton6",
		},
		CP_R_RIGHT = {
			ui 			= KEY.CIRCLE,
			action 		= "ActionButton3",
			shift 		= "ActionButton8",
			ctrl 		= "MultiBarBottomLeftButton3",
			ctrlsh 		= "MultiBarBottomLeftButton8",
		},
		-- Triggers
		CP_TR1 =	{
			action 		= "ActionButton4",
			shift 		= "ActionButton9",
			ctrl 		= "MultiBarBottomLeftButton4",
			ctrlsh 		= "MultiBarBottomLeftButton9",
		},
		CP_TR2 = 	{
			action 		= "ActionButton5",
			shift 		= "ActionButton10",
			ctrl 		= "MultiBarBottomLeftButton5",
			ctrlsh 		= "MultiBarBottomLeftButton10",
		},
		-- Left side
		CP_L_UP = {
			ui			= KEY.UP,
			action 		= "MultiBarBottomLeftButton12",
			shift 		= "MultiBarBottomRightButton2",
			ctrl 		= "MultiBarBottomRightButton6",
			ctrlsh 		= "MultiBarBottomRightButton10",
		},
		CP_L_DOWN = {
			ui			= KEY.DOWN,
			action 		= "ActionButton11",
			shift 		= "MultiBarBottomRightButton4",
			ctrl  		= "MultiBarBottomRightButton8",
			ctrlsh		= "MultiBarBottomRightButton12",
		},
		CP_L_LEFT = {
			ui			= KEY.LEFT,
			action 		= "MultiBarBottomLeftButton11",
			shift 		= "MultiBarBottomRightButton1",
			ctrl 		= "MultiBarBottomRightButton5",
			ctrlsh 		= "MultiBarBottomRightButton9",
		},
		CP_L_RIGHT = {
			ui			= KEY.RIGHT,
			action 		= "ActionButton12",
			shift 		= "MultiBarBottomRightButton3",
			ctrl 		= "MultiBarBottomRightButton7",
			ctrlsh 		= "MultiBarBottomRightButton11",
		},		
		CP_L_OPTION = {
			ui 			= KEY.SHARE,
		},
		CP_C_OPTION = {
			ui 			= KEY.CENTER,
		},
		CP_R_OPTION = {
			ui 			= KEY.OPTIONS,
		},
	}
	return keys[key]
end


local function GetDefaultMouseEvents()
	return {
		["PLAYER_STARTED_MOVING"] = false,
		["PLAYER_TARGET_CHANGED"] = true,
		["CURRENT_SPELL_CAST_CHANGED"] = true,
		["GOSSIP_SHOW"] = true,
		["GOSSIP_CLOSED"] = true,
		["MERCHANT_SHOW"] = true,
		["MERCHANT_CLOSED"] = true,
		["TAXIMAP_OPENED"] = true,
		["TAXIMAP_CLOSED"] = true,
		["QUEST_GREETING"] = true,
		["QUEST_DETAIL"] = true,
		["QUEST_PROGRESS"] = true,
		["QUEST_COMPLETE"] = true,
		["QUEST_FINISHED"] = true,
		["QUEST_AUTOCOMPLETE"] = true,
		["SHIPMENT_CRAFTER_OPENED"] = true,
		["SHIPMENT_CRAFTER_CLOSED"] = true,
		["LOOT_OPENED"] = true,
		["LOOT_CLOSED"] = true,
	}
end

local function GetDefaultMouseCursor()
	return {
		Left 	= "CP_R_RIGHT",
		Right 	= "CP_R_LEFT",
		Special = "CP_R_UP",
		Scroll 	= "CP_TR3",
	}
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
    		Events = GetDefaultMouseEvents(),
    		Cursor = GetDefaultMouseCursor(),
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

