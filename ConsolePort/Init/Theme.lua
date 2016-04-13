---------------------------------------------------------------
-- Theme.lua: Controller theme loader
---------------------------------------------------------------
-- Provides controller specific textures and tooltip lines.

local _, db = ...
local init = true
local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Controllers\\%s\\Icons64x64\\%s"
local TEXTURE_ESC = "|T%s:24:24:0:0|t"

setglobal("BINDING_NAME_CLICK ConsolePortUtilityToggle:LeftButton", db.CUSTOMBINDS.CP_UTILITYBELT)
setglobal("BINDING_NAME_CLICK ConsolePortWorldCursor:LeftButton", db.CUSTOMBINDS.CP_WORLDCURSOR)
setglobal("BINDING_NAME_CLICK ConsolePortNameplateCycle:LeftButton", db.CUSTOMBINDS.CP_CYCLEPLATES)
setglobal("BINDING_NAME_CLICK ConsolePortRaidCursorToggle:LeftButton", db.CUSTOMBINDS.CP_RAIDCURSOR)
setglobal("BINDING_NAME_CLICK ConsolePortRaidCursorFocus:LeftButton", db.CUSTOMBINDS.CP_RAIDCURSOR_F)
setglobal("BINDING_NAME_CLICK ConsolePortRaidCursorTarget:LeftButton", db.CUSTOMBINDS.CP_RAIDCURSOR_T)
setglobal("BINDING_NAME_CLICK ConsolePortSpellWheel:LeftButton", db.CUSTOMBINDS.CP_SPELLWHEEL)

local function LoadTooltipLines()
	local Left = db.Mouse and db.Mouse.Cursor.Left or "CP_R_RIGHT"
	local Right = db.Mouse and db.Mouse.Cursor.Right or "CP_R_LEFT"
	local Special = db.Mouse and db.Mouse.Cursor.Special or "CP_R_UP"
	-- Click strings
	local ICON				= "|T%s:24:24:0:0|t |cFF%s%s|r"
	local ShiftHold 		= format(ICON, db.TEXTURE.CP_TL1, "6882A1", "%s")
	local LeftClick 		= format(ICON, db.TEXTURE[Left], db.COLOR[gsub(Left, "CP_%w_", "")], "%s")
	local RightClick 		= format(ICON, db.TEXTURE[Right], db.COLOR[gsub(Right, "CP_%w_", "")], "%s")
	local SpecialClick		= format(ICON, db.TEXTURE[Special], db.COLOR[gsub(Special, "CP_%w_", "")], "%s")
	db.CLICK = {
		COMPARE 			= format(ShiftHold, 	db.TOOLTIP.CLICK.COMPARE),
		QUEST_TRACKER 		= format(LeftClick, 	db.TOOLTIP.CLICK.QUEST_TRACKER),
		USE_NOCOMBAT 		= format(LeftClick, 	db.TOOLTIP.CLICK.USE_NOCOMBAT),
		BUY 				= format(RightClick, 	db.TOOLTIP.CLICK.BUY),
		USE 				= format(RightClick, 	db.TOOLTIP.CLICK.USE),
		EQUIP				= format(RightClick, 	db.TOOLTIP.CLICK.EQUIP),
		SELL 				= format(RightClick, 	db.TOOLTIP.CLICK.SELL),
		QUEST_DETAILS 		= format(RightClick, 	db.TOOLTIP.CLICK.QUEST_DETAILS),
		PICKUP 				= format(SpecialClick, 	db.TOOLTIP.CLICK.PICKUP),
		CANCEL 				= format(SpecialClick, 	db.TOOLTIP.CLICK.CANCEL),
		STACK_BUY 			= format(SpecialClick, 	db.TOOLTIP.CLICK.STACK_BUY),
		STACK_SPLIT 		= format(SpecialClick, 	db.TOOLTIP.CLICK.STACK_SPLIT),
		ADD_TO_EXTRA		= format(SpecialClick, 	db.TOOLTIP.CLICK.ADD_TO_EXTRA),
	}
end

local function LoadTriggerTextures(ctrlType)
	-- Trigger textures
	db.TEXTURE.CP_TR1 = format(TEXTURE_PATH, ctrlType, db.Settings and db.Settings.trigger1 or "CP_TR1")
	db.TEXTURE.CP_TR2 = format(TEXTURE_PATH, ctrlType, db.Settings and db.Settings.trigger2 or "CP_TR2")
	db.TEXTURE.CP_TL1 = format(TEXTURE_PATH, ctrlType, db.Settings and db.Settings.shift 	or "CP_TL1")
	db.TEXTURE.CP_TL2 = format(TEXTURE_PATH, ctrlType, db.Settings and db.Settings.ctrl 	or "CP_TL2")
	db.TEXTURE.CP_TR3 = format(TEXTURE_PATH, ctrlType, "CP_TR3")
	db.TEXTURE.CP_TL3 = format(TEXTURE_PATH, ctrlType, "CP_TL3")
	-- Change global binding names
	BINDING_NAME_CP_TR1 = format(TEXTURE_ESC, db.TEXTURE.CP_TR1)
	BINDING_NAME_CP_TR2 = format(TEXTURE_ESC, db.TEXTURE.CP_TR2)
end

function ConsolePort:LoadControllerTheme()
	local ctrlType = db.Settings and strupper(db.Settings.type) or "PS4"
	if init then
		init = nil -- Don't repeat this section
		-- Controller specific

		db.Controller = db.Controllers[ctrlType]
		db.BindLayout = db.Controller.Layout
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
		for i, name in pairs(self:GetBindingNames()) do
			db.TEXTURE[name] = format(TEXTURE_PATH, ctrlType, name)
			_G["BINDING_NAME_"..name] = format(TEXTURE_ESC, db.TEXTURE[name])
		end
	end

	LoadTriggerTextures(ctrlType)
	LoadTooltipLines()
end