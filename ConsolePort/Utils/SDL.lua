SDL = {};
---------------------------------------------------------------
-- SDL Mappings
---------------------------------------------------------------
---@enum SDL.HardwareBus
SDL.HardwareBus = {
	USB         = 0x03;
	Bluetooth   = 0x05;
	Virtual     = 0xFF;
};

---@class SDL.GUID
---@field bus number
---@field vendorID number|string
---@field productID number|string
---@field revision number|string

---@alias SDL.ButtonMap table<string, string>

---@class SDL.Mapping
---@field name string
---@field guid SDL.GUID
---@field mapping string
---@field platform Enum.ClientPlatformType

function SDL.BigLittleEndian(hex)
	hex = ('%08x'):format(type(hex) == 'string' and tonumber(hex, 16) or hex);
	local littleEndian = '';
	for i = #hex, 1, -2 do
		littleEndian = littleEndian .. hex:sub(i-1, i)
	end
	print(hex, littleEndian);
	return littleEndian;
end

---@param guid SDL.GUID
---@return string guid <bus><vendorID><productID><revision> 
function SDL.MakeSDLGUID(guid)
	return table.concat({
		SDL.BigLittleEndian(guid.bus or SDL.HardwareBus.USB),
		SDL.BigLittleEndian(guid.vendorID),
		SDL.BigLittleEndian(guid.productID),
		SDL.BigLittleEndian(guid.revision or 0),
	}, ''):lower();
end

function SDL.MakeConfig(mapping)
	local config = {};
	for id, value in pairs(mapping) do
		config[#config + 1] = ('%s:%s'):format(id, value);
	end
	return table.concat(config, ',');
end

---@param name string
---@param guid SDL.GUID
---@param mapping SDL.ButtonMap
---@return string
function SDL.MakeSDLMapping(name, guid, mapping)
	return table.concat({
		SDL.MakeSDLGUID(guid),
		name,
		SDL.MakeConfig(mapping)
	}, ',') .. ',';
end

---@param name string
---@param guid SDL.GUID
---@param mapping SDL.ButtonMap
---@param platform Enum.ClientPlatformType
---@return boolean success
function SDL.AddSDLMapping(name, guid, mapping, platform)
	local entry = SDL.MakeSDLMapping(name, guid, mapping);
	print(entry);
	return C_GamePad.AddSDLMapping(platform or Enum.ClientPlatformType.Windows, entry);
end

-- Generates:
-- 050000004c050000f20d000000010000,DualSense Edge Wireless,paddle2:b15,b:b1,leftstick:b7,dpleft:h0.8,leftx:a0,leftshoulder:b9,lefty:a1,a:b0,righttrigger:a5,touchpad:b11,rightx:a2,rightshoulder:b10,lefttrigger:a4,righty:a3,start:b6,y:b3,x:b2,dpup:h0.1,paddle4:b13,dpright:h0.2,paddle1:b16,rightstick:b8,paddle3:b14,dpdown:h0.4,guide:b5,misc1:b12,back:b4,
SDL.AddDS5Edge = function()
	return SDL.AddSDLMapping('DualSense Edge Wireless', {
		bus       = SDL.HardwareBus.Bluetooth,
		vendorID  = 0x054C,
		productID = 0x0DF2,
		revision  = 0x100,
	}, {
		a = 'b0',
		b = 'b1',
		x = 'b2',
		y = 'b3',
		back = 'b4',
		guide = 'b5',
		start = 'b6',
		leftstick = 'b7',
		rightstick = 'b8',
		leftshoulder = 'b9',
		rightshoulder = 'b10',
		touchpad = 'b11',
		misc1 = 'b12',
		paddle4 = 'b13',
		paddle3 = 'b14',
		paddle2 = 'b15',
		paddle1 = 'b16',
		dpdown = 'h0.4',
		dpleft = 'h0.8',
		dpright = 'h0.2',
		dpup = 'h0.1',
		leftx = 'a0',
		lefty = 'a1',
		rightx = 'a2',
		righty = 'a3',
		lefttrigger = 'a4',
		righttrigger = 'a5',
	});
end