local _, db = ...;
local GamepadMixin, GamepadAPI = {}, CPAPI.CreateEventHandler({'Frame', '$parentGamePadHandler', ConsolePort}, {
	'GAME_PAD_CONFIGS_CHANGED';
	'GAME_PAD_CONNECTED';
	'GAME_PAD_DISCONNECTED';
}, {
	Devices = {};
	Index = {
		Stick  = {};
		Button = {};
		Modifier = {};
	};
});
---------------------------------------------------------------
db:Register('Gamepad', GamepadAPI)
db:Save('Gamepad/Devices', 'ConsolePortDevices')

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function GamepadAPI:GAME_PAD_CONFIGS_CHANGED()
	print('GAME_PAD_CONFIGS_CHANGED')
	for device in pairs(self.Devices) do
	--	TODO: handle this somehow, device:UpdateConfig()
	end
end

function GamepadAPI:GAME_PAD_CONNECTED()
	print('GAME_PAD_CONNECTED')
end

function GamepadAPI:GAME_PAD_DISCONNECTED()
	print('GAME_PAD_DISCONNECTED')
end

function GamepadAPI:OnDataLoaded()
	self:ReindexMappedState()
	local old = self.Devices
	db:Load('Gamepad/Devices', 'ConsolePortDevices')
	for id, device in pairs(old) do
		if not self.Devices[id] then
			self.Devices[id] = device
		end
	end
	for id, device in pairs(self.Devices) do
		CPAPI.Proxy(device, GamepadMixin):OnLoad()
		if device.Active then
			self:SetActiveDevice(id)
		end
	end
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function GamepadAPI:AddGamepad(data, skipDefault)
	local defaultData = db('table/copy')(self.Devices.Default)
	local gamepadData = skipDefault and data or db('table/merge')(defaultData, data)
	self.Devices[data.Name] = CPAPI.Proxy(gamepadData, GamepadMixin):OnLoad()
end

function GamepadAPI:CreateGamepadFromPreset(name, preset)
	assert(self.Devices[preset], 'Preset ID does not exist in registry.')
	-- TODO: allow copies of presets
end

