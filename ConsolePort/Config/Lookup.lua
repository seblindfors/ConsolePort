---------------------------------------------------------------
-- Lookup.lua: Lookup tables for all intents and purposes
---------------------------------------------------------------
-- Tables/functions in this file are used to get static data
-- used when generating settings. Essentially, it's a database.

local addOn, db = ...
---------------------------------------------------------------
local Controller
---------------------------------------------------------------
local tonumber, ipairs, pairs = tonumber, ipairs, pairs
local spairs, copy = db.table.spairs, db.table.copy
---------------------------------------------------------------
local class = select(2, UnitClass('player'))
---------------------------------------------------------------
-- Integer keys for interface manipulation
---------------------------------------------------------------
db.KEY = {
	CIRCLE  	= 1,
	SQUARE 		= 2,
	TRIANGLE 	= 3,
	UP			= 4,
	DOWN		= 5,
	LEFT		= 6,
	RIGHT		= 7,
	CROSS 		= 8,
	SHARE 		= 9,
	OPTIONS 	= 10,
	CENTER 		= 11,
	STATE_UP 	= 'up',
	STATE_DOWN	= 'down',
}
local KEY = db.KEY

---------------------------------------------------------------
function ConsolePort:LoadLookup()
	Controller = db.Controllers[db.Settings.type]
	self.LoadLookup = nil
end
---------------------------------------------------------------
-- Plug-in access to addon table
---------------------------------------------------------------
function ConsolePort:GetData() return db end

