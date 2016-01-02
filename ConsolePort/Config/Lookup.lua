---------------------------------------------------------------
-- Lookup.lua: Lookup tables for all intents and purposes
---------------------------------------------------------------
-- Tables/functions in this file are used to get static data
-- used when generating settings. Essentially, it's a database.

local addOn, db = ...
---------------------------------------------------------------
local class = select(2, UnitClass("player"))
---------------------------------------------------------------
-- Lookup: Integer keys for interface manipulation
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
	STATE_UP 	= "up",
	STATE_DOWN	= "down",
}
local KEY = db.KEY


---------------------------------------------------------------
-- Lookup: Action IDs and their corresponding binding
---------------------------------------------------------------
local actionIDs = {
	-- Main bar 							-- Second page
	[1] 	= "ACTIONBUTTON1",				[13] 	= "ACTIONBUTTON1",
	[2] 	= "ACTIONBUTTON2",				[14] 	= "ACTIONBUTTON2",
	[3] 	= "ACTIONBUTTON3",				[15] 	= "ACTIONBUTTON3",
	[4] 	= "ACTIONBUTTON4",				[16] 	= "ACTIONBUTTON4",
	[5] 	= "ACTIONBUTTON5",				[17] 	= "ACTIONBUTTON5",
	[6] 	= "ACTIONBUTTON6",				[18] 	= "ACTIONBUTTON6",
	[7] 	= "ACTIONBUTTON7",				[19] 	= "ACTIONBUTTON7",
	[8] 	= "ACTIONBUTTON8",				[20] 	= "ACTIONBUTTON8",
	[9] 	= "ACTIONBUTTON9",				[21] 	= "ACTIONBUTTON9",
	[10] 	= "ACTIONBUTTON10",				[22] 	= "ACTIONBUTTON10",
	[11] 	= "ACTIONBUTTON11",				[23] 	= "ACTIONBUTTON11",
	[12] 	= "ACTIONBUTTON12",				[24] 	= "ACTIONBUTTON12",
	-- Right 								-- Left
	[25] 	= "MULTIACTIONBAR3BUTTON1",		[37] 	= "MULTIACTIONBAR4BUTTON1",
	[26] 	= "MULTIACTIONBAR3BUTTON2",		[38] 	= "MULTIACTIONBAR4BUTTON2",
	[27] 	= "MULTIACTIONBAR3BUTTON3",		[39] 	= "MULTIACTIONBAR4BUTTON3",
	[28] 	= "MULTIACTIONBAR3BUTTON4",		[40] 	= "MULTIACTIONBAR4BUTTON4",
	[29] 	= "MULTIACTIONBAR3BUTTON5",		[41] 	= "MULTIACTIONBAR4BUTTON5",
	[30] 	= "MULTIACTIONBAR3BUTTON6",		[42] 	= "MULTIACTIONBAR4BUTTON6",
	[31] 	= "MULTIACTIONBAR3BUTTON7",		[43] 	= "MULTIACTIONBAR4BUTTON7",
	[32] 	= "MULTIACTIONBAR3BUTTON8",		[44] 	= "MULTIACTIONBAR4BUTTON8",
	[33] 	= "MULTIACTIONBAR3BUTTON9",		[45] 	= "MULTIACTIONBAR4BUTTON9",
	[34] 	= "MULTIACTIONBAR3BUTTON10",	[46] 	= "MULTIACTIONBAR4BUTTON10",
	[35] 	= "MULTIACTIONBAR3BUTTON11",	[47] 	= "MULTIACTIONBAR4BUTTON11",
	[36] 	= "MULTIACTIONBAR3BUTTON12",	[48] 	= "MULTIACTIONBAR4BUTTON12",
	-- Bottom Right 						-- Bottom Left
	[49] 	= "MULTIACTIONBAR2BUTTON1",		[61] 	= "MULTIACTIONBAR1BUTTON1",
	[50] 	= "MULTIACTIONBAR2BUTTON2",		[62] 	= "MULTIACTIONBAR1BUTTON2",
	[51] 	= "MULTIACTIONBAR2BUTTON3",		[63] 	= "MULTIACTIONBAR1BUTTON3",
	[52] 	= "MULTIACTIONBAR2BUTTON4",		[64] 	= "MULTIACTIONBAR1BUTTON4",
	[53] 	= "MULTIACTIONBAR2BUTTON5",		[65] 	= "MULTIACTIONBAR1BUTTON5",
	[54] 	= "MULTIACTIONBAR2BUTTON6",		[66] 	= "MULTIACTIONBAR1BUTTON6",
	[55] 	= "MULTIACTIONBAR2BUTTON7",		[67] 	= "MULTIACTIONBAR1BUTTON7",
	[56] 	= "MULTIACTIONBAR2BUTTON8",		[68] 	= "MULTIACTIONBAR1BUTTON8",
	[57] 	= "MULTIACTIONBAR2BUTTON9",		[69] 	= "MULTIACTIONBAR1BUTTON9",
	[58] 	= "MULTIACTIONBAR2BUTTON10",	[70] 	= "MULTIACTIONBAR1BUTTON10",
	[59] 	= "MULTIACTIONBAR2BUTTON11",	[71] 	= "MULTIACTIONBAR1BUTTON11",
	[60] 	= "MULTIACTIONBAR2BUTTON12",	[72] 	= "MULTIACTIONBAR1BUTTON12",
	-- Bonusbar 7							-- Bonusbar 8
	[73] 	= "ACTIONBUTTON1",				[85] 	= "ACTIONBUTTON1",
	[74] 	= "ACTIONBUTTON2",				[86] 	= "ACTIONBUTTON2",
	[75] 	= "ACTIONBUTTON3",				[87] 	= "ACTIONBUTTON3",
	[76] 	= "ACTIONBUTTON4",				[88] 	= "ACTIONBUTTON4",
	[77] 	= "ACTIONBUTTON5",				[89] 	= "ACTIONBUTTON5",
	[78] 	= "ACTIONBUTTON6",				[90] 	= "ACTIONBUTTON6",
	[79] 	= "ACTIONBUTTON7",				[91] 	= "ACTIONBUTTON7",
	[80] 	= "ACTIONBUTTON8",				[92] 	= "ACTIONBUTTON8",
	[81] 	= "ACTIONBUTTON9",				[93] 	= "ACTIONBUTTON9",
	[82] 	= "ACTIONBUTTON10",				[94] 	= "ACTIONBUTTON10",
	[83] 	= "ACTIONBUTTON11",				[95] 	= "ACTIONBUTTON11",
	[84] 	= "ACTIONBUTTON12",				[96] 	= "ACTIONBUTTON12",
	-- Bonusbar 9 (druid only) 				-- Bonusbar 10 (druid only)
	[97] 	= "ACTIONBUTTON1",				[109] 	= "ACTIONBUTTON1",
	[98] 	= "ACTIONBUTTON2",				[110] 	= "ACTIONBUTTON2",
	[99] 	= "ACTIONBUTTON3",				[111] 	= "ACTIONBUTTON3",
	[100] 	= "ACTIONBUTTON4",				[112] 	= "ACTIONBUTTON4",
	[101] 	= "ACTIONBUTTON5",				[113] 	= "ACTIONBUTTON5",
	[102] 	= "ACTIONBUTTON6",				[114] 	= "ACTIONBUTTON6",
	[103] 	= "ACTIONBUTTON7",				[115] 	= "ACTIONBUTTON7",
	[104] 	= "ACTIONBUTTON8",				[116] 	= "ACTIONBUTTON8",
	[105] 	= "ACTIONBUTTON9",				[117] 	= "ACTIONBUTTON9",
	[106] 	= "ACTIONBUTTON10",				[118] 	= "ACTIONBUTTON10",
	[107] 	= "ACTIONBUTTON11",				[119] 	= "ACTIONBUTTON11",
	[108] 	= "ACTIONBUTTON12",				[120] 	= "ACTIONBUTTON12",

	-- OverrideBar
	[133] 	= "ACTIONBUTTON1",
	[134] 	= "ACTIONBUTTON2",
	[135] 	= "ACTIONBUTTON3",
	[136] 	= "ACTIONBUTTON4",
	[137] 	= "ACTIONBUTTON5",
	[138] 	= "ACTIONBUTTON6",

	[169] 	= "EXTRAACTIONBUTTON1",

	["StanceButton1"]	 	= "SHAPESHIFTBUTTON1",
	["StanceButton2"]	 	= "SHAPESHIFTBUTTON2",
	["StanceButton3"]	 	= "SHAPESHIFTBUTTON3",
	["StanceButton4"]	 	= "SHAPESHIFTBUTTON4",
	["StanceButton5"]	 	= "SHAPESHIFTBUTTON5",
	["StanceButton6"]	 	= "SHAPESHIFTBUTTON6",
	["StanceButton7"]	 	= "SHAPESHIFTBUTTON7",
	["StanceButton8"]	 	= "SHAPESHIFTBUTTON8",
	["StanceButton9"]	 	= "SHAPESHIFTBUTTON9",
	["StanceButton10"]	 	= "SHAPESHIFTBUTTON10",
	["PetActionButton1"]	= "BONUSACTIONBUTTON1",
	["PetActionButton2"]	= "BONUSACTIONBUTTON2",
	["PetActionButton3"]	= "BONUSACTIONBUTTON3",
	["PetActionButton4"]	= "BONUSACTIONBUTTON4",
	["PetActionButton5"]	= "BONUSACTIONBUTTON5",
	["PetActionButton6"]	= "BONUSACTIONBUTTON6",
	["PetActionButton7"]	= "BONUSACTIONBUTTON7",
	["PetActionButton8"]	= "BONUSACTIONBUTTON8",
	["PetActionButton9"]	= "BONUSACTIONBUTTON9",
	["PetActionButton10"]	= "BONUSACTIONBUTTON10",

}

