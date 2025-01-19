local env, db = CPAPI.GetEnv(...)
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

---------------------------------------------------------------
CPTabGroupMixin = CreateFromMixins(
---------------------------------------------------------------
	BaseButtonTrayMixin,
	HorizontalButtonTrayMixin,
	RadioButtonGroupMixin
);

function CPTabGroupMixin:OnLoad()
	HorizontalButtonTrayMixin.OnLoad(self)
	RadioButtonGroupMixin.Init(self)

	local TabButtonSetup = function(button, text, controlCallback, data)
		button.data = data;
		button.tabText = text;
		MinimalTabMixin.OnLoad(button)
		if controlCallback then
			button:SetScript('OnClick', GenerateClosure(controlCallback, data))
		end
	end

	self:SetButtonSetup(TabButtonSetup)
end

function CPTabGroupMixin:OnShow()
	local showTabKeys = self.showTabKeys;
	self.TabDecrementIcon:SetShown(showTabKeys)
	self.TabIncrementIcon:SetShown(showTabKeys)
	if not showTabKeys then return end;
	local decrementKey = self.decrementKey or 'PADLSHOULDER';
	local incrementKey = self.incrementKey or 'PADRSHOULDER';
	local iconScale = self:GetScale()
	local is, as = 24 / iconScale, 18 / iconScale;
	db.Gamepad.SetIconToTexture(self.TabDecrementIcon, decrementKey, 32, {is, is}, {as, as})
	db.Gamepad.SetIconToTexture(self.TabIncrementIcon, incrementKey, 32, {is, is}, {as, as})
end

function CPTabGroupMixin:AddTab(text, data, controlCallback)
	local button = self:AddControl(text, controlCallback, data)
	self:AddButton(button)
	return button;
end

function CPTabGroupMixin:AddTabs(tabs)
	for _, tab in ipairs(tabs) do
		self:AddTab(tab.text, tab.data, tab.func)
	end
end

---------------------------------------------------------------
CPNavBarMixin = {
---------------------------------------------------------------
	ButtonWidthBuffer = 70;
	fadedLeftButton   = true;
	fadedRightButton  = false;
};

function CPNavBarMixin:OnLoad()
	local function NavBarButtonSetup(button, label, controlCallback, ...)
		local args = {...};
		button:SetText(label)
		button:SetWidth(button:GetTextWidth() + CPNavBarMixin.ButtonWidthBuffer)
		button:SetScript('OnClick', function()
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS);
			controlCallback(button, self, unpack(args))
		end)
	end
	self.skipChildLayout = true;
	self.ButtonTray:SetButtonSetup(NavBarButtonSetup);
end

function CPNavBarMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self)
	self:SetButtonVisuals()
end

function CPNavBarMixin:AddButton(label, controlCallback, ...)
	return self.ButtonTray:AddControl(label, controlCallback, ...)
end

function CPNavBarMixin:SetButtonVisuals()
	local leftMost, rightMost;
	for button in self.ButtonTray:EnumerateControls() do
		if ( not leftMost or button.layoutIndex < leftMost.layoutIndex ) then
			leftMost = button;
		end
		if ( not rightMost or button.layoutIndex > rightMost.layoutIndex ) then
			rightMost = button;
		end
		button:SetMiddle()
	end
	self.leftMost, self.rightMost = leftMost, rightMost;
	self.leftPadding, self.rightPadding = 0, 0;
	if ( self.fadedLeftButton and leftMost and leftMost ~= rightMost ) then
		self.leftPadding = leftMost:SetLeftMost()
	end
	if ( self.fadedRightButton and rightMost and rightMost ~= leftMost ) then
		self.rightPadding = rightMost:SetRightMost()
	end
	self:MarkDirty()
end

function CPNavBarMixin:GetJustify()
	return self.fadedLeftButton == self.fadedRightButton and 'CENTER'
		or self.fadedRightButton and 'LEFT'
		or self.fadedLeftButton  and 'RIGHT';
end

function CPNavBarMixin:GetLayoutChildren()
	return { self.ButtonTray };
end

---------------------------------------------------------------
CPNavBarWrapperMixin = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut);
---------------------------------------------------------------

function CPNavBarWrapperMixin:OnLoad()
	self.Setter = GenerateClosure(self.UpdateScroll, self)
	self.NavBar.OnCleaned = function(navBar)

	end;
end

function CPNavBarWrapperMixin:OnShow()
	self:UpdateScroll(self:GetHorizontalScroll())
end

function CPNavBarWrapperMixin:AddButton(label, controlCallback, ...)
	return self.NavBar:AddButton(label, controlCallback, ...)
end

function CPNavBarWrapperMixin:GetRange()
	return 0, self:GetHorizontalScrollRange();
end

