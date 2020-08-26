local strsplit, select, _, db = strsplit, select, ...
-----------------------------------------------------------
-- DB Usage:
--  @set      db('[pathto/]var', value)
--  @get      db('[pathto/]var')
-- Registry:
--  @save     db:Save('[pathto/]var', 'asGlobalName', raw)
--  @load     db:Load('[pathto/]var', 'globalName', raw)
--  @default  db:Default(tbl)
--  @register db:Register('name', obj)
-----------------------------------------------------------
db.default = db -- fallback

local function __cd(dir, idx, nxt, ...)
	if not nxt then
		return dir, tonumber(idx) or idx
	end
	local dir = dir[tonumber(idx) or idx]
	if (dir == nil) then return end
	return __cd(dir, nxt, ...)
end

function db:Set(path, value)
	local repo, var = __cd(self, strsplit('/', path))
	if repo and var then
		repo[var] = value
		ConsolePort:FireVarCallback(path, value)
		return true 
	end
end

function db:Get(path)
	local repo, var = __cd(self, strsplit('/', path))
	if repo and var then
		local value = repo[var]
		if (value == nil) then
			local varDefault = self.default[var]
			return varDefault
		end
		return value
	end
end

function db:Save(path, ref, raw)
	_G[ref] = raw and rawget(self, path) or self:Get(path)
end

function db:Load(path, src, raw)
	if raw then
		return rawset(self, path, _G[src])
	end
	return self:Set(path, _G[src])
end

function db:Register(name, obj, raw)
	if not raw then
		assert(not rawget(self, name), 'Object already exists.')
	end
	return rawset(self, name, obj)
end

function db:Default(tbl)
	rawset(self, 'default', tbl) -- add vars
	return tbl
end

function db:Call(path, ...)
	local repo, func = __cd(self, _G[_], path)
	if repo and func then
		return func(repo, ...)
	end
end

setmetatable(db, {
	__call = function(self, ...)
		local func = select('#', ...) > 1 and self.Set or self.Get
		return func(self, ...)
	end;
	__newindex = function()
		error('Access denied. Use ConsolePort:DB(...) to set/get data.')
	end;
})

---------------------------------------------------------------
-- Plug-in access to addon data
---------------------------------------------------------------
function ConsolePort:DB(...)
	if select('#', ...) > 0 then
		return db(...)
	end
	return db
end