function GamepadAPI:GetDevices()
	local devices = {}
	for device in db('table/spairs')(self.Devices) do
		devices[#devices + 1] = device
	end
	return devices
end

function GamepadAPI:EnumerateDevices()
	return db('table/spairs')(GamepadAPI.Devices)
end

function GamepadAPI:SetActiveDevice(name)
	assert(self.Devices[name], ('Device %s does not exist in registry.'):format(name or '<nil>'))
	for device, data in pairs(self.Devices) do
		data.Active = nil
	end
	db(('Gamepad/Devices/%s/Active'):format(name), true)
	db('Gamepad/Active', self.Devices[name])
end

function GamepadAPI:GetActiveDevice()
	return self.Active
end

---------------------------------------------------------------
-- Data
---------------------------------------------------------------
function GamepadAPI:ReindexMappedState()
	local state = C_GamePad.GetDeviceMappedState(C_GamePad.GetActiveDeviceID())
	-- buttons
	local map = wipe(self.Index.Button)
	map.ID = {}; map.Config = {}; map.Binding = {};

	for i in ipairs(state.buttons) do
		local conf = C_GamePad.ButtonIndexToConfigName(i-1)
		local bind = C_GamePad.ButtonIndexToBinding(i-1)

		map.ID[i-1]       = {Config = conf; Binding = bind}
		map.Config[conf]  = {ID = i-1; Binding = bind}
		map.Binding[bind] = {ID = i-1; Config = conf}
	end
	-- modifiers
	map = wipe(self.Index.Modifier)
	map.Key = {}; map.Prefix = {};
	for _, mod in ipairs({'Shift', 'Ctrl', 'Alt'}) do
		local btn = GetCVar('GamePadEmulate'..mod)
		if (btn and btn:match('PAD')) then
			self.Index.Modifier.Key[mod] = btn
			self.Index.Modifier.Prefix[mod..'-'] = btn
		end
	end
	map.Active = self:GetActiveModifiers()
	-- sticks
	map = wipe(self.Index.Stick)
	map.ID = {}; map.Config = {};
	for i in ipairs(state.sticks) do
		local name = C_GamePad.StickIndexToConfigName(i-1)
		map.ID[i] = name
		map.Config[name] = i
	end
end

function GamepadAPI:GetActiveModifiers()
	local mods = db('table/copy')(self.Index.Modifier.Prefix)
	local spairs = db('table/spairs') -- need to scan in-order

	local function assertUniqueOrder(...)
		local uniques = {}
		for i=1, select('#', ...) do
			local v1 = select(i, ...)
			if uniques[v1] then return end
			uniques[v1] = true
			for v2 in pairs(uniques) do
				if v2 > v1 then return end
			end
		end
		return true
	end

	for M1 in spairs(mods) do
		for M2 in spairs(mods) do
			for M3 in spairs(mods) do
				if (assertUniqueOrder(M1, M2, M3)) then
					mods[M1..M2..M3] = true
				end
			end
			if (assertUniqueOrder(M1, M2)) then
				mods[M1..M2] = true
			end
		end
	end
	mods[''] = true
	return mods
end

function GamepadAPI:GetBindings()
	local btns = self.Index.Button.Binding
	local mods = self.Index.Modifier.Active
	assert(btns, 'Active bindings have not been indexed.')
	assert(mods, 'Active modifiers have not been indexed.')

	local bindings = {}
	for btn in pairs(btns) do
		for mod in pairs(mods) do
			local binding = GetBindingAction(mod..btn)
			if binding:len() > 0 then
				bindings[btn] = bindings[btn] or {}
				bindings[btn][mod] = binding
			end
		end
	end
	return bindings
end

function GamepadAPI:GetBindingKey(binding)
	return unpack(tFilter({GetBindingKey(binding)}, function(x)
		return x:match 'PAD' and not x:match 'NUM'
	end, true))
end

function GamepadAPI:GetIconPath(path, style)
	return self.Index.Icons.Path:format(style or 64, path)
end

---------------------------------------------------------------
-- Gamepad Mixin
---------------------------------------------------------------
function GamepadMixin:OnLoad(data)
	self.Icons = CPAPI.Proxy({}, function(_, id)
		local id, style = strsplit('-', id)
		return style and self:GetIconForBinding(id, style) or self:GetIconIDForBinding(id)
	end)

	self:UpdateConfig()
	return self
end

function GamepadMixin:UpdateConfig()

end

function GamepadMixin:ApplyPresetVars()
	assert(self.Preset.Variables, ('Console variables missing from %s template.'):format(self.Name))
	for var, val in pairs(self.Preset.Variables) do
		SetCVar('Gamepad'..var, val)
	end
end

function GamepadMixin:ApplyPresetBindings(setID)
	assert(self.Preset.Bindings, ('Preset bindings missing from %s template.'):format(self.Name))
	for btn, set in pairs(self.Preset.Bindings) do
		for mod, binding in pairs(set) do
			SetBinding(mod..btn, binding)
		end
	end
	if setID then
		SaveBindings(setID)
	end
end

---------------------------------------------------------------
-- Icon queries
---------------------------------------------------------------
function GamepadMixin:GetIconForBinding(binding, style)
	assert(binding, 'Binding is not defined.')
	return GamepadAPI:GetIconPath(db(('Gamepad/Index/Icons/%s'):format(self:GetIconIDForBinding(binding))), style)
end

function GamepadMixin:GetIconIDForBinding(binding)
	assert(binding, 'Binding is not defined.')
	return self.Theme.Icons[binding]
end

function GamepadMixin:GetIconForName(name, style)
	return self:GetIconForBinding(db(('Gamepad/Index/Button/Config/%s/Binding'):format(name)))
end

function GamepadMixin:GetIconIDForName(name)
	return self:GetIconIDForBinding(db(('Gamepad/Index/Button/Config/%s/Binding'):format(name)))
end

function GamepadMixin:GetIconForIndex(i, style)
	return self:GetIconForBinding(db(('Gamepad/Index/Button/ID/%d/Binding'):format(i)))
end

function GamepadMixin:GetIconIDForIndex(i)
	return self:GetIconIDForBinding(db(('Gamepad/Index/Button/ID/%d/Binding'):format(i)))
end