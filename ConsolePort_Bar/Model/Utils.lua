local name, env = ...;
local env = LibStub('RelaTable')(name, env, false)
env.db         = ConsolePort:DB();
env.Const      = {};
env.Attributes = {};
env.UIHandler  = CPAPI.CreateEventHandler({'Frame'}, {
	'PLAYER_REGEN_DISABLED';
	'PLAYER_REGEN_ENABLED';
}); local db, L, UIHandler = env.db, env.db.Locale, env.UIHandler;

UIHandler:Hide()
function UIHandler:OnDataLoaded()
	self:HideBlizzard()
	env:TriggerEvent('OnEnvLoaded')
end

function UIHandler:PLAYER_REGEN_DISABLED()
	env:TriggerEvent('OnCombatLockdown', true)
end

function UIHandler:PLAYER_REGEN_ENABLED()
	env:TriggerEvent('OnCombatLockdown', false)
end

---------------------------------------------------------------
-- Libs
---------------------------------------------------------------
env.LIB = LibStub('ConsolePortActionButton')
env.LAB = LibStub('LibActionButton-1.0')
env.MSQ = LibStub('Masque', true)

EventUtil.ContinueOnAddOnLoaded('Masque', function()
	env.MSQ = LibStub('Masque', true)
	if env.MSQ then
		RunNextFrame(function() env:TriggerEvent('OnMasqueLoaded', env.MSQ) end)
	end
end)

---------------------------------------------------------------
do -- Data handler
	-----------------------------------------------------------
	local VAR_SETTINGS, VAR_LAYOUT, VAR_PRESETS =
		'ConsolePort_BarDB', 'ConsolePort_BarLayout', 'ConsolePort_BarPresets';

	function env:UpdateDataSource()
		if not _G[VAR_SETTINGS] then _G[VAR_SETTINGS] = {} end;
		local settings = CPAPI.Proxy(_G[VAR_SETTINGS], self.Defaults);
		env:Register('Settings', settings, true)
		env:Default(settings)
		env:Save('Settings', VAR_SETTINGS)

		if not _G[VAR_PRESETS]  then _G[VAR_PRESETS] = {} end;
		local presets  = CPAPI.Proxy(_G[VAR_PRESETS], self.Presets);
		env:Register('Presets', presets, true)
		env:Save('Presets', VAR_PRESETS)

		if not _G[VAR_LAYOUT] then _G[VAR_LAYOUT] = env:GetDefaultLayout() end;
		local layout = env.UpgradeLayout(_G[VAR_LAYOUT]);
		env:Register('Layout', layout, true)
		env:Save('Layout', VAR_LAYOUT)
	end

	function env:GetDefault(var)
		local varDefault = self.default[var];
		if (type(varDefault) == 'table' and varDefault.Get) then
			return varDefault:Get()
		end
		return varDefault;
	end

	function env:OnVariablesChanged(variables)
		for varID, data in pairs(variables) do
			self.Defaults[varID] = data[1]:Get();
		end
	end

	function env:OnEnvLoaded()
		self.Defaults = {};
		self:OnVariablesChanged(env.Variables)
		self:UpdateDataSource()
		env:TriggerEvent('OnDataLoaded')
		if env.MSQ then
			env:TriggerEvent('OnMasqueLoaded', env.MSQ)
		end
	end

	function env:TriggerPathEvent(path, ...)
		local obj = self(path);
		if obj then
			self:TriggerEvent(tostring(obj), ...)
		end
	end

	env:RegisterCallback('OnEnvLoaded', env.OnEnvLoaded, env)
	env:RegisterCallback('Layout', env.Save, env, 'Layout', VAR_LAYOUT)
end -- Data handler

