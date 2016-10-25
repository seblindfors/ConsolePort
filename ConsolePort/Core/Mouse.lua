---------------------------------------------------------------
-- Mouse.lua: Smart camera control and mouse function wrappers
---------------------------------------------------------------
-- Removes the need of holding right click to control camera.
-- Allows user to mouseover their character to control camera.
-- Toggles off on targeted spells, InteractUnit and pickups.

local _, db = ...
---------------------------------------------------------------
local TEXTURE, ICONS, Settings = db.TEXTURE, db.ICONS
---------------------------------------------------------------
local 	WorldFrame, UIParent, GameTooltip, Core = 
		WorldFrame, UIParent, GameTooltip, ConsolePort
---------------------------------------------------------------
-- Camera functions
local 	GetMouseFocus, HasCursorItem, SpellIsTargeting, IsMouseButtonDown, IsMouselooking, FlipCameraYaw = 
		GetMouseFocus, GetCursorInfo, SpellIsTargeting, IsMouseButtonDown, IsMouselooking, FlipCameraYaw
---------------------------------------------------------------
-- Highlight functions
local 	HighlightStart, HighlightStop = 
		TargetPriorityHighlightStart, TargetPriorityHighlightEnd
---------------------------------------------------------------
-- Mouse functions
local 	UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, CanLootUnit, GetCursorPosition, SetPortrait, SetCVar = 
		UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, CanLootUnit, GetScaledCursorPosition, SetPortraitTexture, SetCVar
---------------------------------------------------------------
local 	Camera, numTap, modTap, timer, interactPushback, highlightTimer =
		CreateFrame("Frame", "ConsolePortCamera", UIParent), 0, 0, 0, 0, 0
Camera.Start = MouselookStart
Camera.Stop = MouselookStop
---------------------------------------------------------------
Camera.Locker = CreateFrame("Frame", "$parentLocker", Camera)
Camera.Locker:SetPoint("CENTER", UIParent, 0, 0)
Camera.Locker:Hide()
---------------------------------------------------------------
Camera.Edge = CreateFrame("Frame", "$parentEdge", Camera)
Camera.Edge:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50)
Camera.Edge:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 50)
Camera.Edge:Hide()
---------------------------------------------------------------
Camera.Deadzone = CreateFrame("Frame", "$parentDeadzone", Camera)
Camera.Deadzone:SetPoint("CENTER", UIParent, 0, 0)
Camera.Deadzone:Hide()
---------------------------------------------------------------
Camera.BlockUI = CreateFrame("Frame", "ConsolePortUIBlocker", UIParent)
Camera.BlockUI:SetAllPoints()
Camera.BlockUI:SetFrameStrata("FULLSCREEN_DIALOG")
Camera.BlockUI:EnableMouse(true)
Camera.BlockUI:Hide()
---------------------------------------------------------------
local blockCursor, cameraMode, isMouseDown, isCentered, isOutside, isTargeting, hasItem, hasWorldFocus, wasMouseLooking

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
	---------------
	interactPushback = interactPushback > 0 and interactPushback - elapsed or 0
end

local yawFlipped = 0
local deadzone = 0.85
local smooth = 0.075
local reset = 0.5
function Camera:CalculateYaw()
	if isTargeting then
		local viewPortCenter = ( UIParent:GetWidth() / 2 )
		local x, y = GetCursorPosition()
		local offset = - ( ( x - viewPortCenter ) / 360 )
		if abs(offset) > deadzone then
			local newAngle = yawFlipped + offset
			if newAngle < 90 and newAngle > -90 then
				yawFlipped = newAngle
				FlipCameraYaw(offset)
			end
		end
	elseif yawFlipped ~= 0 then
		local offset = -yawFlipped * smooth
		yawFlipped = yawFlipped + offset
		FlipCameraYaw(offset)
		if abs(yawFlipped) < reset then
			FlipCameraYaw(-yawFlipped)
			yawFlipped = 0
		end
	end
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
	timer = timer + elapsed
	if numTap > 1 then
		self:Toggle()
		modTap = 0
		numTap = 0
	end
	if timer > self.modTapWindow then
		numTap = numTap > 0 and numTap - 1 or 0
		timer = timer - self.modTapWindow
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
	highlightTimer = highlightTimer + elapsed
	if highlightTimer > 3 then
		if not UnitExists("target") then
			HighlightStart()
		end
		highlightTimer = highlightTimer - 3
	end
