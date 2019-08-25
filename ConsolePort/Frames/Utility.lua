---------------------------------------------------------------
-- Utility.lua: Main radial action bar  
---------------------------------------------------------------
-- Creates an action bar that can be populated with
-- items, spells, mounts, macros, etc. The user may manually
-- assign items from container buttons inside bag frames.
-- Action buttons can grab info from cursor.

---------------------------------------------------------------
local addOn, db = ...
---------------------------------------------------------------
local ConsolePort = ConsolePort
---------------------------------------------------------------
local FadeIn, FadeOut = db.GetFaders()
local GetItemCooldown = GetItemCooldown
local InCombatLockdown = InCombatLockdown
---------------------------------------------------------------
local 	Utility, Tooltip, Animation, AniCircle = 
		ConsolePortUtilityToggle,
		ConsolePortUtilityToggle.Tooltip,
		CreateFrame('Frame', 'ConsolePortUtilityAnimation', UIParent),
		CreateFrame('Frame', 'ConsolePortUtilityAnimationCircle', UIParent)
---------------------------------------------------------------
local red, green, blue = db.Atlas.GetCC()
local colMul = 1 + ( 1 - (( red + green + blue ) / 3) )
---------------------------------------------------------------

function Animation:ShowNewAction(actionButton, autoassigned)
	-- if an item was auto-assigned, postpone its animation until the current animation has finished
	if  autoassigned and self.Group:IsPlaying() then
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
	local scale = Utility.frameScale or 1
	self.Icon:SetTexture(actionButton.Icon.texture)
	--self.Spell:SetSize(175, 175)
	self:ClearAllPoints()
	self:SetPoint('CENTER', actionButton)
	self:SetScale(scale)
	self:Show()
	self.Group:Stop()
	self.Group:Play()
	--FadeOut(self.Spell, 3, 0.15, 0)

	if ConsolePortUtility[actionButton:GetID()] then
		local value = ConsolePortUtility[actionButton:GetID()].value
		local binding = ConsolePort:GetFormattedBindingOwner('CLICK ConsolePortUtilityToggle:LeftButton', nil, nil, true)
		if value then
			local string = binding and ' '..binding or '.'
			if value and not tonumber(value) then
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_NEWBIND, value, string), 3, -190)
			elseif binding then
				db.Hint:DisplayMessage(format(db.TUTORIAL.HINTS.UTILITY_RING_BIND, binding), 3, -190)
			end
		end
	end

	local angle = actionButton:GetAttribute('rotation')
	AniCircle:Show()
	AniCircle:SetScale(scale)
	AniCircle.Ring:SetRotation(angle)
	AniCircle.Arrow:SetRotation(angle)
	AniCircle.Runes:SetRotation(angle)
	FadeOut(AniCircle, 3, 1, 0)
end

local function AnimateOnFinished(self)
	AniCircle:Hide()
	self:GetParent():Hide()
end

-- called from secure scope (e.g. extra action button 1 appears)
function Utility:AnimateNew(button) Animation:ShowNewAction(_G[button], true) end


---------------------------------------------------------------
-- Add action to free actionbutton
---------------------------------------------------------------
local function AddAction(actionType, ID, autoassigned)
	ID = tonumber(ID) or ID
	local alreadyBound
	for id, ActionButton in pairs(Utility.Buttons) do
		alreadyBound = 	( ActionButton:GetAttribute('type') == actionType and
						( ActionButton:GetAttribute('cursorID') == ID or ActionButton:GetAttribute(actionType) == ID) ) and id
		if alreadyBound then
			break
		end
	end
	if alreadyBound and not autoassigned then
		Animation:ShowNewAction(Utility.Buttons[alreadyBound])
	elseif not alreadyBound then
		for _, ActionButton in ipairs(Utility.Buttons) do
			if not ActionButton:GetAttribute('type') then
				if actionType == 'item' then
					ActionButton:SetAttribute('cursorID', ID)
				end
				ActionButton:SetAttribute('autoassigned', autoassigned)
				ActionButton:SetAttribute('type', actionType)
				ActionButton:SetAttribute(actionType, ID)
				Animation:ShowNewAction(ActionButton, autoassigned)
				break
			end 
		end
	end
