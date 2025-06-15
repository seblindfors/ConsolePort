local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
local SEP = GRAY_FONT_COLOR:WrapTextInColorCode(' | ');

local function MakeDivider()
	return env.Elements.Divider:New(8)
end

local function MakeHeader(text, collapsed)
	return env.Elements.Header:New(L(text), collapsed)
end

local function MakeTitle(text)
	return env.Elements.Title:New(L(text))
end

---------------------------------------------------------------
-- Settings Panel
---------------------------------------------------------------
local Settings = env:CreatePanel({
	name      = SETTINGS;
	providers = {};
	mutators  = {};
	callbacks = {};
})

function Settings:AddProvider(provider)
	tinsert(self.providers, provider)
end

function Settings:AddMutator(mutator)
	-- Mutators are called after the providers, so they can modify the
	-- data set after it has been created.
	tinsert(self.mutators, mutator)
end

function Settings:OnLoad()
	CPAPI.Start(self)
	self:Reindex()
	self:SetActiveCategory(GENERAL, self.index[SETTING_GROUP_SYSTEM][GENERAL])
	env:RegisterCallback('OnSubcatClicked', self.OnSubcatClicked, self)
	env:RegisterCallback('OnSettingsDirty', self.OnSettingsDirty, self)
	env:RegisterCallback('OnFlushLeft', self.OnFlushLeft, self)
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
	db:RegisterCallback('OnVariablesChanged', self.OnVariablesChanged, self)
	db:RegisterCallback('Settings/useCharacterSettings', self.OnToggleCharacterSettings, self)
end

function Settings:OnShow()
	self:RenderCategories()
	self:RenderSettings()
end

function Settings:OnDefaults()
	db:TriggerEvent('OnVariablesReset')
	CPAPI.Log('Settings have been reset to default.')
end

function Settings:OnDependencyChanged(...)
	local _, right = self:GetLists()
	RunNextFrame(function()
		right:GetScrollView():Layout()
	end)
end

function Settings:OnToggleCharacterSettings(value)
	if self.toggleSettingsMutex then return end;
	self.toggleSettingsMutex = true;
	db:TriggerEvent('OnToggleCharacterSettings', value)
	self.toggleSettingsMutex = nil;
end

function Settings:OnVariablesChanged()
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

function Settings:OnSubcatClicked(text, set)
	local left = self:GetLists()
	left:GetDataProvider():ForEach(function(elementData)
		local data = elementData:GetData()
		data.checked = data.childData == set or nil;
	end, false)
	left:GetScrollView():ReinitializeFrames()
	self:SetActiveCategory(text, set)
end

function Settings:OnSettingsDirty()
	if self.activeData then
		self:RenderSettings()
	end
end

function Settings:OnFlushLeft()
	-- This is called when the left panel is flushed,
	-- so we need to re-render the categories.
	if self:IsVisible() then
		self:RenderCategories()
	end
end

function Settings:SetActiveCategory(text, data)
	self.activeText = text;
	self.activeData = data;
	self:RenderSettings()
end

function Settings:Render(provider, title, data, preferCollapsed, useDeviceEdit, flattened)
	if not flattened then
		provider:Insert(MakeTitle(title))
	end

	-- Sort settings into types of elements, which determines
	-- the default category they are placed in.
	local base, advd, cvar, path, after, before, xtra = {}, {}, {}, {}, {}, {}, {};
	for _, data in ipairs(data) do
		local target = base;
		if data.field.advd then
			target = advd;
		elseif data.field.cvar then
			target = cvar;
		elseif data.field.path then
			target = path;
		elseif data.field.after then
			target = after;
		elseif data.field.before then
			target = before;
		elseif data.field.xtra then
			target = xtra;
		end
		tinsert(target, data)
	end

	local activeHeaders = {};
	-- Returns a pointer to a shared header, creating it if it does not exist.
	local function GetHeader(name, collapsed)
		if not activeHeaders[name] then
			 activeHeaders[name] = provider:Insert(MakeHeader(name, collapsed))
			 activeHeaders[name]:SetCollapsed(collapsed)
		end
		return activeHeaders[name];
	end

	-- Returns a pointer to the list for the current setting.
	local __ = flattened and function(_, setting)
		local list = setting.field.list;
		if list then
			return GetHeader(title..SEP..list, false)
		end
		return GetHeader(title, false)
	end or function(default, setting, collapsed)
		if setting.field.advd then collapsed = preferCollapsed end;
		if setting.field.expd then collapsed = false end;
		return GetHeader(setting.field.list or default, collapsed)
	end

	local hasDeviceSettings = not not next(path);
	local renderDeviceEdit  = useDeviceEdit and hasDeviceSettings;

	if renderDeviceEdit then
		provider:Insert(env.Elements.DeviceEdit:New())
		provider:Insert(MakeDivider())
	end

	if not flattened and next(before) then
		for i, dp in ipairs(before) do
			provider:Insert(dp.type:New(dp))
		end
		provider:Insert(MakeDivider())
	end
	if next(base) then
		for i, dp in ipairs(base) do
			__(GENERAL, dp, false):Insert(dp.type:New(dp))
		end
	end
	if hasDeviceSettings then
		for i, dp in ipairs(path) do
			__(SYSTEM, dp, false):Insert(dp.type:New(dp))
		end
	end
	if next(cvar) then
		for i, dp in ipairs(cvar) do
			__(SYSTEM, dp, false):Insert(dp.type:New(dp))
		end
	end
	if next(advd) then
		for i, dp in ipairs(advd) do
			__(ADVANCED_LABEL, dp, preferCollapsed):Insert(dp.type:New(dp))
		end
	end
	if not flattened and next(after) then
		for i, dp in ipairs(after) do
			provider:Insert(dp.type:New(dp))
		end
	end
	if next(xtra) then
		for i, dp in ipairs(xtra) do
			__(ADVANCED_LABEL, dp, preferCollapsed):Insert(dp.type:New(dp))
		end
	end
	for _, header in pairs(activeHeaders) do
		header:Insert(MakeDivider())
	end

	-- Return true if a device select is necessary, but has not been added.
	return hasDeviceSettings and not useDeviceEdit;
