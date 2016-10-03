---------------------------------------------------------------
-- Table.lua: Extra table functions for various uses
---------------------------------------------------------------
-- These table functions are used to perform special operations
-- that are not natively supported.  
---------------------------------------------------------------
local _, db = ...
local tbl = {}
---------------------------------------------------------------
db.table = tbl
---------------------------------------------------------------
-- Copy: Recursive table duplicator, creates a deep copy
---------------------------------------------------------------
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
---------------------------------------------------------------
-- Flip: Flips the table associations. (only for unique values)
---------------------------------------------------------------
local function flip(src)
	local srcType, t = type(src)
	if srcType == "table" then
		t = {}
		for key, value in pairs(src) do
			if not t[value] then
				t[value] = key
			else
				return src
			end
		end
	end
	return t or src
end
---------------------------------------------------------------
-- Compare: Recursive table comparator, checks if identical
---------------------------------------------------------------
local function compare(t1, t2)
	if t1 == t2 then
		return true
	elseif t1 and not t2 or t2 and not t1 then
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
---------------------------------------------------------------
-- spairs: Sort by non-numeric key, handy for string keys
---------------------------------------------------------------
local function spairs(t, order)
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end
---------------------------------------------------------------
local function global_mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...)
		for k, v in pairs(mixin) do
			object[k] = v
		end
	end

	return object
end

local function mixin(t, ...)
	t = global_mixin(t, ...)
	if t.HasScript then
		for k, v in pairs(t) do
			if t:HasScript(k) then
				if t:GetScript(k) then
					t:HookScript(k, v)
				else
					t:SetScript(k, v)
				end
			end
		end
	end
end
---------------------------------------------------------------
tbl.copy, tbl.flip, tbl.compare, tbl.spairs, tbl.mixin = copy, flip, compare, spairs, mixin