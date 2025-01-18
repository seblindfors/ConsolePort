local _, env = ...; local L, db = env.L, env.db;
local WIZARD_WIDTH, FIXED_OFFSET, DEVICE_PER_ROW = 900, 8, 3;
local DEVICE_WIDTH, DEVICE_HEIGHT = 250, 100;
---------------------------------------------------------------
-- Device
---------------------------------------------------------------
local Device = {};

function Device:OnClick()
	local device = self.Device;
	ConsolePort:SetCursorNode(env.Splash.Wizard.Child.Continue, true)
	CPAPI.Popup('ConsolePort_Apply_Preset', {
		text = L('Do you want to load settings for %s?\n\nThis will configure your modifiers, mouse emulation buttons, and previously saved device settings (if any).', device.Name);
		button1 = OKAY;
		button2 = CANCEL;
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
				button1 = OKAY;
				button2 = CANCEL;
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
	self:UpdateState()
end

function Device:UpdateState()
	local isActive = self.Device.Active;
	self:SetChecked(isActive and true or false)
	self:OnChecked(isActive and true or false)
	self:SetAttribute('nodepriority', isActive and 1 or 2)
end

function Device:OnShow()
	self:UpdateState()
	self.Splash:SetTexture(CPAPI.GetAsset('Splash\\Gamepad\\'..db('Gamepad/Index/Splash/'..self.ID)))
	self.Splash:SetVertexColor(0.35, 0.35, 0.35, 1)
	self.Splash:SetTexCoord(10/1024, 492/1024, 160/1024, 820/1024, 820/1024, 110/1024, 975/1024, 435/1024)
	self.Name:SetText(self.ID)
end


---------------------------------------------------------------
-- Device selector
---------------------------------------------------------------
local Devices = {}; env.DeviceSelector = Devices;

function Devices:OnLoad()
	self.DevicePool = CreateFramePool('IndexButton', self, 'CPConfigWizardDeviceButton')
end

function Devices:OnShow()
	self:UpdateDevices()
end

function Devices:AddDevice(name, device)
	local widget, newObj = self.DevicePool:Acquire()
	if newObj then
		db.table.mixin(widget, Device)
		widget:SetDrawOutline(true)
	end
	widget.ID = name;
	widget.Device = device;
	widget:Show()
	return widget;
end

function Devices:GetFirstDeviceStyle()
	for _, i in ipairs(C_GamePad.GetAllDeviceIDs()) do
		local state = C_GamePad.GetDeviceMappedState(i)
		if (state and state.labelStyle and not(state.labelStyle == 'Generic')) then
			return state.labelStyle, state.name;
		end
	end
end

function Devices:UpdateDevices()
	self.DevicePool:ReleaseAll()
	local usableDevices = {};
	for name, device in db:For('Gamepad/Devices', true) do
		if device.Theme then
			tinsert(usableDevices, self:AddDevice(name, device))
		end
	end

	local connectedStyle, connectedName = self:GetFirstDeviceStyle();
	local connectedDeviceWidget;
	local connectedIsNameMatched = false; -- A name matched device will be preferred

	local containerHeight, prev = 0;
	for i, device in ipairs(usableDevices) do
		device:SetSiblings(usableDevices)
		if (i % DEVICE_PER_ROW == 1) then
			device:SetPoint('TOPLEFT', 0, -containerHeight)
		else
			if (i % DEVICE_PER_ROW == 0) then
				containerHeight = containerHeight + DEVICE_HEIGHT + FIXED_OFFSET;
			end
			device:SetPoint('LEFT', prev, 'RIGHT', FIXED_OFFSET, 0)
		end
		if (connectedStyle and (device.Device.LabelStyle == connectedStyle)) then
			if (device.Device.StyleNameSubStrs) then
				-- This device must also have a name substring match
				for _, subStr in ipairs(device.Device.StyleNameSubStrs) do
					if (string.find(connectedName, subStr)) then
						connectedDeviceWidget = device;
						connectedIsNameMatched = true;
						break
					end
				end
			elseif (not connectedIsNameMatched) then
				-- A style match is sufficient for this device
				connectedDeviceWidget = device;
			end
		end
		prev = device;
	end

	local containerWidth;
	if (#usableDevices > DEVICE_PER_ROW) then
		containerWidth = (DEVICE_PER_ROW * DEVICE_WIDTH) + (FIXED_OFFSET * (DEVICE_PER_ROW - 1))
	else
		containerWidth = (#usableDevices * DEVICE_WIDTH) + (FIXED_OFFSET * (#usableDevices - 1))
	end
	self:SetSize(containerWidth, containerHeight + DEVICE_HEIGHT)

	if (connectedDeviceWidget) then
		local activeDevice = db.Gamepad:GetActiveDevice();
		if (not activeDevice) then
			RunNextFrame(function()
				ConsolePort:SetCursorNode(connectedDeviceWidget, false, true);
			end);
		end
	end
end