end

function Camera:HighlightAlways(elapsed)
	highlightTimer = highlightTimer + elapsed
	if highlightTimer > 3 then
		HighlightStart()
		highlightTimer = highlightTimer - 3
	end
end

function Camera:OnEvent(_, ...)
	local modifier, down = ...
	if down == 1 then
		if modifier then
			timer = 0
			numTap = modTap == modifier and numTap + 1 or 1
			modTap = modifier
		end
	end
end

function Camera:OnAction() interactPushback = Settings.interactPushback or 1 end

function Camera:OnInteract()
	local guid, canInteract = UnitGUID("target")
	if guid then
		canInteract = CanLootUnit(guid) or GetCVar("autoInteract") == "1"--CheckInteractDistance("target", 5)
	end
	if canInteract then
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

function Camera:OnRightClick()
	if interactPushback > 0 then
		Camera:Start()
	else
		blockCursor = nil
	end
end

function Camera:OnLeftClickDown()
	if db.Settings.lookAround then
		wasMouseLooking = IsMouselooking()
		if wasMouseLooking then
			Camera:Stop()
		end
	end
end

function Camera:OnLeftClickUp()
	if wasMouseLooking and db.Settings.lookAround and not isTargeting then
		Camera:Start()
	end
	wasMouseLooking = nil
end

