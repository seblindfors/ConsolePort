-- Presets that I made but don't think should be included in the main file.
-- They're here for reference and to keep the main file clean.

Presets.Grid = {
	name 	   = 'Grid';
	desc       = 'Group buttons by modifier in a grid layout.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		Petring = Interface.Petring:Render {
			scale = 0.65;
			pos   = { x = 550, y = 80 };
		};
		Vehicle = DefaultVehicle;
		DividerMid = Interface.Divider : Render {
			breadth    = 300;
			depth      = 100;
			transition = 150;
			opacity    = '[vehicleui][overridebar] 0; [mod:ALT-] 50; [mod:M2M1] 100; 50';
			pos = { point = 'BOTTOM', y = 120 };
		};
		DividerLeft = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 90;
			transition = 150;
			opacity  = '[vehicleui][overridebar] 0; [mod:ALT-][mod:M2M1] 50; [mod:M1] 100; 50';
			pos = { point = 'BOTTOM', x = -153, y = 120 };
		};
		DividerRight = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 270;
			transition = 150;
			opacity  = '[vehicleui][overridebar] 0; [mod:ALT-][mod:M2M1] 50; [mod:M2] 100; 50';
			pos = { point = 'BOTTOM', x = 147, y = 120 };
		};
		Nomod = Interface.Group : Render {
			opacity  = '[nomod] 100; 10';
			modifier = '[nomod] ;';
			pos = { point = 'BOTTOM', y = 25 };
			width  = 300;
			height = 100;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x = 200, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 250, y = -25 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x = 150, y = -25 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x = 200, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x = 150, y =  25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 250, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =   0, y = -25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 100, y = -25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =  50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y =  25 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 100, y =  25 } };
			};
		};
		Shift = Interface.Group : Render {
			opacity  = '[mod:ALT-][mod:M2M1] 10; [mod:M1] 100; 10';
			modifier = '[] M1;';
			pos = { point = 'BOTTOM', x = -225, y = 25 };
			width  = 150;
			height = 200;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -75 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 100, y = -75 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x =   0, y = -75 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y = -25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 100, y = -25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =   0, y =  25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 100, y =  25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =  50, y =  25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =  50, y =  75 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y =  75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 100, y =  75 } };
			};
		};
		Ctrl = Interface.Group : Render {
			opacity  = '[mod:ALT-][mod:M2M1] 10; [mod:M2] 100; 10';
			modifier = '[] M2;';
			pos = { point = 'BOTTOM', x = 225, y = 25 };
			width  = 150;
			height = 200;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -75 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 100, y = -75 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x =   0, y = -75 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y = -25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 100, y = -25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =   0, y =  25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 100, y =  25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =  50, y =  25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =  50, y =  75 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y =  75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 100, y =  75 } };
			};
		};
		CtrlShift = Interface.Group : Render {
			opacity  = '[mod:ALT-] 10; [mod:M2M1] 100; 10';
			modifier = '[] M2M1;';
			pos = { point = 'BOTTOM', y = 125 };
			width  = 300;
			height = 100;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x = 200, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 250, y = -25 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x = 150, y = -25 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x = 200, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x = 150, y =  25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 250, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =   0, y = -25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 100, y = -25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =  50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y =  25 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 100, y =  25 } };
			};
		};
	};
};

Presets.DiamondGrid = {
	name 	   = 'Diamond Grid';
	desc       = 'Group buttons by modifier in a diamond layout.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		Petring = Interface.Petring:Render {
			scale = 0.65;
			pos   = { x = 0, y = 370 };
		};
		Vehicle = DefaultVehicle;
		Nomod = Interface.Group : Render {
			opacity  = '[nomod] 100; 10';
			modifier = '[nomod] ;';
			pos = { point = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x = 400, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 450, y =   0 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x = 350, y =   0 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x = 400, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x = 350, y =  50 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 350, y = -50 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x = 200, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 300, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x = 250, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x = 250, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x = 300, y =  50 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 300, y = -50 } };
			};
		};
		Shift = Interface.Group : Render {
			opacity  = '[mod:M2M1] 10; [mod:M1] 100; 10';
			modifier = '[] M1;';
			pos = { point = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x = 500, y = -75 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 550, y = -50 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x = 450, y = -50 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x = 500, y = -25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x = 600, y = -75 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 400, y = -75 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x = 100, y = -50 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 200, y = -50 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x = 150, y = -75 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x = 150, y = -25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 250, y = -75 } };
			};
		};
		Ctrl = Interface.Group : Render {
			opacity  = '[mod:M2M1] 10; [mod:M2] 100; 10';
			modifier = '[] M2;';
			pos = { point = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x = 500, y = 25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 550, y = 50 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x = 450, y = 50 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x = 500, y = 75 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x = 600, y = 75 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 400, y = 75 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x = 100, y = 50 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 200, y = 50 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x = 150, y = 25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x = 150, y = 75 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =  50, y = 75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 250, y = 75 } };
			};
		};
		CtrlShift = Interface.Group : Render {
			opacity  = '[mod:M2M1] 100; 10';
			modifier = '[] M2M1;';
			pos = { point = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', x = 600, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', x = 650, y =   0 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', x = 550, y =   0 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', x = 600, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', x = 650, y =  50 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 650, y = -50 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =   0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x = 100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =  50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =  50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y =  50 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x =   0, y = -50 } };
			};
		};
	};
};