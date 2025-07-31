local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Binding = {};
---------------------------------------------------------------

function Binding:OnClick(button)
	self:GetParent():OnBindingClick(button == 'RightButton')
end

---------------------------------------------------------------
local Set = CPAPI.CreateElement('CPRingSetCard', 292, 95);
---------------------------------------------------------------

function Set:Init(elementData)
	local info = elementData:GetData()
	local setID, set = info.setID, info.set;

	local ringName = Container:GetBindingDisplayNameForSetID(setID);
	local statusText  = WHITE_FONT_COLOR:WrapTextInColorCode(ITEMS_VARIABLE_QUANTITY:format(#set));
	local icon = env:GetSetIcon(setID);

	self.Name:SetText(ringName)
	self.Info:SetText(statusText)
	self.Icon:SetTexture(icon)
	self.Binding.Status:SetBinding(Container:GetBindingForSet(setID))
	self:SetChecked(info.selected)
	self:SetEnabled(not info.disabled)
	self:SetSize(self.size:GetXY())
end

function Set:OnClick(button)
	local elementData = self:GetElementData()
	local info = elementData:GetData()
	local setID = info.setID;

	if ( button == 'RightButton' ) then
		self:SetChecked(true)
		env:TriggerEvent('OnRequestWipe', setID, info.set, info.owner)
	end

	self:OnButtonStateChanged()
	self:OnEnter()
	env:TriggerEvent('OnSelectSet', elementData, setID, self:GetChecked())
end

function Set:OnEnter()
	RunNextFrame(function()
		if ConsolePort:IsCursorNode(self) and not self:IsMouseOver() then
			local elementData = self:GetElementData()
			local info = elementData:GetData()
			local canDelete = #info.set == 0 and info.setID ~= CPAPI.DefaultRingSetID;

			self.handle = ConsolePort:ToggleHintFocus(self, true)
			self.handle:AddHint(db('UICursorLeftClick'), info.selected and CLOSE or EDIT)
			self.handle:AddHint(db('UICursorRightClick'), canDelete and DELETE or CLEAR_ALL)
			self.handle:AddHint(db('UICursorSpecial'), KEY_BINDING)
		end
	end)
end

function Set:OnLeave()
	if self.handle then
		self.handle:ToggleHintFocus(self, false)
		self.handle = nil;
	end
end

function Set:OnSpecialClick(_, down)
	if down then return end;
	self:OnBindingClick(false)
end

function Set:OnAcquire(new)
	if new then
		Mixin(self, Set)
		self:SetScript('OnClick', self.OnClick)
		self:HookScript('OnEnter', self.OnEnter)
		self:HookScript('OnLeave', self.OnLeave)
		self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		CPAPI.Specialize(self.Binding, Binding)
	end
	RunNextFrame(function()
		if self:GetChecked() then
			ConsolePort:SetCursorNodeIfActive(self)
		end
	end)
end

function Set:OnRelease()
	self:SetChecked(false, true)
end

function Set:OnBindingClick(clearBindings)
	env:TriggerEvent('OnBindSet', self, self:GetElementData():GetData().setID, clearBindings)
end

function Set:Data(setID, set, owner, selected, disabled)
	return {
		setID    = setID;
		set      = set;
		owner    = owner;
		selected = not disabled and selected;
		disabled = disabled;
	};
end

---------------------------------------------------------------
local Add = CPAPI.CreateElement('CPCardAddTemplate', Set.size.x, 88);
---------------------------------------------------------------

function Add:Init(elementData)
	local info = elementData:GetData()
	self:SetChecked(info.isAdding)
	self:SetSize(self.size:GetXY())
end

function Add:OnAcquire(new)
	if new then
		Mixin(self, Add)
		self:SetScript('OnClick', self.OnClick)
	end
end

function Add:OnRelease()
	self:SetChecked(false, true)
end

function Add:OnClick()
	local elementData = self:GetElementData()
	local data = elementData:GetData()
	data.isAdding = not data.isAdding;
	self:OnButtonStateChanged()
	env:TriggerEvent('OnAddNewSet', elementData, data.container, data.isAdding)
end

function Add:Data()
	return { isAdding = false };
end

---------------------------------------------------------------
local Sets = {}; env.SharedConfig.Sets = Sets;
---------------------------------------------------------------

function Sets:OnLoad()
	local scrollView, dataProvider = self:InitDefault()
	scrollView:SetElementStretchDisabled(true)

	self.playerSets = dataProvider:Insert(env.SharedConfig.Header:New(CPAPI.GetPlayerName(true)))
	self.sharedSets = dataProvider:Insert(env.SharedConfig.Header:New(MANAGE_ACCOUNT))

	self.addPlayerSet = Add:New()
	self.addSharedSet = Add:New()

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNewSet', self.OnAddNewSet, self)
	env:RegisterCallback('OnSetUpdate', self.OnSetUpdate, self)
	env:RegisterCallback('OnFlashSets', self.OnFlashSets, self)
end

function Sets:OnShow()
	self:GetScrollView():ReinitializeFrames()
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

function Sets:OnSetUpdate()
	if not self:IsVisible() then return end;
	self:GetScrollView():ReinitializeFrames()
end

function Sets:OnFlashSets()
	local hasMovedCursor = false;
	self:GetScrollView():ForEachFrame(function(frame, elementData)
		if elementData:GetData().xml == 'CPRingSetCard' then
			frame:Flash()
			if not hasMovedCursor then
				ConsolePort:SetCursorNodeIfActive(frame)
				hasMovedCursor = true;
			end
		end
	end)
end

function Sets:SetData(data, sharedData, selectedSetID)
	self.playerSets:Flush()
	self.sharedSets:Flush()

	for setID, set in db.table.spairs(data) do
		self.playerSets:Insert( Set:New(setID, set, data, setID == selectedSetID) )
	end
	self.addPlayerSet.container = data;
	self.playerSets:Insert( self.addPlayerSet )
	self.playerSets:Insert( env.SharedConfig.Divider:New() )

	for setID, set in db.table.spairs(sharedData) do
		-- For shared sets, they should be disabled if they conflict with player sets.
		self.sharedSets:Insert( Set:New(setID, set, sharedData, setID == selectedSetID, not not data[setID]) )
	end
	self.addSharedSet.container = sharedData;
	self.sharedSets:Insert( self.addSharedSet )
end