---------------------------------------------------------------
-- Mouse.lua: Smart camera control and mouse function wrappers
---------------------------------------------------------------
-- Removes the need of holding right click to control camera.
-- Allows user to mouseover their character to control camera.
-- Toggles off on targeted spells, InteractUnit and pickups.

local _, db = ...
---------------------------------------------------------------
local TEXTURE = db.TEXTURE
---------------------------------------------------------------
local Settings
---------------------------------------------------------------
local ConsolePort = ConsolePort
---------------------------------------------------------------
local WorldFrame = WorldFrame
local HasCursorItem = GetCursorInfo
local GetMouseFocus = GetMouseFocus
local SpellIsTargeting = SpellIsTargeting
local IsMouseButtonDown = IsMouseButtonDown
---------------------------------------------------------------
local IsCentered, IsVisible
local Locker = CreateFrame("Frame", "ConsolePortMouseLookCenter", UIParent)
Locker:SetPoint("CENTER", 0, 0)
Locker:SetSize(70, 180)
Locker:Hide()
---------------------------------------------------------------
local Deadzone = CreateFrame("Frame", "ConsolePortMouseLookDeadzone", UIParent)
Deadzone:SetPoint("CENTER", 0, 0)
Deadzone:SetSize(4, 4)
Deadzone:Hide()
---------------------------------------------------------------
local IsOutside
local Padding = CreateFrame("Frame", "ConsolePortMouseLookRim", UIParent)
Padding:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50)
Padding:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 50)
Padding:Hide()
---------------------------------------------------------------
local DoubleTapCatcher = CreateFrame("Frame")
DoubleTapCatcher.Num = 0
DoubleTapCatcher.Timer = 0
---------------------------------------------------------------

local function MouseLookOnJump()
	if 	Settings.mouseOnJump and
		not SpellIsTargeting() and
		not HasCursorItem() then
		ConsolePort:StartMouse()
	end
end

local function MouselookOnCenter()
	return Settings.mouseOnCenter and Locker:IsMouseOver() and not Deadzone:IsMouseOver()
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

local function MouselookPaddingUpdate(self)
	if not Padding:IsMouseOver() and not IsOutside and
		(GetMouseFocus() == WorldFrame) then
		IsOutside = true
		self:StartMouse()
	elseif Padding:IsMouseOver() then
		IsOutside = false
	end
end

local function MouselookDoubleTapUpdate(self, elapsed)
	self.Timer = self.Timer + elapsed
	if self.Num > 1 then
		ConsolePort:ToggleMouse()
		self.Num = 0
		self.Mod = 0
	end
	if self.Timer > 0.25 then
		self.Num = self.Num > 0 and self.Num - 1 or 0
		self.Timer = self.Timer - 0.25
	end
end

