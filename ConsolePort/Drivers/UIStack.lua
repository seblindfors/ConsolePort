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
		After, SetHook, IsLoaded,
		-- Table functions
		pairs, next, unravel,
		-- Stacks: all frames, visible frames, show/hide hooks
		frames, visible, hooks, forbidden, obstructors,
		-- Boolean checks (default nil)
		hasUIFocus, isLocked, isEnabled, updateQueued, isObstructed =
		-------------------------------------
		ConsolePort,
		C_Timer.After, hooksecurefunc, IsAddOnLoaded,
		pairs, next, db.table.unravel, {}, {}, {}, {}, {}
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

-- Update the cursor state on visibility change.
-- Use After to circumvent omitting frames that set their points on show.
-- Check for point because frames can be visible but not drawn.
local function updateVisible(self)
	visible[self] = self:GetPoint() and self:IsVisible() and true or nil
end

local function showHook(self)
	if isEnabled and frames[self] then
		updateQueued = true
		After(0.02, function()
			updateVisible(self)
			if updateQueued then
				updateQueued = false
				Core:UpdateFrames()
			end
		end)
	end
end

-- Use C_Timer.After to circumvent node jumping when closing multiple frames,
-- which leads to the cursor ending up in an unexpected place on re-show.
-- E.g. close 5 bags, cursor was in 1st bag, ends up in 5th bag on re-show.
local function hideHook(self, explicit)
	if isEnabled and frames[self] then
		After(0.02, function()
			if explicit or visible[self] then
				hasUIFocus = nil
				updateVisible(self)
				Core:UpdateFrames()
			end
		end)
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
	if widget then
		if ( not forbidden[widget] ) then
			-- assert the frame isn't hooked twice
			if ( not frames[widget] ) then
				local mt = getmetatable(widget).__index

				if not hooks[mt.Show] then
					SetHook(mt, "Show", showHook)
					hooks[mt.Show] = true
				else
					widget:HookScript("OnShow", showHook)
				end

				if not hooks[mt.Hide] then
					SetHook(mt, "Hide", hideHook)
					hooks[mt.Hide] = true
				else
					widget:HookScript("OnHide", hideHook)
				end
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
	isEnabled = not db.Settings.disableUI
	if not isEnabled then
		self:SetButtonOverride(false)
	end
end

function Core:UpdateFrames()
	if not isLocked then
		self:UpdateFrameTracker()
		if next(visible) then
			if not hasUIFocus then
				hasUIFocus = true
				if not self:UIControl() then
					-- there are visible frames, but no eligible nodes -> flag frames as hidden.
					for frame in pairs(visible) do
						hideHook(frame, true)
					end
				else
					self:SetButtonOverride(true)
				end
			end
		else
			self:SetButtonOverride(false)
		end
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