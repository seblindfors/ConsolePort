local _
local _, G = ...;
local type = "PS4\\";
local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Buttons\\";
local TEXTURE = "TEXTURE_";
local EXT = ".tga";
local function AddTexture(BINDING, TYPE)
	G[TEXTURE..string.upper(BINDING)] = TEXTURE_PATH..TYPE..BINDING..EXT;
end
-- Small guide button measurements
G.GUIDE_BORDER_S_SMALL 			= 56;
G.GUIDE_BORDER_X_SMALL 			= -4.75;
G.GUIDE_BORDER_Y_SMALL 			= 3.6;
G.GUIDE_BUTTON_S_SMALL 			= 24;
G.GUIDE_BUTTON_LEFT_SMALL_X 	= -16;
G.GUIDE_BUTTON_LEFT_SMALL_Y 	= 0;
G.GUIDE_BUTTON_RIGHT_SMALL_X 	= 16;
G.GUIDE_BUTTON_RIGHT_SMALL_Y 	= 0;
G.GUIDE_BUTTON_CENTER_SMALL_X 	= 0;
G.GUIDE_BUTTON_CENTER_SMALL_Y 	= 0;
G.GUIDE_BUTTON_BOTTOM_SMALL_X 	= 0;
G.GUIDE_BUTTON_BOTTOM_SMALL_Y 	= -20;
-- Large guide button measurements
G.GUIDE_BORDER_S_LARGE 			= 70;
G.GUIDE_BORDER_X_LARGE 			= -5;
G.GUIDE_BORDER_Y_LARGE 			= 3.2;
G.GUIDE_BUTTON_S_LARGE 			= 32;
G.GUIDE_BUTTON_LEFT_LARGE_X 	= -26;
G.GUIDE_BUTTON_LEFT_LARGE_Y 	= 0;
G.GUIDE_BUTTON_RIGHT_LARGE_X 	= 26;
G.GUIDE_BUTTON_RIGHT_LARGE_Y 	= 0;
G.GUIDE_BUTTON_CENTER_LARGE_X 	= 0;
G.GUIDE_BUTTON_CENTER_LARGE_Y 	= 0;
G.GUIDE_BUTTON_BOTTOM_SMALL_X 	= 0;
G.GUIDE_BUTTON_BOTTOM_SMALL_Y 	= -28;
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
-- Local binding strings
G.NAME_CP_L_UP				=	"Up";
G.NAME_CP_L_DOWN			=	"Down";
G.NAME_CP_L_LEFT			=	"Left";
G.NAME_CP_L_RIGHT			=	"Right";
G.NAME_CP_TR1				=	"Trigger 1";
G.NAME_CP_TR2				=	"Trigger 2";

G.SPLASH_LEFT = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashLeft.tga";
G.SPLASH_RIGHT = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashRight.tga";
G.SPLASH_BOTTOM = "Interface\\AddOns\\ConsolePort\\Graphic\\SplashBottom.tga";

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
		G.NAME_CP_R_UP				=	"Y";
		G.NAME_CP_X_OPTION			=	"A";
		G.NAME_CP_R_LEFT			=	"X";
		G.NAME_CP_R_RIGHT			=	"B";
		G.NAME_CP_L_OPTION			= 	"Back";
		G.NAME_CP_C_OPTION			=	"Guide";
		G.NAME_CP_R_OPTION			= 	"Start";
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
		G.NAME_CP_R_UP				=	"Triangle";
		G.NAME_CP_X_OPTION			=	"Cross";
		G.NAME_CP_R_LEFT			=	"Square";
		G.NAME_CP_R_RIGHT			=	"Circle";
		G.NAME_CP_L_OPTION			= 	"Share";
		G.NAME_CP_C_OPTION			=	"PS";
		G.NAME_CP_R_OPTION			= 	"Options";
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
	G.TEXTURE 					= TEXTURE;
	G.BIND_TARGET 				= false;
	G.CONF_BUTTON 				= nil;
	G.CP 						= "CP";
	G.CONF 						= "_CONF";
	G.CONFBG 					= "_CONF_BG";
	G.GUIDE 					= "_GUIDE";
	G.NOMOD 					= "_NOMOD";
	G.SHIFT 					= "_SHIFT";
	G.CTRL 						= "_CTRL";
	G.CTRLSH 					= "_CTRLSH";
	-- Arrows
	AddTexture(G.NAME_CP_L_UP, type);
	AddTexture(G.NAME_CP_L_DOWN, type);
	AddTexture(G.NAME_CP_L_LEFT, type);
	AddTexture(G.NAME_CP_L_RIGHT, type);
	-- Action buttons
	AddTexture(G.NAME_CP_R_UP, type);
	AddTexture(G.NAME_CP_R_LEFT, type);
	AddTexture(G.NAME_CP_R_RIGHT, type);
	AddTexture(G.NAME_CP_X_OPTION, type);
	-- Options
	AddTexture(G.NAME_CP_L_OPTION, type);
	AddTexture(G.NAME_CP_C_OPTION, type);
	AddTexture(G.NAME_CP_R_OPTION, type);
	-- L/R
	G.TEXTURE_LONE   			= TEXTURE_PATH..type.."l1"..EXT;
	G.TEXTURE_LTWO   			= TEXTURE_PATH..type.."l2"..EXT;
	G.TEXTURE_LTHREE   			= TEXTURE_PATH..type.."l3"..EXT;
	G.TEXTURE_RONE   			= TEXTURE_PATH..type.."r1"..EXT;
	G.TEXTURE_RTWO   			= TEXTURE_PATH..type.."r2"..EXT;
	G.TEXTURE_RTHREE			= TEXTURE_PATH..type.."r3"..EXT;
	-- Guide strings
	local POINTS 			= ":20:20:0:0";
	local _RIGHT 			= "|T"..G[TEXTURE..string.upper(G.NAME_CP_R_RIGHT)]..POINTS.."|t|cFF"..G.COLOR_RIGHT;
	local _LEFT 			= "|T"..G[TEXTURE..string.upper(G.NAME_CP_R_LEFT)]..POINTS.."|t|cFF"..G.COLOR_LEFT;
	local _UP				= "|T"..G[TEXTURE..string.upper(G.NAME_CP_R_UP)]..POINTS.."|t|cFF"..G.COLOR_UP;
	G.CLICK_USE 			= _RIGHT.."Use|r";
	G.CLICK_QUEST_TRACKER 	= _RIGHT.."Set current quest|r";
	G.CLICK_USE_NOCOMBAT 	= _RIGHT.."Use (out of combat)|r";
	G.CLICK_SELL 			= _RIGHT.."Sell|r";
	G.CLICK_BUY 			= _RIGHT.."Buy|r";
	G.CLICK_LOOT			= _RIGHT.."Loot|r";
	G.CLICK_EQUIP			= _RIGHT.."Equip|r";
	G.CLICK_REPLACE			= _RIGHT.."Replace|r";
	G.CLICK_GLYPH_CAST		= _RIGHT.."Use glyph|r";
	G.CLICK_TALENT 			= _RIGHT.."Learn talent|r";
	G.CLICK_TAKETAXI 		= _RIGHT.."Fly to location|r";
	G.CLICK_PICKUP 			= _LEFT.."Pick up|r";
	G.CLICK_QUEST_DETAILS 	= _LEFT.."View quest details|r";
	G.CLICK_CANCEL 			= _UP.."Cancel|r";
	G.CLICK_STACK_BUY 		= _UP.."Buy a different amount|r";
