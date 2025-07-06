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
	self:SetActiveCategory(GENERAL, self.index[SETTING_GROUP_SYSTEM][GENERAL])
	env:RegisterCallback('Settings.OnSubcatClicked', self.OnSubcatClicked, self)
	env:RegisterCallback('Settings.OnDirty', self.OnDirty, self)
	env:RegisterCallback('OnFlushLeft', self.OnFlushLeft, self)
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
	db:RegisterCallback('OnVariablesChanged', self.OnIndexChanged, self)
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

function Settings:OnIndexChanged()
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

function Settings:OnDirty()
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

function Settings:RenderSettings()
	if not self.activeData then
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
	categories:Insert(self.MakeTitle(CATEGORIES))

	for main, group in env.table.spairs(self:GetIndex(), self.GroupSort) do
		local header = categories:Insert(self.MakeHeader(main, false))
		for head, data in env.table.spairs(group, self.CategorySort) do
			header:Insert(env.Elements.Subcat:New(head, data == self.activeData, data))
		end
		header:Insert(self.MakeDivider())
	end
end

function Settings:GetSearchTitle()
	return self.name;
end