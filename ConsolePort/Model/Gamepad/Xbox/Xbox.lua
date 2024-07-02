select(2, ...).Gamepad:AddGamepad({
	Name = 'Xbox';
	LabelStyle = 'Letters';
	Version = 3;
	Theme = {
		Label = 'LTR';
		Colors = {
			PADDUP    = 'FFE74F';
			PADDLEFT  = '00A2FF';
			PADDRIGHT = 'FA4451';
			PADDDOWN  = '52C14E';
		};
		Icons = {
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
			PADLTRIGGER  = 0x11;
			PADLSHOULDER = 0x12;
			PADLSTICK    = 0x13;
			--------------------
			PADDUP		 = 0x14;
			PADDLEFT	 = 0x15;
			PADDDOWN	 = 0x16;
			PADDRIGHT	 = 0x17;
			--------------------
			PADBACK      = 0x18;
			--------------------
			PADRTRIGGER	 = 0x21;
			PADRSHOULDER = 0x22;
			--------------------
			PAD4		 = 0x23;
			PAD2         = 0x24;
			PAD1         = 0x25;
			PAD3         = 0x26;
			--------------------
			PADRSTICK    = 0x27;
			PADFORWARD   = 0x28;
			--------------------
			PADSYSTEM    = 0x32;
		};
	};
	Preset = {
		Variables = {
			GamePadEmulateShift     = 'PADLTRIGGER';
			GamePadEmulateCtrl      = 'PADRTRIGGER';
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
				['CTRL-']       = 'CLICK ConsolePortMenuTrigger:LeftButton';
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
			PADLTRIGGER = {
				['']            = 'INTERACTTARGET';
				['CTRL-']       = 'TARGETPREVIOUSFRIEND';
			};
			PADRTRIGGER = {
				['']            = 'TARGETNEARESTENEMY';
				['SHIFT-']      = 'TARGETNEARESTFRIEND';
			};
			PADLSHOULDER = {
				['']            = 'ACTIONBUTTON5';
				['SHIFT-']      = 'ACTIONBUTTON10';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON5';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON10';
			};
			PADRSHOULDER = {
				['']            = 'ACTIONBUTTON4';
				['SHIFT-']      = 'TARGETSCANENEMY';
				['CTRL-']       = 'MULTIACTIONBAR1BUTTON4';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON9';
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
})