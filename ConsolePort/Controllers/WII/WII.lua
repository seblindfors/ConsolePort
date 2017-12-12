local _, db = ...
---------------------------------------------------------------
if not db.Controllers then db.Controllers = {} end
---------------------------------------------------------------
---------------------------------------------------------------
--[[ WII Controller template by Ethanfel
---------------------------------------------------------------

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

db.Controllers.WII = {
	Hide = true,
	Color = {
		['UP'] 			= 	'62BBB2',
		['LEFT'] 		= 	'D35280',
		['RIGHT']		= 	'D84E58',
		['DOWN'] 		= 	'6882A1',
	},
	Settings = {
		['CP_M1'] 		= 'CP_TL1',
		['CP_M2'] 		= 'CP_TL2',
		['CP_T1'] 		= 'CP_TR1',
		['CP_T2'] 		= 'CP_TR2',
		-------------------------------
		['skipGuideBtn'] = false,
		-------------------------------
		['interactWith'] = 'CP_T1',
		-------------------------------
	},
	Layout = {
		['CP_L_UP']		= {index = 1, anchor = 'LEFT'},
		['CP_L_LEFT']	= {index = 2, anchor = 'LEFT'},
		['CP_L_DOWN']	= {index = 3, anchor = 'LEFT'},
		['CP_L_RIGHT']	= {index = 4, anchor = 'LEFT'},
		['CP_T_L3'] 	= {index = 5, anchor = 'LEFT'},
		['CP_TL1']		= {index = 6, anchor = 'LEFT'},
		['CP_TL2']		= {index = 7, anchor = 'LEFT'},
		['CP_X_LEFT']	= {index = 8, anchor = 'LEFT'},
		
		-------------------------------------------------
		['CP_R_DOWN']	= {index = 1, anchor = 'RIGHT'},
		['CP_R_RIGHT']	= {index = 2, anchor = 'RIGHT'},
		['CP_TR1']		= {index = 3, anchor = 'RIGHT'},
		['CP_X_RIGHT']	= {index = 4, anchor = 'RIGHT'},
		['CP_TR2']		= {index = 5, anchor = 'RIGHT'},
		['CP_R_UP']		= {index = 7, anchor = 'RIGHT'},
		['CP_R_LEFT']	= {index = 6, anchor = 'RIGHT'},
	},
	Bindings = {
		["CP_L_UP"] = {
			["CTRL-"] = "MULTIACTIONBAR3BUTTON1",
			["SHIFT-"] = "ACTIONBUTTON7",
			[""] = "ACTIONBUTTON1",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR3BUTTON7",
		},
		["CP_R_LEFT"] = {
			["CTRL-"] = "MULTIACTIONBAR3BUTTON5",
			["SHIFT-"] = "ACTIONBUTTON11",
			[""] = "ACTIONBUTTON5",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR3BUTTON11",
		},
		["CP_R_RIGHT"] = {
			["CTRL-"] = "TARGETSCANENEMY",
			["SHIFT-"] = "TARGETNEARESTENEMY",
			[""] = "CAMERAORSELECTORMOVE",
			["CTRL-SHIFT-"] = "TARGETPREVIOUSENEMY",
		},
		["CP_L_RIGHT"] = {
			["CTRL-"] = "MULTIACTIONBAR3BUTTON2",
			["SHIFT-"] = "ACTIONBUTTON8",
			[""] = "ACTIONBUTTON2",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR3BUTTON8",
		},
		["CP_L_DOWN"] = {
			["CTRL-"] = "MULTIACTIONBAR3BUTTON3",
			["SHIFT-"] = "ACTIONBUTTON9",
			[""] = "ACTIONBUTTON3",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR3BUTTON9",
		},
		["CP_T1"] = {
			[""] = "MULTIACTIONBAR1BUTTON12",
			["SHIFT-"] = "MULTIACTIONBAR1BUTTON11",
			["CTRL-"] = "MULTIACTIONBAR1BUTTON10",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR1BUTTON9",
		},
		["CP_L_LEFT"] = {
			["CTRL-"] = "MULTIACTIONBAR3BUTTON4",
			["SHIFT-"] = "ACTIONBUTTON10",
			[""] = "ACTIONBUTTON4",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR3BUTTON10",
		},
		["CP_R_UP"] = {
			["CTRL-"] = "MULTIACTIONBAR3BUTTON6",
			["SHIFT-"] = "ACTIONBUTTON12",
			[""] = "ACTIONBUTTON6",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR3BUTTON12",
		},
		["CP_T2"] = {
			[""] = "MULTIACTIONBAR2BUTTON8",
			["SHIFT-"] = "MULTIACTIONBAR2BUTTON9",
			["CTRL-"] = "MULTIACTIONBAR2BUTTON10",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR2BUTTON11",
		},
		["CP_X_RIGHT"] = {
			["CTRL-"] = "MULTIACTIONBAR1BUTTON7",
			["SHIFT-"] = "MULTIACTIONBAR1BUTTON8",
			[""] = "TOGGLEGAMEMENU",
			["CTRL-SHIFT-"] = "MULTIACTIONBAR2BUTTON7",
		},
		["CP_R_DOWN"] = {
			["CTRL-"] = "JUMP",
			["SHIFT-"] = "TARGETNEARESTFRIEND",
			[""] = "TURNORACTION",
			["CTRL-SHIFT-"] = "TARGETPREVIOUSFRIEND",
		},
		['CP_X_LEFT'] = {
			[''] 			= 'OPENALLBAGS',
			['SHIFT-'] 		= 'TOGGLECHARACTER0',
			['CTRL-'] 		= 'TOGGLESPELLBOOK',
			['CTRL-SHIFT-'] = 'TOGGLETALENTS',
		},
	}
}
