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

CPAPI.SecureEnvironmentMixin = {
	CreateEnvironment = function(self, newEnv)
		if newEnv then
			self.Env = CreateFromMixins(self.Env or {}, newEnv)
		end
		for func, body in pairs(self.Env) do
			body = CPAPI.ConvertSecureBody(body);
			self:SetAttribute(func, body)
			self:Execute(('%s = self:GetAttribute("%s")'):format(func, func))
		end
	end;
	Wrap = function(self, scriptHandler, body)
		return self:WrapScript(self, scriptHandler, CPAPI.ConvertSecureBody(body))
	end;
}

CPAPI.AdvancedSecureMixin = CreateFromMixins(CPAPI.SecureExportMixin, CPAPI.SecureEnvironmentMixin, {
	Parse = function(self, body, args)
		local backup = {};
		for key, value in pairs(args) do
			backup[key] = self:GetAttribute(key)
			self:SetAttribute(tostring(key), value)
			body = body:gsub(
				('{%s}'):format(key),
				([[self:GetAttribute('%s')]]):format(key)
			);
		end
		self:Execute(body)
		for key, value in pairs(args) do
			self:SetAttribute(key, backup[key])
		end
		return body;
	end;
})

---------------------------------------------------------------
-- Tools
---------------------------------------------------------------
function CPAPI.CreateFrame(...)
	return Mixin(CreateFrame(...), CPAPI.DisplayMixin)
end

function CPAPI.CreateEventHandler(args, events, ...)
	local handler = db.table.mixin(CreateFrame(unpack(args)), ...)
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
-- Secure environment translation
---------------------------------------------------------------
do	local ConvertSecureBody, GetSecureBodySignature, GetNewtableSignature;
	function GetSecureBodySignature(obj, func, args)
		return ConvertSecureBody(
			('%s:RunAttribute(\'%s\'%s%s)'):format(
				obj, func, args:trim():len() > 0 and ', ' or '', args));
	end

	function GetNewtableSignature(contents)
		return ('newtable(%s)'):format(contents:sub(2, -2))
	end

	function ConvertSecureBody(body)
		return (body
			:gsub('(%w+)::(%w+)%((.-)%)', GetSecureBodySignature)
			:gsub('%b{}', GetNewtableSignature)
		);
	end

	CPAPI.ConvertSecureBody = ConvertSecureBody;
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

function CPAPI.GetClassColorObject(classFile)
	if C_ClassColor then
		return C_ClassColor.GetClassColor(classFile or CPAPI.GetClassFile())
	end
	local r, g, b = CPAPI.GetClassColor(classFile)
	return CreateColor(r, g, b)
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
	--	edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
	Opaque = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_Noise]]);
	--	edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		tile     = true;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
	Frame = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\Edgefile.blp]]);
		edgeSize = 8;
		tile     = true;
		insets   = {left = 8, right = 8, top = 8, bottom = 8};
	};
	Simple = {
	--	bgFile   = CPAPI.GetAsset([[Textures\Frame\Gradient_Alpha_Horizontal]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
	Popup = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Backdrop_Black_Transparent.blp]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgefileTalkbox.blp]]);
		edgeTile = false;
		edgeSize = 10;
		insets   = {left = 10, right = 10, top = 10, bottom = 10};
	};
}

