select(2, ...).Gamepad:AddGamepad({
	Name = 'PlayStation 4';
	LabelStyle = 'Shapes';
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
			--PAD5
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
			PADSYSTEM    = 0x32;
			PADBACK      = 0x43;
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
			PADLSHOULDER = {
				['']            = 'INTERACTTARGET';
				['CTRL-']       = 'TARGETNEARESTFRIEND';
			};
			PADLTRIGGER = {
				['']            = 'TARGETNEARESTENEMY';
				['SHIFT-']      = 'TARGETPREVIOUSFRIEND';
			};
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
})