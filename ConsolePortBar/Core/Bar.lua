---------------------------------------------------------------
local db = ConsolePort:GetData()
---------------------------------------------------------------
local addOn, ab = ...
---------------------------------------------------------------
local class = select(2, UnitClass("player"))
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()
local UIasset = "Interface\\AddOns\\ConsolePort\\Textures\\UIAsset"


local Bar = CreateFrame("Frame", addOn, UIParent, "SecureHandlerStateTemplate")
local Eye = CreateFrame("Button", "$parentShowHideButtons", Bar, "SecureActionButtonTemplate")
local Menu = CreateFrame("Button", "$parentShowHideMenu", Bar, "SecureActionButtonTemplate")
local Lib = ab.libs.button
local state, now = ConsolePort:GetActionPageDriver()

-- Set up action bar
---------------------------------------------------------------
ab.bar = Bar
---------------------------------------------------------------
Bar:SetAttribute("actionpage", now)
Bar.ignoreNode = true
Bar.Buttons = {}
Bar.isForbidden = true
Bar:SetClampedToScreen(true)
Bar:SetScript("OnMouseDown", Bar.StartMoving)
Bar:SetScript("OnMouseUp", Bar.StopMovingOrSizing)
Bar:SetMovable(true)
Bar:SetPoint("BOTTOM", UIParent, 0, 0)
RegisterStateDriver(Bar, "page", state)
RegisterStateDriver(Bar, "modifier", "[mod:ctrl,mod:shift] CTRL-SHIFT-; [mod:ctrl] CTRL-; [mod:shift] SHIFT-; ")
RegisterStateDriver(Bar, "visibility", "[petbattle][vehicleui][overridebar] hide; show")

Bar:SetFrameRef("ActionBar", MainMenuBarArtFrame)
Bar:SetFrameRef("OverrideBar", OverrideActionBar)

Bar:SetAttribute("_onstate-modifier", [[
	self:SetAttribute("state", newstate)
	control:ChildUpdate("state", newstate)
]])
Bar:SetAttribute("_onstate-page", [[
	if HasVehicleActionBar() then
		newstate = GetVehicleBarIndex()
	elseif HasOverrideActionBar() then
		newstate = GetOverrideBarIndex()
	elseif HasTempShapeshiftActionBar() then
		newstate = GetTempShapeshiftBarIndex()
	elseif GetBonusBarOffset() > 0 then
		newstate = GetBonusBarOffset()+6
	else
		newstate = GetActionBarPage()
	end
	self:SetAttribute("actionpage", newstate)
	control:ChildUpdate("actionpage", newstate)
]])


local layout = {
	["CP_T1"] = {"CENTER", -50, 70},
	["CP_T2"] = {"CENTER", 50, 70},
	---
	["CP_L_GRIP"] = {"LEFT", 160, 10},
	["CP_R_GRIP"] = {"RIGHT", -160, 10},
	---
	["CP_L_LEFT"] 	= {"LEFT", 240, 50},
	["CP_L_RIGHT"] 	= {"LEFT", 400, 50},
	["CP_L_UP"] 	= {"LEFT", 320, 95},
	["CP_L_DOWN"] 	= {"LEFT", 320, 10},
	---
	["CP_R_LEFT"] 	= {"RIGHT", -400, 50},
	["CP_R_RIGHT"] 	= {"RIGHT", -240, 50},
	["CP_R_UP"] 	= {"RIGHT", -320, 95},
	["CP_R_DOWN"] 	= {"RIGHT", -320, 10},
}

for binding in ConsolePort:GetBindings() do
	local button = Lib:Create(Bar, binding)

