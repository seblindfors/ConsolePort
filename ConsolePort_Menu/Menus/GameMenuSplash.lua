local _, env = ...;
local Splash = CreateFromMixins(CPButtonMixin); env.SplashButtonMixin = Splash;

function Splash:Initialize(menu)
	self.ringWidth = 116 * 0.8;
	self.ringHeight = 117 * 0.8;
	self.checkedTextureSize = 99 * 0.8;
	CPButtonMixin.OnLoad(self)
	self:HookScript('PreClick', self.PreClick)

	local mask = self.CircleMask;
	mask:SetTexture(CPAPI.GetAsset([[Textures\Button\Icon_Mask64_Reverse]]), 'CLAMPTOWHITE')
	menu.Background:AddMaskTexture(mask)
	menu.Rollover:AddMaskTexture(mask)
	menu.BG:AddMaskTexture(mask)
end

function Splash:OnClear()
	self:SetChecked(false)
	self:StopFlash()
	self.BackgroundFrame:Hide()

	env.db.Alpha.FadeOut(self.ContentFrame, 0.1, self.ContentFrame:GetAlpha(), 0, {
		finishedFunc = self.ContentFrame.Hide;
		finishedArg1 = self.ContentFrame;
	})
end

function Splash:PreClick()
	if self.ContentFrame:IsShown() then
		self.clearOnFocus = true;
	end
end

function Splash:OnFocus()
	if self.clearOnFocus then
		self.clearOnFocus = nil;
		return self:OnClear()
	end
	
	self:SetChecked(true)
	self:StartFlash()
	self.BackgroundFrame:Show()

	if not self.contentFrameLoaded then
		local configLoaded = IsAddOnLoaded('ConsolePort_Config');
		if not configLoaded then
			configLoaded = LoadAddOn('ConsolePort_Config')
		end

		if configLoaded then
			self.contentFrameLoaded = true;
			env.db.table.mixin(self.ContentFrame, ConsolePortConfig:GetEnvironment().Overview)
			self.ContentFrame:OnLoad()
		end
	end

	self.ContentFrame:Show()
end