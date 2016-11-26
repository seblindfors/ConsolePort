---------------------------------------------------------------
-- Utility.lua: Radial 8 button action bar  
---------------------------------------------------------------
-- Creates an 8 button action bar that can be populated with
-- items, spells, mounts, macros, etc. The user may manually
-- assign items from container buttons inside bag frames.
-- Action buttons can grab info from cursor.

---------------------------------------------------------------
local addOn, db = ...
---------------------------------------------------------------
local ConsolePort = ConsolePort
---------------------------------------------------------------
local FadeIn, FadeOut = db.UIFrameFadeIn, db.UIFrameFadeOut
local GetItemCooldown = GetItemCooldown
local InCombatLockdown = InCombatLockdown
---------------------------------------------------------------
local 	Utility, Tooltip, Animation, AniCircle = 
		CreateFrame("Frame", "ConsolePortUtilityFrame", UIParent, "SecureHandlerBaseTemplate, SecureHandlerStateTemplate"),
		CreateFrame("GameTooltip", "ConsolePortUtilityTooltip", ConsolePortUtilityFrame, "GameTooltipTemplate"),
		CreateFrame("Frame", "ConsolePortUtilityAnimation", UIParent),
		CreateFrame("Frame", "ConsolePortUtilityAnimationCircle", UIParent)
---------------------------------------------------------------
local ActionButtons, ButtonMixin = {}, {}
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()
local colMul = 1 + ( 1 - (( red + green + blue ) / 3) )
---------------------------------------------------------------
local NUM_BUTTONS = 8
local RADIAN_FRACTION = rad( 360 / NUM_BUTTONS )
local ANI_SPEED = 2
local ANI_SMOOTH = 1.35

function Animation:ShowNewAction(actionButton, autoAssigned)
	-- if an item was auto-assigned, postpone its animation until the current animation has finished
	if  autoAssigned and self.Group:IsPlaying() then
		local progress = self.Group:GetDuration() * self.Group:GetProgress()
		local delay = self.Group:GetDuration() - progress
		C_Timer.After(delay, function() self:ShowNewAction(actionButton, true) end)
		return
	end
	if actionButton.isQuest then
		self.Quest:Show()
	else
		self.Quest:Hide()
	end
	local x, y = actionButton:GetCenter()
	self.Icon:SetTexture(actionButton.icon.texture)
	self.Spell:SetSize(175, 175)
	self:ClearAllPoints()
	self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
	self:Show()
	self.Group:Stop()
	self.Group:Play()
	FadeOut(self.Spell, 3, 0.15, 0)

	if ConsolePortUtility[actionButton.ID] then
		local value = ConsolePortUtility[actionButton.ID].value
		local binding = ConsolePort:GetFormattedBindingOwner("CLICK ConsolePortUtilityToggle:LeftButton", nil, nil, true)
		if value then
			local string = binding and " "..binding or "."
			if value and not tonumber(value) then
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_NEWBIND, value, string), 3, -190)
			elseif binding then
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_BIND, binding), 3, -190)
			end
		end
	end

	local angle = -actionButton.angle
	AniCircle:Show()
	AniCircle.Ring:SetRotation(angle)
	AniCircle.Arrow:SetRotation(angle)
	AniCircle.Runes:SetRotation(angle)
	FadeOut(AniCircle, 3, 1, 0)
end

local function AnimateOnFinished(self)
	AniCircle:Hide()
	self:GetParent():Hide()
end

function Utility:AnimateNew(button) Animation:ShowNewAction(_G[button], true) end

local function AddAction(actionType, ID, autoAssigned)
	ID = tonumber(ID) or ID
	local alreadyBound
	for id, ActionButton in pairs(ActionButtons) do
		alreadyBound = 	( ActionButton:GetAttribute("type") == actionType and
						( ActionButton:GetAttribute("cursorID") == ID or ActionButton:GetAttribute(actionType) == ID) ) and id
		if alreadyBound then
			break
		end
	end
	if alreadyBound and not autoAssigned then
		Animation:ShowNewAction(ActionButtons[alreadyBound])
	elseif not alreadyBound then
		for i, ActionButton in pairs(ActionButtons) do
			if not ActionButton:GetAttribute("type") then
				if actionType == "item" then
					ActionButton:SetAttribute("cursorID", ID)
				end
				ActionButton:SetAttribute("autoAssigned", autoAssigned)
				ActionButton:SetAttribute("type", actionType)
				ActionButton:SetAttribute(actionType, ID)
				Animation:ShowNewAction(ActionButton, autoAssigned)
				break
			end 
		end
	end
end

