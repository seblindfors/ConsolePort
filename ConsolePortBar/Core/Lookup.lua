local addOn, ab = ...
local r, g, b = ConsolePort:GetData().Atlas.GetNormalizedCC()

function ab:GetBindingIcon(binding)
	local icons = {
		['JUMP'] = [[Interface\Icons\Ability_Karoz_Leap]],
		['OPENALLBAGS'] = [[Interface\Icons\INV_Misc_Bag_29]],
		['TOGGLEGAMEMENU'] = [[Interface\Icons\Achievement_ChallengeMode_Auchindoun_Hourglass]],
		['TOGGLEWORLDMAP'] = [[Interface\Icons\INV_Misc_Map02]],
		['TARGETNEARESTENEMY'] = [[Interface\Icons\Spell_Hunter_FocusingShot]],
		['TARGETSCANENEMY'] = [[Interface\Icons\Spell_Hunter_FocusingShot]],
		['CLICK ConsolePortEasyMotionButton:LeftButton'] = [[Interface\Icons\Achievement_GuildPerk_EverybodysFriend]],
		['CLICK ConsolePortRaidCursorToggle:LeftButton'] = [[Interface\Icons\Achievement_GuildPerk_EverybodysFriend]],
		['CLICK ConsolePortRaidCursorFocus:LeftButton'] = [[Interface\Icons\Achievement_GuildPerk_EverybodysFriend]],
		['CLICK ConsolePortRaidCursorTarget:LeftButton'] = [[Interface\Icons\Achievement_GuildPerk_EverybodysFriend]],
		['CLICK ConsolePortUtilityToggle:LeftButton'] = [[Interface\Icons\Ability_Monk_CounteractMagic]],
	}
	return icons[binding]
end

function ab:GetCover(class)
	local classArt = {
		['WARRIOR'] = {1, 1},
		['PALADIN'] = {1, 2},
		['DRUID'] 	= {1, 3},
		['DEATHKNIGHT'] = {1, 4},
		----------------------------
		['MAGE'] 	= {2, 1},
		['HUNTER'] 	= {2, 2},
		['ROGUE'] 	= {2, 3},
		['WARLOCK'] = {2, 4},
		----------------------------
		['SHAMAN'] 	= {3, 1},
		['PRIEST'] 	= {3, 2},
		['DEMONHUNTER'] = {3, 3},
		['MONK'] 	= {3, 4},
	}
	local art = class and classArt[class]
	if not class and not art then
		art = classArt[select(2, UnitClass('player'))]
	end
	if art then
		local index, px = unpack(art)
		return [[Interface\AddOns\]]..addOn..[[\Textures\Covers\]]..index, {0, 1, (( px - 1 ) * 256 ) / 1024, ( px * 256 ) / 1024 }
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
		['CP_T1'] = {point = {'LEFT', 440, 64}, dir = 'right', size = 64},
		['CP_T2'] = {point = {'RIGHT', -440, 64}, dir = 'left', size = 64},
		---
		['CP_T3'] = {point = {'LEFT', 390, 110}, dir = 'up', size = 64},
		['CP_T4'] = {point = {'RIGHT', -390, 110}, dir = 'up', size = 64},
		---
		['CP_L_LEFT'] 	= {point = {'LEFT', 255 - 80, 50 + 14}, dir = 'left', size = 64},
		['CP_L_RIGHT'] 	= {point = {'LEFT', 385 - 80, 50 + 14}, dir = 'right', size = 64},
		['CP_L_UP'] 	= {point = {'LEFT', 320 - 80, 95 + 14}, dir = 'up', size = 64},
		['CP_L_DOWN'] 	= {point = {'LEFT', 320 - 80, 10 + 14}, dir = 'down', size = 64},
		---
		['CP_R_LEFT'] 	= {point = {'RIGHT', -385 + 80, 50 + 14}, dir = 'left', size = 64},
		['CP_R_RIGHT'] 	= {point = {'RIGHT', -255 + 80, 50 + 14}, dir = 'right', size = 64},
		['CP_R_UP'] 	= {point = {'RIGHT', -320 + 80, 95 + 14}, dir = 'up', size = 64},
		['CP_R_DOWN'] 	= {point = {'RIGHT', -320 + 80, 10 + 14}, dir = 'down', size = 64},
	}
	if button ~= nil then
		return layout[button]
	else
		return layout
	end
end

function ab:GetPresets()
	return {
		Default = ab:GetDefaultSettings(),
		Orthodox = {
			scale = 0.9,
			width = 1105,
			watchbars = true,
			showline = true,
			lock = true,
			layout = {
				CP_L_RIGHT = {dir = 'right', point = {'LEFT', 330, 9}, size = 64},
				CP_R_LEFT = {dir = 'left', point = {'RIGHT', -330, 9}, size = 64},
				CP_L_DOWN = {dir = 'down', point = {'LEFT', 165, 9}, size = 64},
				CP_L_LEFT = {dir = 'left', point = {'LEFT', 80, 9}, size = 64},
				CP_L_UP = {dir = 'up', point = {'LEFT', 250, 9}, size = 64},
				CP_T3 = {dir = 'up', point = {'LEFT', 405, 75}, size = 64},
				CP_T1 = {dir = 'right', point = {'LEFT', 440, 9}, size = 64},
				CP_R_RIGHT = {dir = 'right', point = {'RIGHT', -80, 9}, size = 64},
				CP_T4 = {dir = 'up', point = {'RIGHT', -405, 75}, size = 64},
				CP_T2 = {dir = 'left', point = {'RIGHT', -440, 9}, size = 64},
				CP_R_UP = {dir = 'up', point = {'RIGHT', -165, 9}, size = 64},
				CP_R_DOWN = {dir = 'down', point = {'RIGHT', -250, 9}, size = 64},
			},
		},
		Roleplay = {
			scale = 0.9,
			width = 1105,
			watchbars = true,
			showline = true,
			showart = true,
			lock = true,
			layout = ab:GetDefaultButtonLayout(),
		},
	}
