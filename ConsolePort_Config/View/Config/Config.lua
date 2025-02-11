local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Container = {};
---------------------------------------------------------------

function Container:OnLoad()
    FrameUtil.SpecializeFrameWithMixins(self, CPBackgroundMixin)
    self:SetBackgroundInsets(4, -4, 4, 4)
    self:AddBackgroundMaskTexture(self.BorderArt.BgMask)
    self:SetBackgroundAlpha(0.25)
end

---------------------------------------------------------------
local Config = CreateFromMixins(CPButtonCatcherMixin); env.Config = Config;
---------------------------------------------------------------

function Config:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)

    self.NavBar:AddButton('Interface')
    self.NavBar:AddButton('Gamepad')
    self.NavBar:AddButton('Help')
end

function Config:OnShow()
	FrameUtil.UpdateScaleForFit(self, 40, 80)
	FrameUtil.SpecializeFrameWithMixins(self.Container, Container)
end