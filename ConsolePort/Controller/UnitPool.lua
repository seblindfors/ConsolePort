---------------------------------------------------------------
-- Unit pool (secure unit state driver)
---------------------------------------------------------------
-- Watches a configurable pool of unit IDs through state drivers
-- and maintains a sorted list of units in the restricted
-- environment, shared by secure consumers.

local _, db = ...;
---------------------------------------------------------------
local UNIT_DRIVER_FORMAT   = '[@%s,exists] 1; %s';
local UNIT_DRIVER_UPDATE   = 'units[%q][%q] = newstate; self:RunAttribute("RefreshUnits")';
local UNIT_DRIVER_CLLBCK   = '_onstate-%s';
local UNIT_POOL_DELIMITER  = '[^;]+';
local UNIT_RANGE_DELIMITER = '-';
local UNIT_TOKEN_GMATCH    = '(%a+)(%d+)%'..UNIT_RANGE_DELIMITER..'?(%d*)(.*)';

local Pool = db:Register('UnitPool', Mixin(
	CPAPI.EventHandler(ConsolePortUnitPool, {'PLAYER_ENTERING_WORLD'}),
	CPAPI.SecureEnvironmentMixin
));
Pool.UnitDrivers, Pool.Sorted, Pool.Consumers = {}, {}, {};

Pool:Run([[
	units, sorted, CONSUMERS = newtable(), newtable(), newtable();
]])

Pool:CreateEnvironment({
	RefreshUnits = [[
		self::SortUnits()
		self::BroadcastUnits()
	]];
	SortUnits = ([[
		local pool, c = self:GetAttribute('unitpool'), 0;
		local hasBeenInserted = {};
		sorted = wipe(sorted)

		if ( not pool or pool:len() == 0 ) then
			for group in pairs(units) do
				for unit in pairs(group) do
					if not hasBeenInserted[unit] then
						hasBeenInserted[unit] = true;
						table.insert(sorted, unit)
					end
				end
			end
			return table.sort(sorted)
		end

		for group in pool:gmatch(%q) do
			local set = {};
			for unit in pairs(units[group]) do
				if not hasBeenInserted[unit] then
					hasBeenInserted[unit] = true;
					table.insert(set, unit)
				end
			end
			table.sort(set)
			for i, unit in ipairs(set) do
				sorted[c + i] = unit;
			end
			c = #sorted;
		end
	]]):format(UNIT_POOL_DELIMITER);
	GetSortedUnits = [[
		local list = '';
		for i, unit in ipairs(sorted) do
			list = list .. unit .. ';';
		end
		return list;
	]];
	BroadcastUnits = [[
		local list = self::GetSortedUnits()
		for name, consumer in pairs(CONSUMERS) do
			consumer::OnUnitPoolChanged(list)
		end
		self:::OnSortedUnitsChanged(list)
	]];
})

---------------------------------------------------------------
-- Consumers
---------------------------------------------------------------
function Pool:RegisterConsumer(consumer, name)
	self.Consumers[name] = true;
	self:SetFrameRef('consumer', consumer)
	self:Run([[
		CONSUMERS[%q] = self:GetFrameRef('consumer')
	]], name)
	self:OnUnitPoolChanged()
end

function Pool:UnregisterConsumer(name)
	self.Consumers[name] = nil;
	self:Run([[ CONSUMERS[%q] = nil ]], name)
	if not next(self.Consumers) then
		self:ClearWatchedUnits()
	end
end

function Pool:OnSortedUnitsChanged(list)
	local sorted = wipe(self.Sorted)
	for unit in list:gmatch(UNIT_POOL_DELIMITER) do
		sorted[#sorted + 1] = unit;
	end
	db:TriggerEvent('OnUnitPoolChanged', sorted)
end

function Pool:GetSortedUnits()
	return self.Sorted;
end

function Pool:GetNumWatchedUnits()
	local count = 0;
	for _ in pairs(self.UnitDrivers) do
		count = count + 1;
	end
	return count;
end

---------------------------------------------------------------
-- Unit drivers
---------------------------------------------------------------
function Pool:OnUnitPoolChanged()
	self:ClearWatchedUnits()
	if not next(self.Consumers) then return end;

	local tokens = db('unitHotkeyTokens')
	local static = db('unitHotkeyStaticMode')
	self.driverFallback = static and '0' or 'nil';
	self:SetAttribute('unitpool', tokens)
	self:SetAttribute('useStatic', static)
	self:Execute('units = wipe(units)')
	for token in tokens:gmatch(UNIT_POOL_DELIMITER) do
		self:ParseToken(token, token)
	end

	self:Run([[ self::RefreshUnits() ]])
end

function Pool:ParseToken(token, group)
	local hasRangeToResolve = token:find(UNIT_RANGE_DELIMITER)
	if hasRangeToResolve then
		for unitID, n, range, rest in token:gmatch(UNIT_TOKEN_GMATCH) do
			hasRangeToResolve, n, range = true, tonumber(n), tonumber(range);
			for i = n, range or n do
				self:ParseToken(unitID..i..rest, group)
			end
		end
	end
	if not hasRangeToResolve then
		self:AddUnitToWatch(token, group)
	end
end

function Pool:ClearWatchedUnits()
	for unitID in pairs(self.UnitDrivers) do
		UnregisterStateDriver(self, unitID)
		self:SetAttribute(UNIT_DRIVER_CLLBCK:format(unitID), nil)
	end
	wipe(self.UnitDrivers)
end

function Pool:AddUnitToWatch(unitID, group) unitID = unitID:trim();
	if self.UnitDrivers[unitID] then
		return false;
	end
	local driver = UNIT_DRIVER_FORMAT:format(unitID, self.driverFallback)
	self.UnitDrivers[unitID] = true;
	self:Run([[
		local unitID, group, driver = %q, %q, %q;
		units[group] = units[group] or {};
		units[group][unitID] = tonumber((SecureCmdOptionParse(driver)));
	]], unitID, group, driver)
	RegisterStateDriver(self, unitID, driver)
	self:SetAttribute(UNIT_DRIVER_CLLBCK:format(unitID), UNIT_DRIVER_UPDATE:format(group, unitID))
	return true;
end

---------------------------------------------------------------
-- Events and callbacks
---------------------------------------------------------------
function Pool:PLAYER_ENTERING_WORLD()
	self:OnUnitPoolChanged()
end

db:RegisterSafeCallbacks(Pool.OnUnitPoolChanged, Pool,
	'Settings/unitHotkeyTokens',
	'Settings/unitHotkeyStaticMode'
);
