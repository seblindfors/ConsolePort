local DP, env, db, L = 1, CPAPI.GetEnv(...); L = env.L;
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
	name = SETTINGS;
})

function Settings:OnLoad()
	CPAPI.Start(self)
	self:Reindex()
	env:RegisterCallback('OnSubcatClicked', self.OnSubcatClicked, self)
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
	db:RegisterCallback('OnVariablesChanged', self.OnVariablesChanged, self)
end

function Settings:OnShow()
	self:RenderCategories()
	self:RenderSettings()
end

function Settings:OnDependencyChanged(...)
	local _, right = self:GetLists()
	RunNextFrame(function()
		right:GetScrollView():Layout()
	end)
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
					return Refresh();
				end
			end
		end
		self.activeText, self.activeData = nil, nil;
	end
	Refresh()
end

function Settings:OnSubcatClicked(text, set)
	local left = self:GetLists()
	left:GetDataProvider():ForEach(function(elementData)
		local data = elementData:GetData()
		data.checked = data.childData == set or nil;
	end, true)
	left:GetScrollView():ReinitializeFrames()
	self.activeText = text;
	self.activeData = set;
	self:RenderSettings()
end

function Settings:Render(provider, title, data, preferCollapsed, useDeviceSelect, flattened)
	if not flattened then
		provider:Insert(MakeTitle(title))
	end

	-- Sort settings into types of elements, which determines
	-- the widget type used to display them.
	local base, advd, cvar, path = {}, {}, {}, {};
	for _, data in ipairs(data) do
		local target = base;
		if data.field.advd then
			target = advd;
		elseif data.field.cvar then
			target = cvar;
		elseif data.field.path then
			target = path;
		end
		tinsert(target, data)
	end

	local activeHeaders = {};
	local function GetHeader(name, collapsed)
		if not activeHeaders[name] then
			 activeHeaders[name] = provider:Insert(MakeHeader(name, collapsed))
		end
		return activeHeaders[name];
	end

	local _list = flattened and function(_, setting)
		local list = setting.field.list;
		if list then
			return GetHeader(title..SEP..list, false)
		end
		return GetHeader(title, false)
	end or function(default, setting, collapsed)
		if setting.field.advd then collapsed = preferCollapsed end;
		return GetHeader(setting.field.list or default, collapsed)
	end

	local hasDeviceSettings = not not next(path);
	-- Render this first so it appears at the top of the list, below the title.
	if useDeviceSelect and hasDeviceSettings then
		provider:Insert(env.Elements.DeviceSelect:New())
		provider:Insert(MakeDivider())
	end
	if next(base) then
		for i, dp in ipairs(base) do
			_list(GENERAL, dp, false):Insert(env.Elements.Setting:New(dp))
		end
	end
	if hasDeviceSettings then
		for i, dp in ipairs(path) do
			_list(SYSTEM, dp, false):Insert(env.Elements.Mapper:New(dp))
		end
	end
	if next(cvar) then
		for i, dp in ipairs(cvar) do
			_list(SYSTEM, dp, false):Insert(env.Elements.Cvar:New(dp))
		end
	end
	if next(advd) then
		for i, dp in ipairs(advd) do
			_list(ADVANCED_LABEL, dp, preferCollapsed):Insert(env.Elements.Setting:New(dp))
		end
	end
	for _, header in pairs(activeHeaders) do
		header:Insert(MakeDivider())
	end

	-- Return true if a device select is necessary, but has not been added.
	return hasDeviceSettings and not useDeviceSelect;
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
	local left = self:GetLists()

	local categories = left:GetDataProvider()
	categories:Flush()

	categories:Insert(MakeTitle(CATEGORIES))
	for main, group in env.table.spairs(self.index) do
		local header = categories:Insert(MakeHeader(main, false))
		for head, data in env.table.spairs(group) do
			header:Insert(env.Elements.Subcat:New(head, data == self.activeData, data))
		end
		header:Insert(MakeDivider())
	end
end

function Settings:Reindex()
	local interface, sortIndex = {}, {};

	local function GetSortIndex(main, head, index)
		return max(sortIndex[main][head] or 0, index or 0);
	end

	local function AddSetting(main, head, data)
		if not interface[main] then
			interface[main], sortIndex[main] = {}, {};
		end
		if not interface[main][head] then
			interface[main][head] = {};
			sortIndex[main][head] = 0;
		end
		tinsert(interface[main][head], data);
		sortIndex[main][head] = GetSortIndex(main, head, data.sort);
	end

	foreach(db.Variables, function(var, data)
		local head = data.head or MISCELLANEOUS;
		local main = data.main or SETTINGS;
		if data.hide then
			return;
		end
		AddSetting(main, head, {
			varID = var;
			field = data;
			sort  = data.sort;
		});
	end)

	local ConsoleToSettingsMap = {
		Mouse     = CONTROLS_LABEL;
		Camera    = CONTROLS_LABEL;
		Bindings  = CONTROLS_LABEL;
		Touchpad  = CONTROLS_LABEL;
		Interact  = BINDING_HEADER_TARGETING;
		Tooltips  = BINDING_HEADER_TARGETING;
		System    = INTERFACE_LABEL;
	};

	for head, group in pairs(db.Console) do
		local main = ConsoleToSettingsMap[head] or SETTINGS;
		local sort = GetSortIndex(main, head);
		for i, data in ipairs(group) do
			-- Sanity check: if the cvar is nil, it does not exist in
			-- the current game version. Skip it.
			local value = GetCVar(data.cvar);
			if ( value ~= nil ) then
				data[DP] = (data[DP] or data.type()):Set(value);
				AddSetting(main, head, {
					varID = data.cvar;
					field = data;
					sort  = sort + i;
				});
			end
		end
	end

	local ProfileToSettingsMap = {
		Movement = CONTROLS_LABEL;
		Camera   = CONTROLS_LABEL;
	};

	for head, group in pairs(db.Profile) do
		local main = ProfileToSettingsMap[head] or SETTINGS;
		local sort = GetSortIndex(main, head);
		for i, data in ipairs(group) do
			data[DP] = (data[DP] or data.data())
			AddSetting(main, head, {
				varID = data.path;
				field = data;
				sort  = sort + i;
			});
		end
	end

	for _, group in pairs(interface) do
		for _, data in pairs(group) do
			table.sort(data, function(a, b)
				return a.sort < b.sort;
			end)
		end
	end

	self.index = interface;
end

function Settings:OnSearch(text, provider) text = text:lower();
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
			or TestString(field.desc) or TestString(field.note) or TestString(field.list);
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

	local needsDeviceSelect = false;
	for main, group in env.table.spairs(results) do
		if self:Render(provider, main, group, false, false, true) then
			needsDeviceSelect = true;
		end
	end

	if needsDeviceSelect then
		provider:InsertAtIndex(MakeDivider(), 1)
		provider:InsertAtIndex(env.Elements.DeviceSelect:New(), 1)
	end
	if next(results) then
		provider:InsertAtIndex(MakeTitle(SETTINGS), 1)
	end
end