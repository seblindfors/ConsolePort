local env, _, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Panel = { name = BINDING_HEADER_ACTIONBAR };
---------------------------------------------------------------
local RenderSettings, Button, Divider;

function Panel:OnLoad()
	CPAPI.Start(self)
	self:Reindex()
	self:SetActiveCategory(GENERAL, self.index[ACTIONBARS_LABEL][GENERAL])
end

function Panel:RenderSettings()
	local settings = RenderSettings(self)
	if not settings then return end;

	settings:InsertAtIndex(Button:New({
		text  = L'Open Designer';
		atlas = 'RedButton-Expand';
		callback = GenerateClosure(self.OpenDesigner, self);
	}), 2)
	settings:InsertAtIndex(Divider:New(), 3)
end

function Panel:OpenDesigner()
	ConsolePortConfig:Hide()
	env:TriggerEvent('OnConfigToggle')
end

ConsolePort:RegisterConfigCallback(function(self, configEnv)
	local Settings = CreateFromMixins(
		configEnv.SettingsPanel,
		configEnv.SettingsRenderer,
		Panel
	);

	RenderSettings = configEnv.SettingsPanel.RenderSettings;
	Button         = configEnv.Elements.Button;
	Divider        = configEnv.Elements.Divider;

	Settings:Init()

	Settings:AddProvider(function(AddSetting)
		foreach(self.Variables, function(var, data)
			local head = data.head or MISCELLANEOUS;
			local main = data.main or SETTINGS;
			if data.hide then
				return;
			end
			AddSetting(main, head, {
				varID    = var;
				field    = data;
				sort     = data.sort;
				type     = configEnv.Elements.Setting;
				registry = self;
			});
		end)
	end)

	Settings:AddProvider(GenerateClosure(configEnv.ActionBarsProvider,
		ACTIONBARS_LABEL,
		KEY_BINDINGS_MAC,
		true -- excludeSearch
	));

	Settings:AddMutator(function(_, _, interface)
		interface[ACTIONBARS_LABEL][GENERAL].sort = 1;
		interface[ACTIONBARS_LABEL][KEY_BINDINGS_MAC].sort = 2;
	end)

	configEnv:CreatePanel(Settings)
end, env)