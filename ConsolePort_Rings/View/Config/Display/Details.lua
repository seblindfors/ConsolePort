local env = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Command = {};
---------------------------------------------------------------

function Command:OnLoad()
	CPAPI.SetAtlas(self:GetNormalTexture(), 'perks-list-hover', false, true)
	CPAPI.SetAtlas(self:GetHighlightTexture(), 'perks-list-active', false, false)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
	self:SetText(self.text)
	self:SetSize(self:GetParent():GetWidth() + 8, 40)
	self:SetNormalFontObject(GameFontNormalMed2)
	self:SetHighlightFontObject(GameFontHighlightMed2)
	self:SetDisabledFontObject(CPGameFontDisableMed2)
	self.Icon:SetAtlas(self.icon)

	local base = env.SharedConfig.Env.Settings.Base;
	self:HookScript('OnEnter', base.OnEnter)
	self:HookScript('OnLeave', base.OnLeave)
	self.UpdateTooltip = base.UpdateTooltip;
end

function Command:OnClick(button)
	env:TriggerEvent(self.event, self, self:GetParent().currentSetID, button == 'RightButton')
end

---------------------------------------------------------------
local Details = {}; env.SharedConfig.Details = Details;
---------------------------------------------------------------

function Details:OnLoad()
	local prev, L = self.OptionsHeader, env.L;
	for key, option in env.table.spairs({
		Bind = {
			text    = KEY_BINDING;
			icon    = 'common-icon-forwardarrow';
			event   = 'OnBindSet';
			tooltipText = L'Assign or clear bindings for this set.';
			tooltipHints  = {
				env.SharedConfig.Env:GetTooltipPromptForClick('LeftClick', EDIT),
				env.SharedConfig.Env:GetTooltipPromptForClick('RightClick', REMOVE),
			};
		};
		Clear = {
			text    = CLEAR_ALL;
			icon    = 'common-icon-undo';
			event   = 'OnClearSet';
			tooltipText = L'Clear all items from this set.';
			disableTooltipHints = true;
		};
		Delete = {
			text    = DELETE;
			icon    = 'common-icon-redx';
			event   = 'OnDeleteSet';
			tooltipText = L'Remove this set. This action cannot be undone.';
			disableTooltipHints = true;
		};
	}) do
		local button = CreateFrame('Button', nil, self, 'CPPopupButtonTemplate');
		CPAPI.Specialize(button, Command, option)
		button:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -4);
		self[key], prev = button, button;
	end

	self.OptionsHeader.Text:SetText(OPTIONS)
	self.OptionsHeader.Text:ClearAllPoints()
	self.OptionsHeader.Text:SetPoint('LEFT', 40, 0)

	self.IconHeader.Text:SetText(EMBLEM_SYMBOL)
	self.IconHeader.Text:ClearAllPoints()
	self.IconHeader.Text:SetPoint('LEFT', 40, 0)

	self.BindingText = self.Bind:CreateFontString(nil, 'ARTWORK', 'CPGameFontDisableMed2')
	self.BindingText:SetPoint('RIGHT', -8, 0)
	CPAPI.Specialize(self.BindingText, CPSlugMixin)

	self.activeIconFilter = IconSelectorPopupFrameIconFilterTypes.All;
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
	self.BindingText:SetBinding(isSelected and env.Frame:GetBindingForSet(setID))
	self.Delete:SetEnabled(self.currentSetID ~= CPAPI.DefaultRingSetID)
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
	self.IconSelector:ScrollToSelectedIndex();
end

function Details:OnSearch(text)
	self.searchTerm = text;
	if self:IsVisible() then
		self.IconSelector.iconDataProvider:SetSearchQuery(text);
		self.IconSelector:UpdateSelections();
		self:UpdateSelectedIcon();
	end
end