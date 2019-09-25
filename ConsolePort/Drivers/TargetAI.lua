local _, db = ...
---------------------------------------
local AI, SEL, HANDLE, CORE = ConsolePortTargetAI, ConsolePortTargetAISelector, ConsolePortMouseHandle, ConsolePort
---------------------------------------
local inRange, mapData, nameOnlyMode = AI.InRange, AI.MapData
---------------------------------------
local spairs, copy, strsplit = db.table.spairs, db.table.copy, strsplit
local getmetatable, setmetatable, rawset, next, select = getmetatable, setmetatable, rawset, next, select
---------------------------------------
-- Upvalued API:
local GetGUID, GetName, IsDead, Exists = UnitGUID, UnitName, UnitIsDead, UnitExists
local IsPlayer, IsEnemy, IsAttackable = UnitIsPlayer, UnitIsEnemy, UnitCanAttack
local IsControlled, IsBattlePet = UnitPlayerControlled, CPAPI.UnitIsBattlePet
local CanLoot = CanLootUnit

---------------------------------------
local BLACKLIST = {
	['89713'] = true; 	-- Koak Hoburn, heirloom mount driver
	['89715'] = true;	-- Franklin Martin, heirloom mount driver 
}
---------------------------------------
-- Extended API:
local function CanInteract(guid)
	-- guid hack: looting in range, returns true even with no loot.
	return select(2, CanLoot(guid))
end

local function GetUnitProperties(unit)
	local guid = GetGUID(unit)
	if not guid then return end
	local unitType, _, _, _, _, ID = strsplit('-',guid)
	return unitType, ID
end

local function IsNPC(unit)
	local unitType, ID = GetUnitProperties(unit)
	return 	not IsBattlePet(nil, unit) and	-- unit should not be battlepet
			not IsPlayer(unit) and			-- unit should not be player
			not IsControlled(unit) and 		-- unit should not be bodyguard
			not IsEnemy('player', unit) and -- unit should not be enemy
			not IsAttackable('player', unit) and 
			(unitType == 'Creature') and	-- GUID should start with Creature
			(not BLACKLIST[ID])				-- check with blacklist
end

local function IsInteractive(unit)
	return not IsDead(unit) and CanInteract(GetGUID(unit))
end

---------------------------------------
local MAX_ZONES = 3
local MAX_NAMEPLATES = 30
local MAX_MARKER_GUIDS = 10

---------------------------------------
-- Metatables
---------------------------------------
setmetatable(AI, {
	__index = getmetatable(AI).__index;
	__newindex = function(t, k, v)
		if t:HasScript(k) then
			if t:GetScript(k) then
				t:HookScript(k, v)
			else
				t:SetScript(k, v)
			end
		else
			rawset(t, k, v)
		end
	end;
})
setmetatable(SEL, {
	__index = getmetatable(SEL).__index;
	__newindex = getmetatable(AI).__newindex;
})
---------------------------------------
-- inRange: Stack of NPCs in range
---------------------------------------
do 	local inRangeMT = {
		__index = {
			HasMultiple = function(t) return t.__mt.__active > 1 end;
			HasTarget = function(t) return t.__mt.__active > 0 end;
			Add = function(t, k, v)
				if k and v and not t[k] then
					rawset(t, k, v)
					t:Update(1)
					AI:UpdateSelection()
				end
			end;
			Remove = function(t, k)
				if k and t[k] then
					rawset(t, k, nil)
					t:Update(-1)
					AI:UpdateSelection()
				end
			end;
			Prune = function(t)
				local mt = t.__mt
				local guid, name = next(t, mt.__cleaner)
				mt.__cleaner = guid
				if guid and not CanInteract(guid) then
					t:Remove(guid)
				end
			end;
			Update = function(t, delta)
				local mt = t.__mt
				mt.__active = delta and mt.__active + delta or 0
				mt.__idx = nil
				mt.__cleaner = nil
			end;
			Wipe = function(t)
				if next(t) then
					t:Update()
					wipe(t)
					AI:UpdateSelection()
				end
			end;
		};
		__newindex = function() end; -- no uncontrolled access.
		__active = 0;
	}
	inRangeMT.__index.__mt = inRangeMT
	setmetatable(inRange, inRangeMT)
