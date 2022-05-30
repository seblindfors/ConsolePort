----------------------------------------------------------------
-- RelaTable (╯°□°）╯︵ ┻━┻
----------------------------------------------------------------
-- 
-- Author:  Sebastian Lindfors (Munk / MunkDev)
-- Website: https://github.com/seblindfors/RelaTable
-- Licence: GPL version 2 (General Public License)

local Lib = LibStub:NewLibrary('RelaTable', 1)
if not Lib then return end

local compare, copy, map, merge, spairs, unravel;
local assert, strsplit, select, type = assert, strsplit, select, type;
local next, ipairs, pairs, sort = next, ipairs, pairs, sort;
local getmetatable, setmetatable, rawget, rawset = getmetatable, setmetatable, rawget, rawset;

----------------------------------------------------------------
-- Database handler
----------------------------------------------------------------
local Database = {};

local __mt = {
    __call = function(self, ...)
        local func = select('#', ...) > 1 and self.Set or self.Get;
        return func(self, ...)
    end;
}

local function __cd(dir, idx, nxt, ...)
    if not nxt then
        return dir, tonumber(idx) or idx;
    end
    dir = dir[tonumber(idx) or idx];
    if (dir == nil) then return end
    return __cd(dir, nxt, ...)
end

function Database:Set(path, value)
    local repo, var = __cd(self, strsplit('/', path))
    if repo and var then
        repo[var] = value;
        self:TriggerEvent(path, value)
        return true;
    end
end

function Database:Get(path)
    local repo, var = __cd(self, strsplit('/', path))
    if repo and var then
        local value = repo[var];
        if (value == nil) then
            return self:GetDefault(var)
        end
        return value;
    end
end

function Database:GetDefault(var)
    return self.default[var];
end

function Database:Save(path, ref, raw)
    _G[ref] = raw and rawget(self, path) or self:Get(path)
end

function Database:Load(path, src, raw)
    if raw then
        return rawset(self, path, _G[src])
    end
    return self:Set(path, _G[src])
end

function Database:Register(name, obj, raw)
    if not raw then
        assert(not rawget(self, name), 'Object already exists.')
    end
    rawset(self, name, obj)
    return obj;
end

function Database:Default(tbl)
    rawset(self, 'default', tbl)
    return tbl;
end

function Database:Call(path, ...)
    local repo, func = __cd(self, _G[_], path)
    if repo and func then
        return func(repo, ...)
    end
end

function Database:Copy(path)
    return copy(self:Get(path))
end

function Database:For(path, alphabetical)
    local repo = self:Get(path)
    assert(type(repo) == 'table', 'Path to database entry is invalid: ' .. tostring(path))
    if #repo > 0 then
        return ipairs(repo)
    elseif alphabetical then
        return spairs(repo)
    end
    return pairs(repo)
end

-- Callback handling proxy
function Database:RegisterSafeCallback(...)
    return self.callbacks:RegisterSafeCallback(...)
end

function Database:RegisterCallback(...)
    return self.callbacks:RegisterCallback(...)
end

function Database:RegisterCallbacks(...)
    local callback, owner = ...;
    for i = 3, select('#', ...) do
        self.callbacks:RegisterCallback(select(i, ...), callback, owner)
    end
end

function Database:TriggerEvent(...)
    return self.callbacks:TriggerEvent(...)
end

function Database:RunSafe(...)
    return self.callbacks.safeCallback(...)
end

----------------------------------------------------------------
-- Callback handler
----------------------------------------------------------------
local Callbacks = CreateFromMixins(CallbackRegistryMixin)

function Callbacks:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:SetUndefinedEventsAllowed(true)
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
    self:SetScript('OnEvent', self.OnSafeMode)
    -- Create closure environment for safe callbacks
    self.runSafeClosure  = function(f, args) f(unpack(args)) end;
    self.runSafeClosures = {};
    self.safeCallback    = function(func, ...)
        if InCombatLockdown() then
            return self:QueueSafeClosure(func, ...)
        end
        return func(...)
    end;
end

function Callbacks:OnSafeMode()
    foreach(self.runSafeClosures, self.runSafeClosure)
    wipe(self.runSafeClosures)
end

function Callbacks:QueueSafeClosure(func, ...)
    self.runSafeClosures[func] = {...};
end

function Callbacks:RegisterSafeCallback(event, ...)
    return self:RegisterCallback(event, self.safeCallback, ...)
end

----------------------------------------------------------------
-- Table utilities
----------------------------------------------------------------
function compare(t1, t2)
    if t1 == t2 then
        return true;
    elseif (t1 and not t2) or (t2 and not t1) then
        return false;
    end
    if type(t1) ~= "table" then
        return false;
    end
    local mt1, mt2 = getmetatable(t1), getmetatable(t2)
    if not compare(mt1,mt2) then
        return false;
    end
    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if not compare(v1,v2) then
            return false;
        end
    end
    for k2, v2 in pairs(t2) do
        local v1 = t1[k2]
        if not compare(v1,v2) then
            return false;
        end
    end
    return true;
end

function copy(src)
    local srcType, t = type(src)
    if srcType == "table" then
        t = {};
        for key, value in next, src, nil do
            t[copy(key)] = copy(value)
        end
        setmetatable(t, copy(getmetatable(src)))
    else
        t = src;
    end
    return t;
end

function map(f, v, ...)
    if (v ~= nil) then
        return f(v), map(...)
    end
end

function mapt(f, t)
    for k, v in pairs(t) do
        t[k] = f(v)
    end
end

function merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            merge(t1[k], t2[k])
        else
            t1[k] = v;
        end
    end
    return t1;
end

function spairs(t, order)
    local keys = {unravel(t)}
    if order then
        sort(keys, function(a,b) return order(t, a, b) end)
    else
        sort(keys)
    end
    local i, k = 0;
    return function()
        i = i + 1;
        k = keys[i];
        if k then
            return k, t[k];
        end
    end
end

function unravel(t, i)
    local k = next(t, i)
    if k ~= nil then
        return k, unravel(t, k)
    end
end

local TableUtils = setmetatable({
    compare = compare;
    copy    = copy;
    map     = map;
    mapt    = mapt;
    merge   = merge;
    spairs  = spairs;
    unravel = unravel;
}, { __index = table })


----------------------------------------------------------------
-- Lib
----------------------------------------------------------------
setmetatable(Lib, {
    __newindex = nop;
    __call = function(self, id, db)
        if id then
            local dbHandle = rawget(self, id)
            if dbHandle then
                return dbHandle;
            end
            rawset(self, id, db)
        end

        local callbackHandle = Mixin(CreateFrame('Frame'), Callbacks)
        callbackHandle:OnLoad()

        Mixin(db, Database)
        db.table = copy(TableUtils);
        db.default = db;
        db.callbacks = callbackHandle;

        if (EventRegistry and EventRegistry.TriggerEvent) then
            hooksecurefunc(EventRegistry, 'TriggerEvent', function(_, ...)
                db:TriggerEvent(...)
            end)
        end

        return setmetatable(db, __mt)
    end;
})