local _, db = ...;
---------------------------------------------------------------
-- Get the entire database object (caution)
---------------------------------------------------------------
function ConsolePort:GetData()
	return db;
end

---------------------------------------------------------------
-- Add variable options to database
---------------------------------------------------------------
function ConsolePort:AddVariables(variables)
	db.table.merge(db.Variables, variables)
	db:TriggerEvent('OnVariablesChanged', variables)
end

---------------------------------------------------------------
-- Get all possible bindings
---------------------------------------------------------------
function ConsolePort:GetBindings()
	return db.table.spairs(db.Gamepad:GetBindings(true))
end

---------------------------------------------------------------
-- Get currently applied and validated bindings
---------------------------------------------------------------
function ConsolePort:GetCurrentBindings()
	return db.Gamepad:GetBindings()
end

---------------------------------------------------------------
-- Get corresponding binding ID for an action index
---------------------------------------------------------------
function ConsolePort:GetActionBinding(index)
	return db('Actionbar/Action/'..index)
end

---------------------------------------------------------------
-- Get unified page condition driver and current page
---------------------------------------------------------------
function ConsolePort:GetActionPageDriver()
	local pager = db.Pager;
	return pager:GetPageCondition(), pager:GetCurrentPage()
end

---------------------------------------------------------------
-- Get the button that's currently bound to a defined ID
---------------------------------------------------------------
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
-- Get a slugified texture escape string for a button combo
---------------------------------------------------------------
function ConsolePort:GetFormattedButtonCombination(key, mod)
	local device = db.Gamepad.Active;
	if device and key and mod then
		return db.Hotkeys:GetButtonSlug(device, key, mod)
	end
end

---------------------------------------------------------------
-- Get a slugified texture escape string for a binding ID
---------------------------------------------------------------
function ConsolePort:GetFormattedBindingOwner(bindingID)
	local key, mod = self:GetCurrentBindingOwner(bindingID)
	if key and mod then
		return self:GetFormattedButtonCombination(key, mod)
	end
end

---------------------------------------------------------------
-- Force focus the keyboard (nil to clear, false to disable kb)
---------------------------------------------------------------
function ConsolePort:ForceKeyboardFocus(frame)
	if ConsolePortKeyboard then
		ConsolePortKeyboard:ForceFocus(frame)
		return true;
	end
end

function ConsolePort:GetKeyboardFocus()
	if ConsolePortKeyboard then
		return ConsolePortKeyboard:GetForceFocus()
	end
end

---------------------------------------------------------------
-- Interface cursor API
---------------------------------------------------------------
local CURSOR_ADDON_NAME = 'ConsolePort_Cursor';
---------------------------------------------------------------
-- Add a new frame to the interface cursor stack
---------------------------------------------------------------
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
-- Forbid a frame from being used by the interface cursor stack
---------------------------------------------------------------
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
-- Directly mapped functions for manipulating the cursor
---------------------------------------------------------------
do local map = function(func)
		return function(_, ...)
			if db.Cursor then
				return db.Cursor[func](db.Cursor, ...)
			end
		end
	end

	ConsolePort.SetCursorNode         = map 'SetCurrentNode'
	ConsolePort.IsCursorNode          = map 'IsCurrentNode'
	ConsolePort.GetCursorNode         = map 'GetCurrentNode'
	ConsolePort.SetCursorNodeIfActive = map 'SetCurrentNodeIfActive'
end