local _, G = ...;
local type = "PS4\\";
local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Buttons\\";
local function AddTexture(BINDING, TYPE)
	G.TEXTURE[string.upper(BINDING)] = TEXTURE_PATH..TYPE..BINDING;
end
-- Init string tables
G.GUIDE 	= {};
G.TEXTURE 	= {};
G.NAME 		= {};
G.CLICK 	= {};
G.TUTORIAL 	= {};
-- Small guide button measurements
G.GUIDE.BORDER_S_SMALL 			= 56;
G.GUIDE.BORDER_X_SMALL 			= -4.75;
G.GUIDE.BORDER_Y_SMALL 			= 3.6;
G.GUIDE.BUTTON_S_SMALL 			= 24;
G.GUIDE.BUTTON_LEFT_SMALL_X 	= -16;
G.GUIDE.BUTTON_LEFT_SMALL_Y 	= 0;
G.GUIDE.BUTTON_RIGHT_SMALL_X 	= 16;
G.GUIDE.BUTTON_RIGHT_SMALL_Y 	= 0;
G.GUIDE.BUTTON_CENTER_SMALL_X 	= 0;
G.GUIDE.BUTTON_CENTER_SMALL_Y 	= 0;
G.GUIDE.BUTTON_BOTTOM_SMALL_X 	= 0;
G.GUIDE.BUTTON_BOTTOM_SMALL_Y 	= -20;
-- Large guide button measurements
G.GUIDE.BORDER_S_LARGE 			= 70;
G.GUIDE.BORDER_X_LARGE 			= -5;
G.GUIDE.BORDER_Y_LARGE 			= 3.2;
G.GUIDE.BUTTON_S_LARGE 			= 32;
G.GUIDE.BUTTON_LEFT_LARGE_X 	= -26;
G.GUIDE.BUTTON_LEFT_LARGE_Y 	= 0;
G.GUIDE.BUTTON_RIGHT_LARGE_X 	= 26;
G.GUIDE.BUTTON_RIGHT_LARGE_Y 	= 0;
G.GUIDE.BUTTON_CENTER_LARGE_X 	= 0;
G.GUIDE.BUTTON_CENTER_LARGE_Y 	= 0;
G.GUIDE.BUTTON_BOTTOM_SMALL_X 	= 0;
G.GUIDE.BUTTON_BOTTOM_SMALL_Y 	= -28;
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
-- Local binding strings
G.NAME.CP_L_UP				=	"Up";
G.NAME.CP_L_DOWN			=	"Down";
G.NAME.CP_L_LEFT			=	"Left";
G.NAME.CP_L_RIGHT			=	"Right";
G.NAME.CP_TR1				=	"Trigger 1";
G.NAME.CP_TR2				=	"Trigger 2";

