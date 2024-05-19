local _, env = ...;
local Data, _ = env.db.Data, CPAPI.Define;
---------------------------------------------------------------
do -- Variables
---------------------------------------------------------------
local classColor = CreateColor(CPAPI.NormalizeColor(CPAPI.GetClassColor()));

env:Register('Variables', CPAPI.Callable({
	---------------------------------------------------------------
	_'Action Bars';
	---------------------------------------------------------------
	---------------------------------------------------------------
	_'Clusters';
	---------------------------------------------------------------
	clusterShowAll = _{Data.Bool(false);
		name = 'Always Show All Buttons';
		desc = 'Show all enabled combinations in the cluster at all times.';
		note = 'By default, shows modifiers on mouseover and on cooldown.';
	};
	clusterShowMainIcons = _{Data.Bool(true);
		name = 'Show Main Icons';
		desc = 'Show the icons for main buttons.';
	};
	clusterShowFlyoutIcons = _{Data.Bool(true);
		name = 'Show Modifier Icons';
		desc = 'Show the icons for modifier buttons.';
	};
	clusterFullStateModifier = _{Data.Bool(false);
		name = 'Full State Modifier';
		desc = 'Enable all modifier states for the cluster, including unmapped modifiers.';
	};
	clusterBorderStyle = _{Data.Select('Normal', 'Normal', 'Large', 'Beveled');
		name = 'Main Button Border Style';
		desc = 'Style of the border around main buttons.';
	};
	---------------------------------------------------------------
	_'Toolbar';
	---------------------------------------------------------------
	enableXPBar = _{Data.Bool(true);
		name = 'Enable Watch Bars';
		desc = 'Show the XP bar at the bottom of the toolbar.';
	};
	fadeXPBar = _{Data.Bool(false);
		name = 'Fade Watch Bars';
		desc = 'Fade out the XP bar when not mousing over it.';
		deps = { enableXPBar = true };
	};
	---------------------------------------------------------------
	_'Colors';
	---------------------------------------------------------------
	xpBarColor = _{Data.Color(classColor);
		name = 'XP Bar Color';
		desc = 'Color of the main XP bar.';
		deps = { enableXPBar = true };
	};
	swipeColor = _{Data.Color(classColor);
		name = 'Swipe Color';
		desc = 'Color of the cooldown swipe effect on buttons.';
	};
	tintColor = _{Data.Color(classColor);
		name = 'Tint Color';
		desc = 'Color of the tint effect on bars.';
	};
	procColor = _{Data.Color(classColor);
		name = 'Spell Proc Color';
		desc = 'Color of the spell proc effect.';
	};
	borderColor = _{Data.Color(WHITE_FONT_COLOR);
		name = 'Border Vertex Color';
		desc = 'Color of the vertices on the border of buttons.';
	};
}, function(self, key) return (rawget(self, key) or {})[1] end))
---------------------------------------------------------------
end -- Variables

---------------------------------------------------------------
do -- Cluster information
---------------------------------------------------------------
local M1, M2, M3 = 'M1', 'M2', 'M3';
---------------------------------------------------------------
local NOMOD,  SHIFT,    CTRL,    ALT =
      '',    'SHIFT-', 'CTRL-', 'ALT-';
