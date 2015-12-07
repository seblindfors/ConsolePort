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
		if not InCombatLockdown() then
			if not popupFrames[i-1] or popupFrames[i-1] and not popupFrames[i-1]:IsVisible() then
				ConsolePort:SetCurrentNode(self.button1)
			end
		end
	end)
end