local function CheckQuestWatches(self)
	if not InCombatLockdown() then
		local questWatches = {}
		for i=1, GetNumQuestWatches() do
			local watchIndex = GetQuestIndexForWatch(i)
			if watchIndex then
				questWatches[watchIndex] = true
			end
		end
		for questID in pairs(questWatches) do
			if GetQuestLogSpecialItemInfo(questID) then
				local name, link, _, _, _, class, sub, _, _, texture = GetItemInfo(GetQuestLogSpecialItemInfo(questID))
				if link then
					local _, itemID = strsplit(":", strmatch(link, "item[%-?%d:]+"))
					if itemID then
						AddAction("item", itemID, true)
					end
				end
			end
		end
		self:RemoveUpdateSnippet(CheckQuestWatches)
	end
end

function Tooltip:Refresh()
	if self.castButton then
		self:AddLine(self.castInfo:format(db.TEXTURE[self.castButton]))
	end
	self:AddLine(self.removeInfo:format(db.TEXTURE.CP_T_L3))
end

function Tooltip:OnShow()
	self.castButton = ConsolePort:GetCurrentBindingOwner("CLICK ConsolePortUtilityToggle:LeftButton")
	-- set CC backdrop
	self:SetBackdropColor(red*0.15, green*0.15, blue*0.15,  0.75)
	self:Refresh()
	FadeIn(self, 0.2, 0, 1)
end

function Utility:OnEvent(event, ...)
	if event == "QUEST_WATCH_LIST_CHANGED" and self.autoExtra then
		ConsolePort:AddUpdateSnippet(CheckQuestWatches)
	end
	for i, ActionButton in pairs(ActionButtons) do
		ActionButton:UpdateState()
	end
end

function Utility:SetNewRotationValue(newAngle)
	self.newAngle = newAngle
	if self.currAngle then
		local radChange = abs(self.newAngle) - abs(self.currAngle)
		-- offset is too large, lap reset 
		if abs(radChange) > 1 then
			local delta = radChange > 0 and 1 or -1
			self.currAngle = self.newAngle - (delta * RADIAN_FRACTION)
		end
		return true
	else
		self.currAngle = newAngle
		return false
	end
end

function Utility:SetRotation(value)
	self.Ring:SetRotation(value)
	self.Arrow:SetRotation(value)
	self.Runes:SetRotation(value)
end


function Utility:OnAttributeChanged(attribute, detail)
	if attribute == "index" then
		local actionButton = ActionButtons[detail]
		local oldButton = ActionButtons[self.oldID]
		if oldButton then
			oldButton:OnLeave()
		end
		if 	actionButton then
			actionButton:OnEnter()
		end
		if actionButton and actionButton:IsVisible() then
			if self:SetNewRotationValue(-actionButton.angle) then
				FadeOut(self.Spell, 1, self.Spell:GetAlpha(), 0)
			else
				self:SetRotation(self.newAngle)
				FadeIn(self.Spell, 0.2, self.Spell:GetAlpha(), 0.15)	
			end

			FadeIn(self.Arrow, 0.2, self.Arrow:GetAlpha(), 1)

			if actionButton:GetAttribute("type") then
				FadeIn(self.Runes, 3, self.Runes:GetAlpha(), 1)
				FadeIn(self.Ring, 0.2, self.Ring:GetAlpha(), 1)
			else
				FadeOut(self.Ring, 0.5, self.Ring:GetAlpha(), 0)
				FadeOut(self.Runes, 0.5, self.Runes:GetAlpha(), 0)
			end

			self.Gradient:Show()
			self.Gradient:ClearAllPoints()
			self.Gradient:SetPoint("CENTER", actionButton, "CENTER", 0, 0)
			FadeIn(self.Gradient, 0.2, self.Gradient:GetAlpha(), 1)

			self.Spell:Show()
			self.Spell:ClearAllPoints()
			self.Spell:SetPoint("CENTER", actionButton, 0, 0)
		else
			FadeOut(self.Runes, 0.2, self.Runes:GetAlpha(), 0)
			FadeOut(self.Arrow, 0.2, self.Arrow:GetAlpha(), 0)
			FadeOut(self.Ring, 0.1, self.Ring:GetAlpha(), 0)

			self.newAngle = nil
			self.currAngle = nil

			self.Gradient:SetAlpha(0)
			self.Gradient:ClearAllPoints()
			self.Gradient:Hide()

			self.Spell:ClearAllPoints()
			self.Spell:Hide()
		end
		self.oldID = detail
	end
end

function Utility:DisplayHints(elapsed)
	self.hintTimer = self.hintTimer + elapsed
	if self.hintTimer > 5 then
		local binding = ConsolePort:GetFormattedBindingOwner("CLICK ConsolePortUtilityToggle:LeftButton", nil, nil, true)
		if binding then
			if self:GetAttribute("toggled") then
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_DOUBLE, binding), 4, -190)
			else
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_BIND, binding), 4, -190)
			end
		else
			db.Hint:DisplayMessage(db.CUSTOMBINDS.CP_UTILITYBELT)
		end
		self.hasHints = nil
	end
