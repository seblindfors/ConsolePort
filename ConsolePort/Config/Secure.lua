---------------------------------------------------------------
-- Secure.lua: Secure action button management 
---------------------------------------------------------------
-- Creates all secure action buttons used by the addon.
-- These buttons are also used to bind UI widgets, since
-- direct "clicking" causes taint to spread in a lot of cases.
-- These buttons are under-the-hood and invisible to the user.

local addOn, db = ...
local TEXTURE = db.TEXTURE
local KEY = db.KEY
---------------------------------------------------------------
local ConsolePort = ConsolePort
local GameMenuFrame = GameMenuFrame
---------------------------------------------------------------
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
---------------------------------------------------------------

---------------------------------------------------------------
-- Get current action page and an optional statedriver string
---------------------------------------------------------------
function ConsolePort:GetActionPageState()
	local state = {}
	tinsert(state, "[overridebar][possessbar]possess")
	for i = 2, 6 do
		tinsert(state, ("[bar:%d]%d"):format(i, i))
	end
	for i = 1, 4 do
		tinsert(state, ("[bonusbar:%d]%d"):format(i, i+6))
	end
	tinsert(state, "[stance:1]tempshapeshift")
	tinsert(state, "1")
	state = table.concat(state, ";")
	local now = SecureCmdOptionParse(state)
	return now, state
end

---------------------------------------------------------------
-- SecureBtn: Actionpage state handler (hardly useful anymore)
---------------------------------------------------------------
function ConsolePort:CreateButtonHandler()
	local ButtonHandler = CreateFrame("Frame", addOn.."ButtonHandler", ConsolePort, "SecureHandlerStateTemplate")
	ButtonHandler:Execute([[
		SecureButtons = newtable()
		UpdateActionPage = [=[
			local page = ...
			if page == "tempshapeshift" then
				if HasTempShapeshiftActionBar() then
					page = GetTempShapeshiftBarIndex()
				else
					page = 1
				end
			elseif page == "possess" then
				page = self:GetFrameRef("MainMenuBarArtFrame"):GetAttribute("actionpage") or 1
				if  page <= 10 then
					page = self:GetFrameRef("OverrideActionBar"):GetAttribute("actionpage") or 12
				end
				if  page <= 10 then
					page = 12
				end
			end
			self:SetAttribute("actionpage", page)
			for btn in pairs(SecureButtons) do
				btn:SetAttribute("actionpage", page)
			end
		]=]
	]])
	ButtonHandler:SetFrameRef("MainMenuBarArtFrame", MainMenuBarArtFrame)
	ButtonHandler:SetFrameRef("OverrideActionBar", OverrideActionBar)

	local now, state = self:GetActionPageState()

	ButtonHandler:SetAttribute("actionpage", now)
	RegisterStateDriver(ButtonHandler, "page", state)
	ButtonHandler:Execute([[
		self:Run(UpdateActionPage, self:GetAttribute("actionpage"))
	]])
	ButtonHandler:SetAttribute("_onstate-page", [=[
		self:Run(UpdateActionPage, newstate)
	]=])
	self.CreateButtonHandler = nil
end

---------------------------------------------------------------
-- SecureBtn: Input scripts 
---------------------------------------------------------------
local function OnMouseDown(self, button)
	local func = self:GetAttribute("type")
	local click = self:GetAttribute("clickbutton")
	self.state = KEY.STATE_DOWN
	self.timer = 0
	if 	(func == "click" or func == "action") and click then
		click:SetButtonState("PUSHED")
		return
	end
	-- Fire function twice where keystate is requested
	if 	self[func] then self[func](self) end
end

local function OnMouseUp(self, button)
	local func = self:GetAttribute("type")
	local click = self:GetAttribute("clickbutton")
	self.state = KEY.STATE_UP
	if 	(func == "click" or func == "action") and click then
		click:SetButtonState("NORMAL")
	end
end

