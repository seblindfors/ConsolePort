---------------------------------------------------------------
-- Interact button
---------------------------------------------------------------
-- Simple interact button using center-fixed cursor, when given
-- macro condtions apply.

local _, db = ...;
local Interact = db:Register('Interact', CPAPI.DataHandler(ConsolePortInteract))

Interact:SetAttribute('_onstate-override', [[
	self:SetAttribute('enabled', newstate)
	self:RunAttribute('OnOverrideChanged', newstate)
]])
Interact:SetAttribute('OnOverrideChanged', CPAPI.ConvertSecureBody([[
	local action = ...;
	local slug, name = self:GetAttribute('slug'), self:GetName();
	if action then
		layers::Claim(name, 'OVERRIDE', slug, 'binding', action)
	else
		layers::Release(name, slug)
	end
]]))
Interact:SetAttribute('OnBindingsChanged', [[
	self:RunAttribute('OnOverrideChanged', self:GetAttribute('enabled'))
]])

function Interact:OnDataLoaded()
	local button = db('interactButton')
	local condition = db('interactCondition')

	self:SetAttribute('slug', button)
	self:SetFrameRef('Layers', db.Layers)
	self:Execute([[ layers = self:GetFrameRef('Layers') ]])
	db.Layers:ReleaseAll(self)
	UnregisterStateDriver(self, 'override')

	if IsBindingForGamePad(button) then
		RegisterStateDriver(self, 'override', condition)
		self:Execute([[self:RunAttribute('OnBindingsChanged')]])
	end

	return CPAPI.KeepMeForLater;
end

db:RegisterSafeCallback('Settings/interactButton', Interact.OnDataLoaded, Interact)
db:RegisterSafeCallback('Settings/interactCondition', Interact.OnDataLoaded, Interact)