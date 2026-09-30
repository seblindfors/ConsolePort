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
-- Layer validation
---------------------------------------------------------------
-- One group per feature of the input layer controller, so that a
-- latched layer can be told apart from a held one at a glance. Each
-- group sits at 10% until its own layer is live, except the one that
-- hides outright, which exercises the engine's visibility shorthand
-- rather than opacity.
---------------------------------------------------------------
do  local function Glyph(modifier, x, y)
		return Interface.Glyph : Render {
			modifier = modifier;
			size     = 28;
			pos      = { point = 'BOTTOM', relPoint = 'BOTTOM', x = x, y = y };
		};
	end

	local function Group(modifier, opacity, visibility, x, y)
		return Interface.Group : Render {
			modifier   = modifier;
			opacity    = opacity;
			visibility = visibility;
			pos    = { point = 'BOTTOM', relPoint = 'BOTTOM', x = x, y = y };
			width  = 120;
			height = 60;
			children = {
				PAD1 = Handle:Warp { pos = { point = 'LEFT', relPoint = 'LEFT', x = 35, y = 0 } };
				PAD2 = Handle:Warp { pos = { point = 'LEFT', relPoint = 'LEFT', x = 85, y = 0 } };
			};
		};
	end

	Presets.Layers = {
		name       = 'Layer Test';
		desc       = 'One group per input layer feature, for validating latches against holds.';
		visibility = env.Const.ManagerVisibility;
		children = {
			Vehicle = DefaultVehicle;
			-- Base, so there is something to return to.
			Base    = Group('[nomod] ;', '[nomod] 100; 10', nil, -260, 30);
			-- Pure layer driver: every clause belongs to the controller.
			Shift   = Group('[] M1;', '[mod:M1] 100; 10', nil, -130, 30);
			-- Mixed driver: the first segment stays with the engine, so
			-- this one also proves the residual trigger still fires.
			Ctrl    = Group('[] M2;', '[vehicleui][overridebar] 0; [mod:M2] 100; 10', nil, 0, 30);
			-- Reachable only by double tapping, and only while the
			-- Doubled Bar option is on.
			Doubled = Group('[] M1M1;', '[mod:M1M1] 100; 10', nil, 130, 30);
			-- Shift then Ctrl, which is a different layer from M2M1
			-- only while Modifier Order is on.
			Ordered = Group('[] M1M2;', '[mod:M1M2] 100; 10', nil, 260, 30);
			-- Shown rather than dimmed, through state-visibility.
			Hidden  = Group('[] M2M1;', nil, '[mod:M2M1] show; hide', 0, 100);

			-- Static labels, so each group says which layer it answers
			-- for without having to read the driver.
			LabelBase    = Glyph('M0',   -260, 95);
			LabelShift   = Glyph('M1',   -130, 95);
			LabelCtrl    = Glyph('M2',      0, 95);
			LabelDoubled = Glyph('M1M1',  130, 95);
			LabelOrdered = Glyph('M1M2',  260, 95);

			-- The layer the controller reports it is in, right now.
			LayerNow = Interface.Glyph : Render {
				dynamic = true;
				size    = 48;
				pos     = { point = 'CENTER', relPoint = 'CENTER', y = 120 };
			};
		};
	};
end
