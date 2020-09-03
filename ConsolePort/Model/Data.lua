------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
local DATA, DESC = 1, 2; local DEFAULT_DATA = {
    --------------------------------------------------------------------------------------------------------
    -- Action page handling:
    actionPageCondition     = {''       ; 'Macro condition to evaluate action bar page'};
    actionPageResponse      = {''       ; 'Response to condition for custom processing'};
    -- Radial:
    radialActionDeadzone    = {0.5      ; 'Deadzone for simple pie menus'};
    radialCosineDelta       = {-1       ; 'Direction of item order in a pie menu (default clockwise)'};
    radialStartIndexAt      = {90       ; 'Starting angle of the first item in a pie menu'};
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
    UICursor = {
        [DESC] = 'Cursor actions: which buttons to use to click on items in the interface';
        [DATA] = {
            LeftClick  = 'PAD1'; -- cross
            RightClick = 'PAD2'; -- circle
            Special    = 'PAD4'; -- triangle
        };
    };
    radialPrimaryStick = {
        [DESC] = 'Primary radial stick: which stick to intercept for main radial actions';
        [DATA] = {
            'Left';
            'Movement';
        };
    };
    radialSecondaryStick = {
        [DESC] = 'Secondary radial stick: which stick to intercept for extra radial actions';
        [DATA] = {
            'Right';
            'Cursor';
        };
    };
}   --------------------------------------------------------------------------------------------------------

local DataAPI, _, db = CPAPI.CreateEventHandler({'Frame', '$parentDataHandler', ConsolePort}), ...
local copy = db.table.copy;

function DataAPI:OnDataLoaded()
	local settings = setmetatable(ConsolePortSettings or {}, {
		__index = function(self, key)
			local var = DEFAULT_DATA[key]
			return var and copy(var[DATA])
		end;
	})
	db:Register('Settings', settings, true)
	db:Default(settings)
	db:Save('Settings', 'ConsolePortSettings')
end