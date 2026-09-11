local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Quest log model
---------------------------------------------------------------
-- Flavor-neutral view of the quest log built on index/ID-taking
-- getters only, so Blizzard's selected-quest state is never touched
-- except inside Abandon, which saves and restores it.
local QuestLog = CPAPI.CreateEventHandler({'Frame', '$parentQuestLogModel', ConsolePort}, {
	'QUEST_LOG_UPDATE';
	'QUEST_WATCH_LIST_CHANGED';
	'SUPER_TRACKING_CHANGED';
	'QUEST_DATA_LOAD_RESULT';
}); env.QuestLog = QuestLog;

local IsRetail = CPAPI.IsRetailVersion;
local GetNumEntries = C_QuestLog and C_QuestLog.GetNumQuestLogEntries or GetNumQuestLogEntries;
local GetLogIndex   = CPAPI.GetQuestLogIndexForQuestID;

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function QuestLog:QUEST_LOG_UPDATE()
	self.entries = nil;
	env:TriggerEvent('OnQuestLogChanged')
end

QuestLog.QUEST_WATCH_LIST_CHANGED = QuestLog.QUEST_LOG_UPDATE;
QuestLog.SUPER_TRACKING_CHANGED   = QuestLog.QUEST_LOG_UPDATE;

function QuestLog:QUEST_DATA_LOAD_RESULT(questID, success)
	self.requests[questID] = 'done';
	if success then
		env:TriggerEvent('OnQuestDataLoaded', questID)
	end
end

