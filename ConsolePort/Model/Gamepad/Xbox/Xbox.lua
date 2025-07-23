local _, db = ...; db.Gamepad:AddGamepad({
	Name = 'Xbox';
	Version = 3;
	Preset = {
		Variables = {
			GamePadEmulateShift     = 'PADLTRIGGER';
			GamePadEmulateCtrl      = 'PADRTRIGGER';
			GamePadEmulateAlt       = 'none';
			GamePadEmulateEsc       = 'none';
			GamePadCursorLeftClick  = 'PADLSTICK';
			GamePadCursorRightClick = 'PADRSTICK';
		};
		Bindings = {
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
			-- Trigger buttons
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
			PADBACK = {
				-- EmulateEsc
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
			-- Sticks
			PADLSTICK = {
				[''] = 'CAMERAORSELECTORMOVE';
			};
			PADRSTICK = {
				[''] = 'TURNORACTION';
			};
		};
	};
}, { -- metaData
	Label = 'LTR';
	LabelStyle = 'Letters';
	Description = db.Locale.DEVICE_DESC_XBOX;
	Colors = {
		PADDUP    = 'FFE74F';
		PADDLEFT  = '00A2FF';
		PADDRIGHT = 'FA4451';
		PADDDOWN  = '52C14E';
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
		PADLSTICK    = 'Xbox/LSB';
		PADRSTICK    = 'Xbox/RSB';
		PADLSHOULDER = 'Xbox/LB';
		PADRSHOULDER = 'Xbox/RB';
		PADLTRIGGER  = 'Xbox/LT';
		PADRTRIGGER  = 'Xbox/RT';
		PADPADDLE1   = 'PlayStation/L1';
		PADPADDLE2   = 'PlayStation/L2';
		PADPADDLE3   = 'PlayStation/R1';
		PADPADDLE4   = 'PlayStation/R2';
		PADFORWARD   = 'Xbox/Forward';
		PADBACK      = 'Xbox/Back';
		PADSYSTEM    = 'Xbox/System';
		PADSOCIAL    = 'Xbox/Share';
	};
	Layout = {
	--	PADLTRIGGER  = 0x11;
	--	PADLSHOULDER = 0x12;
	--	PADLSTICK    = 0x13;
		--------------------
	--	PADDUP		 = 0x14;
	--	PADDLEFT	 = 0x15;
	--	PADDDOWN	 = 0x16;
	--	PADDRIGHT	 = 0x17;
		--------------------
	--	PADBACK      = 0x18;
		--------------------
	--	PADRTRIGGER	 = 0x21;
	--	PADRSHOULDER = 0x22;
		--------------------
	--	PAD4		 = 0x23;
	--	PAD2         = 0x24;
	--	PAD1         = 0x25;
	--	PAD3         = 0x26;
		--------------------
	--	PADRSTICK    = 0x27;
	--	PADFORWARD   = 0x28;
		--------------------
	--	PADSYSTEM    = 0x32;

	-- format: delta (-1 or 1), drawLayer, x1, y1, ..., xN, yN
		--------------------
		PADBACK      = {-1,  1, 50, 70, 100, 260};
		PADSOCIAL    = {-1,  1, 96, 96, 120, 220};
		--------------------
		PADLSHOULDER = {-1,  1, 125, 110, 150, 180};
		PADLTRIGGER  = {-1, -1, 150, 100, 170, 120};
		--------------------
		PADDUP		 = {-1,  1, 125, 66};
		PADDLEFT	 = {-1,  1, 150, 40, 200, 10};
		PADDDOWN	 = {-1,  1, 125, 18, 200, -40};
		PADDRIGHT	 = {-1,  1, 100, 40, 120, -10, 200, -92};
		--------------------
		PADLSTICK    = {-1,  1, 84, -30, 140, -100, 200, -150};
		--------------------
		PADPADDLE2   = {-1, -1, 90, -40, 160, -194};
		PADPADDLE4   = {-1,  1, 70, -60, 140, -250};
		--------------------
		PADSYSTEM    = {-1,  1, 0, -10, 40, -60, 120, -300};
		--------------------
		PAD6         = {1,  1, 50, 70, 100, 260};
		PADFORWARD   = {1,  1, 96, 96, 120, 220};
		--------------------
		PADRSHOULDER = {1,  1, 125, 110, 150, 180};
		PADRTRIGGER	 = {1, -1, 150, 100, 170, 120};
		--------------------
		PAD4		 = {1,  1, 142, 72};
		PAD2         = {1,  1, 160, 34, 200, 10};
		PAD1         = {1,  1, 136, 2, 200, -40};
		PAD3         = {1,  1, 100, 30, 120, -10, 200, -92};
		--------------------
		PADRSTICK    = {1,  1, 84, -30, 140, -100, 200, -150};
		--------------------
		PAD5         = {1,  1, 2, -40, 40, -100, 120, -300};
		--------------------
		PADPADDLE1   = {1, -1, 90, -40, 160, -194};
		PADPADDLE3   = {1,  1, 70, -60, 140, -250};
	};
})