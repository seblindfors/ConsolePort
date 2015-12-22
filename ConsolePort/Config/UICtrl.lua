---------------------------------------------------------------
-- UICtrl.lua: Advanced interface settings
---------------------------------------------------------------
-- Provides detailed management of the frame stack used by the
-- UI cursor. User has full control over which frames to bind
-- and may add custom frames from other addons.

local addOn, db = ...
local FadeIn = db.UIFrameFadeIn
local FadeOut = db.UIFrameFadeOut
local TUTORIAL = db.TUTORIAL.UICTRL
local DefaultBackdrop = StaticPopup1:GetBackdrop()
local Popup

local function ShowPopup(...)
	Popup = StaticPopup_Show(...)
	Popup:EnableKeyboard(false)
	Popup:SetBackdrop(db.Atlas.Backdrops.Full)
	return Popup
end

local function ClearPopup()
	if Popup then
		Popup:SetBackdrop(DefaultBackdrop)
		Popup = nil
	end
end

local function GetOuterParent(node)
	if node then
		if node:GetParent() == UIParent then
			return node
		else
			return GetOuterParent(node:GetParent())
		end
	end
end
---------------------------------------------------------------
-- UICtrl: UICtrl addons/frames scripts
---------------------------------------------------------------
local function NewAddonOnClick(self)
	local self = self:GetParent()
	local dialog = ShowPopup("CONSOLEPORT_ADDADDON")
	if dialog then
		dialog.data = self.AddonList
	end
end

local function NewFrameOnClick(self)
	local self = self:GetParent()
	if self.CurrentAddon then
		local dialog = ShowPopup("CONSOLEPORT_ADDFRAME", self.CurrentAddon:GetText())
		if dialog then
			dialog.data = self.CurrentAddon
		end
	end
end

local function AddAddonOnClick(self)
	db.UIStack[self:GetParent():GetText()] = {}
end

local function RemoveAddonOnClick(self)
	local self = self:GetParent()
	local addonList = self.parent.AddonList
	local addon = self:GetText()
	local dialog = ShowPopup("CONSOLEPORT_REMOVEADDON", addon)
	if dialog then
		dialog.data = addonList
		dialog.data2 = addon
	end
end

local function RemoveFrameOnClick(self)
	local self = self:GetParent()
	local frame = self:GetText()
	local owner = self.owner
	local addon = owner:GetText()
	local dialog = ShowPopup("CONSOLEPORT_REMOVEFRAME", frame, addon)
	if dialog then
		dialog.data = self
		dialog.data2 = owner
	end
end

---------------------------------------------------------------
-- UICtrl: UICtrl addons and frames
---------------------------------------------------------------
local function CreateUICtrlConfigButton(parent, num, clickScript)
	local button = CreateFrame("Button", "$parentButton"..num, parent, "OptionsListButtonTemplate")
	button:SetHeight(24)
	button:SetScript("OnClick", clickScript)
	button.text:ClearAllPoints()
	button.text:SetPoint("LEFT", 24, 0)
	button.Alter = CreateFrame("Button", "$parentAlter", button)
	button.Alter:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	button.Alter:SetSize(14, 14)
	button.Alter:SetPoint("RIGHT", button, "RIGHT", -8, 0)
	button.Alter:SetAlpha(0.5)
	button.Loaded = button:CreateTexture()
	button.Loaded:SetSize(16, 16)
	button.Loaded:SetPoint("LEFT", 0, 0)
	button.Loaded:SetAlpha(0.5)
	tinsert(parent.Buttons, button)
	if num == 1 then
		button:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, 0)
		button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, 0)
	else
		button:SetPoint("TOPLEFT", parent.Buttons[num-1], "BOTTOMLEFT")
		button:SetPoint("TOPRIGHT", parent.Buttons[num-1], "BOTTOMRIGHT")
	end
	return button
end

