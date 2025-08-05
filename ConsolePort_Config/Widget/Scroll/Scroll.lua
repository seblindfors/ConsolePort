local env, db = CPAPI.GetEnv(...);
--------------------------------------------------------------
CPScrollBox = CreateFromMixins(env.Mixin.ScrollBoxHelper)
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
	scrollView:SetElementIndentCalculator(function(elementData)
		local indent = (elementData:GetDepth() - 1) * scrollView:GetElementIndent();
		local info = elementData:GetData()
		if info.indent then
			return indent + info.indent;
		end
		return indent;
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
CPScrollBoxSettingsTree = CreateFromMixins(CPScrollBoxTree);
---------------------------------------------------------------

function CPScrollBoxSettingsTree:InitDefault()
	local XML_SETTING_TEMPLATE = 'CPSetting';

	local function SettingFactory(self, info)
		local pool = self.frameFactory.poolCollection:GetOrCreatePool('CheckButton',
			self:GetScrollTarget(), info.xml, self.frameFactoryResetter, nil, info.type)
		local frame, new = pool:Acquire()
		self.initializers[frame] = info.init;
		self.factoryFrame = frame;
		self.factoryFrameIsNew = new;
	end

	local scrollView = CPScrollBoxTree.InitDefault(self)
	scrollView:SetElementFactory(function(factory, elementData)
		local info = elementData:GetData()
		if ( info.xml ~= XML_SETTING_TEMPLATE ) then
			return factory(info.xml, info.init)
		end
		SettingFactory(scrollView, info)
	end)
end

---------------------------------------------------------------
CPScrollBoxLip = CreateFromMixins(CPScrollBoxTree);
---------------------------------------------------------------

function CPScrollBoxLip:OnLoad()
	CPScrollBoxTree.OnLoad(self)
	self:ToggleInversion(true)
	self:SetBackgroundAlpha(0.9)
end

function CPScrollBoxLip:SetOwner(scrollView)
	self:Release(scrollView)
	self:SetHeight(self:GetLipHeight())
	self.owner = scrollView;
	self.validated = true;

	local padding = scrollView:GetPadding()
	padding.oldTop = padding:GetTop()
	padding:SetTop(self:GetLipHeight() + padding.oldTop)

	local scrollBox = scrollView:GetScrollBox()

	self:Show()
	self:ClearAllPoints()
	self:SetFrameLevel(scrollBox:GetFrameLevel() + 1)
	self:SetPoint('TOPLEFT', scrollBox, 'TOPLEFT', padding:GetLeft(), 0)
	self:SetPoint('TOPRIGHT', scrollBox, 'TOPRIGHT', 4-padding:GetRight(), 0)

	scrollView:TriggerEvent(ScrollBoxListViewMixin.Event.OnDataChanged)

	return self;
end

function CPScrollBoxLip:IsOwned(owner)
	return self.owner == owner and owner ~= nil and self.validated;
end

function CPScrollBoxLip:Invalidate()
	self.validated = false;
	return self;
end

function CPScrollBoxLip:Release()
	if self.owner then
		local padding = self.owner:GetPadding()
		local oldTop = padding.oldTop;
		if oldTop then
			padding.oldTop = nil;
			padding:SetTop(oldTop)
		end
		self.owner:TriggerEvent(ScrollBoxListViewMixin.Event.OnDataChanged)
		self.owner, self.validated = nil, false;
	end
end

function CPScrollBoxLip:GetLipHeight()
	return self:GetHeight() or 0;
end

function CPScrollBoxLip:OnHide()
	self:Release()
end

function CPScrollBoxLip:OnShow()
	db.Alpha.FadeIn(self, 0.5, 0, 1)
end

---------------------------------------------------------------
CPSmoothScroll = {}; -- ScrollFrame with interpolated scrolling.
---------------------------------------------------------------

function CPSmoothScroll:OnLoad()
	ScrollFrame_OnLoad(self)

	local interpolator = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut)
	local setScroll    = GenerateClosure(self.SetVerticalScroll, self)
	local scrollBar    = self.ScrollBar;
	local timeToKill   = 0.075;

	local onMouseWheel = function(scrollFrame, delta)
		local panExtentPercentage = scrollBar:GetPanExtentPercentage()
		local currentScrollValue  = scrollFrame:GetVerticalScroll()
		local verticalScrollRange = scrollFrame:GetVerticalScrollRange()

		local target = interpolator:GetInterpolateTo() or currentScrollValue;
		target = Clamp(target - (delta * panExtentPercentage * verticalScrollRange), 0, verticalScrollRange);
		interpolator:Interpolate(currentScrollValue, target, timeToKill, setScroll)
	end

	self:SetScript('OnMouseWheel', onMouseWheel)
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

