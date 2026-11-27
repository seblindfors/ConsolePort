local _, Data, env = CPAPI.LinkEnv(...)
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
env.Const.ProxyKeyOptions = function()
	local keys = {};
	for buttonID in pairs(env.db.Gamepad.Index.Button.Binding) do
		if CPAPI.IsButtonValidForBinding(buttonID) then
			keys[buttonID] = buttonID;
		end
	end
	return keys;
end

env.Const.DefaultPresetName = ('%s (%s)'):format(GetUnitName('player'), GetRealmName());
env.Const.ManagerVisibility = '[petbattle] hide; show';
env.Const.DefaultVisibility = '[vehicleui][overridebar] hide; show';

env.Const.ValidFontFlags = CPAPI.Enum('OUTLINE', 'THICKOUTLINE', 'MONOCHROME');
env.Const.ValidJustifyH  = CPAPI.Enum('LEFT', 'CENTER', 'RIGHT');
env.Const.ValidStratas   = CPAPI.Enum('BACKGROUND', 'LOW', 'MEDIUM', 'HIGH', 'DIALOG');
env.Const.ValidFlyouts   = CPAPI.Enum('UP', 'DOWN', 'LEFT', 'RIGHT');
env.Const.ValidPoints    = CPAPI.Enum(
	'CENTER', 'TOP',      'BOTTOM',
	'LEFT',   'TOPLEFT',  'BOTTOMLEFT',
	'RIGHT',  'TOPRIGHT', 'BOTTOMRIGHT'
);

env.Const.ClusterDesign = CPAPI.Enum('Original', 'OriginalGold', 'Hex', 'Squared', 'Beveled');

local CLUSTER_DESIGN  = env.Const.ClusterDesign;
local CLUSTER_DESIGNS = {
	[CLUSTER_DESIGN.Original] = {
		Name      = env.L'Round Silver';
		Directory = 'RoundSilver';
		PetRing   = 'RoundSilver';
		Order     = 1;
	};
	[CLUSTER_DESIGN.Beveled] = {
		Name      = env.L'Beveled Silver';
		Directory = 'BeveledSilver';
		PetRing   = 'BeveledSilver';
		Order     = 2;
	};
	[CLUSTER_DESIGN.OriginalGold] = {
		Name      = env.L'Round Gold';
		Directory = 'RoundGold';
		PetRing   = 'Gold';
		Order     = 3;
		IsGold    = true;
	};
	[CLUSTER_DESIGN.Hex] = {
		Name      = env.L'Hex Gold';
		Directory = 'HexGold';
		PetRing   = 'Gold';
		Order     = 4;
		IsGold    = true;
	};
	[CLUSTER_DESIGN.Squared] = {
		Name      = env.L'Squared Gold';
		Directory = 'SquaredGold';
		PetRing   = 'Gold';
		Order     = 5;
		IsGold    = true;
	};
};

local CLUSTER_DESIGN_NAMES = {};
for design, info in pairs(CLUSTER_DESIGNS) do
	CLUSTER_DESIGN_NAMES[design] = info.Name;
end

local COOLDOWN_SHADE_ALPHA = 163 / 255;
local COOLDOWN_SHADE_COLOR = CreateColor(0, 0, 0, COOLDOWN_SHADE_ALPHA);

function env:IsGoldClusterDesign()
	local design = CLUSTER_DESIGNS[self('clusterDesign')];
	return design ~= nil and design.IsGold == true;
end

env.Const.PageDescription =  {
	['vehicleui']   = 'Vehicle UI is active.';
	['possessbar']  = 'Possess bar is visible, such as Mind Control or Eyes of the Beast.';
	['overridebar'] = 'An override bar is active, can use either vehicle UI or an unskinned override bar.';
	['shapeshift']  = 'Temporarily shapeshifted, but not forms or stances that have their own action bar.';
	['bar:1']       = 'Selected page 1 (default)';
	['bar:2']       = 'Selected page 2';
	['bar:3']       = 'Selected page 3';
	['bar:4']       = 'Selected page 4';
	['bar:5']       = 'Selected page 5';
	['bar:6']       = 'Selected page 6';
	['bonusbar:1']  = 'Stance/Form 1';
	['bonusbar:2']  = 'Stance/Form 2';
	['bonusbar:3']  = 'Stance/Form 3';
	['bonusbar:4']  = 'Stance/Form 4';
	['bonusbar:5']  = 'Dragonriding';
};