---------------------------------------------------------------
-- Action IDs and their corresponding binding
---------------------------------------------------------------
local actionIDs = {
	-- Main bar 							-- Second page
	[1] 	= 'ACTIONBUTTON1',				[13] 	= 'ACTIONBUTTON1',
	[2] 	= 'ACTIONBUTTON2',				[14] 	= 'ACTIONBUTTON2',
	[3] 	= 'ACTIONBUTTON3',				[15] 	= 'ACTIONBUTTON3',
	[4] 	= 'ACTIONBUTTON4',				[16] 	= 'ACTIONBUTTON4',
	[5] 	= 'ACTIONBUTTON5',				[17] 	= 'ACTIONBUTTON5',
	[6] 	= 'ACTIONBUTTON6',				[18] 	= 'ACTIONBUTTON6',
	[7] 	= 'ACTIONBUTTON7',				[19] 	= 'ACTIONBUTTON7',
	[8] 	= 'ACTIONBUTTON8',				[20] 	= 'ACTIONBUTTON8',
	[9] 	= 'ACTIONBUTTON9',				[21] 	= 'ACTIONBUTTON9',
	[10] 	= 'ACTIONBUTTON10',				[22] 	= 'ACTIONBUTTON10',
	[11] 	= 'ACTIONBUTTON11',				[23] 	= 'ACTIONBUTTON11',
	[12] 	= 'ACTIONBUTTON12',				[24] 	= 'ACTIONBUTTON12',
	-- Right 								-- Left
	[25] 	= 'MULTIACTIONBAR3BUTTON1',		[37] 	= 'MULTIACTIONBAR4BUTTON1',
	[26] 	= 'MULTIACTIONBAR3BUTTON2',		[38] 	= 'MULTIACTIONBAR4BUTTON2',
	[27] 	= 'MULTIACTIONBAR3BUTTON3',		[39] 	= 'MULTIACTIONBAR4BUTTON3',
	[28] 	= 'MULTIACTIONBAR3BUTTON4',		[40] 	= 'MULTIACTIONBAR4BUTTON4',
	[29] 	= 'MULTIACTIONBAR3BUTTON5',		[41] 	= 'MULTIACTIONBAR4BUTTON5',
	[30] 	= 'MULTIACTIONBAR3BUTTON6',		[42] 	= 'MULTIACTIONBAR4BUTTON6',
	[31] 	= 'MULTIACTIONBAR3BUTTON7',		[43] 	= 'MULTIACTIONBAR4BUTTON7',
	[32] 	= 'MULTIACTIONBAR3BUTTON8',		[44] 	= 'MULTIACTIONBAR4BUTTON8',
	[33] 	= 'MULTIACTIONBAR3BUTTON9',		[45] 	= 'MULTIACTIONBAR4BUTTON9',
	[34] 	= 'MULTIACTIONBAR3BUTTON10',	[46] 	= 'MULTIACTIONBAR4BUTTON10',
	[35] 	= 'MULTIACTIONBAR3BUTTON11',	[47] 	= 'MULTIACTIONBAR4BUTTON11',
	[36] 	= 'MULTIACTIONBAR3BUTTON12',	[48] 	= 'MULTIACTIONBAR4BUTTON12',
	-- Bottom Right 						-- Bottom Left
	[49] 	= 'MULTIACTIONBAR2BUTTON1',		[61] 	= 'MULTIACTIONBAR1BUTTON1',
	[50] 	= 'MULTIACTIONBAR2BUTTON2',		[62] 	= 'MULTIACTIONBAR1BUTTON2',
	[51] 	= 'MULTIACTIONBAR2BUTTON3',		[63] 	= 'MULTIACTIONBAR1BUTTON3',
	[52] 	= 'MULTIACTIONBAR2BUTTON4',		[64] 	= 'MULTIACTIONBAR1BUTTON4',
	[53] 	= 'MULTIACTIONBAR2BUTTON5',		[65] 	= 'MULTIACTIONBAR1BUTTON5',
	[54] 	= 'MULTIACTIONBAR2BUTTON6',		[66] 	= 'MULTIACTIONBAR1BUTTON6',
	[55] 	= 'MULTIACTIONBAR2BUTTON7',		[67] 	= 'MULTIACTIONBAR1BUTTON7',
	[56] 	= 'MULTIACTIONBAR2BUTTON8',		[68] 	= 'MULTIACTIONBAR1BUTTON8',
	[57] 	= 'MULTIACTIONBAR2BUTTON9',		[69] 	= 'MULTIACTIONBAR1BUTTON9',
	[58] 	= 'MULTIACTIONBAR2BUTTON10',	[70] 	= 'MULTIACTIONBAR1BUTTON10',
	[59] 	= 'MULTIACTIONBAR2BUTTON11',	[71] 	= 'MULTIACTIONBAR1BUTTON11',
	[60] 	= 'MULTIACTIONBAR2BUTTON12',	[72] 	= 'MULTIACTIONBAR1BUTTON12',
	-- Bonusbar 7							-- Bonusbar 8
	[73] 	= 'ACTIONBUTTON1',				[85] 	= 'ACTIONBUTTON1',
	[74] 	= 'ACTIONBUTTON2',				[86] 	= 'ACTIONBUTTON2',
	[75] 	= 'ACTIONBUTTON3',				[87] 	= 'ACTIONBUTTON3',
	[76] 	= 'ACTIONBUTTON4',				[88] 	= 'ACTIONBUTTON4',
	[77] 	= 'ACTIONBUTTON5',				[89] 	= 'ACTIONBUTTON5',
	[78] 	= 'ACTIONBUTTON6',				[90] 	= 'ACTIONBUTTON6',
	[79] 	= 'ACTIONBUTTON7',				[91] 	= 'ACTIONBUTTON7',
	[80] 	= 'ACTIONBUTTON8',				[92] 	= 'ACTIONBUTTON8',
	[81] 	= 'ACTIONBUTTON9',				[93] 	= 'ACTIONBUTTON9',
	[82] 	= 'ACTIONBUTTON10',				[94] 	= 'ACTIONBUTTON10',
	[83] 	= 'ACTIONBUTTON11',				[95] 	= 'ACTIONBUTTON11',
	[84] 	= 'ACTIONBUTTON12',				[96] 	= 'ACTIONBUTTON12',
	-- Bonusbar 9 (druid / monk only) 		-- Bonusbar 10 (druid only)
	[97] 	= 'ACTIONBUTTON1',				[109] 	= 'ACTIONBUTTON1',
	[98] 	= 'ACTIONBUTTON2',				[110] 	= 'ACTIONBUTTON2',
	[99] 	= 'ACTIONBUTTON3',				[111] 	= 'ACTIONBUTTON3',
	[100] 	= 'ACTIONBUTTON4',				[112] 	= 'ACTIONBUTTON4',
	[101] 	= 'ACTIONBUTTON5',				[113] 	= 'ACTIONBUTTON5',
	[102] 	= 'ACTIONBUTTON6',				[114] 	= 'ACTIONBUTTON6',
	[103] 	= 'ACTIONBUTTON7',				[115] 	= 'ACTIONBUTTON7',
	[104] 	= 'ACTIONBUTTON8',				[116] 	= 'ACTIONBUTTON8',
	[105] 	= 'ACTIONBUTTON9',				[117] 	= 'ACTIONBUTTON9',
	[106] 	= 'ACTIONBUTTON10',				[118] 	= 'ACTIONBUTTON10',
	[107] 	= 'ACTIONBUTTON11',				[119] 	= 'ACTIONBUTTON11',
	[108] 	= 'ACTIONBUTTON12',				[120] 	= 'ACTIONBUTTON12',

	-- OverrideBar
	[133] 	= 'ACTIONBUTTON1',
	[134] 	= 'ACTIONBUTTON2',
	[135] 	= 'ACTIONBUTTON3',
	[136] 	= 'ACTIONBUTTON4',
	[137] 	= 'ACTIONBUTTON5',
	[138] 	= 'ACTIONBUTTON6',

	[169] 	= 'EXTRAACTIONBUTTON1',

	['StanceButton1']	 	= 'SHAPESHIFTBUTTON1',
	['StanceButton2']	 	= 'SHAPESHIFTBUTTON2',
	['StanceButton3']	 	= 'SHAPESHIFTBUTTON3',
	['StanceButton4']	 	= 'SHAPESHIFTBUTTON4',
	['StanceButton5']	 	= 'SHAPESHIFTBUTTON5',
	['StanceButton6']	 	= 'SHAPESHIFTBUTTON6',
	['StanceButton7']	 	= 'SHAPESHIFTBUTTON7',
	['StanceButton8']	 	= 'SHAPESHIFTBUTTON8',
	['StanceButton9']	 	= 'SHAPESHIFTBUTTON9',
	['StanceButton10']	 	= 'SHAPESHIFTBUTTON10',
	['PetActionButton1']	= 'BONUSACTIONBUTTON1',
	['PetActionButton2']	= 'BONUSACTIONBUTTON2',
	['PetActionButton3']	= 'BONUSACTIONBUTTON3',
	['PetActionButton4']	= 'BONUSACTIONBUTTON4',
	['PetActionButton5']	= 'BONUSACTIONBUTTON5',
	['PetActionButton6']	= 'BONUSACTIONBUTTON6',
	['PetActionButton7']	= 'BONUSACTIONBUTTON7',
	['PetActionButton8']	= 'BONUSACTIONBUTTON8',
	['PetActionButton9']	= 'BONUSACTIONBUTTON9',
	['PetActionButton10']	= 'BONUSACTIONBUTTON10',

}