---------------------------------------------------------------
local SIZE_L,  SIZE_S,  SIZE_T  = 64, 46, 58;
local OFS_MOD, OFS_MID, OFS_FIX = 38, 21, 4;
-----------------------------------------------------------------------------------------------------------------------
local HK_ICONS_SIZE_L, HK_ICONS_SIZE_S = 32, 20;
local HK_ATLAS_SIZE_L, HK_ATLAS_SIZE_S = 18, 12;
-----------------------------------------------------------------------------------------------------------------------
env.ClusterConstants = {
	Directions = CPAPI.Enum('UP', 'DOWN', 'LEFT', 'RIGHT');
	Types      = CPAPI.Enum('Cluster', 'ClusterHandle', 'ClusterButton', 'ClusterHotkey', 'ClusterShadow');
	ModNames   = CPAPI.Enum(NOMOD, SHIFT, CTRL, CTRL..SHIFT, ALT, ALT..SHIFT, ALT..CTRL, ALT..CTRL..SHIFT);
	SnapPixels = 4;
	PxSize     = SIZE_L;
	Layout = {
		[NOMOD]      = { ----------------------------------------------------------------------------------------------------------
			Prefix   = nil;
			Shadow   = { 82 / SIZE_L, 0.3, CPAPI.GetAsset([[Textures\Button\Shadow]]), {'CENTER', 0, -6} };
			Level    = 4;
			Hotkey   = {{ HK_ICONS_SIZE_L, HK_ATLAS_SIZE_L, {'TOP', 0, 12}, nil }};
			-----------------------------------------------------------------------------------------------------------------------
		};
		[SHIFT]      = { ----------------------------------------------------------------------------------------------------------
			DOWN     = {'TOPRIGHT', 'BOTTOMLEFT',  OFS_MOD - OFS_FIX,  OFS_MOD + OFS_FIX, Coords = {0, 0,   1, 0,   0, 1,   1, 1}};
			UP       = {'BOTTOMRIGHT', 'TOPLEFT',  OFS_MOD - OFS_FIX, -OFS_MOD - OFS_FIX, Coords = {1, 0,   0, 0,   1, 1,   0, 1}};
			LEFT     = {'BOTTOMRIGHT', 'TOPLEFT',  OFS_MOD + OFS_FIX, -OFS_MOD + OFS_FIX, Coords = {1, 0,   1, 1,   0, 0,   0, 1}};
			RIGHT    = {'BOTTOMLEFT', 'TOPRIGHT', -OFS_MOD - OFS_FIX, -OFS_MOD + OFS_FIX, Coords = {0, 0,   0, 1,   1, 0,   1, 1}};
			-----------------------------------------------------------------------------------------------------------------------
			Prefix   = M1;
			Size     = SIZE_S / SIZE_L;
			TexSize  = SIZE_T / SIZE_S;
			Offset   = OFS_MOD / SIZE_L;
			Hotkey   = {{ HK_ICONS_SIZE_S, HK_ATLAS_SIZE_S, {'CENTER', 0, 0}, M1 }};
			-----------------------------------------------------------------------------------------------------------------------
		};
		[CTRL]       = { ----------------------------------------------------------------------------------------------------------
			DOWN     = {'TOPLEFT', 'BOTTOMRIGHT', -OFS_MOD + OFS_FIX,  OFS_MOD + OFS_FIX, Coords = {0, 1,   1, 1,   0, 0,   1, 0}};
			UP       = {'BOTTOMLEFT', 'TOPRIGHT', -OFS_MOD + OFS_FIX, -OFS_MOD - OFS_FIX, Coords = {1, 1,   0, 1,   1, 0,   0, 0}};
			LEFT     = {'TOPRIGHT', 'BOTTOMLEFT',  OFS_MOD + OFS_FIX,  OFS_MOD - OFS_FIX, Coords = {1, 1,   1, 0,   0, 1,   0, 0}};
			RIGHT    = {'TOPLEFT', 'BOTTOMRIGHT', -OFS_MOD - OFS_FIX,  OFS_MOD - OFS_FIX, Coords = {0, 1,   0, 0,   1, 1,   1, 0}};
			-----------------------------------------------------------------------------------------------------------------------
			Prefix   = M2;
			Size     = SIZE_S / SIZE_L;
			TexSize  = SIZE_T / SIZE_S;
			Offset   = OFS_MOD / SIZE_L;
			Hotkey   = {{ HK_ICONS_SIZE_S, HK_ATLAS_SIZE_S, {'CENTER', 0, 0}, M2 }};
			-----------------------------------------------------------------------------------------------------------------------
		};
		[CTRL..SHIFT] = { ----------------------------------------------------------------------------------------------------------
			DOWN     = {'TOP',          'BOTTOM',                  0,            OFS_MID, Coords = {0, 1,   1, 1,   0, 0,   1, 0}};
			UP       = {'BOTTOM',          'TOP',                  0,           -OFS_MID, Coords = {1, 1,   0, 1,   1, 0,   0, 0}};
			LEFT     = {'RIGHT',          'LEFT',            OFS_MID,                  0, Coords = {1, 0,   1, 1,   0, 0,   0, 1}};
			RIGHT    = {'LEFT',          'RIGHT',           -OFS_MID,                  0, Coords = {0, 0,   0, 1,   1, 0,   1, 1}};
			-----------------------------------------------------------------------------------------------------------------------
			Prefix   = M3;
			Size     = SIZE_S / SIZE_L;
			TexSize  = SIZE_T / SIZE_S * 0.9;
			Offset   = OFS_MID / SIZE_L;
			Hotkey   = {{ HK_ICONS_SIZE_S, HK_ATLAS_SIZE_S, {'CENTER', -4, 0}, M1 },
						{ HK_ICONS_SIZE_S, HK_ATLAS_SIZE_S, {'CENTER',  4, 0}, M2 }};
			-----------------------------------------------------------------------------------------------------------------------
		};
	};
	AdjustTextures = {
		[NOMOD] = {
			Border                =   env.GetAsset([[Textures\Button\Hilite]]);
			CheckedTexture        =   env.GetAsset([[Textures\Button\Hilite]]);
			NewActionTexture      =   env.GetAsset([[Textures\Button\Hilite]]);
			SpellHighlightTexture =   env.GetAsset([[Textures\Button\Hilite2x.png]]);
		};
		[SHIFT] = {
			Border                =   env.GetAsset([[Textures\Button\M1]]);
			NormalTexture         =   env.GetAsset([[Textures\Button\M1]]);
			PushedTexture         =   env.GetAsset([[Textures\Button\M1]]);
			HighlightTexture      =   env.GetAsset([[Textures\Button\M1Hilite]]);
			CheckedTexture        =   env.GetAsset([[Textures\Button\M1Hilite]]);
			NewActionTexture      =   env.GetAsset([[Textures\Button\M1Hilite]]);
			SpellHighlightTexture =   env.GetAsset([[Textures\Button\M1Hilite]]);
		};
		[CTRL] = {
			Border                =   env.GetAsset([[Textures\Button\M1]]);
			NormalTexture         =   env.GetAsset([[Textures\Button\M1]]);
			PushedTexture         =   env.GetAsset([[Textures\Button\M1]]);
			HighlightTexture      =   env.GetAsset([[Textures\Button\M1Hilite]]);
			CheckedTexture        =   env.GetAsset([[Textures\Button\M1Hilite]]);
			NewActionTexture      =   env.GetAsset([[Textures\Button\M1Hilite]]);
			SpellHighlightTexture =   env.GetAsset([[Textures\Button\M1Hilite]]);
		};
		[CTRL..SHIFT] = {
			Border                =   env.GetAsset([[Textures\Button\M3]]);
			NormalTexture         =   env.GetAsset([[Textures\Button\M3]]);
			PushedTexture         =   env.GetAsset([[Textures\Button\M3]]);
			HighlightTexture      =   env.GetAsset([[Textures\Button\M3Hilite]]);
			CheckedTexture        =   env.GetAsset([[Textures\Button\M3Hilite]]);
			NewActionTexture      =   env.GetAsset([[Textures\Button\M3Hilite]]);
			SpellHighlightTexture =   env.GetAsset([[Textures\Button\M3Hilite]]);
		};
	};
	Assets = {
		CooldownBling             =   env.GetAsset([[Textures\Cooldown\Bling]]);
		CooldownEdge              =   env.GetAsset([[Textures\Cooldown\Edge2x3.png]]);
		MainMask                  = CPAPI.GetAsset([[Textures\Button\Mask]]);
		MainSwipe                 =   env.GetAsset([[Textures\Cooldown\Swipe]]);
		EmptyIcon                 = CPAPI.GetAsset([[Textures\Button\EmptyIcon]]);
	};
	BorderStyle = {
		Normal = {
			NormalTexture         =   env.GetAsset([[Textures\Button\Normal]]);
			PushedTexture         =   env.GetAsset([[Textures\Button\Hilite]]);
			HighlightTexture      =   env.GetAsset([[Textures\Button\Hilite]]);
		};
		Large = {
			NormalTexture         =   env.GetAsset([[Textures\Button\Normal2x.png]]);
			PushedTexture         =   env.GetAsset([[Textures\Button\Normal2x.png]]);
			HighlightTexture      =   env.GetAsset([[Textures\Button\Hilite2x.png]]);
		};
		Beveled = {
			NormalTexture         = CPAPI.GetAsset([[Textures\Button\Normal]]);
			PushedTexture         = CPAPI.GetAsset([[Textures\Button\Hilite]]);
			HighlightTexture      =   env.GetAsset([[Textures\Button\Hilite]]);
		};
	};
	LABConfig = {
		clickOnDown     = true;
		flyoutDirection = 'RIGHT';
		showGrid        = true;
		tooltip         = 'enabled';
		colors = {
			mana =  { 0.5, 0.5, 1.0 };
			range = { 0.8, 0.1, 0.1 };
		};
		hideElements = {
			equipped = false;
			hotkey   = true;
			macro    = false;
		};
	};
};

