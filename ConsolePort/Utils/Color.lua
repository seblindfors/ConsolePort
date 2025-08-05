---------------------------------------------------------------
-- Colors
---------------------------------------------------------------
CPAPI.WebColors = {
	DEATHKNIGHT =  '05131c';
	DEMONHUNTER =  '141c0d';
	DRUID       =  '0f1a16';
	EVOKER      =  '2d1420';
	HUNTER      =  '061510';
	MAGE        =  '140e1a';
	MONK        =  '0e1003';
	PALADIN     =  '140613';
	PRIEST      =  '171b27';
	ROGUE       =  '0d0c12';
	SHAMAN      =  '01000e';
	WARLOCK     =  '1c0905';
	WARRIOR     =  '221411';
};

function CPAPI.GetWebColor(classFile, addAlpha)
	return CreateColor(CPAPI.Hex2RGB(CPAPI.WebColors[classFile]..(addAlpha or ''), true))
end

function CPAPI.GetClassColor(classFile)
	return GetClassColor(classFile or CPAPI.GetClassFile())
end

function CPAPI.GetMutedClassColor(factor, asObject, classFile)
	local r, g, b = CPAPI.GetMutedColor(factor, CPAPI.GetClassColor(classFile))
	if asObject then
		return CreateColor(r, g, b)
	end
	return r, g, b, 1;
end

function CPAPI.GetClassColorObject(classFile)
	if C_ClassColor then
		return C_ClassColor.GetClassColor(classFile or CPAPI.GetClassFile())
	end
	local r, g, b = CPAPI.GetClassColor(classFile)
	return CreateColor(r, g, b)
end

function CPAPI.GetPlayerName(classColored, unit) unit = unit or 'player';
	local name = UnitName(unit)
	if classColored then
		return GetClassColorObj(select(2, UnitClass(unit))):WrapTextInColorCode(name)
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

function CPAPI.HSV2RGB(h, s, v)
	local chroma = v * s;
	local hue = h / 60;
	local x = chroma * (1 - math.abs(hue % 2 - 1));
	local r, g, b = 0, 0, 0;
	if
		hue < 1 then r, g, b = chroma, x, 0; elseif
		hue < 2 then r, g, b = x, chroma, 0; elseif
		hue < 3 then r, g, b = 0, chroma, x; elseif
		hue < 4 then r, g, b = 0, x, chroma; elseif
		hue < 5 then r, g, b = x, 0, chroma;
		else         r, g, b = chroma, 0, x;
	end

	local m = v - chroma;
	return r + m, g + m, b + m;
end

function CPAPI.RGB2HSV(r, g, b)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local delta, h, s, v = max - min, 0, 0, max;
    if delta ~= 0 then
        h = max == r and (g - b) / delta
		or max == g and 2 + (b - r) / delta
		or 4 + (r - g) / delta;
        h = (h * 60 + 360) % 360;
        s = delta / max;
    end
    return h, s, v;
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
	return r + diff, g + diff, b + diff, tonumber(a) and a or 1;
end

function CPAPI.GetMutedColor(factor, ...)
	local r, g, b, a = CPAPI.NormalizeColor(...)
	return r * factor, g * factor, b * factor, a;
end

function CPAPI.XY2Polar(x, y)
	local r = math.sqrt(x*x + y*y)
	local theta = math.atan2(y, x)
	return r, theta;
end

function CPAPI.Rad2Deg(rad)
    return ((rad + math.pi) / (2 * math.pi)) * 360;
end