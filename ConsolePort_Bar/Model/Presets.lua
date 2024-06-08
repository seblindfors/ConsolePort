local _, env = ...;
---------------------------------------------------------------

function env:GetDefaultLayout()
	return env.UpgradeFromV1() or CopyTable(env.Presets.Default);
end

---------------------------------------------------------------
local Presets = {}; env.Presets = Presets;
local Interface = env.Interface;
---------------------------------------------------------------

---------------------------------------------------------------
-- Cluster bar presets
---------------------------------------------------------------
local Handle = Interface.ClusterHandle(); -- reuse one handle instance and warp it

Presets.Default = {
	name       = DEFAULT;
	desc       = 'A cluster bar with a toolbar below it.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar:Render();
		Petring = Interface.Petring:Render();
		Cluster = Interface.Cluster:Render {
			rescale  = '90';
			children = {
				PADDLEFT     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =  176, y =  40 } };
				PADDRIGHT    = Handle:Warp { dir = 'RIGHT', pos = { point =  'LEFT', x =  306, y =  40 } };
				PADDUP       = Handle:Warp { dir =    'UP', pos = { point =  'LEFT', x =  240, y =  84 } };
				PADDDOWN     = Handle:Warp { dir =  'DOWN', pos = { point =  'LEFT', x =  240, y =   0 } };
				PAD2         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x = -176, y =  40 } };
				PAD3         = Handle:Warp { dir =  'LEFT', pos = { point = 'RIGHT', x = -306, y =  40 } };
				PAD4         = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', x = -240, y =  84 } };
				PAD1         = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', x = -240, y =   0 } };
				PADLSHOULDER = Handle:Warp { dir =    'UP', pos = { point =  'LEFT', x =  456, y =  40 } };
				PADRSHOULDER = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', x = -456, y =  40 } };
				PADLTRIGGER  = Handle:Warp { dir =  'DOWN', pos = { point =  'LEFT', x =  396, y =   0 } };
				PADRTRIGGER  = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', x = -396, y =   0 } };
			};
		};
	};
};

Presets.Orthodox = {
	name       = 'Orthodox';
	desc       = 'A cluster bar with a toolbar below it, laid out horizontally.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render();
		Cluster = Interface.Cluster : Render {
			rescale = '80';
			children = {
				PADDRIGHT    = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =  320, y =  0 } };
				PADDLEFT     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =   32, y =  0 } };
				PADDDOWN     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =  128, y =  0 } };
				PADDUP       = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =  224, y =  0 } };
				PADLTRIGGER  = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =  512, y =  0 } };
				PADLSHOULDER = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =  416, y =  0 } };
				PAD1         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x = -224, y =  0 } };
				PAD2         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x =  -32, y =  0 } };
				PAD3         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x = -320, y =  0 } };
				PAD4         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x = -128, y =  0 } };
				PADRTRIGGER  = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x = -512, y =  0 } };
				PADRSHOULDER = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x = -416, y =  0 } };
			};
		};
	};
};

---------------------------------------------------------------
-- Crossbar (group) presets
---------------------------------------------------------------
Handle = Interface.GroupButton(); -- reuse one handle instance and warp it
Presets.CrossbarMinimal = {
	name 	   = 'Minimal Crossbar';
	desc       = 'Group buttons in a single crossbar layout, with modifier swapping.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		Crossbar = Interface.Group : Render {
			modifier = '[nomod] ; [mod:M2M1] M2M1; [mod:M1] M1; [mod:M2] M2;';
			pos = { point = 'BOTTOM', y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point = 'RIGHT', x = -150, y =  25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point = 'RIGHT', x = -150, y = -25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =   50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =  150, y =  25 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x =  150, y = -25 } };
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

Presets.Grid = {
	name 	   = 'Grid';
	desc       = 'Group buttons by modifier in a grid layout.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		DividerMid = Interface.Divider : Render {
			breadth    = 300;
			depth      = 100;
			transition = 150;
			opacity    = '[mod:ALT-] 50; [mod:M2M1] 100; 50';
			pos = { point = 'BOTTOM', y = 120 };
		};
		DividerLeft = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 90;
			transition = 150;
			opacity  = '[mod:ALT-][mod:M2M1] 50; [mod:M1] 100; 50';
			pos = { point = 'BOTTOM', x = -153, y = 120 };
		};
		DividerRight = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 270;
			transition = 150;
			opacity  = '[mod:ALT-][mod:M2M1] 50; [mod:M2] 100; 50';
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

Presets.Crossbar = {
	name 	   = 'Crossbar';
	desc       = 'Group buttons in crossbar layouts, with modifier swapping.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		['Left Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 90;
			thickness  = 4;
			transition = 150;
			rescale  = '[mod:M2M1] 100; [mod:M1] 110; 100';
			opacity  = '[mod:M2M1] 0; [mod:M1] 100; 50';
			pos = { point = 'BOTTOM', x = -3, y = 75 };
		};
		['Right Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 270;
			thickness  = 4;
			transition = 150;
			rescale  = '[mod:M2M1] 100; [mod:M2] 110; 100';
			opacity  = '[mod:M2M1] 0; [mod:M2] 100; 50';
			pos = { point = 'BOTTOM', x = 3, y = 75 };
		};
		Left = Interface.Group : Render {
			modifier   = '[] M1';
			width      = 300;
			rescale    = '[mod:M2M1] 100; [mod:M1] 110; 100';
			visibility = '[mod:M2M1] hide; show';
			pos = { point = 'BOTTOM', x = -160, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =   50, y =  25 } };
			};
		};
		Right = Interface.Group : Render {
			modifier   = '[] M2';
			width      = 300;
			rescale    = '[mod:M2M1] 100; [mod:M2] 110; 100';
			visibility = '[mod:M2M1] hide; show';
			pos = { point = 'BOTTOM', x = 160, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =   50, y =  25 } };
			};
		};
		Center = Interface.Group : Render {
			modifier   = '[] M2M1';
			width      = 300;
			rescale    = '110';
			visibility = '[mod:M2M1] show; hide';
			pos = { point = 'BOTTOM', x = 0, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', x =   50, y =  25 } };
			};
		};
		Triggers = Interface.Group : Render {
			modifier = '[nomod] ; [mod:M2M1] M2M1; [mod:M1] M1; [mod:M2] M2;';
			width   = 210;
			height  = 50;
			rescale = '75';
			pos = { point = 'BOTTOM', y = 200 };
			children = {
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =   0, y = 0 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x =  50, y = 0 } };
				PADRSHOULDER = Handle:Warp { pos = { point = 'RIGHT', x =   0, y = 0 } };
				PADRTRIGGER  = Handle:Warp { pos = { point = 'RIGHT', x = -50, y = 0 } };
			};
		};
	};
};