end
------------------------------------------------------------------------------
-- markerMT: Associative array with sequential FIFO stack in metatable.
-- Over a play session, the user is likely to interact with a lot of creatures,
-- especially while questing. To cope with the growing data set, each marker
-- is given this self-managing metatable, which automatically prunes entries
-- on a FIFO basis. This keeps the dataset in a manageable size over time.
------------------------------------------------------------------------------
local markerMT = {
	__index = {};
	__limit = MAX_MARKER_GUIDS;
	__newindex = function(t, k, v)
		--------------------------------
		rawset(t, k, v)
		--------------------------------
		local mt = getmetatable(t)
		mt.__idx = nil -- reset iterator
		--------------------------------
		-- Pruning on FIFO basis
		--------------------------------
		local fifo = mt.__index
		local limit = mt.__limit
		--------------
		tinsert(fifo, 1, k)
		fifo[limit+1] = nil
		--------------
		local num = 0
		for _,_ in pairs(t) do num=num+1 end
		if num > limit then
			for i=#fifo, 1, -1 do
				if t[fifo[i]] then
					rawset(t, fifo[i], nil)
					num = num - 1
				end
				if num == limit then
					break
				end
			end
		end
	end;
}
---------------------------------------
do	local mapDataMT = copy(markerMT)
	mapDataMT.__limit = MAX_ZONES
	setmetatable(mapData, mapDataMT)
end

local function f10(val)
	return math.floor((val or 0) * 10) / 10
end

-- metatable iterators
local function __iterate(t)
	local mt = getmetatable(t)
	local idx, val = next(t, mt.__idx)
	mt.__idx = idx
	return idx, val
end

local function __loop(t)
	local mt = getmetatable(t)
	local idx, val = next(t, mt.__idx)
	if not idx and not val then
		idx, val = next(t, nil)
	end
	mt.__idx = idx
	return idx, val
end

---------------------------------------

function AI:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function AI:OnHide()
	inRange:Wipe()
	wipe(mapData)
	SEL:Hide()
	self:UnregisterAllEvents()
end

function AI:OnShow()
	nameOnlyMode = db('nameplateNameOnly')
	self:SetToCurrentMapMarker()
	self:ForceUpdatePlates()
	for event in pairs(self) do
		pcall(self.RegisterEvent, self, event)
	end
	if not nameOnlyMode then
		pcall(self.UnregisterEvent, self, 'UNIT_THREAT_LIST_UPDATE')
	end
end

---------------------------------------
local throttle, interval = 0, .5
function AI:OnUpdate(elapsed)
	throttle = throttle + elapsed
	if throttle > interval then
		local grid, dirty, plate = self:GetNPCs()
		if (grid or dirty or plate) then
			self:IterateTracker(dirty, true)
			self:IterateTracker(plate, false)
			self:IterateTracker(grid, false)
			interval = .05
		else
			interval = .5
		end
		inRange:Prune()
		throttle = 0
	end
	if self.plateUpdate then
		local unit = ('nameplate' .. self.plateIdx)
		if Exists(unit) then
			self:NAME_PLATE_UNIT_ADDED(unit)
		end
		self.plateIdx = self.plateIdx + 1
		if self.plateIdx > MAX_NAMEPLATES then
			self.plateUpdate = nil
		end
	end
end

function AI:IterateTracker(tracker, convertToGrid)
	if tracker then
		local guid, name = __iterate(tracker)
		if guid then
			if CanInteract(guid) then
				if convertToGrid then
					self:ConvertToNPC(guid, name, self:GetPositionMarker())
				else
					inRange:Add(guid, name)
				end
			end
		end
	end
end

function AI:UpdateSelection()
	SEL:SetShown(inRange:HasMultiple())
	self:SetFocus(__loop(inRange))
end