function CPNavBarWrapperMixin:OnMouseWheel(delta)
	local target = Clamp(self:GetHorizontalScroll() - delta * 100, self:GetRange())
	self:Interpolate(self:GetHorizontalScroll(), target, .11, self.Setter)
end

function CPNavBarWrapperMixin:UpdateScroll(target)
	local min, max = self:GetRange()
	self:SetHorizontalScroll(target)
	self.LeftNotch:SetShown(not self.NavBar.fadedLeftButton or target > min)
	self.RightNotch:SetShown(not self.NavBar.fadedRightButton or target < max)
end

---------------------------------------------------------------
CPBackgroundMixin = CreateFromMixins(BackdropTemplateMixin);
---------------------------------------------------------------

function CPBackgroundMixin:OnLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:HookScript('OnSizeChanged', self.OnBackdropSizeChanged)
	self.Background = self:CreateTexture(nil, 'BACKGROUND', nil, 2)
	self.Rollover   = self:CreateTexture(nil, 'BACKGROUND', nil, 3)
	self.Rollover:SetAllPoints(self.Background)
	self.Rollover:SetTexture(CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]))
	CPAPI.SetGradient(self.Rollover, 'VERTICAL',
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 1},
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 0}
	)
	self:SetOriginTop(true)
	self:CreateBackground(2048, 2048, 2048, 2048, CPAPI.GetAsset([[Art\Background\%s]]):format(CPAPI.GetClassFile()))
end

function CPBackgroundMixin:GetBGOffset(point, size)
	return ((point / 2) / size)
end

function CPBackgroundMixin:GetBGFraction(point, size)
	return (point / size)
end

function CPBackgroundMixin:SetBackgroundDimensions(w, h, x, y)
	assert(self.Background, 'Frame is missing background.')
	self.Background.maxWidth = w;
	self.Background.maxHeight = h;
	self.Background.sizeX = x;
	self.Background.sizeY = y;
end

function CPBackgroundMixin:SetOriginTop(enabled)
	self.originTop = enabled;
end

function CPBackgroundMixin:OnAspectRatioChanged()
	local maxWidth, maxHeight = self.Background.maxWidth, self.Background.maxHeight;
	local sizeX, sizeY = self.Background.sizeX, self.Background.sizeY;
	local width, height = self:GetSize()

	local maxCoordX, maxCoordY, centerCoordX, centerCoordY =
		self:GetBGFraction(maxWidth, sizeX),
		self:GetBGFraction(maxHeight, sizeY),
		self:GetBGOffset(maxWidth, sizeX),
		self:GetBGOffset(maxHeight, sizeY);

	local top, bottom, left, right = 0, 1, 0, 1;
	if width > height then
		local newHeight = self:GetBGFraction(height, width) * maxWidth;
		if self.originTop then
			top, left, right = 0, 0, maxCoordX;
			bottom = self:GetBGFraction(newHeight, sizeY)
		else
			local offset = self:GetBGOffset(newHeight, sizeY)
			left, right = 0, maxCoordX;
			top = centerCoordY - offset;
			bottom = centerCoordY + offset;
		end
	end
	if height > width or (top < 0 or bottom < 0) then
		local newWidth = self:GetBGFraction(width, height) * maxHeight;
		local offset = self:GetBGOffset(newWidth, sizeX)
		top, bottom = 0, maxCoordY;
		left = centerCoordX - offset;
		right = centerCoordX + offset;
	end
	self.Background:SetTexCoord(left, right, top, bottom)
end

function CPBackgroundMixin:SetBackgroundInsets(tlX, tlY, brX, brY)
	self.Background:ClearAllPoints()
	if tlX then
		tlX = tonumber(tlX) or 8;
		tlY = tonumber(tlY) or -tlX;
		brX = tonumber(brX) or -tlX;
		brY = tonumber(brY) or  tlX;
		self.Background:SetPoint('TOPLEFT', tlX, tlY)
		self.Background:SetPoint('BOTTOMRIGHT', brX, brY)
	else
		self.Background:SetAllPoints()
	end
end

function CPBackgroundMixin:CreateBackground(w, h, x, y, texture)
	self.Background:SetTexture(texture)
	self:SetBackgroundDimensions(w, h, x, y)
	self:OnAspectRatioChanged()
	self:HookScript('OnShow', self.OnAspectRatioChanged)
	self:HookScript('OnSizeChanged', self.OnAspectRatioChanged)
end

function CPBackgroundMixin:SetBackgroundVertexColor(...)
	self.Background:SetVertexColor(...)
end

function CPBackgroundMixin:SetBackgroundAlpha(alpha)
	self.Background:SetAlpha(alpha)
	self.Rollover:SetAlpha(alpha)
end

function CPBackgroundMixin:AddBackgroundMaskTexture(mask)
	self.Background:AddMaskTexture(mask)
	self.Rollover:AddMaskTexture(mask)
end