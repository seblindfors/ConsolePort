local _, env = ...;
---------------------------------------------------------------
do -- Variables
---------------------------------------------------------------
local Data, _ = env.db.Data, CPAPI.Define;
local classColor = CreateColor(CPAPI.NormalizeColor(CPAPI.GetClassColor()));

env:Register('Variables', CPAPI.Callable({
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
	};
	---------------------------------------------------------------
	_'Clusters';
	---------------------------------------------------------------
	-- TODO: Add cluster settings
	---------------------------------------------------------------
	_'Colors';
	---------------------------------------------------------------
	xpBarColor = _{Data.Color(classColor);
		name = 'XP Bar Color';
		desc = 'Normal background color of pie slices.';
	};
	swipeColor = _{Data.Color(classColor);
		name = 'Swipe Color';
		desc = 'Color of the cooldown swipe effect on buttons.';
	};
	tintColor = _{Data.Color(classColor);
		name = 'Tint Color';
		desc = 'Color of the tint effect on buttons.';
	};
	borderVertexColor = _{Data.Color(WHITE_FONT_COLOR);
		name = 'Border Vertex Color';
		desc = 'Color of the vertexes on the border of buttons.';
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
			NormalTexture         =   env.GetAsset([[Textures\Button\Normal]]);
			PushedTexture         =   env.GetAsset([[Textures\Button\Hilite]]);
			HighlightTexture      =   env.GetAsset([[Textures\Button\Hilite]]);
			CheckedTexture        =   env.GetAsset([[Textures\Button\Hilite]]);
			NewActionTexture      =   env.GetAsset([[Textures\Button\Hilite]]);
			SpellHighlightTexture =   env.GetAsset([[Textures\Button\Hilite]]);
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
		CooldownBling             =   env.GetAsset([[Cooldown\Bling]]);
		MainMask                  = CPAPI.GetAsset([[Textures\Button\Mask]]);
		MainSwipe                 =   env.GetAsset([[Textures\Cooldown\Swipe]]);
		EmptyIcon                 = CPAPI.GetAsset([[Textures\Button\EmptyIcon]]);
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
-- Presets
---------------------------------------------------------------
env.Presets = {};
env.Presets.Default = function() return {
	name = DEFAULT;
	desc = 'A cluster bar with a toolbar below it.';
	visibility = '[petbattle][vehicleui][overridebar] hide; show';
	bars = {
		Cluster = {
			type     = 'Cluster';
			lock     = true;
			scale 	 = 1;
			width 	 = 1200;
			height   = 140;
			point    = { point = 'BOTTOM', x = 0, y = 16};
			buttons  = (function(buttons)
				local handle = env.db.UIHandle;
				local T1, T2 = handle:GetUIControlBinding('T1'), handle:GetUIControlBinding('T2')
				local M1, M2 = handle:GetUIControlBinding('M1'), handle:GetUIControlBinding('M2')

				if M1 then buttons[M1] = { dir = 'UP',    point = {'LEFT',   405, 75}, size = 64 } end;
				if M2 then buttons[M2] = { dir = 'UP',    point = {'RIGHT', -405, 75}, size = 64 } end;
				if T1 then buttons[T1] = { dir = 'RIGHT', point = {'LEFT',   440,  9}, size = 64 } end;
				if T2 then buttons[T2] = { dir = 'LEFT',  point = {'RIGHT', -440,  9}, size = 64 } end;

				return buttons;
			end)({
				PADDRIGHT = { dir = 'RIGHT', point = {'LEFT',   330, 9}, size = 64 };
				PADDLEFT  = { dir = 'LEFT',  point = {'LEFT',    80, 9}, size = 64 };
				PADDDOWN  = { dir = 'DOWN',  point = {'LEFT',   165, 9}, size = 64 };
				PADDUP    = { dir = 'UP',    point = {'LEFT',   250, 9}, size = 64 };
				PAD2      = { dir = 'RIGHT', point = {'RIGHT',  -80, 9}, size = 64 };
				PAD3      = { dir = 'LEFT',  point = {'RIGHT', -330, 9}, size = 64 };
				PAD1      = { dir = 'DOWN',  point = {'RIGHT', -250, 9}, size = 64 };
				PAD4      = { dir = 'UP',    point = {'RIGHT', -165, 9}, size = 64 };
			});
		};
		Toolbar = {
			type    = 'Toolbar';
			lock     = true;
			scale    = 1;
			width    = 900;
			point    = { point = 'BOTTOM', x = 0, y = 0};
		};
	};
}; end;


function env:GetDefaultLayout()
	return env.Presets.Default();
end