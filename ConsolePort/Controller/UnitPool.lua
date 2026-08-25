---------------------------------------------------------------
-- Unit pool (secure unit state driver)
---------------------------------------------------------------
-- Watches a configurable pool of unit IDs through state drivers
-- and maintains a sorted list of units in the restricted
-- environment, shared by secure consumers. The pool itself is
-- a macro condition selecting a comma-separated list of units,
-- so the watched set follows group state in combat.

local _, db = ...;
---------------------------------------------------------------
local POOL_STATE = 'pool';

local Pool = db:Register('UnitPool', Mixin(
	CPAPI.EventHandler(ConsolePortUnitPool),
	CPAPI.SecureEnvironmentMixin
));
Pool.Sorted, Pool.Consumers = {}, {};

Pool:Run([[
	units, sorted, order, wanted, watched, CONSUMERS =
		newtable(), newtable(), newtable(), newtable(), newtable(), newtable();
]])

Pool:CreateEnvironment({
	SetPool = [[
		local list = ...;
		wanted = wipe(wanted)
		order  = wipe(order)
		if ( list and list ~= 'nil' ) then
			for token in list:gmatch('[^,]+') do
				self::ExpandToken(token:match('^%s*(.-)%s*$'))
			end
		end
		updating = true;
		for unit in pairs(watched) do
			if not wanted[unit] then
				self::UnwatchUnit(unit)
			end
		end
		for i, unit in ipairs(order) do
			if not watched[unit] then
				self::WatchUnit(unit)
			end
		end
		updating = nil;
		self::RefreshUnits()
	]];
	ExpandToken = [[
		local token = ...;
		if ( not token or token == '' ) then return end;
		local unitID, first, last, rest = token:match('^(%a+)(%d+)%-?(%d*)(.*)$')
		if not unitID then
			if not wanted[token] then
				wanted[token] = true;
				order[#order + 1] = token;
			end
			return
		end
		first, last = tonumber(first), tonumber(last) or tonumber(first);
		for i = first, last do
			local unit = unitID..i..rest;
			if unit:find('%d%-%d') then
				self::ExpandToken(unit)
			elseif not wanted[unit] then
				wanted[unit] = true;
				order[#order + 1] = unit;
			end
		end
	]];
	WatchUnit = [[
		local unit = ...;
		local driver = '[@'..unit..',exists] 1; '..(self:GetAttribute('fallback') or 'nil');
		watched[unit] = true;
		units[unit] = tonumber((SecureCmdOptionParse(driver)));
		RegisterStateDriver(self, unit, driver)
	]];
	UnwatchUnit = [[
		local unit = ...;
		watched[unit], units[unit] = nil, nil;
		UnregisterStateDriver(self, unit)
	]];
	RefreshUnits = [[
		self::SortUnits()
		self::BroadcastUnits()
	]];
	SortUnits = [[
		sorted = wipe(sorted)
		for i, unit in ipairs(order) do
			if units[unit] then
				sorted[#sorted + 1] = unit;
			end
		end
	]];
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

Pool:SetAttribute('_onattributechanged', CPAPI.ConvertSecureBody([[
	local unit = name:match('^state%-(.+)$');
	if not unit then return end;
	if ( unit == ']]..POOL_STATE..[[' ) then
		return self::SetPool(value)
	end
	if watched[unit] then
		units[unit] = value;
		if not updating then
			self::RefreshUnits()
		end
	end
]]))

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
		self:OnUnitPoolChanged()
	end
end

function Pool:OnSortedUnitsChanged(list)
	local sorted = wipe(self.Sorted)
	for unit in list:gmatch('[^;]+') do
		sorted[#sorted + 1] = unit;
	end
	db:TriggerEvent('OnUnitPoolChanged', sorted)
end

function Pool:GetSortedUnits()
	return self.Sorted;
end

---------------------------------------------------------------
-- Pool driver
---------------------------------------------------------------
function Pool:GetPoolDriver(tokens)
	if not tokens:find('[', 1, true) then
		-- legacy pools carry no conditions and become one comma list
		return (tokens:gsub(';', ','));
	end
	local clauses, pending = {}, '';
	for condition, list in tokens:gmatch('(%b[])([^%[]*)') do
		list = list:gsub(';', ','):match('^%s*(.-)%s*$');
		if ( list == '' ) then
			pending = pending .. condition;
		else
			clauses[#clauses + 1] = pending .. condition .. ' ' .. list;
			pending = '';
		end
	end
	return table.concat(clauses, '; ');
end

function Pool:OnUnitPoolChanged()
	UnregisterStateDriver(self, POOL_STATE)
	self:SetAttribute('state-'..POOL_STATE, nil)
	if not next(self.Consumers) then return end;
	self:SetAttribute('fallback', db('unitHotkeyStaticMode') and '0' or 'nil')
	RegisterStateDriver(self, POOL_STATE, self:GetPoolDriver(db('unitHotkeyTokens')))
end

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------
db:RegisterSafeCallbacks(Pool.OnUnitPoolChanged, Pool,
	'Settings/unitHotkeyTokens',
	'Settings/unitHotkeyStaticMode'
);
