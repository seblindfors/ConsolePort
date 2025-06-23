local _, _, env, db, name = CPAPI.LinkEnv(...);
---------------------------------------------------------------
LibStub('RelaTable')(name, env, false);
---------------------------------------------------------------
-- Binding helpers
---------------------------------------------------------------
env.BindingInfo, env.BindingInfoMixin = db.Loadout, db.LoadoutMixin;

function env:GetActiveDeviceAndMap()
	-- using ID to get the buttons in WinRT API order (NOTE: zero-indexed)
	return db.Gamepad.Active, db('Gamepad/Index/Button/ID')
end

function env:GetActiveModifiers()
	return db('Gamepad/Index/Modifier/Active')
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
}; -- dummy until loaded.

function ConsolePortConfig:Load()
	env.Frame = CreateFrame('Frame', 'ConsolePortConfig', UIParent, 'CPConfig');
	ConsolePortConfig = env.Frame;
	FrameUtil.SpecializeFrameWithMixins(env.Frame, env.Config, {
		Load           = CPAPI.Static(env.Frame);
		GetEnvironment = self.GetEnvironment;
		CreatePanel    = self.CreatePanel;
	});
	return env.Frame;
end