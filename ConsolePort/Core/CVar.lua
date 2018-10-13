---------------------------------------------------------------
-- CVar.lua: CVar management 
---------------------------------------------------------------
-- Used to increase convenience during gameplay without 
-- applying permanent changes to global CVars. Allows
-- cvar updates when entering/leaving combat.

local _, db = ...

local CVars = {
	TargetNearestUseNew 		= 	{value = 0,		event = nil},
	autoLootDefault 			= 	{value = true,	event = 'AUTO_LOOT_DEFAULT_TEXT', isCombatCVar = true },
	mouseInvertPitch 			= 	{value = true, 	event = 'INVERT_MOUSE'},
	mouseInvertYaw				= 	{value = true, 	event = nil},
	nameplateShowAll			= 	{value = 1,		event = 'UNIT_NAMEPLATES_AUTOMODE'},
	nameplateShowFriends		= 	{value = 1,		event = 'UNIT_NAMEPLATES_SHOW_FRIENDS'},
	nameplateShowFriendlyNPCs 	= 	{value = 1,		event = nil},
}


function ConsolePort:LoadDefaultCVars()
	for cvar, info in pairs(CVars) do
		if info.default then
			info.protected = true
		else
			info.default = GetCVar(cvar)
		end
	end
	self.LoadDefaultCVars = nil
end

function ConsolePort:UpdateCVars(inCombat, ...)
	local isToggled = db.Settings
	local newCvar, newValue = ...
	for cvar, info in pairs(CVars) do
		if inCombat == nil then
			-- If a specific cvar triggered the update (toggled inside Blizzard interface options), assign it to default value
			if newCvar and info.event == newCvar then
				info.default = newValue
			end
			-- If the cvar is not combat related, toggle it on until logout/disable
			if not info.isCombatCVar and isToggled[cvar] then
				info.default = info.default or GetCVar(cvar)
				SetCVar(cvar, info.value)
			-- If the cvar is not toggled but has a stored default value, then set default
			elseif not isToggled[cvar] and info.default then
				SetCVar(cvar, info.default)
				if not info.protected then
					info.default = nil
				end
			end
			-- If the cvar is combat related and toggled on
		elseif info.isCombatCVar and isToggled[cvar] then
			if inCombat then
				SetCVar(cvar, info.value)
			else
				SetCVar(cvar, info.default)
			end
		end
	end
end

function ConsolePort:ResetCVars()
	for cvar, info in pairs(CVars) do
		if info.default then
			SetCVar(cvar, info.default)
		end
	end
end
