---------------------------------------------------------------
-- UICtrl.lua: Advanced interface settings
---------------------------------------------------------------
-- Provides detailed management of the frame stack used by the
-- UI cursor. User has full control over which frames to bind
-- and may add custom frames from other addons.

local addOn, db = ...
local FadeIn, FadeOut = db.GetFaders()
local spairs = db.table.spairs
local TUTORIAL, ICONS = db.TUTORIAL.UICTRL, db.ICONS
local WindowMixin = {}

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
	local dialog = ConsolePort:ShowPopup("CONSOLEPORT_ADDADDON")
	if dialog then
		dialog.data = self.AddonList
	end
end

local function NewFrameOnClick(self)
	local self = self:GetParent()
	if self.CurrentAddon then
		local dialog = ConsolePort:ShowPopup("CONSOLEPORT_ADDFRAME", self.CurrentAddon:GetText())
		if dialog then
			dialog:EnableKeyboard(true)
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
	local dialog = ConsolePort:ShowPopup("CONSOLEPORT_REMOVEADDON", addon)
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
	local dialog = ConsolePort:ShowPopup("CONSOLEPORT_REMOVEFRAME", frame, addon)
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
	self.parent.FrameListText:Show()
	self.parent.HideFrameList:Show()
	
	self.parent.HotKeyModule:Hide()
	self.parent.MultiChoiceModule:Hide()

	self.parent.TutorialFrame:ClearAllPoints()
	self.parent.TutorialFrame:SetPoint("RIGHT", -24, 0)
	self.parent.TutorialFrame:SetWidth(350)
	self.parent.TutorialFrame.Text:SetText(TUTORIAL.TUTORIALFRAMEMO)

	self.parent.CurrentAddon = self
	self.parent.NewMouseover.Addon = self:GetText()

	if self.parent.NewMouseover.MouseOver then
		self.parent.NewMouseover:SetFormattedText(TUTORIAL.MOUSEOVERVALID, self.parent.NewMouseover.MouseOver, self.parent.NewMouseover.Addon)
	end

	self.parent.FrameListText:SetFormattedText(TUTORIAL.FRAMELISTFORMAT, self:GetText())

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

	if not self.parent.FrameStack then

		self.parent.FrameStack = CreateFrame("GameTooltip", "$parentFrameStack", self.parent, "GameTooltipTemplate")
		self.parent.FrameStack:SetOwner(self.parent.FrameScroll, "ANCHOR_BOTTOMRIGHT")
		self.parent.FrameStack:SetPoint("TOP", 0, 0)
		self.parent.FrameStack:SetFrameStrata('TOOLTIP')

		local FRAMESTACK_UPDATE_TIME = .1
		local _timeSinceLast = 0

		self.parent.FrameStack:SetBackdrop(db.Atlas.Backdrops.FullSmall)
		self.parent.FrameStack.config = self.parent:GetParent()
		self.parent.FrameStack:SetScript("OnUpdate", function(self, elapsed)
			if self.config:IsMouseOver() then
				self:SetAlpha(0)
				return
			else
				self:SetAlpha(1)
			end

			_timeSinceLast = _timeSinceLast - elapsed
			if ( _timeSinceLast <= 0 ) then
				_timeSinceLast = FRAMESTACK_UPDATE_TIME
				local highlightFrame = self:SetFrameStack(false, false)
			end
		end)

		self.parent.FrameStack:HookScript("OnShow", function(self)
			self:SetBackdrop(db.Atlas.Backdrops.FullSmall)
		end)

	end
	self.parent.FrameStack:SetOwner(self.parent.FrameScroll, "ANCHOR_BOTTOMRIGHT", 32, self.parent.FrameScroll:GetHeight() + 8)
	self.parent.FrameStack:SetFrameStack(false, false, 1)
	self.parent.FrameStack:Show()
end

