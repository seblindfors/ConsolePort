---------------------------------------------------------------
-- Interact button
---------------------------------------------------------------
-- Simple interact button using center-fixed cursor, when given
-- macro condtions apply.

local _, db = ...;
local Interact = db:Register('Interact', CPAPI.EventHandler(ConsolePortInteract))

Interact:SetAttribute('_onstate-override', [[
	self:SetAttribute('enabled', newstate)
	self:RunAttribute('OnOverrideChanged', newstate)
]])
Interact:SetAttribute('OnOverrideChanged', [[
	self:SetBinding(true, self:GetAttribute('slug'), ...)
]])
Interact:SetAttribute('OnBindingsChanged', [[
	self:RunAttribute('OnOverrideChanged', self:GetAttribute('enabled'))
]])

function Interact:OnDataLoaded()
	local button = db('interactButton')
	self:SetAttribute('slug', button)
	ClearOverrideBindings(self)
	if IsBindingForGamePad(button) then
		RegisterStateDriver(self, 'override', db('interactCondition'))
	else
		UnregisterStateDriver(self, 'override')
	end
end

db:RegisterSafeCallback('Settings/interactButton', Interact.OnDataLoaded, Interact)
db:RegisterSafeCallback('Settings/interactCondition', Interact.OnDataLoaded, Interact)