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

function Setting:OnMapperDeviceChanged()
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
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	Widgets.Select(self, 'DeviceID', nil, db.Data.Select(1, 1):SetRawOptions(options), 'Device Information')
	self.Popout:ClearAllPoints()
	self.Popout:SetPoint('TOP', self, 'BOTTOM', 0, 0)
	self.controller:SetCallback(function(value)
		self:OnValueChanged(value)
		self:Update()
	end)
	self:Update()
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
	else
		self:SetText(L'Select a device from the list to continue.')
	end
	db:TriggerEvent('OnMapperDeviceChanged', device, self:GetCurrentDeviceID())
end

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
				db:RegisterCallback('OnMapperDeviceChanged', widget.OnMapperDeviceChanged, widget)
			end
			widget:Construct(data, newObj, self)
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET)
			prev = widget;
		end
	end

	-- console variables
	for group, set in db.table.spairs(db.Console) do
		prev = self:CreateHeader(group, prev)

		for i, data in ipairs(set) do
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
	self.Child:SetHeight(nil)
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
	LibStub('Carpenter'):BuildFrame(self, {
		Select = {
			_Type  = 'IndexButton';
			_Setup = 'CPIndexButtonBindingHeaderTemplate';
			_Mixin = DeviceSelect;
			_Width = SHORTCUT_WIDTH - 16;
			_Point = {'TOPLEFT', 8, -32};
			{
				TopText = {
					_Type = 'FontString';
					_Point = {'BOTTOMLEFT', '$parent', 'TOPLEFT', 8, 8};
					_OnLoad = function(self)
						self:SetFontObject(GameFontNormal)
						self:SetText(L'Selected device profile:')
					end;
				};
			};
		};
	}, false, true)
	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		_Mixin = env.SettingShortcutsMixin;
		_Width = SHORTCUT_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Select', 'BOTTOMLEFT', -8, -40};
			{'BOTTOMLEFT', 0, 200};
		};
	})
	local cvars = self:CreateScrollableColumn('Console', {
		_Mixin = Console;
		_Width = GENERAL_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Select', 'TOPRIGHT', 8, 32};
			{'BOTTOMLEFT', '$parent.Shortcuts', 'BOTTOMRIGHT', 0, -200};
		};
	})
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