-- Consts
local STICK_SELECT = {'Left', 'Right', 'Movement', 'Cursor'};
local UINAV_SELECT = {'PAD1', 'PAD2', 'PAD3', 'PAD4'};
local MODID_SELECT = {'ALT', 'SHIFT', 'CTRL'};
local ADVANCED_OPT = RED_FONT_COLOR:WrapTextInColorCode(ADVANCED_OPTIONS);

local unpack, __, db = unpack, ...; __ = 1;
setfenv(__, setmetatable(db('Data'), {__index = _G}));
------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
db:Register('Variables', {
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
		sort = 1;
		name = 'Enable Mouse Handling';
		desc = 'Enable custom mouse handling'
	};
	mouseAlwaysCentered = {Bool(false);
		head = MOUSE_LABEL;
		sort = 2;
		name = 'Always Show Mouse Cursor';
		desc = 'Always keep cursor centered and visible when controlling camera.';
	};
	mouseAutoClearCenter = {Number(2.0, 0.25);
		head = MOUSE_LABEL;
		sort = 3;
		name = 'Automatic Cursor Timeout';
		desc = 'Time in seconds to automatically hide centered cursor.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Radial:
	--------------------------------------------------------------------------------------------------------
	radialClearFocusTime = {Number(0.5, 0.1);
		head = 'Radial Menus';
		sort = 1;
		name = 'Radial Focus Timeout';
		desc = 'Time to clear focus after intercepting stick input';
	};
	radialActionDeadzone = {Range(0.5, 0.05, 0, 1);
		head = 'Radial Menus';
		sort = 2;
		name = 'Radial Deadzone';
		desc = 'Deadzone for simple pie menus'
	};
	radialStartIndexAt = {Range(90, 22.5, 0, 360);
		head = 'Radial Menus';
		sort = 3;
		name = 'Radial Start Angle';
		desc = 'Starting angle of the first item in a pie menu';
	};
	radialCosineDelta = {Delta(1);
		head = 'Radial Menus';
		sort = 4;
		name = 'Radial Direction Delta';
		desc = 'Direction of item order in a pie menu (default clockwise)';
	};
	radialPrimaryStick = {Table({'Left', 'Movement'});
		head = 'Radial Menus';
		sort = 5;
		name = 'Primary Stick';
		desc = 'Primary radial stick: which stick to intercept for main radial actions';
		opts = STICK_SELECT;
	};
	radialSecondaryStick = {Table({'Right', 'Cursor'});
		head = 'Radial Menus';
		sort = 6;
		name = 'Secondary Stick';
		desc = 'Secondary radial stick: which stick to intercept for extra radial actions';
		opts = STICK_SELECT;
	};
	--------------------------------------------------------------------------------------------------------
	-- Interface cursor:
	--------------------------------------------------------------------------------------------------------
	UIenableCursor = {Bool(true);
		head = 'Interface Cursor';
		sort = 1;
		name = ENABLE;
		desc = 'Enable interface cursor. Disable to use mouse-based interface interaction.';
	};
	UIaccessUnlimited = {Bool(false);
		head = 'Interface Cursor';
		sort = 2;
		name = 'Unlimited Navigation';
		desc = 'Allow cursor to interact with the entire interface.';
	};
	UIholdRepeatDisable = {Bool(false);
		head = 'Interface Cursor';
		sort = 3;
		name = 'Disable Repeated Movement';
		desc = 'Disable repeated cursor movements - each click will only move the cursor once.';
	};
	UIholdRepeatDelay = {Number(.125, 0.025);
		head = 'Interface Cursor';
		sort = 4;
		name = 'Repeated Movement Delay';
		desc = 'Delay until a movement is repeated, when holding down a direction, in seconds.';
	};
	UIleaveCombatDelay = {Number(0.5, 0.1);
		head = 'Interface Cursor';
		sort = 4;
		name = 'Reactivation Delay';
		desc = 'Delay before reactivating interface cursor after leaving combat, in seconds.';
	};
	UImodifierCommands = {Select('SHIFT', unpack(MODID_SELECT));
		head = 'Interface Cursor';
		sort = 5;
		name = 'Modifier';
		desc = 'Which modifier to use for modified commands';
		opts = MODID_SELECT;
	};
	UICursor = {
		head = 'Interface Cursor';
		sort = 6;
		name = 'Action Buttons';
		desc = 'Cursor actions: which buttons to use to click on items in the interface';
		opts = UINAV_SELECT;
		[__] = Table({
			LeftClick  = 'PAD1'; -- cross
			RightClick = 'PAD2'; -- circle
			Special    = 'PAD4'; -- triangle
		});
	};
	--------------------------------------------------------------------------------------------------------
	-- Unit hotkeys:
	--------------------------------------------------------------------------------------------------------
	unitHotkeyGhostMode = {Bool(false);
		head = 'Unit Hotkeys';
		sort = 1;
		name = 'Always Show';
		desc = 'Hotkey prompts linger on unit frames after targeting.';
	};
	unitHotkeyIgnorePlayer = {Bool(false);
		head = 'Unit Hotkeys';
		sort = 2;
		name = 'Ignore Player';
		desc = 'Always ignore player, regardless of unit pool.';
	};
	unitHotkeySize = {Number(32, 1);
		head = 'Unit Hotkeys';
		sort = 3;
		name = 'Size';
		desc = 'Size of unit hotkeys (px)';
	};
	unitHotkeyOffsetX = {Number(0, 1, true);
		head = 'Unit Hotkeys';
		sort = 4;
		name = 'Horizontal Offset';
		desc = 'Horizontal offset of the hotkey prompt position, in pixels.';
	};
	unitHotkeyOffsetY = {Number(0, 1, true);
		head = 'Unit Hotkeys';
		sort = 5;
		name = 'Vertical Offset';
		desc = 'Vertical offset of the hotkey prompt position, in pixels.';
	};
	unitHotkeyPool = {String('player$;party%d$;raid%d+$');
		head = 'Unit Hotkeys';
		sort = 6;
		name = 'Unit Pool';
		desc = 'Match criteria for unit pool, each type separated by semicolon.';
		note = '$: end of match token\n+: matches multiple tokens\n%d: matches number';
	};
	--------------------------------------------------------------------------------------------------------
	-- Misc:
	--------------------------------------------------------------------------------------------------------
	autoExtra = {Bool(true);
		head = MISCELLANEOUS;
		name = 'Automatically Bind Quest Items';
		desc = 'Automatically add tracked quest items to main utility ring.';
	};
	autoSellJunk = {Bool(true);
		head = MISCELLANEOUS;
		name = 'Automatically Sell Junk';
		desc = 'Automatically sell junk when interacting with a merchant.';
	};
	disableAmbientFrames = {Bool(false);
		head = MISCELLANEOUS;
		name = 'Disable Ambient Noise-Cancelling';
		desc = 'Disable ambient noise-cancelling in menus.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Advanced:
	--------------------------------------------------------------------------------------------------------
	actionPageCondition = {String(nil);
		head = ADVANCED_OPT;
		name = 'Action Page Condition';
		desc = 'Macro condition to evaluate action bar page.';
	};
	actionPageResponse = {String(nil);
		head = ADVANCED_OPT;
		name = 'Action Page Response';
		desc = 'Response to condition for custom processing.'
	};
	classFileOverride = {String(nil);
		head = ADVANCED_OPT;
		name = 'Override Class File';
		desc = 'Override class theme for interface styling.';
	};
})  --------------------------------------------------------------------------------------------------------
