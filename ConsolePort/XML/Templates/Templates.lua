local _, db = ...;

---------------------------------------------------------------
CPAtlasMixin = { useAtlasSize = true };
---------------------------------------------------------------

function CPAtlasMixin:OnLoad()
	if self.atlas then
		self:ApplyAtlas()
	end
end

function CPAtlasMixin:SetAtlas(atlas, useAtlasSize, flipHorz, flipVert, hWrapMode, vWrapMode, sm) sm = sm or {};
	self.flipHorz,   self.flipVert = flipHorz, flipVert;
	self.hWrapMode, self.vWrapMode = hWrapMode, vWrapMode;
	self.sliceMode, self.sliceLeft, self.sliceRight, self.sliceTop, self.sliceBottom
	= sm.sliceMode,   sm.sliceLeft,   sm.sliceRight,   sm.sliceTop,   sm.sliceBottom;
	self:SwapAtlas(atlas, useAtlasSize);
end

function CPAtlasMixin:SwapAtlas(atlas, useAtlasSize)
	self.atlas, self.useAtlasSize = atlas, useAtlasSize;
	self:ApplyAtlas()
end

function CPAtlasMixin:ApplyAtlas()
	CPAPI.SetAtlas(self,
		self.atlas,
		self.useAtlasSize,
		self.flipHorz,
		self.flipVert,
		self.hWrapMode,
		self.vWrapMode,
		self.sliceMode and {
			sliceMode    = self.sliceMode;
			marginLeft   = self.sliceLeft;
			marginRight  = self.sliceRight;
			marginTop    = self.sliceTop;
			marginBottom = self.sliceBottom;
		}
	);
end

---------------------------------------------------------------
CPFrameMixin = {};
---------------------------------------------------------------

function CPFrameMixin:OnLoad()
	if self.layoutAtlas then
		self.Center = self:CreateTexture(nil, 'BACKGROUND', nil, -7)
		self.Center:SetAllPoints()
		CPAPI.SetAtlas(self.Center, self.layoutAtlas)
		self.layoutRegions = { Center = self.Center };
		if self.layoutScale then
			self.Center:SetScale(self.layoutScale)
		end
	end
	if self.layoutType then
		CPAPI.Specialize(self, NineSlicePanelMixin)
		if C_Widget.IsRenderableWidget(self.BgMask) then
			self:SetBackgroundMask(self.BgMask)
		end
	end
	self:SetBackgroundAlpha(self.layoutAlpha)
end

function CPFrameMixin:GetBackgroundRegions()
	return self.layoutAtlas and self.layoutRegions or NineSliceLayouts[self.layoutType];
end

function CPFrameMixin:SetBackgroundAlpha(alpha)
	self.layoutAlpha = alpha;
	local regions = self:GetBackgroundRegions()
	if not regions then return end;
	for region in pairs(regions) do
		if self[region] then
			self[region]:SetAlpha(self.layoutAlpha);
		end
	end
end

function CPFrameMixin:SetBackgroundMask(mask)
	local regions = self:GetBackgroundRegions()
	if not regions then return end;
	for region in pairs(regions) do
		if self[region] then
			self[region]:AddMaskTexture(mask);
		end
	end
end

---------------------------------------------------------------
CPSmoothButtonMixin = {}
---------------------------------------------------------------

function CPSmoothButtonMixin:OnLoad()
	self:SetBackdrop({
		bgFile   = CPAPI.GetAsset('Textures\\Frame\\Backdrop_Gossip.blp');
		edgeFile = CPAPI.GetAsset('Textures\\Frame\\Edge_Gossip_BG.blp');
		edgeSize = 4;
		insets   = {left = 2, right = 2, top = 2, bottom = 2};
	})
	self.Overlay:SetBackdrop({
		edgeFile = CPAPI.GetAsset('Textures\\Frame\\Edge_Gossip_Normal.blp');
		edgeSize = 4;
	})
	self.Hilite:SetBackdrop({
		edgeFile = CPAPI.GetAsset('Textures\\Frame\\Edge_Gossip_Hilite.blp');
		edgeSize = 4;
	})
	self.Overlay:SetFrameLevel(self.Overlay:GetFrameLevel() + 1)
	self.Hilite:SetFrameLevel(self.Overlay:GetFrameLevel() + 1)
