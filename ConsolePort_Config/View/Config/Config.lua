local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Panel = {};
---------------------------------------------------------------

function Panel:Init(id, container, navButton)
	self.id = id;
	self.container = container;
	self.navButton = navButton;
	self:SetParent(container)
	env:RegisterCallback('OnPanelLoad', self.OnPanelLoad, self)
	return self;
end

function Panel:GetLists()
	return self.container:GetLists();
end

function Panel:GetCanvas()
	return self.container:GetCanvas();
end

function Panel:OnPanelLoad(id)
	if id ~= self.id then return end;
	self:OnLoad()
	env:UnregisterCallback('OnPanelLoad', self)
	env:RegisterCallback('OnPanelShow', self.OnPanelShow, self)
	self:OnPanelShow(id)
end

function Panel:OnPanelShow(id)
	if id ~= self.id then
		return self:Hide()
	end
	self:Show()
end

function Panel:OnSearch(text, dataProvider)
	-- query string, dataprovider to add results to
end

function Panel:OnDefaults()
	-- reset to defaults
end

---------------------------------------------------------------
local Container = {};
---------------------------------------------------------------

function Container:OnLoad()
	FrameUtil.SpecializeFrameWithMixins(self, CPBackgroundMixin)
	self:SetBackgroundInsets(4, -4, 4, 4)
	self:AddBackgroundMaskTexture(self.BorderArt.BgMask)
	self:SetBackgroundAlpha(0.25)
	self.Left:InitDefault()

	local XML_SETTING_TEMPLATE = 'CPSetting';

	local function SettingFactory(self, info)
		local pool = self.frameFactory.poolCollection:GetOrCreatePool('CheckButton',
			self:GetScrollTarget(), info.xml, self.frameFactoryResetter, nil, info.type)
		local frame, new = pool:Acquire()
		self.initializers[frame] = info.init;
		self.factoryFrame = frame;
		self.factoryFrameIsNew = new;
	end

	local scrollView = self.Right:InitDefault()
	scrollView:SetElementFactory(function(factory, elementData)
		local info = elementData:GetData()
		if ( info.xml ~= XML_SETTING_TEMPLATE ) then
			return factory(info.xml, info.init)
		end
		SettingFactory(scrollView, info)
	end)
end

function Container:ToggleLayout(canvasEnabled)
	self.Left:SetShown(not canvasEnabled)
	self.Right:SetShown(not canvasEnabled)
	self.Canvas:SetShown(canvasEnabled)
end

function Container:GetLists()
	self:ToggleLayout(false)
	return self.Left, self.Right;
end

function Container:GetCanvas()
	self:ToggleLayout(true)
	return self.Canvas;
end

---------------------------------------------------------------
local Search = {};
---------------------------------------------------------------

function Search:OnLoad()
	env.Search.OnLoad(self)
	env:RegisterCallback('OnSubcatClicked', self.OnSubcatClicked, self)
end

function Search:OnSubcatClicked()
	self:SetText('')
end

---------------------------------------------------------------
local Results = CPAPI.CreateElement('SettingsListSectionHeaderTemplate', 292, 45);
---------------------------------------------------------------

function Results:Init(elementData)
	local info = elementData:GetData()
	self.Title:SetText(info.text)
	self.Title:SetPoint('TOPRIGHT', -7, -16)
	self:SetSize(Results.size:GetXY())
end

function Results:Data(text)
	return { text = text };
end

---------------------------------------------------------------
local IconSelector = {};
---------------------------------------------------------------

function IconSelector:OnLoad()
	self.activeIconFilter = IconSelectorPopupFrameIconFilterTypes.All;
	self.IconHeader.Text:ClearAllPoints()
	self.IconHeader.Text:SetPoint('LEFT', 40, 0)
	self.IconHeader.Text:SetFontObject(GameFontNormalMed1)
	self:SetSize(508, 500)
	self:Update()
end

function IconSelector:Update()
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
		self:Update()
	end

	self.IconType.Dropdown:SetupMenu(function(dropdown, rootDescription)
		for key, filterType in pairs(IconSelectorPopupFrameIconFilterTypes) do
			local text = _G['ICON_FILTER_' .. strupper(key)];
			rootDescription:CreateRadio(text, IsSelected, SetSelected, filterType);
		end
	end)

	self.IconSelector:SetSelectedCallback(function(index)
		-- HACK: If we're clicking with the interface cursor,
		-- skip the need to hit accept and just set the icon.
		RunNextFrame(function()
			if not self.popup then return end;
			self.popup.button1:Enable();
			if self.popup.editBox:IsShown() then return end;
			local cursorNode = ConsolePort:GetCursorNode()
			if ( cursorNode and cursorNode.selectionIndex == index ) then
				StaticPopup_OnClick(self.popup, 1) -- accept
			end
		end)
	end)
end

