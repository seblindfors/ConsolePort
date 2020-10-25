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

LibStub:GetLibrary('Carpenter'):BuildFrame(Config, {
	DefaultFrame = {
		_Type = 'Frame';
		_Points = {
			{'TOPLEFT', '$parent.Container', 'TOPLEFT', 0, 0};
			{'BOTTOMRIGHT', '$parent.Container', 'BOTTOMRIGHT', 0, 0};
		};
		{
			Logo = {
				_Type = 'Texture';
				_Size = {128, 128};
				_Texture = CPAPI.GetAsset('Textures\\Logo\\CP');
				_Point = {'TOP', 0, -100};
			};
		};
	};
})