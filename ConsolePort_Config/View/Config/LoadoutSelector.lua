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
	local matches = self:GetSlotMatches(info)
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
	env:TriggerEvent('OnActionEntrySelected', info, self)
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
	button:SetPoint('RIGHT', -6, 0)
	button:Show()
	button.Slug:SetText('')
	self[1] = button;
end

---------------------------------------------------------------
local LoadoutSelector = CreateFromMixins(CPLoadoutContainerMixin)
---------------------------------------------------------------
env.LoadoutSelector = LoadoutSelector;

function LoadoutSelector:Init()
	ActionSlotter = CreateFromMixins(env.Elements.ActionbarMapper, ActionSlotter)
	env:RegisterCallback('OnPanelShow', self.Release, self)
	env:RegisterCallback('OnSearch', self.Release, self)
	env:RegisterCallback('OnActionEntrySelected', self.RefreshCollections, self)
	env.Frame:HookScript('OnHide', GenerateClosure(self.Release, self))
end

function LoadoutSelector:IsVisible()
	return not not CurrentActionID;
end

function LoadoutSelector:Release()
	CurrentActionID = nil;
	self:OnSearch(nil)
	self:ClearCollections()
end

function LoadoutSelector:GetDataProvider()
	return env.Frame.Container.Left:GetDataProvider()
end

function LoadoutSelector:GetScrollView()
	return env.Frame.Container.Left:GetScrollView()
end

function LoadoutSelector:EditAction(actionID, bindingID, element)
	if not actionID or CurrentActionID == actionID then
		return;
	end
	CurrentActionID = actionID;
	self:RefreshSlotter(self:GetSlotterData(actionID))
	self:RefreshCollections()
end

function LoadoutSelector:RefreshSlotter(newData)
	local elementData = self:GetScrollView():FindElementDataByPredicate(function(elementData)
		return elementData:GetData().xml == ActionSlotter.xml;
	end)
	if elementData then
		db.table.merge(elementData:GetData(), ActionSlotter:Data(newData))
	end
end

function LoadoutSelector:UpdateCollections()
	local dataProvider = CPLoadoutContainerMixin.UpdateCollections(self)

	for i, element in ipairs({
		env.Elements.Divider:New(4);
		ActionSlotter:New(self:GetSlotterData(CurrentActionID));
		env.Elements.Divider:New(4);
		env.Elements.Back:New({
			callback = function()
				self:Release()
				env:TriggerEvent('OnActionSlotEdit', nil)
				env:TriggerEvent('OnFlushLeft')
			end;
		});
		env.Elements.Divider:New(2);
		env.Elements.Search:New({
			dispatch = false;
			callback = function(text)
				self:OnSearch(text)
			end
		});
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