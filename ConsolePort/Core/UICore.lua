---------------------------------------------------------------
-- UICore.lua: Core functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. Stack is processed in CursorUI.lua.

local hasUIFocus = false

-- Frame stacks
local visibleStack = {}
local cursorStack = {}

local InCombatLockdown = InCombatLockdown
local tinsert = tinsert
local pairs = pairs
local wipe = wipe

-- Upvalue because of explicit use in hook scripts
local ConsolePort = ConsolePort

-- Cursor will choose these nodes above all else,
-- providing smart snap behaviour when searching
-- for the most appropriate node to focus.
local hasPriority = {
	ContainerFrame1Item16,
	GossipTitleButton1,
	HonorFrameSoloQueueButton,
	LFDQueueFrameFindGroupButton,
	MerchantItem1ItemButton,
	MerchantRepairAllButton,
	PaperDollSidebarTab3,
	QuestFrameAcceptButton,
	QuestFrameCompleteButton,
	QuestFrameCompleteQuestButton,
	QuestTitleButton1,
	QuestMapFrame.DetailsFrame.BackButton,
	QuestScrollFrame.ViewAll,
}

-- Cursor will ignore these nodes completely,
-- since they are pointless or annoying to deal with.
local ignoreNode = {
	LootFrameCloseButton,
	WorldMapTitleButton,
	WorldMapButton,
}

for _, node in pairs(hasPriority) do node.hasPriority = true end
for _, node in pairs(ignoreNode) do node.ignoreNode = true end

local function FrameShow(self)
	ConsolePort:UpdateFrames()
end

local function FrameHide(self)
	hasUIFocus = nil
	ConsolePort:UpdateFrames()
end

function ConsolePort:AddFrame(frame)
	local widget = _G[frame]
	if widget then
		if not cursorStack[widget] then
			widget:HookScript("OnShow", FrameShow)
			widget:HookScript("OnHide", FrameHide)
			cursorStack[widget] = true
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
		local defaultActions = true
		self:UpdateFrameTracker(self)
		for frame in pairs(cursorStack) do
			if 	frame:IsVisible() and
				frame:GetPoint() then
				defaultActions = false
				if not hasUIFocus then
					hasUIFocus = true
					self.Cursor:Show()
					self:SetButtonActionsUI()
					self:UIControl()
				end
				break
			end
		end
		if defaultActions then
			self:SetButtonActionsDefault()
		end
	end
end

function ConsolePort:HasUIFocus()
	return hasUIFocus
end

function ConsolePort:SetUIFocus(focus)
	hasUIFocus = focus
end

function ConsolePort:GetFrameStack()
	wipe(visibleStack)
	if ConsolePortRebindFrame:IsVisible() then
		if ConsolePortRebindFrame.isRebinding then
			for _, Frame in pairs({UIParent:GetChildren()}) do
				if not Frame:IsForbidden() and
					Frame:IsVisible() and
					Frame ~= InterfaceOptionsFrame then
					tinsert(visibleStack, Frame)
				end
			end
		end
		tinsert(visibleStack, DropDownList1)
		tinsert(visibleStack, DropDownList2)
		tinsert(visibleStack, ConsolePortRebindFrame)
	else
		for frame in pairs(cursorStack) do
			if 	frame:IsVisible() and 
				frame:GetPoint() then
				tinsert(visibleStack, frame)
			end
		end
	end
	return visibleStack
end