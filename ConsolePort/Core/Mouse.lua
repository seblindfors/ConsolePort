---------------------------------------------------------------
-- Mouse.lua: Smart camera control and mouse function wrappers
---------------------------------------------------------------
-- Removes the need of holding right click to control camera.
-- Allows user to mouseover their character to control camera.
-- Toggles off on targeted spells, InteractUnit and pickups.

local _, db = ...
---------------------------------------------------------------
local Settings
---------------------------------------------------------------
local WorldFrame = WorldFrame
local HasCursorItem = GetCursorInfo
local GetMouseFocus = GetMouseFocus
local SpellIsTargeting = SpellIsTargeting
local IsMouseButtonDown = IsMouseButtonDown
---------------------------------------------------------------
local IsCentered, IsVisible
local Locker = CreateFrame("Frame", "ConsolePortMouseLook", UIParent)
Locker:SetPoint("CENTER", 0, 0)
Locker:SetSize(70, 180)
Locker:Hide()
---------------------------------------------------------------
local function MouseLookOnJump()
	if 	Settings.mouseOnJump and
		not SpellIsTargeting() and
		not HasCursorItem() then
		ConsolePort:StartMouse()
	end
end

local function MouselookOnCenter()
	return Settings.mouseOnCenter and Locker:IsMouseOver()
end

local function MouselookShouldStart()
	if 	not SpellIsTargeting() 			and
		not IsMouseButtonDown(1) 		and
		not HasCursorItem() 			and
		MouselookOnCenter() 			and
		(GetMouseFocus() == WorldFrame) then
		return true
	end
end

local function MouselookUpdate(self)
	if 	not IsVisible and HasCursorItem() then
		self:StopMouse()
	elseif not IsCentered and
		MouselookShouldStart() then
		self:StartMouse()
		IsCentered = true
	elseif not Locker:IsMouseOver() and IsCentered then
		IsCentered = false
	end
end

---------------------------------------------------------------
-- This handle is used to determine whether a dedicated button
-- should be used to cast spells or to interact with mouseover.
-- The behaviour alters itself depending on whether the button
-- is bound to a healing spell or harmful spell.
-- Helpful: will interact with no target, cast on friendly.
-- Harmful: will interact with no target, cast on enemy.
---------------------------------------------------------------
local MouseHandle = CreateFrame("Frame", "ConsolePortMouseHandle", UIParent, "SecureHandlerStateTemplate")
MouseHandle:RegisterEvent("LEARNED_SPELL_IN_TAB")
MouseHandle:SetFrameRef("ActionBar", MainMenuBarArtFrame)
MouseHandle:SetFrameRef("OverrideBar", OverrideActionBar)
MouseHandle:Execute([[
	SPELLS = newtable()
	ALL = newtable()
	USE = false
	PAGE = 0
	ID = 0
]])
MouseHandle:Execute([[
	UpdateTarget = [=[
		local exists = ...
		local interact = false

		if exists == "enemy" or exists == "friend" then
			local id = ID >= 0 and ID <= 12 and (PAGE-1) * 12 + ID or ID >= 0 and ID
			if id then
				local actionType, actionID, subType = GetActionInfo(id)
				if actionType == "spell" and subType == "spell" then
					local spellBookID = SPELLS[actionID]
					if exists == "friend" then
						if spellBookID and IsHelpfulSpell(spellBookID, subType) then
							self:ClearBindings()
						end
					elseif exists == "enemy" then
						if spellBookID and IsHarmfulSpell(spellBookID, subType) then
							self:ClearBindings()
						end
					end
				end
			else
				self:ClearBindings()
			end
		else
			interact = true
		end

		if interact and USE then
			local key = GetBindingKey(USE)
			if key then
				self:SetBinding(true, key, "INTERACTMOUSEOVER")
			end
		end
	]=]

	UpdateMouseOver = [=[
		local mouseover = ...
		self:SetAttribute("mousestate", mouseover and true)
		if mouseover then
			for binding in pairs(ALL) do
				local key = GetBindingKey(binding)
				if key then
					self:SetBinding(true, key, "INTERACTMOUSEOVER")
				end
			end
		else
			self:ClearBindings()
		end
	]=]

	UpdateActionPage = [=[
		PAGE = ...
		if PAGE == "tempshapeshift" then
			if HasTempShapeshiftActionBar() then
				PAGE = GetTempShapeshiftBarIndex()
			else
				PAGE = 1
			end
		elseif PAGE == "possess" then
			PAGE = self:GetFrameRef("ActionBar"):GetAttribute("actionpage")
			if PAGE <= 10 then
				PAGE = self:GetFrameRef("OverrideBar"):GetAttribute("actionpage")
			end
			if PAGE <= 10 then
				PAGE = 12
			end
		end
	]=]
]])

MouseHandle:SetAttribute("_onstate-targetstate", 	[[ self:Run(UpdateTarget, newstate) ]])
MouseHandle:SetAttribute("_onstate-mousestate", 	[[ self:Run(UpdateMouseOver, newstate) ]])
MouseHandle:SetAttribute("_onstate-actionpage", 	[[ self:Run(UpdateActionPage, newstate) ]])

