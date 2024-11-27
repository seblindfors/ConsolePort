---------------------------------------------------------------
-- Mods
---------------------------------------------------------------
-- Modifications to the UI to support better cursor behavior.

local _, env = ...; _ = CPAPI.OnAddonLoaded;

-- Popups:
-- Since popups normally appear in response to an event or
-- crucial action, the UI cursor will automatically move to
-- a popup when it is shown. StaticPopup1 has first priority.
do  local popups, visible, oldNode = {}, {};
	for i=1, STATICPOPUP_NUMDIALOGS do
		popups[_G['StaticPopup'..i]] = _G['StaticPopup'..(i-1)] or false;
	end

	for popup, previous in pairs(popups) do
		popup:SetAttribute(env.Attributes.PassThrough, true)
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
					env.Cursor:SetCurrentNodeIfActive(self.button1)
				end
			end
		end)
		popup:HookScript('OnHide', function(self)
			visible[self] = nil;
			if not next(visible) and not InCombatLockdown() and oldNode then
				env.Cursor:SetCurrentNodeIfActive(oldNode)
				oldNode = nil;
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

-- Group loot frames:
-- Set priority to icon/tooltip to minimize accidental need/greed/pass.
do local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES or 4;
	for i=1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G['GroupLootFrame'..i];
		local iconFrame = frame and frame.IconFrame;
		if iconFrame then
			iconFrame:SetAttribute(env.Attributes.Priority, 1)
		end
	end
end

-- Classic Spellbook:
-- Handle the spellbook frame using an unreferenced and hardcoded close button name.
if (SpellBookFrame and SpellBookCloseButton) then
	SpellBookFrame.CloseButton = SpellBookCloseButton;
end

-- PVP match results:
-- The PvP match results frame has a scroll box with a data provider that is recreated on every
-- rendered frame. If the cursor focuses a line in the scroll box, it will flicker around the
-- screen as the data provider is recreated, and the lines are recycled, appearing in a different
-- order. To prevent this, ignore the entire scroll box and limit acccess to just the scroll bar
-- and other standard frame elements.
_('Blizzard_PVPMatch', function()
	if (PVPMatchResults and PVPMatchResults.content and PVPMatchResults.content.scrollBox) then
		PVPMatchResults.content.scrollBox:SetAttribute(env.Attributes.IgnoreNode, true)
	end
end)

-- Taint error callback:
-- Replace popup messages for forbidden actions which cannot be fixed by the addon.
function env.HandleTaintError(action)
	local errorMessage =  env.ForbiddenActions[action];
	if (errorMessage) then
		RunNextFrame(function()
			local message = CPAPI.FormatLongText(env.db.Locale(errorMessage))
			local popup = StaticPopup_FindVisible('ADDON_ACTION_FORBIDDEN')
			if popup then
				_G[popup:GetName()..'Text']:SetText(message)
				popup.button1:SetEnabled(false)
				StaticPopup_Resize(popup, 'ADDON_ACTION_FORBIDDEN')
			end
		end)
	end
end