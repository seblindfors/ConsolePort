---------------------------------------------------------------
-- Mods
---------------------------------------------------------------
-- Modifications to the UI to support better cursor behavior.

local _, env = ...;

-- Popups:
-- Since popups normally appear in response to an event or
-- crucial action, the UI cursor will automatically move to
-- a popup when it is shown. StaticPopup1 has first priority.
do  local popups, visible, oldNode = {}, {};
	for i=1, STATICPOPUP_NUMDIALOGS do
		popups[_G['StaticPopup'..i]] = _G['StaticPopup'..(i-1)] or false;
	end

	for popup, previous in pairs(popups) do
		popup:HookScript('OnShow', function(self)
			visible[self] = true;
			if not InCombatLockdown() then
				local prio = popups[previous];
				if not prio or ( not prio:IsVisible() ) then
					local current = env.Cursor:GetCurrentNode()
					-- assert not caching a return-to node on a popup
					if current and not popups[current:GetParent()] then
						oldNode = current;
					end
					env.Cursor:SetCurrentNode(self.button1)
				end
			end
		end)
		popup:HookScript('OnHide', function(self)
			visible[self] = nil;
			if not next(visible) and not InCombatLockdown() and oldNode then
				env.Cursor:SetCurrentNode(oldNode)
			end
		end)
	end
end


-- Map canvas:
-- Disable automatic cursor scrolling.
if MapCanvasScrollControllerMixin then
	hooksecurefunc(MapCanvasScrollControllerMixin, 'OnLoad', function(self)
		self:SetAttribute(env.Attributes.IgnoreScroll, true)
	end)
end

if (WorldMapFrame and WorldMapFrame.ScrollContainer) then
	WorldMapFrame.ScrollContainer:SetAttribute(env.Attributes.IgnoreScroll, true)
end