local function RefreshFrameStatus(self)
	if self:IsVisible() then
		for i, button in pairs(self.Buttons) do
			if button:IsVisible() then
				if _G[button:GetText()] then
					button.Loaded:SetTexture("Interface\\FriendsFrame\\StatusIcon-Online")
				else
					button.Loaded:SetTexture("Interface\\FriendsFrame\\StatusIcon-Offline")
				end
			end
		end
	end
end

local function RefreshFrameList(self)
	local addonButtons = self.parent.AddonList.Buttons
	local frameButtons = self.parent.FrameList.Buttons
	local frameList = self.parent.FrameList

	self.parent.NewFrame:Show()
	self.parent.NewMouseover:Show()
	self.parent.FrameScroll:Show()
	self.parent.FrameWrap:Show()
	self.parent.FrameListText:Show()
	self.parent.TutorialFrame:Hide()

	self.parent.CurrentAddon = self
	self.parent.NewMouseover.Addon = self:GetText()

	self.parent.FrameListText:SetText(format(TUTORIAL.FRAMELISTFORMAT, self:GetText()))
	self.parent.NewFrame:SetText(format(TUTORIAL.NEWFRAME, self:GetText()))

	for i, button in pairs(addonButtons) do
		button:UnlockHighlight()
	end
	self:LockHighlight()

	for i, button in pairs(frameButtons) do
		button:Hide()
	end

	local frames = self.list
	local num = 0
	for i, frame in pairs(frames) do
		num = num + 1
		local button
		if not frameButtons[num] then
			button = CreateUICtrlConfigButton(frameList, num)
			button.Alter:SetScript("OnClick", RemoveFrameOnClick)
		else
			button = frameButtons[num]
		end
		button:Show()
		button:SetText(frame)
		button.list = frames
		button.owner = self
	end

	RefreshFrameStatus(frameList)
	frameList:SetHeight(num*24)
end

local function RefreshAddonList(self)
	local UIFrames, list = db.UIStack, {}
	for i, button in pairs(self.Buttons) do
		button:Hide()
	end

	for addon, frames in db.pairsByKeys(UIFrames) do
		list[addon] = frames
	end

	for i=1, GetNumAddOns() do
		local name = GetAddOnInfo(i)
		if not list[name] then
			list[name] = {}
		end
	end

	local num = 0

	for addon, frames in db.pairsByKeys(list) do
		num = num + 1
		local button
		if not self.Buttons[num] then
			button = CreateUICtrlConfigButton(self, num)
			button.parent = self.parent
		else
			button = self.Buttons[num]
		end
		if IsAddOnLoaded(addon) then
			button.Loaded:SetTexture("Interface\\FriendsFrame\\StatusIcon-Online")
		else
			button.Loaded:SetTexture("Interface\\FriendsFrame\\StatusIcon-Offline")
		end
		if UIFrames[addon] then
			button:SetScript("OnClick", RefreshFrameList)
			button.Alter:SetScript("OnClick", RemoveAddonOnClick)
			button.Alter:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		else
			button:SetScript("OnClick", function() RefreshAddonList(self) end)
			button.Alter:SetScript("OnClick", AddAddonOnClick)
			button.Alter:HookScript("OnClick", function() RefreshAddonList(self) end)
			button.Alter:SetNormalTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
		end
		button:Show()
		button:SetText(addon)
		button.list = frames
	end

	self.parent.NewFrame:Hide()
	self.parent.NewMouseover:Hide()
	self.parent.FrameScroll:Hide()
	self.parent.FrameWrap:Hide()
	self.parent.FrameListText:Hide()
	self.parent.TutorialFrame:Show()

	self:SetHeight(num*24)
	self:RegisterEvent("ADDON_LOADED")
end

---------------------------------------------------------------
-- UICtrl: UICtrl popup functions
---------------------------------------------------------------
local function AddFramePopupAccept(self, addonButton)
	local list = db.UIStack
	local addon = list[addonButton:GetText()]
	if addon then
		local exists
		local name = self.editBox:GetText():trim()
		for i, frame in pairs(addon) do
			if frame == name then
				exists = true
				break
			end
		end
		if not exists then
			tinsert(addon, name)
		end
	end
	RefreshFrameList(addonButton)
	ConsolePort:CheckLoadedAddons()
