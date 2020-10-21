local DataAPI, _, db = CPAPI.CreateEventHandler({'Frame', '$parentDataHandler', ConsolePort}), ...
local copy = db.table.copy;
local DEFAULT_DATA

function DataAPI:OnDataLoaded()
	DEFAULT_DATA = db('Variables')
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
				return self:IsType(typeCheck)
			end
		end
		return nop;
	end;
	__call = function(self)
		return setmetatable(CopyTable(self), getmetatable(self));
	end;
});

do  local ID, DATA, TYPE, CALL, PATH = 0x0, 0x1, 0x2, 0x3, 0x4;

	function Field:Get()     return copy(rawget(self, DATA)) end
	function Field:GetID()   return rawget(self, ID) end
	function Field:GetPath() return rawget(self, PATH) end
	function Field:GetType() return rawget(self, TYPE) end

	function Field:IsType(cmp)
		return (rawget(self, TYPE):lower() == cmp:lower());
	end

	function Field:IsValue(cmp)
		return (self:Get() == cmp)
	end

	function Field:Save()
		db(self:GetPath(), self:Get())
	end

	function Field:Set(val)
		rawset(self, DATA, val)
		local callback = rawget(self, CALL)
		return self, callback and callback(val);
	end

	function Field:SetCallback(callback)
		rawset(self, CALL, callback)
		return self;
	end

	function Field:SetID(id)
		rawset(self, ID, id)
		return self;
	end

	function Field:SetPath(path)
		rawset(self, PATH, path)
		return self;
	end

	function Field:SetType(type)
		rawset(self, TYPE, type)
		return self;
	end

	Field:SetType('Field')
end

---------------------------------------------------------------
local Cvar = Field():SetType('Cvar');
---------------------------------------------------------------
do  local Set, Get, GetBool = SetCVar, GetCVar, GetCVarBool;

	function Cvar:Get(bool)
		return (bool and GetBool or Get)(self:GetID())
	end

	function Cvar:Set(val)
		Set(self:GetID(), val)
		return Field.Set(self, val)
	end
end

---------------------------------------------------------------
local Select = Field():SetType('Select');
---------------------------------------------------------------
function Select:GetOptions()
	return self.options;
end

function Select:IsOption(option)
	return (self.options[option] ~= nil);
end

function Select:Set(val)
	return self:IsOption(val) and Field.Set(self, val) or self;
end

function Select:SetOptions(...)
	local options = {};
	for i=1, select('#', ...) do
		options[select(i, ...)] = true;
	end
	return self:SetRawOptions(options)
end

function Select:SetRawOptions(options)
	self.options = options;
	return self;
end

---------------------------------------------------------------
local Range = Field():SetType('Range');
---------------------------------------------------------------
function Range:GetMinMax()
	return self.min, self.max;
end

function Range:GetStep()
	return self.step;
end

function Range:Set(val)
	return Field.Set(self, Clamp(val, self.min, self.max))
end

function Range:SetMinMax(min, max)
	self.min, self.max = min, max;
	return self;
end

function Range:SetStep(step)
	self.step = step;
	return self;
end

---------------------------------------------------------------
-- Data interface
---------------------------------------------------------------
local Data = db:Register('Data', {});

function Data.Cvar(id)
	return Cvar():SetID(id)
end

function Data.Number(val)
	return Field():SetType('Number'):Set(val)
end

function Data.Range(val, min, max, step)
	return Range():SetMinMax(min, max):Set(val):SetStep(step)
end

function Data.Select(val, ...)
	return Select():SetOptions(...):Set(val)
end

function Data.String(val)
	return Field():SetType('String'):Set(val)
end

function Data.Table(val)
	return Field():SetType('Table'):Set(val)
end


do  _ = newproxy() -- Select variants with pre-defined options

	local Bool = {[true] =_, [false] =_};
	function Data.Bool(val)
		return Select():SetRawOptions(Bool):SetType('Bool'):Set(val)
	end

	local Delta = {[-1] =_, [1] =_};
	function Data.Delta(val)
		return Select():SetRawOptions(Delta):SetType('Delta'):Set(val)
	end

	local IO = {[0] =_, [1] =_};
	function Data.IO(val)
		return Select():SetRawOptions(IO):SetType('IO'):Set(val)
	end
end