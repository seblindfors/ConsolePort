---------------------------------------------------------------
-- Theme.lua: Controller theme loader
---------------------------------------------------------------
-- Provides controller specific textures and tooltip lines.

local _, db = ...
local TEXTURE_PATH = [[Interface\AddOns\ConsolePort\Controllers\%s\Icons%d\%s]]
local TEXTURE_ESC = '|T%s:24:24:0:0|t'

local function LoadTooltipLines()
	local tooltipLoc = db.TOOLTIP
	---------------------------------
	local Left = db.Mouse and db.Mouse.Cursor.Left or 'CP_R_RIGHT'
	local Right = db.Mouse and db.Mouse.Cursor.Right or 'CP_R_LEFT'
	local Special = db.Mouse and db.Mouse.Cursor.Special or 'CP_R_UP'
	-- Click strings
	local ICON				= '|T%s:24:24:0:0|t |cFF%s%s|r'
	local ShiftHold 		= format(ICON, db.TEXTURE.CP_M1, '6882A1', '%s')
	local LeftClick 		= format(ICON, db.TEXTURE[Left], db.COLOR[gsub(Left, 'CP_%w_', '')], '%s')
	local RightClick 		= format(ICON, db.TEXTURE[Right], db.COLOR[gsub(Right, 'CP_%w_', '')], '%s')
	local SpecialClick		= format(ICON, db.TEXTURE[Special], db.COLOR[gsub(Special, 'CP_%w_', '')], '%s')
	db.CLICK = {
		COMPARE 			= format(ShiftHold, 	tooltipLoc.COMPARE),
		PICKUP_ITEM 		= format(LeftClick, 	tooltipLoc.PICKUP_ITEM),
		QUEST_TRACKER 		= format(LeftClick, 	tooltipLoc.QUEST_TRACKER),
		USE_NOCOMBAT 		= format(LeftClick, 	tooltipLoc.USE_NOCOMBAT),
		BUY 				= format(RightClick, 	tooltipLoc.BUY),
		USE 				= format(RightClick, 	tooltipLoc.USE),
		EQUIP				= format(RightClick, 	tooltipLoc.EQUIP),
		SELL 				= format(RightClick, 	tooltipLoc.SELL),
		QUEST_DETAILS 		= format(RightClick, 	tooltipLoc.QUEST_DETAILS),
		PICKUP 				= format(SpecialClick, 	tooltipLoc.PICKUP),
		CANCEL 				= format(SpecialClick, 	tooltipLoc.CANCEL),
		ITEM_MENU			= format(SpecialClick,  tooltipLoc.ITEM_MENU),
		STACK_BUY 			= format(SpecialClick, 	tooltipLoc.STACK_BUY),
		STACK_SPLIT 		= format(SpecialClick, 	tooltipLoc.STACK_SPLIT),
		ADD_TO_EXTRA		= format(SpecialClick, 	tooltipLoc.ADD_TO_EXTRA),
		MAP_CANVAS_ZOOM_IN	= format(SpecialClick, 	tooltipLoc.MAP_CANVAS_ZOOM_IN),
		MAP_CANVAS_ZOOM_OUT	= format(SpecialClick, 	tooltipLoc.MAP_CANVAS_ZOOM_OUT),
	}
end

