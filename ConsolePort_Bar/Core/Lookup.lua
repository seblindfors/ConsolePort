local name, env = ...;
--------------------------------------------------------
env.db   = ConsolePort:GetData()
env.bar  = ConsolePortBar;
env.libs = { acb = LibStub('CPActionButton') };
--------------------------------------------------------
local r, g, b = CPAPI.NormalizeColor(CPAPI.GetClassColor())
--------------------------------------------------------
local defaultIcons
do  local custom = [[Interface\AddOns\ConsolePort_Bar\Textures\Icons\%s]]
	local client = [[Interface\Icons\%s]]
	local isRetail = CPAPI.IsRetailVersion;
	defaultIcons = {
	----------------------------
	JUMP = custom:format('Jump'),
	TOGGLERUN = custom:format('Run'),
	OPENALLBAGS = custom:format('Bags'),
	TOGGLEGAMEMENU = custom:format('Menu'),
	TOGGLEWORLDMAP = custom:format('Map'),
	----------------------------
	TARGETNEARESTENEMY = custom:format('Target'),
	TARGETPREVIOUSENEMY = custom:format('Target'),
	TARGETSCANENEMY = custom:format('Target'),
	TARGETNEARESTFRIEND = custom:format('Target'),
	TARGETPREVIOUSFRIEND = custom:format('Target'),
	TARGETNEARESTENEMYPLAYER = custom:format('Target'),
	TARGETPREVIOUSENEMYPLAYER = custom:format('Target'),
	TARGETNEARESTFRIENDPLAYER = custom:format('Target'),
	TARGETPREVIOUSFRIENDPLAYER = custom:format('Target'),
	----------------------------
	TARGETPARTYMEMBER1 = isRetail and client:format('Achievement_PVP_A_01'),
	TARGETPARTYMEMBER2 = isRetail and client:format('Achievement_PVP_A_02'),
	TARGETPARTYMEMBER3 = isRetail and client:format('Achievement_PVP_A_03'),
	TARGETPARTYMEMBER4 = isRetail and client:format('Achievement_PVP_A_04'),
	TARGETSELF = isRetail and client:format('Achievement_PVP_A_05'),
	TARGETPET = client:format('Spell_Hunter_AspectOfTheHawk'),
	----------------------------
	ATTACKTARGET = client:format('Ability_SteelMelee'),
	STARTATTACK  = client:format('Ability_SteelMelee'),
	PETATTACK    = client:format('ABILITY_HUNTER_INVIGERATION'),
	FOCUSTARGET  = client:format('Ability_Hunter_MasterMarksman'),
	----------------------------
	['CLICK ConsolePortFocusButton:LeftButton']      = client:format('VAS_RaceChange'),
	['CLICK ConsolePortEasyMotionButton:LeftButton'] = custom:format('Group'),
	['CLICK ConsolePortRaidCursorToggle:LeftButton'] = custom:format('Group'),
	['CLICK ConsolePortRaidCursorFocus:LeftButton']  = custom:format('Group'),
	['CLICK ConsolePortRaidCursorTarget:LeftButton'] = custom:format('Group'),
	['CLICK ConsolePortUtilityToggle:LeftButton']    = custom:format('Ring'),
	----------------------------
	}
end
--------------------------------------------------------
local classArt = {
	WARRIOR 	= {1, 1},
	PALADIN 	= {1, 2},
	DRUID 		= {1, 3},
	DEATHKNIGHT = {1, 4},
	----------------------------
	MAGE 		= {2, 1},
	HUNTER 		= {2, 2},
	ROGUE 		= {2, 3},
	WARLOCK 	= {2, 4},
	----------------------------
	SHAMAN 		= {3, 1},
	PRIEST 		= {3, 2},
	DEMONHUNTER = {3, 3},
	MONK 		= {3, 4},
}
--------------------------------------------------------

function env:GetBindingIcon(binding)
	return env.manifest.BindingIcons[binding]
end

function env:CreateManifest()
	if type(ConsolePortBarManifest) ~= 'table' then
		ConsolePortBarManifest = {
			BindingIcons = defaultIcons,
		}
	elseif type(ConsolePortBarManifest.BindingIcons) ~= 'table' then
		ConsolePortBarManifest.BindingIcons = defaultIcons
	end
	defaultIcons = nil
	env.manifest = ConsolePortBarManifest
	return ConsolePortBarManifest
end

function env:GetCover(class)
	local art = class and classArt[class]
	if not class and not art then
		art = classArt[select(2, UnitClass('player'))]
	end
	if art then
		local index, px = unpack(art)
		return [[Interface\AddOns\]]..name..[[\Textures\Covers\]]..index, 
				{0, 1, (( px - 1 ) * 256 ) / 1024, ( px * 256 ) / 1024 }
	end
end

