local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Set = { Template = 'CPRingSetCard', Size = CreateVector2D(292, 95) };
---------------------------------------------------------------

function Set:Init(elementData)
	local info = elementData:GetData()
	local setID, data = info.setID, info.data;

	local ringName = Container:GetBindingDisplayNameForSetID(setID);
	local statusText  = WHITE_FONT_COLOR:WrapTextInColorCode(ITEMS_VARIABLE_QUANTITY:format(#data));
	local bindingText = Container:GetButtonSlugForSet(setID) or NOT_BOUND;
	local icon = env:GetSetIcon(setID);

	self.Name:SetText(ringName)
	self.Info:SetText(statusText)
	self.Icon:SetTexture(icon)
	self.Binding.Status:SetText(bindingText)
	self:SetChecked(info.selected)
	self:SetEnabled(not info.disabled)
	self:SetSize(self.Size:GetXY())
end

function Set:OnClick()
	local elementData = self:GetElementData()
	local setID = elementData:GetData().setID;
	self:OnButtonStateChanged()
	env:TriggerEvent('OnSelectSet', elementData, setID, self:GetChecked())
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

function Set.New(setID, data, selected, disabled)
	return {
		setID    = setID;
		data     = data;
		selected = not disabled and selected;
		disabled = disabled;
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
	env:TriggerEvent('OnAddNewSet', elementData, data.container, data.isAdding)
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
local Sets = {}; env.SharedConfig.Sets = Sets;
---------------------------------------------------------------

function Sets:OnLoad()
	local scrollView, dataProvider = self:Init()
	scrollView:SetElementExtentCalculator(function(_, elementData)
		local info = elementData:GetData()
		return info.extent;
	end)
	scrollView:SetElementFactory(function(factory, elementData)
		local info = elementData:GetData()
		factory(info.template, info.factory)
	end)
	scrollView:SetElementStretchDisabled(true)

	self.playerSets = dataProvider:Insert(env.SharedConfig.Header.New(CPAPI.GetPlayerName(true)))
	self.sharedSets = dataProvider:Insert(env.SharedConfig.Header.New(MANAGE_ACCOUNT))

	self.addPlayerSet = Add.New()
	self.addSharedSet = Add.New()

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNewSet', self.OnAddNewSet, self)
end

function Sets:ForEach(func, excludeCollapsed)
	self.playerSets.dataProvider:ForEach(func, excludeCollapsed)
	self.sharedSets.dataProvider:ForEach(func, excludeCollapsed)
	self:GetScrollView():ReinitializeFrames()
end

function Sets:OnAddNewSet(addElementData)
	self:ForEach(function(elementData)
		if elementData == addElementData then return end;
		local data = elementData:GetData();
		data.selected = nil;
		data.isAdding = nil;
	end, false)
end

function Sets:OnSelectSet(setElementData, setID, isSelected)
	self:ForEach(function(elementData)
		local data = elementData:GetData();
		if setElementData then
			if elementData == setElementData then
				data.selected = isSelected;
				return;
			end
		elseif ( setID == data.setID ) then
			data.selected = isSelected;
			return;
		end
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
	self.playerSets:Insert( env.SharedConfig.Divider.New() )

	for setID, set in db.table.spairs(sharedData) do
		-- For shared sets, they should be disabled if they conflict with player sets.
		self.sharedSets:Insert( Set.New(setID, set, setID == selectedSetID, not not data[setID]) )
	end
	self.addSharedSet.container = sharedData;
	self.sharedSets:Insert( self.addSharedSet )
end