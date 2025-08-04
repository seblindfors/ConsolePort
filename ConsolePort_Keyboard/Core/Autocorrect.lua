local Scheduler, _, env = CreateFrame('Frame', nil, ConsolePortKeyboard), ...;
local MinEditDistance, ClampedPercentageBetween = CPAPI.MinEditDistance, ClampedPercentageBetween;
local tinsert, max, floor = table.insert, math.max, math.floor;
local coroutine, assert, GetTimePreciseSec = coroutine, assert, GetTimePreciseSec;
---------------------------------------------------------------
-- Scoring
---------------------------------------------------------------
local function ScoreStrings(searchText, otherString)
	-- lower is better

	local subStringStartIndex, subStringEndIndex = otherString:find(searchText, 1, true);
	local hasSubString = not not subStringStartIndex;

	local editDistance = MinEditDistance(searchText, otherString);
	if not hasSubString and editDistance == max(#searchText, #otherString) then
		return 100; -- not even close
	end

	local subStringScore = hasSubString and -#searchText * 10 or 0;
	local startOfMatchScore = hasSubString
		and ClampedPercentageBetween(subStringStartIndex, 15, 1) * -2 * #searchText or 0;

	return editDistance + subStringScore + startOfMatchScore;
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
		local text = self.text;
		self:StepAutoCompleteSearchCoroutine(text)
	end)
	self.bestResults = {};
end

function Scheduler:StepAutoCompleteSearchCoroutine(searchText)
	local dict = self.dict;
	local lowerSearchText = searchText:lower();

	local candidates = {};
	for word, weight in pairs(dict) do
		self:CheckYield();
		tinsert(candidates, {
			word  = word;
			score = ScoreStrings(lowerSearchText, word) - weight * 0.1;
		})
	end

	local criteria = #searchText / 2;
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

function Scheduler:Init(word, dict, callback)
	self.text = word;
	self.dict = dict;
	self.callback = callback;
	self:MarkDirty();
	self:Show();
end

---------------------------------------------------------------
-- Scheduler setup
---------------------------------------------------------------
Scheduler.maxResults = 8;
Scheduler:Hide();
Scheduler:SetScript('OnUpdate', Scheduler.OnUpdate);

---------------------------------------------------------------
-- Get word suggestions
---------------------------------------------------------------
function env:GetSpellCorrectSuggestions(word, dict, callback)
	word = word:lower();
	Scheduler:Init(word, dict, callback);
end