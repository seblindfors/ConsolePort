local DATA, DESC, _, db = 1, 2, ...; setfenv(1, db('Data'));
------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
db:Register('Defaults', {
    --------------------------------------------------------------------------------------------------------
    -- variable            | value              | description
    --------------------------------------------------------------------------------------------------------
    -- Action page handling:
    actionPageCondition    = {String(nil)       ; 'Macro condition to evaluate action bar page'};
    actionPageResponse     = {String(nil)       ; 'Response to condition for custom processing'};
    -- Bindings:
    bindingOverlapEnable   = {Bool(false)       ; 'Allow binding multiple combos to the same binding'};
    bindingShowExtraBars   = {Bool(false)       ; 'Show extra action bars for non-applicable characters'};
    -- Mouse:
    mouseHandlingEnabled   = {Bool(true)        ; 'Enable custom mouse handling'};
    mouseAutoClearCenter   = {Number(2.0)       ; 'Time in seconds to automatically hide centered cursor'};
    mouseAlwaysCentered    = {Bool(false)       ; 'Always keep cursor centered when controlling camera'};
    -- Radial:
    radialActionDeadzone   = {Range(0.5, 0, 1)  ; 'Deadzone for simple pie menus'};
    radialCosineDelta      = {Delta(-1)         ; 'Direction of item order in a pie menu (default clockwise)'};
    radialStartIndexAt     = {Range(90, 0, 360) ; 'Starting angle of the first item in a pie menu'};
    radialClearFocusTime   = {Number(0.5)       ; 'Time to clear focus after intercepting stick input'};
    -- Interface cursor:
    UIaccessUnlimited      = {Bool(false)       ; 'Allow cursor to interact with the entire interface'};
    UIdisableCursor        = {Bool(false)       ; 'Disable interface cursor'};
    UIleaveCombatDelay     = {Number(.5)        ; 'Delay before re-activating interface cursor after combat'};
    UIholdRepeatDelay      = {Number(.125)      ; 'Delay until a D-pad input is repeated (interface)'};
    UIholdRepeatDisable    = {Bool(false)       ; 'Disable D-pad input repeater'};
    -- Unit hotkey specific:
    unitHotkeySize         = {Number(32)        ; 'Size of unit hotkeys (px)'};
    unitHotkeyOffsetX      = {Number(0)         ; 'Offset X-placement on unit frames (px)'};
    unitHotkeyOffsetY      = {Number(0)         ; 'Offset Y-placement on unit frames (px)'};
    unitHotkeyGhostMode    = {Bool(false)       ; 'Restore calculated combinations after targeting'};
    unitHotkeyIgnorePlayer = {Bool(false)       ; 'Always ignore player regardless of pool'};
    -- Misc:
    classFileOverride      = {String(nil)       ; 'Override class theme'};
    disableAmbientFrames   = {Bool(false)       ; 'Disable ambient noise-cancelling in menus'};
    -- Structures:
    UICursor = {
        [DESC] = 'Cursor actions: which buttons to use to click on items in the interface';
        [DATA] = Table({
            LeftClick  = 'PAD1'; -- cross
            RightClick = 'PAD2'; -- circle
            Special    = 'PAD4'; -- triangle
        });
    };
    UImodifierCommands = {
        [DESC] = 'Which modifier to use for modified commands';
        [DATA] = Select('Shift', 'Alt', 'Shift', 'Ctrl');
    };
    radialPrimaryStick = {
        [DESC] = 'Primary radial stick: which stick to intercept for main radial actions';
        [DATA] = Table({
            'Left';
            'Movement';
        });
    };
    radialSecondaryStick = {
        [DESC] = 'Secondary radial stick: which stick to intercept for extra radial actions';
        [DATA] = Table({
            'Right';
            'Cursor';
        });
    };
})  --------------------------------------------------------------------------------------------------------
