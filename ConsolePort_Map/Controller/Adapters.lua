local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Pin adapters
---------------------------------------------------------------
-- Interaction with pins is never delegated to Blizzard's handlers.
-- Each adapter reads pin data and the C API only:
--   Tooltip(pin, tooltip)  fill an already-owned GameTooltip
--   Primary(pin, canvas)   accept button; return true if handled
--   Secondary(pin, canvas) track/waypoint button; return true if handled
--   Label(pin)             short label for hints
local Adapters = {}; env.Adapters = Adapters;

local function GetQuestTitle(questID)
	return C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)
		or (QuestUtils_GetQuestName and QuestUtils_GetQuestName(questID))
		or ('%s %d'):format(QUEST_LABEL or 'Quest', questID);
end

local function AddQuestObjectives(tooltip, questID)
	if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then return end
	local objectives = C_QuestLog.GetQuestObjectives(questID)
	if not objectives then return end
	for _, objective in ipairs(objectives) do
		if objective.text and not objective.finished then
			tooltip:AddLine(QUEST_DASH..objective.text, 1, 1, 1, true)
		end
	end
end

local function SuperTrackQuest(questID)
	if not C_SuperTrack then return false end
	if C_SuperTrack.GetSuperTrackedQuestID() == questID then
		C_SuperTrack.SetSuperTrackedQuestID(0)
	else
		C_SuperTrack.SetSuperTrackedQuestID(questID)
	end
	return true;
end

local Generic = {
	Tooltip = function(pin, tooltip)
		local name = pin.name or (pin.GetDisplayName and pin:GetDisplayName())
			or (pin.poiInfo and pin.poiInfo.name) or (pin.taxiNodeData and pin.taxiNodeData.name);
		if not name then return false end
		tooltip:SetText(name)
		local description = pin.description or (pin.poiInfo and pin.poiInfo.description);
		if description and description ~= '' then
			tooltip:AddLine(description, 1, 1, 1, true)
		end
		return true;
	end;
	Primary   = function() return false end;
	Secondary = function() return false end;
	Label     = function(pin)
		return pin.name or (pin.GetDisplayName and pin:GetDisplayName()) or nil;
	end;
};

local function Define(template, adapter)
	Adapters[template] = setmetatable(adapter, { __index = Generic });
end

---------------------------------------------------------------
-- Quests
---------------------------------------------------------------
local QuestAdapter = {
	Tooltip = function(pin, tooltip)
		local questID = pin.questID or (pin.GetQuestID and pin:GetQuestID())
		if not questID then return false end
		tooltip:SetText(GetQuestTitle(questID))
		if QuestUtils_AddQuestTypeToTooltip then
			QuestUtils_AddQuestTypeToTooltip(tooltip, questID, NORMAL_FONT_COLOR)
		end
		if C_QuestLog.IsComplete and C_QuestLog.IsComplete(questID) then
			tooltip:AddLine(QUEST_DASH..(QUEST_WATCH_QUEST_READY or COMPLETE), 0, 1, 0)
		else
			AddQuestObjectives(tooltip, questID)
		end
		return true;
	end;
	Primary = function(pin, canvas)
		local questID = pin.questID or (pin.GetQuestID and pin:GetQuestID())
		if not questID then return false end
		env:TriggerEvent('OnQuestSelected', questID)
		return SuperTrackQuest(questID);
	end;
	Secondary = function(pin)
		local questID = pin.questID or (pin.GetQuestID and pin:GetQuestID())
		if not questID then return false end
		return env.QuestLog:ToggleWatch(questID);
	end;
	Label = function(pin)
		return C_SuperTrack and (C_SuperTrack.GetSuperTrackedQuestID() == pin.questID and L'Untrack' or L'Track') or L'Select';
	end;
};
Define('QuestPinTemplate', QuestAdapter)
Define('StorylineQuestPinTemplate', QuestAdapter)

