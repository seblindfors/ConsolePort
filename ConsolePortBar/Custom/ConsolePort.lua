-- This file modifies default ConsolePort behaviour to accommodate the action bars.
local bar = select(2, ...).bar
---------------------------------------------------------------
-- Raid cursor fix to add the hidden action bars to the interface scan process

ConsolePortRaidCursor:SetFrameRef("hiddenBars", bar.UIHider)
ConsolePortRaidCursor:Execute([[
	UpdateFrameStack = [=[
		local frames = newtable(self:GetParent():GetChildren())
		frames[#frames + 1] = self:GetFrameRef("hiddenBars")
		for _, frame in ipairs(frames) do
			if frame:IsProtected() and not Cache[frame] then
				CurrentNode = frame
				self:Run(GetNodes)
			end
		end
		self:Run(RefreshActions)
		if IsEnabled then
			self:Run(SelectNode, 0)
		end
	]=]
]])


---------------------------------------------------------------
-- Stop action button lookup from adding hotkeys to the bars,
-- since this is handled internally by the wrapper.

ConsolePort:SetIgnoreFrameForActionLookup(bar, true)