local DataAPI, _, db = CPAPI.CreateEventHandler({'Frame', '$parentDataHandler', ConsolePort}), ...;
local copy = db.table.copy;

function DataAPI:OnDataLoaded()
	self.Defaults = {};
	self:OnVariablesChanged(db.Variables)
	self:UpdateDataSource()
	db:TriggerEvent('OnDataLoaded')
end

function DataAPI:UpdateDataSource()
	local settings, saveAsID;

	if not ConsolePortSettings then
		ConsolePortSettings = {};
	end

	if ConsolePortCharacterSettings then
		saveAsID = 'ConsolePortCharacterSettings';
		settings = CPAPI.Proxy(ConsolePortCharacterSettings,
			CPAPI.Proxy(ConsolePortSettings, self.Defaults)
		);
	else
		saveAsID = 'ConsolePortSettings';
		settings = CPAPI.Proxy(ConsolePortSettings, self.Defaults)
	end

	db:Register('Settings', settings, true)
	db:Default(settings)
	db:Save('Settings', saveAsID)
end

function DataAPI:OnToggleCharacterSettings(enabled)
	local overrides = ConsolePortCharacterSettings;
	ConsolePortCharacterSettings = enabled and {} or nil;
	self:UpdateDataSource()
	-- Since data source was switched, dispatch to update callbacks
	db('Settings/useCharacterSettings', enabled)
	if overrides then
		-- Trigger updates for all the variables that had overrides
		for id in pairs(overrides) do
			db('Settings/'..id, db(id))
		end
	end
end

function DataAPI:OnVariablesChanged(variables)
	for varID, data in pairs(variables) do
		self.Defaults[varID] = data[1]:Get();
	end
end

db:RegisterCallback('OnVariablesChanged', DataAPI.OnVariablesChanged, DataAPI)
db:RegisterCallback('OnToggleCharacterSettings', DataAPI.OnToggleCharacterSettings, DataAPI)

---------------------------------------------------------------
-- Fields
---------------------------------------------------------------
local Field = setmetatable({}, {
	__index = function(self, k)
		local typeCheck = k:gsub('^Is(%w+)$', '%1');
		if typeCheck then
			return GenerateClosure(self.IsType, self, typeCheck)
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
		return self, callback and callback(self:Get());
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
local Button = Field():SetType('Button');
---------------------------------------------------------------
function Button:Set(val, force)
	if force or (val and IsBindingForGamePad(val)) then
		if self:IsModifierAllowed() then
			return Field.Set(self, CPAPI.CreateKeyChord(val))
		end
		return Field.Set(self, val)
	end
	return self;
end

function Button:IsModifierAllowed()
	return self.allowModifiers;
end

function Button:SetAllowModifiers(enabled)
	self.allowModifiers = enabled or false;
	return self;
end

---------------------------------------------------------------
local Color = Field():SetType('Color');
---------------------------------------------------------------
function Color:Set(...)
	local colorObj, converted = self:ConvertToRGBA(...)
	return Field.Set(self, colorObj):SetHex(converted)
end

function Color:Get()
	if self.hex then
		return self:GetHex()
	end
	return Field.Get(self):GetRGBA()
end

function Color:GetHex()
	local r, g, b, a = Field.Get(self):GetRGBAAsBytes()
	return ('%.2x%.2x%.2x%.2x'):format(a, r, g, b)
end

function Color:ConvertToRGBA(arg1, ...)
	if (type(arg1) == 'string') then
		return CPAPI.CreateColorFromHexString(arg1), true;
	end
	return CreateColor(arg1, ...), false;
end

function Color:SetHex(enabled)
	self.hex = enabled;
	return self;
end

function Color:IsHex()
	return self.hex;
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
local Number = Field():SetType('Number');
---------------------------------------------------------------
function Number:Set(val)
	return Field.Set(self, self:GetSigned() and val or abs(val))
end

function Number:SetStep(step)
	self.step = step;
	return self;
end

function Number:SetSigned(signed)
	self.signed = signed;
	return self;
end

function Number:GetStep()
	return self.step;
end

function Number:GetSigned()
	return self.signed;
end

---------------------------------------------------------------
local Pseudokey = Button():SetType('Pseudokey');
---------------------------------------------------------------
function Pseudokey:Set(val, force)
	if (force or val) then
		if self:IsModifierAllowed() then
			return Field.Set(self, CPAPI.CreateKeyChord(val))
		end
		return Field.Set(self, val)
	end
	return self;
end

---------------------------------------------------------------
local Range = Number():SetType('Range');
---------------------------------------------------------------
function Range:GetMinMax()
	return self.min, self.max;
end

function Range:Set(val)
	return Field.Set(self, Clamp(val, self.min, self.max))
end

function Range:SetMinMax(min, max)
	self.min, self.max = min, max;
	return self;
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
-- Data interface (call obj to enter data definition env)
---------------------------------------------------------------
local Data = db:Register('Data', setmetatable({}, {
	__call = function(self) setfenv(2, self) end;
	__index = _G;
}));

function Data.Button(val, allowModifiers)
	return Button():SetAllowModifiers(allowModifiers):Set(val)
end

function Data.Cvar(id)
	return Cvar():SetID(id)
end

function Data.Color(...)
	return Color():Set(...)
end

function Data.Number(val, step, signed)
	return Number():SetStep(step):SetSigned(signed):Set(val)
end

function Data.Map(val, opts)
	return Select(val, val):SetRawOptions(opts):Set(val)
end

function Data.Pseudokey(val, allowModifiers)
	return Pseudokey():SetAllowModifiers(allowModifiers):Set(val)
end

function Data.Range(val, step, min, max)
	return Range():SetStep(step):SetMinMax(min, max):Set(val)
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