local classPage = {
	["WARRIOR"]	= "[bonusbar:1] 7; [bonusbar:2] 8;",
	["ROGUE"]	= "[stance:1] 7; [stance:2] 7; [stance:3] 7;",
	["DRUID"]	= "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["MONK"]	= "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] 	= "[bonusbar:1] 7;"
}

local classReserved = {
	["WARRIOR"] = {7, 8},
	["ROGUE"] 	= {7, 7},
	["DRUID"] 	= {7, 10},
	["MONK"] 	= {7, 9},
	["PRIEST"] 	= {7, 7},
}

local reserved = classReserved[class]

---------------------------------------------------------------
-- Functions for grabbing action button data
---------------------------------------------------------------
function ConsolePort:GetActionPageState()
	local state = {}
	local classSpecific = classPage[class]

	tinsert(state, "[overridebar][possessbar] possess; ")
	for i = 2, 6 do
		tinsert(state, ("[bar:%d] %d; "):format(i, i))
	end

	state = table.concat(state)

	if classSpecific then
		state = state..classSpecific
	end

	state = state.."[stance:1] temp; 1"

	local now = SecureCmdOptionParse(state)
	return now, state
end

function ConsolePort:GetActionBinding(id)
	-- reserve bars for classes with stances
	if reserved then
		local min, max = unpack(reserved)
		min = (min - 1) * 12
		max = (max - 1) * 12
		if (id < min or id > max) then
			return actionIDs[id]
		end
	-- let other classes use bars 7-10 
	elseif (id < 73 or id > 120) then
		return actionIDs[id]
	end