end


---------------------------------------------------------------
-- Manage auto-assigned items (quest items)
---------------------------------------------------------------
local function AddItemForQuestLogIndex(itemTbl, questLogIndex)
	if questLogIndex then
		local link = CPAPI:GetQuestLogSpecialItemInfo(questLogIndex)
		local name = link and GetItemInfo(link)
		if name then
			local _, itemID = strsplit(':', strmatch(link, 'item[%-?%d:]+'))
			if itemID then
				itemTbl[name] = itemID
			end
		end
	end
end

local function GetQuestWatchItems()
	local items = {}
	for i=1, CPAPI:GetNumQuestWatches() do
		AddItemForQuestLogIndex(items, GetQuestIndexForWatch(i))
	end
	for i=1, CPAPI:GetNumWorldQuestWatches() do
		AddItemForQuestLogIndex(items, GetQuestLogIndexByID(GetWorldQuestWatchInfo(i)))
	end
	return items
end

local function GetAutoAssignedItems()
	local items = {}
	for _, button in ipairs(Utility.Buttons) do
		local itemID = button:GetAutoAssigned()
		if itemID then
			items[itemID] = button
		end
	end
	return items
end

local function UpdateQuestItems(self)
	if not InCombatLockdown() then

		local oldItems = GetAutoAssignedItems()
		local newItems = GetQuestWatchItems()

		-- prune items that are not in the new set.
		for currItem, button in pairs(oldItems) do
			if not newItems[currItem] then
				button:SetAttribute('type', nil)
				button:SetAttribute('item', nil)
			end
		end

		-- add new items that are not already autoassigned.
		for newItemName, newItemID in pairs(newItems) do
			if not oldItems[newItemName] then
				AddAction('item', newItemID, true)
			end
		end

		self:RemoveUpdateSnippet(UpdateQuestItems)
	end
end


---------------------------------------------------------------
-- Tooltip 
---------------------------------------------------------------
function Tooltip:Refresh()
	if self.castButton then
		self:AddLine(self.castInfo:format(db.TEXTURE[self.castButton]))
	end
	self:AddLine(self.removeInfo:format(db.TEXTURE.CP_T_L3))
end

function Tooltip:OnShow()
	self.castButton = ConsolePort:GetCurrentBindingOwner('CLICK ConsolePortUtilityToggle:LeftButton')
	-- set CC backdrop
	self:SetBackdropColor(red*0.15, green*0.15, blue*0.15,  0.75)
	self:Refresh()
	FadeIn(self, 0.2, 0, 1)
end

---------------------------------------------------------------
-- Ring maangement 
---------------------------------------------------------------
function Utility:OnEvent(event, ...)
	if (event == 'QUEST_ACCEPTED' or 
		event == 'QUEST_POI_UPDATE' or 
		event == 'QUEST_WATCH_LIST_CHANGED') and self.autoExtra then
		ConsolePort:RunOOC(UpdateQuestItems)
	end
	for _, ActionButton in ipairs(self.Buttons) do
		ActionButton:UpdateState()
	end
end


