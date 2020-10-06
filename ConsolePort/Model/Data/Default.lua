local DATA, DESC, _, db = 1, 2, ...; _ = db('Data');
------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
db:Register('Defaults', {
    --------------------------------------------------------------------------------------------------------
    -- variable            | value                | description
    --------------------------------------------------------------------------------------------------------
    -- Action page handling:
    actionPageCondition    = {_.String(nil)       ; 'Macro condition to evaluate action bar page'};
    actionPageResponse     = {_.String(nil)       ; 'Response to condition for custom processing'};
    -- Bindings:
    bindingOverlapEnable   = {_.Bool(false)       ; 'Allow binding multiple combos to the same binding'};
    bindingShowExtraBars   = {_.Bool(false)       ; 'Show extra action bars for non-applicable characters'};
    -- Mouse:
    mouseHandlingEnabled   = {_.Bool(true)        ; 'Enable custom mouse handling'};
    mouseAutoClearCenter   = {_.Number(2.0)       ; 'Time in seconds to automatically hide centered cursor'};
    mouseAlwaysCentered    = {_.Bool(false)       ; 'Always keep cursor centered when controlling camera'};
    -- Radial:
    radialActionDeadzone   = {_.Range(0.5, 0, 1)  ; 'Deadzone for simple pie menus'};
    radialCosineDelta      = {_.Delta(-1)         ; 'Direction of item order in a pie menu (default clockwise)'};
    radialStartIndexAt     = {_.Range(90, 0, 360) ; 'Starting angle of the first item in a pie menu'};
    radialClearFocusTime   = {_.Number(0.5)       ; 'Time to clear focus after intercepting stick input'};
    -- Interface cursor:
    UIaccessUnlimited      = {_.Bool(false)       ; 'Allow cursor to interact with the entire interface'};
    UIdisableCursor        = {_.Bool(false)       ; 'Disable interface cursor'};
    UIleaveCombatDelay     = {_.Number(.5)        ; 'Delay before re-activating UI core after combat'};
    UIholdRepeatDelay      = {_.Number(.125)      ; 'Delay until a D-pad input is repeated (interface)'};
    UIholdRepeatDisable    = {_.Bool(false)       ; 'Disable D-pad input repeater'};
    -- Unit hotkey specific:
    unitHotkeySize         = {_.Number(32)        ; 'Size of unit hotkeys (px)'};
    unitHotkeyOffsetX      = {_.Number(0)         ; 'Offset X-placement on unit frames (px)'};
    unitHotkeyOffsetY      = {_.Number(0)         ; 'Offset Y-placement on unit frames (px)'};
    unitHotkeyGhostMode    = {_.Bool(false)       ; 'Restore calculated combinations after targeting'};
    unitHotkeyIgnorePlayer = {_.Bool(false)       ; 'Always ignore player regardless of pool'};
    -- Misc:
    classFileOverride      = {_.String(nil)       ; 'Override class theme'};
    disableAmbientFrames   = {_.Bool(false)       ; 'Disable ambient noise-cancelling in menus'};
    -- Structures:
    UICursor = {
        [DESC] = 'Cursor actions: which buttons to use to click on items in the interface';
        [DATA] = _.Table({
            LeftClick  = 'PAD1'; -- cross
            RightClick = 'PAD2'; -- circle
            Special    = 'PAD4'; -- triangle
        });
    };
    UImodifierCommands = {
        [DESC] = 'Which modifier to use for modified commands';
        [DATA] = _.Select('Shift', {'Alt','Shift', 'Ctrl'});
    };
    radialPrimaryStick = {
        [DESC] = 'Primary radial stick: which stick to intercept for main radial actions';
        [DATA] = _.Table({
            'Left';
            'Movement';
        });
    };
    radialSecondaryStick = {
        [DESC] = 'Secondary radial stick: which stick to intercept for extra radial actions';
        [DATA] = _.Table({
            'Right';
            'Cursor';
        });
    };
})  --------------------------------------------------------------------------------------------------------
