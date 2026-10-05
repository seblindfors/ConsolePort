local _, env = ...;
---------------------------------------------------------------
-- Serializer
---------------------------------------------------------------
-- Export strings open with a format marker. Everything else is
-- read by the legacy decoder.

local FORMAT = '!1';
local EncodingUtil, Enum = C_EncodingUtil, Enum;
local pcall, gsub, strsub = pcall, string.gsub, string.sub;

local function Encode(data)
	local cbor   = EncodingUtil.SerializeCBOR(data);
	local packed = EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize);
	return FORMAT .. EncodingUtil.EncodeBase64(packed, Enum.Base64Variant.StandardUrlSafe);
end

local function Decode(text)
	local packed = EncodingUtil.DecodeBase64(strsub(text, #FORMAT + 1), Enum.Base64Variant.StandardUrlSafe);
	local cbor   = packed and EncodingUtil.DecompressString(packed, Enum.CompressionMethod.Deflate);
	return cbor and EncodingUtil.DeserializeCBOR(cbor);
end

function env.Serialize(data)
	return Encode(data);
end

function env.Deserialize(text)
	text = gsub(text or '', '%s', '');
	if ( strsub(text, 1, #FORMAT) == FORMAT ) then
		local ok, data = pcall(Decode, text);
		return ok and data or nil;
	end
	return env.LegacyDeserialize(text);
end
