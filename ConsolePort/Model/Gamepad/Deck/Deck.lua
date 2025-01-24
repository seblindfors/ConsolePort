select(2, ...).Gamepad:AddGamepad({
	Name = 'Steam Deck';
	LabelStyle = 'Letters';
	Version = 1;
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
		Layout = {
			PADLTRIGGER  = 0x10;
			PADLSHOULDER = 0x11;
			PADLSTICK    = 0x12;
			--------------------
			PADDUP		 = 0x13;
			PADDLEFT	 = 0x14;
			PADDDOWN	 = 0x15;
			PADDRIGHT	 = 0x16;
			--------------------
			PADBACK      = 0x17;
			--------------------
			PADPADDLE1   = 0x18;
			PADPADDLE2   = 0x19;
			--------------------
			PADRTRIGGER	 = 0x20;
			PADRSHOULDER = 0x21;
			PADRSTICK    = 0x22;
			--------------------
			PAD1         = 0x23;
			PAD2         = 0x24;
			PAD3         = 0x25;
			PAD4		 = 0x26;
			--------------------
			PADFORWARD   = 0x27;
			--------------------
			PADPADDLE3   = 0x28;
			PADPADDLE4   = 0x29;

		};
	};
	Preset = {
		Variables = {
			synchronizeSettings     = 0;
			synchronizeBindings     = 0;
			synchronizeConfig       = 0;
			synchronizeMacros       = 1;
			HardwareCursor          = 0;
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
})