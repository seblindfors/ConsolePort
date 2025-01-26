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

local function IsEntryPartOfCurrentSet(info)
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
	self:SetChecked(IsEntryPartOfCurrentSet(info))
end

function Entry:OnEnter()
	local info = self:GetElementData():GetData()
	CPCardSmallMixin.OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	info.funcs.tooltip(GameTooltip, UnpackEntryID(info.id))
end

function Entry:OnLeave()
	CPCardSmallMixin.OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
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

function Entry:OnAcquire(new)
	if new then
		FrameUtil.SpecializeFrameWithMixins(self, Entry)
		self:OnLoad()
		self:RegisterForDrag('LeftButton')
		self:SetScript('OnDragStop', self.OnDragStop)
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
end

function Loadout:OnSelectSet(elementData, setID, isSelected)
	CurrentSetID = isSelected and setID or nil;
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
	local activeCategories, searchTerm = {}, self.searchTerm;
	local isSearchActive = searchTerm and searchTerm ~= '';

	local function GetCollectionEntry(i, data, collapsed)
		if not activeCategories[i] then
			activeCategories[i] = dataProvider:Insert(Header.New(data.name, collapsed));
		end
		return activeCategories[i];
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
		for _, entry in ipairs(data.items) do
			if FilterLoadoutEntry(entry, data) then
				GetCollectionEntry(i, data, not isSearchActive):Insert(Entry.New(entry, data));
			end
		end
	end
end