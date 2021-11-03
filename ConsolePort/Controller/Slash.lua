local _, db = ...;
local HELP_STRING, SLASH_FUNCTIONS = 'Usage: |cFFFFFFFF/consoleport|r |cFF00FFFF%s|r |cFF00FF00%s|r';
local DOCU_STRING = '  |cFF00FFFF%s|r |cFF00FF00%s|r \n- |cFFFFFFFF%s|r';
local CONFIG_ADDON_NAME = 'ConsolePort_Config';
---------------------------------------------------------------
-- Process slash command
---------------------------------------------------------------
local function ProcessSlash(command, ...)
	local func = SLASH_FUNCTIONS[command];
	if func then
		func(...)
		return true
	end
end

local function Compile(...)
	local args = table.concat({...}, ' ')
	local func, errorMsg = loadstring(('return %s'):format(args))
	if not func then
		CPAPI.Log('Error while compiling:\n%s', errorMsg)
		return
	end
	return func()
end

local function ProcessVarUpdate(var, ...)
	if (db(var) ~= nil) then
		local value = Compile(...)
		if (value == nil) then
			return true;
		end
		if (args == 'nil') then
			db('Settings/'..var, nil)
			CPAPI.Log('Variable |cFFFFFFFF%s|r reset to default.')
			return true;
		elseif (value ~= nil) then
			db('Settings/'..var, value)
			CPAPI.Log('Variable |cFFFFFFFF%s|r updated to:', var)
			DevTools_Dump(value)
			return true;
		end
	end
end

local function HandleSlashCommand(self, msg)
	if ProcessSlash((' '):split(msg or '')) then
		return
	elseif ProcessVarUpdate((' '):split(msg or '')) then
		return
	end
	if not IsAddOnLoaded(CONFIG_ADDON_NAME) then
		EnableAddOn(CONFIG_ADDON_NAME)
		LoadAddOn(CONFIG_ADDON_NAME)
	end
	ConsolePortConfig:SetShown(not ConsolePortConfig:IsShown())
end

local function Uninstall()
	for _, var in ipairs({
		-- Saved variables
		'ConsolePortSettings',
		'ConsolePortDevices',
		'ConsolePortUIStack',
		'ConsolePortShared',
		-- Saved variables per character
		'ConsolePortUtility',
		'ConsolePort_BarSetup',
	}) do _G[var] = nil; end
	ReloadUI()
end

function ClearPadBindings()
	local function ClearPadBinding(binding, key, ...)
		if key then
			if IsBindingForGamePad(key) then
				SetBinding(key, nil)
			end
			ClearPadBinding(binding, ...)
		end
	end

	for i=1, GetNumBindings() do
		ClearPadBinding(GetBinding(i))
	end
end

