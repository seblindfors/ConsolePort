---------------------------------------------------------------
-- Config.lua: Base config frame
---------------------------------------------------------------
-- Provides a template function for convenient panel creation.

local _, db = ...
local TUTORIAL = db.TUTORIAL.CONFIG
local FadeIn, FadeOut, Mixin = db.UIFrameFadeOut, db.UIFrameFadeIn, db.table.mixin
local red, green, blue = db.Atlas.GetCC()
---------------------------------------------------------------
local ConsolePort, WindowMixin = ConsolePort, {}
local Popup = db.Atlas.GetFutureWindow("ConsolePortPopup")
local Config = db.Atlas.GetFutureWindow("ConsolePortConfig")
local Scroll = CreateFrame("ScrollFrame", "$parentBannerScroll", Config)
local Category = CreateFrame("Frame", "$parentCategories", Scroll)
local Container = CreateFrame("Frame", "$parentContainer", Config)
---------------------------------------------------------------
-- beta
Config.BetaCorner = CreateFrame("Frame", nil, Config)
Config.BetaCorner:SetFrameLevel(3)
Config.BetaCorner:SetPoint("TOPRIGHT", -16, -16)
Config.BetaCorner:SetSize(70, 70)
Config.Beta = Config.BetaCorner:CreateTexture(nil, "ARTWORK")
Config.Beta:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
Config.Beta:SetTexCoord(0.9121, 1, 0, 0.0878)
Config.Beta:SetSize(70, 70)
Config.Beta:SetPoint("TOPRIGHT")
---------------------------------------------------------------
ConsolePort.configFrame = Config
Config.Category = Category
Config.Container = Container
---------------------------------------------------------------
Config.Close:Hide()
Config:SetFrameStrata("DIALOG")
Config:SetSize(1000, 800)
Config:SetPoint("CENTER", 0, 0)
Config:EnableMouse(true)
Config:Hide()
Config:SetMovable(true)
Config:RegisterForDrag("LeftButton")
Config:HookScript("OnDragStart", Config.StartMoving)
Config:HookScript("OnDragStop", Config.StopMovingOrSizing)
---------------------------------------------------------------
Scroll.StepSize = 100
Scroll:SetScrollChild(Category)
Scroll:SetWidth(1000)
Scroll:SetPoint("TOPLEFT", Config, 16, -34)
Scroll:SetPoint("BOTTOMRIGHT", Config, "TOPRIGHT", -16, -80)
---------------------------------------------------------------
Category.Buttons = {}
Category:SetHeight(46)
Category:SetPoint("CENTER", 0, 0)
---------------------------------------------------------------
Container:SetPoint("TOPLEFT", Config, "TOPLEFT", 8, -80)
Container:SetPoint("BOTTOMRIGHT", Config, "BOTTOMRIGHT", -8, 54)
---------------------------------------------------------------
Container.Frames = {}
---------------------------------------------------------------
function Scroll:SmoothScroll(elapsed)
	local current = self:GetHorizontalScroll()
	if abs(current - self.Target) < 2 then
		self:SetHorizontalScroll(self.Target)
		self:SetScript("OnUpdate", nil)
		return
	end
	local delta = current > self.Target and -1 or 1
	self:SetHorizontalScroll(current + (delta * abs(current - self.Target) / self.StepSize * 4 ) )
end

function Scroll:OnMouseWheel(delta)
	local maxScroll = self:GetHorizontalScrollRange()
	local current = self:GetHorizontalScroll()
	local new = current - delta * 100
	self:SetHorizontalScroll(new < 0 and 0 or new > maxScroll and maxScroll or new)
end

function Scroll:ScrollTo(id)
	local maxScroll = self:GetHorizontalScrollRange()
	local stepSize = maxScroll / #Category.Buttons
	local new = id <= 3 and 0 or id >= (#Category.Buttons - 2) and maxScroll or stepSize * (id - 1)
	self.StepSize = stepSize
	self.Target = new < 0 and 0 or new > maxScroll and maxScroll or new
	self:SetScript("OnUpdate", self.SmoothScroll)
end
---------------------------------------------------------------
Scroll:SetScript("OnMouseWheel", Scroll.OnMouseWheel)

local Cancel = db.Atlas.GetFutureButton("$parentCancel", Config)
function Cancel:OnClick()
	if not InCombatLockdown() then
		for i, frame in pairs(Container.Frames) do
			if frame.Cancel then
				frame:Cancel()
			end
		end
		Config:Hide()
	end
end

Cancel:SetPoint("BOTTOMRIGHT", -20, 20)
Cancel:SetText(TUTORIAL.CANCEL)
Cancel:SetScript("OnClick", Cancel.OnClick)
Cancel.Cover:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, 1, 1, 1, 0.5)
---------------------------------------------------------------
local Save = db.Atlas.GetFutureButton("$parentSave", Config)
function Save:OnClick()
	local reload
	if not InCombatLockdown() then
		for i, frame in pairs(Container.Frames) do
			if frame.Save then
				reload = frame:Save() or reload
			end
		end
		if reload then
			ReloadUI()
		else
			Config:Hide()
		end
	end
