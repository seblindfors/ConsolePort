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
	self:SetActiveCategory(SYSTEM, self.index[CONTROLS_LABEL][SYSTEM])
	env:RegisterCallback('OnSubcatClicked', self.OnSubcatClicked, self)
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
	end, false)
	left:GetScrollView():ReinitializeFrames()
	self:SetActiveCategory(text, set)
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
	-- Returns a pointer to a shared header, creating it if it does not exist.
	local function _header(name, collapsed)
		if not activeHeaders[name] then
			 activeHeaders[name] = provider:Insert(MakeHeader(name, collapsed))
		end
		return activeHeaders[name];
	end

	-- Returns a pointer to the header for the current setting.
	local _list = flattened and function(_, setting)
		local list = setting.field.list;
		if list then
			return _header(title..SEP..list, false)
		end
		return _header(title, false)
	end or function(default, setting, collapsed)
		if setting.field.advd then collapsed = preferCollapsed end;
		return _header(setting.field.list or default, collapsed)
	end

	local hasDeviceSettings = not not next(path);
	local renderDeviceEdit  = useDeviceEdit and hasDeviceSettings;

	if renderDeviceEdit then
		provider:Insert(env.Elements.DeviceEdit:New())
		provider:Insert(MakeDivider())
	end

	if next(base) then
		for i, dp in ipairs(base) do
			_list(GENERAL, dp, false):Insert(dp.type:New(dp))
		end
	end
	if hasDeviceSettings then
		for i, dp in ipairs(path) do
			_list(SYSTEM, dp, false):Insert(dp.type:New(dp))
		end
	end
	if next(cvar) then
		for i, dp in ipairs(cvar) do
			_list(SYSTEM, dp, false):Insert(dp.type:New(dp))
		end
	end
	if next(advd) then
		for i, dp in ipairs(advd) do
			_list(ADVANCED_LABEL, dp, preferCollapsed):Insert(dp.type:New(dp))
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

	local function CategorySort(t, a, b)
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

	for main, group in env.table.spairs(self.index) do
		local header = categories:Insert(MakeHeader(main, false))
		for head, data in env.table.spairs(group, CategorySort) do
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

	-----------------------------------------------------------
	-- Addon settings
	-----------------------------------------------------------
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
			type  = env.Elements.Setting;
		});
	end)

	-----------------------------------------------------------
	-- Device profiles
	-----------------------------------------------------------
	do local numAddedDevices = 0;
		local deviceProfile = env.Elements.DeviceProfile;
		for name, device in db:For('Gamepad/Devices', true) do
			if device.Theme then
				local sort = GetSortIndex(CONTROLS_LABEL, SYSTEM);
				local data = deviceProfile:Data({
					device = device;
					varID  = ('Gamepad/Devices/%s'):format(name);
				});
				numAddedDevices = numAddedDevices + 1;
				data.type = deviceProfile;
				data.sort = sort + numAddedDevices;
				AddSetting(CONTROLS_LABEL, SYSTEM, data);
			end
		end
	end

	-----------------------------------------------------------
	-- Console settings (game native)
	-----------------------------------------------------------
	local ConsoleToSettingsMap = {
		Mouse     = CONTROLS_LABEL;
		Camera    = CONTROLS_LABEL;
		Bindings  = CONTROLS_LABEL;
		Touchpad  = CONTROLS_LABEL;
		Interact  = BINDING_HEADER_TARGETING;
		Tooltips  = BINDING_HEADER_TARGETING;
		System    = CONTROLS_LABEL;
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
					type  = env.Elements.Cvar;
				});
			end
		end
	end

	-----------------------------------------------------------
	-- Mapper profile settings (game native)
	-----------------------------------------------------------
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
				type  = env.Elements.Mapper;
			});
		end
	end

	-----------------------------------------------------------
	-- Customization
	-----------------------------------------------------------
	for _, group in pairs(interface) do
		for _, data in pairs(group) do
			table.sort(data, function(a, b)
				return a.sort < b.sort;
			end)
		end
	end

	-- This should be the first category, sort the rest alphabetically.
	interface[CONTROLS_LABEL][SYSTEM].sort = 1;

	-- Add custom device select setting.
	local deviceSelect = env.Elements.DeviceSelect;
	local deviceSelectData = deviceSelect:Data()
	AddSetting(CONTROLS_LABEL, SYSTEM, {
		varID = deviceSelectData.varID;
		field = deviceSelectData.field;
		type  = deviceSelect;
		sort  = 0;
	})
end