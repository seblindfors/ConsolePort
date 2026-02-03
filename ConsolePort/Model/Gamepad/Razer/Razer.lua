local _, db = ...; db.Gamepad:AddGamepad({
	Name = 'Razer';
	Version = 3;
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
				['']            = 'OPENALLBAGS';
				['SHIFT-']      = 'TOGGLECHARACTER0';
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
		Extra = {
		-- Paddle buttons (Elite controllers have physical, standard need emulation)
			PADPADDLE1 = {
				['']            = 'MULTIACTIONBAR3BUTTON1';
				['SHIFT-']      = 'MULTIACTIONBAR3BUTTON2';
				['CTRL-']       = 'MULTIACTIONBAR3BUTTON3';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR3BUTTON4';
			};
			PADPADDLE2 = {
				['']            = 'MULTIACTIONBAR3BUTTON5';
				['SHIFT-']      = 'MULTIACTIONBAR3BUTTON6';
				['CTRL-']       = 'MULTIACTIONBAR3BUTTON7';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR3BUTTON8';
			};
			PADPADDLE3 = {
				['']            = 'MULTIACTIONBAR3BUTTON9';
				['SHIFT-']      = 'MULTIACTIONBAR3BUTTON10';
				['CTRL-']       = 'MULTIACTIONBAR3BUTTON11';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR3BUTTON12';
			};
			PADPADDLE4 = {
				['']            = 'MULTIACTIONBAR4BUTTON1';
				['SHIFT-']      = 'MULTIACTIONBAR4BUTTON2';
				['CTRL-']       = 'MULTIACTIONBAR4BUTTON3';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR4BUTTON4';
			};
			-- Extra face buttons (not on standard Xbox controllers)
			PAD5 = {
				['']            = 'MULTIACTIONBAR4BUTTON5';
				['SHIFT-']      = 'MULTIACTIONBAR4BUTTON6';
				['CTRL-']       = 'MULTIACTIONBAR4BUTTON7';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR4BUTTON8';
			};
			PAD6 = {
				['']            = 'MULTIACTIONBAR4BUTTON9';
				['SHIFT-']      = 'MULTIACTIONBAR4BUTTON10';
				['CTRL-']       = 'MULTIACTIONBAR4BUTTON11';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR4BUTTON12';
			};
			-- PlayStation-style system buttons (not on Xbox)
			PADSYSTEM = {
				['']            = 'MULTIACTIONBAR5BUTTON1';
				['SHIFT-']      = 'MULTIACTIONBAR5BUTTON2';
				['CTRL-']       = 'MULTIACTIONBAR5BUTTON3';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR5BUTTON4';
			};
			PADSOCIAL = {
				['']            = 'MULTIACTIONBAR5BUTTON5';
				['SHIFT-']      = 'MULTIACTIONBAR5BUTTON6';
				['CTRL-']       = 'MULTIACTIONBAR5BUTTON7';
				['CTRL-SHIFT-'] = 'MULTIACTIONBAR5BUTTON8';
			};
			-- Xbox has physical PADBACK and PADFORWARD, so DON'T include them here
			
		};
	};
}, { -- metaData
	Label = 'LTR';
	LabelStyle = 'Letters';
	Description = db.Locale.DEVICE_DESC_XBOX;
	Colors = {
		PAD1 = '52C14E';
		PAD2 = 'FA4451';
		PAD3 = '00A2FF';
		PAD4 = 'FFE74F';
	};
	Assets = {
		PADFORWARD   = 'Xbox/Forward';
		PADBACK      = 'Xbox/Back';
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
		PAD5         = 'PlayStation/L3';
		PAD6         = 'PlayStation/R3';
		PADSYSTEM    = 'Xbox/System';
		PADSOCIAL    = 'Xbox/Share';
	};
	Layout = {
	
		------------------------------------------------------------
		-- EXTRA BUMPERS (M1/M2 - above the triggers)
		-- These are the additional bumper buttons on Wolverine V3 Pro
		------------------------------------------------------------
		PAD5         = {-1, 01, 0070, 0105, 0160, 0100};  -- Left extra bumper (above LT)
		PAD6         = {01, 01, 0070, 0105, 0160, 0100};  -- Right extra bumper (above RT)
	
		------------------------------------------------------------
		-- CENTER BUTTONS (View/Menu - positioned closer together)
		------------------------------------------------------------
		PADBACK      = {-1, 01, 0040, 0048, 0070, 0180};
		PADFORWARD   = {01, 01, 0040, 0048, 0070, 0180};
	
		
		------------------------------------------------------------
		-- LEFT SIDE - SHOULDER/TRIGGER (slightly wider spacing)
		------------------------------------------------------------
		PADLSHOULDER = {-1, 01, 0115, 0100, 0160, 0190};
		PADLTRIGGER  = {-1, -1, 0125, 0095, 0180, 0130};
		
		------------------------------------------------------------
		-- LEFT SIDE - D-PAD (positioned lower on Wolverine)
		-- D-pad is below the left stick on this controller
		------------------------------------------------------------
		PADDUP       = {-1, 01, 0060, -0020};
		PADDLEFT     = {-1, 01, 0090, -0050, 0150, -0050};
		PADDDOWN     = {-1, 01, 0060, -0075, 0150, -0095};
		PADDRIGHT    = {-1, 01, 0035, -0050, 0150, -0150};
		
		------------------------------------------------------------
		-- LEFT STICK (high position - asymmetric Xbox-style layout)
		-- The Wolverine has the left stick in the upper left position
		------------------------------------------------------------
		PADLSTICK    = {-1, 01, 0120, 0015, 0200, 0025};
		
		------------------------------------------------------------
		-- BACK PADDLES - LEFT SIDE (M3, M4 - inner triggers)
		-- Wolverine V3 Pro has 4 back triggers, 2 on each side
		------------------------------------------------------------
		PADPADDLE2   = {-1, -1, 0085, -055, 0150, -210};
		PADPADDLE4   = {-1, -1, 0065, -075, 0130, -265};
		
		------------------------------------------------------------
		-- RIGHT SIDE - SHOULDER/TRIGGER (mirrored from left)
		------------------------------------------------------------
		PADRSHOULDER = {01, 01, 0115, 0100, 0160, 0190};
		PADRTRIGGER  = {01, -1, 0125, 0095, 0180, 0130};
		
		------------------------------------------------------------
		-- RIGHT SIDE - FACE BUTTONS (ABXY diamond)
		-- Face buttons are positioned higher on Wolverine
		-- Y is top, B is right, A is bottom, X is left
		------------------------------------------------------------
		PAD4         = {01, 01, 0120, 0050};                  			  -- Y (top)
		PAD2         = {01, 01, 0145, 0020};                 			  -- B (right)
		PAD1         = {01, 01, 0115, -0010};                			  -- A (bottom)
		PAD3         = {01, 01, 0090, 0015, 0190, -0110};      			  -- X (left)
		
		------------------------------------------------------------
		-- RIGHT STICK (lower position - below face buttons)
		-- The Wolverine has asymmetric sticks like Xbox
		------------------------------------------------------------
		PADRSTICK    = {01, 01, 0060, -0050, 0150, -0150};
		
		------------------------------------------------------------
		-- BACK PADDLES - RIGHT SIDE (M1, M2 - inner triggers)
		------------------------------------------------------------
		PADPADDLE1   = {01, -1, 0085, -055, 0150, -210};
		PADPADDLE3   = {01, -1, 0065, -075, 0130, -265};
		
		
	};
})