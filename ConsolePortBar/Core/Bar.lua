---------------------------------------------------------------
local db = ConsolePort:GetData()
---------------------------------------------------------------
local addOn, ab = ...
---------------------------------------------------------------
local cfg
---------------------------------------------------------------
local class = select(2, UnitClass("player"))
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()
local UIasset = "Interface\\AddOns\\ConsolePort\\Textures\\UIAsset"


local Bar = CreateFrame("Frame", addOn, UIParent, "SecureHandlerStateTemplate, SecureHandlerShowHideTemplate")
local Eye = CreateFrame("Button", "$parentShowHideButtons", Bar, "SecureActionButtonTemplate")
local Menu = CreateFrame("Button", "$parentShowHideMenu", Bar, "SecureActionButtonTemplate")
local Wrapper = ab.libs.wrapper
local state, now = ConsolePort:GetActionPageDriver()

-- Set up action bar
---------------------------------------------------------------
ab.bar = Bar
ab.data = db
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
Bar:SetFrameRef("Cursor", ConsolePortRaidCursor)
Bar:SetFrameRef("Mouse", ConsolePortMouseHandle)
Bar:Execute([[
	bindings = newtable()
	cursor = self:GetFrameRef("Cursor")
	mouse = self:GetFrameRef("Mouse")
]])

Bar:SetAttribute("_onhide", [[
	self:ClearBindings()
]])

Bar:SetAttribute("_onshow", [[
	for key, button in pairs(bindings) do
		self:SetBindingClick(true, key, button)
	end
	mouse:RunAttribute("UpdateTarget", mouse:GetAttribute("current"))
	self:CallMethod("FadeIn")
]])

function Bar:FadeIn()
	db.UIFrameFadeIn(self, 1, 0, 1)
end

function Bar:UnregisterOverrides()
	self:Execute([[
		bindings = wipe(bindings)
		self:ClearBindings()
	]])
end

function Bar:UpdateOverrides()
	self:Execute([[
		for key, button in pairs(bindings) do
			self:SetBindingClick(true, key, button)
		end
	]])
end

function Bar:RegisterOverride(key, button)
	self:Execute(format([[
		bindings["%s"] = "%s"
	]], key, button))
end

