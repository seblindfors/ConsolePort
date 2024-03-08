local _, db = ...;

---------------------------------------------------------------
CPMaskedButtonMixin = CreateFromMixins(CPFrameWithTooltipMixin)
---------------------------------------------------------------

function CPMaskedButtonMixin:OnLoad()
	CPFrameWithTooltipMixin.OnLoad(self)

	self.CircleMask:SetPoint('TOPLEFT', self, 'TOPLEFT', self.circleMaskSizeOffset, -self.circleMaskSizeOffset)
	self.CircleMask:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -self.circleMaskSizeOffset, self.circleMaskSizeOffset)

	local hasRingSizes = self.ringWidth and self.ringHeight
	if hasRingSizes then
		CPAPI.SetAtlas(self.Ring, self.ringAtlas)
		CPAPI.SetAtlas(self.Flash.Ring, self.ringAtlas)
		CPAPI.SetAtlas(self.Flash.Ring2, self.ringAtlas)
		self.Ring:SetSize(self.ringWidth, self.ringHeight)
		self.Flash.Ring:SetSize(self.ringWidth, self.ringHeight)
		self.Flash.Ring2:SetSize(self.ringWidth, self.ringHeight)
	else
		CPAPI.SetAtlas(self.Ring, self.ringAtlas, true)
		CPAPI.SetAtlas(self.Flash.Ring, self.ringAtlas, true)
		CPAPI.SetAtlas(self.Flash.Ring2, self.ringAtlas, true)
	end

	self.NormalTexture:AddMaskTexture(self.CircleMask)
	self.PushedTexture:AddMaskTexture(self.CircleMask)
	self.DisabledOverlay:AddMaskTexture(self.CircleMask)
	self.DisabledOverlay:SetAlpha(self.disabledOverlayAlpha)
	self.CheckedTexture:SetSize(self.checkedTextureSize, self.checkedTextureSize)
	self.Flash.Portrait:AddMaskTexture(self.CircleMask)

	if self.flipTextures then
		self.NormalTexture:SetTexCoord(1, 0, 0, 1)
		self.PushedTexture:SetTexCoord(1, 0, 0, 1)
		self.Flash.Portrait:SetTexCoord(1, 0, 0, 1)
	end

	if self.BlackBG then
		self.BlackBG:AddMaskTexture(self.CircleMask)
	end
end

function CPMaskedButtonMixin:SetIconAtlas(atlas)
	self:SetNormalAtlas(atlas)
	self:SetPushedAtlas(atlas)
	self.Flash.Portrait:SetAtlas(atlas)
end

function CPMaskedButtonMixin:SetIcon(texture)
	local default = not texture and [[Interface\AddOns\ConsolePort\Textures\Button\EmptyIcon]]
	self:SetNormalTexture(texture or default)
	self:SetPushedTexture(texture or default)
	self.Flash.Portrait:SetTexture(texture or default)
end

function CPMaskedButtonMixin:StartFlash()
	self.Flash:Show()
	self.Flash.Anim:Play()
end

function CPMaskedButtonMixin:StopFlash()
	self.Flash.Anim:Stop()
	self.Flash:Hide()
end

function CPMaskedButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled)

	local normalTex = self:GetNormalTexture()
	if normalTex then
		normalTex:SetDesaturated(not enabled)
	end

	self.Ring:SetAtlas(self.ringAtlas..(enabled and '' or 'disabled'))

	self.DisabledOverlay:SetShown(not enabled)
end

function CPMaskedButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.CheckedTexture:SetPoint('CENTER', self, 'CENTER', 0, -1)
		self.CircleMask:SetPoint('TOPLEFT', self.PushedTexture, 'TOPLEFT', self.circleMaskSizeOffset, -self.circleMaskSizeOffset)
		self.CircleMask:SetPoint('BOTTOMRIGHT', self.PushedTexture, 'BOTTOMRIGHT', -self.circleMaskSizeOffset, self.circleMaskSizeOffset)
		self.Ring:SetPoint('CENTER', self, 'CENTER', 0, -1)
		self.Flash:SetPoint('CENTER', self, 'CENTER', 0, -1)
	end
end

function CPMaskedButtonMixin:OnMouseUp(button)
	if button == 'RightButton' and self.expandedTooltipFrame then
		tooltipsExpanded = not tooltipsExpanded
		if GetMouseFocus() == self then
			self:OnEnter()
		end
	end

	self.CheckedTexture:SetPoint('CENTER')
	self.CircleMask:SetPoint('TOPLEFT', self.NormalTexture, 'TOPLEFT', self.circleMaskSizeOffset, -self.circleMaskSizeOffset)
	self.CircleMask:SetPoint('BOTTOMRIGHT', self.NormalTexture, 'BOTTOMRIGHT', -self.circleMaskSizeOffset, self.circleMaskSizeOffset)
	self.Ring:SetPoint('CENTER')
	self.Flash:SetPoint('CENTER')
