select(2, ...).Gamepad:AddGamepad({
	Name = 'Nintendo N64';
	LabelStyle = 'N64';
	Version = 1;
	Theme = {
		Label = 'N64';
		Colors = {
			PAD1	  = '00A2FF';
			PAD2	  = '00FF5D';
		};
		Icons = {
			PADDUP       = 'N64/Up';
			PADDRIGHT    = 'N64/Right';
			PADDDOWN     = 'N64/Down';
			PADDLEFT     = 'N64/Left';
			PAD1         = 'N64/A';
			PAD2         = 'N64/B';
			PAD3         = 'N64/CLeft';
			PAD4         = 'N64/CUp';
			PAD5         = 'N64/Snapshot';
			--PAD6
			PADLSTICK    = 'N64/ZR';
			--PADRSTICK
			PADLSHOULDER = 'N64/L';
			PADRSHOULDER = 'N64/R';
			PADLTRIGGER  = 'N64/ZL';
			PADRTRIGGER  = 'N64/CDown';
			--PADLSTICKUP
			--PADLSTICKRIGHT
			--PADLSTICKDOWN
			--PADLSTICKLEFT
			--PADRSTICKUP
			--PADRSTICKRIGHT
			--PADRSTICKDOWN
			--PADRSTICKLEFT
			--PADPADDLE1
			--PADPADDLE2
			--PADPADDLE3
			--PADPADDLE4
			PADFORWARD  = 'N64/Start';
			PADBACK     = 'N64/CRight';
			PADSYSTEM   = 'N64/Home';
			--PADSOCIAL
		};
		Layout = {
			PADLTRIGGER  = 0x10;
			PADLSHOULDER = 0x11;
			--------------------
			PADDUP		 = 0x12;
			PADDLEFT	 = 0x13;
			PADDDOWN	 = 0x14;
			PADDRIGHT	 = 0x15;
			--------------------
			PADLSTICK    = 0x16;
			PADBACK      = 0x17;
			PADSYSTEM    = 0x18;
			--------------------
			PADRTRIGGER	 = 0x19;
			PADRSHOULDER = 0x20;
			--------------------
			PAD1         = 0x21;
			PAD2         = 0x22;
			PAD3         = 0x23;
			PAD4		 = 0x24;
			PAD5		 = 0x25;
			--------------------
			PADFORWARD   = 0x26;
			--------------------
		};
	};
	Preset = {
		Variables = {
			synchronizeSettings     = 0;
			synchronizeBindings     = 0;
			synchronizeConfig       = 0;
			synchronizeMacros       = 1;
			GamePadEmulateShift     = 'PADLTRIGGER';
			GamePadEmulateCtrl      = 'PADLSHOULDER';
			GamePadEmulateAlt       = 'none';
			GamePadEmulateEsc       = 'none';
			GamePadCursorLeftClick  = 'PADRSHOULDER';
			GamePadCursorRightClick = 'PAD5';
			GamePadAbbreviatedBindingReverse = 0;
		};
		Bindings = {
			PAD1 = {
				['']            = 'JUMP';
				['SHIFT-']      = 'INTERACTTARGET';
				['CTRL-']       = 'ACTIONBUTTON9';
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
			PADFORWARD = {
				['SHIFT-']      = 'OPENALLBAGS';
				['CTRL-']       = 'TOGGLEWORLDMAP';
				['CTRL-SHIFT-'] = 'TOGGLEAUTORUN';
			};
			-- Trigger buttons
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
			PADSYSTEM = {
				['']            = 'TOGGLEGAMEMENU';
				['SHIFT-']      = 'CLICK ConsolePortRaidCursorToggle:LeftButton';
				['CTRL-']       = 'CAMERAZOOMOUT';
				['CTRL-SHIFT-'] = 'CAMERAZOOMIN';
			};
			-- Sticks
			PADLSTICK = {
				[''] = 'CAMERAORSELECTORMOVE';
			};
		};
	};
})