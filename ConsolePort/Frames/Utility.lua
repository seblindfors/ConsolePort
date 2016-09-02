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
local pairs = pairs
local select = select
---------------------------------------------------------------
local 	Utility, Tooltip, Animation, AniCircle = 
		CreateFrame("Frame", "ConsolePortUtilityFrame", UIParent, "SecureHandlerBaseTemplate, SecureHandlerStateTemplate"),
		CreateFrame("GameTooltip", "$parentTooltip", Utility, "GameTooltipTemplate"),
		CreateFrame("Frame", "ConsolePortUtilityAnimation", UIParent),
		CreateFrame("Frame", "ConsolePortUtilityAnimationCircle", UIParent)
---------------------------------------------------------------
local ActionButtons, Watches, OldIndex = {}, {}, 0
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()
---------------------------------------------------------------
local QUEST =  "Quest" -- temp fix --select(10, GetAuctionItemClasses())
---------------------------------------------------------------

local function AnimateNewAction(self, actionButton, autoAssigned)
	-- if an item was auto-assigned, postpone its animation until the current animation has finished
	if  autoAssigned and self.Group:IsPlaying() then
		local progress = self.Group:GetDuration() * self.Group:GetProgress()
		local delay = self.Group:GetDuration() - progress
		C_Timer.After(delay, function() AnimateNewAction(self, actionButton, true) end)
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
	FadeOut(self.Spell, 3, 1, 0)
	if ConsolePortUtility[actionButton.ID] then
		local value = ConsolePortUtility[actionButton.ID].value
		local binding = ConsolePort:GetFormattedBindingOwner("CLICK ConsolePortUtilityToggle:LeftButton", nil, nil, true)
		if value then
			local string = binding and " "..binding or "."
			db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_NEWBIND, value or "", string), 4, 180)
		end
	end

	AniCircle:Show()
	AniCircle.Glow:SetRotation(-actionButton.angle)
	AniCircle.Line:SetRotation(-actionButton.angle)
	FadeOut(AniCircle, 3, 1, 0)
end

local function AnimateOnFinished(self)
	AniCircle:Hide()
	self:GetParent():Hide()
end

