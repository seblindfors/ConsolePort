local env = CPAPI.GetEnv(...);

---------------------------------------------------------------
local Display = {}; env.SharedConfig.Display = Display;
---------------------------------------------------------------

function Display:OnLoad()
	FrameUtil.SpecializeFrameWithMixins(self, CPBackgroundMixin)
	self:SetBackgroundInsets(4, -4, 4, 4)
	self:AddBackgroundMaskTexture(self.BorderArt.BgMask)
	self:SetBackgroundAlpha(0.25)

	self.Ring = env:CreateMockRing('$parentRing', self.RingContainer, env.SharedConfig.Ring)
	FrameUtil.SpecializeFrameWithMixins(self.Details, env.SharedConfig.Details)
end