-- Index the entire spellbook by using spell ID as key and spell book slot as value.
-- IsHarmfulSpell/IsHelpfulSpell functions can use spell book slot, but not actual spell IDs.
local function SecureSpellBookUpdate(self)
	if not InCombatLockdown() then
		for id=1, MAX_SPELLS do
			local ok, err, _, _, _, _, _, spellID = pcall(GetSpellInfo, id, "spell")
			if ok then
				MouseHandle:Execute(format([[
					SPELLS[%d] = %d
				]], spellID, id))
			end
		end
		self:RemoveUpdateSnippet(SecureSpellBookUpdate)
	end
end

-- Update the spell table when a new spell is learned. Not sure if actually necessary.
MouseHandle:SetScript("OnEvent", function(self, event, ...)
	if event == "LEARNED_SPELL_IN_TAB" then
		ConsolePort:AddUpdateSnippet(SecureSpellBookUpdate)
	end
end)

---------------------------------------------------------------
-- Cursor trail for interact button
---------------------------------------------------------------
local UIParent = UIParent
local GameTooltip = GameTooltip
local IsMouselooking = IsMouselooking
local GetCursorPosition, posX, posY = GetScaledCursorPosition
local CursorTrail = CreateFrame("Frame", "ConsolePortCursorTrail", UIParent, "")

local function CursorTrailUpdate(self)
	posX, posY = GetCursorPosition()
	self:SetPoint("BOTTOMLEFT", posX+24, posY-46)
	if GameTooltip:GetOwner() == UIParent and not IsMouselooking() then
		self:SetAlpha(GameTooltip:GetAlpha())
	else
		self:SetAlpha(0)
	end
end

CursorTrail:SetFrameStrata("TOOLTIP")
CursorTrail:SetSize(24,24)
CursorTrail.Texture = CursorTrail:CreateTexture(nil, "OVERLAY", nil, 7)
CursorTrail.Texture:SetAllPoints(CursorTrail)
CursorTrail:Hide()

---------------------------------------------------------------
-- Mouse function wrappers
---------------------------------------------------------------
function ConsolePort:StopMouse()
	IsVisible = true
	MouselookStop()
end

function ConsolePort:StartMouse()
	IsVisible = nil
	MouselookStart()
end

function ConsolePort:ToggleMouse()
	if IsVisible then
		MouselookStart()
		IsVisible = nil
	else
		MouselookStop()
		IsVisible = true
	end
end

---------------------------------------------------------------
-- Toggle smart mouse behaviour on/off
---------------------------------------------------------------
function ConsolePort:UpdateSmartMouse()
	if not Settings then
		Settings = ConsolePortSettings
	end
	if Settings.disableSmartMouse then
		self:RemoveUpdateSnippet(MouselookUpdate)
	else
		self:AddUpdateSnippet(MouselookUpdate)
	end
end

---------------------------------------------------------------
-- Toggle interactive mouse driver on/off
---------------------------------------------------------------
function ConsolePort:UpdateStateDriver()
	if ConsolePortSettings.mouseOverMode then
		RegisterStateDriver(MouseHandle, "mousestate", "[@mouseover,exists] true; nil")
		MouseHandle:Execute([[
			ALL = newtable()
		]])
		for _, binding in pairs(self:GetBindingNames()) do
			MouseHandle:Execute(format([[
				ALL.%s = true
			]], binding, binding))
		end
	else
		UnregisterStateDriver(MouseHandle, "mousestate")
	end

	if ConsolePortSettings.interactWith then
		local currentPage, actionpage = self:GetActionPageState()
		local button = ConsolePortSettings.interactWith
		local original = ConsolePortBindingSet[button].action
		local id = original and self:GetActionID(original)

		local targetstate = "[@playertarget,exists,harm,nodead] enemy; [@playertarget,exists,noharm,nodead] friend; nil"
		local currentTarget = SecureCmdOptionParse(targetstate)

		CursorTrail.Texture:SetTexture(db.TEXTURE[button])
		CursorTrail:SetScript("OnUpdate", CursorTrailUpdate)
		CursorTrail:Show()

		RegisterStateDriver(MouseHandle, "actionpage", actionpage)
		RegisterStateDriver(MouseHandle, "targetstate", targetstate)
		MouseHandle:SetAttribute("actionpage", currentPage)
		MouseHandle:SetAttribute("target", currentTarget)
		MouseHandle:Execute(format([[
			USE = "%s"
			ID = %d
			self:Run(UpdateActionPage, self:GetAttribute("actionpage"))
			self:Run(UpdateTarget, self:GetAttribute("target"))
			self:SetAttribute("actionpage", nil)
			self:SetAttribute("target", nil)
		]], button, id or -1))

		self:AddUpdateSnippet(SecureSpellBookUpdate)
	else
		CursorTrail:SetScript("OnUpdate", nil)
		CursorTrail:Hide()

		MouseHandle:Execute([[
			self:ClearBindings()
		]])

		UnregisterStateDriver(MouseHandle, "actionpage")
		UnregisterStateDriver(MouseHandle, "targetstate")
	end
end

-- Get rid of mouselook when trying to interact with mouse
hooksecurefunc("InteractUnit", ConsolePort.StopMouse)
-- Hook jump and lock mouse if it's enabled
hooksecurefunc("JumpOrAscendStart", MouseLookOnJump)