local function CheckHeldDown(self, elapsed)
	self.timer = self.timer + elapsed
	if self.timer >= 0.125 and self.state == KEY.STATE_DOWN then
		local func = self:GetAttribute("type")
		if func and func ~= "action" and self[func] then self[func](self) end
		self.timer = 0
	end
end

local function PreClick(self)
	if GameMenuFrame:IsVisible() then
		local clickbutton = self:GetAttribute("clickbutton")
		if not (clickbutton and clickbutton.ignoreMenu) then 
			ToggleFrame(GameMenuFrame)
		end
	end
end

local function PostClick(self)
	local click = self:GetAttribute("clickbutton")
	if click and not click:IsEnabled() then
		self:SetAttribute("clickbutton", nil)
	end
end

---------------------------------------------------------------
-- SecureBtn: Global frame references
---------------------------------------------------------------
local function UIControl(self)
	ConsolePort:UIControl(self.command, self.state)
end

---------------------------------------------------------------
-- SecureBtn: Combat reversion functions
---------------------------------------------------------------
local function RevertBinding(self)
	self:SetAttribute("type", self.default.type)
	self:SetAttribute(self.default.attr, self.default.val)
	self:SetAttribute("clickbutton", self.action)
end

local function ResetBinding(self)
	self.default = {
			type = "click",
			attr = "clickbutton",
			val  = self.action
	}
end

---------------------------------------------------------------
-- SecureBtn: HotKey textures and indicators
---------------------------------------------------------------
local function GetHotKeyTexture(button)
	local texFile = TEXTURE[button.name]
	local texture = "|T%s:14:14:%s:0|t" -- texture, offsetX
	local plain = format(texture, texFile, 3)
	local mods = {
		_NOMOD = plain,
		_SHIFT = format(texture, TEXTURE.CP_TL1, 7)..plain,
		_CTRL = format(texture, TEXTURE.CP_TL2, 7)..plain,
		_CTRLSH = format(strrep(texture, 2), TEXTURE.CP_TL1, 11, TEXTURE.CP_TL2, 7)..plain,
	}
	return mods[button.mod]
end

local function OnModifierChanged(self)
	local ctrl, shift = IsControlKeyDown(), IsShiftKeyDown()
	if self.mod == "_NOMOD" then
		if shift or ctrl then
			self:Hide()
		else
			self:Show()
		end
	else
		self:Show()
		if 	self.mod == "_CTRLSH" and (ctrl and shift) or
			self.mod == "_CTRL" and (ctrl and not shift) or
			self.mod == "_SHIFT" and (shift and not ctrl) then
			self.mod1:Hide()
			if self.mod2 then
				self.mod2:Hide()
			end
			self:ClearAllPoints()
			self:SetPoint("TOP", 0, 12)
			self.main:ClearAllPoints()
			self.main:SetPoint("TOP", 0, 0)
			self.main.Group:Play()
		elseif self.mod == "_CTRLSH" and (ctrl or shift) or
			self.mod == "_CTRL" and shift or
			self.mod == "_SHIFT" and ctrl then
			self:Hide()
		else
			self.mod1:Show()
			if self.mod2 then
				self.mod2:Show()
			end
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", 0, 0)
			self.main:ClearAllPoints()
			self.main:SetPoint("TOPRIGHT", 12, 12)
		end
	end
end

