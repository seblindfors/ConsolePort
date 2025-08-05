local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Panel = {};
---------------------------------------------------------------

function Panel:InitPanel(id, container, navButton)
	self.id = id;
	self.isEnabled = true;
	self.container = container;
	self.navButton = navButton;
	self:SetParent(container)
	env:RegisterCallback('OnPanelLoad', self.OnPanelLoad, self)
	if self.OnInit then
		self:OnInit(id, container, navButton)
	end
end

function Panel:GetLists()
	return self.container:GetLists();
end

function Panel:GetCanvas(reset)
	return self.container:GetCanvas():Flush():GetContainer(self, reset)
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

function Panel:IsEnabled()
	return self.isEnabled;
end

function Panel:SetEnabled(enabled)
	self.isEnabled = not not enabled;
	self.navButton:SetEnabled(enabled)
end

function Panel:OnSearch(text, dataProvider)
	-- query string, dataprovider to add results to
end

function Panel:OnDefaults()
	-- reset to defaults
end

---------------------------------------------------------------
local Canvas = CreateFromMixins(CPIndexPoolMixin)
---------------------------------------------------------------

function Canvas:OnLoad()
	CPIndexPoolMixin.OnLoad(self)
	self:CreateFramePool('Frame')
end

function Canvas:Flush()
	for canvasPanel in self:EnumerateActive() do
		canvasPanel:Hide()
	end
	return self;
end

function Canvas:GetContainer(panel, reset)
	local canvasPanel, newObj = self:TryAcquireRegistered(panel.id)
	if newObj or reset then
		canvasPanel:ClearAllPoints()
		canvasPanel:SetPoint('CENTER', 0, 0)
		canvasPanel:SetSize(self:GetSize())
	end
	return canvasPanel, newObj;
end

---------------------------------------------------------------
local Container = {};
---------------------------------------------------------------

function Container:OnLoad()
	CPAPI.Specialize(self, env.Mixin.Background)

	self:SetBackgroundInsets(4, -4, 4, 4)
	self:AddBackgroundMaskTexture(self.BorderArt.BgMask)
	self:SetBackgroundAlpha(0.25)
end

function Container:ToggleLayout(canvasEnabled)
	if self.Left   then self.Left:SetShown(not canvasEnabled) end;
	if self.Right  then self.Right:SetShown(not canvasEnabled) end;
	if self.Canvas then self.Canvas:SetShown(canvasEnabled) end;
end

function Container:GetLists()
	self:ToggleLayout(false)
	return self:GetLeftScrollBox(), self:GetRightScrollBox();
end

function Container:GetCanvas()
	self:ToggleLayout(true)
	if not self.Canvas then
		self.Canvas = CreateFrame('Frame', nil, self)
		self.Canvas:SetPoint('TOPLEFT')
		self.Canvas:SetPoint('BOTTOMRIGHT', 10, 0)
		self.Canvas:SetClipsChildren(true)
		CPAPI.SpecializeOnce(self.Canvas, Canvas)
	end
	return self.Canvas;
end

function Container:GetLeftScrollBox()
	if not self.Left then
		self.Left = CreateFrame('Frame', nil, self, 'CPConfigScrollBox')
		self.Left:SetPoint('TOPLEFT', 0, -2)
		self.Left:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT', 320, 0)

		self.Left:InitDefault()
		self.Left.ScrollBar:SetAttribute('nodeignore', true)
	end
	return self.Left;
end

function Container:GetRightScrollBox()
	if not self.Right then
		self.Right = CreateFrame('Frame', nil, self, 'CPConfigScrollBox')
		self.Right:SetPoint('TOPLEFT', 340, -2)
		self.Right:SetPoint('BOTTOMRIGHT', -12, 0)
		CPScrollBoxSettingsTree.InitDefault(self.Right)
	end
	return self.Right;
end

---------------------------------------------------------------
local Search = {};
---------------------------------------------------------------

function Search:OnLoad()
	env.Search.OnLoad(self)
	env:RegisterCallback('Settings.OnSubcatClicked', self.ClearQuery, self)
end

function Search:ClearQuery()
	self:SetText('')
end

---------------------------------------------------------------
local Config = CreateFromMixins(CPButtonCatcherMixin, CPCombatHideMixin)
---------------------------------------------------------------
env.Config = Config;

function Config:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	CPAPI.SpecializeOnce(self.Container, Container)
	CPAPI.Specialize(self.Search, env.Search, Search)

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
		OnAccept = function()
			ConsolePort 'resetall';
		end;
		OnAlt = function()
			self:GetCurrentPanel():OnDefaults()
		end;
	}))
	self.Import:SetOnClickHandler(GenerateClosure(env.TriggerEvent, env, 'OnImportButtonClicked'))
	self.Export:SetOnClickHandler(GenerateClosure(env.TriggerEvent, env, 'OnExportButtonClicked'))
	self.Credits:SetScript('OnClick', GenerateClosure(env.TriggerEvent, env, 'OnPanelShow', 0))

	self.PanelSelectDelta = {
		PADLSHOULDER = -1;
		PADRSHOULDER =  1;
	};
end

---------------------------------------------------------------
-- Components
---------------------------------------------------------------

function Config:GetCatcher()
	if not self.Catcher then
		self.Catcher = CreateFrame('Button', nil, self, env.Mixin.BindingCatcher.Template)
		self.Catcher.promptText = L.SLOT_SET_BINDING;
		CPAPI.Specialize(self.Catcher, env.Mixin.BindingCatcher)
	end
	return self.Catcher;
