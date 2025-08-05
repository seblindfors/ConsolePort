local DP, env, db, L = 1, CPAPI.GetEnv(...); L = env.L;
----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local function Shared(datapoint)
	-- Needs to be used for any datapoint where it's possible
	-- for more than one widget at a time to be mounted to it.
	datapoint.node = datapoint.node or {};
	function datapoint:Register(node)
		self.node[node] = true;
	end
	function datapoint:Unregister(node)
		self.node[node] = nil;
	end
	function datapoint:Enumerate()
		return pairs(self.node);
	end
	return datapoint;
end

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

local InitializeSetting = env.Elements.InitializeSetting;

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
		InitializeSetting(self, env.Setting, DeviceSelect)
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
		InitializeSetting(self, env.Setting, DeviceEdit)
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
	if not self.GetElementData then
		return false; -- not mounted.
	end
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
		InitializeSetting(self, env.Setting, DeviceProfile)
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

	local splashTx = env:GetSplashTexture(device)
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
		text = L('Do you want to load settings for %s?', device.Name);
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

---------------------------------------------------------------
local CharacterBindings = CreateFromMixins(env.Elements.Setting);
local CharacterBindingsDatapoint;
---------------------------------------------------------------
env.Elements.CharacterBindings = CharacterBindings;

local function AreCharacterBindingsEnabled()
	return GetCurrentBindingSet() == Enum.BindingSet.Character;
end

local function SetCharacterBindings(enabled)
	if enabled then
		Settings.SelectCharacterBindings()
	else
		Settings.SelectAccountBindings()
	end
end

local function UpdateCharacterBindings(value)
	for node in CharacterBindingsDatapoint:Enumerate() do
		node:OnValueChanged(value)
	end
	env:TriggerEvent('Settings.OnCharacterBindingsChanged', value)
end

local function GetCharacterBindingsDatapoint()
	if not CharacterBindingsDatapoint then
		CharacterBindingsDatapoint = Shared({
			name = CHARACTER_SPECIFIC_KEYBINDINGS;
			desc = CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP;
			[DP] = db.Data.Bool(false);
		});
	end
	CharacterBindingsDatapoint[DP]:SetCallback(nil)
	CharacterBindingsDatapoint[DP]:Set(AreCharacterBindingsEnabled())
	return CharacterBindingsDatapoint;
end

function CharacterBindings:Init(elementData)
	local data = elementData:GetData()
	xpcall(self.Mount, geterrorhandler(), self, {
		name       = data.field.name;
		varID      = data.varID;
		field      = data.field;
		owner      = ConsolePortConfig;
		registry   = db;
		newObj     = true;
		callbackFn = function(enabled)
			-- Changing from character to account bindings requires confirmation
			-- since it overwrites character with account bindings.
			if not enabled then
				return CPAPI.Popup('ConsolePort_Confirm_Account_Bindings', {
					text     = CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS,
					button1  = OKAY,
					button2  = CANCEL,
					OnCancel = nop;
					OnAccept = function()
						SetCharacterBindings(enabled)
					end;
					OnHide = function()
						UpdateCharacterBindings(AreCharacterBindingsEnabled())
					end;
					timeout   = 0;
					showAlert = 1;
				})
			end
			SetCharacterBindings(enabled)
			UpdateCharacterBindings(AreCharacterBindingsEnabled())
		end;
	})
end

function CharacterBindings:OnAcquire(new)
	if new then
		InitializeSetting(self, env.Setting, CharacterBindings)
		self.Get = AreCharacterBindingsEnabled;
		self.disableTooltipHints = true;
	end
	CharacterBindingsDatapoint:Register(self);
end

function CharacterBindings:OnRelease()
	CharacterBindingsDatapoint:Unregister(self);
end

function CharacterBindings:Data()
	return {
		varID = 'CharacterBindingsID';
		field = GetCharacterBindingsDatapoint();
		type  = 'CharacterBindings';
	};
end

---------------------------------------------------------------
local BindingPreset = CPAPI.CreateElement('CPBindingPreset', 0, 40)
---------------------------------------------------------------
env.Elements.BindingPreset = BindingPreset;