env.ClusterConstants.Masks, env.ClusterConstants.Swipes = (function(layout, directions)
	-- Generated masks and swipes for each prefix, e.g.:
	-- env.ClusterConstants.Masks.M1.UP = 'MASKS\M1_UP'
	local masks, swipes = {}, {};
	for _, data in pairs(layout) do
		local prefix = data.Prefix;
		if prefix then
			masks[prefix], swipes[prefix] = {}, {};
			for direction in pairs(directions) do
				masks  [prefix][direction] = env.GetAsset([[Textures\Masks\%s_%s]], prefix, direction)
				swipes [prefix][direction] = env.GetAsset([[Textures\Swipes\%s_%s]], prefix, direction)
			end
		end
	end
	return masks, swipes;
end)( env.ClusterConstants.Layout, env.ClusterConstants.Directions )

env.ClusterConstants.ModDriver = (function(driver, ...)
	for _, modifier in ipairs({...}) do
		-- Insert in reverse order to prioritize most complex modifiers
		tinsert(driver, 1, ('[mod:%s] %s'):format(modifier, modifier))
	end
	driver[#driver] = '[nomod]'; -- NOMOD fix
	return table.concat(driver, '; ')..' ;';
end)( {}, env.ClusterConstants.ModNames() )

end -- Cluster information

---------------------------------------------------------------
env.Types = {};
---------------------------------------------------------------
env.Types.SimplePoint = Data.Interface {
	name = 'Position';
	desc = 'Position of the element.';
	Data.Point {
		point = {
			name = 'Anchor';
			desc = 'Anchor point relative to parent action bar.';
			Data.Select('CENTER', 'CENTER', 'BOTTOM', 'TOP', 'LEFT', 'RIGHT');
		};
		x = {
			name = 'X Offset';
			desc = 'Horizontal offset from anchor point.';
			Data.Number(0, 1, true);
		};
		y = {
			name = 'Y Offset';
			desc = 'Vertical offset from anchor point.';
			vert = true;
			Data.Number(0, 1, true);
		};
	};
};

env.Types.ClusterHandle = Data.Interface {
	name = 'Cluster Handle';
	desc = 'A button cluster for all modifiers of a single button.';
	Data.Table {
		size = {
			name = 'Size';
			desc = 'Size of the button cluster.';
			Data.Number(64, 2);
		};
		dir = {
			name = 'Direction';
			desc = 'Direction of the button cluster.';
			Data.Select('DOWN', env.ClusterConstants.Directions());
		};
		pos = env.Types.SimplePoint : Implement {
			desc = 'Position of the button cluster.';
		};
		showFlyouts = {
			name = 'Show Flyouts';
			desc = 'Show the flyout of small buttons for the button cluster.';
			Data.Bool(true);
		};
	};
};

env.Types.Cluster = Data.Interface {
	name    = 'Cluster Action Bar';
	desc    = 'A cluster action bar.';
	Data.Table {
		type = {hide = true; Data.String('Cluster')};
		children = {
			name = 'Buttons';
			desc = 'Buttons in the cluster bar.';
			Data.Mutable(env.Types.ClusterHandle):SetKeyOptions(env.db.Gamepad.Index.Button.Binding);
		};
		width = {
			name = 'Width';
			desc = 'Width of the cluster bar.';
			Data.Number(1200, 25);
		};
		height = {
			name = 'Height';
			desc = 'Height of the cluster bar.';
			vert = true;
			Data.Number(140, 25);
		};
		scale = {
			name = 'Scale';
			desc = 'Scale of the cluster bar.';
			Data.Number(1, 0.1);
		};
		pos = env.Types.SimplePoint : Implement {
			desc = 'Position of the cluster bar.';
			{
				point = 'BOTTOM';
				y     = 16;
			};
		};
	};
};

env.Types.Toolbar = Data.Interface {
	name = 'Toolbar';
	desc = 'A toolbar with XP indicators, shortcuts and other information.';
	Data.Table {
		type = {hide = true; Data.String('Toolbar')};
		pos = env.Types.SimplePoint : Implement {
			desc = 'Position of the toolbar.';
			{
				point = 'BOTTOM';
			};
		};
		width = {
			name = 'Width';
			desc = 'Width of the toolbar.';
			Data.Range(900, 25, 300, 1200);
		};
	};
};

---------------------------------------------------------------
env.Presets = {};
---------------------------------------------------------------
do -- Cluster layouts
local Handle = env.Types.ClusterHandle(); -- reuse one handle instance and warp it

env.Presets.Default = {
	name       = DEFAULT;
	desc       = 'A cluster bar with a toolbar below it.';
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = env.Types.Toolbar:Render();
		Cluster = env.Types.Cluster:Render {
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

env.Presets.Orthodox = {
	name       = 'Orthodox';
	desc       = 'A cluster bar with a toolbar below it, laid out Horizontally.';
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	children = {
		Toolbar = env.Types.Toolbar : Render();
		Cluster = env.Types.Cluster : Render {
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
end -- Cluster layouts


function env:GetDefaultLayout()
	return env.Presets.Default;
end