function Utility:OnButtonFocused(index)
	local button = self:GetAttribute(index)
	local focused = self.oldID and self:GetAttribute(self.oldID)
	if  focused then
		focused:OnLeave()
	end
	if 	button and button:IsVisible() then
		button:OnEnter()

		if self:SetNewRotationValue(button:GetAttribute('rotation')) then
			FadeOut(self.Spell, 1, self.Spell:GetAlpha(), 0)
		else
			FadeIn(self.Spell, 0.2, self.Spell:GetAlpha(), 0.15)
		end

		if button:GetAttribute('type') then
			FadeIn(self.Runes, 3, self.Runes:GetAlpha(), 1)
			FadeIn(self.Ring, 0.2, self.Ring:GetAlpha(), 1)
		else
			FadeOut(self.Ring, 0.5, self.Ring:GetAlpha(), 0)
			FadeOut(self.Runes, 0.5, self.Runes:GetAlpha(), 0)
		end

		self.Gradient:Show()
		self.Gradient:ClearAllPoints()
		self.Gradient:SetPoint('CENTER', button, 'CENTER', 0, 0)
		FadeIn(self.Gradient, 0.2, self.Gradient:GetAlpha(), 1)
		FadeIn(self.Arrow, 0.2, self.Arrow:GetAlpha(), 1)

		self.Spell:Show()
		self.Spell:ClearAllPoints()
		self.Spell:SetPoint('CENTER', button, 0, 0)
	else
		FadeOut(self.Runes, 0.2, self.Runes:GetAlpha(), 0)
		FadeOut(self.Arrow, 0.2, self.Arrow:GetAlpha(), 0)
		FadeOut(self.Ring, 0.1, self.Ring:GetAlpha(), 0)

		self.anglenew = nil
		self.anglecur = nil

		self.Gradient:SetAlpha(0)
		self.Gradient:ClearAllPoints()
		self.Gradient:Hide()

		self.Spell:ClearAllPoints()
		self.Spell:Hide()
	end
	self.oldID = index
end

function Utility:DisplayHints(elapsed)
	self.hintTimer = self.hintTimer + elapsed
	if self.hintTimer > 5 then
		local binding = ConsolePort:GetFormattedBindingOwner('CLICK ConsolePortUtilityToggle:LeftButton', nil, nil, true)
		if binding then
			if self:GetAttribute('toggled') then
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

function Utility:OnUpdateDisplay(elapsed)
	if self.hasHints then
		self:DisplayHints(elapsed)
	end
end

function Utility:OnShow()
	Animation:Hide()
	AniCircle:Hide()
	--self.Spell:SetSize(175, 175)
	FadeOut(self.Ring, 0, 0, 0)
	FadeOut(self.Arrow, 0, 0, 0)
	FadeOut(self.Runes, 0, 0, 0)
	self.hintTimer = 0
	self.hasHints = true
end

function Utility:OnHide()
	self.Gradient:SetAlpha(0)
	self.Gradient:ClearAllPoints()
	self.Gradient:Hide()
--	self.Spell:Hide()
end

Utility:SetAttribute('_onextrabar', [[
	local extraID = 169
	local size = self:RunAttribute('_getsize')
	if newstate then
		for i=1, size do
			local button = self:GetFrameRef(tostring(i))
			if 	button:GetAttribute('type') == 'action' and button:GetAttribute('action') == extraID then
				self:CallMethod('AnimateNew', button:GetName())
				return
			end
		end
		for i=1, size do
			local button = self:GetFrameRef(tostring(i))
			if 	not button:GetAttribute('type') then
				button:SetAlpha(1)
				button:SetAttribute('type', 'action')
				button:SetAttribute('action', extraID)
				self:CallMethod('AnimateNew', button:GetName())
				return
			end
		end
	else
		for i=1, size do
			local button = self:GetFrameRef(tostring(i))
			if 	button:GetAttribute('type') == 'action' and button:GetAttribute('action') == extraID then
				button:SetAlpha(0.5)
				button:SetAttribute('type', nil)
				button:SetAttribute('action', nil)
			end
		end
	end
]])

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------
local function OnButtonContentChanged(self, actionType)
	ConsolePortUtility[self:GetID()] = {
		action = actionType;
		value = self:GetAttribute(actionType);
		cursorID = self:GetAttribute('cursorID');
		autoassigned = self:GetAttribute('autoassigned');
	}
end

local function OnButtonContentRemoved(self)
	ConsolePortUtility[self:GetID()] = nil
end


function Utility:OnNewButton(button, index, angle, rotation)
	button.Cooldown:SetSwipeColor(db.Atlas.GetNormalizedCC())
	button.Pushed:SetVertexColor(red, green, blue, 1)

	button.OnContentChanged = OnButtonContentChanged
	button.OnContentRemoved = OnButtonContentRemoved
	self:SetAttribute(tostring(angle), button)
