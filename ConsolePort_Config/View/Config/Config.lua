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
	self.Left.ScrollBar.Track:SetAttribute('nodeignore', true)

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
	env:RegisterCallback('OnSubcatClicked', self.ClearQuery, self)
end

function Search:ClearQuery()
	self:SetText('')
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
	env:RegisterCallback('OnActionSlotEdit', self.OnActionSlotEdit, self)
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
		self.IconSelector = CreateFrame('Frame', nil, self, env.IconSelector.Template)
		FrameUtil.SpecializeFrameWithMixins(self.IconSelector, env.IconSelector)
	end
	return self.IconSelector;
end

function Config:GetLoadoutSelector()
	if not self.LoadoutSelector then
		self.LoadoutSelector = CreateAndInitFromMixin(env.LoadoutSelector)
	end
	return self.LoadoutSelector;
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
			results:Insert(env.Elements.Results:New(SETTINGS_SEARCH_NOTHING_FOUND:gsub('%. ', '.\n')))
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
	return self:GetIconSelector():SetDataAndShow(info)
end

function Config:OnActionSlotEdit(actionID, bindingID, element)
	return self:GetLoadoutSelector():EditAction(actionID, bindingID, element)
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
		local panel = Mixin(CreateFrame('Frame'), Panel, info)
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