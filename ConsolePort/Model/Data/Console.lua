-- Consts
local MOTION_SICKNESS_CHARACTER_CENTERED = MOTION_SICKNESS_CHARACTER_CENTERED or 'Keep Character Centered';
local MOTION_SICKNESS_REDUCE_CAMERA_MOTION = MOTION_SICKNESS_REDUCE_CAMERA_MOTION or 'Reduce Camera Motion';
local SOFT_TARGET_DEVICE_OPTS = {[0] = OFF, [1] = 'Gamepad', [2] = 'KBM', [3] = ALWAYS};
local SOFT_TARGET_ARC_ALLOWANCE = {[0] = 'Front', [1] = 'Cone', [2] = 'Around'};
local BLUE = GenerateClosure(ColorMixin.WrapTextInColorCode, BLUE_FONT_COLOR)
local unpack, _, db = unpack, ...; local Console = {}; db('Data')();
------------------------------------------------------------------------------------------------------------
-- Blizzard console variables
------------------------------------------------------------------------------------------------------------
db:Register('Console', CPAPI.Proxy({
	--------------------------------------------------------------------------------------------------------
	Emulation = {
	--------------------------------------------------------------------------------------------------------
		{	cvar = 'GamePadEmulateShift';
			type = Button;
			name = 'Emulate Shift';
			desc = 'Button that emulates the '..BLUE'Shift'..' key. Hold this button to swap your binding set.';
			note = 'Recommended as first choice modifier.';
		};
		{	cvar = 'GamePadEmulateCtrl';
			type = Button;
			name = 'Emulate Ctrl';
			desc = 'Button that emulates the '..BLUE'Ctrl'..' key. Hold this button to swap your binding set.';
			note = 'Recommended as second choice modifier.';
		};
		{ 	cvar = 'GamePadEmulateAlt';
			type = Button;
			name = 'Emulate Alt';
			desc = 'Button that emulates the '..BLUE'Alt'..' key.';
			note = 'Only recommended for super users.';
		};
		{	cvar = 'GamePadCursorLeftClick';
			type = Button;
			name = KEY_BUTTON1;
			desc = 'Button that emulates '..BLUE'Left Click'..' while controlling the mouse cursor.';
			note = 'Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.';
		};
		{	cvar = 'GamePadCursorRightClick';
			type = Button;
			name = KEY_BUTTON2;
			desc = 'Button that emulates '..BLUE'Right Click'..' while controlling the mouse cursor.';
			note = 'Used for interacting with the world, at a center-fixed position.';
		};
		{	cvar = 'GamePadEmulateTapWindowMs';
			type = Number(350, 25);
			name = 'Emulated Modifier Tap Window';
			desc = 'Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.';
			note = 'Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	Cursor = {
	--------------------------------------------------------------------------------------------------------
		{	cvar = 'interactOnLeftClick';
			type = Bool(false);
			name = INTERACT_ON_LEFT_CLICK_TEXT;
			desc = OPTION_TOOLTIP_INTERACT_ON_LEFT_CLICK;
			note = 'Affects both mouse and gamepad.';
		};
		{	cvar = 'HardwareCursor';
			type = Bool(true);
			name = 'Use Hardware Mouse Cursor';
			desc = 'Use the hardware cursor provided by the operating system.';
			note = 'Disable if your mouse cursor is invisible.';
		};
		{	cvar = 'GamePadCursorAutoDisableJump';
			type = Bool(true);
			name = 'Hide Cursor on Jump';
			desc = 'Disable free-roaming mouse cursor when you jump.';
		};
		{	cvar = 'GamePadCursorAutoDisableSticks';
			type = Map(2, {[0] = NONE, [1] = TUTORIAL_TITLE2, [2] = STATUS_TEXT_BOTH});
			name = 'Hide Cursor on Stick Input';
			desc = 'Disable free-roaming mouse cursor when you use your sticks.';
			note = 'When set to both sticks, cursor only disables when both sticks are used together.';
		};
		{	cvar = 'CursorCenteredYPos';
			type = Range(0.6, 0.025, 0, 1);
			name = 'Cursor Center Position';
			desc = 'Vertical position of centered cursor & targeting, as fraction of screen height.';
		};
		{	cvar = 'GamePadCursorSpeedStart';
			type = Number(0.1, 0.05);
			name = 'Cursor Start Speed';
			desc = 'Speed of cursor when it starts moving.';
		};
		{	cvar = 'GamePadCursorSpeedAccel';
			type = Number(2, 0.1);
			name = 'Cursor Acceleration';
			desc = 'Acceleration of cursor per second as it continues to move.';
		};
		{	cvar = 'GamePadCursorSpeedMax';
			type = Number(1, 0.1);
			name = 'Cursor Max Speed';
			desc = 'Top speed of cursor movement.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	Camera = {
	--------------------------------------------------------------------------------------------------------
		{	cvar = 'CameraKeepCharacterCentered';
			type = Bool(true);
			name = MOTION_SICKNESS_CHARACTER_CENTERED;
			desc = 'Keeps your character centered to reduce motion sickness.';
		};
		{	cvar = 'CameraReduceUnexpectedMovement';
			type = Bool(true);
			name = MOTION_SICKNESS_REDUCE_CAMERA_MOTION;
			desc = 'Reduces unexpected camera movement to reduce motion sickness.';
		};
		{	cvar = 'test_cameraDynamicPitch';
			type = Bool(false);
			name = 'Dynamic Pitch';
			desc = 'Pitches the camera upwards as you zoom out.';
			note = ('Incompatible with %s.'):format(MOTION_SICKNESS_CHARACTER_CENTERED);
		};
		{	cvar = 'test_cameraOverShoulder';
			type = Range(0, 0.5, -1.0, 1.0);
			name = 'Over Shoulder';
			desc = 'Offsets the camera horizontally from your character, for a more cinematic view.';
			note = ('Incompatible with %s.'):format(MOTION_SICKNESS_CHARACTER_CENTERED);
		};
		{	cvar = 'CameraFollowOnStick';
			type = Bool(false);
			name = 'Follow On A Stick (FOAS)';
			desc = 'Auto-adjusts your camera, allowing you to control movement with a single stick.';
			note = ('|T%s:128:128:0|t'):format([[Interface\AddOns\ConsolePort_Config\Assets\jose.blp]]);
		};
		{	cvar = 'CameraFollowGamepadAdjustDelay';
			type = Number(1, 0.25);
			name = 'FOAS Adjust Delay';
			desc = 'Delay before starting to adjust angle when camera control is idle, in seconds.';
		};
		{	cvar = 'CameraFollowGamepadAdjustEaseIn';
			type = Number(1, 0.25);
			name = 'FOAS Adjust Ease In';
			desc = 'The time it takes to transition from idle camera control to auto-adjustment (FOAS).';
		};
		{
			cvar = 'GamePadCameraLookMaxYaw';
			type = Range(0, 15, -180, 180);
			name = 'Camera Look Max Yaw';
			desc = 'Maximum Yaw adjust for the camera "look" feature.';
			note = 'Camera Look is a temporary turn of the camera based on the current analog input.';
		};
		{
			cvar = 'GamePadCameraLookMaxPitch';
			type = Range(0, 5, 0, 90);
			name = 'Camera Look Max Pitch';
			desc = 'Maximum Pitch adjust for the camera "look" feature.';
			note = 'Camera Look is a temporary turn of the camera based on the current analog input.';
		};
		{	cvar = 'GamePadCameraYawSpeed';
			type = Range(1, 0.25, -4.0, 4.0);
			name = 'Camera Yaw Speed';
			desc = 'Yaw speed of camera - turning left/right.';
			note = 'Choose a negative value to invert the axis.';
		};
		{	cvar = 'GamePadCameraPitchSpeed';
			type = Range(1, 0.25, -4.0, 4.0);
			name = 'Camera Pitch Speed';
			desc = 'Pitch speed of camera - moving up/down.';
			note = 'Choose a negative value to invert the axis.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	System = {
	--------------------------------------------------------------------------------------------------------
		{	cvar = 'synchronizeSettings';
			type = Bool(true);
			name = 'Synchronize Settings';
			desc = 'Whether client settings should be saved to the server.';
			note = 'Master setting for Synchronize Bindings, Synchronize Config and Synchronize Macros.';
		};
		{	cvar = 'synchronizeBindings';
			type = Bool(true);
			name = 'Synchronize Bindings';
			desc = 'Whether client keybindings should be saved to the server.';
		};
		{	cvar = 'synchronizeConfig';
			type = Bool(true);
			name = 'Synchronize Config';
			desc = 'Whether to save character- and account-scoped variables to the server.';
		};
		{	cvar = 'synchronizeMacros';
			type = Bool(true);
			name = 'Synchronize Macros';
			desc = 'Whether client macros should be saved to the server.';
		};
		{	cvar = 'GamePadOverlapMouseMs';
			type = Number(2000, 100);
			name = 'Combined Input Overlap Time';
			desc = 'Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	Interact = {
	--------------------------------------------------------------------------------------------------------
		{	cvar = 'SoftTargetInteract';
			type = Map(0, SOFT_TARGET_DEVICE_OPTS);
			name = 'Enable Interact Key';
			desc = 'Enable interact key to interact with objects and creatures in the game world.';
			note = ('To interact with a target, use the binding %s.'):format(BLUE_FONT_COLOR:WrapTextInColorCode(BINDING_NAME_INTERACTTARGET));
		};
		{	cvar = 'SoftTargetInteractArc';
			type = Map(0, SOFT_TARGET_ARC_ALLOWANCE);
			name = 'Arc Allowance';
			desc = 'Area where the interact key can find a suitable target.';
		};
		{	cvar = 'SoftTargetInteractRange';
			type = Range(10, 1, 1, 45);
			name = 'Target Range';
			desc = 'Controls the cutoff range where an interactable target or object can be found.';
			note = 'Does not affect actual ability to interact with the target, which may have a different range.';
		};
		{	cvar = 'SoftTargetInteractRangeIsHard';
			type = Bool(false);
			name = 'Target Range Hard Cutoff';
			desc = 'Sets if range should be a hard cutoff, even for something you can interact with.';
		};
		{	cvar = 'SoftTargetIconInteract';
			type = Bool(true);
			name = 'Show Target Icon';
			desc = 'Show icon above the current interactable target.';
		};
		{	cvar = 'SoftTargetIconGameObject';
			type = Bool(true);
			name = 'Show Object Icon';
			desc = 'Show icon above the current interactable object.';
		};
		{	cvar = 'SoftTargetTooltipInteract';
			type = Bool(false);
			name = 'Show Tooltip';
			desc = 'Show tooltip for interactables.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	Tooltips = {
	--------------------------------------------------------------------------------------------------------
		{	cvar = 'SoftTargetTooltipDurationMs';
			type = Number(2000, 250, true);
			name = 'Automatic Tooltip Duration';
			desc = 'Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.';
		};
		{	cvar = 'SoftTargetTooltipLocked';
			type = Bool(false);
			name = 'Lock Automatic Tooltip';
			desc = 'Always show tooltip for an automatically acquired target, as long as it exists.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	Touchpad = {
	--------------------------------------------------------------------------------------------------------
		{	cvar = 'GamePadTouchCursorEnable';
			type = Bool(false);
			name = 'Enable Touchpad Cursor';
			desc = 'Allows the use of the touchpad to control cursor movement.';
		};
		{	cvar = 'GamePadTouchCursorMoveThreshold';
			type = Number(0.042, 0.002, true);
			name = 'Cursor Move Threshold';
			desc = 'Change before touchpad moves the cursor.';
			note = 'Larger value for easier taps.';
		};
		{	cvar = 'GamePadTouchCursorAccel';
			type = Number(1.0, 0.25, true);
			name = 'Cursor Acceleration';
			desc = 'Cursor acceleration for touchpad control.';
		};
		{	cvar = 'GamePadTouchCursorSpeed';
			type = Number(1.0, 0.25, true);
			name = 'Cursor Speed';
			desc = 'Cursor speed for touchpad control.';
		};
		{	cvar = 'GamePadTouchTapButtons';
			type = Bool(false);
			name = 'Touch Tap Buttons';
			desc = 'Enable touch tap to press touchpad buttons.';
			note = 'When enabled, a tap will act as a button press.';
		};
		{	cvar = 'GamePadTouchTapMaxMs';
			type = Number(200, 50, true);
			name = 'Touch Tap Max Time';
			desc = 'Max time for a touch to register a tap/click, in milliseconds.';
		};
		{	cvar = 'GamePadTouchTapOnlyClick';
			type = Bool(false);
			name = 'Touch Tap Exclusive Click';
			desc = 'Only use taps for cursor clicks, do not use tap presses.';
			note = 'When disabled, a button press will also act as a cursor click.';
		};
		{	cvar = 'GamePadTouchTapRightClick';
			type = Bool(false);
			name = 'Touch Tap Right Click';
			desc = 'Taps for cursor clicks are right clicks instead of left.';
		};
	};
}, Console))

function Console:GetMetadata(key)
	for set, cvars in pairs(self) do
		for i, data in ipairs(cvars) do
			if (data.cvar == key) then
				return data;
			end
		end
	end
end

function Console:GetEmulationForButton(button)
	if (button == 'none') then return end
	for i, data in ipairs(self.Emulation) do
		if (GetCVar(data.cvar) == button) then
			return data;
		end
	end
end

--[[ unhandled:
	
	GamePadCursorCentering = "When using GamePad, center the cursor",
	GamePadCursorOnLogin = "Enable GamePad cursor control on login and character screens",
	GamePadCursorAutoEnable = "",

	GamePadCursorCenteredEmulation = "When cursor is centered for GamePad movement, also emulate mouse clicks",
	GamePadTankTurnSpeed = "If non-zero, character turns like a tank from GamePad movement",
	GamePadSingleActiveID = "ID of single GamePad device to use. 0 = Use all devices' combined input",
	GamePadAbbreviatedBindingReverse = "Display main binding button first so it's visible even if truncated on action bar",
	GamePadListDevices = "List all connected GamePad devices in the console",
]]--