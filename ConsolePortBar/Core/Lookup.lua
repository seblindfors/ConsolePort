local addOn, ab = ...

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
		['CP_L_GRIP'] = {point = {'LEFT', 390, 110}, dir = 'up', size = 64},
		['CP_R_GRIP'] = {point = {'RIGHT', -390, 110}, dir = 'up', size = 64},
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

function ab:GetDefaultSettings()
	return 	{
		scale = 0.9,
		width = BAR_MIN_WIDTH,
		watchbars = true,
		showline = true,
		lock = true,
		layout = ab:GetDefaultButtonLayout()
	}
end

function ab:GetSimpleSettings()
	local cfg = ab.cfg
	local L = ab.data.ACTIONBAR
	return {
		{
			desc = L.CFG_LOCK,
			cvar = 'lock',
			toggle = cfg and cfg.lock,
		},
		{
			desc = L.CFG_LOCKPET,
			cvar = 'lockpet',
			toggle = cfg and cfg.lockpet,
		},
		{
			desc = L.CFG_HIDEINCOMBAT,
			cvar = 'combathide',
			toggle = cfg and cfg.combathide,
		},
		{
			desc = L.CFG_HIDEPETINCOMBAT,
			cvar = 'combatpethide',
			toggle = cfg and cfg.combatpethide,
		},
		{
			desc = L.CFG_HIDEOUTOFCOMBAT,
			cvar = 'hidebar',
			toggle = cfg and cfg.hidebar,
		},
		{
			desc = L.CFG_SHOWALLBUTTONS,
			cvar = 'showbuttons',
			toggle = cfg and cfg.showbuttons,
		},
		{
			desc = L.CFG_WATCHBAR_OFF,
			cvar = 'hidewatchbars',
			toggle = cfg and cfg.hidewatchbars,
		},
		{
			desc = L.CFG_WATCHBAR_ALPHA,
			cvar = 'watchbars',
			toggle = cfg and cfg.watchbars,
		},
		{
			desc = L.CFG_QUICKMENU,
			cvar = 'quickMenu',
			toggle = cfg and cfg.quickMenu,
		},
		{
			desc = L.CFG_MOUSE_ENABLE,
			cvar = 'mousewheel',
			toggle = cfg and cfg.mousewheel,
		},
		{
			desc = L.CFG_ART_UNDERLAY,
			cvar = 'showart',
			toggle = cfg and cfg.showart,
		},
		{
			desc = L.CFG_ART_TINT,
			cvar = 'showline',
			toggle = cfg and cfg.showline,
		},
	}
end

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- Override the original consoleport action button lookup, to
-- stop it from adding hotkey textures to the controller bars.

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
	if action and tonumber(action) then
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