end

function ab:GetRGBColorFor(element, default)
	local cfg = ab.cfg
	local defaultColors = {
		tint 	= {r, g, b, 1},
		border 	=  {1, 1, 1, 1},
		swipe 	= {r, g, b, 1},
		exp 	= {r, g, b, 1},
	}
	if default then
		if defaultColors[element] then
			return unpack(defaultColors[element])
		end
	end
	local current = {
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
		width = 1105,
		watchbars = true,
		showline = true,
		lock = true,
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

function ab:GetSimpleSettings(otherCFG)
	local cfg = otherCFG or ab.cfg
	local L = ab.data.ACTIONBAR
	return {
		{	desc = L.CFG_LOCK,
			cvar = 'lock',
			toggle = cfg and cfg.lock,
		},
		{	desc = L.CFG_LOCKPET,
			cvar = 'lockpet',
			toggle = cfg and cfg.lockpet,
		},
		{	desc = L.CFG_HIDEINCOMBAT,
			cvar = 'combathide',
			toggle = cfg and cfg.combathide,
		},
		{	desc = L.CFG_HIDEPETINCOMBAT,
			cvar = 'combatpethide',
			toggle = cfg and cfg.combatpethide,
		},
		{	desc = L.CFG_HIDEOUTOFCOMBAT,
			cvar = 'hidebar',
			toggle = cfg and cfg.hidebar,
		},
		{
			desc = L.CFG_DISABLEPET,
			cvar = 'hidepet',
			toggle = cfg and cfg.hidepet,
		},
		{	desc = L.CFG_SHOWALLBUTTONS,
			cvar = 'showbuttons',
			toggle = cfg and cfg.showbuttons,
		},
		{
			desc = L.CFG_DISABLEDND,
			cvar = 'disablednd',
			toggle = cfg and cfg.disablednd,
		},
		{	desc = L.CFG_WATCHBAR_OFF,
			cvar = 'hidewatchbars',
			toggle = cfg and cfg.hidewatchbars,
		},
		{	desc = L.CFG_WATCHBAR_ALPHA,
			cvar = 'watchbars',
			toggle = cfg and cfg.watchbars,
		},
		{	desc = L.CFG_QUICKMENU,
			cvar = 'quickMenu',
			toggle = cfg and cfg.quickMenu,
		},
		{	desc = L.CFG_MOUSE_ENABLE,
			cvar = 'mousewheel',
			toggle = cfg and cfg.mousewheel,
		},
		{	desc = L.CFG_ART_UNDERLAY,
			cvar = 'showart',
			toggle = cfg and cfg.showart,
		},
		{	desc = L.CFG_ART_TINT,
			cvar = 'showline',
			toggle = cfg and cfg.showline,
		},
	}
end

function ab:SetRainbowScript(on)
	local f = ab.bar
	local wr = ab.libs.wrapper
	local cp = ConsolePort
	if on then
		local t, i, p, c, w, m = 0, 0, 0, 128, 127, 180
		local hz = (math.pi*2) / m

		f:SetScript('OnUpdate', function(self, e)
			t = t + e
			if t > 0.1 then
				i = i + 1
				local r = (math.sin((hz * i) + 2 + p) * w + c) / 255
				local g = (math.sin((hz * i) + 0 + p) * w + c) / 255
				local b = (math.sin((hz * i) + 4 + p) * w + c) / 255
				if i > m then
					i = i - m
				end
				f.BG:SetGradientAlpha(ab:GetColorGradient(r, g, b))
				f.BottomLine:SetVertexColor(r, g, b)
				for bn in cp:GetBindings() do
					local rap = wr:Get(bn)
					if rap then
						rap:SetSwipeColor(r, g, b, 1)
					end
				end
				t = 0
			end
		end)
	else
		f:SetScript('OnUpdate', nil)
	end
end

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- Override the original consoleport action button lookup, to
-- stop it from adding hotkey textures to the controller bars.
-- This should still add hotkey textures to override/vehicles.

local valid_action_buttons = {
	Button = true,
	CheckButton = true,
}

-- Wrap this function since it's recursive.
local function GetActionButtons(buttons, this)
	buttons = buttons or {}
	this = this or UIParent
	if this:IsForbidden() or this == ab.bar then
		return buttons
	end
	local objType = this:GetObjectType()
	local action = this:IsProtected() and valid_action_buttons[objType] and this:GetAttribute('action')
	if action and tonumber(action) and this:GetAttribute('type') == 'action' then
		buttons[this] = action
	end
	for _, object in pairs({this:GetChildren()}) do
		GetActionButtons(buttons, object)
	end
	return buttons
end

---------------------------------------------------------------
-- Get all buttons that look like action buttons
---------------------------------------------------------------
function ConsolePort:GetActionButtons(getTable, parent)
	if getTable then
		return GetActionButtons(parent)
	else
		return pairs(GetActionButtons(parent))
	end
end
---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------