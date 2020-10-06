local DataAPI, _, db = CPAPI.CreateEventHandler({'Frame', '$parentDataHandler', ConsolePort}), ...
local copy = db.table.copy;
local DEFAULT_DATA

function DataAPI:OnDataLoaded()
	DEFAULT_DATA = db('Defaults')
	local settings = setmetatable(ConsolePortSettings or {}, {
		__index = function(self, key)
			local var = DEFAULT_DATA[key]
			return var and var[1]:Get()
		end;
		-- TODO: newindex handling
	})
	db:Register('Settings', settings, true)
	db:Default(settings)
	db:Save('Settings', 'ConsolePortSettings')
end

---------------------------------------------------------------
-- Fields
---------------------------------------------------------------
local Field = setmetatable({}, {
	__index = function(self, k)
		local typeCheck = k:gsub('^Is(%w+)$', '%1');
		if typeCheck then
			return function()
				return self:IsType(typeCheck:lower())
			end
		end
		return nop;
	end;
	__call = function(self)
		return setmetatable(CopyTable(self), getmetatable(self));
	end;
});

do  local DATA, TYPE, CALL = 0x1, 0x2, 0x3;
	function Field:Get()
		return copy(rawget(self, DATA));
	end

	function Field:Set(val)
		rawset(self, DATA, val)
		local callback = rawget(self, CALL)
		return self, callback and callback(self, val);
	end

	function Field:SetCallback(callback)
		rawset(self, CALL, callback);
		return self;
	end

	function Field:SetType(type)
		rawset(self, TYPE, type:lower())
		return self;
	end

	function Field:GetType()
		return rawget(self, TYPE);
	end

	function Field:IsType(cmp)
		return (rawget(self, TYPE) == cmp);
	end
end

---------------------------------------------------------------
local Select = Field(); Select:SetType('select');
function Select:Set(val)
	assert(self.options[val] ~= nil,
		('Value %s is not defined as option.'):format(tostring(val)))
	return Field.Set(self, val)
end

function Select:GetOptions()
	return self.options;
end

function Select:SetOptions(options)
	for i, option in ipairs(options) do
		options[option] = true;
		options[i] = nil;
	end
	self.options = options;
	return self;
end

---------------------------------------------------------------
local Range = Field(); Range:SetType('range');
function Range:Set(val)
	return Field.Set(self,
		val < self.min and self.min or val > self.max and self.max or val)
end

function Range:GetMinMax()
	return self.min, self.max;
end

function Range:SetMinMax(min, max)
	self.min, self.max = min, max;
	return self;
end

---------------------------------------------------------------
-- Data interface
---------------------------------------------------------------
local Data = db:Register('Data', {});

function Data.Field(val)
	return Field():Set(val)
end

function Data.Number(val)
	return Field():Set(val):SetType('number')
end

function Data.String(val)
	return Field():Set(val):SetType('string')
end

function Data.Bool(val)
	return Select():SetOptions({true, false}):Set(val):SetType('bool')
end

function Data.Table(val)
	return Field():Set(val):SetType('table')
end

function Data.Delta(val)
	return Select():SetOptions({1, -1}):Set(val):SetType('delta')
end

function Data.Select(val, options)
	return Select():SetOptions(options):Set(val)
end

function Data.Range(val, min, max)
	return Range():SetMinMax(min, max):Set(val)
end