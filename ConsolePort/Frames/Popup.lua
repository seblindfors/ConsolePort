---------------------------------------------------------------
-- Popup.lua: Redirect cursor to an appropriate popup on show
---------------------------------------------------------------
-- Since popups normally appear in response to an event or
-- crucial action, the UI cursor will automatically move to
-- a popup when it is shown. StaticPopup1 has first priority.

local oldNode

local popups = {
	[StaticPopup1] = false,
	[StaticPopup2] = StaticPopup1,
	[StaticPopup3] = StaticPopup2,
	[StaticPopup4] = StaticPopup3,
}

for Popup, previous in pairs(popups) do
	Popup:HookScript("OnShow", function(self)
		self:EnableKeyboard(false)
		if not InCombatLockdown() then
			if not popups[previous] or ( popups[previous] and not popups[previous]:IsVisible() ) then
				local current = ConsolePort:GetCurrentNode()
				if current and not popups[current:GetParent()] then
					oldNode = current
				end
				ConsolePort:SetCurrentNode(self.button1)
			end
		end
	end)
	Popup:HookScript("OnHide", function(self)
		if not InCombatLockdown() and oldNode then
			ConsolePort:SetCurrentNode(oldNode)
		end
	end)
end

---------------------------------------------------------------
-- Dropdowns: Child widget filtering to remove unwanted entries
---------------------------------------------------------------

-- local dropDowns = {
-- 	DropDownList1,
-- 	DropDownList2,
-- }

-- local forbidden = {
-- 	["SET_FOCUS"] = true,
-- 	["PET_DISMISS"] = true,
-- }

-- for i, DD in pairs(dropDowns) do
-- 	DD:HookScript("OnShow", function(self)
-- 		local children = {self:GetChildren()}
-- 		for j, child in pairs(children) do
-- 			if (child.IsVisible and not child:IsVisible()) or (child.IsEnabled and not child:IsEnabled()) then
-- 				child.ignoreNode = true
-- 			else
-- 				child.ignoreNode = nil
-- 			end
-- 			if child.hasArrow then
-- 				child.ignoreChildren = true
-- 			else
-- 				child.ignoreChildren = false
-- 			end
-- 			if forbidden[child.value] then
-- 				child.ignoreNode = true
-- 			end
-- 		end
-- 	end)
-- end