local env, _, localenv = ConsolePortConfig:GetEnvironment(), ...;
local db, L = env.db, env.L;
----------------------------------------------------------------
local Data, Consts, Widgets = db.Data, env.MapperConsts, env.Widgets;
----------------------------------------------------------------
local PANEL_WIDTH, STATE_VIEW_HEIGHT = 960, 250;
local FIELD_WIDTH = 480;

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
	local hex = string.format('%x', number)
	return ((#hex % 2 == 1) and '0'..hex or hex):upper();
end

local function Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end


----------------------------------------------------------------
-- Device selection
----------------------------------------------------------------
-- Renders real devices in a list for individual mapping.

local DeviceSelect = {};

function DeviceSelect:Construct()
	local options = self:GetRawOptions()
	self:SetDrawOutline(true)
	self:SetText(L'Device')
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	Widgets.Select(self, 'DeviceID', nil, Data.Select(1, 1):SetRawOptions(options), 'Device Information')
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
	self:SetValue(device.axes[self:GetID()])
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

----------------------------------------------------------------
-- State update display handler
----------------------------------------------------------------
local Display = {};

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
	self.Child:SetMeasurementOrigin(self, self.Child, PANEL_WIDTH, 32)
	self.Child:SetHeight(300)

	db:RegisterCallback('OnMapperDeviceChanged', self.OnDeviceChanged, self)
	self.Child.Config:Construct()
	self.Child.DeviceSelect:Construct()
end

----------------------------------------------------------------
-- Simple sub-content wrapper
----------------------------------------------------------------
local Wrapper = {};

function Wrapper:OnClick()
	local checked = self:GetChecked()
	self.Content:SetShown(checked)
	self.Hilite:SetShown(not checked)
	self:SetHeight(checked and self.fixedHeight or 40)
end

function Wrapper:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('TOPLEFT', 16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
end

----------------------------------------------------------------
--//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
----------------------------------------------------------------
--                           Config                           --
----------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////--
----------------------------------------------------------------
local Carpenter, FieldSize = LibStub('Carpenter'), {FIELD_WIDTH - 32, 36};
local BaseMixin, FieldMixin = CreateFromMixins(env.ScaleToContentMixin), {}

function FieldMixin:Get()
	return self.controller:Get()
end

function FieldMixin:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 8, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
end

function BaseMixin:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('TOPLEFT', 8, 0)
	self.Label:SetJustifyH('LEFT')

	local blueprint = db.table.copy(self.Blueprint)
	for field, instructions in pairs(blueprint) do
		instructions._Type  = 'IndexButton';
		instructions._Size  = FieldSize;
		instructions._Setup = 'CPIndexButtonBindingHeaderTemplate';
		instructions._Point = instructions.point;
	end
	Carpenter:BuildFrame(self.Content, blueprint, false, true)

	for key, data in pairs(blueprint) do
		local widget = self.Content[key]
		local constructor = Widgets[data.field:GetType()]
		if constructor then
			Mixin(widget, FieldMixin)
			widget:SetText(data.text)
			widget:OnLoad()
			constructor(widget, widget.data, data, data.field, data.desc)
			widget.controller:SetCallback(function(...)
				print(...)
				-- TODO
			end)
		end
	end
	self:Hide()
	self:Show()
	self:SetMeasurementOrigin(self.Content, self.Content, FIELD_WIDTH - 20, 50)
	self:HookScript('OnClick', self.OnClick)
	self:SetWidth(FIELD_WIDTH - 20)
	self:SetDrawOutline(true)
end

function BaseMixin:OnClick(...)
	local expanded = self:GetChecked()
	self.Content:SetShown(expanded)
	self:SetHeight(not expanded and 40 or nil)
	self:SetHitRectInsets(0, 0, 0, expanded and self:GetHeight() - 40 or 0)
end

function BaseMixin:UpdateFields(data)
	for varID, value in pairs(data) do
		local field = self.Content[varID]
		if field then
			field:Set(type(value) == 'number' and Round(value, 5) or value)
		end
	end
end

----------------------------------------------------------------
-- AxisMap
----------------------------------------------------------------
--   int      rawIndex
--   axis     axis
--   [string] comment

local AxisMap = CreateFromMixins(BaseMixin, {
	Blueprint = {
		rawIndex = {
			point  = {'TOP', 0, -4};
			data   = 'rawIndex';
			text   = 'Raw Index';
			desc   = 'Raw axis index to map to named axis input.';
			field  = Data.Number(0, 1, false);
		};
		comment = {
			point  = {'TOP', '$parent.rawIndex', 'BOTTOM', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this axis.';
			field  = Data.String(nil);
		};
		axis = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis';
			desc   = 'Axis to map to.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
	};
})

function AxisMap:Set(data, i)
	self:SetText(('Raw Axis %s: |cffffffff%s|r'):format(
		data.rawIndex or Consts.Unassigned,
		data.axis or data.comment or Consts.Unassigned
	))
	self:UpdateFields(data)
end

----------------------------------------------------------------
-- ButtonMap
----------------------------------------------------------------
--   int      rawIndex
--   [button] button
--   [axis]   axis (must be set along with axisValue)
--   [float]  axisValue
--   [string] comment

local ButtonMap = CreateFromMixins(BaseMixin, {
	Blueprint = {
		rawIndex = {
			point  = {'TOP', 0, -4};
			data   = 'rawIndex';
			text   = 'Raw Index';
			desc   = 'Raw button index to map to named button input.';
			field  = Data.Number(0, 1, false);
		};
		comment = {
			point  = {'TOP', '$parent.rawIndex', 'BOTTOM', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this axis.';
			field  = Data.String(nil);
		};
		button = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'button';
			text   = 'Button';
			desc   = 'Optional button to map raw index to.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Buttons));
		};
		axis = {
			point  = {'TOP', '$parent.button', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis';
			desc   = 'Optional axis to map raw index to (requires axis value).';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		axisValue = {
			point  = {'TOP', '$parent.axis', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis Value';
			desc   = 'Optional axis value to control trigger point for selected axis.';
			field  = Data.Number(0.25, 0.1);
		};
	};
})

function ButtonMap:Set(data, i)
	self:SetText(('Raw Button %s: |cffffffff%s|r'):format(
		data.rawIndex or Consts.Unassigned,
		data.button or data.axis or Consts.Unassigned
	))
	self:UpdateFields(data)
end

----------------------------------------------------------------
-- AxisConfig
----------------------------------------------------------------
--   axis     axis
--   [string] comment
--   [button] buttonPos
--   [button] buttonNeg
--   [float]  shift (Value shift when mapping from a raw axis)
--   [float]  scale (Value scale when mapping from a raw axis)
--   [float]  deadzone (deadzone applied when mapping from a raw axis)
--   [float]  buttonThreshold (Must be set if setting buttonPos or buttonNeg)

local AxisConfig = CreateFromMixins(BaseMixin, {
	Blueprint = {
		comment = {
			point  = {'TOP', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this axis.';
			field  = Data.String(nil);
		};
		axis = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis';
			desc   = 'Axis to configure.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		buttonPos = {
			point  = {'TOP', '$parent.axis', 'BOTTOM', 0, -4};
			data   = 'buttonPos';
			text   = 'Button Positive';
			desc   = 'Button to press at positive value above threshold.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Buttons));
		};
		buttonNeg = {
			point  = {'TOP', '$parent.buttonPos', 'BOTTOM', 0, -4};
			data   = 'buttonNeg';
			text   = 'Button Negative';
			desc   = 'Button to press at negative value above threshold.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Buttons));
		};
		shift = {
			point  = {'TOP', '$parent.buttonNeg', 'BOTTOM', 0, -4};
			data   = 'shift';
			text   = 'Shift';
			desc   = 'Shifts the axis value by a constant to mapped range.';
			field  = Data.Number(0, 0.1);
		};
		scale = {
			point  = {'TOP', '$parent.shift', 'BOTTOM', 0, -4};
			data   = 'scale';
			text   = 'Scale';
			desc   = 'Scales the axis value to work in mapped range.';
			field  = Data.Number(0, 0.1);
		};
		deadzone = {
			point  = {'TOP', '$parent.scale', 'BOTTOM', 0, -4};
			data   = 'deadzone';
			text   = 'Deadzone';
			desc   = 'Deadzone applied to ignore axis input from raw state.';
			field  = Data.Number(0.25, 0.1);
		};
		buttonThresh = {
			point  = {'TOP', '$parent.deadzone', 'BOTTOM', 0, -4};
			data   = 'buttonThreshold';
			text   = 'Button Threshold';
			desc   = 'Threshold for button input, range from 0-1.';
			field  = Data.Number(0.5, 0.1);
		};
	};
});

function AxisConfig:Set(axis, i)
	self:SetText(axis.comment or axis.axis or L('Mapped Axis %d', tostring(i)))
	self:UpdateFields(axis)
end

----------------------------------------------------------------
-- StickConfig
----------------------------------------------------------------
--   stick    stick
--   axis     axisX
--   axis     axisY
--   [float]  deadzone
--   [string] comment

local StickConfig = CreateFromMixins(BaseMixin, {
	Blueprint = {
		comment = {
			point  = {'TOP', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this stick.';
			field  = Data.String(nil);
		};
		stick = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'stick';
			text   = 'Stick';
			desc   = 'Stick to configure.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Sticks));
		};
		axisX = {
			point  = {'TOP', '$parent.stick', 'BOTTOM', 0, -4};
			data   = 'axisX';
			text   = 'Axis X';
			desc   = 'Which axis to use as horizontal value for the stick input.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		axisY = {
			point  = {'TOP', '$parent.axisX', 'BOTTOM', 0, -4};
			data   = 'axisY';
			text   = 'Axis Y';
			desc   = 'Which axis to use as vertical value for the stick input.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		deadzone = {
			point  = {'TOP', '$parent.axisY', 'BOTTOM', 0, -4};
			data   = 'deadzone';
			text   = 'Deadzone';
			desc   = 'Deadzone applied when normalizing the stick input length.';
			field  = Data.Number(0.25, 0.1);
		};
	};
})

function StickConfig:Set(stick, i)
	self:SetText(stick.comment or stick.stick or L('Stick %d', tostring(i)))
	self:UpdateFields(stick)
end

local Config = CreateFromMixins(Wrapper, env.ScaleToContentMixin)

function Config:OnLoad()
	Wrapper.OnLoad(self)
	self:SetHeight(40)
	self:SetMeasurementOrigin(self.Content, self.Content, PANEL_WIDTH - 32, 0)
end

function Config:LayoutData(set, pool, mixin, sort)
	local prev1, prev2;
	if sort then
		table.sort(set, sort)
	end
	for i, data in ipairs(set) do
		local widget, newObj = pool:Acquire()
		if newObj then
			Mixin(widget, mixin)
			widget:OnLoad()
		end
		widget:Set(data, i)
		widget:Show()

		-- odd
		if ((i-1) % 2 == 0) then
			if not prev1 then
				widget:SetPoint('TOPLEFT', 16, -24)
			else
				widget:SetPoint('TOP', prev1, 'BOTTOM', 0, -8)
			end
			prev1 = widget;
		else -- even
			if not prev2 then
				widget:SetPoint('TOPRIGHT', -16, -24)
			else
				widget:SetPoint('TOP', prev2, 'BOTTOM', 0, -8)
			end
			prev2 = widget;
		end
	end
	pool.parent:SetHeight(ceil(#set/2) * 40 + 40)
	pool.parent.forbidRecursiveScale = false;
end

function Config:OnDeviceChanged(device, deviceID)
	self:ReleaseAll()

	local config = C_GamePad.GetConfig({
		vendorID  = device.vendorID;
		productID = device.productID; 
	})

	self:LayoutData(config.rawAxisMappings, self.pools.axisMap, AxisMap, function(a, b) return a.rawIndex < b.rawIndex; end)
	self:LayoutData(config.rawButtonMappings, self.pools.buttonMap, ButtonMap, function(a, b) return a.rawIndex < b.rawIndex; end)
	self:LayoutData(config.axisConfigs, self.pools.axisConfig, AxisConfig)
	self:LayoutData(config.stickConfigs, self.pools.stickConfig, StickConfig)

	C = config --REMOVE
end

function Config:ReleaseAll()
	for _, pool in pairs(self.pools) do
		pool:ReleaseAll()
	end
end

function Config:Construct()
	self.pools = {
		axisMap     = CreateFramePool('IndexButton', self.Content.RawAxisBlock, 'CPIndexButtonBindingHeaderTemplate');
		buttonMap   = CreateFramePool('IndexButton', self.Content.RawButtonBlock, 'CPIndexButtonBindingHeaderTemplate');
		axisConfig  = CreateFramePool('IndexButton', self.Content.MappedAxisBlock, 'CPIndexButtonBindingHeaderTemplate');
		stickConfig = CreateFramePool('IndexButton', self.Content.StickBlock, 'CPIndexButtonBindingHeaderTemplate');
	};

	Wrapper.OnLoad(self)
	db:RegisterCallback('OnMapperDeviceChanged', self.OnDeviceChanged, self)
end

----------------------------------------------------------------
----------------------------------------------------------------
local Panel, BlockMixin = env.Mapper, CreateFromMixins(env.ScaleToContentMixin);

function BlockMixin:OnLoad()
	self:SetMeasurementOrigin(self, self, PANEL_WIDTH, 0)
	self.Label = self:CreateFontString()
	self.Label:SetPoint('TOPLEFT', 24, -6)
	self.Label:SetFontObject(GameFontGreen)
	self.Label:SetText(self.text)
end

function Panel:OnFirstShow()
	local config = self:CreateScrollableColumn('Config', {
		_Mixin = Display;
		_Width = PANEL_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 0, 1};
			{'BOTTOMLEFT', 0, -1};
		};
		{
			Flexer = {
				_Type = 'CheckButton';
				_Setup = 'BackdropTemplate';
				_Mixin = env.FlexibleMixin;
				_Width = 24;
				_Points = {
					{'TOPLEFT', 'parent', 'TOPRIGHT', 0, 0};
					{'BOTTOMLEFT', 'parent', 'BOTTOMRIGHT', 0, 0};
				};
				_Backdrop = CPAPI.Backdrops.Opaque;
				_SetBackdropBorderColor = {0.15, 0.15, 0.15, 1};
				_SetNormalTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				_SetHighlightTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				['state'] = true;
				_OnLoad = function(self)
					local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
					self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
					self.Center:SetGradientAlpha('HORIZONTAL', r*2, g*2, b*2, 1, r/1.25, g/1.25, b/1.25, 1)
					local normal = self:GetNormalTexture()
					local hilite = self:GetHighlightTexture()
					normal:ClearAllPoints()
					normal:SetPoint('CENTER', -1, 0)
					normal:SetSize(16, 32)
					hilite:ClearAllPoints()
					hilite:SetPoint('CENTER', -1, 0)
					hilite:SetSize(16, 32)
					EquipmentFlyoutPopoutButton_SetReversed(self, true)
					self:SetFlexibleElement(self:GetParent(), PANEL_WIDTH)
					self:SetChecked(true)
				end;
				_OnClick = function(self)
					local enabled = self:GetChecked()
					EquipmentFlyoutPopoutButton_SetReversed(self, self:GetChecked())
					self:ToggleFlex(enabled)
				end;
			};
			Child = {
				_Width = PANEL_WIDTH;
				{
					DeviceSelect = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Mixin = DeviceSelect;
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', 0, -32};
						{
							TopText = {
								_Type = 'FontString';
								_Point = {'BOTTOMLEFT', '$parent', 'TOPLEFT', 8, 8};
								_OnLoad = function(self)
									self:SetFontObject(GameFontNormal)
									self:SetText(L'Selected device:')
								end;
							};
						};
					};
					Raw = {
						_Type  = 'IndexButton';
						_Mixin = Wrapper;
						_Text  = L'Raw state';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', '$parent.DeviceSelect', 'BOTTOM', 0, -8};
						fixedHeight = STATE_VIEW_HEIGHT;
						{
							Content = {
								{
									RawAxes = {
										_Type = 'Frame';
										_Point = {'TOPRIGHT', '$parent', 'TOP', 0, 0};
										_Height = 200;
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Raw Axes:')
												end;
											};
										};
									};
									RawButtons = {
										_Type  = 'Frame';
										_Point = {'TOPLEFT', '$parent', 'TOP', 0, 0};
										_Size  = {240, 200};
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Raw Buttons:')
												end;
											};
										};
									};
								};
							};
						};
					};
					Map = {
						_Type  = 'IndexButton';
						_Mixin = Wrapper;
						_Text  = L'Mapped state';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', '$parent.Raw', 'BOTTOM', 0, -8};
						fixedHeight = STATE_VIEW_HEIGHT;
						{
							Content = {
								{
									MapAxes = {
										_Type = 'Frame';
										_Point = {'TOPRIGHT', '$parent', 'TOP', 0, 0};
										_Height = 200;
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Mapped Axes:')
												end;
											};
										};
									};
									MapButtons = {
										_Type  = 'Frame';
										_Point = {'TOPLEFT', '$parent', 'TOP', 0, 0};
										_Size  = {240, 200};
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Mapped Buttons:')
												end;
											};
										};
									};
								};
							};
						};
					};
					Config = {
						_Type  = 'IndexButton';
						_Mixin = Config;
						_Text  = L'Configuration';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', '$parent.Map', 'BOTTOM', 0, -8};
						{
							Content = {
								{
									RawAxisBlock = {
										text   = L'Raw Axis -> Mapped Axis';
										struct = 'rawAxisMappings';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', 0, 0};
									};
									RawButtonBlock = {
										text   = L'Raw Button -> Mapped Button';
										struct = 'rawButtonMappings';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', '$parent.RawAxisBlock', 'BOTTOM', 0, 0};
									};
									MappedAxisBlock = {
										text   = L'Mapped Axes';
										struct = 'axisConfigs';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', '$parent.RawButtonBlock', 'BOTTOM', 0, 0};
									};
									StickBlock = {
										text   = L'Stick Configuration';
										struct = 'stickConfigs';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', '$parent.MappedAxisBlock', 'BOTTOM', 0, 0};
									};
								};
							};
						};
					};
				};
			};
		};
	})
	config:Init()
end