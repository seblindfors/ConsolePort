local addOn, db = ...
local KEY = db.KEY


--[[
|---------------------------------------|
| SecureBtn: Actionpage state handler 	|
|---------------------------------------|
]]--
function ConsolePort:CreateButtonHandler()
	if not ConsolePortButtonHandler then
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
					page = self:GetFrameRef("MainMenuBarArtFrame"):GetAttribute("actionpage")
					if page <= 10 then
						page = self:GetFrameRef("OverrideActionBar"):GetAttribute("actionpage")
					end
					if page <= 10 then
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

		local state = {}
		tinsert(state, "[overridebar][possessbar]possess")
		for i = 2, 6 do
			tinsert(state, ("[bar:%d]%d"):format(i, i))
		end
		local _, playerClass = UnitClass("player")
		if playerClass == "DRUID" then
			tinsert(state, "[bonusbar:1,stealth]7")
		elseif playerClass == "WARRIOR" then
			tinsert(state, "[stance:2]7")
			tinsert(state, "[stance:3]8")
		end
		for i = 1, 4 do
			tinsert(state, ("[bonusbar:%d]%d"):format(i, i+6))
		end
		tinsert(state, "[stance:1]tempshapeshift")
		tinsert(state, "1")
		state = table.concat(state, ";")
		local now = SecureCmdOptionParse(state)
		ButtonHandler:SetAttribute("actionpage", now)
		RegisterStateDriver(ButtonHandler, "page", state)
		ButtonHandler:Execute([[
			self:Run(UpdateActionPage, self:GetAttribute("actionpage"))
		]])
		ButtonHandler:SetAttribute("_onstate-page", [=[
			self:Run(UpdateActionPage, newstate)
		]=])
	end
end


--[[
|---------------------------------------|
| SecureBtn: Main bar button ref check 	|
|---------------------------------------|
]]--
local function MainBarAction(action)
	if 	type(action) == "table" and
		action:GetParent() == MainMenuBarArtFrame and
		action.action then
		return action:GetID()
	else
		return nil
	end
end

--[[
|---------------------------------------|
| SecureBtn: Input scripts  			|
|---------------------------------------|
]]--
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

local function PostClick(self)
	local click = self:GetAttribute("clickbutton")
	if click and not click:IsEnabled() then
		self:SetAttribute("clickbutton", nil)
	end
end


--[[
|---------------------------------------|
| SecureBtn: Global frame references 	|
|---------------------------------------|
]]--
local function UIControl(self)
	ConsolePort:UIControl(self.command, self.state)
end

local function Popup(self)
	ConsolePort:Popup(self.command, self.state)
end


--[[
|---------------------------------------|
| SecureBtn: Combat reversion functions |
|---------------------------------------|
]]--
local function RevertBinding(self)
	if  MainBarAction(self.default.val) then
		self.default.type = "action"
		self.default.attr = "action"
		self.default.val  = MainBarAction(self.default.val)
		self:SetID(self.default.val)
	end
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


--[[
|---------------------------------------|
| SecureBtn: Mock ActionBar button init |
|---------------------------------------|
]]--
function ConsolePort:CreateSecureButton(name, modifier, clickbutton, UIcommand)
	local btn 	= CreateFrame("Button", name..modifier, UIParent, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
	btn.name 	= name
	btn.timer 	= 0
	btn.state 	= KEY.STATE_UP
	btn.action 	= _G[clickbutton]
	btn.command = UIcommand
	btn.mod 	= modifier
	btn.default = {}
	btn.UIControl 	= UIControl
	btn.Popup		= Popup
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
	if 	btn.command == KEY.UP or btn.command == KEY.DOWN or btn.command == KEY.LEFT or btn.command == KEY.RIGHT then
		btn:SetScript("OnUpdate", CheckHeldDown)
	end
	ConsolePortButtonHandler:SetFrameRef("NewButton", btn)
	ConsolePortButtonHandler:Execute([[
        SecureButtons[self:GetFrameRef("NewButton")] = true
    ]])
    db.SECURE[btn] = true
end
