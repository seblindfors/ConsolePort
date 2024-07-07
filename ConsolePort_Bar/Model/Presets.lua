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
-- Toolbar presets
---------------------------------------------------------------
local DefaultVehicle = Interface.Page : Render {
	pos        = { y = 32 };
	slots      = 6;
	rescale    = '120';
	page       = 'override';
	visibility = '[vehicleui][overridebar] show; hide';
};

---------------------------------------------------------------
-- Cluster bar presets
---------------------------------------------------------------
local Handle = Interface.ClusterHandle(); -- reuse one handle instance and warp it

Presets.Default = {
	name       = DEFAULT;
	desc       = 'A cluster bar with a toolbar below it.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar  = Interface.Toolbar:Render {
			totem = { pos = { y = 18 } };
		};
		VehicleL = Interface.Page : Render {
			pos        = { x = -126, y = 54 };
			slots      = 3;
			rescale    = '120';
			page       = 'override';
			visibility = '[vehicleui][overridebar] show; hide';
		};
		VehicleR = Interface.Page : Render {
			pos        = { x = 126, y = 54 };
			slots      = 3;
			offset     = 4;
			rescale    = '120';
			page       = 'override';
			visibility = '[vehicleui][overridebar] show; hide';
		};
		Petring  = Interface.Petring:Render();
		Cluster  = Interface.Cluster:Render {
			rescale  = '90';
			children = {
				PADDLEFT     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  176, y =  40 } };
				PADDRIGHT    = Handle:Warp { dir = 'RIGHT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  306, y =  40 } };
				PADDUP       = Handle:Warp { dir =    'UP', pos = { point =  'LEFT', relPoint =  'LEFT', x =  240, y =  84 } };
				PADDDOWN     = Handle:Warp { dir =  'DOWN', pos = { point =  'LEFT', relPoint =  'LEFT', x =  240, y =   0 } };
				PAD2         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -176, y =  40 } };
				PAD3         = Handle:Warp { dir =  'LEFT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -306, y =  40 } };
				PAD4         = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -240, y =  84 } };
				PAD1         = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -240, y =   0 } };
				PADLSHOULDER = Handle:Warp { dir =    'UP', pos = { point =  'LEFT', relPoint =  'LEFT', x =  456, y =  40 } };
				PADRSHOULDER = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -456, y =  40 } };
				PADLTRIGGER  = Handle:Warp { dir =  'DOWN', pos = { point =  'LEFT', relPoint =  'LEFT', x =  396, y =   0 } };
				PADRTRIGGER  = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -396, y =   0 } };
			};
		};
	};
};

Presets.Orthodox = {
	name       = 'Orthodox';
	desc       = 'A cluster bar with a toolbar below it, laid out horizontally.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar  = Interface.Toolbar:Render {
			totem = { pos = { y = 116 } };
		};
		VehicleL = Interface.Page : Render {
			pos        = { x = -126, y = 50 };
			slots      = 3;
			rescale    = '110';
			page       = 'override';
			visibility = '[vehicleui][overridebar] show; hide';
		};
		VehicleR = Interface.Page : Render {
			pos        = { x = 126, y = 50 };
			slots      = 3;
			offset     = 4;
			rescale    = '110';
			page       = 'override';
			visibility = '[vehicleui][overridebar] show; hide';
		};
		Petring = Interface.Petring:Render {
			scale = 0.7;
			pos   = { y = 75 };
		};
		Cluster = Interface.Cluster:Render {
			width   = 1325;
			rescale = '80';
			children = {
				PADDRIGHT    = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  320, y =  0 } };
				PADDLEFT     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =   32, y =  0 } };
				PADDDOWN     = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  128, y =  0 } };
				PADDUP       = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  224, y =  0 } };
				PADLTRIGGER  = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  512, y =  0 } };
				PADLSHOULDER = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  416, y =  0 } };
				PAD1         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -224, y =  0 } };
				PAD2         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -32, y =  0 } };
				PAD3         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -320, y =  0 } };
				PAD4         = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -128, y =  0 } };
				PADRTRIGGER  = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -512, y =  0 } };
				PADRSHOULDER = Handle:Warp { dir = 'RIGHT', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -416, y =  0 } };
			};
		};
	};
};

