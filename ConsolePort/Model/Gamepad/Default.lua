select(2, ...)('Gamepad/Devices/Default', {
	Name = 'Default';
	Config = {
		axisConfigs = {
			{
				axis = 'LStickX';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'LStickRight';
				buttonNeg = 'LStickLeft';
			};
			{
				axis = 'LStickY';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'LStickUp';
				buttonNeg = 'LStickDown';
			};
			{
				axis = 'RStickX';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'RStickRight';
				buttonNeg = 'RStickLeft';
			};
			{
				axis = 'RStickY';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'RStickUp';
				buttonNeg = 'RStickDown';
			};
			{
				axis = 'GStickX';
				deadzone = 0.05;
			};
			{
				axis = 'GStickY';
				deadzone = 0.05;
			};
			{
				axis = 'LTrigger';
				deadzone = 0.12;
				buttonThreshold = 0.5;
				buttonPos = 'LTrigger';
			};
			{
				axis = 'RTrigger';
				deadzone = 0.12;
				buttonThreshold = 0.5;
				buttonPos = 'RTrigger';
			};
		};
		stickConfigs = {
			{
				stick = 'Left';
				axisX = 'LStickX';
				axisY = 'LStickY';
				deadzone = 0.25;
			};
			{
				stick = 'Right';
				axisX = 'RStickX';
				axisY = 'RStickY';
				deadzone = 0.25;
			};
			{
				stick = 'Gyro';
				axisX = 'GStickX';
				axisY = 'GStickY';
				deadzone = 0.25;
			};
			{
				stick = 'Movement';
				axisX = 'LStickX';
				axisY = 'LStickY';
				deadzone = 0.25;
			};
			{
				stick = 'Camera';
				axisX = 'RStickX';
				axisY = 'RStickY';
				deadzone = 0.25;
			};
			{
				stick = 'Cursor';
				axisX = 'RStickX';
				axisY = 'RStickY';
				deadzone = 0.25;
			};
		};
	};
})

GamepadInfo = {
	{"Up",          "PADDUP", }, -- 1
	{"Right",       "PADDRIGHT", }, -- 2
	{"Down",        "PADDDOWN", }, -- 3
	{"Left",        "PADDLEFT", }, -- 4
	{"Face1",       "PAD1", }, -- 5
	{"Face2",       "PAD2", }, -- 6
	{"Face3",       "PAD3", }, -- 7
	{"Face4",       "PAD4", }, -- 8
	{"Face5",       "PAD5", }, -- 9
	{"Face6",       "PAD6", }, -- 10
	{"LStickIn",    "PADLSTICK", }, -- 11
	{"RStickIn",    "PADRSTICK", }, -- 12
	{"LShoulder",   "PADLSHOULDER", }, -- 13
	{"RShoulder",   "PADRSHOULDER", }, -- 14
	{"LTrigger",    "PADLTRIGGER", }, -- 15
	{"RTrigger",    "PADRTRIGGER", }, -- 16
	{"LStickUp",    "PADLSTICKUP", }, -- 17
	{"LStickRight", "PADLSTICKRIGHT", }, -- 18
	{"LStickDown",  "PADLSTICKDOWN", }, -- 19
	{"LStickLeft",  "PADLSTICKLEFT", }, -- 20
	{"RStickUp",    "PADRSTICKUP", }, -- 21
	{"RStickRight", "PADRSTICKRIGHT", }, -- 22
	{"RStickDown",  "PADRSTICKDOWN", }, -- 23
	{"RStickLeft",  "PADRSTICKLEFT", }, -- 24
	{"Paddle1",     "PADPADDLE1", }, -- 25
	{"Paddle2",     "PADPADDLE2", }, -- 26
	{"Paddle3",     "PADPADDLE3", }, -- 27
	{"Paddle4",     "PADPADDLE4", }, -- 28
	{"Forward",     "PADFORWARD", }, -- 29
	{"Back",        "PADBACK", }, -- 30
	{"System",      "PADSYSTEM", }, -- 31
	{"Social",      "PADSOCIAL", }, -- 32
}