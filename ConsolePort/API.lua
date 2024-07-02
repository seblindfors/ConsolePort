local _, db = ...;
---------------------------------------------------------------
-- @brief Get the entire database object (caution)
-- @return db: database object (table)
function ConsolePort:GetData()
	return db;
end

---------------------------------------------------------------
-- @brief Add variable options to database
-- @param variables: table {
--    [variableID] = {
--        @param 1 = datapoint (table) see Data.lua for examples
--        @param name = display name (string)
--        @param desc = description (string)
--        @param note = additional notes (string)
--        @param advd = advanced option flag (bool)
--        @param hide = hide option flag (bool)
--    }, ...
-- }
function ConsolePort:AddVariables(variables)
	db.table.merge(db.Variables, variables)
	db:TriggerEvent('OnVariablesChanged', variables)
end

---------------------------------------------------------------
-- @brief Get all possible bindings
-- @return table {
--    [buttonID] = {
--        [modifier] = bindingID, ...
--    }, ...
-- }
function ConsolePort:GetBindings()
	return db.table.spairs(db.Gamepad:GetBindings(true))
end

---------------------------------------------------------------
-- @brief Get currently applied and validated bindings
-- @return table {
--    [buttonID] = {
--        [modifier] = bindingID, ...
--    }, ...
-- }
function ConsolePort:GetCurrentBindings()
	return db.Gamepad:GetBindings()
end

---------------------------------------------------------------
-- @brief Get corresponding binding ID for an action index
-- @param index: action index (number)
-- @return bindingID: binding ID (string)
function ConsolePort:GetActionBinding(index)
	return db('Actionbar/Action/'..index)
end

---------------------------------------------------------------
-- @brief Get unified page condition driver and current page
-- @return condition: condition driver (string)
-- @return page: current page (number)
function ConsolePort:GetActionPageDriver()
	local pager = db.Pager;
	return pager:GetPageCondition(), pager:GetCurrentPage()
end

---------------------------------------------------------------
-- @brief Get the button that's currently bound to a defined ID
-- @param bindingID: binding ID (string)
-- @return key: button ID (string)
-- @return mod: modifier (string)
function ConsolePort:GetCurrentBindingOwner(bindingID)
	for key, set in pairs(self:GetCurrentBindings()) do
		for mod, binding in pairs(set) do
			if (bindingID == binding) then
				return key, mod;
			end
		end
	end
end

---------------------------------------------------------------
-- @brief Get a slugified texture escape string for a button combo
-- @param key: button ID (string)
-- @param mod: modifier (string)
-- @return slug: texture escape string (string)
function ConsolePort:GetFormattedButtonCombination(key, mod)
	local device = db.Gamepad.Active;
	if device and key and mod then
		return db.Hotkeys:GetButtonSlug(device, key, mod)
	end
end

---------------------------------------------------------------
-- @brief Get a slugified texture escape string for a binding ID
-- @param bindingID: binding ID (string)
-- @return slug: texture escape string (string)
function ConsolePort:GetFormattedBindingOwner(bindingID)
	local key, mod = self:GetCurrentBindingOwner(bindingID)
	if key and mod then
		return self:GetFormattedButtonCombination(key, mod)
	end
end

---------------------------------------------------------------
-- @brief Force focus the keyboard (nil to clear, false to disable kb)
-- @param frame: frame to focus, false to disable (frame or bool)
function ConsolePort:ForceKeyboardFocus(frame)
	if ConsolePortKeyboard then
		ConsolePortKeyboard:ForceFocus(frame)
		return true;
	end
end

---------------------------------------------------------------
-- @brief Get the current keyboard focus
-- @return frame: frame that has focus (frame)
function ConsolePort:GetKeyboardFocus()
	if ConsolePortKeyboard then
		return ConsolePortKeyboard:GetForceFocus()
	end
end

---------------------------------------------------------------
-- Interface cursor API
---------------------------------------------------------------
-- The interface cursor has three major components:
--  Cursor: The cursor object itself, which is a frame
--  Stack: The stack of frames that the cursor can interact with
--  Hooks: The hooking process that allows custom interactions
---------------------------------------------------------------
local CURSOR_ADDON_NAME = 'ConsolePort_Cursor';

