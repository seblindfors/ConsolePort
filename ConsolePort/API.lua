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
-- Add a new frame to the interface cursor stack
---------------------------------------------------------------
function ConsolePort:AddInterfaceCursorFrame(frame)
	local object = C_Widget.IsFrameWidget(frame) and frame or _G[frame];
	if object then
		local result = db.Stack:AddFrame(object)
		db.Stack:UpdateFrames()
		return result;
	end
end