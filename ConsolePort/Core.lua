-- ConsolePort 
local addOn, db = ...
local KEY = db.KEY

local f = ConsolePort
local m = ConsolePort:CreateMouseLooker()

local UIControls = db.UI.Controls

local function MouseLookShouldStart()
	if 	not SpellIsTargeting() 			and
		not IsMouseButtonDown(1) 		and
		not GetCursorInfo() 			and
		MouseIsOver(m) 					and
		(GetMouseFocus() == WorldFrame) then
		return true
	end
end

function ConsolePort:GetFrameStack()
	local stack = {}
	if ConsolePortRebindFrame:IsVisible() then
		if ConsolePortRebindFrame.isRebinding then
			for _, Frame in pairs({UIParent:GetChildren()}) do
				if not Frame:IsForbidden() and
					Frame:IsVisible() and
					Frame ~= InterfaceOptionsFrame then
					tinsert(stack, Frame)
				end
			end
		end
		tinsert(stack, DropDownList1)
		tinsert(stack, DropDownList2)
		tinsert(stack, ConsolePortRebindFrame)
	else
		for _, UIControl in pairs(UIControls) do
			if UIControl.frame:IsVisible() then
				tinsert(stack, UIControl.frame)
			end
		end
	end
	return stack
end

local interval = 0.1
local time = 0
local MouseIsCentered = false
local function OnUpdate (self, elapsed)
	time = time + elapsed
	while time > interval do
		if GetCursorInfo() then
			MouselookStop()
		elseif not MouseIsCentered and
			MouseLookShouldStart() then
			MouselookStart()
			MouseIsCentered = true;
		elseif not MouseIsOver(m) and MouseIsCentered then
			MouseIsCentered = false
		end
		if not InCombatLockdown() then
			self:UpdateFrames()
		end
		time = time - interval
	end
end

local function OnEvent (self, event, ...)
	if 	self[event] then
		self[event](self, ...);
		return
	end
	self:CheckMouselookEvent(event)
	if not InCombatLockdown() then
		ClearOverrideBindings(self)
	end
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

function ConsolePort:SetButtonActionsDefault()
	for _, button in pairs(self:GetInterfaceButtons()) do
		button:Revert()
	end
end

function ConsolePort:SetButtonActions(type)
	local buttons = self:GetInterfaceButtons()
	buttons[5] = nil -- ignore square
	buttons[6] = nil -- ignore circle
	for i, button in pairs(buttons) do
		button:SetAttribute("type", type)
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
