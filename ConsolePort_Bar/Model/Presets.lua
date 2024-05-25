local _, env = ...;
---------------------------------------------------------------

function env:GetDefaultLayout()
	return env.Presets.Crossbar;
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
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = Interface.Toolbar:Render();
		Cluster = Interface.Cluster:Render {
			children = {
				PADDLEFT     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =  176, y =  56 } };
				PADDRIGHT    = Handle:Warp { dir = 'RIGHT', pos = { point =  'LEFT', x =  306, y =  56 } };
				PADDUP       = Handle:Warp { dir =    'UP', pos = { point =  'LEFT', x =  240, y = 100 } };
				PADDDOWN     = Handle:Warp { dir =  'DOWN', pos = { point =  'LEFT', x =  240, y =  16 } };
				PAD2         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x = -176, y =  56 } };
				PAD3         = Handle:Warp { dir =  'LEFT', pos = { point = 'RIGHT', x = -306, y =  56 } };
				PAD4         = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', x = -240, y = 100 } };
				PAD1         = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', x = -240, y =  16 } };
				PADLSHOULDER = Handle:Warp { dir = 'RIGHT', pos = { point =  'LEFT', x =  456, y =  56 } };
				PADRSHOULDER = Handle:Warp { dir =  'LEFT', pos = { point = 'RIGHT', x = -456, y =  56 } };
				PADLTRIGGER  = Handle:Warp { dir =  'DOWN', pos = { point =  'LEFT', x =  396, y =  16 } };
				PADRTRIGGER  = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', x = -396, y =  16 } };
			};
		};
	};
};

Presets.Orthodox = {
	name       = 'Orthodox';
	desc       = 'A cluster bar with a toolbar below it, laid out horizontally.';
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = Interface.Toolbar : Render();
		Cluster = Interface.Cluster : Render {
			children = {
				PADDRIGHT    = Handle:Warp { dir = 'RIGHT', pos = { point =  'LEFT', x =  330, y =  9 } };
				PADDLEFT     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', x =   80, y =  9 } };
				PADDDOWN     = Handle:Warp { dir =  'DOWN', pos = { point =  'LEFT', x =  165, y =  9 } };
				PADDUP       = Handle:Warp { dir =    'UP', pos = { point =  'LEFT', x =  250, y =  9 } };
				PAD2         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', x =  -80, y =  9 } };
				PAD3         = Handle:Warp { dir =  'LEFT', pos = { point = 'RIGHT', x = -330, y =  9 } };
				PAD1         = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', x = -250, y =  9 } };
				PAD4         = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', x = -165, y =  9 } };
				PADLSHOULDER = Handle:Warp { dir =    'UP', pos = { point =  'LEFT', x =  405, y = 75 } };
				PADLTRIGGER  = Handle:Warp { dir = 'RIGHT', pos = { point =  'LEFT', x =  440, y =  9 } };
				PADRSHOULDER = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', x = -405, y = 75 } };
				PADRTRIGGER  = Handle:Warp { dir =  'LEFT', pos = { point = 'RIGHT', x = -440, y =  9 } };
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
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = Interface.Toolbar : Render {
			width = 600;
		};
		Actionbar = Interface.Group : Render {
			modifier = '[nomod] ; [mod:CTRL-SHIFT-] CTRL-SHIFT-; [mod:SHIFT-] SHIFT-; [mod:CTRL-] CTRL-;';
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
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = Interface.Toolbar : Render {
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
			opacity  = '[mod:CTRL-SHIFT-] 10; [mod:SHIFT-] 100; 10';
			modifier = '[] SHIFT-;';
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
			opacity  = '[mod:CTRL-SHIFT-] 10; [mod:CTRL-] 100; 10';
			modifier = '[] CTRL-;';
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
			opacity  = '[mod:CTRL-SHIFT-] 100; 10';
			modifier = '[] CTRL-SHIFT-;';
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
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = Interface.Toolbar : Render {
			width = 600;
		};
		DividerMid = Interface.Divider : Render {
			breadth    = 300;
			depth      = 100;
			transition = 150;
			opacity    = '[mod:ALT-] 50; [mod:CTRL-SHIFT-] 100; 50';
			pos = { point = 'BOTTOM', y = 120 };
		};
		DividerLeft = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 90;
			transition = 150;
			opacity  = '[mod:ALT-][mod:CTRL-SHIFT-] 50; [mod:SHIFT-] 100; 50';
			pos = { point = 'BOTTOM', x = -153, y = 120 };
		};
		DividerRight = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 270;
			transition = 150;
			opacity  = '[mod:ALT-][mod:CTRL-SHIFT-] 50; [mod:CTRL-] 100; 50';
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
			opacity  = '[mod:ALT-][mod:CTRL-SHIFT-] 10; [mod:SHIFT-] 100; 10';
			modifier = '[] SHIFT-;';
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
			opacity  = '[mod:ALT-][mod:CTRL-SHIFT-] 10; [mod:CTRL-] 100; 10';
			modifier = '[] CTRL-;';
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
			opacity  = '[mod:ALT-] 10; [mod:CTRL-SHIFT-] 100; 10';
			modifier = '[] CTRL-SHIFT-;';
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
	name 	   = 'Minimal Crossbar';
	desc       = 'Group buttons in a single crossbar layout, with modifier swapping.';
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = Interface.Toolbar : Render {
			width = 600;
		};
		['Left Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 90;
			thickness  = 4;
			transition = 150;
			rescale  = '[mod:CTRL-SHIFT-] 100; [mod:SHIFT-] 110; 100';
			opacity  = '[mod:CTRL-SHIFT-] 0; [mod:SHIFT-] 100; 50';
			pos = { point = 'BOTTOM', x = -3, y = 75 };
		};
		['Right Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 270;
			thickness  = 4;
			transition = 150;
			rescale  = '[mod:CTRL-SHIFT-] 100; [mod:CTRL-] 110; 100';
			opacity  = '[mod:CTRL-SHIFT-] 0; [mod:CTRL-] 100; 50';
			pos = { point = 'BOTTOM', x = 3, y = 75 };
		};
		Left = Interface.Group : Render {
			modifier   = '[] SHIFT-';
			width      = 300;
			rescale    = '[mod:CTRL-SHIFT-] 100; [mod:SHIFT-] 110; 100';
			visibility = '[mod:CTRL-SHIFT-] hide; show';
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
			modifier   = '[] CTRL-';
			width      = 300;
			rescale    = '[mod:CTRL-SHIFT-] 100; [mod:CTRL-] 110; 100';
			visibility = '[mod:CTRL-SHIFT-] hide; show';
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
			modifier   = '[] CTRL-SHIFT-';
			width      = 300;
			rescale    = '110';
			visibility = '[mod:CTRL-SHIFT-] show; hide';
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
			modifier = '[nomod] ; [mod:CTRL-SHIFT-] CTRL-SHIFT-; [mod:SHIFT-] SHIFT-; [mod:CTRL-] CTRL-;';
			width   = 210;
			height  = 50;
			rescale = '75';
			pos = { point = 'BOTTOM', y = 175 };
			children = {
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', x =  0 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', x = 50 } };
				PADRSHOULDER = Handle:Warp { pos = { point = 'RIGHT', x =  0 } };
				PADRTRIGGER  = Handle:Warp { pos = { point = 'RIGHT', x = -50 } };
			};
		};
	};
};