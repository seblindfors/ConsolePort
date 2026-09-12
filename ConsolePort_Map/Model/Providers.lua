local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Provider trust tiers
---------------------------------------------------------------
-- See docs/tasks/world-map-pin-strategy.md. Tier A mixins are attached
-- as-is (allowlist, kept in sync with Tools/audit-map-providers.py).
-- Tier B mixins are replaced by the C-API subclasses built below.
-- Every entry is guarded by existence so Classic attaches fewer.
local Providers = {}; env.Providers = Providers;

Providers.World = {
	'MapExplorationDataProviderMixin';
	'FogOfWarDataProviderMixin';
	'QuestBlobDataProviderMixin';
	'ScenarioDataProviderMixin';
	'ZoneLabelDataProviderMixin';
	'VignetteDataProviderMixin';
	'QuestDataProviderMixin';
	'FlightPointDataProviderMixin';
	'DungeonEntranceDataProviderMixin';
	'DelveEntranceDataProviderMixin';
	'MapLinkDataProviderMixin';
	'AreaPOIDataProviderMixin';
	'WaypointLocationDataProviderMixin';
	'SuperTrackWaypointDataProviderMixin';
	'GroupMembersDataProviderMixin';
	'AreaPOIEventDataProviderMixin';
	'ContentTrackingDataProviderMixin';
	'DragonridingRaceDataProviderMixin';
	'InvasionDataProviderMixin';
	'EncounterJournalDataProviderMixin';
	'PetTamerDataProviderMixin';
	'GossipDataProviderMixin';
	'VehicleDataProviderMixin';
	'SelectableGraveyardDataProviderMixin';
	'QuestSessionDataProviderMixin';
	'DigSiteDataProviderMixin';
	'BannerDataProvider';
	'ContributionCollectorDataProviderMixin';
	'DeathMapDataProviderMixin';
	'NeighborhoodMapDataProviderMixin';
	'BattlefieldFlagDataProviderMixin';
	'WorldQuestDataProviderMixin';
	'BonusObjectiveDataProviderMixin';
	'StorylineQuestDataProviderMixin';
};

Providers.Flight = {
	'FlightMap_FlightPathDataProviderMixin';
	'FlightMap_AreaPOIProviderMixin';
	'FlightMap_VignetteDataProviderMixin';
	'ZoneLabelDataProviderMixin';
	'DelveEntranceDataProviderMixin';
	'QuestSessionDataProviderMixin';
	{ 'GroupMembersDataProviderMixin', function(provider)
		provider:SetUnitPinSize('player', 0)
		provider:SetUnitPinSize('party', 13)
		provider:SetUnitPinSize('raid', 13)
	end };
};

Providers.FrameLevels = {
	'PIN_FRAME_LEVEL_MAP_EXPLORATION';
	'PIN_FRAME_LEVEL_EVENT_OVERLAY';
	'PIN_FRAME_LEVEL_GARRISON_PLOT';
	'PIN_FRAME_LEVEL_FOG_OF_WAR';
	'PIN_FRAME_LEVEL_QUEST_BLOB';
	'PIN_FRAME_LEVEL_SCENARIO_BLOB';
	'PIN_FRAME_LEVEL_MAP_HIGHLIGHT';
	'PIN_FRAME_LEVEL_DIG_SITE';
	'PIN_FRAME_LEVEL_DUNGEON_ENTRANCE';
	'PIN_FRAME_LEVEL_DELVE_ENTRANCE';
	'PIN_FRAME_LEVEL_FLIGHT_POINT';
	'PIN_FRAME_LEVEL_INVASION';
	'PIN_FRAME_LEVEL_PET_TAMER';
	'PIN_FRAME_LEVEL_SELECTABLE_GRAVEYARD';
	'PIN_FRAME_LEVEL_AREA_POI';
	'PIN_FRAME_LEVEL_GOSSIP';
	'PIN_FRAME_LEVEL_MAP_LINK';
	'PIN_FRAME_LEVEL_ENCOUNTER';
	'PIN_FRAME_LEVEL_CONTRIBUTION_COLLECTOR';
	{ 'PIN_FRAME_LEVEL_VIGNETTE', 200 };
	'PIN_FRAME_LEVEL_SCENARIO';
	'PIN_FRAME_LEVEL_STORY_LINE';
	{ 'PIN_FRAME_LEVEL_BONUS_OBJECTIVE', 500 };
	{ 'PIN_FRAME_LEVEL_WORLD_QUEST', 500 };
	'PIN_FRAME_LEVEL_ACTIVE_QUEST';
	'PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST';
	'PIN_FRAME_LEVEL_WAYPOINT_LOCATION';
	'PIN_FRAME_LEVEL_SUPER_TRACKED_WAYPOINT';
	'PIN_FRAME_LEVEL_CONTENT_TRACKING';
	'PIN_FRAME_LEVEL_TOPMOST';
	'PIN_FRAME_LEVEL_GROUP_MEMBER';
	'PIN_FRAME_LEVEL_GROUP_MEMBER_ABOVE_FLIGHT';
	'PIN_FRAME_LEVEL_AREA_LABEL';
	'PIN_FRAME_LEVEL_ZONE_LABEL';
	'PIN_FRAME_LEVEL_CORPSE';
	'PIN_FRAME_LEVEL_QUEST_OFFER';
	'PIN_FRAME_LEVEL_QUEST_SESSION';
	'PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER';
	'PIN_FRAME_LEVEL_BATTLEFIELD_FLAG';
	'PIN_FRAME_LEVEL_DRAGONRIDING_RACE';
	'PIN_FRAME_LEVEL_NEIGHBORHOOD_MAP_OBJECTS';
	'PIN_FRAME_LEVEL_DEBUG';
};

