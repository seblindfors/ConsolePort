---------------------------------------------------------------
-- UITracker.lua: Widget tracking
---------------------------------------------------------------
-- Used to track and bind interface widgets to the controller.
-- Necessary since widgets might be created at a later time.

local widgetTrackers = {}

local function CheckWidgetTrackers(self)
	if not InCombatLockdown() then
		local numTrackers = 0
		for button, action in pairs(widgetTrackers) do
			numTrackers = numTrackers + 1
			if _G[action] then
				self:LoadInterfaceBinding(button, action)
				button.widgetTracker = nil
				widgetTrackers[button] = nil
			end
		end
		if numTrackers == 0 then
			self:RemoveUpdateSnippet(CheckWidgetTrackers)
		end
	end
end

function ConsolePort:AddWidgetTracker(button, action)
	widgetTrackers[button] = action
	button.widgetTracker = action
	self:AddUpdateSnippet(CheckWidgetTrackers)
end

---------------------------------------------------------------
-- UITracker.lua: Frame tracking
---------------------------------------------------------------
-- Used to track and bind addon frames to the UI cursor.
-- Necessary since all frames do not exist on ADDON_LOADED.
-- Automatically adds all special frames, i.e. closed with ESC.

local allFramesLoaded = false
local specialFrames = {}
local frameTrackers = {}

local function CheckSpecialFrames(self)
	local frames = UISpecialFrames
	for i, frame in pairs(frames) do
		if not specialFrames[frame] then
			if self:AddFrame(frame) then
				specialFrames[frame] = true
			end
		end
	end
end

function ConsolePort:UpdateFrameTracker(self)
	CheckSpecialFrames(self)
	if not allFramesLoaded then
		local numTrackers = 0
		for frame in pairs(frameTrackers) do
			if self:AddFrame(frame) then
				frameTrackers[frame] = nil
			else
				numTrackers = numTrackers + 1
			end
		end
		if 	numTrackers == 0 then
			allFramesLoaded = true
		end
	end
end

function ConsolePort:AddFrameTracker(frame)
	frameTrackers[frame] = true
	allFramesLoaded = false
end