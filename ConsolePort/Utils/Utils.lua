local _, db = ...;
---------------------------------------------------------------
-- Mixins
---------------------------------------------------------------
-- Frame wrapper, provide backwards compat in widgets
CPAPI.DisplayMixin = {
	SetBackdrop = function(self, ...)
		if BackdropTemplateMixin then
			if not self.OnBackdropLoaded then 
				Mixin(self, BackdropTemplateMixin)
				self:HookScript('OnSizeChanged', self.OnBackdropSizeChanged)
			end
			BackdropTemplateMixin.SetBackdrop(self, ...)
		else
			getmetatable(self).__index.SetBackdrop(self, ...)
		end
	end;
};

-- Event handler mixin
CPAPI.EventMixin = {
	OnEvent = function(self, event, ...)
		if self[event] then
			self[event](self, ...)
		end
	end;
	ADDON_LOADED = function(self, ...)
		self:UnregisterEvent('ADDON_LOADED')
		if self.OnDataLoaded then
			self:OnDataLoaded(...)
		end
	end;
}

CPAPI.SecureExportMixin = {
	Export = function(self, body, ...)
		assert(not InCombatLockdown())
		local signature, args = '', {...};
		for i, arg in ipairs(args) do
			local isN = tonumber(arg) or (arg == true or arg == false)
			signature = signature .. (isN and arg or ('"%s"'):format(tostring(arg)));
			if i < #args then
				signature = signature .. ',';
			end
		end
		self:Execute(([[
			local returns = newtable(self:RunAttribute("%s", %s))
			for i, v in ipairs(returns) do
				self:SetAttribute(tostring(i), v)
			end
			self:SetAttribute('n', #returns)
		]]):format(body, signature))
		local values = {}
		for i=1, self:GetAttribute('n') do
			values[i] = self:GetAttribute(tostring(i))
			self:SetAttribute(tostring(i), nil)
		end
		self:SetAttribute('n', nil)
		return unpack(values)
	end;
}

---------------------------------------------------------------
-- Tools
---------------------------------------------------------------
function CPAPI.CreateFrame(...)
	return Mixin(CreateFrame(...), CPAPI.DisplayMixin)
end

function CPAPI.CreateEventHandler(args, events, ...)
	local handler = db('table/mixin')(CreateFrame(unpack(args)), ...)
	return CPAPI.EventHandler(handler, events)
end

function CPAPI.EventHandler(handler, events)
	db('table/mixin')(handler, CPAPI.EventMixin)
	if events then
		FrameUtil.RegisterFrameForEvents(handler, events)
		handler.Events = events;
	end
	handler:RegisterEvent('ADDON_LOADED')
	return handler;
end

function CPAPI.Proxy(owner, proxy)
	assert(not C_Widget.IsFrameWidget(owner), 'Attempted to proxy frame widget.')
	local mt = getmetatable(owner) or {};
	mt.__index = proxy;
	return setmetatable(owner, mt)
end

function CPAPI.Lock(object)
	local mt = getmetatable(object) or {};
	mt.__newindex = nop;
	return setmetatable(object, mt)
end

function CPAPI.Start(handler)
	for k, v in pairs(handler) do
		if handler:HasScript(k) then
			if handler:GetScript(k) then
				handler:HookScript(k, v)
			else
				handler:SetScript(k, v)
			end
		end
	end
end

function CPAPI.Popup(id, settings)
	StaticPopupDialogs[id:upper()] = settings;
	local dialog = StaticPopup_Show(id:upper())
	if dialog then
		local icon = _G[dialog:GetName() .. 'AlertIcon']
		local original = icon:GetTexture()
		local onHide = settings.OnHide;
		icon:SetTexture(CPAPI.GetAsset('Textures\\Logo\\CP'))
		settings.OnHide = function(...)
			icon:SetTexture(original)
			if onHide then
				return onHide(...)
			end
		end;
		return dialog;
	end
end

---------------------------------------------------------------
-- Assets
---------------------------------------------------------------
function CPAPI.GetAsset(path)
	return ([[Interface\AddOns\ConsolePort\Assets\%s]]):format(path)
end

function CPAPI.GetClassIcon(class)
	-- returns concatenated icons file with slicing coords
	return [[Interface\TargetingFrame\UI-Classes-Circles]], CLASS_ICON_TCOORDS[class or CPAPI.GetClassFile()]
end

function CPAPI.GetWebClassIcon(class)
	return CPAPI.GetAsset([[Art\Class\Web_Class_Icons_Grid]]), CLASS_ICON_TCOORDS[class or CPAPI.GetClassFile()]
end

---------------------------------------------------------------
-- Colors
---------------------------------------------------------------
CPAPI.WebColors = {
	WARRIOR     =  '221411';
	HUNTER      =  '061510';
	MAGE        =  '140e1a';
	ROGUE       =  '0d0c12';
	PRIEST      =  '171b27';
	WARLOCK     =  '1c0905';
	PALADIN     =  '140613';
	DRUID       =  '0f1a16';
	SHAMAN      =  '01000e';
	MONK        =  '0e1003';
	DEMONHUNTER =  '141c0d';
	DEATHKNIGHT =  '05131c';
};

function CPAPI.GetWebColor(classFile, addAlpha)
	return CreateColor(CPAPI.Hex2RGB(CPAPI.WebColors[classFile]..(addAlpha or ''), true))
end

function CPAPI.GetClassColor(classFile)
	return GetClassColor(classFile or CPAPI.GetClassFile())
end

function CPAPI.GetPlayerName(classColored)
	local name = UnitName('player')
	if classColored then
		return GetClassColorObj(select(2, UnitClass('player'))):WrapTextInColorCode(name)
	end
	return name;
end

function CPAPI.Hex2RGB(hex, fractal)
    hex = hex:gsub('#','')
    local div = fractal and 255 or 1
    return 	( (tonumber(hex:sub(1,2), 16) or div) / div ), -- R
    		( (tonumber(hex:sub(3,4), 16) or div) / div ), -- G
    		( (tonumber(hex:sub(5,6), 16) or div) / div ), -- B
    		( (tonumber(hex:sub(7,8), 16) or div) / div ); -- A
end

function CPAPI.GetMixColorGradient(dir, r, g, b, a, base, multi)
	local add = base or 0.3
	local mul = multi or 1.1
	local alp = a or 1

	return dir,
		0 + (r + add) * mul, 0 + (g + add) * mul, 0 + (b + add) * mul, alp,
		1 - (r - add) * mul, 1 - (g - add) * mul, 1 - (b - add) * mul, alp;
end

function CPAPI.GetReverseMixColorGradient(dir, r, g, b, a, base, multi)
	local add = base or 0.3
	local mul = multi or 1.1
	local alp = a or 1

	return dir,
		1 - (r - add) * mul, 1 - (g - add) * mul, 1 - (b - add) * mul, alp,
		0 + (r + add) * mul, 0 + (g + add) * mul, 0 + (b + add) * mul, alp;
end

function CPAPI.InvertColor(r, g, b)
	return 1-r, 1-g, 1-b;
end

function CPAPI.NormalizeColor(...)
	local high, c = 0
	for i=1, 3 do
		c = select(i, ...)
		if c > high then
			high = c
		end
	end
	local diff = (1 - high)
	local r, g, b, a = ...
	return r + diff, g + diff, b + diff, a;
end

---------------------------------------------------------------
-- Backdrops
---------------------------------------------------------------
CPAPI.Backdrops = {
	Header = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Gradient_Alpha_Horizontal]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
	Opaque = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_Noise]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		tile = true;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
	Frame = {
		bgFile      = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]),
		edgeFile 	= CPAPI.GetAsset([[Textures\Edgefile\Edgefile]]),
		edgeSize 	= 8,
		tile = true,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	};
	Simple = {
	--	bgFile   = CPAPI.GetAsset([[Textures\Frame\Gradient_Alpha_Horizontal]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
}