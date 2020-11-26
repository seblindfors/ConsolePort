local _, env = ...; local db = env.db;
local Config = {};

function Config:OnFirstShow()
	local templates = self:CreateScrollableColumn('Templates', {
		_Mixin = {};
		_Width = 270;
		_Setup = {'CPSmoothScrollTemplate'};
		_Points = {
			{'TOPLEFT', 0, 1};
			{'BOTTOMLEFT', 0, -1};
		};
	})
	local options = self:CreateScrollableColumn('Options', {
		_Mixin = {};
		_Width = 300;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Templates', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.Templates', 'BOTTOMRIGHT', 0, 0};
		};
	})
	local clusters = self:CreateScrollableColumn('Clusters', {
		_Mixin = {};
		_Width = 414;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Options', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.Options', 'BOTTOMRIGHT', 0, 0};
		};
	})
	env.config.OpaqueMixin.OnLoad(options)
	env.config.OpaqueMixin.OnLoad(clusters)
end


db:RegisterCallback('OnConfigLoaded', function(localEnv, config, env)
	localEnv.config = env;
	env.Bars = config:CreatePanel({
		name  = BINDING_HEADER_ACTIONBAR;
		mixin = Config;
		scaleToParent = true;
		forbidRecursiveScale = true;
	})
end, env)