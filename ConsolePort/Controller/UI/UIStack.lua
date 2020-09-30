local _, db = ...;
---------------------------------------------------------------
-- Stack functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. See View\UICursor.lua.
---------------------------------------------------------------
local Stack = db:Register('Stack', CPAPI.CreateEventHandler({'Frame', '$parentUIStackHandler', ConsolePort}, {
	'PLAYER_REGEN_ENABLED',
	'PLAYER_REGEN_DISABLED',
}, {
	Registry = {};
}));

---------------------------------------------------------------
-- General functions
local After = C_Timer.After;
local pairs, next, unravel = pairs, next, db.table.unravel;
-- Boolean checks (all default nil)
local isLocked, isEnabled, isObstructed;

---------------------------------------------------------------
-- Externals:
---------------------------------------------------------------
function Stack:LockCore(...)      isLocked = ...      end
function Stack:IsCoreLocked()     return isLocked     end
function Stack:IsCursorObstructed() return isObstructed end

---------------------------------------------------------------
-- Update state on visibility change.
---------------------------------------------------------------

-- Stacks: all frames, visible frames, show/hide hooks
do local frames, visible, buffer, hooks, forbidden, obstructors = {}, {}, {}, {}, {}, {};

	local function updateVisible(self)
		visible[self] = self:GetPoint() and self:IsVisible() and true or nil;
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

	local function addHook(widget, script, hook, name)
		local mt = getmetatable(widget)
		local ix = mt and mt.__index
		local fn = ix and ix[script]
		if ( type(fn) == 'function' and not hooks[fn] ) then
			hooksecurefunc(ix, script, hook)
			hooks[fn] = true
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
		local widget = (type(frame) == 'string' and _G[frame]) or (type(frame) == 'table' and frame)
		local name = (type(frame) == 'string' and frame or type(frame) == 'table' and frame:GetName())
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

	function Stack:LoadAddonFrames(name)
		local frames = db('Stack/Registry/'..name)
		if (type(frames) == 'table') then
			for k, v in pairs(frames) do
				if (type(k) == 'string') then
					self:AddFrame(k)
				elseif (type(v) == 'string') then
					self:AddFrame(v)
				end
			end
		end
	end

	function Stack:RemoveFrame(frame)
		if frame then
			visible[frame] = nil;
			frames[frame]  = nil;
		end
	end

	function Stack:ForbidFrame(frame)
		if frames[frame] then
			forbidden[frame] = true;
			self:RemoveFrame(frame)
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
			end
		end
	end

	function Stack:ToggleCore()
		isEnabled = not db('UIdisableCursor')
		if not isEnabled then
			db('Cursor'):SetEnabled(false)
		end
	end

	function Stack:UpdateFrames(updateCursor)
		if not isLocked then
			self:UpdateFrameTracker()
			db('Cursor'):SetEnabled(next(visible))
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
	db('Cursor'):SetEnabled(false)
	self:LockCore(true)
end

---------------------------------------------------------------
-- Stack management over sessions
---------------------------------------------------------------
do 
	db:Save('Stack/Registry', 'ConsolePortUIStack')

	function Stack:GetFrameStack(name)
		self.Registry[name] = self.Registry[name] or {};
		return self.Registry[name];
	end

	function Stack:GenerateDefaultRegistry()
		local default = self:GetFrameStack(_)
		-- Special handling for containers
		for i=1, NUM_CONTAINER_FRAMES do
			default['ContainerFrame'..i] = true;
		end
		return default;
	end

	function Stack:AddToDefaultRegistry(name)
		if name then
			local default = self:GetFrameStack(_)
			if (default[name] == nil) then
				default[name] = true;
			end
			return default[name];
		end
	end

	hooksecurefunc('RegisterUIPanel', function(frame)
		local addedAndEnabled = Stack:AddToDefaultRegistry(frame:GetName())
		if addedAndEnabled then
			Stack:AddFrame(frame)
		end
	end)

	function Stack:TryRegisterFrame(register, name, state)
		local stack = self:GetFrameStack(register)
		if (stack[name] == nil) then
			stack[name] = (state == nil and true) or state;
			return true;
		end
	end

	function Stack:OnDataLoaded()
		db:Load('Stack/Registry', 'ConsolePortUIStack')
		self:GenerateDefaultRegistry()
		self:ToggleCore()
		self:LoadAddonFrames(_)
		self:RegisterEvent('ADDON_LOADED')
		self.ADDON_LOADED = function(self, name)
			self:LoadAddonFrames(name)
			self:UpdateFrames()
		end;
	end
end

---------------------------------------------------------------
-- Frame tracking
---------------------------------------------------------------
-- Used to track and bind additional frames to the UI cursor.
-- Necessary since all frames do not exist on ADDON_LOADED.
-- Automatically adds all special frames, i.e. closed with ESC.

do  local managers = {[UIPanelWindows] = true, [UISpecialFrames] = false, [UIMenus] = false};
	local specialFrames, frameTrackers = {}, {}

	local function TryAddSpecialFrame(self, frame)
		if not specialFrames[frame] then
			if self:AddFrame(frame) then
				specialFrames[frame] = true;
			end
		end
	end

	local function CheckSpecialFrames(self)
		for manager, isAssociative in pairs(managers) do
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

	function Stack:UpdateFrameTracker()
		CheckSpecialFrames(self)
		for frame in pairs(frameTrackers) do
			if self:AddFrame(frame) then
				frameTrackers[frame] = nil;
			end
		end
	end

	function Stack:AddFrameTracker(frame)
		frameTrackers[frame] = true;
	end
end