local function RefreshAddonList(self)
	local UIFrames, list = db.UIStack, {}
	for i, button in pairs(self.Buttons) do
		button:Hide()
	end

	if db('showAllAddons') then
		for addon, frames in spairs(UIFrames) do
			list[addon] = frames
		end

		for i=1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if not list[name] then
				list[name] = {}
			end
		end
	else
		for addon, frames in spairs(UIFrames) do
			if not addon:match("ConsolePort") and not addon:match("Blizzard_") then
				list[addon] = frames
			end
		end

		for i=1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if 	( not name:match("ConsolePort") ) then
				if not list[name] then
					list[name] = {}
				end
			end
		end
	end

	local num = 0

	for addon, frames in spairs(list) do
		num = num + 1
		local button
		if not self.Buttons[num] then
			button = CreateUICtrlConfigButton(self, num)
			button.parent = self.parent
		else
			button = self.Buttons[num]
		end
		button.Loaded:SetTexture("Interface\\FriendsFrame\\StatusIcon-" .. (IsAddOnLoaded(addon) and "Online" or "Offline"))
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
	self.parent.HideFrameList:Hide()

	self.parent.HotKeyModule:Show()
	self.parent.MultiChoiceModule:Show()

	self.parent.TutorialFrame:ClearAllPoints()
	self.parent.TutorialFrame:SetPoint("CENTER", 150, 160)
	self.parent.TutorialFrame:SetWidth(500)
	self.parent.TutorialFrame.Text:SetText(TUTORIAL.TUTORIALFRAME)

	if self.parent.FrameStack then
		self.parent.FrameStack:Hide()
	end

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
	ConsolePort:RemoveFrame(_G[name])
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
		if outerParent and outerParent ~= ConsolePortOldConfig and outerParent:IsMouseEnabled() and outerParent:GetName() then
			local name = outerParent:GetName()
			if not name:match("ConsolePort") then 
				self.MouseOver = outerParent:GetName()
				self:SetFormattedText(TUTORIAL.MOUSEOVERVALID, self.MouseOver, self.Addon)
			else
				self:SetText(TUTORIAL.MOUSEOVERINVALID)
				self.MouseOver = nil
			end
		end
		timer = 0
	end
end

---------------------------------------------------------------
-- UICtrl: Config mixin functions
---------------------------------------------------------------
function WindowMixin:Default()
	db.UIStack = ConsolePort:GetDefaultUIFrames()
	ConsolePortUIFrames = db.UIStack
	if self.AddonList then
		RefreshAddonList(self.AddonList)
	end
end

function WindowMixin:Save()
	local needReload

	if self.LeftClick then
		db.Mouse.Cursor.Left = self.LeftClick.Value
		db.Mouse.Cursor.Right = self.RightClick.Value
		db.Mouse.Cursor.Scroll = self.ScrollClick.Value
	end

	if self.ToggleCursor then
		db('disableUI', not self.ToggleCursor:GetChecked())
	end

	if self.HotKeyModule then
		local actionBarStyle = self.HotKeyModule:GetID()
		if db('actionBarStyle') ~= actionBarStyle then
			db('actionBarStyle', actionBarStyle)
			needReload = true
		end
	end

	ConsolePort:ToggleUICore()
	ConsolePort:SetupCursor()
	ConsolePort:LoadControllerTheme()

	return needReload
