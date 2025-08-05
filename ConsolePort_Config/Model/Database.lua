local _, _, env, db, name = CPAPI.LinkEnv(...);
---------------------------------------------------------------
LibStub('RelaTable')(name, env, false);
---------------------------------------------------------------
-- Binding helpers
---------------------------------------------------------------
env.BindingInfo, env.BindingInfoMixin = db.Loadout, db.LoadoutMixin;

function env:SetTempBinding(...)
	if SetBinding(...) then
		self:TriggerEvent('OnBindingChanged', ...)
		return true;
	end
	local combination, bindingID = ...;
	---@see https://github.com/Stanzilla/WoWUIBugs/issues/752
	CPAPI.Log('Failed to set binding %s to %s. Report this bug to Blizzard.',
		tostring(combination),
		GetBindingName(tostring(bindingID)))
end

function env:SetBinding(keyChord, bindingID, ...)
	if bindingID and not db('bindingOverlapEnable') then
		self:ClearBindingsForID(bindingID)
	end
	if self:SetTempBinding(keyChord, bindingID, ...) then
		SaveBindings(GetCurrentBindingSet())
		return true;
	end
end

do  local cleaner = GenerateClosure(env.SetTempBinding, env)
	function env:ClearBindingsForID(bindingID, saveAfter)
		db.table.map(cleaner, db.Gamepad:GetBindingKey(bindingID))
		if saveAfter then
			SaveBindings(GetCurrentBindingSet())
		end
	end
end

function env:GetActiveDeviceAndMap()
	-- using ID to get the buttons in WinRT API order (NOTE: zero-indexed)
	return db.Gamepad.Active, db('Gamepad/Index/Button/ID')
end

function env:GetActiveModifiers()
	return db.Gamepad.Index.Modifier.Active;
end

function env:GetActiveModifier(button)
	return db.Gamepad:GetActiveModifier(button)
end

function env:GetHotkeyData(btnID, modID, styleMain, styleMod)
	return db.Hotkeys:GetHotkeyData(db.Gamepad.Active, btnID, modID, styleMain, styleMod)
end

function env:GetButtonSlug(btnID, modID, split)
	return db.Hotkeys:GetButtonSlug(db.Gamepad.Active, btnID, modID, split)
end

function env:GetTooltipPrompt(btnID, text)
	local device = db.Gamepad.Active;
	if device then
		return device:GetTooltipButtonPrompt(btnID, text)
	end
end

function env:GetTooltipPromptForClick(clickID, text, useMouse)
	if useMouse then
		return ('%s %s'):format(
			CreateAtlasMarkup(('NPE_%s'):format(clickID), 28, 28), text)
	end

	local device = db.Gamepad.Active;
	local btnID = db('UICursor'..clickID)
	if device and btnID then
		return device:GetTooltipButtonPrompt(btnID, text)
	end
end

function env:GetBindings()
	return db.Gamepad:GetBindings()
end

function env:GetBindingName(bindingID)
	local info = db.Bindings:GetCustomBindingInfo(bindingID)
	if info and info.name then
		return info.name;
	end
	info = db.Bindings:ConvertRingBindingToDisplayName(bindingID)
	if info then
		return info;
	end
	return GetBindingName(bindingID);
end

function env:GetEmulationForButton(buttonID)
	return db.Console:GetEmulationForButton(buttonID);
end

function env:GetEmulationForCursor(buttonID)
	return db.Console:GetEmulationForCursor(buttonID);
end

function env:GetEmulationForModifier(modifier)
	if not modifier then return end;
	local modifierData = db.Gamepad.Index.Modifier.Cvars[modifier];
	if not modifierData then return end;

	local variableData = db.Console:GetEmulationForModifier(modifierData);
	if not variableData then return end;

	return variableData, modifierData;
end

function env:GetBlockedCombination(combination)
	return db.Gamepad.Index.Modifier.Blocked[tostring(combination)];
end

function env:GetCombinationBlockerInfo(combination)
	local blockedModifier = self:GetBlockedCombination(combination);
	if not blockedModifier then return end;
	return self:GetEmulationForModifier(blockedModifier);
end

function env:GetSplashTexture(device)
	if not device then return end;
	local splashID = db('Gamepad/Index/Splash/'..device.Name);
	return splashID and CPAPI.GetAsset('Splash\\Gamepad\\'..splashID);
end

---------------------------------------------------------------
-- Interface
---------------------------------------------------------------
env.Elements = {};

function env:GetSettingInitializer(widgetType, widgetID)
	return env.Settings[widgetID] or env.Settings[widgetType];
end

---------------------------------------------------------------
ConsolePortConfig = {
---------------------------------------------------------------
	GetEnvironment = CPAPI.Static(env);
	CreatePanel    = function(_, ...) return env:CreatePanel(...) end;
	IsLoaded       = CPAPI.Static(false);
	Show = nop, Hide = nop;
}; -- dummy until loaded.

function ConsolePortConfig:Load()
	env.Frame = CreateFrame('Frame', 'ConsolePortConfig', UIParent, 'CPConfig');
	ConsolePortConfig = env.Frame;
	CPAPI.SpecializeOnce(env.Frame, env.Config, {
		Load           = CPAPI.Static(env.Frame);
		GetEnvironment = self.GetEnvironment;
		CreatePanel    = self.CreatePanel;
		IsLoaded       = CPAPI.Static(true);
	});
	CPAPI.Next(function()
		db:TriggerEvent('OnConfigLoaded', env, env.Frame)
		env.Frame.Nav:Hide() -- Since we may have added new panels,
		env.Frame.Nav:Show() -- force the nav to update on first load.
	end)
	return env.Frame;
end