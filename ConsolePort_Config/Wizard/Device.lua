local db, _, env = ConsolePort:DB(), ...;
---------------------------------------------------------------
-- Device
---------------------------------------------------------------
local Device = {}; env.DeviceSelectMixin = Device;

function Device:OnClick()
	local device = self.Device;
	device:ApplyPresetVars()
	CPAPI.Popup('ConsolePort_Reset_Keybindings', {
		text = CONFIRM_RESET_KEYBINDINGS;
		button1 = OKAY;
		button2 = CANCEL;
		timeout = 0;
		whileDead = 1;
		showAlert = 1;
		OnAccept = function()
			device:ApplyPresetBindings(GetCurrentBindingSet())
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
	self.Splash:SetTexture(([[Interface\AddOns\ConsolePort\Model\Gamepad\%s\Assets\Splash]]):format(self.ID))
	self.Splash:SetVertexColor(0.35, 0.35, 0.35, 1)
	self.Splash:SetTexCoord(10/1024, 492/1024, 160/1024, 820/1024, 820/1024, 110/1024, 975/1024, 435/1024)
	self.Name:SetText(self.ID)
end