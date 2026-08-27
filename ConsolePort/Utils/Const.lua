---------------------------------------------------------------
-- General
---------------------------------------------------------------
-- return true or nil (nil for dynamic table insertions)
CPAPI.IsClassicEraVersion = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or nil;
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC or nil;
CPAPI.IsWrathVersion      = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC or nil;
CPAPI.IsRetailVersion     = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or nil;
CPAPI.IsAnniVersion       = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC or nil;

---------------------------------------------------------------
-- Button
---------------------------------------------------------------
CPAPI.ActionTypeRelease   = 'typerelease';
CPAPI.ActionTypePress     = 'type';
CPAPI.ActionPressAndHold  = 'pressAndHoldAction';
CPAPI.ActionUseOnKeyDown  = 'useOnKeyDown';

CPAPI.DefaultRingSetID    = 1;

CPAPI.SkipHotkeyRender    = 'ignoregamepadhotkey';
CPAPI.UseCustomFlyout     = 'usegamepadflyout';

CPAPI.RaidCursorUnit      = 'cursorunit';
CPAPI.ActionButtonGUID    = tostring(random((select(4, GetBuildInfo()))));


---------------------------------------------------------------
-- Game constants
---------------------------------------------------------------
CPAPI.ExtraActionButtonID  = (ExtraActionButton1 or {}).action or CPAPI.IsRetailVersion and 217 or 169;
CPAPI.MAX_ACCOUNT_MACROS   = MAX_ACCOUNT_MACROS or Constants.MacroConsts.MAX_ACCOUNT_MACROS;
CPAPI.MAX_CHARACTER_MACROS = MAX_CHARACTER_MACROS or Constants.MacroConsts.MAX_CHARACTER_MACROS;

---------------------------------------------------------------
-- Addon
---------------------------------------------------------------
CPAPI.ConfigAddOn         = 'ConsolePort_Config';
CPAPI.CursorAddOn         = 'ConsolePort_Cursor';
CPAPI.TargetingAddOn      = 'ConsolePort_Targeting';

---------------------------------------------------------------
-- For use with OnDataLoaded.
---------------------------------------------------------------
CPAPI.BurnAfterReading    = random(0001, 1337); -- Mark as garbage.
CPAPI.KeepMeForLater      = random(1338, 1992); -- Will be used again.

---------------------------------------------------------------
-- Tutorial
---------------------------------------------------------------
CPAPI.Tutorial = CPAPI.CreateFlags(
	'GamepadGraphics',
	'ControlScheme',
	'ModuleSelection',
	'ExternalSupport'
);