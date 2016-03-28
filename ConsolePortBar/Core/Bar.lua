---------------------------------------------------------------
local db = ConsolePort:DB()
---------------------------------------------------------------
local addOn, ab = ...
---------------------------------------------------------------
local class = select(2, UnitClass("player"))
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()

local classPage = {
	["WARRIOR"]	= "[bonusbar:1] 7; [bonusbar:2] 8;",
	["ROGUE"]	= "[stance:1] 7; [stance:2] 7; [stance:3] 7;",
	["DRUID"]	= "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["MONK"]	= "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] 	= "[bonusbar:1] 7;"
}

local Bar = CreateFrame("Frame", addOn, UIParent, "SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate")
local Lib = ab.libs.button
local now, state = ConsolePort:GetActionPageState()
---------------------------------------------------------------
ab.bar = Bar
---------------------------------------------------------------

Bar.ignoreNode = true
Bar.Buttons = {}
Bar.isForbidden = true
Bar:SetClampedToScreen(true)
Bar:SetScript("OnMouseDown", Bar.StartMoving)
Bar:SetScript("OnMouseUp", Bar.StopMovingOrSizing)
Bar:SetMovable(true)
Bar:SetPoint("BOTTOM", UIParent, 0, 0)
RegisterStateDriver(Bar, "page", state)
RegisterStateDriver(Bar, "modifier", "[mod:ctrl,mod:shift] ctrlsh; [mod:ctrl] ctrl; [mod:shift] shift; action")
RegisterStateDriver(Bar, "visibility", "[petbattle][vehicleui] hide; show")

Bar:SetFrameRef("ActionBar", MainMenuBarArtFrame)
Bar:SetFrameRef("OverrideBar", OverrideActionBar)

Bar:SetAttribute("_onstate-modifier", [[
	self:SetAttribute("state", newstate)
	control:ChildUpdate("state", newstate)
]])
Bar:SetAttribute("_onenter", [[
	control:ChildUpdate("hover", true)
]])
Bar:SetAttribute("_onleave", [[
	if not self:IsUnderMouse(true) then
		control:ChildUpdate("hover", false)
	end
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

function ConsolePort:GetBindingIcon(binding)
	local icons = {
		["JUMP"] = [[Interface\Icons\Ability_Karoz_Leap]],
		["OPENALLBAGS"] = [[Interface\Icons\INV_Misc_Bag_29]],
		["TOGGLEGAMEMENU"] = [[Interface\Icons\Achievement_ChallengeMode_Auchindoun_Hourglass]],
		["TOGGLEWORLDMAP"] = [[Interface\Icons\INV_Misc_Map02]],
		["TARGETNEARESTENEMY"] = [[Interface\Icons\Spell_Hunter_FocusingShot]],
		["CLICK ConsolePortWorldCursor:LeftButton"] = [[Interface\Icons\Achievement_GuildPerk_EverybodysFriend]],
	}
	return icons[binding]
end

local layout = {
	-- ["CP_TR1"] = {"CENTER", -56, 0},
	-- ["CP_TR2"] = {"CENTER", 56, 0},
	-- ---
	-- ["CP_L_LEFT"] 	= {"LEFT", 160, 55},
	-- ["CP_L_RIGHT"] 	= {"LEFT", 360, 55},
	-- ["CP_L_UP"] 	= {"LEFT", 260, 110},
	-- ["CP_L_DOWN"] 	= {"LEFT", 260, 0},
	-- ---
	-- ["CP_R_LEFT"] 	= {"RIGHT", -160, 55},
	-- ["CP_R_RIGHT"] 	= {"RIGHT", -360, 55},
	-- ["CP_R_UP"] 	= {"RIGHT", -260, 110},
	-- ["CP_R_DOWN"] 	= {"RIGHT", -260, 0},
}

for i, binding in pairs(ConsolePort:GetBindingNames()) do
	local button = Lib:Create(Bar, binding)
--	Lib:SetState(button, db.Bindings[binding])

	local position = layout[binding]

	if position then
		button:SetPoint(unpack(position))
	else
		if i > 10 then
			button:SetPoint("RIGHT", UIParent, -30, (i-10) * -110 + 300)
		else
			button:SetPoint("LEFT", Bar, (i-1)*110 + 51, 0)
		end
	end
	Bar.Buttons[i] = button
end

Lib:UpdateAllBindings()

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

	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil

	MainMenuBar:EnableMouse(false)

	local animations = {MainMenuBar.slideOut:GetAnimations()}
	animations[1]:SetOffset(0,0)

	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	MainMenuExpBar:SetParent(Bar)
	MainMenuExpBar:ClearAllPoints()
	MainMenuExpBar:SetPoint("BOTTOM", 0, 3)
	MainMenuExpBar.OldSetStatusBarColor = MainMenuExpBar.SetStatusBarColor

	function MainMenuExpBar:SetStatusBarColor(...)
		self:OldSetStatusBarColor(red, green, blue)
	end

	MainMenuXPBarTextureMid:SetTexCoord(0, 1, 1, 0)
	MainMenuXPBarTextureLeftCap:SetTexCoord(0.18750000, 0.43750000, 0.26562500, 0.01562500)
	MainMenuXPBarTextureRightCap:SetTexCoord(0.18750000, 0.43750000, 0.54687500, 0.29687500)

	MainMenuXPBarTextureMid:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)
	MainMenuXPBarTextureLeftCap:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)
	MainMenuXPBarTextureRightCap:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)

	MainMenuMicroButton:SetParent(self)
	MainMenuMicroButton:ClearAllPoints()
	MainMenuMicroButton:SetPoint("TOP", 0, -16)
	MainMenuMicroButton:SetHitRectInsets(0, 0, 0, 0)
	MainMenuMicroButton:SetSize(80, 42)
	MainMenuMicroButton:SetNormalTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\MenuNormal")
	MainMenuMicroButton:SetHighlightTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\MenuNormal")
	MainMenuMicroButton:SetPushedTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\MenuPushed")

	MainMenuMicroButton:GetNormalTexture():SetVertexColor(red, green, blue, 0.25)

	MainMenuMicroButton.SetNormalTexture = function() end
	MainMenuMicroButton.SetHighlightTexture = function() end
	MainMenuMicroButton.SetPushedTexture = function() end

	MainMenuMicroButton.SetPoint = function() end

	MainMenuBarPerformanceBar:SetParent(UIHider)
	MainMenuBarPerformanceBar:ClearAllPoints()

	MainMenuXPBarTextureMid:SetAlpha(0.5)
	MainMenuXPBarTextureLeftCap:SetAlpha(0.5)
	MainMenuXPBarTextureRightCap:SetAlpha(0.5)

	for i=1, 19 do
		_G["MainMenuXPBarDiv"..i]:SetAlpha(0.5)
	end

	MainMenuBarMaxLevelBar:Hide()
	MainMenuBarMaxLevelBar:SetParent(UIHider)

	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIHider)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIHider)

	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)

	ObjectiveTrackerFrame:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -100, -132)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end

