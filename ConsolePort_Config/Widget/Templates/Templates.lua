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
	self:SetAttribute('nodeignore', true)
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
	local buttons = {};
	for i, tab in ipairs(tabs) do
		buttons[i] = self:AddTab(tab.text, tab.data, tab.func)
	end
	return buttons;
end

function CPTabGroupMixin:SetEnabled(index, enabled)
	local button = self:GetAtIndex(index)
	button.Text:SetTextColor((enabled and GameFontNormal or GameFontDisable):GetTextColor())
	return button:SetEnabled(enabled)
end

function CPTabGroupMixin:SelectAtIndex(index)
	local isNewIndex = index ~= self.tabIndex;
	self.tabIndex = index;
	RadioButtonGroupMixin.SelectAtIndex(self, index)
	return isNewIndex;
end

function CPTabGroupMixin:Decrement()
	local limit = 1;
	local delta = max(limit, self.tabIndex - 1);
	while delta >= limit and not self:GetAtIndex(delta):IsEnabled() do
		delta = delta - 1;
	end
	local target = self:GetAtIndex(delta)
	if target and target:IsEnabled() then
		return self:SelectAtIndex(delta)
	end
end

function CPTabGroupMixin:Increment()
	local limit = #self.buttons;
	local delta = min(limit, self.tabIndex + 1);
	while delta <= limit and not self:GetAtIndex(delta):IsEnabled() do
		delta = delta + 1;
	end
	local target = self:GetAtIndex(delta)
	if target and target:IsEnabled() then
		return self:SelectAtIndex(delta)
	end
end

function CPTabGroupMixin:GetActiveTabIndex()
	return self.tabIndex or 1;
end

---------------------------------------------------------------
CPNavBarMixin = {
---------------------------------------------------------------
	ButtonWidthBuffer = 60;
	fadedLeftButton   = false;
	fadedRightButton  = true;
};

function CPNavBarMixin:OnLoad()
	local function NavBarButtonSetup(button, label, controlCallback, ...)
		local args = {...};
		button:SetText(label)
		button:SetWidth(button:GetTextWidth() + CPNavBarMixin.ButtonWidthBuffer)
		button:SetScript('OnClick', function()
			PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
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
	self.GetVerticalScrollRange = CPAPI.Static(0);
	self.Bar.OnCleaned = function(navBar)

	end;
end

function CPNavBarWrapperMixin:OnShow()
	self:UpdateScroll(self:GetHorizontalScroll())
end

function CPNavBarWrapperMixin:AddButton(label, controlCallback, ...)
	return self.Bar:AddButton(label, controlCallback, ...)
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
	self.LeftNotch:SetShown(target > min)
	self.RightNotch:SetShown(target < max)
end