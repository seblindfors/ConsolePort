local _, db = ...; local Mapper = db:Register('Mapper', {});
---------------------------------------------------------------
-- Helpers & shared metatable
---------------------------------------------------------------
Mapper.ConfigGroups = tInvert {
	'configID';
	'rawAxisMappings';
	'rawButtonMappings';
	'axisConfigs';
	'stickConfigs';
};

local function FillGroups(config)
	for group in pairs(Mapper.ConfigGroups) do
		if not config[group] then
			config[group] = {};
		end
	end
	return config;
end

local function MatchTable(source, criteria)
	if type(source) ~= 'table' then return end;
	for k, v in pairs(criteria) do
		if rawget(source, k) ~= v then return end;
	end
	return true;
end

local function GetIndex(self, key)
	local newTable = {};
	if key:match('%b<>') then
		for k, v in key:gmatch('<([%w%p]-):([%w%p]-)>') do
			newTable[k] = tonumber(v) or v;
		end
		for k, v in pairs(self) do
			if MatchTable(v, newTable) then
				return setmetatable(v, getmetatable(self));
			end
		end
		key = #self + 1;
	end
	rawset(self, key, setmetatable(newTable, getmetatable(self)));
	return rawget(self, key);
end

local configMeta = {__index = GetIndex};

local function ApplyMetatable(var)
	if type(var) == 'table' then
		setmetatable(var, configMeta)
		for key, val in pairs(var) do
			ApplyMetatable(key)
			ApplyMetatable(val)
		end
	end
	return var;
end

local function ClearMetatable(var)
	if type(var) == 'table' then
		setmetatable(var, nil)
		for key, val in pairs(var) do
			ClearMetatable(key)
			ClearMetatable(val)
		end
	end
	return var;
end

local function Scrub(var)
	if type(var) == 'table' then
		local key, val = next(var)
		while key do
			local newValue = Scrub(val);
			var[key] = newValue;
			if newValue == nil then
				key = nil;
			end
			key, val = next(var, key);
		end
		if ( next(var) == nil ) then
			return nil;
		end
	end
	return var;
end

---------------------------------------------------------------
-- Mapper handler
---------------------------------------------------------------
function Mapper:OnDeviceChanged(device, deviceID)
	local configID = {
		vendorID  = device.vendorID;
		productID = device.productID;
	};
	local config = C_GamePad.GetConfig(configID) or {
		name = device.name;
		configID = configID;
	};

	self.config = ApplyMetatable(FillGroups(config));
	db:TriggerEvent('OnMapperConfigLoaded', self.config)
end

function Mapper:OnValueChanged(path, value)
	local config = self:GetConfig()
	if config then
		C_GamePad.SetConfig(config)
		C_GamePad.ApplyConfigs()
		return value;
	end
end

function Mapper:GetValue(path, default)
	if self.config then
		local value = Scrub(db('Mapper/config/'..path))
		if ( value ~= nil ) then
			return value;
		end
	end
	return default;
end

function Mapper:SetValue(path, value)
	if self.config then
		if db('Mapper/config/'..path, value) then
			return self:OnValueChanged(path, value)
		end
	end
end

function Mapper:GetConfig()
	local rawConfig = self.config;
	if rawConfig then
		return FillGroups(Scrub(ClearMetatable(CopyTable(rawConfig))));
	end
end

db:RegisterCallback('OnMapperValueChanged', Mapper.OnValueChanged, Mapper)
db:RegisterCallback('OnMapperDeviceChanged', Mapper.OnDeviceChanged, Mapper)