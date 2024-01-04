-- Loosely based on https://norvig.com/spell-correct.html

local Scheduler, threads, _, env = CreateFrame('Frame'), {}, ...;

---------------------------------------------------------------
-- Scheduler
---------------------------------------------------------------
Scheduler:SetScript('OnUpdate', function(self, elapsed)
	local continue;
	for thread in pairs(threads) do
		continue = true;
		if coroutine.status(thread) ~= 'dead' then
			coroutine.resume(thread)
		else
			threads[thread] = nil;
		end
	end
	if not continue then self:Hide() end;
end)

local function yield()
	threads[coroutine.running()] = true;
	Scheduler:Show()
	coroutine.yield()
end

local function yieldif(count)
	if count % env.DictYieldRate == 0 then
		yield()
	end
end

local function queue(f, ...)
	coroutine.resume(coroutine.create(f), ...)
end

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function Union(t1, t2, callback)
	local opCount = 0;
	for k, v in pairs(t2) do
		t1[k] = v;
		opCount = opCount + 1;
		yieldif(opCount)
	end
	return callback(t1)
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
		return a[1] > b[1];
	end)

	local i, k = 1;
	return function()
		i, k = i + 1, tuples[i];
		if k then
			return k[2], k[1];
		end
	end
end

---------------------------------------------------------------
-- String generation
---------------------------------------------------------------
local function delete    (t,    s1, s2) t[ s1 .. s2:sub(2) ] = true; yield(); end;
local function transpose (t,    s1, s2) t[ s1 .. s2:sub(2, 2) .. s2:sub(1, 1) .. s2:sub(3) ] = true; yield(); end;
local function replace   (t, l, s1, s2) for c in l:gmatch('.') do t[ s1 .. c .. s2:sub(2) ] = true; end yield(); end;
local function insert    (t, l, s1, s2) for c in l:gmatch('.') do t[ s1 .. c .. s2 ] = true; end yield(); end;


local function Edits(word, result, callback)
	local letters = env.DictMatchAlphabet;
	for i = 0, #word do
		local s1, s2 = word:sub(0, i), word:sub(i + 1);
		if #s2 > 0 then
			delete(result, s1, s2)
			replace(result, letters, s1, s2)
		end
		if #s2 > 1 then
			transpose(result, s1, s2)
		end
		insert(result, letters, s1, s2)
	end
	return callback(result);
end

local function MatchPartial(prefix, dict, callback)
	local result, count = {}, 0;
	for word, weight in pairs(dict) do
		if word ~= prefix and word:match(prefix) then
			result[word] = weight ^ 2;
		end
		count = count + 1;
		yieldif(count)
	end
	return callback(result);
end

local function PruneDict(result, dict, edits, callback)
	local count, weight = 0;
	for word in pairs(edits) do
		weight = dict[word];
		if weight then
			result[word] = (result[word] or 0) + weight;
		end
		count = count + 1;
		yieldif(count)
	end
	return callback(result)
end

---------------------------------------------------------------
-- Async data collection
---------------------------------------------------------------
local function GetUnion(result1, result2, callback)
	queue(Union, result1, result2, callback)
end

local function GetPartials(prefix, dict, callback)
	queue(MatchPartial, prefix, dict, callback)
end

local function GetResult(result, dict, edits, callback)
	queue(PruneDict, result, dict, edits, callback)
end

local function GetEdits(word, callback)
	queue(Edits, word, {}, function(result1)
		local edits2, editThreads = {}, 0;
		for suggestion in pairs(result1) do
			editThreads = editThreads + 1;
			queue(Edits, suggestion, edits2, function(result2)
				editThreads = editThreads - 1;
				if (editThreads == 0) then
					return GetUnion(result1, result2, callback)
				end
			end)
		end
	end)
end

---------------------------------------------------------------
-- Get word suggestions
---------------------------------------------------------------
function env:GetSpellCorrectSuggestions(word, dict, callback)
	word = word:lower();
	wipe(threads)
	GetEdits(word, function(edits)
		GetPartials(word, dict, function(result)
			GetResult(result, dict, edits, function(result)
				collectgarbage()
				return callback(result, IterateSuggestions)
			end)
		end)
	end)
end