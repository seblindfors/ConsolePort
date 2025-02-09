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

local function ReplaceAction(info, index)
	env.ReplaceID = nil;
	local action = MapToAction(info);
	Container:RemoveAction(CurrentSetID, index);
	return Container:AddUniqueAction(CurrentSetID, index, action);
end

local function RemoveAction(info)
	local action = MapToAction(info);
	return not Container:ClearActionByCompare(CurrentSetID, action);
end

---------------------------------------------------------------
local Entry = CPAPI.CreateElement('CPRingLoadoutCard', 292, 48);
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
	tooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, self.size.y)
	NineSliceUtil.ApplyLayoutByName(
		tooltip.NineSlice,
		'CharacterCreateDropdown',
		tooltip.NineSlice:GetFrameLayoutTextureKit()
	);

	tooltipFunc(tooltip, ...)
	RunNextFrame(function()
		tooltip:SetHeight(tooltip:GetHeight() + 24)
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

function Entry:OnClick(button)
	if ( button == 'RightButton' ) then
		return self:CollapseToParent()
	end
	local info = self:GetElementData():GetData()
	if self:GetChecked() then
		local operation = env.ReplaceID and ReplaceAction or AppendAction;
		self:SetChecked(operation(info, env.ReplaceID))
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
		self:SetAttribute('nohooks', true)
		self.InnerContent.SelectedHighlight:SetPoint('TOPLEFT', 50, -20)
	end
end

function Entry:CollapseToParent()
	self:SetChecked(false)

	local parentElementData = self:GetElementData().parent;
	local scrollBox = self:GetParent():GetParent();
	scrollBox:ScrollToElementData(parentElementData, ScrollBoxConstants.AlignCenter, 0, true)

	local scrollView = scrollBox:GetParent():GetScrollView()
	local header = scrollView:FindFrame(parentElementData);
	if header then
		header:Click()
		ConsolePort:SetCursorNodeIfActive(header)
	end
end

function Entry:OnRelease()
	self:SetChecked(false)
end

function Entry:Data(id, funcs)
	return { id = id, funcs = funcs };
end

---------------------------------------------------------------
local Results = CPAPI.CreateElement('SettingsListSectionHeaderTemplate', 292, 45);
---------------------------------------------------------------

function Results:Init(elementData)
	local info = elementData:GetData()
	self.Title:SetText(info.text)
	self.Title:SetPoint('TOPRIGHT', -7, -16)
	self:SetSize(self.Size:GetXY())
end

function Results:Data(text)
	return { text = text };
end

---------------------------------------------------------------
local Loadout = CreateFromMixins(db.LoadoutMixin); env.SharedConfig.Loadout = Loadout;
---------------------------------------------------------------

function Loadout:OnLoad()
	self:InitDefault()

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
	env:RegisterCallback('OnSetChanged', self.OnSetChanged, self)
	env:RegisterCallback('OnConfigShown', self.OnConfigShown, self)

	self.HeaderIcons = {
		[ABILITIES] = 'book';
		[ITEMS]     = 'misc';
		[MACROS]    = 'enchantscroll';
		[SPECIAL]   = 'featured';
	};
end

function Loadout:OnSelectSet(_, setID, isSelected)
	CurrentSetID = isSelected and setID or nil;
	self:ClearCollections()
end

function Loadout:OnSetChanged(setID)
	if ( setID == CurrentSetID ) then
		self:GetScrollView():ReinitializeFrames()
	end
end

function Loadout:OnSearch(text)
	self.searchTerm = text;
	if self:IsVisible() then
		self:UpdateCollections()
	end
end

function Loadout:OnConfigShown(shown)
	if not shown then
		self:ClearCollections()
	end
end

function Loadout:OnShow()
	self:RefreshCollections()
end

function Loadout:GetCollections(...)
	if not self.Collections then
		db.LoadoutMixin.GetCollections(self, ...);
		tAppendAll(self.Collections, env:GetCollections(CurrentSetID, env:IsSharedSet(CurrentSetID)));
	end
	return self.Collections;
end

function Loadout:RefreshCollections()
	if not self.Collections then
		return self:UpdateCollections()
	end
	self:GetScrollView():ReinitializeFrames()
end

function Loadout:UpdateCollections()
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
				category:Insert(Entry:New(entry, data));
				hasItems = true;
			end
		end
		if hasItems then
			MakeCategory(data, not isSearchActive):Insert(env.SharedConfig.Divider:New(4));
		end
	end
	if isSearchActive and dataProvider:IsEmpty() then
		dataProvider:Insert(Results:New(SETTINGS_SEARCH_NOTHING_FOUND:gsub('%. ', '.\n')))
	end
end