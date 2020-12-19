local unpack, __, db = unpack, ...; __ = 1; local Console = {};
setfenv(__, setmetatable(db('Data'), {__index = _G}));
------------------------------------------------------------------------------------------------------------
-- Blizzard console variables
------------------------------------------------------------------------------------------------------------
db:Register('Console', setmetatable({
	--------------------------------------------------------------------------------------------------------
	-- Emulation:
	--------------------------------------------------------------------------------------------------------
	Emulation = {
		{	cvar = 'GamePadEmulateShift';
			type = Button;
			name = 'Emulate Shift';
			desc = 'Button that emulates the Shift key. Hold this button to swap your binding set.';
			note = 'Recommended as first choice modifier.';
		};
		{	cvar = 'GamePadEmulateCtrl';
			type = Button;
			name = 'Emulate Ctrl';
			desc = 'Button that emulates the Ctrl key. Hold this button to swap your binding set.';
			note = 'Recommended as second choice modifier.';
		};
		{ 	cvar = 'GamePadEmulateAlt';
			type = Button;
			name = 'Emulate Alt';
			desc = 'Button that emulates the Alt key.';
			note = 'Only recommended for super users.';
		};
		{	cvar = 'GamePadEmulateEsc';
			type = Button;
			name = 'Emulate Esc';
			desc = 'Button that emulates the Esc key.';
			note = 'This key can be replaced by binding Toggle Game Menu. This emulation is not necessary.';
		};
		{	cvar = 'GamePadCursorLeftClick';
			type = Button;
			name = KEY_BUTTON1;
			desc = 'Button that emulates Left Click while controlling the mouse cursor.';
			note = 'Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.';
		};
		{	cvar = 'GamePadCursorRightClick';
			type = Button;
			name = KEY_BUTTON2;
			desc = 'Button that emulates Right Click while controlling the mouse cursor.';
			note = 'Used for interacting with the world, at a center-fixed position.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	-- Handling:
	--------------------------------------------------------------------------------------------------------
	Cursor = {
		{	cvar = 'GamePadCursorAutoDisableJump';
			type = Bool(true);
			name = 'Hide Cursor on Jump';
			desc = 'Disable free-roaming mouse cursor when you jump.';
		};
		{	cvar = 'GamePadCursorAutoDisableSticks';
			type = Select(2, 2):SetRawOptions({[0] = NONE, [1] = TUTORIAL_TITLE2, [2] = STATUS_TEXT_BOTH});
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
	-- Controls:
	--------------------------------------------------------------------------------------------------------
	Controls = {
		{	cvar = 'GamePadFaceMovement';
			type = Bool(true);
			name = 'Face Movement Direction';
			desc = 'Separates character movement from camera movement.';
			note = 'Your character will strafe while moving forward, and follow your movement stick when moving backwards.';
		};
		{	cvar = 'GamePadFaceAngleThreshold';
			type = Range(115, 5, 0, 180);
			name = 'Face Movement Threshold';
			desc = 'Controls when your character transitions from strafing to following your movement stick.';
			note = 'Expressed in degrees, from looking straight forward. Max value is recommended for tanking.';
		};
		{	cvar = 'GamePadCameraYawSpeed';
			type = Number(1, 0.1);
			name = 'Camera Yaw Speed';
			desc = 'Yaw speed of camera - turning left/right.';
			note = 'Choose a negative value to invert the axis.';
		};
		{	cvar = 'GamePadCameraPitchSpeed';
			type = Number(1, 0.1);
			name = 'Camera Pitch Speed';
			desc = 'Pitch speed of camera - moving up/down.';
			note = 'Choose a negative value to invert the axis.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	-- Camera:
	--------------------------------------------------------------------------------------------------------
	Camera = {
		{	cvar = 'CameraKeepCharacterCentered';
			type = Bool;
			name = MOTION_SICKNESS_CHARACTER_CENTERED;
			desc = 'Keeps your character centered to reduce motion sickness.';
		};
		{	cvar = 'CameraReduceUnexpectedMovement';
			type = Bool;
			name = MOTION_SICKNESS_REDUCE_CAMERA_MOTION;
			desc = 'Reduces unexpected camera movement to reduce motion sickness.';
		};
		{	cvar = 'test_cameraDynamicPitch';
			type = Bool;
			name = 'Dynamic Pitch';
			desc = 'Pitches the camera upwards as you zoom out.';
			note = ('Incompatible with %s.'):format(MOTION_SICKNESS_CHARACTER_CENTERED);
		};
		{	cvar = 'CameraFollowOnStick';
			type = Bool;
			name = 'Follow On A Stick';
			desc = ('|T%s:128:128:0|t'):format([[Interface\AddOns\ConsolePort_Config\Assets\jose.blp]]);
		};
		{	cvar = 'test_cameraOverShoulder';
			type = Number(0, 0.5);
			name = 'Over Shoulder';
			desc = 'Offsets the camera horizontally from your character, for a more cinematic view.';
			note = ('Incompatible with %s.'):format(MOTION_SICKNESS_CHARACTER_CENTERED);
		};
	};
}, {
	__index = Console;
}))

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
	GamePadForceXInput = "Force game to use XInput, rather than a newer, more advanced api",
	GamePadSingleActiveID = "ID of single GamePad device to use. 0 = Use all devices' combined input",
	GamePadAbbreviatedBindingReverse = "Display main binding button first so it's visible even if truncated on action bar",
	GamePadListDevices = "List all connected GamePad devices in the console",
]]--