end

function Utility:OnUpdate(elapsed)
	if self.hasHints then
		self:DisplayHints(elapsed)
	end
	if self.newAngle ~= self.currAngle then
		local dist = (self.newAngle - self.currAngle)
		local smoothVal = abs(dist / ANI_SPEED) ^ ANI_SMOOTH
		local diff = dist < 0 and -smoothVal or smoothVal
		self.currAngle = self.currAngle + diff
		if abs( abs(self.currAngle) - abs(self.newAngle) ) < 0.02 then
			self.currAngle = self.newAngle
			FadeIn(self.Spell, 0.2, self.Spell:GetAlpha(), 0.15)
		end
		self:SetRotation(self.currAngle)
	end
end

function Utility:OnShow()
	Animation:Hide()
	AniCircle:Hide()
	self.Spell:SetSize(175, 175)
	FadeOut(self.Ring, 0, 0, 0)
	FadeOut(self.Arrow, 0, 0, 0)
	FadeOut(self.Runes, 0, 0, 0)
	self.hintTimer = 0
	self.hasHints = true
	self.newAngle = nil
end
function Utility:OnHide()
	for i, ActionButton in pairs(ActionButtons) do
		ActionButton:OnLeave()
	end
	self.currAngle = nil
	self.newAngle = nil
	self.Gradient:SetAlpha(0)
	self.Gradient:ClearAllPoints()
	self.Gradient:Hide()
	self.Spell:Hide()
end

Utility:Execute([[
	Utility = self
	---------------------------------------------------------------
	BUTTONS = newtable()
	---------------------------------------------------------------
	KEYS = newtable()
	---------------------------------------------------------------
	INDEX = 0
	---------------------------------------------------------------
	KEYS.UP 	= false		KEYS.W 		= false
	KEYS.LEFT 	= false		KEYS.A 		= false
	KEYS.DOWN 	= false		KEYS.S 		= false
	KEYS.RIGHT 	= false		KEYS.D 		= false
	---------------------------------------------------------------
	OnKey = [=[
		local key, down = ...
		if down then
			if key == "UP" then
				KEYS.DOWN = false
				KEYS.UP = true
			elseif key == "DOWN" then
				KEYS.UP = false
				KEYS.DOWN = true
			elseif key == "LEFT" then
				KEYS.RIGHT = false
				KEYS.LEFT = true
			elseif key == "RIGHT" then
				KEYS.LEFT = false
				KEYS.RIGHT = true
			end
		else
			KEYS[key] = false
		end
		INDEX = 
			( KEYS.UP and KEYS.RIGHT 	) and 2 or
			( KEYS.DOWN and KEYS.RIGHT 	) and 4 or
			( KEYS.DOWN and KEYS.LEFT 	) and 6 or
			( KEYS.UP and KEYS.LEFT 	) and 8 or
			( KEYS.UP 					) and 1 or
			( KEYS.RIGHT 				) and 3 or
			( KEYS.DOWN 				) and 5 or
			( KEYS.LEFT 				) and 7 or 0
		self:SetAttribute("index", INDEX)
		local button
		if BUTTONS[INDEX] then
			self:SetBindingClick(true, "BUTTON1", BUTTONS[INDEX], "RightButton")
		else
			self:ClearBinding("BUTTON1")
		end
	]=]

	CursorUpdate = [=[
		local hasItem = ...
		if hasItem then
			self:Show()
			for _, button in pairs(BUTTONS) do
				if button:IsProtected() and not button:GetAttribute("type") then
					button:SetAlpha(0.5)
				end
			end
		elseif not hasItem and not TOGGLED then
			self:Hide()
			for _, button in pairs(BUTTONS) do
				if not button:GetAttribute("type") then
					button:SetAlpha(0.5)
				end
			end
		end
	]=]

	UseUtility = [=[
		local enabled = ...
		if enabled then
			TOGGLED = true
			INDEX = 0
			self:SetAttribute("toggled", true)
			self:Show()
			for key in pairs(KEYS) do
				self:SetBindingClick(true, key, "ConsolePortUtilityButton"..key)
				self:SetBindingClick(true, "CTRL-"..key, "ConsolePortUtilityButton"..key)
				self:SetBindingClick(true, "SHIFT-"..key, "ConsolePortUtilityButton"..key)
				self:SetBindingClick(true, "CTRL-SHIFT-"..key, "ConsolePortUtilityButton"..key)
			end
		else
			TOGGLED = false
			self:SetAttribute("toggled", false)
			for key in pairs(KEYS) do
				KEYS[key] = false
			end
			self:ClearBindings()
			self:Hide()
			self:Run(CursorUpdate, nil)
		end
	]=]
]])
Utility:SetAttribute("_onstate-cursor", [[
	self:Run(CursorUpdate, newstate)
]])
Utility:SetAttribute("_onstate-extrabar", [[
	local extraID = 169
	if newstate then
		for _, button in pairs(BUTTONS) do
			if 	button:GetAttribute("type") == "action" and button:GetAttribute("action") == extraID then
				Utility:CallMethod("AnimateNew", button:GetName())
				return
			end
		end
		for _, button in pairs(BUTTONS) do
			if 	not button:GetAttribute("type") then
				button:SetAlpha(1)
				button:SetAttribute("type", "action")
				button:SetAttribute("action", extraID)
				Utility:CallMethod("AnimateNew", button:GetName())
				return
			end
		end
	else
		for _, button in pairs(BUTTONS) do
			if 	button:GetAttribute("type") == "action" and button:GetAttribute("action") == extraID then
				button:SetAlpha(0.5)
				button:SetAttribute("type", nil)
				button:SetAttribute("action", nil)
			end
		end
	end
]])

