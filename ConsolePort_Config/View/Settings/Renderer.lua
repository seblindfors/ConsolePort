local env, db, _, L = CPAPI.GetEnv(...);
local Settings = env:GetContextPanel();
local Renderer = {}; env.SettingsRenderer = Renderer;

-----------------------------------------------------------
-- Helpers
-----------------------------------------------------------
local SEP = GRAY_FONT_COLOR:WrapTextInColorCode(' | ');

function Renderer.MakeDivider()
	return env.Elements.Divider:New(8)
end

function Renderer.MakeHeader(text, collapsed)
	return env.Elements.Header:New(L(text), collapsed)
end

function Renderer.MakeTitle(text)
	return env.Elements.Title:New(L(text))
end

---------------------------------------------------------------
-- Interface
---------------------------------------------------------------
function Renderer:Init()
	self.providers = {}; -- Data providers for the settings index.
	self.mutators  = {}; -- Mutators for the settings index.
	self.callbacks = {}; -- Callbacks to respond to visibility changes.
	assert(self.OnIndexChanged, 'Renderer must implement OnIndexChanged')
	assert(self.GetSearchTitle, 'Renderer must implement GetSearchTitle')
end

function Renderer:AddProvider(provider)
	-- Invoked with function(AddSetting, GetSortIndex, interface, index)
	-- Providers can return callback IDs to be registered.
	tinsert(self.providers, provider)
end

function Renderer:AddMutator(mutator)
	-- Mutators are called after the providers, so they can modify the
	-- data set after it has been created.
	tinsert(self.mutators, mutator)
end

function Renderer:GetIndex()
	if not self.index then
		return self:Reindex()
	end
	return self.index;
end

function Renderer:ReleaseCallbacks()
	for provider, callbacks in pairs(self.callbacks) do
		for event in pairs(callbacks) do
			db:UnregisterCallback(event, provider);
		end
	end
	wipe(self.callbacks);
end

function Renderer:ReleaseIndex()
	if self.index then
		self:ReleaseCallbacks()
		self.index = nil;
	end
end

---------------------------------------------------------------
-- Rendering
---------------------------------------------------------------
function Renderer:Render(provider, title, data, preferCollapsed, useDeviceEdit, flattened, headless)
	if not flattened then
		provider:Insert(self.MakeTitle(title))
	end

	-- Sort settings into types of elements, which determines
	-- the default category they are placed in.
	local base, advd, cvar, path, after, before, xtra = {}, {}, {}, {}, {}, {}, {};
	for _, dp in ipairs(data) do
		local target = base;
		if dp.field.advd then
			target = advd;
		elseif dp.field.cvar then
			target = cvar;
		elseif dp.field.path then
			target = path;
		elseif dp.field.after then
			target = after;
		elseif dp.field.before then
			target = before;
		elseif dp.field.xtra then
			target = xtra;
		end
		tinsert(target, dp)
	end

	local activeHeaders = {};
	-- Returns a pointer to a shared header, creating it if it does not exist.
	local function GetHeader(name, collapsed)
		if not activeHeaders[name] then
			 activeHeaders[name] = provider:Insert(self.MakeHeader(name, collapsed))
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
		provider:Insert(self.MakeDivider())
	end

	local allowHeadless = not flattened or headless;
	if allowHeadless and next(before) then
		for i, dp in ipairs(before) do
			provider:Insert(dp.type:New(dp))
		end
		provider:Insert(self.MakeDivider())
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
	if allowHeadless and next(after) then
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
		header:Insert(self.MakeDivider())
	end

	-- Return true if a device select is necessary, but has not been added.
	return hasDeviceSettings and not useDeviceEdit;
end

function Renderer:OnSearch(text, provider, startIndex) text = text:lower();
	local interface = self:GetIndex()
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
		local name  = field.name;
		local excl  = field.excludeSearch;

		return not excl and (( name and MinEditDistance(name:lower(), text) < 3 )
			or TestString(name)
			or TestString(field.desc)
			or TestString(field.note)
			or TestString(field.list));
	end

	for main, group in env.table.spairs(interface) do
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
		provider:InsertAtIndex(self.MakeDivider(), startIndex)
		provider:InsertAtIndex(env.Elements.DeviceEdit:New(), startIndex)
	end
	if next(results) then
		provider:InsertAtIndex(self.MakeTitle(self:GetSearchTitle()), startIndex)
	end
end

function Renderer:Reindex()
	local interface, sortIndex = {}, {};
	self.index = interface;

	self:ReleaseCallbacks()

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
			local callback = GenerateClosure(self.OnIndexChanged, self)
			for _, event in ipairs(callbacks) do
				db:RegisterCallback(event, callback, provider);
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

	return interface;
end

---------------------------------------------------------------
Mixin(Settings, Renderer):Init()
---------------------------------------------------------------