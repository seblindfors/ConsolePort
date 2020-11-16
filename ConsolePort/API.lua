local _, db = ...;

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
	if device then
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