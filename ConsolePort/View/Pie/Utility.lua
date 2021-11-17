local _, db = ...;
---------------------------------------------------------------
local Utility = Mixin(CPAPI.EventHandler(ConsolePortUtilityToggle, {
	'ACTIONBAR_SLOT_CHANGED';
	'BAG_UPDATE_DELAYED';
	'SPELLS_CHANGED';
	'QUEST_WATCH_UPDATE';
	'QUEST_WATCH_LIST_CHANGED';
	'UPDATE_BINDINGS';
	CPAPI.IsRetailVersion and 'UPDATE_EXTRA_ACTIONBAR';
}), CPAPI.AdvancedSecureMixin)
local Button = CreateFromMixins(CPActionButton);
---------------------------------------------------------------
local DEFAULT_SET, EXTRA_ACTION_ID = 1, ExtraActionButton1 and ExtraActionButton1.action or 169;
---------------------------------------------------------------
Utility.Data = {[DEFAULT_SET] = {}};
Utility:Execute([[DATA = newtable()]])
db:Register('Utility', Utility)
db:Save('Utility/Data', 'ConsolePortUtility')

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Utility:CreateEnvironment({
	-----------------------------------------------------------
	-- Draw current ring
	-----------------------------------------------------------
	DrawSelectedRing = [[
		local set = ...;
		RING = DATA[set];
		if not RING then
			return
		end

		local radius = math.sqrt(self:GetWidth() * self:GetHeight()) / 2;
		local numActive = #RING;
		local invertY = self:GetAttribute('axisInversion')

		self:SetAttribute('trigger', self::GetButtonsHeld())
		self:SetAttribute('state', set)
		control:ChildUpdate('state', set)

		for i, action in ipairs(RING) do
			local x, y = radial:RunAttribute('GetPointForIndex', i, numActive, radius)
			local widget = self:GetFrameRef(set..':'..i)

			widget:Show()
			widget:ClearAllPoints()
			widget:SetPoint('CENTER', '$parent', 'CENTER', x, invertY * y)
		end
		for i=numActive+1, self:GetAttribute('numButtons') do
			self:GetFrameRef(tostring(i)):Hide()
		end
		self:SetAttribute('size', numActive)
	]];
	CopySelectedIndex = [[
		local index = ...;
		if not RING or not index then
			return self:CallMethod('ClearInstantly')
		end
		for attribute, value in pairs(RING[index]) do
			self:SetAttribute(attribute, value)
		end
	]];
	GetRingSetFromButton = ([[
		local button = ...;
		if DATA[button] then
			return button;
		end
		return tostring(%s);
	]]):format(DEFAULT_SET);
	-----------------------------------------------------------
	-- Set pre-defined remove binding
	-----------------------------------------------------------
	SetRemoveBinding = [[
		local enabled = ...;
		if enabled then
			local binding, trigger = self:GetAttribute('removeButton'), self:GetAttribute('trigger')
			if trigger and binding and trigger:match(binding) then
				self:SetAttribute('removeButtonBlocked', true)
				return self:ClearBindings()
			end

			self:SetAttribute('removeButtonBlocked', false)
			local mods = {self::GetModifiersHeld()}
			table.sort(mods)
			mods[#mods+1] = table.concat(mods)

			local removeWidget = self:GetFrameRef('Remove')
			for _, mod in ipairs(mods) do
				self:SetBindingClick(true, mod..binding, removeWidget)
			end
			self:SetBindingClick(true, binding, removeWidget)
		else
			self:ClearBindings()
		end
	]];
});

---------------------------------------------------------------
-- Trigger script
---------------------------------------------------------------
Utility:Wrap('PreClick', [[
	self:SetAttribute('type', nil)

	if down then
		local set = self::GetRingSetFromButton(button)
		self:CallMethod('CheckCursorInfo', set)
		self::DrawSelectedRing(set)
		self::SetRemoveBinding(true)
		self:Show()
	else
		self::CopySelectedIndex(self::GetIndex())
		self:ClearBindings()
		self:Hide()
	end
]])


---------------------------------------------------------------
-- Secure removal
---------------------------------------------------------------
Utility:SetFrameRef('Remove', Utility.Remove)
Utility:WrapScript(Utility.Remove, 'OnClick', [[
	local index = control:Run(GetIndex)
	local set = control:GetAttribute('state')
	if set and index then
		control:CallMethod('SafeRemoveAction', set, index)
		control:Run(DrawSelectedRing, set)
	end
]])

---------------------------------------------------------------
-- Data handling
---------------------------------------------------------------
function Utility:OnDataLoaded()
	self:SetAttribute('size', 0)
	self:CreateFramePool('SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate, CPUIActionButtonTemplate', Button)
	db:Load('Utility/Data', 'ConsolePortUtility')

	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'UtilityRing', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			local size = self:GetAttribute('size');
		]];
	});
	self:RefreshAll()
	setmetatable(self.Data, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end})
	self:OnAutoAssignedChanged()
	self:OnRemoveButtonChanged()
	self:OnAxisInversionChanged()
