---------------------------------------------------------------
-- Bindings (emulation and conditional presets)
---------------------------------------------------------------
-- Extends the bindings model with controller functionality:
-- emulates gamepad buttons that are missing from the current
-- loadout by proxying their bindings from keyboard keys, and
-- loads binding presets automatically when a macro condition
-- applies.

local _, db = ...;
local Bindings = db.Bindings;
local NOT_BOUND, PRESET_ATTRIBUTE = 'none', 'preset';

---------------------------------------------------------------
-- Emulated buttons
---------------------------------------------------------------
Bindings.Emulated = {
	'PADPADDLE1';
	'PADPADDLE2';
	'PADPADDLE3';
	'PADPADDLE4';
	'PAD5';
	'PAD6';
	'PADBACK';
	'PADFORWARD';
	'PADSYSTEM';
	'PADSOCIAL';
};

function Bindings:IsButtonBound(key)
	return key ~= nil and key ~= NOT_BOUND;
end

function Bindings:GetEmulatedButton(key)
	if not self:IsButtonBound(key) then return end;
	for _, button in ipairs(self.Emulated) do
		if ( key == db('emulate'..button) ) then
			return button;
		end
	end
end

function Bindings:GetEmulation(button)
	local mapping = db('emulate'..button)
	return mapping, self:IsButtonBound(mapping);
end

function Bindings:SetEmulation(button, key)
	return db('Settings/emulate'..button, key)
end

function Bindings:OnEmulationChanged()
	for _, button in ipairs(self.Emulated) do
		self:UpdateEmulation(button)
	end
end

function Bindings:UpdateEmulation(button)
	local mapping, isBound = self:GetEmulation(button)

	-- Clear old bindings
	if self[button] then
		for activeMapping in pairs(self[button]) do
			SetOverrideBinding(self, false, activeMapping, nil)
		end
		self[button] = nil;
	end

	if (isBound) then
		-- Clear overlap
		for _, other in ipairs(self.Emulated) do
			if ( other ~= button and (self:GetEmulation(other)) == mapping ) then
				self:SetEmulation(other, NOT_BOUND)
			end
		end

		-- Set new bindings, resolving overrides so that emulated
		-- buttons route to the same target as their real combos.
		self[button] = {};
		for modifier in pairs(db.Gamepad.Index.Modifier.Active) do
			local action = CPAPI.GetBindingAction(modifier..button, true)
			local activeMapping = modifier..mapping;
			self[button][activeMapping] = action;
			SetOverrideBinding(self, false, activeMapping, action)
		end
	end
end

---------------------------------------------------------------
-- Conditional binding presets
---------------------------------------------------------------

function Bindings:OnConditionChanged()
	local condition = (db('bindingPresetCondition') or ''):trim()
	UnregisterAttributeDriver(self, PRESET_ATTRIBUTE)
	self:SetAttribute(PRESET_ATTRIBUTE, nil)
	if ( condition ~= '' ) then
		-- Force a fallback clause so the attribute zeroes out when
		-- no condition applies, allowing the same preset to fire
		-- again the next time a condition matches.
		RegisterAttributeDriver(self, PRESET_ATTRIBUTE, condition..'; nil')
	end
end

function Bindings:OnAttributeChanged(attribute, value)
	if ( attribute ~= PRESET_ATTRIBUTE ) then return end;
	if ( type(value) ~= 'string' ) then return end;
	db:RunSafe(self.LoadPreset, self, value:trim())
end

function Bindings:GetPresetByName(name)
	for key, settings in db:For('Shared/Data', true) do
		if settings.Bindings and ( key == name or settings.Meta and settings.Meta.Name == name ) then
			return settings.Bindings;
		end
	end
end

function Bindings:GetDeviceByName(name)
	for deviceName, device in db.Gamepad:EnumerateDevices() do
		if ( deviceName == name ) then
			return device;
		end
	end
end

function Bindings:LoadPreset(name)
	if ( name == '' or name == 'nil' ) then return end;
	local preset = self:GetPresetByName(name)
	if preset then
		local merge, copy = db.table.merge, db.table.copy;
		local bindings = merge(db.Gamepad:GetBindingsTemplate(), copy(preset))
		for button, set in pairs(bindings) do
			for modifier, binding in pairs(set) do
				CPAPI.SetBinding(modifier..button, binding, false)
			end
		end
		SaveBindings(GetCurrentBindingSet())
		return CPAPI.Log('Loaded binding preset %s.', name)
	end
	local device = self:GetDeviceByName(name)
	if device then
		device:ApplyPresetBindings(GetCurrentBindingSet())
		return CPAPI.Log('Loaded binding preset %s.', name)
	end
	CPAPI.Log('No binding preset named %s exists.', name)
end

---------------------------------------------------------------
-- Events and callbacks
---------------------------------------------------------------

function Bindings:UPDATE_BINDINGS()
	-- Deferred a frame so override owners (e.g. the action bar)
	-- have reclaimed their combos before emulation resolves what
	-- each real button actually does.
	CPAPI.Next(db.RunSafe, db, self.OnEmulationChanged, self)
end

Bindings:RegisterEvent('UPDATE_BINDINGS')
Bindings:HookScript('OnAttributeChanged', Bindings.OnAttributeChanged)

db:RegisterSafeCallback('OnDataLoaded', Bindings.OnEmulationChanged, Bindings)
db:RegisterSafeCallback('OnDataLoaded', Bindings.OnConditionChanged, Bindings)
db:RegisterSafeCallback('Gamepad/Active', Bindings.OnEmulationChanged, Bindings)
db:RegisterSafeCallback('Settings/bindingPresetCondition', Bindings.OnConditionChanged, Bindings)
for _, button in ipairs(Bindings.Emulated) do
	db:RegisterSafeCallback('Settings/emulate'..button, Bindings.UpdateEmulation, Bindings, button)
end