end

function ConsolePort:GetActionID(bindName)
	for ID, binding in ipairs(actionIDs) do
		if binding == bindName then
			return tonumber(ID)
		end
	end
end

function ConsolePort:GetActionTexture(bindName)
	local ID = self:GetActionID(bindName)
	if ID then
		local actionpage = self:GetActionPageState()
		return ID < 73 and GetActionTexture(ID + (actionpage - 1) * 12) or GetActionTexture(ID)
	end
end


---------------------------------------------------------------
-- Lookup: Get the clean binding names for various uses
---------------------------------------------------------------
function ConsolePort:GetBindingNames()
	return {
		"CP_R_UP",
		"CP_R_DOWN",
		"CP_R_LEFT",
		"CP_R_RIGHT",
		"CP_L_LEFT",
		"CP_L_UP",
		"CP_L_RIGHT",
		"CP_L_DOWN",
		"CP_TR1",
		"CP_TR2",
		"CP_L_OPTION",
		"CP_C_OPTION",
		"CP_R_OPTION",
	}
end


---------------------------------------------------------------
-- Lookup: Default faux binding settings
---------------------------------------------------------------
function ConsolePort:GetDefaultBinding(key)
	local keys = {
		CP_R_UP = 	{
			action 		= "ACTIONBUTTON2",
			shift 		= "ACTIONBUTTON7",
			ctrl 		= "MULTIACTIONBAR1BUTTON2",
			ctrlsh 		= "MULTIACTIONBAR1BUTTON7",
		},
		CP_R_DOWN = {
			action 		= "JUMP",
			shift 		= "TARGETNEARESTENEMY",
			ctrl  		= "INTERACTMOUSEOVER",
			ctrlsh 		= "CLICK ConsolePortUtilityToggle:LeftButton",
		},
		CP_R_LEFT = {
			action 		= "ACTIONBUTTON1",
			shift 		= "ACTIONBUTTON6",
			ctrl 		= "MULTIACTIONBAR1BUTTON1",
			ctrlsh 		= "MULTIACTIONBAR1BUTTON6",
		},
		CP_R_RIGHT = {
			action 		= "ACTIONBUTTON3",
			shift 		= "ACTIONBUTTON8",
			ctrl 		= "MULTIACTIONBAR1BUTTON3",
			ctrlsh 		= "MULTIACTIONBAR1BUTTON8",
		},
		-- Triggers
		CP_TR1 =	{
			action 		= "ACTIONBUTTON4",
			shift 		= "ACTIONBUTTON9",
			ctrl 		= "MULTIACTIONBAR1BUTTON4",
			ctrlsh 		= "MULTIACTIONBAR1BUTTON9",
		},
		CP_TR2 = 	{
			action 		= "ACTIONBUTTON5",
			shift 		= "ACTIONBUTTON10",
			ctrl 		= "MULTIACTIONBAR1BUTTON5",
			ctrlsh 		= "MULTIACTIONBAR1BUTTON10",
		},
		-- Left side
		CP_L_UP = {
			action 		= "MULTIACTIONBAR1BUTTON12",
			shift 		= "MULTIACTIONBAR2BUTTON2",
			ctrl 		= "MULTIACTIONBAR2BUTTON6",
			ctrlsh 		= "MULTIACTIONBAR2BUTTON10",
		},
		CP_L_DOWN = {
			action 		= "ACTIONBUTTON11",
			shift 		= "MULTIACTIONBAR2BUTTON4",
			ctrl  		= "MULTIACTIONBAR2BUTTON8",
			ctrlsh		= "MULTIACTIONBAR2BUTTON12",
		},
		CP_L_LEFT = {
			action 		= "MULTIACTIONBAR1BUTTON11",
			shift 		= "MULTIACTIONBAR2BUTTON1",
			ctrl 		= "MULTIACTIONBAR2BUTTON5",
			ctrlsh 		= "MULTIACTIONBAR2BUTTON9",
		},
		CP_L_RIGHT = {
			action 		= "ACTIONBUTTON12",
			shift 		= "MULTIACTIONBAR2BUTTON3",
			ctrl 		= "MULTIACTIONBAR2BUTTON7",
			ctrlsh 		= "MULTIACTIONBAR2BUTTON11",
		},		
		CP_L_OPTION = {
			action 		= "OPENALLBAGS",
			shift 		= "TOGGLECHARACTER0",
			ctrl 		= "TOGGLESPELLBOOK",
			ctrlsh 		= "TOGGLETALENTS",
		},
		CP_C_OPTION = {
			action 		= "TOGGLEGAMEMENU",
			shift 		= "CLICK ConsolePortRaidCursorToggle:LeftButton",
			ctrl 		= "TOGGLEAUTORUN",
			ctrlsh 		= "OPENCHAT",
		},
		CP_R_OPTION = {
			action 		= "TOGGLEWORLDMAP",
			shift 		= "CP_CAMZOOMOUT",
			ctrl 		= "CP_CAMZOOMIN",
			ctrlsh 		= "SETVIEW1",
		},
	}
	return keys[key]
