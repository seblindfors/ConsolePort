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
-- manager, bindable like any other ConsolePort action. The
-- manager is driven from PreClick; the tab target is protected,
-- so it runs as the button's own macro, on press or on release
-- depending on the setting. On release, the camera stick is held
-- off only when pushed past the targeting deadzone.

local TAB_OFF, TAB_ALWAYS, TAB_NO_TARGET = 0, 1, 2;
local ANALOG_DEADZONE = 'GamepadTargetingAnalogDeadzone';

local function CreateTargetButton(name, filter, macro)
	local button = CreateFrame('Button', 'ConsolePort'..name, ConsolePort, 'SecureActionButtonTemplate')
	button:RegisterForClicks('AnyDown', 'AnyUp')
	button:SetAttribute('type', 'macro')
	button:SetScript('PreClick', function(_, _, down)
		if down then
			C_GamepadTargeting.SetFilter(filter)
			C_GamepadTargeting.Enable()
			db:TriggerEvent('OnAimHold', true)
			return;
		end
		C_GamepadTargeting.Disable()
		db:TriggerEvent('OnAimHold', false)
		db.Radial:ReleaseStick('Camera', tonumber(GetCVar(ANALOG_DEADZONE)) or 0)
	end)
	function button:UpdateMacro()
		local mode = db('trgtHoldTabTarget');
		if ( mode == TAB_ALWAYS ) then
			self:SetAttribute('useOnKeyDown', true)
			self:SetAttribute('macrotext', macro)
		elseif ( mode == TAB_NO_TARGET ) then
			self:SetAttribute('useOnKeyDown', false)
			self:SetAttribute('macrotext', macro .. ' [@target,noexists]')
		else
			self:SetAttribute('useOnKeyDown', false)
			self:SetAttribute('macrotext', '')
		end
	end
	return button;
end

local TargetFriendly = CreateTargetButton('TargetFriendly', Enum.GamepadTargetingFilters.Friendly, '/targetfriend')
local TargetHostile  = CreateTargetButton('TargetHostile',  Enum.GamepadTargetingFilters.Hostile,  '/targetenemy')

local TargetButtons = CPAPI.DataHandler({})

function TargetButtons:OnDataLoaded()
	TargetFriendly:UpdateMacro()
	TargetHostile:UpdateMacro()
	return CPAPI.BurnAfterReading;
end

db:RegisterSafeCallback('Settings/trgtHoldTabTarget', TargetButtons.OnDataLoaded, TargetButtons)
