---------------------------------------------------------------
-- Stack functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. See Cursor.lua.

local env, db, name = CPAPI.GetEnv(...)
---------------------------------------------------------------
local After = C_Timer.After;
local pairs, next, unravel = pairs, next, db.table.unravel;
local isLocked, isEnabled, isObstructed;
---------------------------------------------------------------
local Stack = db:Register('Stack', CPAPI.CreateEventHandler({'Frame', '$parentUIStackHandler', ConsolePort}, {
	'PLAYER_REGEN_ENABLED',
	'PLAYER_REGEN_DISABLED',
}, {
	Registry = {};
}), true);
local GetPoint, IsAnchoringRestricted, IsVisible = Stack.GetPoint, Stack.IsAnchoringRestricted, Stack.IsVisible;

---------------------------------------------------------------
local function GetFrameWidget(frame)
	if C_Widget.IsFrameWidget(frame) then
		return frame;
	elseif type(frame) == 'string' and C_Widget.IsFrameWidget(_G[frame]) then
		return _G[frame];
	end
end

---------------------------------------------------------------
-- Core state management
---------------------------------------------------------------
do local tracked, visible, buffer, hooks, watchers, obstructors = {}, {}, {}, {}, {}, {};

	---------------------------------------------------------------
	-- Visibility tracking
	---------------------------------------------------------------
	local function checkVisible(widget)
		visible[widget] = (
			not IsAnchoringRestricted(widget)
			and GetPoint(widget)
			and IsVisible(widget)
		) or nil;
	end

	local function scheduleVisibilityUpdate(widget)
		buffer[widget] = true;
		After(0, function()
			checkVisible(widget)
			buffer[widget] = nil;
			if not next(buffer) then
				Stack:UpdateFrames()
			end
		end)
	end

	-- OnShow:
	-- Use C_Timer.After to circumvent omitting frames that set their points on show.
	-- Check for point because frames can be visible but not drawn.
	local function showHook(self)
		if isEnabled and tracked[self] then
			scheduleVisibilityUpdate(self)
		end
	end

	-- OnHide:
	-- Use C_Timer.After to circumvent node jumping when closing multiple frames,
	-- which leads to the cursor ending up in an unexpected place on re-show.
	-- E.g. close 5 bags, cursor was in 1st bag, ends up in 5th bag on re-show.
	local function hideHook(self, force)
		if isEnabled and tracked[self] and (force or visible[self]) then
			scheduleVisibilityUpdate(self)
		end
	end

	---------------------------------------------------------------
	-- Hook management
	---------------------------------------------------------------
	local function addHook(widget, script, hook)
		local mt = getmetatable(widget)
		local ix = mt and mt.__index;
		local fn = type(ix) == 'table' and ix[script];
		if ( type(fn) == 'function' and not hooks[fn] ) then
			hooksecurefunc(ix, script, hook)
			hooks[fn] = true;
		elseif ( widget.HookScript ) then
			widget:HookScript(('On%s'):format(script), hook)
		end
	end

	local function setPassThrough(widget, state)
		db:RunSafe(widget.SetAttribute, widget, env.Attributes.PassThrough, state)
	end

	-- Cache default methods so that frames with unaltered
	-- metatables use hook scripts instead of a secure hook.
	hooks[CPAPI.Index(UIParent).Show] = true
	hooks[CPAPI.Index(UIParent).Hide] = true

	---------------------------------------------------------------
	-- Track / untrack a resolved widget
	---------------------------------------------------------------
	local function trackWidget(widget)
		if not tracked[widget] then
			addHook(widget, 'Show', showHook)
			addHook(widget, 'Hide', hideHook)
		end
		tracked[widget] = true;
		setPassThrough(widget, true)
		checkVisible(widget)
	end

	local function untrackWidget(widget)
		if tracked[widget] then
			visible[widget] = nil;
			tracked[widget] = nil;
			setPassThrough(widget, nil)
		end
	end

	---------------------------------------------------------------
	-- SetFrame: unified frame state management
	---------------------------------------------------------------
	-- @param frame : frame reference (string or widget)
	-- @param state : true (enabled), false (disabled), or nil (reset)
	-- @param owner : registry set key (defaults to addon name)
	function Stack:SetFrame(frame, state, owner)
		local fname;
		if type(frame) == 'string' then
			fname = frame;
		elseif C_Widget.IsFrameWidget(frame) then
			fname = frame:GetDebugName();
			-- Reject anonymous frames whose debug name contains the object pointer,
			-- since they cannot be reliably tracked across sessions.
			local ptr = tostring(frame):match('%x+$');
			if ptr and fname:lower():find(ptr:lower():gsub('^0+', ''), 1, true) then
				return
			end
		end
		if not fname then return end;

		-- Update registry
		local key = owner or name;
		self.Registry[key] = self.Registry[key] or {};
		self.Registry[key][fname] = state;

		-- Update runtime tracking
		local widget = GetFrameWidget(frame)
		if widget then
			if state then
				trackWidget(widget)
			else
				untrackWidget(widget)
			end
			return true;
		elseif state then
			watchers[fname] = true;
		end
	end

	---------------------------------------------------------------
	-- Flush: re-check visibility of a single tracked frame
	---------------------------------------------------------------
	function Stack:Flush(frame)
		if not tracked[frame] then return end;
		local wasVisible = visible[frame];
		checkVisible(frame)
		if wasVisible ~= visible[frame] then
			self:UpdateFrames()
		end
	end

	---------------------------------------------------------------
	-- LoadAddonFrames: load tracked frames for a given addon
	---------------------------------------------------------------
	function Stack:LoadAddonFrames(addonName)
		local frames = db('Stack/Registry/'..addonName)
		if ( type(frames) == 'table' ) then
			for frame, state in pairs(frames) do
				self:SetFrame(frame, state, addonName)
			end
		end
	end

	---------------------------------------------------------------
	-- Obstructor management
	---------------------------------------------------------------
	function Stack:SetCursorObstructor(idx, state)
		if idx then
			obstructors[idx] = state or nil;
			isObstructed = not not next(obstructors)
			if not isObstructed then
				self:UpdateFrames()
			else
				db.Cursor:OnStackChanged(false)
			end
		end
	end

	---------------------------------------------------------------
	-- Core toggle
	---------------------------------------------------------------
	function Stack:ToggleCore()
		isEnabled = db('UIenableCursor');
		if not isEnabled then
			db.Cursor:OnStackChanged(false)
		end
	end

	---------------------------------------------------------------
	-- ToggleGroup: enable/disable a group of frames
	---------------------------------------------------------------
	function Stack:ToggleGroup(group, enabled, skipUpdate)
		for _, frame in ipairs(group) do
			self:SetFrame(frame, not not enabled)
		end
		if not skipUpdate then
			self:UpdateFrames()
		end
	end

	---------------------------------------------------------------
	-- UpdateFrames: notify cursor of visible frame changes
	---------------------------------------------------------------
	function Stack:UpdateFrames()
		if not isLocked and not isObstructed then
			self:UpdateFrameTracker()
			RunNextFrame(function()
				if not isLocked then
					db.Cursor:OnStackChanged(not not next(visible))
				end
			end)
		end
	end

	---------------------------------------------------------------
	-- Visible frame queries
	---------------------------------------------------------------
	function Stack:GetVisibleCursorFrames()
		return unravel(visible)
	end

	---------------------------------------------------------------
	-- Frame discovery
	---------------------------------------------------------------
	-- Scans frame managers (UIPanelWindows, UISpecialFrames, etc.)
	-- and adds newly discovered frames to the stack.

	local function TryDiscoverFrame(self, frame)
		local widget = GetFrameWidget(frame)
		if tracked[widget] then return end;
		local set = self.Registry[name];
		if set and set[frame] == false then return end;
		self:SetFrame(frame, true)
		return true;
	end

	local function CheckSpecialFrames(self)
		for manager, isAssociative in pairs(env.FrameManagers) do
			if isAssociative then
				for frame in pairs(manager) do
					TryDiscoverFrame(self, frame)
				end
			else
				for _, frame in ipairs(manager) do
					TryDiscoverFrame(self, frame)
				end
			end
		end
	end

	local function CatchNewFrame(frame)
		if TryDiscoverFrame(Stack, frame) then
			Stack:UpdateFrames()
		end
	end

	local function CatchPoolFrame(frame)
		if not tracked[frame] then
			trackWidget(frame)
			Stack:UpdateFrames()
			return true;
		end
	end

	for key, method in pairs(env.FramePipelines) do
		if method then
			local object = _G[key];
			if object then
				hooksecurefunc(object, method, CatchPoolFrame)
			end
		else
			hooksecurefunc(key, CatchNewFrame)
		end
	end

	if (_G.Menu and _G.Menu.GetManager) then
		local menu = _G.Menu;
		local mgr  = menu.GetManager();
		local function CatchOpenMenu()
			local openMenu = mgr:GetOpenMenu()
			if CatchPoolFrame(openMenu) then
				for _, tag in ipairs(menu.GetOpenMenuTags()) do
					menu.ModifyMenu(tag, function(_, description)
						description:AddMenuAcquiredCallback(CatchPoolFrame)
					end)
				end
			elseif openMenu then
				Stack:Flush(openMenu)
			end
		end
		hooksecurefunc(mgr, 'OpenMenu', CatchOpenMenu)
		hooksecurefunc(mgr, 'OpenContextMenu', CatchOpenMenu)
	end

	function Stack:UpdateFrameTracker()
		if self.OnDataLoaded then return end;
		CheckSpecialFrames(self)
		for frame in pairs(watchers) do
			local widget = GetFrameWidget(frame)
			if widget then
				trackWidget(widget)
				watchers[frame] = nil;
			end
		end
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Stack:PLAYER_REGEN_ENABLED()
	After(db('UIleaveCombatDelay'), function()
		if not InCombatLockdown() then
			isLocked = false;
			self:UpdateFrames()
		end
	end)
