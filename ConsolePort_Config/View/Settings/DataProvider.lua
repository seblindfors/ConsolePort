local DP, env, db = 1, CPAPI.GetEnv(...);
local Settings = env:GetContextPanel();

-----------------------------------------------------------
-- Sorting
-----------------------------------------------------------
do local GroupOrder = {
		[CONTROLS_LABEL]           = 1;
		[INTERFACE_LABEL]          = 2;
		[BINDING_HEADER_TARGETING] = 3;
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

    function Settings.CategorySort(t, a, b)
		local iA, iB = t[a].sort, t[b].sort;
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
	for name, device in db:For('Gamepad/Devices', true) do
		if device.Theme then
			local sort = GetSortIndex(CONTROLS_LABEL, SYSTEM);
			local data = deviceProfile:Data({
				device = device;
				varID  = ('Gamepad/Devices/%s'):format(name);
			});
			numAddedDevices = numAddedDevices + 1;
			data.type = deviceProfile;
			data.sort = sort + numAddedDevices;
			AddSetting(CONTROLS_LABEL, SYSTEM, data);
		end
	end
end)

-----------------------------------------------------------
-- Console settings (game native)
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting, GetSortIndex)
	local ConsoleCategoryMap = {
		Mouse     = CONTROLS_LABEL;
		Camera    = CONTROLS_LABEL;
		Bindings  = CONTROLS_LABEL;
		Touchpad  = CONTROLS_LABEL;
		Interact  = BINDING_HEADER_TARGETING;
		Tooltips  = BINDING_HEADER_TARGETING;
		System    = CONTROLS_LABEL;
	};

	local ConsoleListMap = {
		Bindings = KEY_BINDINGS_MAC;
		Mouse    = MOUSE_LABEL;
		Camera   = CAMERA_LABEL;
		System   = SYSTEM;
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
		Movement = CONTROLS_LABEL;
		Camera   = CONTROLS_LABEL;
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
-- Bindings
-----------------------------------------------------------
Settings:AddProvider(function(AddSetting, GetSortIndex)
	local bindings = env.BindingInfo:RefreshDictionary()
	local main, head = CONTROLS_LABEL, KEY_BINDINGS_MAC;
	local sort = GetSortIndex(main, head);

	AddSetting(main, head, {
		sort  = 0;
		type  = env.Elements.CharacterBindings;
		field = { before = true };
	})

	AddSetting(main, head, {
		sort  = sort + 1;
		type  = env.Elements.Title;
		text  = CATEGORIES;
		field = { after = true };
	})

	for category, set in env.table.spairs(bindings) do
		local list = category:trim();
		sort = GetSortIndex(main, head);
		for i, info in ipairs(set) do
			AddSetting(main, head, {
				sort     = sort + i;
				type     = env.Elements.Binding;
				name     = info.name;
				binding  = info.binding;
				readonly = info.readonly or nop;
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
-- Base customizations to data sets/provider
-----------------------------------------------------------
Settings:AddMutator(function(AddSetting, _, interface)
	-- Enforce the sort order of the main categories.
	interface[CONTROLS_LABEL][SYSTEM].sort = 1;
	interface[CONTROLS_LABEL][KEY_BINDINGS_MAC].sort = 2;

	-- Add custom device select setting.
	local deviceSelect = env.Elements.DeviceSelect;
	local deviceSelectData = deviceSelect:Data()
	AddSetting(CONTROLS_LABEL, SYSTEM, {
		varID = deviceSelectData.varID;
		field = deviceSelectData.field;
		type  = deviceSelect;
		sort  = 0;
	})
end)