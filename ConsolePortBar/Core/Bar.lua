---------------------------------------------------------------
local db = ConsolePort:GetData()
---------------------------------------------------------------
local addOn, ab = ...
---------------------------------------------------------------
local cfg

local Bar = CreateFrame("Frame", addOn, UIParent, "SecureHandlerStateTemplate, SecureHandlerShowHideTemplate")
local Wrapper = ab.libs.wrapper
local state, now = ConsolePort:GetActionPageDriver()

local BAR_MIN_WIDTH = 1085
local BAR_MAX_SCALE = 1.6

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
	bar = self
	cursor = self:GetFrameRef("Cursor")
	mouse = self:GetFrameRef("Mouse")
	self:SetAttribute("state", "")
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
		ab.cfg = cfg

		self:SetScale(cfg.scale or 1)

		if cfg.artMode == 1 then
			self.CoverArt:SetSize(1024, 256)
		elseif cfg.artMode == 2 then
			self.CoverArt:SetSize(768, 192)
		else
			self.CoverArt:Hide()
		end

		if cfg.showbuttons then
			self.Eye:SetAttribute("showbuttons", true)
			Bar:Execute([[
				control:ChildUpdate("hover", true)
			]])
		end

		if cfg.lock then
			Bar:SetMovable(false)
			Bar:SetScript("OnMouseDown", nil)
			Bar:SetScript("OnMouseUp", nil)
		end

		if cfg.width then
			self:SetWidth(cfg.width)
		end

		self:UnregisterEvent("ADDON_LOADED")
	end
end

function Bar:OnMouseWheel(delta)
	if not InCombatLockdown() then
		if IsShiftKeyDown() then
			local newWidth = self:GetWidth() + ( delta * 10 )
			cfg.width = newWidth > BAR_MIN_WIDTH and newWidth or BAR_MIN_WIDTH
			self:SetWidth(cfg.width)
		else
			local newScale = self:GetScale() + ( delta * 0.1 )
			if newScale > BAR_MAX_SCALE then cfg.scale = BAR_MAX_SCALE
			elseif newScale <= 0 then cfg.scale = 0.1
			else cfg.scale = newScale end
			self:SetScale(cfg.scale)
		end
	end
end

Bar:SetScript("OnEvent", Bar.OnEvent)
Bar:SetScript("OnMouseWheel", Bar.OnMouseWheel)
Bar:RegisterEvent("PLAYER_LOGIN")
Bar:RegisterEvent("ADDON_LOADED")
Bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Bar:RegisterEvent("PLAYER_TALENT_UPDATE")

local layout = {
	["CP_T1"] = {point = {"LEFT", 440, 64}, dir = "right"},
	["CP_T2"] = {point = {"RIGHT", -440, 64}, dir = "left"},
	---
	["CP_L_GRIP"] = {point = {"LEFT", 390, 110}, dir = "up"},
	["CP_R_GRIP"] = {point = {"RIGHT", -390, 110}, dir = "up"},
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
	local wrapper = Wrapper:Create(Bar, binding, position and position.dir or "down")

	if position then
		wrapper:SetPoint(unpack(position.point))
	end
	Bar.Buttons[#Bar.Buttons + 1] = wrapper
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