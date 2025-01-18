---------------------------------------------------------------
-- General
---------------------------------------------------------------
-- return true or nil (nil for dynamic table insertions)
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC or nil;
CPAPI.IsRetailVersion     = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or nil;
CPAPI.IsClassicEraVersion = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or nil;

---------------------------------------------------------------
-- Button
---------------------------------------------------------------
CPAPI.ExtraActionButtonID = (ExtraActionButton1 or {}).action or CPAPI.IsRetailVersion and 217 or 169;

CPAPI.ActionTypeRelease   = CPAPI.IsRetailVersion and 'typerelease' or 'type';
CPAPI.ActionTypePress     = 'type';
CPAPI.ActionPressAndHold  = 'pressAndHoldAction';

CPAPI.DefaultRingSetID    = 1;

CPAPI.SkipHotkeyRender    = 'ignoregamepadhotkey';
CPAPI.UseCustomFlyout     = 'usegamepadflyout';

CPAPI.RaidCursorUnit      = 'cursorunit';

---------------------------------------------------------------
-- Addon
---------------------------------------------------------------

CPAPI.ConfigAddOn         = 'ConsolePort_Config';
CPAPI.CursorAddOn         = 'ConsolePort_Cursor';