-- action ID thresholds
local classReserved = {
	['WARRIOR'] = 96,
	['ROGUE'] 	= 84,
	['DRUID'] 	= 120,
	['MONK'] 	= 108,
	['PRIEST'] 	= 84,
}

---------------------------------------------------------------
local customRange = classReserved[class]
local ACTION_ID_RANGE = 72
local ACTION_ID_STANCE_RANGE = 120
local ACTION_ID_MAX_THRESHOLD = 169
---------------------------------------------------------------
local DefaultBar = MainMenuBarArtFrame

---------------------------------------------------------------
-- Functions for grabbing action button data
---------------------------------------------------------------
function ConsolePort:GetActionPageDriver()
	local driver = '[vehicleui] 1; [possessbar] 2; [overridebar] 3; [shapeshift] 4; [bar:2] 5; [bar:3] 6; [bar:4] 7; [bar:5] 8; [bar:6] 9; [bonusbar:1] 10; [bonusbar:2] 11; [bonusbar:3] 12; [bonusbar:4] 13; 14'
	local newstate
	if db.Settings and db.Settings.pagedriver then
		newstate = SecureCmdOptionParse(db.Settings.pagedriver)
	elseif HasVehicleActionBar() then
		newstate = GetVehicleBarIndex()
	elseif HasOverrideActionBar() then
		newstate = GetOverrideBarIndex()
	elseif HasTempShapeshiftActionBar() then
		newstate = GetTempShapeshiftBarIndex()
	elseif GetBonusBarOffset() > 0 then
		newstate = GetBonusBarOffset()+6
	else
		newstate = GetActionBarPage()
	end
	return driver, newstate
