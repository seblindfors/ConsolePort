local _, db = ...
---------------------------------------
local AI, SEL, HANDLE = ConsolePortTargetAI, ConsolePortTargetAISelector, ConsolePortMouseHandle
---------------------------------------
local inRange, mapData = AI.InRange, AI.MapData
---------------------------------------
local spairs, copy = db.table.spairs, db.table.copy
local getmetatable, rawset, next = getmetatable, rawset, next
---------------------------------------
-- Extended API:
local function CanInteract(guid)
	-- guid hack: looting in range, returns true even with no loot.
	return select(2, CanLootUnit(guid))
end

local function UnitIsNPC(unit)
	return 	not UnitIsBattlePet(unit) and
			not UnitIsPlayer(unit) and
			UnitIsFriend('player', unit) and 
			((UnitGUID(unit) or ''):sub(1,8) == 'Creature')
end

local function UnitIsInteractive(unit)
	return not UnitIsDead(unit) and CanInteract(UnitGUID(unit))
end
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
setmetatable(inRange, {
	__index = {
		HasMultiple = function(t) return getmetatable(t).__active > 1 end;
		HasTarget = function(t) return getmetatable(t).__active > 0 end;
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
			local mt = getmetatable(t)
			local guid, name = next(t, mt.__pruneIdx)
			mt.__pruneIdx = guid
			if guid and not CanInteract(guid) then
				inRange:Remove(guid)
			end
		end;
		Update = function(t, delta)
			local mt = getmetatable(t)
			mt.__active = delta and mt.__active + delta or 0
			mt.__idx = nil
			mt.__pruneIdx = nil
		end;
		Wipe = function(t)
			if next(t) then
				t:Update()
				wipe(t)
				AI:UpdateSelection()
			end
		end;
	};
	__active = 0;
})
---------------------------------------
local MAX_ZONES = 3
local MAX_NAMEPLATES = 30
local MAX_MARKER_GUIDS = 10
---------------------------------------
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
	self:SetToCurrentMapMarker()
	self:ForceUpdatePlates()
	for index in pairs(self) do
		self:RegisterEvent(index)
	end
end

---------------------------------------
local throttle, interval = 0, .25
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
			interval = .25
		end
		inRange:Prune()
		throttle = 0
	end
	if self.plateUpdate then
		local unit = ('nameplate' .. self.plateIdx)
		if UnitExists(unit) then
			self:NAME_PLATE_UNIT_ADDED(unit)
		end
		self.plateIdx = self.plateIdx + 1
		if self.plateIdx >= MAX_NAMEPLATES then
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
	return table.concat({GetCurrentMapZone()})
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
	local posX, posY = GetPlayerMapPosition('player')
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

function AI:Track(unit, marker, maxGUIDs, forceMarker)
	local guid, name, interactive = UnitGUID(unit), UnitName(unit), UnitIsInteractive(unit)
	if interactive and not forceMarker then
		marker = self:GetPositionMarker()
		self:ClearNPCDirty(guid, 'dirty')
	end
	if guid and name and marker then
		self:CreateTrackerFromMarker(marker, maxGUIDs)[guid] = name
	end
end

function AI:ForceUpdatePlates()
	self.plateUpdate = true
	self.plateIdx = 1
end

---------------------------------------

function AI:GOSSIP_SHOW() 	self:Track('npc') end
function AI:MERCHANT_SHOW() self:Track('npc') end
function AI:QUEST_DETAIL() 	self:Track(UnitExists('questnpc') and 'questnpc' or 'npc') end
function AI:QUEST_GREETING() self:Track(UnitExists('questnpc') and 'questnpc' or 'npc') end
function AI:WORLD_MAP_UPDATE() self:SetToCurrentMapMarker() end
function AI:PLAYER_TARGET_CHANGED()
	if UnitExists('target') then
		SEL:Hide()
	else
		self:UpdateSelection(inRange)
	end
end

function AI:UPDATE_MOUSEOVER_UNIT()
	if UnitExists('mouseover') then
		SEL:Hide()
		if UnitIsNPC('mouseover') then
			self:Track('mouseover', 'dirty')
		end
	else
		self:UpdateSelection(inRange)
	end
end

function AI:NAME_PLATE_UNIT_ADDED(unit)
	if UnitIsNPC(unit) then
		self:Track(unit, 'plate', MAX_NAMEPLATES, true)
	end
end

function AI:NAME_PLATE_UNIT_REMOVED(unit)
	self:ClearNPCDirty(UnitGUID(unit), 'plate')
end

---------------------------------------

function SEL:Next()
	AI:SetFocus(__loop(inRange))
end

function SEL:OnShow()
	local interactWith = db.Settings.interactWith
	if (interactWith == 'CP_L_UP' or interactWith == 'CP_L_DOWN') then
		self.CP_L_UP = nil 			; self.CP_L_DOWN = nil
		self.CP_L_LEFT = self.Next 	; self.CP_L_RIGHT = self.Next
	else
		self.CP_L_UP = self.Next 	; self.CP_L_DOWN = self.Next
		self.CP_L_LEFT = nil 		; self.CP_L_RIGHT = nil
	end
end

function SEL:OnKeyDown(key)
	local action = GetBindingAction(key)
	local override = GetBindingAction(key, true)
	local safe = (ConsolePort:GetCurrentBindingOwner(override) == action) or (override:match('ControllerInput'))
	local func = self[action]
	if func and safe then
		func(self)
		self:SetPropagateKeyboardInput(false)
	else
		self:SetPropagateKeyboardInput(true)
	end
end