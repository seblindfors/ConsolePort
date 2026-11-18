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

---------------------------------------------------------------
-- Native gamepad targeting (Forever)
---------------------------------------------------------------
local CONTEXT = Enum.BindingContext and Enum.BindingContext.GamepadModeInGameCore;
if not CONTEXT or not GamepadMode or not GamepadMode.RegisterTargetModifierStateChanged then return end;

local ANALOG_DEADZONE = 'GamepadTargetingAnalogDeadzone';
local TARGETING_NONE  = GamepadTargetingState.NONE;

local Targeting = CPAPI.DataHandler({})

local ActivateContext;
function ActivateContext()
	if InCombatLockdown() then
		return db:RunSafe(ActivateContext);
	end
	if not C_KeyBindings.IsBindingContextActive(CONTEXT) then
		C_KeyBindings.ActivateBindingContext(CONTEXT)
	end
end

function Targeting:OnHoldChanged(state)
	local held = ( state ~= TARGETING_NONE );
	if ( self.held == held ) then return end;
	self.held = held;
	db:TriggerEvent('OnAimHold', held)
	if not held then
		db.Radial:ReleaseStick('Camera', tonumber(GetCVar(ANALOG_DEADZONE)) or 0)
	end
end

function Targeting:OnHoldCancelled()
	self:OnHoldChanged(TARGETING_NONE)
end

function Targeting:OnNativeNavigationChanged()
	RunNextFrame(ActivateContext)
end

function Targeting:OnDataLoaded()
	ActivateContext()
	return CPAPI.BurnAfterReading;
end

GamepadMode.RegisterTargetModifierStateChanged(Targeting.OnHoldChanged, Targeting)
GamepadMode.RegisterTargetModifierStateCancelled(Targeting.OnHoldCancelled, Targeting)
db:RegisterCallback('OnNativeNavigationChanged', Targeting.OnNativeNavigationChanged, Targeting)

---------------------------------------------------------------
-- Target any unit (Forever)
---------------------------------------------------------------
local FILTER_ALL = C_GamepadTargeting and Enum.GamepadTargetingFilters and Enum.GamepadTargetingFilters.All;
if not FILTER_ALL then return end;

local TargetAny = CreateFrame('Button', '$parentTargetAny', ConsolePort)
TargetAny:RegisterForClicks('AnyDown', 'AnyUp')
TargetAny:SetScript('OnClick', function(_, _, down)
	if down then
		C_GamepadTargeting.SetFilter(FILTER_ALL)
		C_GamepadTargeting.Enable()
		return Targeting:OnHoldChanged(GamepadTargetingState.BOTH);
	end
	C_GamepadTargeting.Disable()
	Targeting:OnHoldChanged(TARGETING_NONE)
end)
