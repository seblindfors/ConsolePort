-- ConsolePort 
local addOn, db = ...
local KEY = db.KEY

local buttonWatchers = 0
local hasButtonWatch = false
local buttonWatch = {}

local function CheckButtonWatchers(self)
	if hasButtonWatch and not InCombatLockdown() then
		buttonWatchers = 0
		for button, info in pairs(buttonWatch) do
			buttonWatchers = buttonWatchers + 1
			if _G[info.action] then
				self:ReloadBindingAction(button, info.action, info.name, info.mod1, info.mod2)
				button.buttonWatch = nil
				buttonWatch[button] = nil
			end
		end
		if buttonWatchers == 0 then
			hasButtonWatch = false
		end
	end
end

local function OnEvent (self, event, ...)
	if 	self[event] then
		self[event](self, ...)
		return
	end
	self:CheckMouselookEvent(event)

end

function ConsolePort:AddButtonWatch(button, action, name, mod1, mod2)
	buttonWatch[button] = {action = action, name = name, mod1 = mod1, mod2 = mod2}
	button.buttonWatch = action
	hasButtonWatch = true
end

function ConsolePort:SetClickButton(button, clickbutton)
	button:SetAttribute("type", "click")
	button:SetAttribute("clickbutton", clickbutton)
end

ConsolePort:AddUpdateSnippet(CheckButtonWatchers)
ConsolePort:RegisterEvent("ADDON_LOADED");
ConsolePort:RegisterEvent("PLAYER_LOGOUT");
ConsolePort:SetScript("OnEvent", OnEvent);
