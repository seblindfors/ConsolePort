if not CPAPI.IsCamelotVersion then return end;
local _, db = ...;

---------------------------------------------------------------
-- Interface style transitions (Forever)
---------------------------------------------------------------
local Transition = CPAPI.CreateEventHandler({'Frame', '$parentInterfaceTransition', ConsolePort}, {
	'INPUT_DEVICE_INTERFACE_TRANSITION';
})

function Transition:INPUT_DEVICE_INTERFACE_TRANSITION()
	db:TriggerEvent('OnNativeNavigationChanged', CPAPI.IsNativeNavigationActive())
end

if not C_GamepadTargeting or not Enum.GamepadTargetingFilters then return end;
---------------------------------------------------------------
-- Native gamepad targeting (Forever)
---------------------------------------------------------------
-- Hold-to-target buttons over the game's gamepad targeting
-- manager, bindable like any other ConsolePort action.

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
		db.Radial:ReleaseStick('Camera')
	end)
	return button;
end

CreateTargetButton('TargetFriendly', Enum.GamepadTargetingFilters.Friendly, TargetNearestFriend, 'GamepadTabFriendlyTargetAction')
CreateTargetButton('TargetHostile',  Enum.GamepadTargetingFilters.Hostile,  TargetNearestEnemy,  'GamepadTabHostileTargetAction')
