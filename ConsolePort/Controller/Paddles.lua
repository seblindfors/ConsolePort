---------------------------------------------------------------
-- Paddles (faux bindings)
---------------------------------------------------------------
-- Since few APIs and gamepads can actually use the defined
-- paddle buttons in the game, allow keyboard buttons to simulate
-- them by proxying their bindings and treating them as real buttons.

local _, db = ...
local Paddles = db:Register('Paddles', CPAPI.EventHandler(ConsolePortPaddles, { 'UPDATE_BINDINGS' }))
local NUM_PADDLES, NOT_BOUND = 4, 'none';


function Paddles:IsButtonBound(button)
	return button ~= nil and button ~= NOT_BOUND;
end

function Paddles:GetEmulatedButton(key)
	if not self:IsButtonBound(key) then return end;
	for i = 1, NUM_PADDLES do
		local mapping, buttonID = self:GetEmulation(i)
		if (key == mapping) then
			return buttonID;
		end
	end
end

function Paddles:GetEmulation(id)
	local button  = ('PADPADDLE' .. id)
	local mapping = db('emulate' .. button)
	return mapping, button, self:IsButtonBound(mapping);
end

function Paddles:SetEmulation(id, key)
	return db('Settings/emulatePADPADDLE'..id, key)
end

function Paddles:UPDATE_BINDINGS()
	C_Timer.After(0, function()
		db:RunSafe(self.OnPaddlesChanged, self)
	end)
end

function Paddles:OnDataLoaded()
	self:OnPaddlesChanged()
end

function Paddles:OnPaddlesChanged()
	for i = 1, NUM_PADDLES do
		self:UpdatePaddleBindings(i)
	end
end

function Paddles:UpdatePaddleBindings(id)
	local mapping, button, isBound = self:GetEmulation(id)

	-- Clear old bindings
	if self[id] then
		for activeMapping in pairs(self[id]) do
			SetOverrideBinding(self, false, activeMapping, nil)
		end
		self[id] = nil;
	end

	if (isBound) then
		-- Clear overlap
		for other = 1, NUM_PADDLES do
			if (other ~= id and self:GetEmulation(other) == mapping) then
				self:SetEmulation(other, NOT_BOUND)
			end
		end

		-- Set new bindings
		self[id] = {};
		for modifier in pairs(db.Gamepad.Index.Modifier.Active) do
			local action = GetBindingAction(modifier..button)
			local activeMapping = modifier..mapping;
			self[id][activeMapping] = action;
			SetOverrideBinding(self, false, activeMapping, action)
		end
	end
end

db:RegisterSafeCallback('Gamepad/Active', Paddles.OnPaddlesChanged, Paddles)
for i = 1, NUM_PADDLES do
	db:RegisterSafeCallback('Settings/emulatePADPADDLE'..i, Paddles.UpdatePaddleBindings, Paddles, i)
end