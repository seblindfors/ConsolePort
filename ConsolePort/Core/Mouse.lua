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
local 	GetMouseFocus, HasCursorItem, SpellIsTargeting, IsMouseButtonDown, IsMouselooking = 
		GetMouseFocus, GetCursorInfo, SpellIsTargeting, IsMouseButtonDown, IsMouselooking
---------------------------------------------------------------
-- Highlight functions
local 	HighlightStart, HighlightStop = 
		TargetPriorityHighlightStart, TargetPriorityHighlightEnd
---------------------------------------------------------------
-- Mouse functions
local 	UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, UnitIsUnit, CanLootUnit, GetCursorPosition, GetScreenWidth, SetPortrait, SetCVar = 
		UnitGUID, UnitIsDead, UnitCanAttack, UnitExists, UnitIsUnit, CanLootUnit, GetScaledCursorPosition, GetScreenWidth, SetPortraitTexture, SetCVar
---------------------------------------------------------------
local 	Camera, numTap, modTap, timer, interactPushback, highlightTimer = ConsolePortCamera, 0, 0, 0, 0, 0
---------------------------------------------------------------
local blockCursor, cameraMode, isMouseDown, isCentered, isOutside, isTargeting, hasItem, hasWorldFocus, wasMouseLooking
---------------------------------------------------------------
-- Extended API:
---------------------------------------------------------------
local function CanInteractGUID(guid)
	if guid then return select(2, CanLootUnit(guid)) end -- returns true if in range
end

local function CanInteract(unit)
	if unit then return CanInteractGUID(UnitGUID(unit)) end
end

local function CanInteractOrLoot(guid)
	if guid then local int, loot = CanLootUnit(guid) return int or loot end
end

local function UnitIsGUID(unit, queryGUID)
	local guid = unit and UnitGUID(unit)
	return (guid == queryGUID)
end
---------------------------------------------------------------

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

local yawDeadZone, yawSmoothOut, yawSmoothIn, yawMaxAngle
do
	local viewPortCenter, mousePos, offset, newAngle
	local FlipCameraYaw, yawFlipped = FlipCameraYaw, .0

	local function AdjustCameraYaw(yawOffset, actionCamOffset)
		FlipCameraYaw(yawOffset)
		SetCVar('test_cameraOverShoulder', -actionCamOffset * (actionCamOffset > 0 and .25 or .15))
	end

	function Camera:CalculateYaw()
		if not cameraMode then
			viewPortCenter = ( GetScreenWidth() / 2 )
			mousePos = GetCursorPosition()
			offset = - ( ( mousePos - viewPortCenter ) / 360 )
			if abs(offset) > yawDeadZone then
				newAngle = yawFlipped + (offset * yawSmoothIn)
				if newAngle < yawMaxAngle and newAngle > -yawMaxAngle then
					yawFlipped = newAngle
					AdjustCameraYaw(offset * yawSmoothIn, yawFlipped)
				end
			end
		elseif yawFlipped ~= 0 then
			offset = -yawFlipped * yawSmoothOut
			yawFlipped = yawFlipped + offset
			AdjustCameraYaw(offset, yawFlipped)
			if abs(yawFlipped) < .5 then
				AdjustCameraYaw(-yawFlipped, 0)
				yawFlipped = 0
			end
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
		if not UnitExists('target') then
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

function Camera:OnModifierChanged(_, modifier, down)
	if down == 1 then
		if modifier then
			timer = 0
			numTap = modTap == modifier and numTap + 1 or 1
			modTap = modifier
		end
	end
end

function Camera:OnAction() interactPushback = ( Settings.interactWith and (Settings.interactPushback or 1) ) or 0 end

function Camera:OnInteract()
	local guid, canInteract = UnitGUID('target')
	if guid then
		canInteract = CanInteractOrLoot(guid) or GetCVar('autoInteract') == '1'
	end
	if canInteract then
		blockCursor = true
		Camera:Start()
	else
		Camera:Stop()
	end
end

function Camera:OnStop() if blockCursor then blockCursor = nil Camera:Start() end end
function Camera:OnRightClick() if interactPushback > 0 then Camera:Start() else blockCursor = nil end end

function Camera:OnLeftClickDown()
	if Camera.lookAround then
		wasMouseLooking = IsMouselooking()
		if wasMouseLooking then
			Camera:Stop()
		end
	end
end