RegisterStateDriver(Utility, "cursor", "[cursor] true; nil")
RegisterStateDriver(Utility, "extrabar", "[extrabar] true; nil")

------------------------------------------------------------------------------------------------------------------------------
local UseUtility = CreateFrame("Button", "ConsolePortUtilityToggle", nil, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
---------------------------------------------------------------
UseUtility:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
UseUtility:SetFrameRef("Utility", Utility)
Utility:WrapScript(UseUtility, "OnClick", [[
	Utility:Run(UseUtility, down)
	if down then
		self:SetAttribute("type", nil)
		self:ClearBinding("MOUSE1")
	else
		local button = BUTTONS[INDEX]
		if button then
			local actionType = button:GetAttribute("type")
			local id = actionType and button:GetAttribute(actionType)
			if id then
				self:SetAttribute("type", actionType)
				self:SetAttribute(actionType, id)
			end
		else
			self:SetAttribute("type", nil)
		end
	end
]])
Utility:WrapScript(UseUtility, "OnDoubleClick", [[
	Utility:Run(UseUtility, true)
	Utility:Run(CursorUpdate, true)
]])
---------------------------------------------------------------
local buttons = {
	["UP"] 		= {"W", "UP"},
	["LEFT"] 	= {"A", "LEFT"},
	["DOWN"] 	= {"S", "DOWN"},
	["RIGHT"] 	= {"D", "RIGHT"},
}
---------------------------------------------------------------
local dropTypes = {
	item = true,
	spell = true,
	macro = true,
	mount = true,
}
---------------------------------------------------------------
for direction, keys in pairs(buttons) do
	for _, key in pairs(keys) do
		local button = CreateFrame("Button", "ConsolePortUtilityButton"..key, Utility, "SecureActionButtonTemplate")
		button:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
		Utility:WrapScript(button, "OnClick", format([[
			Utility:Run(OnKey, "%s", down)
		]], direction))
	end
end
---------------------------------------------------------------

function ButtonMixin:PreClick(button)
	if not InCombatLockdown() then
		if button == "RightButton" then
			self:SetAttribute("type", nil)
			self.cooldown:SetCooldown(0, 0)
			self.Count:SetText()
			ClearCursor()
		elseif dropTypes[GetCursorInfo()] then
			self:SetAttribute("type", nil)
		end
	end
end

function ButtonMixin:PostClick(button)
	if dropTypes[GetCursorInfo()] then
		local cursorType, id,  _, spellID = GetCursorInfo()
		ClearCursor()

		if InCombatLockdown() then
			return
		end

		local newValue

		-- Garrison ability
		if cursorType == "spell" and spellID == 161691 then
			newValue = spellID
		-- Convert spellID to name
		elseif cursorType == "spell" then
			newValue = GetSpellInfo(id, "spell")
		-- Summon favorite mount, ignore this
		elseif cursorType == "mount" and id == 268435455 then
			return
		elseif cursorType == "mount" then
			newValue = C_MountJournal.GetMountInfoByID(id)
			cursorType = "spell"
		end

		self:SetAttribute("type", cursorType)
		self:SetAttribute("cursorID", id)
		self:SetAttribute(cursorType, newValue or id)
	end
end

function ButtonMixin:SetCooldown(time, cooldown, enable)
	if time and cooldown then
		self.onCooldown = true
		self.cooldown:SetCooldown(time, cooldown, enable)
	else
		self.onCooldown = false
		self.cooldown:SetCooldown(0, 0)
	end
end

function ButtonMixin:SetCharges(charges)
	self.Count:SetText(charges)
end

function ButtonMixin:SetUsable(isUsable)
	if isUsable then
		self.icon:SetVertexColor(1, 1, 1)
	else
		self.icon:SetVertexColor(0.5, 0.5, 0.5)
	end
end

function ButtonMixin:SetTexture(actionType, actionValue)
	local texture, isQuest
	if actionValue then
		if actionType == "item" then
			texture = select(10, GetItemInfo(actionValue))
			isQuest = select(12, GetItemInfo(actionValue)) == 12
		elseif actionType == "spell" then
			texture = select(3, GetSpellInfo(actionValue))
		elseif actionType == "macro" then
			texture = select(2, GetMacroInfo(actionValue))
		elseif actionType == "action" then
			texture = GetActionTexture(actionValue)
		end
	end
	if texture then
		self.icon.texture = texture
		self.icon:SetTexture(texture)
		self:SetAlpha(1)
		self.icon:SetVertexColor(1, 1, 1)
	else
		self.icon.texture = nil
		self.icon:SetTexture(nil)
		self:SetAlpha(0.5)
	end
	if isQuest then
		self.isQuest = true
		self.Quest:Show()
	else
		self.isQuest = nil
		self.Quest:Hide()
	end
end

function ButtonMixin:OnAttributeChanged(attribute, detail)
	if attribute == "autoassigned" or attribute == "statehidden" then
		return
	end

	local texture, isQuest
	if detail then
		if attribute == "item" and tonumber(detail) then
			local name = GetItemInfo(detail)
			self:SetAttribute("item", name)
			return
		elseif attribute == "mount" then
			local spellID = select(2, C_MountJournal.GetMountInfoByID(detail))
			self:SetAttribute("mountID", spellID)
			self:SetAttribute("type", "spell")
			self:SetAttribute("spell", spellID)
			return
		end
		ClearCursor()
	end
	self:SetTexture(attribute, detail)
	
	local actionType = self:GetAttribute("type")
	if actionType then
		ConsolePortUtility[self.ID] = {
			action = actionType,
			value = self:GetAttribute(actionType),
			cursorID = self:GetAttribute("cursorID"),
			autoAssigned = self:GetAttribute("autoAssigned"),
		}
	else
		self.clearAutoAssign = true
		ConsolePortUtility[self.ID] = nil
	end
end

function ButtonMixin:OnEnter()
	self.HasFocus = true
	FadeIn(self.Pushed, 0.1, self.Pushed:GetAlpha(), 1)
	FadeIn(self.Highlight, 0.1, self.Highlight:GetAlpha(), 1)
	FadeOut(self.NormalTexture, 0.1, self.NormalTexture:GetAlpha(), 1)
	FadeOut(self.Quest, 0.1, self.Quest:GetAlpha(), 0)
end

function ButtonMixin:OnLeave()
	self.HasFocus = nil
	if Tooltip:GetOwner() == self then
		Tooltip:Hide()
	end
	FadeOut(self.Pushed, 0.2, self.Pushed:GetAlpha(), 0)
	FadeOut(self.Highlight, 0.2, self.Highlight:GetAlpha(), 0)
	FadeIn(self.NormalTexture, 0.2, self.NormalTexture:GetAlpha(), 0.75)
	FadeIn(self.Quest, 0.2, self.Quest:GetAlpha(), 1)
end

function ButtonMixin:UpdateState()
	local action = self:GetAttribute("type")
	if action and not self.icon.texture then
		self:SetTexture(action, self:GetAttribute(action))
	end
	if action == "item" then
		local item = self:GetAttribute("item")
		local count = GetItemCount(item)
		local _, _, maxStack = select(6, GetItemInfo(item))
		if  self:GetAttribute("autoAssigned") and count < 1 and not InCombatLockdown() then
			self:SetAttribute("type", nil)
			self:SetAttribute("item", nil)
		else
			self:SetCooldown(GetItemCooldown(self:GetAttribute("cursorID")))
			self:SetUsable(IsUsableItem(item))
			self:SetCharges(maxStack and maxStack > 1 and count)
		end
	elseif action == "spell" then
		local spellID = self:GetAttribute("spell")
		self:SetCharges(GetSpellCharges(spellID))
		if spellID then
			self:SetUsable(IsUsableSpell(spellID))
			self:SetCooldown(GetSpellCooldown(spellID))
		end
	elseif action == "action" then
		local actionID = self:GetAttribute("action")
		if actionID then
			self:SetUsable(IsUsableAction(actionID))
			self:SetCooldown(GetActionCooldown(actionID))
		end
	end
end

function ButtonMixin:OnUpdate(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.25 do
		if self.HasFocus then
			self.Idle = self.Idle + self.Timer
			if self.Idle > 1 then
				local action = self:GetAttribute("type")
				if action == "item" then
					Tooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -16)
					Tooltip:SetItemByID(self:GetAttribute("cursorID"))
				elseif action == "spell" then
					local id = select(7, GetSpellInfo(self:GetAttribute("spell")))
					if id then
						Tooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -16)
						Tooltip:SetSpellByID(id)
					end
				end
				self.HasFocus = nil
			end
		else
			self.Idle = 0
		end
		if self.clearAutoAssign and not InCombatLockdown() then
			self.clearAutoAssign = nil
			self:SetAttribute("autoAssigned", nil)
		end

		self.Timer = self.Timer - 0.25
	end
