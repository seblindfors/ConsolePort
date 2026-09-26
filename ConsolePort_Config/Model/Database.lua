local _, _, env, db, name = CPAPI.LinkEnv(...);
---------------------------------------------------------------
LibStub('RelaTable')(name, env);
---------------------------------------------------------------
-- Binding helpers
---------------------------------------------------------------

function env:SetBinding(keyChord, bindingID, skipSave)
	if CPAPI.SetBinding(keyChord, bindingID, not skipSave) then
		self:TriggerEvent('OnBindingChanged', keyChord, bindingID)
		return true;
	end
end

-- A layer coordinate cannot be produced by pressing keys, because the
-- engine composes a chord from the modifiers physically held and knows
-- nothing about a latch. So the controller's own state supplies it: a
-- latched or doubled layer survives into the binding catcher, and the
-- button pressed there lands in the layer the player is standing in.
-- @param button : button that was caught
function env:CreateKeyChordForLayer(button)
	local layer = db.Layers:GetActiveLayer();
	if db.Gamepad.Index.Modifier.Layered[layer] then
		return layer..button;
	end
	return CPAPI.CreateKeyChord(button);
end

-- Says which layer the press will land in, since the catcher looks
-- identical whether one is latched or not.
-- @param prompt : the prompt the catcher would otherwise show
function env:GetBindingCatcherPrompt(prompt)
	local layer = db.Layers:GetActiveLayer();
	if db.Gamepad.Index.Modifier.Layered[layer] then
		return ('%s\n\n%s'):format(prompt, env.L('Binding into the %s layer.', layer))
	end
	return prompt;
end

function env:ClearBindingsForID(bindingID, saveAfter)
	return CPAPI.ClearBindingsForID(bindingID, saveAfter)
end

function env:GetActiveDevice()
	return db.Gamepad.Active;
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