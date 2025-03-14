local env, db = CPAPI.GetEnv(...);
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
local Config = CreateFromMixins(CPButtonCatcherMixin); env.Config = Config;
---------------------------------------------------------------

function Config:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	FrameUtil.SpecializeFrameWithMixins(self.Container, Container)
	FrameUtil.SpecializeFrameWithMixins(self.Search, env.Search, Search)
	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)
	self:SetScript('OnKeyDown', self.OnKeyDown)

	env:RegisterCallback('OnPanelShow', self.OnPanelShow, self)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
	env:TriggerEvent('OnConfigLoad', self)
end

function Config:OnPanelShow(id)
	if not self:GetAttribute(id) then
		self:SetAttribute(id, true)
		env:TriggerEvent('OnPanelLoad', id)
	end
	self.currentPanelID = id;
end

function Config:OnSearch(text)
	if text then
		local _, right = self.Container:GetLists()
		local results = right:GetDataProvider()
		results:Flush()
		for _, panel in env:EnumeratePanels() do
			panel:OnSearch(text, results)
		end
	elseif self.currentPanelID then
		ExecuteFrameScript(env:GetPanelByID(self.currentPanelID), 'OnShow')
	end
end

function Config:SetDefaultClosures()
	self:ReleaseClosures()
end

function Config:OnShow()
	FrameUtil.UpdateScaleForFit(self, 40, 80)
	self:SetDefaultClosures()
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
end