function env:GetBackdrop()
	return {
		edgeFile 	= 'Interface\\AddOns\\'..name..'\\Textures\\BarEdge',
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	}
end

function env:GetDefaultButtonLayout(button)
	local layout = {
		---------
		PADDLEFT 	= {point = {'LEFT', 176, 56}, dir = 'left', size = 64},
		PADDRIGHT 	= {point = {'LEFT', 306, 56}, dir = 'right', size = 64},
		PADDUP 	    = {point = {'LEFT', 240, 100}, dir = 'up', size = 64},
		PADDDOWN 	= {point = {'LEFT', 240, 16}, dir = 'down', size = 64},
		---------
		PAD3 		= {point = {'RIGHT', -306, 56}, dir = 'left', size = 64},
		PAD2 		= {point = {'RIGHT', -176, 56}, dir = 'right', size = 64},
		PAD4 		= {point = {'RIGHT', -240, 100}, dir = 'up', size = 64},
		PAD1 		= {point = {'RIGHT', -240, 16}, dir = 'down', size = 64},
	}

	local handle = env.db.UIHandle;
	local T1, T2 = handle:GetUIControlBinding('T1'), handle:GetUIControlBinding('T2')
	local M1, M2 = handle:GetUIControlBinding('M1'), handle:GetUIControlBinding('M2')

	if M1 then layout[M1] = {point = {'LEFT', 456, 56}, dir = 'right', size = 64} end;
	if M2 then layout[M2] = {point = {'RIGHT', -456, 56}, dir = 'left', size = 64} end;
	if T1 then layout[T1] = {point = {'LEFT', 396, 16}, dir = 'down', size = 64} end;
	if T2 then layout[T2] = {point = {'RIGHT', -396, 16}, dir = 'down', size = 64} end;

	if button ~= nil then
		return layout[button]
	else
		return layout
	end
end

function env:GetOrthodoxButtonLayout()
	local layout = {
		---------
		PADDRIGHT = {dir = 'right', point = {'LEFT', 330, 9}, size = 64},
		PADDLEFT = {dir = 'left', point = {'LEFT', 80, 9}, size = 64},
		PADDDOWN = {dir = 'down', point = {'LEFT', 165, 9}, size = 64},
		PADDUP = {dir = 'up', point = {'LEFT', 250, 9}, size = 64},
		---------
		PAD2 = {dir = 'right', point = {'RIGHT', -80, 9}, size = 64},
		PAD3 = {dir = 'left', point = {'RIGHT', -330, 9}, size = 64},
		PAD1 = {dir = 'down', point = {'RIGHT', -250, 9}, size = 64},
		PAD4 = {dir = 'up', point = {'RIGHT', -165, 9}, size = 64},
	}

	local handle = env.db.UIHandle;
	local T1, T2 = handle:GetUIControlBinding('T1'), handle:GetUIControlBinding('T2')
	local M1, M2 = handle:GetUIControlBinding('M1'), handle:GetUIControlBinding('M2')

	if M1 then layout[M1] = {dir = 'up', point = {'LEFT', 405, 75}, size = 64} end;
	if M2 then layout[M2] = {dir = 'up', point = {'RIGHT', -405, 75}, size = 64} end;
	if T1 then layout[T1] = {dir = 'right', point = {'LEFT', 440, 9}, size = 64} end;
	if T2 then layout[T2] = {dir = 'left', point = {'RIGHT', -440, 9}, size = 64} end;

	return layout;
end

function env:GetPresets()
	return {
		Default = self:GetDefaultSettings(),
		Orthodox = {
			scale = 0.9,
			width = 1100,
			watchbars = true,
			showline = true,
			showbuttons = false,
			lock = true,
			layout = self:GetOrthodoxButtonLayout(),
		},
		Roleplay = {
			scale = 0.9,
			width = 1100,
			watchbars = true,
			showline = true,
			showart = true,
			showbuttons = false,
			lock = true,
			layout = self:GetDefaultButtonLayout(),
		},
	}
end

function env:GetUserPresets()
	local presets, copy = {}, env.db.table.copy;
	for character, data in env.db:For('Shared/Data') do
		if data.Bar and data.Bar.layout then
			presets[character] = copy(data.Bar)
		end
	end
	return presets;
end

function env:GetAllPresets()
	return env.db.table.merge(self:GetPresets(), self:GetUserPresets())
end

function env:GetRGBColorFor(element, default)
	local cfg = env.cfg or {}
	local defaultColors = {
		art 	= {1, 1, 1, 1},
		tint 	= {r, g, b, 1},
		border 	= {1, 1, 1, 1},
		swipe 	= {r, g, b, 1},
		exp 	= {r, g, b, 1},
	}
	if default then
		if defaultColors[element] then
			return unpack(defaultColors[element])
		end
	end
	local current = {
		art 	= cfg.artRGB or defaultColors.art,
		tint 	= cfg.tintRGB or defaultColors.tint,
		border 	= cfg.borderRGB or defaultColors.border,
		swipe 	= cfg.swipeRGB or defaultColors.swipe,
		exp 	= cfg.expRGB or defaultColors.exp,
	}
	if current[element] then
		return unpack(current[element])
	end
