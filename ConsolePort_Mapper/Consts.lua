local env = ConsolePortConfig:GetEnvironment()
local Consts = {}; env.MapperConsts = Consts;

Consts.Buttons = {
	'Up';
	'Right';
	'Down';
	'Left';
	'Face1';
	'Face2';
	'Face3';
	'Face4';
	'Face5';
	'Face6';
	'LStickIn';
	'RStickIn';
	'LShoulder';
	'RShoulder';
	'LTrigger';
	'RTrigger';
	'LStickUp';
	'LStickRight';
	'LStickDown';
	'LStickLeft';
	'RStickUp';
	'RStickRight';
	'RStickDown';
	'RStickLeft';
	'Paddle1';
	'Paddle2';
	'Paddle3';
	'Paddle4';
	'Forward';
	'Back';
	'System';
	'Social';
}

Consts.Axes = {
	'LStickX';
	'LStickY';
	'RStickX';
	'RStickY';
	'GStickX';
	'GStickY';
	'LTrigger';
	'RTrigger';
}

Consts.Sticks = {
	'Left';
	'Right';
	'Gyro';
	'Movement';
	'Camera';
	'Cursor';
}

Consts.Labels = {
	'Generic';
	'Letters';
	'Reverse';
	'Shapes';
}

-- Append 'unassigned' value to each enum for the config.
do local unassigned = '|cffffffffN/A|r';
	for _, enum in pairs(Consts) do
		tinsert(enum, unassigned)
	end
	Consts.Unassigned = unassigned;
end

Consts.ConfigGroups = {
	'configID';
	'rawAxisMappings';
	'rawButtonMappings';
	'axisConfigs';
	'stickConfigs'
}