function Camera:OnLeftClickUp()
	if wasMouseLooking and Camera.lookAround and not isTargeting then
		Camera:Start()
	end
	wasMouseLooking = nil
end

-----------------------------------------------------------------------
-- Function hooks to create custom mouselook triggers without any event
-----------------------------------------------------------------------
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

	Camera:SetScript('OnEvent', nil)
	Camera:SetScript('OnUpdate', Camera.OnUpdate)
	Camera:UnregisterEvent('MODIFIER_STATE_CHANGED')

	Camera.Locker:SetSize(Settings.centerLockRangeX or 70, Settings.centerLockRangeY or 180)
	Camera.Deadzone:SetSize(Settings.centerLockDeadzoneX or 4, Settings.centerLockDeadzoneY or 4)

	numTap, modTap, timer, interactPushback, highlightTimer = 0, 0, 0, 0, 0
	Camera.lookAround = nil

	if not Settings.disableSmartMouse then
		Camera:HookScript('OnUpdate', Camera.CheckCursor)

		if Settings.doubleModTap then
			Camera.modTapWindow = db.Settings.doubleModTapWindow or 0.25
			Camera:SetScript('OnEvent', Camera.OnModifierChanged)
			Camera:RegisterEvent('MODIFIER_STATE_CHANGED')
		end

		local dynamicYaw
		if db.Mouse.Camera then
			Camera.lookAround = db.Mouse.Camera.lookAround
			dynamicYaw = db.Mouse.Camera.calculateYaw
		end

		if dynamicYaw then
			yawDeadZone  = Settings.cameraYawDeadzone 	or .8
			yawSmoothOut = Settings.cameraYawSmoothOut 	or .085
			yawSmoothIn  = Settings.cameraYawSmoothIn 	or .155
			yawMaxAngle  = Settings.cameraYawMaxAngle 	or 30
		end

		for _, script in pairs({
			-- trigger when cursor is centered
			Settings.mouseOnCenter and Camera.CheckCenter,
			-- trigger when cursor is at the edge of the screen
			Settings.preventMouseDrift and Camera.CheckEdge,
			-- trigger when double tapping a modifier
			Settings.doubleModTap and Camera.CheckDoubleTap,
			-- rotate yaw dynamically when cursor is out
			(dynamicYaw) and Camera.CalculateYaw,
		}) do
			if script then
				Camera:HookScript('OnUpdate', script)
			end
		end
	end

	if Settings.alwaysHighlight == 1 then
		Camera:HookScript('OnUpdate', Camera.HighlightNoTarget)
	elseif Settings.alwaysHighlight == 2 then
		Camera:HookScript('OnUpdate', Camera.HighlightAlways)
	end
	Camera.lockOnLoot = db.Mouse.Events.LOOT_OPENED
end

---------------------------------------------------------------
-- This handle is used to determine whether a dedicated button
-- should be used to cast spells or to interact with mouseover.
-- The behaviour alters itself depending on whether the button
-- is bound to a healing spell, harmful spell or binding.
---------------------------------------------------------------
local Mouse = ConsolePortMouseHandle
Mouse:Execute([[ id, isEnabled = 0, true ]])
Mouse.FadeInRef, Mouse.FadeOutRef = db.GetFaders()
Mouse.Line:SetTexture(1243535)
Mouse.Line:SetVertexColor(1, .75, .75)

