---------------------------------------------------------------
-- UITracker.lua: Widget tracking
---------------------------------------------------------------
-- Used to track and bind interface widgets to the controller.
-- Necessary since widgets might be created at a later time.

local widgetTrackers = {}

local function CheckWidgetTrackers(self)
	if not InCombatLockdown() then
		for button, widget in pairs(widgetTrackers) do
			if _G[widget] then
				self:LoadInterfaceBinding(button, widget)
				widgetTrackers[button] = nil
			end
		end
		if not next(widgetTrackers) then
			self:RemoveUpdateSnippet(CheckWidgetTrackers)
		end
	end
end

function ConsolePort:AddWidgetTracker(button, action)
	widgetTrackers[button] = action
	self:AddUpdateSnippet(CheckWidgetTrackers)
end

---------------------------------------------------------------
-- UITracker.lua: Frame tracking
---------------------------------------------------------------
-- Used to track and bind addon frames to the UI cursor.
-- Necessary since all frames do not exist on ADDON_LOADED.
-- Automatically adds all special frames, i.e. closed with ESC.

local specialFrames, frameTrackers = {}, {}

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

function ConsolePort:UpdateFrameTracker()
	CheckSpecialFrames(self)
	for frame in pairs(frameTrackers) do
		if self:AddFrame(frame) then
			frameTrackers[frame] = nil
		end
	end
end

function ConsolePort:AddFrameTracker(frame)
	frameTrackers[frame] = true
end