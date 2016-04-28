---------------------------------------------------------------
-- Secure.lua: Secure action button management 
---------------------------------------------------------------
-- Creates all secure action buttons used by the addon.
-- These buttons are also used to bind UI widgets, since
-- direct "clicking" causes taint to spread in a lot of cases.
-- These buttons are under-the-hood and invisible to the user.

local _, db = ...
local TEXTURE = db.TEXTURE
local KEY = db.KEY
---------------------------------------------------------------
local ConsolePort = ConsolePort
local GameMenuFrame = GameMenuFrame
---------------------------------------------------------------

---------------------------------------------------------------
-- SecureBtn: Actionpage state handler (hardly useful anymore)
---------------------------------------------------------------
function ConsolePort:CreateButtonHandler()
	local ButtonHandler = CreateFrame("Frame", "ConsolePortButtonHandler", ConsolePort, "SecureHandlerStateTemplate")
	ButtonHandler:Execute([[
		SecureButtons = newtable()
	]])
	ButtonHandler:SetAttribute("pageupdate", [[
		local page = ...
		self:SetAttribute("actionpage", page)
		for btn in pairs(SecureButtons) do
			btn:SetAttribute("actionpage", page)
		end
	]])
	self:RegisterActionPage(ButtonHandler)
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

local function ShowHotKey(button, index, actionButton)
	local HotKey = button.HotKeys[index]
	HotKey:SetParent(actionButton)
	HotKey:ClearAllPoints()
	HotKey:SetPoint("TOPRIGHT", actionButton, 0, 0)
	HotKey:Show()
end

local function ShowInterfaceHotKey(button, custom, forceStyle)
	for i, HotKey in pairs(button.HotKeys) do
		HotKey:Hide()
	end
	button.HotKeys[1] = button.HotKeys[1] or button:CreateHotKey(forceStyle)
	ShowHotKey(button, 1, custom or button.action)
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
	btn.default = {}
	-----------------------------------------------------------
	btn.HotKey 		= GetHotKeyTexture(btn)
	btn.HotKeys 	= {}
	btn.CreateHotKey = ConsolePort.CreateHotKey
	-----------------------------------------------------------
	btn.ShowHotKey 	= ShowHotKey
	btn.ShowInterfaceHotKey = ShowInterfaceHotKey
	-----------------------------------------------------------
	btn.UIControl 	= UIControl
	btn.Reset 		= ResetBinding
	btn.Revert 		= RevertBinding
	-----------------------------------------------------------
	btn:Reset()
	btn:Revert()
	btn:SetAttribute("actionpage", ConsolePortButtonHandler:GetAttribute("actionpage"))
	btn:RegisterEvent("PLAYER_REGEN_DISABLED")
	-----------------------------------------------------------
	btn:SetScript("OnEvent", btn.Revert)
	btn:HookScript("PostClick", PostClick)
	btn:HookScript("OnMouseDown", OnMouseDown)
	btn:HookScript("OnMouseUp", OnMouseUp)
	-----------------------------------------------------------
	if 		ConsolePortSettings.type ~= "STEAM" and
			(btn.command == KEY.UP or
			btn.command == KEY.DOWN or
			btn.command == KEY.LEFT or
			btn.command == KEY.RIGHT) then
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