end

function Utility:OnNewRotation(value)
	self.Ring:SetRotation(value)
	self.Arrow:SetRotation(value)
	self.Runes:SetRotation(value)
end

function Utility:OnRefresh(size)
	for index, info in pairs(ConsolePortUtility) do
		local actionButton = self.Buttons[index]
		if actionButton and info.action then
			actionButton:SetAttribute('autoassigned', info.autoassigned)
			actionButton:SetAttribute('type', info.action)
			actionButton:SetAttribute('cursorID', info.cursorID)
			actionButton:SetAttribute(info.action, info.value)
			actionButton:Show()
		end
	end

	self.autoExtra = db.Settings.autoExtra
	self.frameScale = db.Settings.utilityRingScale or 1
	self:SetScale(self.frameScale)

	self.Runes:SetSize(448 + (8 * size), 448 + (8 * size))
	self.Full:SetTexture([[Interface\AddOns\ConsolePort\Textures\Utility\UtilityGlow]]..size)

	if self.autoExtra then
		ConsolePort:RunOOC(UpdateQuestItems)
	end

	self:SetCursorDrop(true)
	self:SetExtraButtonDrop(self.autoExtra)
	
	for _, event in pairs({
		'ACTIONBAR_UPDATE_COOLDOWN',
		'ACTIONBAR_UPDATE_STATE',
		'ACTIONBAR_UPDATE_USABLE',
		'BAG_UPDATE',
		'BAG_UPDATE_COOLDOWN',
		'QUEST_ACCEPTED',
		'QUEST_POI_UPDATE',
		'QUEST_WATCH_LIST_CHANGED',
		'SPELL_UPDATE_COOLDOWN',
		'SPELL_UPDATE_CHARGES',
		'SPELL_UPDATE_USABLE',
	}) do pcall(self.RegisterEvent, self, event) end
end


---------------------------------------------------------------
function ConsolePort:AddUtilityAction(actionType, value)
	if actionType and value then
		AddAction(actionType, value)
	end
end

function ConsolePort:SetupUtilityRing()
	if not InCombatLockdown() then
		Utility:UnregisterAllEvents()
		Utility:Initialize()
		self:RemoveUpdateSnippet(self.SetupUtilityRing)
	end
end



---------------------------------------------------------------

Utility.Gradient:SetVertexColor(red * colMul, green * colMul, blue * colMul)
Utility.Full:SetVertexColor(red * 1.5, green * 1.5, blue * 1.5)
Utility.Ring:SetVertexColor(red * colMul, green * colMul, blue * colMul)
Utility.Arrow:SetVertexColor(red * 1.25, green * 1.25, blue * 1.25)
---------------------------------------------------------------
Utility:HookScript('OnHide', Utility.OnHide)
Utility:HookScript('OnShow', Utility.OnShow)
Utility:HookScript('OnEvent', Utility.OnEvent)
Utility:HookScript('OnUpdate', Utility.OnUpdateDisplay)
---------------------------------------------------------------