---------------------------------------------------------------
-- Tier B: own refresh paths on the C API
---------------------------------------------------------------
-- Retail only: Classic's provider revision has none of the shared
-- caches, so Blizzard's mixins are attached directly there.
local GetFocusedQuestID = QuestMapFrame_GetFocusedQuestID or function() end;

local function GetTasksOnMap(mapID)
	local tasks = C_TaskQuest and C_TaskQuest.GetQuestsOnMap(mapID) or {};
	local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID)
	if questsOnMap then
		for _, info in ipairs(questsOnMap) do
			if info.isMapIndicatorQuest and (info.type ~= Enum.QuestTagType.Islands or (ShouldShowIslandsWeeklyPOI and ShouldShowIslandsWeeklyPOI())) then
				info.inProgress = true;
				info.numObjectives = C_QuestLog.GetNumQuestObjectives(info.questID)
				info.mapID = mapID;
				info.isQuestStart = false;
				info.isDaily = false;
				info.isCombatAllyQuest = false;
				info.isMeta = false;
				table.insert(tasks, info)
			end
		end
	end
	return tasks;
end

local function GetQuestStyle(questID)
	if C_QuestLog.IsComplete(questID) then
		return POIButtonUtil.Style.QuestComplete;
	elseif C_QuestLog.IsQuestDisabledForSession(questID) then
		return POIButtonUtil.Style.QuestDisabled;
	end
	return POIButtonUtil.Style.QuestInProgress;
end

env.GetQuestStyle = GetQuestStyle;

