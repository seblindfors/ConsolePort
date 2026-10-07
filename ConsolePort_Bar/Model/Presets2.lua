-- Presets that I made but don't think should be included in the main file.
-- They're here for reference and to keep the main file clean.

local _, env = ...;
---------------------------------------------------------------
local Presets   = env.Presets;
local Interface = env.Interface;
local Handle    = Interface.ClusterHandle();
---------------------------------------------------------------
local DefaultVehicle = Interface.Page : Render {
	pos        = { y = 32 };
	slots      = 6;
	rescale    = '120';
	page       = 'override';
	visibility = '[vehicleui][overridebar] show; hide';
};

---------------------------------------------------------------
Presets.Grid = {
	name 	   = 'Grid';
	desc       = 'Group buttons by modifier in a grid layout.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Watchbar = Interface.Watchbar:Render {
			width = 600;
		};
		Toolbar  = Interface.Toolbar:Render {
			menu = { eye = false };
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
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 120 };
		};
		DividerLeft = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 90;
			transition = 150;
			opacity  = '[vehicleui][overridebar] 0; [mod:ALT-][mod:M2M1] 50; [mod:M1] 100; 50';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', x = -153, y = 120 };
		};
		DividerRight = Interface.Divider : Render {
			breadth    = 200;
			depth      = 150;
			rotation   = 270;
			transition = 150;
			opacity  = '[vehicleui][overridebar] 0; [mod:ALT-][mod:M2M1] 50; [mod:M2] 100; 50';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', x = 147, y = 120 };
		};
		Nomod = Interface.Group : Render {
			opacity  = '[nomod] 100; 10';
			modifier = '[nomod] ;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 25 };
			width  = 300;
			height = 100;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 200, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y = -25 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y = -25 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 200, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y =  25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = -25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = -25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =  25 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y =  25 } };
			};
		};
		Shift = Interface.Group : Render {
			opacity  = '[mod:ALT-][mod:M2M1] 10; [mod:M1] 100; 10';
			modifier = '[] M1;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', x = -225, y = 25 };
			width  = 150;
			height = 200;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -75 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = -75 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = -75 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = -25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = -25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =  25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y =  25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y =  25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y =  75 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =  75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y =  75 } };
			};
		};
		Ctrl = Interface.Group : Render {
			opacity  = '[mod:ALT-][mod:M2M1] 10; [mod:M2] 100; 10';
			modifier = '[] M2;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', x = 225, y = 25 };
			width  = 150;
			height = 200;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -75 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = -75 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = -75 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = -25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = -25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =  25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y =  25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y =  25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y =  75 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =  75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y =  75 } };
			};
		};
		CtrlShift = Interface.Group : Render {
			opacity  = '[mod:ALT-] 10; [mod:M2M1] 100; 10';
			modifier = '[] M2M1;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 125 };
			width  = 300;
			height = 100;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 200, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y = -25 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y = -25 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 200, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y =  25 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y =  25 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = -25 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = -25 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =  25 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y =  25 } };
			};
		};
	};
};

Presets.DiamondGrid = {
	name 	   = 'Diamond Grid';
	desc       = 'Group buttons by modifier in a diamond layout.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Watchbar = Interface.Watchbar:Render {
			width = 600;
		};
		Toolbar  = Interface.Toolbar:Render {
			menu = { eye = false };
		};
		Petring = Interface.Petring:Render {
			scale = 0.65;
			pos   = { x = 0, y = 370 };
		};
		Vehicle = DefaultVehicle;
		Nomod = Interface.Group : Render {
			opacity  = '[nomod] 100; 10';
			modifier = '[nomod] ;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 400, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 450, y =   0 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 350, y =   0 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 400, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 350, y =  50 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 350, y = -50 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 200, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 300, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 300, y =  50 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 300, y = -50 } };
			};
		};
		Shift = Interface.Group : Render {
			opacity  = '[mod:M2M1] 10; [mod:M1] 100; 10';
			modifier = '[] M1;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 500, y = -75 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 550, y = -50 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 450, y = -50 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 500, y = -25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 600, y = -75 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 400, y = -75 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = -50 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 200, y = -50 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y = -75 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y = -25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y = -75 } };
			};
		};
		Ctrl = Interface.Group : Render {
			opacity  = '[mod:M2M1] 10; [mod:M2] 100; 10';
			modifier = '[] M2;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 500, y = 25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 550, y = 50 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 450, y = 50 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 500, y = 75 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 600, y = 75 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 400, y = 75 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y = 50 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 200, y = 50 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y = 25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 150, y = 75 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = 75 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 250, y = 75 } };
			};
		};
		CtrlShift = Interface.Group : Render {
			opacity  = '[mod:M2M1] 100; 10';
			modifier = '[] M2M1;';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 75 };
			width = 700;
			children = {
				PAD1         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 600, y = -25 } };
				PAD2         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 650, y =   0 } };
				PAD3         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 550, y =   0 } };
				PAD4         = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 600, y =  25 } };
				PADRSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 650, y =  50 } };
				PADRTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 650, y = -50 } };
				PADDLEFT     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =   0 } };
				PADDRIGHT    = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x = 100, y =   0 } };
				PADDDOWN     = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y = -25 } };
				PADDUP       = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =  50, y =  25 } };
				PADLSHOULDER = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y =  50 } };
				PADLTRIGGER  = Handle:Warp { pos = { point =  'LEFT', relPoint =  'LEFT', x =   0, y = -50 } };
			};
		};
	};
};