---------------------------------------------------------------
-- @brief Add a new frame to the interface cursor stack
-- @param frame: frame to add (string or frame)
-- @return success: true if frame was added
function ConsolePort:AddInterfaceCursorFrame(frame)
	local object = C_Widget.IsFrameWidget(frame) and frame or _G[frame];
	if object then
		EventUtil.ContinueOnAddOnLoaded(CURSOR_ADDON_NAME, function()
			if db.Stack:AddFrame(object) then
				db.Stack:UpdateFrames()
			end
		end)
		return true;
	end
end

---------------------------------------------------------------
-- @brief Remove a frame from the interface cursor stack
-- @param frame: frame to remove (string or frame)
-- @return success: true if frame was removed
function ConsolePort:RemoveInterfaceCursorFrame(frame)
	local object = C_Widget.IsFrameWidget(frame) and frame or _G[frame];
	if object then
		EventUtil.ContinueOnAddOnLoaded(CURSOR_ADDON_NAME, function()
			db.Stack:RemoveFrame(object)
		end)
		return true;
	end
end


---------------------------------------------------------------
-- @brief Forbid a frame from being used by the interface cursor stack
-- @param frame: frame to forbid (string or frame)
-- @return success: true if frame was forbidden
function ConsolePort:ForbidInterfaceCursorFrame(frame)
	local object = C_Widget.IsFrameWidget(frame) and frame or _G[frame];
	if object then
		EventUtil.ContinueOnAddOnLoaded(CURSOR_ADDON_NAME, function()
			db.Stack:ForbidFrame(object)
		end)
		return true;
	end
end

---------------------------------------------------------------
-- @brief Notify the hooks process that a click event occurred
-- @param script: script name (string)
-- @param node: node that was clicked (frame)
-- @return success: true if node click was processed somehow
function ConsolePort:ProcessInterfaceClickEvent(...)
	if db.Hooks then
		return db.Hooks:ProcessInterfaceClickEvent(...)
	end
end

---------------------------------------------------------------
-- @brief Set an obstructor for the interface cursor
-- @param obstructor: obstructor frame (frame)
-- @param state: obstructor state (bool)
function ConsolePort:SetCursorObstructor(obstructor, state)
	if db.Stack then
		if not state then state = nil end;
		db.Stack:SetCursorObstructor(obstructor, state)
	end
end

---------------------------------------------------------------
-- Directly mapped functions for manipulating the cursor
---------------------------------------------------------------
do local map = function(func)
		return function(_, ...)
			if db.Cursor then
				return db.Cursor[func](db.Cursor, ...)
			end
		end
	end

	-----------------------------------------------------------
	-- @brief Set the cursor to a node
	-- @param node: node to set (frame)
	-- @param assertNotMouse: assert that node is not mouseovered (bool)
	-- @param forceEnable: force enable cursor (bool)
	-- @return success: true if cursor was set to the node (bool)
	ConsolePort.SetCursorNode         = map 'SetCurrentNode'
	-----------------------------------------------------------
	-- @brief Check if cursor is currently on a node
	-- @param node: node to check (frame)
	-- @return isCurrent: true if node is current (bool)
	ConsolePort.IsCursorNode          = map 'IsCurrentNode'
	-----------------------------------------------------------
	-- @brief Get the current node
	-- @return node: current node (frame)
	ConsolePort.GetCursorNode         = map 'GetCurrentNode'
	-----------------------------------------------------------
	-- @brief Set the cursor to a node if the cursor is active
	-- @param node: node to set (frame)
	-- @param assertNotMouse: assert that node is not mouseovered (bool)
	-- @return success: true if cursor is active and node was set (bool)
	ConsolePort.SetCursorNodeIfActive = map 'SetCurrentNodeIfActive'
	-----------------------------------------------------------
	-- @brief Replace the script of a node by function pointer
	-- @param scriptType: script type (string)
	-- @param original: original script (function)
	-- @param replacement: replacement script (function)
	ConsolePort.ReplaceCursorScript   = map 'ReplaceScript'
	-----------------------------------------------------------
	-- @brief Check if the cursor is currently active
	-- @return isActive: true if cursor is active (bool)
	ConsolePort.IsCursorActive        = map 'IsShown'
end