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
		FrameUtil.SpecializeFrameWithMixins(self, NineSlicePanelMixin)
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
CPFlashableFiligreeMixin = {
---------------------------------------------------------------
	Durations = {
		ActivationExpandFxScale     = 1.4;
		ActivationExpandFxAlpha     = 1.4;
		ActivationFx1Alpha          = 1.2;
		ActivationFx2Alpha          = 1.2;
		ActivationFx3Alpha          = 0.3;
		ActivationFx4Alpha          = 0.5;
		ActivationFx3Scale          = 0.3;
		ActivationFx4Scale          = 0.5;
	};
	Ratios = {
		Container                   = { x =  806 / 230, y = 300 / 230 };
		ActivationExpandFx          = { x =  160 / 230, y = 160 / 230 };
		ActivationExpandFxMask      = { x = 1209 / 230, y = 558 / 230 };
		ActivationExpandFxScale     = { x =   10 / 230, y =  10 / 230 };
		ActivationExpandFxMaskPoint = { x =  130 / 230, y = -60 / 230 };
	};
};

function CPFlashableFiligreeMixin:OnLoad()
	local r, g, b = CPAPI.GetClassColor()
	CPAPI.SetAtlas(self.ActivationExpandFx, 'animations-gridburst', false)
	self:SetVertexColor(r, g, b, 1)
	self:SetClassEmblem()
end

function CPFlashableFiligreeMixin:Stop(...)
	self.filigreeAnim:Stop(...)
end

function CPFlashableFiligreeMixin:Play(...)
	self.filigreeAnim:Play(...)
end

function CPFlashableFiligreeMixin:SetLooping(loopState)
	local anim = self.filigreeAnim;
	if ( loopState == 'NONE' and anim:GetLoopState() == 'REVERSE' ) then
		return anim:SetScript('OnLoop', function(group)
			group:SetLooping(loopState)
			group:SetScript('OnLoop', nil)
		end)
	end
	anim:SetLooping(loopState)
end

function CPFlashableFiligreeMixin:SetVertexColor(r, g, b, a)
	self.ActivationExpandFx:SetVertexColor(r, g, b, a)
	for i, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetVertexColor(r, g, b, a)
	end
end

function CPFlashableFiligreeMixin:SetBackgroundColor(r, g, b, a)
	self.ActivationExpandFx:SetVertexColor(r, g, b, a)
end

function CPFlashableFiligreeMixin:SetTexture(...)
	for i, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetTexture(...)
	end
end

function CPFlashableFiligreeMixin:SetTexCoord(...)
	for i, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetTexCoord(...)
	end
end

function CPFlashableFiligreeMixin:SetAtlas(...)
	for i, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAtlas(...)
	end
end

function CPFlashableFiligreeMixin:SetScale(...)
	for i, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetScale(...)
	end
end

function CPFlashableFiligreeMixin:SetAnimationSpeedMultiplier(multiplier)
	local group, durations = self.filigreeAnim, self.Durations;
	for animation, duration in pairs(durations) do
		group[animation]:SetDuration(duration * multiplier)
	end
end

function CPFlashableFiligreeMixin:SetAllPoints(anchor)
	self:SetSize(self:SetAnchor(anchor):GetSize())
end

function CPFlashableFiligreeMixin:SetAnchor(anchor) anchor = anchor or self:GetParent()
	self:SetPoint('CENTER', anchor, 'CENTER')
	return anchor;
end

function CPFlashableFiligreeMixin:SetSize(width, height) height = height or width;
	local ratios = self.Ratios;
	for i, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetSize(width, height)
	end
	self:SetWidth(ratios.Container.x * width)
	self:SetHeight(ratios.Container.y * height)
	-- These should not change aspect ratio, so only use width
	self.ActivationExpandFx:SetSize(
		ratios.ActivationExpandFx.x * width,
		ratios.ActivationExpandFx.y * width
	);
	self.ActivationExpandFxMask:SetSize(
		ratios.ActivationExpandFxMask.x * width,
		ratios.ActivationExpandFxMask.y * width
	);
	self.ActivationExpandFxMask:SetPoint('CENTER', self, 'CENTER',
		ratios.ActivationExpandFxMaskPoint.x * width,
		ratios.ActivationExpandFxMaskPoint.y * width
	);
	self.filigreeAnim.ActivationExpandFxScale:SetScaleTo(
		ratios.ActivationExpandFxScale.x * width,
		ratios.ActivationExpandFxScale.y * width
	);
end

function CPFlashableFiligreeMixin:SetClassEmblem(classFile)
	local classAtlas = ('animations-class-%s'):format((classFile or CPAPI.GetClassFile()):lower())
	CPAPI.SetAtlas(self.ActivationExpandFxMask, 'animations-mask-filigree-activate', false,
		false, false, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	CPAPI.SetAtlas(self.ActivationFx1, classAtlas, false)
	CPAPI.SetAtlas(self.ActivationFx2, classAtlas, false)
	CPAPI.SetAtlas(self.ActivationFx3, classAtlas, false)
	CPAPI.SetAtlas(self.ActivationFx4, classAtlas, false)
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