local function CreateHotKey(self)
	local hotKey = CreateFrame("Frame", "$parent_HOTKEY"..#self.HotKeys+1, self)
	hotKey:SetSize(1,1)
	hotKey.mod = self.mod
	hotKey:SetScript("OnEvent", OnModifierChanged)
	hotKey:RegisterEvent("MODIFIER_STATE_CHANGED")

	local main = hotKey:CreateTexture("$parent_MAIN", "OVERLAY", nil, 7)
	hotKey.main = main
	main:SetSize(32, 32)
	main:SetTexture(gsub(TEXTURE[self.name], "Icons64x64", "Icons32x32"))
	main:SetPoint("TOPRIGHT", 12, 12)

	main.Group = main:CreateAnimationGroup()
	main.Group:SetScript("OnFinished", function() main:SetSize(32, 32) end)
	main.Group:SetScript("OnPlay", function() main:SetSize(64, 64) end)
	main.Animation = main.Group:CreateAnimation("SCALE")

	main.Animation:SetScale(0.5, 0.5)
	main.Animation:SetDuration(0.2)
	main.Animation:SetSmoothing("OUT")
	main.Animation:SetOrigin("TOP", 0, 0)

	if self.mod ~= "_NOMOD" then
		local mod1 = hotKey:CreateTexture("$parent_MOD1", "OVERLAY", nil, 6)
		hotKey.mod1 = mod1
		mod1:SetPoint("RIGHT", main, "LEFT", 14, -2)
		mod1:SetSize(24, 24)

		if self.mod == "_SHIFT" then
			mod1:SetTexture(gsub(TEXTURE.CP_TL1, "Icons64x64", "Icons32x32"))
		elseif self.mod == "_CTRL" then
			mod1:SetTexture(gsub(TEXTURE.CP_TL2, "Icons64x64", "Icons32x32"))
		elseif self.mod == "_CTRLSH" then
			mod1:SetTexture(gsub(TEXTURE.CP_TL2, "Icons64x64", "Icons32x32"))
			mod1:SetPoint("RIGHT", main, "LEFT", 15, -2)

			local mod2 = hotKey:CreateTexture("$parent_MOD2", "OVERLAY", nil, 5)
			hotKey.mod2 = mod2
			mod2:SetPoint("RIGHT", mod1, "LEFT", 14, 0)
			mod2:SetSize(24, 24)
			mod2:SetTexture(gsub(TEXTURE.CP_TL1, "Icons64x64", "Icons32x32"))
		end
	end

	return hotKey
end

---------------------------------------------------------------
-- SecureBtn: Mock ActionBar button init
---------------------------------------------------------------
function ConsolePort:CreateSecureButton(name, modifier, clickbutton, UIcommand)
	local btn 	= CreateFrame("Button", name..modifier, nil, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
	btn.name 	= name
	btn.timer 	= 0
	btn.state 	= KEY.STATE_UP
	btn.action 	= _G[clickbutton]
	btn.command = UIcommand
	btn.mod 	= modifier
	btn.HotKey 	= GetHotKeyTexture(btn)
	btn.HotKeys = {}
	btn.default = {}
	btn.CreateHotKey = CreateHotKey
	btn.UIControl 	= UIControl
	btn.Reset 		= ResetBinding
	btn.Revert 		= RevertBinding
	btn:Reset()
	btn:Revert()
	btn:SetAttribute("actionpage", ConsolePortButtonHandler:GetAttribute("actionpage"))
	btn:RegisterEvent("PLAYER_REGEN_DISABLED")
	btn:SetScript("OnEvent", btn.Revert)
	btn:HookScript("PostClick", PostClick)
	btn:HookScript("OnMouseDown", OnMouseDown)
	btn:HookScript("OnMouseUp", OnMouseUp)
	if 		btn.command == KEY.UP or
			btn.command == KEY.DOWN or
			btn.command == KEY.LEFT or
			btn.command == KEY.RIGHT then
		btn:SetScript("OnUpdate", CheckHeldDown)
	elseif 	btn.command == KEY.CROSS or
			btn.command == KEY.CIRCLE or
			btn.command == KEY.SQUARE or
			btn.command == KEY.TRIANGLE then
		btn:SetScript("PreClick", PreClick)
	end
	ConsolePortButtonHandler:SetFrameRef("NewButton", btn)
	ConsolePortButtonHandler:Execute([[
        SecureButtons[self:GetFrameRef("NewButton")] = true
    ]])
    db.SECURE[btn] = true
end