G.SPLASH_LEFT = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashLeft";
G.SPLASH_RIGHT = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashRight";
G.SPLASH_BOTTOM = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashBottom";

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
		G.NAME.CP_R_UP				=	"Y";
		G.NAME.CP_X_OPTION			=	"A";
		G.NAME.CP_R_LEFT			=	"X";
		G.NAME.CP_R_RIGHT			=	"B";
		G.NAME.CP_L_OPTION			= 	"Back";
		G.NAME.CP_C_OPTION			=	"Guide";
		G.NAME.CP_R_OPTION			= 	"Start";
		-- Colors
		G.COLOR_UP 					= 	"FFE74F";
		G.COLOR_LEFT 				= 	"00A2FF";
		G.COLOR_RIGHT				= 	"FA4451";
		G.COLOR_DOWN 				= 	"52C14E";
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
		G.NAME.CP_R_UP				=	"Triangle";
		G.NAME.CP_X_OPTION			=	"Cross";
		G.NAME.CP_R_LEFT			=	"Square";
		G.NAME.CP_R_RIGHT			=	"Circle";
		G.NAME.CP_L_OPTION			= 	"Share";
		G.NAME.CP_C_OPTION			=	"PS";
		G.NAME.CP_R_OPTION			= 	"Options";
		-- Colors
		G.COLOR_UP 					= 	"62BBB2";
		G.COLOR_LEFT 				= 	"D35280";
		G.COLOR_RIGHT				= 	"D84E58";
		G.COLOR_DOWN 				= 	"6882A1";
	end
	-- Interaction keys
	G.CIRCLE  					= 1;
	G.SQUARE 					= 2;
	G.TRIANGLE 					= 3;
	G.UP						= 4;
	G.DOWN						= 5;
	G.LEFT						= 6;
	G.RIGHT						= 7;
	G.PREPARE 					= 8;
	G.STATE_UP 					= "up";
	G.STATE_DOWN				= "down";
	-- Global config variables
	G.BIND_TARGET 				= false;
	G.CONF_BUTTON 				= nil;
	G.CP 						= "CP";
	G.CONF 						= "_CONF";
	G.CONFBG 					= "_CONF_BG";
	G.NOMOD 					= "_NOMOD";
	G.SHIFT 					= "_SHIFT";
	G.CTRL 						= "_CTRL";
	G.CTRLSH 					= "_CTRLSH";
	-- Arrows
	AddTexture(G.NAME.CP_L_UP, type);
	AddTexture(G.NAME.CP_L_DOWN, type);
	AddTexture(G.NAME.CP_L_LEFT, type);
	AddTexture(G.NAME.CP_L_RIGHT, type);
	-- Action buttons
	AddTexture(G.NAME.CP_R_UP, type);
	AddTexture(G.NAME.CP_R_LEFT, type);
	AddTexture(G.NAME.CP_R_RIGHT, type);
	AddTexture(G.NAME.CP_X_OPTION, type);
	-- Options
	AddTexture(G.NAME.CP_L_OPTION, type);
	AddTexture(G.NAME.CP_C_OPTION, type);
	AddTexture(G.NAME.CP_R_OPTION, type);
	-- L/R
	G.TEXTURE.LONE   			= TEXTURE_PATH..type.."l1";
	G.TEXTURE.LTWO   			= TEXTURE_PATH..type.."l2";
	G.TEXTURE.LTHREE   			= TEXTURE_PATH..type.."l3";
	G.TEXTURE.RONE   			= TEXTURE_PATH..type.."r1";
	G.TEXTURE.RTWO   			= TEXTURE_PATH..type.."r2";
	G.TEXTURE.RTHREE			= TEXTURE_PATH..type.."r3";
	-- Click strings
	local POINTS 			= ":20:20:0:0";
	local _RIGHT 			= "|T"..G.TEXTURE[string.upper(G.NAME.CP_R_RIGHT)]..POINTS.."|t|cFF"..G.COLOR_RIGHT;
	local _LEFT 			= "|T"..G.TEXTURE[string.upper(G.NAME.CP_R_LEFT)]..POINTS.."|t|cFF"..G.COLOR_LEFT;
	local _UP				= "|T"..G.TEXTURE[string.upper(G.NAME.CP_R_UP)]..POINTS.."|t|cFF"..G.COLOR_UP;
	G.CLICK.USE 			= _RIGHT.."Use|r";
	G.CLICK.QUEST_TRACKER 	= _RIGHT.."Set current quest|r";
	G.CLICK.USE_NOCOMBAT 	= _RIGHT.."Use (out of combat)|r";
	G.CLICK.SELL 			= _RIGHT.."Sell|r";
	G.CLICK.BUY 			= _RIGHT.."Buy|r";
	G.CLICK.LOOT			= _RIGHT.."Loot|r";
	G.CLICK.EQUIP			= _RIGHT.."Equip|r";
	G.CLICK.REPLACE			= _RIGHT.."Replace|r";
	G.CLICK.GLYPH_CAST		= _RIGHT.."Use glyph|r";
	G.CLICK.TALENT 			= _RIGHT.."Learn talent|r";
	G.CLICK.TAKETAXI 		= _RIGHT.."Fly to location|r";
	G.CLICK.PICKUP 			= _LEFT.."Pick up|r";
	G.CLICK.QUEST_DETAILS 	= _LEFT.."View quest details|r";
	G.CLICK.CANCEL 			= _UP.."Cancel|r";
	G.CLICK.STACK_BUY 		= _UP.."Buy a different amount|r";
	G.CLICK.ADD_TO_EXTRA	= _UP.."Bind|r";
	-- Tutorial strings
	local tutorialCursor 	= "|TInterface\\AddOns\\ConsolePort\\Graphic\\TutorialCursor:64:128:0:0|t";
	local exampleTexture 	= G.TEXTURE.Y or G.TEXTURE.TRIANGLE;
	local exampleCombo 		= "|T"..G.TEXTURE.LONE..":20:20:0:0|t".."|T"..exampleTexture..":20:20:0:0|t";
	G.TUTORIAL.BIND 		= {};
	G.TUTORIAL.BIND.IMPORT 	= "You can import bindings from your other characters here. Your current bindings will be exported when you log out.\nPress |cFFFFD200Okay|r to apply.";
	G.TUTORIAL.BIND.DYNAMIC = "       |cFFFFD200[Rebind Instructions]|r\n\n1. Mouse over an action button\n2.  Press a button combination\n"..tutorialCursor.."+   "..exampleCombo;
	G.TUTORIAL.BIND.STATIC 	= "       |cFFFFD200[Rebind Instructions]|r\n\n1.   Click on a combination\n2. Choose action from the list\n";
	G.TUTORIAL.BIND.MOD 	= "              |cFFFFD200[Modifiers]|r\nThese columns represent all button combinations. Every button in the list to the left\nhas four combinations each.";
	G.TUTORIAL.BIND.ACTION 	= "          |cFFFFD200[Action Buttons]|r\nThese buttons can be used for abilities, macros and items. They are also used to control the interface.";
	G.TUTORIAL.BIND.OPTION 	= "          |cFFFFD200[Option Buttons]|r\nThese buttons can be used to perform any action defined in the regular key bindings.";
end

-- debug tool
function ConsolePort:G()
	return G
end