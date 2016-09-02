---------------------------------------------------------------
-- UICore.lua: Core functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. See Cursors\Interface.lua.
---------------------------------------------------------------
local _, db = ...
---------------------------------------------------------------
		-- Upvalue menu and main frame due to frequent calls
local 	GameMenu, Core, 
		-- General functions
		InCombat, Callback, SetHook, IsLoaded,
		-- Table functions
		pairs, next,
		-- Stacks: all frames, visible frames, show/hide hooks
		frameStack, visibleStack, hookStack, customStack,
		-- Boolean checks (default nil)
		hasUIFocus, isEnabled, updateQueued =
		-------------------------------------
		GameMenuFrame, ConsolePort,
		InCombatLockdown, C_Timer.After, hooksecurefunc, IsAddOnLoaded,
		pairs, next, {}, {}, {}
---------------------------------------------------------------

function Core:HasUIFocus() return hasUIFocus end
function Core:SetUIFocus(focus) hasUIFocus = focus end

---------------------------------------------------------------
-- Node modification to prevent unwanted and wonky UI behaviour.
---------------------------------------------------------------
--[[ flag: a flag that is read by the UI cursor upon recursive lookup.
	 nodes: a table of nodes to apply the modifier flag to.
	 flags:
		hasPriority:
			Choose these nodes above all else,
			providing smart snap behaviour when searching
			for the most appropriate node to focus.
		ignoreNode:
			Ignore these nodes completely,
			since they are pointless or annoying to deal with.
		ignoreMenu:
			Will not cause the game menu to hide itself
			whenever one of these nodes are clicked.
		ignoreScroll:
			Will not attempt to automatically scroll
			these frames when a child node within is focused.
		includeChildren:
			Will ignore the host widget, but include all
			children widgets contained inside.
]]
---------------------------------------------------------------
for flag, nodes in pairs({
	-----------------------------------------------------------
	hasPriority = {
		GossipTitleButton1,
		HonorFrameSoloQueueButton,
		LFDQueueFrameFindGroupButton,
		MerchantItem1ItemButton,
		MerchantRepairAllButton,
		InterfaceOptionsFrameCancel,
		PaperDollSidebarTab3,
		QuestFrameAcceptButton,
		QuestFrameCompleteButton,
		QuestFrameCompleteQuestButton,
		QuestTitleButton1,
		QuestMapFrame.DetailsFrame.BackButton,
	},
	ignoreNode = {
		LootFrameCloseButton,
		WorldMapTitleButton,
		WorldMapButton,
	},
	ignoreMenu = {
		ObjectiveTrackerFrame.HeaderMenu.MinimizeButton,
		MinimapZoomIn,
		MinimapZoomOut,
	},
	ignoreScroll = {
		WorldMapScrollFrame,
	},
	includeChildren = {
		DropDownList1,
		DropDownList2,
	},
	-----------------------------------------------------------
}) do for _, node in pairs(nodes) do node[flag] = true end end
---------------------------------------------------------------

-- Update the cursor state on visibility change.
-- Use callback to circumvent omitting frames that set their points on show.
-- Check for point because frames can be visible but not drawn.
local function showHook(self)
	if isEnabled and frameStack[self] then
		updateQueued = true
		Callback(0.02, function()
			visibleStack[self] = self:GetPoint() and self:IsVisible() and true or nil
			if updateQueued then
				updateQueued = false
				Core:UpdateFrames()
			end
		end)
	end
end

-- Use callback to circumvent node jumping when closing multiple frames,
-- which leads to the cursor ending up in an unexpected place on re-show.
-- E.g. close 5 bags, cursor was in 1st bag, ends up in 5th bag on re-show.
local function hideHook(self)
	if isEnabled and frameStack[self] then
		Callback(0.02, function()
			hasUIFocus = nil
			visibleStack[self] = nil
			Core:UpdateFrames()
		end)
	end
end

hookStack[getmetatable(UIParent).__index.Show] = true
hookStack[getmetatable(UIParent).__index.Hide] = true 

-- When adding a new frame:
-- Store metatable functions for hooking show/hide scripts.
-- Most frames will use the same standard Show/Hide, but addons 
-- may use custom metatables, which should still work with this approach.
function Core:AddFrame(frame)
	local widget = (type(frame) == "string" and _G[frame]) or (type(frame) == "table" and frame)
	if widget then
		-- assert the frame isn't hooked twice
		if not frameStack[widget] then
			local mt = getmetatable(widget).__index

			if not hookStack[mt.Show] then
				SetHook(mt, "Show", showHook)
				hookStack[mt.Show] = true
			else
				widget:HookScript("OnShow", showHook)
			end

			if not hookStack[mt.Hide] then
				SetHook(mt, "Hide", hideHook)
				hookStack[mt.Hide] = true
			else
				widget:HookScript("OnHide", hideHook)
			end
		end

		frameStack[widget] = true
		if widget:IsVisible() and widget:GetPoint() then
			visibleStack[widget] = true
		end
		return true
	else
		self:AddFrameTracker(frame)
	end
end

function Core:RemoveFrame(frame)
	if frame then
		visibleStack[frame] = nil
		frameStack[frame] = nil
	end
end

function Core:CheckLoadedAddons()
	local addOnList, loaded = ConsolePortUIFrames, {}
	for name, frames in pairs(addOnList) do
		if IsLoaded(name) then
			for i, frame in pairs(frames) do
				self:AddFrame(frame)
			end
		end
	end
	for name, loadPlugin in pairs(db.PLUGINS) do
		if IsLoaded(name) then
			loadPlugin(self)
			loaded[name] = true
		end
	end
	for name in pairs(loaded) do
		db.PLUGINS[name] = nil
	end
end

function Core:ToggleUICore()
	isEnabled = not db.Settings.disableUI
	if not isEnabled then
		self:SetButtonOverride(false)
	end
end

function Core:UpdateFrames()
	if not InCombat() then
		self:UpdateFrameTracker()
		if next(visibleStack) then
			if not hasUIFocus then
				hasUIFocus = true
				self:SetButtonOverride(true)
				if not self:UIControl() then
					-- there are visible frames, but no eligible nodes -> flag frames as hidden.
					for frame in pairs(visibleStack) do
						hideHook(frame)
					end
				end
			end
		else
			self:SetButtonOverride(false)
		end
	end
end

-- Returns a stack of visible frames.
function Core:GetFrameStack()
	if customStack then
		return customStack
	elseif GameMenu:IsVisible() then
		local fullStack = {}
		for _, frame in pairs({UIParent:GetChildren()}) do
			if not frame:IsForbidden() and frame:IsVisible() then
				fullStack[frame] = true
			end
		end
		return fullStack
	else
		return visibleStack
	end
end

function Core:SetFrameStack(stack)
	customStack = stack
end

function Core:IsFrameVisible(...)
	for i, frame in pairs({...}) do
		if visibleStack[frame] then
			return true
		end
	end
end 