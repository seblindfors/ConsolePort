local _, db = ...;
local HELP_STRING, SLASH_FUNCTIONS = 'Usage: |cFFFFFFFF/consoleport|r |cFF00FFFF%s|r |cFF00FF00%s|r';
local DOCU_STRING = '  |cFF00FFFF%s|r |cFF00FF00%s|r \n- |cFFFFFFFF%s|r';
local CONFIG_ADDON_NAME = 'ConsolePort_Config';
local CURSOR_ADDON_NAME = 'ConsolePort_Cursor';
---------------------------------------------------------------
-- Process slash command
---------------------------------------------------------------
local function ProcessSlash(command, ...)
	local data = SLASH_FUNCTIONS[command];
	if data then
		if ( data[1](...) == false ) then
			SLASH_FUNCTIONS.help[1](command)
		end
		return true;
	end
end

local function Compile(...)
	local args = table.concat({...}, ', ')
	local func, errorMsg = loadstring(('return %s'):format(args))
	if not func then
		CPAPI.Log('Error while compiling:\n%s', errorMsg)
		return
	end
	return func(), args;
end

local function ProcessVarUpdate(var, ...)
	if (db(var) ~= nil) then
		local value, args = Compile(...)
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
	local args = {(' '):split(msg or '')};
	if ProcessSlash(unpack(args)) then
		return
	elseif ProcessVarUpdate(unpack(args)) then
		return
	elseif ( #args > 0 and args[1]:trim():len() > 0 ) then
		CPAPI.Log('Unknown command |cFF00FFFF%s|r.', args[1])
		SLASH_FUNCTIONS.help[1]()
		return true;
	end
	if not CPAPI.IsAddOnLoaded(CONFIG_ADDON_NAME) then
		CPAPI.EnableAddOn(CONFIG_ADDON_NAME)
		CPAPI.LoadAddOn(CONFIG_ADDON_NAME)
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
		'ConsolePort_BarDB',
		'ConsolePort_BarLayout',
		'ConsolePort_BarSetup', -- legacy
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
	frame = {
		desc  = 'Add, remove or reset a frame from cursor stack.';
		usage = {
			{'add||remove||reset', 'string', 'Action to perform on the frame.'};
			{'frameName', 'string', 'Name of the frame to add, remove or reset.'};
			{'[addonName]', 'string', 'Optional name of the addon that owns the frame.'};
		};
		function(action, frame, owner)
			if not owner then owner = CURSOR_ADDON_NAME end;
			if action and frame then
				local loadable, reason = select(4, CPAPI.GetAddOnInfo(owner))
				if loadable or CPAPI.IsAddOnLoaded(owner) then
					CPAPI.EnableAddOn(CURSOR_ADDON_NAME)
					CPAPI.LoadAddOn(CURSOR_ADDON_NAME)
					return EventUtil.ContinueOnAddOnLoaded(CURSOR_ADDON_NAME, function()
						local stack = db.Stack;
						if ( action == 'add' ) then
							if stack:TryRegisterFrame(owner, frame, true) then
								if stack:AddFrame(frame) then
									stack:UpdateFrames()
									return CPAPI.Log('Frame %s was added under %s.', frame, owner)
								end
								return CPAPI.Log('Frame %s was registered to %s, but does not exist yet.', frame, owner)
							end
						elseif ( action == 'remove' ) then
							if stack:TryUnregisterFrame(owner, frame) then
								stack:RemoveFrame(frame)
								stack:UpdateFrames()
								return CPAPI.Log('Frame %s was removed from %s.', frame, owner)
							end
							return CPAPI.Log('Frame %s was not found in %s. Command ignored.', frame, owner)
						elseif ( action == 'reset' ) then
							if stack:TryUnregisterFrame(owner, frame, true) then
								stack:UpdateFrames()
								return CPAPI.Log('Frame %s was reset.', frame)
							end
							return CPAPI.Log('Frame %s was not found in %s. Nothing to reset.', frame, owner)
						end
					end)
				end
				return CPAPI.Log('Frame owner %s is not eligble. Reason: %s', owner, reason)
			end
			return false;
		end;
	};
	-----------------------------------------------------------
	-- Config
	-----------------------------------------------------------
	status = {
		desc  = 'Show connected devices.';
		usage = {
			{'[deviceID]', 'number', 'Optional device ID to show axis readings and state.'};
		};
		function(deviceID)
			local activeDevices = {};
			for _, i in ipairs(C_GamePad.GetAllDeviceIDs()) do
				local device = C_GamePad.GetDeviceRawState(i)
				local devicePowerLevel = C_GamePad.GetPowerLevel(i)
				local powerLevelInfo = db.Battery:GetPowerLevelInfo(devicePowerLevel)
				if device then
					tinsert(activeDevices, {
						id    = i;
						state = device;
						powerLevel = powerLevelInfo.color:WrapTextInColorCode(powerLevelInfo.name);
					})
				end
			end
			if next(activeDevices) then
				CPAPI.Log('Connected devices:')
				for _, device in ipairs(activeDevices) do
					local vendorID  = ('%04x'):format(device.state.vendorID):upper();
					local productID = ('%04x'):format(device.state.productID):upper();
					local powerLevel = device.powerLevel;
					local config = C_GamePad.GetConfig({
						vendorID  = device.state.vendorID;
						productID = device.state.productID;
					});

					CPAPI.Log('%d: |cFFFFFFFF%s|r', device.id, device.state.name)
					CPAPI.Log('   Vendor: |cFF00FFFF%s|r, Product: |cFF00FFFF%s|r, Config: %s, Battery Level: %s',
						vendorID, productID,
						config and ('|cFF00FF00%s|r'):format(config.name or 'custom') or '|cFFFFFFFFgeneric|r',
						powerLevel
					);
				end
			else
				CPAPI.Log('No connected devices found.')
			end
			-- TODO: show axis readings and state when device ID is provided
		end;
	};
	applyconfig = {
		desc = 'Re-apply config for the active device.';
		usage = {
			{'[useBluetooth]', 'bool', 'Optional bluetooth state to apply.'};
		};
		function(useBluetooth)
			local bluetooth = useBluetooth and Compile(useBluetooth)
			local device = db('Gamepad/Active')
			if device then
				device:ApplyConfig(bluetooth)
				CPAPI.Log('Config was applied for your %s device.', device.Name)
			end
		end;
	};
	bluetooth = {
		desc = 'Change bluetooth state for active device.';
		usage = {
			{'state', 'bool', 'State to set bluetooth to.'};
		};
		function(state)
			if state then
				local bluetooth = state and Compile(state)
				local device = db('Gamepad/Active')
				if device then
					device:ApplyConfig(bluetooth)
					return CPAPI.Log('Bluetooth set to %s for %s.', state, device.Name)
				end
			end
			return false;
		end;
	};
	config = {
		desc = 'Change or print a value from the active device configuration.';
		usage = {
			{'path/to/key', 'string', 'Path to the key in the configuration.'};
			{'[value]', 'any', 'Optional value to set at the key.'};
		};
		function(path, value)
			if not path and not value then
				return false;
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
	};
	resetconfigs = {
		desc  = 'Reset all mapping configurations and reload. (will not affect bindings)';
		function()
			for i, config in ipairs(C_GamePad.GetAllConfigIDs()) do
				C_GamePad.DeleteConfig(config)
			end
			C_GamePad.ApplyConfigs()
			ReloadUI()
		end;
	};
	-----------------------------------------------------------
	-- Reset/uninstall
	-----------------------------------------------------------
	clearbindings = {
		desc = 'Clear configured gamepad bindings and reload interface.';
		function()
			ClearPadBindings()
			ReloadUI()
		end;
	};
	resetall = {
		desc = 'Remove all saved settings and reload interface.';
		function()
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
	};
	uninstall = {
		desc = 'Remove all saved settings and bindings, disable addon, and reload interface.';
		function()
			CPAPI.Popup('ConsolePort_Uninstall_Addon', {
				text = 'This action will remove all your saved settings and reload your interface.';
				button1 = OKAY;
				button2 = CANCEL;
				timeout = 0;
				whileDead = 1;
				showAlert = 1;
				OnAccept = function()
					CPAPI.DisableAddOn('ConsolePort')
					SetCVar('GamePadEnable', 0)
					ClearPadBindings()
					Uninstall()
				end;
			})
		end;
	};
	-----------------------------------------------------------
	-- Utils
	-----------------------------------------------------------
	unitmenu = {
		desc = 'Open the unit menu for the target unit.';
		usage = {
			{'[unit]', 'string', 'Unit to open the menu for.'};
		};
		function(unit)
			return db.UnitMenu:SetUnit(unit or 'target')
		end;
	};
	-----------------------------------------------------------
	-- Help
	-----------------------------------------------------------
	help = {
		desc = 'Show help for command(s).';
		usage = {
			{'[command]', 'string', 'Optional command to show help for.'};
		};
		function(command)
			local function GenerateUsage(data, usage) usage = usage or '';
				if data.usage then
					local args = {};
					for _, arg in ipairs(data.usage) do
						tinsert(args, arg[1])
					end
					usage = table.concat(args, ' ')
				end
				return usage;
			end

			local data = SLASH_FUNCTIONS[command];
			if data then
				CPAPI.Log(HELP_STRING, command, GenerateUsage(data))
				if data.usage then
					for _, arg in ipairs(data.usage) do
						CPAPI.Log(DOCU_STRING, unpack(arg))
					end
				end
			else
				CPAPI.Log(HELP_STRING, 'command', '[args]')
				CPAPI.Log(DOCU_STRING, '<empty>', '', 'Open configuration interface.')
				for func, data in db.table.spairs(SLASH_FUNCTIONS) do
					CPAPI.Log(DOCU_STRING, func, GenerateUsage(data), data.desc)
				end
			end
		end;
	}
};

---------------------------------------------------------------
-- Set up slash handler
---------------------------------------------------------------
setmetatable(ConsolePort, {
	__index = getmetatable(ConsolePort).__index;
	__call  = HandleSlashCommand;
})

RegisterNewSlashCommand(ConsolePort, 'consoleport', 'cp')

---------------------------------------------------------------
-- Temp?: add a game menu button to access config
---------------------------------------------------------------
do local GMB = CreateFrame('Button', '$parent'.._, GameMenuFrame)
	GMB:SetSize(58, 58)
	GMB:SetPoint('TOP', 0, 70)
	GMB:SetNormalTexture(CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]))
	GMB:SetPushedTexture(CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]))
	local pushed = GMB:GetPushedTexture()
	pushed:ClearAllPoints()
	pushed:SetSize(GMB:GetSize())
	pushed:SetPoint('CENTER', 0, -2)
	-- Protect against ElvUI shenanigans
	GMB.SetNormalTexture = nop;
	GMB.SetPushedTexture = nop;
	GMB.GetNormalTexture = nop;
	GMB.GetPushedTexture = nop;
	GMB:SetScript('OnClick', function()
		if not InCombatLockdown() then
			HideUIPanel(GameMenuFrame)
			ConsolePort()
		end
	end)
end