---------------------------------------------------------------
-- Crossbar (group) presets
---------------------------------------------------------------
Handle = Interface.GroupButton(); -- reuse one handle instance and warp it
Presets.CrossbarMinimal = {
	name 	   = 'Crossbar: Minimal';
	desc       = 'Group buttons in a single crossbar layout, with modifier swapping.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		Petring = Interface.Petring:Render {
			scale = 0.7;
			pos   = { x = 380, y = 84 };
		};
		Vehicle = DefaultVehicle;
		Crossbar = Interface.Group : Render {
			modifier = '[nomod] ; [mod:M2M1] M2M1; [mod:M1] M1; [mod:M2] M2;';
			pos = { point = 'BOTTOM', y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -150, y =  25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -150, y = -25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  150, y =  25 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  150, y = -25 } };
			};
		};
	};
};

Presets.Crossbar = {
	name 	   = 'Crossbar: Standard';
	desc       = 'Group buttons for left and right triggers, with modifier swapping.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		Petring = Interface.Petring:Render {
			scale = 0.7;
			pos   = { x = 600, y = 80 };
		};
		Vehicle = DefaultVehicle;
		['Left Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 90;
			thickness  = 4;
			transition = 150;
			rescale  = '[mod:M2M1] 100; [mod:M1] 110; 100';
			opacity  = '[vehicleui][overridebar] 0; [mod:M2M1] 0; [mod:M1] 100; 50';
			pos = { point = 'BOTTOM', x = -3, y = 75 };
		};
		['Right Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 270;
			thickness  = 4;
			transition = 150;
			rescale  = '[mod:M2M1] 100; [mod:M2] 110; 100';
			opacity  = '[vehicleui][overridebar] 0; [mod:M2M1] 0; [mod:M2] 100; 50';
			pos = { point = 'BOTTOM', x = 3, y = 75 };
		};
		Left = Interface.Group : Render {
			modifier   = '[] M1';
			width      = 300;
			rescale    = '[mod:M2M1] 100; [mod:M1] 110; 100';
			visibility = '[vehicleui][overridebar][mod:M2M1] hide; show';
			pos = { point = 'BOTTOM', x = -160, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y =  25 } };
			};
		};
		Right = Interface.Group : Render {
			modifier   = '[] M2';
			width      = 300;
			rescale    = '[mod:M2M1] 100; [mod:M2] 110; 100';
			visibility = '[vehicleui][overridebar][mod:M2M1] hide; show';
			pos = { point = 'BOTTOM', x = 160, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y =  25 } };
			};
		};
		Center = Interface.Group : Render {
			modifier   = '[] M2M1';
			width      = 300;
			rescale    = '110';
			visibility = '[vehicleui][overridebar] hide; [mod:M2M1] show; hide';
			pos = { point = 'BOTTOM', x = 0, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y =  25 } };
			};
		};
		Triggers = Interface.Group : Render {
			modifier = '[nomod] ; [mod:M2M1] M2M1; [mod:M1] M1; [mod:M2] M2;';
			width   = 210;
			height  = 50;
			rescale = '75';
			pos = { point = 'BOTTOM', y = 200 };
			visibility = '[vehicleui][overridebar] hide; show';
			children = {
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = 0 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = 0 } };
				PADRSHOULDER = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =   0, y = 0 } };
				PADRTRIGGER  = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -50, y = 0 } };
			};
		};
	};
};