end


---------------------------------------------------------------
-- Lookup: Get the integer key used to perform UI operations
---------------------------------------------------------------
function ConsolePort:GetUIControlKey(key)
	local keys = {
		-- Right side
		CP_R_UP =  KEY.TRIANGLE,
		CP_R_DOWN = KEY.CROSS,
		CP_R_LEFT = KEY.SQUARE,
		CP_R_RIGHT = KEY.CIRCLE,
		-- Left side
		CP_L_UP = KEY.UP,
		CP_L_DOWN = KEY.DOWN,
		CP_L_LEFT = KEY.LEFT,
		CP_L_RIGHT = KEY.RIGHT,
		-- Option buttons
		CP_L_OPTION = KEY.SHARE,
		CP_C_OPTION = KEY.CENTER,
		CP_R_OPTION = KEY.OPTIONS,
	}
	return keys[key]
end


---------------------------------------------------------------
-- Lookup: Binding set / buttons for faux binding system
---------------------------------------------------------------
function ConsolePort:GetDefaultBindingSet()
	local bindingSet = {}
	local Buttons = self:GetBindingNames()
	for _, Button in ipairs(Buttons) do
		bindingSet[Button] = self:GetDefaultBinding(Button)
	end
	return bindingSet
end

function ConsolePort:GetDefaultBindingButtons()
	local bindingSet = {}
	for _, Button in ipairs(self:GetBindingNames()) do
		bindingSet[Button] = { ui = self:GetUIControlKey(Button) }
	end
	return bindingSet
