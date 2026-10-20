if not CPAPI.IsCamelotVersion or not C_GamepadTargeting or not Enum.GamepadTargetingFilters then return end;
---------------------------------------------------------------
-- Native gamepad targeting (Forever)
---------------------------------------------------------------
-- Hold-to-target buttons over the game's gamepad targeting
-- manager, bindable like any other ConsolePort action.

local _, db = ...;

local function CreateTargetButton(name, filter, tabTarget, tabCvar)
	local button = CreateFrame('Button', 'ConsolePort'..name, ConsolePort)
	button:RegisterForClicks('AnyDown', 'AnyUp')
	button:SetScript('OnClick', function(_, _, down)
		if down then
			C_GamepadTargeting.SetFilter(filter)
			C_GamepadTargeting.Enable()
			return;
		end
		local targetAlreadySelected = C_GamepadTargeting.Disable()
		if ( not targetAlreadySelected and GetCVarBool(tabCvar) ) then
			tabTarget(false)
		end
	end)
	return button;
end

CreateTargetButton('TargetFriendly', Enum.GamepadTargetingFilters.Friendly, TargetNearestFriend, 'GamepadTabFriendlyTargetAction')
CreateTargetButton('TargetHostile',  Enum.GamepadTargetingFilters.Hostile,  TargetNearestEnemy,  'GamepadTabHostileTargetAction')
