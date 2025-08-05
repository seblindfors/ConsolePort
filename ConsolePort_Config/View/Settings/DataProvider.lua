local DP, env, db, _, L = 1, CPAPI.GetEnv(...);
local Settings = env:GetContextPanel();

-----------------------------------------------------------
-- Sorting
-----------------------------------------------------------
do local GroupOrder = {
		[SETTING_GROUP_GAMEPLAY]   = 1;
		[SETTING_GROUP_SYSTEM]     = 2;
		[BINDING_HEADER_TARGETING] = 3;
		[INTERFACE_LABEL]          = 4;
	};

	function Settings.GroupSort(_, a, b)
		local iA, iB = GroupOrder[a], GroupOrder[b];
		if iA and not iB then
			return true;
		elseif iB and not iA then
			return false;
		elseif iA and iB then
			return iA < iB;
		else
			return a < b;
		end
	end
end

-----------------------------------------------------------
-- Addon settings
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting)
	foreach(db.Variables, function(var, data)
		local head = data.head or MISCELLANEOUS;
		local main = data.main or SETTINGS;
		if data.hide then
			return;
		end
		AddSetting(main, head, {
			varID = var;
			field = data;
			sort  = data.sort;
			type  = env.Elements.Setting;
		});
	end)
end)

-----------------------------------------------------------
-- Device profiles
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting, GetSortIndex)
	local numAddedDevices = 0;
	local deviceProfile = env.Elements.DeviceProfile;
	for name, device in db.Gamepad:EnumerateDevices() do
		if device.Layout then
			local sort = GetSortIndex(SETTING_GROUP_SYSTEM, GENERAL);
			local data = deviceProfile:Data({
				device = device;
				varID  = ('Gamepad/Template/Gamepads/%s'):format(name);
			});
			numAddedDevices = numAddedDevices + 1;
			data.type = deviceProfile;
			data.sort = sort + numAddedDevices;
			AddSetting(SETTING_GROUP_SYSTEM, GENERAL, data);
		end
	end
end)

-----------------------------------------------------------
-- Console settings (game native)
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting, GetSortIndex)
	local ConsoleCategoryMap = {
		Mouse     = SETTING_GROUP_SYSTEM;
		Camera    = SETTING_GROUP_SYSTEM;
		Bindings  = SETTING_GROUP_GAMEPLAY;
		Touchpad  = SETTING_GROUP_SYSTEM;
		Interact  = BINDING_HEADER_TARGETING;
		Tooltips  = BINDING_HEADER_TARGETING;
		System    = SETTING_GROUP_SYSTEM;
	};

	local ConsoleListMap = {
		Bindings = KEY_BINDINGS_MAC;
		Mouse    = MOUSE_LABEL;
		Camera   = CAMERA_LABEL;
		System   = GENERAL;
	};

	for head, group in pairs(db.Console) do
		local main = ConsoleCategoryMap[head] or SETTINGS;
		local list = ConsoleListMap[head] or head;
		local sort = GetSortIndex(main, list);
		for i, data in ipairs(group) do
			-- Sanity check: if the cvar is nil, it does not exist in
			-- the current game version. Skip it.
			local value = GetCVar(data.cvar);
			if ( value ~= nil ) then
				data[DP] = (data[DP] or data.type()):Set(value);
				AddSetting(main, list, {
					varID = data.cvar;
					field = data;
					sort  = sort + i;
					type  = env.Elements.Cvar;
				});
			end
		end
	end
end)

-----------------------------------------------------------
-- Mapper profile settings (game native)
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting, GetSortIndex)
	local ProfileCategoryMap = {
		Movement = SETTING_GROUP_SYSTEM;
		Camera   = SETTING_GROUP_SYSTEM;
	};

	local ProfileListMap = {
		Camera = CAMERA_LABEL;
	};

	for head, group in pairs(db.Profile) do
		local main = ProfileCategoryMap[head] or SETTINGS;
		local list = ProfileListMap[head] or head;
		local sort = GetSortIndex(main, list);
		for i, data in ipairs(group) do
			data[DP] = (data[DP] or data.data())
			AddSetting(main, list, {
				varID = data.path;
				field = data;
				sort  = sort + i;
				type  = env.Elements.Mapper;
			});
		end
	end
end)

