local env = CPAPI.GetEnv(...);
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

function Panel:OnDependencyChanged(...)
	local _, right = self:GetLists()
	RunNextFrame(function()
		right:GetScrollView():Layout()
	end)
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