---------------------------------------------------------------
-- Gallery
---------------------------------------------------------------
Presets.Gallery = {
	name       = 'Gallery';
	desc       = 'Every element type in one layout, for testing.';
	visibility = env.Const.ManagerVisibility;
	children = {
		Watchbar = Interface.Watchbar:Render {
			width = 600;
		};
		Toolbar  = Interface.Toolbar:Render {};
		Petring  = Interface.Petring:Render {
			scale = 0.65;
			pos   = { x = 500, y = 120 };
		};
		Vehicle  = DefaultVehicle;
		Cluster  = Interface.Cluster:Render {
			width   = 600;
			rescale = '80';
			pos     = { y = 30 };
			children = {
				PADDLEFT  = Handle:Warp { dir =  'LEFT', pos = { point =  'LEFT', relPoint =  'LEFT', x =   60, y = 0 } };
				PADDRIGHT = Handle:Warp { dir = 'RIGHT', pos = { point =  'LEFT', relPoint =  'LEFT', x =  180, y = 0 } };
				PAD1      = Handle:Warp { dir =  'DOWN', pos = { point = 'RIGHT', relPoint = 'RIGHT', x = -180, y = 0 } };
				PAD2      = Handle:Warp { dir =    'UP', pos = { point = 'RIGHT', relPoint = 'RIGHT', x =  -60, y = 0 } };
			};
		};
		Group = Interface.Group : Render {
			modifier = '[nomod] ;';
			opacity  = '[nomod] 100; 50';
			pos      = { point = 'BOTTOM', relPoint = 'BOTTOM', x = -300, y = 150 };
			width    = 200;
			height   = 50;
			children = {
				PADDUP       = Handle:Warp { pos = { point = 'LEFT', relPoint = 'LEFT', x =   0, y = 0 } };
				PADDDOWN     = Handle:Warp { pos = { point = 'LEFT', relPoint = 'LEFT', x =  50, y = 0 } };
				PADLSHOULDER = Handle:Warp { pos = { point = 'LEFT', relPoint = 'LEFT', x = 100, y = 0 } };
				PADLTRIGGER  = Handle:Warp { pos = { point = 'LEFT', relPoint = 'LEFT', x = 150, y = 0 } };
			};
		};
		Page = Interface.Page : Render {
			pos   = { x = 300, y = 150 };
			slots = 6;
			page  = '6';
		};
		Divider = Interface.Divider : Render {
			breadth    = 400;
			depth      = 60;
			transition = 150;
			opacity    = '[mod:M1] 100; 40';
			pos = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 110 };
		};
		GlyphShift = Interface.Glyph : Render {
			modifier = 'M1';
			size     = 28;
			pos      = { point = 'BOTTOM', relPoint = 'BOTTOM', x = -80, y = 220 };
		};
		GlyphLayer = Interface.Glyph : Render {
			dynamic = true;
			size    = 40;
			pos     = { point = 'BOTTOM', relPoint = 'BOTTOM', x = 80, y = 220 };
		};
		Collage = Interface.Art : Render {
			style  = 'Collage';
			flavor = 'Class';
			width  = 512;
			height = 128;
			pos    = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 300 };
		};
		Artifact = Interface.Art : Render {
			style  = 'Artifact';
			flavor = 'Class';
			width  = 512;
			height = 128;
			pos    = { point = 'BOTTOM', relPoint = 'BOTTOM', y = 440 };
		};
		TextureAtlas = Interface.Texture : Render {
			file  = 'UI-HUD-ActionBar-Frame';
			size  = { width = '[mod:M1] 192; 128', height = '[mod:M1] 48; 32' };
			color = '[combat] ffff4040; ffffffff';
			pos   = { point = 'BOTTOM', relPoint = 'BOTTOM', x = -400, y = 260 };
		};
		TexturePath = Interface.Texture : Render {
			file    = [[Interface\Icons\INV_Misc_QuestionMark]];
			size    = { width = '64', height = '64' };
			rescale = '[mod:M2] 150; 100';
			pos     = { point = 'BOTTOM', relPoint = 'BOTTOM', x = -400, y = 340 };
		};
		TextureID = Interface.Texture : Render {
			file    = '[mod:M1] 134400; 136243';
			size    = { width = '64', height = '64' };
			opacity = '[combat] 100; 60';
			pos     = { point = 'BOTTOM', relPoint = 'BOTTOM', x = -400, y = 420 };
		};
	};
};
