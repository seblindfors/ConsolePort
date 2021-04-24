local db, _, env, L = ConsolePort:DB(), ...;
local Config, Options = {}, {};

function Config:OnFirstShow()
	local options = self:CreateScrollableColumn('Options', {
		_Mixin = Options;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMRIGHT', 0, 0};
		};
	})
	env.config.OpaqueMixin.OnLoad(options)
end

db:RegisterCallback('OnConfigLoaded', function(localEnv, config, env)
	localEnv.config, localEnv.panel, L = env, config, env.L;
	env.Keyboard = config:CreatePanel({
		name = L'Keyboard';
		mixin = Config;
		scaleToParent = true;
		forbidRecursiveScale = true;
	})
end, env)