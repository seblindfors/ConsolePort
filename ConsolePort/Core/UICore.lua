---------------------------------------------------------------
-- UICore.lua: Core functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. Stack is processed in Interface.lua.

local frameStack, visibleStack, hasUIFocus, isEnabled = {}, {}

local GameMenuFrame = GameMenuFrame
local InCombatLockdown = InCombatLockdown
local Callback = C_Timer.After
local pairs = pairs
local next = next

-- Upvalue because of explicit use in hook scripts
local _, db = ...
local ConsolePort = ConsolePort

function ConsolePort:HasUIFocus() return hasUIFocus end
function ConsolePort:SetUIFocus(focus) hasUIFocus = focus end

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
local updateQueued = false
local function showHook(self)
	if isEnabled and frameStack[self] then
		updateQueued = true
		Callback(0.02, function()
			visibleStack[self] = self:GetPoint() and self:IsVisible() and true or nil
			if updateQueued then
				updateQueued = false
				ConsolePort:UpdateFrames()
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
			ConsolePort:UpdateFrames()
		end)
	end
end

-- Store metatable functions for hooking show/hide on frames.
-- Most frames will use the same standard Show/Hide, but addons 
-- may use custom metatables for extra functionality. 
local hookStack = {}

function ConsolePort:AddFrame(frame)
	local widget = (type(frame) == "string" and _G[frame]) or (type(frame) == "table" and frame)
	if widget then
		local mt = getmetatable(widget).__index

		if not hookStack[mt.Show] then
			hooksecurefunc(mt, "Show", showHook)
			hookStack[mt.Show] = true
		end

		if not hookStack[mt.Hide] then
			hooksecurefunc(mt, "Hide", hideHook)
			hookStack[mt.Hide] = true
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

function ConsolePort:RemoveFrame(frame)
	if frame then
		visibleStack[frame] = nil
		frameStack[frame] = nil
	end
end

function ConsolePort:CheckLoadedAddons()
	local addOnList = ConsolePortUIFrames
	for name, frames in pairs(addOnList) do
		if IsAddOnLoaded(name) then
			for i, frame in pairs(frames) do
				self:AddFrame(frame)
			end
		end
	end
	for name, loadFunc in pairs(db.PLUGINS) do
		if IsAddOnLoaded(name) then
			loadFunc(self)
		end
	end
end

function ConsolePort:ToggleUICore()
	isEnabled = not db.Settings.disableUI
	if not isEnabled then
		self:SetButtonOverride(false)
	end
end

function ConsolePort:UpdateFrames()
	if not InCombatLockdown() then
		self:UpdateFrameTracker(self)
		if next(visibleStack) then
			if not hasUIFocus then
				hasUIFocus = true
				self.Cursor:Show()
				self:SetButtonOverride(true)
				self:UIControl()
			end
		else
			self:SetButtonOverride(false)
		end
	end
end

-- Returns a stack of visible frames.
function ConsolePort:GetFrameStack()
	if GameMenuFrame:IsVisible() then
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

function ConsolePort:IsFrameVisible(...)
	for i, frame in pairs({...}) do
		if visibleStack[frame] then
			return true
		end
	end
end 