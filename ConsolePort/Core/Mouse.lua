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
local Settings, IsCentered, IsVisible, IsOutside
---------------------------------------------------------------
local ConsolePort, WorldFrame = ConsolePort, WorldFrame
---------------------------------------------------------------
local 	GetMouseFocus, HasCursorItem, SpellIsTargeting, IsMouseButtonDown, IsMouselooking = 
		GetMouseFocus, GetCursorInfo, SpellIsTargeting, IsMouseButtonDown, IsMouselooking
---------------------------------------------------------------
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
local UIBlocker = CreateFrame("Frame", "ConsolePortUIBlocker", UIParent)
UIBlocker:SetAllPoints()
UIBlocker:SetFrameStrata("FULLSCREEN_DIALOG")
UIBlocker:EnableMouse(true)
UIBlocker:Hide()
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

local function MouselookUpdate(self)
	UIBlocker:SetShown(IsMouselooking())
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
-- Cursor drift catcher: This frame looks for whether the cursor
-- is at the very edge of the screen. (fullscreen recommended)
---------------------------------------------------------------
local Padding = CreateFrame("Frame", "ConsolePortMouseLookRim", UIParent)
Padding:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50)
Padding:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 50)
Padding:Hide()

local function MouselookPaddingUpdate(self)
	if not Padding:IsMouseOver() and not IsOutside and
		(GetMouseFocus() == WorldFrame) then
		IsOutside = true
		self:StartMouse()
	elseif Padding:IsMouseOver() then
		IsOutside = false
	end
end

---------------------------------------------------------------
-- Double tap catcher: This frame looks for double-tapping on
-- a modifier, which is then used to toggle the cursor on/off.
---------------------------------------------------------------
local DoubleTapCatcher = CreateFrame("Frame")
DoubleTapCatcher.numTap = 0
DoubleTapCatcher.timer = 0

local dtModifiers = {
	RSHIFT = "SHIFT",
	LSHIFT = "SHIFT",
	SHIFT = "SHIFT",
	LCTRL = "CTRL",
	RCTRL = "CTRL",
	CTRL = "CTRL",
}

local function MouselookDoubleTapUpdate(self, elapsed)
	self.timer = self.timer + elapsed
	if self.numTap > 1 then
		ConsolePort:ToggleMouse()
		self.numTap = 0
		self.modTap = 0
	end
	if self.timer > 0.25 then
		self.numTap = self.numTap > 0 and self.numTap - 1 or 0
		self.timer = self.timer - 0.25
	end
end