-- Function hooks to address event-less would-be mouse events
for func, hook in pairs({
	-- Get rid of mouselook when trying to interact with mouse
	MouselookStop = Camera.OnStop,
	-- InteractUnit removes mouse look, restart if target has loot
	InteractUnit = Camera.OnInteract,
	-- Releasing 'right click' should remove the cursor block
	TurnOrActionStop = Camera.OnRightClick,
	-- Pressing left click should remove mouse look if configured
	CameraOrSelectOrMoveStart = Camera.OnLeftClickDown,
	-- Releasing left click should restart the camera if configured
	CameraOrSelectOrMoveStop = Camera.OnLeftClickUp,
	-- Hook jump to use it as a camera trigger
	JumpOrAscendStart = Camera.OnJump,
	-- Get rid of mouselook when moving the pet
	PetMoveTo = Camera.Stop,
	-- Hook action usage to manipulate mouselook
	UseAction = Camera.OnAction, 
}) do hooksecurefunc(func, hook) end

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

	Camera.Locker:SetSize(Settings.centerLockRangeX or 70, Settings.centerLockRangeY or 180)
	Camera.Deadzone:SetSize(Settings.centerLockDeadzoneX or 4, Settings.centerLockDeadzoneY or 4)

	numTap, modTap, timer, interactPushback, highlightTimer = 0, 0, 0, 0, 0

	if not Settings.disableSmartMouse then
		Camera:HookScript("OnUpdate", Camera.CheckCursor)

		if Settings.mouseOnCenter then
			Camera:HookScript("OnUpdate", Camera.CheckCenter)
		end
		if Settings.preventMouseDrift then
			Camera:HookScript("OnUpdate", Camera.CheckEdge)
		end
		if Settings.doubleModTap then
			Camera.modTapWindow = db.Settings.doubleModTapWindow or 0.25
			Camera:SetScript("OnEvent", Camera.OnEvent)
			Camera:RegisterEvent("MODIFIER_STATE_CHANGED")
			Camera:HookScript("OnUpdate", Camera.CheckDoubleTap)
		end
		if Settings.calculateYaw then
			Camera:HookScript("OnUpdate", Camera.CalculateYaw)
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
Mouse:Execute([[ id, isEnabled = 0, true ]])
Mouse:SetAttribute("_onattributechanged", [[
	if name == "state-targetstate" then
		self:RunAttribute("UpdateTarget", value)
	elseif name == "state-vehicle" then
		self:RunAttribute("_onstate-vehicle", value)
	elseif name == "override" then
		isEnabled = value
		if not isEnabled then
			self:ClearBindings()
		else
			self:RunAttribute("UpdateTarget", target)
		end
	end
]])
Mouse:SetAttribute("_onstate-vehicle", [[
	inVehicle = newstate
	if inVehicle then
		self:ClearBindings()
	else
		self:RunAttribute("UpdateTarget", target)
	end
]])
Mouse:SetAttribute("UpdateTarget", [[
	target = ...
	self:SetAttribute("current", target)
	self:SetAttribute("npc", nil)

	if inVehicle or not isEnabled then return end

	local interact, loot, npc

	if ( target == "hover" ) then
		interact = true
		if checkNPC and ( not PlayerCanAttack("mouseover") and not PlayerCanAssist("mouseover") ) then
			self:SetAttribute("npc", true)
		end
	elseif checkNPC and ( target == "friend" and not PlayerCanAssist("target") ) then
		target = "npc"
		npc = true
	elseif ( target == "enemy" or target == "friend" ) then
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

	if ( interact or loot or npc ) and USE then
		local key = GetBindingKey(USE)
		if key then
			if loot or npc then
				self:SetBinding(true, key, "INTERACTTARGET")
			else
				self:SetBinding(true, key, "TURNORACTION")
			end
		end
	end
	self:CallMethod("TrackUnit", target)
]])
---------------------------------------------------------------
local Focus = CreateFrame("Button", "$parentFocus", Mouse, "SecureActionButtonTemplate")
Focus:SetAttribute("type", "focus")
Focus:SetAttribute("unit", "mouseover")
Mouse:SetFrameRef("Focus", Focus)
Mouse:Execute([[ Focus = self:GetFrameRef("Focus") ]])
---------------------------------------------------------------
Mouse:SetPoint("CENTER", 0, -300)
Mouse:SetSize(300, 64)
Mouse:SetAlpha(0)

Mouse.Line = Mouse:CreateTexture("$parentLine", "ARTWORK")
Mouse.Line:SetAtlas("legioninvasion-title-bg")
Mouse.Line:SetPoint("BOTTOM")
Mouse.Line:SetSize(300, 100)
Mouse.Line:SetVertexColor(1, 0.75, 0.75)

Mouse.Text = Mouse:CreateFontString("$parentText", "OVERLAY", "MovieSubtitleFont")
Mouse.Text:SetPoint("CENTER", 0, 16)

Mouse.Button = Mouse:CreateTexture("$parentButton", "OVERLAY")
Mouse.Button:SetPoint("RIGHT", Mouse.Text, "LEFT", -15, 0)
Mouse.Button:SetSize(32, 32)

Mouse.Portrait = Mouse:CreateTexture("$parentPortrait", "ARTWORK", nil, 2)
Mouse.Portrait:SetPoint("LEFT", Mouse.Text, "RIGHT", 15, 0)
Mouse.Portrait:SetSize(32, 32)

Mouse.PortraitMask = Mouse:CreateTexture("$parentPortraitMask", "OVERLAY")
Mouse.PortraitMask:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask")
Mouse.PortraitMask:SetSize(32, 32)
Mouse.PortraitMask:SetPoint("CENTER", Mouse.Portrait, "CENTER", 0, 0)


Mouse.FadeIn = db.UIFrameFadeIn
Mouse.FadeOut = db.UIFrameFadeOut

function Mouse:SetAutoWalk(enabled)
	if self.autoInteract and enabled then
		SetCVar("autoInteract", 1)
	else
		SetCVar("autoInteract", 0)
	end
