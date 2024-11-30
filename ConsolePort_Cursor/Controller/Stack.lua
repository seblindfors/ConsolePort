---------------------------------------------------------------
-- Stack functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. See Cursor.lua.

local _, env, db = ...; db = env.db;
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
local GetPoint, IsVisible = Stack.GetPoint, Stack.IsVisible;

---------------------------------------------------------------
local function GetFrameWidget(frame)
	if C_Widget.IsFrameWidget(frame) then
		return frame;
	elseif type(frame) == 'string' and C_Widget.IsFrameWidget(_G[frame]) then
		return _G[frame];
	end
end

---------------------------------------------------------------
-- Externals:
---------------------------------------------------------------
function Stack:LockCore(...)        isLocked = ...      end
function Stack:IsCoreLocked()       return isLocked     end
function Stack:IsCursorObstructed() return isObstructed end

---------------------------------------------------------------
-- Update state on visibility change.
---------------------------------------------------------------

-- Stacks: all frames, visible frames, show/hide hooks
do local frames, visible, buffer, hooks, forbidden, obstructors = {}, {}, {}, {}, {}, {};

	local function updateVisible(self)
		visible[self] = GetPoint(self) and IsVisible(self) and true or nil;
	end

	local function updateBuffer(self, flag)
		buffer[self] = flag;
	end

	local function updateOnBuffer(self)
		updateBuffer(self, true)
		After(0, function()
			updateVisible(self)
			updateBuffer(self, nil)
			if not next(buffer) then
				Stack:UpdateFrames()
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

	-- Cache default methods so that frames with unaltered
	-- metatables use hook scripts instead of a secure hook.
	hooks[getmetatable(UIParent).__index.Show] = true
	hooks[getmetatable(UIParent).__index.Hide] = true

	-- When adding a new frame:
	-- Store metatable functions for hooking show/hide scripts.
	-- Most frames will use the same standard Show/Hide, but addons 
	-- may use custom metatables, which should still work with this approach.
	function Stack:AddFrame(frame)
		local widget = GetFrameWidget(frame)
		if widget then
			if ( not forbidden[widget] ) then
				-- assert the frame isn't hooked twice
				if ( not frames[widget] ) then
					addHook(widget, 'Show', showHook)
					addHook(widget, 'Hide', hideHook)
				end

				frames[widget] = true;
				updateVisible(widget)
			end
			return true;
		else
			self:AddFrameWatcher(frame)
		end
	end

	function Stack:LoadAddonFrames(name)
		local frames = db('Stack/Registry/'..name)
		if (type(frames) == 'table') then
			for frame, enabled in pairs(frames) do
				if enabled then
					self:AddFrame(frame)
				end
			end
		end
	end

	function Stack:RemoveFrame(frame)
		local widget = GetFrameWidget(frame)
		if widget then
			visible[widget] = nil;
			frames[widget]  = nil;
		end
	end

	function Stack:ForbidFrame(frame)
		local widget = GetFrameWidget(frame)
		if frames[widget] then
			forbidden[widget] = true;
			self:RemoveFrame(widget)
		end
	end

	function Stack:UnforbidFrame(frame)
		if forbidden[frame] then
			self:AddFrame(frame)
			forbidden[frame] = nil
		end
	end

	function Stack:SetCursorObstructor(idx, state)
		if idx then
			if not state then state = nil end
			obstructors[idx] = state;
			isObstructed = ((next(obstructors) and true) or false)
			if not isObstructed then
				self:UpdateFrames()
			else
				db.Cursor:OnStackChanged(false)
			end
		end
	end

	function Stack:ToggleCore()
		isEnabled = db('UIenableCursor');
		if not isEnabled then
			db.Cursor:OnStackChanged(false)
		end
	end

	function Stack:UpdateFrames(updateCursor)
		if not isLocked and not isObstructed then
			self:UpdateFrameTracker()
			RunNextFrame(function()
				if not isLocked then
					db.Cursor:OnStackChanged(not not next(visible))
				end
			end)
		end
	end

	-- Returns a stack of visible frames.
	function Stack:IterateVisibleCursorFrames()
		return pairs(visible)
	end

	function Stack:GetVisibleCursorFrames()
		return unravel(visible)
	end

	function Stack:IsFrameVisibleToCursor(frame, ...)
		if frame then
			return visible[frame] or false, self:IsFrameVisibleToCursor(...)
		end
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Stack:PLAYER_REGEN_ENABLED()
	After(db('UIleaveCombatDelay'), function()
		if not InCombatLockdown() then
			self:LockCore(false)
			self:UpdateFrames()
		end
	end)
end

function Stack:PLAYER_REGEN_DISABLED()
	db.Cursor:OnStackChanged(false)
	self:LockCore(true)
end

---------------------------------------------------------------
-- Stack management over sessions
---------------------------------------------------------------
db:Save('Stack/Registry', 'ConsolePortUIStack')

function Stack:GetRegistrySet(name)
	self.Registry[name] = self.Registry[name] or {};
	return self.Registry[name];
end

function Stack:TryRegisterFrame(set, name, state)
	if not name then return end

	local stack = self:GetRegistrySet(set)
	if (stack[name] == nil) then
		stack[name] = (state == nil) or state;
	elseif (state ~= nil) then
		stack[name] = state;
	end
	return stack[name];
end

function Stack:TryUnregisterFrame(set, name, wipe)
	if not name then return end

	local stack = self:GetRegistrySet(set)
	if (stack[name] ~= nil) then
		if wipe then
			stack[name] = nil;
		else
			stack[name] = false;
		end
		return true;
	end
end

function Stack:OnDataLoaded()
	db:Load('Stack/Registry', 'ConsolePortUIStack')

	-- Load standalone frame stack
	for i, frame in ipairs(env.StandaloneFrameStack) do
		self:TryRegisterFrame(_, frame)
	end

	-- Toggle the stack core
	self:ToggleCore()

	-- Load all existing frames in the registry
	for addon in pairs(self.Registry) do
		if CPAPI.IsAddOnLoaded(addon) then
			self:LoadAddonFrames(addon)
		end
	end

	self.OnDataLoaded = nil;
	self:RegisterEvent('ADDON_LOADED')
	self.ADDON_LOADED = function(self, name)
		self:LoadAddonFrames(name)
		self:UpdateFrames()
	end;

	db:RegisterSafeCallback('Settings/UIenableCursor', self.ToggleCore, self)
	db:RegisterSafeCallback('Settings/UIshowOnDemand', self.ToggleCore, self)
end

---------------------------------------------------------------
-- Frame watching
---------------------------------------------------------------
-- Used to track and bind additional frames to the UI cursor.
-- Necessary since all frames do not exist when the game loads.
-- Automatically adds all special frames and managed panels.

do  local specialFrames, poolFrames, watchers = {}, {}, {};

	local function TryAddSpecialFrame(self, frame)
		if specialFrames[frame] then return end;
		-- If the frame is not in the stack, try to add it.
		if self:TryRegisterFrame(_, frame) then
			if self:AddFrame(frame) then
				specialFrames[frame] = true;
			end
		-- The frame exists, but should not be added.
		elseif GetFrameWidget(frame) then
			specialFrames[frame] = true;
		end
	end

	local function CheckSpecialFrames(self)
		for manager, isAssociative in pairs(env.FrameManagers) do
			if isAssociative then
				for frame in pairs(manager) do
					TryAddSpecialFrame(self, frame)
				end
			else
				for _, frame in ipairs(manager) do
					TryAddSpecialFrame(self, frame)
				end
			end
		end
	end

	local function CatchNewFrame(frame)
		local widget = GetFrameWidget(frame)
		if widget and not Stack:IsFrameVisibleToCursor(widget) then
			if Stack:TryRegisterFrame(_, widget:GetName()) then
				Stack:AddFrame(widget)
				Stack:UpdateFrames()
			end
		end
	end

	local function CatchPoolFrame(frame)
		if not Stack:IsFrameVisibleToCursor(frame) then
			if not poolFrames[frame] then
				Stack:AddFrame(frame)
				Stack:UpdateFrames()
				poolFrames[frame] = true;
				return true;
			end
		end
	end

	for name, method in pairs(env.FramePipelines) do
		if type(method) == 'string' then
			local object = _G[name];
			if object then
				hooksecurefunc(object, method, CatchPoolFrame)
			end
		elseif type(method) == 'boolean' then
			hooksecurefunc(name, CatchNewFrame)
		end
	end

	if (_G.Menu and _G.Menu.GetManager) then
		local menu = _G.Menu; -- Blizzard's menu manager
		local mgr  = menu.GetManager();
		local function CatchOpenMenu()
			if CatchPoolFrame(mgr:GetOpenMenu()) then
				-- EXPERIMENTAL: catch submenus, if the menu is tagged
				for _, tag in ipairs(menu.GetOpenMenuTags()) do
					menu.ModifyMenu(tag, function(_, description)
						description:AddMenuAcquiredCallback(CatchPoolFrame)
					end)
				end
			end
		end
		hooksecurefunc(mgr, 'OpenMenu', CatchOpenMenu)
		hooksecurefunc(mgr, 'OpenContextMenu', CatchOpenMenu)
	end

	function Stack:UpdateFrameTracker()
		if self.OnDataLoaded then return end;
		CheckSpecialFrames(self)
		for frame in pairs(watchers) do
			if self:AddFrame(frame) then
				watchers[frame] = nil;
			end
		end
	end

	function Stack:AddFrameWatcher(frame)
		watchers[frame] = true;
	end
end