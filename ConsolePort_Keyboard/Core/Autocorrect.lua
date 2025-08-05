local Scheduler, _, env = CreateFrame('Frame', nil, ConsolePortKeyboard), ...;
local MinEditDistance, ClampedPercentageBetween = CPAPI.MinEditDistance, ClampedPercentageBetween;
local tinsert, max, floor = table.insert, math.max, math.floor;
local coroutine, assert, GetTimePreciseSec = coroutine, assert, GetTimePreciseSec;
---------------------------------------------------------------
-- Scoring
---------------------------------------------------------------
local function ScoreStrings(searchText, otherString, weight, len)
	-- lower is better

	local subStringStartIndex = otherString:find(searchText, 1, true);
	local hasSubString  = not not subStringStartIndex;

	local editDistance = MinEditDistance(searchText, otherString);
	if not hasSubString and editDistance == max(len, #otherString) then
		return 100; -- not even close
	end

	local subStringScore = hasSubString and -len * 10 or 0;
	local startOfMatchScore = hasSubString
		and ClampedPercentageBetween(subStringStartIndex, 15, 1) * -2 * len or 0;

	return editDistance + subStringScore + startOfMatchScore - weight;
end

local function BinaryInsert(t, value)
	local startIndex = 1;
	local endIndex = #t;
	local midIndex = 1;
	local preInsert = true;

	while startIndex <= endIndex do
		midIndex = floor((startIndex + endIndex) / 2);

		if value.score < t[midIndex].score then
			endIndex = midIndex - 1;
			preInsert = true;
		else
			startIndex = midIndex + 1;
			preInsert = false;
		end
	end

	tinsert(t, midIndex + (preInsert and 0 or 1), value);
end

---------------------------------------------------------------
-- Scheduler
---------------------------------------------------------------
local TIME_PER_FRAME_SEC = 0.015;
local WEIGHT_DEF_GRAVITY = 0.005;

function Scheduler:ResumeWork()
	self.workEndTime = GetTimePreciseSec() + TIME_PER_FRAME_SEC;
	coroutine.resume(self.workingCoroutine);
end

function Scheduler:FinishWork()
	self.workEndTime = nil;
	if self.workingCoroutine then
		coroutine.resume(self.workingCoroutine);
		self.workingCoroutine = nil;
		self:DisplayResults()
	end
end

function Scheduler:CheckYield()
	if self.workEndTime and GetTimePreciseSec() > self.workEndTime then
		return coroutine.yield();
	end
end

function Scheduler:CancelSearch()
	assert(self.workingCoroutine ~= nil);
	assert(self.workingCoroutine ~= coroutine.running());
	self.workingCoroutine = nil;
end

function Scheduler:StartSearch()
	assert(self.workingCoroutine == nil);
	self.workingCoroutine = coroutine.create(function()
		local text = self.searchTerm;
		self:StepAutoCompleteSearchCoroutine(text)
	end)
	self.bestResults = {};
end

function Scheduler:StepAutoCompleteSearchCoroutine(searchText)
	local dict = env.Dictionary;

	local lowerSearchText, len = searchText:lower(), #searchText;
	local gravity = len > 0 and WEIGHT_DEF_GRAVITY or 0.1;

	local candidates = {};
	for word, weight in pairs(dict) do
		self:CheckYield();
		tinsert(candidates, {
			word  = word;
			score = ScoreStrings(lowerSearchText, word, weight * gravity, len);
		})
	end

	local criteria = len / 2;
	for _, candidate in ipairs(candidates) do
		self:CheckYield();

		if candidate.score < criteria then
			BinaryInsert(self.bestResults, candidate);
			if #self.bestResults > self.maxResults then
				self.bestResults[#self.bestResults] = nil;
			end
		end
	end
end

function Scheduler:MarkDirty()
	self.dirty = true;
end

function Scheduler:OnUpdate()
	if not self.dirty and not self.workingCoroutine then
		return self:DisplayResults();
	end

	if self.dirty and self.workingCoroutine then
		self:CancelSearch();
	end

	if self.workingCoroutine then
		self:ResumeWork();
		if coroutine.status(self.workingCoroutine) == 'dead' then
			self.workingCoroutine = nil;
		end
	else
		self:StartSearch();
	end
	self.dirty = false;
end

local function IterateResults(results)
	local i = 0;
	return function()
		i = i + 1;
		if results[i] then
			return results[i].word, results[i].score;
		end
	end
end

function Scheduler:DisplayResults()
	self.callback(self.bestResults, IterateResults);
	self:Hide()
end

function Scheduler:Init(word, callback, maxResults)
	self.searchTerm = word;
	self.callback   = callback;
	self.maxResults = maxResults;
	self:MarkDirty();
	self:Show();
end

---------------------------------------------------------------
-- Scheduler setup
---------------------------------------------------------------
Scheduler:Hide();
Scheduler:SetScript('OnUpdate', Scheduler.OnUpdate);

---------------------------------------------------------------
-- Get word suggestions
---------------------------------------------------------------
function env:GetAutoCorrectSuggestions(word, callback, maxResults)
	word = word:lower();
	Scheduler:Init(word, callback, maxResults);
end