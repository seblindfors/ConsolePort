---------------------------------------------------------------
-- Secure.lua: Secure action button management 
---------------------------------------------------------------
-- Creates all secure action buttons used by the addon.
-- These buttons are also used to bind UI widgets, since
-- direct 'clicking' causes taint to spread in a lot of cases.
-- These buttons are under-the-hood and invisible to the user.

local _, db = ...
local KEY = db.KEY
---------------------------------------------------------------
local 	ConsolePort, Button, Handler = 
		ConsolePort, {}, CreateFrame('Frame', 'ConsolePortButtonHandler', ConsolePort, 'SecureHandlerStateTemplate')
---------------------------------------------------------------
RegisterStateDriver(Handler, 'combat', '[combat] true; nil')
Handler:SetAttribute('_onstate-combat', [[
	control:ChildUpdate('combat', newstate)
]])
---------------------------------------------------------------

-- Input scripts
---------------------------------------------------------------
function Button:OnMouseDown()
	local func = self:GetAttribute('type')
	local click = self:GetAttribute('clickbutton')
	self.state = KEY.STATE_DOWN
	self.timer = 0
	-- simulate button clicks by setting pushed state on focused button
	if 	(func == 'click' or func == 'action') and click then
		click:SetButtonState('PUSHED')
		return
	end
	-- Fire function twice where keystate is requested
	if 	self[func] then self[func](self) end
end

function Button:OnMouseUp()
	local func = self:GetAttribute('type')
	local click = self:GetAttribute('clickbutton')
	self.state = KEY.STATE_UP
	-- revert simulated button click
	if 	(func == 'click' or func == 'action') and click then
		click:SetButtonState('NORMAL')
	end
end

function Button:PostClick()
	local click = self:GetAttribute('clickbutton')
	if click and not click:IsEnabled() then
		self:SetAttribute('clickbutton', nil)
	end
end

-- Run UI control 
---------------------------------------------------------------
function Button:UIControl()
	self:Show()
	ConsolePort:UIControl(self.command, self.state)
end

-- Clear button override
---------------------------------------------------------------
function Button:Clear(manualClear)
	self.timer = 0
	self.state = KEY.STATE_UP
	if manualClear then
		self:Hide()
		self:SetAttribute('clickbutton', nil)
	end
end

-- HotKey textures and indicators
---------------------------------------------------------------
function Button:ShowHotKey(index, actionButton)
	local HotKey = self.HotKeys[index]
	HotKey:SetParent(actionButton)
	HotKey:ClearAllPoints()
	HotKey:SetPoint('TOPRIGHT', actionButton, 0, 0)
	HotKey:Show()
end

function Button:ShowInterfaceHotKey(custom, forceStyle)
	for i, HotKey in pairs(self.HotKeys) do
		HotKey:Hide()
	end
	self.HotKeys[1] = self.HotKeys[1] or self:CreateHotKey(forceStyle)
	self:ShowHotKey(1, custom or self.action)
end

---------------------------------------------------------------

-- Variables to be mixed in on init
Button.timer = 0
Button.state = KEY.STATE_UP

-- Optional repeater
local function CheckHeldDown(self, elapsed)
	self.timer = self.timer + elapsed
	if self.timer >= self.tickNext and self.state == KEY.STATE_DOWN then
		local func = self:GetAttribute('type')
		if func and func ~= 'action' and self[func] then self[func](self) end
		self.timer = 0
	end
end

local keyUpdate = {
	[KEY.UP] = {'OnUpdate', CheckHeldDown},
	[KEY.DOWN] = {'OnUpdate', CheckHeldDown},
	[KEY.LEFT] = {'OnUpdate', CheckHeldDown},
	[KEY.RIGHT] = {'OnUpdate', CheckHeldDown},
}

---------------------------------------------------------------
-- SecureBtn: Button init
---------------------------------------------------------------
function ConsolePort:CreateSecureButton(name, modifier, command)
	local btn 	= CreateFrame('Button', name..modifier, Handler, 'SecureActionButtonTemplate, SecureHandlerBaseTemplate')
	btn:Hide()
	btn.command = command
	btn.name = name
	btn.mod = modifier
	-----------------------------------------------------------
	btn.HotKeys = {}
	btn.CreateHotKey = ConsolePort.CreateHotKey
	-----------------------------------------------------------
	btn:SetAttribute('_childupdate-combat', [[
		if message then
			self:SetAttribute('clickbutton', nil)
			self:Hide()
			self:CallMethod('Clear')
		end
	]])
	-----------------------------------------------------------
	db.table.mixin(btn, Button)
	-----------------------------------------------------------
	local keyUpdate = keyUpdate[command]
	if keyUpdate and not db.Settings.UIdisableHoldRepeat then
		btn.tickNext = db.Settings.UIholdRepeatDelay or 0.125
		btn:SetScript(unpack(keyUpdate))
	end
    db.SECURE[btn] = true
    return btn
end

function ConsolePort:GetSecureButton(name, modifier)
	return _G[name .. modifier]
end