end

function Utility:OnAutoAssignedChanged()
	self.autoAssignExtras = db('autoExtra')
end

function Utility:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
	self:SetAttribute('axisInversion', self.axisInversion)
end

function Utility:OnRemoveButtonChanged()
	self:SetAttribute('removeButton', db('radialRemoveButton'))
end

function Utility:OnPrimaryStickChanged()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	self:SetInterrupt(sticks)
	self:SetIntercept({sticks[1]})
end

db:RegisterSafeCallback('Settings/autoExtra', Utility.OnAutoAssignedChanged, Utility)
db:RegisterSafeCallback('Settings/radialCosineDelta', Utility.OnAxisInversionChanged, Utility)
db:RegisterSafeCallback('Settings/radialRemoveButton', Utility.OnRemoveButtonChanged, Utility)
db:RegisterSafeCallback('Settings/radialPrimaryStick', Utility.OnPrimaryStickChanged, Utility)

---------------------------------------------------------------
-- Widget handling
---------------------------------------------------------------
function Utility:RefreshAll()
	self:ClearAllActions()
	local numButtons = 0;
	for setID, set in pairs(self.Data) do
		for i, action in ipairs(set) do
			self:AddSecureAction(setID, i, action)
		end
		numButtons = #set > numButtons and #set or numButtons;
	end
	self:SetAttribute('numButtons', numButtons)
end

function Utility:ClearAllActions()
	self:Execute('wipe(DATA)')
	for button in self:EnumerateActive() do
		button:ClearStates()
	end
	self:ReleaseAll()
end

function Utility:AddSecureAction(set, idx, info)
	local button, newObj = self:TryAcquireRegistered(idx)
	if newObj then
		button:SetFrameLevel(idx)
		button:SetID(idx)
		button:OnLoad()
		button:DisableDragNDrop(true)
		self:SetFrameRef(tostring(idx), button)
	end

	self:SetFrameRef(set..':'..idx, button)
	button:SetState(set, self:GetKindAndAction(info))

	local args, body = { ring = tostring(set), slot = idx }, [[
		local ring = DATA[{ring}];
		if not ring then
			DATA[{ring}] = newtable();
			ring = DATA[{ring}];
		end

		local slot = ring[{slot}];
		if not slot then
			ring[{slot}] = newtable();
			slot = ring[{slot}];
		end
	]];
	for key, value in pairs(info) do
		body = ('%s\n slot.%s = {%s}'):format(body, key, key)
		args[key] = value;
	end
	return self:Parse(body, args)
end

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
function Utility:OnInput(x, y, len, stick)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetAttribute('size')))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, len > self:GetValidThreshold())
end

function Utility:GetButtonSlugForSet(setID)
	return db.Hotkeys:GetButtonSlugForBinding(('CLICK ConsolePortUtilityToggle:%s'):format(setID));
end

function Utility:GetBindingSuffixForSet(setID)
	return (tonumber(setID) == DEFAULT_SET and 'LeftButton' or tostring(setID));
end

function Utility:GetTooltipRemovePrompt()
	local removeButton = not self:GetAttribute('removeButtonBlocked') and self:GetAttribute('removeButton')
	local device = db('Gamepad/Active')
	if removeButton and device then
		return device:GetTooltipButtonPrompt(removeButton, REMOVE, 64)
	end
