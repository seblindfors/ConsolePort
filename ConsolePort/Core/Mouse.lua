---------------------------------------------------------------
-- Mouse.lua: Smart camera control and mouse function wrappers
---------------------------------------------------------------
-- Removes the need of holding right click to control camera.
-- Allows user to mouseover their character to control camera.
-- Toggles off on targeted spells, InteractUnit and pickups.

local _, db = ...
---------------------------------------------------------------
local TEXTURE, Settings = db.TEXTURE
---------------------------------------------------------------
local 	WorldFrame, UIParent, GameTooltip, Core = 
		WorldFrame, UIParent, GameTooltip, ConsolePort
---------------------------------------------------------------
-- Camera functions
local 	GetMouseFocus, HasCursorItem, SpellIsTargeting, IsMouseButtonDown, IsMouselooking = 
		GetMouseFocus, GetCursorInfo, SpellIsTargeting, IsMouseButtonDown, IsMouselooking
---------------------------------------------------------------
-- Highlight functions
local 	HighlightStart, HighlightStop = 
		TargetPriorityHighlightStart, TargetPriorityHighlightEnd
---------------------------------------------------------------
-- Mouse functions
local 	UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, CanLootUnit, GetCursorPosition = 
		UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, CanLootUnit, GetScaledCursorPosition
---------------------------------------------------------------
local Camera = CreateFrame("Frame", "ConsolePortCamera", UIParent)
Camera.numTap = 0
Camera.timer = 0
Camera.highlightTimer = 0
Camera.Start = MouselookStart
Camera.Stop = MouselookStop
---------------------------------------------------------------
Camera.Locker = CreateFrame("Frame", "$parentLocker", Camera)
Camera.Locker:SetPoint("CENTER", UIParent, 0, 0)
Camera.Locker:SetSize(70, 180)
Camera.Locker:Hide()
---------------------------------------------------------------
Camera.Edge = CreateFrame("Frame", "$parentEdge", Camera)
Camera.Edge:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50)
Camera.Edge:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 50)
Camera.Edge:Hide()
---------------------------------------------------------------
Camera.Deadzone = CreateFrame("Frame", "$parentDeadzone", Camera)
Camera.Deadzone:SetPoint("CENTER", UIParent, 0, 0)
Camera.Deadzone:SetSize(4, 4)
Camera.Deadzone:Hide()
---------------------------------------------------------------
Camera.BlockUI = CreateFrame("Frame", "ConsolePortUIBlocker", UIParent)
Camera.BlockUI:SetAllPoints()
Camera.BlockUI:SetFrameStrata("FULLSCREEN_DIALOG")
Camera.BlockUI:EnableMouse(true)
Camera.BlockUI:Hide()
---------------------------------------------------------------
local blockCursor, cameraMode, isMouseDown, isCentered, isOutside, isTargeting, hasItem, hasWorldFocus

function Camera:Toggle() if cameraMode then self:Stop() else self:Start() end end
function Camera:IsCentered() return self.Locker:IsMouseOver() and not self.Deadzone:IsMouseOver() end
function Camera:ShouldStart() return not isTargeting and not isMouseDown and not hasItem and self:IsCentered() and hasWorldFocus end
function Camera:OnJump() if Settings.mouseOnJump and not isTargeting and not hasItem then Camera:Start() end end

function Camera:OnUpdate(elapsed)
	cameraMode = IsMouselooking()
	isTargeting = SpellIsTargeting()
	isMouseDown = IsMouseButtonDown(1)
	hasItem = HasCursorItem()
	hasWorldFocus = GetMouseFocus() == WorldFrame
	---------------
	self.BlockUI:SetShown(cameraMode)
end

function Camera:CheckCursor()
	if cameraMode and hasItem then
		self:Stop()
	end
end

function Camera:CheckCenter()
	if not isCentered and self:ShouldStart() then
		self:Start()
		isCentered = true
	elseif not self.Locker:IsMouseOver() and isCentered then
		isCentered = false
	end
end