end

function ConsolePort:GetActionBinding(id)
	local idType = type(id)
	if idType == 'number' then
		-- reserve bars for classes with stances
		if customRange then
			if (id <= customRange or id > ACTION_ID_STANCE_RANGE) then
				return actionIDs[id]
			end
		-- let other classes use bars 7-10 
		elseif (id <= ACTION_ID_RANGE or id > ACTION_ID_STANCE_RANGE) then
			return actionIDs[id]
		end
	elseif idType == 'string' then
		return actionIDs[id]
	end
end

function ConsolePort:GetActionID(bindName)
	if bindName ~= nil then
		for ID=1, ACTION_ID_MAX_THRESHOLD do
			local binding = actionIDs[ID]
			if binding == bindName then
				return tonumber(ID)
			end
		end
	end
end

function ConsolePort:GetActionTexture(bindName)
	local ID = self:GetActionID(bindName)
	if ID then
		local actionpage = DefaultBar:GetAttribute('actionpage')
		return ID < 73 and GetActionTexture(ID + (actionpage - 1) * 12) or GetActionTexture(ID)
	end
end

local valid_action_buttons = {
	Button = true,
	CheckButton = true,
}

-- Wrap this function since it's recursive.
local function GetActionButtons(buttons, this)
	buttons = buttons or {}
	this = this or UIParent
	if this:IsForbidden() then
		return buttons
	end
	local objType = this:GetObjectType()
	local action = this:IsProtected() and valid_action_buttons[objType] and this:GetAttribute('action')
	if action and tonumber(action) and this:GetAttribute('type') == 'action' then
		buttons[this] = action
	end
	for _, object in pairs({this:GetChildren()}) do
		GetActionButtons(buttons, object)
	end
	return buttons
end

local function GetOuterParent(this)
	local parent = this:GetParent()
	if not parent or parent == UIParent then
		return this
	else
		return GetOuterParent(parent)
	end
end

local function GetActionBars(bars, this)
	bars = bars or {}
	this = this or UIParent
	if this:IsForbidden() then
		return bars
	end
	local objType = this:GetObjectType()
	local action = this:IsProtected() and valid_action_buttons[objType] and this:GetAttribute('action')
	if action and tonumber(action) and this:GetAttribute('type') == 'action' then
		local outerParent = GetOuterParent(this)
		bars[outerParent] = outerParent:GetName() or math.random()
		return bars
	end
	for _, object in pairs({this:GetChildren()}) do
		GetActionBars(bars, object)
	end
	return bars
end

---------------------------------------------------------------
-- Get all buttons that look like action buttons
---------------------------------------------------------------
function ConsolePort:GetActionButtons(getTable, parent)
	if getTable then
		return GetActionButtons(parent)
	else
		return pairs(GetActionButtons(parent))
	end
end

---------------------------------------------------------------
-- Get all container frames that look like action bars
---------------------------------------------------------------
function ConsolePort:GetActionBars(getTable, parent)
	if getTable then
		return db.table.flip(GetActionBars(parent))
	else
		return pairs(db.table.flip(GetActionBars(parent)))
	end
end

---------------------------------------------------------------
-- Get the clean bindings for various uses
---------------------------------------------------------------
function ConsolePort:GetBindings(tbl) return tbl and db.table.copy(Controller.Bindings) or spairs(Controller.Bindings) end

---------------------------------------------------------------
-- Default faux binding settings
---------------------------------------------------------------
function ConsolePort:GetDefaultBinding(key) return copy(Controller.Bindings[key]) end