end

function Utility:GetTooltipUsePrompt()
	local useButton = self:GetAttribute('trigger')
	local device = db('Gamepad/Active')
	if useButton and device then
		return device:GetTooltipButtonPrompt(useButton, USE, 64)
	end
end

---------------------------------------------------------------
-- Set manager
---------------------------------------------------------------
function Utility:AddSavedVar(setID, idx, info)
	setID = setID or DEFAULT_SET;
	local set = self.Data[setID];
	local maxIndex = #set + 1;
	idx = Clamp(idx or maxIndex, 1, maxIndex)
	tinsert(set, idx, info)
end

function Utility:RemoveSavedVar(setID, idx)
	return tremove(self.Data[setID], idx)
end

function Utility:AddAction(setID, idx, info)
	self:AddSavedVar(setID, idx, info)
	self:RefreshAll()
	return true;
end

function Utility:RemoveAction(setID, idx)
	local action = self:RemoveSavedVar(setID, idx)
	self:RefreshAll()
	return action;
end

function Utility:SafeAddAction(setID, idx, ...)
	local info = {};
	for i=1, select('#', ...), 2 do
		info[select(i, ...)] = select(i + 1, ...);
	end
	self:AddSavedVar(tonumber(setID) or setID, tonumber(idx), info)
end

function Utility:SafeRemoveAction(setID, idx)
	if not InCombatLockdown() then
		self:RemoveAction(tonumber(setID) or setID, tonumber(idx))
	end
end

function Utility:ClearActionByAttribute(setID, key, value)
	local index = self:SearchActionByAttribute(setID, key, value)
	if index then
		return self:RemoveAction(setID, index)
	end
end

function Utility:ClearActionByKey(setID, key)
	local index = self:SearchActionByKey(setID, key)
	if index then
		return self:RemoveAction(setID, index)
	end
end

function Utility:SearchActionByAttribute(setID, key, value)
	local set = self.Data[setID];
	for i, action in ipairs(set) do
		for attribute, content in pairs(action) do
			if (attribute == key and content == value) then
				return i, set;
			end
		end
	end
end

function Utility:SearchActionByKey(setID, key)
	local set = self.Data[setID];
	for i, action in ipairs(set) do
		for attribute in pairs(action) do
			if (attribute == key) then
				return i, set;
			end
		end
	end
end

function Utility:IsUniqueAction(setID, info)
	local set = self.Data[setID];
	local cmp = db.table.compare;
	-- check if already existing on ring
	for i, action in ipairs(set) do
		if cmp(action, info) then
			return false, i;
		end
	end
	return true;
end

---------------------------------------------------------------
-- Announcements
---------------------------------------------------------------
Utility.Messages, Utility.MessageCount = {}, 0;

function Utility:AnnounceAddition(link, set, force)
	local slug = self:GetButtonSlugForSet(set or 'LeftButton')
	if self.MessageCount > 10 then
		wipe(self.Messages)
		self.MessageCount = 0;
	end
	local messageID = self:GetBindingSuffixForSet(set) .. link;
	local messageIsNew = not self.Messages[messageID]; 
	if force or messageIsNew then
		CPAPI.Log('%s was added to your utility ring. Use: %s', link, slug or NOT_BOUND)
		self.Messages[messageID] = true;
		if messageIsNew then
			self.MessageCount = self.MessageCount + 1;
		end
	end
end

function Utility:AnnounceRemoval(link, set)
	CPAPI.Log('%s was removed from your utility ring.', link)
	local messageID = self:GetBindingSuffixForSet(set) .. link;
	if self.Messages[messageID] then
		self.Messages[messageID] = nil;
		self.MessageCount = self.MessageCount - 1;
	end
end

---------------------------------------------------------------
-- Mapping from type to usable attributes
---------------------------------------------------------------
Utility.KindAndActionMap = {
	action = function(data) return data.action end;
	item   = function(data) return data.item end;
	pet    = function(data) return data.action end;
	spell  = function(data) return data.spell end;
	macro  = function(data) return data.macro end;
	equipmentset = function(data) return data.equipmentset end;
}

