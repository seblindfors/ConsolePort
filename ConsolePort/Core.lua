-- ConsolePort 
local addOn, db = ...
local KEY = db.KEY

local f = ConsolePort
local m = ConsolePort:CreateMouseLooker()

local UIControls = db.UI.Controls

local buttonWatchers = 0
local hasButtonWatch = false
local buttonWatch = {}

local function MouseLookShouldStart()
	if 	not SpellIsTargeting() 			and
		not IsMouseButtonDown(1) 		and
		not GetCursorInfo() 			and
		MouseIsOver(m) 					and
		(GetMouseFocus() == WorldFrame) then
		return true
	end
end

function CheckButtonWatchers(self)
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

local interval = 0.1
local time = 0
local MouseIsCentered = false
local CursorInfo = false
local UpdateQueued = false
local function OnUpdate (self, elapsed)
	time = time + elapsed
	while time > interval do
		if hasButtonWatch and not InCombatLockdown() then
			CheckButtonWatchers(self)
		end
		if 	not CursorInfo and GetCursorInfo() then
			self:StopMouse()
		elseif not MouseIsCentered and
			MouseLookShouldStart() then
			self:StartMouse()
			MouseIsCentered = true;
		elseif not MouseIsOver(m) and MouseIsCentered then
			MouseIsCentered = false
		end
		time = time - interval
	end
end

local function OnEvent (self, event, ...)
	if 	self[event] then
		self[event](self, ...)
		return
	end
	self:CheckMouselookEvent(event)
	if not InCombatLockdown() then
		ClearOverrideBindings(self)
	end
end


function ConsolePort:StopMouse()
	CursorInfo = true
	MouselookStop()
end

function ConsolePort:StartMouse()
	CursorInfo = nil
	MouselookStart()
end

function ConsolePort:GetInterfaceButtons()
	return {
		CP_L_UP_NOMOD, 		--1
		CP_L_DOWN_NOMOD,	--2
		CP_L_RIGHT_NOMOD,	--3
		CP_L_LEFT_NOMOD,	--4
		CP_R_LEFT_NOMOD,	--5
		CP_R_RIGHT_NOMOD,	--6
		CP_R_UP_NOMOD,		--7
	}
end

function ConsolePort:QueueButtonWatch(button, action, name, mod1, mod2)
	buttonWatch[button] = {action = action, name = name, mod1 = mod1, mod2 = mod2}
	button.buttonWatch = action
	hasButtonWatch = true
end

function ConsolePort:SetButtonActionsDefault()
	for _, button in pairs(self:GetInterfaceButtons()) do
		button:Revert()
	end
end

function ConsolePort:SetButtonActionsUI()
	local buttons = self:GetInterfaceButtons()
	buttons[_G[ConsolePortMouse.Cursor.Left.."_NOMOD"]] = nil
	buttons[_G[ConsolePortMouse.Cursor.Right.."_NOMOD"]] = nil
	for i, button in pairs(buttons) do
		button:SetAttribute("type", "UIControl")
	end
end

function ConsolePort:SetClickButton(button, clickbutton)
	button:SetAttribute("type", "click")
	button:SetAttribute("clickbutton", clickbutton)
end

function ConsolePort:OverrideBinding(self, priority, modifier, old, new)
	if not InCombatLockdown() then
		local key1, key2 = GetBindingKey(old);
		if modifier then
			if key1 then key1 = modifier.."-"..key1; end;
			if key2 then key2 = modifier.."-"..key2; end;
		end
		if key1 then SetOverrideBinding(self, priority, key1, new); end;
		if key2 then SetOverrideBinding(self, priority, key2, new); end;
	end
end

f:RegisterEvent("ADDON_LOADED");
f:RegisterEvent("PLAYER_LOGOUT");
f:SetScript("OnEvent", OnEvent);
f:SetScript("OnUpdate", OnUpdate);
