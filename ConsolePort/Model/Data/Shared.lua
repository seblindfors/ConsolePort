local _, db = ...;
local Shared = db:Register('Shared', CPAPI.CreateEventHandler({'Frame', '$parentSharedDataHandler', ConsolePort}, {
	'PLAYER_LOGOUT';
	'PLAYER_ENTERING_WORLD';
}, {
	Data = {};
}))
db:Save('Shared/Data', 'ConsolePortShared')
---------------------------------------------------------------
-- Shared metatable
---------------------------------------------------------------
local sharedMeta = {
	__index = function(self, key)
		if Shared[key] then
			local k, v = Shared[key]()
			rawset(self, k, setmetatable(rawget(self, k) or v, getmetatable(self)))
			return rawget(self, k);
		end
		rawset(self, key, setmetatable({}, getmetatable(self)))
		return rawget(self, key);
	end;
};

---------------------------------------------------------------
-- Entry generation
---------------------------------------------------------------
Shared['<player>'] = function()
	local name = GetUnitName('player')
	local specID, specName, _, icon = CPAPI.GetCharacterMetadata()
	return -- guid, preset
	('%s (%s) %s'):format(name, specName, GetRealmName()), {
		Meta = {
			Type  = db.Gamepad:GetActiveDeviceName();
			Class = select(2, UnitClass('player'));
			Spec  = specID;
			Icon  = icon;
			Name  = name;
		};
	}
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function Shared:SavePlayerData(set, newData, unique)
	if unique then
		local cmp = db.table.compare;
		for character, data in pairs(self.Data) do
			if data[set] and cmp(data[set], newData) then
				return false;
			end
		end
	end
	self.Data['<player>'][set] = db.table.copy(newData);
	return true;
end

function Shared:SaveData(idx, set, newData, unique)
	if unique then
		local cmp = db.table.compare;
		for owner, data in pairs(self.Data) do
			if data[set] and cmp(data[set], newData) then
				return false;
			end
		end
	end
	self.Data[idx][set] = db.table.copy(newData);
end

function Shared:RemoveData(idx, set)
	self.Data[idx][set] = nil;
end

function Shared:SaveBindings(bindings)
	if not self.metaDataAvailable then return end;
	self:SavePlayerData('Bindings', bindings, true)
end

---------------------------------------------------------------
-- Collect garbage
---------------------------------------------------------------
function Shared:PLAYER_LOGOUT()
	self:CollectGarbageRecursive(self.Data)
	self:CollectCharacterGarbage()
end

function Shared:CollectCharacterGarbage()
	local charactersToCollect = {};
	for character, data in pairs(self.Data) do
		local meta = data.Meta;
		data.Meta = nil;
		if not next(data) then
			charactersToCollect[character] = true;
		else
			data.Meta = meta;
		end
	end
	for character in pairs(charactersToCollect) do
		self.Data[character] = nil;
	end
end

function Shared:CollectGarbageRecursive(tbl)
	for k, v in pairs(tbl) do
		if (type(v) == 'table') then
			self:CollectGarbageRecursive(v)
			if (next(v) == nil) then
				tbl[k] = nil;
			end
		end
	end
end

function Shared:PLAYER_ENTERING_WORLD()
	self.metaDataAvailable = true;
end

function Shared:OnDataLoaded()
	db:Load('Shared/Data', 'ConsolePortShared')
	db:RegisterCallback('OnNewBindings', self.SaveBindings, self)
	setmetatable(self.Data, sharedMeta)
end