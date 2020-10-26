local b = CreateFrame('Button', 'ConfigB', UIParent, 'SecureActionButtonTemplate')
b:SetAttribute('type', 'macro')
b:SetAttribute('macrotext', '/run ConsolePortConfig:SetShown(not ConsolePortConfig:IsShown())')
SetOverrideBindingClick(b, true, 'K', 'ConfigB')

local _, env = ...;
local Config = ConsolePortConfig; env.Config = Config;

Config:SetMinResize(1000, 700)
Config:SetScript('OnMouseWheel', function(self, delta, ...)
	local f = IsShiftKeyDown() and PixelUtil.SetHeight or IsControlKeyDown() and PixelUtil.SetWidth
	local g = IsShiftKeyDown() and self.GetHeight or IsControlKeyDown() and self.GetWidth
	if f and g then
		f(self, g(self) + (delta * 10))
	end
end)

local db = ConsolePort:DB()

function Config:OnActiveDeviceChanged()
	local hasActiveDevice = db('Gamepad/Active') and true or false;
	self.Header:ToggleEnabled(hasActiveDevice)
end

function Config:OnShow()
	self:OnActiveDeviceChanged()
end

CPAPI.Start(Config)
db:RegisterCallback('Gamepad/Active', Config.OnActiveDeviceChanged, Config)