end

local function RemoveAddonPopupAccept(self, addonList, addon)
	local list = db.UIStack
	list[addon] = nil
	RefreshAddonList(addonList)
	ConsolePort:CheckLoadedAddons()
end

local function RemoveFramePopupAccept(self, frame, addon)
	local list = db.UIStack[addon:GetText()]
	local name = frame:GetText()
	for i, frame in pairs(list) do
		if frame == name then
			list[i] = nil
			break
		end
	end
	RefreshFrameList(addon)
	ConsolePort:CheckLoadedAddons()
end

---------------------------------------------------------------
-- UICtrl: Mouseover frame catcher
---------------------------------------------------------------
local function NewMouseoverOnClick(self)
	if self.MouseOver then
		local list = db.UIStack[self.Addon]
		local exists
		for i, frame in pairs(list) do
			if frame == self.MouseOver then
				exists = true
				break
			end
		end
		if not exists then
			tinsert(list, self.MouseOver)
		end
		RefreshFrameList(self:GetParent().CurrentAddon)
		ConsolePort:CheckLoadedAddons()
	end
end

local timer, mouseFocus, outerParent = 0
local function NewMouseoverUpdate(self, elapsed)
	timer = timer + elapsed
	if timer > 0.1 then
		mouseFocus = GetMouseFocus()
		outerParent = mouseFocus ~= WorldFrame and GetOuterParent(mouseFocus)
		if outerParent and outerParent ~= ConsolePortConfig and outerParent:IsMouseEnabled() and outerParent:GetName() then
			self.MouseOver = outerParent:GetName()
			self:SetText(format(TUTORIAL.MOUSEOVERVALID, self.MouseOver, self.Addon))
		else
			self.MouseOver = nil
			self:SetText(TUTORIAL.MOUSEOVERINVALID)
		end
		timer = 0
	end
end

---------------------------------------------------------------
-- UICtrl: Default function
---------------------------------------------------------------
local function LoadDefaultUICtrl(self)
	db.UIStack = ConsolePort:GetDefaultUIFrames()
	ConsolePortUIFrames = db.UIStack
	RefreshAddonList(self.AddonList)
end