---------------------------------------------------------------
Animation:SetSize(76, 76)
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
Animation.Spell = CreateFrame("PlayerModel", nil, Animation)
Animation.Spell:SetFrameStrata("TOOLTIP")
Animation.Spell:SetPoint("CENTER", Animation.Icon, "CENTER", -4, 0)
Animation.Spell:SetSize(176, 176)
Animation.Spell:SetAlpha(0)
Animation.Spell:SetDisplayInfo(66673) --(42486)
Animation.Spell:SetCamDistanceScale(2)
Animation.Spell:SetLight(true, false, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
Animation.Spell:SetFrameLevel(1)
---------------------------------------------------------------
Animation.ShowNewAction = AnimateNewAction
Animation.Group:SetScript("OnFinished", AnimateOnFinished)
---------------------------------------------------------------
AniCircle:SetPoint("CENTER", 0, 0)
AniCircle:SetSize(512, 512)
AniCircle:Hide()
AniCircle.Glow = AniCircle:CreateTexture(nil, "OVERLAY")
AniCircle.Line = AniCircle:CreateTexture(nil, "OVERLAY", 2)
---------------------------------------------------------------
AniCircle.Glow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityGlowBind")
AniCircle.Glow:SetVertexColor(red, green, blue)
AniCircle.Glow:SetPoint("CENTER", 0, 0)
AniCircle.Glow:SetSize(720, 720)
---------------------------------------------------------------
AniCircle.Line:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityCircleBind")
AniCircle.Line:SetPoint("CENTER", 0, 0)
AniCircle.Line:SetSize(720, 720)
---------------------------------------------------------------

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
				ActionButton:Show()
				Animation:ShowNewAction(ActionButton, autoAssigned)
				break
			end 
		end
	end
end

local function CheckQuestWatches(self)
	if not InCombatLockdown() then
		wipe(Watches)
		for i=1, GetNumQuestWatches() do
			local watchIndex = GetQuestIndexForWatch(i)
			if watchIndex then
				Watches[watchIndex] = true
			end
		end
		for questID in pairs(Watches) do
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

---------------------------------------------------------------
Utility:SetPoint("CENTER", 0, 0)
Utility:Hide()
---------------------------------------------------------------
Utility.Full = Utility:CreateTexture(nil, "OVERLAY")
Utility.Full:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityGlow")
Utility.Full:SetVertexColor(red, green, blue)
Utility.Full:SetPoint("CENTER", 0, 0)
Utility.Full:SetSize(512, 512)
Utility.Full:SetAlpha(0.5)
---------------------------------------------------------------
Utility.Gradient = Utility:CreateTexture(nil, "BACKGROUND")
Utility.Gradient:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Circle")
Utility.Gradient:SetBlendMode("ADD")
Utility.Gradient:SetVertexColor(red, green, blue, 1)
Utility.Gradient:SetPoint("CENTER", 0, 0)
Utility.Gradient:SetSize(256, 256)
---------------------------------------------------------------
Utility.Glow = Utility:CreateTexture(nil, "OVERLAY")
Utility.Glow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityGlowBind")
Utility.Glow:SetVertexColor(red, green, blue)
Utility.Glow:SetPoint("CENTER", 0, 0)
Utility.Glow:SetSize(720, 720)
Utility.Glow:SetAlpha(0)
---------------------------------------------------------------
Utility.Line = Utility:CreateTexture(nil, "OVERLAY", 2)
Utility.Line:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityCircleBind")
Utility.Line:SetPoint("CENTER", 0, 0)
Utility.Line:SetSize(720, 720)
Utility.Line:SetAlpha(0)
---------------------------------------------------------------
Utility.Spell = CreateFrame("PlayerModel", nil, Utility)
Utility.Spell:SetPoint("CENTER", -4, 0)
Utility.Spell:SetSize(176, 176)
Utility.Spell:SetAlpha(0)
Utility.Spell:SetDisplayInfo(66673) --(42486)
Utility.Spell:SetCamDistanceScale(2)
Utility.Spell:SetLight(true, false, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
Utility.Spell:Hide()
Utility.Spell:SetFrameLevel(1)
---------------------------------------------------------------
Utility.Tooltip = Tooltip

function Tooltip:OnShow()
	-- edge file fractioned pixel fix, pretty unncessary
	local width, height = self:GetSize()
	width, height = floor(width + 0.5) + 4, floor(height + 0.5) + 4
	local point, anchor, relative, x, y = self:GetPoint()
	self:ClearAllPoints()
	self:SetPoint(point, anchor, relative, floor(x + 0.5), floor(y + 0.5))
	self:SetSize(width - (width % 2), height - (height % 2))
	-- set CC backdrop
	self:SetBackdropColor(red*0.15, green*0.15, blue*0.15,  0.75)
	FadeIn(self, 0.2, 0, 1)
end

Tooltip:SetBackdrop(db.Atlas.Backdrops.Tooltip)
Tooltip:SetScript("OnShow", Tooltip.OnShow)
Tooltip:SetPoint("CENTER", 0, 0)
Tooltip:SetOwner(Utility)
---------------------------------------------------------------
function Utility:OnEvent(event, ...)
	if event == "QUEST_WATCH_LIST_CHANGED" then
		ConsolePort:AddUpdateSnippet(CheckQuestWatches)
	elseif event == "BAG_UPDATE" then
		for i, ActionButton in pairs(ActionButtons) do
			ActionButton:Update(0.3)
		end
	end
end
function Utility:OnAttributeChanged(attribute, detail)
	if attribute == "index" then
		if detail ~= 0 then
			self:SetScript("OnUpdate", nil)
		end
		local actionButton = ActionButtons[detail]
		if ActionButtons[OldIndex] then
			ActionButtons[OldIndex]:Leave()
		end
		if 	actionButton then
			actionButton:Enter()
		end
		if actionButton and actionButton:IsVisible() then

			self.Glow:SetRotation(-actionButton.angle)
			self.Line:SetRotation(-actionButton.angle)
			self.Glow:SetAlpha(1)
			self.Line:SetAlpha(1)

			self.Gradient:Show()
			self.Gradient:ClearAllPoints()
			self.Gradient:SetPoint("CENTER", ActionButtons[detail], "CENTER", 0, 0)
			FadeIn(self.Gradient, 0.2, self.Gradient:GetAlpha(), 1)

			self.Spell:Show()
			self.Spell:ClearAllPoints()
			self.Spell:SetPoint("CENTER", ActionButtons[detail], -4, 0)
			FadeIn(self.Spell, 0.2, self.Spell:GetAlpha(), 0.5)
		else			
			self.Glow:SetAlpha(0)
			self.Line:SetAlpha(0)

			self.Gradient:SetAlpha(0)
			self.Gradient:ClearAllPoints()
			self.Gradient:Hide()


			self.Spell:SetAlpha(0)
			self.Spell:ClearAllPoints()
			self.Spell:Hide()
		end
		OldIndex = detail
	end
end

function Utility:OnUpdate(elapsed)
	self.timer = self.timer + elapsed
	if self.timer > 2 then
		local binding = ConsolePort:GetFormattedBindingOwner("CLICK ConsolePortUtilityToggle:LeftButton", nil, nil, true)
		if binding then
			if self:GetAttribute("toggled") then
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_REMOVE, BINDING_NAME_CP_T_L3), 4, 180)
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_DOUBLE, binding), 4, 180)
			else
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_BIND, binding), 4, 180)
			end
		else
			db.Hint:DisplayMessage(db.CUSTOMBINDS.CP_UTILITYBELT)
		end
		self:SetScript("OnUpdate", nil)
	end
