---------------------------------------------------------------
-- Interact button
---------------------------------------------------------------
-- Simple interact button using center-fixed cursor, when given
-- macro condtions apply.

local _, db = ...;
local Interact = db:Register('Interact', CPAPI.EventHandler(ConsolePortInteract))

local STATE = {
	OFF  = 0;
	PAD  = 1;
	KBM  = 2;
	ALL  = 3;
}

Interact:SetAttribute('_onstate-override', [[
	self:SetAttribute('enabled', newstate)
	self:RunAttribute('OnOverrideChanged', newstate)
]])
Interact:SetAttribute('OnOverrideChanged', [[
	self:SetBinding(false, self:GetAttribute('slug'), ...)
]])
Interact:SetAttribute('OnBindingsChanged', [[
	self:RunAttribute('OnOverrideChanged', self:GetAttribute('enabled'))
]])

function Interact:OnDataLoaded()
	local button = db('interactButton')
	local condition = db('interactCondition')

	self:SetAttribute('slug', button)
	ClearOverrideBindings(self)
	UnregisterStateDriver(self, 'override')
	
	local isEnabled = false;
	if IsBindingForGamePad(button) then
		RegisterStateDriver(self, 'override', condition)
		self:Execute([[self:RunAttribute('OnBindingsChanged')]])
		isEnabled = true;
	end

	if CPAPI.IsWoW10Version then
		local interactState, state = isEnabled and 1 or -1, tonumber(GetCVar('SoftTargetInteract'))
		interactState = 
			(state == STATE.OFF or state == STATE.PAD) and (isEnabled and STATE.PAD or STATE.OFF) or
			(state == STATE.KBM or state == STATE.ALL) and (isEnabled and STATE.ALL or STATE.KBM);

		SetCVar('SoftTargetInteract', interactState)
		if (interactState == STATE.PAD or interactState == STATE.ALL) then
			SetCVar('SoftTargetLowPriorityIcons', 1)
			SetCVar('SoftTargetIconGameObject', 1)
			SetCVar('SoftTargetIconInteract', 1)
		end
	end
end

db:RegisterSafeCallback('Settings/interactButton', Interact.OnDataLoaded, Interact)
db:RegisterSafeCallback('Settings/interactCondition', Interact.OnDataLoaded, Interact)