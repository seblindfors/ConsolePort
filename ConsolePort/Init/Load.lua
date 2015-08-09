local _, db = ...;
local type = "PS4\\";
local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Buttons\\";
local function AddTexture(BINDING, TYPE)
	db.TEXTURE[strupper(BINDING)] = TEXTURE_PATH..TYPE..BINDING;
end
-- Init string tables
db.TEXTURE 	= {};
db.COLOR 	= {};
db.CLICK 	= {};
db.TUTORIAL = {};
-- Guide button measurements
db.GUIDE = {
	BORDER_S_SMALL 			= 56,
	BORDER_X_SMALL 			= -4.75,
	BORDER_Y_SMALL 			= 3.6,
	BUTTON_S_SMALL 			= 24,
	BUTTON_LEFT_SMALL_X 	= -16,
	BUTTON_LEFT_SMALL_Y 	= 0,
	BUTTON_RIGHT_SMALL_X 	= 16,
	BUTTON_RIGHT_SMALL_Y 	= 0,
	BUTTON_CENTER_SMALL_X 	= 0,
	BUTTON_CENTER_SMALL_Y 	= 0,
	BUTTON_BOTTOM_SMALL_X 	= 0,
	BUTTON_BOTTOM_SMALL_Y 	= -20,
	BORDER_S_LARGE 			= 70,
	BORDER_X_LARGE 			= -5,
	BORDER_Y_LARGE 			= 3.2,
	BUTTON_S_LARGE 			= 32,
	BUTTON_LEFT_LARGE_X 	= -26,
	BUTTON_LEFT_LARGE_Y 	= 0,
	BUTTON_RIGHT_LARGE_X 	= 26,
	BUTTON_RIGHT_LARGE_Y 	= 0,
	BUTTON_CENTER_LARGE_X 	= 0,
	BUTTON_CENTER_LARGE_Y 	= 0,
	BUTTON_BOTTOM_SMALL_X 	= 0,
	BUTTON_BOTTOM_SMALL_Y 	= -28
}
-- Interaction keys
db.KEY = {
	CIRCLE  				= 1;
	SQUARE 					= 2;
	TRIANGLE 				= 3;
	UP						= 4;
	DOWN					= 5;
	LEFT					= 6;
	RIGHT					= 7;
	PREPARE 				= 8;
	STATE_UP 				= "up";
	STATE_DOWN				= "down";
}
-- Local binding strings
db.NAME = {
	CP_L_UP					=	"Up",
	CP_L_DOWN				=	"Down",
	CP_L_LEFT				=	"Left",
	CP_L_RIGHT				=	"Right",
	CP_TR1					=	"Trigger 1",
	CP_TR2					=	"Trigger 2"

}
-- Global binding headers
BINDING_HEADER_CP_LEFT 		=	"Arrow pad";
BINDING_HEADER_CP_RIGHT 	=	"Buttons";
BINDING_HEADER_CP_CENTER 	=	"Center buttons";
BINDING_HEADER_CP_TRIG 		=	"Triggers";
-- Global binding strings
BINDING_NAME_CP_L_UP		=	"Up";		
BINDING_NAME_CP_L_DOWN		=	"Down";
BINDING_NAME_CP_L_LEFT		=	"Left";
BINDING_NAME_CP_L_RIGHT		=	"Right";
BINDING_NAME_CP_TR1			=	"Trigger 1";
BINDING_NAME_CP_TR2			=	"Trigger 2";
setglobal("BINDING_NAME_CLICK ConsolePortExtraButton:LeftButton", "ConsolePort Extra"); 

db.SPLASH_LEFT = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashLeft";
db.SPLASH_RIGHT = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashRight";
db.SPLASH_BOTTOM = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashBottom";
db.BUTTON_WRAP = "Interface\\AddOns\\ConsolePort\\Graphic\\ButtonWrapper";
db.BUTTON_HILITE = "Interface\\AddOns\\ConsolePort\\Graphic\\ButtonWrapperHiLite";