---------------------------------------------------------------
-- Get the button that's currently bound to a defined ID
---------------------------------------------------------------
function ConsolePort:GetCurrentBindingOwner(bindingID, set)
	local set = set or db.Bindings
	if set then
		for key, subSet in pairs(set) do
			for mod, value in pairs(subSet) do
				if value == bindingID then
					return key, mod
				end
			end
		end
	end
end

function ConsolePort:GetFormattedButtonCombination(key, mod, size, useLargeIcons)
	if key and mod then
		local texture_esc = '|T%s:'..format('%d:%d:0:0|t', size or 24, size or 24)
		local texTable = useLargeIcons and db.TEXTURE or db.ICONS
		local icon = texTable[key]
		if icon then
			local formattedKeys = {
				[''] = format(texture_esc, icon),
				['SHIFT-'] = format(texture_esc, texTable.CP_M1) .. format(texture_esc, icon),
				['CTRL-'] = format(texture_esc, texTable.CP_M2) .. format(texture_esc, icon),
				['CTRL-SHIFT-'] = format(texture_esc, texTable.CP_M1) .. format(texture_esc, texTable.CP_M2) .. format(texture_esc, icon),
			}
			return formattedKeys[mod]
		end
	end
end

function ConsolePort:GetFormattedBindingOwner(bindingID, set, size, useLargeIcons)
	local key, mod = self:GetCurrentBindingOwner(bindingID, set)
	if key and mod then
		return self:GetFormattedButtonCombination(key, mod, size, useLargeIcons)
	end
end

---------------------------------------------------------------
-- Get the integer key used to perform UI operations
---------------------------------------------------------------
function ConsolePort:GetUIControlKey(key)
	local keys = {
		-- Right side
		CP_R_UP 	= KEY.TRIANGLE,
		CP_R_DOWN 	= KEY.CROSS,
		CP_R_LEFT 	= KEY.SQUARE,
		CP_R_RIGHT 	= KEY.CIRCLE,
		-- Left side
		CP_L_UP 	= KEY.UP,
		CP_L_DOWN 	= KEY.DOWN,
		CP_L_LEFT 	= KEY.LEFT,
		CP_L_RIGHT 	= KEY.RIGHT,
		-- Option buttons
		CP_X_LEFT = KEY.SHARE,
		CP_X_CENTER = KEY.CENTER,
		CP_X_RIGHT = KEY.OPTIONS,
	}
	return keys[key]
end

function ConsolePort:GetUIControlKeyOwner(key)
	local keys = {
		-- Right side
		[KEY.TRIANGLE] 	= 'CP_R_UP',
		[KEY.CROSS] 	= 'CP_R_DOWN',
		[KEY.SQUARE] 	= 'CP_R_LEFT',
		[KEY.CIRCLE] 	= 'CP_R_RIGHT', 
		-- Left side
		[KEY.UP] 		= 'CP_L_UP',
		[KEY.DOWN] 		= 'CP_L_DOWN',
		[KEY.LEFT] 		= 'CP_L_LEFT',
		[KEY.RIGHT] 	= 'CP_L_RIGHT', 
		-- Option buttons
		[KEY.SHARE] 	= 'CP_X_LEFT',
		[KEY.CENTER] 	= 'CP_X_CENTER',
		[KEY.OPTIONS] 	= 'CP_X_RIGHT',
	}
	return keys[key]
end

---------------------------------------------------------------
-- Get the modifiers currently used by ConsolePort
---------------------------------------------------------------
local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown
local modifiers = {
	[''] 		= function() return ( not IsShiftKeyDown() and not IsControlKeyDown() ) end,
	['SHIFT-'] 	= function() return ( IsShiftKeyDown() and not IsControlKeyDown() ) end,
	['CTRL-'] 	= function() return ( IsControlKeyDown() and not IsShiftKeyDown() ) end,
	['CTRL-SHIFT-'] = function() return ( IsShiftKeyDown() and IsControlKeyDown() ) end,
}

function ConsolePort:GetModifiers() return pairs(modifiers) end

