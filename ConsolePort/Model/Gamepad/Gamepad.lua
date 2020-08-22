local _, db = ...;
local GamepadMixin, GamepadAPI = {}, CPAPI.CreateEventHandler({'Frame', 'ConsolePortGamePadHandler'}, {
	'GAME_PAD_CONFIGS_CHANGED';
	'GAME_PAD_CONNECTED';
	'GAME_PAD_DISCONNECTED';
});
---------------------------------------------------------------
GamepadAPI.Devices = {}; GamepadAPI.Index = {Buttons = {}};
---------------------------------------------------------------
db:Register('Gamepad', GamepadAPI)
db:Save('Gamepad/Devices', 'ConsolePortDevices')
---------------------------------------------------------------

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function GamepadAPI:GAME_PAD_CONFIGS_CHANGED()
	print('GAME_PAD_CONFIGS_CHANGED')
	for device in pairs(self.Devices) do
	--	device:UpdateConfig()
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
	db:Load('Gamepad/Devices', 'ConsolePortDevices')
	for id, device in pairs(self.Devices) do
		Mixin(device, GamepadMixin):OnLoad()
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
	self.Devices[data.Name] = CreateFromMixins(GamepadMixin, gamepadData):OnLoad()
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
	db('Gamepad/Active', name)
end

---------------------------------------------------------------
-- Data
---------------------------------------------------------------
function GamepadAPI:ReindexMappedState()
	local state = C_GamePad.GetDeviceMappedState(C_GamePad.GetActiveDeviceID())
	local map = wipe(self.Index.Buttons)

	map.ID = {}; map.Config = {}; map.Binding = {};

	for i in ipairs(state.buttons) do
		local conf = C_GamePad.ButtonIndexToConfigName(i-1)
		local bind = C_GamePad.ButtonIndexToBinding(i-1)

		map.ID[i-1]       = {Config = conf; Binding = bind}
		map.Config[conf]  = {ID = i-1; Binding = bind}
		map.Binding[bind] = {ID = i-1; Config = conf}
	end
end

function GamepadAPI:GetIconPath(path, style)
	return self.Index.Icons.Path:format(style or 64, path)
end

---------------------------------------------------------------
-- Gamepad Mixin
---------------------------------------------------------------
function GamepadMixin:OnLoad(data)
	self:UpdateConfig()
	return self
end

function GamepadMixin:UpdateConfig()

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
	return db(('Gamepad/Devices/%s/Theme/Icons/%s'):format(self.Name, binding))
end

function GamepadMixin:GetIconForName(name, style)
	return self:GetIconForBinding(db(('Gamepad/Index/Buttons/Config/%s/Binding'):format(name)))
end

function GamepadMixin:GetIconIDForName(name)
	return self:GetIconIDForBinding(db(('Gamepad/Index/Buttons/Config/%s/Binding'):format(name)))
end

function GamepadMixin:GetIconForIndex(i, style)
	return self:GetIconForBinding(db(('Gamepad/Index/Buttons/ID/%d/Binding'):format(i)))
end

function GamepadMixin:GetIconIDForIndex(i)
	return self:GetIconIDForBinding(db(('Gamepad/Index/Buttons/ID/%d/Binding'):format(i)))
end