-- Consts
local STICK_SELECT = {'Movement', 'Camera', 'Gyro'};
local MODID_SELECT = {'SHIFT', 'CTRL', 'ALT'};
local MODID_EXTEND = {'SHIFT', 'CTRL', 'ALT', 'CTRL-SHIFT', 'ALT-SHIFT', 'ALT-CTRL'};
local ADVANCED_OPT = RED_FONT_COLOR:WrapTextInColorCode(ADVANCED_OPTIONS);
local BINDINGS_OPT = KEY_BINDINGS_MAC or 'Bindings';

-- Helpers
local BLUE = GenerateClosure(ColorMixin.WrapTextInColorCode, BLUE_FONT_COLOR)
local unpack, _, db = unpack, ...; _ = CPAPI.Define; db.Data();
------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
db:Register('Variables', {
	showAdvancedSettings = {Bool(false);
		name = 'All Settings';
		desc = 'Display all available settings.';
		hide = true;
	};
	useCharacterSettings = {Bool(false);
		name = 'Character Specific';
		desc = 'Use character specific settings for this character.';
		hide = true;
	};
	--------------------------------------------------------------------------------------------------------
	_'Crosshair';
	--------------------------------------------------------------------------------------------------------
	crosshairEnable = _{Bool(true);
		name = 'Enable';
		desc = 'Enables a crosshair to reveal your hidden center cursor position at all times.';
		note = 'Use together with [@cursor] macros to place reticle spells in a single click.';
	};
	crosshairSizeX = _{Number(24, 1, true);
		name = 'Width';
		desc = 'Width of the crosshair, in scaled pixel units.';
		advd = true;
	};
	crosshairSizeY = _{Number(24, 1, true);
		name = 'Height';
		desc = 'Height of the crosshair, in scaled pixel units.';
		advd = true;
	};
	crosshairCenter = _{Number(0.2, 0.05, true);
		name = 'Center Gap';
		desc = 'Center gap, as fraction of overall crosshair size.';
		advd = true;
	};
	crosshairThickness = _{Number(2, 0.025, true);
		name = 'Thickness';
		desc = 'Thickness in scaled pixel units.';
		note = 'Value below two may appear interlaced or not at all.';
		advd = true;
	};
	crosshairColor = _{Color('ff00fcff');
		name = 'Color';
		desc = 'Color of the crosshair.';
	};
	--------------------------------------------------------------------------------------------------------
	_'Movement';
	--------------------------------------------------------------------------------------------------------
	mvmtAnalog = _{Bool(true);
		name = 'Analog Movement';
		desc = 'Movement is analog, translated from your movement stick angle.';
		note = 'Disable to use discrete legacy movement controls.';
	};
	mvmtStrafeAngleTravel = _{Range(tonumber(GetCVar('GamePadFaceMovementMaxAngle')) or 115, 5, 0, 180);
		name = 'Strafe Angle Threshold (Travel)';
		desc = 'Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.';
		note = 'When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.';
	};
	mvmtStrafeAngleCombat = _{Range(tonumber(GetCVar('GamePadFaceMovementMaxAngleCombat')) or 115, 5, 0, 180);
		name = 'Strafe Angle Threshold (Combat)';
		desc = 'Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.';
		note = 'When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.';
	};
	mvmtRunThreshold = _{Range(tonumber(GetCVar('GamePadRunThreshold')) or 0.5, 0.05, 0, 1);
		name = 'Run / Walk Threshold';
		desc = 'Controls when your character starts running. Expressed as a fraction of your total movement stick radius.';
	};
	mvmtTurnWithCamera = _{Map(tonumber(GetCVar('GamePadTurnWithCamera')) or 2, {[0] = NEVER, [1] = 'In Combat', [2] = ALWAYS});
		name = 'Turn Character With Camera';
		desc = 'Turn your character facing when you turn your camera angle.';
	};
	mvmtStrafeAngleTravelMacro = _{String(nil);
		name = 'Strafe Angle Macro Condition (Travel)';
		desc = 'Macro condition to override the strafe angle threshold for travel.';
		note = 'Takes the format of...\n'
			.. BLUE'[condition] angle; nil'
			.. '\n...where each condition/angle is separated by a semicolon, and "nil" clears the override.';
		advd = true;
	};
	mvmtStrafeAngleCombatMacro = _{String(nil);
		name = 'Strafe Angle Macro Condition (Combat)';
		desc = 'Macro condition to override the strafe angle threshold for combat.';
		note = 'Takes the format of...\n'
			.. BLUE'[condition] angle; nil'
			.. '\n...where each condition/angle is separated by a semicolon, and "nil" clears the override.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	_( MOUSE_LABEL ); -- Mouse
	--------------------------------------------------------------------------------------------------------
	mouseHandlingEnabled = _{Bool(true);
		name = 'Enable Mouse Handling';
		desc = 'Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.';
		note = 'While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.';
		advd = true;
	};
	mouseHandlingReversed = _{Bool(false);
		name = 'Reverse Mouse Handling';
		desc = 'Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.',
		note = 'Combine with '..BLUE(INTERACT_ON_LEFT_CLICK_TEXT)..' to make left click work similarly to right click without risk of unwanted combat engagements.',
		advd = true;
	};
	mouseFreeCursorReticle = _{Map(0, {[0] = OFF, [1] = VIDEO_OPTIONS_ENABLED, [2] = TARGET});
		name = 'Cursor Reticle Targeting';
		desc = 'Reticle targeting uses free cursor instead of staying center-fixed.';
		note = 'Reticle targeting means anything you place on the ground.';
	};
	mouseHideCursorOnMovement = _{Bool(false);
		name = 'Hide Cursor On Movement';
		desc = 'Cursor hides when you start moving, if free of obstacles.';
		note = 'Requires Settings > Hide Cursor on Stick Input set to None.';
	};
	mouseAlwaysCentered = _{Bool(false);
		name = 'Always Show Mouse Cursor';
		desc = 'Always keep cursor centered and visible when controlling camera.';
	};
	mouseShowCenterTooltip = _{Bool(true);
		name = 'Show Centered Cursor Tooltip';
		desc = 'Show tooltip for mouseover targets when cursor is centered.';
	};
	mouseAutoControlPickup = _{Bool(true);
		name = 'Automatically Control Cursor Pickups';
		desc = 'Automatically control cursor when picking up items.';
		advc = true;
	};
	mouseAutoClearCenter = _{Number(2.0, 0.25, true);
		name = 'Automatic Cursor Timeout';
		desc = 'Time in seconds to automatically hide centered cursor.';
		advd = true;
	};
	mouseFreeCursorEnableTime = _{Number(0.15, 0.05, true);
		name = 'Free Cursor Timein';
		desc = 'Time in seconds to enable free cursor.';
		note = 'Needs to be long enough to press and release the button.';
		advd = true;
	};
	doubleTapTimeout = _{Number(0.25, 0.05, true);
		name = 'Double Tap Timeframe';
		desc = 'Timeframe to toggle the mouse cursor when double-tapping a selected modifier.';
		advd = true;
	};
	doubleTapModifier = _{Select('<none>', '<none>', unpack(MODID_SELECT));
		name = 'Double Tap Modifier';
		desc = 'Which modifier to use to toggle the mouse cursor when double-tapped.';
	};
	--------------------------------------------------------------------------------------------------------
	_'Radial Menus';
	--------------------------------------------------------------------------------------------------------
	radialStickySelect = _{Bool(false);
		name = 'Sticky Selection';
		desc = 'Selecting an item on a ring will stick until another item is chosen.';
	};
	radialClearFocusTime = _{Number(0.5, 0.025);
		name = 'Focus Timeout';
		desc = 'Time to clear focus after intercepting stick input, in seconds.';
	};
	radialScale = _{Number(1, 0.025, true);
		name = 'Ring Scale';
		desc = 'Scale of all radial menus, relative to UI scale.';
		advd = true;
	};
	radialPreferredSize = _{Number(500, 25, true);
		name = 'Ring Size';
		desc = 'Preferred size of radial menus, in pixels.';
		advd = true;
	};
	radialActionDeadzone = _{Range(0.5, 0.05, 0, 1);
		name = 'Deadzone';
		desc = 'Deadzone for simple point-to-select rings.';
	};
	radialCosineDelta = _{Delta(1);
		name = 'Axis Interpretation';
		desc = 'Correlation between stick position and pie selection.';
		note = '+ Normal\n- Inverted';
		advd = true;
	};
	radialPrimaryStick = _{Select('Movement', unpack(STICK_SELECT));
		name = 'Primary Stick';
		desc = 'Stick to use for main radial actions.';
		note = 'Make sure your choice does not conflict with your bindings.';
	};
	radialRemoveButton = _{Button('PADRSHOULDER');
		name = 'Remove Button';
		desc = 'Button used to remove a selected item from an editable ring.';
	};
	--------------------------------------------------------------------------------------------------------
	_'Radial Keyboard';
	--------------------------------------------------------------------------------------------------------
	keyboardEnable = _{Bool(false);
		name = 'Enable';
		desc = 'Enables a radial on-screen keyboard that can be used to type messages.';
	};
	--------------------------------------------------------------------------------------------------------
	_'Raid Cursor';
	--------------------------------------------------------------------------------------------------------
	raidCursorScale = _{Number(1, 0.1);
		name = 'Scale';
		desc = 'Scale of the cursor.';
	};
	raidCursorMode = _{Map(1, {'Redirect', FOCUS, TARGET}),
		name = 'Targeting Mode';
		desc = 'Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.';
		note = 'Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.';
	};
	raidCursorModifier = _{Select('<none>', '<none>', unpack(MODID_EXTEND));
		name = 'Modifier';
		desc = 'Which modifier to use with the movement buttons to move the cursor.';
		note = 'The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.';
	};
	raidCursorUp = _{Button('PADDUP', true);
		name = 'Move Up';
		desc = 'Button to move the cursor up.';
		advd = true;
	};
	raidCursorDown = _{Button('PADDDOWN', true);
		name = 'Move Down';
		desc = 'Button to move the cursor down.';
		advd = true;
	};
	raidCursorLeft = _{Button('PADDLEFT', true);
		name = 'Move Left';
		desc = 'Button to move the cursor left.';
		advd = true;
	};
	raidCursorRight = _{Button('PADDRIGHT', true);
		name = 'Move Right';
		desc = 'Button to move the cursor right.';
		advd = true;
	};
	raidCursorFilter = _{String(nil);
		name = 'Filter Condition';
		desc = 'Filter condition to find raid cursor frames.';
		note = BLUE'node' .. ' is the current frame under scrutinization.';
		advd = true;
	};
	raidCursorWrapDisable = _{Bool(false);
		name = 'Disable Wrapping';
		desc = 'Prevent the cursor from wrapping when navigating.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	_'Interface Cursor';
	--------------------------------------------------------------------------------------------------------
	UIenableCursor = _{Bool(true);
		name = ENABLE;
		desc = 'Enable interface cursor. Disable to use mouse-based interface interaction.';
	};
	UIWrapDisable = _{Bool(false);
		name = 'Disable Wrapping';
		desc = 'Prevent the cursor from wrapping when navigating.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	_'Unit Hotkeys';
	--------------------------------------------------------------------------------------------------------
	unitHotkeyFocusMode = _{Bool(false);
		name = 'Use Focus Mode';
		desc = 'Hotkeys control your focus target instead of your current target.';
	};
	unitHotkeyDefaultMode = _{Bool(false);
		name = 'Default to '..BLUE(GetBindingName('TARGETNEARESTENEMY'));
		desc = 'Hotkeys use '..BLUE(GetBindingName('TARGETNEARESTENEMY'))..' when no target is selected.';
	};
	unitHotkeyNamePlates = _{Bool(true);
		name = 'Show on Name Plates';
		desc = 'Hotkey prompts appear on applicable name plates.';
	};
	unitHotkeyGhostMode = _{Bool(false);
		name = 'Always Show';
		desc = 'Hotkey prompts linger on unit frames after targeting.';
	};
	unitHotkeyGhostAlpha = _{Number(0.5, 0.05, true);
		name = 'Inactive Opacity';
		desc = 'Opacity of inactive hotkey prompts on unit frames after targeting.';
	};
	unitHotkeySize = _{Number(CPAPI.IsClassicEraVersion and 32 or 24, 1);
		name = 'Size';
		desc = 'Size of unit hotkeys, in pixels.';
	};
	unitHotkeyOffsetX = _{Number(0, 1, true);
		name = 'Horizontal Offset';
		desc = 'Horizontal offset of the hotkey prompt position, in pixels.';
		advd = true;
	};
	unitHotkeyOffsetY = _{Number(0, 1, true);
		name = 'Vertical Offset';
		desc = 'Vertical offset of the hotkey prompt position, in pixels.';
		advd = true;
	};
	unitHotkeyTokens = _{String('party1-4; player; raid1-40; boss1-4; arena1-5; party1-4pet; raid1-40target');
		name = 'Unit Pool';
		desc = 'Match criteria for unit pool, each type separated by semicolon.';
		note = 'E.g. '..BLUE('party1-4')..'; '..BLUE('player')..' will match party1, party2, party3, party4, and player.';
		advd = true;
	};
	unitHotkeySet = _{Select('Dynamic', 'Dynamic', 'Left', 'Right', 'Custom');
		name = 'Button Set';
		desc = 'Which button set to use for unit hotkeys.';
		note = 'Dynamic will use the button set that does not conflict with your '..BLUE'L[Target Unit Frames (Hold)]'..' binding.';
	};
	unitHotkeyButton1 = _{Button('PAD1');
		name = 'Combo Button 1';
		desc = 'Button to use for combo hotkey 1.';
		note = 'Requires '..BLUE'L[Button Set]'..' > '..BLUE'L[Custom]'..' to control each button individually.';
	};
	unitHotkeyButton2 = _{Button('PAD2');
		name = 'Combo Button 2';
		desc = 'Button to use for combo hotkey 2.';
		note = 'Requires '..BLUE'L[Button Set]'..' > '..BLUE'L[Custom]'..' to control each button individually.';
	};
	unitHotkeyButton3 = _{Button('PAD3');
		name = 'Combo Button 3';
		desc = 'Button to use for combo hotkey 3.';
		note = 'Requires '..BLUE'L[Button Set]'..' > '..BLUE'L[Custom]'..' to control each button individually.';
	};
	unitHotkeyButton4 = _{Button('PAD4');
		name = 'Combo Button 4';
		desc = 'Button to use for combo hotkey 4.';
		note = 'Requires '..BLUE'L[Button Set]'..' > '..BLUE'L[Custom]'..' to control each button individually.';
	};
	--------------------------------------------------------------------------------------------------------
	_( ACCESSIBILITY_LABEL ); -- Accessibility
	--------------------------------------------------------------------------------------------------------
	autoExtra = _{Bool(true);
		name = 'Automatically Bind Extra Items';
		desc = 'Automatically add tracked quest items and extra spells to main utility ring.';
	};
	autoSellJunk = _{Bool(true);
		name = 'Automatically Sell Junk';
		desc = 'Automatically sell junk when interacting with a merchant.';
	};
	UIscale = _{Number(1, 0.025, true);
		name = 'Global Scale';
		desc = 'Scale of most ConsolePort frames, relative to UI scale.';
		note = 'Action bar is scaled separately.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	_'Power Level';
	--------------------------------------------------------------------------------------------------------
	powerLevelShow = _{Bool(false);
		name = 'Show Gauge';
		desc = 'Display power level for the current active gamepad.';
		note = 'This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.';
	};
	powerLevelShowIcon = _{Bool(true);
		name = 'Show Type Icon';
		desc = 'Display icon next to the power level for the current active gamepad.';
		note = 'Types are PlayStation, Xbox, or Generic.';
	};
	powerLevelShowText = _{Bool(true);
		name = 'Show Status Text';
		desc = 'Display power level status text for the current active gamepad.';
		note = 'Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.';
	};
	--------------------------------------------------------------------------------------------------------
	_( BINDINGS_OPT ); -- Bindings
	--------------------------------------------------------------------------------------------------------
	bindingOverlapEnable = _{Bool(false);
		name = 'Allow Binding Overlap';
		desc = 'Allow binding multiple combos to the same binding.';
		advd = true;
	};
	bindingAllowSticks = _{Bool(false);
		name = 'Allow Radial Bindings';
		desc = 'Allow binding discrete radial stick inputs.';
		advd = true;
	};
	bindingShowExtraBars = _{Bool(false);
		name = 'Show All Action Bars';
		desc = 'Show bonus bar configuration for characters without stances.';
		advd = true;
	};
	bindingDisableQuickAssign = _{Bool(false);
		name = 'Disable Quick Assign';
		desc = 'Disables quick assign for unbound combinations when using the gamepad action bar.';
		note = 'Requires reload.';
		advd = true;
	};
	bindingShowSpellMenuGrid = _{Bool(false);
		name = 'Show Action Bar Grid on Spell Pickup';
		desc = 'Display the action bar grid when picking up a spell on the cursor.';
	};
	disableHotkeyRendering = _{Bool(false);
		name = 'Disable Hotkey Rendering';
		desc = 'Disables customization to hotkeys on regular action bar.';
		advd = true;
	};
	useAtlasIcons = _{Bool(not CPAPI.IsClassicEraVersion);
		name = 'Use Default Hotkey Icons';
		desc = 'Uses the default hotkey icons instead of the custom icons provided by ConsolePort.';
		note = 'Requires reload.';
		hide = CPAPI.IsClassicEraVersion;
	};
	emulatePADPADDLE1 = _{Pseudokey('none');
		name = 'Emulate '..(KEY_PADPADDLE1 or 'Paddle 1');
		desc = 'Keyboard button to emulate the paddle 1 button.';
	};
	emulatePADPADDLE2 = _{Pseudokey('none');
		name = 'Emulate '..(KEY_PADPADDLE2 or 'Paddle 2');
		desc = 'Keyboard button to emulate the paddle 2 button.';
	};
	emulatePADPADDLE3 = _{Pseudokey('none');
		name = 'Emulate '..(KEY_PADPADDLE3 or 'Paddle 3');
		desc = 'Keyboard button to emulate the paddle 3 button.';
	};
	emulatePADPADDLE4 = _{Pseudokey('none');
		name = 'Emulate '..(KEY_PADPADDLE4 or 'Paddle 4');
		desc = 'Keyboard button to emulate the paddle 4 button.';
	};
	interactButton = _{Button('PAD1', true):Set('none', true);
		name = 'Click Override Button';
		desc = 'Button or combination used to click when a given condition applies, but act as a normal binding otherwise.';
		note = 'Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.';
	};
	interactCondition = _{String('[vehicleui] nil; [@target,noharm][@target,noexists][@target,harm,dead] TURNORACTION; nil');
		name = 'Click Override Condition';
		desc = 'Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.';
		note = 'Takes the format of...\n'
			.. BLUE'[condition] bindingID; nil'
			.. '\n...where each condition/binding is separated by a semicolon, and "nil" clears the override.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	_( ADVANCED_OPT ); -- Advanced
	--------------------------------------------------------------------------------------------------------
	actionPageCondition = _{String(nil);
		name = 'Action Page Condition';
		desc = 'Macro condition to evaluate action bar page.';
		advd = true;
	};
	actionPageResponse = _{String(nil);
		name = 'Action Page Response';
		desc = 'Response to condition for custom processing.';
		advd = true;
	};
	classFileOverride = _{String(nil);
		name = 'Override Class File';
		desc = 'Override class theme for interface styling.';
		advd = true;
	};
})  --------------------------------------------------------------------------------------------------------
