local __, db = ...; __ = 1; local Profile = {};
local kSelectAxisOptions = {
	LStickX = 'Left Stick X',
	LStickY = 'Left Stick Y',
	RStickX = 'Right Stick X',
	RStickY = 'Right Stick Y',
	LTrigger = 'Left Trigger',
	RTrigger = 'Right Trigger',
	GStickX = 'Gyro X',
	GStickY = 'Gyro Y',
	PStickX = 'TouchPad X',
	PStickY = 'TouchPad Y',
};
setfenv(__, setmetatable(db('Data'), {__index = _G}));
------------------------------------------------------------------------------------------------------------
-- Gamepad API profile values
------------------------------------------------------------------------------------------------------------
db:Register('Profile', CPAPI.Proxy({
	['Movement Input'] = {
		{	name = 'Movement Deadzone';
			path = 'stickConfigs/<stick:Movement>/deadzone';
			data = Range(0.25, 0.05, 0, 0.95);
			desc = '2D deadzone for movement that takes into account X and Y movement together.';
			note = ('|T%s:128:128:0|t'):format([[Interface\AddOns\ConsolePort_Config\Assets\Deadzone2Da.blp]]);
		};
		{
			name = 'Movement X Axis';
			path = 'stickConfigs/<stick:Movement>/axisX';
			data = Map('LStickX', kSelectAxisOptions);
			desc = 'The analog input for left/right movement.';
		};
		{
			name = 'Movement Y Axis';
			path = 'stickConfigs/<stick:Movement>/axisY';
			data = Map('LStickY', kSelectAxisOptions);
			desc = 'The analog input for forward/back movement.';
		};
	};
	['Camera Input'] = {
		{	name = 'Camera Yaw-Only Deadzone';
			path = 'stickConfigs/<stick:Camera>/deadzoneX';
			data = Range(0.05, 0.05, 0, 0.95);
			desc = 'Yaw-only deadzone for camera, applied before the 2D deadzone.';
			note = ('|T%s:128:128:0|t'):format([[Interface\AddOns\ConsolePort_Config\Assets\DeadzoneXa.blp]]);
		};
		{	name = 'Camera Pitch-Only Deadzone';
			path = 'stickConfigs/<stick:Camera>/deadzoneY';
			data = Range(0.2, 0.05, 0, 0.95);
			desc = 'Pitch-only deadzone for camera, applied before the 2D deadzone.';
			note = ('|T%s:128:128:0|t'):format([[Interface\AddOns\ConsolePort_Config\Assets\DeadzoneYa.blp]]);
		};
		{	name = 'Camera 2D Deadzone';
			path = 'stickConfigs/<stick:Camera>/deadzone';
			data = Range(0.25, 0.05, 0, 0.95);
			desc = '2D deadzone for camera that takes into account pitch and yaw movement together.';
			note = ('|T%s:128:128:0|t'):format([[Interface\AddOns\ConsolePort_Config\Assets\Deadzone2Da.blp]]);
		};
		{
			name = 'Camera Yaw Axis';
			path = 'stickConfigs/<stick:Camera>/axisX';
			data = Map('RStickX', kSelectAxisOptions);
			desc = 'The analog input for left/right Camera Yaw.';
		};
		{
			name = 'Camera Pitch Axis';
			path = 'stickConfigs/<stick:Camera>/axisY';
			data = Map('RStickY', kSelectAxisOptions);
			desc = 'The analog input for up/down Camera Pitch.';
		};
		{
			name = 'Camera Look Yaw Axis';
			path = 'stickConfigs/<stick:Look>/axisX';
			data = Map('GStickX', kSelectAxisOptions);
			desc = 'The analog input for left/right Camera Yaw "look" feature.';
			note = 'Camera Look is a temporary turn of the camera based on the current analog input.';
		};
		{
			name = 'Camera Look Pitch Axis';
			path = 'stickConfigs/<stick:Look>/axisY';
			data = Map('GStickY', kSelectAxisOptions);
			desc = 'The analog input for up/down Camera Pitch "look" feature.';
			note = 'Camera Look is a temporary turn of the camera based on the current analog input.';
		};
	};
}, Profile))

function Profile:GetObject(path)
	for section, fields in pairs(self) do
		for i, field in ipairs(fields) do
			if ( field.path == path ) then
				return field, section, i;
			end
		end
	end
end

function Profile:GetConfiguredValue(path)
	local field = self:GetObject(path)
	if field then
		return field.data:Get()
	end
end