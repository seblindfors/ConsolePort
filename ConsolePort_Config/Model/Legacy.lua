local _, env = ...;
---------------------------------------------------------------
-- Legacy import
---------------------------------------------------------------
-- Reads strings exported before 3.3.9: a 6-bit packing over a
-- custom alphabet, a Huffman container, and AceSerializer text.
-- Decode only.

local bit_band, bit_lshift, bit_rshift, bit_bor = bit.band, bit.lshift, bit.rshift, bit.bor;
local strbyte, strchar, strsub, gsub, gmatch = string.byte, string.char, string.sub, string.gsub, string.gmatch;
local tconcat, tonumber, error, pcall = table.concat, tonumber, error, pcall;
local huge = math.huge;

---------------------------------------------------------------
-- 6-bit packing
---------------------------------------------------------------
local B64tobyte = {
	a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
	i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
	q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
	y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
	G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
	O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
	W = 48,  X = 49,  Y = 50,  Z = 51,['0']=52,['1']=53,['2']=54,['3']=55,
	['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['(']=62,[')']=63
};

local function Unpack(str)
	local out, n, acc, accLen = {}, 0, 0, 0;
	for i = 1, #str do
		local v = B64tobyte[strsub(str, i, i)];
		if not v then return nil end;
		acc, accLen = acc + bit_lshift(v, accLen), accLen + 6;
		if ( accLen >= 8 ) then
			n = n + 1;
			out[n] = strchar(bit_band(acc, 255));
			acc, accLen = bit_rshift(acc, 8), accLen - 8;
		end
	end
	return tconcat(out, '', 1, n);
end

---------------------------------------------------------------
-- Huffman container
---------------------------------------------------------------
-- Byte 1 is the codec: 1 is raw, 3 is Huffman. Then the leaf
-- count minus one, a 24-bit little-endian length, a symbol table
-- and the code stream, all read one bit at a time, LSB first.
-- A code in the table is escaped: a 0 bit is written as 0, a 1 bit
-- as 1 then 0, and two 1 bits end it.

local function Inflate(data)
	local codec = strbyte(data, 1);
	if ( codec == 1 ) then return strsub(data, 2) end;
	if ( codec ~= 3 ) then return nil end;

	local numLeaves = (strbyte(data, 2) or 0) + 1;
	local size = (strbyte(data, 3) or 0) + (strbyte(data, 4) or 0) * 256 + (strbyte(data, 5) or 0) * 65536;
	if ( size == 0 ) then return '' end;

	local pos, buf, bufLen, dataLen = 6, 0, 0, #data;
	local function ReadBit()
		if ( bufLen == 0 ) then
			if ( pos > dataLen ) then return nil end;
			buf, bufLen, pos = strbyte(data, pos), 8, pos + 1;
		end
		local b = bit_band(buf, 1);
		buf, bufLen = bit_rshift(buf, 1), bufLen - 1;
		return b;
	end

	local map, maxLen = {}, 0;
	for _ = 1, numLeaves do
		local symbol = 0;
		for i = 0, 7 do
			local b = ReadBit();
			if not b then return nil end;
			symbol = symbol + bit_lshift(b, i);
		end
		local code, len = 0, 0;
		while true do
			local b = ReadBit();
			if not b then return nil end;
			if ( b == 0 ) then
				len = len + 1;
			else
				local next = ReadBit();
				if not next then return nil end;
				if ( next == 1 ) then break end;
				code, len = bit_bor(code, bit_lshift(1, len)), len + 1;
			end
			if ( len > 32 ) then return nil end;
		end
		local byLen = map[len];
		if not byLen then byLen = {} map[len] = byLen end;
		byLen[code] = strchar(symbol);
		if ( len > maxLen ) then maxLen = len end;
	end

	local out, n = {}, 0;
	local single = map[0] and map[0][0];
	if single then
		for i = 1, size do out[i] = single end;
		return tconcat(out, '', 1, size);
	end

	local code, len = 0, 0;
	while ( n < size ) do
		local b = ReadBit();
		if not b then return nil end;
		code, len = code + bit_lshift(b, len), len + 1;
		local byLen = map[len];
		local symbol = byLen and byLen[code];
		if symbol then
			n = n + 1;
			out[n] = symbol;
			code, len = 0, 0;
		elseif ( len > maxLen ) then
			return nil;
		end
	end
	return tconcat(out, '', 1, n);
end

---------------------------------------------------------------
-- AceSerializer text
---------------------------------------------------------------
-- Control characters and spaces are noise. Then ^x codes, each
-- followed by its data up to the next ^.

local StringEscapes = {
	['~\122'] = '\030';
	['~\123'] = '\127';
	['~\124'] = '\126';
	['~\125'] = '\94';
};

local function UnescapeString(escape)
	local fixed = StringEscapes[escape];
	if fixed then return fixed end;
	return strchar(strbyte(escape, 2) - 64);
end

local NamedNumbers = {
	['1.#INF']  =  huge;
	['-1.#INF'] = -huge;
	['inf']     =  huge;
	['-inf']    = -huge;
};

local function ReadValue(iter, single, ctl, data)
	if not single then
		ctl, data = iter();
	end
	if not ctl then
		error('missing terminator');
	end
	if ( ctl == '^^' ) then return end;

	local value;
	if ( ctl == '^S' ) then
		value = gsub(data, '~.', UnescapeString);
	elseif ( ctl == '^N' ) then
		value = NamedNumbers[data] or tonumber(data);
		if not value then error('bad number '..data) end;
	elseif ( ctl == '^F' ) then
		local ctl2, exponent = iter();
		if ( ctl2 ~= '^f' ) then error('bad float') end;
		local mantissa = tonumber(data);
		exponent = tonumber(exponent);
		if not ( mantissa and exponent ) then error('bad float') end;
		value = mantissa * (2 ^ exponent);
	elseif ( ctl == '^B' ) then
		value = true;
	elseif ( ctl == '^b' ) then
		value = false;
	elseif ( ctl == '^Z' ) then
		value = nil;
	elseif ( ctl == '^T' ) then
		value = {};
		while true do
			ctl, data = iter();
			if ( ctl == '^t' ) then break end;
			local key = ReadValue(iter, true, ctl, data);
			if ( key == nil ) then error('bad table') end;
			ctl, data = iter();
			local item = ReadValue(iter, true, ctl, data);
			if ( item == nil ) then error('bad table') end;
			value[key] = item;
		end
	else
		error('bad control '..ctl);
	end

	if not single then
		return value, ReadValue(iter);
	end
	return value;
end

local function Unserialize(text)
	text = gsub(text, '[%c ]', '');
	local iter = gmatch(text, '(^.)([^^]*)');
	local ctl = iter();
	if ( ctl ~= '^1' ) then return false end;
	return pcall(ReadValue, iter);
end

---------------------------------------------------------------
-- @param str : legacy export string
-- @return ... : the exported values, or nothing
function env.LegacyDeserialize(str)
	local packed = Unpack(str);
	if not packed then return end;
	local text = Inflate(packed);
	if not text then return end;
	local ok, value = Unserialize(text);
	if not ok then return end;
	return value;
end
