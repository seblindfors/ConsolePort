local _, db = ...;
local C_GamePad, GamepadMixin, GamepadAPI = C_GamePad, {}, CPAPI.CreateEventHandler({'Frame', '$parentGamePadHandler', ConsolePort}, {
	'UPDATE_BINDINGS';
	'GAME_PAD_CONFIGS_CHANGED';
	'PLAYER_ENTERING_WORLD';
	(CPAPI.IsRetailVersion or CPAPI.IsClassicVersion) and 'GAME_PAD_POWER_CHANGED';
}, {
	Modsims = {'ALT', 'CTRL', 'SHIFT'};
	Devices = {};
	Index = {
		Stick  = {
			ID      = {}; -- index -> config name
			Config  = {}; -- config name -> index
		};
		Button = {
			ID      = {}; -- index -> config name / binding
			Config  = {}; -- config name -> index / binding
			Binding = {}; -- binding -> config name / index
		};
		Modifier = {
			Key     = {}; -- modifier -> button
			Prefix  = {}; -- modifier string -> button
			Active  = {}; -- all possible modifier combinations
			Owner   = {}; -- button -> modifier string
			Driver  = ''; -- state driver for all active modifiers
		};
		Atlas = {
			['']    = {[32] = {}; [64] = {}}; -- Generic button labels
			SHP     = {[32] = {}; [64] = {}}; -- "Shapes" label style specializations
			LTR     = {[32] = {}; [64] = {}}; -- "Letters" label style specializations
			REV     = {[32] = {}; [64] = {}}; -- "Reverse" label style specializations
		};
	};
});
---------------------------------------------------------------
db:Register('Icons', {})
db:Register('Gamepad', GamepadAPI)
db:Save('Gamepad/Devices', 'ConsolePortDevices')

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function GamepadAPI:AddGamepad(data, mergeDefault)
	local defaultData = db.table.copy(self.Devices.Default)
	local gamepadData = mergeDefault and db.table.merge(defaultData, data) or data
	self.Devices[data.Name] = CPAPI.Proxy(gamepadData, GamepadMixin):OnLoad()
end