---------------------------------------------------------------
-- Asset atlas
---------------------------------------------------------------
CPAPI.Atlas = {
	['banner-bottom'] = {200, 64, 0.89892578125, 0.99658203125, 0.0009765625, 0.0634765625, false, false};
	['banner-middle'] = {200, 194, 0.41064453125, 0.50830078125, 0.6220703125, 0.8115234375, false, false};
	['banner-top'] = {200, 49, 0.75146484375, 0.84912109375, 0.0771484375, 0.125, false, false};
	['gendericon-male'] = {56, 56, 0.10595703125, 0.13330078125, 0.9365234375, 0.9912109375, false, false};
	['gendericon-female'] = {56, 56, 0.07763671875, 0.10498046875, 0.9365234375, 0.9912109375, false, false};
	['icon-alliance'] = {184, 200, 0.51318359375, 0.60302734375, 0.0009765625, 0.1962890625, false, false};
	['icon-customize-accessories-selected'] = {156, 158, 0.13720703125, 0.21337890625, 0.8271484375, 0.9814453125, false, false};
	['icon-customize-accessories'] = {156, 158, 0.00048828125, 0.07666015625, 0.8271484375, 0.9814453125, false, false};
	['icon-customize-body-selected'] = {156, 158, 0.51318359375, 0.58935546875, 0.3955078125, 0.5498046875, false, false};
	['icon-customize-body'] = {156, 158, 0.41064453125, 0.48681640625, 0.8134765625, 0.9677734375, false, false};
	['icon-customize-hair-selected'] = {208, 210, 0.41064453125, 0.51220703125, 0.0009765625, 0.2060546875, false, false};
	['icon-customize-hair'] = {208, 210, 0.27392578125, 0.37548828125, 0.7509765625, 0.9560546875, false, false};
	['icon-customize-head-selected'] = {156, 158, 0.51318359375, 0.58935546875, 0.7080078125, 0.8623046875, false, false};
	['icon-customize-head'] = {156, 158, 0.51318359375, 0.58935546875, 0.5517578125, 0.7060546875, false, false};
	['icon-customize-torso-selected'] = {208, 210, 0.41064453125, 0.51220703125, 0.4150390625, 0.6201171875, false, false};
	['icon-customize-torso'] = {208, 210, 0.41064453125, 0.51220703125, 0.2080078125, 0.4130859375, false, false};
	['icon-dice'] = {32, 30, 0.21435546875, 0.22998046875, 0.8916015625, 0.9208984375, false, false};
	['icon-horde'] = {184, 200, 0.51318359375, 0.60302734375, 0.1982421875, 0.3935546875, false, false};
	['ring-alliance'] = {278, 280, 0.00048828125, 0.13623046875, 0.0009765625, 0.2744140625, false, false};
	['ring-customizebackground'] = {246, 246, 0.27392578125, 0.39404296875, 0.2763671875, 0.5166015625, false, false};
	['ring-horde'] = {278, 280, 0.00048828125, 0.13623046875, 0.5517578125, 0.8251953125, false, false};
	['ring-metaldark'] = {278, 280, 0.13720703125, 0.27294921875, 0.2763671875, 0.5498046875, false, false};
	['ring-metallight'] = {278, 280, 0.27392578125, 0.40966796875, 0.0009765625, 0.2744140625, false, false};
	['ring-select'] = {236, 236, 0.27392578125, 0.38916015625, 0.5185546875, 0.7490234375, false, false};
	['vignette-bottom'] = {1, 577, 0.60400390625, 0.6044921875, 0.15625, 0.7197265625, false, false};
	['vignette-sides'] = {703, 1, 0.60400390625, 0.947265625, 0.1533203125, 0.154296875, false, false};
	['vignette-top'] = {1, 451, 0.60546875, 0.60595703125, 0.15625, 0.5966796875, false, false};
	['ring-alliance-disabled'] = {278, 280, 0.00048828125, 0.13623046875, 0.2763671875, 0.5498046875, false, false};
	['ring-metaldark-disabled'] = {278, 280, 0.13720703125, 0.27294921875, 0.5517578125, 0.8251953125, false, false};
	['ring-horde-disabled'] = {278, 280, 0.13720703125, 0.27294921875, 0.0009765625, 0.2744140625, false, false};
	['tooltip-background'] = {1, 1, 0.044921875, 0.04541015625, 0.9833984375, 0.984375, false, false};
	['tooltip-corner'] = {68, 68, 0.07763671875, 0.11083984375, 0.8271484375, 0.8935546875, false, false};
	['tooltip-side'] = {1, 68, 0.21435546875, 0.21484375, 0.9228515625, 0.9892578125, false, false};
	['tooltip-top'] = {1, 68, 0.2158203125, 0.21630859375, 0.9228515625, 0.9892578125, false, false};
	['ring-racialtrait'] = {38, 38, 0.11181640625, 0.13037109375, 0.8271484375, 0.8642578125, false, false};
	['customize-dropdownbox'] = {300, 76, 0.60400390625, 0.75048828125, 0.0009765625, 0.0751953125, false, false};
	['customize-palette'] = {84, 20, 0.21435546875, 0.25537109375, 0.8271484375, 0.8466796875, false, false};
	['customize-dropdown-linemouseover-middle'] = {1, 40, 0.13525390625, 0.1357421875, 0.8955078125, 0.9345703125, false, false};
	['customize-dropdown-linemouseover-side'] = {12, 40, 0.12841796875, 0.13427734375, 0.8955078125, 0.9345703125, false, false};
	['customize-dropdownbox-hover'] = {300, 76, 0.75146484375, 0.89794921875, 0.0009765625, 0.0751953125, false, false};
	['customize-dropdownbox-open'] = {300, 76, 0.60400390625, 0.75048828125, 0.0771484375, 0.1513671875, false, false};
	['customize-palette-selected'] = {102, 40, 0.07763671875, 0.12744140625, 0.8955078125, 0.9345703125, false, false};
	['customize-palette-glow'] = {84, 20, 0.21435546875, 0.25537109375, 0.8486328125, 0.8681640625, false, false};
	['customize-palette-half'] = {84, 20, 0.21435546875, 0.25537109375, 0.8701171875, 0.8896484375, false, false};
	['vignette-sides-widescreen'] = {89, 1, 0.00048828125, 0.0439453125, 0.9833984375, 0.984375, false, false};
	['reset-button'] = {34, 34, 0.9375, 0.9541015625, 0.94140625, 0.974609375, false, false};
}

function CPAPI.SetAtlas(object, atlas, useAtlasSize, flipHoriz, flipVert)
	local atlasInfo = CPAPI.Atlas[atlas];
	if atlasInfo then
		local width, height, leftTX, rightTX, topTX, bottomTX,
			tilesHorizontally, tilesVertically = unpack(atlasInfo)
		if useAtlasSize then
			object:SetSize(width, height)
		end
		object:SetTexture(CPAPI.GetAsset([[Textures\Frame\General_Atlas]]))
		object:SetTexCoord(
			flipHoriz and rightTX or leftTX,
			flipHoriz and leftTX or rightTX,
			flipVert and bottomTX or topTX,
			flipVert and topTX or bottomTX
		);
		object:SetHorizTile(tilesHorizontally)
		object:SetVertTile(tilesVertically)
		return true;
	end
end