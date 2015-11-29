---------------------------------------------------------------
-- Table.lua: Extra table functions for various uses
---------------------------------------------------------------
-- These table functions are used to perform special operations
-- that are not natively supported.  

local _, db = ...
---------------------------------------------------------------
-- Table: Recursive table duplicator, creates a deep copy
---------------------------------------------------------------
local function Copy(src)
	local srcType = type(src)
	local copy
	if srcType == "table" then
		copy = {}
		for key, value in next, src, nil do
			copy[Copy(key)] = Copy(value)
		end
		setmetatable(copy, Copy(getmetatable(src)))
	else
		copy = src
	end
	return copy
end

db.Copy = Copy

---------------------------------------------------------------
-- Table: Recursive table comparator, checks if identical
---------------------------------------------------------------
local function Compare(t1, t2)
	if t1 == t2 then
		return true
	end
	if type(t1) ~= "table" then
		return false
	end
	local mt1, mt2 = getmetatable(t1), getmetatable(t2)
	if not Compare(mt1,mt2) then
		return false
	end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1]
		if not Compare(v1,v2) then
			return false
		end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2]
		if not Compare(v1,v2) then
			return false
		end
	end
	return true
end

db.Compare = Compare

---------------------------------------------------------------
-- Table: Sort by non-numeric key, handy for string indices.
---------------------------------------------------------------
local function PairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do tinsert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local function iter()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

db.pairsByKeys = PairsByKeys