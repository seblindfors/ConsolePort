local addOn, ab = ...
local r, g, b = ConsolePort:GetData().Atlas.GetNormalizedCC()
--------------------------------------------------------
local defaultIcons
do  local custom = [[Interface\AddOns\ConsolePortBar\Textures\Icons\%s]]
	local client = [[Interface\Icons\%s]]
	local isRetail = CPAPI:IsRetailVersion()
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
local defaultReticleSpellIDs = {
	DEATHKNIGHT = {
		43265, -- Death and Decay
		152280, -- Defile
	},
	DEMONHUNTER = {
		189110, -- Infernal Strike
		191427, -- Metamorphosis (Havoc)
		202137, -- Sigil of Silence
		202138, -- Sigil of Chains
		204596, -- Sigil of Flame
		207684, -- Sigil of Misery
	},
	DRUID = {
		102793, -- Ursol's Vortex
		191034, -- Starfall
		205636, -- Force of Nature
		202770, -- Fury of Elune
	},
	HUNTER = {
		1543, -- Flare
		6197, -- Eagle Eye
		13813, -- Explosive Trap
		109248, -- Binding Shot
		162488, -- Steel Trap
		187650, -- Freezing Trap
		187698, -- Tar Trap
		194277, -- Caltrops
		206817, -- Sentinel
		236776, -- Hi-Explosive Trap
	},
	MAGE = {
		2120, -- Flamestrike
		33395, -- Freeze
		113724, -- Ring of Frost
		153561, -- Meteor
		190356, -- Blizzard
	},
	MONK = {
		115313, -- Summon Jade Serpent Statue
		115315, -- Summon Black Ox Statue
		116844, -- Ring of Peace
	},
	PALADIN = {
		114158, -- Light's Hammer
	},
	PRIEST = {
		32375, -- Mass Dispel
		81782, -- Power Word: Barrier
		121536, -- Angelic Feather
	},
	ROGUE = {
		1725, -- Distract
		185767, -- Cannonball Barrage
		195457, -- Grappling Hook
	},
	SHAMAN = {
		2484, -- Earthbind Totem
		6196, -- Far Sight
		61882, -- Earthquake
		73920, -- Healing Rain
		98008, -- Spirit Link Totem (Resto Shaman baseline)
		51485, -- Earthgrab Totem (Shaman talent, replaces Earthbind Totem)
		192058, -- Lightning Surge Totem (Shaman talent)
		192222, -- Liquid Magma Totem (Elemental Shaman talent)
		196932, -- Voodoo Totem (Shaman talent)
		192077, -- Wind Rush Totem (Shaman talent)
		204332, -- Windfury Totem (Shaman pvp talent)
		207399, -- Ancestral Protection Totem (Resto Shaman Talent)
		207778, -- Gift of the Queen (Resto Artifact)
		215864, -- Rainfall
	},
	WARLOCK = {
		1122, -- Summon Infernal
		5740, -- Rain of Fire
		30283, -- Shadowfury
		152108, -- Cataclysm
	},
	WARRIOR = {
		6544, -- Heroic Leap
		152277, -- Ravager (Arms)
		228920, -- Ravager (Protection)
	},
}
--------------------------------------------------------

function ab:GetBindingIcon(binding)
	return ab.manifest.BindingIcons[binding]
end

function ab:CreateManifest()
	if type(ConsolePortBarManifest) ~= 'table' then
		ConsolePortBarManifest = {
			ReticleSpells = ab:GetReticleSpellManifest(),
			BindingIcons = defaultIcons,
		}
	elseif type(ConsolePortBarManifest.BindingIcons) ~= 'table' then
		ConsolePortBarManifest.BindingIcons = defaultIcons
	end
	defaultIcons = nil
	ab.manifest = ConsolePortBarManifest
	return ConsolePortBarManifest
end

function ab:GetCover(class)
	local art = class and classArt[class]
	if not class and not art then
		art = classArt[select(2, UnitClass('player'))]
	end
	if art then
		local index, px = unpack(art)
		return [[Interface\AddOns\]]..addOn..[[\Textures\Covers\]]..index, 
				{0, 1, (( px - 1 ) * 256 ) / 1024, ( px * 256 ) / 1024 }
	end
