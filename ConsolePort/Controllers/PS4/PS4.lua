local _, db = ...
---------------------------------------------------------------
if not db.Controllers then db.Controllers = {} end
---------------------------------------------------------------
---------------------------------------------------------------
--[[ PS4 Controller template by Munk
---------------------------------------------------------------

Buttons: 
	Binding code for each controller button.
	CP_TR* represents trigger buttons 1 & 2 here, whereas
	it represents right side shoulder inputs elsewhere.

Color:
	Hex color codes for the right hand action buttons.
	Used to color text and tint spell effect on cursor.

Settings:
	Default controller settings that should be applied when
	loading the template, but may be customized afterwards.

Layout:
	The config binding layout to correctly align each button
	with its corresponding spot in the controller blueprint.

Bindings:
	Default bindings for each controller button.

]]-------------------------------------------------------------

db.Controllers.PS4 = {
	Buttons = {
		'CP_R_UP',
		'CP_R_DOWN',
		'CP_R_LEFT',
		'CP_R_RIGHT',
		----------------
		'CP_L_LEFT',
		'CP_L_UP',
		'CP_L_RIGHT',
		'CP_L_DOWN',
		----------------
		'CP_TR1',
		'CP_TR2',
		----------------
		'CP_TL3',
		'CP_TR3',
		----------------
		'CP_L_OPTION',
		'CP_C_OPTION',
		'CP_R_OPTION',
	},
	Color = {
		['UP'] 			= 	'62BBB2',
		['LEFT'] 		= 	'D35280',
		['RIGHT']		= 	'D84E58',
		['DOWN'] 		= 	'6882A1',
	},
	Settings = {
		['shift'] 		= 'CP_TL1',
		['ctrl'] 		= 'CP_TL2',
		['trigger1'] 	= 'CP_TR1',
		['trigger2'] 	= 'CP_TR2',
		-------------------------------
		['skipGuideBtn'] = false,
		-------------------------------
		['interactWith'] = 'CP_TR1',
		['mouseOverMode'] = true,
		-------------------------------
	},
	Layout = {
		['CP_TL1']		= {index = 1, anchor = 'LEFT'},
		['CP_TL2']		= {index = 2, anchor = 'LEFT'},
		['CP_L_UP']		= {index = 3, anchor = 'LEFT'},
		['CP_L_LEFT']	= {index = 4, anchor = 'LEFT'},
		['CP_L_DOWN']	= {index = 5, anchor = 'LEFT'},
		['CP_L_RIGHT']	= {index = 6, anchor = 'LEFT'},
		['CP_L_OPTION']	= {index = 7, anchor = 'LEFT'},
		['CP_TL3'] 		= {index = 8, anchor = 'LEFT'},
		-------------------------------------------------
		['CP_TR1']		= {index = 1, anchor = 'RIGHT'},
		['CP_TR2']		= {index = 2, anchor = 'RIGHT'},
		['CP_R_UP']		= {index = 3, anchor = 'RIGHT'},
		['CP_R_RIGHT']	= {index = 4, anchor = 'RIGHT'},
		['CP_R_DOWN']	= {index = 5, anchor = 'RIGHT'},
		['CP_R_LEFT']	= {index = 6, anchor = 'RIGHT'},
		['CP_R_OPTION']	= {index = 7, anchor = 'RIGHT'},
		['CP_TR3'] 		= {index = 8, anchor = 'RIGHT'},
		-------------------------------------------------
		['CP_C_OPTION'] = {index = 1, anchor = 'CENTER'},
		-------------------------------------------------
	},
	Bindings = {
		['CP_R_UP'] = 	{
			['action'] 	= 'ACTIONBUTTON2',
			['shift'] 	= 'ACTIONBUTTON7',
			['ctrl'] 	= 'MULTIACTIONBAR1BUTTON2',
			['ctrlsh'] 	= 'MULTIACTIONBAR1BUTTON7',
		},
		['CP_R_DOWN'] = {
			['action'] 	= 'JUMP',
			['shift'] 	= 'CLICK ConsolePortWorldCursor:LeftButton',
			['ctrl']  	= 'INTERACTMOUSEOVER',
			['ctrlsh'] 	= 'CLICK ConsolePortUtilityToggle:LeftButton',
		},
		['CP_R_LEFT'] = {
			['action'] 	= 'ACTIONBUTTON1',
			['shift'] 	= 'ACTIONBUTTON6',
			['ctrl'] 	= 'MULTIACTIONBAR1BUTTON1',
			['ctrlsh'] 	= 'MULTIACTIONBAR1BUTTON6',
		},
		['CP_R_RIGHT'] = {
			['action'] 	= 'ACTIONBUTTON3',
			['shift'] 	= 'ACTIONBUTTON8',
			['ctrl'] 	= 'MULTIACTIONBAR1BUTTON3',
			['ctrlsh'] 	= 'MULTIACTIONBAR1BUTTON8',
		},
		-- Trigger buttons
		['CP_TR1'] =	{
			['action'] 	= 'ACTIONBUTTON4',
			['shift'] 	= 'ACTIONBUTTON9',
			['ctrl'] 	= 'MULTIACTIONBAR1BUTTON4',
			['ctrlsh'] 	= 'MULTIACTIONBAR1BUTTON9',
		},
		['CP_TR2'] = 	{
			['action'] 	= 'ACTIONBUTTON5',
			['shift'] 	= 'ACTIONBUTTON10',
			['ctrl'] 	= 'MULTIACTIONBAR1BUTTON5',
			['ctrlsh'] 	= 'MULTIACTIONBAR1BUTTON10',
		},
		-- D-Pad
		['CP_L_UP'] = {
			['action'] 	= 'MULTIACTIONBAR1BUTTON12',
			['shift'] 	= 'MULTIACTIONBAR2BUTTON2',
			['ctrl'] 	= 'MULTIACTIONBAR2BUTTON6',
			['ctrlsh'] 	= 'MULTIACTIONBAR2BUTTON10',
		},
		['CP_L_DOWN'] = {
			['action'] 	= 'ACTIONBUTTON11',
			['shift'] 	= 'MULTIACTIONBAR2BUTTON4',
			['ctrl']  	= 'MULTIACTIONBAR2BUTTON8',
			['ctrlsh']	= 'MULTIACTIONBAR2BUTTON12',
		},
		['CP_L_LEFT'] = {
			['action'] 	= 'MULTIACTIONBAR1BUTTON11',
			['shift'] 	= 'MULTIACTIONBAR2BUTTON1',
			['ctrl'] 	= 'MULTIACTIONBAR2BUTTON5',
			['ctrlsh'] 	= 'MULTIACTIONBAR2BUTTON9',
		},
		['CP_L_RIGHT'] = {
			['action'] 	= 'ACTIONBUTTON12',
			['shift'] 	= 'MULTIACTIONBAR2BUTTON3',
			['ctrl'] 	= 'MULTIACTIONBAR2BUTTON7',
			['ctrlsh'] 	= 'MULTIACTIONBAR2BUTTON11',
		},
		-- Center buttons
		['CP_L_OPTION'] = {
			['action'] 	= 'OPENALLBAGS',
			['shift'] 	= 'TOGGLECHARACTER0',
			['ctrl'] 	= 'TOGGLESPELLBOOK',
			['ctrlsh'] 	= 'TOGGLETALENTS',
		},
		['CP_C_OPTION'] = {
			['action'] 	= 'TOGGLEGAMEMENU',
			['shift'] 	= 'CLICK ConsolePortRaidCursorToggle:LeftButton',
			['ctrl'] 	= 'TOGGLEAUTORUN',
			['ctrlsh'] 	= 'OPENCHAT',
		},
		['CP_R_OPTION'] = {
			['action'] 	= 'TOGGLEWORLDMAP',
			['shift'] 	= 'CP_CAMZOOMOUT',
			['ctrl'] 	= 'CP_CAMZOOMIN',
			['ctrlsh'] 	= 'CLICK ConsolePortNameplateCycle:LeftButton',
		},
	}
}

