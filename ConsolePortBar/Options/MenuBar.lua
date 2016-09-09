local addOn, ab = ...
local db = ConsolePort:GetData()
local Bar = ab.bar
---------------------------------------------------------------
local class = select(2, UnitClass("player"))
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()
-- Set up buttons on the bar.
---------------------------------------------------------------
local Eye = CreateFrame("Button", "$parentShowHideButtons", Bar, "SecureActionButtonTemplate")
local Menu = CreateFrame("Button", "$parentShowHideMenu", Bar, "SecureActionButtonTemplate")
local UIasset = "Interface\\AddOns\\ConsolePort\\Textures\\UIAsset"

Bar.Eye = Eye
Bar.Menu = Menu

Bar:SetBackdrop(backdrop)

---------------------------------------------------------------
---------------------------------------------------------------
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
---------------------------------------------------------------
---------------------------------------------------------------

---------------------------------------------------------------
-- Toggler for buttons and art
---------------------------------------------------------------
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
		ab.cfg.showbuttons = value
		if value == true then
			self.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Show")
		else
			self.Texture:SetTexture("Interface\\AddOns\\"..addOn.."\\Textures\\Hide")
		end
	end
end

function Eye:OnClick(button, down)
	if button == "RightButton" then
		if not ab.cfg.artMode then
			ab.cfg.artMode = 1
		elseif ab.cfg.artMode ~= 2 then
			ab.cfg.artMode = 2
		else
			ab.cfg.artMode = nil
		end

		if ab.cfg.artMode == 1 then
			Bar.CoverArt:SetSize(1024, 256)
		elseif ab.cfg.artMode == 2 then
			Bar.CoverArt:SetSize(768, 192)
		end

		Bar.CoverArt:SetShown(ab.cfg.artMode)
	elseif button == "LeftButton" then
		if IsShiftKeyDown() then
			ab.cfg.lock = not ab.cfg.lock
			if ab.cfg.lock then
				Bar:SetMovable(false)
				Bar:SetScript("OnMouseDown", nil)
				Bar:SetScript("OnMouseUp", nil)
			else
				Bar:SetMovable(true)
				Bar:SetScript("OnMouseDown", Bar.StartMoving)
				Bar:SetScript("OnMouseUp", Bar.StopMovingOrSizing)
			end
			self:OnEnter()
		elseif IsControlKeyDown() and not InCombatLockdown() then
			Bar:ClearAllPoints()
			Bar:SetPoint("BOTTOM", UIParent, 0, 0)
		end
	end
end

function Eye:OnEnter()
	local texture_esc = "|T%s:24:24:0:0|t"
	self.tooltipText = 	format(db.ACTIONBAR.EYE_HEADER, ab.cfg.lock and db.ACTIONBAR.EYE_LOCKED or db.ACTIONBAR.EYE_UNLOCKED) .. "\n" ..
						format(db.ACTIONBAR.EYE_LEFTCLICK, format(texture_esc, db.ICONS.CP_T_L3)) .. "\n" ..
						format(db.ACTIONBAR.EYE_RIGHTCLICK, format(texture_esc, db.ICONS.CP_T_R3)) .. "\n" ..
						format(db.ACTIONBAR.EYE_LEFTCLICK_SHIFT, format(texture_esc, db.ICONS.CP_M1), format(texture_esc, db.ICONS.CP_T_L3)) .. "\n" ..
						format(db.ACTIONBAR.EYE_LEFTCLICK_CTRL, format(texture_esc, db.ICONS.CP_M2), format(texture_esc, db.ICONS.CP_T_L3)) .. "\n" ..
						db.ACTIONBAR.EYE_SCROLL .. "\n" ..
						db.ACTIONBAR.EYE_SCROLL_SHIFT
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
	if button == "LeftButton" and bar:GetAttribute("state") == "" then
		local showhide = not self:GetAttribute("showbuttons")
		self:SetAttribute("showbuttons", showhide)
		control:ChildUpdate("hover", showhide)
	end
]])

---------------------------------------------------------------
-- Menu button
---------------------------------------------------------------

function Menu:OnClick()
	if not InCombatLockdown() then
		ToggleFrame(GameMenuFrame)
	end
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