end

function CPSmoothButtonMixin:OnHide()
	self:OnLeave()
	db.Alpha.FadeOut(self, 0.1, self:GetAlpha(), 0)
end

function CPSmoothButtonMixin:OnShow()
	self:Animate()
end

function CPSmoothButtonMixin:Animate()
	C_Timer.After((self:GetID() or 1) * 0.01, function()
		db.Alpha.FadeIn(self, 0.1, self:GetAlpha(), 1)
	end)
end

function CPSmoothButtonMixin:Image(texture)
	self.Icon:SetTexture(('Interface\\Icons\\%s'):format(texture))
end

function CPSmoothButtonMixin:CustomImage(texture)
	self.Icon:SetTexture(texture)
end

function CPSmoothButtonMixin:SetPulse(enabled)
	if enabled then
		db.Alpha.Flash(self.Hilite, 0.5, 0.5, -1, true, 0.2, 0.1)
	else
		db.Alpha.Stop(self.Hilite, 0)
	end
end

function CPSmoothButtonMixin:OnEnter()
	self:LockHighlight()
	if self.Hilite.flashTimer then
		db.Alpha.Stop(self.Hilite, self.Hilite:GetAlpha())
	end
	db.Alpha.FadeIn(self.Hilite, 0.15, self.Hilite:GetAlpha(), 1)
end

function CPSmoothButtonMixin:OnLeave()
	self:UnlockHighlight()
	db.Alpha.FadeOut(self.Hilite, 0.2, self.Hilite:GetAlpha(), 0)
end

---------------------------------------------------------------
CPAnimatedLootHeaderMixin = {};
---------------------------------------------------------------

function CPAnimatedLootHeaderMixin:SetDurationMultiplier(multiplier)
	for _, animation in ipairs({self.HeaderOpenAnim:GetAnimations()}) do
		animation:SetDuration(animation:GetDuration() * multiplier)
	end
end

function CPAnimatedLootHeaderMixin:Play()
	self.HeaderOpenAnim:Stop()
	self.HeaderOpenAnim:Play()
end

function CPAnimatedLootHeaderMixin:SetText(...)
	self.Text:SetText(...)
end

---------------------------------------------------------------
CPSwatchHighlightMixin = {};
---------------------------------------------------------------

function CPSwatchHighlightMixin:SetTexture(texture)
	self.SwatchMask:SetTexture(texture)
end

function CPSwatchHighlightMixin:SetTexCoord(...)
	self.SwatchMask:SetTexCoord(...)
end

---------------------------------------------------------------
CPToolbarSixSliceInverterMixin = {};
---------------------------------------------------------------

function CPToolbarSixSliceInverterMixin:ToggleInversion(invert)
	local tLeft  = self.TopLeftCorner;
	local tRight = self.TopRightCorner;
	local bLeft  = self.BottomLeftCorner;
	local bRight = self.BottomRightCorner;
	local left   = self.LeftEdge;
	local right  = self.RightEdge;

	tLeft:SetShown(not invert)
	tRight:SetShown(not invert)
	bLeft:SetShown(invert)
	bRight:SetShown(invert)

	self.TopEdge:SetShown(not invert)
	self.BottomEdge:SetShown(invert)

	left:ClearAllPoints()
	right:ClearAllPoints()

	if not invert then
		left:SetPoint('TOPLEFT', tLeft, 'BOTTOMLEFT', 0, 0)
		left:SetPoint('BOTTOMLEFT', 0, 0)
		right:SetPoint('TOPRIGHT', tRight, 'BOTTOMRIGHT', 0, 0)
		right:SetPoint('BOTTOMRIGHT', 0, 0)
	else
		left:SetPoint('TOPLEFT', -34, 0)
		left:SetPoint('BOTTOMRIGHT', bLeft, 'TOPRIGHT', 0, 0)
		right:SetPoint('TOPRIGHT', 34, 0)
		right:SetPoint('BOTTOMLEFT', bRight, 'TOPLEFT', 0, 0)
	end
end

function CPToolbarSixSliceInverterMixin:SetBackgroundAlpha(alpha)
	for piece in pairs(NineSliceLayouts.CharacterCreateDropdown) do
		if self[piece] then
			self[piece]:SetAlpha(alpha)
		end
	end
end