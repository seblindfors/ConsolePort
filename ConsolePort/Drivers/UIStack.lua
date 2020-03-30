---------------------------------------------------------------
-- UIStack.lua: Core functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. See Cursors\Interface.lua.
---------------------------------------------------------------
local _, db = ...
---------------------------------------------------------------
		-- Upvalue main frame due to frequent calls
local 	Core, 
		-- General functions
		After, SetHook,
		-- Table functions
		pairs, next, unravel,
		-- Stacks: all frames, visible frames, show/hide hooks
		frames, visible, buffer, hooks, forbidden, obstructors,
		-- Boolean checks (default nil)
		hasUIFocus, isLocked, isEnabled, isObstructed =
		-------------------------------------
		ConsolePort,
		C_Timer.After, hooksecurefunc,
		pairs, next, db.table.unravel, {}, {}, {}, {}, {}, {}
---------------------------------------------------------------
-- Externals:
---------------------------------------------------------------
function Core:HasUIFocus()         return hasUIFocus   end
function Core:SetUIFocus(...)      hasUIFocus = ...    end
function Core:LockUICore(...)      isLocked = ...      end
function Core:IsUICoreLocked()     return isLocked     end
function Core:IsCursorObstructed() return isObstructed end

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
		(QuestMapFrame and QuestMapFrame.DetailsFrame.BackButton),
	},
	ignoreNode = {
		LootFrameCloseButton,
		SpellFlyout,
		WorldMapTitleButton,
	},
	ignoreMenu = {
		(ObjectiveTrackerFrame and ObjectiveTrackerFrame.HeaderMenu.MinimizeButton),
		MinimapZoomIn,
		MinimapZoomOut,
	},
	ignoreScroll = {
		-- nothing here
	},
	includeChildren = {
		DropDownList1,
		DropDownList2,
	},
	-----------------------------------------------------------
}) do for _, node in pairs(nodes) do node[flag] = true end end
---------------------------------------------------------------

---------------------------------------------------------------
-- Update the cursor state on visibility change.
---------------------------------------------------------------
local function updateVisible(self)
	visible[self] = self:GetPoint() and self:IsVisible() and true or nil
end

local function updateBuffer(self, flag)
	buffer[self] = flag
end

local function updateOnBuffer(self)
	updateBuffer(self, true)
	After(0.02, function()
		updateVisible(self)
		updateBuffer(self, nil)
		if not next(buffer) then
			Core:UpdateFrames()
		end
	end)
end

-- OnShow:
-- Use C_Timer.After to circumvent omitting frames that set their points on show.
-- Check for point because frames can be visible but not drawn.
local function showHook(self)
	if isEnabled and frames[self] then
		updateOnBuffer(self)
	end
end

-- OnHide:
-- Use C_Timer.After to circumvent node jumping when closing multiple frames,
-- which leads to the cursor ending up in an unexpected place on re-show.
-- E.g. close 5 bags, cursor was in 1st bag, ends up in 5th bag on re-show.
local function hideHook(self, force)
	if isEnabled and frames[self] and (force or visible[self]) then
		updateOnBuffer(self)
	end
end

local function addHook(widget, script, hook, name)
	local mt = getmetatable(widget)
	local ix = mt and mt.__index
	local fn = ix and ix[script]
	if ( type(fn) == 'function' and not hooks[fn] ) then
		SetHook(ix, script, hook)
		hooks[fn] = true
	elseif ( widget.HookScript ) then
		widget:HookScript(('On%s'):format(script), hook)
	else
		print(db('TUTORIAL/ERRORS/CORRUPTFRAME'):format(name))
	end
end

-- Cache default methods so that frames with unaltered
-- metatables use hook scripts instead of a secure hook.
hooks[getmetatable(UIParent).__index.Show] = true
hooks[getmetatable(UIParent).__index.Hide] = true

-- When adding a new frame:
-- Store metatable functions for hooking show/hide scripts.
-- Most frames will use the same standard Show/Hide, but addons 
-- may use custom metatables, which should still work with this approach.
function Core:AddFrame(frame)
	local widget = (type(frame) == "string" and _G[frame]) or (type(frame) == "table" and frame)
	local name = (type(frame) == "string" and frame or type(frame) == "table" and frame:GetName())
	if C_Widget.IsFrameWidget(widget) then
		if ( not forbidden[widget] ) then
			-- assert the frame isn't hooked twice
			if ( not frames[widget] ) then
				addHook(widget, 'Show', showHook, name)
				addHook(widget, 'Hide', hideHook, name)
			end

			frames[widget] = true
			if widget:IsVisible() and widget:GetPoint() then
				visible[widget] = true
			end
		end
		return true
	else
		self:AddFrameTracker(frame)
	end
end

function Core:LoadAddonFrames(name)
	local frames = self:GetData(('UIStack/%s'):format(name))
	if frames then
		for i, frame in pairs(frames) do
			self:AddFrame(frame)
		end
	end
end

function Core:RemoveFrame(frame)
	if frame then
		visible[frame] = nil
		frames[frame] = nil
	end
end

function Core:ForbidFrame(frame)
	if frames[frame] then
		forbidden[frame] = true
		self:RemoveFrame(frame)
	end
end

function Core:UnforbidFrame(frame)
	if forbidden[frame] then
		self:AddFrame(frame)
		forbidden[frame] = nil
	end
end

function Core:SetCursorObstructor(idx, state)
	if idx then
		if not state then state = nil end
		obstructors[idx] = state
		isObstructed = ((next(obstructors) and true) or false)
		if isObstructed then
			hasUIFocus = false
		else
			self:UpdateFrames()
		end
	end
end

function Core:ToggleUICore()
	isEnabled = not db('disableUI')
	if not isEnabled then
		self:UIOverrideButtons(false)
	end
end

function Core:UpdateFrames()
	if not isLocked then
		self:UpdateFrameTracker()
		if next(visible) then
			hasUIFocus = hasUIFocus or self:UIOverrideButtons(self:UIControl())
			return
		end
		hasUIFocus = self:UIOverrideButtons(false)
	end
end

-- Returns a stack of visible frames.
function Core:IterateVisibleCursorFrames()
	return pairs(visible)
end

function Core:GetVisibleCursorFrames()
	return unravel(visible)
end

function Core:IsFrameVisibleToCursor(...)
	local returns = {}
	for i, frame in ipairs({...}) do
		returns[i] = visible[frame] or false
	end
	return unpack(returns)
end