end

function env:GetDefaultSettings()
	return 	{
		scale = 0.9,
		width = 1100,
		watchbars = true,
		showline = true,
		lock = true,
		flashart = true,
		eye = true,
		showbuttons = false,
		layout = env:GetDefaultButtonLayout()
	}
end

function env:GetColorGradient(red, green, blue)
	local gBase = 0.15
	local gMulti = 1.2
	local startAlpha = 0.25
	local endAlpha = 0
	local gradient = {
		'VERTICAL',
		(red + gBase) * gMulti, (green + gBase) * gMulti, (blue + gBase) * gMulti, startAlpha,
		1 - (red + gBase) * gMulti, 1 - (green + gBase) * gMulti, 1 - (blue + gBase) * gMulti, endAlpha,
	}
	return unpack(gradient)
end

function env:GetBooleanSettings() return {
	{	name = 'Width/scale on mouse wheel';
		cvar = 'mousewheel';
		desc = 'Allows you to scroll on the action bar to adjust its proportions.';
		note = 'Hold Shift to adjust width, otherwise scale.';
	};
	---------------------------------------
	{	name = 'Visibility & Lock' };
	{	name = 'Lock action bar';
		cvar = 'lock';
		desc = 'Lock/unlock action bar, allowing it to be moved with the mouse.';
	};
	{	name = 'Hide in combat';
		cvar = 'combathide';
		desc = 'Hide action bar in combat.';
		note = 'Only for the truly insane.';
	};
	{	name = 'Fade out of combat';
		cvar = 'hidebar';
		desc = 'Fades out the action bar while not in combat.';
		note = 'The action bar will become visible if you bring your cursor over it.';
	};
	{	name = 'Disable drag and drop';
		cvar = 'disablednd';
		desc = 'Disables dragging and dropping actions using your mouse cursor.';
	};
	{	name = 'Always show all buttons';
		cvar = 'showbuttons';
		desc = 'Shows the entire button cluster at all times, not just abilities on cooldown.';
	};
	---------------------------------------
	{	name = 'Pet Ring' };
	{	name = 'Lock pet ring';
		cvar = 'lockpet';
		desc = 'Lock/unlock pet ring, allowing it to be moved with the mouse.';
	};
	{	name = 'Disable pet ring';
		cvar = 'hidepet';
		desc = 'Disables the pet ring entirely.';
	};
	{	name = 'Hide pet ring in combat';
		cvar = 'combatpethide';
		desc = 'Hide pet ring in combat.';
	};
	{	name = 'Always show all buttons';
		cvar = 'disablepetfade';
		desc = 'Shows the entire pet ring cluster at all times, not just abilities on cooldown.';
	};
	---------------------------------------
	{	name = 'Display' };
	{	name = 'The Eye';
		cvar = 'eye';
		desc = 'Shows an "eye" in the middle of your action bar, to quickly toggle between show/hide all buttons.';
		note = 'The Eye can be used to train your gameplay performance.';
	};
	{	name = 'Disable watch bars';
		cvar = 'hidewatchbars';
		desc = 'Disables watch bars at the bottom of the action bar.';
		note = 'Disables all tracking of experience, honor, reputation and artifacts.';
	};
	{	name = 'Always show watch bars';
		cvar = 'watchbars';
		desc = 'When enabled, shows watch bars at all times. When disabled, shows them on mouse over.';
	};
	{	name = 'Hide main button icons';
		cvar = 'hideIcons';
		desc = 'Hide binding icons on all large buttons.';
	};
	{	name = 'Hide modifier icons';
		cvar = 'hideModifiers';
		desc = 'Hide binding icons on all small buttons.';
	};
	{	name = 'Use beveled borders';
		cvar = 'classicBorders';
		desc = 'Use the classic button border texture.';
	};
	{ 	name = 'Disable micro menu modifications';
		cvar = 'disablemicromenu';
		desc = 'Disables micro menu modifications.';
		note = 'Check this if you have another addon customizing the micro menu.';
	};
	---------------------------------------
	{	name = 'Cast Bar' };
	{	name = 'Show default cast bar';
		cvar = 'defaultCastBar';
		desc = 'Shows the default cast bar, adjusted to the action bar position.';
	};
	{	name = 'Disable cast bar modification';
		cvar = 'disableCastBarHook';
		desc = 'Disables any modifications to the cast bar, including position.';
		note = 'This may fix compatibility issues with other addons modifying the cast bar.';
	};
	---------------------------------------
	{	name = 'Artwork' };
	{	name = 'Show class art underlay';
		cvar = 'showart';
		desc = 'Shows a class-based artpiece under your button clusters, to use as anchoring reference.';
	};
	{	name = 'Blend class art underlay';
		cvar = 'blendart';
		desc = 'Sets class art underlay to blend colors with the background, resulting in a brighter, less opaque texture.';
	};
	{	name = 'Flash art underlay on proc';
		cvar = 'flashart';
		desc = 'Flashes the art underlay whenever a spell procs and starts glowing.';
	};
	{	name = 'Smaller art underlay';
		cvar = 'smallart';
		desc = 'Reduces the size of the class art underlay.';
	};
	{	name = 'Show color tint';
		cvar = 'showline';
		desc = 'Shows a subtle tint, anchored to the top of the watch bars.';
	};
	{	name = 'RGB Gaming God';
		cvar = 'rainbow';
		desc = 'Behold the might of my personal computer, you dirty console peasant. Do you really have enough buttons on that thing to match me?';
		note = ('|T%s:64:128:0|t'):format([[Interface\AddOns\ConsolePort_Config\Assets\master.blp]]);
	};
} end

