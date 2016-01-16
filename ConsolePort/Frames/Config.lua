---------------------------------------------------------------
-- Config.lua: Base config frame
---------------------------------------------------------------
-- Provides a template function for convenient panel creation.

local _, db = ...
local TUTORIAL = db.TUTORIAL.CONFIG
local FadeOut = db.UIFrameFadeOut
local FadeIn = db.UIFrameFadeIn
---------------------------------------------------------------
local ConsolePort = ConsolePort
local Popup = db.Atlas.GetFutureWindow("ConsolePortPopup", nil, nil, true)
local Config = db.Atlas.GetFutureWindow("ConsolePortConfig")
local Category = CreateFrame("Frame", "$parentCategory", Config)
local Container = CreateFrame("Frame", "$parentContainer", Config)
---------------------------------------------------------------
db.ConfigWindow = Config
Config.Category = Category
Config.Container = Container
---------------------------------------------------------------
Config.Close:Hide()
Config:SetFrameStrata("DIALOG")
Config:SetSize(1000, 720)
Config:SetPoint("CENTER", 0, 0)
Config:EnableMouse(true)
Config:Hide()
Config:SetMovable(true)
Config:RegisterForDrag("LeftButton")
Config:HookScript("OnDragStart", Config.StartMoving)
Config:HookScript("OnDragStop", Config.StopMovingOrSizing)
---------------------------------------------------------------
Category.Buttons = {}
Category:SetHeight(46)
Category:SetPoint("TOP", Config, "TOP", 0, -28)
Container:SetPoint("TOPLEFT", Config, "TOPLEFT", 8, -80)
Container:SetPoint("BOTTOMRIGHT", Config, "BOTTOMRIGHT", -8, 54)
---------------------------------------------------------------
Container.Frames = {}
---------------------------------------------------------------
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

Cancel:SetPoint("BOTTOMRIGHT", -12, 12)
Cancel:SetText(TUTORIAL.CANCEL)
Cancel:SetScript("OnClick", Cancel.OnClick)
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
Default:SetPoint("BOTTOMLEFT", 12, 12)
Default:SetText(TUTORIAL.DEFAULT)
Default:SetScript("OnClick", Default.OnClick)
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
local red, green, blue = db.Atlas.GetCC()
Config.Tooltip = Tooltip

function Tooltip:OnShow()
	-- edge file fractioned pixel fix, pretty unncessary
	local width, height = self:GetSize()
	width, height = floor(width + 0.5) + 4, floor(height + 0.5) + 4
	local point, anchor, relativePoint, x, y = self:GetPoint()
	self:ClearAllPoints()
	self:SetPoint(point, anchor, relativePoint, floor(x + 0.5), floor(y + 0.5))
	self:SetSize(width - (width % 2), height - (height % 2))
	-- set CC backdrop
	self:SetBackdrop(db.Atlas.Backdrops.Full)
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
Popup.Container:SetBackdrop(db.Atlas.Backdrops.BorderInset)
Popup.Container:SetPoint("TOPLEFT", Popup, "TOPLEFT", 16, -52)
Popup.Container:SetPoint("BOTTOMRIGHT", Popup, "BOTTOMRIGHT", -16, 52)
---------------------------------------------------------------
Popup.Header = Popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
Popup.Header:SetPoint("TOP", 0, -32)
---------------------------------------------------------------
Popup.Button1:SetPoint("BOTTOMLEFT", Popup, "BOTTOMLEFT", 16, 16)
Popup.Button2:SetPoint("BOTTOMRIGHT", Popup, "BOTTOMRIGHT", -16, 16)
---------------------------------------------------------------
function Popup:WrapClick(wrapper, button)
	wrapper:SetScript("OnClick", function()
		button:Click()
		if not button.dontHide then
			self:Hide()
		end
	end)
end

function Popup:SetPopup(header, frame, button1, button2, height)
	if self.frame then
		self.frame:Hide()
	end
	frame:Show()
	frame:SetParent(self)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 8, -8)
	frame:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", -8, 8)
	self.Header:SetText(header)
	self:WrapClick(self.Button1, button1)
	self:WrapClick(self.Button2, button2)
	self.Button1:SetText(button1:GetText())
	self.Button2:SetText(button2:GetText())
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
Popup:SetScript("OnShow", Popup.OnShow)
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

function Category:AddNew(header, bannerAtlas)
	local id = #self.Buttons+1
	local banner = db.Atlas.GetFutureButton("$parentHeader"..id, self, nil, bannerAtlas, nil, nil, true)
	banner.id = id
	banner:SetText(header)
	banner:SetScript("OnClick", function(self) Container:ShowFrame(self.id) end)
	banner:SetPoint("LEFT", self.Buttons[id-1] or self, self.Buttons[id-1] and "RIGHT" or "LEFT", 0, 0)
	self.Buttons[id] = banner
	self:SetWidth(id*banner:GetWidth())
	return id
end

---------------------------------------------------------------

function Config:OpenCategory(index)
	if Container.Frames[index] then
		Container:ShowFrame(index)
		self:Show()
	end
end

---------------------------------------------------------------

function Config:AddPanel(name, header, bannerAtlas, save, cancel, default, configure)
	local frame = CreateFrame("FRAME", "$parent"..name, Container)
	frame:SetBackdrop(db.Atlas.Backdrops.Border)
	local id = Category:AddNew(header, bannerAtlas)
	Container.Frames[id] = frame
	frame.Default = default
	frame.Cancel = cancel
	frame.Save = save
	frame:SetParent(self)
	frame:SetAllPoints(Container)
	frame:Hide()
	configure(ConsolePort, frame)
	db[name] = frame
end

---------------------------------------------------------------
-- Config: Creates all config panels in panel table on load.
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