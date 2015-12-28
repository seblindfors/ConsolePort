local _, db = ...

-- Use English as default locale.

local DEFAULT = {

TUTORIAL = {
	BIND  = {
		HEADER 				= "Bindings",
		SIDEBAR 			= "Bindings",
		MENUHEADER 			= "Controller",
		TOOLTIPHEADER 		= "Bindings",
		TOOLTIPCLICK 		= "<Click to change>",
		DEFAULT 			= "Click here to change a binding.",
		COMBATTEXT 			= "Exit combat to change your settings.",
		CATCHER 			= "Press a button on your controller.",
		COMBO 				= "Click on a combination to change it.",
		REBIND 				= "Select an interface button or key binding to change:\n%s",
		APPLIED 			= "%s was bound to %s.",
		SWAPPED 			= "%s was bound to %s.\n%s was bound to %s.",
		INVALID 			= "Error: Invalid button. New binding was discarded.",
		COMBAT 				= "Error: In combat! Exit combat to change your settings.",
		IMPORT 				= "Settings were imported from %s.",
		RESET 				= "Default settings loaded.",
		IMPORTDEFAULT 		= "Choose character",
		IMPORTBUTTON 		= "Import",
		REMOVEBUTTON		= "Remove",
		OTHERCATEGORY 		= "Other",
	},
	MOUSE = {
		STARTED_MOVING 		= "Player starts moving",
		TARGET_CHANGED 		= "Player changes target",
		DIRECT_SPELL_CAST 	= "Player casts a direct spell",
		NPC_INTERACTION 	= "Interacting with an NPC",
		QUEST_AUTOCOMPLETE 	= "Popup quest appears",
		LOOTING 			= "Looting",
		JUMPING 			= "Jumping",
		CENTERCURSOR 		= "Cursor is centered",
	},
	UICTRL = {
		HEADER 				= "Interface",
		SIDEBAR 			= "Interface",
		ADDONLISTHEADER 	= "AddOns:",
		FRAMELISTHEADER 	= "Frames:",
		FRAMELISTFORMAT 	= "Frames in |cffffe00a%s|r:",
		NEWFRAME			= "Add frame by name to %s",
		MOUSEOVERVALID		= "Add frame %s to %s",
		MOUSEOVERINVALID 	= "Add frame by mouse over",
		TUTORIALFRAME 		= "Integrate your custom add-ons and frames here.",
		ADDADDON 			= "Enter name of addon or module:",
		ADDFRAME 			= "Enter name to add frame to addon |cffffe00a%s|r:",
		REMOVEADDON 		= "Do you want to remove addon |cffffe00a%s|r from interface cursor?",
		REMOVEFRAME 		= "Do you want to remove frame |cffffe00a%s|r in addon |cffffe00a%s|r from interface cursor?",
		ADD 				= "Add",
		CANCEL 				= "Cancel",
		REMOVE 				= "Remove",
	},
	CONFIG = {
		VIRTUALCURSOR 		= "Interface cursor settings",
		TRIGGERHEADER		= "Trigger textures (requires reload)",
		GENERALHEADER 		= "General settings",
		MOUSEHEADER 		= "Lock mouse cursor when...",
		INTERACTCATCHER 	= "Click here to assign.",
		INTERACTASSIGNED 	= "Assigned to\n|T%s:64:64:0:-8|t",
		INTERACTHEADER 		= "Interact button",
		INTERACTCHECK 		= "Enable",
		INTERACTDESC 		= "Used to interact when you don't have a valid target.\nChanges behaviour depending on original action.",
		MOUSEOVERMODE 		= "Always interact with mouseover",
		MOUSEDRIFTING 		= "Prevent mouse cursor from drifting off screen",
		CLICKTOMOVE 		= "Click-to-move / move to target on interaction",
		TURNMOVE 			= "Turn instead of strafe when mouse look is off",
		DOUBLEMODTAP 		= "Double tap |T%s:32:32:0:0|t or |T%s:32:32:0:0|t to toggle mouse cursor",
		DISABLEMOUSE 		= "Disable smart mouse behaviour",
		AUTOEXTRA 			= "Auto bind items from tracked quests",
		FASTCAM 			= "Fast camera zooming",
		AUTOLOOT 			= "Force auto loot in combat",
		CONTROLLER 			= "Change controller",
		BINDRESET 			= "Reset bindings",
		FULLRESET 			= "Reset all settings",
		CONFIRMRESET 		= "Are you sure?",
		SHOWSLASH 			= "Slash commands",
		SAVE 				= "Save settings",
		APPLY 				= "Apply",
		CANCEL 				= "Cancel",
		DEFAULT 			= "Default",
		DEFAULTHEADER 		= "Reset settings",
		DEFAULTTHIS			= "Reset these settings",
		DEFAULTALL			= "Reset all settings",
		KEYBOARDLANG 		= "Language templates:",
	},
	SETUP = {
		LAYOUT  			= "Setup: Select controller layout",
		HEADER 				= "Setup: Assign controller buttons",
		SKIPGUIDE 			= "Skip this button",
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
	CP_UTILITYBELT			= 	"Utility belt",
	CP_RAIDCURSOR			= 	"Toggle raid cursor",
	CP_TOGGLEMOUSE			= 	"Toggle mouse look",
	CP_CAMZOOMIN			= 	"Zoom in (custom)",
	CP_CAMZOOMOUT			= 	"Zoom out (custom)",
	CP_CAMLOOKBEHIND		= 	"Look behind",
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

DEFAULT = nil