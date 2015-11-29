---------------------------------------------------------------
-- Theme.lua: Controller theme loader
---------------------------------------------------------------
-- Provides controller specific textures and tooltip lines.
-- Provides coordinates for drawing clickable binding buttons.

local _, db = ...
local init = true
local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Textures\\Buttons\\%s\\%s"
local TEXTURE_ESC = "|T%s:20:20:0:0|t"

setglobal("BINDING_NAME_CLICK ConsolePortExtraButton:LeftButton", db.CUSTOMBINDS.CP_EXTRABUTTON)
setglobal("BINDING_NAME_CLICK ConsolePortRaidCursorToggle:LeftButton", db.CUSTOMBINDS.CP_RAIDCURSOR)

local function LoadTooltipLines()
	local Left = ConsolePortMouse and ConsolePortMouse.Cursor.Left or "CP_R_RIGHT"
	local Right = ConsolePortMouse and ConsolePortMouse.Cursor.Right or "CP_R_LEFT"
	local Special = ConsolePortMouse and ConsolePortMouse.Cursor.Special or "CP_R_UP"
	-- Click strings
	local ICON				= "|T%s:20:20:0:0|t |cFF%s%s|r"
	local ShiftHold 		= format(ICON, db.TEXTURE.CP_TL1, "6882A1", "%s")
	local LeftClick 		= format(ICON, db.TEXTURE[Left], db.COLOR[gsub(Left, "CP_%w_", "")], "%s")
	local RightClick 		= format(ICON, db.TEXTURE[Right], db.COLOR[gsub(Right, "CP_%w_", "")], "%s")
	local SpecialClick		= format(ICON, db.TEXTURE[Special], db.COLOR[gsub(Special, "CP_%w_", "")], "%s")
	db.CLICK = {
		COMPARE 			= format(ShiftHold, 	db.TOOLTIP.CLICK.COMPARE),
		QUEST_TRACKER 		= format(LeftClick, 	db.TOOLTIP.CLICK.QUEST_TRACKER),
		USE_NOCOMBAT 		= format(LeftClick, 	db.TOOLTIP.CLICK.USE_NOCOMBAT),
		BUY 				= format(RightClick, 	db.TOOLTIP.CLICK.BUY),
		USE 				= format(RightClick, 	db.TOOLTIP.CLICK.USE),
		EQUIP				= format(RightClick, 	db.TOOLTIP.CLICK.EQUIP),
		SELL 				= format(RightClick, 	db.TOOLTIP.CLICK.SELL),
		QUEST_DETAILS 		= format(RightClick, 	db.TOOLTIP.CLICK.QUEST_DETAILS),
		PICKUP 				= format(SpecialClick, 	db.TOOLTIP.CLICK.PICKUP),
		CANCEL 				= format(SpecialClick, 	db.TOOLTIP.CLICK.CANCEL),
		STACK_BUY 			= format(SpecialClick, 	db.TOOLTIP.CLICK.STACK_BUY),
		ADD_TO_EXTRA		= format(SpecialClick, 	db.TOOLTIP.CLICK.ADD_TO_EXTRA),
	}
end

local function LoadTriggerTextures(ctrlType)
	-- Trigger textures
	db.TEXTURE.CP_TR1 = format(TEXTURE_PATH, ctrlType, ConsolePortSettings and ConsolePortSettings.trigger1 or "CP_TR1")
	db.TEXTURE.CP_TR2 = format(TEXTURE_PATH, ctrlType, ConsolePortSettings and ConsolePortSettings.trigger2 or "CP_TR2")
	db.TEXTURE.CP_TL1 = format(TEXTURE_PATH, ctrlType, ConsolePortSettings and ConsolePortSettings.shift 	or "CP_TL1")
	db.TEXTURE.CP_TL2 = format(TEXTURE_PATH, ctrlType, ConsolePortSettings and ConsolePortSettings.ctrl 	or "CP_TL2")
	db.TEXTURE.CP_TR3 = format(TEXTURE_PATH, ctrlType, "CP_TR3")
	db.TEXTURE.CP_TL3 = format(TEXTURE_PATH, ctrlType, "CP_TL3")
	-- Change global binding names
	BINDING_NAME_CP_TR1 = format(TEXTURE_ESC, db.TEXTURE.CP_TR1)
	BINDING_NAME_CP_TR2 = format(TEXTURE_ESC, db.TEXTURE.CP_TR2)
