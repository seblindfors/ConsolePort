---------------------------------------------------------------
-- Mods
---------------------------------------------------------------
-- Modifications to the UI to support better cursor behavior.

local env, db, _ = CPAPI.GetEnv(...); _ = CPAPI.OnAddonLoaded;

-- Popups:
-- Since popups normally appear in response to an event or
-- crucial action, the UI cursor will automatically move to
-- a popup when it is shown. StaticPopup1 has first priority.
do  local popups, visible, oldNode = {}, {};
	for i, popup in ipairs(env.StaticPopupStack) do
		popups[_G[popup]] = _G[env.StaticPopupStack[i-1]] or false;
	end

	local function PopupOnShow(self)
		visible[self] = true;
		if InCombatLockdown() or not db('UIenablePopups') then return end;

		local prio = popups[self];
		if prio and prio:IsVisible() then return end;

		local current = env.Cursor:GetCurrentNode()
		-- assert not caching a return-to node on a popup
		if current and not popups[current:GetParent()] then
			oldNode = current;
		end
		local button = self.button1;
		if self.GetButton1 then
			button = self:GetButton1();
		end
		env.Cursor:SetCurrentNodeIfActive(button)
	end

	local function PopupOnHide(self)
		visible[self] = nil;
		if InCombatLockdown() or not db('UIenablePopups') then return end;
		if not next(visible) and oldNode then
			env.Cursor:SetCurrentNodeIfActive(oldNode)
			oldNode = nil;
		end
	end

	for popup in pairs(popups) do
		popup:HookScript('OnShow', PopupOnShow)
		popup:HookScript('OnHide', PopupOnHide)
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

-- High priority frames:
for _, frame in ipairs({
	QuestFrameAcceptButton,
	QuestFrameCompleteButton,
	QuestFrameCompleteQuestButton,
}) do
	if frame then
		frame:SetAttribute(env.Attributes.Priority, 1)
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

-- Help plates:
-- Help plates are bound to a canvas frame that is not part of the regular cursor stack.
-- First step is adding the canvas so that the cursor can see the plates, but the plates
-- also need to be passthrough so that the anchor point is the (i) button on the plate,
-- rather than the center of the plate itself, since it often covers other UI elements.
-- Finally, handle the OnEnter/OnLeave scripts by propagating it from the button to the
-- plate, where OnLeave is handled here (because the button has no OnLeave script), and
-- OnEnter is handled in Scripts.lua with a replacement script.
_('Blizzard_HelpPlate', function()
	if HelpPlateCanvas then
		db.Stack:SetFrame(HelpPlateCanvas, true)
		HelpPlateCanvas:HookScript('OnShow', function(self)
			for _, child in ipairs({self:GetChildren()}) do
				child:SetAttribute(env.Attributes.PassThrough, true)
			end
		end)
	end
	if HelpPlateButtonMixin then
		hooksecurefunc(HelpPlateButtonMixin, 'OnLoad', function(self)
			self:HookScript('OnLeave', function(self)
				if env.Cursor:GetOldNode() == self then
					ExecuteFrameScript(self:GetParent(), 'OnLeave')
				end
			end)
		end)
	end
end)

-- Hero talents selection dialog:
-- The Hero talents selection dialog is not piped through the cursor stack,
-- so it needs to be manually added to the stack.
_('Blizzard_PlayerSpells', function()
	db.Stack:SetFrame(HeroTalentsSelectionDialog, true)
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

_('Blizzard_HouseEditor', function()
	db.Stack:SetFrame(HouseEditorFrame, true)
	if GeneralDockManager then
		GeneralDockManager:SetAttribute(env.Attributes.IgnoreNode, true)
	end
end)