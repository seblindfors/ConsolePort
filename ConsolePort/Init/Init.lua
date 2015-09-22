local _, db = ...
local KEY = db.KEY
local BIND_TARGET 	 	= false
local CONF_BUTTON 		= nil
local CP 				= "CP"
local CONF 				= "_CONF"
local CONFBG 			= "_CONF_BG"
local GUIDE 			= "_GUIDE"
local NOMOD				= "_NOMOD"
local SHIFT 			= "_SHIFT"
local CTRL 				= "_CTRL"
local CTRLSH 			= "_CTRLSH"

db.ButtonGuides 		 = {}

-- Sort table by non-numeric key
db.pairsByKeys = function (t,f)
	local a = {}
	for n in pairs(t) do tinsert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

function ConsolePort:GetBindingNames()
	return {
		"CP_R_LEFT",
		"CP_R_UP",
		"CP_R_RIGHT",
		"CP_L_LEFT",
		"CP_L_UP",
		"CP_L_RIGHT",
		"CP_L_DOWN",
		"CP_TR1",
		"CP_TR2",
		"CP_X_OPTION",
		"CP_L_OPTION",
		"CP_C_OPTION",
		"CP_R_OPTION"
	}
end

function ConsolePort:GetBindingButtons()
	return {
		"CP_R_LEFT",
		"CP_R_UP",
		"CP_R_RIGHT",
		"CP_L_LEFT",
		"CP_L_UP",
		"CP_L_RIGHT",
		"CP_L_DOWN",
		"CP_TR1",
		"CP_TR2",
	}
end

function ConsolePort:GetDefaultBindingSet()
	local bindingSet = {}
	local Buttons = ConsolePort:GetBindingNames()
	for _, Button in ipairs(Buttons) do
		bindingSet[Button] = ConsolePort:GetDefaultBinding(Button)
	end
	return bindingSet
end

function ConsolePort:GetDefaultBindingButtons()
	local bindingSet = {}
	local Buttons = ConsolePort:GetBindingButtons()
	for _, Button in ipairs(Buttons) do
		bindingSet[Button] = ConsolePort:GetDefaultButton(Button)
	end
	return bindingSet
end


function ConsolePort:GetDefaultBinding(key)
	local nomod
	local modshift
	local modctrl
	local shiftctrl
	-- Right side
	if 		key == "CP_X_OPTION" then
		nomod 		= "JUMP"
		modshift 	= "TARGETNEARESTENEMY"
		modctrl  	= "FOCUSTARGET"
		shiftctrl 	= "TARGETFOCUS"
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
		modshift 	= "NEXTVIEW"
		modctrl 	= "PREVVIEW"
		shiftctrl 	= "CAMERAZOOMOUT"
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
	local command 	= nil
	local nomod 	= nil
	local modshift 	= nil
	local ctrl 		= nil
	local modshiftctrl = nil
	if 		key == "CP_R_LEFT" then
		command		= KEY.SQUARE
		nomod 		= "ActionButton1"
		modshift 	= "ActionButton6"
		modctrl 	= "MultiBarBottomLeftButton1"
		shiftctrl 	= "MultiBarBottomLeftButton6"
	elseif key == "CP_R_UP" then
		command		= KEY.TRIANGLE
		nomod 		= "ActionButton2"
		modshift 	= "ActionButton7"
		modctrl 	= "MultiBarBottomLeftButton2"
		shiftctrl 	= "MultiBarBottomLeftButton7"
	elseif key == "CP_R_RIGHT" then
		command 	= KEY.CIRCLE
		nomod 		= "ActionButton3"
		modshift 	= "ActionButton8"
		modctrl 	= "MultiBarBottomLeftButton3"
		shiftctrl 	= "MultiBarBottomLeftButton8"
	-- Triggers
	elseif key == "CP_TR1" then
		nomod 		= "ActionButton4"
		modshift 	= "ActionButton9"
		modctrl 	= "MultiBarBottomLeftButton4"
		shiftctrl 	= "MultiBarBottomLeftButton9"
	elseif key == "CP_TR2" then
		nomod 		= "ActionButton5"
		modshift 	= "ActionButton10"
		modctrl 	= "MultiBarBottomLeftButton5"
		shiftctrl 	= "MultiBarBottomLeftButton10"
	-- Left side
	elseif key == "CP_L_DOWN" then
		command		= KEY.DOWN
		nomod 		= "ActionButton11"
		modshift 	= "MultiBarBottomRightButton4"
		modctrl  	= "MultiBarBottomRightButton8"
		shiftctrl	= "MultiBarBottomRightButton12"
	elseif key == "CP_L_LEFT" then
		command		= KEY.LEFT
		nomod 		= "MultiBarBottomLeftButton11"
		modshift 	= "MultiBarBottomRightButton1"
		modctrl 	= "MultiBarBottomRightButton5"
		shiftctrl 	= "MultiBarBottomRightButton9"
	elseif key == "CP_L_UP" then
		command		= KEY.UP
		nomod 		= "MultiBarBottomLeftButton12"
		modshift 	= "MultiBarBottomRightButton2"
		modctrl 	= "MultiBarBottomRightButton6"
		shiftctrl 	= "MultiBarBottomRightButton10"
	elseif key == "CP_L_RIGHT" then
		command		= KEY.RIGHT
		nomod 		= "ActionButton12"
		modshift 	= "MultiBarBottomRightButton3"
		modctrl 	= "MultiBarBottomRightButton7"
		shiftctrl 	= "MultiBarBottomRightButton11"
	end
	local binding = {
		ui 		= command,
		action 	= nomod,
		shift 	= modshift,
		ctrl 	= modctrl,
		ctrlsh 	= shiftctrl
	}
	return binding
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
		["LOOT_CLOSED"] = true
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
	local t = {}
	t.type = "PS4"
	t.cam = false
	t.autoExtra = true
	return t
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
        	elseif 	msg == "resetAll" then print("Error: Cannot reset addon in combat!")
        	elseif 	msg == "binds" or
        			msg == "binding" or
        			msg == "bindings" then
        		InterfaceOptionsFrame_OpenToCategory(db.Binds)
				InterfaceOptionsFrame_OpenToCategory(db.Binds)
			elseif 	msg == "test" and _G["ConsolePortUI"] then
				_G["ConsolePortUI"]:Toggle()
        	else
        		print("Console Port:")
        		print("/cp type: Change controller type")
        		print("/cp resetAll: Full addon reset")
        		print("/cp binds: Open binding menu")
        	end
        end
        SlashCmdList["CONSOLEPORT"] = SlashHandler
 end


function ConsolePort:CreateMouseLooker()
	local MouseLook = CreateFrame("Frame", "ConsolePortMouseLook", UIParent)
	MouseLook.hoverButton = MouseLook:CreateTexture(nil, "BACKGROUND")
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
		if key.action 	then 
			self:CreateSecureButton(name, 	NOMOD,	key.action,	key.ui)
			self:CreateConfigButton(name, 	NOMOD, 0)
		end
		if key.shift 	then
			self:CreateSecureButton(name,	SHIFT, 	key.shift, 	key.ui)
			self:CreateConfigButton(name, 	SHIFT, 1)
		end
		if key.ctrl 	then
			self:CreateSecureButton(name,	CTRL,  	key.ctrl, 	key.ui)
			self:CreateConfigButton(name,	CTRL,  2)
		end
		if key.ctrlsh 	then
			self:CreateSecureButton(name, 	CTRLSH,	key.ctrlsh, key.ui)
			self:CreateConfigButton(name,	CTRLSH, 3)
		end
	end
end