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
local Utility = CreateFrame("Frame", "ConsolePortUtilityFrame", UIParent, "SecureHandlerBaseTemplate")
---------------------------------------------------------------
local Tooltip = CreateFrame("GameTooltip", "$parentTooltip", Utility, "GameTooltipTemplate")
---------------------------------------------------------------
local Animation = CreateFrame("Frame", "ConsolePortUtilityAnimation", UIParent)
---------------------------------------------------------------
local ActionButtons = {}
---------------------------------------------------------------
local Watches = {}
---------------------------------------------------------------
local OldIndex = 0
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()
---------------------------------------------------------------
local QUEST = select(10, GetAuctionItemClasses())
---------------------------------------------------------------
local UI_SCALE = UIParent:GetScale()
---------------------------------------------------------------
UIParent:HookScript("OnSizeChanged", function(self)
	UI_SCALE = self:GetScale()
end)
---------------------------------------------------------------

local function AnimateNewAction(self, actionButton, autoAssigned)
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
	self.Spell:SetSize(175 / UI_SCALE, 175 / UI_SCALE)
	self.Spell:SetPoint("CENTER", self.Icon, "BOTTOMLEFT", 48, 44 / UI_SCALE)
	self:ClearAllPoints()
	self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
	self:SetSize(120, 120)
	self:Show()
	self.Group:Stop()
	self.Group:Play()
	FadeOut(self.Spell, 3, 0.15, 0)
end

