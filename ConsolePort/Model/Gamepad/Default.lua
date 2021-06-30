select(2, ...)('Gamepad/Devices/Default', {
	Name = 'Default';
	Config = {
		axisConfigs = {
			[1] = {
				axis = 'LStickX';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'LStickRight';
				buttonNeg = 'LStickLeft';
			};
			[2] = {
				axis = 'LStickY';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'LStickUp';
				buttonNeg = 'LStickDown';
			};
			[3] = {
				axis = 'RStickX';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'RStickRight';
				buttonNeg = 'RStickLeft';
			};
			[4] = {
				axis = 'RStickY';
				deadzone = 0.05;
				buttonThreshold = 0.5;
				buttonPos = 'RStickUp';
				buttonNeg = 'RStickDown';
			};
			[5] = {
				axis = 'GStickX';
				deadzone = 0.05;
			};
			[6] = {
				axis = 'GStickY';
				deadzone = 0.05;
			};
			[7] = {
				axis = 'LTrigger';
				deadzone = 0.12;
				buttonThreshold = 0.5;
				buttonPos = 'LTrigger';
			};
			[8] = {
				axis = 'RTrigger';
				deadzone = 0.12;
				buttonThreshold = 0.5;
				buttonPos = 'RTrigger';
			};
		};
		stickConfigs = {
			[1] = {
				stick = 'Left';
				axisX = 'LStickX';
				axisY = 'LStickY';
				deadzone = 0.25;
			};
			[2] = {
				stick = 'Right';
				axisX = 'RStickX';
				axisY = 'RStickY';
				deadzone = 0.25;
			};
			[3] = {
				stick = 'Gyro';
				axisX = 'GStickX';
				axisY = 'GStickY';
				deadzone = 0.25;
			};
			[4] = {
				stick = 'Movement';
				axisX = 'LStickX';
				axisY = 'LStickY';
				deadzone = 0.25;
			};
			[5] = {
				stick = 'Camera';
				axisX = 'RStickX';
				axisY = 'RStickY';
				deadzone = 0.25;
			};
			[6] = {
				stick = 'Cursor';
				axisX = 'RStickX';
				axisY = 'RStickY';
				deadzone = 0.25;
			};
		};
	};
})