local ownMixins;
function Providers:GetOwnMixins()
	if ownMixins then return ownMixins end
	ownMixins = {};
	if not CPAPI.IsRetailVersion then return ownMixins end

	if QuestDataProviderMixin then
		local Quest = CreateFromMixins(QuestDataProviderMixin)
		function Quest:RefreshAllData(fromOnShow)
			self:RemoveAllData()
			local mapID = self:GetMap():GetMapID()
			if not mapID or not GetCVarBool('questPOI') then return end

			local pinsToQuantize = {};
			local mapInfo = C_Map.GetMapInfo(mapID)
			local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID)
			local doesMapShowTaskObjectives = C_TaskQuest.DoesMapShowTaskQuestObjectives(mapID)

			local function CheckAddQuest(questID, x, y, isMapIndicatorQuest, frameLevelOffset, isWaypoint)
				if self:ShouldShowQuest(questID, mapInfo.mapType, doesMapShowTaskObjectives, isMapIndicatorQuest) then
					local pin = self:AddQuest(questID, x, y, frameLevelOffset, isWaypoint)
					table.insert(pinsToQuantize, pin)
				end
			end

			if questsOnMap then
				for i, info in ipairs(questsOnMap) do
					CheckAddQuest(info.questID, info.x, info.y, info.isMapIndicatorQuest, i)
				end
			end

			local waypointQuestID = GetFocusedQuestID() or C_SuperTrack.GetSuperTrackedQuestID()
			if waypointQuestID then
				local x, y = C_QuestLog.GetNextWaypointForMap(waypointQuestID, mapID)
				if x and y then
					CheckAddQuest(waypointQuestID, x, y, false, questsOnMap and (#questsOnMap + 1) or 0, true)
				end
			end

			self.poiQuantizer:ClearAndQuantize(pinsToQuantize)
			for _, pin in pairs(pinsToQuantize) do
				pin:SetPosition(pin.quantizedX or pin.normalizedX, pin.quantizedY or pin.normalizedY)
			end
			self:UpdatePing()
		end

		function Quest:AddQuest(questID, x, y, frameLevelOffset, isWaypoint)
			local pin = self:GetMap():AcquirePin(self:GetPinTemplate())
			pin:SetQuestID(questID)
			pin.dataProvider = self;

			local isSuperTracked = questID == C_SuperTrack.GetSuperTrackedQuestID()
			pin.isSuperTracked = isSuperTracked;
			if isSuperTracked then
				pin:UseFrameLevelType('PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST')
			else
				pin:UseFrameLevelType('PIN_FRAME_LEVEL_ACTIVE_QUEST', frameLevelOffset)
			end

			pin.Display:ClearAllPoints()
			pin.Display:SetPoint('CENTER')
			pin:SetSelected(isSuperTracked)
			pin:SetStyle(isWaypoint and POIButtonUtil.Style.Waypoint or GetQuestStyle(questID))
			pin:UpdateButtonStyle()
			pin:EvaluateManagedHighlight()

			MapPinHighlight_CheckHighlightPin(pin:GetHighlightType(), pin, pin.NormalTexture)

			pin:SetPosition(x, y)
			return pin;
		end
		ownMixins.QuestDataProviderMixin = Quest;
	end

	if AreaPOIDataProviderMixin then
		local AreaPOI = CreateFromMixins(AreaPOIDataProviderMixin)
		function AreaPOI:RefreshAllData(fromOnShow)
			self:RemoveAllData()
			local mapID = self:GetMap():GetMapID()
			if not mapID then return end
			for _, areaPoiID in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(mapID)) do
				local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
				if poiInfo then
					poiInfo.dataProvider = self;
					self:GetMap():AcquirePin(self:GetPinTemplate(), poiInfo)
				end
			end
		end
		ownMixins.AreaPOIDataProviderMixin = AreaPOI;
	end

	if WorldQuestDataProviderMixin then
		-- WorldMap's subclass adds the mapID == info.mapID filter and the
		-- POI quantizer; without them a world map shows every task on the
		-- planet as an unmerged pin.
		local WorldQuest = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin or WorldQuestDataProviderMixin)
		function WorldQuest:RefreshAllData(fromOnShow)
			local pinsToRemove = {};
			for questID in pairs(self.activePins) do
				pinsToRemove[questID] = true;
			end

			local mapCanvas = self:GetMap()
			local mapID = mapCanvas:GetMapID()
			local taskInfo;
			if mapID then
				taskInfo = GetTasksOnMap(mapID)
				self.matchWorldMapFilters = MapUtil.MapShouldShowWorldQuestFilters(mapID)
			end

			if taskInfo and GetCVarBool('questPOIWQ') then
				for _, info in ipairs(taskInfo) do
					if self:ShouldMapShowQuest(mapID, info) or self:ShouldShowQuest(info) and HaveQuestData(info.questID) then
						if QuestUtils_IsQuestWorldQuest(info.questID) or info.isMapIndicatorQuest then
							if self:DoesWorldQuestInfoPassFilters(info) then
								pinsToRemove[info.questID] = nil;
								local pin = self.activePins[info.questID];
								if pin then
									pin:RefreshVisuals()
									pin.numObjectives = info.numObjectives;
									pin:SetPosition(info.x, info.y)
									pin:AddIconWidgets()
								else
									self.activePins[info.questID] = self:AddWorldQuest(info)
								end
							end
						end
					end
				end
			end

			for questID in pairs(pinsToRemove) do
				mapCanvas:RemovePin(self.activePins[questID])
				self.activePins[questID] = nil;
			end

			self:UpdatePing()
			mapCanvas:TriggerEvent('WorldQuestsUpdate', mapCanvas:GetNumActivePinsByTemplate(self:GetPinTemplate()))

			if self.poiQuantizer then
				self.poiQuantizer:ClearAndQuantize(self.activePins)
				for _, pin in pairs(self.activePins) do
					pin:SetPosition(pin.quantizedX or pin.normalizedX, pin.quantizedY or pin.normalizedY)
				end
			end
		end
		ownMixins.WorldQuestDataProviderMixin = WorldQuest;
	end

	if BonusObjectiveDataProviderMixin then
		local Bonus = CreateFromMixins(BonusObjectiveDataProviderMixin)
		function Bonus:OnAdded(mapCanvas)
			BonusObjectiveDataProviderMixin.OnAdded(self, mapCanvas)
			self:RegisterEvent('QUEST_DATA_LOAD_RESULT')
		end
		function Bonus:RefreshAllData(fromOnShow)
			self:RemoveAllData()
			local mapID = self:GetMap():GetMapID()
			if not mapID or self.hidePins then return end
			for _, info in ipairs(GetTasksOnMap(mapID)) do
				if HaveQuestData(info.questID) then
					if MapUtil.ShouldShowTask(mapID, info) then
						local pinTemplate = self:GetPinTemplateFromTask(info)
						if pinTemplate then
							info.dataProvider = self;
							self:GetMap():AcquirePin(pinTemplate, info)
						end
					end
				else
					C_QuestLog.RequestLoadQuestByID(info.questID)
				end
			end
		end
		ownMixins.BonusObjectiveDataProviderMixin = Bonus;
	end

	return ownMixins;
end
