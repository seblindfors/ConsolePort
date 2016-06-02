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
local ConsolePort, GameMenuFrame = ConsolePort, GameMenuFrame
---------------------------------------------------------------
local Handler = CreateFrame("Frame", "ConsolePortButtonHandler", ConsolePort, "SecureHandlerStateTemplate")
---------------------------------------------------------------
RegisterStateDriver(Handler, "combat", "[combat] true; nil")
Handler:SetAttribute("_onstate-combat", [[
	control:ChildUpdate("combat", newstate)
]])
---------------------------------------------------------------

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
	self:Show()
	ConsolePort:UIControl(self.command, self.state)
end

---------------------------------------------------------------
-- SecureBtn: Combat reversion functions
---------------------------------------------------------------
local function ClearOverride(self, manualClear)
	self.timer = 0
	self.state = KEY.STATE_UP
	if manualClear then
		self:Hide()
		self:SetAttribute("clickbutton", nil)
	end
end

---------------------------------------------------------------
-- SecureBtn: HotKey textures and indicators
---------------------------------------------------------------
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
local keyClick = {
	[KEY.CROSS] = {"PreClick", PreClick},
	[KEY.CIRCLE] = {"PreClick", PreClick},
	[KEY.SQUARE] = {"PreClick", PreClick},
	[KEY.TRIANGLE] = {"PreClick", PreClick},
}
local keyUpdate = {
	[KEY.UP] = {"OnUpdate", CheckHeldDown},
	[KEY.DOWN] = {"OnUpdate", CheckHeldDown},
	[KEY.LEFT] = {"OnUpdate", CheckHeldDown},
	[KEY.RIGHT] = {"OnUpdate", CheckHeldDown},
}

---------------------------------------------------------------
-- SecureBtn: Button init
---------------------------------------------------------------
function ConsolePort:CreateSecureButton(name, modifier, command)
	local btn 	= CreateFrame("Button", name..modifier, Handler, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
	btn:Hide()
	btn.command = command
	btn.state = KEY.STATE_UP
	btn.timer = 0
	btn.name = name
	btn.mod = modifier
	-----------------------------------------------------------
	btn.HotKeys = {}
	btn.CreateHotKey = ConsolePort.CreateHotKey
	-----------------------------------------------------------
	btn.ShowHotKey = ShowHotKey
	btn.ShowInterfaceHotKey = ShowInterfaceHotKey
	-----------------------------------------------------------
	btn.UIControl = UIControl
	btn.Clear = ClearOverride
	-----------------------------------------------------------
	btn:SetAttribute("_childupdate-combat", [[
		if message then
			self:SetAttribute("clickbutton", nil)
			self:Hide()
			self:CallMethod("Clear")
		end
	]])
	-----------------------------------------------------------
	btn:HookScript("PostClick", PostClick)
	btn:HookScript("OnMouseDown", OnMouseDown)
	btn:HookScript("OnMouseUp", OnMouseUp)
	-----------------------------------------------------------
	local keyClick, keyUpdate = keyClick[command], keyUpdate[command]
	if keyClick then
		btn:SetScript(unpack(keyClick))
	elseif keyUpdate and db.Settings.type ~= "STEAM" then
		btn:SetScript(unpack(keyUpdate))
	end
    db.SECURE[btn] = true
    return btn
end
