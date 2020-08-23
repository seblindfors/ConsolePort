local strsplit, select, _, db = strsplit, select, ...
-----------------------------------------------------------
-- DB Usage:
--  @set      db('[pathto/]var', value)
--  @get      db('[pathto/]var')
-- Registry:
--  @save     db:Save('[pathto/]var', 'asGlobalName', raw)
--  @register db:Register('name', obj)
-----------------------------------------------------------
local vars = {} -- TODO: replace

local function __cd(root, default, rawPath)
	local path = {strsplit('/', rawPath)}
	local depth = #path
	if (depth == 1) then
		return default, rawPath
	else
		local dest = root
		for i=1, (depth - 1) do
			dest = dest[tonumber(path[i]) or path[i]]
			if (dest == nil) then
				return
			end
		end
		return dest, tonumber(path[depth]) or path[depth]
	end
end

function db:Set(path, value)
	local repo, var = __cd(self, self.Settings, path)
	if repo and var then
		repo[var] = value
		ConsolePort:FireVarCallback(path, value)
		return true 
	end
end

function db:Get(path)
	local repo, var = __cd(self, self.Settings, path)
	if repo and var then
		local value = repo[var]
		if (value == nil) then
			local varDefault = vars[var]
			return varDefault and varDefault[1]
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