--	Lib:SetState(button, db.Bindings[binding])

	local position = layout[binding]

	if position then
		button:SetPoint(unpack(position))
	end
	Bar.Buttons[#Bar.Buttons + 1] = button
end

Lib:UpdateAllBindings()

Bar:SetWidth(#Bar.Buttons > 10 and (10 * 110) + 55 or (#Bar.Buttons * 110) + 55)

Bar:SetAttribute("page", 1)


-- this was stolen from Bartender4
do
	-- Hidden parent frame
	local UIHider = CreateFrame("Frame")
	UIHider:Hide()
	Bar.UIHider = UIHider

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

	hooksecurefunc(MainMenuExpBar, "SetStatusBarColor", function(self, r, g, b, a)
		if r ~= red or g ~= green or b ~= blue then
			self:SetStatusBarColor(red, green, blue)
		end
	end)

	MainMenuXPBarTextureMid:SetTexCoord(0, 1, 1, 0)
	MainMenuXPBarTextureLeftCap:SetTexCoord(0.18750000, 0.43750000, 0.26562500, 0.01562500)
	MainMenuXPBarTextureRightCap:SetTexCoord(0.18750000, 0.43750000, 0.54687500, 0.29687500)

	MainMenuXPBarTextureMid:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)
	MainMenuXPBarTextureLeftCap:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)
	MainMenuXPBarTextureRightCap:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)

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

	for i=0, 3 do
		HonorWatchBar.StatusBar["WatchBarTexture"..i]:SetAlpha(0.5)
		HonorWatchBar.StatusBar["XPBarTexture"..i]:SetAlpha(0.5)
	end

	HonorWatchBar:SetParent(Bar)
	HonorWatchBar:ClearAllPoints()
	HonorWatchBar:SetPoint("BOTTOM", 0, 3)

	HonorWatchBar:HookScript("OnShow", function(self) MainMenuExpBar:Hide() end)
	HonorWatchBar:HookScript("OnHide", function(self) MainMenuExpBar:SetShown(UnitLevel("player") < MAX_PLAYER_LEVEL and not IsXPUserDisabled()) end)

	hooksecurefunc(HonorWatchBar, "SetPoint", function(self, anchor, xoffset, yoffset)
		if anchor ~= "BOTTOM" or xoffset ~= 0 or yoffset ~= 3 then
			self:ClearAllPoints()
			self:SetPoint("BOTTOM", 0, 3)
		end
	end)

	ArtifactWatchBar:ClearAllPoints()
	ArtifactWatchBar:SetParent(Bar)
	ArtifactWatchBar:SetPoint("BOTTOM", 0, 16)

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

	-- raid cursor fix to add the hidden action bars to the interface scan process
	ConsolePortRaidCursor:SetFrameRef("hiddenBars", UIHider)
	ConsolePortRaidCursor:Execute([[
		UpdateFrameStack = [=[
			local frames = newtable(self:GetParent():GetChildren())
			frames[#frames + 1] = self:GetFrameRef("hiddenBars")
			for i, frame in pairs(frames) do
				if frame:IsProtected() and not Cache[frame] then
					CurrentNode = frame
					self:Run(GetNodes)
				end
			end
			self:Run(RefreshActions)
			if IsEnabled then
				self:Run(SelectNode, 0)
			end
		]=]
	]])

end

ConsolePort:LoadHotKeyTextures()

local backdrop = {
	edgeFile 	= "Interface\\AddOns\\"..addOn.."\\Textures\\BarEdge",
	edgeSize 	= 32,
	insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
}

Bar:SetBackdrop(backdrop)

Bar.BG = Bar:CreateTexture(nil, "BACKGROUND")
Bar.BG:SetPoint("TOPLEFT", Bar, "TOPLEFT", 16, -16)
Bar.BG:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT", -16, 16)
Bar.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Bar.BG:SetBlendMode("ADD")

Bar.BottomLine = Bar:CreateTexture(nil, "BORDER")
Bar.BottomLine:SetTexture("Interface\\LevelUp\\LevelUpTex")
Bar.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500)
Bar.BottomLine:SetHeight(7)
Bar.BottomLine:SetPoint("BOTTOMLEFT", 0, 16)
Bar.BottomLine:SetPoint("BOTTOMRIGHT", 0, 16)
Bar.BottomLine:SetVertexColor(red, green, blue, 1)


Bar.BG:SetVertexColor(red, green, blue, 0.25)
Bar.BG:SetGradientAlpha("VERTICAL", red, green, blue, 0.25, red, green, blue, 0)

Bar:SetHeight(120)

function Bar:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Bar:OnMouseWheel(delta)
	self:SetScale(self:GetScale() + ( delta * 0.1 ) )
end

hooksecurefunc(ConsolePort, "LoadBindingSet", function(self, ...)
	if not InCombatLockdown() then
		Lib:UpdateAllBindings(...)
	end
end)


