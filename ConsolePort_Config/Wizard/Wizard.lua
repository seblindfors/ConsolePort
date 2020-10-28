local db, _, env = ConsolePort:DB(), ...; local L = db('Locale');
---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local WIZARD_WIDTH, FIXED_OFFSET, DEVICE_PER_ROW = 900, 8, 3;
local DEVICE_WIDTH, DEVICE_HEIGHT = 250, 100;

---------------------------------------------------------------
-- Content
---------------------------------------------------------------
local WizardContent = {};

function WizardContent:OnLoad()
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, WIZARD_WIDTH, FIXED_OFFSET * 5)
	-- pools
	self.DevicePool = CreateFramePool('IndexButton', self.Child.Devices, 'CPConfigWizardDeviceButton')
	self:OnShow()
end

function WizardContent:AddDevice(name, device)
	local widget, newObj = self.DevicePool:Acquire()
	if newObj then
		db.table.mixin(widget, env.DeviceSelectMixin)
		widget:SetDrawOutline(true)
	end
	widget.ID = name;
	widget.Device = device;
	widget:Show()
	return widget;
end

function WizardContent:UpdateDevices()
	self.DevicePool:ReleaseAll()
	local usableDevices = {};
	for name, device in db:For('Gamepad/Devices', true) do
		if device.Theme then
			tinsert(usableDevices, self:AddDevice(name, device))
		end
	end

	local containerHeight, prev = 0;
	for i, device in ipairs(usableDevices) do
		device:SetSiblings(usableDevices)
		if (i % DEVICE_PER_ROW == 1) then
			device:SetPoint('TOPLEFT', 0, containerHeight)
		else
			if (i % DEVICE_PER_ROW == 0) then
				containerHeight = containerHeight + DEVICE_HEIGHT + FIXED_OFFSET;
			end
			device:SetPoint('LEFT', prev, 'RIGHT', FIXED_OFFSET, 0)
		end
		prev = device;
	end

	local containerWidth;
	if (#usableDevices > DEVICE_PER_ROW) then
		containerWidth = (DEVICE_PER_ROW * DEVICE_WIDTH) + (FIXED_OFFSET * (DEVICE_PER_ROW - 1))
	else
		containerWidth = (#usableDevices * DEVICE_WIDTH) + (FIXED_OFFSET * (#usableDevices - 1))
	end
	self.Child.Devices:SetSize(containerWidth, containerHeight + DEVICE_HEIGHT)
end

function WizardContent:OnShow()
	self:UpdateDevices()
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
local Wizard = {};

function Wizard:OnShow()
	if self.OnFirstShow then
		self:OnFirstShow()
		self.OnFirstShow = nil;
	end
	db('Alpha/FadeIn')(self, 1)
end

function Wizard:OnFirstShow()
	self:SetAllPoints()
	local content = self:CreateScrollableColumn('Setup', {
		_Mixin = WizardContent;
		_Width = WIZARD_WIDTH;
		_Setup = {'CPSmoothScrollTemplate'};
		_Points = {
			{'TOP', 0, 0};
			{'BOTTOM', 0, 0};
		};
		{
			Child = {
				_Width = WIZARD_WIDTH;
				{
					Logo = {
						_Type = 'Texture';
						_Size = {128, 128};
						_Point = {'TOP', 0, -100};
						_Texture = CPAPI.GetAsset('Textures\\Logo\\CP');
					};
					Help = {
						_Type = 'FontString';
						_Point = {'TOP', '$parent.Logo', 'BOTTOM', 0, -FIXED_OFFSET};
						_OnLoad = function(self)
							self:SetFontObject(CPHeaderFont);
							self:SetText(L'Select your device.');
						end;
					};
					Devices = {
						_Type = 'Frame';
						_Point = {'TOP', '$parent.Help', 'BOTTOM', 0, -FIXED_OFFSET * 2};
					};
					Variables = {
						_Type  = 'Frame';
						_Mixin = env.VariablesMixin;
						_Width = WIZARD_WIDTH;
						_Point = {'TOP', '$parent.Devices', 'BOTTOM', 0, -FIXED_OFFSET * 2};
					};
				};
			};
		};
	})
end

env.Wizard = ConsolePortConfig:CreatePanel({
	name  = 'Wizard';
	mixin = Wizard;
	noHeader = true;
	scaleToParent = true;
	forbidRecursiveScale = true;
})

-- Set as default frame
ConsolePortConfig.DefaultFrame = env.Wizard;
ConsolePortConfig:ShowDefaultFrame(true)