end

---------------------------------------------------------------
function ConsolePort:AddUtilityAction(actionType, value)
	if actionType and value then
		AddAction(actionType, value)
	end
end

function ConsolePort:SetupUtilityBelt()
	if not InCombatLockdown() then
		Utility:UnregisterAllEvents()
		for index, info in pairs(ConsolePortUtility) do
			local actionButton = ActionButtons[index]
			if info.action then
				actionButton:SetAttribute("autoAssigned", info.autoAssigned)
				actionButton:SetAttribute("type", info.action)
				actionButton:SetAttribute("cursorID", info.cursorID)
				actionButton:SetAttribute(info.action, info.value)
				actionButton:Show()
			end
		end

		if GameMenuButtonController and not GameMenuButtonController.loaded then
			GameMenuButtonController.loaded = true
			GameMenuButtonController:SetFrameRef("Utility", Utility)
			Utility:WrapScript(GameMenuButtonController, "OnClick", [[
				Utility:Run(UseUtility, nil)
			]])
		end

		Utility.autoExtra = db.Settings.autoExtra

		if Utility.autoExtra then
			self:AddUpdateSnippet(CheckQuestWatches)
		end

		for _, event in pairs({
			"ACTIONBAR_UPDATE_COOLDOWN",
			"ACTIONBAR_UPDATE_STATE",
			"ACTIONBAR_UPDATE_USABLE",
			"BAG_UPDATE",
			"BAG_UPDATE_COOLDOWN",
			"QUEST_WATCH_LIST_CHANGED",
			"SPELL_UPDATE_COOLDOWN",
			"SPELL_UPDATE_CHARGES",
			"SPELL_UPDATE_USABLE",
		}) do Utility:RegisterEvent(event) end

		self:RemoveUpdateSnippet(self.SetupUtilityBelt)
	end