---------------------------------------------------------------
-- Entries
---------------------------------------------------------------
function QuestLog:GetEntries()
	if self.entries then return self.entries end
	local entries = {};
	local numEntries = GetNumEntries and GetNumEntries() or 0;
	local currentHeader;
	for index = 1, numEntries do
		local info = CPAPI.GetQuestInfo(index)
		if info and info.title and not info.isHidden then
			info.questLogIndex = info.questLogIndex or index;
			if info.isHeader then
				currentHeader = info;
				info.quests = 0;
				entries[#entries + 1] = info;
			else
				info.header = currentHeader;
				info.isComplete = C_QuestLog and C_QuestLog.IsComplete and C_QuestLog.IsComplete(info.questID) or info.isComplete or false;
				info.isWatched = self:IsWatched(info.questID, info.questLogIndex)
				info.isSuperTracked = self:IsSuperTracked(info.questID)
				if currentHeader then currentHeader.quests = currentHeader.quests + 1 end
				entries[#entries + 1] = info;
			end
		end
	end
	self.entries = entries;
	return entries;
end

function QuestLog:GetEntryByQuestID(questID)
	for _, entry in ipairs(self:GetEntries()) do
		if entry.questID == questID then return entry end
	end
end

---------------------------------------------------------------
-- Details
---------------------------------------------------------------
function QuestLog:GetText(questLogIndex)
	local description, objectivesText = GetQuestLogQuestText(questLogIndex)
	return description or '', objectivesText or '';
end

function QuestLog:GetObjectives(questID, questLogIndex)
	local objectives = {};
	if C_QuestLog and C_QuestLog.GetQuestObjectives then
		for _, objective in ipairs(C_QuestLog.GetQuestObjectives(questID) or {}) do
			objectives[#objectives + 1] = { text = objective.text, finished = objective.finished };
		end
	elseif GetNumQuestLeaderBoards and questLogIndex then
		for i = 1, GetNumQuestLeaderBoards(questLogIndex) do
			local text, _, finished = GetQuestLogLeaderBoard(i, questLogIndex)
			objectives[#objectives + 1] = { text = text, finished = finished };
		end
	end
	return objectives;
end

function QuestLog:GetCompletionText(questLogIndex)
	return GetQuestLogCompletionText and GetQuestLogCompletionText(questLogIndex) or nil;
end

function QuestLog:HasRewardData(questID)
	return not HaveQuestRewardData or HaveQuestRewardData(questID);
end

function QuestLog:RequestRewardData(questID)
	if self.requests[questID] or not (C_QuestLog and C_QuestLog.RequestLoadQuestByID) then
		return false;
	end
	self.requests[questID] = 'pending';
	C_QuestLog.RequestLoadQuestByID(questID)
	return true;
end

function QuestLog:GetRewards(questID)
	if not IsRetail then return nil end
	local rewards = { items = {}, choices = {} };
	if not self:HasRewardData(questID) then
		rewards.pending = self.requests[questID] ~= 'done';
		self:RequestRewardData(questID)
		return rewards;
	end
	for i = 1, GetNumQuestLogRewards(questID) do
		local name, texture, count, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID)
		rewards.items[#rewards.items + 1] = { name = name, texture = texture, count = count, quality = quality, itemID = itemID };
	end
	for i = 1, GetNumQuestLogChoices(questID, true) do
		local name, texture, count, quality, isUsable, itemID = GetQuestLogChoiceInfo(i, questID)
		rewards.choices[#rewards.choices + 1] = { name = name, texture = texture, count = count, quality = quality, itemID = itemID };
	end
	rewards.money = GetQuestLogRewardMoney(questID)
	rewards.xp    = GetQuestLogRewardXP(questID)
	if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestRewardCurrencies then
		rewards.currencies = C_QuestInfoSystem.GetQuestRewardCurrencies(questID)
	end
	return rewards;
end

---------------------------------------------------------------
-- State
---------------------------------------------------------------
function QuestLog:IsWatched(questID, questLogIndex)
	if QuestUtils_IsQuestWatched then
		return QuestUtils_IsQuestWatched(questID)
	elseif IsQuestWatched and questLogIndex then
		return IsQuestWatched(questLogIndex)
	end
	return false;
end

function QuestLog:IsSuperTracked(questID)
	return C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID() == questID or false;
end

---------------------------------------------------------------
-- Actions
---------------------------------------------------------------
function QuestLog:ToggleWatch(questID)
	local questLogIndex = GetLogIndex(questID)
	if self:IsWatched(questID, questLogIndex) then
		if C_QuestLog and C_QuestLog.RemoveQuestWatch then
			C_QuestLog.RemoveQuestWatch(questID)
		elseif RemoveQuestWatch and questLogIndex then
			RemoveQuestWatch(questLogIndex)
		end
	else
		if C_QuestLog and C_QuestLog.AddQuestWatch then
			C_QuestLog.AddQuestWatch(questID)
		elseif AddQuestWatch and questLogIndex then
			AddQuestWatch(questLogIndex)
		end
	end
	return true;
end

function QuestLog:SetSuperTracked(questID)
	if not C_SuperTrack then return false end
	if self:IsSuperTracked(questID) then
		C_SuperTrack.SetSuperTrackedQuestID(0)
	else
		C_SuperTrack.SetSuperTrackedQuestID(questID)
	end
	return true;
end

function QuestLog:CanShare(questID)
	return IsInGroup() and C_QuestLog and C_QuestLog.IsPushableQuest and C_QuestLog.IsPushableQuest(questID) or false;
end

function QuestLog:Share(questID)
	local questLogIndex = GetLogIndex(questID)
	if questLogIndex and QuestLogPushQuest then
		QuestLogPushQuest(questLogIndex)
		return true;
	end
	return false;
end

function QuestLog:CanAbandon(questID)
	if C_QuestLog and C_QuestLog.CanAbandonQuest then
		return C_QuestLog.CanAbandonQuest(questID)
	end
	return GetLogIndex(questID) ~= nil;
end

function QuestLog:Abandon(questID)
	if C_QuestLog and C_QuestLog.SetSelectedQuest then
		local previous = C_QuestLog.GetSelectedQuest()
		C_QuestLog.SetSelectedQuest(questID)
		C_QuestLog.SetAbandonQuest()
		local title = C_QuestLog.GetAbandonQuest and C_QuestLog.GetTitleForQuestID(questID) or '';
		C_QuestLog.AbandonQuest()
		C_QuestLog.SetSelectedQuest(previous)
		return title;
	end
	local questLogIndex = GetLogIndex(questID)
	if questLogIndex and SelectQuestLogEntry then
		local previous = GetQuestLogSelection and GetQuestLogSelection()
		SelectQuestLogEntry(questLogIndex)
		SetAbandonQuest()
		AbandonQuest()
		if previous then SelectQuestLogEntry(previous) end
		return true;
	end
end

function QuestLog:ConfirmAbandon(questID, title)
	CPAPI.Popup('ConsolePort_Map_Abandon_Quest', {
		text = ABANDON_QUEST_CONFIRM or L'Abandon %s?';
		button1 = YES;
		button2 = NO;
		timeout = 0;
		hideOnEscape = true;
		OnAccept = function()
			QuestLog:Abandon(questID)
		end;
	}, title)
end

---------------------------------------------------------------
-- Map position
---------------------------------------------------------------
function QuestLog:GetMapForQuest(questID)
	if GetQuestUiMapID then
		local mapID = GetQuestUiMapID(questID)
		if mapID and mapID > 0 then return mapID end
	end
	if C_QuestLog and C_QuestLog.GetNextWaypoint then
		local mapID = C_QuestLog.GetNextWaypoint(questID)
		if mapID then return mapID end
	end
	return nil;
end

function QuestLog:GetPositionOnMap(questID, mapID)
	if C_QuestLog and C_QuestLog.GetNextWaypointForMap then
		local x, y = C_QuestLog.GetNextWaypointForMap(questID, mapID)
		if x and y then return x, y end
	end
	if C_QuestLog and C_QuestLog.GetQuestsOnMap then
		for _, info in ipairs(C_QuestLog.GetQuestsOnMap(mapID) or {}) do
			if info.questID == questID then return info.x, info.y end
		end
	end
	return nil;
end

QuestLog.requests = {};

function QuestLog:OnDataLoaded()
	self:QUEST_LOG_UPDATE()
	return CPAPI.BurnAfterReading;
end
