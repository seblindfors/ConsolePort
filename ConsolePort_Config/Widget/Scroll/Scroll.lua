
--------------------------------------------------------------
CPScrollBox = {};
---------------------------------------------------------------

function CPScrollBox:OnLoad()
	local dataProvider = self:GetDataProvider();
	local scrollView = self:GetScrollView();
	scrollView:SetDataProvider(dataProvider);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, scrollView);
	self:UpdateScrollBar()
end

function CPScrollBox:GetDataProvider()
	if not self.dataProvider then
		self.dataProvider = self:CreateDataProvider();
	end
	return self.dataProvider;
end

function CPScrollBox:GetScrollView()
	if not self.scrollView then
		self.scrollView = self:CreateScrollView();
	end
	return self.scrollView;
end

function CPScrollBox:CreateDataProvider()
	error("CPScrollBox:CreateDataProvider must be overridden");
end

function CPScrollBox:CreateScrollView()
	error("CPScrollBoxMixin:CreateScrollView must be overridden");
end

function CPScrollBox:UpdateScrollBar()
	local left   = self.scrollBarX or SCROLL_FRAME_SCROLL_BAR_OFFSET_LEFT or 0;
	local top    = self.scrollBarTopY or SCROLL_FRAME_SCROLL_BAR_OFFSET_TOP or 0;
	local bottom = self.scrollBarBottomY or SCROLL_FRAME_SCROLL_BAR_OFFSET_BOTTOM or 0;
	self.ScrollBar:SetHideIfUnscrollable(self.scrollBarHideIfUnscrollable)
	self.ScrollBar:SetPoint('TOPLEFT', self.ScrollBox, 'TOPRIGHT', left, top)
	self.ScrollBar:SetPoint('BOTTOMLEFT', self.ScrollBox, 'BOTTOMRIGHT', left, bottom)
	self.ScrollBar:Show()
	self.ScrollBar:Update()
end

---------------------------------------------------------------
CPScrollBoxTree = CreateFromMixins(CPScrollBox);
---------------------------------------------------------------

function CPScrollBoxTree:CreateDataProvider()
	return CreateTreeDataProvider();
end

function CPScrollBoxTree:CreateScrollView()
	return CreateScrollBoxListTreeListView(
		self.indent or 6,
		self.paddingTop or 8,
		self.paddingBottom or 8,
		self.paddingLeft or 6,
		self.paddingRight or 12,
		self.spacing or 8
	);
end