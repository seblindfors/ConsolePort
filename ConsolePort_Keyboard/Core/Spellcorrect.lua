local _, env = ...;

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function Union(t1, t2, ...)
	if not t2 then return t1; end
	for k, v in pairs(t2) do
		t1[k] = v; 
	end
	return Union(t1, ...)
end

local function Copy(t1)
	local t2 = {};
	for k, v in pairs(t1) do t2[k] = v; end
	return t2;
end

local function IterateSuggestions(dict)
	local tuples = {};
	for word, weight in pairs(dict) do
		tuples[#tuples + 1] = {weight, word}
	end
	table.sort(tuples, function(a, b)
		return a[1] > b[1]
	end)

	local i, k = 1;
	return function()
		i, k = i + 1, tuples[i];
		if k then
			return k[2], k[1]
		end
	end
end

---------------------------------------------------------------
-- String generation
---------------------------------------------------------------
local function delete    (t,    s1, s2) t[ s1 .. s2:sub(2) ] = true; end;
local function transpose (t,    s1, s2) t[ s1 .. s2:sub(2, 2) .. s2:sub(1, 1) .. s2:sub(3) ] = true; end;
local function replace   (t, l, s1, s2) for c in l:gmatch('.') do t[ s1 .. c .. s2:sub(2) ] = true; end end;
local function insert    (t, l, s1, s2) for c in l:gmatch('.') do t[ s1 .. c .. s2 ] = true; end end;


local function Edits1(word)
	local letters = env.DictMatchAlphabet;
	local splits = {{'', word}};
	for i=1, #word do splits[#splits + 1] = {word:sub(0, i), word:sub(i + 1)} end;

	local result = {};
	for i, split in ipairs(splits) do local s1, s2 = split[1], split[2];
		if #s2 > 0 then
			delete(result, s1, s2)
			replace(result, letters, s1, s2)
		end
		if #s2 > 1 then
			transpose(result, s1, s2)
		end
		insert(result, letters, s1, s2)
	end
	return result;
end

local function Edits2(word)
	local edits1, edits2 = Edits1(word), {};
	for suggestion in pairs(edits1) do
		Union(edits2, Edits1(suggestion))
	end
	return edits1, edits2;
end

local function PruneDict(res, dict, candidate, ...)
	if not candidate then return res; end
	local v;
	for k in pairs(candidate) do
		v = dict[k];
		if v then
			res[k] = v;
		end
	end
	return PruneDict(res, dict, ...)
end

local function MatchPartial(prefix, dictionary)
	local result = {};
	for word, weight in pairs(dictionary) do
		if word:match(prefix) then
			result[word] = weight;
		end
	end
	return result;
end

function env:GetSuggestions(word, dictionary)
	return PruneDict(MatchPartial(word, dictionary), dictionary, Edits2(word));
end

function test(word)
	return env:GetSuggestions(word, ConsolePort_KeyboardDictionary)
end

function printtest(word)
	for k, v in IterateSuggestions(test(word)) do
		print(k, v)
	end
end