end

function CPMaskedButtonMixin:UpdateHighlightTexture()
	if self:GetChecked() then
		CPAPI.SetAtlas(self.HighlightTexture, 'ring-select')
		self.HighlightTexture:SetPoint('TOPLEFT', self.CheckedTexture)
		self.HighlightTexture:SetPoint('BOTTOMRIGHT', self.CheckedTexture)
	else
		CPAPI.SetAtlas(self.HighlightTexture, self.ringAtlas)
		self.HighlightTexture:SetPoint('TOPLEFT', self.Ring)
		self.HighlightTexture:SetPoint('BOTTOMRIGHT', self.Ring)
	end
end


---------------------------------------------------------------
CPButtonMixin = CreateFromMixins(CPMaskedButtonMixin)
---------------------------------------------------------------

function CPButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS)
end

function CPButtonMixin:SetDescription(text)
	self.Description:SetText(text)
end

function CPButtonMixin:SetEnabledState(enabled)
	CPMaskedButtonMixin.SetEnabledState(self, enabled)
	self.Description:SetFontObject(enabled and 'GameFontNormalMed3' or 'GameFontDisableMed3')
end

function CPButtonMixin:OnEnter()
	CPFrameWithTooltipMixin.OnEnter(self)
end

function CPButtonMixin:OnLeave()
	CPFrameWithTooltipMixin.OnLeave(self)
end


---------------------------------------------------------------
CPSmoothButtonMixin = {}
---------------------------------------------------------------

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
CPSmoothRectangleButtonMixin = CreateFromMixins(CPSmoothButtonMixin)
---------------------------------------------------------------

function CPSmoothRectangleButtonMixin:OnLoad()
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


local ThreeSliceButtonMixin = ThreeSliceButtonMixin;
if not ThreeSliceButtonMixin then

	ThreeSliceButtonMixin = CreateFromMixins(UIButtonMixin);

	function ThreeSliceButtonMixin:GetLeftAtlasName()
		return self.atlasName.."-Left";
	end
	
	function ThreeSliceButtonMixin:GetRightAtlasName()
		return self.atlasName.."-Right";
	end
	
	function ThreeSliceButtonMixin:GetCenterAtlasName()
		return "_"..self.atlasName.."-Center";
	end
	
	function ThreeSliceButtonMixin:GetHighlightAtlasName()
		return self.atlasName.."-Highlight";
	end
	
	function ThreeSliceButtonMixin:OnMouseDown()
		self:UpdateButton("PUSHED");
	end
	
	function ThreeSliceButtonMixin:OnMouseUp()
		self:UpdateButton("NORMAL");
	end
end
---------------------------------------------------------------
CPThreeSliceButtonMixin = CreateFromMixins(ThreeSliceButtonMixin)
---------------------------------------------------------------

function CPThreeSliceButtonMixin:InitButton()
	self.leftAtlasInfo = CPAPI.GetAtlasInfo(self:GetLeftAtlasName())
	self.rightAtlasInfo = CPAPI.GetAtlasInfo(self:GetRightAtlasName())

    self.Hilite = self:CreateTexture(nil, 'HIGHLIGHT')
    self:SetHighlightTexture(self.Hilite)

    print(CPAPI.SetAtlas(self.Hilite, self:GetHighlightAtlasName()))
	DevTools_Dump(CPAPI.GetAtlasInfo(self:GetHighlightAtlasName()))

	print(self.Hilite:GetTexture())
	print(self.Hilite:GetTexCoord())
	print(self.Hilite:GetAlpha())
end

function CPThreeSliceButtonMixin:UpdateButton(buttonState)
    local left, center, right = self:GetAtlasNames(buttonState)

	local useAtlasSize = true;
	CPAPI.SetAtlas(self.Left, left, useAtlasSize)
	CPAPI.SetAtlas(self.Center, center)
	CPAPI.SetAtlas(self.Right, right, useAtlasSize)

	self:UpdateScale()
end

function CPThreeSliceButtonMixin:GetAtlasNames(buttonState)
    buttonState = self:EvaluateButtonState(buttonState);
	local atlasNamePostfix = '';
	if buttonState == 'DISABLED' then
		atlasNamePostfix = '-Disabled';
	elseif buttonState == 'PUSHED' then
		atlasNamePostfix = '-Pressed';
	end
    return
        self:GetLeftAtlasName()..atlasNamePostfix,
        self:GetCenterAtlasName()..atlasNamePostfix,
        self:GetRightAtlasName()..atlasNamePostfix;