local TaskAdapter = {
	Tooltip = function(pin, tooltip)
		local questID = pin.questID;
		if not questID then return false end
		if GameTooltip_AddQuest and HaveQuestData(questID) then
			GameTooltip_AddQuest(pin)
		else
			tooltip:SetText(GetQuestTitle(questID))
			AddQuestObjectives(tooltip, questID)
		end
		return true;
	end;
	Primary = function(pin)
		return pin.questID and SuperTrackQuest(pin.questID) or false;
	end;
	Label = QuestAdapter.Label;
};
Define('WorldQuestPinTemplate', TaskAdapter)
Define('BonusObjectivePinTemplate', TaskAdapter)
Define('ThreatObjectivePinTemplate', TaskAdapter)

---------------------------------------------------------------
-- Points of interest
---------------------------------------------------------------
Define('AreaPOIPinTemplate', {
	Tooltip = function(pin, tooltip)
		local info = pin.poiInfo;
		if not info then return false end
		tooltip:SetText(info.name or '')
		if info.description and info.description ~= '' then
			tooltip:AddLine(info.description, 1, 1, 1, true)
		end
		if info.areaPoiID and C_AreaPoiInfo.GetAreaPOISecondsLeft then
			local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(info.areaPoiID)
			if secondsLeft and secondsLeft > 0 then
				tooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(SecondsToTime(secondsLeft)), 1, 1, 1)
			end
		end
		return true;
	end;
})

Define('MapLinkPinTemplate', {
	Primary = function(pin, canvas)
		local linkedMapID = pin.linkedUiMapID or (pin.mapLinkInfo and pin.mapLinkInfo.linkedUiMapID)
		if not linkedMapID then return false end
		canvas:NavigateTo(linkedMapID)
		return true;
	end;
	Label = function() return L'Open' end;
})

Define('WaypointLocationPinTemplate', {
	Tooltip = function(pin, tooltip)
		tooltip:SetText(MAP_PIN or L'Map Pin')
		tooltip:AddLine(L'Press the waypoint button to remove.', 1, 1, 1)
		return true;
	end;
	Secondary = function()
		C_Map.ClearUserWaypoint()
		return true;
	end;
	Label = function() return L'Remove' end;
})

---------------------------------------------------------------
-- Flight
---------------------------------------------------------------
Define('FlightMap_FlightPointPinTemplate', {
	Tooltip = function(pin, tooltip)
		local node = pin.taxiNodeData;
		if not node then return false end
		tooltip:SetText(node.name or '')
		if node.state == Enum.FlightPathState.Current then
			tooltip:AddLine(L'You are here.', 1, 1, 1)
		elseif node.state == Enum.FlightPathState.Unreachable then
			tooltip:AddLine(L'Not connected.', 1, 0.3, 0.3)
		end
		return true;
	end;
	Primary = function(pin)
		local node = pin.taxiNodeData;
		if not node or pin.isMapLayerTransition then return false end
		if node.state == Enum.FlightPathState.Reachable then
			TakeTaxiNode(node.slotIndex)
			return true;
		end
		return false;
	end;
	Label = function(pin)
		local node = pin.taxiNodeData;
		return node and node.state == Enum.FlightPathState.Reachable and L'Fly' or nil;
	end;
})

---------------------------------------------------------------
-- Lookup
---------------------------------------------------------------
function Adapters:Get(pin)
	return pin and (self[pin.pinTemplate] or Generic) or Generic;
end

function Adapters:ShowTooltip(pin, anchor)
	local adapter = self:Get(pin)
	GameTooltip:SetOwner(anchor or pin, 'ANCHOR_RIGHT')
	if adapter.Tooltip(pin, GameTooltip) then
		GameTooltip:Show()
		return true;
	end
	GameTooltip:Hide()
	return false;
end

function Adapters:HideTooltip(pin)
	if GameTooltip:IsOwned(pin) then
		GameTooltip:Hide()
	end
end
