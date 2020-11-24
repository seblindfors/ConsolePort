-- This file modifies default ConsolePort behaviour to accommodate the action bars.
local bar = select(2, ...).bar
---------------------------------------------------------------
-- Raid cursor fix to add the hidden action bars to the interface scan process

ConsolePortRaidCursor:SetFrameRef("hiddenBars", bar.UIHider)
ConsolePortRaidCursor:CreateEnvironment({
	UpdateNodes = [[
		local frames = newtable(self:GetParent():GetChildren())
		frames[#frames+1] = self:GetFrameRef('hiddenBars')
		for i, object in ipairs(frames) do
			node = object; self:Run(GetNodes);
		end
	]];
})