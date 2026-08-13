local env, db = CPAPI.GetEnv(...);
local Settings = env:GetContextPanel();
local Panel = {}; env.SettingsPanel = Panel;

---------------------------------------------------------------
-- Settings Panel Handler
---------------------------------------------------------------

function Panel:OnShow()
	env:RegisterCallback('Settings.OnSubcatClicked', self.OnSubcatClicked, self)
	env:RegisterCallback('Settings.OnDirty', self.OnDirty, self)
	env:RegisterCallback('OnFlushLeft', self.OnFlushLeft, self)
	self:RenderSections()
	self:RenderSettings()
end

function Panel:OnHide()
	env:UnregisterCallback('Settings.OnSubcatClicked', self)
	env:UnregisterCallback('Settings.OnDirty', self)
	env:UnregisterCallback('OnFlushLeft', self)
end

function Panel:OnIndexChanged()
	self:Reindex()

	local Refresh = self:IsVisible() and self.OnShow or nop;

	if self.activeText then
		-- The data set has been regenerated, so the old references
		-- are no longer valid. We need to find the new data set, or
		-- clear the active data if it no longer exists.
		for _, group in env.table.spairs(self.index) do
			for head, data in env.table.spairs(group) do
				if ( head == self.activeText ) then
					self.activeData = data;
					return Refresh(self);
				end
			end
		end
		self.activeText, self.activeData = nil, nil;
	end
	Refresh(self)
end

function Panel:OnSubcatClicked(text, set)
	local left = self:GetLists()
	left:GetDataProvider():ForEach(function(elementData)
		local data = elementData:GetData()
		data.checked = data.childData == set or nil;
	end, false)
	left:GetScrollView():ReinitializeFrames()
	self:SetActiveCategory(text, set)
end

do -- Dependency reconciliation
	local function FindNodeByOrdinal(header, ordinal)
		for _, node in ipairs(header:GetNodes()) do
			if ( node:GetData().ordinal == ordinal ) then
				return node;
			end
		end
	end

	local function FindInsertionIndex(header, ordinal)
		local nodes = header:GetNodes()
		for index, node in ipairs(nodes) do
			local other = node:GetData().ordinal;
			if ( not other or other > ordinal ) then
				return index;
			end
		end
		return #nodes + 1;
	end

	-- Inserts or removes setting nodes when their dependencies
	-- change, leaving the rest of the tree untouched.
	function Panel:OnDependencyChanged()
		local ledger = self.dependencyLedger;
		if not ledger then return end;
		local IsDatapointShown = env.Setting.IsDatapointShown;
		local skipInvalidation, dirty = true, false;
		for dp, entry in pairs(ledger) do
			local node = FindNodeByOrdinal(entry.header, entry.ordinal)
			if IsDatapointShown(dp) then
				if not node then
					local index = FindInsertionIndex(entry.header, entry.ordinal)
					entry.header:InsertNodeAtIndex(dp.type:New(dp), index):GetData().ordinal = entry.ordinal;
					dirty = true;
				end
			elseif node then
				entry.header:Remove(node, skipInvalidation)
				dirty = true;
			end
		end
		if dirty then
			local _, right = self:GetLists()
			right:GetDataProvider():Invalidate()
		end
	end
end

function Panel:UpdateDependencyWatchers()
	local watchers = self.dependencyWatchers;
	if watchers then
		for _, watcher in ipairs(watchers) do
			watcher.registry:UnregisterCallback(watcher.event, self)
		end
		wipe(watchers)
	else
		watchers = {};
		self.dependencyWatchers = watchers;
	end
	if not self.activeData then return end;
	local seen = {};
	for _, dp in ipairs(self.activeData) do
		local deps = dp.field.deps;
		if deps then
			local registry = dp.registry or db;
			local events = seen[registry] or {};
			seen[registry] = events;
			for dep in pairs(deps) do
				local event = dep:match('/') and dep or (dp.pathID or 'Settings')..'/'..dep;
				if not events[event] then
					events[event] = true;
					registry:RegisterCallback(event, self.OnDependencyChanged, self)
					tinsert(watchers, { registry = registry, event = event })
				end
			end
		end
	end
end

function Panel:OnDirty()
	if self.activeData then
		self:RenderSettings()
	end
end

function Panel:OnFlushLeft()
	-- This is called when the left panel is flushed,
	-- so we need to re-render the categories.
	if self:IsVisible() then
		self:RenderSections()
	end
end

function Panel:SetActiveCategory(text, data)
	self.activeText = text;
	self.activeData = data;
	self:RenderSettings()
end

function Panel:RenderSettings()
	if not self.activeData then
		return;
	end
	local _, right = self:GetLists()
	local settings = right:GetDataProvider()
	settings:Flush()
	self:Render(settings, self.activeText, self.activeData, true, true)
	self:UpdateDependencyWatchers()

	return settings;
end

function Panel:RenderSections()
	local sections = self:GetLists():GetDataProvider()
	sections:Flush()
	sections:Insert(self.MakeTitle(CATEGORIES))

	for main, group in env.table.spairs(self:GetIndex(), self.GroupSort) do
		local header = sections:Insert(self.MakeHeader(main, false))
		for head, data in env.table.spairs(group, self.CategorySort) do
			header:Insert(env.Elements.Subcat:New(head, data == self.activeData, data))
		end
		header:Insert(self.MakeDivider())
	end

	return sections;
end

function Panel:GetSearchTitle()
	return self.name;
end

function Panel.CategorySort(t, a, b)
	local iA, iB = t[a].sort, t[b].sort;
	if iA and not iB then
		return true;
	elseif iB and not iA then
		return false;
	elseif iA and iB then
		return iA < iB;
	else
		return a < b;
	end
end

---------------------------------------------------------------
Mixin(Settings, Panel)
---------------------------------------------------------------