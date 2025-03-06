local DP, env, db = 1, CPAPI.GetEnv(...);
---------------------------------------------------------------

local function MakeDivider()
	return env.Elements.Divider:New(8)
end

local function MakeHeader(text, collapsed)
	return env.Elements.Header:New(text, collapsed)
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
end

function Settings:OnDependencyChanged(...)
	local _, right = self:GetLists()
	RunNextFrame(function()
		right:GetScrollView():Layout()
	end)
end

function Settings:OnSubcatClicked(text, set)
	local left, right = self:GetLists()
	left:GetDataProvider():ForEach(function(elementData)
		local data = elementData:GetData()
		data.checked = data.childData == set or nil;
	end, true)
	left:GetScrollView():ReinitializeFrames()
	self.activeText = text;
	self.activeData = set;
	self:RenderSettings()
end

function Settings:RenderSettings()
	if not self.activeData then
		self.renderMutex = nil;
		return;
	end
	local _, right = self:GetLists()
	local settings = right:GetDataProvider()
	settings:Flush()

	settings:Insert(env.Elements.Title:New(self.activeText))

	-- Sort settings into categories
	local base, advd, cvar, path = {}, {}, {}, {};
	for _, data in ipairs(self.activeData) do
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
			 activeHeaders[name] = settings:Insert(MakeHeader(name, collapsed))
		end
		return activeHeaders[name];
	end

	-- Insert settings into the scrollbox under headers
	if next(base) then
		local header = GetHeader(SETTINGS, false)
		for i, dp in ipairs(base) do
			header:Insert(env.Elements.Setting:New(dp))
		end
		header:Insert(MakeDivider())
	end
	if next(path) then
		local header = GetHeader(SYSTEM, false)
		for i, dp in ipairs(path) do
			header:Insert(env.Elements.Mapper:New(dp))
		end
		header:Insert(MakeDivider())
	end
	if next(cvar) then
		local header = GetHeader(SYSTEM, false)
		for i, dp in ipairs(cvar) do
			header:Insert(env.Elements.Cvar:New(dp))
		end
		header:Insert(MakeDivider())
	end
	if next(advd) then
		local header = settings:Insert(env.Elements.Header:New(ADVANCED_LABEL, true))
		for i, dp in ipairs(advd) do
			header:Insert(env.Elements.Setting:New(dp))
		end
	end
end

function Settings:RenderCategories()
	local left = self:GetLists()

	local categories = left:GetDataProvider()
	categories:Flush()

	for main, group in env.table.spairs(self.index) do
		local header = categories:Insert(env.Elements.Header:New(main, true))
		for head, data in env.table.spairs(group) do
			header:Insert(env.Elements.Subcat:New(head, data == self.activeData, data))
		end
		header:Insert(MakeDivider())
	end
end

function Settings:OnShow()
	self:RenderCategories()
	self:RenderSettings()
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
	dbg = interface -- debug
end