local _, localEnv = ...;
local env, db, L = unpack(localEnv)
----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local function GetRealDevices()
	local realDevices = {};
	for i, deviceID in ipairs(C_GamePad.GetAllDeviceIDs()) do
		local device = C_GamePad.GetDeviceRawState(deviceID)
		if device then
			tinsert(realDevices, device)
		end
	end
	return realDevices;
end

local function GetRealDeviceIDs()
	local realDeviceIDs = {};
	for i, deviceID in ipairs(C_GamePad.GetAllDeviceIDs()) do
		local device = C_GamePad.GetDeviceRawState(deviceID)
		if device then
			tinsert(realDeviceIDs, deviceID)
		end
	end
	return realDeviceIDs;
end

local function ConvertToHex(number)
	local hex = string.format('%x', number);
	return ((#hex % 2 == 1) and '0'..hex or hex):upper()
end

----------------------------------------------------------------
-- Device selection
----------------------------------------------------------------
-- Renders real devices in a list for individual mapping.

local DeviceSelect = {}; localEnv.DeviceSelect = DeviceSelect;

function DeviceSelect:Construct()
	local options = self:GetRawOptions()
	self:SetDrawOutline(true)
	self:SetText(L'Device')
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	env.Widgets.Select(self, 'DeviceID', nil, db.Data.Select(1, 1):SetRawOptions(options), 'Device Information')
	self:SetCallback(function(value)
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

function DeviceSelect:Update()
	local device = self:GetCurrentDevice()
	if device then
		self:SetText(('%s <|cFF00FF00%s|r:|cFF00FF00%s|r>'):format(
			device.name, ConvertToHex(device.vendorID), ConvertToHex(device.productID)))
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

----------------------------------------------------------------
-- Button state indicators
----------------------------------------------------------------
local Rawaxis = {};

function Rawaxis:Update(device)
	self:SetValue(device.rawAxes[self:GetID()])
end

----------------------------------------------------------------
local Rawbutton = {};

function Rawbutton:Update(device)
	self.State:SetVertexColor(0, device.rawButtons[self:GetID()] and 1 or 0, 0)
end

----------------------------------------------------------------
local Mapaxis = {};

function Mapaxis:Update(device)
	local axisID = self:GetID() - 1;
	local name = C_GamePad.AxisIndexToConfigName(axisID)
	self:SetValue(device.axes[axisID + 1])
	self.Text:SetText(name and name:gsub('Stick', ''):gsub('Trigger', 'T') or axisID)
end

----------------------------------------------------------------
local Mapbutton = {};

function Mapbutton:Update(device)
	self.State:SetVertexColor(0, device.buttons[self:GetID()] and 1 or 0, 0)
end

function Mapbutton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
	GameTooltip:SetText(GetBindingText(C_GamePad.ButtonIndexToBinding(self:GetID()-1)))
end

function Mapbutton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Mapbutton:SetID(id)
	getmetatable(self).__index.SetID(self, id)
	local glyph = GetBindingText(C_GamePad.ButtonIndexToBinding(id - 1))
	if glyph then
		self.Text:SetText(glyph)
	end
end

----------------------------------------------------------------
-- State update display handler
----------------------------------------------------------------
local Display = {}; localEnv.Display = Display;

function Display:OnDeviceUpdate(elapsed)
	self.throttle = not self.throttle;
	if self.throttle then return end;
	local pools = self.pools;

	local device = C_GamePad.GetDeviceRawState(self.deviceID)
	if not device then return end
	for obj in pools.rawAxis:EnumerateActive()   do obj:Update(device) end
	for obj in pools.rawButton:EnumerateActive() do obj:Update(device) end

	local device = C_GamePad.GetDeviceMappedState(self.deviceID)
	if not device then return end
	for obj in pools.mapAxis:EnumerateActive()   do obj:Update(device) end
	for obj in pools.mapButton:EnumerateActive() do obj:Update(device) end
end

function Display:RefreshAxes(count, pool, mixin)
	if not count then return end;
	local prev;
	for i=1, count do
		local widget, newObj = pool:Acquire()
		if newObj then
			env.db.table.mixin(widget, mixin)
		end
		widget.Text:SetText(i-1)
		widget:SetID(i)
		widget:Show()

		if prev then
			widget:SetPoint('LEFT', prev, 'RIGHT', 24, 0)
		else
			widget:SetPoint('LEFT', 0, -16)
		end
		prev = widget;
	end
	pool.parent:SetWidth(count * 40)
end

function Display:RefreshButtons(count, pool, mixin)
	if not count then return end;
	local prev;
	for i=1, count do
		local widget, newObj = pool:Acquire()
		if newObj then
			env.db.table.mixin(widget, mixin)
			widget.Text:SetJustifyH('CENTER')
		end
		widget.Text:SetText(i-1)
		widget:SetID(i)
		widget:Show()

		local row = floor((i-1) / 8)
		local col = (i-1) % 8;

		widget:SetPoint('TOPLEFT', (col) * 46, -((row) * 46) - 16)
	end
end

function Display:OnDeviceChanged(device, deviceID)
	self:ReleaseAll()
	if not device then
		return self:SetScript('OnUpdate', nil)
	end

	-- Refresh raw values
	self:RefreshAxes(device.rawAxisCount, self.pools.rawAxis, Rawaxis)
	self:RefreshButtons(device.rawButtonCount, self.pools.rawButton, Rawbutton)

	-- Refresh mapped values
	local device = C_GamePad.GetDeviceMappedState(deviceID)
	self:RefreshAxes(device.axisCount, self.pools.mapAxis, Mapaxis)
	self:RefreshButtons(device.buttonCount, self.pools.mapButton, Mapbutton)

	self.deviceID = deviceID;
	self:SetScript('OnUpdate', self.OnDeviceUpdate)
end

function Display:ReleaseAll()
	for _, pool in pairs(self.pools) do
		pool:ReleaseAll()
	end
end

function Display:Init()
	env.OpaqueMixin.OnLoad(self)
	self.pools = {
		rawAxis   = CreateFramePool('Slider', self.Child.Raw.Content.RawAxes,    'CPConfigAxisTemplate');
		mapAxis   = CreateFramePool('Slider', self.Child.Map.Content.MapAxes,    'CPConfigAxisTemplate');
		rawButton = CreateFramePool('Frame',  self.Child.Raw.Content.RawButtons, 'CPConfigRawButtonTemplate');
		mapButton = CreateFramePool('Frame',  self.Child.Map.Content.MapButtons, 'CPConfigRawButtonTemplate');
	};

	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, localEnv.PANEL_WIDTH, 32)
	self.Child:SetHeight(300)

	db:RegisterCallback('OnMapperDeviceChanged', self.OnDeviceChanged, self)
	self.Child.Config:Construct()
	self.Child.DeviceSelect:Construct()
end