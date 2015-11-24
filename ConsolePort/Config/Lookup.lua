local addOn, db = ...
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
	PREPARE 	= 12,
	STATE_UP 	= "up",
	STATE_DOWN	= "down",
}
local KEY = db.KEY


---------------------------------------------------------------
-- Lookup: Action IDs and their corresponding binding
---------------------------------------------------------------
local actionIDs = {
	[1] 	= "ACTIONBUTTON1",
	[2] 	= "ACTIONBUTTON2",
	[3] 	= "ACTIONBUTTON3",
	[4] 	= "ACTIONBUTTON4",
	[5] 	= "ACTIONBUTTON5",
	[6] 	= "ACTIONBUTTON6",
	[7] 	= "ACTIONBUTTON7",
	[8] 	= "ACTIONBUTTON8",
	[9] 	= "ACTIONBUTTON9",
	[10] 	= "ACTIONBUTTON10",
	[11] 	= "ACTIONBUTTON11",
	[12] 	= "ACTIONBUTTON12",

	[13] 	= "ACTIONBUTTON1",
	[14] 	= "ACTIONBUTTON2",
	[15] 	= "ACTIONBUTTON3",
	[16] 	= "ACTIONBUTTON4",
	[17] 	= "ACTIONBUTTON5",
	[18] 	= "ACTIONBUTTON6",
	[19] 	= "ACTIONBUTTON7",
	[20] 	= "ACTIONBUTTON8",
	[21] 	= "ACTIONBUTTON9",
	[22] 	= "ACTIONBUTTON10",
	[23] 	= "ACTIONBUTTON11",
	[24] 	= "ACTIONBUTTON12",

	[25] 	= "MULTIACTIONBAR3BUTTON1",
	[26] 	= "MULTIACTIONBAR3BUTTON2",
	[27] 	= "MULTIACTIONBAR3BUTTON3",
	[28] 	= "MULTIACTIONBAR3BUTTON4",
	[29] 	= "MULTIACTIONBAR3BUTTON5",
	[30] 	= "MULTIACTIONBAR3BUTTON6",
	[31] 	= "MULTIACTIONBAR3BUTTON7",
	[32] 	= "MULTIACTIONBAR3BUTTON8",
	[33] 	= "MULTIACTIONBAR3BUTTON9",
	[34] 	= "MULTIACTIONBAR3BUTTON10",
	[35] 	= "MULTIACTIONBAR3BUTTON11",
	[36] 	= "MULTIACTIONBAR3BUTTON12",

	[37] 	= "MULTIACTIONBAR4BUTTON1",
	[38] 	= "MULTIACTIONBAR4BUTTON2",
	[39] 	= "MULTIACTIONBAR4BUTTON3",
	[40] 	= "MULTIACTIONBAR4BUTTON4",
	[41] 	= "MULTIACTIONBAR4BUTTON5",
	[42] 	= "MULTIACTIONBAR4BUTTON6",
	[43] 	= "MULTIACTIONBAR4BUTTON7",
	[44] 	= "MULTIACTIONBAR4BUTTON8",
	[45] 	= "MULTIACTIONBAR4BUTTON9",
	[46] 	= "MULTIACTIONBAR4BUTTON10",
	[47] 	= "MULTIACTIONBAR4BUTTON11",
	[48] 	= "MULTIACTIONBAR4BUTTON12",

	[49] 	= "MULTIACTIONBAR2BUTTON1",
	[50] 	= "MULTIACTIONBAR2BUTTON2",
	[51] 	= "MULTIACTIONBAR2BUTTON3",
	[52] 	= "MULTIACTIONBAR2BUTTON4",
	[53] 	= "MULTIACTIONBAR2BUTTON5",
	[54] 	= "MULTIACTIONBAR2BUTTON6",
	[55] 	= "MULTIACTIONBAR2BUTTON7",
	[56] 	= "MULTIACTIONBAR2BUTTON8",
	[57] 	= "MULTIACTIONBAR2BUTTON9",
	[58] 	= "MULTIACTIONBAR2BUTTON10",
	[59] 	= "MULTIACTIONBAR2BUTTON11",
	[60] 	= "MULTIACTIONBAR2BUTTON12",

	[61] 	= "MULTIACTIONBAR1BUTTON1",
	[62] 	= "MULTIACTIONBAR1BUTTON2",
	[63] 	= "MULTIACTIONBAR1BUTTON3",
	[64] 	= "MULTIACTIONBAR1BUTTON4",
	[65] 	= "MULTIACTIONBAR1BUTTON5",
	[66] 	= "MULTIACTIONBAR1BUTTON6",
	[67] 	= "MULTIACTIONBAR1BUTTON7",
	[68] 	= "MULTIACTIONBAR1BUTTON8",
	[69] 	= "MULTIACTIONBAR1BUTTON9",
	[70] 	= "MULTIACTIONBAR1BUTTON10",
	[71] 	= "MULTIACTIONBAR1BUTTON11",
	[72] 	= "MULTIACTIONBAR1BUTTON12",

	[73] 	= "ACTIONBUTTON1",
	[74] 	= "ACTIONBUTTON2",
	[75] 	= "ACTIONBUTTON3",
	[76] 	= "ACTIONBUTTON4",
	[77] 	= "ACTIONBUTTON5",
	[78] 	= "ACTIONBUTTON6",
	[79] 	= "ACTIONBUTTON7",
	[80] 	= "ACTIONBUTTON8",
	[81] 	= "ACTIONBUTTON9",
	[82] 	= "ACTIONBUTTON10",
	[83] 	= "ACTIONBUTTON11",
	[84] 	= "ACTIONBUTTON12",

	[85] 	= "ACTIONBUTTON1",
	[86] 	= "ACTIONBUTTON2",
	[87] 	= "ACTIONBUTTON3",
	[88] 	= "ACTIONBUTTON4",
	[89] 	= "ACTIONBUTTON5",
	[90] 	= "ACTIONBUTTON6",
	[91] 	= "ACTIONBUTTON7",
	[92] 	= "ACTIONBUTTON8",
	[93] 	= "ACTIONBUTTON9",
	[94] 	= "ACTIONBUTTON10",
	[95] 	= "ACTIONBUTTON11",
	[96] 	= "ACTIONBUTTON12",

	[97] 	= "ACTIONBUTTON1",
	[98] 	= "ACTIONBUTTON2",
	[99] 	= "ACTIONBUTTON3",
	[100] 	= "ACTIONBUTTON4",
	[101] 	= "ACTIONBUTTON5",
	[102] 	= "ACTIONBUTTON6",
	[103] 	= "ACTIONBUTTON7",
	[104] 	= "ACTIONBUTTON8",
	[105] 	= "ACTIONBUTTON9",
	[106] 	= "ACTIONBUTTON10",
	[107] 	= "ACTIONBUTTON11",
	[108] 	= "ACTIONBUTTON12",

	[109] 	= "ACTIONBUTTON1",
	[110] 	= "ACTIONBUTTON2",
	[111] 	= "ACTIONBUTTON3",
	[112] 	= "ACTIONBUTTON4",
	[113] 	= "ACTIONBUTTON5",
	[114] 	= "ACTIONBUTTON6",
	[115] 	= "ACTIONBUTTON7",
	[116] 	= "ACTIONBUTTON8",
	[117] 	= "ACTIONBUTTON9",
	[118] 	= "ACTIONBUTTON10",
	[119] 	= "ACTIONBUTTON11",
	[120] 	= "ACTIONBUTTON12",

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

function ConsolePort:GetActionBinding(id)
	return actionIDs[id]
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
		local actionpage = MainMenuBarArtFrame:GetAttribute("actionpage")
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
			ctrlsh 		= "TARGETPREVIOUSENEMY",
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
			shift 		= "EXTRAACTIONBUTTON1",
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