local BindingPresetIcon = CreateFromMixins(env.Elements.BindingIcon)

local function MakePresetMeta(name, icon)
	return {
		Type = db.Gamepad:GetActiveDeviceName();
		Name = name;
		Icon = icon;
	};
end

local function AddDoubleTooltipLine(tbl, left, right)
	return tinsert(tbl, {left, right, 1, 1, 1, 1, 1, 1});
end

function BindingPresetIcon:OnIconChanged(result, saveResult)
	self.NormalTexture:SetAlpha(not result and 0.25 or 1)
	self.NormalTexture:SetTexture(result or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
	if saveResult then
		local data = self:GetParent():GetElementData():GetData()
		data.meta.Icon = result;
	end
end

function BindingPresetIcon:OnClick()
	local data = self:GetParent():GetElementData():GetData()
	env:TriggerEvent('OnBindingPresetIconClicked',
		data.meta.Name,
		data.meta.Icon,
		self,
		self.OnIconChanged
	);
end

function BindingPreset:OnAcquire(new)
	if new then
		InitializeSetting(self, BindingPreset)
		self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		self:SetScript('OnClick', BindingPreset.OnClick)

		CPAPI.Specialize(self.Icon, BindingPresetIcon)

		local base = env.Settings.Base;
		self:HookScript('OnEnter', base.OnEnter)
		self:HookScript('OnLeave', base.OnLeave)

		self.UpdateTooltip  = base.UpdateTooltip;
		self.leftClickHint  = APPLY;
		self.rightClickHint = EDIT;
	end
end

function BindingPreset:Init(elementData)
	local data = elementData:GetData()
	self:SetText(data.meta.Name)
	self.Icon:SetEnabled(not data.readonly)
	self.Icon.NormalTexture:SetTexture(data.meta.Icon)

	self.tooltipDoubles = {};
	if data.meta.Type then
		AddDoubleTooltipLine(self.tooltipDoubles, TYPE, data.meta.Type)
	end
	if data.meta.Class then
		for i=1, GetNumClasses() do
			local className, classID = GetClassInfo(i)
			if (data.meta.Class == classID) then
				AddDoubleTooltipLine(self.tooltipDoubles, CLASS, className)
			end
		end
	end
	if data.meta.Spec and GetSpecializationInfoByID then
		local specName = select(2, GetSpecializationInfoByID(data.meta.Spec))
		if specName then
			AddDoubleTooltipLine(self.tooltipDoubles, SPECIALIZATION, specName)
		end
	end
end

function BindingPreset:OnClick(button)
	if ( button == 'RightButton' ) then
		return self:Edit()
	end
	return self:Apply()
end

function BindingPreset:Edit()
	local data = self:GetElementData():GetData()
	if data.readonly then
		return CPAPI.Log('Preset %s cannot be modified.', data.meta.Name)
	end
	CPAPI.Popup('ConsolePort_Modify_Binding_Preset', {
		text = EDIT..': %s';
		button1 = SAVE_CHANGES;
		button2 = CANCEL;
		button3 = DELETE;
		hasEditBox = 1;
		OnShow = function(self, data)
			self.editBox:SetText(data.key)
		end;
		OnAccept = function(popup, data)
			local editBox = popup.editBox or popup:GetEditBox();
			local newKey  = editBox:GetText():trim()
			local oldKey  = data.key;
			if ( newKey == '' ) then
				return CPAPI.Log('Preset key cannot be empty.')
			end
			if ( newKey == data.key ) then
				return CPAPI.Log('Preset key is unchanged.')
			end
			self:Rename(oldKey, newKey, data)
		end;
		OnAlt = function(_, data)
			self:Delete(data)
		end;
	}, data.meta.Name, nil, data)
end

function BindingPreset:Rename(old, new, data)
	-- TODO: This is a bit hacky, and eventually the whole "Shared"
	-- data structure should probably be reevaluated.

	if db.Shared.Data[new] then
		return CPAPI.Log('Preset key %s already exists.', new)
	end

	local meta = MakePresetMeta(new, data.meta.Icon)

	db.Shared.Data[new] = db.Shared.Data[old];
	db.Shared.Data[old] = nil;
	db.Shared.Data[new].Meta = meta;
	db.Shared:CollectCharacterGarbage()
	data.key, data.meta = new, meta;

	local object = data.store[data.index];
	object.key, object.meta = new, meta;

	env:TriggerEvent('Settings.OnDirty')
end

function BindingPreset:Delete(data)
	-- TODO: This is a bit hacky, and eventually the whole "Shared"
	-- data structure should probably be reevaluated.

	if db.Shared:RemoveData(data.key, 'Bindings') then
		CPAPI.Log('Preset %s has been deleted.', data.meta.Name)
		tremove(data.store, data.index)
		db.Shared:CollectCharacterGarbage()
		env:TriggerEvent('Settings.OnDirty')
	end
end

function BindingPreset:Apply()
	local data = self:GetElementData():GetData()
	CPAPI.Popup('ConsolePort_Apply_Binding_Preset', {
		text = YELLOW_FONT_COLOR:WrapTextInColorCode(APPLY..': '..CHARACTER_KEY_BINDINGS:lower())
			.. ('\n\n')
			.. CONFIRM_CONTINUE;
		button1 = YES;
		button2 = NO;
		timeout = 0;
		whileDead = 1;
		showAlert = 1;
		fullScreenCover = 1;
		OnAccept = function(_, data)
			if data.device then
				for combination, binding in pairs(data.device:ApplyPresetBindings(GetCurrentBindingSet())) do
					env:TriggerEvent('OnBindingChanged', combination, binding)
				end
			else
				for button, set in pairs(data.preset) do
					for modifier, binding in pairs(set) do
						env:SetBinding(modifier..button, binding)
					end
				end
				SaveBindings(GetCurrentBindingSet())
			end
			CPAPI.Log('Preset %s has been applied.', data.meta.Name)
		end;
	}, data.meta.Name, nil, data)
end

function BindingPreset:Data(datapoint)
	return {
		meta     = datapoint.meta;
		key      = datapoint.key;
		preset   = datapoint.preset;
		readonly = datapoint.readonly;
		store    = datapoint.store;
		index    = datapoint.index;
		device   = datapoint.device;
	};
end

---------------------------------------------------------------
local BindingPresetAdd = CPAPI.CreateElement('CPBindingPresetAdd', 0, 40)
---------------------------------------------------------------
env.Elements.BindingPresetAdd = BindingPresetAdd;

function BindingPresetAdd:OnAcquire(new)
	if new then
		InitializeSetting(self, BindingPresetAdd)
		self:SetText(ADD)
		self.Icon:EnableMouse(false)
		self.Icon.NormalTexture:SetTexture([[Interface\PaperDollInfoFrame\Character-Plus]])
		self:SetScript('OnClick', self.OnClick)
	end
end

function BindingPresetAdd:OnClick()
	env:TriggerEvent('OnBindingPresetAddClicked', self, self.OnAdded)
end

function BindingPresetAdd:OnAdded(icon, _, name)
	name = name and name:trim() or nil;
	if ( not name or name:len() == 0 ) then
		return CPAPI.Log('Preset name cannot be empty.')
	end
	if not icon then
		return CPAPI.Log('Preset icon cannot be empty.')
	end

	local data = self:GetElementData():GetData()
	local entry = db.Shared.Data[name] or {};
	db.Shared.Data[name] = entry;

	entry.Bindings = db.Gamepad:GetBindings(true)
	entry.Meta = MakePresetMeta(name, icon)

	local dp, store = data.add(entry.Meta, data.make(entry.Bindings), false, name)
	dp.index = #store;
	dp.store = store;

	env:TriggerEvent('Settings.OnDirty')
	CPAPI.Log('Preset %s has been created.', name)
end

function BindingPresetAdd:Data(datapoint)
	return {
		add   = datapoint.add;
		make  = datapoint.make;
	};
end