end

---------------------------------------------------------------
for i=1, NUM_BUTTONS do
	local x, y, r = 0, 0, 180 -- xOffset, yOffset, radius
	local angle = (i+1) * RADIAN_FRACTION
	local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )
	local button = CreateFrame("Button", "ConsolePortUtilityActionButton"..i, Utility, "ActionButtonTemplate, SecureActionButtonTemplate")
	button:SetPoint("CENTER", -ptx, pty)
	button.angle = (i-1) * RADIAN_FRACTION

	button.Timer = 0
	button.Idle = 0
	button.ID = i
	button:SetAlpha(0.5)
	button:SetID(i)
	button:SetSize(66, 66)
	button:SetPoint("CENTER", -ptx, pty)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	button.Border = CreateFrame("Frame", "$parentBorder", button)
	button.Border:SetAllPoints(button)

	button.Border.Shadow = button.Border:CreateTexture(nil, "BACKGROUND")
	button.Border.Shadow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\NormalShadow")
	button.Border.Shadow:SetSize(82, 82)
	button.Border.Shadow:SetPoint("CENTER", 0, -6)
	button.Border.Shadow:SetAlpha(0.75)

	button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.NormalTexture:ClearAllPoints()
	button.NormalTexture:SetParent(button.Border)
	button.NormalTexture:SetPoint("CENTER", 0, 0)
	button.NormalTexture:SetSize(66, 66)
	button.NormalTexture:SetDrawLayer("OVERLAY", 4)

	button.cooldown:SetSwipeColor(db.Atlas.GetNormalizedCC())
	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Swipe")
	button.cooldown:SetAllPoints()
	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
	button.cooldown:SetDrawEdge(false)
	button.cooldown:SetFrameLevel(10)

	button.Count:ClearAllPoints()
	button.Count:SetPoint("BOTTOM", 0, 2)

	button.icon:ClearAllPoints()
	button.icon:SetPoint("CENTER", 0, 0)
	button.icon:SetSize(64, 64)
	button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

	button.Pushed = button:GetPushedTexture()
	button.Pushed:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.Pushed:SetParent(button.Border)
	button.Pushed:SetAllPoints(button.NormalTexture)
	button.Pushed:SetVertexColor(red, green, blue, 1)
	button.Pushed:SetDrawLayer("OVERLAY", 5)
	button.Pushed:SetBlendMode("ADD")
	button.Pushed:SetAlpha(0)

	button:GetHighlightTexture():SetTexture(nil)

	button.Highlight = button.Border:CreateTexture(nil, "OVERLAY", nil, 6)
	button.Highlight:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
	button.Highlight:SetAllPoints(button.NormalTexture)
	button.Highlight:SetBlendMode("ADD")
	button.Highlight:SetAlpha(0)

	button.Quest = button.Border:CreateTexture(nil, "OVERLAY", nil, 7)
	button.Quest:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\QuestButton")
	button.Quest:SetPoint("CENTER", 0, 0)
	button.Quest:SetSize(64, 64)
	button.Quest:Hide()

	Mixin(button, ButtonMixin)

	button:SetScript("PreClick", button.PreClick)
	button:SetScript("PostClick", button.PostClick)
	button:SetScript("OnAttributeChanged", button.OnAttributeChanged)

	button:HookScript("OnEnter", button.OnEnter)
	button:HookScript("OnLeave", button.OnLeave)
	button:HookScript("OnUpdate", button.OnUpdate)

	Utility:SetFrameRef(tostring(i), button)
	Utility:Execute(format([[ BUTTONS[%d] = self:GetFrameRef("%d")]], i, i))
	tinsert(ActionButtons, button)