function ConsolePort:GetCurrentModifier()
	for modifier, isCurrent in self:GetModifiers() do
		if isCurrent() then
			return modifier
		end
	end
end

---------------------------------------------------------------
-- Binding set / buttons for faux binding system
---------------------------------------------------------------
function ConsolePort:GetDefaultBindingSet()
	local bindingSet = {}
	for button in self:GetBindings() do
		bindingSet[button] = self:GetDefaultBinding(button)
	end
	return bindingSet
end

---------------------------------------------------------------
-- Default addon settings (client wide)
---------------------------------------------------------------
local v1, v2, v3 = strsplit('%d+.', GetAddOnMetadata(addOn, 'Version'))
local VERSION = v1*10000+v2*100+v3

function ConsolePort:GetDefaultAddonSettings(setting)
	local settings = {
		['version'] = VERSION,
		['type'] = 'PS4',
		['UIdropDownFix'] = true,
		-------------------------------
		['CP_M1'] = 'CP_TL1',
		['CP_M2'] = 'CP_TL2',
		['CP_T1'] = 'CP_TR1',
		['CP_T2'] = 'CP_TR2',
		-------------------------------
	--	['interactWith'] = 'CP_T1',
	--	['mouseOverMode'] = true,
		-------------------------------
		['actionBarStyle'] = 1,
		-------------------------------
		['autoExtra'] = true,
		['autoSellJunk'] = true,
		['autoInteract'] = false,
		['autoLootDefault'] = true,
		['disableKeyboard'] = true,
		['disableSmartMouse'] = false,
	--	['doubleModTap'] = true,
		['preventMouseDrift'] = false,
		['turnCharacter'] = false,
		-------------------------------
	--	['mouseOnCenter'] = true,
		['mouseOnJump'] = false,
		-------------------------------
		['unitHotkeyPool'] = 'player;party%d;raid%d+',
		-------------------------------
	}
	if Controller then
		for key, value in pairs(Controller.Settings) do
			settings[key] = value
		end
	end
	if setting then
		return settings[setting]
	else
		return settings
	end
end

---------------------------------------------------------------
-- Mouse events and default cursor handler
---------------------------------------------------------------
function ConsolePort:GetDefaultMouseEvents()
	return {
		['PLAYER_STARTED_MOVING'] = true,
		['PLAYER_TARGET_CHANGED'] = true,
		['GOSSIP_SHOW'] = true,
		['GOSSIP_CLOSED'] = true,
		['MERCHANT_SHOW'] = true,
		['MERCHANT_CLOSED'] = true,
		['TAXIMAP_OPENED'] = true,
		['TAXIMAP_CLOSED'] = true,
		['QUEST_GREETING'] = true,
		['QUEST_DETAIL'] = true,
		['QUEST_PROGRESS'] = true,
		['QUEST_COMPLETE'] = true,
		['QUEST_FINISHED'] = true,
		['QUEST_AUTOCOMPLETE'] = true,
		['SHIPMENT_CRAFTER_OPENED'] = true,
		['SHIPMENT_CRAFTER_CLOSED'] = true,
		['LOOT_OPENED'] = true,
		['LOOT_CLOSED'] = true,
	}
end

function ConsolePort:GetDefaultMouseCursor()
	return {
		Left 	= 'CP_R_DOWN',
		Right 	= 'CP_R_RIGHT',
		Special = 'CP_R_UP',
		Scroll 	= 'CP_M1',
	}
end