local f = CreateFrame("FRAME", "ConsolePort");
function ConsolePort:LoadStrings()
	-- Specific controller strings
	if (ConsolePortSettings and ConsolePortSettings.type == "Xbox") then
		type = "Xbox\\";
		-- Binding strings
		BINDING_NAME_CP_R_UP		=	"Y";
		BINDING_NAME_CP_X_OPTION	=	"A";
		BINDING_NAME_CP_R_LEFT		=	"X";
		BINDING_NAME_CP_R_RIGHT		=	"B";
		BINDING_NAME_CP_L_OPTION	= 	"Back";
		BINDING_NAME_CP_C_OPTION	=	"Guide";
		BINDING_NAME_CP_R_OPTION	= 	"Start";
		-- Button name strings
		db.NAME.CP_R_UP				=	"Y";
		db.NAME.CP_X_OPTION			=	"A";
		db.NAME.CP_R_LEFT			=	"X";
		db.NAME.CP_R_RIGHT			=	"B";
		db.NAME.CP_L_OPTION			= 	"Back";
		db.NAME.CP_C_OPTION			=	"Guide";
		db.NAME.CP_R_OPTION			= 	"Start";
		-- Colors
		db.COLOR = {
			UP 		= 	"FFE74F",
			LEFT 	= 	"00A2FF",
			RIGHT	= 	"FA4451",
			DOWN 	= 	"52C14E",
		}
		-- Textures
	else
		-- Binding strings (default: PlayStation)
		BINDING_NAME_CP_R_UP		=	"Triangle";
		BINDING_NAME_CP_X_OPTION	=	"Cross";
		BINDING_NAME_CP_R_LEFT		=	"Square";
		BINDING_NAME_CP_R_RIGHT		=	"Circle";
		BINDING_NAME_CP_L_OPTION	= 	"Share";
		BINDING_NAME_CP_C_OPTION	=	"PS";
		BINDING_NAME_CP_R_OPTION	= 	"Options";
		-- Button name strings (default: PlayStation)
		db.NAME.CP_R_UP				=	"Triangle";
		db.NAME.CP_X_OPTION			=	"Cross";
		db.NAME.CP_R_LEFT			=	"Square";
		db.NAME.CP_R_RIGHT			=	"Circle";
		db.NAME.CP_L_OPTION			= 	"Share";
		db.NAME.CP_C_OPTION			=	"PS";
		db.NAME.CP_R_OPTION			= 	"Options";
		-- Colors
		db.COLOR = {
			UP 		= 	"62BBB2",
			LEFT 	= 	"D35280",
			RIGHT	= 	"D84E58",
			DOWN 	= 	"6882A1",
		}
	end
	-- Global config variables
	db.BIND_TARGET 				= false;
	db.CONF_BUTTON 				= nil;
	db.CP 						= "CP";
	db.CONF 					= "_CONF";
	db.CONFBG 					= "_CONF_BG";
	db.NOMOD 					= "_NOMOD";
	db.SHIFT 					= "_SHIFT";
	db.CTRL 					= "_CTRL";
	db.CTRLSH 					= "_CTRLSH";
	-- Arrows
	AddTexture(db.NAME.CP_L_UP, type);
	AddTexture(db.NAME.CP_L_DOWN, type);
	AddTexture(db.NAME.CP_L_LEFT, type);
	AddTexture(db.NAME.CP_L_RIGHT, type);
	-- Action buttons
	AddTexture(db.NAME.CP_R_UP, type);
	AddTexture(db.NAME.CP_R_LEFT, type);
	AddTexture(db.NAME.CP_R_RIGHT, type);
	AddTexture(db.NAME.CP_X_OPTION, type);
	-- Options
	AddTexture(db.NAME.CP_L_OPTION, type);
	AddTexture(db.NAME.CP_C_OPTION, type);
	AddTexture(db.NAME.CP_R_OPTION, type);
	-- L/R
	db.TEXTURE.LONE   		= TEXTURE_PATH..type.."l1";
	db.TEXTURE.LTWO   		= TEXTURE_PATH..type.."l2";
	db.TEXTURE.LTHREE   	= TEXTURE_PATH..type.."l3";
	db.TEXTURE.RONE   		= TEXTURE_PATH..type.."r1";
	db.TEXTURE.RTWO   		= TEXTURE_PATH..type.."r2";
	db.TEXTURE.RTHREE		= TEXTURE_PATH..type.."r3";
	-- Click strings
	local POINTS 			= ":20:20:0:0";
	local _SHIFT 			= "|T"..db.TEXTURE.LONE..POINTS.."|t |cFF6882A1";
	local _RIGHT 			= "|T"..db.TEXTURE[strupper(db.NAME.CP_R_RIGHT)]..POINTS.."|t |cFF"..db.COLOR.RIGHT;
	local _LEFT 			= "|T"..db.TEXTURE[strupper(db.NAME.CP_R_LEFT)]..POINTS.."|t |cFF"..db.COLOR.LEFT;
	local _UP				= "|T"..db.TEXTURE[strupper(db.NAME.CP_R_UP)]..POINTS.."|t |cFF"..db.COLOR.UP;
	db.CLICK = {
		COMPARE 			= _SHIFT.."Compare|r",
		USE 				= _RIGHT.."Use|r",
		QUEST_TRACKER 		= _RIGHT.."Set current quest|r",
		USE_NOCOMBAT 		= _RIGHT.."Use (out of combat)|r",
		SELL 				= _RIGHT.."Sell|r",
		BUY 				= _RIGHT.."Buy|r",
		LOOT				= _RIGHT.."Loot|r",
		EQUIP				= _RIGHT.."Equip|r",
		REPLACE				= _RIGHT.."Replace|r",
		GLYPH_CAST			= _RIGHT.."Use glyph|r",
		TALENT 				= _RIGHT.."Learn talent|r",
		TAKETAXI 			= _RIGHT.."Fly to location|r",
		PICKUP 				= _LEFT.."Pick up|r",
		QUEST_DETAILS 		= _LEFT.."View quest details|r",
		CANCEL 				= _UP.."Cancel|r",
		STACK_BUY 			= _UP.."Buy a different amount|r",
		ADD_TO_EXTRA		= _UP.."Bind|r",
	}
	-- Tutorial strings
	local tutorialCursor 	= "|TInterface\\AddOns\\ConsolePort\\Graphic\\TutorialCursor:64:128:0:0|t";
	local exampleTexture 	= db.TEXTURE.Y or db.TEXTURE.TRIANGLE;
	local exampleCombo 		= "|T"..db.TEXTURE.LONE..":20:20:0:0|t".."|T"..exampleTexture..":20:20:0:0|t";
	db.TUTORIAL.BIND 		= {
		IMPORT 	= "You can import bindings from your other characters here. Your current bindings will be exported when you log out.\nPress |cFFFFD200Okay|r to apply.",
		DYNAMIC = "       |cFFFFD200[Rebind Instructions]|r\n\n1. Mouse over an action button\n2.  Press a button combination\n"..tutorialCursor.."+   "..exampleCombo,
		STATIC 	= "       |cFFFFD200[Rebind Instructions]|r\n\n1.   Click on a combination\n2. Choose action from the list\n",
		MOD 	= "              |cFFFFD200[Modifiers]|r\nThese columns represent all button combinations. Every button in the list to the left\nhas four combinations each.",
		ACTION 	= "          |cFFFFD200[Action Buttons]|r\nThese buttons can be used for abilities, macros and items. They are also used to control the interface.",
		OPTION 	= "          |cFFFFD200[Option Buttons]|r\nThese buttons can be used to perform any action defined in the regular key bindings.",
	}
end

-- debug tool
function ConsolePort:G()
	return db
end