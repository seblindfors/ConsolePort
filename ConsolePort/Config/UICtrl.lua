local addOn, db = ...
---------------------------------------------------------------
-- Config: UICtrl addons/frames scripts
---------------------------------------------------------------
local function NewAddonOnClick(self)
	local self = self:GetParent()
	local dialog = StaticPopup_Show("CONSOLEPORT_ADDADDON")
	if dialog then
		dialog.data = self.AddonList
	end
end

local function NewFrameOnClick(self)
	local self = self:GetParent()
	if self.CurrentAddon then
		local dialog = StaticPopup_Show("CONSOLEPORT_ADDFRAME", self.CurrentAddon:GetText())
		if dialog then
			dialog.data = self.CurrentAddon
		end
	end
end

local function RemoveAddonOnClick(self)
	local self = self:GetParent()
	local addonList = self.parent.AddonList
	local addon = self:GetText()
	local dialog = StaticPopup_Show("CONSOLEPORT_REMOVEADDON", addon)
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
	local dialog = StaticPopup_Show("CONSOLEPORT_REMOVEFRAME", frame, addon)
	if dialog then
		dialog.data = self
		dialog.data2 = owner
	end
end

---------------------------------------------------------------
-- Config: UICtrl addons and frames
---------------------------------------------------------------
local function CreateUICtrlConfigButton(parent, num, clickScript, removeScript)
	local button = CreateFrame("Button", "$parentButton"..num, parent, "OptionsListButtonTemplate")
	button:SetHeight(24)
	button:SetScript("OnClick", clickScript)
	button.Remove = CreateFrame("Button", "$parentRemove", button)
	button.Remove:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	button.Remove:SetSize(14, 14)
	button.Remove:SetPoint("RIGHT", button, "RIGHT", -8, 0)
	button.Remove:SetAlpha(0.5)
	button.Remove:SetScript("OnClick", removeScript)
	button.Loaded = button:CreateTexture()
	button.Loaded:SetSize(16, 16)
	button.Loaded:SetPoint("LEFT", button.Remove, "RIGHT", -2, -1)
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

	self.parent.NewFrame:SetButtonState("NORMAL")
	self.parent.CurrentAddon = self

	local header = self.parent.FrameListText
	header:SetText(format("Frames in |cffffe00a%s|r:", self:GetText()))

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
			button = CreateUICtrlConfigButton(frameList, num, nil, RemoveFrameOnClick)
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
	local list = ConsolePortUIFrames
	for i, button in pairs(self.Buttons) do
		button:Hide()
	end

	local num = 0
	for addon, frames in db.pairsByKeys(list) do
		num = num + 1
		local button
		if not self.Buttons[num] then
			button = CreateUICtrlConfigButton(self, num, RefreshFrameList, RemoveAddonOnClick)
			button.parent = self.parent
		else
			button = self.Buttons[num]
		end
		if IsAddOnLoaded(addon) then
			button.Loaded:SetTexture("Interface\\FriendsFrame\\StatusIcon-Online")
		else
			button.Loaded:SetTexture("Interface\\FriendsFrame\\StatusIcon-Offline")
		end
		button:Show()
		button:SetText(addon)
		button.list = frames
	end
	self:SetHeight(num*24)
	self:RegisterEvent("ADDON_LOADED")
end

---------------------------------------------------------------
-- Config: UICtrl popup functions
---------------------------------------------------------------
local function AddFramePopupAccept(self, addonButton)
	local list = ConsolePortUIFrames
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

local function AddAddonPopupAccept(self, addonList)
	local list = ConsolePortUIFrames
	local addon = self.editBox:GetText():trim()
	if not list[addon] then
		list[addon] = {}
	end
	RefreshAddonList(addonList)
end

local function RemoveAddonPopupAccept(self, addonList, addon)
	local list = ConsolePortUIFrames
	list[addon] = nil
	RefreshAddonList(addonList)
	ConsolePort:CheckLoadedAddons()
end

local function RemoveFramePopupAccept(self, frame, addon)
	local list = ConsolePortUIFrames[addon:GetText()]
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
-- Config: Default functions	
---------------------------------------------------------------
local function LoadDefaultUICtrl(self)
	ConsolePortUIFrames = ConsolePort:GetDefaultUIFrames()
	RefreshAddonList(self.AddonList)
end


