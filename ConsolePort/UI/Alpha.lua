---------------------------------------------------------------
-- Alpha.lua: Taint-free alpha animation framework
---------------------------------------------------------------
-- Provides a framework for managing alpha animations without
-- risk of spreading taint.

local _, db = ...

---------------------------------------------------------------
-- Fade: Taint-free fade functions
---------------------------------------------------------------

local FADEFRAMES = {}
local FadeManager = CreateFrame("Frame")

local function FadeRemoveFrame(frame)
	tDeleteItem(FADEFRAMES, frame)
end

local function FadeOnUpdate(self, elapsed)
	local index = 1
	local frame, fadeInfo
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index]
		fadeInfo = FADEFRAMES[index].fadeInfo
		-- Reset the timer if there isn't one, this is just an internal counter
		if ( not fadeInfo.fadeTimer ) then
			fadeInfo.fadeTimer = 0
		end
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed

		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade 
		if fadeInfo.fadeTimer < fadeInfo.timeToFade then
			if fadeInfo.mode == "IN" then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha)
			elseif fadeInfo.mode == "OUT" then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha)
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha)
			-- If there is a fadeHoldTime then wait until its passed to continue on
			if fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0  then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed
			else
				-- Complete the fade and call the finished function if there is one
				FadeRemoveFrame(frame)
				if fadeInfo.finishedFunc then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4)
					fadeInfo.finishedFunc = nil
				end
			end
		end
		
		index = index + 1
	end
	
	if #FADEFRAMES == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

-- Generic fade function
local function FadeFrame(frame, fadeInfo)
	frame:SetAlpha(fadeInfo.startAlpha)
	frame.fadeInfo = fadeInfo

	local index = 1
	while FADEFRAMES[index] do
		-- If frame is already set to fade then return
		if FADEFRAMES[index] == frame then
			return
		end
		index = index + 1
	end
	tinsert(FADEFRAMES, frame)
	FadeManager:SetScript("OnUpdate", FadeOnUpdate)
end

-- Convenience function for simple fade in
db.UIFrameFadeIn = function (frame, timeToFade, startAlpha, endAlpha, info)
	if not frame then return end
	local fadeInfo = info or {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha or 0.0
	fadeInfo.endAlpha = endAlpha or 1.0
	FadeFrame(frame, fadeInfo)
end

-- Convenience function for simple fade out
db.UIFrameFadeOut = function (frame, timeToFade, startAlpha, endAlpha, info)
	if not frame then return end
	local fadeInfo = info or {}
	fadeInfo.mode = "OUT"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha or 1.0
	fadeInfo.endAlpha = endAlpha or 0.0
	FadeFrame(frame, fadeInfo)
end

-- Convenience function for localizing both faders
db.GetFaders = function()
	return db.UIFrameFadeIn, db.UIFrameFadeOut
end


---------------------------------------------------------------
-- Flash: Taint-free flash functions
---------------------------------------------------------------
local FlashManager = CreateFrame("FRAME")
local FLASHFRAMES = {}

local FlashTimers = {}
local FlashTimerRefCount = {}

-- Function to stop flashing
local function FlashStop(frame, alpha)
	tDeleteItem(FLASHFRAMES, frame)
	frame:SetAlpha(alpha or 1.0)
	frame.flashTimer = nil
	if frame.syncId then
		FlashTimerRefCount[frame.syncId] = FlashTimerRefCount[frame.syncId]-1
		if FlashTimerRefCount[frame.syncId] == 0 then
			FlashTimers[frame.syncId] = nil
			FlashTimerRefCount[frame.syncId] = nil
		end
		frame.syncId = nil
	end
	if frame.showWhenDone then
		frame:Show()
	else
		frame:Hide()
	end
end

-- Called every frame to update flashing frames
local function FlashOnUpdate(self, elapsed)
	local frame
	local index = #FLASHFRAMES
	
	-- Update timers for all synced frames
	for syncId, timer in pairs(FlashTimers) do
		FlashTimers[syncId] = timer + elapsed
	end
	
	while FLASHFRAMES[index] do
		frame = FLASHFRAMES[index]
		frame.flashTimer = frame.flashTimer + elapsed

		if (frame.flashTimer > frame.flashDuration) and frame.flashDuration ~= -1 then
			FlashStop(frame)
		else
			local flashTime = frame.flashTimer
			local alpha
			
			if frame.syncId then
				flashTime = FlashTimers[frame.syncId]
			end
			
			flashTime = flashTime%(frame.fadeInTime+frame.fadeOutTime+(frame.flashInHoldTime or 0)+(frame.flashOutHoldTime or 0))
			if flashTime < frame.fadeInTime then
				alpha = flashTime/frame.fadeInTime
			elseif flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0) then
				alpha = 1
			elseif flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)+frame.fadeOutTime then
				alpha = 1 - ((flashTime - frame.fadeInTime - (frame.flashInHoldTime or 0))/frame.fadeOutTime)
			else
				alpha = 0
			end
			
			frame:SetAlpha(alpha)
			frame:Show()
		end
		
		-- Loop in reverse so that removing frames is safe
		index = index - 1
	end
	
	if #FLASHFRAMES == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

db.UIFrameFlashStop = function(frame, alpha)
	FlashStop(frame, alpha)
end

-- Function to start a frame flashing
db.UIFrameFlash =  function(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
	if frame then
		local index = 1
		-- If frame is already set to flash then return
		while FLASHFRAMES[index] do
			if FLASHFRAMES[index] == frame then
				return
			end
			index = index + 1
		end

		if syncId then
			frame.syncId = syncId
			if FlashTimers[syncId] == nil then
				FlashTimers[syncId] = 0
				FlashTimerRefCount[syncId] = 0
			end
			FlashTimerRefCount[syncId] = FlashTimerRefCount[syncId]+1
		else
			frame.syncId = nil
		end
		
		-- Time it takes to fade in a flashing frame
		frame.fadeInTime = fadeInTime
		-- Time it takes to fade out a flashing frame
		frame.fadeOutTime = fadeOutTime
		-- How long to keep the frame flashing
		frame.flashDuration = flashDuration
		-- Show the flashing frame when the fadeOutTime has passed
		frame.showWhenDone = showWhenDone
		-- Internal timer
		frame.flashTimer = 0
		-- How long to hold the faded in state
		frame.flashInHoldTime = flashInHoldTime
		-- How long to hold the faded out state
		frame.flashOutHoldTime = flashOutHoldTime
		
		tinsert(FLASHFRAMES, frame)
		
		FlashManager:SetScript("OnUpdate", FlashOnUpdate)
	end
end
