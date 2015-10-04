local _, db = ...
local ctrlType = "PS4"
local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Textures\\Buttons\\%s\\%s"

local function AddTexture(BINDING, ctrlType)
	db.TEXTURE[strupper(BINDING)] = format(TEXTURE_PATH, ctrlType, BINDING)
end

setglobal("BINDING_NAME_CLICK ConsolePortExtraButton:LeftButton", "ConsolePort Extra") 

function ConsolePort:LoadControllerTheme()
	-- Specific controller strings
	local ctrlType = ConsolePortSettings and strupper(ConsolePortSettings.type) or ctrlType
	if 	ctrlType == "XBOX" then
		-- Config frame coords
		db.BINDINGS = {
			CP_R_LEFT				= {X = 318,	Y = -196},
			CP_R_UP					= {X = 346,	Y = -170},
			CP_R_RIGHT				= {X = 374,	Y = -196},
			CP_L_LEFT				= {X = 164,	Y = -260},
			CP_L_UP					= {X = 190,	Y = -240},
			CP_L_RIGHT				= {X = 214,	Y = -260},
			CP_L_DOWN				= {X = 190,	Y = -280},
			CP_TR1					= {X = 346,	Y = -143},
			CP_TR2					= {X = 346,	Y = -117},
			CP_X_OPTION				= {X = 346,	Y = -224},
			CP_L_OPTION				= {X = 218,	Y = -196},
			CP_C_OPTION				= {X = 242,	Y = -150},
			CP_R_OPTION				= {X = 274,	Y = -196},
		}
		-- Colors
		db.COLOR = {
			UP 						= 	"FFE74F",
			LEFT 					= 	"00A2FF",
			RIGHT					= 	"FA4451",
			DOWN 					= 	"52C14E",
		}
	else -- PS4
		-- Config frame coords
		db.BINDINGS = {
			CP_R_LEFT				= {X = 344,	Y = -198},
			CP_R_UP					= {X = 374,	Y = -166},
			CP_R_RIGHT				= {X = 406,	Y = -198}, 
			CP_L_LEFT				= {X = 85,	Y = -198},
			CP_L_UP					= {X = 110,	Y = -175},
			CP_L_RIGHT				= {X = 132,	Y = -198},
			CP_L_DOWN				= {X = 110,	Y = -220},
			CP_TR1					= {X = 374,	Y = -140},
			CP_TR2					= {X = 374,	Y = -114},
			CP_X_OPTION				= {X = 374,	Y = -228},
			CP_L_OPTION				= {X = 156,	Y = -160},
			CP_C_OPTION				= {X = 242,	Y = -256},
			CP_R_OPTION				= {X = 326,	Y = -160},
		}
		-- Colors
		db.COLOR = {
			UP 						= 	"62BBB2",
			LEFT 					= 	"D35280",
			RIGHT					= 	"D84E58",
			DOWN 					= 	"6882A1",
		}
	end
	-- Global binding strings
	BINDING_NAME_CP_L_UP		=	db[ctrlType].CP_L_UP
	BINDING_NAME_CP_L_DOWN		=	db[ctrlType].CP_L_DOWN
	BINDING_NAME_CP_L_LEFT		=	db[ctrlType].CP_L_LEFT
	BINDING_NAME_CP_L_RIGHT		=	db[ctrlType].CP_L_RIGHT
	BINDING_NAME_CP_TR1			=	db[ctrlType].CP_TR1
	BINDING_NAME_CP_TR2			=	db[ctrlType].CP_TR2
	BINDING_NAME_CP_R_UP		=	db[ctrlType].CP_R_UP
	BINDING_NAME_CP_X_OPTION	=	db[ctrlType].CP_X_OPTION
	BINDING_NAME_CP_R_LEFT		=	db[ctrlType].CP_R_LEFT
	BINDING_NAME_CP_R_RIGHT		=	db[ctrlType].CP_R_RIGHT
	BINDING_NAME_CP_L_OPTION	= 	db[ctrlType].CP_L_OPTION
	BINDING_NAME_CP_C_OPTION	=	db[ctrlType].CP_C_OPTION
	BINDING_NAME_CP_R_OPTION	= 	db[ctrlType].CP_R_OPTION
	-- Global binding headers
	BINDING_HEADER_CP_LEFT 		=	db[ctrlType].HEADER_CP_LEFT
	BINDING_HEADER_CP_RIGHT 	=	db[ctrlType].HEADER_CP_RIGHT
	BINDING_HEADER_CP_CENTER 	=	db[ctrlType].HEADER_CP_CENTER
	BINDING_HEADER_CP_TRIG 		=	db[ctrlType].HEADER_CP_TRIG
	-- Nametable
	db.NAME = db[ctrlType]
	-- Arrows
	AddTexture(db.NAME.CP_L_UP, ctrlType);
	AddTexture(db.NAME.CP_L_DOWN, ctrlType);
	AddTexture(db.NAME.CP_L_LEFT, ctrlType);
	AddTexture(db.NAME.CP_L_RIGHT, ctrlType);
	-- Action buttons
	AddTexture(db.NAME.CP_R_UP, ctrlType);
	AddTexture(db.NAME.CP_R_LEFT, ctrlType);
	AddTexture(db.NAME.CP_R_RIGHT, ctrlType);
	AddTexture(db.NAME.CP_X_OPTION, ctrlType);
	-- Options
	AddTexture(db.NAME.CP_L_OPTION, ctrlType);
	AddTexture(db.NAME.CP_C_OPTION, ctrlType);
	AddTexture(db.NAME.CP_R_OPTION, ctrlType);
	-- L/R
	db.TEXTURE.LONE   				= format(TEXTURE_PATH, ctrlType, "l1")
	db.TEXTURE.LTWO   				= format(TEXTURE_PATH, ctrlType, "l2")
	db.TEXTURE.LTHREE   			= format(TEXTURE_PATH, ctrlType, "l3")
	db.TEXTURE.RONE   				= format(TEXTURE_PATH, ctrlType, "r1")
	db.TEXTURE.RTWO   				= format(TEXTURE_PATH, ctrlType, "r2")
	db.TEXTURE.RTHREE				= format(TEXTURE_PATH, ctrlType, "r3")
	db.TEXTURE.VERTICAL				= "Interface\\AddOns\\ConsolePort\\Textures\\Buttons\\VERTICAL"
	db.TEXTURE.HORIZONTAL			= "Interface\\AddOns\\ConsolePort\\Textures\\Buttons\\HORIZONTAL"
	-- Click strings
	local ICON						= "|T%s:20:20:0:0|t |cFF%s%s|r"
	local SHIFT 					= format(ICON, db.TEXTURE.LONE, "6882A1", "%s")
	local RIGHT 					= format(ICON, db.TEXTURE[strupper(db.NAME.CP_R_RIGHT)], db.COLOR.RIGHT, "%s")
	local LEFT 						= format(ICON, db.TEXTURE[strupper(db.NAME.CP_R_LEFT)], db.COLOR.LEFT, "%s")
	local UP 						= format(ICON, db.TEXTURE[strupper(db.NAME.CP_R_UP)], db.COLOR.UP, "%s")
	db.CLICK = {
		COMPARE 					= format(SHIFT, db.TOOLTIP.CLICK.COMPARE),
		QUEST_TRACKER 				= format(RIGHT, db.TOOLTIP.CLICK.QUEST_TRACKER),
		USE_NOCOMBAT 				= format(RIGHT, db.TOOLTIP.CLICK.USE_NOCOMBAT),
		BUY 						= format(LEFT, 	db.TOOLTIP.CLICK.BUY),
		USE 						= format(LEFT, 	db.TOOLTIP.CLICK.USE),
		EQUIP						= format(LEFT, 	db.TOOLTIP.CLICK.EQUIP),
		SELL 						= format(LEFT, 	db.TOOLTIP.CLICK.SELL),
		QUEST_DETAILS 				= format(LEFT, 	db.TOOLTIP.CLICK.QUEST_DETAILS),
		PICKUP 						= format(UP, 	db.TOOLTIP.CLICK.PICKUP),
		CANCEL 						= format(UP, 	db.TOOLTIP.CLICK.CANCEL),
		STACK_BUY 					= format(UP, 	db.TOOLTIP.CLICK.STACK_BUY),
		ADD_TO_EXTRA				= format(UP, 	db.TOOLTIP.CLICK.ADD_TO_EXTRA),
	}
end