end

function CPThreeSliceButtonMixin:EvaluateButtonState(buttonState)
	buttonState = buttonState or self:GetButtonState();
	if not self:IsEnabled() then
		buttonState = 'DISABLED';
	end
    return buttonState;
end

function CPThreeSliceButtonMixin:UpdateScale()
	local buttonWidth, buttonHeight = self:GetSize()
    local l, r = self.leftAtlasInfo, self.rightAtlasInfo;
	local scale = buttonHeight / l.height;
	self.Left:SetScale(scale)
	self.Right:SetScale(scale)

	local leftWidth = l.width * scale;
	local rightWidth = r.width * scale;
	local leftAndRightWidth = leftWidth + rightWidth;

    local lLeftTexCoord, lRightTexCoord, lTopTexCoord, lBottomTexCoord = self.Left:GetTexCoord();
    local rLeftTexCoord, rRightTexCoord, rTopTexCoord, rBottomTexCoord = self.Right:GetTexCoord();

	if leftAndRightWidth > buttonWidth then
		-- At the current buttonHeight, the left and right textures are too big to fit within the button width
		-- So slice some width off of the textures and adjust texture coords accordingly
		local extraWidth = leftAndRightWidth - buttonWidth;
		local newLeftWidth = leftWidth;
		local newRightWidth = rightWidth;

		-- If one of the textures is sufficiently larger than the other one, we can remove all of the width from there
		if (leftWidth - extraWidth) > rightWidth then
			-- left is big enough to take the whole thing...deduct it all from there
			newLeftWidth = leftWidth - extraWidth;
		elseif (rightWidth - extraWidth) > leftWidth then
			-- right is big enough to take the whole thing...deduct it all from there
			newRightWidth = rightWidth - extraWidth;
		else
			-- neither side is sufficiently larger than the other to take the whole extra width
			if leftWidth ~= rightWidth then
				-- so set both widths equal to the smaller size and subtract the difference from extraWidth
				local unevenAmount = math.abs(leftWidth - rightWidth);
				extraWidth = extraWidth - unevenAmount;
				newLeftWidth = math.min(leftWidth, rightWidth);
				newRightWidth = newLeftWidth;
			end
			-- newLeftWidth and newRightWidth are now equal and we just need to remove half of extraWidth from each
			local equallyDividedExtraWidth = extraWidth / 2;
			newLeftWidth = newLeftWidth - equallyDividedExtraWidth;
			newRightWidth = newRightWidth - equallyDividedExtraWidth;
		end

		-- Now set the tex coords and widths of both textures
		local leftPercentage = newLeftWidth / leftWidth;
        self.Left:SetTexCoord(lLeftTexCoord, leftPercentage, lTopTexCoord, lBottomTexCoord);
		self.Left:SetWidth(newLeftWidth / scale);

		local rightPercentage = newRightWidth / rightWidth;
        self.Right:SetTexCoord(rLeftTexCoord - rightPercentage, rRightTexCoord, rTopTexCoord, rBottomTexCoord);
		self.Right:SetWidth(newRightWidth / scale);
	else
		self.Left:SetWidth(l.width);
		self.Right:SetWidth(r.width);
	end
end


---------------------------------------------------------------
CPThreeSliceSmoothButtonMixin = CreateFromMixins(CPThreeSliceButtonMixin, CPSmoothButtonMixin)
---------------------------------------------------------------

function CPThreeSliceSmoothButtonMixin:OnEnter()
    CPThreeSliceButtonMixin.OnEnter(self)
    CPSmoothButtonMixin.OnEnter(self)
end

function CPThreeSliceSmoothButtonMixin:OnLeave()
    CPThreeSliceButtonMixin.OnLeave(self)
    CPSmoothButtonMixin.OnLeave(self)
end

---------------------------------------------------------------
CPLargeIconButtonMixin = CreateFromMixins(CPThreeSliceButtonMixin)
---------------------------------------------------------------

function CPLargeIconButtonMixin:UpdateButton(buttonState)
    CPThreeSliceButtonMixin.UpdateButton(self, buttonState)
    buttonState = self:EvaluateButtonState(buttonState);
    if buttonState == 'PUSHED' then
        self.Icon:SetPoint('LEFT', 26, -6)
    else
        self.Icon:SetPoint('LEFT', 20, -2)
    end
end