function Utility:GetKindAndAction(info)
	return info.type, self.KindAndActionMap[info.type](info);
end

---------------------------------------------------------------
-- Link map
---------------------------------------------------------------
Utility.LinkMap = {
	spell = function(spell, ...)
		local args = select('#', ...)
		if (args > 1) then
			local bookType = ...;
			return GetSpellLink(spell, bookType)
		end
		return GetSpellLink(spell)
	end;
	item = function(...)
		return select(2, ...)
	end;
}

function Utility:GetLinkFromInfo(type, ...)
	local func = self.LinkMap[type];
	if func then
		return func(...)
	end
end

---------------------------------------------------------------
-- Mapping from cursor info
---------------------------------------------------------------
Utility.SecureHandlerMap = {
	action = function(action)
		return {type = 'action', action = action};
	end;
	item = function(itemID, itemLink)
		return {type = 'item', item = itemLink or itemID};
	end;
	spell = function(spellIndex, bookType, spellID)
		return {type = 'spell', spell = spellID};
	end;
	macro = function(index)
		return {type = 'macro', macro = index};
	end;
	mount = function(mountID)
		local spellID = select(2, C_MountJournal.GetMountInfoByID(mountID));
		if spellID then
			return {type = 'spell', spell = spellID};
		end
	end;
	petaction = function(spellID, indexIsOffset)
		if indexIsOffset then
			return {type = 'spell', spell = spellID};
		end
	end;
	equipmentset = function(name)
		return {type = 'equipmentset', equipmentset = name};
	end;
	spellID = function(spellID)
		return {type = 'spell', spell = spellID}
	end;
}

function Utility:AddActionFromInfo(setID, idx, infoType, ...)
	local infoHandler = self.SecureHandlerMap[infoType]
	if infoHandler then
		local info = infoHandler(...)
		if info then
			return self:AddAction(setID, idx, info)
		end
	end
end

---------------------------------------------------------------
-- Special content handlers
---------------------------------------------------------------
function Utility:AddFromCursorInfo(setID, idx)
	return self:AddActionFromInfo(setID, idx, GetCursorInfo())
end

function Utility:AddUniqueAction(setID, info, preferredIndex)
	if self:IsUniqueAction(setID, info) then
		return self:AddAction(setID, preferredIndex, info)
	end
end

function Utility:AutoAssignAction(info, preferredIndex)
	info.autoassigned = true;
	return self:AddUniqueAction(DEFAULT_SET, info, preferredIndex)
end

function Utility:GetItemForQuestID(questID)
	local logIndex = CPAPI.GetQuestLogIndexForQuestID(questID)
	return logIndex and GetQuestLogSpecialItemInfo(logIndex)
end

function Utility:AddQuestWatchItem(questID)
	local item = self:GetItemForQuestID(questID)
	if item then
		local info = self.SecureHandlerMap.item(item)
		info.questID = questID;

		local wasAdded = self:AutoAssignAction(info)
		if wasAdded then
			self:AnnounceAddition(item)
		end
		return wasAdded;
	end
end

function Utility:RemoveQuestWatchItem(questID)
	local wasRemoved = self:ClearActionByAttribute(DEFAULT_SET, 'questID', questID)
	if wasRemoved then
		self:RefreshAll()
	end
end

function Utility:ToggleQuestWatchItem(questID, added)
	if added then
		self:AddQuestWatchItem(questID)
	else
		self:RemoveQuestWatchItem(questID)
	end
end

function Utility:ToggleQuestWatchItemInline(questID)
	local item = self:GetItemForQuestID(questID)
	if item then
		local info = self.SecureHandlerMap.item(item)
		info.questID = questID;

		local wasAdded = self:AutoAssignAction(info)
		if wasAdded then
			self:AnnounceAddition(item)
		end
	else
		self:RemoveQuestWatchItem(questID)
	end
end

function Utility:SetObserveQuestID(questID)
	self.observedQuestIDs = self.observedQuestIDs or {};
	self.observedQuestIDs[questID] = true;
end