end

function ab:GetBackdrop()
	return {
		edgeFile 	= 'Interface\\AddOns\\'..addOn..'\\Textures\\BarEdge',
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	}
end

function ab:GetDefaultButtonLayout(button)
	local layout = {
		CP_T1 = {point = {'LEFT', 456, 56}, dir = 'right', size = 64},
		CP_T2 = {point = {'RIGHT', -456, 56}, dir = 'left', size = 64},
		---
		CP_T3 = {point = {'LEFT', 396, 16}, dir = 'down', size = 64},
		CP_T4 = {point = {'RIGHT', -396, 16}, dir = 'down', size = 64},
		---
		CP_L_LEFT 	= {point = {'LEFT', 176, 56}, dir = 'left', size = 64},
		CP_L_RIGHT 	= {point = {'LEFT', 306, 56}, dir = 'right', size = 64},
		CP_L_UP 	= {point = {'LEFT', 240, 100}, dir = 'up', size = 64},
		CP_L_DOWN 	= {point = {'LEFT', 240, 16}, dir = 'down', size = 64},
		---
		CP_R_LEFT 	= {point = {'RIGHT', -306, 56}, dir = 'left', size = 64},
		CP_R_RIGHT 	= {point = {'RIGHT', -176, 56}, dir = 'right', size = 64},
		CP_R_UP 	= {point = {'RIGHT', -240, 100}, dir = 'up', size = 64},
		CP_R_DOWN 	= {point = {'RIGHT', -240, 16}, dir = 'down', size = 64},
	}
	if button ~= nil then
		return layout[button]
	else
		return layout
	end
end

function ab:GetReticleSpellManifest()
	local reticleSpells = {}
	for class, classSpells in pairs(defaultReticleSpellIDs) do
		reticleSpells[class] = reticleSpells[class] or {}
		for _, spellID in pairs(classSpells) do
			local localizedSpellName = GetSpellInfo(spellID)
			if localizedSpellName then
				reticleSpells[class][spellID] = localizedSpellName
			end
		end
	end
	defaultReticleSpellIDs = nil
	return reticleSpells
end

function ab:GetPresets()
	return {
		Default = ab:GetDefaultSettings(),
		Orthodox = {
			scale = 0.9,
			width = 1100,
			watchbars = true,
			showline = true,
			lock = true,
			layout = {
				CP_L_RIGHT = {dir = 'right', point = {'LEFT', 330, 9}, size = 64},
				CP_L_LEFT = {dir = 'left', point = {'LEFT', 80, 9}, size = 64},
				CP_L_DOWN = {dir = 'down', point = {'LEFT', 165, 9}, size = 64},
				CP_L_UP = {dir = 'up', point = {'LEFT', 250, 9}, size = 64},
				CP_R_RIGHT = {dir = 'right', point = {'RIGHT', -80, 9}, size = 64},
				CP_R_LEFT = {dir = 'left', point = {'RIGHT', -330, 9}, size = 64},
				CP_R_DOWN = {dir = 'down', point = {'RIGHT', -250, 9}, size = 64},
				CP_R_UP = {dir = 'up', point = {'RIGHT', -165, 9}, size = 64},
				CP_T1 = {dir = 'right', point = {'LEFT', 440, 9}, size = 64},
				CP_T2 = {dir = 'left', point = {'RIGHT', -440, 9}, size = 64},
				CP_T3 = {dir = 'up', point = {'LEFT', 405, 75}, size = 64},
				CP_T4 = {dir = 'up', point = {'RIGHT', -405, 75}, size = 64},
			},
		},
		Roleplay = {
			scale = 0.9,
			width = 1100,
			watchbars = true,
			showline = true,
			showart = true,
			lock = true,
			layout = ab:GetDefaultButtonLayout(),
		},
	}
end

function ab:GetRGBColorFor(element, default)
	local cfg = ab.cfg or {}
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