end

-- debug tool
function ConsolePort:DumpG()
	return G
end

-- Override tutorials
-- local POINTS		= ":20:20:-3:-10";
-- local _CIRCLE 		= "|T"..TEXTURE_CIRCLE..POINTG.."|t|cFF"..COLOR_CIRCLE;
-- local _SQUARE 		= "|T"..TEXTURE_SQUARE..POINTG.."|t|cFF"..COLOR_SQUARE;
-- local _TRIANGLE		= "|T"..TEXTURE_TRIANGLE..POINTG.."|t|cFF"..COLOR_TRIANGLE;
-- local N 			= "\n\n";
-- local T 			= "\n     ";
-- WORLD_MAP_TUTORIAL1 = "Map Navigation Shortcuts"..N;
-- WORLD_MAP_TUTORIAL1 = WORLD_MAP_TUTORIAL1.._SQUARE.."Zoom out of current zone|r"..N;
-- WORLD_MAP_TUTORIAL1 = WORLD_MAP_TUTORIAL1.._CIRCLE.."Enter highlighted zone|r"..N;
-- WORLD_MAP_TUTORIAL1 = WORLD_MAP_TUTORIAL1.._TRIANGLE.."Switch to quest mode|r";
-- WORLD_MAP_TUTORIAL2 = "Your quests will be listed here based on the Current Map."..N;
-- WORLD_MAP_TUTORIAL2 = WORLD_MAP_TUTORIAL2.._CIRCLE.."Click highlighted item|r"..N;
-- WORLD_MAP_TUTORIAL2 = WORLD_MAP_TUTORIAL2.._TRIANGLE.."Switch to map mode|r";
-- WorldMapFrame_HelpPlate[1].ToolTipText 	= WORLD_MAP_TUTORIAL1;
-- WorldMapFrame_HelpPlate[2].ToolTipText 	= WORLD_MAP_TUTORIAL2;
-- SPELLBOOK_HELP_1	= SPELLBOOK_HELP_1..N;
-- SPELLBOOK_HELP_1 	= SPELLBOOK_HELP_1.._CIRCLE.."Use spell directly."..T.."Only non-combat spells"..T.."can be cast directly.|r"..N;
-- SPELLBOOK_HELP_1 	= SPELLBOOK_HELP_1.._SQUARE.."Pick up spell on cursor."..T.."Place it on your action bar.|r";
-- SPELLBOOK_HELP_2 	= SPELLBOOK_HELP_2..N;
-- SPELLBOOK_HELP_2 	= SPELLBOOK_HELP_2.._TRIANGLE.."Switch active tab|r";
-- SpellBookFrame_HelpPlate[1].ToolTipText = SPELLBOOK_HELP_1;
-- SpellBookFrame_HelpPlate[2].ToolTipText = SPELLBOOK_HELP_2;