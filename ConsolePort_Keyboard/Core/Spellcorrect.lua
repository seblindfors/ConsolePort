local Scheduler, threads, _, env = CreateFrame('Frame'), {}, ...;
local THREAD_LOOP_COUNT_MAX = 4000;

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
	if count % THREAD_LOOP_COUNT_MAX == 0 then
		yield()
	end
end

local function queue(f, ...)
	coroutine.resume(coroutine.create(f), ...)
end

---------------------------------------------------------------
-- String generation
---------------------------------------------------------------
local function delete    (t,    s1, s2) t[ s1 .. s2:sub(2) ] = true; end;
local function transpose (t,    s1, s2) t[ s1 .. s2:sub(2, 2) .. s2:sub(1, 1) .. s2:sub(3) ] = true; end;
local function replace   (t, l, s1, s2) for c in l:gmatch('.') do t[ s1 .. c .. s2:sub(2) ] = true; end end;
local function insert    (t, l, s1, s2) for c in l:gmatch('.') do t[ s1 .. c .. s2 ] = true; end end;


local function Edits1(word, result, callback)
	local letters = env.DictMatchAlphabet;
	local splits = {{'', word}};
	for i=1, #word do splits[i+1] = {word:sub(0, i), word:sub(i + 1)} end;

	for i, split in ipairs(splits) do local s1, s2 = split[1], split[2];
		if #s2 > 0 then
			delete(result, s1, s2)
			replace(result, letters, s1, s2)
		end
		if #s2 > 1 then
			transpose(result, s1, s2)
		end
		insert(result, letters, s1, s2)
		yield()
	end
	return callback(result);
end

local function GetEdits(word, callback)
	queue(Edits1, word, {}, function(result1)
		local edits2, editThreads = {}, 0;
		for suggestion in pairs(result1) do
			editThreads = editThreads + 1;
			queue(Edits1, suggestion, edits2, function(result2)
				editThreads = editThreads - 1;
				if (editThreads == 0) then
					return callback(Union(result1, result2))
				end
			end)
		end
	end)
end

local function MatchPartial(prefix, dict, callback)
	local result, count = {}, 0;
	for word, weight in pairs(dict) do
		if word ~= prefix and word:match(prefix) then
			result[word] = weight;
		end
		count = count + 1;
		yieldif(count)
	end
	return callback(result);
end

local function GetPartials(prefix, dict, callback)
	queue(MatchPartial, prefix, dict, callback)
end

local function PruneDict(res, dict, candidate, ...)
	if not candidate then return res; end
	local v;
	for word in pairs(candidate) do
		weight = dict[word];
		if weight then
			res[word] = (res[word] or 0) + weight;
		end
	end
	return PruneDict(res, dict, ...)
end

---------------------------------------------------------------
-- Get word suggestions
---------------------------------------------------------------
function env:GetAutoCorrectSuggestions(word, dict, callback)
	GetEdits(word, function(edits)
		GetPartials(word, dict, function(result)
			PruneDict(result, dict, edits)
			return callback(result, IterateSuggestions)
		end)
	end)
end