local function AnimateOnFinished(self)
	self:GetParent():SetSize(76, 76)
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
Animation.Fade = Animation.Group:CreateAnimation("Alpha")
Animation.Scale = Animation.Group:CreateAnimation("Scale")
---------------------------------------------------------------
Animation.Scale:SetScale(76/120, 76/120)
Animation.Scale:SetDuration(0.5)
Animation.Scale:SetSmoothing("IN")
Animation.Scale:SetOrder(1)
Animation.Fade:SetChange(-1)
Animation.Fade:SetSmoothing("OUT")
Animation.Fade:SetOrder(2)
Animation.Fade:SetStartDelay(3)
Animation.Fade:SetDuration(0.2)
---------------------------------------------------------------
Animation.Border:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
Animation.Border:SetAlpha(0.5)
Animation.Border:SetAllPoints(Animation)
Animation.Icon:SetSize(100, 100)
Animation.Icon:SetPoint("CENTER", 0, 0)
Animation.Icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")
---------------------------------------------------------------
Animation.Quest:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\QuestButton")
Animation.Quest:SetPoint("CENTER", 0, 0)
Animation.Quest:SetSize(100, 100)
---------------------------------------------------------------
Animation.Gradient = Animation:CreateTexture(nil, "BACKGROUND")
Animation.Gradient:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Circle")
Animation.Gradient:SetBlendMode("ADD")
Animation.Gradient:SetVertexColor(red, green, blue, 1)
Animation.Gradient:SetPoint("CENTER", 0, 0)
Animation.Gradient:SetSize(512, 512)
---------------------------------------------------------------
Animation.Spell = CreateFrame("PlayerModel", nil, UIParent)
Animation.Spell:SetFrameStrata("TOOLTIP")
Animation.Spell:SetPoint("CENTER", Animation.Icon, "CENTER", 0, 14)
Animation.Spell:SetSize(256, 256)
Animation.Spell:SetAlpha(0.25)
Animation.Spell:SetDisplayInfo(42486)
Animation.Spell:SetLight(1, 0, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
---------------------------------------------------------------
Animation.ShowNewAction = AnimateNewAction
Animation.Group:SetScript("OnFinished", AnimateOnFinished)
---------------------------------------------------------------

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
				local _, itemID = strsplit(":", strmatch(link, "item[%-?%d:]+"))
				AddAction("item", itemID, true)
			end
		end
		self:RemoveUpdateSnippet(CheckQuestWatches)
	end
end

---------------------------------------------------------------
Utility:SetPoint("CENTER", 0, 0)
Utility:Hide()
---------------------------------------------------------------
Utility.Background = Utility:CreateTexture(nil, "BACKGROUND")
Utility.Background:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Circle")
Utility.Background:SetBlendMode("ADD")
Utility.Background:SetVertexColor(red, green, blue, 1)
Utility.Background:SetPoint("CENTER", 0, 0)
Utility.Background:SetSize(512, 512)
---------------------------------------------------------------
Utility.Gradient = Utility:CreateTexture(nil, "BACKGROUND")
Utility.Gradient:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Circle")
Utility.Gradient:SetBlendMode("ADD")
Utility.Gradient:SetVertexColor(red, green, blue, 1)
Utility.Gradient:SetPoint("CENTER", 0, 0)
Utility.Gradient:SetSize(256, 256)
---------------------------------------------------------------
Utility.Spell = CreateFrame("PlayerModel", nil, Utility)
Utility.Spell:SetPoint("CENTER", 0, 0)
Utility.Spell:SetSize(175, 175)
Utility.Spell:SetAlpha(0)
Utility.Spell:SetDisplayInfo(42486)
Utility.Spell:SetLight(1, 0, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
Utility.Spell:Hide()
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
Utility:HookScript("OnEvent", function(self, event, ...)
	if event == "QUEST_WATCH_LIST_CHANGED" then
		ConsolePort:AddUpdateSnippet(CheckQuestWatches)
	elseif event == "BAG_UPDATE" then
		for i, ActionButton in pairs(ActionButtons) do
			ActionButton:Update(0.3)
		end
	end
end)
Utility:HookScript("OnAttributeChanged", function(self, attribute, detail)
	if attribute == "index" then
		local actionButton = ActionButtons[detail]
		if ActionButtons[OldIndex] then
			ActionButtons[OldIndex]:Leave()
		end
		if 	actionButton then
			actionButton:Enter()
		end
		if actionButton and actionButton:IsVisible() then
			self.Gradient:Show()
			self.Gradient:ClearAllPoints()
			self.Gradient:SetPoint("CENTER", ActionButtons[detail], "CENTER", 0, 0)
			FadeIn(self.Gradient, 0.2, self.Gradient:GetAlpha(), 1)

			self.Spell:Show()
			self.Spell:ClearAllPoints()
			self.Spell:SetPoint("CENTER", ActionButtons[detail], "BOTTOMLEFT", 23, 27 / UI_SCALE)
			FadeIn(self.Spell, 0.2, self.Spell:GetAlpha(), 0.15)
		else
			self.Gradient:SetAlpha(0)
			self.Gradient:ClearAllPoints()
			self.Gradient:Hide()


			self.Spell:SetAlpha(0)
			self.Spell:ClearAllPoints()
			self.Spell:Hide()
		end
		OldIndex = detail
	end
end)
Utility:HookScript("OnShow", function(self)
	self.Spell:SetSize(175 / UI_SCALE, 175 / UI_SCALE)
	Animation:Hide()
end)
Utility:HookScript("OnHide", function(self)
	for i, ActionButton in pairs(ActionButtons) do
		ActionButton:Leave()
	end
	self.Gradient:SetAlpha(0)
	self.Gradient:ClearAllPoints()
	self.Gradient:Hide()
	self.Spell:Hide()
end)
Utility:Execute([[
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
	]=]

	CursorUpdate = [=[
		local hasItem = ...
		local children = newtable(self:GetChildren())
		if hasItem then
			self:Show()
			for _, child in pairs(children) do
				if child:IsProtected() and not child:GetAttribute("type") then
					child:Show()
					child:SetAlpha(0.5)
				end
			end
		elseif not hasItem and not TOGGLED then
			self:Hide() 
			for _, child in pairs(children) do
				if not child:GetAttribute("type") then
					child:Hide()
				end
			end
		end
	]=]

	UseUtility = [=[
		local enabled = ...
		if enabled then
			TOGGLED = true
			INDEX = 0
			self:Show()
			for key in pairs(KEYS) do
				self:SetBindingClick(true, key, "ConsolePortUtilityButton"..key)
				self:SetBindingClick(true, "CTRL-"..key, "ConsolePortUtilityButton"..key)
				self:SetBindingClick(true, "SHIFT-"..key, "ConsolePortUtilityButton"..key)
				self:SetBindingClick(true, "CTRL-SHIFT-"..key, "ConsolePortUtilityButton"..key)
			end
		else
			TOGGLED = false
			for key in pairs(KEYS) do
				KEYS[key] = false
			end
			self:ClearBindings()
			self:Hide()
			self:Run(CursorUpdate, nil)
		end
	]=]
]])

------------------------------------------------------------------------------------------------------------------------------
local UseUtility = CreateFrame("Button", "ConsolePortUtilityToggle", nil, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
------------------------------------------------------------------------------------------------------------------------------
local Timer = 0
local CursorItem
---------------------------------------------------------------
UseUtility:HookScript("OnUpdate", function(self, elapsed)
	Timer = Timer + elapsed
	while Timer > 0.1 do
		if not CursorItem and GetCursorInfo() and not InCombatLockdown() then
			Utility:Execute([[ self:Run(CursorUpdate, true) ]])
			CursorItem = true
		elseif CursorItem and not GetCursorInfo() and not InCombatLockdown() then
			Utility:Execute([[ self:Run(CursorUpdate, nil)  ]])
			CursorItem = nil
		end
		Timer = Timer - 0.1
	end
end)
---------------------------------------------------------------
UseUtility:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
UseUtility:SetFrameRef("Utility", Utility)
UseUtility:SetAttribute("type", "macro")
Utility:WrapScript(UseUtility, "OnClick", [[
	local Utility = self:GetFrameRef("Utility")
	Utility:Run(UseUtility, down)
	if down then
		self:SetAttribute("macrotext", nil)
	else
		local button = Utility:GetFrameRef(tostring(INDEX))
		if button then
			self:SetAttribute("macrotext", "/click "..button:GetName().." LeftButton")
		else
			self:SetAttribute("macrotext", nil)
		end
	end
]])
Utility:WrapScript(UseUtility, "OnDoubleClick", [[
	local Utility = self:GetFrameRef("Utility")
	Utility:Run(UseUtility, true)
	Utility:Run(CursorUpdate, true)
]])
GameMenuButtonController:SetFrameRef("Utility", Utility)
Utility:WrapScript(GameMenuButtonController, "OnClick", [[
	local Utility = self:GetFrameRef("Utility")
	Utility:Run(UseUtility, nil)
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
			local Utility = self:GetParent()
			Utility:Run(OnKey, "%s", down)
		]], direction))
	end
