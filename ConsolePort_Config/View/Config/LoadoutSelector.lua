local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Entry = CreateFromMixins(env.Elements.LoadoutEntry)
---------------------------------------------------------------
local CurrentActionID;

function Entry:GetSlotMatches(info)
	local match = info.funcs.match;
	if not match then return nil, false end;
	return match(self.UnpackID(info.id)), true;
end

function Entry:ShouldBeChecked(info)
	local matches, triedMatch = self:GetSlotMatches(info)
	self.InnerContent.Glow:SetShown(triedMatch and not matches)
	if not matches then return false end;

	for _, actionID in ipairs(matches) do
		if actionID == CurrentActionID then
			return true;
		end
	end
end

function Entry:OnSelected(info)
	if self:GetChecked() then
		local pickup = info.funcs.pickup;
		if pickup then
			pickup(self.UnpackID(info.id))
			PlaceAction(CurrentActionID)
		end
	else
		PickupAction(CurrentActionID)
		ClearCursor()
	end
end

function Entry:OnLeaveEntry()
	if self.highlightedSlots then
		for _, actionID in ipairs(self.highlightedSlots) do
			env:TriggerEvent('OnActionSlotHighlight', actionID, false)
		end
		self.highlightedSlots = nil;
	end
end

function Entry:OnFocusEntry(info)
	self.highlightedSlots = self:GetSlotMatches(info)
	if not self.highlightedSlots then return end;
	for _, actionID in ipairs(self.highlightedSlots) do
		env:TriggerEvent('OnActionSlotHighlight', actionID, true)
	end
end

function Entry:OnAcquire(new)
	if new then
		env.Elements.LoadoutEntry.OnAcquire(self, new)
		FrameUtil.SpecializeFrameWithMixins(self, Entry)
	end
end

function Entry:OnCancelClick(_, down)
	if down then return end;
	env:TriggerEvent('OnLoadoutClose')
end

---------------------------------------------------------------
local ActionSlotter = {};
---------------------------------------------------------------

function ActionSlotter:Data(datapoint)
	return {
		bar  = datapoint.bar;
		slot = datapoint.slot;
		page = datapoint.slot;
		name = datapoint.field.name;
		icon = datapoint.field.icon;
		info = datapoint.field.info;
	};
end

function ActionSlotter:SetMinMaxRange(data)
	self.rangeMin = data.slot;
	self.rangeMax = data.slot;
end

function ActionSlotter:OnAcquire(new)
	if new then
		Mixin(self, ActionSlotter)
		self:SetScript('OnEvent', CPAPI.EventMixin.OnEvent)
		self:EnableMouse(false)
		self.InnerContent:SetScale(0.5) -- correct the background scale
	end
	self:InitButtons()
	db:RegisterCallback('OnActionPageChanged', self.UpdateActivePage, self)
	env:RegisterCallback('OnActionSlotHighlight', self.UpdateSlotHighlight, self)
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
	if new then
		ConsolePort:SetCursorNodeIfActive(self[1])
	end
end

function ActionSlotter:OnRelease()
	local button = self[1];
	if button then
		button:UnlockHighlight()
		env.Elements.ActionbarMapper.ReleaseActionbarMapperButton(button)
		self[1] = nil;
	end
	db:UnregisterCallback('OnActionPageChanged', self)
	env:UnregisterCallback('OnActionSlotHighlight', self)
	self:UnregisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function ActionSlotter:UpdateButtons(data)
	local button = self[1];
	button:SetID(data.slot)
end

function ActionSlotter:InitButtons()
	local button, newObj = env.Elements.ActionbarMapper.GetActionbarMapperButton(self)
	if newObj then
		env.Elements.ActionbarMapper.ActionButtonInit(button)
	end
	button:SetPoint('RIGHT', -8, 0)
	button:Show()
	button.Slug:SetText('')
	self[1] = button;
end

---------------------------------------------------------------
local LoadoutLip = CreateFromMixins(CPScrollBoxLip)
---------------------------------------------------------------
local LIP_HEIGHT = 184;

function LoadoutLip:OnLoad()
	self:SetHeight(LIP_HEIGHT)
	self:InitDefault()
end

---------------------------------------------------------------
local LoadoutSelector = CreateFromMixins(CPLoadoutContainerMixin)
---------------------------------------------------------------
env.LoadoutSelector = LoadoutSelector;

function LoadoutSelector:Init(container)
	ActionSlotter = CreateFromMixins(env.Elements.ActionbarMapper, ActionSlotter)
	env:RegisterCallback('OnPanelShow', self.Release, self)
	env:RegisterCallback('OnSearch', self.Release, self)
	env:RegisterCallback('OnLoadoutClose', self.OnLoadoutClose, self)
	env.Frame:HookScript('OnHide', GenerateClosure(self.Release, self))

	self.Lip = CreateFrame('Frame', nil, container, 'CPScrollBoxLip')
	FrameUtil.SpecializeFrameWithMixins(self.Lip, LoadoutLip)
