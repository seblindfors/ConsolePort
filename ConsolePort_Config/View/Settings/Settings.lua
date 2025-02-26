local env, db = CPAPI.GetEnv(...);
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
		return;
	end
	local _, right = self:GetLists()
	local settings = right:GetDataProvider()
	settings:Flush()

	settings:Insert(env.Elements.Title:New(self.activeText))

	local base, advd, cvar = {}, {}, {};
	for _, data in ipairs(self.activeData) do
		local target = base;
		if data.field.advd then
			target = advd;
		elseif data.field.cvar then
			target = cvar;
		end
		tinsert(target, data)
	end

	if next(base) then
		local header = settings:Insert(env.Elements.Header:New(SETTINGS, false))
		for i, dp in ipairs(base) do
			header:Insert(env.Elements.Setting:New(dp))
		end
		header:Insert(env.Elements.Divider:New(4))
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
		header:Insert(env.Elements.Divider:New(4))
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

	local function AddSetting(main, head, id, data)
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
		AddSetting(main, head, data.name, {
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
		System    = SETTINGS;
	};

	for head, group in pairs(db.Console) do
		local main = ConsoleToSettingsMap[head] or SETTINGS;
		local sort = GetSortIndex(main, head);
		for i, data in ipairs(group) do
			AddSetting(main, head, data.name, {
				varID = data.cvar;
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
	dbg = interface
end