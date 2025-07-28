local env, db, Auto = CPAPI.GetEnv(...); Auto = env.Frame;
---------------------------------------------------------------
local DEFAULT_SET, EXTRA_ACTION_ID = CPAPI.DefaultRingSetID, CPAPI.ExtraActionButtonID;
local SecureHandlerMap = env.SecureHandlerMap;
---------------------------------------------------------------

-- All auto-assigned actions are stored in the DEFAULT_SET,
-- which is the 'Utility Ring', and the action contains a flag
-- to indicate that it was auto-assigned. This is used to
-- automatically remove the action when it is no longer needed.
function Auto:AssignAction(info, preferredIndex)
	info.autoassigned = true;
	return self:AddUniqueAction(DEFAULT_SET, preferredIndex, info)
end

function Auto:IsAutoEnabled()
	return self.autoAssignExtras;
end

function Auto:HasExtraActionButton()
	return self.hasExtraActionButton;
end

function Auto:OnAutoAssignedChanged()
	self.autoAssignExtras = db('ringAutoExtra')
end

db:RegisterCallback('Settings/ringAutoExtra', Auto.OnAutoAssignedChanged, Auto)
env:AddLoader(Auto.OnAutoAssignedChanged)

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function GetItemForQuestID(questID)
	local logIndex = CPAPI.GetQuestLogIndexForQuestID(questID)
	return logIndex and GetQuestLogSpecialItemInfo(logIndex)
end

local function IsActionAutoAssigned(action)
	return action and action.autoassigned;
end

---------------------------------------------------------------
-- Content
---------------------------------------------------------------
function Auto:AddQuestWatchItem(questID)
	local item = GetItemForQuestID(questID)
	if item then
		local info = SecureHandlerMap.item(item)
		info.questID = questID;

		local wasAdded = self:AssignAction(info)
		if wasAdded then
			self:AnnounceAddition(item)
		end
		return wasAdded;
	end
end

function Auto:RemoveQuestWatchItem(questID)
	local wasRemoved = self:ClearActionByAttribute(DEFAULT_SET, 'questID', questID)
	if wasRemoved then
		self:RefreshAll()
	end
end

function Auto:ToggleQuestWatchItem(questID, added)
	if added then
		self:AddQuestWatchItem(questID)
	else
		self:RemoveQuestWatchItem(questID)
	end
end

function Auto:ToggleQuestWatchItemInline(questID)
	local item = GetItemForQuestID(questID)
	if item then
		local info = SecureHandlerMap.item(item)
		info.questID = questID;

		local wasAdded = self:AssignAction(info)
		if wasAdded then
			self:AnnounceAddition(item)
		end
	else
		self:RemoveQuestWatchItem(questID)
	end
end

function Auto:SetObserveQuestID(questID)
	self.observedQuestIDs = self.observedQuestIDs or {};
	self.observedQuestIDs[questID] = true;
end

function Auto:ParseObservedQuestIDs()
	local observedQuestIDs = self.observedQuestIDs;
	if observedQuestIDs then
		self.observedQuestIDs = nil;
		for questID in pairs(observedQuestIDs) do
			self:ToggleQuestWatchItemInline(questID)
		end
	end
end

function Auto:AddAllQuestWatchItems()
	for i=1, CPAPI.GetNumQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
		self:ToggleQuestWatchItem(questID, true)
	end
end

function Auto:RefreshQuestWatchItems()
	self:ClearActionByKey(DEFAULT_SET, 'questID')
	self:AddAllQuestWatchItems()
end

function Auto:ToggleExtraActionButton(enabled)
	if not CPAPI.IsRetailVersion then return end

	if enabled then
		self:AssignAction(SecureHandlerMap.action(EXTRA_ACTION_ID), 1)
		self.hasExtraActionButton = true;
	else
		self:ClearActionByAttribute(DEFAULT_SET, 'action', EXTRA_ACTION_ID)
		self.hasExtraActionButton = false;
	end
end

function Auto:ToggleZoneAbilities()
	local zoneAbilities = CPAPI.GetActiveZoneAbilities()
	table.sort(zoneAbilities, function(lhs, rhs)
		return lhs.uiPriority < rhs.uiPriority;
	end)

	for i, zoneAbility in ipairs(zoneAbilities) do
		local spellID = zoneAbility.spellID;
		if not C_ActionBar.FindSpellActionButtons(spellID) then
			local wasAdded = self:AssignAction(SecureHandlerMap.spellID(spellID))
			if wasAdded then
				self:AnnounceAddition((CPAPI.GetSpellLink(spellID)))
			end
		else
			local index, set = self:SearchActionByAttribute(DEFAULT_SET, 'spell', spellID)
			if index and set and IsActionAutoAssigned(set[index]) then
				self:RemoveAction(DEFAULT_SET, index)
			end
		end
	end
end

function Auto:ToggleInventoryQuestItems(hideAnnouncement)
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
		local link = CPAPI.GetContainerItemInfo(item:GetBagAndSlot()).hyperlink;
		local isQuestItem = link and select(6, GetItemInfoInstant(link)) == LE_ITEM_CLASS_QUESTITEM;
		if isQuestItem and IsUsableItem(link) and not exists[getItemID(link)] then
			local info = SecureHandlerMap.item(link)
			info.autoqitem = true;

			local wasAdded = self:AssignAction(info)
			if wasAdded and not hideAnnouncement then
				self:AnnounceAddition(link)
			end
		end
	end)
end