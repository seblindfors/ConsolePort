---------------------------------------------------------------
local db = ConsolePort:DB()
---------------------------------------------------------------
local addOn, ab = ...
---------------------------------------------------------------
local class = select(2, UnitClass("player"))
---------------------------------------------------------------

local classPage = {
	["WARRIOR"]	= "[bonusbar:1] 7; [bonusbar:2] 8;",
	["ROGUE"]	= "[stance:1] 7; [stance:2] 7; [stance:3] 7;",
	["DRUID"]	= "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["MONK"]	= "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] 	= "[bonusbar:1] 7;"
}

local Bar = CreateFrame("Frame", addOn, UIParent, "SecureHandlerStateTemplate")
local Lib = ab.libs.button
local now, state = ConsolePort:GetActionPageState()

Bar.Buttons = {}
Bar.isForbidden = true
Bar:SetPoint("BOTTOM", UIParent, 0, 0)
RegisterStateDriver(Bar, "page", state)
RegisterStateDriver(Bar, "modifier", "[mod:ctrl,mod:shift] ctrlsh; [mod:ctrl] ctrl; [mod:shift] shift; action")
Bar:SetAttribute("_onstate-modifier", [[
	self:SetAttribute("state", newstate)
	control:ChildUpdate("state", newstate)
]])
Bar:SetAttribute("_onstate-page", [[
	local page = newstate
	if page == "temp" then
		if HasTempShapeshiftActionBar() then
			page = GetTempShapeshiftBarIndex()
		else
			page = 1
		end
	elseif page == "possess" then
		page = self:GetFrameRef("ActionBar"):GetAttribute("actionpage") or 1
		if  page <= 10 then
			page = self:GetFrameRef("OverrideBar"):GetAttribute("actionpage") or 12
		end
		if  page <= 10 then
			page = 12
		end
	end
	self:SetAttribute("actionpage", page)
	control:ChildUpdate("actionpage", page)
]])
Bar:Execute(format([[
	self:RunAttribute("_onstate-page", "%s")
]], now))
---------------------------------------------------------------
-- 1
---------------------------------------------------------------
-- for btn=1, 12 do
-- 	local button = Lib:CreateButton(1, "LABTest"..btn, Bar)
-- 	button:SetPoint("LEFT", Bar, (btn-1)*70, 0)
-- 	button:Show()
-- 	button:SetState(1, "action", btn)
-- 	button:SetState(2, "action", btn)
-- 	button:SetSize(64, 64)

-- 	button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

-- 	button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.NormalTexture:SetAlpha(0.75)
-- 	button.NormalTexture:ClearAllPoints()
-- 	button.NormalTexture:SetPoint("CENTER", 0, 0)
-- 	button.NormalTexture:SetSize(74, 74)
-- 	button:HookScript("OnAttributeChanged", function(self, ...)
-- 	--	print(...)
-- 	end)

-- 	button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
-- 	button:GetPushedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")
-- 	button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")

-- 	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
-- end

-- ---------------------------------------------------------------
-- -- 2
-- ---------------------------------------------------------------
-- for btn=61, 72 do
-- 	local button = Lib:CreateButton(1, "LABTest"..btn, Bar)
-- 	button:SetPoint("LEFT", Bar, ((btn-61)*54), 64)
-- 	button:Show()
-- 	button:SetState(1, "action", btn)
-- 	button:SetState(2, "action", btn)
-- 	button:SetSize(64*0.75, 64*0.75)

-- 	button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

-- 	button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.NormalTexture:SetAlpha(0.75)
-- 	button.NormalTexture:ClearAllPoints()
-- 	button.NormalTexture:SetPoint("CENTER", 0, 0)
-- 	button.NormalTexture:SetSize(74*0.75, 74*0.75)
-- 	button:HookScript("OnAttributeChanged", function(self, ...)
-- 	--	print(...)
-- 	end)

-- 	button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
-- 	button:GetPushedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")
-- 	button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")

-- 	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
-- end

-- ---------------------------------------------------------------
-- -- 3
-- ---------------------------------------------------------------
-- for btn=49, 60 do
-- 	local button = Lib:CreateButton(1, "LABTest"..btn, Bar)
-- 	button:SetPoint("LEFT", Bar, ((btn-49)*54), 120)
-- 	button:Show()
-- 	button:SetState(1, "action", btn)
-- 	button:SetState(2, "action", btn)
-- 	button:SetSize(64*0.75, 64*0.75)