end

Save:SetPoint("RIGHT", Cancel, "LEFT", 0, 0)
Save:SetText(TUTORIAL.SAVE)
Save:SetScript("OnClick", Save.OnClick)
---------------------------------------------------------------
local Default = db.Atlas.GetFutureButton("$parentDefault", Config)
Default:SetPoint("BOTTOMLEFT", 20, 20)
Default:SetText(TUTORIAL.DEFAULT)
Default:SetScript("OnClick", Default.OnClick)
Default.Cover:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0.5, 1, 1, 1, 1)
---------------------------------------------------------------
Default.PopupFrame = CreateFrame("Frame", "$parentPopup", Default)
Default.PopupFrame.Apply = CreateFrame("Button", "$parentApply", Default.PopupFrame)
Default.PopupFrame.Cancel = CreateFrame("Button", "$parentCancel", Default.PopupFrame)
Default.PopupFrame.ResetAll = db.Atlas.GetFutureButton("$parentResetAll", Default.PopupFrame)
Default.PopupFrame.ResetThis = db.Atlas.GetFutureButton("$parentResetThis", Default.PopupFrame)
Default.PopupFrame.ResetAll:SetPoint("CENTER", 0, 23)
Default.PopupFrame.ResetThis:SetPoint("CENTER", 0, -23)
Default.PopupFrame.ResetAll:SetText(TUTORIAL.DEFAULTALL)
Default.PopupFrame.ResetThis:SetText(TUTORIAL.DEFAULTTHIS)
Default.PopupFrame.Apply:SetText(TUTORIAL.APPLY)
Default.PopupFrame.Cancel:SetText(TUTORIAL.CANCEL)
---------------------------------------------------------------

function Default:ResetAll()
	if not InCombatLockdown() then
		for i, frame in pairs(Container.Frames) do
			if frame.Default then
				frame:Default()
			end
		end
	end
end

function Default:ResetThis()
	if not InCombatLockdown() then
		if Container.Current and Container.Current.Default then
			Container.Current:Default()
			Container.Current:Show()
		end
	end
end

function Default:OnClick()
	Popup:SetPopup(TUTORIAL.DEFAULTHEADER, self.PopupFrame, self.PopupFrame.Apply, self.PopupFrame.Cancel, 220)
end

function Default.PopupFrame:OnHide()
	self.ResetThis.SelectedTexture:Hide()
	self.ResetAll.SelectedTexture:Hide()
	self.Apply:SetScript("OnClick", nil)
end

function Default.PopupFrame.ResetAll:OnClick()
	self.SelectedTexture:Show()
	Default.PopupFrame.ResetThis.SelectedTexture:Hide()
	Default.PopupFrame.Apply:SetScript("OnClick", Default.ResetAll)
end

function Default.PopupFrame.ResetThis:OnClick()
	self.SelectedTexture:Show()
	Default.PopupFrame.ResetAll.SelectedTexture:Hide()
	Default.PopupFrame.Apply:SetScript("OnClick", Default.ResetThis)
end

---------------------------------------------------------------
Default:SetScript("OnClick", Default.OnClick)
Default.PopupFrame:SetScript("OnHide", Default.PopupFrame.OnHide)
Default.PopupFrame.ResetAll:SetScript("OnClick", Default.PopupFrame.ResetAll.OnClick)
Default.PopupFrame.ResetThis:SetScript("OnClick", Default.PopupFrame.ResetThis.OnClick)

---------------------------------------------------------------
local Tooltip = CreateFrame("GameTooltip", "$parentTooltip", Config, "GameTooltipTemplate")
Config.Tooltip = Tooltip

function Tooltip:OnShow()
	-- set CC backdrop
	self:SetBackdrop(db.Atlas.Backdrops.FullSmall)
	self:SetBackdropColor(red, green, blue,  0.9)
	FadeIn(self, 0.2, 0, 1)
end

Tooltip:SetScript("OnShow", Tooltip.OnShow)
Tooltip:Show()
Tooltip:Hide()
---------------------------------------------------------------
Popup.Button1 = db.Atlas.GetFutureButton("$parentButton1", Popup, nil, nil, 180, 36)
Popup.Button2 = db.Atlas.GetFutureButton("$parentButton2", Popup, nil, nil, 180, 36)
---------------------------------------------------------------
Popup.Container = db.Atlas.GetGlassWindow("$parentContainer", Popup, nil, true)
Popup.Container.BG:SetAlpha(0.1)
Popup.Container.Close:Hide()
Popup.Container.Tint:Hide()
Popup.Container:SetPoint("TOPLEFT", Popup, "TOPLEFT", 8, -44)
Popup.Container:SetPoint("BOTTOMRIGHT", Popup, "BOTTOMRIGHT", -8, 44)
---------------------------------------------------------------
Popup.Header = Popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
Popup.Header:SetPoint("TOP", 0, -32)
---------------------------------------------------------------
Popup.Button1:SetPoint("BOTTOMLEFT", Popup, "BOTTOMLEFT", 20, 20)
Popup.Button2:SetPoint("BOTTOMRIGHT", Popup, "BOTTOMRIGHT", -20, 20)
---------------------------------------------------------------
function Popup:WrapClick(wrapper, button)
	if button then
		wrapper:Show()
		wrapper:SetText(button:GetText())
		wrapper:SetScript("OnClick", function()
			button:Click()
			if not button.dontHide then
				self:Hide()
			end
		end)
	else
		wrapper:SetText()
		wrapper:SetScript("OnClick", nil)
		wrapper:Hide()
	end