function ab:GetDefaultSettings()
	return 	{
		scale = 0.9,
		width = 1100,
		watchbars = true,
		showline = true,
		lock = true,
		flashart = true,
		layout = ab:GetDefaultButtonLayout()
	}
end

function ab:GetColorGradient(red, green, blue)
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

function ab:GetBooleanSettings(otherCFG)
	local cfg = otherCFG or ab.cfg or {}
	local L = ab.data.ACTIONBAR
	return {
		{	desc = L.CFG_LOCK,
			cvar = 'lock',
			toggle = cfg.lock,
		},
		{	desc = L.CFG_LOCKPET,
			cvar = 'lockpet',
			toggle = cfg.lockpet,
		},
		{	desc = L.CFG_HIDEINCOMBAT,
			cvar = 'combathide',
			toggle = cfg.combathide,
		},
		{	desc = L.CFG_HIDEPETINCOMBAT,
			cvar = 'combatpethide',
			toggle = cfg.combatpethide,
		},
		{	desc = L.CFG_HIDEOUTOFCOMBAT,
			cvar = 'hidebar',
			toggle = cfg.hidebar,
		},
		{	desc = L.CFG_DISABLEPET,
			cvar = 'hidepet',
			toggle = cfg.hidepet,
		},
		{	desc = L.CFG_DISABLERETICLE,
			cvar = 'disablecastonrelease',
			toggle = cfg.disablecastonrelease,
		},
		{	desc = L.CFG_DISABLEDND,
			cvar = 'disablednd',
			toggle = cfg.disablednd,
		},
		{	desc = L.CFG_SHOWALLBUTTONS,
			cvar = 'showbuttons',
			toggle = cfg.showbuttons,
		},
		{	desc = L.CFG_QUICKMENU,
			cvar = 'quickMenu',
			toggle = cfg.quickMenu,
		},
		{	desc = L.CFG_WATCHBAR_OFF,
			cvar = 'hidewatchbars',
			toggle = cfg.hidewatchbars,
		},
		{	desc = L.CFG_WATCHBAR_ALPHA,
			cvar = 'watchbars',
			toggle = cfg.watchbars,
		},
		{	desc = L.CFG_DISABLE_ICONS,
			cvar = 'hideIcons',
			toggle = cfg.hideIcons,
		},
		{	desc = L.CFG_DISABLE_MINIS,
			cvar = 'hideModifiers',
			toggle = cfg.hideModifiers,
		},
		{	desc = L.CFG_OLD_BORDERS,
			cvar = 'classicBorders',
			toggle = cfg.classicBorders,
		},
		{	desc = L.CFG_MOUSE_ENABLE,
			cvar = 'mousewheel',
			toggle = cfg.mousewheel,
		},
		{	desc = L.CFG_CAST_DEFAULT,
			cvar = 'defaultCastBar',
			toggle = cfg.defaultCastBar,
		},
		{	desc = L.CFG_CAST_NOHOOK,
			cvar = 'disableCastBarHook',
			toggle = cfg.disableCastBarHook,
		},
		{	desc = L.CFG_ART_UNDERLAY,
			cvar = 'showart',
			toggle = cfg.showart,
		},
		{	desc = L.CFG_ART_BLEND,
			cvar = 'blendart',
			toggle = cfg.blendart,
		},
		{	desc = L.CFG_ART_FLASH,
			cvar = 'flashart',
			toggle = cfg.flashart,
		},
		{	desc = L.CFG_ART_SMALL,
			cvar = 'smallart',
			toggle = cfg.smallart,
		},
		{	desc = L.CFG_ART_TINT,
			cvar = 'showline',
			toggle = cfg.showline,
		},
		{	desc = L.CFG_COLOR_RAINBOW,
			cvar = 'rainbow',
			toggle = cfg.rainbow,
		},
	}
end

function ab:SetRainbowScript(on) 
	local f = ab.bar
	if on then
		local reg, pairs = ab.libs.registry, pairs
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
				__bg:SetGradientAlpha(ab:GetColorGradient(r, g, b))
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

function ab:SetArtUnderlay(enabled, flashOnProc)
	local bar = ab.bar
	local cfg = ab.cfg
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