local function LoadTriggerTextures(ctrlType, cfg, shared)
	-- Trigger textures
	local t = {
		[1] = cfg.CP_T1 or 'CP_TR1',
		[2] = cfg.CP_T2 or 'CP_TR2',
		[3] = cfg.CP_T3 or 'CP_L_GRIP',
		[4] = cfg.CP_T4 or 'CP_R_GRIP',
	}
	-- Arbitrary buttons
	for i=#t, 8 do
		t[i] = cfg['CP_T' .. i]
	end
	-- Modifiers
	local m = {
		[1] = cfg.CP_M1 or 'CP_TL1',
		[2] = cfg.CP_M2 or 'CP_TL2',
	}
	-- Icon sets to format
	local formatConfig = {
		[32] = db.ICONS,
		[64] = db.TEXTURE,
	}
	-- Format the icon sets
	for size, tbl in pairs(formatConfig) do
		for id, bTex in pairs(t) do -- Triggers/grips/arbitrary
			tbl['CP_T' .. id] = format(TEXTURE_PATH, shared[bTex] and 'Shared' or ctrlType, size, bTex)
		end		
		for id, bTex in pairs(m) do -- Modifiers
			tbl['CP_M' .. id] = format(TEXTURE_PATH, shared[bTex] and 'Shared' or ctrlType, size, bTex)
		end
		tbl.CP_T_R3 = format(TEXTURE_PATH, ctrlType, size, 'CP_T_R3') -- right stick
		tbl.CP_T_L3 = format(TEXTURE_PATH, ctrlType, size, 'CP_T_L3') -- left stick
	end
	-- Change global binding names
	for id in pairs(t) do
		_G['BINDING_NAME_CP_T' .. id] = format(TEXTURE_ESC, db.TEXTURE['CP_T' .. id] or '')
	end	
	for id in pairs(m) do
		_G['BINDING_NAME_CP_M' .. id] = format(TEXTURE_ESC, db.TEXTURE['CP_M' .. id] or '')
	end
end

local function PostInitLoadTheme()
	local settings = db.Settings
	local ctrlType = settings and strupper(settings.type) or 'PS4'
	LoadTriggerTextures(ctrlType, settings or {}, db.Controller and db.Controller.Shared or {})
	LoadTooltipLines()
end

function ConsolePort:LoadControllerTheme()
	local settings = db.Settings
	local ctrlType = settings and strupper(settings.type) or 'PS4'
	----------------------------------
	-- OnLoad chunk, only runs once
	----------------------------------
	-- Controller specific
	----------------------------------
	db.Controller = db.Controllers[ctrlType]
	db.Layout = db.Controller.Layout
	db.COLOR = db.Controller.Color
	----------------------------------

	-- Global binding headers
	for name, description in pairs(db.HEADERS) do
		_G['BINDING_HEADER_'..name] = description
	end
	-- Invisible bindings
	for name, description in pairs(db.CUSTOMBINDS) do
		_G['BINDING_NAME_'..name] = description
	end
	-- Button textures
	local shared = db.Controller.Shared or {}
	for name in self:GetBindings() do
		db.TEXTURE[name] = format(TEXTURE_PATH, shared[name] and 'Shared' or ctrlType, 64, name)
		db.ICONS[name] = format(TEXTURE_PATH, shared[name] and 'Shared' or ctrlType, 32, name)
		_G['BINDING_NAME_'..name] = format(TEXTURE_ESC, db.TEXTURE[name])
	end

	-- Center icon fix for presets without guide button
	db.TEXTURE.CP_X_CENTER = format(TEXTURE_PATH, ctrlType, 64, 'CP_X_CENTER')

	----------------------------------
	-- Set globals for click bindings
	----------------------------------
	for _, info in pairs(self:GetCustomBindings()) do
		if info.binding and info.binding:match('CLICK') then
			_G['BINDING_NAME_'..info.binding] = info.name
		end
	end
	----------------------------------
	self.LoadControllerTheme = PostInitLoadTheme
	----------------------------------

	LoadTriggerTextures(ctrlType, settings or {}, db.Controller and db.Controller.Shared or {})
	LoadTooltipLines()
end

db.Hex2RGB = function(hex, fractal)
    hex = hex:gsub('#','')
    local div = fractal and 255 or 1
    return 	( (tonumber(hex:sub(1,2), 16) or div) / div ), -- R
    		( (tonumber(hex:sub(3,4), 16) or div) / div ), -- G
    		( (tonumber(hex:sub(5,6), 16) or div) / div ), -- B
    		( (tonumber(hex:sub(7,8), 16) or div) / div ); -- A
end

function ConsolePort:GetControllerTexture() 
	return ([[Interface\AddOns\ConsolePort\Controllers\%s\Front]]):format(db('type') or 'PS4')
end