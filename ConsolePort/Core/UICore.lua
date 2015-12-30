---------------------------------------------------------------
-- UICore.lua: Core functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. Stack is processed in CursorUI.lua.

local visibleStack, hasUIFocus = {}

local IsOptionFrameOpen = IsOptionFrameOpen
local InCombatLockdown = InCombatLockdown
local Callback = C_Timer.After
local pairs = pairs
local next = next

-- Upvalue because of explicit use in hook scripts
local ConsolePort = ConsolePort

function ConsolePort:HasUIFocus() return hasUIFocus end
function ConsolePort:SetUIFocus(focus) hasUIFocus = focus end

-- Cursor will choose these nodes above all else,
-- providing smart snap behaviour when searching
-- for the most appropriate node to focus.
for _, node in pairs({
	ContainerFrame1Item16,
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
	QuestScrollFrame.ViewAll,
}) do node.hasPriority = true end

-- Cursor will ignore these nodes completely,
-- since they are pointless or annoying to deal with.
for _, node in pairs({
	LootFrameCloseButton,
	WorldMapTitleButton,
	WorldMapButton,
}) do node.ignoreNode = true end

-- Cursor will not cause the game menu to hide itself
-- whenever one of these nodes are clicked.
for _, node in pairs({
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton,
	MinimapZoomIn,
	MinimapZoomOut,
}) do node.ignoreMenu = true end

-- Cursor will ignore the host frame, but include all
-- children widgets contained inside.
for _, node in pairs({
	DropDownList1,
	DropDownList2,
}) do node.includeChildren = true end

-- Update the cursor state on visibility change.
-- Use callback to circumvent frames that set their points on show.
-- Check for point because frames can be visible but not drawn.
local function FrameShow(self)
	Callback(0.02, function()
		visibleStack[self] = self:GetPoint() and self:IsVisible() and true or nil
		ConsolePort:UpdateFrames()
	end)
end

-- Use callback to circumvent node jumping when closing multiple frames,
-- which leads to the cursor ending up in an unexpected place on re-show.
-- E.g. close 5 bags, cursor was in 1st bag, ends up in 5th bag on re-show.
local function FrameHide(self)
	Callback(0.02, function()
		hasUIFocus = nil
		visibleStack[self] = nil
		ConsolePort:UpdateFrames()
	end)
end

function ConsolePort:AddFrame(frame)
	local widget = _G[frame]
	if widget then
		widget:HookScript("OnShow", FrameShow)
		widget:HookScript("OnHide", FrameHide)
		if widget:IsVisible() and widget:GetPoint() then
			visibleStack[widget] = true
		end
		return true
	else
		self:AddFrameTracker(frame)
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
end

function ConsolePort:UpdateFrames()
	if not InCombatLockdown() then
		self:UpdateFrameTracker(self)
		if next(visibleStack) then
			if not hasUIFocus then
				hasUIFocus = true
				self.Cursor:Show()
				self:SetButtonActionsUI()
				self:UIControl()
			end
		else
			self:SetButtonActionsDefault()
		end
	end
end

-- Returns a stack of visible frames.
-- Uses UIParent when rebinding.
function ConsolePort:GetFrameStack()
	if self.rebindMode then
		local rebindStack = {}
		-- a button is waiting to be bound, allow access to the whole interface 
		if ConsolePortRebindFrame.isRebinding then
			for _, Frame in pairs({UIParent:GetChildren()}) do
				if not Frame:IsForbidden() and Frame:IsVisible() then
					rebindStack[Frame] = true
				end
			end
		end
		rebindStack[DropDownList1] = true
		rebindStack[DropDownList2] = true
		rebindStack[ConsolePortConfig] = nil
		rebindStack[ConsolePortRebindFrame] = true
		return rebindStack
	elseif IsOptionFrameOpen() then
		local fullStack = {}
		for _, Frame in pairs({UIParent:GetChildren()}) do
			if not Frame:IsForbidden() and Frame:IsVisible() then
				fullStack[Frame] = true
			end
		end
		return fullStack
	else
		return visibleStack
	end
end