end

function LoadoutSelector:OnLoadoutClose()
	self:Release()
	env:TriggerEvent('OnActionSlotEdit', nil)
	env:TriggerEvent('OnFlushLeft')
end

function LoadoutSelector:IsVisible()
	return not not CurrentActionID;
end

function LoadoutSelector:Release()
	CurrentActionID = nil;
	self:OnSearch(nil)
	self:ClearCollections()
	self.Lip:Hide()
	if self.returnToNode then
		ConsolePort:SetCursorNodeIfActive(self.returnToNode)
		self.returnToNode = nil;
	end
	if self.slotChangedCallback then
		self.slotChangedCallback = self.slotChangedCallback:Unregister()
	end
end

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
function LoadoutSelector:GetDataProvider()
	return self.dataProvider;
end

function LoadoutSelector:GetScrollView()
	return self.scrollView;
end

function LoadoutSelector:SetDataProvider(dataProvider)
	self.dataProvider = dataProvider;
	return self;
end

function LoadoutSelector:SetScrollView(scrollView)
	self.scrollView = scrollView;
	self.Lip:SetOwner(scrollView)
	return self;
end

function LoadoutSelector:FindFirstOfType(type, scrollView)
	return (scrollView or self:GetScrollView()):FindElementDataByPredicate(function(elementData)
		return elementData:GetData().xml == type.xml;
	end)
end

---------------------------------------------------------------
-- Action edits
---------------------------------------------------------------
function LoadoutSelector:RefreshSlotter(newData)
	local scrollView = self.Lip:GetScrollView()
	local elementData = self:FindFirstOfType(ActionSlotter, scrollView)
	if elementData then
		db.table.merge(elementData:GetData(), ActionSlotter:Data(newData))
		scrollView:ReinitializeFrames()
	end
end

function LoadoutSelector:EditAction(actionID, bindingID, element)
	if not actionID then return end;
	if CurrentActionID == actionID then
		return env:TriggerEvent('OnLoadoutClose')
	end

	CurrentActionID = actionID;
	self:RefreshSlotter(self:GetSlotterData(actionID))
	self:RefreshCollections()

	if not self.slotChangedCallback then
		self.slotChangedCallback = EventRegistry:RegisterFrameEventAndCallbackWithHandle(
			'ACTIONBAR_SLOT_CHANGED',
			self.ACTIONBAR_SLOT_CHANGED,
			self
		);
	end

	local elementData, target = self:FindFirstOfType(env.Elements.Back, self.Lip:GetScrollView())
	if elementData then
		target = self.Lip:GetScrollView():FindFrame(elementData)
	end
	if target then
		self.returnToNode = element;
		return ConsolePort:SetCursorNodeIfActive(target)
	end
end

---------------------------------------------------------------
-- Collection
---------------------------------------------------------------
function LoadoutSelector:UpdateCollections()
	local dataProvider = CPLoadoutContainerMixin.UpdateCollections(self)
	local lipProvider = self.Lip:GetDataProvider()
	lipProvider:Flush()

	for i, element in ipairs({
		env.Elements.Title:New(EDIT);
		ActionSlotter:New(self:GetSlotterData(CurrentActionID));
		env.Elements.Divider:New(4);
		env.Elements.Back:New({
			callback = GenerateClosure(env.TriggerEvent, env, 'OnLoadoutClose');
		});
		env.Elements.Divider:New(2);
		env.Elements.Search:New({
			dispatch = false;
			callback = function(text)
				self:OnSearch(text)
			end
		});
	}) do
		lipProvider:InsertAtIndex(element, i)
	end

	for i, element in ipairs({
		env.Elements.Divider:New(4);
	}) do
		dataProvider:InsertAtIndex(element, i)
	end
end

function LoadoutSelector:GetSlotterData(actionID)
	local barID  = ceil(actionID / NUM_ACTIONBAR_BUTTONS);
	local stance = db.Actionbar.Lookup.Stances[barID];
	local name   = env:GetBindingName(db('Actionbar/Action/'..actionID)) or BINDING_NAME_ACTIONBUTTON1:gsub('%d', actionID);
	return {
		bar   = barID;
		slot  = actionID;
		field = {
			info = stance or false;
			icon = stance and stance.iconID or false;
			name = table.concat({
				YELLOW_FONT_COLOR:WrapTextInColorCode(name),
				db.Actionbar.Names[barID] or barID,
				GRAY_FONT_COLOR:WrapTextInColorCode(PAGE_NUMBER:format(barID))
			}, '\n');
		};
	};
end

function LoadoutSelector:GetElements()
	return Entry, CPLoadoutContainerMixin.GetElements(self);
end

function LoadoutSelector:ACTIONBAR_SLOT_CHANGED(slot)
	if slot == CurrentActionID then
		self:RefreshCollections()
	end
end