---------------------------------------------------------------
-- Get all hidden customly created convenience bindings 
---------------------------------------------------------------
function ConsolePort:GetAddonBindings()
	local L = db.CUSTOMBINDS
	return {
		-- Mouse bindings
		{name = L.CP_MOUSE},
		{name = L.CAMERAORSELECTORMOVE, binding = 'CAMERAORSELECTORMOVE'},
		{name = L.TURNORACTION, binding = 'TURNORACTION'},
		-- Targeting
		{name = L.CP_TARGETING},
		{name = L.CP_EM_FRAMES, binding = 'CLICK ConsolePortEasyMotionButton:LeftButton'},
	--	{name = L.CP_EM_PLATES, binding = 'CLICK ConsolePortEasyMotionButton:RightButton'},
	--	{name = L.CP_EM_NEAREST, binding = 'CLICK ConsolePortEasyMotionButton:MiddleButton'},
		{name = L.CP_RAIDCURSOR, binding = 'CLICK ConsolePortRaidCursorToggle:LeftButton'},
		{name = L.CP_RAIDCURSOR_F, binding = 'CLICK ConsolePortRaidCursorFocus:LeftButton'},
		{name = L.CP_RAIDCURSOR_T, binding = 'CLICK ConsolePortRaidCursorTarget:LeftButton'},
		-- Utility
		{name = L.CP_UTILITY},
		{name = L.CP_UTILITYBELT, binding = 'CLICK ConsolePortUtilityToggle:LeftButton'},
		{name = L.CP_PETRING, binding = 'CLICK ConsolePortBarPet:MiddleButton'},
		-- Pager
		{name = L.CP_PAGER},
		{name = L.CP_PAGE2, binding = 'CLICK ConsolePortPager:2'},
		{name = L.CP_PAGE3, binding = 'CLICK ConsolePortPager:3'},
		{name = L.CP_PAGE4, binding = 'CLICK ConsolePortPager:4'},
		{name = L.CP_PAGE5, binding = 'CLICK ConsolePortPager:5'},
		{name = L.CP_PAGE6, binding = 'CLICK ConsolePortPager:6'},
		-- Camera
		{name = L.CP_CAMERA},
		{name = L.CP_TOGGLEMOUSE, binding = 'CP_TOGGLEMOUSE'},
		{name = L.CP_CAMZOOMIN, binding = 'CP_CAMZOOMIN'},
		{name = L.CP_CAMZOOMOUT, binding = 'CP_CAMZOOMOUT'},
		{name = L.CP_CAMLOOKBEHIND, binding = 'CP_CAMLOOKBEHIND'},
	}
end