end


---------------------------------------------------------------
-- Lookup: Default addon settings (client wide)
---------------------------------------------------------------
local v1, v2, v3 = strsplit("%d+.", GetAddOnMetadata(addOn, "Version"))
local VERSION = v1*10000+v2*100+v3

function ConsolePort:GetDefaultAddonSettings(setting)
	local settings = {
		["version"] = VERSION,
		["type"] = "PS4",
		-------------------------------
		["shift"] = "CP_TL1",
		["ctrl"] = "CP_TL2",
		["trigger1"] = "CP_TR1",
		["trigger2"] = "CP_TR2",
		-------------------------------
		["interactWith"] = "CP_TR1",
		["mouseOverMode"] = true,
		-------------------------------
		["actionBarStyle"] = 1,
		-------------------------------
		["autoExtra"] = true,
		["autoInteract"] = false,
		["autoLootDefault"] = true,
		["cameraDistanceMoveSpeed"] = true,
		["disableSmartMouse"] = false,
		["doubleModTap"] = true,
		["preventMouseDrift"] = false,
		["turnCharacter"] = false,
		-------------------------------
		["mouseOnCenter"] = true,
		["mouseOnJump"] = false,
	}
	if setting then
		return settings[setting]
	else
		return settings
	end
end

---------------------------------------------------------------
-- Lookup: Mouse events and default cursor handler
---------------------------------------------------------------
function ConsolePort:GetDefaultMouseEvents()
	return {
		["PLAYER_STARTED_MOVING"] = false,
		["PLAYER_TARGET_CHANGED"] = true,
		["CURRENT_SPELL_CAST_CHANGED"] = true,
		["GOSSIP_SHOW"] = true,
		["GOSSIP_CLOSED"] = true,
		["MERCHANT_SHOW"] = true,
		["MERCHANT_CLOSED"] = true,
		["TAXIMAP_OPENED"] = true,
		["TAXIMAP_CLOSED"] = true,
		["QUEST_GREETING"] = true,
		["QUEST_DETAIL"] = true,
		["QUEST_PROGRESS"] = true,
		["QUEST_COMPLETE"] = true,
		["QUEST_FINISHED"] = true,
		["QUEST_AUTOCOMPLETE"] = true,
		["SHIPMENT_CRAFTER_OPENED"] = true,
		["SHIPMENT_CRAFTER_CLOSED"] = true,
		["LOOT_OPENED"] = true,
		["LOOT_CLOSED"] = true,
	}
end

function ConsolePort:GetDefaultMouseCursor()
	return {
		Left 	= "CP_R_RIGHT",
		Right 	= "CP_R_LEFT",
		Special = "CP_R_UP",
		Scroll 	= "CP_TL1",
	}
end


---------------------------------------------------------------
-- Lookup: Get all hidden customly created convenience bindings 
---------------------------------------------------------------
function ConsolePort:GetAddonBindings()
	return {
		{name = BINDING_NAME_CP_RAIDCURSOR, binding = "CLICK ConsolePortRaidCursorToggle:LeftButton"},
		{name = BINDING_NAME_CP_UTILITYBELT, binding = "CLICK ConsolePortUtilityToggle:LeftButton"},
		{name = BINDING_NAME_CP_TOGGLEMOUSE, binding = "CP_TOGGLEMOUSE"},
		{name = BINDING_NAME_CP_CAMZOOMIN, binding = "CP_CAMZOOMIN"},
		{name = BINDING_NAME_CP_CAMZOOMOUT, binding = "CP_CAMZOOMOUT"},
		{name = BINDING_NAME_CP_CAMLOOKBEHIND, binding = "CP_CAMLOOKBEHIND"},
	}
