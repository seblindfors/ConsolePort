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
	
	if IsBindingForGamePad(button) then
		RegisterStateDriver(self, 'override', condition)
		self:Execute([[self:RunAttribute('OnBindingsChanged')]])
	end
end

db:RegisterSafeCallback('Settings/interactButton', Interact.OnDataLoaded, Interact)
db:RegisterSafeCallback('Settings/interactCondition', Interact.OnDataLoaded, Interact)