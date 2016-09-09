local addOn, ab = ...

function ab:GetBindingIcon(binding)
	local icons = {
		["JUMP"] = [[Interface\Icons\Ability_Karoz_Leap]],
		["OPENALLBAGS"] = [[Interface\Icons\INV_Misc_Bag_29]],
		["TOGGLEGAMEMENU"] = [[Interface\Icons\Achievement_ChallengeMode_Auchindoun_Hourglass]],
		["TOGGLEWORLDMAP"] = [[Interface\Icons\INV_Misc_Map02]],
		["TARGETNEARESTENEMY"] = [[Interface\Icons\Spell_Hunter_FocusingShot]],
		["TARGETSCANENEMY"] = [[Interface\Icons\Spell_Hunter_FocusingShot]],
		["CLICK ConsolePortWorldCursor:LeftButton"] = [[Interface\Icons\Achievement_GuildPerk_EverybodysFriend]],
	}
	return icons[binding]
end

function ab:GetCover(class)
	local classArt = {
		["WARRIOR"] = {1, 1},
		["PALADIN"] = {1, 2},
		["DRUID"] 	= {1, 3},
		["DEATHKNIGHT"] = {1, 4},
		----------------------------
		["MAGE"] 	= {2, 1},
		["HUNTER"] 	= {2, 2},
		["ROGUE"] 	= {2, 3},
		["WARLOCK"] = {2, 4},
		----------------------------
		["SHAMAN"] 	= {3, 1},
		["PRIEST"] 	= {3, 2},
		["DEMONHUNTER"] = {3, 3},
		["MONK"] 	= {3, 4},
	}
	local art = class and classArt[class]
	if not class and not art then
		art = classArt[select(2, UnitClass("player"))]
	end
	if art then
		local index, px = unpack(art)
		return [[Interface\AddOns\]]..addOn..[[\Textures\Covers\]]..index, {0, 1, (( px - 1 ) * 256 ) / 1024, ( px * 256 ) / 1024 }
	end
end

function ab:GetBackdrop()
	return {
		edgeFile 	= "Interface\\AddOns\\"..addOn.."\\Textures\\BarEdge",
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	}
end

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- Override the original consoleport action button lookup.
-- We don't want to display additional hotkey textures on our own bars, 
-- since we'll be using our own icons.

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
	local action = this:IsProtected() and valid_action_buttons[objType] and this:GetAttribute("action")
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