---------------------------------------------------------------
Animation:SetSize(64, 64)
Animation:SetFrameStrata('TOOLTIP')
Animation.Group = Animation:CreateAnimationGroup()
---------------------------------------------------------------
Animation.Icon = Animation:CreateTexture(nil, 'ARTWORK')
Animation.Quest = Animation:CreateTexture(nil, 'OVERLAY')
Animation.Border = Animation:CreateTexture(nil, 'OVERLAY')
Animation.Scale = Animation.Group:CreateAnimation('Scale')
Animation.Fade = Animation.Group:CreateAnimation('Alpha')
---------------------------------------------------------------
Animation.Scale:SetToScale(1, 1)
Animation.Scale:SetFromScale(2, 2)
Animation.Scale:SetDuration(0.5)
Animation.Scale:SetSmoothing('IN')
Animation.Fade:SetFromAlpha(1)
Animation.Fade:SetToAlpha(0)
Animation.Fade:SetSmoothing('OUT')
Animation.Fade:SetStartDelay(3)
Animation.Fade:SetDuration(0.2)
---------------------------------------------------------------
Animation.Border:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal')
Animation.Border:SetAlpha(1)
Animation.Border:SetAllPoints(Animation)
---------------------------------------------------------------
Animation.Icon:SetSize(64, 64)
Animation.Icon:SetPoint('CENTER', 0, 0)
Animation.Icon:SetMask('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Mask')
---------------------------------------------------------------
Animation.Quest:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\QuestButton')
Animation.Quest:SetPoint('CENTER', 0, 0)
Animation.Quest:SetSize(64, 64)
---------------------------------------------------------------
Animation.Gradient = Animation:CreateTexture(nil, 'BACKGROUND')
Animation.Gradient:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Window\\Circle')
Animation.Gradient:SetBlendMode('ADD')
Animation.Gradient:SetVertexColor(red, green, blue, 1)
Animation.Gradient:SetPoint('CENTER', 0, 0)
Animation.Gradient:SetSize(512, 512)	
---------------------------------------------------------------
Animation.Shadow = Animation:CreateTexture(nil, 'BACKGROUND')
Animation.Shadow:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\NormalShadow')
Animation.Shadow:SetSize(82, 82)
Animation.Shadow:SetPoint('CENTER', 0, -6)
Animation.Shadow:SetAlpha(0.75)
---------------------------------------------------------------
Animation.Spell = CreateFrame('PlayerModel', nil, Animation)
Animation.Spell:SetFrameStrata('TOOLTIP')
Animation.Spell:SetPoint('CENTER', Animation.Icon, 'CENTER', -4, 0)
Animation.Spell:SetSize(176, 176)
Animation.Spell:SetAlpha(0)
Animation.Spell:SetDisplayInfo(66673) --(42486)
Animation.Spell:SetCamDistanceScale(2)
Animation.Spell:SetFrameLevel(1)
---------------------------------------------------------------
Animation.Group:SetScript('OnFinished', AnimateOnFinished)
---------------------------------------------------------------
AniCircle:SetPoint('CENTER', 0, 0)
AniCircle:SetSize(512, 512)
AniCircle:Hide()
---------------------------------------------------------------

---------------------------------------------------------------
AniCircle.Ring = AniCircle:CreateTexture(nil, 'OVERLAY', nil, 2)
AniCircle.Ring:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityCircle')
AniCircle.Ring:SetVertexColor(red * colMul, green * colMul, blue * colMul)
AniCircle.Ring:SetPoint('CENTER', 0, 0)
AniCircle.Ring:SetSize(512, 512)
--AniCircle.Ring:SetAlpha(0)
AniCircle.Ring:SetRotation(0)
AniCircle.Ring:SetBlendMode('ADD')
---------------------------------------------------------------
AniCircle.Arrow = AniCircle:CreateTexture(nil, 'OVERLAY')
AniCircle.Arrow:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityArrow')
AniCircle.Arrow:SetVertexColor(red * 1.25, green * 1.25, blue * 1.25)
AniCircle.Arrow:SetPoint('CENTER', 0, 0)
AniCircle.Arrow:SetSize(512, 512)
--AniCircle.Arrow:SetAlpha(0)
AniCircle.Arrow:SetRotation(0)
---------------------------------------------------------------
AniCircle.Runes = AniCircle:CreateTexture(nil, 'OVERLAY')
AniCircle.Runes:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Utility\\UtilityRunes')
AniCircle.Runes:SetPoint('CENTER', 0, 0)
AniCircle.Runes:SetSize(512, 512)
--AniCircle.Runes:SetAlpha(0)
AniCircle.Runes:SetRotation(0)
---------------------------------------------------------------

---------------------------------------------------------------
Tooltip:SetScript('OnShow', Tooltip.OnShow)
Tooltip.castInfo = db.TOOLTIP.UTILITY_RELEASE
Tooltip.removeInfo = db.TOOLTIP.UTILITY_REMOVE
---------------------------------------------------------------