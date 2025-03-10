local DP, env, db, L = 1, CPAPI.GetEnv(...); L = env.L;
----------------------------------------------------------------
-- Device selection
----------------------------------------------------------------
-- Renders real devices in a list for individual mapping.
local function GetRealDevices()
	local realDevices = {{
		name = DEFAULT;
		productID = 0x0;
		vendorID  = 0x0;
	}};
	for i, deviceID in ipairs(C_GamePad.GetAllDeviceIDs()) do
		local device = C_GamePad.GetDeviceRawState(deviceID)
		if device then
			tinsert(realDevices, device)
		end
	end
	return realDevices;
end

local function GetRealDeviceIDs()
	local realDeviceIDs = {0x0};
	for i, deviceID in ipairs(C_GamePad.GetAllDeviceIDs()) do
		local device = C_GamePad.GetDeviceRawState(deviceID)
		if device then
			tinsert(realDeviceIDs, deviceID)
		end
	end
	return realDeviceIDs;
end

local function GetRawOptions()
	local options = {};
	for i, device in ipairs(GetRealDevices()) do
		tinsert(options, device.name)
	end
	return options;
end

local DeviceSelectDatapoint;
local function GetDatapoint()
	if not DeviceSelectDatapoint then
		DeviceSelectDatapoint = {
			name = L'Device Information';
			desc = L'Select the device you want to configure.';
			note = L'Click here to reset your device profile.';
			[DP] = db.Data.Select(1, 1);
		};
	end
	DeviceSelectDatapoint[DP]:SetRawOptions(GetRawOptions())
	return DeviceSelectDatapoint;
end

local function ConvertToHex(number)
	local hex = string.format('%x', number)
	return ((#hex % 2 == 1) and '0'..hex or hex):upper();
end

---------------------------------------------------------------
local DeviceSelect = CreateFromMixins(env.Elements.Setting);
---------------------------------------------------------------
env.Elements.DeviceSelect = DeviceSelect;

function DeviceSelect:Init(elementData)
	local data = elementData:GetData()
	xpcall(self.Mount, geterrorhandler(), self, {
		name      = data.field.name;
		varID     = data.varID;
		field     = data.field;
		owner     = ConsolePortConfig;
		registry  = db;
		newObj    = true;
		callbackFn = function(value)
			self:OnValueChanged(value)
			self:Update()
		end;
	})
	self:SetScript('OnClick', self.OnResetClick)
	self:Update()
end

function DeviceSelect:OnAcquire(new)
	if new then
		Mixin(self, env.Setting, DeviceSelect)
		self:HookScript('OnEnter', self.LockHighlight)
		self:HookScript('OnLeave', self.UnlockHighlight)
	end
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
end

function DeviceSelect:Data()
	return {
		varID = 'DeviceID';
		field = GetDatapoint();
		type  = 'DeviceSelect';
	};
end

function DeviceSelect:Get()
	return self.controller:Get()
end

function DeviceSelect:GetCurrentDevice()
	return GetRealDevices()[self:Get()]
end

function DeviceSelect:GetCurrentDeviceID()
	return GetRealDeviceIDs()[self:Get()]
end

function DeviceSelect:GetHexSlug(vendorID, productID)
	if ( vendorID == 0x0 and productID == 0x0 ) then
		return '';
	end
	return ('<|cFF00FF00%s|r:|cFF00FF00%s|r>'):format(
		ConvertToHex(vendorID),
		ConvertToHex(productID)
	);
end

function DeviceSelect:Update()
	local device = self:GetCurrentDevice()
	if device then
		self:SetText(('%s: %s %s'):format(L'Device', device.name, self:GetHexSlug(device.vendorID, device.productID)))
		self.tooltipText = ('Name: %s\nVendor ID: |cFF00FFFF%s|r / |cFF00FF00%s|r\nProduct ID: |cFF00FFFF%s|r / |cFF00FF00%s|r'):format(
			device.name,
			device.vendorID,  ConvertToHex(device.vendorID),
			device.productID, ConvertToHex(device.productID)
		);
		self.disableTooltipHints = true;
	else
		self:SetText(L'Select a device from the list to continue.')
	end
	db:TriggerEvent('OnMapperDeviceChanged', device, self:GetCurrentDeviceID())
end

function DeviceSelect:OnResetClick()
	local device = self:GetCurrentDevice()
	if device then
		local disclaimer = '\n\n'..L'This will not affect your bindings, interface settings or system-wide settings.';
		if IsModifierKeyDown() then
			CPAPI.Popup('ConsolePort_Reset_Devices', {
				text = L'Are you sure you want to reset all device profiles?'
					.. disclaimer;
				button1 = RESET;
				button2 = CANCEL;
				whileDead = 1;
				showAlert = 1;
				OnAccept = function()
					for _, config in ipairs(C_GamePad.GetAllConfigIDs()) do
						C_GamePad.DeleteConfig(config)
					end
					C_GamePad.ApplyConfigs()
					db:TriggerEvent('OnMapperDeviceChanged', self:GetCurrentDevice(), self:GetCurrentDeviceID())
	 			end;
			})
		else
			CPAPI.Popup('ConsolePort_Reset_Device', {
				text = YELLOW_FONT_COLOR:WrapTextInColorCode(self:GetText())
					..'\n'
					.. L'Are you sure you want to reset your device profile?'
					.. disclaimer;
				button1 = RESET;
				button2 = CANCEL;
				whileDead = 1;
				showAlert = 1;
				OnAccept = function()
					for i, identifier in ipairs(C_GamePad.GetAllConfigIDs()) do
						local config = C_GamePad.GetConfig(identifier)
						if ( config.name == device.name ) then
							C_GamePad.DeleteConfig(identifier)
							C_GamePad.ApplyConfigs()
							db:TriggerEvent('OnMapperDeviceChanged', self:GetCurrentDevice(), self:GetCurrentDeviceID())
							break
						end
					end
	 			end;
			})
		end
	end
end