Presets.CrossbarTriple = {
	name 	   = 'Crossbar: Triple';
	desc       = 'Group buttons in three layouts, with center modifier swapping.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar : Render {
			menu = { eye = false };
			width = 600;
		};
		Petring = Interface.Petring:Render {
			scale = 0.6;
			pos   = { x = -276, y = 240 };
		};
		Vehicle = DefaultVehicle;
		['Left Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 90;
			thickness  = 2;
			transition = 150;
			rescale  = '[mod:M2M1] 100; [mod:M1] 105; 100';
			opacity  = '[vehicleui][overridebar][mod:M2] 0; [mod:M2M1] 75; [mod:M1] 100; 50';
			pos = { point = 'BOTTOM', x = -168, y = 75 };
		};
		['Right Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 270;
			thickness  = 2;
			transition = 150;
			rescale  = '[mod:M2M1] 100; [mod:M2] 105; 100';
			opacity  = '[vehicleui][overridebar][mod:M1] 0; [mod:M2M1] 75; [mod:M2] 100; 50';
			pos = { point = 'BOTTOM', x = 168, y = 75 };
		};
		['Center Left Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 270;
			thickness  = 2;
			transition = 150;
			rescale  = '[mod:M2M1][mod:M0] 105; 100';
			opacity  = '[vehicleui][overridebar] 0; [mod:M0][mod:M2M1] 100; 0';
			pos = { point = 'BOTTOM', x = -158, y = 75 };
		};
		['Center Right Divider'] = Interface.Divider : Render {
			breadth    = 100;
			depth      = 300;
			rotation   = 90;
			thickness  = 2;
			transition = 150;
			rescale  = '[mod:M2M1][mod:M0] 105; 100';
			opacity  = '[vehicleui][overridebar] 0; [mod:M0][mod:M2M1] 100; 0';
			pos = { point = 'BOTTOM', x = 158, y = 75 };
		};
		Left = Interface.Group : Render {
			modifier   = '[] M1';
			width      = 300;
			rescale    = '[mod:M2M1] 100; [mod:M1] 105; 100';
			pos = { point = 'BOTTOM', x = -325, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y =  25 } };
			};
		};
		Right = Interface.Group : Render {
			modifier   = '[] M2';
			width      = 300;
			rescale    = '[mod:M2M1] 100; [mod:M2] 105; 100';
			pos = { point = 'BOTTOM', x = 325, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y =  25 } };
			};
		};
		Center = Interface.Group : Render {
			modifier   = '[mod:M2M1] M2M1; [mod:M0] M0';
			width      = 300;
			rescale    = '[mod:M2M1][mod:M0] 105; 100';
			pos = { point = 'BOTTOM', x = 0, y = 25 };
			children = {
				PAD1         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y = -25 } };
				PAD2         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =    0, y =   0 } };
				PAD3         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -100, y =   0 } };
				PAD4         = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -50, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =    0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   50, y =  25 } };
			};
		};
		Triggers = Interface.Group : Render {
			modifier = '[nomod] ; [mod:M2M1] M2M1; [mod:M1] M1; [mod:M2] M2;';
			width   = 210;
			height  = 50;
			rescale = '75';
			pos = { point = 'BOTTOM', y = 200 };
			visibility = '[vehicleui][overridebar] hide; show';
			children = {
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = 0 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = 0 } };
				PADRSHOULDER = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x =   0, y = 0 } };
				PADRTRIGGER  = Handle:Warp { pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -50, y = 0 } };
			};
		};
	};
};

Presets.Keyboard = {
	name       = 'Keyboard';
	desc       = 'A regular action bar.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Toolbar = Interface.Toolbar:Render {
			width = 725;
		};
		Petring = Interface.Petring:Render {
			scale = 0.7;
			pos   = { x = 504, y = 100 };
		};
		['Bar 1'] = Interface.Page:Render {
			visibility = 'show';
			pos = { y = 24 };
		};
		['Bar 2'] = Interface.Page:Render {
			pos  = { y = 74 };
			page = '6';
		};
		['Bar 3'] = Interface.Page:Render {
			pos  = { y = 124 };
			page = '5';
		};
	};
};