end

function ConsolePort:LoadControllerTheme()
	local ctrlType = ConsolePortSettings and strupper(ConsolePortSettings.type) or "PS4"
	if init then
		init = nil -- Don't repeat this section
		-- Controller specific
		if 	ctrlType == "XBOX" then
			-- Config frame coords
			db.BINDINGS = {
				CP_R_LEFT			= {X = 318,	Y = -196},
				CP_R_UP				= {X = 346,	Y = -170},
				CP_R_RIGHT			= {X = 374,	Y = -196},
				CP_L_LEFT			= {X = 164,	Y = -260},
				CP_L_UP				= {X = 190,	Y = -240},
				CP_L_RIGHT			= {X = 214,	Y = -260},
				CP_L_DOWN			= {X = 190,	Y = -280},
				CP_TR1				= {X = 346,	Y = -143},
				CP_TR2				= {X = 346,	Y = -117},
				CP_R_DOWN			= {X = 346,	Y = -224},
				CP_L_OPTION			= {X = 218,	Y = -196},
				CP_C_OPTION			= {X = 242,	Y = -150},
				CP_R_OPTION			= {X = 274,	Y = -196},
			}
			-- Colors
			db.COLOR = {
				UP 					= 	"FFE74F",
				LEFT 				= 	"00A2FF",
				RIGHT				= 	"FA4451",
				DOWN 				= 	"52C14E",
			}
		elseif 	ctrlType == "STEAM" then
			-- Config frame coords
			db.BINDINGS = { 
				CP_R_UP				= {X = 294,	Y = -223},
				CP_R_DOWN			= {X = 294,	Y = -279},
				CP_R_LEFT			= {X = 267,	Y = -252},
				CP_R_RIGHT			= {X = 323,	Y = -252},
				CP_L_UP				= {X = 122,	Y = -155},
				CP_L_DOWN			= {X = 122,	Y = -225},
				CP_L_LEFT			= {X = 90,	Y = -187},
				CP_L_RIGHT			= {X = 156,	Y = -187},
				CP_TR1				= {X = 360,	Y = -114},
				CP_TR2				= {X = 122,	Y = -114},
				CP_L_OPTION			= {X = 205,	Y = -187},
				CP_C_OPTION			= {X = 242,	Y = -187},
				CP_R_OPTION			= {X = 279,	Y = -187},
			}
			-- Colors
			db.COLOR = {
				UP 					= 	"FFE74F",
				LEFT 				= 	"00A2FF",
				RIGHT				= 	"FA4451",
				DOWN 				= 	"52C14E",
			}
		else -- PS4
			-- Config frame coords
			db.BINDINGS = {
				CP_R_LEFT			= {X = 344,	Y = -198},
				CP_R_UP				= {X = 374,	Y = -166},
				CP_R_RIGHT			= {X = 406,	Y = -198}, 
				CP_L_LEFT			= {X = 85,	Y = -198},
				CP_L_UP				= {X = 110,	Y = -175},
				CP_L_RIGHT			= {X = 132,	Y = -198},
				CP_L_DOWN			= {X = 110,	Y = -220},
				CP_TR1				= {X = 374,	Y = -140},
				CP_TR2				= {X = 374,	Y = -114},
				CP_R_DOWN			= {X = 374,	Y = -228},
				CP_L_OPTION			= {X = 156,	Y = -160},
				CP_C_OPTION			= {X = 242,	Y = -256},
				CP_R_OPTION			= {X = 326,	Y = -160},
			}
			-- Colors
			db.COLOR = {
				UP 					= 	"62BBB2",
				LEFT 				= 	"D35280",
				RIGHT				= 	"D84E58",
				DOWN 				= 	"6882A1",
			}
		end
		-- Global binding headers
		for name, description in pairs(db.HEADERS) do
			_G["BINDING_HEADER_"..name] = description
		end
		-- Invisible bindings
		for name, description in pairs(db.CUSTOMBINDS) do
			_G["BINDING_NAME_"..name] = description
		end
		-- Button textures
		for i, name in pairs(self:GetBindingNames()) do
			db.TEXTURE[name] = format(TEXTURE_PATH, ctrlType, name)
			_G["BINDING_NAME_"..name] = format(TEXTURE_ESC, db.TEXTURE[name])
		end
	end

	LoadTriggerTextures(ctrlType)
	LoadTooltipLines()
end