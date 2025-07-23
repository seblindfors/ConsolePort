---------------------------------------------------------------
-- LED Handler
---------------------------------------------------------------
local _, db = ...;
local LED, Modes = CPAPI.CreateEventHandler({'Frame', '$parentLEDHandler', ConsolePort}), CPAPI.Enum(
	'Faction', -- Default mode
	'Target',  -- Uses the target's class color
	'Player',  -- Uses the player's class color
	'RGB',     -- Cycles through RGB colors
	'Custom',  -- Uses a custom color defined in settings
	'Off'      -- Turns the LED off (black color)
);

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local SetLedColor = C_GamePad.SetLedColor or nop;
local ClearLedColor = C_GamePad.ClearLedColor or nop;
local GetClassColor = C_ClassColor and C_ClassColor.GetClassColor or GetClassColorObj;
local UnitClass, select = UnitClass, select;
local BLACK = BLACK_FONT_COLOR or CreateColor(0, 0, 0, 1);

local function GetClassColorObjForUnit(unit)
	local class = select(2, UnitClass(unit));
	if class then
		return GetClassColor(class);
	end
	return BLACK;
end

---------------------------------------------------------------
-- Handler
---------------------------------------------------------------

LED[Modes.Faction] = function()
	-- The default mode is Faction, which is handled by the gamepad API.
	ClearLedColor()
end;

LED[Modes.Target] = function(self)
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	function self:PLAYER_TARGET_CHANGED()
		SetLedColor(GetClassColorObjForUnit('target'));
	end
	self:PLAYER_TARGET_CHANGED()
end;

LED[Modes.Player] = function(self)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	function self:PLAYER_ENTERING_WORLD()
		SetLedColor(GetClassColorObjForUnit('player'));
	end
	self:PLAYER_ENTERING_WORLD()
end;

LED[Modes.RGB] = function(self)
	local t, i, p, c, w, m = 0, 0, 0, 128, 127, 180;
	local color = CreateColor(0, 0, 0, 1);
	local hz, sin = (math.pi*2) / m, math.sin;
	local r, g, b;
	self:SetScript('OnUpdate', function(_, e)
		t = t + e;
		if t > 0.1 then
			i = i + 1;
			r = (sin((hz * i) + 0 + p) * w + c) / 255;
			g = (sin((hz * i) + 2 + p) * w + c) / 255;
			b = (sin((hz * i) + 4 + p) * w + c) / 255;
			if i > m then
				i = i - m;
			end
			t = 0;
			color:SetRGB(r, g, b);
			SetLedColor(color);
		end
	end)
end;

LED[Modes.Custom] = function()
	SetLedColor(CPAPI.CreateColorFromHexString(db('LEDColor')))
end;

LED[Modes.Off] = function()
	-- Black will result in the LED being turned off.
	SetLedColor(BLACK)
end;

---------------------------------------------------------------
-- Data loading
---------------------------------------------------------------
function LED:OnDataLoaded()
	self:SetScript('OnUpdate', nil)
	self:UnregisterAllEvents()
	self:RegisterEvent('GAME_PAD_CONNECTED')

	local mode = self[db('LEDMode')];
	if not mode then
		-- Default to Faction if the mode is not recognized.
		mode = self[Modes.Faction];
	end
	securecallfunction(mode, self);
	return CPAPI.KeepMeForLater;
end

LED.GAME_PAD_CONNECTED = LED.OnDataLoaded;
db:RegisterCallbacks(LED.OnDataLoaded, LED,
	'Settings/LEDMode',
	'Settings/LEDColor'
);