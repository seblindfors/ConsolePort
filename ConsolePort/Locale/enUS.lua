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
		PROFILEPRESET 		= " Preset",
		PROFILEEMPTY 		= "Empty",
		DEFAULT 			= "Click here to change a binding.",
		COMBATTEXT 			= "Exit combat to change your settings.",
		CATCHER 			= "Press a button on your controller.",
		RETURN 				= "Return to blueprint",
		COMBO 				= "|T%s:20:20:0:0|tLeft click: change or add binding\n|T%s:20:20:0:0|tRight click: clear binding",
		SWAPPER 			= "Click on a button combination or binding to start pairing.",
		COMBAT 				= "Error: In combat! Exit combat to change your settings.",
		IMPORT 				= "Settings were imported from %s.",
		RESET 				= "Default settings loaded.",
		IMPORTDEFAULT 		= "Choose character",
		IMPORTBUTTON 		= "Import",
		REMOVEBUTTON		= "Remove",
		MAINCATEGORY 		= " |cFFFF6600Controller|r ",
		NOTASSIGNED 		= "|cFF575757Not assigned|r",
		SPELL 				= "Spell",
		ITEM 				= "Item",
		MOUNT 				= "Mount",
		CRITTER 			= "Battle Pet",
		MACRO 				= "|cFF575757 (Macro)",
		EQSET 				= "|cFF575757 (Equipment Set)|r",
		LEFTCLICK 			= "|cFF757575Left Click / Movement|r",
		RIGHTCLICK 			= "|cFF757575Right Click / Mouse|r",
		SHIFT 				= "|cFF757575Modifier 1 / Shift|r",
		CTRL 				= "|cFF757575Modifier 2 / Ctrl|r",
		T1 					= "Trigger 1",
		T2 					= "Trigger 2",
	},
	MOUSE = {
		STARTED_MOVING 		= "Starting to move",
		TARGET_CHANGED 		= "Changing target",
		DIRECT_SPELL_CAST 	= "Casting a spell",
		NPC_INTERACTION 	= "Interacting with an NPC",
		QUEST_AUTOCOMPLETE 	= "Popup quest appears",
		LOOTING 			= "Looting",
		JUMPING 			= "Jumping",
		CENTERCURSOR 		= "Cursor is centered",
	},
	UICTRL = {
		VIRTUALCURSOR 		= "Interface cursor",
		ACTIONBARHEADER		= "Hotkey style",
		HEADER 				= "Interface",
		SIDEBAR 			= "Interface",
		ADDONLISTHEADER 	= "AddOns:",
		FRAMELISTHEADER 	= "Frames:",
		FRAMELISTFORMAT 	= "Frames in |cffffe00a%s|r:",
		NEWFRAME			= "Add new frame manually",
		MOUSEOVERVALID		= "Add |cffffffff%s|r to |cffffaaaa%s|r",
		MOUSEOVERINVALID 	= "Add frame by mouse over",
		TUTORIALFRAME 		= "Integrate your custom add-ons and frames here.",
		TUTORIALFRAMEMO 	= "Hover a frame to register its name.",
		HIDEFRAMELIST 		= "Return to interface settings",
		ADDADDON 			= "Enter name of addon or module:",
		ADDFRAME 			= "Enter name to add frame to addon |cffffe00a%s|r:",
		REMOVEADDON 		= "Do you want to remove addon |cffffe00a%s|r from the interface cursor?",
		REMOVEFRAME 		= "Do you want to remove frame |cffffe00a%s|r in addon |cffffe00a%s|r from the interface cursor?",
		ADD 				= "Add",
		CANCEL 				= "Cancel",
		REMOVE 				= "Remove",
		SHOWALLADDONS		= "Show core add-ons and frames",
		ENABLECURSOR 		= "Enable interface cursor",
	},
	CONFIG = {
		GENERALHEADER 		= "General settings",
		CONTROLLERBUTTON 	= "Controller",
		INTERACTHEADER 		= "Interact button",
		MOUSEHEADER 		= "Hide mouse cursor when...",
		TRIGGERHEADER		= "Trigger settings",
		CAMERAHEADER 		= "Camera settings",
		TARGETHEADER		= "Highlight next target",
		INTERACTCATCHER 	= "Click here to assign.",
		INTERACTASSIGNED 	= "Assigned to\n|T%s:64:64:0:-8|t",
		INTERACTCHECK 		= "Enable",
		INTERACTDESC 		= "Used to interact when you don't have a valid target.\nChanges behaviour depending on original action.",
		MOUSEOVERMODE 		= "Always interact with mouseover",
		-----------------------------------------------------------
		TRIGGERHELP 		= "These settings will change which graphics are displayed for your triggers and modifiers.\nIf you want to change your modifiers, you will also have to change them in your controller mapper.",
		-----------------------------------------------------------
		MOUSEHANDLE 		= "Character handling",
		MOUSEDRIFTING 		= "Prevent mouse cursor from drifting off screen",
		ACTIONCAM 			= "Focus camera on target",
		TURNMOVE 			= "Turn instead of strafe when the cursor is visible",
		DOUBLEMODTAP 		= "Double tap |T%s:32:32:0:0|t or |T%s:32:32:0:0|t to toggle mouse cursor",
		LOOKAROUND 			= "Hold |T%s:32:32:0:0|t to look around",
		DISABLEMOUSE 		= "Disable automatic mouse behaviour",
		CONVENIENCE 		= "Convenience features",
		AUTOEXTRA 			= "Add quest items and extra spells to utility ring",
		FASTCAM 			= "Fast camera zooming",
		AUTOLOOT 			= "Force auto loot in combat",
		AUTOSELL 			= "Automatically sell junk",
		CPMENU 				= "Use default game menu",
		-----------------------------------------------------------
		CONTROLLER 			= "Change controller",
		BINDRESET 			= "Calibrate controller",
		FULLRESET 			= "Reset all settings",
		CONFIRMRESET 		= "Are you sure?",
		SHOWSLASH 			= "Slash commands",
		-----------------------------------------------------------
		TARGETSCAN 			= "When scanning (default)",
		TARGETNONE 			= "When no target exists",
		TARGETALWAYS 		= "Always on",
		-----------------------------------------------------------
		SAVE 				= "Save settings",
		APPLY 				= "Apply",
		CANCEL 				= "Cancel",
		DEFAULT 			= "Default",
		DEFAULTHEADER 		= "Reset settings",
		DEFAULTTHIS			= "Reset these settings",
		DEFAULTALL			= "Reset all settings",
		-----------------------------------------------------------
	},
	HINTS = {
		DISABLE 				= "Disable on-screen hints",
		UTILITY_RING_BIND 		= "Hold %s to open the utility ring.",
		UTILITY_RING_DOUBLE 	= "Press %s twice to toggle the utility ring.",
		UTILITY_RING_REMOVE 	= "Press %s when an item is selected to remove it.",
		UTILITY_RING_NEWBIND	= "%s was bound to your Utility Ring%s",
	},
	SETUP = {
		LAYOUT  			= "Setup: Select controller layout",
		HEADER 				= "Setup: Calibrate controller",
		CONTINUECLICK 		= "Click here to continue",
		LOADWOWMAPPER 		= "I'm using WoWmapper",
		SKIPGUIDE 			= "Skip this button",
		HEADLINE 			= "Your controller calibration is incomplete.\nPress the requested button on your controller.\nDo NOT use your keyboard during calibration.",
		OVERRIDE 			= "%s is already bound to %s.\nPress |T%s:20:20:0:0|t again to continue anyway.",
		NOEXISTFIX 			= "something else",
		NEWMODIFIER 		= "You have attempted to map a modifier.\nThe interface needs to be reloaded in order to continue.",
		RESERVED 			= "This binding (%s) is reserved to %s.\nYou don't need to calibrate your controller sticks.",
		INVALID 			= "Invalid binding.\nDid you press the correct button?",
		COMBAT 				= "You are in combat!",
		EMPTY 				= "<Empty>",
		SUCCESS 			= "|T%s:16:16:0:0|t was successfully bound to %s.",
		CONTINUE 			= "Press |T%s:20:20:0:0|t again to continue.",
		CONFIRM 			= "Press |T%s:20:20:0:0|t again to confirm.",
		CONTROLLER 			= "Select your preferred button layout by clicking a controller.",
		WTFTEXT				= "What is this?",
		AHATEXT				= "|cFF888888World of Warcraft doesn't natively support controllers. \nTo solve this problem, the controller has to emulate mouse and keyboard input.|r\n\n%s",
		DISCLAIMER			= "Using an input mapper is legal and does not violate the terms of use.",
		NOINSTRUCTIONS 		= "This controller has no mapping instructions yet.",
	},
	SLASH = {
		ACCEPT 				= "Yes (recommended)",
		CANCEL 				= "Cancel",
		-----------------------------------------------------------
		COMBAT 				= "Error! Cannot reset addon in combat!",
		TYPE				= "|cffffe00a(ID)|r Change controller type",
		CONFIG 				= "Open the configuration panel",
		RECALIBRATE 		= "Recalibrate controller",
		CALIBRATE 			= "Recalibrate",
		RESET 				= "Full addon reset (irreversible)",
		BINDS 				= "Open binding menu",
		EDITBINDS 			= "Edit bindings",
		-----------------------------------------------------------
		WARNINGBINDINGUI 	= "|cffffe00a[ConsolePort]|r\n|cFFFF1111WARNING:|r You can only customize your keyboard bindings from this panel.\n\nModifying keyboard bindings while using your controller is not recommended.\n\nWould you like to edit your controller bindings, recalibrate your controller or continue anyway?",
		WARNINGCOMBATLOGIN 	= "|cffffe00a[ConsolePort]|r\n|cFFFF1111WARNING:|r You reloaded your interface in combat.\nLeave combat to complete initialization.",
		CRITICALUPDATE		= "|cffffe00a[ConsolePort]|r\n|cFFFF1111WARNING:|r Your settings are incompatible with this version (%s).\nWould you like to reset your settings?",
		NEWCONTROLLER 		= "|cffffe00a[ConsolePort]|r\nYou have loaded a new controller profile. Would you like to load the default bindings for this controller?",
		NEWCHARACTER 		= "|cffffe00a[ConsolePort]|r\nWould you like to load the default bindings for your controller?",
		NOBINDINGS 			= "|cffffe00a[ConsolePort]|r\nYou don't have any bindings configured. Would you like to load the default bindings for your controller?",
		CALIBRATIONUPDATE	= "|cffffe00a[ConsolePort]|r\nYour current calibration doesn't match your WoWmapper settings. Would you like to update your calibration?",
		WMUPDATE 			= "|cffffe00a[ConsolePort]|r\nYou have recently made changes to your WoWmapper settings. For these changes to take effect, the interface has to be reloaded.\nReload now?",
	},
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
		PICKUP_ITEM			= 	"Pick up",
		CANCEL 				= 	"Cancel",
		STACK_BUY 			= 	"Buy a different amount",
		STACK_SPLIT 		= 	"Split stack",
		ADD_TO_EXTRA		= 	"Quick bind",
		FLYOUT 				= 	"%s Cast spell %s Cancel",
	}
},
CUSTOMBINDS = {
	-- Headers
	-----------------------------------------------------------
	CP_MOUSE 				= 	"Mouse Simulation",
	CP_UTILITY 				= 	"Utility",
	CP_CAMERA 				= 	"Camera",
	CP_NAMEPLATES 			= 	"Targeting (custom)",
	-- Bindings
	-----------------------------------------------------------
	CP_CYCLEPLATES 			= 	"Cycle Name Plates",
	CP_WORLDCURSOR			= 	"Smart Target",
	CP_UTILITYBELT			= 	"Utility Ring",
	CP_SPELLWHEEL 			= 	"Spell Wheel",
	CP_RAIDCURSOR			= 	"Toggle Raid Cursor",
	CP_RAIDCURSOR_F 		= 	"Focus Raid Cursor",
	CP_RAIDCURSOR_T 		= 	"Target Raid Cursor",
	CP_TOGGLEMOUSE			= 	"Toggle Mouse Look",
	CP_CAMZOOMIN			= 	"Zoom In (x5)",
	CP_CAMZOOMOUT			= 	"Zoom Out (x5)",
	CP_CAMLOOKBEHIND		= 	"Look Behind",
	-- Strings in case controller has no texture for the binding XML
	-----------------------------------------------------------
	CP_X_CENTER				= 	"|c75757575Guide |caaee5555(disabled)|r",
	CP_L_GRIP 				= 	"|c75757575Left Grip 1 |caaee5555(disabled)|r",
	CP_R_GRIP 				= 	"|c75757575Right Grip 1 |caaee5555(disabled)|r",
	CP_L_GRIP2 				= 	"|c75757575Left Grip 2 |caaee5555(disabled)|r",
	CP_R_GRIP2 				= 	"|c75757575Right Grip 2 |caaee5555(disabled)|r",
	CP_L_PULL 				= 	"|c75757575Left Hard Pull |caaee5555(disabled)|r",
	CP_R_PULL 				= 	"|c75757575Right Hard Pull |caaee5555(disabled)|r",
	-- Headers
	-----------------------------------------------------------
	CAMERAORSELECTORMOVE 	= 	"Left Mouse Button",
	TURNORACTION 			= 	"Right Mouse Button",
},
ACTIONBAR = {
	EYE_LEFTCLICK 			= "Left click or %s to show/hide modified actions.",
	EYE_RIGHTCLICK 			= "Right click or %s to toggle cover art display.",
	EYE_SCROLL 				= "Scroll with your mouse wheel anywhere on the bar to change scale.",
},
HEADERS = {
	CP_LEFT 				= 	"Directional Pad",
	CP_RIGHT				= 	"Action Buttons",
	CP_CENTER				= 	"Center Buttons",
	CP_GRIP 				= 	"Grip Buttons",
	CP_TRIG					=	"Triggers",
}}


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