end
function Utility:OnShow()
	self.Spell:SetSize(175, 175)
	Animation:Hide()
	AniCircle:Hide()
	self.timer = 0
	self:SetScript("OnUpdate", self.OnUpdate)
end
function Utility:OnHide()
	for i, ActionButton in pairs(ActionButtons) do
		ActionButton:Leave()
	end
	self.Gradient:SetAlpha(0)
	self.Gradient:ClearAllPoints()
	self.Gradient:Hide()
	self.Spell:Hide()
	self:SetScript("OnUpdate", nil)
end
Utility:HookScript("OnHide", Utility.OnHide)
Utility:HookScript("OnShow", Utility.OnShow)
Utility:HookScript("OnEvent", Utility.OnEvent)
Utility:HookScript("OnAttributeChanged", Utility.OnAttributeChanged)
Utility:Execute([[
	Utility = self
	---------------------------------------------------------------
	BUTTONS = newtable()
	---------------------------------------------------------------
	KEYS = newtable()
	---------------------------------------------------------------
	INDEX = 0
	---------------------------------------------------------------
	KEYS.UP 	= false
	KEYS.LEFT 	= false
	KEYS.DOWN 	= false
	KEYS.RIGHT 	= false
	---------------------------------------------------------------
	KEYS.W 		= false
	KEYS.A 		= false
	KEYS.S 		= false
	KEYS.D 		= false
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
					button:Show()
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
RegisterStateDriver(Utility, "cursor", "[cursor] true; nil")

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

local function ActionButtonPreClick(self, button)
	if not InCombatLockdown() then
		if button == "RightButton" then
			self:SetAttribute("type", nil)
		--	Utility:Execute([[ self:Run(CursorUpdate, nil)  ]])
			self.cooldown:SetCooldown(0, 0)
			self.Count:SetText()
			ClearCursor()
		elseif dropTypes[GetCursorInfo()] then
			self:SetAttribute("type", nil)
		end
	end
end

local function ActionButtonPostClick(self, button)
	if dropTypes[GetCursorInfo()] then
		local cursorType, id,  mountID, spellID = GetCursorInfo()
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
		-- Summon favorite mount, not yet supported
		elseif cursorType == "mount" and id == 268435455 then
			return
		-- Use mountID instead of id when assigning mount
		elseif cursorType == "mount" then
			newValue = MountJournal_GetMountInfo(mountID)
		--	newValue = mountID
			cursorType = "spell"
		end

		self:SetAttribute("type", cursorType)
		self:SetAttribute("cursorID", id)
		self:SetAttribute(cursorType, newValue or id)
	end
end

local function ActionButtonGetTexture(self, actionType, actionValue)
	local texture, isQuest
	if actionValue then
		if actionType == "item" then
			texture = select(10, GetItemInfo(actionValue))
			isQuest = select(6, GetItemInfo(actionValue)) == QUEST
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

local function ActionButtonOnAttributeChanged(self, attribute, detail)
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
			local spellID = MountJournal_GetMountInfo(detail)
			self:SetAttribute("mountID", spellID)
			self:SetAttribute("type", "spell")
			self:SetAttribute("spell", spellID)
			return
		end
		ClearCursor()
	end
	ActionButtonGetTexture(self, attribute, detail)
	
	local actionType = self:GetAttribute("type")
	if actionType then
		ConsolePortUtility[self.ID] = {
			action = actionType,
			value = self:GetAttribute(actionType),
			cursorID = self:GetAttribute("cursorID"),
			autoAssigned = self:GetAttribute("autoAssigned"),
		}
	else
		self:SetAttribute("autoAssigned", nil)
		ConsolePortUtility[self.ID] = nil
	end
end

local function ActionButtonOnEnter(self)
	self.HasFocus = true
	FadeIn(self.Pushed, 0.2, self.Pushed:GetAlpha(), 1)
	FadeIn(self.Highlight, 0.2, self.Highlight:GetAlpha(), 0.5)
	FadeOut(self.NormalTexture, 0.2, self.NormalTexture:GetAlpha(), 1)
	FadeOut(self.Quest, 0.2, self.Quest:GetAlpha(), 0)
end

local function ActionButtonOnLeave(self)
	self.HasFocus = nil
	if Tooltip:GetOwner() == self then
		Tooltip:Hide()
	end
	FadeOut(self.Pushed, 0.2, self.Pushed:GetAlpha(), 0)
	FadeOut(self.Highlight, 0.2, self.Highlight:GetAlpha(), 0)
	FadeIn(self.NormalTexture, 0.2, self.NormalTexture:GetAlpha(), 0.75)
	FadeIn(self.Quest, 0.2, self.Quest:GetAlpha(), 1)
end

local function ActionButtonOnUpdate(self, elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.25 do
		local actionType = self:GetAttribute("type")
		if actionType and not self.icon.texture then
			ActionButtonGetTexture(self, actionType, self:GetAttribute(actionType))
		end
		if actionType == "item" then
			local item = self:GetAttribute("item")
			local count = GetItemCount(item)
			local _, _, maxStack = select(6, GetItemInfo(item))
			if  self:GetAttribute("autoAssigned") and count < 1 and not InCombatLockdown() then
				self:SetAttribute("type", nil)
				self:SetAttribute("item", nil)
				self:Hide()
			else
				local time, cooldown = GetItemCooldown(self:GetAttribute("cursorID"))
				if time and cooldown then
					self.cooldown:SetCooldown(time, cooldown)
					self.cooldown:SetSwipeColor(0.17, 0, 0)
				else
					self.cooldown:SetCooldown(0, 0)
				end
				if maxStack and maxStack > 1 then
					self.Count:SetText(count)
				else
					self.Count:SetText()
				end
				if count and count == 0 then
					self.icon:SetVertexColor(0.5, 0.5, 0.5, 1)
				elseif count and count > 0 then
					self.icon:SetVertexColor(1, 1, 1) 
				end
			end
		elseif actionType == "spell" then
			local spellID = self:GetAttribute("spell")
			local count = GetSpellCharges(spellID)
			if spellID then
				local time, cooldown = GetSpellCooldown(spellID)
				if time and cooldown then
					self.cooldown:SetCooldown(time, cooldown)
					self.cooldown:SetSwipeColor(0.17, 0, 0)
				else
					self.cooldown:SetCooldown(0, 0)
				end
			end
			if count then
				self.Count:SetText(count)
			else
				self.Count:SetText()
			end
		elseif actionType == "action" then
			local actionID = self:GetAttribute("action")
			if actionID then
				local time, cooldown = GetActionCooldown(actionID)
				if time and cooldown then
					self.cooldown:SetCooldown(time, cooldown)
					self.cooldown:SetSwipeColor(0.17, 0, 0)
				else
					self.cooldown:SetCooldown(0, 0)
				end
			end
		end
		if self.HasFocus then
			self.Idle = self.Idle + self.Timer
			if self.Idle > 1 then
				if actionType == "item" then
					Tooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -16)
					Tooltip:SetItemByID(self:GetAttribute("cursorID"))
				elseif actionType == "spell" then
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

		self.Timer = self.Timer - 0.25
	end
end

---------------------------------------------------------------
local NUM_BUTTONS = 8
for i=1, NUM_BUTTONS do
	local x, y, r = 0, 0, 180 -- xOffset, yOffset, radius
	local angle = (i+1) * (360 / NUM_BUTTONS) * math.pi / 180
	local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )
	local button = CreateFrame("Button", "ConsolePortUtilityActionButton"..i, Utility, "ActionButtonTemplate, SecureActionButtonTemplate")
	button:SetPoint("CENTER", -ptx, pty)
	button.angle = (i-1) * (360 / NUM_BUTTONS) * math.pi / 180

	button.Timer = 0
	button.Idle = 0
	button.ID = i
	button:SetAlpha(0.5)
	button:SetID(i)
	button:SetSize(46, 46)
	button:SetPoint("CENTER", -ptx, pty)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	button.Border = CreateFrame("Frame", "$parentBorder", button)
	button.Border:SetAllPoints(button)

	button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.NormalTexture:ClearAllPoints()
	button.NormalTexture:SetParent(button.Border)
	button.NormalTexture:SetPoint("CENTER", 0, 0)
	button.NormalTexture:SetAlpha(1)
	button.NormalTexture:SetSize(76, 76)
	button.NormalTexture:SetDrawLayer("OVERLAY", 4)

	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.cooldown:ClearAllPoints()
	button.cooldown:SetPoint("CENTER")
	button.cooldown:SetSize(76, 76)
	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
	button.cooldown:SetDrawEdge(false)

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
	button.Highlight:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.Highlight:SetAllPoints(button.NormalTexture)
	button.Highlight:SetVertexColor(red, green, blue, 1)
	button.Highlight:SetBlendMode("ADD")
	button.Highlight:SetAlpha(0)

	button.Quest = button.Border:CreateTexture(nil, "OVERLAY", nil, 7)
	button.Quest:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\QuestButton")
	button.Quest:SetPoint("CENTER", 0, 0)
	button.Quest:SetSize(64, 64)
	button.Quest:Hide()

	button:SetScript("PreClick", ActionButtonPreClick)
	button:SetScript("PostClick", ActionButtonPostClick)
	button:SetScript("OnAttributeChanged", ActionButtonOnAttributeChanged)

	button.Leave = ActionButtonOnLeave
	button.Enter = ActionButtonOnEnter
	button.Update = ActionButtonOnUpdate

	button:HookScript("OnEnter", ActionButtonOnEnter)
	button:HookScript("OnLeave", ActionButtonOnLeave)
	button:HookScript("OnUpdate", ActionButtonOnUpdate)

	Utility:SetFrameRef(tostring(i), button)
	Utility:Execute(format([[ BUTTONS[%d] = self:GetFrameRef("%d")]], i, i))
	tinsert(ActionButtons, button)
end

---------------------------------------------------------------
---------------------------------------------------------------
function ConsolePort:AddUtilityAction(actionType, value)
	if actionType and value then
		AddAction(actionType, value)
	end
end

function ConsolePort:SetupUtilityBelt()
	if not InCombatLockdown() then
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

		if db.Settings.autoExtra then
			self:AddUpdateSnippet(CheckQuestWatches)
			Utility:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
		else
			Utility:UnregisterEvent("QUEST_WATCH_LIST_CHANGED")
		end

		Utility:RegisterEvent("BAG_UPDATE")
		self:RemoveUpdateSnippet(self.SetupUtilityBelt)
	end
end

-- Extra action button
Utility:WrapScript(ExtraActionButton1, "OnShow", [[
	local extraID = self:GetAttribute("action")
	for _, button in pairs(BUTTONS) do
		if 	button:GetAttribute("type") == "action" and button:GetAttribute("action") == extraID then
			Utility:CallMethod("AnimateNew", button:GetName())
			return
		end
	end
	for _, button in pairs(BUTTONS) do
		if 	not button:GetAttribute("type") then
			button:Show()
			button:SetAlpha(1)
			button:SetAttribute("type", "action")
			button:SetAttribute("action", extraID)
			Utility:CallMethod("AnimateNew", button:GetName())
			return
		end
	end
]])

Utility:WrapScript(ExtraActionButton1, "OnHide", [[
	local extraID = self:GetAttribute("action")
	for _, button in pairs(BUTTONS) do
		if 	button:GetAttribute("type") == "action" and button:GetAttribute("action") == extraID then
			button:Hide()
			button:SetAttribute("type", nil)
			button:SetAttribute("action", nil)
		end
	end
]])