---------------------------------------------------------------
-- UI cursor frames to be handled with D-pad
---------------------------------------------------------------
function ConsolePort:GetDefaultUIFrames()
	return {	
		Blizzard_AchievementUI 		= {
			'AchievementFrame' },
		Blizzard_ArchaeologyUI 		= {
			'ArchaeologyFrame' },
		Blizzard_ArtifactUI 		= {
			'ArtifactFrame' },
		Blizzard_AuctionUI 			= {
			'AuctionFrame' },
		Blizzard_BarbershopUI		= {
			'BarberShopFrame' },
		Blizzard_Calendar			= {
			'CalendarFrame' },
		Blizzard_ChallengesUI 		= {
			'ChallengesKeystoneFrame' },
		Blizzard_Collections		= {
			'CollectionsJournal',
			'WardrobeFrame', },
		Blizzard_DeathRecap			= {
			'DeathRecapFrame' },
		Blizzard_EncounterJournal 	= {
			'EncounterJournal' },
		Blizzard_GarrisonUI			= {
			'GarrisonBuildingFrame',
			'GarrisonCapacitiveDisplayFrame',
			'GarrisonLandingPage',
			'GarrisonMissionFrame',
			'GarrisonMonumentFrame',
			'GarrisonRecruiterFrame',
			'GarrisonShipyardFrame',
			'OrderHallMissionFrame',
			'OrderHallTalentFrame', },
		Blizzard_GuildUI			= {
			'GuildFrame' },
		Blizzard_InspectUI			= {
			'InspectFrame' },
		Blizzard_ItemAlterationUI 	= {
			'TransmogrifyFrame' },
		Blizzard_LookingForGuildUI 	= {
			'LookingForGuildFrame' },
		Blizzard_MacroUI 			= {
			'MacroFrame' },
		Blizzard_ObliterumUI 		= {
			'ObliterumForgeFrame' },
		Blizzard_QuestChoice 		= {
			'QuestChoiceFrame' },
		Blizzard_TalentUI 			= {
			'PlayerTalentFrame' },
		Blizzard_TradeSkillUI		= {
			'TradeSkillFrame' },
		Blizzard_TrainerUI 			= {
			'ClassTrainerFrame' },
		Blizzard_VoidStorageUI		= {
			'VoidStorageFrame' },
		ConsolePort					= {
			'AddonList',
			'BagHelpBox',
			'BankFrame',
			'BasicScriptErrors',
			'CharacterFrame',
			'ChatConfigFrame',
			'ChatMenu',
			'CinematicFrameCloseDialog',
			'ContainerFrame1',
			'ContainerFrame2',
			'ContainerFrame3',
			'ContainerFrame4',
			'ContainerFrame5',
			'ContainerFrame6',
			'ContainerFrame7',
			'ContainerFrame8',
			'ContainerFrame9',
			'ContainerFrame10',
			'ContainerFrame11',
			'ContainerFrame12',
			'ContainerFrame13',
			'DressUpFrame',
			'DropDownList1',
			'DropDownList2',
			'FriendsFrame',	
			'GameMenuFrame',
			'GossipFrame',
			'GuildInviteFrame',
			'InterfaceOptionsFrame',
			'ItemRefTooltip',
			'ItemTextFrame',
			'LFDRoleCheckPopup',
			'LFGDungeonReadyDialog',
			'LFGInvitePopup',
			'LootFrame',
			'MailFrame',
			'MerchantFrame',
			'OpenMailFrame',
			'PetBattleFrame',
			'PetitionFrame',
			'PVEFrame',
			'PVPReadyDialog',
			'QuestFrame','QuestLogPopupDetailFrame',
			'RecruitAFriendFrame',
			'ReadyCheckFrame',
			'SpellBookFrame',
			'SplashFrame',
			'StackSplitFrame',
			'StaticPopup1',
			'StaticPopup2',
			'StaticPopup3',
			'StaticPopup4',
			'TaxiFrame',
			'TimeManagerFrame',
			'TradeFrame',
			'TutorialFrame',
			'VideoOptionsFrame',
			'WorldMapFrame',
			'GroupLootFrame1',
			'GroupLootFrame2',
			'GroupLootFrame3',
			'GroupLootFrame4'
		},
	}
end

---------------------------------------------------------------
-- Cvar list and getter function
---------------------------------------------------------------
local cvars = { -- value = default
	alwaysHighlight 	= 0,
	autoExtra 			= true,
	autoLootDefault		= true,
	autoSellJunk 		= true,
	centerLockRangeX 	= 70,
	centerLockRangeY 	= 180,
	centerLockDeadzoneX = 4,
	centerLockDeadzoneY = 4,
	disableHints 		= false,
	disableSmartBind 	= false,
	disableSmartMouse 	= false,
	disableStickMouse	= false,
	doubleModTap 		= true,
	doubleModTapWindow 	= 0.25,
	interactAuto 		= false,
	interactNPC 		= false,
	interactPushback 	= 1,
	interactWith 		= false,
	lookAround 			= false,
	mouseOnCenter 		= true,	
	mouseOnJump 		= false,
	mouseOverMode 		= false,
	turnCharacter 		= false,
	preventMouseDrift 	= false,
	raidCursorDirect 	= false,
	raidCursorModifier 	= '',
	skipCalibration 	= false,
	skipGuideBtn 		= false,
	UIleaveCombatDelay	= 0.5,
	UIholdRepeatDelay 	= 0.125,
	UIdisableHoldRepeat = false,
	UIdropDownFix		= false,
	unitHotkeySize 		= 32,
	unitHotkeyOffsetX 	= 0,
	unitHotkeyOffsetY 	= 0,
	unitHotkeyAnchor	= 'CENTER',
	unitHotkeyGhostMode = false,
	unitHotkeyIgnorePlayer = false,
	unitHotkeyPool = 'player;party%d;raid%d+',
	unitHotkeySet = '',
}

function ConsolePort:GetCompleteCVarList()
	local cvars = db.table.copy(cvars)
	for cvar, value in pairs(db.Settings) do
		if type(value) ~= 'table' then
			cvars[cvar] = value
		end
	end
	return cvars
end


