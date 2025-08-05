local _, db = ...;
local Shared = db:Register('Shared', CPAPI.CreateEventHandler({'Frame', '$parentSharedDataHandler', ConsolePort}, {
	'PLAYER_LOGOUT';
	'PLAYER_ENTERING_WORLD';
}, {
	Data = {};
}))
db:Save('Shared/Data', 'ConsolePortShared')

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
		for _, data in pairs(self.Data) do
			if data[set] and cmp(data[set], newData) then
				return false;
			end
		end
	end
	self.Data[idx] = self.Data[idx] or {};
	self.Data[idx][set] = db.table.copy(newData);
end

function Shared:GetData(idx, set)
	if not rawget(self.Data, idx) then return end;
	return db.table.copy(self.Data[idx][set]);
end

function Shared:RemoveData(idx, set)
	if not self.Data[idx] then return end;
	self.Data[idx][set] = nil;
	return true;
end

function Shared:SaveBindings(bindings)
	if not self.metaDataAvailable then return end;
	if not db('bindingAutomaticBackup') then return end;
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
	CPAPI.Proxy(self.Data, function(data, key)
		if ( key ~= 0 and self[key] ) then
			local k, v = self[key]()
			rawset(data, k, rawget(self, k) or v)
			return rawget(data, k);
		end
		return rawget(data, key);
	end)
	return CPAPI.BurnAfterReading;
end