-- 	button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

-- 	button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.NormalTexture:SetAlpha(0.75)
-- 	button.NormalTexture:ClearAllPoints()
-- 	button.NormalTexture:SetPoint("CENTER", 0, 0)
-- 	button.NormalTexture:SetSize(74*0.75, 74*0.75)
-- 	button:HookScript("OnAttributeChanged", function(self, ...)
-- 	--	print(...)
-- 	end)

-- 	button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
-- 	button:GetPushedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")
-- 	button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")

-- 	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
-- end

function ConsolePort:GetBindingIcon(binding)
	local icons = {
		["JUMP"] = "Interface\\Icons\\Ability_Karoz_Leap",
	}
	return icons[binding]
end

for i, binding in pairs(ConsolePort:GetBindingNames()) do
	local button = Lib:Create(Bar, binding)
	Lib:SetState(button, db.Bindings[binding])

	if i > 10 then
		button:SetPoint("RIGHT", UIParent, -30, (i-10) * -110 + 300)
	else
		button:SetPoint("LEFT", Bar, (i-1)*110 + 51, 16)
	end
	Bar.Buttons[i] = button
end

Bar:SetWidth(#Bar.Buttons > 10 and (10 * 110) + 55 or (#Bar.Buttons * 110) + 55)

Bar:SetAttribute("page", 1)



function Bar:HideBlizzard()
	-- Hidden parent frame
	local UIHider = CreateFrame("Frame")
	UIHider:Hide()
	self.UIHider = UIHider

	MultiBarBottomLeft:SetParent(UIHider)
	MultiBarBottomRight:SetParent(UIHider)
	MultiBarLeft:SetParent(UIHider)
	MultiBarRight:SetParent(UIHider)

	-- Hide MultiBar Buttons, but keep the bars alive
	for i=1,12 do
		_G["ActionButton" .. i]:Hide()
		_G["ActionButton" .. i]:UnregisterAllEvents()
		_G["ActionButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton" .. i]:Hide()
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton" .. i]:Hide()
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton" .. i]:Hide()
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton" .. i]:Hide()
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true)
	end
	--UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarRight"] = nil
	--UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarLeft"] = nil
	--UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = nil
	--UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil

	--MainMenuBar:UnregisterAllEvents()
	--MainMenuBar:Hide()
	--MainMenuBar:SetParent(UIHider)
	MainMenuBar:EnableMouse(false)

	local animations = {MainMenuBar.slideOut:GetAnimations()}
	animations[1]:SetOffset(0,0)

	animations = {OverrideActionBar.slideOut:GetAnimations()}
	animations[1]:SetOffset(0,0)

	--MainMenuBarArtFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	--MainMenuBarArtFrame:UnregisterEvent("BAG_UPDATE")
	--MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	--MainMenuBarArtFrame:UnregisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
	--MainMenuBarArtFrame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	--MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	--MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERING_VEHICLE")
	--MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	--MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITING_VEHICLE")
	--MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITED_VEHICLE")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	--MainMenuExpBar:UnregisterAllEvents()
	--MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(UIHider)

	MainMenuBarMaxLevelBar:Hide()
	MainMenuBarMaxLevelBar:SetParent(UIHider)

	--ReputationWatchBar:UnregisterAllEvents()
	--ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIHider)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIHider)

	--BonusActionBarFrame:UnregisterAllEvents()
	--BonusActionBarFrame:Hide()
	--BonusActionBarFrame:SetParent(UIHider)

	--PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end

	--self:RegisterPetBattleDriver()
end

Bar:HideBlizzard()


ConsolePort:LoadHotKeyTextures()

Bar:SetBackdrop(db.Atlas.Backdrops.Border)

Bar.BG = Bar:CreateTexture(nil, "BACKGROUND")
Bar.BG:SetPoint("TOPLEFT", Bar, "TOPLEFT", 16, -16)
Bar.BG:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT", -16, 16)
Bar.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Bar.BG:SetBlendMode("ADD")

local red, green, blue = db.Atlas.GetCC()

Bar.BG:SetVertexColor(red, green, blue, 0.25)

Bar:SetHeight(150)