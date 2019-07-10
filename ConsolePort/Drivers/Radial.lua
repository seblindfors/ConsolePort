---------------------------------------------------------------
-- Radial.lua: Handles radial input (left stick / movement)
---------------------------------------------------------------
local bor = bit.bor
----------------------------------
local BIT = {
    -- Directions:
    UP    = 0x00000001;
    DOWN  = 0x00000002;
    LEFT  = 0x00000004;
    RIGHT = 0x00000008;
    -- Axis dominant:
    HORZ  = 0x00000010;
    VERT  = 0x00000020;
}

local BINDINGS = {
    UP    = {'W', 'UP'};
    DOWN  = {'S', 'DOWN'};
    LEFT  = {'A', 'LEFT'};
    RIGHT = {'D', 'RIGHT'};
    HORZ  = {'H'};
    VERT  = {'V'};
}

local MOVEMENT = {
    UP    = 'MOVEFORWARD';
    DOWN  = 'MOVEBACKWARD';
    LEFT  = 'STRAFELEFT';
    RIGHT = 'STRAFERIGHT';
}

local KEY = {
    W = BIT.UP;    UP    = BIT.UP;
    S = BIT.DOWN;  DOWN  = BIT.DOWN; 
    A = BIT.LEFT;  LEFT  = BIT.LEFT;
    D = BIT.RIGHT; RIGHT = BIT.RIGHT;
    -----------------------------------
    H = BIT.HORZ; V = BIT.VERT;
}

local BITS_TO_ANGLE = {
    [BIT.LEFT]                           = 0;
    [BIT.UP]                             = 90;
    [BIT.RIGHT]                          = 180;
    [BIT.DOWN]                           = 270;
    ---------------------------------------------
    [bor(BIT.UP, BIT.LEFT)]              = 45;
    [bor(BIT.UP, BIT.RIGHT)]             = 135; 
    [bor(BIT.DOWN, BIT.RIGHT)]           = 225;
    [bor(BIT.DOWN, BIT.LEFT)]            = 315;
    ---------------------------------------------
    [bor(BIT.UP, BIT.LEFT, BIT.HORZ)]    = 22.5;
    [bor(BIT.UP, BIT.LEFT, BIT.VERT)]    = 67.5;
    [bor(BIT.UP, BIT.RIGHT, BIT.VERT)]   = 112.5;
    [bor(BIT.UP, BIT.RIGHT, BIT.HORZ)]   = 157.5;
    ---------------------------------------------
    [bor(BIT.DOWN, BIT.RIGHT, BIT.HORZ)] = 202.5;
    [bor(BIT.DOWN, BIT.RIGHT, BIT.VERT)] = 247.5;
    [bor(BIT.DOWN, BIT.LEFT, BIT.VERT)]  = 292.5;
    [bor(BIT.DOWN, BIT.LEFT, BIT.HORZ)]  = 337.5;
}
--[[
local buttons = {
    ['UP']      = {'W', 'UP'},
    ['LEFT']    = {'A', 'LEFT'},
    ['DOWN']    = {'S', 'DOWN'},
    ['RIGHT']   = {'D', 'RIGHT'},
}
---------------------------------------------------------------
for direction, keys in pairs(buttons) do
    for _, key in pairs(keys) do
        local button = CreateFrame('Button', 'ConsolePortUtilityButton'..key, Utility, 'SecureHandlerClickTemplate')
        button:RegisterForClicks('LeftButtonDown', 'LeftButtonUp')
        button:SetAttribute('_onclick', ("self:GetParent():RunAttribute('_onkey', '%s', down)"):format(direction))
    end
end
]]