end
---------------------------------------------------------------

local function ActionButtonPreClick(self, button)
	if not InCombatLockdown() then
		if button == "RightButton" then
			self:SetAttribute("type", nil)
			Utility:Execute([[ self:Run(CursorUpdate, nil)  ]])
			self.cooldown:SetCooldown(0, 0)
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
	FadeOut(self.NormalTexture, 0.2, self.NormalTexture:GetAlpha(), 0.5)
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
for i=1, 8 do
	local x, y, r = 0, 0, 180
	local angle = (i+1) * (360 / 8) * math.pi / 180
	local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )
	local ActionButton = CreateFrame("Button", "ConsolePortUtilityActionButton"..i, Utility, "ActionButtonTemplate, SecureActionButtonTemplate")

	ActionButton.Timer = 0
	ActionButton.Idle = 0
	ActionButton.ID = i
	ActionButton:Hide()
	ActionButton:SetID(i)
	ActionButton:SetSize(46, 46)
	ActionButton:SetPoint("CENTER", -ptx, pty)
	ActionButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	ActionButton.Border = CreateFrame("Frame", "$parentBorder", ActionButton)
	ActionButton.Border:SetAllPoints(ActionButton)

	ActionButton.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	ActionButton.NormalTexture:ClearAllPoints()
	ActionButton.NormalTexture:SetParent(ActionButton.Border)
	ActionButton.NormalTexture:SetPoint("CENTER", 0, 0)
	ActionButton.NormalTexture:SetAlpha(0.75)
	ActionButton.NormalTexture:SetSize(76, 76)
	ActionButton.NormalTexture:SetDrawLayer("OVERLAY", 4)

	ActionButton.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	ActionButton.cooldown:ClearAllPoints()
	ActionButton.cooldown:SetPoint("CENTER")
	ActionButton.cooldown:SetSize(76, 76)
	ActionButton.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
	ActionButton.cooldown:SetDrawEdge(false)

	ActionButton.Count:ClearAllPoints()
	ActionButton.Count:SetPoint("BOTTOM", 0, 2)

	ActionButton.icon:ClearAllPoints()
	ActionButton.icon:SetPoint("CENTER", 0, 0)
	ActionButton.icon:SetSize(64, 64)
	ActionButton.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

	ActionButton.Pushed = ActionButton:GetPushedTexture()
	ActionButton.Pushed:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	ActionButton.Pushed:SetParent(ActionButton.Border)
	ActionButton.Pushed:SetAllPoints(ActionButton.NormalTexture)
	ActionButton.Pushed:SetVertexColor(red, green, blue, 1)
	ActionButton.Pushed:SetDrawLayer("OVERLAY", 5)
	ActionButton.Pushed:SetBlendMode("ADD")
	ActionButton.Pushed:SetAlpha(0)

	ActionButton:GetHighlightTexture():SetTexture(nil)

	ActionButton.Highlight = ActionButton.Border:CreateTexture(nil, "OVERLAY", nil, 6)
	ActionButton.Highlight:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	ActionButton.Highlight:SetAllPoints(ActionButton.NormalTexture)
	ActionButton.Highlight:SetVertexColor(red, green, blue, 1)
	ActionButton.Highlight:SetBlendMode("ADD")
	ActionButton.Highlight:SetAlpha(0)

	ActionButton.Quest = ActionButton.Border:CreateTexture(nil, "OVERLAY", nil, 7)
	ActionButton.Quest:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\QuestButton")
	ActionButton.Quest:SetPoint("CENTER", 0, 0)
	ActionButton.Quest:SetSize(64, 64)
	ActionButton.Quest:Hide()

	ActionButton:SetScript("PreClick", ActionButtonPreClick)
	ActionButton:SetScript("PostClick", ActionButtonPostClick)
	ActionButton:SetScript("OnAttributeChanged", ActionButtonOnAttributeChanged)

	ActionButton.Leave = ActionButtonOnLeave
	ActionButton.Enter = ActionButtonOnEnter
	ActionButton.Update = ActionButtonOnUpdate

	ActionButton:HookScript("OnEnter", ActionButtonOnEnter)
	ActionButton:HookScript("OnLeave", ActionButtonOnLeave)
	ActionButton:HookScript("OnUpdate", ActionButtonOnUpdate)

	Utility:SetFrameRef(tostring(i), ActionButton)
	tinsert(ActionButtons, ActionButton)
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
