local _, db = ...

-- Use English as default locale.

local DEFAULT = {

TUTORIAL = {
	BIND  = {
		HEADER 				= "Binding settings",
		SIDEBAR 			= "Bindings",
		TOOLTIPHEADER 		= "Bindings",
		TOOLTIPCLICK 		= "<Click to change>",
		DEFAULT 			= "Click on a button to change its behaviour.",
		COMBO 				= "Click on a combination of %s to change it.",
		REBIND 				= "Select an interface button or key binding with the cursor to change:\n%s",
		APPLIED 			= "%s was applied to %s.",
		INVALID 			= "Error: Invalid button. New binding was discarded.",
		COMBAT 				= "Error: In combat! Exit combat to change your settings.",
		IMPORT 				= "Settings imported from %s. Press Okay to apply.",
		RESET 				= "Default settings loaded. Press Okay to apply.",
		IMPORTDEFAULT 		= "Choose character",
		IMPORTBUTTON 		= "Import",
		REMOVEBUTTON		= "Remove",
		OTHERCATEGORY 		= "Other",
	},
	MOUSE = {
		HEADER 				= "Toggle mouse look when...",
		SIDEBAR 			= "Mouse",
		VIRTUALCURSOR 		= "Virtual cursor settings",
		STARTED_MOVING 		= "Player starts moving",
		TARGET_CHANGED 		= "Player changes target",
		DIRECT_SPELL_CAST 	= "Player casts a direct spell",
		NPC_INTERACTION 	= "NPC interaction",
		QUEST_AUTOCOMPLETE 	= "Popup quest completion",
		GARRISON_ORDER 		= "Garrison work order",
		LOOT_OPENED 		= "Loot window opened",
		LOOT_CLOSED 		= "Loot window closed",
	},
	UICTRL = {
		HEADER 				= "Interface settings (advanced)",
		SIDEBAR 			= "Interface",
		ADDONLISTHEADER 	= "AddOns:",
		FRAMELISTHEADER 	= "Frames:",
		FRAMELISTFORMAT 	= "Frames in |cffffe00a%s|r:",
		NEWADDON			= "New addon",
		NEWFRAME			= "New frame",
		ADDADDON 			= "Enter name of addon or module:",
		ADDFRAME 			= "Enter name to add frame to addon |cffffe00a%s|r:",
		REMOVEADDON 		= "Do you want to remove addon |cffffe00a%s|r from virtual cursor?",
		REMOVEFRAME 		= "Do you want to remove frame |cffffe00a%s|r in addon |cffffe00a%s|r from virtual cursor?",
		ADD 				= "Add",
		CANCEL 				= "Cancel",
		REMOVE 				= "Remove",
	},
	CONFIG = {
		TRIGGERHEADER		= "Trigger textures (requires reload)",
		AUTOEXTRA 			= "Auto bind appropriate quest items",
		CONTROLLER 			= "Change controller",
		BINDRESET 			= "Reset bindings",
		FULLRESET 			= "Reset all settings",
		CONFIRMRESET 		= "Are you sure?",
		SHOWSLASH 			= "Slash commands",
	},
	SETUP = {
		LAYOUT  			= "Setup: Select controller layout",
		HEADER 				= "Setup: Assign controller buttons",
		HEADLINE 			= "Your controller bindings are incomplete.\nPress the requested button on your controller.",
		OVERRIDE 			= "%s is already bound to %s.\nPress |T%s:20:20:0:0|t again to continue anyway.",
		NOEXISTFIX 			= "something else",			
		INVALID 			= "Invalid binding.\nDid you press the correct button?",
		COMBAT 				= "You are in combat!",
		EMPTY 				= "<Empty>",
		SUCCESS 			= "|T%s:16:16:0:0|t was successfully bound to %s.",
		CONTINUE 			= "Press |T%s:20:20:0:0|t again to continue.",
		CONFIRM 			= "Press |T%s:20:20:0:0|t again to confirm.",
		CONTROLLER 			= "Select your preferred button layout by clicking a controller.",
	},
	SLASH = {
		COMBAT 				= "Error! Cannot reset addon in combat!",
		TYPE				= "Change controller type",
		RESET 				= "Full addon reset (irreversible)",
		TOGGLEMOUSE 		= "Toggle centered cursor lock",
		MOUSEOFF 			= "Centered cursor lock is |cFFFF1111OFF|r.",
		MOUSEON 			= "Centered cursor lock is |cFF11FF11ON|r.",
		BINDS 				= "Open binding menu",
		CRITICALUPDATE		= "|cffffe00a[ConsolePort]|r\n|cFFFF1111WARNING:|r Your settings are incompatible with this version (%s).\nWould you like to reset your settings?",
	}
},
TOOLTIP = {
	CLICK = {
		COMPARE 			=	"Compare",
		QUEST_TRACKER 		=	"Set current quest",
		USE_NOCOMBAT 		=	"Use (out of combat)",
		BUY 				= 	"Buy",
		USE 				= 	"Use",
		EQUIP				= 	"Equip",
		SELL 				= 	"Sell",
		QUEST_DETAILS 		= 	"View quest details",
		PICKUP 				= 	"Pick up",
		CANCEL 				= 	"Cancel",
		STACK_BUY 			= 	"Buy a different amount",
		ADD_TO_EXTRA		= 	"Bind",
	}
},
CUSTOMBINDS = {
	CP_EXTRABUTTON			= 	"Custom extra button",
	CP_RAIDCURSOR			= 	"Toggle raid cursor",
	CP_TOGGLEMOUSE			= 	"Toggle mouse look",
	CP_CAMZOOMIN			= 	"Zoom in (custom)",
	CP_CAMZOOMOUT			= 	"Zoom out (custom)",
},
HEADERS = {
	CP_LEFT 				= 	"Directional pad",
	CP_RIGHT				= 	"Action buttons",
	CP_CENTER				= 	"Center buttons",
	CP_TRIG					=	"Triggers",
},

}


-- Compare a database table against a default table
-- Fill in non-existing values in the database tables
local function CheckTable(dbTable, defaultTable)
	for key, value in pairs(defaultTable) do
		if type(value) == "table" then
			if not dbTable[key] then
				dbTable[key] = {}
			end
			CheckTable(dbTable[key], value)
		elseif type(value) == "string" and not dbTable[key] then
			dbTable[key] = value
		end
	end
end

for val, tbl in pairs(DEFAULT) do
	if not db[val] then
		db[val] = tbl
	end
	CheckTable(db[val], tbl)
end