end

function Config:GetIconSelector()
	if not self.IconSelector then
		self.IconSelector = CreateFrame('Frame', nil, self, env.IconSelector.Template)
		CPAPI.Specialize(self.IconSelector, env.IconSelector)
	end
	return self.IconSelector;
end

function Config:GetLoadoutSelector()
	if not self.LoadoutSelector then
		self.LoadoutSelector = CreateAndInitFromMixin(env.LoadoutSelector, self.Container)
	end
	return self.LoadoutSelector;
end

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------

function Config:OnShow()
	CPCombatHideMixin.OnShow(self)
	self:SetDefaultClosures()
	self:OnActiveDeviceChanged()
	CPAPI.Next(self.OnShowDelayed, self)
end

function Config:OnShowDelayed()
	FrameUtil.UpdateScaleForFit(self, 40, 80)
	if not self.currentPanelID then
		self:SetCurrentPanel(SETTINGS)
	end
end

function Config:SetDefaultClosures()
	self:ReleaseClosures()
	for button, delta in pairs(self.PanelSelectDelta) do
		self:CatchButton(button, self.SetPanelByDelta, self, delta)
	end
end

function Config:FreeButton(button, closure)
	if not CPButtonCatcherMixin.FreeButton(self, button, closure) then
		return false;
	end
	local panelSelectDelta = self.PanelSelectDelta[button];
	if panelSelectDelta then
		self:CatchButton(button, self.SetPanelByDelta, self, panelSelectDelta)
	end
	return true;
end

function Config:OnActiveDeviceChanged()
	self.hasActiveDevice = not not db.Gamepad.Active;
	if self.hasActiveDevice and not self.isClosableByEsc then
		tinsert(UISpecialFrames, self:GetName())
		self.isClosableByEsc = true;
	end
end

function Config:OnBindingClicked(bindingID, isClearEvent, readonly, element)
	if readonly then
		return;
	end

	if isClearEvent then
		return env:ClearBindingsForID(bindingID, true)
	end

	local catcher = self:GetCatcher()
	catcher:TryCatchBinding({
		text = catcher.promptText;
		OnShow = function()
			self:PauseCatcher()
			ConsolePort:SetCursorNodeIfActive(element)
			CPAPI.Next(function(tooltip)
				-- Workaround for the tooltip overlapping the binding catcher,
				-- and presenting button prompts that are disabled while
				-- the binding catcher is active.
				tooltip:Hide()
				GameTooltip_HideShoppingTooltips(tooltip)
			end, GameTooltip)
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
	if not actionID then return end;
	local left = self.Container:GetLeftScrollBox()
	return self:GetLoadoutSelector()
		:SetExternalLip(nil)
		:SetAlternateTitle(nil)
		:SetDataProvider(left:GetDataProvider())
		:SetScrollView(left:GetScrollView())
		:SetCloseCallback(GenerateClosure(env.TriggerEvent, env, 'OnFlushLeft'))
		:SetToggleByID(true)
		:EditAction(actionID, bindingID, element)
end

---------------------------------------------------------------
-- Search
---------------------------------------------------------------

function Config:SetSearchOwner(searchOwner)
	self.searchOwner = searchOwner;
end

function Config:ClearSearchOwner(searchOwner)
	if self.searchOwner == searchOwner then
		self.searchOwner = nil;
	end
end

function Config:OnSearch(text)
	if self.searchOwner then
		if self.searchOwner.OnSearch then
			return self.searchOwner:OnSearch(text)
		end
		return; -- search owner handled the search
	end
	if text then
		local _, right = self.Container:GetLists()
		local results = right:GetDataProvider()
		results:Flush()
		for _, panel in env:EnumeratePanels() do
			panel:OnSearch(text, results, results.node:GetSize() + 1)
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

function Config:SetCurrentPanelByID(id)
	local panel = env:GetPanelByID(id)
	assert(panel, 'Panel does not exist: ' .. tostring(id))
	if not panel:IsEnabled() then return end;
	env:TriggerEvent('OnPanelShow', id)
end

function Config:SetCurrentPanel(name)
	for id, panel in env:EnumeratePanels() do
		if panel.name == name then
			return self:SetCurrentPanelByID(id)
		end
	end
end

function Config:SetPanelByDelta(delta)
	if not self.currentPanelID then return end;
	local newPanelID = Clamp(self.currentPanelID + delta, 1, env:GetNumPanels())
	if newPanelID ~= self.currentPanelID then
		self:SetCurrentPanelByID(newPanelID)
		ConsolePort:SetCursorNodeIfActive(self:GetCurrentPanel().navButton)
	end
end

do  local panelIDGen, panels = CreateCounter(-1), {};
	local function NavButtonOnClick(self, navBar, id)
		env:TriggerEvent('OnPanelShow', id)
	end

	local function NavButtonOnPanelShow(self, id)
		self:SetLockHighlight(id == self:GetID())
	end

	local function PanelInitializer(panel, panelID, info, config)
		local navButton;
		if info.nav ~= false then
			navButton = config.Nav:AddButton(info.name, NavButtonOnClick, panelID)
			navButton:SetID(panelID)
			navButton.layoutIndex = panelID;
			env:RegisterCallback('OnPanelShow', NavButtonOnPanelShow, navButton)
		end
		env:UnregisterCallback('OnConfigLoad', panel)
		panel:InitPanel(panelID, config.Container, navButton)
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

	function env:GetNumPanels()
		return #panels;
	end
end