Bar:SetScript("OnEvent", Bar.OnEvent)
Bar:SetScript("OnMouseWheel", Bar.OnMouseWheel)
Bar:RegisterEvent("PLAYER_LOGIN")
Bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Bar:RegisterEvent("PLAYER_TALENT_UPDATE")

Bar:Execute(format([[
	control:ChildUpdate("state", "")
	self:RunAttribute("_onstate-page", "%s")
]], now or 1))


Eye:SetAttribute("showbuttons", false)
Eye:SetPoint("BOTTOM", -40, 26)
Eye:SetSize(83.2, 47.2)
Eye:SetNormalTexture(UIasset)
Eye:SetHighlightTexture(UIasset)
Eye.Texture = Eye:CreateTexture(nil, "OVERLAY")
Eye.Texture:SetPoint("CENTER", 0, 2)
Eye.Texture:SetSize(64 * 0.9, 32 * 0.9)
Eye.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Hide")


local normal, highlight = Eye:GetNormalTexture(), Eye:GetHighlightTexture()

normal:SetTexCoord(0.1064, 0.2080, 0.3886, 0.4462)
normal:ClearAllPoints()
normal:SetAllPoints()

highlight:SetTexCoord(0.0009, 0.0937, 0.3896, 0.4365)
highlight:ClearAllPoints()
highlight:SetPoint("LEFT", 3.2, 3.2)
highlight:SetSize(76, 38.4)
highlight:SetAlpha(1)
highlight:SetVertexColor(red, green, blue)

function Eye:OnAttributeChanged(attribute, value)
	if attribute == "showbuttons" then
		if value == true then
			self.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Show")
		else
			self.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Hide")
		end
	end
end

Eye:SetScript("OnAttributeChanged", Eye.OnAttributeChanged)

Bar:WrapScript(Eye, "OnClick", [[
	local showhide = not self:GetAttribute("showbuttons")
	self:SetAttribute("showbuttons", showhide)
	control:ChildUpdate("hover", showhide)
]])


function Menu:OnClick()
	ToggleFrame(GameMenuFrame)
end

Menu:HookScript("OnClick", Menu.OnClick)

Menu:SetPoint("BOTTOM", 40, 26)
Menu:SetSize(83.2, 47.2)
Menu:SetNormalTexture(UIasset)
Menu:SetHighlightTexture(UIasset)

local normal, highlight = Menu:GetNormalTexture(), Menu:GetHighlightTexture()

normal:SetTexCoord(0.2080, 0.1064, 0.3886, 0.4462)
highlight:SetTexCoord(0.0937, 0.0009, 0.3896, 0.4365)
highlight:SetSize(76, 38.4)
highlight:ClearAllPoints()
highlight:SetAlpha(1)
highlight:SetPoint("RIGHT", -3.2, 3.2)
highlight:SetVertexColor(red, green, blue)

local grid = Menu:CreateTexture(nil, "OVERLAY")
grid:SetPoint("CENTER", 0, 2)
grid:SetTexCoord(0.0517, 0.0761, 0.4453, 0.4628)
grid:SetSize(20 * 1.15, 14.4 * 1.15)
grid:SetTexture(UIasset)
grid:SetVertexColor(0.45, 0.45, 0.45)

local gridShadow = Menu:CreateTexture(nil, "ARTWORK")
gridShadow:SetPoint("CENTER", 0, 1)
gridShadow:SetTexCoord(0.0517, 0.0761, 0.4453, 0.4628)
gridShadow:SetSize(20 * 1.15, 14.4 * 1.15)
gridShadow:SetTexture(UIasset)
gridShadow:SetVertexColor(0, 0, 0, 0.5)


Menu.hover = nil
Menu.updateInterval = 0
Menu.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
Menu.newbieText = NEWBIE_TOOLTIP_MAINMENU

Menu:SetScript("OnEnter", function(self)
	self.hover = 1
	self.updateInterval = 0
end)
Menu:SetScript("OnLeave", function(self)
	self.hover = nil
	GameTooltip:Hide()
end)

Menu:SetScript("OnUpdate", function(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	elseif self.hover then
		MainMenuBarPerformanceBarFrame_OnEnter(self)
	end
end)