local function MouselookDoubleTapEvent(self, _, ...)
	local modifier, down = ...
	if down == 1 then
		local dtMod = dtModifiers[modifier]
		if dtMod then
			self.timer = 0
			self.numTap = self.modTap == dtMod and self.numTap + 1 or 1
			self.modTap = dtMod
		end
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
local MouseHandle = CreateFrame("Frame", "ConsolePortMouseHandle", UIParent, "SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
MouseHandle:SetFrameRef("ActionBar", MainMenuBarArtFrame)
MouseHandle:SetFrameRef("OverrideBar", OverrideActionBar)
MouseHandle:Execute([[
	---------------------------------------------------------------
	USE = false
	id = 0
	---------------------------------------------------------------
	isEnabled = true
	target = false
	---------------------------------------------------------------

	UpdateTarget = [=[
		target = ...

		if not isEnabled then
			return
		end

		local interact, loot = false, false

		if target ~= "hover" and ( target == "enemy" or target == "friend" ) then
			local helpful = self:RunAttribute("IsHelpfulAction", id)
			local harmful = self:RunAttribute("IsHarmfulAction", id)

			if 	( not helpful and not harmful ) or
				( target == "friend" and helpful ) or
				( target == "enemy" and harmful ) then
				self:ClearBindings()
			end
		elseif target == "loot" then
			loot = true
		else
			interact = true
		end

		if ( interact or loot ) and USE then
			local key = GetBindingKey(USE)
			if key then
				if loot then
					self:SetBinding(true, key, "INTERACTTARGET")
				else
					self:SetBinding(true, key, "TURNORACTION")
				end
			end
		end
		self:CallMethod("TrackUnit", target)
	]=]

	UpdateAttribute = [=[
		local attribute, value = ...
		if attribute == "state-targetstate" then
			self:Run(UpdateTarget, value)
		elseif attribute == "override" then
			isEnabled = value
			if not isEnabled then
				self:ClearBindings()
			else
				self:Run(UpdateTarget, Target)
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
MouseHandle:SetAttribute("_onattributechanged", "self:Run(UpdateAttribute, name, value)")

MouseHandle:SetPoint("CENTER", 0, -300)
MouseHandle:SetSize(300, 64)
MouseHandle:SetAlpha(0)

MouseHandle.Line = MouseHandle:CreateTexture("$parentLine", "ARTWORK")
MouseHandle.Line:SetAtlas("legioninvasion-title-bg")
MouseHandle.Line:SetPoint("BOTTOM")
MouseHandle.Line:SetSize(300, 100)
MouseHandle.Line:SetVertexColor(1, 0.75, 0.75)

MouseHandle.Button = MouseHandle:CreateTexture("$parentButton", "ARTWORK")
MouseHandle.Button:SetPoint("LEFT", 50, 16)
MouseHandle.Button:SetSize(32, 32)

MouseHandle.Text = MouseHandle:CreateFontString("$parentText", "OVERLAY", "MovieSubtitleFont")
MouseHandle.Text:SetPoint("CENTER", 0, 16)

local 	UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, CanLootUnit = 
		UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, CanLootUnit

MouseHandle.FadeIn = db.UIFrameFadeIn
MouseHandle.FadeOut = db.UIFrameFadeOut

function MouseHandle:CheckLoot(elapsed)
	local alpha = self:GetAlpha()
	local guid, hasLoot, canLoot = UnitGUID("target")
	if guid then
		hasLoot, canLoot = CanLootUnit(guid)
	end
	if hasLoot and canLoot then
		self.Text:SetText(LOOT)
		if self.fade ~= "in" then
			self:FadeIn(0.1, alpha, 1)
			self.fade = "in"
		end
	else
		if self.fade ~= "out" then
			self:FadeOut(0.2, alpha, 0)
			self.fade = "out"
		end
	end
end

function MouseHandle:CheckHover(elapsed)
	local guid, hasLoot, canLoot = UnitGUID("mouseover")
	local exists = UnitExists("mouseover")
	local isDead, isEnemy = UnitIsDead("mouseover"), UnitCanAttack("player", "mouseover")
	if guid then
		hasLoot, canLoot = CanLootUnit(guid)
	end
	if hasLoot and canLoot then
		self.Text:SetText(LOOT)
	elseif isEnemy and not isDead then
		self.Text:SetText(ATTACK)
	elseif exists and ( isDead or not isEnemy ) then
		self.Text:SetText(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
	end
	if self.fade ~= "in" then
		self:FadeIn(0.1, self:GetAlpha(), 1)
		self.fade = "in"
	end
end

function MouseHandle:TrackUnit(unitType)
	local hasScript = self:GetScript("OnUpdate")
	if not hasScript and unitType == "loot" then
		self:SetScript("OnUpdate", self.CheckLoot)
	elseif not hasScript and unitType == "hover" then
		self:SetScript("OnUpdate", self.CheckHover)
	else
		self:SetScript("OnUpdate", nil)
		if self.fade ~= "out" then
			self:FadeOut(0.5, self:GetAlpha(), 0)
			self.fade = "out"
		end
	end
end

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
		self.Texture:SetTexture(TEXTURE.CP_T_L3)
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

function ConsolePort:StopMouse(...)
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
function ConsolePort:UpdateMouseDriver()
	if not InCombatLockdown() then
		if db.Settings.interactWith then
			local button = db.Settings.interactWith
			local original = db.Bindings and db.Bindings[button] and db.Bindings[button][""]
			local id = original and self:GetActionID(original)

			local targetstate = "[@playertarget,exists,harm,dead] loot; [@playertarget,exists,harm,nodead] enemy; [@playertarget,exists,noharm,nodead] friend; nil"

			if db.Settings.mouseOverMode then
				targetstate = "[@mouseover,exists] hover; "..targetstate
			end

			local currentTarget = SecureCmdOptionParse(targetstate)

			CursorTrail.Default = TEXTURE[button]
			CursorTrail.Texture:SetTexture(CursorTrail.Default)
			CursorTrail:SetScript("OnUpdate", CursorTrailUpdate)
			CursorTrail:Show()

			MouseHandle.Button:SetTexture(db.TEXTURE[db.Settings.interactWith])

			RegisterStateDriver(MouseHandle, "targetstate", targetstate)
			MouseHandle:SetAttribute("target", currentTarget)

			self:RegisterSpellHeader(MouseHandle)

			MouseHandle:Execute(format([[
				USE = "%s"
				id = %d
				self:Run(UpdateTarget, self:GetAttribute("target"))
				self:SetAttribute("target", nil)
			]], button, id or -1))
		else
			CursorTrail:SetScript("OnUpdate", nil)
			CursorTrail:Hide()

			MouseHandle:Execute([[
				self:ClearBindings()
			]])

			UnregisterStateDriver(MouseHandle, "targetstate")
			self:UnregisterSpellHeader(MouseHandle)

		end
		self:RemoveUpdateSnippet(self.UpdateMouseDriver)
	end
end


local blockStop = false

local function MouselookStopWrap()
	if blockStop then
		MouselookStart()
		blockStop = false
	end
end

local function InteractUnitWrap()
	local guid, hasLoot = UnitGUID("target")
	if guid then
		hasLoot = CanLootUnit(guid)
	end
	if hasLoot then
		blockStop = true
		ConsolePort:StartMouse()
	else
		ConsolePort:StopMouse()
	end
end

local function TurnOrActionStopWrap()
	blockStop = false
	ConsolePort:StopMouse()
end


-- Get rid of mouselook when trying to interact with mouse
hooksecurefunc("MouselookStop", MouselookStopWrap)
hooksecurefunc("InteractUnit", InteractUnitWrap)
hooksecurefunc("TurnOrActionStop", TurnOrActionStopWrap)
-- Hook jump and lock mouse if it's enabled
hooksecurefunc("JumpOrAscendStart", MouseLookOnJump)