local function MouselookDoubleTapEvent(self, _, ...)
	local modifier, down = ...
	if down == 1 and (modifier == "LSHIFT" or modifier == "RSHIFT") then
		self.Timer = 0
		self.Num = self.Mod == "SHIFT" and self.Num + 1 or 1
		self.Mod = "SHIFT"
	elseif down == 1 and (modifier == "LCTRL" or modifier == "RCTRL") then
		self.Timer = 0
		self.Num = self.Mod == "CTRL" and self.Num + 1 or 1
		self.Mod = "CTRL"
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
-- Helpful: interact with no target/enemy, cast on friend.
-- Harmful: interact with no target/friend, cast on enemy.
---------------------------------------------------------------
local MouseHandle = CreateFrame("Frame", "ConsolePortMouseHandle", UIParent, "SecureHandlerBaseTemplate, SecureHandlerStateTemplate")
MouseHandle:RegisterEvent("LEARNED_SPELL_IN_TAB")
MouseHandle:SetFrameRef("ActionBar", MainMenuBarArtFrame)
MouseHandle:SetFrameRef("OverrideBar", OverrideActionBar)
MouseHandle:Execute([[
	SPELLS = newtable()
	USE = false
	PAGE = 1
	ID = 0
]])
MouseHandle:Execute([[
	UpdateTarget = [=[
		local exists = ...
		local interact = false

		if exists ~= "hover" and (exists == "enemy" or exists == "friend") then
			local id = ID >= 0 and ID <= 12 and (PAGE-1) * 12 + ID or ID >= 0 and ID
			if id then
				local actionType, actionID, subType = GetActionInfo(id)
				if actionType == "spell" and subType == "spell" then
					local spellBookID = SPELLS[actionID]
					local helpful = spellBookID and IsHelpfulSpell(spellBookID, subType)
					local harmful = spellBookID and IsHarmfulSpell(spellBookID, subType)
					if not helpful and not harmful then
						self:ClearBindings()
					elseif exists == "friend" and helpful then
						self:ClearBindings()
					elseif exists == "enemy" and harmful then
						self:ClearBindings()
					end
				end
			else
				self:ClearBindings()
			end
		else
			interact = true
		end

		if exists == "hover" then
			self:SetBindingClick(true, "SHIFT-BUTTON1", Focus, "LeftButton")
		else
			self:ClearBinding("SHIFT-BUTTON1")
		end

		if interact and USE then
			local key = GetBindingKey(USE)
			if key then
				self:SetBinding(true, key, "INTERACTMOUSEOVER")
			end
		end
	]=]

	UpdateActionPage = [=[
		PAGE = ...
		if PAGE == "temp" then
			if HasTempShapeshiftActionBar() then
				PAGE = GetTempShapeshiftBarIndex()
			else
				PAGE = 1
			end
		elseif PAGE == "possess" then
			PAGE = self:GetFrameRef("ActionBar"):GetAttribute("actionpage") or 1
			if PAGE <= 10 then
				PAGE = self:GetFrameRef("OverrideBar"):GetAttribute("actionpage") or 12
			end
			if PAGE <= 10 then
				PAGE = 12
			end
		end
	]=]
]])
---------------------------------------------------------------
local Focus = CreateFrame("Button", "ConsolePortMouseHandleMouseoverFocus", MouseHandle, "SecureActionButtonTemplate")
Focus:SetAttribute("type", "focus")
Focus:SetAttribute("unit", "mouseover")
MouseHandle:SetFrameRef("Focus", Focus)
MouseHandle:Execute([[ Focus = self:GetFrameRef("Focus") ]])
---------------------------------------------------------------

MouseHandle:SetAttribute("_onstate-targetstate", 	[[ self:Run(UpdateTarget, newstate) ]])
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
			else
				break
			end
		end
		self:RemoveUpdateSnippet(SecureSpellBookUpdate)
	end
end

-- Update the spell table when a new spell is learned.
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
	if SpellIsTargeting() then
		self.Texture:SetTexture(TEXTURE.CP_TL3)
		self:SetAlpha(1)
	elseif GameTooltip:GetOwner() == UIParent and not IsMouselooking() then
		self.Texture:SetTexture(self.Default)
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
		Settings = db.Settings
	end
	if Settings.disableSmartMouse then
		self:RemoveUpdateSnippet(MouselookUpdate)
	else
		self:AddUpdateSnippet(MouselookUpdate)
	end
	if Settings.preventMouseDrift then
		self:AddUpdateSnippet(MouselookPaddingUpdate)
	else
		self:RemoveUpdateSnippet(MouselookPaddingUpdate)
	end
	if Settings.doubleModTap then
		DoubleTapCatcher:SetScript("OnEvent", MouselookDoubleTapEvent)
		DoubleTapCatcher:SetScript("OnUpdate", MouselookDoubleTapUpdate)
		DoubleTapCatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
	else
		DoubleTapCatcher:SetScript("OnEvent", nil)
		DoubleTapCatcher:SetScript("OnUpdate", nil)
		DoubleTapCatcher:UnregisterEvent("MODIFIER_STATE_CHANGED")
	end
end

---------------------------------------------------------------
-- Toggle interactive mouse driver on/off
---------------------------------------------------------------
function ConsolePort:UpdateStateDriver()
	if db.Settings.interactWith then
		local currentPage, actionpage = self:GetActionPageState()
		local button = db.Settings.interactWith
		local original = db.Bindings[button].action
		local id = original and self:GetActionID(original)

		local targetstate = "[@playertarget,exists,harm,nodead] enemy; [@playertarget,exists,noharm,nodead] friend; nil"

		if db.Settings.mouseOverMode then
			targetstate = "[@mouseover,exists] hover; "..targetstate
		end

		local currentTarget = SecureCmdOptionParse(targetstate)

		CursorTrail.Default = TEXTURE[button]
		CursorTrail.Texture:SetTexture(CursorTrail.Default)
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