local function hold(binding) return ('%s (Hold)'):format(binding) end;
local extra = BINDING_NAME_EXTRAACTIONBUTTON1:gsub('%d', ''):trim()
select(2, ...):Register('Bindings', {
	-- Mouse bindings
	{name = KEY_BUTTON1,                      binding = 'CAMERAORSELECTORMOVE'};
	{name = KEY_BUTTON2,                      binding = 'TURNORACTION'};
	-- Targeting
	{name = hold(FOCUS_CAST_KEY_TEXT),        binding = 'CLICK ConsolePortFocusButton:LeftButton'};
	{name = hold'Target Unit Frames',        binding = 'CLICK ConsolePortEasyMotionButton:LeftButton'};
	{name = 'Toggle Raid Cursor',             binding = 'CLICK ConsolePortRaidCursorToggle:LeftButton'};
	{name = 'Focus Raid Cursor',              binding = 'CLICK ConsolePortRaidCursorFocus:LeftButton'};
	{name = 'Target Raid Cursor',             binding = 'CLICK ConsolePortRaidCursorTarget:LeftButton'};
	-- Utility
	{name = 'Utility Ring',                   binding = 'CLICK ConsolePortUtilityToggle:LeftButton'};
--	{name = 'Pet Ring',                       binding = 'CLICK ConsolePortBarPet:MiddleButton'};
--	{name = L.CP_TOGGLEADDON,                 binding = 'CLICK ConsolePortLoader:LeftButton'};
	{name = extra,  binding = 'EXTRAACTIONBUTTON1'};
	-- Pager

	{name = hold(BINDING_NAME_ACTIONPAGE2),   binding = 'CLICK ConsolePortPager:2'};
	{name = hold(BINDING_NAME_ACTIONPAGE3),   binding = 'CLICK ConsolePortPager:3'};
	{name = hold(BINDING_NAME_ACTIONPAGE4),   binding = 'CLICK ConsolePortPager:4'};
	{name = hold(BINDING_NAME_ACTIONPAGE5),   binding = 'CLICK ConsolePortPager:5'};
	{name = hold(BINDING_NAME_ACTIONPAGE6),   binding = 'CLICK ConsolePortPager:6'};
})