function AI:SetFocus(guid, name)
	self:SetAttribute('macrotext', (name and '/targetexact ' .. name) or ('') )
	HANDLE:SetArtificialUnit(guid, name)
end

---------------------------------------
local zone

function AI:GetMapMarker()
	return C_Map.GetBestMapForUnit('player') or 0
end

function AI:SetToCurrentMapMarker()
	local zoneID = self:GetMapMarker()
	self.MapData[zoneID] = self.MapData[zoneID] or {}
	local isNewZone, oldID = self:SetZoneID(zoneID)
	if isNewZone then
		self:ClearDirtyTrackers(oldID)
		self:ForceUpdatePlates()
	end
	return self.MapData[zoneID]
end

function AI:SetZoneID(newID)
	local isNewZone, oldID = (zone ~= newID), zone
	zone = newID -- don't modify this anywhere else!
	return isNewZone, oldID, newID
end

function AI:GetCurrentMapData()
	return zone and self.MapData[zone]
end

function AI:GetMapDataForID(zoneID)
	return self.MapData[zoneID]
end

function AI:GetGridPosition()
	local position = C_Map.GetPlayerMapPosition(zone or 0, 'player')
	local posX, posY = (position and position:GetXY())
	posX = f10(posX)
	posY = f10(posY)
	return posX, posY
end

function AI:GetPositionMarker()
	local x, y = self:GetGridPosition()
	return (x ..':'.. y)
end

function AI:CreateTrackerFromMarker(marker, maxGUIDs)
	local mapData = self:GetCurrentMapData()
	if not mapData then
		mapData = self:SetToCurrentMapMarker()
	end
	if not mapData[marker] then
		local mt = copy(markerMT)
		mt.__limit = maxGUIDs or MAX_MARKER_GUIDS
		mapData[marker] = setmetatable({}, mt)
	end
	return mapData[marker]
end

function AI:ClearDirtyTrackers(mapID)
	local mapData = self:GetMapDataForID(mapID)
	if mapData then
		mapData.dirty = nil
		mapData.plate = nil
	end
end

function AI:ClearNPCDirty(guid, marker)
	local mapData = self:GetCurrentMapData()
	local tracker = mapData and mapData[marker]
	if tracker then
		tracker[guid] = nil
		if not next(tracker) then
			mapData[marker] = nil
		end
	end
end

function AI:ConvertToNPC(guid, name, marker)
	self:ClearNPCDirty(guid, 'dirty')
	self:CreateTrackerFromMarker(marker)[guid] = name
end

function AI:GetNPCs()
	local mapData = self:GetCurrentMapData()
	if mapData then
		return mapData[self:GetPositionMarker()], mapData.dirty, mapData.plate
	end
end

function AI:Track(unit, marker, maxGetGUIDs, forceMarker)
	local guid, name, interactive = GetGUID(unit), GetName(unit), IsInteractive(unit)
	if interactive and not forceMarker then
		marker = self:GetPositionMarker()
		self:ClearNPCDirty(guid, 'dirty')
	end
	if guid and name and marker then
		self:CreateTrackerFromMarker(marker, maxGetGUIDs)[guid] = name
	end
end

function AI:ForceUpdatePlates()
	self.plateUpdate = true
	self.plateIdx = 1
end

--------------------------------------------------------
-- Calls to AI:Track should only occur below this line.
--------------------------------------------------------

function AI:WORLD_MAP_UPDATE() 
	self:SetToCurrentMapMarker()
end

function AI:GOSSIP_SHOW() 
	if Exists('npc') and IsNPC('npc') then
		self:Track('npc')
	end
end

function AI:MERCHANT_SHOW()
	if Exists('npc') and IsNPC('npc') then
		self:Track('npc')
	end
end

function AI:QUEST_DETAIL()
	if IsNPC('questnpc') then
		self:Track('questnpc')
	elseif IsNPC('npc') then
		self:Track('npc')
	end
end

function AI:QUEST_GREETING()
	if IsNPC('questnpc') then
		self:Track('questnpc')
	elseif IsNPC('npc') then
		self:Track('npc')
	end
end