---------------------------------------------------------------
do -- Widget factory
	-----------------------------------------------------------
	local Factories, Interface, Widgets, ActiveWidgets = {}, {}, {}, {};

	local function HideAndClearAnchors(widget)
		widget:Hide()
		widget:ClearAllPoints()
	end

	local function FindSignature(widget)
		for signature, w in pairs(Widgets) do
			if ( w == widget )  then
				return signature;
			end
		end
	end

	function env:AddFactory(type, factory, props)
		Factories[type] = factory;
		Interface[type] = props;
	end

	function env:Acquire(...)
		return securecallfunction(self.Factory, self, ...)
	end

	function env:Factory(frameType, id, ...)
		assert(Factories[frameType], 'Factory does not exist: '..frameType)
		assert(type(id) == 'string', 'Factory widget ID must be a string')
		local signature = self.MakeSig(frameType, id);
		if not Widgets[signature] then
			local widget = Factories[frameType](id, ...);
			Widgets[signature] = widget;
			if ( widget.SetAttribute ) then
				widget:SetAttribute('signature', signature);
			end
		end
		ActiveWidgets[Widgets[signature]] = signature;
		return Widgets[signature];
	end

	function env:Map(frameType, id, func, ...)
		local signature = '^'..self.MakeSig(frameType, id);
		for widget, sig in pairs(ActiveWidgets) do
			if sig:find(signature) then
				func(widget, ...);
			end
		end
	end

	function env:GetSignature(widget)
		return ActiveWidgets[widget] or FindSignature(widget);
	end

	function env:IsActive(widget)
		return not not ActiveWidgets[widget];
	end

	function env:Release(widget, release)
		ActiveWidgets[widget] = nil;
		(release or HideAndClearAnchors)(widget);
		if widget.OnRelease then
			widget:OnRelease();
		end
	end

	function env:ReleaseAll()
		repeat
			for widget in pairs(ActiveWidgets) do
				self:Release(widget);
			end
		until not next(ActiveWidgets)
	end

	-----------------------------------------------------------
	-- Interface
	-----------------------------------------------------------
	local function GetFrameType(signature)
		return signature:match('^(%a+):');
	end

	local function GetInterfaceBySignature(signature)
		return Interface[GetFrameType(signature)];
	end

	function env:GetInterface(widget)
		local signature = ActiveWidgets[widget];
		if signature then
			return GetInterfaceBySignature(signature);
		end
	end

	function env:GetProps(widget)
		local interface = self:GetInterface(widget);
		if interface then
			return interface():Set(widget.props);
		end
	end

	local function GetLocalProps(signature)
		local interface = GetInterfaceBySignature(signature);
		if interface then
			return interface;
		end
	end

	function env:GetConfiguration()
		local hierarchy = {};

		local function scaffold(widget, sig)
			local props = GetLocalProps(sig)
			if not props then return nil end;
			local widgetType, widgetName = self.UnpackSig(sig);
			return widgetName, { props[1];
				type      = widgetType;
				props     = props():Set(widget.props);
				widget    = widget;
				signature = sig;
			};
		end

		for widget, sig in pairs(ActiveWidgets) do
			if not ActiveWidgets[widget:GetParent()] then
				local name, config = scaffold(widget, sig)
				if name and config then
					hierarchy[name] = config;
				end
			end
		end

		return hierarchy;
	end

end -- Widget factory


---------------------------------------------------------------
-- Asset data handler
---------------------------------------------------------------
env.Colors = {};

function env:GetColor(id)
	local hex = self(id)
	local color = self.Colors[id];
	if color and (hex == color.hex) then
		return color;
	end
	color = CPAPI.CreateColorFromHexString(hex);
	color.hex = hex;
	self.Colors[id] = color;
	return color;
end

function env:GetColorRGB(id)
	local color = self:GetColor(id);
	return color:GetRGB();
end

function env:GetColorRGBA(id)
	local color = self:GetColor(id);
	return color:GetRGBA();
end

function env:GetColorGradient(r, g, b, a, i, invert)
	a = a or 1;
	i = i or 0.25;
	local base, mult = 0.15, 1.2;
	local startA, endA = i * a, 0;
	local minColor = CreateColor((r + base) * mult, (g + base) * mult, (b + base) * mult, startA);
	local maxColor = CreateColor(1 - (r + base) * mult, 1 - (g + base) * mult, 1 - (b + base) * mult, endA);
	return -- SetGradient
	--[[ orientation ]] 'VERTICAL',
	--[[ minColor    ]] invert and maxColor or minColor,
	--[[ maxColor    ]] invert and minColor or maxColor;
end

function env.GetAsset(asset, arg1, ...)
	return [[Interface\AddOns\ConsolePort_Bar\Assets\]]
	..(arg1 and asset:format(arg1, ...) or asset);
end

---------------------------------------------------------------
-- Utility functions
---------------------------------------------------------------
function env.MakeID(name, ...)
	return name:format(...):gsub('[- ]', '_'):gsub('_$', '')
end

function env.MakeSig(type, id)
	return type..':'..(id or '');
end

function env.UnpackSig(sig)
	return sig:match('^(%a+):(.+)$');
end

function env.ModComplement(A, B)
	return A:gsub((B:gsub('%-', '%%-')), '')
end

function env.IsModSubset(A, B)
	return not not (B:find(A:gsub('%-', '%%-')))
end

function env.UpdateFlags(flag, flags, predicate)
	return predicate and bit.bor(flags, flag) or bit.band(flags, bit.bnot(flag))
end

function env.CreateFlagClosures(flags)
	local closures = {};
	for flagName, flagValue in pairs(flags) do
		closures[flagName] = GenerateClosure(env.UpdateFlags, flagValue);
	end
	return closures;
end