---------------------------------------------------------------
local Config = CreateFromMixins(CPButtonCatcherMixin); env.Config = Config;
---------------------------------------------------------------

function Config:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	FrameUtil.SpecializeFrameWithMixins(self.Container, Container)
	FrameUtil.SpecializeFrameWithMixins(self.Search, env.Search, Search)

	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)
	self:SetScript('OnKeyDown', self.OnKeyDown)

	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)

	env:RegisterCallback('OnPanelShow', self.OnPanelShow, self)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
	env:RegisterCallback('OnBindingClicked', self.OnBindingClicked, self)
	env:RegisterCallback('OnBindingIconClicked', self.OnBindingIconClicked, self)
	env:RegisterCallback('OnBindingPresetAddClicked', self.OnBindingPresetAddClicked, self)
	env:RegisterCallback('OnBindingPresetIconClicked', self.OnBindingPresetIconClicked, self)

	env:TriggerEvent('OnConfigLoad', self)

	-- Nav bar buttons
	local L = env.L;
	self.CloseButton:SetTooltipInfo(SETTINGS_CLOSE, L(
		'The configuration is accessible by the chat command %s or from the game menu.',
		GREEN_FONT_COLOR:WrapTextInColorCode('/consoleport')
	))
	self.Defaults:SetTooltipInfo(SETTINGS_DEFAULTS, L(
		'Apply default settings to the current category or all settings.'
	))
	self.Import:SetTooltipInfo(L'Import', L(
		'Import serialized settings from an external source.'
	))
	self.Export:SetTooltipInfo(L'Export', L(
		'Export serialized settings for sharing or backup.'
	))

	self.CloseButton:SetOnClickHandler(GenerateClosure(self.Hide, self))
	self.Defaults:SetOnClickHandler(GenerateClosure(CPAPI.Popup, 'ConsolePort_Defaults_Config', {
		text            = CONFIRM_RESET_INTERFACE_SETTINGS;
		button1         = ALL_SETTINGS;
		button3         = CURRENT_SETTINGS;
		button2         = CANCEL;
		hideOnEscape    = 1;
		showAlert       = 1;
		fullScreenCover = true;
		OnCancel        = nop;
		OnAccept = function(self)
			-- TODO: SettingsPanel:SetAllSettingsToDefaults();
		end;
		OnAlt = function()
			self:GetCurrentPanel():OnDefaults()
		end;
	}))
	self.Import:SetOnClickHandler(GenerateClosure(env.TriggerEvent, env, 'OnImportButtonClicked'))
	self.Export:SetOnClickHandler(GenerateClosure(env.TriggerEvent, env, 'OnExportButtonClicked'))
end

---------------------------------------------------------------
-- Components
---------------------------------------------------------------

function Config:GetCatcher()
	if not self.Catcher then
		self.Catcher = CreateFrame('Button', nil, self, CPBindingCatcherMixin.Template)
		self.Catcher.promptText = L.SLOT_SET_BINDING;
		FrameUtil.SpecializeFrameWithMixins(self.Catcher, CPBindingCatcherMixin)
	end
	return self.Catcher;
end

function Config:GetIconSelector()
	if not self.IconSelector then
		self.IconSelector = CreateFrame('Frame', nil, self, 'CPConfigIconSelector')
		FrameUtil.SpecializeFrameWithMixins(self.IconSelector, IconSelector)
	end
	return self.IconSelector;
end

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------

function Config:OnShow()
	FrameUtil.UpdateScaleForFit(self, 40, 80)
	self:SetDefaultClosures()
	self:OnActiveDeviceChanged()
end

function Config:SetDefaultClosures()
	self:ReleaseClosures()
end

function Config:OnActiveDeviceChanged()
	self.hasActiveDevice = not not db.Gamepad.Active;
	if self.hasActiveDevice and not self.isClosableByEsc then
		tinsert(UISpecialFrames, self:GetName())
		self.isClosableByEsc = true;
	end
end

function Config:OnSearch(text)
	if text then
		local _, right = self.Container:GetLists()
		local results = right:GetDataProvider()
		results:Flush()
		for _, panel in env:EnumeratePanels() do
			panel:OnSearch(text, results)
		end
		if results:IsEmpty() then
			results:Insert(env.Elements.Title:New(SEARCH))
			results:Insert(Results:New(SETTINGS_SEARCH_NOTHING_FOUND:gsub('%. ', '.\n')))
		end
		return;
	end
	local currentPanel = self:GetCurrentPanel()
	if currentPanel then
		ExecuteFrameScript(currentPanel, 'OnShow')
	end
end

