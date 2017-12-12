local _, L = ...
local Timer = CreateFrame('Frame')

-- Borrowed fixes from Storyline :)
local LINE_FEED_CODE = string.char(10)
local CARRIAGE_RETURN_CODE = string.char(13)
local WEIRD_LINE_BREAK = LINE_FEED_CODE .. CARRIAGE_RETURN_CODE .. LINE_FEED_CODE

local DELAY_DIVISOR
local DELAY_PADDING = 2
local MAX_UNTIL_SPLIT = 200

Timer.Texts = {}
L.TextMixin = {}

local Text = L.TextMixin

function Text:SetText(text)
	DELAY_DIVISOR = L.Get('delaydivisor')
	self:StopTexts()
	self.storedText = text
	if text then
		local strings, delays = {}, {}
		local timeToFinish = 0
		text = text:gsub(LINE_FEED_CODE .. '+', '\n'):gsub(WEIRD_LINE_BREAK, '\n')
		for i, str in pairs({strsplit('\n', text)}) do
			timeToFinish = timeToFinish + self:AddString(str, strings, delays)
		end
		self.numTexts = #strings
		self.timeToFinish = timeToFinish
		self.timeStarted = GetTime()
		self:QueueTexts(strings, delays)
	end
end

function Text:CalculateDelay(length)
	return (length / (DELAY_DIVISOR or 15) ) + DELAY_PADDING
end

function Text:AddString(str, strings, delays)
	local length, delay, force = str:len(), 0
	if length > MAX_UNTIL_SPLIT then
		local new = str -- substitute natural breaks with newline.
			:gsub('%.%s+', '.\n') -- sentence
			:gsub('%.%.%.\n', '...\n...') -- ponder
			:gsub('%!%s+', '!\n'):gsub('%?%s+', '?\n') -- question/exclamation.
		--[[ If the string is unchanged, this will recurse infinitely, therefore
			force the long string to be shown. This safeguard is probably meaningless,
			as it requires 200+ chars without any punctuation. ]]
		if ( new == str ) then
			force = true
		else -- recursively split the altered string
			for i, short in pairs({strsplit('\n', new)}) do
				delay = delay + self:AddString(short, strings, delays)
			end
			return delay
		end
	end
	if ( length ~= 0 or force ) then
		delay = self:CalculateDelay(length)
		delays[ #strings + 1] = delay
		strings[ #strings + 1 ] = str
	end
	return delay
end

function Text:QueueTexts(strings, delays)
	assert(strings, 'No strings added to object '.. ( self:GetName() or '<unnamed fontString>' ) )
	assert(delays, 'No delays added to object '.. ( self:GetName() or '<unnamed fontString>' ) )
	self.strings = strings
	self.delays = delays
	Timer:AddText(self)
end

function Text:RepeatTexts()
	if self.storedText then
		self:SetText(self.storedText)
	end
end

function Text:IsFinished()
	return ( not self.strings )
end

function Text:IsSequence()
	return ( self.numTexts and self.numTexts > 1 )
end

function Text:GetNumRemaining()
	return self.strings and #self.strings or 0
end

function Text:GetTimeRemaining()
	if self.timeStarted and self.timeToFinish then
		local difference = ( self.timeStarted + self.timeToFinish ) - GetTime()
		return difference < 0 and 0 or difference
	end
	return 0
end

function Text:GetProgress()
	local full = self.numTexts or 0
	local remaining = self.strings and #self.strings or 0
	return ('%d/%d'):format(full - remaining + 1, full)
end

function Text:GetProgressPercent()
	if self.timeStarted and self.timeToFinish then
		local progress = ( GetTime() - self.timeStarted ) / self.timeToFinish
		return ( progress > 1 ) and 1 or progress
	end
	return 1
end

function Text:GetNumTexts() return self.numTexts or 0 end

function Text:OnFinished()
	self.strings = nil
	self.delays = nil
	self.timeToFinish = nil
	self.timeStarted = nil
end

function Text:ForceNext()
	if self.delays and self.strings then
		tremove(self.delays, 1)
		tremove(self.strings, 1)
		if self.strings[1] then
			self:SetNext(self.strings[1])
		else
			self:StopProgression()
			self:RepeatTexts()
		end
		if not self.strings[2] then
			self:OnFinished()
		end
	else
		self:RepeatTexts()
	end
end

function Text:StopProgression()
	Timer:RemoveText(self)
end

function Text:StopTexts()
	self:StopProgression()
	self:OnFinished()
	self:SetNext()
end

function Text:SetNext(text)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error('No fonts applied to TextMixin, call SetFontObjectsToTry first')
		end
		self:SetFontObject(self.fontObjectsToTry[1])
	end

	getmetatable(self).__index.SetText(self, text)
	self:ApplyFontObjects()
end

function Text:SetFontObjectsToTry(...)
	self.fontObjectsToTry = { ... }
	if self:GetText() then
		self:ApplyFontObjects()
	end
end

function Text:ApplyFontObjects()
	if not self.fontObjectsToTry then
		error('No fonts applied to TextMixin, call SetFontObjectsToTry first');
	end

	for i, fontObject in ipairs(self.fontObjectsToTry) do
		self:SetFontObject(fontObject)
		if not self:IsTruncated() then
			break
		end
	end
end

function Text:SetFormattedText(format, ...)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error('No fonts applied to TextMixin, call SetFontObjectsToTry first')
		end
		self:SetFontObject(self.fontObjectsToTry[1])
	end

	getmetatable(self).__index.SetFormattedText(self, format, ...)
	self:ApplyFontObjects()
end

function Timer:AddText(fontString)
	if fontString then
		self.Texts[fontString] = true
		if not self:GetScript('OnUpdate') then
			self.elapsed = 0
		end
		self:SetScript('OnUpdate', self.OnUpdate)
	end
end

function Timer:GetTexts() return pairs(self.Texts) end

function Timer:RemoveText(fontString)
	if fontString then
		self.Texts[fontString] = nil
	end
end

function Timer:OnTextFinished(fontString)
	if fontString then
		self:RemoveText(fontString)
		if fontString.OnFinishedCallback then
			fontString:OnFinishedCallback()
		end
	end
end

function Timer:OnUpdate(elapsed)
	for text in self:GetTexts() do
		if 	( text.strings and text.delays ) and
		 	( next(text.strings) and next(text.delays) ) then
			if not text:GetText() then
				text:SetNext(text.strings[1])
			end
			-- deduct elapsed time since update from current delay
			text.delays[1] = text.delays[1] - elapsed
			-- delay is below zero, move on to next line
			if text.delays[1] <= 0 then
				tremove(text.delays, 1)
				tremove(text.strings, 1)
				-- check if there's another line waiting
				if text.strings[1] then
					text:SetNext(text.strings[1])
				else
					self:OnTextFinished(text)
				end
			end
		else
			text:OnFinished()
			self:OnTextFinished(text)
		end
	end
	if not next(self.Texts) then
		self:SetScript('OnUpdate', nil)
	end
end