do local ModReplacements = {
		M0 = '';
		M1 = 'SHIFT-';
		M2 = 'CTRL-';
		M3 = 'ALT-';
	};
	function env.ConvertDriver(driver) driver = driver or '';
		for key, rep in pairs(ModReplacements) do
			driver = driver:gsub(key, rep)
		end
		driver = driver:gsub('%b[]', function(capture)
			return capture:gsub('%s', '')
		end)
		return (driver:gsub('%[mod:%]', '[nomod]'))
	end
end

function env.MapDriver(driver)
	local result, i = {}, 0;
	for condition, response in driver:gmatch('(%b[])([^;]+)') do
		tinsert(result, { ( response:trim() ), ( condition:sub(2, -2) ) });
	end
	for response in driver:gmatch('([^;%[%]]+)$') do
		tinsert(result, { response:trim(), nil })
	end
	return function()
		i = i + 1;
		if result[i] then
			return unpack(result[i]);
		end
		return nil;
	end
end

function env.MakeMacroDriverDesc(text, outcome, condition, state, simple, arguments, states, baseColor)
	text = L(text);
	baseColor = baseColor or NORMAL_FONT_COLOR;

	local function MakeBulletList(topic, args, color)
		local list = baseColor:WrapTextInColorCode(L(topic)..':')
		for arg, desc in db.table.spairs(args) do
			list = ('%s\n• %s - %s'):format(list, color:WrapTextInColorCode(arg), L(desc));
		end
		return list;
	end

	if condition and state then
		text = ('%s\n\n%s\n[%s] %s; ...'):format(text,
			baseColor:WrapTextInColorCode(L'Format'..':'),
			BLUE_FONT_COLOR:WrapTextInColorCode(condition),
			GREEN_FONT_COLOR:WrapTextInColorCode(state));
		if simple then
			text = ('%s %s %s'):format(text,
				YELLOW_FONT_COLOR:WrapTextInColorCode(L'or'),
				GREEN_FONT_COLOR:WrapTextInColorCode(state));
		end
	end
	if arguments then
		text = ('%s\n\n%s'):format(text, MakeBulletList('Arguments', arguments, BLUE_FONT_COLOR));
	end
	if states then
		text = ('%s\n\n%s'):format(text, MakeBulletList('States', states, GREEN_FONT_COLOR));
	end
	if outcome then
		text = ('%s\n\n%s\n%s'):format(text, baseColor:WrapTextInColorCode(L'Outcome'..':'), L(outcome));
	end
	return text;
end

---------------------------------------------------------------
do -- Binding data handler
	-----------------------------------------------------------
	local TOOLTIP_LINE_LEN = 50;
	local NOT_BOUND_MOD = 'This button is not bound to any action.';
	local NOT_BOUND_TAP = 'This button is not bound to any tap action.';

	function env.GetBindingIcon(binding)
		return db.Bindings.Icons[binding];
	end

	function env.GetBindingName(binding)
		return _G['BINDING_NAME_'..binding] or GetBindingName(binding);
	end

	function env.GetXMLBindingInfo(binding)
		local desc, image, name, texture = db.Bindings:GetDescriptionForBinding(binding, true, TOOLTIP_LINE_LEN)
		local tooltip = ('%s%s%s'):format(
			WHITE_FONT_COLOR:WrapTextInColorCode(name or env.GetBindingName(binding)),
			desc  and ('\n\n%s'):format(desc)  or '',
			image and ('\n\n%s'):format(image) or ''
		);
		return {
			name    = name;
			desc    = desc;
			texture = texture;
			tooltip = tooltip;
		};
	end

	function env.GetRebindInfo(buttonID)
		local emulation = db.Console:GetEmulationForButton(buttonID)
		local title = emulation and emulation.name or NOT_BOUND;
		local desc  = emulation and CPAPI.FormatLongText(('%s\n\n%s'):format(
			emulation.desc, NOT_BOUND_TAP), TOOLTIP_LINE_LEN) or NOT_BOUND_MOD;
		local tooltip = ('%s\n%s'):format(WHITE_FONT_COLOR:WrapTextInColorCode(title), desc)
		return {
			name    = title;
			desc    = desc;
			texture = nil;
			tooltip = tooltip;
		};
	end
end -- Binding data handler


---------------------------------------------------------------
-- State handler helpers
---------------------------------------------------------------
env.Attributes.State   = GenerateClosure(format, '_onstate-%s');     -- macro conditional response
env.Attributes.Driver  = GenerateClosure(format, 'driver-%s');       -- macro conditional driver
env.Attributes.Update  = GenerateClosure(format, '_childupdate-%s'); -- child update closure
env.Attributes.OnState = 'OnStateChanged';                           -- see LibActionButton-1.0.lua
env.Attributes.OnPage  = 'ActionPageChanged';                        -- see Pager.lua
env.Attributes.Visible = 'visibility';
env.Attributes.Hidden  = 'statehidden';