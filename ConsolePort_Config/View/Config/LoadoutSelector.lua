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
			ClearCursor()
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
		CPAPI.Specialize(self, Entry)
	end
end

function Entry:OnCancelClick(_, down)
	if down then return end;
	env:TriggerEvent('OnLoadoutClose')
end

---------------------------------------------------------------
local ActionSlotter = CreateFromMixins(env.Elements.ActionbarMapper)
---------------------------------------------------------------
env.Elements.ActionSlotter = ActionSlotter;

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
	self.Info:SetPoint('BOTTOMRIGHT', self[1], 'BOTTOMLEFT', -4, 0)
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

function ActionSlotter:UpdateChildren(data)
	local button = self[1];
	button:SetID(data.slot)
	button:SetOnClickEvent('OnBindingClicked')
	button:SetPairMode(false)
	button:SetEditMode(true)
end

function ActionSlotter:InitButtons()
	local button, newObj = env.Elements.ActionbarMapper.GetActionbarMapperButton(self)
	if newObj then
		env.Elements.ActionbarMapper.ActionButtonInit(button)
	end
	button:SetPoint('RIGHT', -8, 0)
	button:Show()
	self[1] = button;
end

---------------------------------------------------------------
local LoadoutLip = CreateFromMixins(CPScrollBoxLip)
---------------------------------------------------------------
local LIP_HEIGHT = 176;

function LoadoutLip:OnLoad()
	self:SetHeight(LIP_HEIGHT)
	self:InitDefault()
end

function LoadoutLip:OnSearch(text)
	if not text then
		return self:Hide()
	end
end

function LoadoutLip:OnShow()
	CPScrollBoxLip.OnShow(self)
	env:RegisterCallback('OnFlushLeft', self.Hide, self)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
end

function LoadoutLip:OnHide()
	CPScrollBoxLip.OnHide(self)
	env:UnregisterCallback('OnFlushLeft', self)
	env:UnregisterCallback('OnSearch', self)
end

---------------------------------------------------------------
local LoadoutSelector = CreateFromMixins(CPLoadoutContainerMixin)
---------------------------------------------------------------
env.LoadoutSelector = LoadoutSelector;

LoadoutSelector.IsFlat = CPAPI.Static(false);

function LoadoutSelector:Init(container)
	env:RegisterCallback('OnPanelShow', self.Release, self)
	env:RegisterCallback('OnLoadoutClose', self.OnLoadoutClose, self)
	env.Frame:HookScript('OnHide', GenerateClosure(self.Release, self))
	self.container = container;
end

function LoadoutSelector:OnLoadoutClose()
	self:Release()
	env:TriggerEvent('OnActionSlotEdit', nil)
	if self.closeCallback then
		self.closeCallback()
		self.closeCallback = nil;
	end
end

function LoadoutSelector:IsVisible()
	return not not CurrentActionID;
end

function LoadoutSelector:Release()
	CurrentActionID = nil;
	self:OnSearch(nil)
	self:ClearCollections()
	self:GetLip():Hide()
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
CPAPI.Props(LoadoutSelector)
	.Prop 'AlternateTitle'      -- Set an alternate top title
	.Prop 'CloseCallback'       -- Callback to run when the selector is closed
	.Prop 'DataProvider'        -- Data provider for the scroll view
	.Prop 'ExternalLip'         -- External lip frame to use instead of the default
	.Prop 'ScrollView'          -- Scroll view to use
	.Bool('ToggleByID', true)   -- If true, the selector will close when action is reselected

function LoadoutSelector:GetLip()
	if self.externalLip then
		return self.externalLip;
	end
	if not self.Lip then
		self.Lip = CreateFrame('Frame', nil, self.container, 'CPScrollBoxLip')
		CPAPI.SpecializeOnce(self.Lip, LoadoutLip)
	end
	return self.Lip;
end

function LoadoutSelector:GetTitle()
	if self.alternateTitle then
		return self.alternateTitle;
	end
	return EDIT;
end

---------------------------------------------------------------
-- Action edits
---------------------------------------------------------------
function LoadoutSelector:RefreshSlotter(newData)
	local scrollView = self:GetLip():GetScrollView()
	local elementData = self:FindFirstOfType(ActionSlotter, scrollView)
	if elementData then
		db.table.merge(elementData:GetData(), ActionSlotter:Data(newData))
		scrollView:ReinitializeFrames()
	end
end

function LoadoutSelector:EditAction(actionID, bindingID, element)
	if not actionID then return end;
	local isCurrentActionID = actionID == CurrentActionID;
	local isToggleByID = self:IsToggleByID();

	if isCurrentActionID and isToggleByID then
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

	local lipScrollView = self:GetLip():GetScrollView()
	local elementData, target = self:FindFirstOfType(env.Elements.Back, lipScrollView)
	if elementData then
		target = lipScrollView:FindFrame(elementData)
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
	local lip = self:GetLip()
	local dataProvider = CPLoadoutContainerMixin.UpdateCollections(self)
	local scrollView = self:GetScrollView()

	if not lip:IsOwned(scrollView) then
		self:UpdateLip(lip)
		lip:SetOwner(scrollView)
	end

	for i, element in ipairs({
		env.Elements.Divider:New(4);
	}) do
		dataProvider:InsertAtIndex(element, i)
	end
end

function LoadoutSelector:UpdateLip(lip) lip = lip or self:GetLip();
	local lipProvider = lip:GetDataProvider()
	lipProvider:Flush()

	for i, element in ipairs({
		env.Elements.Title:New(self:GetTitle());
		ActionSlotter:New(self:GetSlotterData(CurrentActionID));
		env.Elements.Divider:New(1);
		env.Elements.Back:New({
			callback = GenerateClosure(env.TriggerEvent, env, 'OnLoadoutClose');
		});
		env.Elements.Search:New({
			dispatch = false;
			callback = function(text)
				self:OnSearch(text)
			end
		});
	}) do
		lipProvider:InsertAtIndex(element, i)
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