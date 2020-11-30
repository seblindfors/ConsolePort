local _, db = ...;
local Shared = db:Register('Shared', CPAPI.CreateEventHandler({'Frame', '$parentShared', ConsolePort}, {
	'PLAYER_LOGOUT';
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
	local specID, specName, _, icon = CPAPI.GetCharacterMetadata()
	return -- guid, preset
	('%s (%s) %s'):format(GetUnitName('player'), specName, GetRealmName()), {
		Type  = db.Gamepad:GetActiveDeviceName();
		Class = select(2, UnitClass('player'));
		Spec  = specID;
		Icon  = icon;
	}
end

---------------------------------------------------------------
-- Collect garbage
---------------------------------------------------------------
function Shared:PLAYER_LOGOUT()
	self:CollectGarbage(self.Data)
end

function Shared:CollectGarbage(tbl)
	for k, v in pairs(tbl) do
		if (type(v) == 'table') then
			self:CollectGarbage(v)
			if (next(v) == nil) then
				tbl[k] = nil;
			end
		end
	end
end

function Shared:OnDataLoaded()
	db:Load('Shared/Data', 'ConsolePortShared')
	setmetatable(self.Data, sharedMeta)
end