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
-- Override the original consoleport action button lookup, to
-- stop it from adding hotkey textures to the controller bars.
-- It will still add hotkey textures to override/vehicle bars,
-- and any other action bars present that match the criteria.

local valid_action_buttons = {
	Button = true,
	CheckButton = true,
}

-- Wrap this function since it's recursive.
local function GetActionButtons(buttons, this)
	buttons = buttons or {}
	this = this or UIParent
	if this:IsForbidden() or this == bar then
		return buttons
	end
	local action = this:IsProtected() and valid_action_buttons[this:GetObjectType()] and this:GetAttribute('action')
	if action and tonumber(action) and this:GetAttribute('type') == 'action' then
		buttons[this] = action
	end
	for _, object in ipairs({this:GetChildren()}) do
		GetActionButtons(buttons, object)
	end
	return buttons
end

---------------------------------------------------------------
-- Get all buttons that look like action buttons
---------------------------------------------------------------
function ConsolePort:GetActionButtons(getTable, parent)
	if getTable then
		return GetActionButtons(parent)
	else
		return pairs(GetActionButtons(parent))
	end
end
---------------------------------------------------------------