tinsert(db.PANELS, {"UICtrl", TUTORIAL.HEADER, false, false, false, LoadDefaultUICtrl, function(self, UICtrl)
	UICtrl.AddonList = CreateFrame("Frame", "$parentAddonList", UICtrl)
	UICtrl.AddonList:SetSize(260, 1000)
	UICtrl.AddonList.parent = UICtrl
	UICtrl.AddonList.Buttons = {}
	UICtrl.AddonList:SetScript("OnShow", RefreshAddonList)
	UICtrl.AddonList:SetScript("OnEvent", RefreshAddonList)
	UICtrl.AddonList:SetScript("OnHide", UICtrl.AddonList.UnregisterAllEvents)

	UICtrl.TutorialFrame = db.Atlas.GetGlassWindow("$parentTutorialFrame", UICtrl, nil, true)
	UICtrl.TutorialFrame:SetBackdrop(db.Atlas.Backdrops.Border)
	UICtrl.TutorialFrame:SetSize(500, 300)
	UICtrl.TutorialFrame:SetPoint("CENTER", 150, 0)
	UICtrl.TutorialFrame.Close:Hide()
	UICtrl.TutorialFrame.BG:SetAlpha(0.1)
	UICtrl.TutorialFrame:SetScript("OnShow", function(self)
		FadeIn(self, 0.5, 0, 1)
	end)

	UICtrl.TutorialFrame.Text = UICtrl.TutorialFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	UICtrl.TutorialFrame.Text:SetPoint("BOTTOM", UICtrl.TutorialFrame, 0, 56)
	UICtrl.TutorialFrame.Text:SetText(TUTORIAL.TUTORIALFRAME)

	UICtrl.TutorialFrame.Background = UICtrl.TutorialFrame:CreateTexture("$parentBackground" ,"ARTWORK")
	UICtrl.TutorialFrame.Background:SetPoint("CENTER", 0, 0)
	UICtrl.TutorialFrame.Background:SetTexture("Interface\\TUTORIALFRAME\\UI-TutorialFrame-Spellbook")
	UICtrl.TutorialFrame.Background:SetSize(256, 256)

	UICtrl.AddonScroll = CreateFrame("ScrollFrame", "$parentAddonScrollFrame", UICtrl, "UIPanelScrollFrameTemplate")
	UICtrl.AddonScroll:SetPoint("TOPLEFT", UICtrl, "TOPLEFT", 16, -40)
	UICtrl.AddonScroll:SetPoint("BOTTOMLEFT", UICtrl, "BOTTOMLEFT", 16, 16)
	UICtrl.AddonScroll:SetWidth(260)
	UICtrl.AddonScroll:SetScrollChild(UICtrl.AddonList)

	UICtrl.AddonScroll.ScrollBar.scrollStep = 64
	UICtrl.AddonScroll.ScrollBar:ClearAllPoints()
	UICtrl.AddonScroll.ScrollBar:SetPoint("TOPLEFT", UICtrl.AddonScroll, "TOPRIGHT", 0, 0)
	UICtrl.AddonScroll.ScrollBar:SetPoint("BOTTOMLEFT", UICtrl.AddonScroll, "BOTTOMRIGHT", 0, 0)
	UICtrl.AddonScroll.ScrollBar.Thumb = UICtrl.AddonScroll.ScrollBar:GetThumbTexture()
	UICtrl.AddonScroll.ScrollBar.Thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	UICtrl.AddonScroll.ScrollBar.Thumb:SetTexCoord(0, 1, 0, 1)
	UICtrl.AddonScroll.ScrollBar.Thumb:SetSize(18, 34)
	UICtrl.AddonScroll.ScrollBar.ScrollUpButton:SetAlpha(0)
	UICtrl.AddonScroll.ScrollBar.ScrollDownButton:SetAlpha(0)

	UICtrl.AddonWrap = CreateFrame("Frame", "$parentAddonWrap", UICtrl)
	UICtrl.AddonWrap:SetBackdrop(db.Atlas.Backdrops.Border)
	UICtrl.AddonWrap:SetPoint("TOPLEFT", UICtrl, "TOPLEFT", 8, -32)
	UICtrl.AddonWrap:SetPoint("BOTTOMLEFT", UICtrl, "BOTTOMLEFT", 8, 8)
	UICtrl.AddonWrap:SetWidth(300)

	UICtrl.AddonListText = UICtrl:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.AddonListText:SetPoint("BOTTOMLEFT", UICtrl.AddonWrap, "TOPLEFT", 8, 0)
	UICtrl.AddonListText:SetText(TUTORIAL.ADDONLISTHEADER)

	UICtrl.FrameList = CreateFrame("Frame", "$parentFrameList", UICtrl)
	UICtrl.FrameList:RegisterEvent("ADDON_LOADED")
	UICtrl.FrameList:SetScript("OnEvent", RefreshFrameStatus)
	UICtrl.FrameList:SetSize(260, 1000)
	UICtrl.FrameList.parent = UICtrl
	UICtrl.FrameList.Buttons = {}

	UICtrl.FrameScroll = CreateFrame("ScrollFrame", "$parentFrameScrollFrame", UICtrl, "UIPanelScrollFrameTemplate")
	UICtrl.FrameScroll:SetPoint("TOPLEFT", UICtrl.AddonScroll, "TOPRIGHT", 40, 0)
	UICtrl.FrameScroll:SetPoint("BOTTOMLEFT", UICtrl.AddonScroll, "BOTTOMRIGHT", 40, 0)
	UICtrl.FrameScroll:SetScrollChild(UICtrl.FrameList)
	UICtrl.FrameScroll:SetWidth(260)

	UICtrl.FrameScroll.ScrollBar.scrollStep = 64
	UICtrl.FrameScroll.ScrollBar:ClearAllPoints()
	UICtrl.FrameScroll.ScrollBar:SetPoint("TOPLEFT", UICtrl.FrameScroll, "TOPRIGHT", 0, 0)
	UICtrl.FrameScroll.ScrollBar:SetPoint("BOTTOMLEFT", UICtrl.FrameScroll, "BOTTOMRIGHT", 0, 0)
	UICtrl.FrameScroll.ScrollBar.Thumb = UICtrl.FrameScroll.ScrollBar:GetThumbTexture()
	UICtrl.FrameScroll.ScrollBar.Thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	UICtrl.FrameScroll.ScrollBar.Thumb:SetTexCoord(0, 1, 0, 1)
	UICtrl.FrameScroll.ScrollBar.Thumb:SetSize(18, 34)
	UICtrl.FrameScroll.ScrollBar.ScrollUpButton:SetAlpha(0)
	UICtrl.FrameScroll.ScrollBar.ScrollDownButton:SetAlpha(0)

	UICtrl.FrameWrap = CreateFrame("Frame", "$parentFrameWrap", UICtrl)
	UICtrl.FrameWrap:SetBackdrop(db.Atlas.Backdrops.Border)
	UICtrl.FrameWrap:SetPoint("TOPLEFT", UICtrl.AddonWrap, "TOPRIGHT", 0, 0)
	UICtrl.FrameWrap:SetPoint("BOTTOMLEFT", UICtrl.AddonWrap, "BOTTOMRIGHT", 0, 0)
	UICtrl.FrameWrap:SetWidth(300)

	UICtrl.FrameListText = UICtrl:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.FrameListText:SetPoint("BOTTOMLEFT", UICtrl.FrameScroll, "TOPLEFT", 0, 8)
	UICtrl.FrameListText:SetText(TUTORIAL.FRAMELISTHEADER)

	UICtrl.NewFrame = db.Atlas.GetFutureButton("$parentNewFrameButton", UICtrl, nil, nil, 358, 50)
	UICtrl.NewFrame:SetPoint("RIGHT", UICtrl, "RIGHT", -16, 33)
	UICtrl.NewFrame:SetText(TUTORIAL.NEWFRAME)
	UICtrl.NewFrame:SetScript("OnClick", NewFrameOnClick)
	UICtrl.NewFrame:Hide()

	UICtrl.NewMouseover = db.Atlas.GetFutureButton("$parentNewFrameButton", UICtrl, nil, nil, 358, 50)
	UICtrl.NewMouseover:SetPoint("TOP", UICtrl.NewFrame, "BOTTOM", 0, -16)
	UICtrl.NewMouseover:SetText(TUTORIAL.MOUSEOVERINVALID)
	UICtrl.NewMouseover:SetScript("OnUpdate", NewMouseoverUpdate)
	UICtrl.NewMouseover:SetScript("OnClick", NewMouseoverOnClick)
	UICtrl.NewMouseover.Timer = 0
	UICtrl.NewMouseover:Hide()

	StaticPopupDialogs["CONSOLEPORT_ADDFRAME"] = {
		text = TUTORIAL.ADDFRAME,
		button1 = TUTORIAL.ADD,
		button2 = TUTORIAL.CANCEL,
		showAlert = true,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = AddFramePopupAccept,
		OnCancel = ClearPopup,
	}

	StaticPopupDialogs["CONSOLEPORT_REMOVEFRAME"] = {
		text = TUTORIAL.REMOVEFRAME,
		button1 = TUTORIAL.REMOVE,
		button2 = TUTORIAL.CANCEL,
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = RemoveFramePopupAccept,
		OnCancel = ClearPopup,
	}

	StaticPopupDialogs["CONSOLEPORT_REMOVEADDON"] = {
		text = TUTORIAL.REMOVEADDON,
		button1 = TUTORIAL.REMOVE,
		button2 = TUTORIAL.CANCEL,
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept =  RemoveAddonPopupAccept,
		OnCancel = ClearPopup,
	}
end})