-----------------------------------------------------------
-- Binding presets and meta configuration
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting, GetSortIndex)
	local main, head = SETTING_GROUP_GAMEPLAY, KEY_BINDINGS_MAC;
	local sort = GetSortIndex(main, head);
	local list = L'Presets';

	-- Toggle character bindings on/off
	AddSetting(main, head, {
		sort  = 0;
		type  = env.Elements.CharacterBindings;
		field = { before = true };
	})

	-- Presets
	local function AddPreset(meta, preset, readonly, key, device)
		sort = GetSortIndex(main, head);
		local datapoint = {
			sort     = sort + 1;
			type     = env.Elements.BindingPreset;
			meta     = meta;
			preset   = preset;
			readonly = readonly;
			key      = key;
			device   = device;
			field    = {
				name = meta.Name;
				list = list;
				advd = true;
			};
		};
		return datapoint, AddSetting(main, head, datapoint)
	end

	-- The empty preset overwrites all bindings, so we're using it as a base
	-- for other presets, to wipe out residual bindings.
	local table, emptyPreset = db.table, db.Gamepad:GetBindingsTemplate();

	local function MakePreset(bindings)
		return table.merge(table.copy(emptyPreset), table.copy(bindings))
	end

	-- Add the "Add Preset" button
	AddSetting(main, head, {
		sort  = GetSortIndex(main, head) + 1;
		type  = env.Elements.BindingPresetAdd;
		add   = AddPreset;
		make  = MakePreset;
		field = {
			name = ADD;
			list = list;
			advd = true;
		};
	})

	-- Add the empty preset
	AddPreset({
		Name = EMPTY;
		Icon = CPAPI.GetAsset([[Icons\64\xbox_c_options]]);
	}, emptyPreset, true);

	-- Presets for each gamepad device
	for name, device in db.Gamepad:EnumerateDevices() do
		local asset = db('Gamepad/Index/Splash/'..name)
		local icon = asset and CPAPI.GetAsset([[Splash\Gamepad\]]..asset)
		AddPreset({
			Name = name;
			Icon = icon;
		}, nil, true, name, device);
	end

	-- Presets from saved character data
	for key, settings in db:For('Shared/Data', true) do
		if settings.Bindings then
			local datapoint, store = AddPreset(settings.Meta, MakePreset(settings.Bindings), false, key);
			datapoint.index = #store;
			datapoint.store = store;
		end
	end
end)

-----------------------------------------------------------
-- Bindings
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting, GetSortIndex)
	local main, head = SETTING_GROUP_GAMEPLAY, KEY_BINDINGS_MAC;
	local sort = GetSortIndex(main, head);
	local bindings = env.BindingInfo:RefreshDictionary()

	AddSetting(main, head, {
		sort  = sort + 1;
		type  = env.Elements.Title;
		text  = CATEGORIES;
		field = { after = true };
	})

	for category, set in env.table.spairs(bindings) do
		local list = category:trim();
		head = list == KEY_BINDINGS_MAC and ACTIONBARS_LABEL or KEY_BINDINGS_MAC;
		sort = GetSortIndex(main, head);
		for i, info in ipairs(set) do
			AddSetting(main, head, {
				sort     = sort + i;
				type     = env.Elements.Binding;
				binding  = info.binding;
				readonly = info.readonly;
				field = {
					name = info.name;
					list = list;
					xtra = true;
				};
			})
		end
	end
end)

-----------------------------------------------------------
-- Action bars
-----------------------------------------------------------
env.ActionBarsProvider = (function(main, head, excludeSearch, AddSetting, GetSortIndex)
	local sort = GetSortIndex(main, head);

	-- Toggle character bindings on/off
	AddSetting(main, head, {
		sort  = 0;
		type  = env.Elements.CharacterBindings;
		field = { before = true };
	})

	for groupID, container in db:For('Actionbar/Pages') do
		local shouldDrawBars = container();
		if shouldDrawBars then
			for barIndex, barID in ipairs(container) do
				local list, name, icon, prio;

				local stanceBarInfo = db.Actionbar.Lookup.Stances[barID];
				if stanceBarInfo and stanceBarInfo.name then
					list = PRIMARY;
					icon = stanceBarInfo.iconID;
					name = stanceBarInfo.name;
					prio = 10;
				else
					list = db.Actionbar.Names[container];
					name = db.Actionbar.Names[barID];
					prio = 100;
				end

				AddSetting(main, head, {
					type = env.Elements.ActionbarMapper;
					sort = sort + groupID * prio + barIndex;
					bar  = barID;
					field = {
						name = name;
						list = list;
						icon = icon;
						advd = true;
						expd = list == PRIMARY;
						info = stanceBarInfo;
						excludeSearch = excludeSearch;
					};
				})
			end
		end
	end

	return 'OnShapeshiftFormInfoChanged', 'Settings/bindingShowExtraBars';
end); Settings:AddProvider(GenerateClosure(env.ActionBarsProvider,
	SETTING_GROUP_GAMEPLAY, -- main
	ACTIONBARS_LABEL,       -- head
	false                   -- excludeSearch
));

-----------------------------------------------------------
-- Base customizations to data sets/provider
-----------------------------------------------------------
Settings:AddMutator(function(AddSetting, _, interface)
	-- Enforce the sort order of the main categories.
	interface[SETTING_GROUP_SYSTEM][GENERAL].sort = 1;
	interface[SETTING_GROUP_GAMEPLAY][KEY_BINDINGS_MAC].sort = 1;

	-- Add custom device select setting.
	local deviceSelect = env.Elements.DeviceSelect;
	local deviceSelectData = deviceSelect:Data()
	AddSetting(SETTING_GROUP_SYSTEM, GENERAL, {
		varID = deviceSelectData.varID;
		field = deviceSelectData.field;
		type  = deviceSelect;
		sort  = 0;
	})
end)