function Utility:ParseObservedQuestIDs()
	local observedQuestIDs = self.observedQuestIDs;
	if observedQuestIDs then
		self.observedQuestIDs = nil;
		for questID in pairs(observedQuestIDs) do
			self:ToggleQuestWatchItemInline(questID)
		end
	end
end

function Utility:AddAllQuestWatchItems()
	for i=1, CPAPI.GetNumQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
		self:ToggleQuestWatchItem(questID, true)
	end
end

function Utility:RefreshQuestWatchItems()
	self:ClearActionByKey(DEFAULT_SET, 'questID')
	self:AddAllQuestWatchItems()
end

function Utility:ToggleExtraActionButton(enabled)
	if not CPAPI.IsRetailVersion then return end
	
	if enabled then
		self:AutoAssignAction(self.SecureHandlerMap.action(EXTRA_ACTION_ID), 1)
	else
		self:ClearActionByAttribute(DEFAULT_SET, 'action', EXTRA_ACTION_ID)
	end
end

function Utility:ToggleZoneAbilities()
	local zoneAbilities = CPAPI.GetActiveZoneAbilities()
	table.sort(zoneAbilities, function(lhs, rhs)
		return lhs.uiPriority < rhs.uiPriority;
	end)

	for i, zoneAbility in ipairs(zoneAbilities) do
		local spellID = zoneAbility.spellID;
		if not C_ActionBar.FindSpellActionButtons(spellID) then
			local wasAdded = self:AutoAssignAction(self.SecureHandlerMap.spellID(spellID))
			if wasAdded then
				self:AnnounceAddition((GetSpellLink(spellID)))
			end
		else
			local index, set = self:SearchActionByAttribute(DEFAULT_SET, 'spell', spellID)
			if index and set then
				local action = set[index];
				if action and action.autoassigned then
					self:RemoveAction(DEFAULT_SET, index)
				end
			end
		end
	end
end

function Utility:ToggleInventoryQuestItems(hideAnnouncement)
	if CPAPI.IsRetailVersion then return end
	local function getItemID(input) return input:match('item:(%d+)') end;

	local set, exists = self.Data[DEFAULT_SET], {};
	for i = #set, 1, -1 do
		local info = set[i];
		if info.autoqitem then
			local itemID = getItemID(info.item);
			if GetItemCount(info.item) < 1 or exists[itemID] then
				self:RemoveAction(DEFAULT_SET, i)
			else
				exists[itemID] = true;
			end
		end
	end

	CPAPI.IteratePlayerInventory(function(item)
		local link = select(7, GetContainerItemInfo(item:GetBagAndSlot()))
		local isQuestItem = link and select(6, GetItemInfoInstant(link)) == LE_ITEM_CLASS_QUESTITEM;
		if isQuestItem and IsUsableItem(link) and not exists[getItemID(link)] then
			local info = self.SecureHandlerMap.item(link)
			info.autoqitem = true;

			local wasAdded = self:AutoAssignAction(info)
			if wasAdded and not hideAnnouncement then
				self:AnnounceAddition(link)
			end
		end
	end)
end

function Utility:CheckCursorInfo(setID)
	if not InCombatLockdown() then
		setID = tonumber(setID) or setID;
		if GetCursorInfo() then
			if self:AddFromCursorInfo(setID) then
				-- TODO: map returns to links
				self:AnnounceAddition(
					GetCursorInfo():gsub('^%l', strupper),
					self:GetBindingSuffixForSet(setID), true
				);
				ClearCursor()
			end
		end
	end
end

---------------------------------------------------------------
-- Pending action
---------------------------------------------------------------
local function CreatePendingAction(setID, info, enabled)
	return {
		setID = setID;
		info  = info;
		add   = enabled;
	};
end

function Utility:SetPendingAction(setID, info, force)
	if force or self:IsUniqueAction(setID, info) then
		self.pendingAction = CreatePendingAction(setID, info, true)
		return true;
	end
end

function Utility:SetPendingRemove(setID, info)
	self.pendingAction = CreatePendingAction(setID, info, false)
end

function Utility:HasPendingAction()
	return self.pendingAction;
end

