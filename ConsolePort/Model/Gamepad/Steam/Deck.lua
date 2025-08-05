local _, db = ...; db.Gamepad:AddGamepad({
	Name = 'Steam Deck';
	Version = 1;
	Environment = {
		Console = {
			synchronizeBindings = 0;
			synchronizeConfig   = 0;
			HardwareCursor      = 0;
		};
		Settings = {
			emulatePADPADDLE1   = 'F1';
			emulatePADPADDLE2   = 'F2';
			emulatePADPADDLE3   = 'F3';
			emulatePADPADDLE4   = 'F4';
			gameMenuFontSize    = 16;
			gameMenuScale       = 0.75;
			keyboardEnable      = true;
		};
	};
	Generator = {
		LeftHand = {
			PADLSHOULDER = {
				['']            = 'INTERACTTARGET';
				['CTRL-']       = 'TARGETPREVIOUSFRIEND';
			};
			PADLTRIGGER = {
				['']            = 'TARGETNEARESTENEMY';
				['SHIFT-']      = 'TARGETNEARESTFRIEND';
			};
			PADRSHOULDER = {
				['']            = 'ACTIONBUTTON1';
				['SHIFT-']      = 'TARGETSCANENEMY';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON1';
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
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON1';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON11';
			};
		};
		Face = {
			PAD1 = {
				['']            = 'JUMP';
				['SHIFT-']      = 'MULTIACTIONBAR1BUTTON9';
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
		};
		Center = {
			PADBACK = {
				['SHIFT-']      = 'OPENALLBAGS';
				['CTRL-']       = 'TOGGLEWORLDMAP';
				['CTRL-SHIFT-'] = 'TOGGLEAUTORUN';
			};
			PADFORWARD = {
				['']            = 'TOGGLEGAMEMENU';
				['SHIFT-']      = 'CLICK ConsolePortRaidCursorToggle:LeftButton';
				['CTRL-']       = 'CAMERAZOOMOUT';
				['CTRL-SHIFT-'] = 'CAMERAZOOMIN';
			};
		};
	};
}, { -- metaData
	Label = 'LTR';
	LabelStyle = 'Letters';
	Description = db.Locale.DEVICE_DESC_STEAMDECK;
	Colors = {
		PAD1 = '52C14E';
		PAD2 = 'FA4451';
		PAD3 = '00A2FF';
		PAD4 = 'FFE74F';
	};
	Assets = {
		PADDUP       = 'All/Up';
		PADDRIGHT    = 'All/Right';
		PADDDOWN     = 'All/Down';
		PADDLEFT     = 'All/Left';
		PAD1         = 'Xbox/A';
		PAD2         = 'Xbox/B';
		PAD3         = 'Xbox/X';
		PAD4         = 'Xbox/Y';
		--PAD5
		--PAD6
		PADLSTICK    = 'Xbox/LSB';
		PADRSTICK    = 'Xbox/RSB';
		PADLSHOULDER = 'Xbox/LB';
		PADRSHOULDER = 'Xbox/RB';
		PADLTRIGGER  = 'Xbox/LT';
		PADRTRIGGER  = 'Xbox/RT';
		--PADLSTICKUP
		--PADLSTICKRIGHT
		--PADLSTICKDOWN
		--PADLSTICKLEFT
		--PADRSTICKUP
		--PADRSTICKRIGHT
		--PADRSTICKDOWN
		--PADRSTICKLEFT
		PADPADDLE1  = 'PlayStation/L1';
		PADPADDLE2  = 'PlayStation/L2';
		PADPADDLE3  = 'PlayStation/R1';
		PADPADDLE4  = 'PlayStation/R2';
		PADFORWARD  = 'Xbox/Options';
		PADBACK     = 'Xbox/Share';
		--PADSYSTEM
		--PADSOCIAL
	};
	Layout = { -- format: delta (-1 or 1), drawLayer, x1, y1, ..., xN, yN
		--------------------
		PADLSHOULDER = {-1, 01, 0125, 0130, 0150, 0210};
		PADLTRIGGER  = {-1, -1, 0150, 0100, 0170, 0160};
		--------------------
		PADBACK      = {-1, 01, 0100, 0114, 0180, 0120};
		--------------------
		PADDUP       = {-1, 01, 0146, 0100, 0190, 0094, 0210, 0064};
		PADDLEFT     = {-1, 01, 0162, 0074, 0200, 0010};
		PADDDOWN     = {-1, 01, 0144, 0054, 0200, -036};
		PADDRIGHT    = {-1, 01, 0124, 0074, 0136, -010, 0200, -092};
		--------------------
		PADLSTICK    = {-1, 01, 0066, 0060, 0140, -100, 0200, -150};
		--------------------
		PADPADDLE1   = {-1, -1, 0090, -040, 0160, -194};
		PADPADDLE2   = {-1, -1, 0070, -060, 0140, -250};
		--------------------
		PADRSHOULDER = {01, 01, 0125, 0130, 0150, 0210};
		PADRTRIGGER  = {01, -1, 0150, 0100, 0170, 0160};
		--------------------
		PADFORWARD   = {01, 01, 0100, 0114, 0180, 0120};
		--------------------
		PAD4         = {01, 01, 0154, 0100, 0190, 0094, 0210, 0064};
		PAD2         = {01, 01, 0168, 0064, 0200, 0010};
		PAD1         = {01, 01, 0146, 0040, 0200, -036};
		PAD3         = {01, 01, 0120, 0062, 0136, -010, 0200, -092};
		--------------------
		PADRSTICK    = {01, 01, 0066, 0060, 0140, -100, 0200, -150};
		--------------------
		PADPADDLE3   = {01, -1, 0090, -040, 0160, -194};
		PADPADDLE4   = {01, -1, 0070, -060, 0140, -250};
	};
})