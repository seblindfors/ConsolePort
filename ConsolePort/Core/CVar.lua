---------------------------------------------------------------
-- CVar.lua: CVar management 
---------------------------------------------------------------
-- Used to increase convenience during gameplay without 
-- applying permanent changes to global CVars. Allows
-- cvar updates when entering/leaving combat.

local CVars = {
	autoLootDefault 			= 	{value = true,	isCombatCVar = true, 	event = "AUTO_LOOT_DEFAULT_TEXT"},
	autoInteract 				= 	{value = true, 	isCombatCVar = false,	event = "CLICK_TO_MOVE"},
	cameraDistanceMoveSpeed 	=	{value = 50, 	isCombatCVar = false},
}

function ConsolePort:UpdateCVars(inCombat, ...)
	local isToggled = ConsolePortSettings
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
				info.default = nil
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