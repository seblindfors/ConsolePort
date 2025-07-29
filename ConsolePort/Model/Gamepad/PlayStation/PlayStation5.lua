local _, db = ...; db.Gamepad:AddGamepad({
	Name = 'PlayStation 5';
	Version = 5;
	Generator = {
		LeftHand = {
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
		};
		Triggers = {
			PADLTRIGGER = {
				['']            = 'INTERACTTARGET';
				['CTRL-']       = 'TARGETPREVIOUSFRIEND';
			};
			PADRTRIGGER = {
				['']            = 'TARGETNEARESTENEMY';
				['SHIFT-']      = 'TARGETNEARESTFRIEND';
			};
			PADLSHOULDER = {
				['']            = 'ACTIONBUTTON2';
				['SHIFT-']      = 'MULTIACTIONBAR1BUTTON2';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON10';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON12';
			};
			PADRSHOULDER = {
				['']            = 'ACTIONBUTTON1';
				['SHIFT-']      = 'TARGETSCANENEMY';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON9';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON11';
			};
		};
		Face = {
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
		};
		Center = {
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
		};
	};
}, { -- metaData
	Label = 'SHP';
	LabelStyle = 'Shapes';
	StyleNameSubStrs = { 'PS5', 'DS5', 'DualShock 5', 'PlayStation 5', 'DualSense' };
	Description = db.Locale.DEVICE_DESC_PLAYSTATION5;
	Colors = {
		PAD1 = '6882A1';
		PAD2 = 'D84E58';
		PAD3 = 'D35280';
		PAD4 = '62BBB2';
	};
	Assets = {
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
		PADPADDLE1   = 'All/RG';
		PADPADDLE2   = 'All/LG';
		PADPADDLE3   = 'Xbox/RB';
		PADPADDLE4   = 'Xbox/LB';
	};
	Layout = { -- format: delta (-1 or 1), drawLayer, x1, y1, ..., xN, yN
		--------------------
		PADBACK      = {-1, 01, 0050, 0070, 0100, 0260};
		PADSOCIAL    = {-1, 01, 0096, 0096, 0120, 0220};
		--------------------
		PADLSHOULDER = {-1, 01, 0125, 0110, 0150, 0180};
		PADLTRIGGER  = {-1, -1, 0150, 0100, 0170, 0120};
		--------------------
		PADDUP       = {-1, 01, 0125, 0066};
		PADDLEFT     = {-1, 01, 0150, 0040, 0200, 0010};
		PADDDOWN     = {-1, 01, 0125, 0018, 0200, -040};
		PADDRIGHT    = {-1, 01, 0100, 0040, 0120, -010, 0200, -092};
		--------------------
		PADLSTICK    = {-1, 01, 0084, -030, 0140, -100, 0200, -150};
		--------------------
		PADPADDLE2   = {-1, -1, 0090, -040, 0160, -194};
		PADPADDLE4   = {-1, 01, 0070, -060, 0140, -250};
		--------------------
		PADSYSTEM    = {-1, 01, 0000, -010, 0040, -060, 0120, -300};
		--------------------
		PAD6         = {01, 01, 0050, 0070, 0100, 0260};
		PADFORWARD   = {01, 01, 0096, 0096, 0120, 0220};
		--------------------
		PADRSHOULDER = {01, 01, 0125, 0110, 0150, 0180};
		PADRTRIGGER	 = {01, -1, 0150, 0100, 0170, 0120};
		--------------------
		PAD4         = {01, 01, 0142, 0072};
		PAD2         = {01, 01, 0160, 0034, 0200, 0010};
		PAD1         = {01, 01, 0136, 0002, 0200, -040};
		PAD3         = {01, 01, 0100, 0030, 0120, -010, 0200, -092};
		--------------------
		PADRSTICK    = {01, 01, 0084, -030, 0140, -100, 0200, -150};
		--------------------
		PAD5         = {01, 01, 0002, -040, 0040, -100, 0120, -300};
		--------------------
		PADPADDLE1   = {01, -1, 0090, -040, 0160, -194};
		PADPADDLE3   = {01, 01, 0070, -060, 0140, -250};
	};
})