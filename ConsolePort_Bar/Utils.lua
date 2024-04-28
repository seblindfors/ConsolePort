local env = LibStub('RelaTable')(...)
env.db        = ConsolePort:DB();
env.UIHandler = CPAPI.CreateEventHandler({'Frame'}, {
	-- events go here
}); local UIHandler = env.UIHandler;

UIHandler:Hide()
function UIHandler:OnDataLoaded()
	self:HideBlizzard()
	env:TriggerEvent('OnEnvLoaded')
end

E = env -- debug

---------------------------------------------------------------
-- Libs
---------------------------------------------------------------
env.LIB = LibStub('ConsolePortActionButton')
env.LAB = LibStub('LibActionButton-1.0')

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
		if not _G[VAR_LAYOUT] then
			_G[VAR_LAYOUT] = env:GetDefaultLayout()
		end

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

	env:RegisterCallback('OnEnvLoaded', env.OnEnvLoaded, env)
end -- Data handler

---------------------------------------------------------------
do -- Widget factory
	-----------------------------------------------------------
	env.Factories, env.Widgets, env.ActiveWidgets = {}, {}, {};

	local function HideAndClearAnchors(widget)
		widget:Hide()
		widget:ClearAllPoints()
	end

	function env:AddFactory(type, factory)
		self.Factories[type] = factory;
	end

	function env:Acquire(...)
		return securecallfunction(self.Factory, self, ...)
	end

	function env:Factory(frameType, id, ...)
		assert(self.Factories[frameType], 'Factory does not exist: '..frameType)
		assert(type(id) == 'string', 'Factory widget ID must be a string')
		local signature = self.MakeSig(frameType, id);
		if not self.Widgets[signature] then
			self.Widgets[signature] = self.Factories[frameType](id, ...);
		end
		self.ActiveWidgets[self.Widgets[signature]] = signature;
		return self.Widgets[signature];
	end

	function env:Map(frameType, id, func, ...)
		local signature = '^'..self.MakeSig(frameType, id);
		for widget, sig in pairs(self.ActiveWidgets) do
			if sig:find(signature) then
				func(widget, ...);
			end
		end
	end

	function env:GetSignature(widget)
		return self.ActiveWidgets[widget];
	end

	function env:IsActive(widget)
		return not not self.ActiveWidgets[widget];
	end

	function env:Release(widget, release)
		self.ActiveWidgets[widget] = nil;
		(release or HideAndClearAnchors)(widget);
		if widget.OnRelease then
			widget:OnRelease();
		end
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

function env:GetColorGradient(r, g, b, a) a = a or 1;
	local base, mult = 0.15, 1.2;
	local startA, endA = 0.25 * a, 0;
	return -- SetGradient
	--[[ orientation ]] 'VERTICAL',
	--[[ minColor    ]] CreateColor((r + base) * mult, (g + base) * mult, (b + base) * mult, startA),
	--[[ maxColor    ]] CreateColor(1 - (r + base) * mult, 1 - (g + base) * mult, 1 - (b + base) * mult, endA);
end

function env.GetAsset(asset, arg1, ...)
	return [[Interface\AddOns\ConsolePort_Bar\Assets\]]
	..(arg1 and asset:format(arg1, ...) or asset);
end

function env.MakeID(name, ...)
	return name:format(...):gsub('-', '_'):gsub('_$', '')
end

function env.MakeSig(type, id)
	return type..':'..(id or '');
end

---------------------------------------------------------------
do -- Binding data handler
	-----------------------------------------------------------
	local TOOLTIP_LINE_LEN = 50;

	function env.GetBindingIcon(binding)
		return env.db.Bindings.Icons[binding];
	end

	function env.GetBindingName(binding)
		return _G['BINDING_NAME_'..binding] or binding;
	end

	function env.GetXMLBindingInfo(binding)
		local desc, image, name, texture = env.db.Bindings:GetDescriptionForBinding(binding, true, TOOLTIP_LINE_LEN)
		local tooltip = ('%s%s%s'):format(
		WHITE_FONT_COLOR:WrapTextInColorCode(name),
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

end -- Binding data handler