for name, script in pairs({
	_onattributechanged = [[
		if name == 'state-targetstate' then
			self:RunAttribute('UpdateTarget', value)
		elseif name == 'state-vehicle' then
			self:RunAttribute('UpdateVehicle', value)
		elseif name == 'blockhandle' then
			isEnabled = not value
			if not isEnabled then
				self:ClearBindings()
				self:CallMethod('TrackUnit', nil, true)
			else
				self:RunAttribute('UpdateTarget', target)
			end
		end
	]],
	UpdateVehicle = [[
		inVehicle = ...
		if inVehicle then
			self:ClearBindings()
		else
			self:RunAttribute('UpdateTarget', target)
		end
	]],
	Clear = [[
		local clearType = ...
		if clearType then
			local key = GetBindingKey(clearType)
			if key then
				self:ClearBinding(key)
			end
		end
	]],
	Set = [[
		local setType, binding = ...
		if setType and binding then
			local key = GetBindingKey(setType)
			if key then
				self:SetBinding(true, key, binding)
			end
		end
	]],
	UpdateTarget = [[
		target = ...
		self:SetAttribute('current', target)
		self:SetAttribute('npc', nil)
		self:ClearBindings()

		if inVehicle or not isEnabled then return end

		local interact, loot, npc

		if ( target == 'hover' ) then
			interact = true
			if checkNPC and ( not PlayerCanAttack('mouseover') and not PlayerCanAssist('mouseover') ) then
				self:SetAttribute('npc', true)
			end
		elseif checkNPC and ( target == 'friend' and not PlayerCanAssist('target') ) then
			target = 'npc'
			npc = true
		elseif ( target == 'enemy' or target == 'friend' ) then
			if 	( target == 'friend' and self:RunAttribute('IsHarmfulAction', id) ) or
				( target == 'enemy' and self:RunAttribute('IsHelpfulAction', id) ) then
				interact = true
			end
		elseif target == 'loot' then
			loot = true
		else
			interact = true
		end

		if (( interact or loot or npc ) and USEKEY) or (loot and LOOTKEY) then
			if loot and LOOTKEY then
				self:RunAttribute('Set', LOOTKEY, 'INTERACTTARGET')
			end

			self:RunAttribute('Set', USEKEY, ( (loot or npc) and 'INTERACTTARGET' or 'TURNORACTION' ) )

		end
		self:CallMethod('TrackUnit', target)
	]],
}) do Mouse:SetAttribute(name, script) end

---------------------------------------------------------------
-- Display functions
---------------------------------------------------------------

function Mouse:FadeIn(speed)
	if self.fade ~= 'in' then
		self:FadeInRef(speed or 0.1, self:GetAlpha(), 1)
		self.fade = 'in'
	end
end

function Mouse:FadeOut(speed)
	if self.fade ~= 'out' then
		self:FadeOutRef(speed or 0.2, self:GetAlpha(), 0)
		self.fade = 'out'
	end
end

function Mouse:SetPortrait(unit)
	SetPortrait(self.Portrait, unit)
end

function Mouse:TogglePortrait(enabled)
	self.Portrait:SetAlpha(enabled and 1 or 0)
	self.PortraitMask:SetAlpha(enabled and 1 or 0)
end

function Mouse:UpdateMouseover()
	SetPortrait(self.Portrait, 'mouseover')
end

function Mouse:SetIcon(icon)
	self.Button:SetTexture(ICONS[icon])
end

---------------------------------------------------------------
-- Insecure override wrappers
---------------------------------------------------------------

function Mouse:HasInsecureOverride()
	return self.insecureOverrideActive
end

function Mouse:ToggleInsecureOverride(enabled, key, binding)
	if enabled and not Core:HasUIFocus() then
		self.insecureOverrideActive = true
		SetOverrideBinding(self, true, key, binding)
	else
		self.insecureOverrideActive = false
		ClearOverrideBindings(self)
	end
end

function Mouse:SetOverride(binding, bindingID)
	if not InCombatLockdown() then
		local key = bindingID and GetBindingKey(bindingID)
		if key then
			self:ToggleInsecureOverride(true, key, binding)
			if binding then
				self:RegisterEvent('PLAYER_REGEN_DISABLED')
				self:SetScript('OnEvent', self.ClearOverride)
				self:SetIcon(bindingID)
			else
				self:UnregisterEvent('PLAYER_REGEN_DISABLED')
				self:SetScript('OnEvent', nil)
			end
		end
	end
end

function Mouse:ClearOverride()
	if not InCombatLockdown() then
		self:ToggleInsecureOverride(false)
		self:SetIcon(self.interactWith)
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
		self:SetScript('OnEvent', nil)
	end
end

function Mouse:ClearScriptOverride()
	if ( self.override == self.interactWith ) then
		-- if the full interact button is enabled, any OnUpdate script
		-- should revert to TURNORACTION, else just clear.
		self:SetOverride('TURNORACTION', self.override)
	else
		self:ClearOverride()
	end
end

---------------------------------------------------------------
-- OnUpdate scripts:
-- 	CheckLoot: visual in range indicator (secure)
--	CheckNPC: visual in range indicator (secure)
--	CheckHover: visual in range indicator (secure)
--	CheckLootOverride: last hostile loot override (insecure)
--	CheckArtificial: smart interaction override (insecure)
---------------------------------------------------------------
function Mouse:CheckLoot(elapsed)
	local guid, hasLoot, canLoot = UnitGUID('target')
	if guid then
		hasLoot, canLoot = CanLootUnit(guid)
	end
	if hasLoot and canLoot then
		self:SetOverride('INTERACTTARGET', self.override)
		self.Text:SetText(LOOT)
		self:FadeIn()
	else
		if self.override then
			self:SetOverride(nil, self.override)
		end
		self:FadeOut()
		if not hasLoot then
			self:SetScript('OnUpdate', nil)
		end
	end
