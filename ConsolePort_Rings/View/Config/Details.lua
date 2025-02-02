local env = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Details = {}; env.SharedConfig.Details = Details;
---------------------------------------------------------------

function Details:OnLoad()
	self.OptionsHeader.Text:SetText(OPTIONS)
	self.OptionsHeader.Text:ClearAllPoints()
	self.OptionsHeader.Text:SetPoint('LEFT', 40, 0)

	self.IconHeader.Text:SetText(EMBLEM_SYMBOL)
	self.IconHeader.Text:ClearAllPoints()
	self.IconHeader.Text:SetPoint('LEFT', 40, 0)

	self.activeIconFilter =  IconSelectorPopupFrameIconFilterTypes.All;
	self:UpdateIconDropdown()

	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
end

function Details:UpdateIconDropdown()
	local function IconFilterToIconTypes(filter)
		if ( filter == IconSelectorPopupFrameIconFilterTypes.All ) then
			return IconDataProvider_GetAllIconTypes();
		elseif (filter == IconSelectorPopupFrameIconFilterTypes.Spell) then
			return { IconDataProviderIconType.Spell };
		elseif (filter == IconSelectorPopupFrameIconFilterTypes.Item) then
			return { IconDataProviderIconType.Item };
		end
		return nil;
	end

	local function IsSelected(filterType)
		return self.activeIconFilter == filterType;
	end

	local function SetSelected(filterType)
		self.activeIconFilter = filterType;
		self.IconSelector.iconDataProvider:SetIconTypes(IconFilterToIconTypes(filterType));
		self.IconSelector:UpdateSelections()
		self:UpdateIconDropdown()
	end

	self.IconType.Dropdown:SetupMenu(function(dropdown, rootDescription)
		for key, filterType in pairs(IconSelectorPopupFrameIconFilterTypes) do
			local text = _G['ICON_FILTER_' .. strupper(key)];
			rootDescription:CreateRadio(text, IsSelected, SetSelected, filterType);
		end
	end)

	self.IconSelector:SetSelectedCallback(function(_, icon)
		env:SetIconForSet(self.currentSetID, icon)
		env:TriggerEvent('OnSetUpdate', self.currentSetID, true)
	end)
end

function Details:OnTabSelected(tabIndex, panels)
	self.isOptionsTabActive = tabIndex == panels.Options;
	self:Update()
end

function Details:OnSelectSet(_, setID, isSelected)
	self.currentSetID = isSelected and setID or nil;
	self:Update()
end

function Details:Update()
	self:SetShown(self.isOptionsTabActive and self.currentSetID ~= nil);
	if self:IsVisible() then
		self:UpdateSelectedIcon()
	end
end

function Details:UpdateSelectedIcon()
	local icon = env:GetSetIcon(self.currentSetID)
	local index = self.IconSelector.iconDataProvider:GetIndexOfIcon(icon);
	self.IconSelector:SetSelectedIndex(index);
end

function Details:OnSearch(text)
	self.searchTerm = text;
	if self:IsVisible() then
		self.IconSelector.iconDataProvider:SetSearchQuery(text);
		self.IconSelector:UpdateSelections();
		self:UpdateSelectedIcon();
	end
end