Bar:SetAttribute("_onstate-modifier", [[
	self:SetAttribute("state", newstate)
	control:ChildUpdate("state", newstate)
	cursor:RunAttribute("pageupdate")
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

local art, coords = ab:GetCover()
if art and coords then
	Bar.CoverArt = Bar:CreateTexture(nil, "BACKGROUND")
	Bar.CoverArt:SetPoint("BOTTOM", 0, 16)
	Bar.CoverArt:SetSize(1024, 256)
	Bar.CoverArt:SetTexture(art)
	Bar.CoverArt:SetTexCoord(unpack(coords))
end

local gBase = 0.15
local gMulti = 1.2
local startAlpha = 0.25
local endAlpha = 0
local classGradient = {
	"VERTICAL",
	(red + gBase) * gMulti, (green + gBase) * gMulti, (blue + gBase) * gMulti, startAlpha,
	1 - (red + gBase) * gMulti, 1 - (green + gBase) * gMulti, 1 - (blue + gBase) * gMulti, endAlpha,
}

Bar.BG:SetGradientAlpha(unpack(classGradient))

Bar:SetHeight(140)

function Bar:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Bar:ADDON_LOADED(...)
	local name = ...
	if name == addOn then
		if not ConsolePortBarSetup then
			ConsolePortBarSetup = {
				scale = 1,
				artMode = 1,
			}
		end
		cfg = ConsolePortBarSetup

		self:SetScale(cfg.scale or 1)

		if cfg.artMode == 1 then
			self.CoverArt:SetSize(1024, 256)
		elseif cfg.artMode == 2 then
			self.CoverArt:SetSize(768, 192)
		else
			self.CoverArt:Hide()
		end

		if cfg.showbuttons then
			Eye:SetAttribute("showbuttons", true)
			Bar:Execute([[
				control:ChildUpdate("hover", true)
			]])
		end

		self:UnregisterEvent("ADDON_LOADED")
	end
end

function Bar:OnMouseWheel(delta)
	if not InCombatLockdown() then
		cfg.scale = self:GetScale() + ( delta * 0.1 )
		self:SetScale(cfg.scale)
	end
end

Bar:SetScript("OnEvent", Bar.OnEvent)
Bar:SetScript("OnMouseWheel", Bar.OnMouseWheel)
Bar:RegisterEvent("PLAYER_LOGIN")
Bar:RegisterEvent("ADDON_LOADED")
Bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Bar:RegisterEvent("PLAYER_TALENT_UPDATE")

local layout = {
	["CP_T1"] = {point = {"CENTER", -110, 64}, dir = "right"},
	["CP_T2"] = {point = {"CENTER", 110, 64}, dir = "left"},
	---
	["CP_L_GRIP"] = {point = {"CENTER", -160, 120}, dir = "up"},
	["CP_R_GRIP"] = {point = {"CENTER", 160, 120}, dir = "up"},
	---
	["CP_L_LEFT"] 	= {point = {"LEFT", 255 - 80, 50 + 14}, dir = "left"},
	["CP_L_RIGHT"] 	= {point = {"LEFT", 385 - 80, 50 + 14}, dir = "right"},
	["CP_L_UP"] 	= {point = {"LEFT", 320 - 80, 95 + 14}, dir = "up"},
	["CP_L_DOWN"] 	= {point = {"LEFT", 320 - 80, 10 + 14}, dir = "down"},
	---
	["CP_R_LEFT"] 	= {point = {"RIGHT", -385 + 80, 50 + 14}, dir = "left"},
	["CP_R_RIGHT"] 	= {point = {"RIGHT", -255 + 80, 50 + 14}, dir = "right"},
	["CP_R_UP"] 	= {point = {"RIGHT", -320 + 80, 95 + 14}, dir = "up"},
	["CP_R_DOWN"] 	= {point = {"RIGHT", -320 + 80, 10 + 14}, dir = "down"},
}

for binding in ConsolePort:GetBindings() do
	local position = layout[binding]
	local button = Wrapper:Create(Bar, binding, position and position.dir or "down")

	if position then
		button:SetPoint(unpack(position.point))
	end
	Bar.Buttons[#Bar.Buttons + 1] = button
end

Wrapper:UpdateAllBindings()
Bar:Hide()
Bar:Show()

hooksecurefunc(ConsolePort, "OnNewBindings", function(self, ...)
	if not InCombatLockdown() then
		Bar:UnregisterOverrides()
		Wrapper:UpdateAllBindings(...)
		Bar:UpdateOverrides()
	end
end)

Bar:SetAttribute("page", 1)

Bar:Execute(format([[
	control:ChildUpdate("state", "")
	self:RunAttribute("_onstate-page", "%s")
]], now or 1))


Bar:SetWidth(#Bar.Buttons > 10 and (10 * 110) + 55 or (#Bar.Buttons * 110) + 55)


-- Set up buttons on the bar.
---------------------------------------------------------------

-- Toggler for buttons and art
local sz = .8

Eye:RegisterForClicks("AnyUp")
Eye:SetAttribute("showbuttons", false)
Eye:SetPoint("BOTTOMLEFT", 70, 30)
Eye:SetSize(83.2 * sz, 47.2 * sz)
Eye:SetNormalTexture(UIasset)
Eye:SetHighlightTexture(UIasset)
Eye.Texture = Eye:CreateTexture(nil, "OVERLAY")
Eye.Texture:SetPoint("CENTER", 0, 2)
Eye.Texture:SetSize((64 * 0.9) * sz, (32 * 0.9) * sz)
Eye.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Hide") 


local normal, highlight = Eye:GetNormalTexture(), Eye:GetHighlightTexture()

normal:SetTexCoord(0.1064, 0.2080, 0.3886, 0.4462)
normal:ClearAllPoints()
normal:SetAllPoints()

highlight:SetTexCoord(0.0009, 0.0937, 0.3896, 0.4365)
highlight:ClearAllPoints()
highlight:SetPoint("LEFT", 3.2, 3.2)
highlight:SetSize(76 * sz, 38.4 * sz)
highlight:SetAlpha(1)
highlight:SetVertexColor(red, green, blue)

function Eye:OnAttributeChanged(attribute, value)
	if attribute == "showbuttons" then
		cfg.showbuttons = value
		if value == true then
			self.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Show")
		else
			self.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Hide")
		end
	end
end

function Eye:OnClick(button, down)
	if button == "RightButton" then
		if not cfg.artMode then
			cfg.artMode = 1
		elseif cfg.artMode ~= 2 then
			cfg.artMode = 2
		else
			cfg.artMode = nil
		end

		if cfg.artMode == 1 then
			Bar.CoverArt:SetSize(1024, 256)
		elseif cfg.artMode == 2 then
			Bar.CoverArt:SetSize(768, 192)
		end

		Bar.CoverArt:SetShown(cfg.artMode)
	end
end

function Eye:OnEnter()
	if not self.tooltipText then
		local texture_esc = "|T%s:24:24:0:0|t"
		self.tooltipText = 	format(db.ACTIONBAR.EYE_LEFTCLICK, format(texture_esc, db.ICONS.CP_T_L3)) .. "\n" ..
							format(db.ACTIONBAR.EYE_RIGHTCLICK, format(texture_esc, db.ICONS.CP_T_R3)) .. "\n" ..
							db.ACTIONBAR.EYE_SCROLL
	end
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText(self.tooltipText)
	GameTooltip:Show()
end

function Eye:OnLeave()
	GameTooltip:Hide()
end

Eye:SetScript("OnClick", Eye.OnClick)
Eye:SetScript("OnEnter", Eye.OnEnter)
Eye:SetScript("OnLeave", Eye.OnLeave)
Eye:SetScript("OnAttributeChanged", Eye.OnAttributeChanged)

Bar:WrapScript(Eye, "OnClick", [[
	if button == "LeftButton" then
		local showhide = not self:GetAttribute("showbuttons")
		self:SetAttribute("showbuttons", showhide)
		control:ChildUpdate("hover", showhide)
	end
]])

-- Menu button

function Menu:OnClick()
	ToggleFrame(GameMenuFrame)
end

Menu:HookScript("OnClick", Menu.OnClick)

Menu:SetPoint("LEFT", Eye, "RIGHT", 0, 0)
Menu:SetSize(83.2 * sz, 47.2 * sz)
Menu:SetNormalTexture(UIasset)
Menu:SetHighlightTexture(UIasset)

local normal, highlight = Menu:GetNormalTexture(), Menu:GetHighlightTexture()

normal:SetTexCoord(0.2080, 0.1064, 0.3886, 0.4462)
highlight:SetTexCoord(0.0937, 0.0009, 0.3896, 0.4365)
highlight:SetSize(76 * sz, 38.4 * sz)
highlight:ClearAllPoints()
highlight:SetAlpha(1)
highlight:SetPoint("RIGHT", -3.2, 3.2)
highlight:SetVertexColor(red, green, blue)

local grid = Menu:CreateTexture(nil, "OVERLAY")
grid:SetPoint("CENTER", 0, 2)
grid:SetTexCoord(0.0517, 0.0761, 0.4453, 0.4628)
grid:SetSize((20 * 1.15) * sz, (14.4 * 1.15) * sz) 
grid:SetTexture(UIasset)
grid:SetVertexColor(0.45, 0.45, 0.45)

local gridShadow = Menu:CreateTexture(nil, "ARTWORK")
gridShadow:SetPoint("CENTER", 0, 1)
gridShadow:SetTexCoord(0.0517, 0.0761, 0.4453, 0.4628)
gridShadow:SetSize((20 * 1.15) * sz, (14.4 * 1.15) * sz)
gridShadow:SetTexture(UIasset)
gridShadow:SetVertexColor(0, 0, 0, 0.5)


Menu.timer = 0
Menu.updateInterval = 1
Menu.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
Menu.newbieText = NEWBIE_TOOLTIP_MAINMENU

function Menu:ShowPerformance(elapsed)
	self.timer = self.timer + elapsed
	if self.timer > self.updateInterval then
		MainMenuBarPerformanceBarFrame_OnEnter(self)
		self.timer = 0
	end
end

Menu:SetScript("OnEnter", function(self)
	local key, mod = ConsolePort:GetCurrentBindingOwner("TOGGLEGAMEMENU")
	if key and mod then
		local mods = {
			[""] = "",
			["SHIFT-"] = BINDING_NAME_CP_M1,
			["CTRL-"] = BINDING_NAME_CP_M2,
			["CTRL-SHIFT-"] = BINDING_NAME_CP_M1..BINDING_NAME_CP_M2,
		}
		self.tooltipText = mods[mod].._G["BINDING_NAME_"..key].."  |c"..RAID_CLASS_COLORS[class].colorStr..MAINMENU_BUTTON
	else
		self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
	end
	MainMenuBarPerformanceBarFrame_OnEnter(self)
	self.timer = 0
	self:SetScript("OnUpdate", self.ShowPerformance)
end)

Menu:SetScript("OnLeave", function(self)
	self:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end)

