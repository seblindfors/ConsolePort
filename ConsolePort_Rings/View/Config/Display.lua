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

	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
end

function Display:OnTabSelected(tabIndex, panels)
	-- The options panel is in need of slightly more visual clarity
	self:SetBackgroundAlpha(tabIndex == panels.Options and 0.1 or 0.25)
end