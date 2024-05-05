local _, env, db, L = ...; db, L = env.db, env.L;
local PanelMixin, Widgets = {}, env.Widgets;
local SHORTCUT_WIDTH, GENERAL_WIDTH, FIXED_OFFSET = 284, 700, 8;

---------------------------------------------------------------
-- Console variable fields
---------------------------------------------------------------
local Cvar, Mapper = env.CvarMixin, db.Mapper;
local Setting = CreateFromMixins(Cvar)

function Setting:OnLoad()
	Cvar.OnLoad(self)
	self:SetWidth(GENERAL_WIDTH - 32)
end

function Setting:GetData()
	return self:GetMetadata().data;
end

function Setting:SetRaw(variableID, ...)
	local data = self:GetData()
	if data then
		return Mapper:SetValue(self.variableID, ...)
	end
	return Cvar.SetRaw(self, variableID, ...)
end

function Setting:GetRaw(...)
	local data = self:GetData()
	if data then
		return Mapper:GetValue(self.variableID, data:Get())
	end
	return Cvar.GetRaw(self, ...)
end

function Setting:GetRawBool(...)
	local data = self:GetData()
	if data then
		return Mapper:GetValue(self.variableID, data:Get()) -- TODO
	end
	return Cvar.GetRawBool(self, ...)
end

function Setting:OnMapperConfigLoaded()
	db.Alpha.FadeIn(self, 1, 0, 1)
	self:OnValueChanged(self:GetRaw())
end

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