---------------------------------------------------------------
CPLoadoutContainerMixin = CreateFromMixins(db.LoadoutMixin, env.Mixin.ScrollBoxHelper, {
---------------------------------------------------------------
	IsFlat = CPAPI.Static(true); -- Unravel flyouts to regular spell depth.
	HeaderIcons = {
		[ABILITIES] = 'book';
		[ITEMS]     = 'misc';
		[MACROS]    = 'enchantscroll';
		[SPECIAL]   = 'featured';
	};
	-- Needs to be implemented:
	--  GetDataProvider, GetScrollView
});

function CPLoadoutContainerMixin:OnSearch(text)
	self.searchTerm = text;
	if self:IsVisible() then
		self:UpdateCollections()
	end
end

function CPLoadoutContainerMixin:RefreshCollections()
	if not self.Collections or self:GetDataProvider():IsEmpty() then
		return self:UpdateCollections()
	end
	self:GetScrollView():ReinitializeFrames()
end

function CPLoadoutContainerMixin:GetElements()
	local elements = env.Elements;
	return -- elements.LoadoutEntry,
			  elements.Header,
			  elements.Divider,
			  elements.Results;
end

function CPLoadoutContainerMixin:UpdateCollections()
	local Entry, Header, Divider, Results = self:GetElements()
	local dataProvider = self:GetDataProvider()
	local collections = self:GetCollections(self:IsFlat())

	dataProvider:Flush()

	local MinEditDistance = CPAPI.MinEditDistance;
	local cats, searchTerm = {}, self.searchTerm;
	local isSearchActive = env.Search:Validate(searchTerm) ~= nil;

	local function MakeHeaderName(name)
		local icon = self.HeaderIcons[name];
		if icon then
			return ([[|TInterface\Store\category-icon-%s:20:20:0:0:64:64:18:46:18:46|t %s]]):format(icon, name);
		end
		return name;
	end

	local function MakeCategory(data, collapsed)
		if not cats[data.name] then
			local provider = dataProvider;
			if data.header then
				local main = data.header..0;
				if not cats[main] then
					cats[main] = dataProvider:Insert(Header:New(MakeHeaderName(data.header), collapsed));
				end
				provider = cats[main];
			end
			cats[data.name] = provider:Insert(Header:New(data.name, collapsed));
		end
		return cats[data.name];
	end

	local function FilterLoadoutEntry(entry, data)
		if not isSearchActive then
			return true;
		end
		local title = data.title(Entry.UnpackID(entry));
		if not title then
			return false;
		end
		if title:lower():find(searchTerm:lower()) then
			return true;
		end
		return MinEditDistance(title, searchTerm) < 3;
	end

	for i, data in ipairs(collections) do
		local hasItems = false;
		for _, entry in ipairs(data.items) do
			if FilterLoadoutEntry(entry, data) then
				local category = MakeCategory(data, not isSearchActive);
				category:SetCollapsed(not isSearchActive);
				category:Insert(Entry:New(entry, data));
				hasItems = true;
			end
		end
		if hasItems then
			MakeCategory(data, not isSearchActive):Insert(Divider:New(4));
		end
	end
	if isSearchActive and dataProvider:IsEmpty() then
		dataProvider:Insert(Results:New(SETTINGS_SEARCH_NOTHING_FOUND:gsub('%. ', '.\n')))
	end

	return dataProvider;
end