end

function Mouse:CheckNPC(elapsed)
	local canInteract = CanInteract('target')
	if ( canInteract ) and not ( UnitExists('npc') or UnitExists('questnpc') ) then
		if canInteract then
			self.Text:SetText(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
		end
		self:FadeIn()
	else
		self:FadeOut()
	end
end

function Mouse:CheckHover(elapsed)
	local guid, hasLoot, canLoot = UnitGUID('mouseover')
	local exists = UnitExists('mouseover')
	local isDead, isEnemy = UnitIsDead('mouseover'), UnitCanAttack('player', 'mouseover')
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
	self:FadeIn()
end

function Mouse:CheckLootOverride(elapsed)
	local hasLoot, canLoot = CanLootUnit(self.cachedUnit)
	if hasLoot and canLoot then
		self:SetOverride('TARGETLASTHOSTILE', self.override)
		self.Text:SetText(LOOT)
		self:FadeIn()
	else
		self:ClearScriptOverride()
		self:FadeOut()
		if not hasLoot then
			self:SetScript('OnUpdate', nil)
		end
	end
end

function Mouse:CheckArtificial(elapsed)
	local canInteract = CanInteractGUID(self.artificial)
	if canInteract then
		local guidMatch = UnitIsGUID('target', self.artificial)
		local isCurrentNPC = UnitIsUnit('target', 'npc') or UnitIsUnit('target', 'questnpc')
		if isCurrentNPC then
			self:ClearOverride()
			self:FadeOut()
			return
		elseif guidMatch then
			self:SetOverride('INTERACTTARGET', self.override)
			self.Text:SetText(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
		elseif not CanInteract('target') then
			self:SetOverride('CLICK ConsolePortTargetAI:LeftButton', self.override)
			self.Text:SetText(self.artificialName)
		end
		self:FadeIn()
	else
		self:ClearScriptOverride()
		self:FadeOut()
		self:SetScript('OnUpdate', nil)
	end
end

---------------------------------------------------------------
-- Tracking helpers
---------------------------------------------------------------

function Mouse:SetArtificialUnit(guid, name)
	self.artificial = guid
	self.artificialName = name
	if guid and name and not UnitExists('target') then
		self:TrackUnit(self.fauxUnit, self:GetAttribute('blockhandle'))
	end
end

function Mouse:CacheUnit(unit, fauxUnit)
	local newGUID = UnitGUID(unit)
	if newGUID then
		self.cachedUnit = newGUID
		self:SetPortrait(unit)
	end
	self.fauxUnit = fauxUnit
end

function Mouse:PrepareTracking()
	self:SetScript('OnUpdate', nil)
	self:SetScript('OnEvent', nil)
	self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
	self:TogglePortrait(true)
	self:SetIcon(self.interactWith)
end

-- Workaround: loot is not always available right away.
function Mouse:FindLootFromCache(delay, dispatcherCallback)
	if 	self.cachedUnit
		and not InCombatLockdown() 
		and not self:GetAttribute('blockhandle')
		and not UnitExists('target')
		and CanLootUnit(self.cachedUnit) then
		--------------------------------------------------
		return CanLootUnit(self.cachedUnit)
		--------------------------------------------------
	elseif dispatcherCallback then
		self:DispatchLootCheck(delay, self.lootCheckSpool, false)
	end
end

-- Since there's no event indicating when a GUID has loot,
-- this function needs to query the game multiple times with some delay.
function Mouse:DispatchLootCheck(delay, numCalls, firstCall)
	self.lootCheckSpool = (firstCall and numCalls) or (numCalls - 1)
	if self.lootCheckSpool < 1 then return end
	--------------------------------------------------
	C_Timer.After(delay, function()
		if self:FindLootFromCache(delay, true) then
			--------------------------------------------------
			self:SetIcon(self.override or self.interactWith)
			self:SetScript('OnUpdate', self.CheckLootOverride)
			--------------------------------------------------
		end
	end)
end

function Mouse:TrackUnit(fauxUnit, blocked, forceCache)
	self:CacheUnit(forceCache or 'target', fauxUnit)
	self:PrepareTracking()
	-- loot: existing dead target, assigned securely.
	if ( fauxUnit == 'loot' ) then
		self:SetIcon(self.override or self.interactWith)
		self:SetScript('OnUpdate', self.CheckLoot)
	-- npc: existing friendly npc, assigned securely.
	elseif ( fauxUnit == 'npc' ) then
		self:SetScript('OnUpdate', self.CheckNPC)
	-- hover: mouseover priority, assigned securely.
	elseif ( fauxUnit == 'hover' ) then
		self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
		self:SetScript('OnEvent', self.UpdateMouseover)
		self:SetScript('OnUpdate', self.CheckHover)
		self:SetPortrait('mouseover')
		if not UnitCanAssist('player', 'mouseover') and not UnitCanAttack('player', 'mouseover') then
			self:TogglePortrait(false)
		end
	-- in proximity of tracked GUID, check proximity (insecure).
	elseif ( not blocked and self.artificial ) then
		-- artificial unit might stand next to lootable mob
		local hasLoot, canLoot = self:FindLootFromCache()
		if ( hasLoot and canLoot ) then
			self:SetIcon(self.override or self.interactWith)
			self:SetScript('OnUpdate', self.CheckLootOverride)
		else -- proceed with artificial unit
			self:SetIcon(self.override or self.interactWith)
			self:SetScript('OnUpdate', self.CheckArtificial)
		end
		self:TogglePortrait(false)
	else -- cached last target might have loot, check proximity (insecure).
		if ( not blocked and self.cachedUnit ) then
			self:DispatchLootCheck(.35, 20, true)
		end
		self:TogglePortrait(false)
		self:FadeOut()
	end
end

---------------------------------------------------------------
-- Cursor trail for interact button
---------------------------------------------------------------
local Trail = ConsolePortCursorTrail

function Trail:ResetStates()
	self.Use:SetTexture()
	self.Cancel:SetTexture()
	self.Primary:SetTexture()
	self.Secondary:SetTexture()
	self.isMouseOver = nil
	self.isTargeting = nil
	self.hasItem = nil
	self.default = true
end

function Trail.OnAction(action)
	local self = Trail
	if SpellIsTargeting() and not self.isTargeting then
		self:ResetStates()
		self.isTargeting = true
		self.default = nil
		self.Use:SetTexture(GetActionTexture(action) or 'Interface\\RAIDFRAME\\ReadyCheck-Ready')
		self.Primary:SetTexture(db.ICONS.CP_T_L3)
		if GetBindingAction('BUTTON2', true) == 'TURNORACTION' then
			self.Secondary:SetTexture(db.ICONS.CP_T_R3)
			self.Cancel:SetTexture('Interface\\RAIDFRAME\\ReadyCheck-NotReady')
		else
			self.Secondary:SetTexture()
			self.Cancel:SetTexture()
		end
	else
		self.isTargeting = nil
	end
end

function Trail.OnItemAdd()
	local self = Trail
	self:ResetStates()
	self.hasItem = true
	if GetBindingAction('BUTTON1', true) == 'CAMERAORSELECTORMOVE' then
		self.Primary:SetTexture(db.ICONS.CP_T_L3)
		self.Use:SetTexture('Interface\\RAIDFRAME\\ReadyCheck-NotReady')
	end
end

function Trail.OnTooltipAdd(_, owner)
	local self = Trail
	if not hasItem and not isTargeting then
		if owner == UIParent then
			self:ResetStates()
			self.isMouseOver = true
			self.Primary:SetTexture(self.Default)
		else
			self.isMouseOver = nil
		end
	end
end

function Trail.OnTooltipClear()
	Trail.isMouseOver = nil
end

function Trail:ShowPrimaryTextures(toggled)
	self.Ghost:SetShown(not toggled)
	self.Use:SetShown(toggled)
	self.Cancel:SetShown(toggled)
	self.Primary:SetShown(toggled)
	self.Secondary:SetShown(toggled)
end

function Trail:OnUpdate()
	local posX, posY = GetCursorPosition()
	self:SetPoint('BOTTOMLEFT', posX+24, posY-46)
	self:ShowPrimaryTextures(true)
	if ( self.isTargeting and isTargeting ) then
		self:SetAlpha(1)
	elseif ( self.hasItem and hasItem ) then
		if hasWorldFocus and not self.hasWorldFocus then
			self.hasWorldFocus = true
			self.Use:SetTexture('Interface\\RAIDFRAME\\ReadyCheck-NotReady')
		elseif not hasWorldFocus and self.hasWorldFocus then
			self.hasWorldFocus = nil
			self.Use:SetTexture('Interface\\RAIDFRAME\\ReadyCheck-Ready')
		end
		self:SetAlpha(1)
	elseif self.isMouseOver and not cameraMode then
		self:SetAlpha(GameTooltip:GetAlpha())
	elseif self.ghostMode and cameraMode then
		self:ShowPrimaryTextures(false)
		self:SetAlpha(self.ghostAlpha or .25)
	else
		self:SetAlpha(0)
	end
end

-- Hooks
hooksecurefunc('UseAction', Trail.OnAction)
hooksecurefunc('PickupContainerItem', Trail.OnItemAdd)
hooksecurefunc('PickupSpell', Trail.OnItemAdd)
hooksecurefunc(GameTooltip, 'SetOwner', Trail.OnTooltipAdd)
GameTooltip:HookScript('OnTooltipCleared', Trail.OnTooltipClear)

---------------------------------------------------------------
-- Toggle interactive mouse driver on/off
---------------------------------------------------------------
function Core:UpdateMouseDriver()
	if not InCombatLockdown() then
		local loot = db.Settings.lootWith
		local button = db.Settings.interactWith
		if button then
			local original = db.Bindings and db.Bindings[button] and db.Bindings[button]['']
			local id = original and self:GetActionID(original)

			local targetstate = 
				'[@mouseover,exists] hover; ' ..
				'[@target,exists,harm,dead] loot; ' .. 
				'[@target,exists,harm,nodead] enemy; ' ..
				'[@target,exists,noharm,nodead] friend; nil'

			Trail.Default = ICONS[button]
			Trail.Primary:SetTexture(Trail.Default)

			Mouse.Button:SetTexture(ICONS[button])

			RegisterStateDriver(Mouse, 'vehicle', '[petbattle][vehicleui][overridebar][possessbar] true; nil')
			RegisterStateDriver(Mouse, 'targetstate', targetstate)

			Mouse:SetAttribute('checkNPC', db.Settings.interactNPC)

			Mouse.override = loot or button
			Mouse.interactWith = button

			self:RegisterSpellHeader(Mouse)

			Mouse:Execute(format([[
				USEKEY = %s
				LOOTKEY = %s
				id = %d
				checkNPC = self:GetAttribute('checkNPC')
				self:RunAttribute('UpdateTarget', self:GetAttribute('current'))
			]], ('"%s"'):format(button), ( loot and ('"%s"'):format(loot)) or 'nil', id or -1))


		else
			Trail.Default = ICONS.CP_T_R3

			Mouse.interactWith = nil

			Mouse:Execute([[
				USEKEY = nil
				LOOTKEY = nil
				checkNPC = nil
				self:ClearBindings()
			]])

			if loot then
				Mouse.override = loot
				-- use 'omit' here just to trigger an update without flagging interaction.
				RegisterStateDriver(Mouse, 'targetstate', '[@target,exists,harm,dead] loot; [@target,exists,harm] omit; nil')
				RegisterStateDriver(Mouse, 'vehicle', '[petbattle][vehicleui][overridebar] true; nil')

				Mouse:Execute(format([[
					LOOTKEY = '%s'
					self:RunAttribute('UpdateTarget', self:GetAttribute('current'))
				]], loot))
			else
				Mouse.override = nil
				UnregisterStateDriver(Mouse, 'targetstate')
				UnregisterStateDriver(Mouse, 'vehicle')
			end
		end
		ConsolePortTargetAI:SetShown(loot or button and db('interactCache'))
		------------------------------------------------
		Trail.ghostMode = db('cursorTrailGhost')
		Trail.ghostAlpha = db('cursorTrailGhostVis')
		Trail.Ghost:SetTexture(db('cursorTrailGhostTex'))
		Trail.Ghost:SetShown(db('cursorTrailGhost'))
		Trail:SetScript('OnUpdate', Trail.OnUpdate)
		Trail:SetShown(not db('disableCursorTrail'))
		------------------------------------------------
		Mouse:SetPoint('BOTTOM', 0, db('interactHintPosition'))
		Mouse.Line:SetShown(not db('interactHintNoLine'))
		Mouse.Line:SetAlpha(db('interactHintLineVis'))
		self:RemoveUpdateSnippet(self.UpdateMouseDriver)
	end
end