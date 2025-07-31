local _, db = ...; db.Gamepad:AddGamepad({
	Name = 'Nintendo Switch Pro';
	Version = 1;
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
				['']            = 'TOGGLEWORLDMAP';
				['SHIFT-']      = 'OPENALLBAGS';
				['CTRL-']       = 'CAMERAZOOMOUT';
				['CTRL-SHIFT-'] = 'MINIMAPZOOMOUT';
			};
			PADFORWARD = {
				['']            = 'TOGGLEGAMEMENU';
				['SHIFT-']      = 'TOGGLESPELLBOOK';
				['CTRL-']       = 'CAMERAZOOMIN';
				['CTRL-SHIFT-'] = 'MINIMAPZOOMIN';
			};
			PADSOCIAL = {
				['']            = 'CLICK ConsolePortRaidCursorToggle:LeftButton';
				['SHIFT-']      = 'CLICK ConsolePortUnit:player';
				['CTRL-']       = 'CLICK ConsolePortUnit:target';
				['CTRL-SHIFT-'] = 'OPENCHAT';
			};
			PADSYSTEM = {
				['']            = 'TOGGLETALENTS';
				['SHIFT-']      = 'TOGGLECHARACTER0';
				['CTRL-']       = 'TOGGLEAUTORUN';
				['CTRL-SHIFT-'] = 'FLIPCAMERAYAW';
			};
		};
	};
}, { -- metaData
	Label = 'REV';
	LabelStyle = 'Reverse';
	Description = db.Locale.DEVICE_DESC_SWITCHPRO;
	Colors = {
		PAD1 = 'FA4451';
		PAD2 = '52C14E';
		PAD3 = 'FFE74F';
		PAD4 = '00A2FF';
	};
	Assets = {
		PADDUP       = 'All/Up';
		PADDRIGHT    = 'All/Right';
		PADDDOWN     = 'All/Down';
		PADDLEFT     = 'All/Left';
		PAD1         = 'Xbox/B';
		PAD2         = 'Xbox/A';
		PAD3         = 'Xbox/Y';
		PAD4         = 'Xbox/X';
		PADLSTICK    = 'Xbox/LSB';
		PADRSTICK    = 'Xbox/RSB';
		PADLSHOULDER = 'Xbox/LB';
		PADRSHOULDER = 'Xbox/RB';
		PADLTRIGGER  = 'Xbox/LT';
		PADRTRIGGER  = 'Xbox/RT';
		PADFORWARD   = 'Switch/Forward';
		PADBACK      = 'Switch/Back';
		PADSYSTEM    = 'Switch/System';
		PADSOCIAL    = 'Switch/Share';
	};
	Layout = {-- format: delta (-1 or 1), drawLayer, x1, y1, ..., xN, yN
		--------------------
		PADLSHOULDER = {-1, 01, 0110, 0116, 0150, 0190};
		PADLTRIGGER  = {-1, -1, 0130, 0100, 0170, 0140};
		--------------------
		PADBACK      = {-1, 01, 0062, 0074, 0120, 0100};
		--------------------
		PADLSTICK    = {-1, 01, 0114, 0038};
		--------------------
		PADDUP       = {-1, 01, 0064, 0000, 0200, -020};
		PADDLEFT     = {-1, 01, 0086, -022, 0160, -066};
		PADDDOWN     = {-1, 01, 0066, -042, 0160, -120};
		PADDRIGHT    = {-1, 01, 0044, -024, 0110, -164};
		--------------------
		PADSOCIAL    = {-1, 01, 0024, 0026, 0016, -050, 0130, -220};
		--------------------
		PADRSHOULDER = {01, 01, 0110, 0116, 0150, 0190};
		PADRTRIGGER	 = {01, -1, 0130, 0100, 0170, 0140};
		--------------------
		PADFORWARD   = {01, 01, 0062, 0074, 0120, 0100};
		--------------------
		PAD4         = {01, 01, 0124, 0066, 0170, 0060, 0200, 0034};
		PAD2         = {01, 01, 0148, 0024, 0200, -020};
		PAD1         = {01, 01, 0120, -002, 0190, -070};
		PAD3         = {01, 01, 0082, 0022, 0100, -010, 0180, -120};
		--------------------
		PADRSTICK    = {01, 01, 0054, -024, 0150, -170};
		PADSYSTEM    = {01, 01, 0024, 0026, 0016, -050, 0130, -220};
	};
})