function Camera:CheckDoubleTap(elapsed)
	self.timer = self.timer + elapsed
	if self.numTap > 1 then
		self:Toggle()
		self.numTap = 0
		self.modTap = 0
	end
	if self.timer > 0.25 then
		self.numTap = self.numTap > 0 and self.numTap - 1 or 0
		self.timer = self.timer - 0.25
	end
end

function Camera:CheckEdge()
	if not self.Edge:IsMouseOver() and not isOutside and hasWorldFocus then
		isOutside = true
		self:Start()
	elseif self.Edge:IsMouseOver() then
		isOutside = false
	end
end

function Camera:HighlightNoTarget(elapsed)
	self.highlightTimer = self.highlightTimer + elapsed
	if self.highlightTimer > 3 then
		if not UnitExists("target") then
			HighlightStart()
		end
		self.highlightTimer = self.highlightTimer - 3
	end
end

function Camera:HighlightAlways(elapsed)
	self.highlightTimer = self.highlightTimer + elapsed
	if self.highlightTimer > 3 then
		HighlightStart()
		self.highlightTimer = self.highlightTimer - 3
	end
end

function Camera:OnEvent(event, ...)
	local modifier, down = ...
	if down == 1 then
		if modifier then
			self.timer = 0
			self.numTap = self.modTap == modifier and self.numTap + 1 or 1
			self.modTap = modifier
		end
	end
end

function Camera:OnInteract()
	local guid, hasLoot = UnitGUID("target")
	if guid then
		hasLoot = CanLootUnit(guid)
	end
	if hasLoot then
		blockCursor = true
		Camera:Start()
	else
		Camera:Stop()
	end
end

function Camera:OnStop()
	if blockCursor then
		blockCursor = nil
		Camera:Start()
	end
end

function Camera:OnRightClick() blockCursor = nil end

-- Get rid of mouselook when trying to interact with mouse
hooksecurefunc("MouselookStop", Camera.OnStop)
-- InteractUnit removes mouse look, restart if target has loot
hooksecurefunc("InteractUnit", Camera.OnInteract)
-- Releasing 'right click' should remove the cursor block
hooksecurefunc("TurnOrActionStop", Camera.OnRightClick)
-- Hook jump to use it as a camera trigger
hooksecurefunc("JumpOrAscendStart", Camera.OnJump)
-- Get rid of mouselook when moving the pet
hooksecurefunc("PetMoveTo", Camera.Stop)

---------------------------------------------------------------
-- Mouse function wrappers in case of extended functionality
---------------------------------------------------------------

function Core:StopCamera() Camera:Stop() end
function Core:StartCamera() Camera:Start() end

---------------------------------------------------------------
-- Toggle smart mouse behaviour on/off
---------------------------------------------------------------
function Core:UpdateCameraDriver()
	Settings = Settings or db.Settings

	Camera:SetScript("OnEvent", nil)
	Camera:SetScript("OnUpdate", Camera.OnUpdate)
	Camera:UnregisterEvent("MODIFIER_STATE_CHANGED")

	if not Settings.disableSmartMouse then
		Camera:HookScript("OnUpdate", Camera.CheckCursor)

		if Settings.mouseOnCenter then
			Camera:HookScript("OnUpdate", Camera.CheckCenter)
		end
		if Settings.preventMouseDrift then
			Camera:HookScript("OnUpdate", Camera.CheckEdge)
		end
		if Settings.doubleModTap then
			Camera:SetScript("OnEvent", Camera.OnEvent)
			Camera:RegisterEvent("MODIFIER_STATE_CHANGED")
			Camera:HookScript("OnUpdate", Camera.CheckDoubleTap)
		end
	end

	if Settings.alwaysHighlight == 1 then
		Camera:HookScript("OnUpdate", Camera.HighlightNoTarget)
	elseif Settings.alwaysHighlight == 2 then
		Camera:HookScript("OnUpdate", Camera.HighlightAlways)
	end

	Camera.lockOnLoot = db.Mouse.Events.LOOT_OPENED
end