function GamepadAPI:GetDevices()
	local devices = {};
	for device in db.table.spairs(self.Devices) do
		devices[#devices + 1] = device;
	end
	return devices;
end

function GamepadAPI:EnumerateDevices()
	return db.table.spairs(GamepadAPI.Devices)
end

function GamepadAPI:SetActiveDevice(name)
	assert(self.Devices[name], ('Device %s does not exist in registry.'):format(name or '<nil>'))
	for device, data in pairs(self.Devices) do
		data.Active = nil;
	end
	local activeDevice = self.Devices[name]
	self:SetActiveIconsFromDevice(activeDevice)
	activeDevice:ApplyHotkeyStrings()
	db(('Gamepad/Devices/%s/Active'):format(name), true)
	db('Gamepad/Active', activeDevice)
	db:TriggerEvent('OnIconsChanged', db('useAtlasIcons'))
end

function GamepadAPI:SetActiveIconsFromDevice(device)
	local styler = CPAPI.Proxy({}, function(self, button)
		return device:GetIconForButton(button, self[0])
	end)
	CPAPI.Proxy(db('Icons'), function(_, style)
		styler[0] = style;
		return styler;
	end)
end

function GamepadAPI:GetActiveDevice()
	return self.Active;
end

function GamepadAPI:GetActiveDeviceName()
	return self.Active and self.Active.Name;
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function GamepadAPI:OnDataLoaded()
	-- TODO: remove if/when atlas icons get added to Classic Era.
	-- Added as a workaround for players importing settings from Retail.
	if CPAPI.IsClassicEraVersion and db('useAtlasIcons') then
		db('Settings/useAtlasIcons', false)
	end

	self:ReindexMappedState()
	self:ReindexIconAtlas()
	-- Load preset devices
	local presets = self.Devices;
	-- Load saved devices
	db:Load('Gamepad/Devices', 'ConsolePortDevices')
	for id, device in pairs(presets) do
		-- (1) fill in new presets that have been added,
		-- (2) overwrite existing if version has been bumped
		if  ( not self.Devices[id] or device.Version and
			( self.Devices[id].Version < device.Version )) then
			self.Devices[id] = device;
		end
	end
	for id, device in pairs(self.Devices) do
		CPAPI.Proxy(device, GamepadMixin):OnLoad()
		if device.Active then
			self:SetActiveDevice(id)
		end
	end
	if not self.Active then
		-- open the config, no active device found.
		ConsolePort()
	end
end

function GamepadAPI:PLAYER_ENTERING_WORLD()
	self.IsDispatchReady = true;
	self:QueueOnNewBindings()
end

function GamepadAPI:GAME_PAD_CONFIGS_CHANGED()
	CPAPI.Log('Your gamepad configuration has changed.')
end

function GamepadAPI:GAME_PAD_POWER_CHANGED(level)
	db:TriggerEvent('OnGamePadPowerChange', level)
end

function GamepadAPI:UPDATE_BINDINGS()
	if self.IsMapped and self.IsDispatchReady then
		self:QueueOnNewBindings()
	else
		self:OnNewBindings()
	end
end

-- UPDATE_BINDINGS - handle two different scenarios:
-- 1. just logged in, and bindings are dispatched immediately.
-- 2. logged in for a while, and bindings are dispatched with debouncing.
--
-- Why?
--
-- 1. runs unnecessarily since UPDATE_BINDINGS fires somewhere
-- around 5-10 times on login, but we need to configure action bars
-- immediately in case we're in combat, and we can't tell which event is
-- the one when gamepad bindings are ready to be dispatched without some
-- table inspection gymnastics, looking for a non-empty binding.
--
-- 2. we use debouncing to consolidate unnecessary update cycles, with the
-- added benefit of likely setting overrides _after_ a conflicting action
-- bar addon has already set its bindings. Yes, some people do actually
-- use multiple action bar addons at the same time. Isn't it crazy?

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------
db:RegisterSafeCallback('GamePadCursorLeftClick', function(self, value)
	db.table.map(SetBinding, self:GetBindingKey('CAMERAORSELECTORMOVE'))
	SetBinding(value, 'CAMERAORSELECTORMOVE')
	SaveBindings(GetCurrentBindingSet())
end, GamepadAPI)

db:RegisterSafeCallback('GamePadCursorRightClick', function(self, value)
	db.table.map(SetBinding, self:GetBindingKey('TURNORACTION'))
	SetBinding(value, 'TURNORACTION')
	SaveBindings(GetCurrentBindingSet())
end, GamepadAPI)

for _, modifier in ipairs(GamepadAPI.Modsims) do
	db:RegisterSafeCallback(('GamePadEmulate%s'):format(modifier:lower():gsub('^%l', strupper)),
	function(self, value)
		self:ReindexModifiers()
		-- Wipe the incompatible binding for a modifier when it's set.
		-- E.g. if you set ALT to PAD1, ALT-PAD1 will be removed.
		SetBinding(modifier..value, nil)
		SaveBindings(GetCurrentBindingSet())
		db:TriggerEvent('OnModifierChanged', modifier, value)
	end, GamepadAPI)
end

db:RegisterSafeCallback('GamePadStickAxisButtons', function(self, value)
	if not value then return end;
	for buttonID in pairs(self.Index.Button.Binding) do
		if not CPAPI.IsButtonValidForBinding(buttonID) then
			for modifier in pairs(self.Index.Modifier.Active) do
				SetBinding(modifier..buttonID, nil)
			end
		end
	end
	SaveBindings(GetCurrentBindingSet())
end, GamepadAPI)

db:RegisterSafeCallback('OnNewBindings', function(self)
	db:SetCVar('GamePadStickAxisButtons', db('bindingAllowSticks'))
	if ( self:GetBindingKey('INTERACTTARGET') and not GetCVarBool('SoftTargetInteract') ) then
		-- FIX: On Classic, the interact key is not enabled by default.
		-- If it's bound and disabled, enable it. 1 = GamePad, see Console.lua.
		db:SetCVar('SoftTargetInteract', 1)
	end
end, GamepadAPI)

db:RegisterCallback('Settings/useAtlasIcons', function(self, value)
	self.UseAtlasIcons = value;
	db:TriggerEvent('OnIconsChanged', value)
end, GamepadAPI)

---------------------------------------------------------------
-- Data: state
---------------------------------------------------------------
function GamepadAPI:GetState()
	return C_GamePad.GetDeviceMappedState(C_GamePad.GetActiveDeviceID())
end

function GamepadAPI:GetPowerLevel()
	return C_GamePad.GetPowerLevel(C_GamePad.GetActiveDeviceID())
end

function GamepadAPI:ReindexMappedState(force)
	if not C_GamePad.IsEnabled() then return end
	if not force and self.IsMapped then return end

	self:ReindexSticks()
	self:ReindexButtons()
	self:ReindexModifiers()
	self.IsMapped = true;
end

function GamepadAPI:ReindexButtons()
	local map = self.Index.Button;
	wipe(map.ID); wipe(map.Config); wipe(map.Binding);

	local i = 0;
	while true do
		local conf = C_GamePad.ButtonIndexToConfigName(i)
		local bind = C_GamePad.ButtonIndexToBinding(i)
		if not conf or not bind then break end;

		map.ID[i]         = {Config = conf; Binding = bind}
		map.Config[conf]  = {ID = i; Binding = bind}
		map.Binding[bind] = {ID = i; Config = conf}
		i = i + 1;
	end
end

function GamepadAPI:ReindexSticks()
	local map = self.Index.Stick;
	wipe(map.ID); wipe(map.Config);

	local i = 0;
	while true do
		local name = C_GamePad.StickIndexToConfigName(i)
		if not name then break end;

		map.ID[i+1] = name
		map.Config[name] = i+1
		i = i + 1;
	end
end

function GamepadAPI:ReindexModifiers()
	local map = self.Index.Modifier;
	wipe(map.Key); wipe(map.Prefix); wipe(map.Owner);

	for _, mod in ipairs(self.Modsims) do
		local btn = GetCVar('GamePadEmulate'..mod)
		if (btn and btn:match('PAD')) then
			self.Index.Modifier.Key[mod] = btn -- BUG: uproots the mod order if uppercase
			self.Index.Modifier.Key[mod:upper()] = btn
			self.Index.Modifier.Prefix[mod..'-'] = btn
			self.Index.Modifier.Owner[btn] = mod..'-';
		end
	end
	map.Active, map.Driver = self:GetActiveModifiers()
end

function GamepadAPI:GetActiveModifiers()
	local mods = db.table.copy(self.Index.Modifier.Prefix)
	local driver = {'[nomod] '};
	local spairs = db.table.spairs; -- need to scan in-order

	local function assertUniqueAndInOrder(...)
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

	for M1, K1 in spairs(mods) do
		for M2, K2 in spairs(mods) do
			for M3, K3 in spairs(mods) do
				if (assertUniqueAndInOrder(M1, M2, M3)) then
					local modifier = M1..M2..M3;
					mods[modifier] = ('%s-%s-%s'):format(K1, K2, K3)
					tinsert(driver, ('[mod:%s] %s'):format(modifier, modifier))
				end
			end
			if (assertUniqueAndInOrder(M1, M2)) then
				local modifier = M1..M2;
				mods[modifier] = ('%s-%s'):format(K1, K2)
				tinsert(driver, ('[mod:%s] %s'):format(modifier, modifier))
			end
		end
		tinsert(driver, ('[mod:%s] %s'):format(M1, M1))
	end
	mods[''] = true
	return mods, table.concat(driver, '; ');
end


function GamepadAPI:GetActiveModifier(button)
	for _, mod in ipairs(self.Modsims) do
		if (GetCVar('GamePadEmulate'..mod) == button) then
			return mod;
		end
	end
end

---------------------------------------------------------------
-- Data: bindings
---------------------------------------------------------------
function GamepadAPI:GetModifiersHeld()
	-- NOTE: uses input state instead of Blizzard API,
	-- to get reliable results in things like click wrappers,
	-- which otherwise sandbox the modifier while executing.
	local cmp = {};
	for i, mod in ipairs(self.Modsims) do
		local buttonID = GetCVar('GamePadEmulate'..mod)
		if (buttonID and buttonID ~= 'none') then
			cmp[buttonID] = mod;
		end
	end

	local result = {};
	local state = self:GetState()
	if not state or not state.buttons then return result end

	for id, down in ipairs(state.buttons) do
		if down then
			local binding = C_GamePad.ButtonIndexToBinding(id-1)
			local mod = cmp[binding];
			if mod then
				result[mod] = binding;
			end
		end
	end
	return result;
end

function GamepadAPI:GetModifierHeld(modifier)
	return modifier and self:GetModifiersHeld()[modifier] ~= nil;
end

function GamepadAPI:GetBindings(getInactive)
	local btns = self.Index.Button.Binding;
	local mods = self.Index.Modifier.Active;

	local bindings = {}
	for btn in pairs(btns) do
		for mod in pairs(mods) do
			local binding = GetBindingAction(mod..btn)
			if getInactive or binding:len() > 0 then
				bindings[btn] = bindings[btn] or {};
				bindings[btn][mod] = binding;
			end
		end
	end
	return bindings;
end

function GamepadAPI:GetBindingKey(binding, asTable)
	local keys = tFilter({GetBindingKey(binding, true)}, IsBindingForGamePad, true)
	if asTable then return keys end;
	return unpack(keys)
end

function GamepadAPI:EnumerateBindingKeys(binding)
	local keys = self:GetBindingKey(binding, true)
	local i = 0;
	return function()
		i = i + 1;
		return keys[i];
	end
end

function GamepadAPI:OnNewBindings()
	local newBindings = self:GetBindings(true)
	db:TriggerEvent('OnNewBindings', newBindings)
	db:TriggerEvent('OnUpdateOverrides', false, newBindings)
	db:TriggerEvent('OnUpdateOverrides', true,  newBindings)
end

GamepadAPI.QueueOnNewBindings = CPAPI.Debounce(GamepadAPI.OnNewBindings, GamepadAPI)

---------------------------------------------------------------
-- Data: icons
---------------------------------------------------------------
function GamepadAPI:ReindexIconAtlas()
	self.UseAtlasIcons = db('useAtlasIcons')

	local function getAtlasFromGlobalEscSeq(modifier, button, style)
		local globalKey = ('KEY_%s%s_%s'):format(modifier, button, style):gsub('_$', '')
		local atlasEscSeq = _G[globalKey]
		if not atlasEscSeq then return end
		return atlasEscSeq:gsub('|A:([%w_]+)(.+)', '%1')
	end

	-- Do indexing of the different styles
	for style, sizes in pairs(self.Index.Atlas) do --SHP,
		for size, icons in pairs(sizes) do -- 32,64
			local modifier = (size == 32) and 'ABBR_' or '';
			for button in pairs(self.Index.Button.Binding) do
				icons[button] = getAtlasFromGlobalEscSeq(modifier, button, style)
			end
		end
	end

	-- Proxy the other styles to fallback on generic
	for style, sizes in pairs(self.Index.Atlas) do
		if (style ~= '') then
			for size, icons in pairs(sizes) do
				CPAPI.Proxy(icons, self.Index.Atlas[''][size])
			end
		end
	end
end

function GamepadAPI:GetIconPath(path, style)
	return self.Index.Icons.Path:format(style or 64, path)
end

function GamepadAPI.SetIconToTexture(obj, iconID, style, iconSize, atlasSize)
	if not iconID then return obj:SetTexture(nil) end;
	local icon = db(('Icons/%s/%s'):format(style or 64, iconID))
	if ( type(icon) == 'string' ) then
		CPAPI.SetTextureOrAtlas(obj, {icon, GamepadAPI.UseAtlasIcons}, iconSize, atlasSize)
		return true;
	end
	return false;
end

---------------------------------------------------------------
-- Gamepad Mixin
---------------------------------------------------------------
function GamepadMixin:OnLoad(data)
	self.Icons = CPAPI.Proxy({}, function(_, id)
		local id, style = strsplit('-', id)
		return style and self:GetIconForButton(id, style) or self:GetIconIDForButton(id)
	end)
	return self
end

function GamepadMixin:Activate()
	GamepadAPI:ReindexMappedState(true)
	GamepadAPI:SetActiveDevice(self.Name)
end

function GamepadMixin:ApplyPresetVars()
	assert(self.Preset.Variables, ('Console variables missing from %s template.'):format(self.Name))
	for var, val in pairs(self.Preset.Variables) do
		db:SetCVar(var, val)
	end
	self:Activate()
end

function GamepadMixin:ConfigHasBluetoothHandling()
	if self.Config then
		for set, array in pairs(self.Config) do
			if (type(array) == 'table') then
				for i, data in ipairs(array) do
					if (data.bluetooth ~= nil) then
						return true;
					end
				end
			end
		end
	end
end

function GamepadMixin:ApplyConfig(bluetooth)
	assert(self.Config, ('Raw configuration missing from %s template.'):format(self.Name))
	local config = CopyTable(self.Config);
	-- NOTE: Handle bluetooth differences if supplied
	if (bluetooth ~= nil) then
		for set, array in pairs(config) do
			if (type(array) == 'table') then
				local i, data = 1, array[1];
				while data do
					-- If the configured input has a bluetooth-specific value:
					-- confirm it corresponds to the desired gamepad mapping,
					-- otherwise junk it.
					if (data.bluetooth ~= nil and data.bluetooth ~= bluetooth) then
						tremove(array, i)
						i = i - 1;
					end
					i = i + 1; data = array[i];
				end
			end
		end
	end
	C_GamePad.SetConfig(config)
	C_GamePad.ApplyConfigs()
end

function GamepadMixin:ApplyPresetBindings(setID)
	assert(self.Preset.Bindings, ('Preset bindings missing from %s template.'):format(self.Name))
	local clearOverlap, map = not db('bindingOverlapEnable'), db.table.map;

	for btn, set in pairs(self.Preset.Bindings) do
		for mod, binding in pairs(set) do
			if clearOverlap then
				map(SetBinding, GamepadAPI:GetBindingKey(binding))
			end
			SetBinding(mod..btn, binding)
		end
	end
	if setID then
		SaveBindings(setID)
	end
end

function GamepadMixin:ApplyHotkeyStrings()
	local label, hotkey = self.Theme.Label;
	assert(label, ('Gamepad device %s does not have a button label type.'):format(self.Name))
	for button in pairs(self.Theme.Icons) do
		hotkey = self:GetHotkeyStringForButton(button)
		_G[('KEY_ABBR_%s'):format(button)] = hotkey;
		_G[('KEY_ABBR_%s_%s'):format(button, label)] = hotkey;
	end
end

function GamepadMixin:IsButtonValidForBinding(button)
	return not GamepadAPI:GetActiveModifier(button) and self.Theme.Icons[button]
end

---------------------------------------------------------------
-- Icon queries
---------------------------------------------------------------
function GamepadMixin:GetIconAtlasForButton(button, style)
	return db(('Gamepad/Index/Atlas/%s/%s/%s'):format(self.Theme.Label, style or 64, button)),
		GamepadAPI.UseAtlasIcons;
end

function GamepadMixin:GetIconIDForButton(button)
	assert(button, 'Button is not defined.')
	return self.Theme.Icons[button]
end

function GamepadMixin:GetIconForButton(button, style)
	local atlas, useAtlasIcon = self:GetIconAtlasForButton(button, style)
	if atlas and useAtlasIcon then
		return atlas, true;
	end
	local iconID = self:GetIconIDForButton(button)
	if iconID then
		return GamepadAPI:GetIconPath(db(('Gamepad/Index/Icons/%s'):format(iconID)), style)
	end
	if atlas then
		return atlas, true;
	end
	return GamepadAPI:GetIconPath('ALL_MISSING', style)
end

function GamepadMixin:GetTooltipButtonPrompt(button, prompt, style)
	local color = self.Theme.Colors[button] or 'FFFFFF';
	local icon, isAtlas = self:GetIconForButton(button, style)
	if icon and isAtlas then
		return ('|A:%s:24:24|a |cFF%s%s|r'):format(icon, color, prompt)
	elseif icon then
		return ('|T%s:24:24:0:0|t |cFF%s%s|r'):format(icon, color, prompt)
	end
end

function GamepadMixin:GetHotkeyStringForButton(button)
	local icon, isAtlas = self:GetIconForButton(button, 32)
	if icon and isAtlas then
		return ('|A:%s:14:14|a'):format(icon)
	elseif icon then
		return ('|T%s:0:0:0:0:32:32:8:24:8:24|t'):format(icon)
	end
end

function GamepadMixin:GetIconForName(name, style)
	return self:GetIconForButton(db(('Gamepad/Index/Button/Config/%s/Binding'):format(name)))
end

function GamepadMixin:GetIconIDForName(name)
	return self:GetIconIDForButton(db(('Gamepad/Index/Button/Config/%s/Binding'):format(name)))
end

function GamepadMixin:GetIconForIndex(i, style)
	return self:GetIconForButton(db(('Gamepad/Index/Button/ID/%d/Binding'):format(i)))
end

function GamepadMixin:GetIconIDForIndex(i)
	return self:GetIconIDForButton(db(('Gamepad/Index/Button/ID/%d/Binding'):format(i)))
end