end

function Stack:PLAYER_REGEN_DISABLED()
	db.Cursor:OnStackChanged(false)
	isLocked = true;
end

---------------------------------------------------------------
-- Initialization
---------------------------------------------------------------
db:Save('Stack/Registry', 'ConsolePortUIStack')

function Stack:OnDataLoaded()
	db:Load('Stack/Registry', 'ConsolePortUIStack')

	-- Register standalone frames
	self:ToggleGroup(env.StandaloneFrameStack, true, true)
	self:ToggleGroup(env.StaticPopupStack, db('UIenablePopups'), true)
	self:ToggleGroup(env.GroupLootStack, db('UIenableGroupLoot'), true)

	-- Toggle the stack core
	self:ToggleCore()

	-- Activate all existing frames in the registry
	for addon in pairs(self.Registry) do
		if CPAPI.IsAddOnLoaded(addon) then
			self:LoadAddonFrames(addon)
		end
	end

	self:RegisterEvent('ADDON_LOADED')
	self.ADDON_LOADED = function(stack, addonName)
		stack:LoadAddonFrames(addonName)
		stack:UpdateFrames()
	end;

	db:RegisterSafeCallback('Settings/UIenableCursor', self.ToggleCore, self)
	db:RegisterSafeCallback('Settings/UIshowOnDemand', self.ToggleCore, self)
	db:RegisterSafeCallback('Settings/UIenablePopups', self.ToggleGroup, self, env.StaticPopupStack)
	db:RegisterSafeCallback('Settings/UIenableGroupLoot', self.ToggleGroup, self, env.GroupLootStack)

	return CPAPI.BurnAfterReading;
end