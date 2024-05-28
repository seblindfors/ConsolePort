local name, env = ...;
local env = LibStub('RelaTable')(name, env, false)
env.db        = ConsolePort:DB();
env.UIHandler = CPAPI.CreateEventHandler({'Frame'}, {
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

E = env -- debug

---------------------------------------------------------------
-- Libs
---------------------------------------------------------------
env.LIB = LibStub('ConsolePortActionButton')
env.LAB = LibStub('LibActionButton-1.0')
env.LBG = LibStub('LibButtonGlow-1.0')

do -- LBG Hook
	local ShowOverlayGlow, HideOverlayGlow = env.LBG.ShowOverlayGlow, env.LBG.HideOverlayGlow;
	local OnOverlayGlow = GenerateClosure(env.TriggerEvent, env, 'OnOverlayGlow');
	function env.LBG.ShowOverlayGlow(button)
		OnOverlayGlow(true, button)
		return ShowOverlayGlow(button)
	end
	function env.LBG.HideOverlayGlow(button)
		OnOverlayGlow(false, button)
		return HideOverlayGlow(button)
	end
end

---------------------------------------------------------------
do -- Data handler
	-----------------------------------------------------------
	local VAR_SETTINGS, VAR_LAYOUT = 'ConsolePort_BarDB', 'ConsolePort_BarLayout';

	function env:UpdateDataSource()
		local settings, layout;
		-- TODO: Potentially add global/character setting switch
		if not _G[VAR_SETTINGS] then
			_G[VAR_SETTINGS] = {};
		end
		--if not _G[VAR_LAYOUT] then
			_G[VAR_LAYOUT] = env:GetDefaultLayout()
		--end

		layout = _G[VAR_LAYOUT];
		settings = CPAPI.Proxy(_G[VAR_SETTINGS], self.Defaults);

		env:Register('Layout', layout, true)
		env:Register('Settings', settings, true)
		env:Default(settings)
		env:Save('Settings', VAR_SETTINGS)
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
	end

	function env:TriggerPathEvent(path, ...)
		local obj = self(path);
		if obj then
			self:TriggerEvent(tostring(obj), ...)
		end
	end

	env:RegisterCallback('OnEnvLoaded', env.OnEnvLoaded, env)
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
			Widgets[signature] = Factories[frameType](id, ...);
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
				local key, value = scaffold(widget, sig)
				if key and value then
					hierarchy[key] = value;
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

function env:GetColorGradient(r, g, b, a, i)
	a = a or 1;
	i = i or 0.25;
	local base, mult = 0.15, 1.2;
	local startA, endA = i * a, 0;
	return -- SetGradient
	--[[ orientation ]] 'VERTICAL',
	--[[ minColor    ]] CreateColor((r + base) * mult, (g + base) * mult, (b + base) * mult, startA),
	--[[ maxColor    ]] CreateColor(1 - (r + base) * mult, 1 - (g + base) * mult, 1 - (b + base) * mult, endA);
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
	function env.ConvertDriver(driver)
		for key, rep in pairs(ModReplacements) do
			driver = driver:gsub(key, rep)
		end
		driver = driver:gsub('%b[]', function(capture)
			return capture:gsub('%s', '')
		end)
		return (driver:gsub('%[mod:%]', '[nomod]'))
	end
end

function env.MakeMacroDriverDesc(text, outcome, condition, state, simple, arguments, states)
	text = L(text);

	local function MakeBulletList(topic, args, color)
		local list = NORMAL_FONT_COLOR:WrapTextInColorCode(L(topic)..':')
		for arg, desc in db.table.spairs(args) do
			list = ('%s\n• %s - %s'):format(list, color:WrapTextInColorCode(arg), L(desc));
		end
		return list;
	end

	if condition and state then
		text = ('%s\n\n%s\n[%s] %s; ...'):format(text,
			NORMAL_FONT_COLOR:WrapTextInColorCode(L'Format'..':'),
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
		text = ('%s\n\n%s\n%s'):format(text, NORMAL_FONT_COLOR:WrapTextInColorCode(L'Outcome'..':'), outcome);
	end
	return text;
end

---------------------------------------------------------------
do -- Binding data handler
	-----------------------------------------------------------
	local TOOLTIP_LINE_LEN = 50;

	function env.GetBindingIcon(binding)
		return db.Bindings.Icons[binding];
	end

	function env.GetBindingName(binding)
		return _G['BINDING_NAME_'..binding] or binding;
	end

	function env.GetXMLBindingInfo(binding)
		local desc, image, name, texture = db.Bindings:GetDescriptionForBinding(binding, true, TOOLTIP_LINE_LEN)
		local tooltip = ('%s%s%s'):format(
			WHITE_FONT_COLOR:WrapTextInColorCode(name or binding),
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
		local desc  = emulation and CPAPI.FormatLongText(emulation.desc, TOOLTIP_LINE_LEN) or 'This button is not bound to any action.';
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
env.State   = GenerateClosure(format, '_onstate-%s');     -- macro conditional response
env.Driver  = GenerateClosure(format, 'driver-%s');       -- macro conditional driver
env.Update  = GenerateClosure(format, '_childupdate-%s'); -- child update closure
env.OnState = 'OnStateChanged';                           -- see LibActionButton-1.0.lua
env.OnPage  = 'ActionPageChanged';                        -- see Pager.lua
env.Visible = 'visibility';
env.Hidden  = 'statehidden';