end

Bar:HideBlizzard()


ConsolePort:LoadHotKeyTextures()


local backdrop = {
	edgeFile 	= "Interface\\AddOns\\ConsolePortBar\\Textures\\BarEdge",
	edgeSize 	= 32,
	insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
}

Bar:SetBackdrop(backdrop)

Bar.ArtOverlay = Bar:CreateTexture(nil, "BACKGROUND")

Bar.BG = Bar:CreateTexture(nil, "BACKGROUND")
Bar.BG:SetPoint("TOPLEFT", Bar, "TOPLEFT", 16, -16)
Bar.BG:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT", -16, 16)
Bar.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Bar.BG:SetBlendMode("ADD")

Bar.TopLine = Bar:CreateTexture(nil, "BORDER")
Bar.TopLine:SetTexture("Interface\\LevelUp\\LevelUpTex")
Bar.TopLine:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500)
Bar.TopLine:SetHeight(7)
Bar.TopLine:SetPoint("TOPLEFT", 0, -9)
Bar.TopLine:SetPoint("TOPRIGHT", 0, -9)
Bar.TopLine:SetVertexColor(red, green, blue, 1)

Bar.BottomLine = Bar:CreateTexture(nil, "BORDER")
Bar.BottomLine:SetTexture("Interface\\LevelUp\\LevelUpTex")
Bar.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500)
Bar.BottomLine:SetHeight(7)
Bar.BottomLine:SetPoint("BOTTOMLEFT", 0, 16)
Bar.BottomLine:SetPoint("BOTTOMRIGHT", 0, 16)
Bar.BottomLine:SetVertexColor(red, green, blue, 1)


Bar.BG:SetVertexColor(red, green, blue, 0.25)

Bar:SetHeight(170)

function Bar:UpdateArt()
	self.ArtOverlay:SetMask(nil)
	self.ArtOverlay:SetTexture("Interface\\TALENTFRAME\\"..(db.Atlas.GetOverlay() or ""))
	self.ArtOverlay:SetTexCoord(0, 1, 0, 0.12890625 + 0.025)
	self.ArtOverlay:SetSize(988, 170)
	self.ArtOverlay:SetPoint("CENTER", 0, 0)
	self.ArtOverlay:SetMask("Interface\\GLUES\\Models\\UI_Dwarf\\UI_Goblin_GodRaysMask")
	self.ArtOverlay:SetAlpha(0.4)
end

function Bar:PLAYER_LOGIN()
	-- add art overlay on login
	self:UpdateArt()
	self:UnregisterEvent("PLAYER_LOGIN")
end

function Bar:ACTIVE_TALENT_GROUP_CHANGED()
	self:UpdateArt()
end

function Bar:PLAYER_TALENT_UPDATE()
	self:UpdateArt()
end

function Bar:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

hooksecurefunc(ConsolePort, "LoadBindingSet", function(self, ...)
	if not InCombatLockdown() then
		Lib:UpdateAllBindings(...)
	end
end)


Bar:SetScript("OnEvent", Bar.OnEvent)
Bar:RegisterEvent("PLAYER_LOGIN")
Bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Bar:RegisterEvent("PLAYER_TALENT_UPDATE")

Bar:Execute(format([[
	control:ChildUpdate("state", "action")
	self:RunAttribute("_onstate-page", "%s")
]], now or 1))