---------------------------------------------------------------
-- Slash functions
---------------------------------------------------------------
SLASH_FUNCTIONS = {
	-----------------------------------------------------------
	-- Stack handling
	-----------------------------------------------------------
	addframe = function(owner, frame)
		if owner and frame then
			local loadable, reason = select(4, GetAddOnInfo(owner))
			if loadable then
				local stack = db.Stack;
				if stack:TryRegisterFrame(owner, frame, true) then
					stack:AddFrame(frame)
					stack:UpdateFrames()
					return CPAPI.Log('Frame %s was added under %s.', frame, owner)
				end
			else
				return CPAPI.Log('Addon %s is not eligble. Reason: %s', owner, _G['ADDON_'..reason])
			end
		end
		CPAPI.Log(HELP_STRING, 'addframe', 'addonName frameName')
	end;
	removeframe = function(owner, frame)
		if owner and frame then
			local loadable, reason = select(4, GetAddOnInfo(owner))
			if loadable then
				local stack = db.Stack;
				if stack:TryRemoveFrame(owner, frame) then
					stack:RemoveFrame(_G[frame])
					stack:UpdateFrames()
					return CPAPI.Log('Frame %s was removed from %s.', frame, owner)
				end
			else
				return CPAPI.Log('Addon is not eligble. Reason: %s', reason)
			end
		end
		CPAPI.Log(HELP_STRING, 'removeframe', 'addonName frameName')
	end;
	-----------------------------------------------------------
	-- Config
	-----------------------------------------------------------
	applyconfig = function(useBluetooth)
		local bluetooth = useBluetooth and Compile(useBluetooth)
		local device = db('Gamepad/Active')
		if device then
			device:ApplyConfig(bluetooth)
			CPAPI.Log('Config was applied for your %s device.', device.Name)
		end
	end;
	bluetooth = function(state)
		if state then
			local bluetooth = state and Compile(state)
			local device = db('Gamepad/Active')
			if device then
				device:ApplyConfig(bluetooth)
				return CPAPI.Log('Bluetooth set to %s for %s.', state, device.Name)
			end
		end
		CPAPI.Log(HELP_STRING, 'bluetooth', 'true/false')
	end;
	config = function(path, value)
		if not path and not value then
			return CPAPI.Log(HELP_STRING, 'config', 'path/to/key [value]')
		end

		local config = db('Gamepad/Active/Config')
		if not config then return CPAPI.Log('No active config found.') end

		if not value then
			value = db('Gamepad/Active/Config/'..path)
			if value then
				CPAPI.Log('Value found for %s:', path)
				DevTools_Dump(value)
			else
				CPAPI.Log('Value not found for %s.', path)
			end
			return
		end

		local newstate = Compile(value)
		local __mt, __index = {};
		function __index(t, k)
			local v = setmetatable({}, __mt)
			rawset(t, k, v)
			return v;
		end
		__mt.__index = __index;

		setmetatable(config, __mt)
		if db('Gamepad/Active/Config/'..path, newstate) then
			db('Gamepad/Active'):ApplyConfig()
			return CPAPI.Log('Value %s set at %s.', tostring(newstate), path)
		end
	end;
	status = function(deviceID)
		local activeDevices = {};
		for _, i in ipairs(C_GamePad.GetAllDeviceIDs()) do
			local device = C_GamePad.GetDeviceRawState(i)
			if device then
				tinsert(activeDevices, {
					id    = i;
					state = device;
				})
			end
		end
		if next(activeDevices) then
			CPAPI.Log('Connected devices:')
			for _, device in ipairs(activeDevices) do
				local vendorID  = ('%04x'):format(device.state.vendorID):upper();
				local productID = ('%04x'):format(device.state.productID):upper();
				local config = C_GamePad.GetConfig({
					vendorID  = device.state.vendorID;
					productID = device.state.productID;
				});

				CPAPI.Log('%d: |cFFFFFFFF%s|r', device.id, device.state.name)
				CPAPI.Log('   Vendor: |cFF00FFFF%s|r, Product: |cFF00FFFF%s|r, Config: %s',
					vendorID, productID,
					config and ('|cFF00FF00%s|r'):format(config.name or 'custom') or '|cFFFFFFFFgeneric|r'
				);
			end
		else
			CPAPI.Log('No connected devices found.')
		end
	end;
	-----------------------------------------------------------
	-- Reset/uninstall
	-----------------------------------------------------------
	clearbindings = function()
		ClearPadBindings()
		ReloadUI()
	end;
	resetall = function()
		CPAPI.Popup('ConsolePort_Uninstall_Settings', {
			text = 'This action will remove all your saved settings and reload your interface.';
			button1 = OKAY;
			button2 = CANCEL;
			timeout = 0;
			whileDead = 1;
			showAlert = 1;
			OnAccept = Uninstall;
		})
	end;
	resetconfigs = function()
		for i, config in ipairs(C_GamePad.GetAllConfigIDs()) do
			C_GamePad.DeleteConfig(config)
		end
		C_GamePad.ApplyConfigs()
		ReloadUI()
	end;
	uninstall = function()
		CPAPI.Popup('ConsolePort_Uninstall_Addon', {
			text = 'This action will remove all your saved settings and reload your interface.';
			button1 = OKAY;
			button2 = CANCEL;
			timeout = 0;
			whileDead = 1;
			showAlert = 1;
			OnAccept = function()
				DisableAddOn('ConsolePort')
				SetCVar('GamePadEnable', 0)
				ClearPadBindings()
				Uninstall()
			end;
		})
	end;
	-----------------------------------------------------------
	-- Help
	-----------------------------------------------------------
	help = function(command)
		local commands = {
			{'<empty>', '',
				'Open configuration interface.'};
			{'addframe', 'addonName frameName',
				'Add a custom frame to cursor stack.'};
			{'removeframe', 'addonName frameName',
				'Remove a frame from cursor stack.'};
			{'applyconfig', 'useBluetooth',
				'Apply config for the active device.'};
			{'bluetooth', 'true/false',
				'Change bluetooth state for active device.'};
			{'config', 'path/to/key [value]',
				'Change or print a value from the active device configuration.'};
			{'status', '[deviceID]',
				'Show connected devices.'};
			{'clearbindings', '',
				'Clear configured gamepad bindings and reload interface.'};
			{'resetall', '',
				'Remove all saved settings and reload interface.'};
			{'resetconfigs', '',
				'Reset all mapping configurations and reload. (will not affect bindings)'};
			{'uninstall', '',
				'Remove all saved settings and bindings, disable addon, and reload interface.'};
		}
		if not command then
			CPAPI.Log(HELP_STRING, 'command', '[args]')
			for i, command in ipairs(commands) do
				CPAPI.Log(DOCU_STRING, unpack(command))
			end
		end
	end;
}

---------------------------------------------------------------
-- Set up slash handler
---------------------------------------------------------------
setmetatable(ConsolePort, {
	__index = getmetatable(ConsolePort).__index;
	__call  = HandleSlashCommand;
})

_G['SLASH_' .. _:upper() .. '1'] = '/' .. _:lower()
_G['SLASH_' .. _:upper() .. '2'] = '/cp'
SlashCmdList[_:upper()] = ConsolePort;

---------------------------------------------------------------
-- Temp?: add a game menu button to access config
---------------------------------------------------------------
LibStub('Carpenter'):BuildFrame(GameMenuFrame, {
	[_] = {
		_Type  = 'Button';
		_Setup = 'InsecureActionButtonTemplate';
		_Size  = {58, 58};
		_Point = {'TOP', 0, 70};
		_Macro = '/click GameMenuButtonContinue\n/consoleport';
		_OnLoad = function(self)
			self:SetNormalTexture(CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]))
			self:SetPushedTexture(CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]))
			local pushed = self:GetPushedTexture()
			pushed:ClearAllPoints()
			pushed:SetSize(self:GetSize())
			pushed:SetPoint('CENTER', 0, -2)
			-- Protect against ElvUI shenanigans
			self.SetNormalTexture = nop;
			self.SetPushedTexture = nop;
			self.GetNormalTexture = nop;
			self.GetPushedTexture = nop;
		end;
	};
})