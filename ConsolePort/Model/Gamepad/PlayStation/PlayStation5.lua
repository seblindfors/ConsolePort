select(2, ...).Gamepad:AddGamepad({
	Name = 'PlayStation 5';
	LabelStyle = 'Shapes';
	StyleNameSubStrs = { 'PS5', 'DS5', 'DualShock 5', 'PlayStation 5' };
	Version = 5;
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
			PADFORWARD   = 'PlayStation/Options';
			PADBACK      = 'PlayStation/Back';
			PAD6         = 'PlayStation/Back2';
			PADSYSTEM    = 'PlayStation/System';
			PADSOCIAL    = 'PlayStation/Share';
			PADPADDLE1   = 'Xbox/LB';
			PADPADDLE2   = 'All/LG';
			PADPADDLE3   = 'Xbox/RB';
			PADPADDLE4   = 'All/RG';
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
			PAD6         = 0x43;
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
				['SHIFT-']      = 'MULTIACTIONBAR1BUTTON1';
				['CTRL-']       = 'CLICK ConsolePortMenuTrigger:LeftButton';
				['CTRL-SHIFT-'] = 'CLICK ConsolePortUtilityToggle:LeftButton';
			};
			PAD2 = {
				['']            = 'ACTIONBUTTON5';
				['SHIFT-']      = 'ACTIONBUTTON8';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON5';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON8';
			};
			PAD3 = {
				['']            = 'ACTIONBUTTON3';
				['SHIFT-']      = 'ACTIONBUTTON6';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON3';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON6';
			};
			PAD4 = {
				['']            = 'ACTIONBUTTON4';
				['SHIFT-']      = 'ACTIONBUTTON7';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON4';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON7';
			};
			-- Trigger buttons
			PADLSHOULDER = {
				['']            = 'INTERACTTARGET';
				['CTRL-']       = 'TARGETNEARESTFRIEND';
			};
			PADLTRIGGER = {
				['']            = 'TARGETNEARESTENEMY';
				['SHIFT-']      = 'TARGETPREVIOUSFRIEND';
			};
			PADRSHOULDER = {
				['']            = 'ACTIONBUTTON1';
				['SHIFT-']      = 'TARGETSCANENEMY';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON9';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON11';
			};
			PADRTRIGGER = {
				['']            = 'ACTIONBUTTON2';
				['SHIFT-']      = 'MULTIACTIONBAR1BUTTON2';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON10';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON12';
			};
			-- D-Pad
			PADDUP = {
				['']            = 'ACTIONBUTTON10';
				['SHIFT-']      = 'MULTIACTIONBAR2BUTTON2';
				['CTRL-']       = 'MULTIACTIONBAR2BUTTON6';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON10';
			};
			PADDDOWN = {
				['']            = 'ACTIONBUTTON12';
				['SHIFT-']      = 'MULTIACTIONBAR2BUTTON4';
				['CTRL-']       = 'MULTIACTIONBAR2BUTTON8';
				['CTRL-SHIFT-']	= 'MULTIACTIONBAR2BUTTON12';
			};
			PADDLEFT = {
				['']            = 'ACTIONBUTTON9';
				['SHIFT-']      = 'MULTIACTIONBAR2BUTTON1';
				['CTRL-']       = 'MULTIACTIONBAR2BUTTON5';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON9';
			};
			PADDRIGHT = {
				['']            = 'ACTIONBUTTON11';
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
})