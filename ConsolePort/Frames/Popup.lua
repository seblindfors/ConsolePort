---------------------------------------------------------------
-- Popup.lua: Redirect cursor to an appropriate popup on show
---------------------------------------------------------------
-- Since popups normally appear in response to an event or
-- crucial action, the UI cursor will automatically move to
-- a popup when it is shown. StaticPopup1 has first priority.

local popupFrames = {
	StaticPopup1,
	StaticPopup2,
	StaticPopup3,
	StaticPopup4
}

for i, Popup in pairs(popupFrames) do
	Popup:HookScript("OnShow", function(self)
		self:EnableKeyboard(false)
		if not InCombatLockdown() then
			if not popupFrames[i-1] or popupFrames[i-1] and not popupFrames[i-1]:IsVisible() then
				ConsolePort:SetCurrentNode(self.button1)
			end
		end
	end)
end

---------------------------------------------------------------
-- Dropdowns: Child widget filtering to remove unwanted entries
---------------------------------------------------------------

local dropDowns = {
	DropDownList1,
	DropDownList2,
}

local forbidden = {
	["SET_FOCUS"] = true,
	["PET_DISMISS"] = true,
}

for i, DD in pairs(dropDowns) do
	DD:HookScript("OnShow", function(self)
		local children = {self:GetChildren()}
		for j, child in pairs(children) do
			if (child.IsVisible and not child:IsVisible()) or (child.IsEnabled and not child:IsEnabled()) then
				child.ignoreNode = true
			else
				child.ignoreNode = nil
			end
			if child.hasArrow then
				child.ignoreChildren = true
			else
				child.ignoreChildren = false
			end
			if forbidden[child.value] then
				child.ignoreNode = true
			end
		end
	end)
end