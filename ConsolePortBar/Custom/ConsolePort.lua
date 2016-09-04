-- This code snippet modifies default ConsolePort behaviour to accomodate the action bars.

local addOn, ab = ...
local Bar, UIHider = ab.bar, ab.bar.UIHider

-- raid cursor fix to add the hidden action bars to the interface scan process
ConsolePortRaidCursor:SetFrameRef("hiddenBars", UIHider)
ConsolePortRaidCursor:Execute([[
	UpdateFrameStack = [=[
		local frames = newtable(self:GetParent():GetChildren())
		frames[#frames + 1] = self:GetFrameRef("hiddenBars")
		for i, frame in pairs(frames) do
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
