select(2, ...).Gamepad:AddGamepad({
	Name = 'PlayStation 5';
	Version = 1;
	Theme = {
		Label = 'SHP';
		Colors = {
			PAD1 = '6882A1';
			PAD2 = 'D84E58';
			PAD3 = 'D35280';
			PAD4 = '62BBB2';
		};
		Icons = {
			PADDUP       = 'All/Up';
			PADDRIGHT    = 'All/Right';
			PADDDOWN     = 'All/Down';
			PADDLEFT     = 'All/Left';
			PAD1         = 'PlayStation/Cross';
			PAD2         = 'PlayStation/Circle';
			PAD3         = 'PlayStation/Square';
			PAD4         = 'PlayStation/Triangle';
			PAD5         = 'Xbox/Options';
			PADLSTICK    = 'PlayStation/L3';
			PADRSTICK    = 'PlayStation/R3';
			PADLSHOULDER = 'PlayStation/L1';
			PADRSHOULDER = 'PlayStation/R1';
			PADLTRIGGER  = 'PlayStation/L2';
			PADRTRIGGER  = 'PlayStation/R2';
			PADFORWARD  = 'PlayStation/Options';
			PADBACK     = 'PlayStation/Back';
			PADSYSTEM   = 'PlayStation/System';
			PADSOCIAL   = 'PlayStation/Share';
		};
		Layout = {
			PADLSHOULDER = 0x11;
			PADLTRIGGER  = 0x12;
			--------------------
			PADDUP		 = 0x13;
			PADDLEFT	 = 0x14;
			PADDDOWN	 = 0x15;
			PADDRIGHT	 = 0x16;
			--------------------
			PADSOCIAL    = 0x17;
			PADLSTICK    = 0x18;
			--------------------
			PADRSHOULDER = 0x21;
			PADRTRIGGER	 = 0x22;
			--------------------
			PAD4		 = 0x23;
			PAD2         = 0x24;
			PAD1         = 0x25;
			PAD3         = 0x26;
			--------------------
			PADFORWARD   = 0x27;
			PADRSTICK    = 0x28;
			--------------------
			PADSYSTEM    = 0x31;
			PAD5         = 0x33;
			--------------------
			PADBACK      = 0x41;
		};
	};
	Preset = {
		Variables = {
			GamePadEmulateShift     = 'PADLSHOULDER';
			GamePadEmulateCtrl      = 'PADLTRIGGER';
			GamePadEmulateAlt       = 'none';
			GamePadEmulateEsc       = 'none';
			GamePadCursorLeftClick  = 'PADLSTICK';
			GamePadCursorRightClick = 'PADRSTICK';
			GamePadAbbreviatedBindingReverse = 0;
		};
		Bindings = {
			PAD1 = {
				['']            = 'JUMP';
				['SHIFT-']      = 'ACTIONBUTTON9';
				['CTRL-']       = 'EXTRAACTIONBUTTON1';
				['CTRL-SHIFT-'] = 'CLICK ConsolePortUtilityToggle:LeftButton';
			};
			PAD2 = {
				['']            = 'ACTIONBUTTON3';
				['SHIFT-']      = 'ACTIONBUTTON8';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON3';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON8';
			};
			PAD3 = {
				['']            = 'ACTIONBUTTON1';
				['SHIFT-']      = 'ACTIONBUTTON6';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON1';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON6';
			};
			PAD4 = {
				['']            = 'ACTIONBUTTON2';
				['SHIFT-']      = 'ACTIONBUTTON7';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON2';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON7';
			};
			-- Trigger buttons
			PADRSHOULDER = {
				['']            = 'ACTIONBUTTON4';
				['SHIFT-']      = 'TARGETSCANENEMY';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON4';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON9';
			};
			PADRTRIGGER = {
				['']            = 'ACTIONBUTTON5';
				['SHIFT-']      = 'ACTIONBUTTON10';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON5';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON10';
			};
			-- D-Pad
			PADDUP = {
				['']            = 'MULTIACTIONBAR1BUTTON12';
				['SHIFT-']      = 'MULTIACTIONBAR2BUTTON2';
				['CTRL-']       = 'MULTIACTIONBAR2BUTTON6';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON10';
			};
			PADDDOWN = {
				['']            = 'ACTIONBUTTON11';
				['SHIFT-']      = 'MULTIACTIONBAR2BUTTON4';
				['CTRL-']       = 'MULTIACTIONBAR2BUTTON8';
				['CTRL-SHIFT-']	= 'MULTIACTIONBAR2BUTTON12';
			};
			PADDLEFT = {
				['']            = 'MULTIACTIONBAR1BUTTON11';
				['SHIFT-']      = 'MULTIACTIONBAR2BUTTON1';
				['CTRL-']       = 'MULTIACTIONBAR2BUTTON5';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON9';
			};
			PADDRIGHT = {
				['']            = 'ACTIONBUTTON12';
				['SHIFT-']      = 'MULTIACTIONBAR2BUTTON3';
				['CTRL-']       = 'MULTIACTIONBAR2BUTTON7';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON11';
			};
			-- Center buttons
			PADSOCIAL = {
				['']            = 'OPENALLBAGS';
				['SHIFT-']      = 'TOGGLECHARACTER0';
				['CTRL-']       = 'TOGGLESPELLBOOK';
				['CTRL-SHIFT-'] = 'TOGGLETALENTS';
			};
			PADSYSTEM = {
				['']            = 'TOGGLEGAMEMENU';
				['SHIFT-']      = 'CLICK ConsolePortRaidCursorToggle:LeftButton';
				['CTRL-']       = 'TOGGLEAUTORUN';
				['CTRL-SHIFT-'] = 'OPENCHAT';
			};
			PADFORWARD = {
				['']            = 'TOGGLEWORLDMAP';
				['SHIFT-']      = 'CAMERAZOOMOUT';
				['CTRL-']       = 'CAMERAZOOMIN';
			};
			-- Sticks
			PADLSTICK = {
				[''] = 'CAMERAORSELECTORMOVE';
			};
			PADRSTICK = {
				[''] = 'TURNORACTION';
			};
		};
	};
	Config = {
		name = 'PlayStation 5';
		configID = {
			vendorID = 1356;
			productID = 3302;
		};
		rawButtonMappings = {
			{
				rawIndex = 0;
				button = 'Face3';
				comment = 'Square';
			};
			{
				rawIndex = 1;
				button = 'Face1';
				comment = 'Cross';
			};
			{
				rawIndex = 2;
				button = 'Face2';
				comment = 'Circle';
			};
			{
				rawIndex = 3;
				button = 'Face4';
				comment = 'Triangle';
			};
			{
				rawIndex = 4;
				button = 'LShoulder';
				comment = 'L1';
			};
			{
				rawIndex = 5;
				button = 'RShoulder';
				comment = 'R2';
			};
			{
				rawIndex = 6;
				button = 'None'; -- Face5 for half-press
				comment = 'immediate L2 (disabled so we can control trigger point)';
			};
			{
				rawIndex = 7;
				button = 'None'; -- Face6 for half-press
				comment = 'immediate R2 (disabled so we can control trigger point)';
			};
			{
				rawIndex = 8;
				button = 'Social';
				comment = 'Share';
			};
			{
				rawIndex = 9;
				button = 'Forward';
				comment = 'Options';
			};
			{
				rawIndex = 10;
				button = 'LStickIn';
			};
			{
				rawIndex = 11;
				button = 'RStickIn';
			};
			{
				rawIndex = 12;
				button = 'System';
				comment = 'PS button';
			};
			{
				rawIndex = 13;
				button = 'Back';
				comment = 'Touchpad';
			};
			{
				rawIndex = 14;
				button = 'Face5';
				comment = 'Mic button';
			}
		};
		rawAxisMappings = {
			{
				rawIndex = 0;
				axis = 'LStickX';
			};
			{
				rawIndex = 1;
				axis = 'LStickY';
			};
			{
				rawIndex = 2;
				axis = 'RStickX';
			};
			{
				rawIndex = 3;
				axis = 'LTrigger';
			};
			{
				rawIndex = 4;
				axis = 'RTrigger';
			};
			{
				rawIndex = 5;
				axis = 'RStickY';
			}
		};
		axisConfigs = {
			{
				axis = 'LStickY';
				scale = -2;
			};
			{
				axis = 'RStickY';
				scale = -2;
			}
		}
	}
})