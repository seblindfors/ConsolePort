---------------------------------------------------------------
-- Config.lua: Base config frame
---------------------------------------------------------------
-- Provides a template function for convenient panel creation.

local _, db = ...
local TUTORIAL = db.TUTORIAL.CONFIG
local Mixin, FadeIn, FadeOut = db.table.mixin, db.GetFaders()
local red, green, blue = db.Atlas.GetCC()
---------------------------------------------------------------
local ConsolePort, WindowMixin = ConsolePort, {}
local Popup = db.Atlas.CreateFrame("ConsolePortPopup")
local Config = db.Atlas.CreateFrame("ConsolePortOldConfig")
local Scroll = CreateFrame("ScrollFrame", "$parentBannerScroll", Config)
local Category = CreateFrame("Frame", "$parentCategories", Scroll)
local Container = CreateFrame("Frame", "$parentContainer", Config)
---------------------------------------------------------------
ConsolePort.configFrame = Config
Config.Category = Category
Config.Container = Container
---------------------------------------------------------------
Config.Obstructor = CreateFrame("Frame", nil, Config)
Config.Obstructor:SetAllPoints()
Config.Obstructor:EnableMouse(true)
Config.Obstructor:SetFrameLevel(100)
---------------------------------------------------------------
Config.Close:Hide()
Config:SetFrameStrata("HIGH")
Config:SetSize(1000, 768)
Config:SetPoint("CENTER", 0, 0)
Config:EnableMouse(true)
Config:EnableKeyboard(true)
Config:SetPropagateKeyboardInput(true)
Config:Hide()
Config:SetMovable(true)
Config:RegisterForDrag("LeftButton")
Config:HookScript("OnDragStart", Config.StartMoving)
Config:HookScript("OnDragStop", Config.StopMovingOrSizing)
---------------------------------------------------------------
Config.Model = CreateFrame('PlayerModel', '$parentSmoke', Config)
Config.Model:SetPoint('TOPLEFT', 16, -16)
Config.Model:SetPoint('BOTTOMRIGHT', -16, 16)
Config.Model:SetAlpha(0.15)
Config.Model:SetDisplayInfo(43022)
Config.Model:SetCamDistanceScale(8)
Config.Model:SetLight(true, false, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
---------------------------------------------------------------
Category.NextIcon = Category:CreateTexture(nil, "ARTWORK")
Category.NextIcon:SetSize(24, 24)
Category.NextIcon:SetPoint("LEFT", Category, "RIGHT", 0, 0)
Category.PrevIcon = Category:CreateTexture(nil, "ARTWORK")
Category.PrevIcon:SetSize(24, 24)
Category.PrevIcon:SetPoint("RIGHT", Category, "LEFT", 0, 0)
---------------------------------------------------------------
Scroll.StepSize = 100
Scroll:SetScrollChild(Category)
Scroll:SetWidth(1000)
Scroll:SetPoint("TOPLEFT", Config, 16, -16)
Scroll:SetPoint("BOTTOMRIGHT", Config, "TOPRIGHT", -16, -68)
---------------------------------------------------------------
Category.Buttons = {}
Category:SetHeight(32)
Category:SetPoint("CENTER", 0, 0)
---------------------------------------------------------------
Container:SetPoint("TOPLEFT", Config, "TOPLEFT", 8, -48)
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
		for _, frame in ipairs(Container.Frames) do
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
	local data, reload
	if not InCombatLockdown() then
		for _, frame in ipairs(Container.Frames) do
			if frame.Save and not frame.onLoad then
				local needReload, exportID, exportData = frame:Save()
				reload = needReload or reload
				if exportID and exportData then
					if not data then
						data = {}
					end
					data[exportID] = exportData
				end
			end
		end
		Config:Export(data, db('explicitProfile'))
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
Save.Icon = Save:CreateTexture(nil, "OVERLAY")
Save.Icon:SetPoint("LEFT", 10, 0)
Save.Icon:SetSize(24, 24)
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
		for _, frame in ipairs(Container.Frames) do
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
	self:SetBackdrop(db.Atlas.Backdrops.TooltipBorder)
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

function Popup:SetPopup(header, frame, button1, button2, height, width)
	if self.frame and self.frame:GetParent() == self then
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
	self:SetWidth(width or 400)
	self:SetHeight(height or 500)
	self.frame = frame
	ConsolePort:SetCurrentNode(self.Close)
end

function Popup:SetSelection(value) self.selected = value end
function Popup:GetSelection() return self.selected end

function Popup:OnShow()
	Config.Obstructor:Show()
	Config.ignoreNode = true
	FadeOut(Config, 0.2, 1, 0.5)
end

function Popup:OnHide()
	Config.Obstructor:Hide()
	Config.ignoreNode = nil
	FadeIn(Config, 0.2, Config:GetAlpha(), 1)
end

function Popup:OnEvent()
	self:Hide()
end
---------------------------------------------------------------
Popup:SetSize(400, 500)
Popup:SetPoint("CENTER", 0, 0)
Popup:EnableMouse(true)
Popup:HookScript("OnShow", Popup.OnShow)
Popup:SetScript("OnHide", Popup.OnHide)
Popup:SetScript("OnEvent", Popup.OnEvent)
Popup:SetFrameStrata("DIALOG")
Popup:RegisterEvent("PLAYER_REGEN_DISABLED")
Popup:Hide()
Popup:SetMovable(true)
Popup:SetClampedToScreen(true)
Popup:RegisterForDrag("LeftButton")
Popup:HookScript("OnDragStart", Popup.StartMoving)
Popup:HookScript("OnDragStop", Popup.StopMovingOrSizing)
---------------------------------------------------------------

function Container:HideAll()
	for i, frame in pairs(self.Frames) do
		Category.Buttons[i].hasPriority = nil
		Category.Buttons[i].SelectedTexture:Hide()
		frame:Hide()
	end
end

function Container:GetFrameByName(id)
	for index, frame in pairs(self.Frames) do
		if frame.IDtag == id then
			return frame, index
		end
	end
end

function Container:GetFrameByID(id)
	local frame = self.Frames[id]
	if frame then
		return frame, id
	else 
		return self:GetFrameByName(id)
	end
end

function Container:ShowFrame(id)
	local frame, index = self:GetFrameByID(id)
	self.Current = frame
	self:HideAll()
	self.Current:Show()
	self.id = index
	Category.Buttons[self.id].hasPriority = true
	Category.Buttons[self.id].SelectedTexture:Show()
	Default:SetShown(not self.Current.noDefault)
	return self.Current, self.id
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
	local banner = db.Atlas.GetFutureButton("$parentHeader"..id, self, nil, bannerAtlas, 110, 30, true)
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
function Config:GetCategoryID()
	return Container.id
end

function Config:GetCategory()
	return Container.Frames[Container.id]
end

function Config:OpenCategory(id)
	local frame, index = Container:ShowFrame(id)
	if frame then
		Scroll:ScrollTo(index)
		if not InCombatLockdown() then
			self:Show()
			return frame
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self.combatHide = true
			print(db.TUTORIAL.SLASH.CONFIG_COMBAT)
		end
	end
end

---------------------------------------------------------------

function WindowMixin:AddPanel(info)
	local 	name, header, bannerAtlas, mixin, onCreate, onLoad = 
			info.name, info.header, info.bannerAtlas,
			info.mixin, info.onCreate, info.onLoad
	local frame = CreateFrame("Frame", "$parent"..name, Container)
	frame:SetBackdrop(db.Atlas.Backdrops.Border)
	local id = Category:AddNew(header, bannerAtlas)
	Container.Frames[id] = frame

	Mixin(frame, mixin)

	frame.IDtag = name
	frame.noDefault = info.noDefault
	frame:SetID(id)
	frame:SetParent(self)
	frame:SetAllPoints(Container)
	frame:Hide()
	if onCreate then
		onCreate(frame, ConsolePort)
	end
	if onLoad then
		frame:SetScript("OnShow", function(self)
			self:onLoad(ConsolePort)
			self.onLoad = nil
			self:Hide()
			self:SetScript("OnShow", self.OnShow)
			self:Show()
		end)
		frame.onLoad = onLoad
	end
	db[name] = frame
	return frame
end

function WindowMixin:OnHide()
	if not self.combatHide then
		self:UnregisterAllEvents()
	end
	ClearOverrideBindings(self)
end

local shortCuts = {
	CP_R_LEFT = true,
	CP_R_RIGHT = true,
	CP_R_UP = true,
	CP_R_DOWN = true,
}

local function SetSaveShortCut(self)
	if not InCombatLockdown() then
		for key, value in pairs(shortCuts) do
			shortCuts[key] = true
		end
		for _, key in pairs(db.Mouse.Cursor) do
			shortCuts[key] = false
		end
		local freeKey
		for key, value in pairs(shortCuts) do
			if value then
				freeKey = key
				break
			end
		end
		local key = freeKey and GetBindingKey(freeKey)
		if key then
			Save.Icon:SetTexture(db.ICONS[freeKey])
			SetOverrideBindingClick(self, true, key, Save:GetName())
		else
			Save.Icon:SetTexture()
		end
	else
		Save.Icon:SetTexture()
	end
end

function WindowMixin:ToggleShortcuts(enable)
	local alpha = Save.Icon:GetAlpha()
	if enable then
		FadeIn(Save.Icon, 0.2, alpha, 1)
		FadeIn(self.Category.NextIcon, 0.2, alpha, 1)
		FadeIn(self.Category.PrevIcon, 0.2, alpha, 1)
	else
		FadeOut(Save.Icon, 0.2, alpha, 0)
		FadeOut(self.Category.NextIcon, 0.2, alpha, 0)
		FadeOut(self.Category.PrevIcon, 0.2, alpha, 0)
	end
end

function WindowMixin:OnShow()
	if not InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")

		self:SetPropagateKeyboardInput(true)
		self.Category.NextIcon:SetTexture(db.ICONS.CP_T2)
		self.Category.PrevIcon:SetTexture(db.ICONS.CP_T1)

		SetSaveShortCut(self)
	else
		self:Hide()
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self.combatHide = true
		print(db.TUTORIAL.SLASH.CONFIG_COMBAT)
	end
end

function WindowMixin:OnEvent(event)
	if event == "PLAYER_REGEN_DISABLED" then
		self.combatHide = true
		self:Hide()
		ClearOverrideBindings(self)
	elseif event == "PLAYER_REGEN_ENABLED" then
		FadeIn(self, 0.5, 0, 1)
		self.combatHide = nil
		self:Show()
		SetSaveShortCut(self)
	end
end

function WindowMixin:OnKeyUp(key) 
	self:SetPropagateKeyboardInput(true)
end

function WindowMixin:OnKeyDown(key)
	local t1 = GetBindingKey("CP_T1")
	local t2 = GetBindingKey("CP_T2")
	if key == t1 or key == t2 then
		self:SetPropagateKeyboardInput(false)
		local containerID, numCategories = self.Container.id, #self.Category.Buttons
		if containerID then
			if key == t1 and containerID - 1 > 0 then
				self:OpenCategory(containerID - 1)
				ConsolePort:SetCurrentNode(Category.Buttons[containerID - 1])
			elseif key == t2 and containerID + 1 <= numCategories then
				self:OpenCategory(containerID + 1)
				ConsolePort:SetCurrentNode(Category.Buttons[containerID + 1])
			end
		end
	end
end

function WindowMixin:Export(characterExportData, exportAs)
	if characterExportData then
		local _, classToken = UnitClass('player')
		local specID, specName = CPAPI:GetCharacterMetadata()
		local sharedData = ConsolePortCharacterSettings or {}
		ConsolePortCharacterSettings = sharedData

		local uid = (exportAs ~= nil and exportAs ~= '' and exportAs) or
					('%s (%s) %s'):format(GetUnitName('player'), specName, GetRealmName())

		if not sharedData[uid] then
			sharedData[uid] = {}
		end

		local characterProfile = sharedData[uid]
		local isIdentical = db.table.compare

		-- sanity check for identical data sets, so db isn't incremented needlessly
		for dataID, data in pairs(characterExportData) do
			local allowExport = true
			for exportID, exportData in pairs(sharedData) do
				if isIdentical(data, exportData[dataID]) then
					allowExport = false
				end
			end
			-- add unique data, scrub existing data
			characterProfile[dataID] = allowExport and data or nil
		end

		local exportType 	= db('type')
		local exportClass 	= classToken
		local exportSpec 	= specID

		-- remove metadata to check for empty export table.
		characterProfile.Type 	= nil
		characterProfile.Class 	= nil
		characterProfile.Spec 	= nil

		if next(characterProfile) then
			-- add/reinsert metadata
			characterProfile.Type  = exportType
			characterProfile.Class = exportClass
			characterProfile.Spec  = exportSpec
		else
			sharedData[uid] = nil
		end
	end
end

Mixin(Config, WindowMixin)

---------------------------------------------------------------
-- Creates all config panels in panel table on load.
---------------------------------------------------------------
function ConsolePort:CreateConfigPanel()
	for _, panel in ipairs(db.PANELS) do
		Config:AddPanel(panel)
	end
	db.PANELS = nil
	self.CreateConfigPanel = nil
	self:AddFrame(Config:GetName())
	self:AddFrame(Popup:GetName())
	Container:ShowFrame("Binds")
	tinsert(UISpecialFrames, Config:GetName())
	tinsert(UISpecialFrames, Popup:GetName())
end