end
db.PANELS[#db.PANELS + 1] = {name = "UICtrl", header = UIOPTIONS_MENU, mixin = WindowMixin, onLoad = function(UICtrl, self)
---------------------------------------------------------------

	UICtrl.TutorialFrame = db.Atlas.GetGlassWindow("$parentTutorialFrame", UICtrl, nil, true)
	UICtrl.TutorialFrame:SetBackdrop(db.Atlas.Backdrops.Border)
	UICtrl.TutorialFrame:SetSize(500, 300)
	UICtrl.TutorialFrame:SetPoint("CENTER", 150, 200)
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

	UICtrl.TutorialFrame.Arrow = UICtrl.TutorialFrame:CreateTexture("$parentArrow", "ARTWORK", nil, 7)
	UICtrl.TutorialFrame.Arrow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
	UICtrl.TutorialFrame.Arrow:SetTexCoord(0.4296, 0.3398, 0.9052, 0.9970)
	UICtrl.TutorialFrame.Arrow:SetSize(92*0.75, 94*0.75)
	UICtrl.TutorialFrame.Arrow:SetPoint("LEFT", -28, 0)

---------------------------------------------------------------

	UICtrl.MultiChoiceModule = db.Atlas.GetGlassWindow("$parentMultiChoiceModule", UICtrl, nil, true)
	UICtrl.MultiChoiceModule.Close:Hide()
	UICtrl.MultiChoiceModule.BG:SetAlpha(0.1)
	UICtrl.MultiChoiceModule:SetPoint("TOP", UICtrl.TutorialFrame, "BOTTOM", 0, 8)
	UICtrl.MultiChoiceModule:SetSize(500, 210)
	UICtrl.MultiChoiceModule:SetScript("OnShow", function(self)
		FadeIn(self, 0.5, 0, 1)
	end)

	local function CheckOnClick(self)
		local parent = self.parent
		local oldVal = parent.Index
		local allSets = parent.AllSets
		parent.Index = self.num
		parent.Value = self.name
		if allSets then
			for x, trigger in pairs(allSets) do
				if trigger ~= parent then
					for i, button in pairs(trigger.Set) do
						if i == self.num and button:GetChecked() then
							button:SetChecked(false)
							local swapTo = trigger.Set[oldVal]
							swapTo:SetChecked(true)
							trigger.Value = swapTo.name
							trigger.Index = swapTo.num
						end
					end
				end
			end
		end
		for i, button in pairs(self.set) do
			button:SetChecked(false)
		end
		self:SetChecked(true)
	end

	UICtrl.ClickButtons = {}

	UICtrl.MultiChoiceModule.CursorHeader = UICtrl.MultiChoiceModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	UICtrl.MultiChoiceModule.CursorHeader:SetText(TUTORIAL.VIRTUALCURSOR)
	UICtrl.MultiChoiceModule.CursorHeader:SetPoint("TOPLEFT", UICtrl.MultiChoiceModule, 24, -24)

	local red, green, blue = db.Atlas.GetCC()

	local clickGraphics = {
		{name = "LeftClick", 	coords = {0.0019531, 0.1484375, 0.4257813, 0.5160}},
		{name = "RightClick", 	coords = {0.0019531, 0.1484375, 0.6269531, 0.7172}},
		{name = "SpecialClick", coords = {0.1542969, 0.3007813, 0.2246094, 0.3149}},
		{name = "ScrollClick", 	coords = {0.0019531, 0.1484375, 0.2246094, 0.3149}},
	}

	for i, info in pairs(clickGraphics) do
		local click = UICtrl.MultiChoiceModule:CreateTexture()
		click:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
		click:SetSize(76, 50)
		click:SetGradientAlpha("VERTICAL", 1, 1, 1, 0.15, 1, 1, 1, 1)
		click:SetTexCoord(unpack(info.coords))

		if info.name ~= "ScrollClick" then
			click.AllSets = UICtrl.ClickButtons
			tinsert(UICtrl.ClickButtons, click)
		end

		if info.name == "SpecialClick" then
			local gear = UICtrl.MultiChoiceModule:CreateTexture(nil, 'OVERLAY')
			gear:SetTexture([[Interface\Cursor\Interact]])
			gear:SetPoint('CENTER', click, 'CENTER', 0, -8)
		end

		click:SetPoint("TOPLEFT", UICtrl.MultiChoiceModule.CursorHeader, "TOPLEFT", (i-1) * 110 + 40, -16)

		UICtrl[info.name] = click
	end

	local clickButtons 	= {
		CP_R_RIGHT 	= ICONS.CP_R_RIGHT,
		CP_R_LEFT 	= ICONS.CP_R_LEFT,
		CP_R_UP		= ICONS.CP_R_UP,
		CP_R_DOWN	= ICONS.CP_R_DOWN,
	}

	local scrollButtons = {
		CP_M1 		= ICONS.CP_M1,
		CP_M2 		= ICONS.CP_M2,
	}

	local radioButtons = {
		{parent = UICtrl.LeftClick, 	selection = clickButtons,	default = db.Mouse.Cursor.Left},
		{parent = UICtrl.RightClick, 	selection = clickButtons,	default = db.Mouse.Cursor.Right},
		{parent = UICtrl.SpecialClick, 	selection = clickButtons, 	default = db.Mouse.Cursor.Special},
		{parent = UICtrl.ScrollClick, 	selection = scrollButtons,	default = db.Mouse.Cursor.Scroll},
	}

	for i, radio in pairs(radioButtons) do
		local num = 1
		radio.parent.Set = {}
		for name, texture in pairs(radio.selection) do
			local button = CreateFrame("CheckButton", "ConsolePortVirtualClick"..i..num, UICtrl.MultiChoiceModule)

			button.num = num
			button.set = radio.parent.Set
			button.name = name
			button.parent = radio.parent

			button:SetBackdrop(db.Atlas.Backdrops.BorderSmall)

			button:SetHighlightTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Checked")
			button:SetCheckedTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Checked")

			button.Checked = button:GetCheckedTexture()
			button.Highlight = button:GetHighlightTexture()

			button.Checked:SetTexCoord(0, 1, 1, 0)
			button.Highlight:SetTexCoord(0, 1, 1, 0)

			button.Checked:ClearAllPoints()
			button.Checked:SetPoint("CENTER", 0, 0)
			button.Checked:SetSize(84, 16)
			button.Checked:SetVertexColor(red, green, blue)

			button.Highlight:ClearAllPoints()
			button.Highlight:SetPoint("CENTER", 0, 0)
			button.Highlight:SetSize(84, 16)

			button:SetSize(100, 32)

			if i == 1 then
				button.text = button:CreateTexture(nil, "OVERLAY")
				button.text:SetTexture(gsub(texture, "Icons64x64", "Icons32x32"))
				button.text:SetPoint("RIGHT", button, "LEFT", 0, 0)
				button.text:SetSize(32, 32)
			elseif i == 4 then
				button.text = button:CreateTexture(nil, "OVERLAY")
				button.text:SetTexture(gsub(texture, "Icons64x64", "Icons32x32"))
				button.text:SetPoint("RIGHT", button, "LEFT", 8, 0)
				button.text:SetSize(32, 32)

				button:SetWidth(80)
				button.Highlight:SetWidth(64)
				button.Checked:SetWidth(64)		
			end

			button:SetPoint("TOP", radio.parent, "TOP", 0, -24*(num-1)-42)
			if name == radio.default then
				radio.parent.Index = num
				radio.parent.Value = name
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end
			tinsert(radio.parent.Set, button)
			button:SetScript("OnClick", CheckOnClick)
			num = num + 1
		end
	end

---------------------------------------------------------------

	UICtrl.AddonScroll = db.Atlas.GetScrollFrame("$parentAddonScrollFrame", UICtrl, {
		childKey = "List",
		childWidth = 260,
		stepSize = 64,
	})

	UICtrl.AddonScroll:SetPoint("TOPLEFT", UICtrl, "TOPLEFT", 24, -41)
	UICtrl.AddonScroll:SetPoint("BOTTOMLEFT", UICtrl, "BOTTOMLEFT", 24, 91)
	UICtrl.AddonScroll:SetWidth(260)

	UICtrl.AddonList = UICtrl.AddonScroll.Child
	UICtrl.AddonList.parent = UICtrl
	UICtrl.AddonList.Buttons = UICtrl.AddonScroll.Buttons
	UICtrl.AddonList:SetScript("OnShow", RefreshAddonList)
	UICtrl.AddonList:SetScript("OnEvent", RefreshAddonList)
	UICtrl.AddonList:SetScript("OnHide", UICtrl.AddonList.UnregisterAllEvents)

	UICtrl.AddonShowAll = CreateFrame("CheckButton", "$parentShowAllButton", UICtrl, "ChatConfigCheckButtonTemplate")
	UICtrl.AddonShowAll.Text = UICtrl.AddonShowAll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.AddonShowAll.Text:SetText(TUTORIAL.SHOWALLADDONS)
	UICtrl.AddonShowAll.Text:SetPoint("LEFT", 30, 1)
	UICtrl.AddonShowAll:SetPoint("BOTTOMLEFT", 24, 24)
	UICtrl.AddonShowAll:SetScript("OnShow", function(self)
		self:SetChecked(db.Settings.showAllAddons)
	end)
	UICtrl.AddonShowAll:SetScript("OnClick", function(self)
		db.Settings.showAllAddons = self:GetChecked()
		RefreshAddonList(UICtrl.AddonList)
	end)

	UICtrl.AddonListText = UICtrl.AddonScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.AddonListText:SetPoint("BOTTOMLEFT", UICtrl.AddonScroll, "TOPLEFT", 0, 8)
	UICtrl.AddonListText:SetText(TUTORIAL.ADDONLISTHEADER)

	UICtrl.ToggleCursor = CreateFrame("CheckButton", "$parentToggleButton", UICtrl, "ChatConfigCheckButtonTemplate")
	UICtrl.ToggleCursor.Text = UICtrl.ToggleCursor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.ToggleCursor.Text:SetText(TUTORIAL.ENABLECURSOR)
	UICtrl.ToggleCursor.Text:SetPoint("LEFT", 30, 1)
	UICtrl.ToggleCursor:SetPoint("BOTTOM", UICtrl.AddonShowAll, "TOP", 0, 8)
	UICtrl.ToggleCursor:SetChecked(not db.Settings.disableUI)
	UICtrl.ToggleCursor:SetScript("OnShow", function(self)
		self:SetChecked(not db('disableUI'))
	end)

	UICtrl.FrameScroll = db.Atlas.GetScrollFrame("$parentFrameScrollFrame", UICtrl, {
		childKey = "List",
		childWidth = 260,
		scrollStep = 64,
		stepSize = 24,
	})

	UICtrl.FrameScroll:SetPoint("TOPLEFT", UICtrl.AddonScroll, "TOPRIGHT", 32, 0)
	UICtrl.FrameScroll:SetPoint("BOTTOMLEFT", UICtrl.AddonScroll, "BOTTOMRIGHT", 32, 0)
	UICtrl.FrameScroll:SetWidth(260)

	UICtrl.FrameList = UICtrl.FrameScroll.Child
	UICtrl.FrameList:RegisterEvent("ADDON_LOADED")
	UICtrl.FrameList:SetScript("OnEvent", RefreshFrameStatus)
	UICtrl.FrameList.parent = UICtrl
	UICtrl.FrameList.Buttons = UICtrl.FrameScroll.Buttons

	UICtrl.FrameListText = UICtrl.FrameScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.FrameListText:SetPoint("BOTTOMLEFT", UICtrl.FrameScroll, "TOPLEFT", 0, 8)
	UICtrl.FrameListText:SetText(TUTORIAL.FRAMELISTHEADER)

	UICtrl.NewFrame = db.Atlas.GetFutureButton("$parentNewFrameButton", UICtrl)
	UICtrl.NewFrame:SetPoint("TOP", UICtrl.FrameScroll.Backdrop, "BOTTOM", 0, 0)
	UICtrl.NewFrame:SetText(TUTORIAL.NEWFRAME)
	UICtrl.NewFrame:SetScript("OnClick", NewFrameOnClick)
	UICtrl.NewFrame:Hide()

	UICtrl.HideFrameList = db.Atlas.GetFutureButton("$parentHideFrameListButton", UICtrl, nil, nil, 330)
	UICtrl.HideFrameList:SetPoint("BOTTOMRIGHT", UICtrl, -32, 28)
	UICtrl.HideFrameList:SetText(TUTORIAL.HIDEFRAMELIST)
	UICtrl.HideFrameList:SetScript("OnClick", function(self)
		RefreshAddonList(UICtrl.AddonList)
	end)
	UICtrl.HideFrameList:Hide()

	UICtrl.NewMouseover = db.Atlas.GetFutureButton("$parentNewFrameButton", UICtrl, nil, nil, 330)
	UICtrl.NewMouseover:SetPoint("BOTTOM", UICtrl.HideFrameList, "TOP", 0, 12)
	UICtrl.NewMouseover:SetText(TUTORIAL.MOUSEOVERINVALID)
	UICtrl.NewMouseover:SetScript("OnUpdate", NewMouseoverUpdate)
	UICtrl.NewMouseover:SetScript("OnClick", NewMouseoverOnClick)
	UICtrl.NewMouseover.Timer = 0
	UICtrl.NewMouseover:Hide()

---------------------------------------------------------------

	UICtrl.HotKeyModule = db.Atlas.GetGlassWindow("$parentHotkeyModule", UICtrl, nil, true)
	UICtrl.HotKeyModule:SetID(1)
	UICtrl.HotKeyModule:SetBackdrop(db.Atlas.Backdrops.Border)
	UICtrl.HotKeyModule:SetSize(500, 130)
	UICtrl.HotKeyModule:SetPoint("TOP", UICtrl.MultiChoiceModule, "BOTTOM", 0, 8)
	UICtrl.HotKeyModule.Close:Hide()
	UICtrl.HotKeyModule.BG:SetAlpha(0.1)
	UICtrl.HotKeyModule:SetScript("OnShow", function(self)
		FadeIn(self, 0.5, 0, 1)
	end)


	UICtrl.HotKeyModule.Styles = {}

	UICtrl.HotKeyModule.Header = UICtrl.HotKeyModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	UICtrl.HotKeyModule.Header:SetText(TUTORIAL.ACTIONBARHEADER)
	UICtrl.HotKeyModule.Header:SetPoint("TOPLEFT", 24, -24)

	local actionBarStyles = {
		[1] = {name = "CP_R_UP", 	animated = true},
		[2] = {name = "CP_R_RIGHT", animated = true},
		[3] = {name = "CP_R_LEFT", 	animated = false},
		[4] = {name = "CP_R_DOWN", 	animated = false},
		[5] = {name = "CP_R_DOWN", 	animated = true},
	}

	local styles = UICtrl.HotKeyModule.Styles

	-- since user might not press any modifiers while browsing this module,
	-- simulate a faux modifier change to notify the user that this style is animated.

	local function SimulateModifier(self, elapsed)
		self.time = (self.time or 0) + elapsed
		if self.time > 1.5 then
			self.fauxShift = not self.fauxShift
			self.fauxCtrl = not self.fauxCtrl
			self.GetStates = function() return self.fauxCtrl, self.fauxShift end
			self:GetScript('OnEvent')(self)
			self.time = 0
		end
	end

	local iconFile, iconTCoords = CPAPI:GetClassIcon()

	for index, info in pairs(actionBarStyles) do
		local button = CreateFrame("CheckButton", "$parentStyle"..#UICtrl.HotKeyModule.Styles+1, UICtrl.HotKeyModule)
		button:SetSize(39, 39)

		button.Checked = button:CreateTexture(nil, "ARTWORK")
		button.Checked:SetAtlas("orderhalltalents-spellborder-yellow")
		button.Checked:SetSize(50, 50)
		button.Checked:SetPoint("TOP", 0, 5)

		button:SetCheckedTexture(button.Checked)

		button.Icon = button:CreateTexture(nil, "ARTWORK")
		button.Icon:SetPoint("CENTER")
		button.Icon:SetSize(39, 39)

		button.Icon:SetTexture(iconFile)
		button.Icon:SetTexCoord(unpack(iconTCoords))

		button.name = info.name
		button.mod = "CTRL-SHIFT-"

		button.HotKey = db.CreateHotkey(button, index)
		button.HotKey:Show()
		button.HotKey:SetPoint("TOPRIGHT", 0, 0)

		if info.animated then
			button.HotKey:UnregisterAllEvents()
			button.HotKey:SetScript('OnUpdate', SimulateModifier)
		end

		button:SetPoint("TOPLEFT", UICtrl.HotKeyModule, "LEFT", 32 + 52 * (index - 1), 8)
		if ( index == db.Settings.actionBarStyle ) or ( index == 1 and not db.Settings.actionBarStyle ) then
			UICtrl.HotKeyModule:SetID(index)
			button:SetChecked(true)
		else
			button:SetChecked(false)
		end

		styles[#styles + 1] = button

		button:SetScript("OnClick", function(self)
			for i, button in pairs(styles) do
				button:SetChecked(false)
			end
			self:SetChecked(true)
			UICtrl.HotKeyModule:SetID(index)
		end)
	end

---------------------------------------------------------------

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
		OnCancel = ConsolePort.ClearPopup,
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
		OnCancel = ConsolePort.ClearPopup,
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
		OnCancel = ConsolePort.ClearPopup,
	}
end}