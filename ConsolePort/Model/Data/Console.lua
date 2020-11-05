local unpack, __, db = unpack, ...; __ = 1;
setfenv(__, setmetatable(db('Data'), {__index = _G}));
------------------------------------------------------------------------------------------------------------
-- Blizzard console variables
------------------------------------------------------------------------------------------------------------
db:Register('Console', {
	--------------------------------------------------------------------------------------------------------
	-- Emulation:
	--------------------------------------------------------------------------------------------------------
	Emulation = {
		{	cvar = 'GamePadEmulateShift';
			type = Button;
			name = 'Emulate Shift';
			desc = 'Button that emulates the Shift key.';
			note = 'Recommended as first choice modifier.';
		};
		{	cvar = 'GamePadEmulateCtrl';
			type = Button;
			name = 'Emulate Ctrl';
			desc = 'Button that emulates the Ctrl key.';
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
			note = 'This key can be replaced by binding Toggle Game Menu.';
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
	Handling = {
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
		{	cvar = 'GamePadCameraYawSpeed';
			type = Number(1, 0.1);
			name = 'Camera Yaw Speed';
			desc = 'Yaw speed of camera - turning left/right.';
		};
		{	cvar = 'GamePadCameraPitchSpeed';
			type = Number(1, 0.1);
			name = 'Camera Pitch Speed';
			desc = 'Pitch speed of camera - moving up/down.';
		};
	};
	--------------------------------------------------------------------------------------------------------
	-- Camera:
	--------------------------------------------------------------------------------------------------------
	Camera = {
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
			note = 'Expressed in degrees, from looking straight forward.';
		};
	};
})

--[[

	GamePadCursorCentering = "When using GamePad, center the cursor",
	GamePadCursorAutoDisableJump = "GamePad cursor control will auto-disable when you jump",
	GamePadCursorOnLogin = "Enable GamePad cursor control on login and character screens",
	GamePadCursorAutoEnable = "",

	GamePadCursorCenteredEmulation = "When cursor is centered for GamePad movement, also emulate mouse clicks",
	GamePadTankTurnSpeed = "If non-zero, character turns like a tank from GamePad movement",
	GamePadFaceAngleThreshold = "Angle threshold for strafing instead of facing movement direction",
	GamePadForceXInput = "Force game to use XInput, rather than a newer, more advanced api",
	GamePadSingleActiveID = "ID of single GamePad device to use. 0 = Use all devices' combined input",
	GamePadFaceMovement = "Sets if character should face direction of GamePad movement",
	GamePadCursorAutoDisableSticks = "GamePad cursor control will auto-disable on stick input (0=none, 1=movement, 2=movement+cursor)",
	GamePadAbbreviatedBindingReverse = "Display main binding button first so it's visible even if truncated on action bar",
	GamePadListDevices = "List all connected GamePad devices in the console",
]]--