function Utility:ClearPendingAction()
	self.pendingAction = nil;
end

function Utility:PostPendingAction(preferredIndex)
	local action = self.pendingAction;
	if action then
		if action.add then
			if self:AddAction(action.setID, preferredIndex, action.info) then
				self:AnnounceAddition(action.info.link, self:GetBindingSuffixForSet(action.setID), true)
			end
		else
			if self:ClearActionByAttribute(action.setID, 'link', action.info.link) then
				self:AnnounceRemoval(action.info.link)
			end
		end
		self.pendingAction = nil;
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Utility:QUEST_WATCH_LIST_CHANGED(questID, added)
	if self.autoAssignExtras then
		if questID then
			db:RunSafe(self.ToggleQuestWatchItem, self, questID, added)
		else
			db:RunSafe(self.RefreshQuestWatchItems, self)
		end
	end
end

function Utility:QUEST_WATCH_UPDATE(questID)
	if self.autoAssignExtras then
		self:SetObserveQuestID(questID)
	end
end

function Utility:UPDATE_BINDINGS()
	if self.autoAssignExtras and not db.Gamepad:GetBindingKey('EXTRAACTIONBUTTON1') then
		self.hasExtraActionButton = true;
		db:RunSafe(self.ToggleExtraActionButton, self, true)
	else
		self.hasExtraActionButton = false;
		db:RunSafe(self.ToggleExtraActionButton, self, false)
	end
end

function Utility:UPDATE_EXTRA_ACTIONBAR()
	if self.hasExtraActionButton and HasExtraActionBar() then
		local link = self:GetLinkFromInfo(GetActionInfo(EXTRA_ACTION_ID))
		self:AnnounceAddition(link or BINDING_NAME_EXTRAACTIONBUTTON1, nil, true)
	end
end

-- NOTE: Register unit event instead of QUEST_LOG_UPDATE
-- to get around spam issue with certain addons.
Utility:RegisterUnitEvent('UNIT_QUEST_LOG_CHANGED', 'player')
function Utility:UNIT_QUEST_LOG_CHANGED()
	if self.autoAssignExtras then
		db:RunSafe(self.ParseObservedQuestIDs, self)
		db:RunSafe(self.RefreshQuestWatchItems, self)
	end
end

function Utility:SPELLS_CHANGED()
	if self.autoAssignExtras then
		db:RunSafe(self.ToggleZoneAbilities, self)
	end
end

function Utility:ACTIONBAR_SLOT_CHANGED()
	if self.autoAssignExtras then
		db:RunSafe(self.ToggleZoneAbilities, self)
	end
end

function Utility:BAG_UPDATE_DELAYED()
	if self.autoAssignExtras then
		db:RunSafe(self.ToggleInventoryQuestItems, self, not self.announceBagAdditions)
		self.announceBagAdditions = true;
	end
end

---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
function Button:OnLoad()
	self:Initialize()
	self:SetScript('OnHide', self.OnClear)
	self:SetScript('OnShow', self.UpdateAssets)
end

function Button:UpdateAssets()
	local bg = self.Shadow;
	bg:ClearAllPoints()
	if (self:GetAttribute('action') == EXTRA_ACTION_ID) then
		bg:SetTexture(CPAPI.GetOverrideBarSkin() or 'Interface\\ExtraButton\\Default')
		bg:SetSize(256 * 0.8, 128 * 0.8)
		bg:SetPoint('CENTER', -2, 0)
	else
		bg:SetTexture(CPAPI.GetAsset('Textures\\Button\\Shadow'))
		bg:SetPoint('TOPLEFT', -5, 0)
		bg:SetPoint('BOTTOMRIGHT', 5, -10)
	end
end

function Button:OnFocus()
	self:SetChecked(true)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:SetTooltip()
	local use = Utility:GetTooltipUsePrompt()
	local remove = Utility:GetTooltipRemovePrompt()
	if use then
		GameTooltip:AddLine(use)
	end
	if ( remove and remove ~= use ) then
		GameTooltip:AddLine(remove)
	end
	GameTooltip:Show()
end

function Button:OnClear()
	self:SetChecked(false)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end