function AI:PLAYER_TARGET_CHANGED()
	if Exists('target') then
		SEL:Hide()
		CORE:SetNameOnlyForUnit('target')
	else
		self:UpdateSelection(inRange)
	end
end

function AI:UPDATE_MOUSEOVER_UNIT()
	if Exists('mouseover') then
		SEL:Hide()
		if IsNPC('mouseover') then
			self:Track('mouseover', 'dirty')
		end
	else
		self:UpdateSelection(inRange)
	end
end

function AI:NAME_PLATE_UNIT_ADDED(unit)
	if IsNPC(unit) then
		self:Track(unit, 'plate', MAX_NAMEPLATES, true)
	end
	CORE:SetNameOnlyForUnit(unit)
end

function AI:NAME_PLATE_UNIT_REMOVED(unit)
	self:ClearNPCDirty(GetGUID(unit), 'plate')
end

function AI:UNIT_THREAT_LIST_UPDATE(unit)
	if unit and unit:match('nameplate') then
		CORE:SetNameOnlyForUnit(unit)
	end
end
---------------------------------------
local InCombatLockdown, IsShiftKeyDown, IsControlKeyDown = InCombatLockdown, IsShiftKeyDown, IsControlKeyDown

function SEL:Next()
	AI:SetFocus(__loop(inRange))
end

function SEL:OnShow()
	local interactWith = db('interactWith')
	if (interactWith == 'CP_L_UP' or interactWith == 'CP_L_DOWN') then
		self.CP_L_UP = nil 			; self.CP_L_DOWN = nil
		self.CP_L_LEFT = self.Next 	; self.CP_L_RIGHT = self.Next
	else
		self.CP_L_UP = self.Next 	; self.CP_L_DOWN = self.Next
		self.CP_L_LEFT = nil 		; self.CP_L_RIGHT = nil
	end
end

function SEL:OnKeyDown(key)
	if 	( InCombatLockdown() ) or 
		( IsShiftKeyDown() or IsControlKeyDown() ) or 
		( Exists('npc') or Exists('questnpc') ) then
		self:SetPropagateKeyboardInput(true)
		return
	end

	local action = GetBindingAction(key)
	local override = GetBindingAction(key, true)
	local isSafe = (ConsolePort:GetCurrentBindingOwner(override) == action) or (override:match('ControllerInput'))
	local func = self[action]
	if func and isSafe then
		func(self)
		self:SetPropagateKeyboardInput(false)
	else
		self:SetPropagateKeyboardInput(true)
	end
end

---------------------------------------
-- Experimental nameplate option
local throttleplate, nameplateExperimental, nameplateExperimentalT
AI:HookScript('OnShow', function(self)
	if nameplateExperimental then
		self:UnregisterEvent('NAME_PLATE_UNIT_REMOVED')
	else
		self:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
	end
end)

local after, reset = C_Timer.After, function()
	SetCVar('nameplateShowFriends', false)
	SetCVar('nameplateShowFriendlyNPCs', false)
end

ConsolePort:RegisterVarCallback('nameplateExperimental', function(v)
	nameplateExperimental = v
	if nameplateExperimental then
		throttleplate, nameplateExperimentalT =  0, db('nameplateExperimentalT')
		AI:UnregisterEvent('NAME_PLATE_UNIT_REMOVED')
		if not AI.hooked then
			AI.hooked = true
			AI:HookScript('OnUpdate', function(self, elapsed)
				--------------------------------------------------
				if nameplateExperimental then
					throttleplate = throttleplate + elapsed
					if throttleplate > nameplateExperimentalT then
						SetCVar('nameplateShowFriends', true)
						SetCVar('nameplateShowFriendlyNPCs', true)
						throttleplate = 0
						after(0, reset)
					end
				--------------------------------------------------
				end
			end)
		end
	else
		AI:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
		if AI.hooked then
			AI.hooked = false
			AI:SetScript('OnUpdate', AI.OnUpdate)
		end
	end
end)
ConsolePort:RegisterVarCallback('nameplateExperimentalT', function(v) nameplateExperimentalT = v end)