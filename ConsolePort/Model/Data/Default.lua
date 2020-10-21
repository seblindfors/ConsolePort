-- Consts
local STICK_SELECT = {'Left', 'Right', 'Movement', 'Cursor'};
local UINAV_SELECT = {'PAD1', 'PAD2', 'PAD3', 'PAD4'};
local MODID_SELECT = {'Alt', 'Shift', 'Ctrl'};

local unpack, __, db = unpack, ...; __ = 1;
setfenv(__, setmetatable(db('Data'), {__index = _G}));
------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
db:Register('Variables', {
	--------------------------------------------------------------------------------------------------------
	-- Action page handling:
	--------------------------------------------------------------------------------------------------------
	actionPageCondition = {String(nil);
		head = BINDING_HEADER_ACTIONBAR;
		name = 'Action Page Condition';
		desc = 'Macro condition to evaluate action bar page.';
	};
	actionPageResponse = {String(nil);
		head = BINDING_HEADER_ACTIONBAR;
		name = 'Action Page Response';
		desc = 'Response to condition for custom processing.'
	};
	--------------------------------------------------------------------------------------------------------
	-- Bindings:
	--------------------------------------------------------------------------------------------------------
	bindingOverlapEnable = {Bool(false);
		head = KEY_BINDINGS_MAC;
		name = 'Allow Binding Overlap';
		desc = 'Allow binding multiple combos to the same binding.'
	};
	bindingShowExtraBars = {Bool(false);
		head = KEY_BINDINGS_MAC;
		name = 'Show All Action Bars';
		desc = 'Show bonus bar configuration for characters without stances.'
	};
	--------------------------------------------------------------------------------------------------------
	-- Mouse:
	--------------------------------------------------------------------------------------------------------
	mouseHandlingEnabled = {Bool(true);
		head = MOUSE_LABEL;
		name = 'Enable Mouse Handling';
		desc = 'Enable custom mouse handling'
	};
	mouseAutoClearCenter = {Number(2.0);
		head = MOUSE_LABEL;
		name = 'Automatic Cursor Timeout';
		desc = 'Time in seconds to automatically hide centered cursor.';
	};
	mouseAlwaysCentered = {Bool(false);
		head = MOUSE_LABEL;
		name = 'Always Show Mouse Cursor';
		desc = 'Always keep cursor centered and visible when controlling camera.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Radial:
	--------------------------------------------------------------------------------------------------------
	radialActionDeadzone = {Range(0.5, 0, 1, 0.05);
		head = 'Radial Menus';
		name = 'Radial Deadzone';
		desc = 'Deadzone for simple pie menus'
	};
	radialCosineDelta = {Delta(-1);
		head = 'Radial Menus';
		name = 'Radial Direction Delta';
		desc = 'Direction of item order in a pie menu (default clockwise)';
	};
	radialStartIndexAt = {Range(90, 0, 360, 22.5);
		head = 'Radial Menus';
		name = 'Radial Start Angle';
		desc = 'Starting angle of the first item in a pie menu';
	};
	radialClearFocusTime = {Number(0.5);
		head = 'Radial Menus';
		name = 'Radial Focus Timeout';
		desc = 'Time to clear focus after intercepting stick input';
	};
	radialPrimaryStick = {Table({'Left', 'Movement'});
		head = 'Radial Menus';
		name = 'Primary Stick';
		desc = 'Primary radial stick: which stick to intercept for main radial actions';
		opts = STICK_SELECT;
	};
	radialSecondaryStick = {Table({'Right', 'Cursor'});
		head = 'Radial Menus';
		name = 'Secondary Stick';
		desc = 'Secondary radial stick: which stick to intercept for extra radial actions';
		opts = STICK_SELECT;
	};
	--------------------------------------------------------------------------------------------------------
	-- Interface cursor:
	--------------------------------------------------------------------------------------------------------
	UICursor = {
		head = 'Interface Cursor';
		name = 'Action Buttons';
		desc = 'Cursor actions: which buttons to use to click on items in the interface';
		opts = UINAV_SELECT;
		[__] = Table({
			LeftClick  = 'PAD1'; -- cross
			RightClick = 'PAD2'; -- circle
			Special    = 'PAD4'; -- triangle
		});
	};
	UImodifierCommands = {Select('Shift', unpack(MODID_SELECT));
		head = 'Interface Cursor';
		name = 'Modifier';
		desc = 'Which modifier to use for modified commands';
		opts = MODID_SELECT;
	};
	UIaccessUnlimited = {Bool(false);
		head = 'Interface Cursor';
		name = 'Unlimited Navigation';
		desc = 'Allow cursor to interact with the entire interface.';
	};
	UIenableCursor = {Bool(true);
		head = 'Interface Cursor';
		name = ENABLE;
		desc = 'Enable interface cursor. Disable to use mouse-based interface interaction.';
	};
	UIleaveCombatDelay = {Number(.5);
		head = 'Interface Cursor';
		name = 'Reactivation Delay';
		desc = 'Delay before re-activating interface cursor after leaving combat.';
	};
	UIholdRepeatDelay = {Number(.125);
		head = 'Interface Cursor';
		name = 'Repeated Movement Delay';
		desc = 'Delay until a movement is repeated, when holding down a direction.';
	};
	UIholdRepeatDisable = {Bool(false);
		head = 'Interface Cursor';
		name = 'Disable Repeated Movement';
		desc = 'Disable repeated cursor movements - each click will only move the cursor once.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Unit hotkeys:
	--------------------------------------------------------------------------------------------------------
	unitHotkeySize = {Number(32);
		head = 'Unit Hotkeys';
		name = 'Size';
		desc = 'Size of unit hotkeys (px)';
	};
	unitHotkeyOffsetX = {Number(0);
		head = 'Unit Hotkeys';
		name = 'Horizontal Offset';
		desc = 'Horizontal offset of the hotkey prompt position, in pixels.';
	};
	unitHotkeyOffsetY = {Number(0);
		head = 'Unit Hotkeys';
		name = 'Vertical Offset';
		desc = 'Vertical offset of the hotkey prompt position, in pixels.';
	};
	unitHotkeyGhostMode = {Bool(false);
		head = 'Unit Hotkeys';
		name = 'Always Show';
		desc = 'Hotkey prompts linger on unit frames after targeting.';
	};
	unitHotkeyIgnorePlayer = {Bool(false);
		head = 'Unit Hotkeys';
		name = 'Ignore Player';
		desc = 'Always ignore player, regardless of unit pool.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Misc:
	--------------------------------------------------------------------------------------------------------
	classFileOverride = {String(nil);
		head = MISCELLANEOUS;
		name = 'Override Class File';
		desc = 'Override class theme for interface styling.';
	};
	disableAmbientFrames = {Bool(false);
		head = MISCELLANEOUS;
		name = 'Disable Ambient Noise-Cancelling';
		desc = 'Disable ambient noise-cancelling in menus.';
	};
})  --------------------------------------------------------------------------------------------------------