end

function Settings:RenderSettings()
	if not self.activeData then
		self.renderMutex = nil;
		return;
	end
	local _, right = self:GetLists()
	local settings = right:GetDataProvider()
	settings:Flush()
	self:Render(settings, self.activeText, self.activeData, true, true)
end

function Settings:RenderCategories()
	local categories = self:GetLists():GetDataProvider()
	categories:Flush()
	categories:Insert(MakeTitle(CATEGORIES))

	for main, group in env.table.spairs(self.index, self.GroupSort) do
		local header = categories:Insert(MakeHeader(main, false))
		for head, data in env.table.spairs(group, self.CategorySort) do
			header:Insert(env.Elements.Subcat:New(head, data == self.activeData, data))
		end
		header:Insert(MakeDivider())
	end
end

function Settings:OnSearch(text, provider) text = text:lower();
	if not self.index then
		self:Reindex();
	end

	local MinEditDistance = CPAPI.MinEditDistance;

	local results = {};
	local function AddResult(main, head, data)
		local key = main..SEP..head;
		if not results[key] then
			results[key] = {};
		end
		tinsert(results[key], data);
	end

	local function TestString(str)
		return str and str:lower():find(text);
	end

	local function FilterDatapoint(dp)
		local field = dp.field;
		local name = field.name;
		return ( name and MinEditDistance(name:lower(), text) < 3 ) or TestString(name)
			or TestString(field.desc)
			or TestString(field.note)
			or TestString(field.list);
	end

	for main, group in env.table.spairs(self.index) do
		for head, data in env.table.spairs(group) do
			for _, dp in ipairs(data) do
				if FilterDatapoint(dp) then
					AddResult(main, head, dp);
				end
			end
		end
	end

	local needsDeviceEdit = false;
	for main, group in env.table.spairs(results) do
		if self:Render(provider, main, group, false, false, true) then
			needsDeviceEdit = true;
		end
	end

	if needsDeviceEdit then
		provider:InsertAtIndex(MakeDivider(), 1)
		provider:InsertAtIndex(env.Elements.DeviceEdit:New(), 1)
	end
	if next(results) then
		provider:InsertAtIndex(MakeTitle(SETTINGS), 1)
	end
end

function Settings:Reindex()
	local interface, sortIndex = {}, {};
	self.index = interface;

	for provider, callbacks in pairs(self.callbacks) do
		for event in pairs(callbacks) do
			db:UnregisterCallback(event, provider);
		end
	end
	wipe(self.callbacks);

	local function GetSortIndex(main, head, index)
		return max(sortIndex[main] and sortIndex[main][head] or 0, index or 0);
	end

	local function AddSetting(main, head, data)
		if not interface[main] then
			interface[main], sortIndex[main] = {}, {};
		end
		if not interface[main][head] then
			interface[main][head] = {};
			sortIndex[main][head] = 0;
		end
		local store = interface[main][head];
		tinsert(store, data);
		sortIndex[main][head] = GetSortIndex(main, head, data.sort);
		return store;
	end

	for i, provider in ipairs(self.providers) do
		local callbacks = { securecallfunction(provider, AddSetting, GetSortIndex, interface, i) };
		if next(callbacks) then
			for _, event in ipairs(callbacks) do
				db:RegisterCallback(event, GenerateClosure(self.OnVariablesChanged, self), provider);
				self.callbacks[provider] = self.callbacks[provider] or {};
				self.callbacks[provider][event] = true;
			end
		end
	end

	for _, group in pairs(interface) do
		for _, data in pairs(group) do
			table.sort(data, function(a, b)
				return a.sort < b.sort;
			end)
		end
	end

	for i, mutator in ipairs(self.mutators) do
		securecallfunction(mutator, AddSetting, GetSortIndex, interface, i)
	end
end