end


---------------------------------------------------------------
-- Lookup: UI cursor frames to be handled with D-pad
---------------------------------------------------------------
function ConsolePort:GetDefaultUIFrames()
	return {	
		Blizzard_AchievementUI 		= {
			"AchievementFrame" },
		Blizzard_ArchaeologyUI 		= {
			"ArchaeologyFrame" },
		Blizzard_AuctionUI 			= {
			"AuctionFrame" },
		Blizzard_BarbershopUI		= {
			"BarberShopFrame" },
		Blizzard_Calendar			= {
			"CalendarFrame" },
		Blizzard_Collections		= {
			"CollectionsJournal" },
		Blizzard_DeathRecap			= {
			"DeathRecapFrame" },
		Blizzard_EncounterJournal 	= {
			"EncounterJournal" },
		Blizzard_GarrisonUI			= {
			"GarrisonBuildingFrame",
			"GarrisonCapacitiveDisplayFrame",
			"GarrisonLandingPage",
			"GarrisonMissionFrame",
			"GarrisonMonumentFrame",
			"GarrisonRecruiterFrame",
			"GarrisonShipyardFrame" },
		Blizzard_GuildUI			= {
			"GuildFrame" },
		Blizzard_InspectUI			= {
			"InspectFrame" },
		Blizzard_ItemAlterationUI 	= {
			"TransmogrifyFrame" },
		Blizzard_LookingForGuildUI 	= {
			"LookingForGuildFrame" },
		Blizzard_MacroUI 			= {
			"MacroFrame" },
		Blizzard_QuestChoice 		= {
			"QuestChoiceFrame" },
		Blizzard_TalentUI 			= {
			"PlayerTalentFrame" },
		Blizzard_TradeSkillUI		= {
			"TradeSkillFrame" },
		Blizzard_TrainerUI 			= {
			"ClassTrainerFrame" },
		Blizzard_VoidStorageUI		= {
			"VoidStorageFrame" },
		ConsolePort					= {
			"AddonList",
			"BagHelpBox",
			"BankFrame",
			"BasicScriptErrors",
			"CharacterFrame",
			"ChatConfigFrame",
			"ChatMenu",
			"CinematicFrameCloseDialog",
			"ContainerFrame1",
			"ContainerFrame2",
			"ContainerFrame3",
			"ContainerFrame4",
			"ContainerFrame5",
			"ContainerFrame6",
			"ContainerFrame7",
			"ContainerFrame8",
			"ContainerFrame9",
			"ContainerFrame10",
			"ContainerFrame11",
			"ContainerFrame12",
			"ContainerFrame13",
			"DressUpFrame",
			"DropDownList1",
			"DropDownList2",
			"FriendsFrame",	
			"GameMenuFrame",
			"GossipFrame",
			"GuildInviteFrame",
			"InterfaceOptionsFrame",
			"ItemRefTooltip",
			"ItemTextFrame",
			"LFDRoleCheckPopup",
			"LFGDungeonReadyDialog",
			"LFGInvitePopup",
			"LootFrame",
			"MailFrame",
			"MerchantFrame",
			"OpenMailFrame",
			"PetBattleFrame",
			"PetitionFrame",
			"PVEFrame",
			"PVPReadyDialog",
			"QuestFrame","QuestLogPopupDetailFrame",
			"RecruitAFriendFrame",
			"SpellBookFrame",
			"SpellFlyout",
			"SplashFrame",
			"StackSplitFrame",
			"StaticPopup1",
			"StaticPopup2",
			"StaticPopup3",
			"StaticPopup4",
			"TaxiFrame",
			"TimeManagerFrame",
			"TutorialFrame",
			"VideoOptionsFrame",
			"WorldMapFrame",
			"GroupLootFrame1",
			"GroupLootFrame2",
			"GroupLootFrame3",
			"GroupLootFrame4"
		},
	}
end