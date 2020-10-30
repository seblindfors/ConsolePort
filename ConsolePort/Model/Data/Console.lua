local unpack, __, db = unpack, ...; __ = 1;
setfenv(__, setmetatable(db('Data'), {__index = _G}));
------------------------------------------------------------------------------------------------------------
-- Blizzard console variables
------------------------------------------------------------------------------------------------------------
db:Register('Console', {
	--------------------------------------------------------------------------------------------------------
	-- Bindings:
	--------------------------------------------------------------------------------------------------------
	{	cvar = 'GamePadEmulateShift';
		type = Button;
		name = 'Emulate Shift';
		desc = 'Button that should emulate the Shift key.';
	};
	{	cvar = 'GamePadEmulateCtrl';
		type = Button;
		name = 'Emulate Ctrl';
		desc = 'Button that should emulate the Ctrl key.';
	};
	{ 	cvar = 'GamePadEmulateAlt';
		type = Button;
		name = 'Emulate Alt';
		desc = 'Button that should emulate the Alt key.';
	};
	{	cvar = 'GamePadEmulateEsc';
		type = Button;
		name = 'Emulate Esc';
		desc = 'Button that should emulate the Esc key.';
	};
	{	cvar = 'GamePadCursorLeftClick';
		type = Button;
		name = KEY_BUTTON1;
		desc = 'Button that should emulate mouse Left Click while controlling the mouse cursor.';
	};
	{	cvar = 'GamePadCursorRightClick';
		type = Button;
		name = KEY_BUTTON2;
		desc = 'Button that should emulate mouse Right Click while controlling the mouse cursor.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Cursor:
	--------------------------------------------------------------------------------------------------------
	{	cvar = 'GamePadCursorSpeedMax';
		type = Number(1, 0.1);
		name = 'Cursor Max Speed';
		desc = 'Top speed of cursor movement.';
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