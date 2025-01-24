local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Header = { Template = 'CPHeader', Size = CreateVector2D(304, 40) };
---------------------------------------------------------------
function Header:OnClick()
	self:OnButtonStateChanged()
	self:GetElementData():SetCollapsed(self:GetChecked())
end

function Header:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self:SetSize(self.Size:GetXY())
	self:SetScript('OnClick', Header.OnClick)
	RunNextFrame(function()
		self:SetChecked(elementData:IsCollapsed())
	end)
end

function Header:OnAcquire(new)
	if new then
		Mixin(self, Header)
	end
end

function Header:OnRelease()
	self:SetChecked(false)
end

function Header.New(text)
	return {
		text     = text;
		template = Header.Template;
		factory  = Header.Init;
		acquire  = Header.OnAcquire;
		release  = Header.OnRelease;
		extent   = Header.Size.y;
	};
end

---------------------------------------------------------------
local Set = { Template = 'CPRingSetCard', Size = CreateVector2D(292, 95) };
---------------------------------------------------------------

function Set:Init(elementData)
	local info = elementData:GetData()
	local setID, data = info.setID, info.data;
	print(GetTime(), 'Set:Init', setID, data)

	local ringName = Container:GetBindingDisplayNameForSetID(setID);
	local statusText  = WHITE_FONT_COLOR:WrapTextInColorCode(ITEMS_VARIABLE_QUANTITY:format(#data));
	local bindingText = Container:GetButtonSlugForSet(setID) or NOT_BOUND;
	local icon = Container:GetSetIcon(setID) or [[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\Ring.png]];

	self.Name:SetText(ringName)
	self.Info:SetText(statusText)
	self.Icon:SetTexture(icon)
	self.Binding.Status:SetText(bindingText)
	self:SetChecked(info.selected)
	self:SetSize(self.Size:GetXY())
end

function Set:OnClick()
	local elementData = self:GetElementData()
	local setID = elementData:GetData().setID;
	self:OnButtonStateChanged()
	env:TriggerEvent('OnSelectSet', setID, self:GetChecked(), elementData)
end

function Set:OnAcquire(new)
	if new then
		Mixin(self, Set)
		self:SetScript('OnClick', self.OnClick)
	end
end

function Set:OnRelease()
	self:SetChecked(false)
end

function Set.New(setID, data, selected, isShared)
	return {
		setID    = setID;
		data     = data;
		selected = selected;
		isShared = isShared;
		template = Set.Template;
		factory  = Set.Init;
		acquire  = Set.OnAcquire;
		release  = Set.OnRelease;
		extent   = Set.Size.y;
	};
end

---------------------------------------------------------------
local Add = { Template = 'CPCardAddTemplate', Size = CreateVector2D(Set.Size.x, 88) };
---------------------------------------------------------------

function Add:Init(elementData)
	local info = elementData:GetData()
	self:SetChecked(info.isAdding)
	self:SetSize(self.Size:GetXY())
end

function Add:OnAcquire(new)
	if new then
		Mixin(self, Add)
		self:SetScript('OnClick', self.OnClick)
	end
end

function Add:OnRelease()
	self:SetChecked(false)
end

function Add:OnClick()
	local elementData = self:GetElementData()
	local data = elementData:GetData()
	data.isAdding = not data.isAdding;
	self:OnButtonStateChanged()
	env:TriggerEvent('OnAddNew', elementData, data.container)
end

function Add.New()
	return {
		isAdding  = false;
		template  = Add.Template;
		factory   = Add.Init;
		acquire   = Add.OnAcquire;
		release   = Add.OnRelease;
		extent    = Add.Size.y;
	};
end

---------------------------------------------------------------
local Divider = { Template = 'CPRingSetDivider' };
---------------------------------------------------------------

function Divider.New(extent)
	return {
		extent   = extent or 10;
		template = Divider.Template;
		factory  = nop;
	};
end

---------------------------------------------------------------
local Sets = {}; env.SharedConfig.Sets = Sets;
---------------------------------------------------------------

function Sets:OnLoad()
	local scrollView, dataProvider = self:GetScrollView(), self:GetDataProvider()
	scrollView:SetElementExtentCalculator(function(_, elementData)
		local info = elementData:GetData()
		return info.extent;
	end)
	scrollView:SetElementFactory(function(factory, elementData)
		local info = elementData:GetData()
		factory(info.template, info.factory)
	end)
	scrollView:SetElementStretchDisabled(true)
	scrollView:RegisterCallback(ScrollBoxListViewMixin.Event.OnAcquiredFrame, self.OnAcquiredFrame, self)
	scrollView:RegisterCallback(ScrollBoxListViewMixin.Event.OnReleasedFrame, self.OnReleasedFrame, self)

	self.playerSets = dataProvider:Insert(Header.New(CPAPI.GetPlayerName(true)))
	self.sharedSets = dataProvider:Insert(Header.New(MANAGE_ACCOUNT))

	self.addPlayerSet = Add.New()
	self.addSharedSet = Add.New()

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNew', self.OnAddNew, self)
end

function Sets:OnAcquiredFrame(frame, elementData, new)
	local info = elementData:GetData()
	if info.acquire then
		info.acquire(frame, new)
	end
end

function Sets:OnReleasedFrame(frame, elementData)
	local info = elementData:GetData()
	if info.release then
		info.release(frame)
	end
end

function Sets:ForEach(func, excludeCollapsed)
	self.playerSets.dataProvider:ForEach(func, excludeCollapsed)
	self.sharedSets.dataProvider:ForEach(func, excludeCollapsed)
	self:GetScrollView():ReinitializeFrames()
end

function Sets:OnAddNew(addElementData, container)
	self:ForEach(function(elementData)
		if elementData == addElementData then return end;
		local data = elementData:GetData();
		data.selected = nil;
		data.isAdding = nil;
	end, false)
end

function Sets:OnSelectSet(setID, isSelected, setElementData)
	self:ForEach(function(elementData)
		if elementData == setElementData then
			elementData:GetData().selected = isSelected;
			return;
		end
		local data = elementData:GetData();
		data.selected = nil;
		data.isAdding = nil;
	end, false)
end

function Sets:SetData(data, sharedData, selectedSetID)
	self.playerSets:Flush()
	self.sharedSets:Flush()

	for setID, set in db.table.spairs(data) do
		self.playerSets:Insert( Set.New(setID, set, setID == selectedSetID) )
	end
	self.addPlayerSet.container = data;
	self.playerSets:Insert( self.addPlayerSet )
	self.playerSets:Insert( Divider.New() )

	for setID, set in db.table.spairs(sharedData) do
		self.sharedSets:Insert( Set.New(setID, set, setID == selectedSetID, true) )
	end
	self.addSharedSet.container = sharedData;
	self.sharedSets:Insert( self.addSharedSet )
end