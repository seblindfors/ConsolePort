local env, db = CPAPI.GetEnv(...);
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
	error('CPScrollBox:CreateDataProvider must be overridden');
end

function CPScrollBox:CreateScrollView()
	error('CPScrollBoxMixin:CreateScrollView must be overridden');
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

function CPScrollBox:Init()
	return self:GetScrollView(), self:GetDataProvider();
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

function CPScrollBoxTree:Init()
	local scrollView, dataProvider = CPScrollBox.Init(self);
	scrollView:RegisterCallback(scrollView.Event.OnAcquiredFrame, self.OnAcquiredFrame, self)
	scrollView:RegisterCallback(scrollView.Event.OnReleasedFrame, self.OnReleasedFrame, self)
	return scrollView, dataProvider;
end

function CPScrollBoxTree:InitDefault()
	local scrollView, dataProvider = self:Init()
	scrollView:SetElementExtentCalculator(function(_, elementData)
		local info = elementData:GetData()
		return info.extent;
	end)
	scrollView:SetElementFactory(function(factory, elementData)
		local info = elementData:GetData()
		factory(info.xml, info.init)
	end)
	return scrollView, dataProvider;
end

function CPScrollBoxTree:OnAcquiredFrame(frame, elementData, new)
	local info = elementData:GetData()
	if info.acquire then
		info.acquire(frame, new)
	end
end

function CPScrollBoxTree:OnReleasedFrame(frame, elementData)
	local info = elementData:GetData()
	if info.release then
		info.release(frame)
	end
end

---------------------------------------------------------------
CPIconSelector = CreateFromMixins(ScrollBoxSelectorMixin)
---------------------------------------------------------------

function CPIconSelector:OnLoad()
	local function IconButtonInitializer(button, selectionIndex, icon)
		button:SetIconTexture(icon);
	end
	self:SetSetupCallback(IconButtonInitializer);
	CPScrollBox.UpdateScrollBar(self);
end

function CPIconSelector:OnShow()
	ScrollBoxSelectorMixin.OnShow(self);

	self.iconDataProvider = db.Bindings:GetIconProvider();

	local initialIndex = 1;
	local getSelection = GenerateClosure(self.iconDataProvider.GetIconByIndex, self.iconDataProvider);
	local getNumSelections = GenerateClosure(self.iconDataProvider.GetNumIcons, self.iconDataProvider);

	self:SetSelectedIndex(initialIndex);
	self:SetSelectionsDataProvider(getSelection, getNumSelections);
	self:UpdateSelections()
	self:ScrollToSelectedIndex();
end

function CPIconSelector:OnHide()
	self.iconDataProvider = nil;
	db.Bindings:ReleaseIconProvider();
end