end

---------------------------------------------------------------


---------------------------------------------------------------
Utility:SetPoint("CENTER", 0, 0)
Utility.Tooltip = Tooltip
Utility:Hide()
---------------------------------------------------------------
Utility.Full = Utility:CreateTexture(nil, "OVERLAY")
Utility.Full:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityGlow")
Utility.Full:SetVertexColor(red * 1.5, green * 1.5, blue * 1.5)
Utility.Full:SetPoint("CENTER", 0, 0)
Utility.Full:SetSize(512, 512)
Utility.Full:SetAlpha(0.5)
---------------------------------------------------------------
Utility.Gradient = Utility:CreateTexture(nil, "BACKGROUND")
Utility.Gradient:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Circle")
Utility.Gradient:SetBlendMode("ADD")
Utility.Gradient:SetVertexColor(red * colMul, green * colMul, blue * colMul)
Utility.Gradient:SetPoint("CENTER", 0, 0)
Utility.Gradient:SetSize(256, 256)
---------------------------------------------------------------
Utility.Ring = Utility:CreateTexture(nil, "OVERLAY", nil, 2)
Utility.Ring:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityCircle")
Utility.Ring:SetVertexColor(red * colMul, green * colMul, blue * colMul)
Utility.Ring:SetPoint("CENTER", 0, 0)
Utility.Ring:SetSize(700, 700)
Utility.Ring:SetAlpha(0)
Utility.Ring:SetRotation(0)
Utility.Ring:SetBlendMode("ADD")
---------------------------------------------------------------
Utility.Arrow = Utility:CreateTexture(nil, "OVERLAY")
Utility.Arrow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityArrow")
Utility.Arrow:SetVertexColor(red * 1.25, green * 1.25, blue * 1.25)
Utility.Arrow:SetPoint("CENTER", 0, 0)
Utility.Arrow:SetSize(722, 722)
Utility.Arrow:SetAlpha(0)
Utility.Arrow:SetRotation(0)
---------------------------------------------------------------
Utility.Runes = Utility:CreateTexture(nil, "OVERLAY")
Utility.Runes:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityRunes")
Utility.Runes:SetPoint("CENTER", 0, 0)
Utility.Runes:SetSize(722, 722)
Utility.Runes:SetAlpha(0)
Utility.Runes:SetRotation(0)
---------------------------------------------------------------
Utility.Spell = CreateFrame("PlayerModel", nil, Utility)
Utility.Spell:SetPoint("CENTER", -4, 0)
Utility.Spell:SetSize(176, 176)
Utility.Spell:SetAlpha(0)
Utility.Spell:SetDisplayInfo(66673) --(42486)
Utility.Spell:SetCamDistanceScale(2)
--Utility.Spell:SetLight(true, false, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
Utility.Spell:Hide()
Utility.Spell:SetFrameLevel(1)
---------------------------------------------------------------
Utility:HookScript("OnHide", Utility.OnHide)
Utility:HookScript("OnShow", Utility.OnShow)
Utility:HookScript("OnEvent", Utility.OnEvent)
Utility:HookScript("OnUpdate", Utility.OnUpdate)
Utility:HookScript("OnAttributeChanged", Utility.OnAttributeChanged)
---------------------------------------------------------------


---------------------------------------------------------------
Animation:SetSize(64, 64)
Animation:SetFrameStrata("TOOLTIP")
Animation.Group = Animation:CreateAnimationGroup()
---------------------------------------------------------------
Animation.Icon = Animation:CreateTexture(nil, "ARTWORK")
Animation.Quest = Animation:CreateTexture(nil, "OVERLAY")
Animation.Border = Animation:CreateTexture(nil, "OVERLAY")
Animation.Scale = Animation.Group:CreateAnimation("Scale")
Animation.Fade = Animation.Group:CreateAnimation("Alpha")
---------------------------------------------------------------
Animation.Scale:SetToScale(1, 1)
Animation.Scale:SetFromScale(2, 2)
Animation.Scale:SetDuration(0.5)
Animation.Scale:SetSmoothing("IN")
Animation.Fade:SetFromAlpha(1)
Animation.Fade:SetToAlpha(0)
Animation.Fade:SetSmoothing("OUT")
Animation.Fade:SetStartDelay(3)
Animation.Fade:SetDuration(0.2)
---------------------------------------------------------------
Animation.Border:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
Animation.Border:SetAlpha(1)
Animation.Border:SetAllPoints(Animation)
---------------------------------------------------------------
Animation.Icon:SetSize(64, 64)
Animation.Icon:SetPoint("CENTER", 0, 0)
Animation.Icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")
---------------------------------------------------------------
Animation.Quest:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\QuestButton")
Animation.Quest:SetPoint("CENTER", 0, 0)
Animation.Quest:SetSize(64, 64)
---------------------------------------------------------------
Animation.Gradient = Animation:CreateTexture(nil, "BACKGROUND")
Animation.Gradient:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Circle")
Animation.Gradient:SetBlendMode("ADD")
Animation.Gradient:SetVertexColor(red, green, blue, 1)
Animation.Gradient:SetPoint("CENTER", 0, 0)
Animation.Gradient:SetSize(512, 512)	
---------------------------------------------------------------
Animation.Shadow = Animation:CreateTexture(nil, "BACKGROUND")
Animation.Shadow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\NormalShadow")
Animation.Shadow:SetSize(82, 82)
Animation.Shadow:SetPoint("CENTER", 0, -6)
Animation.Shadow:SetAlpha(0.75)
---------------------------------------------------------------
Animation.Spell = CreateFrame("PlayerModel", nil, Animation)
Animation.Spell:SetFrameStrata("TOOLTIP")
Animation.Spell:SetPoint("CENTER", Animation.Icon, "CENTER", -4, 0)
Animation.Spell:SetSize(176, 176)
Animation.Spell:SetAlpha(0)
Animation.Spell:SetDisplayInfo(66673) --(42486)
Animation.Spell:SetCamDistanceScale(2)
Animation.Spell:SetFrameLevel(1)
---------------------------------------------------------------
Animation.Group:SetScript("OnFinished", AnimateOnFinished)
---------------------------------------------------------------
AniCircle:SetPoint("CENTER", 0, 0)
AniCircle:SetSize(512, 512)
AniCircle:Hide()
---------------------------------------------------------------

---------------------------------------------------------------
AniCircle.Ring = AniCircle:CreateTexture(nil, "OVERLAY", nil, 2)
AniCircle.Ring:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityCircle")
AniCircle.Ring:SetVertexColor(red * colMul, green * colMul, blue * colMul)
AniCircle.Ring:SetPoint("CENTER", 0, 0)
AniCircle.Ring:SetSize(700, 700)
--AniCircle.Ring:SetAlpha(0)
AniCircle.Ring:SetRotation(0)
AniCircle.Ring:SetBlendMode("ADD")
---------------------------------------------------------------
AniCircle.Arrow = AniCircle:CreateTexture(nil, "OVERLAY")
AniCircle.Arrow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityArrow")
AniCircle.Arrow:SetVertexColor(red * 1.25, green * 1.25, blue * 1.25)
AniCircle.Arrow:SetPoint("CENTER", 0, 0)
AniCircle.Arrow:SetSize(722, 722)
--AniCircle.Arrow:SetAlpha(0)
AniCircle.Arrow:SetRotation(0)
---------------------------------------------------------------
AniCircle.Runes = AniCircle:CreateTexture(nil, "OVERLAY")
AniCircle.Runes:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityRunes")
AniCircle.Runes:SetPoint("CENTER", 0, 0)
AniCircle.Runes:SetSize(722, 722)
--AniCircle.Runes:SetAlpha(0)
AniCircle.Runes:SetRotation(0)
---------------------------------------------------------------

---------------------------------------------------------------
Tooltip:SetBackdrop(db.Atlas.Backdrops.Tooltip)
Tooltip:SetScript("OnShow", Tooltip.OnShow)
Tooltip:SetPoint("CENTER", 0, 0)
Tooltip:SetOwner(Utility)
Tooltip.castInfo = db.TOOLTIP.UTILITY_RELEASE
Tooltip.removeInfo = db.TOOLTIP.UTILITY_REMOVE
---------------------------------------------------------------