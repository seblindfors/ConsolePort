---------------------------------------------------------------
-- Paddles (faux bindings)
---------------------------------------------------------------
-- Since few APIs and gamepads can actually use the defined
-- paddle buttons in the game, allow keyboard buttons to simulate
-- them by proxying their bindings and treating them as real buttons.

local _, db = ...
local Paddles = db:Register('Paddles', CPAPI.EventHandler(ConsolePortPaddles, { 'UPDATE_BINDINGS' }))
local NOT_BOUND = 'none';

function Paddles:UPDATE_BINDINGS()
	C_Timer.After(0, function()
		db:RunSafe(self.OnPaddlesChanged, self)
	end)
end

function Paddles:OnDataLoaded()
	self:OnPaddlesChanged()
end

function Paddles:GetEmulatedButton(button)
	if (button == nil or button == NOT_BOUND) then return end;
	for i=1, 4 do
		if (button == db('emulatePADPADDLE' .. i)) then
			return 'PADPADDLE'..i;
		end
	end
end

function Paddles:OnPaddlesChanged()
	for i = 1, 4 do
		self:UpdatePaddleBindings(i)
	end
end

function Paddles:GetEmulation(id)
	local button = ('PADPADDLE' .. id)
	local mapping = db('emulate' .. button)
	return mapping, button, mapping ~= nil and mapping ~= NOT_BOUND;
end

function Paddles:SetEmulation(id, key)
	return db('Settings/emulatePADPADDLE'..id, key)
end

function Paddles:UpdatePaddleBindings(id)
	local mapping, button, isBound = self:GetEmulation(id)

	-- Clear old bindings
	if self[id] then
		for modifier, mapping in pairs(self[id]) do
			SetOverrideBinding(self, false, modifier..mapping, nil)
		end
		self[id] = nil;
	end

	if (isBound) then
		-- Clear overlap
		for other = 1, 4 do
			if (other ~= id and self:GetEmulation(other) == mapping) then
				self:SetEmulation(other, NOT_BOUND)
			end
		end

		-- Set new bindings
		self[id] = {};
		for modifier in pairs(db.Gamepad.Index.Modifier.Active) do
			self[id][modifier] = modifier..mapping;
			SetOverrideBinding(self, false, modifier..mapping, GetBindingAction(modifier..button))
		end
	end
end

db:RegisterSafeCallback('Settings/emulatePADPADDLE1', Paddles.UpdatePaddleBindings, Paddles, 1)
db:RegisterSafeCallback('Settings/emulatePADPADDLE2', Paddles.UpdatePaddleBindings, Paddles, 2)
db:RegisterSafeCallback('Settings/emulatePADPADDLE3', Paddles.UpdatePaddleBindings, Paddles, 3)
db:RegisterSafeCallback('Settings/emulatePADPADDLE4', Paddles.UpdatePaddleBindings, Paddles, 4)
db:RegisterSafeCallback('Gamepad/Active', Paddles.OnPaddlesChanged, Paddles)