local function ConfigurePanelUICtrl(self, UICtrl)
	UICtrl.AddonList = CreateFrame("Frame", "$parentAddonList", UICtrl)
	UICtrl.AddonList:SetSize(260, 1000)
	UICtrl.AddonList.parent = UICtrl
	UICtrl.AddonList.Buttons = {}
	UICtrl.AddonList:SetScript("OnShow", RefreshAddonList)
	UICtrl.AddonList:SetScript("OnEvent", RefreshAddonList)
	UICtrl.AddonList:SetScript("OnHide", UICtrl.AddonList.UnregisterAllEvents)

	UICtrl.AddonScroll = CreateFrame("ScrollFrame", "$parentAddonScrollFrame", UICtrl, "UIPanelScrollFrameTemplate")
	UICtrl.AddonScroll:SetPoint("TOPLEFT", UICtrl, "TOPLEFT", 16, -64)
	UICtrl.AddonScroll:SetPoint("BOTTOMRIGHT", UICtrl, "BOTTOM", -32, 46)
	UICtrl.AddonScroll:SetScrollChild(UICtrl.AddonList)

	UICtrl.AddonWrap = CreateFrame("Frame", "$parentAddonWrap", UICtrl, "InsetFrameTemplate3")
	UICtrl.AddonWrap:SetPoint("TOPLEFT", UICtrl, "TOPLEFT", 14, -60)
	UICtrl.AddonWrap:SetPoint("BOTTOMRIGHT", UICtrl, "BOTTOM", -32, 42)

	UICtrl.AddonListText = UICtrl:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.AddonListText:SetPoint("BOTTOMLEFT", UICtrl.AddonScroll, "TOPLEFT", 0, 8)
	UICtrl.AddonListText:SetText("AddOns:")

	UICtrl.NewAddon = CreateFrame("BUTTON", "$parentNewAddonButton", UICtrl, "UIPanelButtonTemplate")
	UICtrl.NewAddon:SetPoint("TOPLEFT", UICtrl.AddonScroll, "BOTTOMLEFT", 0, -12)
	UICtrl.NewAddon:SetWidth(100)
	UICtrl.NewAddon:SetText("New addon")
	UICtrl.NewAddon:SetScript("OnClick", NewAddonOnClick)

	UICtrl.FrameList = CreateFrame("Frame", "$parentFrameList", UICtrl)
	UICtrl.FrameList:RegisterEvent("ADDON_LOADED")
	UICtrl.FrameList:SetScript("OnEvent", RefreshFrameStatus)
	UICtrl.FrameList:SetSize(260, 1000)
	UICtrl.FrameList.parent = UICtrl
	UICtrl.FrameList.Buttons = {}

	UICtrl.FrameScroll = CreateFrame("ScrollFrame", "$parentFrameScrollFrame", UICtrl, "UIPanelScrollFrameTemplate")
	UICtrl.FrameScroll:SetPoint("TOPRIGHT", UICtrl, "TOPRIGHT", -48, -64)
	UICtrl.FrameScroll:SetPoint("BOTTOMLEFT", UICtrl, "BOTTOM", 0, 46)
	UICtrl.FrameScroll:SetScrollChild(UICtrl.FrameList)

	UICtrl.FrameWrap = CreateFrame("Frame", "$parentFrameWrap", UICtrl, "InsetFrameTemplate3")
	UICtrl.FrameWrap:SetPoint("TOPRIGHT", UICtrl, "TOPRIGHT", -48, -60)
	UICtrl.FrameWrap:SetPoint("BOTTOMLEFT", UICtrl, "BOTTOM", -4, 42)

	UICtrl.FrameListText = UICtrl:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.FrameListText:SetPoint("BOTTOMLEFT", UICtrl.FrameScroll, "TOPLEFT", 0, 8)
	UICtrl.FrameListText:SetText("Frames:")

	UICtrl.NewFrame = CreateFrame("BUTTON", "$parentNewFrameButton", UICtrl, "UIPanelButtonTemplate")
	UICtrl.NewFrame:SetPoint("TOPLEFT", UICtrl.FrameScroll, "BOTTOMLEFT", 0, -12)
	UICtrl.NewFrame:SetWidth(100)
	UICtrl.NewFrame:SetText("New frame")
	UICtrl.NewFrame:SetButtonState("DISABLED")
	UICtrl.NewFrame:SetScript("OnClick", NewFrameOnClick)

	StaticPopupDialogs["CONSOLEPORT_ADDADDON"] = {
		text = "Enter name of addon or module:",
		button1 = "Add",
		button2 = "Cancel",
		showAlert = true,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = AddAddonPopupAccept,
	}

	StaticPopupDialogs["CONSOLEPORT_ADDFRAME"] = {
		text = "Enter name to add frame to addon |cffffe00a%s|r:",
		button1 = "Add",
		button2 = "Cancel",
		showAlert = true,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = AddFramePopupAccept
	}

	StaticPopupDialogs["CONSOLEPORT_REMOVEFRAME"] = {
		text = "Do you want to remove frame |cffffe00a%s|r in addon |cffffe00a%s|r from virtual cursor?",
		button1 = "Remove",
		button2 = "Cancel",
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = RemoveFramePopupAccept
	}

	StaticPopupDialogs["CONSOLEPORT_REMOVEADDON"] = {
		text = "Do you want to remove addon |cffffe00a%s|r from virtual cursor?",
		button1 = "Remove",
		button2 = "Cancel",
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept =  RemoveAddonPopupAccept
	}
end

tinsert(db.Panels, {"ConsolePortConfigFrameConfig", "UICtrl", "Interface", "Interface settings (advanced)", false, false, LoadDefaultUICtrl, ConfigurePanelUICtrl})