---------------------------------------------------------------
do -- Variables
---------------------------------------------------------------
local L          = env.L;
local classColor = CPAPI.GetClassAccentColor();
local WATCH_TEXT_VISIBILITY_ORDER = {hover = 1; always = 2; hidden = 3};
local WATCH_TEXT_VISIBILITY_OPTIONS = {
	hover  = L'Hover - Default';
	always = L'Always Show';
	hidden = L'Hidden';
};
local WATCH_TEXT_FORMAT_ORDER = {progress = 1; percent = 2; both = 3; remaining = 4};
local WATCH_TEXT_FORMAT_OPTIONS = {
	progress  = L'Current/Max';
	percent   = L'Percent';
	both      = L'Numbers + Pct';
	remaining = L'Remaining';
};

env:Register('Variables', CPAPI.Callable({
	---------------------------------------------------------------
	_(GENERAL, ACTIONBARS_LABEL);
	---------------------------------------------------------------
	showMainIcons = _{Data.Bool(true);
		name = 'Show Main Icons';
		desc = 'Show the icons for main buttons.';
	};
	showCooldownText = _{Data.Bool(GetCVarBool('countdownForCooldowns'));
		name = 'Enable Cooldown Numbers';
		desc = 'Show numerical cooldown text on buttons.';
	};
	disableDND = _{Data.Bool(false);
		name = 'Disable Drag and Drop';
		desc = 'Disable dragging and dropping abilities on action bars.';
	};
	LABmouseoverCast = _{Data.Bool(false);
		name = 'Mouseover Cast';
		desc = 'Allow casting on mouseover targets, when enabled in the game options.';
		note = 'Requires the mouseover cast option in the game combat settings.';
	};
	LABclickOnDown = _{Data.Bool(true);
		name = 'Click on Down';
		desc = 'Trigger button actions on press instead of release.';
		advd = true;
	};
	LABhideElementsMacro = _{Data.Bool(false);
		name = 'Hide Macro Text';
		desc = 'Hide the macro text on buttons.';
	};
	LABcolorsRange = _{Data.Color(CreateColor( 0.8, 0.1, 0.1 ));
		name = 'Out of Range Color';
		desc = 'Color of the range indicator on buttons.';
	};
	LABcolorsMana = _{Data.Color(CreateColor(0.5, 0.5, 1.0 ));
		name = 'Out of Mana Color';
		desc = 'Color of the mana indicator on buttons.';
	};
	LABtooltip = _{Data.Select('Enabled', 'Enabled', 'Disabled', 'NoCombat');
		name = 'Tooltip';
		desc = 'Show tooltips on buttons when moused over.';
		advd = true;
	};
	---------------------------------------------------------------
	_('Page Hotkeys', 'Action Buttons');
	---------------------------------------------------------------
	LABhotkeyColor = _{Data.Color(CreateColor( 0.75, 0.75, 0.75 ));
		name = 'Color';
		desc = 'Color of the hotkey text on buttons.';
	};
	LABhotkeyFontSize = _{Data.Number(12, 1);
		name = 'Size';
		desc = 'Font size of the hotkey text on buttons.';
	};
	LABhotkeyPositionOffsetX = _{Data.Number(4, 1, true);
		name = 'Offset X';
		desc = 'Horizontal offset of the hotkey text on buttons.';
	};
	LABhotkeyPositionOffsetY = _{Data.Number(0, 1, true);
		name = 'Offset Y';
		desc = 'Vertical offset of the hotkey text on buttons.';
	};
	LABhotkeyJustifyH = _{Data.Select('RIGHT', env.Const.ValidJustifyH());
		name = 'Alignment';
		desc = 'Alignment of the hotkey text on buttons.';
	};
	LABhotkeyFontFlags = _{Data.Select('OUTLINE', env.Const.ValidFontFlags());
		name = 'Font Flags';
		desc = 'Font flags of the hotkey text on buttons.';
	};
	LABhotkeyPositionAnchor = _{Data.Select('TOPRIGHT', env.Const.ValidPoints());
		name = 'Anchor';
		desc = 'Anchor point of the hotkey text on buttons.';
	};
	LABhotkeyPositionRelAnchor = _{Data.Select('TOPRIGHT', env.Const.ValidPoints());
		name = 'Relative Anchor';
		desc = 'Relative anchor point of the hotkey text on buttons.';
	};
	---------------------------------------------------------------
	_('Macro Text', 'Action Buttons');
	---------------------------------------------------------------
	LABmacroColor = _{Data.Color(WHITE_FONT_COLOR);
		name = 'Color';
		desc = 'Color of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	LABmacroFontSize = _{Data.Number(10, 1);
		name = 'Size';
		desc = 'Font size of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	LABmacroPositionOffsetX = _{Data.Number(0, 1, true);
		name = 'Offset X';
		desc = 'Horizontal offset of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	LABmacroPositionOffsetY = _{Data.Number(2, 1, true);
		name = 'Offset Y';
		desc = 'Vertical offset of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	LABmacroJustifyH = _{Data.Select('CENTER', env.Const.ValidJustifyH());
		name = 'Alignment';
		desc = 'Alignment of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	LABmacroFontFlags = _{Data.Select('OUTLINE', env.Const.ValidFontFlags());
		name = 'Font Flags';
		desc = 'Font flags of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	LABmacroPositionAnchor = _{Data.Select('BOTTOM', env.Const.ValidPoints());
		name = 'Anchor';
		desc = 'Anchor point of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	LABmacroPositionRelAnchor = _{Data.Select('BOTTOM', env.Const.ValidPoints());
		name = 'Relative Anchor';
		desc = 'Relative anchor point of the macro text on buttons.';
		deps = { LABhideElementsMacro = false };
	};
	---------------------------------------------------------------
	_('Recharge', 'Action Buttons');
	---------------------------------------------------------------
	LABcountColor = _{Data.Color(WHITE_FONT_COLOR);
		name = 'Color';
		desc = 'Color of the counter text on buttons.';
	};
	LABcountFontSize = _{Data.Number(16, 1);
		name = 'Size';
		desc = 'Font size of the counter text on buttons.';
	};
	LABcountPositionOffsetX = _{Data.Number(-2, 1, true);
		name = 'Offset X';
		desc = 'Horizontal offset of the counter text on buttons.';
	};
	LABcountPositionOffsetY = _{Data.Number(4, 1, true);
		name = 'Offset Y';
		desc = 'Vertical offset of the counter text on buttons.';
	};
	LABcountJustifyH = _{Data.Select('RIGHT', env.Const.ValidJustifyH());
		name = 'Alignment';
		desc = 'Alignment of the counter text on buttons.';
	};
	LABcountFontFlags = _{Data.Select('OUTLINE', env.Const.ValidFontFlags());
		name = 'Font Flags';
		desc = 'Font flags of the counter text on buttons.';
	};
	LABcountPositionAnchor = _{Data.Select('BOTTOMRIGHT', env.Const.ValidPoints());
		name = 'Anchor';
		desc = 'Anchor point of the counter text on buttons.';
	};
	LABcountPositionRelAnchor = _{Data.Select('BOTTOMRIGHT', env.Const.ValidPoints());
		name = 'Relative Anchor';
		desc = 'Relative anchor point of the counter text on buttons.';
	};
	---------------------------------------------------------------
	_('Groups', ACTIONBARS_LABEL);
	---------------------------------------------------------------
	groupHotkeySize = _{Data.Number(20, 1);
		name = 'Hotkey Size';
		desc = 'Size of the hotkey icon on group buttons.';
	};
	groupHotkeyOffsetX = _{Data.Number(0, 1, true);
		name = 'Hotkey Offset X';
		desc = 'Horizontal offset of the hotkey icon on group buttons.';
	};
	groupHotkeyOffsetY = _{Data.Number(-2, 1, true);
		name = 'Hotkey Offset Y';
		desc = 'Vertical offset of the hotkey icon on group buttons.';
	};
	groupHotkeyAnchor = _{Data.Select('CENTER', env.Const.ValidPoints());
		name = 'Hotkey Anchor';
		desc = 'Anchor point of the hotkey icon on group buttons.';
	};
	groupHotkeyRelAnchor = _{Data.Select('TOP', env.Const.ValidPoints());
		name = 'Hotkey Relative Anchor';
		desc = 'Relative anchor point of the hotkey icon on group buttons.';
	};
	---------------------------------------------------------------
	_('Clusters', ACTIONBARS_LABEL);
	---------------------------------------------------------------
	clusterShowAll = _{Data.Bool(false);
		name = 'Always Show All Buttons';
		desc = 'Show all enabled combinations in the cluster at all times.';
		note = 'By default, shows modifiers on mouseover and on cooldown.';
	};
	clusterShowFlyoutIcons = _{Data.Bool(true);
		name = 'Show Modifier Icons';
		desc = 'Show the icons for modifier buttons.';
	};
	clusterFullStateModifier = _{Data.Bool(false);
		name = 'Full State Modifier';
		desc = 'Enable all modifier states for the cluster, including unmapped modifiers.';
		advd = true;
	};
	clusterSwipeColor = _{Data.Color(COOLDOWN_SHADE_COLOR);
		name = L'Cooldown Swipe Color';
		desc = L'Color and opacity of regular cooldown and swing timer shading.';
	};
	clusterGcdSwipeColor = _{Data.Color(COOLDOWN_SHADE_COLOR);
		name = L'Global Cooldown Swipe Color';
		desc = L'Color and opacity of the global cooldown shading on cluster buttons.';
	};
	borderColor = _{Data.Color(WHITE_FONT_COLOR);
		name = 'Border Vertex Color';
		desc = 'Color of the vertices on the border of buttons.';
	};
	clusterDesign = _{Data.Map(CLUSTER_DESIGN.Original, CLUSTER_DESIGN_NAMES);
		name = L'Cluster Design';
		desc = L'Choose the shape and finish of the cluster buttons. Gold designs also style the pet ring.';
		optionSort = function(_, a, b) return CLUSTER_DESIGNS[a].Order < CLUSTER_DESIGNS[b].Order end;
	};
	---------------------------------------------------------------
	_('Toolbar', ACTIONBARS_LABEL);
	---------------------------------------------------------------
	enableXPBar = _{Data.Bool(true);
		name = 'Enable Watch Bars';
		desc = 'Show the watch bars at the bottom of the toolbar.';
		note = L'Watch bars include XP, reputation, honor, artifact power, azerite, and house favor where available.';
	};
	tintEnable = _{Data.Bool(true);
		name = 'Enable Tint';
		desc = 'Show a color tint on the toolbar.';
	};
	fadeXPBar = _{Data.Bool(false);
		name = 'Fade Watch Bars';
		desc = 'Fade out the watch bars when not mousing over the toolbar.';
		deps = { enableXPBar = true };
	};
	watchTopTextVisibility = _{
		Data.Map('hover', WATCH_TEXT_VISIBILITY_OPTIONS);
		name = L'Top Bar Text Visibility';
		desc = L'Choose when to show text on the top watch bar.';
		deps = { enableXPBar = true };
		optionSort = function(_, a, b) return WATCH_TEXT_VISIBILITY_ORDER[a] < WATCH_TEXT_VISIBILITY_ORDER[b] end;
	};
	watchTopTextFormat = _{
		Data.Map('progress', WATCH_TEXT_FORMAT_OPTIONS);
		name = L'Top Bar Text Format';
		desc = L'Choose what the top watch bar text displays.';
		deps = { enableXPBar = true };
		optionSort = function(_, a, b) return WATCH_TEXT_FORMAT_ORDER[a] < WATCH_TEXT_FORMAT_ORDER[b] end;
	};
	watchBottomTextVisibility = _{
		Data.Map('hover', WATCH_TEXT_VISIBILITY_OPTIONS);
		name = L'Bottom Bar Text Visibility';
		desc = L'Choose when to show text on the bottom or only watch bar.';
		deps = { enableXPBar = true };
		optionSort = function(_, a, b) return WATCH_TEXT_VISIBILITY_ORDER[a] < WATCH_TEXT_VISIBILITY_ORDER[b] end;
	};
	watchBottomTextFormat = _{
		Data.Map('progress', WATCH_TEXT_FORMAT_OPTIONS);
		name = L'Bottom Bar Text Format';
		desc = L'Choose what the bottom or only watch bar text displays.';
		deps = { enableXPBar = true };
		optionSort = function(_, a, b) return WATCH_TEXT_FORMAT_ORDER[a] < WATCH_TEXT_FORMAT_ORDER[b] end;
	};
	xpBarColor = _{Data.Color(classColor);
		name = 'XP Bar Color';
		desc = 'Color of the main XP bar.';
		deps = { enableXPBar = true };
	};
	watchBarBackdropColor = _{Data.Color('26606060');
		name = L'Watch Bar Backdrop Color';
		desc = L'Color and opacity of the empty portion of the watch bars.';
		deps = { enableXPBar = true };
	};
	tintColor = _{Data.Color(classColor);
		name = 'Tint Color';
		desc = 'Global color of the tint effect on the toolbar and dividers.';
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
env.Const.Cluster = {
	Directions = env.Const.ValidFlyouts;
	Types      = CPAPI.Enum('Cluster', 'ClusterHandle', 'ClusterButton', 'ClusterShadow');
	ModNames   = CPAPI.Enum(NOMOD, SHIFT, CTRL, CTRL..SHIFT, ALT, ALT..SHIFT, ALT..CTRL, ALT..CTRL..SHIFT);
	SnapPixels = 4;
	Layout = {
		[NOMOD]      = { ----------------------------------------------------------------------------------------------------------
			Prefix   = nil;
			Part     = 'Main';
			Shadow   = { 82 / SIZE_L, 0.3, CPAPI.GetAsset([[Textures\Button\Shadow]]), {'CENTER', 0, -6} };
			Level    = 4;
			Hotkey   = {{ HK_ICONS_SIZE_L, HK_ATLAS_SIZE_L, {'TOP', 0, 12}, nil }};
			Coords   = {0, 1, 0, 1};
			-----------------------------------------------------------------------------------------------------------------------
		};
		[SHIFT]      = { ----------------------------------------------------------------------------------------------------------
			DOWN     = {'TOPRIGHT', 'BOTTOMLEFT',  OFS_MOD - OFS_FIX,  OFS_MOD + OFS_FIX, Coords = {0, 0,   1, 0,   0, 1,   1, 1}};
			UP       = {'BOTTOMRIGHT', 'TOPLEFT',  OFS_MOD - OFS_FIX, -OFS_MOD - OFS_FIX, Coords = {1, 0,   0, 0,   1, 1,   0, 1}};
			LEFT     = {'BOTTOMRIGHT', 'TOPLEFT',  OFS_MOD + OFS_FIX, -OFS_MOD + OFS_FIX, Coords = {1, 0,   1, 1,   0, 0,   0, 1}};
			RIGHT    = {'BOTTOMLEFT', 'TOPRIGHT', -OFS_MOD - OFS_FIX, -OFS_MOD + OFS_FIX, Coords = {0, 0,   0, 1,   1, 0,   1, 1}};
			-----------------------------------------------------------------------------------------------------------------------
			Prefix   = M1;
			Part     = 'FlyoutSide';
			GoldPart = 'FlyoutShift';
			Glow     = M1;
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
			Part     = 'FlyoutSide';
			GoldPart = 'FlyoutCtrl';
			Glow     = M1;
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
			Part     = 'FlyoutMiddle';
			GoldPart = 'FlyoutShiftCtrl';
			Glow     = M3;
			Size     = SIZE_S / SIZE_L;
			TexSize  = SIZE_T / SIZE_S * 0.9;
			Offset   = OFS_MID / SIZE_L;
			Hotkey   = {{ HK_ICONS_SIZE_S, HK_ATLAS_SIZE_S, {'CENTER', -4, 0}, M1 },
						{ HK_ICONS_SIZE_S, HK_ATLAS_SIZE_S, {'CENTER',  4, 0}, M2 }};
			-----------------------------------------------------------------------------------------------------------------------
		};
	};
	Assets = {
		MainMask                  = CPAPI.GetAsset([[Textures\Button\Mask]]);
		EmptyIcon                 = CPAPI.GetAsset([[Textures\Button\EmptyIcon]]);
		SilverFlash               =   env.GetAsset([[Textures\Button\Hilite2x.png]]);
		SilverSpellHighlight      =   env.GetAsset([[Textures\Button\Hilite2x.png]]);
		ChargeEdge                =   env.GetAsset([[Textures\Cluster\ChargeEdge]]);
		SwingEdge                 =   env.GetAsset([[Textures\Cluster\SwingEdge]]);
		TargetingGlow             =   env.GetAsset([[Textures\Cluster\Glow\Targeting]]);
		ToggleGlow                =   env.GetAsset([[Textures\Cluster\Glow\Toggle]]);
		PetStatusFill             =   env.GetAsset([[Textures\PetRing\StatusFill]]);
		PetStateMask              =   env.GetAsset([[Textures\PetRing\StateMask]]);
		PetStateOutline           =   env.GetAsset([[Textures\PetRing\StateOutline]]);
		PetStatePulse             =   env.GetAsset([[Textures\PetRing\StatePulse]]);
		PetCooldownSwipe          =   env.GetAsset([[Textures\PetRing\CooldownSwipe]]);
	};
	AssetFormats = {
		Border                    =   env.GetAsset([[Textures\Cluster\%s\%s]]);
		BorderHighlight           =   env.GetAsset([[Textures\Cluster\%s\%sHighlight]]);
		ShapeShadow               =   env.GetAsset([[Textures\Cluster\%s\Shadow%s]]);
		ShapeMask                 =   env.GetAsset([[Textures\Cluster\Shapes\%s%sMask]]);
		ProcStart                 =   env.GetAsset([[Textures\Cluster\Glow\Flipbooks\%sStart]]);
		ProcLoop                  =   env.GetAsset([[Textures\Cluster\Glow\Flipbooks\%sLoop]]);
		ProcFlyout                =   env.GetAsset([[Textures\Cluster\Glow\%sFlyout]]);
		ProcWedge                 =   env.GetAsset([[Textures\Cluster\Glow\%s]]);
		CooldownMask              =   env.GetAsset([[Textures\Masks\Cooldowns\%s]]);
		CooldownShadow            =   env.GetAsset([[Textures\Masks\CooldownShadows\%s]]);
		PetRing                   =   env.GetAsset([[Textures\PetRing\%s%s]]);
	};
	Designs            = CLUSTER_DESIGNS;
	RimBrightness      = 0.86;
	GlowFadeIn         = 0.18;
	GlowFadeOut        = 0.38;
	CooldownShadeAlpha = COOLDOWN_SHADE_ALPHA;
	CooldownShadeColor = COOLDOWN_SHADE_COLOR;
	EmptySlotColor     = CreateColor(0.5, 0.5, 0.5, 1);
	GoldEmptySlotColor = CreateColor(0.26, 0.23, 0.20, 0.76);
	AmberColor         = CreateColor(1, 214 / 255, 125 / 255);
	ProcGlowColor      = CreateColor(1, 0.82, 0.42);
	ProcBurstColor     = CreateColor(1, 0.94, 0.70);
	GoldShapes = {
		[CLUSTER_DESIGN.Hex] = {
			Asset           = 'Hex';
			HorizontalAsset = 'HexSideways';
			Size            = 42 / 64;
			Middle          = 49 / 64;
			Outward         = 35 / 64;
			Side            = 37 / 64;
		};
		[CLUSTER_DESIGN.Squared] = {
			Asset        = 'Squared';
			Size         = 34 / 62;
			Middle       = 47 / 64;
			Outward      = 39 / 64;
			Side         = 39 / 64;
			MainHitInset = 5.25 / 64;
		};
	};
};

env.Const.Cluster.ModDriver = (function(driver, ...)
	for _, modifier in ipairs({...}) do
		-- Insert in reverse order to prioritize most complex modifiers
		tinsert(driver, 1, ('[mod:%s] %s'):format(modifier, modifier))
	end
	driver[#driver] = '[nomod]'; -- NOMOD fix
	return table.concat(driver, '; ')..' ;';
end)( {}, env.Const.Cluster.ModNames() )

end -- Cluster information

---------------------------------------------------------------
do -- Artwork
---------------------------------------------------------------
env.Const.Art = {
	Collage = { -- classFile = fileID, texCoordOffset
		WARRIOR     = {1, 1};
		PALADIN     = {1, 2};
		DRUID       = {1, 3};
		DEATHKNIGHT = {1, 4};
		----------------------------
		MAGE        = {2, 1};
		EVOKER      = {2, 1};
		HUNTER      = {2, 2};
		ROGUE       = {2, 3};
		WARLOCK     = {2, 4};
		----------------------------
		SHAMAN      = {3, 1};
		PRIEST      = {3, 2};
		DEMONHUNTER = {3, 3};
		MONK        = {3, 4};
		----------------------------
		[258]       = {3, 2};
	};
	Artifact = { -- classFile = atlas, yOffset
		DEATHKNIGHT = {'DeathKnightFrost', -20};
		DEMONHUNTER = {'DemonHunter',      -20};
		DRUID       = {'Druid',            -50};
		EVOKER      = {'MageArcane',       -30};
		HUNTER      = {'Hunter',             0};
		MAGE        = {'MageArcane',       -30};
		MONK        = {'Monk',             -30};
		PALADIN     = {'Paladin',            0};
		PRIEST      = {'Priest',           -20};
		ROGUE       = {'Rogue',              0};
		SHAMAN      = {'Shaman',           -20};
		WARLOCK     = {'Warlock',          -10};
		WARRIOR     = {'Warrior',           10};
		----------------------------
		[258]       = {'PriestShadow',     -20};
	};
};

env.Const.Art.CollageAsset = env.GetAsset([[Covers\%s]]);
env.Const.Art.ArtifactLine = 'Artifacts-%s-Header';
env.Const.Art.ArtifactRune = 'Artifacts-%s-BG-rune';

env.Const.Art.Types     = CPAPI.Enum('Collage', 'Artifact');
env.Const.Art.Blend     = CPAPI.Enum('ADD', 'BLEND');
env.Const.Art.Selection = {};
env.Const.Art.Flavors   = {};

local localeClassNames = {};
for i = 1, 20 do
	local class, classFile = GetClassInfo(i);
	if classFile then
		localeClassNames[classFile] = class;
	end
end
local function GetLocaleName(classFile)
	if (tonumber(classFile)) then
		return select(2, CPAPI.GetSpecializationInfoByID(tonumber(classFile)))
	end
	return localeClassNames[classFile];
end
for class in env.db.table.spairs(env.Const.Art.Collage) do
	local flavorID = GetLocaleName(class);
	if flavorID then
		tinsert(env.Const.Art.Selection, flavorID);
		env.Const.Art.Flavors[flavorID] = class;
	end
end

end -- Artwork
