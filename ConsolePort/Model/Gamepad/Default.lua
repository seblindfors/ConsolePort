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