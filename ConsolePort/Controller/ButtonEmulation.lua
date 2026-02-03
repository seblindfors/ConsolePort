---------------------------------------------------------------
-- Button Emulation Handler
---------------------------------------------------------------
-- Handles emulation of gamepad buttons that are mismatched
-- between controller types (Xbox vs PlayStation vs others).
-- Allows keyboard keys to emulate these buttons.

local _, db = ...
local ButtonEmulation = db:Register('ButtonEmulation', CPAPI.EventHandler(CreateFrame('Frame', 'ConsolePortButtonEmulation'), { 'UPDATE_BINDINGS' }))
local NOT_BOUND = 'none';

-- Emulated button configurations
-- Priority order: Paddles first (most common), then others
local EMULATED_BUTTONS = {
	-- Paddle buttons (most common - Xbox Elite, DualSense Edge, etc.)
	{id = 'PADDLE1',     button = 'PADPADDLE1',   setting = 'emulatePADPADDLE1'},
	{id = 'PADDLE2',     button = 'PADPADDLE2',   setting = 'emulatePADPADDLE2'},
	{id = 'PADDLE3',     button = 'PADPADDLE3',   setting = 'emulatePADPADDLE3'},
	{id = 'PADDLE4',     button = 'PADPADDLE4',   setting = 'emulatePADPADDLE4'},
	-- Extra face buttons (varies by controller)
	{id = 'PAD5',        button = 'PAD5',         setting = 'emulatePAD5'},
	{id = 'PAD6',        button = 'PAD6',         setting = 'emulatePAD6'},
	-- System/menu buttons (different across platforms)
	{id = 'PADBACK',     button = 'PADBACK',      setting = 'emulatePADBACK'},
	{id = 'PADFORWARD',  button = 'PADFORWARD',   setting = 'emulatePADFORWARD'},
	{id = 'PADSYSTEM',   button = 'PADSYSTEM',    setting = 'emulatePADSYSTEM'},
	{id = 'PADSOCIAL',   button = 'PADSOCIAL',    setting = 'emulatePADSOCIAL'},
}

function ButtonEmulation:IsButtonBound(key)
	return key ~= nil and key ~= NOT_BOUND;
end

function ButtonEmulation:GetEmulatedButton(key)
	if not self:IsButtonBound(key) then return end;
	for _, config in ipairs(EMULATED_BUTTONS) do
		local mapping = db(config.setting)
		if (key == mapping) then
			return config.button;
		end
	end
end

function ButtonEmulation:GetEmulation(id)
	for _, config in ipairs(EMULATED_BUTTONS) do
		if config.id == id then
			local mapping = db(config.setting)
			return mapping, config.button, self:IsButtonBound(mapping);
		end
	end
end

function ButtonEmulation:SetEmulation(id, key)
	for _, config in ipairs(EMULATED_BUTTONS) do
		if config.id == id then
			return db('Settings/'..config.setting, key)
		end
	end
end

function ButtonEmulation:UPDATE_BINDINGS()
	CPAPI.Next(db.RunSafe, db, self.OnButtonsChanged, self)
end

function ButtonEmulation:OnDataLoaded()
	self:OnButtonsChanged()
	return CPAPI.BurnAfterReading;
end

function ButtonEmulation:OnButtonsChanged()
	for _, config in ipairs(EMULATED_BUTTONS) do
		self:UpdateButtonBindings(config.id)
	end
end

function ButtonEmulation:UpdateButtonBindings(id)
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
		for _, config in ipairs(EMULATED_BUTTONS) do
			if (config.id ~= id) then
				local otherMapping = db(config.setting)
				if (otherMapping == mapping) then
					self:SetEmulation(config.id, NOT_BOUND)
				end
			end
		end

		-- Set new bindings
		self[id] = {};
		for modifier in pairs(db.Gamepad.Index.Modifier.Active) do
			local action = CPAPI.GetBindingAction(modifier..button)
			local activeMapping = modifier..mapping;
			self[id][activeMapping] = action;
			SetOverrideBinding(self, false, activeMapping, action)
		end
	end
end

db:RegisterSafeCallback('Gamepad/Active', ButtonEmulation.OnButtonsChanged, ButtonEmulation)
for _, config in ipairs(EMULATED_BUTTONS) do
	db:RegisterSafeCallback('Settings/'..config.setting, ButtonEmulation.UpdateButtonBindings, ButtonEmulation, config.id)
end