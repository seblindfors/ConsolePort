------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
local DEFAULT_DATA = {
    --------------------------------------------------------------------------------------------------------
    -- Interface cursor:
    disableUI               = {false    ; 'Disable interface cursor'};
    UIleaveCombatDelay      = {.5       ; 'Delay before re-activating UI core after combat'};
    UIholdRepeatDelay       = {.125     ; 'Delay until a D-pad input is repeated (interface)'};
    UIholdRepeatDisable     = {false    ; 'Disable D-pad input repeater'};
    -- Unit hotkey specific:
    unitHotkeySize          = {32       ; 'Size of unit hotkeys (px)'};
    unitHotkeyOffsetX       = {0        ; 'Offset X-placement on unit frames (px)'};
    unitHotkeyOffsetY       = {0        ; 'Offset Y-placement on unit frames (px)'};
    unitHotkeyGhostMode     = {false    ; 'Restore calculated combinations after targeting'};
    unitHotkeyIgnorePlayer  = {false    ; 'Always ignore player regardless of pool'};
}   --------------------------------------------------------------------------------------------------------

local DataAPI, _, db = CPAPI.CreateEventHandler({'Frame', '$parentDataHandler', ConsolePort}), ...

function DataAPI:OnDataLoaded()
	local settings = setmetatable(ConsolePortSettings or {}, {
		__index = function(self, key)
			local var = DEFAULT_DATA[key]
			return var and var[1]
		end;
	})
	db:Register('Settings', settings, true)
	db:Default(settings)
	db:Save('Settings', 'ConsolePortSettings') 
end