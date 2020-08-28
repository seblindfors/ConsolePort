------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
local DEFAULT_DATA = {
    --------------------------------------------------------------------------------------------------------
    -- Interface cursor:
    UIdisableCursor         = {false    ; 'Disable interface cursor'};
    UIleaveCombatDelay      = {.5       ; 'Delay before re-activating UI core after combat'};
    UIholdRepeatDelay       = {.125     ; 'Delay until a D-pad input is repeated (interface)'};
    UIholdRepeatDisable     = {false    ; 'Disable D-pad input repeater'};
    UImodifierCommands      = {'Shift'  ; 'Which modifier to use for modified commands'};
    -- Unit hotkey specific:
    unitHotkeySize          = {32       ; 'Size of unit hotkeys (px)'};
    unitHotkeyOffsetX       = {0        ; 'Offset X-placement on unit frames (px)'};
    unitHotkeyOffsetY       = {0        ; 'Offset Y-placement on unit frames (px)'};
    unitHotkeyGhostMode     = {false    ; 'Restore calculated combinations after targeting'};
    unitHotkeyIgnorePlayer  = {false    ; 'Always ignore player regardless of pool'};
    -- Structures:
    UICursor = {{
        LeftClick  = 'PAD1'; -- cross
        RightClick = 'PAD2'; -- circle
        Special    = 'PAD4'; -- triangle
    }; 'Cursor actions'};
}   --------------------------------------------------------------------------------------------------------

CPAPI.Lock(DEFAULT_DATA)
for var, data in pairs(DEFAULT_DATA) do
    if (type(data[1]) == 'table') then
        CPAPI.Lock(data[1])
    end
end

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