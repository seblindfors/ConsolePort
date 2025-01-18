---------------------------------------------------------------
CPInnerFrameMixin = CreateFromMixins(CPFrameMixin);
---------------------------------------------------------------

function CPInnerFrameMixin:OnLoad()
	CPFrameMixin.OnLoad(self)
	if self.layoutAtlas then
		self.layoutRegions.InnerBackground = self.InnerBackground;
		self.InnerBackground:SetPoint('TOPLEFT', self.Center, 'TOPLEFT', 0, 0)
		self.InnerBackground:SetPoint('BOTTOMRIGHT', self.Center, 'BOTTOMRIGHT', 0, self.bottomPadding)
		self.InnerBackgroundEdge:SetAllPoints(self.Center)
		CPAPI.SetAtlas(self.InnerBackgroundEdge, self.layoutAtlas)
	end
	if self.layoutScale then
		self.InnerBackgroundEdge:SetScale(self.layoutScale)
	end
end