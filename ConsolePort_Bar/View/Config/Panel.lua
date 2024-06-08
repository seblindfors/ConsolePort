local _, env = ...;
---------------------------------------------------------------
local Panel = {};
---------------------------------------------------------------

function Panel:OnShow()
	-- HACK: click on the config logo to swap to main page,
	-- so we don't get stuck in a loop of switching configs.
	self.window.Header.Logo:Click()
	self.window:Hide()
	env:TriggerEvent('OnConfigToggle')
	ConsolePort:SetCursorNodeIfActive(env.Config.Main)
end

env.db:RegisterCallback('OnConfigLoaded', function(localEnv, config, configEnv)
	Panel.window = config;
	configEnv.Bars = config:CreatePanel({
		name = BINDING_HEADER_ACTIONBAR;
		mixin = Panel;
		scaleToParent = true;
		forbidRecursiveScale = true;
	})
end, env)