end

function Mouse:SetPortrait(unit)
	SetPortrait(self.Portrait, unit)
end

function Mouse:CheckLoot(elapsed)
	local alpha = self:GetAlpha()
	local guid, hasLoot, canLoot = UnitGUID("target")
	if guid then
		hasLoot, canLoot = CanLootUnit(guid)
	end
	if hasLoot and canLoot then
		self:SetAutoWalk(true)
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

function Mouse:CheckNPC(elapsed)
	local alpha = self:GetAlpha()
	local canMoveTo, canInteract = CheckInteractDistance("target", 4), CheckInteractDistance("target", 5)
	canMoveTo = canMoveTo and self.autoInteract

	if canInteract or canMoveTo then
		if canInteract then
			self.Text:SetText(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
		else
			self.Text:SetText(CLICK_TO_MOVE)
		end
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
	self:SetScript("OnUpdate", nil)
	self.Portrait:SetAlpha(1)
	self.PortraitMask:SetAlpha(1)
	self:SetAutoWalk(false)
	if ( unitType == "loot" ) then
		self:SetScript("OnUpdate", self.CheckLoot)
		self:SetPortrait("target")
	elseif ( unitType == "npc" ) then
		self:SetAutoWalk(true)
		self:SetScript("OnUpdate", self.CheckNPC)
		self:SetPortrait("target")
	elseif unitType == "hover" then
		self:SetAutoWalk(self:GetAttribute("npc"))
		self:SetScript("OnUpdate", self.CheckHover)
		self:SetPortrait("mouseover")
		if not UnitCanAssist("player", "mouseover") and not UnitCanAttack("player", "mouseover") then
			self.Portrait:SetAlpha(0)
			self.PortraitMask:SetAlpha(0)
		end 
	else
		self.Portrait:SetAlpha(0)
		self.PortraitMask:SetAlpha(0)
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
Trail:SetSize(32,32)
Trail.Texture = Trail:CreateTexture(nil, "OVERLAY", nil, 7)
Trail.Texture:SetAllPoints(Trail)
Trail.Icon = Trail:CreateTexture(nil, "OVERLAY")
Trail.Icon:SetPoint("LEFT", Trail, "RIGHT", -6, 0)
Trail.Icon:SetSize(24, 24)
Trail.Texture2 = Trail:CreateTexture(nil, "OVERLAY", nil, 7)
Trail.Texture2:SetSize(32, 32)
Trail.Texture2:SetPoint("TOP", Trail, "BOTTOM", 0, 10)
Trail.Icon2 = Trail:CreateTexture(nil, "OVERLAY")
Trail.Icon2:SetPoint("LEFT", Trail.Texture2, "RIGHT", -6, 0)
Trail.Icon2:SetSize(24, 24)

function Trail:ResetStates()
	self.Icon:SetTexture()
	self.Icon2:SetTexture()
	self.Texture:SetTexture()
	self.Texture2:SetTexture()
	self.isMouseOver = nil
	self.isTargeting = nil
	self.hasItem = nil
	self.default = true
end

function Trail.OnAction(...)
	local action = ...
	local self = Trail
	if SpellIsTargeting() then
		self:ResetStates()
		self.isTargeting = true
		self.default = nil
		self.Icon:SetTexture(GetActionTexture(action) or "Interface\\RAIDFRAME\\ReadyCheck-Ready")
		self.Texture:SetTexture(db.ICONS.CP_T_L3)
		if GetBindingAction("BUTTON2", true) == "TURNORACTION" then
			self.Texture2:SetTexture(db.ICONS.CP_T_R3)
			self.Icon2:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		else
			self.Texture2:SetTexture()
			self.Icon2:SetTexture()
		end
	else
		self.isTargeting = nil
	end
end

function Trail.OnItemAdd(...)
	local self = Trail
	self:ResetStates()
	self.hasItem = true
	if GetBindingAction("BUTTON1", true) == "CAMERAORSELECTORMOVE" then
		self.Texture:SetTexture(db.ICONS.CP_T_L3)
		self.Icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	end
end

function Trail.OnTooltipAdd(_, owner)
	local self = Trail
	if not hasItem and not isTargeting then
		if owner == UIParent then
			self:ResetStates()
			self.isMouseOver = true
			self.Texture:SetTexture(self.Default)
		else
			self.isMouseOver = nil
		end
	end
end

function Trail.OnTooltipClear()
	Trail.isMouseOver = nil
end

function Trail:OnUpdate()
	local posX, posY = GetCursorPosition()
	self:SetPoint("BOTTOMLEFT", posX+24, posY-46)
	if ( self.isTargeting and isTargeting ) then
		self:SetAlpha(1)
	elseif ( self.hasItem and hasItem ) then
		if hasWorldFocus and not self.hasWorldFocus then
			self.hasWorldFocus = true
			self.Icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		elseif not hasWorldFocus and self.hasWorldFocus then
			self.hasWorldFocus = nil
			self.Icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
		end
		self:SetAlpha(1)
	elseif self.isMouseOver and not cameraMode then
		self:SetAlpha(GameTooltip:GetAlpha())
	else
		self:SetAlpha(0)
	end
end

hooksecurefunc("UseAction", Trail.OnAction)
hooksecurefunc("PickupContainerItem", Trail.OnItemAdd)
hooksecurefunc("PickupSpell", Trail.OnItemAdd)
hooksecurefunc(GameTooltip, "SetOwner", Trail.OnTooltipAdd)
GameTooltip:HookScript("OnTooltipCleared", Trail.OnTooltipClear)

---------------------------------------------------------------
-- Toggle interactive mouse driver on/off
---------------------------------------------------------------
function Core:UpdateMouseDriver()
	if not InCombatLockdown() then
		SetCVar("autoInteract", 0)
		if db.Settings.interactWith then
			local button = db.Settings.interactWith
			local original = db.Bindings and db.Bindings[button] and db.Bindings[button][""]
			local id = original and self:GetActionID(original)

			local targetstate = "[@target,exists,harm,dead] loot; [@target,exists,harm,nodead] enemy; [@target,exists,noharm,nodead] friend; nil"

			if db.Settings.mouseOverMode then
				targetstate = "[@mouseover,exists] hover; "..targetstate
			end

			Trail.Default = ICONS[button]
			Trail.Targeting = ICONS.CP_T_L3
			Trail.Texture:SetTexture(Trail.Default)
			Trail:SetScript("OnUpdate", Trail.OnUpdate)
			Trail:Show()

			Mouse.Button:SetTexture(ICONS[db.Settings.interactWith])

			RegisterStateDriver(Mouse, "vehicle", "[petbattle][vehicleui][overridebar] true; nil")
			RegisterStateDriver(Mouse, "targetstate", targetstate)

			Mouse:SetAttribute("checkNPC", db.Settings.interactNPC)
			Mouse.autoInteract = db.Settings.interactAuto

			self:RegisterSpellHeader(Mouse)

			Mouse:Execute(format([[
				USE = "%s"
				id = %d
				checkNPC = self:GetAttribute("checkNPC")
				self:RunAttribute("UpdateTarget", self:GetAttribute("current"))
			]], button, id or -1))
		else
			Trail.Default = ICONS.CP_T_R3
			Trail.Targeting = ICONS.CP_T_L3

			Mouse.autoInteract = nil

			Mouse:Execute([[
				checkNPC = nil
				self:ClearBindings()
			]])

			UnregisterStateDriver(Mouse, "targetstate")
			UnregisterStateDriver(Mouse, "vehicle")
			self:UnregisterSpellHeader(Mouse)

		end
		Trail:SetScript("OnUpdate", Trail.OnUpdate)
		Trail:Show()
		self:RemoveUpdateSnippet(self.UpdateMouseDriver)
	end
end