function Config:OnBindingClicked(bindingID, isClearEvent, readonly, element)
	if readonly then
		return;
	end

	local catcher = self:GetCatcher()

	if isClearEvent then
		catcher:ClearBindingsForID(bindingID)
		return SaveBindings(GetCurrentBindingSet())
	end

	catcher:TryCatchBinding({
		text = catcher.promptText;
		OnShow = function()
			self:PauseCatcher()
			ConsolePort:SetCursorNodeIfActive(element)
			RunNextFrame(function()
				-- Workaround for the tooltip overlapping the binding catcher,
				-- and presenting button prompts that are disabled while
				-- the binding catcher is active.
				GameTooltip:Hide()
				GameTooltip_HideShoppingTooltips(GameTooltip)
			end)
		end;
		OnHide = function()
			self:ResumeCatcher()
			ConsolePort:SetCursorNodeIfActive(element)
		end;
	}, BLUE_FONT_COLOR:WrapTextInColorCode(env:GetBindingName(bindingID)), nil, {
		bindingID = bindingID;
	})
end

function Config:OnBindingIconClicked(bindingID, isClearEvent, element, callback)
	if isClearEvent then
		db.Bindings:SetIcon(bindingID, nil)
		return callback(element, db.Bindings:GetIcon(bindingID))
	end

	self:ShowIconSelector({
		name  = env:GetBindingName(bindingID);
		icon  = db.Bindings:GetIcon(bindingID);
		call  = callback;
		owner = element;
	});
end

function Config:OnBindingPresetIconClicked(name, icon, element, callback)
	self:ShowIconSelector({
		name  = name;
		icon  = icon;
		call  = callback;
		owner = element
	})
end

function Config:OnBindingPresetAddClicked(element, callback)
	self:ShowIconSelector({
		name  = L'Create Binding Preset';
		call  = callback;
		owner = element;
		button1 = SAVE;
		hasEditBox = true;
		initialText = DEFAULT;
	})
end

function Config:ShowIconSelector(info)
	local container = self:GetIconSelector()
	local selector  = container.IconSelector;
	local popup = CPAPI.Popup('ConsolePort_IconSelector', {
		text = ''; -- HACK: text is required for the popup.
		button1 = info.button1 or ACCEPT;
		button2 = info.button2 or CANCEL;
		hasEditBox = info.hasEditBox;
		hideOnEscape = true;
		enterClicksFirstButton = true;
		selectCallbackByIndex = true;
		OnShow = function(popup, data)
			local index = selector.iconDataProvider:GetIndexOfIcon(data.icon);
			selector:SetSelectedIndex(index);
			selector:ScrollToSelectedIndex();
			container.popup = popup;
			ConsolePort:RemoveInterfaceCursorFrame(self)

			popup.button1:SetEnabled(not not index)
			if data.hasEditBox and data.initialText then
				popup.editBox:SetText(data.initialText)
			end
		end;
		OnAccept = function(popup, data)
			local index = selector:GetSelectedIndex()
			local icon = index and selector.iconDataProvider:GetIconByIndex(index);
			if icon then
				data.call(data.owner, icon, true, data.hasEditBox and popup.editBox:GetText() or nil)
			end
		end;
		OnCancel = nop;
		OnHide = function(_, data)
			ConsolePort:AddInterfaceCursorFrame(self)
			ConsolePort:SetCursorNodeIfActive(data.owner)
			container.popup = nil;
		end;
	}, info.name, nil, info, container)
	container.IconHeader.Text:SetText(info.name)
	return popup;
end

---------------------------------------------------------------
-- Panels
---------------------------------------------------------------

function Config:OnPanelShow(id)
	if not self:GetAttribute(id) then
		self:SetAttribute(id, true)
		env:TriggerEvent('OnPanelLoad', id)
	end
	self.currentPanelID = id;
end

function Config:GetCurrentPanel()
	return env:GetPanelByID(self.currentPanelID)
end

do  local panelIDGen, panels = CreateCounter(), {};
	local function NavButtonOnClick(self, navBar, id)
		env:TriggerEvent('OnPanelShow', id)
	end

	local function NavButtonOnPanelShow(self, id)
		self:SetLockHighlight(id == self:GetID())
	end

	local function PanelInitializer(panel, panelID, info, config)
		local navButton = config.Nav:AddButton(info.name, NavButtonOnClick, panelID)
		navButton:SetID(panelID)
		env:RegisterCallback('OnPanelShow', NavButtonOnPanelShow, navButton)
		env:UnregisterCallback('OnConfigLoad', panel)
		panel:Init(panelID, config.Container, navButton)
	end

	function env:CreatePanel(info)
		local panelID = panelIDGen()
		local panel = Mixin(CreateFrame('Frame'), Panel)
		panel:Hide()
		panels[panelID] = panel;
		if self.Frame then
			PanelInitializer(panel, panelID, info, self.Frame)
		else
			env:RegisterCallback('OnConfigLoad', PanelInitializer, panel, panelID, info)
		end
		return panel, Panel;
	end

	function env:EnumeratePanels()
		return ipairs(panels)
	end

	function env:GetPanelByID(id)
		return panels[id];
	end

	function env:GetContextPanel()
		return panels[#panels];
	end
end