local function ConvertToHex(number)
	local hex = string.format('%x', number)
	return ((#hex % 2 == 1) and '0'..hex or hex):upper();
end

local DeviceSelect = {};

function DeviceSelect:Construct()
	local options = self:GetRawOptions()
	self:SetDrawOutline(true)
	self:SetText(L'Device')
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetPoint('RIGHT', -16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	Widgets.Select(self, 'DeviceID', nil, db.Data.Select(1, 1):SetRawOptions(options), L'Device Information')
	self.Popout:ClearAllPoints()
	self.Popout:SetPoint('TOP', self, 'BOTTOM', 0, 0)
	self:SetCallback(function(value)
		self:OnValueChanged(value)
		self:Update()
	end)
	self:Update()
	self.disableTooltipHints = true;
end

function DeviceSelect:GetRawOptions()
	local options = {};
	for i, device in ipairs(GetRealDevices()) do
		tinsert(options, device.name)
	end
	return options;
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
		self:SetText(('%s %s'):format(device.name, self:GetHexSlug(device.vendorID, device.productID)))
		self.tooltipText = ('Name: %s\nVendor ID: |cFF00FFFF%s|r / |cFF00FF00%s|r\nProduct ID: |cFF00FFFF%s|r / |cFF00FF00%s|r'):format(
			device.name,
			device.vendorID, ConvertToHex(device.vendorID),
			device.productID, ConvertToHex(device.productID)
		);
		self.tooltipText = self.tooltipText .. '\n\n'
			.. YELLOW_FONT_COLOR:WrapTextInColorCode(L'Click here to reset your device profile.');
	else
		self:SetText(L'Select a device from the list to continue.')
	end
	db:TriggerEvent('OnMapperDeviceChanged', device, self:GetCurrentDeviceID())
end

function DeviceSelect:OnClick()
	CPIndexButtonMixin.Uncheck(self)
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
					for i, config in ipairs(C_GamePad.GetAllConfigIDs()) do
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

DeviceSelect.GetChecked = nop;

---------------------------------------------------------------
-- Console
---------------------------------------------------------------
local Console = CreateFromMixins(env.SettingListMixin)

function Console:OnVariableChanged(variable, value)
	-- dealing with emulation button overlap (don't trust the user)
	if (variable:match('Emulate') or variable:match('Click')) and not self.isMutexLocked then
		self.isMutexLocked = true;
		for cvar in self:EnumerateActive() do
			if (cvar:Get() == value) and (cvar.variableID ~= variable) then
				cvar:Set('none', true)
			end
		end
		self.isMutexLocked = false;
	end
end

function Console:DrawOptions(showAdvanced)
	self.headerPool:ReleaseAll()

	local prev;

	-- profile settings
	for group, set in db.table.spairs(db.Profile) do
		prev = self:CreateHeader(group, prev)

		for i, data in ipairs(set) do
			local widget, newObj = self:TryAcquireRegistered(group..':'..data.path)
			if newObj then
				widget:SetDrawOutline(true)
				widget:OnLoad()
				db:RegisterCallback('OnMapperConfigLoaded', widget.OnMapperConfigLoaded, widget)
			end
			widget:Construct(data, newObj, self)
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET)
			prev = widget;
		end
	end

	-- console variables
	for group, set in db.table.spairs(db.Console) do
		local hasSettingsToShow = false;
		for i, data in pairs(set) do
			if GetCVar(data.cvar) then
				hasSettingsToShow = true;
				break
			end
		end
		if hasSettingsToShow then
			prev = self:CreateHeader(group, prev)

			for i, data in db.table.spairs(set) do
				if GetCVar(data.cvar) then
					local widget, newObj = self:TryAcquireRegistered(group..':'..data.cvar)
					if newObj then
						widget:SetDrawOutline(true)
						widget:OnLoad()
					end
					widget:Construct(data, newObj, self)
					widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET)
					prev = widget;
				end
			end
		end
	end
	self.Child:SetHeight(nil)
	self.Shortcuts.Child:SetHeight(nil)
end

function Console:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
	self.headerPool = CreateFramePool('Frame', self.Child, 'CPConfigHeaderTemplate')
	self:CreateFramePool('IndexButton',
		'CPIndexButtonSettingTemplate', Setting, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, GENERAL_WIDTH, FIXED_OFFSET)
end


---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function PanelMixin:OnFirstShow()
	local Carpenter = LibStub('Carpenter')
	Carpenter:BuildFrame(self, {
		Select = {
			_Type  = 'IndexButton';
			_Setup = 'CPIndexButtonBindingHeaderTemplate';
			_Mixin = DeviceSelect;
			_Width = SHORTCUT_WIDTH - 16;
			_Level = 2;
			_Point = {'TOPLEFT', 8, -FIXED_OFFSET*8};
			{
				TopText = {
					_Type = 'FontString';
					_Point = {'BOTTOMLEFT', '$parent', 'TOPLEFT', 8, 8};
					_OnLoad = function(self)
						self:SetFontObject(GameFontNormal)
						self:SetText(L'Selected device profile:')
					end;
				};
				HeaderCategories = {
					_Type  = 'Frame';
					_Setup = 'CPAnimatedLootHeaderTemplate';
					_Width = SHORTCUT_WIDTH;
					_Point = {'BOTTOM', FIXED_OFFSET * 3, -FIXED_OFFSET*9};
					_Text  = CATEGORIES;
				};
			};
		};
		LeftBackground = {
			_Type  = 'Frame';
			_Setup = 'BackdropTemplate';
			_Mixin = env.OpaqueMixin;
			_Backdrop = CPAPI.Backdrops.Opaque;
			_Width = SHORTCUT_WIDTH + 1;
			_Level = 1;
			_Points = {
				{'TOPLEFT', 0, 0};
				{'BOTTOMLEFT', 0, 0};
			};
			{
				HeaderDevice = {
					_Type  = 'Frame';
					_Setup = 'CPAnimatedLootHeaderTemplate';
					_Width = SHORTCUT_WIDTH;
					_Point = {'TOP', FIXED_OFFSET * 3, -FIXED_OFFSET};
					_Text  = L'Device';
				};
			}
		};
	}, false, true)
	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		_Mixin = env.SettingShortcutsMixin;
		_Width = SHORTCUT_WIDTH;
		_Setup = {'CPSmoothScrollTemplate'};
		_Points = {
			{'TOPLEFT', '$parent.Select', 'BOTTOMLEFT', -8, -FIXED_OFFSET * 9};
			{'BOTTOMLEFT', 0, 0};
		};
	})
	local cvars = self:CreateScrollableColumn('Console', {
		_Mixin = Console;
		_Width = GENERAL_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.LeftBackground', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.LeftBackground', 'BOTTOMRIGHT', 0, 0};
		};
	})
	Carpenter:BuildFrame(shortcuts.Child, {
		HeaderCategories = {
			_Type  = 'Frame';
			_Setup = 'CPAnimatedLootHeaderTemplate';
			_Width = SHORTCUT_WIDTH;
			_OnLoad = function(self) self.Text:SetText(CATEGORIES) end;
		};
	}, false, true)

	self.Select:Construct()
	cvars.Shortcuts = shortcuts;
	shortcuts.List = cvars;
end

env.Console = ConsolePortConfig:CreatePanel({
	name  = SETTINGS;
	mixin = PanelMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})