end

function Popup:SetPopup(header, frame, button1, button2, height)
	if self.frame then
		self.frame:Hide()
	end
	frame:Show()
	frame:SetParent(self)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 16, -16)
	frame:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", -16, 16)
	self.Header:SetText(header)
	self:WrapClick(self.Button1, button1)
	self:WrapClick(self.Button2, button2)
	self:Show()
	self:SetHeight(height or 500)
	self.frame = frame
	ConsolePort:SetCurrentNode(self.Close)
end

function Popup:SetSelection(value) self.selected = value end
function Popup:GetSelection() return self.selected end

function Popup:OnShow()
	Config.ignoreNode = true
	FadeOut(Config, 0.2, 1, 0.5)
end

function Popup:OnHide()
	Config.ignoreNode = nil
	FadeIn(Config, 0.2, Config:GetAlpha(), 1)
end
---------------------------------------------------------------
Popup:SetSize(400, 500)
Popup:SetPoint("CENTER", 0, 0)
Popup:EnableMouse(true)
Popup:HookScript("OnShow", Popup.OnShow)
Popup:SetScript("OnHide", Popup.OnHide)
Popup:SetFrameStrata("FULLSCREEN_DIALOG")
Popup:Hide()
---------------------------------------------------------------

function Container:HideAll()
	for i, frame in pairs(self.Frames) do
		Category.Buttons[i].hasPriority = nil
		Category.Buttons[i].SelectedTexture:Hide()
		frame:Hide()
	end
end

function Container:ShowFrame(id)
	self.Current = self.Frames[id]
	self:HideAll()
	self.Current:Show()
	Category.Buttons[id].hasPriority = true
	Category.Buttons[id].SelectedTexture:Show()
end

---------------------------------------------------------------
local function CategoryOnClick(self)
	Container:ShowFrame(self.id)
end

local function CategoryOnEnter(self)
	if ConsolePort:GetCurrentNode() == self then
		Scroll:ScrollTo(self.id)
	end
end

function Category:AddNew(header, bannerAtlas)
	local id = #self.Buttons+1
	local banner = db.Atlas.GetFutureButton("$parentHeader"..id, self, nil, bannerAtlas, nil, nil, true)
	banner.id = id
	banner:SetText(header)
	banner:SetScript("OnClick", CategoryOnClick)
	banner:SetScript("OnEnter", CategoryOnEnter)
	banner:SetPoint("LEFT", self.Buttons[id-1] or self, self.Buttons[id-1] and "RIGHT" or "LEFT", 0, 0)
	self.Buttons[id] = banner
	self:SetWidth(id*banner:GetWidth())
	self:ClearAllPoints()
	self:SetPoint("CENTER", 0, 0)
	return id
end

---------------------------------------------------------------

function Config:OpenCategory(index)
	if Container.Frames[index] then
		Scroll:ScrollTo(index)
		Container:ShowFrame(index)
		self:Show()
	end
end

---------------------------------------------------------------

function WindowMixin:AddPanel(name, header, bannerAtlas, mixin, configure)
	local frame = CreateFrame("FRAME", "$parent"..name, Container)
	frame:SetBackdrop(db.Atlas.Backdrops.Border)
	local id = Category:AddNew(header, bannerAtlas)
	Container.Frames[id] = frame

	Mixin(frame, mixin)

	frame:SetParent(self)
	frame:SetAllPoints(Container)
	frame:Hide()
	configure(ConsolePort, frame)
	db[name] = frame
end

function WindowMixin:OnHide()
	if not self.combatHide then
		self:UnregisterAllEvents()
	end
end

function WindowMixin:OnShow()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function WindowMixin:OnEvent(event)
	if event == "PLAYER_REGEN_DISABLED" then
		self.combatHide = true
		self:Hide()
	elseif event == "PLAYER_REGEN_ENABLED" then
		FadeIn(self, 0.5, 0, 1)
		self.combatHide = nil
		self:Show()
	end
end

Mixin(Config, WindowMixin)

---------------------------------------------------------------
-- Creates all config panels in panel table on load.
---------------------------------------------------------------
function ConsolePort:CreateConfigPanel()
	for i, panel in pairs(db.PANELS) do
		Config:AddPanel(unpack(panel))
	end
	db.PANELS = nil
	self.CreateConfigPanel = nil
	self:AddFrame(Config:GetName())
	self:AddFrame(Popup:GetName())
	Container:ShowFrame(2)
	tinsert(UISpecialFrames, Config:GetName())
	tinsert(UISpecialFrames, Popup:GetName())
end