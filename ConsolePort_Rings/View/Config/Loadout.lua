local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local CurrentSetID;

local function UnpackEntryID(id)
	if type(id) == 'table' then
		return unpack(id);
	end
	return id;
end

local function MapToAction(info)
	return info.funcs.map(env.SecureHandlerMap, UnpackEntryID(info.id));
end

local function GetCurrentSetEntry(info)
	local action = MapToAction(info);
	return Container:SearchActionByCompare(CurrentSetID, action);
end

local function AppendAction(info)
	local action = MapToAction(info);
	return Container:AddUniqueAction(CurrentSetID, nil, action);
end

local function RemoveAction(info)
	local action = MapToAction(info);
	return not Container:ClearActionByCompare(CurrentSetID, action);
end

---------------------------------------------------------------
local Entry = { Template = 'CPRingLoadoutCard', Size = CreateVector2D(292, 48) };
---------------------------------------------------------------

function Entry:Init(elementData)
	local info = elementData:GetData()
	local id, funcs = info.id, info.funcs;
	self.Name:SetText(funcs.title(UnpackEntryID(id)))
	self.Icon:SetTexture(funcs.texture(UnpackEntryID(id)))
	self:SetChecked(GetCurrentSetEntry(info))
end

function Entry:ShowTooltip(tooltipFunc, ...)
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, self.Size.y)
	NineSliceUtil.ApplyLayoutByName(
		tooltip.NineSlice,
		'CharacterCreateDropdown',
		tooltip.NineSlice:GetFrameLayoutTextureKit()
	);

	tooltipFunc(tooltip, ...)
	RunNextFrame(function()
		tooltip:AddLine('\n\n')
		tooltip:Show()
		tooltip:SetSize(
			math.max(tooltip:GetWidth(), 90),
			math.max(tooltip:GetHeight(), 90)
		);
	end)
	return tooltip;
end

function Entry:OnEnter()
	local info = self:GetElementData():GetData()
	CPCardSmallMixin.OnEnter(self)
	self:ShowTooltip(info.funcs.tooltip, UnpackEntryID(info.id))
	local index = GetCurrentSetEntry(info)
	if index then
		env:TriggerEvent('OnIndexHighlight', index)
	end
end

function Entry:OnLeave()
	CPCardSmallMixin.OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	env:TriggerEvent('OnIndexHighlight', nil)
end

function Entry:OnClick()
	local info = self:GetElementData():GetData()
	if self:GetChecked() then
		self:SetChecked(AppendAction(info))
	else
		self:SetChecked(RemoveAction(info))
	end
	self:OnButtonStateChanged()
	env:TriggerEvent('OnSetChanged', CurrentSetID, self:GetChecked())
end

function Entry:OnDragStart()
	local info = self:GetElementData():GetData()
	info.funcs.pickup(UnpackEntryID(info.id))
end

function Entry:OnDragStop()
	CPCardSmallMixin.OnMouseUp(self)
end

function Entry:OnButtonStateChanged()
	CPCardSmallMixin.OnButtonStateChanged(self)
	self.Border:SetAtlas(self:GetChecked()
		and 'glues-characterselect-icon-notify-bg-hover'
		or 'glues-characterselect-icon-notify-bg')
end

function Entry:OnAcquire(new)
	if new then
		FrameUtil.SpecializeFrameWithMixins(self, Entry)
		self:OnLoad()
		self:RegisterForDrag('LeftButton')
		self:SetScript('OnDragStop', self.OnDragStop)
		self.InnerContent.SelectedHighlight:SetPoint('TOPLEFT', 50, -20)
	end
end

function Entry:OnRelease()
	self:SetChecked(false)
end

function Entry.New(id, funcs)
	return {
		id       = id;
		funcs    = funcs;
		template = Entry.Template;
		factory  = Entry.Init;
		acquire  = Entry.OnAcquire;
		release  = Entry.OnRelease;
		extent   = Entry.Size.y;
	};
end

---------------------------------------------------------------
local Results = { Template = 'SettingsListSectionHeaderTemplate', Size = CreateVector2D(292, 45) };
---------------------------------------------------------------

function Results:Init(elementData)
	local info = elementData:GetData()
	self.Title:SetText(info.text)
	self.Title:SetPoint('TOPRIGHT', -7, -16)
	self:SetSize(self.Size:GetXY())
end

function Results.New(text)
	return {
		text     = text;
		template = Results.Template;
		factory  = Results.Init;
		extent   = Results.Size.y;
	};
end

---------------------------------------------------------------
local Loadout = CreateFromMixins(db.LoadoutMixin); env.SharedConfig.Loadout = Loadout;
---------------------------------------------------------------

function Loadout:OnLoad()
	local scrollView = self:Init()
	scrollView:SetElementExtentCalculator(function(_, elementData)
		local info = elementData:GetData()
		return info.extent;
	end)
	scrollView:SetElementFactory(function(factory, elementData)
		local info = elementData:GetData()
		factory(info.template, info.factory)
	end)

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
	env:RegisterCallback('OnSetChanged', self.OnSetChanged, self)

	self.HeaderIcons = {
		[ABILITIES] = 'category-icon-book';
		[ITEMS]     = 'category-icon-misc';
		[MACROS]    = 'category-icon-enchantscroll';
	};
end

function Loadout:OnSelectSet(_, setID, isSelected)
	CurrentSetID = isSelected and setID or nil;
end

function Loadout:OnSetChanged(setID)
	if ( setID == CurrentSetID ) then
		self:GetScrollView():ReinitializeFrames()
	end
end

function Loadout:OnSearch(text)
	self.searchTerm = text;
	if self:IsVisible() then
		self:OnShow()
	end
end

function Loadout:OnHide()
	self:ClearCollections()
end

function Loadout:OnShow()
	local Header = env.SharedConfig.Header;
	local dataProvider = self:GetDataProvider();
	local collections = self:GetCollections(true);

	dataProvider:Flush()

	local MinEditDistance = CPAPI.MinEditDistance;
	local cats, searchTerm = {}, self.searchTerm;
	local isSearchActive = searchTerm and searchTerm ~= '';

	local function MakeHeaderName(name)
		local icon = self.HeaderIcons[name];
		if icon then
			return ([[|TInterface\Store\%s:20:20:0:0:64:64:18:46:18:46|t %s]]):format(icon, name);
		end
		return name;
	end

	local function MakeCategory(data, collapsed)
		if not cats[data.name] then
			local provider = dataProvider;
			if data.header then
				local main = data.header..0;
				if not cats[main] then
					cats[main] = dataProvider:Insert(Header.New(MakeHeaderName(data.header), collapsed));
				end
				provider = cats[main];
			end
			cats[data.name] = provider:Insert(Header.New(data.name, collapsed));
		end
		return cats[data.name];
	end

	local function FilterLoadoutEntry(entry, data)
		if not isSearchActive then
			return true;
		end
		local title = data.title(UnpackEntryID(entry));
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
				category:Insert(Entry.New(entry, data));
				hasItems = true;
			end
		end
		if hasItems then
			MakeCategory(data, not isSearchActive):Insert(env.SharedConfig.Divider.New(4));
		end
	end
	if isSearchActive and dataProvider:IsEmpty() then
		dataProvider:Insert(Results.New(SETTINGS_SEARCH_NOTHING_FOUND:gsub('%. ', '.\n')))
	end
end