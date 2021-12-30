local __, db = ...; __ = 1; local Profile = {};
setfenv(__, setmetatable(db('Data'), {__index = _G}));
------------------------------------------------------------------------------------------------------------
-- Gamepad API profile values
------------------------------------------------------------------------------------------------------------
db:Register('Profile', {
	Deadzones = {
		{	name = 'Movement';
			path = 'stickConfigs/<stick:Movement>/deadzone';
			data = Range(0.25, 0.01, 0, 1);
		};
	};
})