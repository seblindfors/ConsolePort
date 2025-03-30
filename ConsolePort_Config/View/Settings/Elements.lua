local DP, env, db, L = 1, CPAPI.GetEnv(...); L = env.L;
----------------------------------------------------------------
-- Device selection
----------------------------------------------------------------
-- Renders real devices in a list for individual mapping.
local function GetRealDevices(defaultDeviceName)
	local realDevices = {{
		name = defaultDeviceName or DEFAULT;
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

local function GetRawOptions(defaultDeviceName)
	local options = {};
	for i, device in ipairs(GetRealDevices(defaultDeviceName)) do
		tinsert(options, device.name)
	end
	return options;
end

local function ConvertToHex(number)
	local hex = string.format('%x', number)
	return ((#hex % 2 == 1) and '0'..hex or hex):upper();
end

---------------------------------------------------------------
local DeviceSelect = CreateFromMixins(env.Elements.Setting);
local DeviceSelectVariable = 'GamePadSingleActiveID';
local DeviceSelectDatapoint;
---------------------------------------------------------------
env.Elements.DeviceSelect = DeviceSelect;

local function GetSelectDatapoint()
	if not DeviceSelectDatapoint then
		DeviceSelectDatapoint = {
			name = L'Device Selection';
			desc = L'Select the device you want to use.';
			note = L'All combines all connected devices into one.';
			list = SYSTEM;
			[DP] = db.Data.Select(1, 1);
		};
	end
	DeviceSelectDatapoint[DP]
		:SetRawOptions(GetRawOptions(ALL))
		:Set(GetCVarNumberOrDefault(DeviceSelectVariable) + 1)
	return DeviceSelectDatapoint;
end

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
	self:Update()
end

function DeviceSelect:OnAcquire(new)
	if new then
		Mixin(self, env.Setting, DeviceSelect)
		self:HookScript('OnEnter', self.LockHighlight)
		self:HookScript('OnLeave', self.UnlockHighlight)
	end
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

function DeviceSelect:Get()
	return self.controller:Get()
end

function DeviceSelect:Data()
	return {
		varID = DeviceSelectVariable;
		field = GetSelectDatapoint();
		type  = 'DeviceSelect';
	};
end

function DeviceSelect:Update()
	local device = self:GetCurrentDevice()
	if device then
		self:SetText(('%s: %s %s'):format(L'Active Device', device.name, self:GetHexSlug(device.vendorID, device.productID)))
		self.tooltipText = ('Name: %s\nVendor ID: |cFF00FFFF%s|r / |cFF00FF00%s|r\nProduct ID: |cFF00FFFF%s|r / |cFF00FF00%s|r'):format(
			device.name,
			device.vendorID,  ConvertToHex(device.vendorID),
			device.productID, ConvertToHex(device.productID)
		);
		self.disableTooltipHints = true;
	else
		self:SetText(L'Unknown device selected.')
	end
	SetCVar(self.variableID, self:Get() - 1)
end

---------------------------------------------------------------
local DeviceEdit = CreateFromMixins(DeviceSelect);
local DeviceEditDatapoint;
---------------------------------------------------------------
env.Elements.DeviceEdit = DeviceEdit;

local function GetEditDatapoint()
	if not DeviceEditDatapoint then
		DeviceEditDatapoint = {
			name = L'Device Information';
			desc = L'Select the device you want to configure.';
			note = L'Click here to reset your device profile.';
			[DP] = db.Data.Select(1, 1);
		};
	end
	DeviceEditDatapoint[DP]:SetRawOptions(GetRawOptions())
	return DeviceEditDatapoint;
end

function DeviceEdit:Init(elementData)
	DeviceSelect.Init(self, elementData)
	self:SetScript('OnClick', self.OnResetClick)
end

function DeviceEdit:OnAcquire(new)
	if new then
		Mixin(self, env.Setting, DeviceEdit)
		self:HookScript('OnEnter', self.LockHighlight)
		self:HookScript('OnLeave', self.UnlockHighlight)
	end
end

function DeviceEdit:Data()
	return {
		varID = 'DeviceEditID';
		field = GetEditDatapoint();
		type  = 'DeviceEdit';
	};
end

function DeviceEdit:Update()
	local device = self:GetCurrentDevice()
	if device then
		self:SetText(('%s: %s %s'):format(EDIT, device.name, self:GetHexSlug(device.vendorID, device.productID)))
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

function DeviceEdit:OnResetClick()
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

---------------------------------------------------------------
local DeviceProfile = CreateFromMixins(env.Elements.Setting);
local DeviceProfileDatapoints;
---------------------------------------------------------------
env.Elements.DeviceProfile = DeviceProfile;

local function GetDeviceProfileDatapoint(device)
	if not DeviceProfileDatapoints then
		DeviceProfileDatapoints = {};
	end
	if not DeviceProfileDatapoints[device] then
		DeviceProfileDatapoints[device] = {
			name = device.Name;
			desc = GRAPHICS_LABEL;
			list = GRAPHICS_LABEL;
			[DP] = db.Data.Bool(false);
		};
	end
	DeviceProfileDatapoints[device][DP]:Set(not not device.Active)
	return DeviceProfileDatapoints[device];
end

function DeviceProfile:Data(datapoint)
	local device = datapoint.device;
	return {
		varID  = datapoint.varID;
		type   = 'DeviceProfile';
		field  = GetDeviceProfileDatapoint(device);
		device = device;
	};
end

function DeviceProfile:Get()
	return not not self:GetElementData():GetData().device.Active;
end

function DeviceProfile:Init(elementData)
	local data = elementData:GetData()
	xpcall(self.Mount, geterrorhandler(), self, {
		name      = data.field.name;
		varID     = data.varID;
		field     = data.field;
		owner     = ConsolePortConfig;
		registry  = db;
		newObj    = true;
		callbackFn = function()
			self:OnActiveChanged()
			self:Update()
		end;
	})
	self.disableTooltipHints = true;
	self:SetScript('OnClick', self.OnActivate)
	self:Update()
end

function DeviceProfile:OnAcquire(new)
	if new then
		Mixin(self, env.Setting, DeviceProfile)
		self:HookScript('OnEnter', self.LockHighlight)
		self:HookScript('OnLeave', self.UnlockHighlight)
	end
	db:RegisterCallback('Gamepad/Active', self.OnActiveChanged, self)
end

function DeviceProfile:GetDevice()
	if not self.GetElementData then return end;
	return self:GetElementData():GetData().device;
end

function DeviceProfile:OnRelease()
	db:UnregisterCallback('Gamepad/Active', self)
end

function DeviceProfile:OnActiveChanged()
	local device = self:GetDevice()
	if device then
		self:OnValueChanged(device.Active)
	end
end

function DeviceProfile:Update()
	local device = self:GetDevice()
	if not device then
		self.tooltipText = UNKNOWN;
		return;
	end
	self.tooltipText = GRAPHICS_LABEL;

	local splashID = db('Gamepad/Index/Splash/'..device.Name);
	local splashTx = splashID and CPAPI.GetAsset('Splash\\Gamepad\\'..splashID);
	local splash = splashTx and ('|T%s:200:200:0|t'):format(splashTx);

	if splash then
		self.tooltipText = self.tooltipText..'\n'..splash;
	end
end

function DeviceProfile:OnActivate()
	local device = self:GetDevice()
	if not device then return end;
	if not IsModifierKeyDown() then
		return device:Activate()
	end
	CPAPI.Popup('ConsolePort_Apply_Preset', {
		text = L('Do you want to load settings for %s?'
			.. '\n\n'
			.. 'This will configure your modifiers, mouse emulation buttons, and previously saved device settings (if any).', device.Name);
		button1 = YES;
		button2 = NO;
		timeout = 0;
		whileDead = 1;
		showAlert = 1;
		fullScreenCover = 1;
		OnAccept = function()
			device:ApplyPresetVars()
		end;
		OnCancel = function()
			device:Activate()
		end;
		OnHide = function()
			CPAPI.Popup('ConsolePort_Reset_Keybindings', {
				text = ('%s\n\n%s'):format(CONFIRM_RESET_KEYBINDINGS, L'This only affects gamepad bindings.');
				button1 = YES;
				button2 = NO;
				timeout = 0;
				whileDead = 1;
				showAlert = 1;
				fullScreenCover = 1;
				OnAccept = function()
					device:ApplyPresetBindings(GetCurrentBindingSet())
				end;
				OnHide = function()
					if device:ConfigHasBluetoothHandling() then
						CPAPI.Popup('ConsolePort_Apply_Config', {
							text = L('Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?', device.Name);
							button1 = L'Wired';
							button2 = CANCEL;
							button3 = L'Bluetooth';
							timeout = 0;
							whileDead = 1;
							showAlert = 1;
							fullScreenCover = 1;
							OnAccept = function()
								device:ApplyConfig(false)
							end;
							OnAlt = function()
								device:ApplyConfig(true)
							end;
						})
					end
				end;
			})
		end;
	})
end