function env:GetNumberSettings() return {
	---------------------------------------
	{	name = 'Size' };
	{	name = 'Width';
		cvar = 'width';
		desc = 'Changes the overall action bar width.';
		note = 'Affects button placement.';
		step = 10;
	};
	{	name = 'Scale';
		cvar = 'scale';
		desc = 'Changes the overall action bar scale.';
		note = 'Affects button size - individual size is multiplied by scale.';
		step = 0.05;
	};
} end

function env:GetColorSettings() return {
	---------------------------------------
	{	name = 'Colors' };
	{	name = 'Border';
		cvar = 'borderRGB';
		desc = 'Changes the color of your button borders.';
		note = 'Right click to reset to default color.';
	};
	{	name = 'Cooldown';
		cvar = 'swipeRGB';
		desc = 'Changes the color of your cooldown graphics.';
		note = 'Right click to reset to class color.';
	};
	{	name = 'Tint';
		cvar = 'tintRGB';
		desc = 'Changes the color of the tint texture above experience bars.';
		note = 'Right click to reset to class color.';
	};
	{	name = 'Experience Bars';
		cvar = 'expRGB';
		desc = 'Changes the preferred color of your experience bars.';
		note = 'Right click to reset to class color.';
	};
	{	name = 'Artwork';
		cvar = 'artRGB';
		desc = 'Changes the color of class-based background artwork.';
		note = 'Right click to reset to default color.';
	};
} end

function env:SetRainbowScript(on) 
	local f = env.bar
	if on then
		local reg, pairs = env.libs.registry, pairs
		local __cb, __bg, __bl, __wb = CastingBarFrame, f.BG, f.BottomLine, f.WatchBarContainer
		local t, i, p, c, w, m = 0, 0, 0, 128, 127, 180
		local hz = (math.pi*2) / m
		local r, g, b
		f:SetScript('OnUpdate', function(self, e)
			t = t + e
			if t > 0.1 then
				i = i + 1
				r = (math.sin((hz * i) + 0 + p) * w + c) / 255
				g = (math.sin((hz * i) + 2 + p) * w + c) / 255
				b = (math.sin((hz * i) + 4 + p) * w + c) / 255
				if i > m then
					i = i - m
				end
				__cb:SetStatusBarColor(r, g, b)
				__wb:SetMainBarColor(r, g, b)
				__bg:SetGradientAlpha(env:GetColorGradient(r, g, b))
				__bl:SetVertexColor(r, g, b)
				for _, rap in pairs(reg) do
					rap:SetSwipeColor(r, g, b, 1)
				end
				t = 0
			end
		end)
	else
		f:SetScript('OnUpdate', nil)
	end
end

function env:SetArtUnderlay(enabled, flashOnProc)
	local bar = env.bar
	local cfg = env.cfg
	if enabled then
		local art, coords = self:GetCover()
		if art and coords then
			local artScale = cfg.smallart and .75 or 1
			bar.CoverArt:SetTexture(art)
			bar.CoverArt:SetTexCoord(unpack(coords))
			bar.CoverArt:SetVertexColor(unpack(cfg.artRGB or {1,1,1}))
			bar.CoverArt:SetBlendMode(cfg.blendart and 'ADD' or 'BLEND')
			bar.CoverArt:SetSize(768 * artScale, 192 * artScale)
			if cfg.showart then
				bar.CoverArt:Show()
			else
				bar.CoverArt:Hide()
			end
		end
	else
		bar.CoverArt:SetTexture(nil)
		bar.CoverArt:Hide()
	end
	bar.CoverArt.flashOnProc = flashOnProc
end