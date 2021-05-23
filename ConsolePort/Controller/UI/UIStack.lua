---------------------------------------------------------------
-- Stack functionality for UI cursor
---------------------------------------------------------------
-- Keeps a stack of frames to control with the D-pad when they
-- are visible on screen. See View\UICursor.lua.

local _, db = ...;
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
}));

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
			self:AddFrameWatcher(frame)
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
		local showOnDemand = db('UIshowOnDemand')
		isEnabled = db('UIenableCursor') and not showOnDemand;
		if not isEnabled and not showOnDemand then
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

function Stack:HideFrame(frame, ignoreAlpha)
	assert(frame, 'Usage: Stack:HideFrame(frame)')
	frame:SetSize(0, 0)
	frame:EnableMouse(false)
	frame:EnableKeyboard(false)
	frame:SetAlpha(ignoreAlpha and frame:GetAlpha() or 0)
	frame:ClearAllPoints()
	self:ForbidFrame(frame)
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
do db:Save('Stack/Registry', 'ConsolePortUIStack')

	-- NOTE: this function generates the default set which should
	-- contain all the frames that are not caught by managers,
	-- and exist within the FrameXML code in some shape or form. 
	local function GenerateDefaultSet(self)
		-- Special handling for containers
		for i=1, NUM_CONTAINER_FRAMES do
			self:TryRegisterFrame(_, 'ContainerFrame'..i, true)
		end
		for i=1, STATICPOPUP_NUMDIALOGS do
			self:TryRegisterFrame(_, 'StaticPopup'..i, true)
		end
		for i=1, NUM_GROUP_LOOT_FRAMES do
			self:TryRegisterFrame(_, 'GroupLootFrame'..i, true)
		end
		for i, frame in ipairs({
			---------------------------------
			'CovenantPreviewFrame';
			'LFGDungeonReadyPopup';
			'OpenMailFrame';
			'PetBattleFrame';
			'StackSplitFrame';
			---------------------------------
		}) do self:TryRegisterFrame(_, frame, true) end
	end

	function Stack:GetRegistrySet(name)
		self.Registry[name] = self.Registry[name] or {};
		return self.Registry[name];
	end

	function Stack:TryRegisterFrame(set, name, state)
		if not name then return end

		local stack = self:GetRegistrySet(set)
		if (stack[name] == nil) then
			stack[name] = (state == nil and true) or state;
			return true;
		end
	end

	function Stack:TryRemoveFrame(set, name)
		if not name then return end

		local stack = self:GetRegistrySet(set)
		if (stack[name] ~= nil) then
			stack[name] = nil;
			return true;
		end
	end

	function Stack:OnDataLoaded()
		db:Load('Stack/Registry', 'ConsolePortUIStack')
		GenerateDefaultSet(self)
		self:ToggleCore()

		-- Load all existing frames in the registry
		for addon in pairs(self.Registry) do
			if IsAddOnLoaded(addon) then
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

	local function CatchNewFrame(frame)
		if not Stack:IsFrameVisibleToCursor(frame) then
			if Stack:TryRegisterFrame(_, frame:GetName(), true) then
				Stack:AddFrame(frame)
				Stack:UpdateFrames()
			end
		end
	end

	hooksecurefunc('ShowUIPanel', CatchNewFrame)
	hooksecurefunc('StaticPopupSpecial_Show', CatchNewFrame)
end

---------------------------------------------------------------
-- Frame watching
---------------------------------------------------------------
-- Used to track and bind additional frames to the UI cursor.
-- Necessary since all frames do not exist when the game loads.
-- Automatically adds all special frames and managed panels.

do  local managers = {[UIPanelWindows] = true, [UISpecialFrames] = false, [UIMenus] = false};
	local specialFrames, watchers = {}, {}

	local function TryAddSpecialFrame(self, frame)
		if not specialFrames[frame] then
			-- low-prio todo: save some memory here by not cloning
			-- the frame into the watchers table. 
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