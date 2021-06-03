---------------------------------------------------------------
-- Table.lua: Extra table functions for various uses
---------------------------------------------------------------
-- These table functions are used to perform special operations
-- that are not natively supported.  
---------------------------------------------------------------
local _, db = ...
---------------------------------------------------------------
db:Register('table', {})

-- recursive
local function copy(src)
	local srcType, t = type(src)
	if srcType == "table" then
		t = {}
		for key, value in next, src, nil do
			t[copy(key)] = copy(value)
		end
		setmetatable(t, copy(getmetatable(src)))
	else
		t = src
	end
	return t
end
db('table/copy', copy)

local function compare(t1, t2)
	if t1 == t2 then
		return true
	elseif (t1 and not t2) or (t2 and not t1) then
		return false
	end
	if type(t1) ~= "table" then
		return false
	end
	local mt1, mt2 = getmetatable(t1), getmetatable(t2)
	if not compare(mt1,mt2) then
		return false
	end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1]
		if not compare(v1,v2) then
			return false
		end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2]
		if not compare(v1,v2) then
			return false
		end
	end
	return true
end
db('table/compare', compare)

local function merge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			merge(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end
db('table/merge', merge)

local function unravel(t, i)
	local k = next(t, i)
	if k ~= nil then
		return k, unravel(t, k)
	end
end
db('table/unravel', unravel)

-- helpers
local function spairs(t, order)
	local keys = {unravel(t)}
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
	local i, k = 0
	return function()
		i = i + 1
		k = keys[i]
		if k then
			return k, t[k]
		end
	end
end
db('table/spairs', spairs)

local function map(f, v, ...)
	if (v ~= nil) then
		return f(v), map(...)
	end
end
db('table/map', map)

-- This is a special iterator that returns a table in reverse order,
-- or by "intuitive" modifier order. E.g. Shift comes before Ctrl.
local mIndex = setmetatable({
	['']                = 1;
	['SHIFT-']          = 2;
	['CTRL-']           = 3;
	['ALT-']            = 4;
	['CTRL-SHIFT-']     = 5;
	['ALT-SHIFT-']      = 6;
	['ALT-CTRL-']       = 7;
	['ALT-CTRL-SHIFT-'] = 8;
}, {__index = function() return 9 end})

db('table/mpairs', function(t)
	return spairs(t, function(t, a, b)
		return mIndex[a] < mIndex[b];
	end)
end)

db('table/ripairs', ripairs or function(t)
	local function ripairsiter(t, index)
		index = index - 1;
		if index > 0 then
			return index, t[index];
		end
	end
	return ripairsiter, t, #t + 1;
end)

db('table/mixin', function(obj, ...)
	local scriptHandler = (type(obj.HasScript) == 'function')
	for i = 1, select('#', ...) do
		local mixin = select(i, ...)

		for k, v in pairs(mixin) do
			if scriptHandler and obj:HasScript(k) then
				if obj:GetScript(k) then
					obj:HookScript(k, v)
				else
					obj:SetScript(k, v)
				end
			end
			obj[k] = v
		end
	end
	return obj
end)