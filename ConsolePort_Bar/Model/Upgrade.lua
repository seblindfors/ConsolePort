local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local CLUSTER_DESIGN = env.Const.ClusterDesign;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local invert = function(v) return not v end;
local color  = function(v) return db.Data.Color(unpack(v)):GetHex() end;

function env.UpgradeClusterSettings(settings)
	-- Copy only an explicitly saved legacy tint. An existing new tint takes priority.
	if rawget(settings, 'swipeColor') then
		settings.clusterSwipeColor = rawget(settings, 'clusterSwipeColor') or settings.swipeColor;
		settings.swipeColor = nil;
	end

	local borderStyle = settings.clusterBorderStyle;
	if not borderStyle then return end;
	local design = settings.clusterDesign;
	-- The old border style only applied to the original cluster design.
	if ( not design or design == CLUSTER_DESIGN.Original ) then
		settings.clusterDesign = borderStyle == 'Beveled' and CLUSTER_DESIGN.Beveled or CLUSTER_DESIGN.Original;
	end
	settings.clusterBorderStyle = nil;
end

---------------------------------------------------------------
-- V1 Upgrade
---------------------------------------------------------------
function env.IsV1Layout(preset)
	-- The format of V1 had a single layout table, while V2 has a
	-- table of children layouts mapped in the manager.
	return type(preset) == 'table' and type(preset.layout) == 'table' and not preset.children;
end

-- Map V1 table -> V2 DB
local V1V2DBMap = {
	showbuttons    = { 'clusterShowAll' };
	hidewatchbars  = { 'enableXPBar', invert };
	watchbars      = { 'fadeXPBar', invert };
	hideIcons      = { 'clusterShowMainIcons', invert };
	hideModifiers  = { 'clusterShowFlyoutIcons', invert };
	classicBorders = { 'clusterDesign', function(v) return v and CLUSTER_DESIGN.Beveled or CLUSTER_DESIGN.Original end };
	borderRGB      = { 'borderColor', color };
	expRGB         = { 'xpBarColor', color };
	swipeRGB       = { 'clusterSwipeColor', color };
	tintRGB        = { 'tintColor', color };
};

local function convertV1Layout(v1)
	assert(type(v1.layout) == 'table', 'No layout found in outdated preset.')

	-- Handle settings that were part of the layout table,
	-- but are now part of the settings table.
	local settings = {};
	for deprecated, value in pairs(v1) do
		local map = V1V2DBMap[deprecated];
		if map then
			local key, conv = unpack(map)
			if conv then
				value = conv(value)
			end
			settings[key] = value;
		end
	end

	-- Handle the layout table buttons, convert to ClusterHandle.
	local buttons = {};
	for buttonID, data in pairs(v1.layout) do
		-- V1 omitted disabled buttons and buttons bound as modifiers.
		if data.point and not db.Gamepad.Index.Modifier.Owner[buttonID] then
			local showFlyouts = data.dir ~= '<hide>';
			local dir = showFlyouts and data.dir and data.dir:upper() or 'DOWN';
			-- point = {[1], [2], [3]} -> pos = {point, relPoint, x, y};
			local point, x, y = unpack(data.point);
			local pos = {point = point, relPoint = point, x = x, y = y};
			-- convert V1 button to V2 ClusterHandle.
			buttons[buttonID] = env.Interface.ClusterHandle():Warp {
				pos         = pos;
				size        = data.size;
				showFlyouts = showFlyouts;
				dir         = dir;
			};
		end
	end

	local v2 = CopyTable(env.Presets.Default)
	v2.settings = settings;
	v2.name = env.Const.DefaultPresetName;
	v2.desc = db.Locale'Player action bar setup.';
	-- Can't track where the pet ring was located in V1, so place it in a convenient spot
	-- for the majority of users (those who never customized the layout in v1)
	v2.children.Petring  = env.Interface.Petring:Render { pos = { y = 70 } };
	-- Convert the V1 layout to a V2 Cluster layout.
	v2.children.Cluster = env.Interface.Cluster:Render {
		children = buttons;
		width    = v1.width;
		-- V1 stored scale as a multiplier. The layout selector stores a percentage string.
		rescale  = v1.scale and tostring(math.ceil(v1.scale * 100));
	};
	return v2;
end

function env:GetDefaultLayout()
	if ConsolePort_BarSetup then
		local layout = convertV1Layout(ConsolePort_BarSetup);
		ConsolePort_BarSetup = nil;
		CPAPI.Log('ConsolePort: upgrading action bar layout...')
		return layout;
	end
	return CopyTable(env.Presets.Default);
end

---------------------------------------------------------------
-- V2 upgrade, dynamic options evaluation, interface upgrades
---------------------------------------------------------------
function env.IsV2Layout(preset)
	return type(preset) == 'table' and type(preset.children) == 'table';
end

function env.BuildLayout(layout, applyOptions)
	if env.IsV1Layout(layout) then
		layout = convertV1Layout(layout);
	end
	-- Activate saved options before resolving the layout. Importing only prepares the preset.
	if applyOptions then env:ApplyPresetOptions(layout) end;

	local function EvaluateDynamicOptions(data)
		if data.children then
			for child, childData in pairs(data.children) do
				data.children[child] = EvaluateDynamicOptions(childData)
			end
		end
		for key, value in pairs(data) do
			if type(value) == 'function' then
				data[key] = value(key);
			end
		end
		return data;
	end

	layout = EvaluateDynamicOptions(layout);

	local function SplitToolbar(children)
		for key, data in pairs(children) do
			if ( data.type == 'Toolbar' and ( data.width or data.castbar or data.totem ) ) then
				local menu, pos = data.menu, data.pos and CopyTable(data.pos);
				data.menu, data.type = nil, 'Watchbar';
				children[key] = nil;
				children.Watchbar = children.Watchbar or data;
				if pos then
					local width = data.width or 900;
					pos.y = (pos.y or 0) + (pos.point:match('^TOP') and -16 or 16);
					if pos.point:match('LEFT$') then
						pos.x = (pos.x or 0) + width / 2;
					elseif pos.point:match('RIGHT$') then
						pos.x = (pos.x or 0) - width / 2;
					end
				end
				children.Toolbar = children.Toolbar or { type = 'Toolbar'; menu = menu; pos = pos };
				return SplitToolbar(children);
			end
		end
	end

	if layout.children then
		SplitToolbar(layout.children)
	end

	local UpgradeInterface;

	local function UpgradeChildren(container)
		for child, data in pairs(container.children) do
			local ok, result, reason = pcall(UpgradeInterface, data)
			if ( ok and result ) then
				container.children[child] = result;
			else
				container.children[child] = nil;
				CPAPI.Log('Skipped layout element %s: %s', child, tostring(ok and reason or result))
			end
		end
	end

	function UpgradeInterface(data)
		if data.children then
			UpgradeChildren(data)
		end
		if data.type then
			local interface = env.Interface[data.type];
			if not interface then
				return nil, ('unknown element type %s'):format(tostring(data.type));
			end
			return interface():Warp(data)
		end
		return data;
	end

	if layout.children then
		UpgradeChildren(layout)
	end

	return layout;
end
