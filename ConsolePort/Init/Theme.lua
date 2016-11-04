---------------------------------------------------------------
-- Theme.lua: Controller theme loader
---------------------------------------------------------------
-- Provides controller specific textures and tooltip lines.

local _, db = ...
local init = true
local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Controllers\\%s\\Icons%s\\%s"
local TEXTURE_ESC = "|T%s:24:24:0:0|t"
local x32, x64 = "32", "64"

local function LoadTooltipLines()
	local Left = db.Mouse and db.Mouse.Cursor.Left or "CP_R_RIGHT"
	local Right = db.Mouse and db.Mouse.Cursor.Right or "CP_R_LEFT"
	local Special = db.Mouse and db.Mouse.Cursor.Special or "CP_R_UP"
	-- Click strings
	local ICON				= "|T%s:24:24:0:0|t |cFF%s%s|r"
	local ShiftHold 		= format(ICON, db.TEXTURE.CP_M1, "6882A1", "%s")
	local LeftClick 		= format(ICON, db.TEXTURE[Left], db.COLOR[gsub(Left, "CP_%w_", "")], "%s")
	local RightClick 		= format(ICON, db.TEXTURE[Right], db.COLOR[gsub(Right, "CP_%w_", "")], "%s")
	local SpecialClick		= format(ICON, db.TEXTURE[Special], db.COLOR[gsub(Special, "CP_%w_", "")], "%s")
	db.CLICK = {
		COMPARE 			= format(ShiftHold, 	db.TOOLTIP.COMPARE),
		PICKUP_ITEM 		= format(LeftClick, 	db.TOOLTIP.PICKUP_ITEM),
		QUEST_TRACKER 		= format(LeftClick, 	db.TOOLTIP.QUEST_TRACKER),
		USE_NOCOMBAT 		= format(LeftClick, 	db.TOOLTIP.USE_NOCOMBAT),
		BUY 				= format(RightClick, 	db.TOOLTIP.BUY),
		USE 				= format(RightClick, 	db.TOOLTIP.USE),
		EQUIP				= format(RightClick, 	db.TOOLTIP.EQUIP),
		SELL 				= format(RightClick, 	db.TOOLTIP.SELL),
		QUEST_DETAILS 		= format(RightClick, 	db.TOOLTIP.QUEST_DETAILS),
		PICKUP 				= format(SpecialClick, 	db.TOOLTIP.PICKUP),
		CANCEL 				= format(SpecialClick, 	db.TOOLTIP.CANCEL),
		STACK_BUY 			= format(SpecialClick, 	db.TOOLTIP.STACK_BUY),
		STACK_SPLIT 		= format(SpecialClick, 	db.TOOLTIP.STACK_SPLIT),
		ADD_TO_EXTRA		= format(SpecialClick, 	db.TOOLTIP.ADD_TO_EXTRA),
		MAP_CANVAS_ZOOM_IN	= format(SpecialClick, 	db.TOOLTIP.MAP_CANVAS_ZOOM_IN),
		MAP_CANVAS_ZOOM_OUT	= format(SpecialClick, 	db.TOOLTIP.MAP_CANVAS_ZOOM_OUT),
	}
end

local function LoadTriggerTextures(ctrlType, settings)
	-- Trigger textures
	local t1, t2, m1, m2
	if settings then
		t1, t2, m1, m2 = settings.CP_T1, settings.CP_T2, settings.CP_M1, settings.CP_M2
	end
	if not t1 or not t2 or not m1 or not m2 then
		t1, t2, m1, m2 = "CP_TR1", "CP_TR2", "CP_TL1", "CP_TL2"
	end
	local formatConfig = {
		[x32] = db.ICONS,
		[x64] = db.TEXTURE,
	}
	for size, tbl in pairs(formatConfig) do
		tbl.CP_T1 = format(TEXTURE_PATH, ctrlType, size, t1)
		tbl.CP_T2 = format(TEXTURE_PATH, ctrlType, size, t2)
		tbl.CP_M1 = format(TEXTURE_PATH, ctrlType, size, m1)
		tbl.CP_M2 = format(TEXTURE_PATH, ctrlType, size, m2)
		tbl.CP_T_R3 = format(TEXTURE_PATH, ctrlType, size, "CP_T_R3")
		tbl.CP_T_L3 = format(TEXTURE_PATH, ctrlType, size, "CP_T_L3")
	end
	-- Change global binding names
	BINDING_NAME_CP_T1 = format(TEXTURE_ESC, db.TEXTURE.CP_T1)
	BINDING_NAME_CP_T2 = format(TEXTURE_ESC, db.TEXTURE.CP_T2)

	BINDING_NAME_CP_M1 = format(TEXTURE_ESC, db.TEXTURE.CP_M1)
	BINDING_NAME_CP_M2 = format(TEXTURE_ESC, db.TEXTURE.CP_M2)
end

function ConsolePort:LoadControllerTheme()
	local settings = db.Settings
	local ctrlType = settings and strupper(settings.type) or "PS4"
	if init then
		init = nil -- Don't repeat this section
		-- Controller specific

		db.Controller = db.Controllers[ctrlType]
		db.Layout = db.Controller.Layout
		db.COLOR = db.Controller.Color

		-- Global binding headers
		for name, description in pairs(db.HEADERS) do
			_G["BINDING_HEADER_"..name] = description
		end
		-- Invisible bindings
		for name, description in pairs(db.CUSTOMBINDS) do
			_G["BINDING_NAME_"..name] = description
		end
		-- Button textures
		for name in self:GetBindings() do
			db.TEXTURE[name] = format(TEXTURE_PATH, ctrlType, x64, name)
			db.ICONS[name] = format(TEXTURE_PATH, ctrlType, x32, name)
			_G["BINDING_NAME_"..name] = format(TEXTURE_ESC, db.TEXTURE[name])
		end

		-- Set globals for click bindings
		for _, info in pairs(self:GetAddonBindings()) do
			if info.binding and info.binding:match("CLICK") then
				_G["BINDING_NAME_"..info.binding] = info.name
			end
		end
	end

	LoadTriggerTextures(ctrlType, settings)
	LoadTooltipLines()
end
