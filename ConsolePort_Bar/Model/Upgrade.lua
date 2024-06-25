local _, env, db = ...; db = env.db;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local invert = function(v) return not v end;
local color  = function(v) return ('%.2x%.2x%.2x%.2x'):format(CreateColor(unpack(v)):GetRGBAAsBytes()) end;

---------------------------------------------------------------
-- V1 Upgrade
---------------------------------------------------------------
function env.IsV1Layout(preset)
	-- The format of V1 had a single layout table, while V2 has a
	-- table of children layouts mapped in the manager.
	return type(preset) == 'table' and type(preset.layout) == 'table' and not preset.children;
end

-- Migration: V1 -> V2
-- Converts an outdated layout to the new format.
function env.UpgradeFromV1()
	local v1 = ConsolePort_BarSetup;
	if v1 then
		-- ConsolePort_BarSetup = nil; -- TODO: enable when build is stable
		CPAPI.Log('ConsolePort: upgrading action bar layout...')
		local v2, settings = env.ConvertV1Layout(v1);
		for path, value in pairs(settings) do
			env(path, value);
		end
		return v2;
	end
end

-- Map V1 table -> V2 DB
local V1V2DBMap = {
	showbuttons    = { 'Settings/clusterShowAll' };
	hidewatchbars  = { 'Settings/enableXPBar', invert };
	watchbars      = { 'Settings/fadeXPBar', invert };
	hideIcons      = { 'Settings/clusterShowMainIcons', invert };
	hideModifiers  = { 'Settings/clusterShowFlyoutIcons', invert };
	classicBorders = { 'Settings/clusterBorderStyle', function(v) return v and 'Beveled' or 'Normal' end };
	borderRGB      = { 'Settings/borderColor', color };
	expRGB         = { 'Settings/xpBarColor', color };
	swipeRGB       = { 'Settings/swipeColor', color };
	tintRGB        = { 'Settings/tintColor', color };
};

-- Map V1 table -> V2 Layout
local V1V2LayoutMap = {
	width = { 'v2/children/Cluster/width' };
	scale = { 'v2/children/Cluster/rescale', function(v) return tostring(math.ceil(v * 100)) end };
};

-- Map V1.button.dir -> V2.ClusterHandle.dir + V2.ClusterHandle.showFlyouts
local V2ValidateDir = CPAPI.Proxy({['<hide>'] = false}, function(_, v) return v:upper() end );

function env.ConvertV1Layout(v1)
	assert(v1.layout, 'No layout found in outdated preset.')

	-- Handle settings that were part of the layout table,
	-- but are now part of the settings table.
	local settings = {};
	for deprecated, value in pairs(v1) do
		local map = V1V2DBMap[deprecated];
		if map then
			local path, conv = unpack(map)
			if conv then
				value = conv(value)
			end
			settings[path] = value;
		end
	end

	-- Handle the layout table buttons, convert to ClusterHandle.
	local buttons = {};
	for buttonID, data in pairs(v1.layout) do
		-- no point in converting disabled buttons, pun intended.
		-- also, remove modifier buttons from the layout, because they were not visible in V1.
		if data.point and not db.Gamepad.Index.Modifier.Owner[buttonID] then
			-- dir = <hide> -> showFlyouts = false;
			local showFlyouts = not not V2ValidateDir[data.dir];
			-- dir = lowercased -> dir = uppercased;
			local dir  = data.dir and V2ValidateDir[data.dir] or 'DOWN';
			-- unchanged
			local size = data.size;
			-- point = {[1], [2], [3]} -> pos = {point, relPoint, x, y};
			local point, x, y = unpack(data.point);
			local pos = {point = point, relPoint = point, x = x, y = y};
			-- convert V1 button to V2 ClusterHandle.
			buttons[buttonID] = env.Interface.ClusterHandle():Warp {
				pos         = pos;
				size        = size;
				showFlyouts = showFlyouts;
				dir         = dir;
			};
		end
	end

	local v2 = CopyTable(env.Presets.Default)
	v2.name = env.Const.DefaultPresetName;
	v2.desc = db.Locale'Player action bar setup.';
	-- Can't track where the pet ring was located in V1, so place it in a convenient spot
	-- for the majority of users (those who never customized the layout in v1)
	v2.children.Petring  = env.Interface.Petring:Render { pos = { y = 70 } };
	-- Convert the V1 layout to a V2 Cluster layout.
	v2.children.Cluster = env.Interface.Cluster:Render {
		children = buttons;
	};

	-- Register in database to leverage pathing.
	env:Register('v2', v2);

	-- Transfer layout settings to the new layout.
	for deprecated, value in pairs(v1) do
		local map = V1V2LayoutMap[deprecated];
		if map then
			local path, conv = unpack(map)
			if conv then
				value = conv(value)
			end
			env(path, value)
		end
	end

	-- Clean up
	env:Register('v2', nil, true)
	return v2, settings;
end

---------------------------------------------------------------
-- V2 Upgrade
---------------------------------------------------------------
function env.IsV2Layout(preset)
	return type(preset) == 'table' and type(preset.children) == 'table';
end

function env.UpgradeLayout(layout)
	if env.IsV1Layout(layout) then
		layout = env.ConvertV1Layout(layout);
	end

	local function UpgradeInterface(data)
		if data.children then
			for child, childData in pairs(data.children) do
				data.children[child] = UpgradeInterface(childData)
			end
		end
		if data.type then
			return env.Interface[data.type]():Warp(data)
		end
		return data;
	end

	if layout.children then
		for child, data in pairs(layout.children) do
			layout.children[child] = UpgradeInterface(data)
		end
	end

	return layout;
end