---------------------------------------------------------------
-- This handle is used to determine whether a dedicated button
-- should be used to cast spells or to interact with mouseover.
-- The behaviour alters itself depending on whether the button
-- is bound to a healing spell or harmful spell.
---------------------------------------------------------------
local Mouse = CreateFrame("Frame", "ConsolePortMouseHandle", UIParent, "SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
Mouse:Execute([[
	---------------------------------------------------------------
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
local Focus = CreateFrame("Button", "$parentFocus", Mouse, "SecureActionButtonTemplate")
Focus:SetAttribute("type", "focus")
Focus:SetAttribute("unit", "mouseover")
Mouse:SetFrameRef("Focus", Focus)
Mouse:Execute([[ Focus = self:GetFrameRef("Focus") ]])
---------------------------------------------------------------
Mouse:SetAttribute("_onattributechanged", "self:Run(UpdateAttribute, name, value)")

Mouse:SetPoint("CENTER", 0, -300)
Mouse:SetSize(300, 64)
Mouse:SetAlpha(0)

Mouse.Line = Mouse:CreateTexture("$parentLine", "ARTWORK")
Mouse.Line:SetAtlas("legioninvasion-title-bg")
Mouse.Line:SetPoint("BOTTOM")
Mouse.Line:SetSize(300, 100)
Mouse.Line:SetVertexColor(1, 0.75, 0.75)

Mouse.Button = Mouse:CreateTexture("$parentButton", "ARTWORK")
Mouse.Button:SetPoint("LEFT", 50, 16)
Mouse.Button:SetSize(32, 32)

Mouse.Text = Mouse:CreateFontString("$parentText", "OVERLAY", "MovieSubtitleFont")
Mouse.Text:SetPoint("CENTER", 0, 16)

Mouse.FadeIn = db.UIFrameFadeIn
Mouse.FadeOut = db.UIFrameFadeOut

function Mouse:CheckLoot(elapsed)
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

function Mouse:CheckHover(elapsed)
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

function Mouse:TrackUnit(unitType)
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
local Trail = CreateFrame("Frame", "ConsolePortCursorTrail", UIParent)
Trail:SetFrameStrata("TOOLTIP")
Trail:SetSize(24,24)
Trail.Texture = Trail:CreateTexture(nil, "OVERLAY", nil, 7)
Trail.Texture:SetAllPoints(Trail)

function Trail:OnUpdate()
	local posX, posY = GetCursorPosition()
	self:SetPoint("BOTTOMLEFT", posX+24, posY-46)
	if isTargeting then
		if not self.isTargeting then
			self.Texture:SetTexture(TEXTURE.CP_T_L3)
			self.isTargeting = true
		end
		self:SetAlpha(1)
	elseif GameTooltip:GetOwner() == UIParent and not cameraMode then
		if self.isTargeting then
			self.Texture:SetTexture(self.Default)
			self.isTargeting = nil
		end
		self:SetAlpha(GameTooltip:GetAlpha())
		self.default = true
	else
		self:SetAlpha(0)
	end
end

---------------------------------------------------------------
-- Toggle interactive mouse driver on/off
---------------------------------------------------------------
function Core:UpdateMouseDriver()
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

			Trail.Default = TEXTURE[button]
			Trail.Targeting = TEXTURE.CP_T_L3
			Trail.Texture:SetTexture(Trail.Default)
			Trail:SetScript("OnUpdate", Trail.OnUpdate)
			Trail:Show()

			Mouse.Button:SetTexture(db.TEXTURE[db.Settings.interactWith])

			RegisterStateDriver(Mouse, "targetstate", targetstate)
			Mouse:SetAttribute("target", currentTarget)

			self:RegisterSpellHeader(Mouse)

			Mouse:Execute(format([[
				USE = "%s"
				id = %d
				self:Run(UpdateTarget, self:GetAttribute("target"))
				self:SetAttribute("target", nil)
			]], button, id or -1))
		else
			Trail:SetScript("OnUpdate", nil)
			Trail:Hide()

			Mouse:Execute([[
				self:ClearBindings()
			]])

			UnregisterStateDriver(Mouse, "targetstate")
			self:UnregisterSpellHeader(Mouse)

		end
		self:RemoveUpdateSnippet(self.UpdateMouseDriver)
	end
end