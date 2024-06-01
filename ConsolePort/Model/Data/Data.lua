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
local ID, DATA, TYPE, CALL, INIT, DEF = 0x0, 0x1, 0x2, 0x3, 0x4, 0x5;

local Field = setmetatable({[TYPE] = 'Field'}, {
	__index = {};
	__newindex = function(self, key, value)
		if (type(value) == 'function') then
			getmetatable(self).__index[key] = value;
			return
		end
		rawset(self, key, value);
	end;
	__call = function(self, newType)
		if newType then
			return rawset(copy(self), TYPE, newType);
		end
		return setmetatable(copy(self), getmetatable(self));
	end;
});

function Field:Get()        return copy(rawget(self, DATA)) end
function Field:GetID()      return rawget(self, ID) end
function Field:GetType()    return rawget(self, TYPE) end
function Field:GetDefault() return copy(rawget(self, DEF)) end

function Field:IsType(cmp)
	return (self:GetType() == cmp)
end

function Field:IsValue(cmp)
	return (self:Get() == cmp)
end

function Field:Set(val)
	rawset(self, DATA, val)
	if not rawget(self, INIT) then
		rawset(self, INIT, true)
		rawset(self, DEF, copy(val))
	end
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

function Field:SetDefault()
	return self:Set(rawget(self, DEF));
end

---------------------------------------------------------------
local Button = Field('Button');
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
local Color = Field('Color');
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

function Color:GetObject()
	return CreateColor(Field.Get(self):GetRGBA())
end

function Color:ConvertToRGBA(arg1, ...)
	if (type(arg1) == 'string') then
		return CPAPI.CreateColorFromHexString(arg1), true;
	elseif (type(arg1) == 'table' and arg1.OnLoad == ColorMixin.OnLoad) then
		return CreateColor(arg1:GetRGBA()), true;
	end
	local r, g, b, a = arg1, ...;
	return CreateColor(r, g, b, tonumber(a) and a or 1), false;
end

function Color:SetHex(enabled)
	self.hex = enabled;
	return self;
end

function Color:IsHex()
	return self.hex;
end

---------------------------------------------------------------
local Cvar = Field('Cvar');
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
local Number = Field('Number');
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
local Pseudokey = Button('Pseudokey');
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
local Range = Number('Range');
---------------------------------------------------------------
function Range:GetMinMax()
	return self.min, self.max;
end

function Range:Set(val)
	return Field.Set(self, Clamp(tonumber(val), self.min, self.max))
end

function Range:SetMinMax(min, max)
	self.min, self.max = min, max;
	return self;
end

---------------------------------------------------------------
local Select = Field('Select');
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
local Table = Field('Table');
---------------------------------------------------------------

function Table:Get()
	local result = {};
	local data = Field.Get(self);
	for child, field in pairs(data) do
		result[child] = field[DATA]:Get();
	end
	return result;
end

function Table:Set(tbl, silent)
	if not rawget(self, INIT) then
		return Field.Set(self, tbl)
	end
	if tbl then
		local inline = rawget(self, DATA);
		for child, field in pairs(tbl) do
			if inline[child] then
				inline[child][DATA]:Set(field)
			elseif not silent then
				error('Malformed table: field "'..child..'" does not exist in definition.')
			end
		end
	end
	local callback = rawget(self, CALL)
	return self, callback and callback(self:Get());
end

---------------------------------------------------------------
local Interface = Table('Interface');
---------------------------------------------------------------

function Interface:Get()
	return Table.Get(self[DATA][DATA]);
end

function Interface:Set(tbl)
	if not rawget(self, INIT) then
		return Table.Set(self, tbl)
	end
	return Table.Set(self[DATA][DATA], tbl, true)
end

function Interface:Warp(tbl)
	return self:Set(tbl):Get()
end

function Interface:Implement(props)
	local instance = Field.Get(self)
	if props then
		local overrides = props[DATA];
		if overrides then
			Table.Set(instance[DATA], overrides)
			props[DATA] = nil;
		end
		Mixin(instance, props)
	end
	return instance;
end

function Interface:Render(props)
	return db.table.merge(self:Get(), props)
end

---------------------------------------------------------------
local Mutable = Table('Mutable');
---------------------------------------------------------------

function Mutable:SetMutator(type)
	self.mutator = type();
	return Field.Set(self, {})
end

function Mutable:GetMutator()
	return self.mutator;
end

function Mutable:SetKeyOptions(options)
	self.keyOptions = options;
	return self;
end

function Mutable:GetKeyOptions()
	if type(self.keyOptions) == 'function' then
		return self.keyOptions();
	end
	return self.keyOptions;
end

function Mutable:GetAvailableKeys()
	local result = {};
	local options = self:GetKeyOptions();
	local data = rawget(self, DATA);
	for key, info in pairs(options) do
		if ( data[key] == nil ) then
			result[key] = info;
		end
	end
	return result;
end

function Mutable:Set(values)
	if values then
		local keyOptions = self:GetKeyOptions();
		for key, val in pairs(values) do
			if keyOptions and not keyOptions[key] then
				error('Malformed mutable: key "'..key..'" does not exist in definition.')
			end
			self:Add(key, val)
		end
	end
	return self;
end

function Mutable:Remove(key)
	local data = rawget(self, DATA);
	if ( data[key] ~= nil ) then
		data[key] = nil;
		return true;
	end
	return false;
end

function Mutable:Add(key, val)
	local data = rawget(self, DATA);
	local newField = self.mutator();
	newField:Set(val)
	data[key] = newField;
	return true;
end

function Mutable:Get()
	local result = {};
	local data = rawget(self, DATA);
	for key, field in pairs(data) do
		result[key] = field:Get();
	end
	return result;
end

---------------------------------------------------------------
local Point = Table('Point');
---------------------------------------------------------------

---------------------------------------------------------------

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
	return Select():SetRawOptions(opts):Set(val)
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
	return Field('String'):Set(val)
end

function Data.Table(val)
	return Table():Set(val)
end

function Data.Interface(val)
	return Interface():Set(val)
end

function Data.Mutable(type, initialValues)
	return Mutable():SetMutator(type):Set(initialValues)
end

function Data.Point(val)
	return Point():Set(val)
end

function Data.Field(val)
	return Field():Set(val)
end


do  _ = newproxy() -- Select variants with pre-defined options

	local Bool = Select('Bool'):SetRawOptions({[true] =_, [false] =_});
	function Data.Bool(val)
		return Bool():Set(val)
	end

	local Delta = Select('Delta'):SetRawOptions({[-1] =_, [1] =_});
	function Data.Delta(val)
		return Delta():Set(val)
	end

	local IO = Select('IO'):SetRawOptions({[0] =_, [1] =_});
	function Data.IO(val)
		return IO():Set(val)
	end
end