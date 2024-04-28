local Data, _, env = ConsolePort:DB('Data'), ...; _ = CPAPI.Define;

env.DefaultLayout = {
	[1] = { 
		{"a", "A", "1", "/s "},
		{"b", "B", "2", "/p "},
		{"c", "C", "3", "/i "},
		{"d", "D", "4", "/g "},
	},
	[2] = { 
		{"e", "E", "5", "/y "},
		{"f", "F", "6", "/w "},
		{"g", "G", "7", "/e "},
		{"h", "H", "8", "/r "},
	},
	[3] = { 
		{"i", "I", "9", "/raid "},
		{"j", "J", "<", "/readycheck "},
		{"k", "K", "0", "/rw "},
		{"l", "L", ">", "%T "},
	},
	[4] = { 
		{"m", "M", "@", "^"},
		{"n", "N", "&", "#"},
		{"o", "O", "$", "€"},
		{"p", "P", "%", "£"},
	},
	[5] = { 
		{"q", "Q", "/", "½"},
		{"r", "R", "(", "["},
		{"s", "S", "\\", "\|"},
		{"t", "T", ")", "]"},
	},
	[6] = { 
		{"u", "U", "+", "§"},
		{"v", "V", "*", "{"},
		{"w", "W", "=", "¿"},
		{"x", "X", "/", "}"},
	},
	[7] = { 
		{"y", "Y", "{rt1}", "{rt1}"},
		{"z", "Z", "{rt2}", "{rt2}"},
		{"\"", "'", "{rt3}", "{rt3}"},
		{"-", "_", "{rt4}", "{rt4}"},
	},
	[8] = { 
		{"!", "!", "{rt5}", "{rt5}"},
		{".", ":", "{rt6}", "{rt6}"},
		{",", ";", "{rt7}", "{rt7}"},
		{"?", "?", "{rt8}", "{rt8}"},
	},
}

env.DefaultMarkers = {
	["{rt1}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1:0|t",
	["{rt2}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_2:0|t",
	["{rt3}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_3:0|t",
	["{rt4}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_4:0|t",
	["{rt5}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_5:0|t",
	["{rt6}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_6:0|t",
	["{rt7}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_7:0|t",
	["{rt8}"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:0|t",
	
	["{ck1}"] = "|TInterface\\AddOns\\ConsolePortKeyboard\\Textures\\IconSpace:0|t",
	["{ck2}"] = "|TInterface\\AddOns\\ConsolePortKeyboard\\Textures\\IconEraser:0|t",
	["{ck3}"] = "|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:0|t",
	["{ck4}"] = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:0|t",

	["/rw "] = "|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:0|t",
	["/raid "] = "|TInterface\\Scenarios\\ScenarioIcon-Boss:0|t",
	["/readycheck "] = "|TInterface\\RAIDFRAME\\ReadyCheck-Waiting:0|t",
	["/attacktarget "] = "|TInterface\\CURSOR\\Attack:0|t",

	["%T "] = "|TInterface\\MINIMAP\\TRACKING\\Target:0|t",
	["%T"]  = "|TInterface\\MINIMAP\\TRACKING\\Target:0|t",
	["%F "] = "|TInterface\\MINIMAP\\TRACKING\\Focus:0|t",
	["%F"]  = "|TInterface\\MINIMAP\\TRACKING\\Focus:0|t",

	["/s "] = "/s",
	["/p "] = "/p",
	["/i "] = "/i",
	["/g "] = "/g",
	["/y "] = "/y",
	["/w "] = "/w",
	["/e "] = "/e",
	["/r "] = "/r",
}

function env:GetText(text)
	return self.Markers[text] or text;
end

local DEPENDENCY = { keyboardEnable = true };
ConsolePort:AddVariables({
	_('Radial Keyboard', 2);
	keyboardSpaceButton = _{Data.Button('PAD1');
		name = 'Space';
		desc = 'Button to use to trigger the space command.';
		deps = DEPENDENCY;
	};
	keyboardEnterButton = _{Data.Button('PAD2');
		name = 'Enter';
		desc = 'Button to use to trigger the enter command.';
		deps = DEPENDENCY;
	};
	keyboardEraseButton = _{Data.Button('PAD3');
		name = 'Erase';
		desc = 'Button to use to erase characters.';
		deps = DEPENDENCY;
	};
	keyboardEscapeButton = _{Data.Button('PAD4');
		name = 'Escape';
		desc = 'Button to use to trigger the escape command.';
		deps = DEPENDENCY;
	};
	keyboardMoveLeftButton = _{Data.Button('PADDLEFT');
		name = 'Move Left';
		desc = 'Button to use to move the cursor leftwards.';
		deps = DEPENDENCY;
	};
	keyboardMoveRightButton = _{Data.Button('PADDRIGHT');
		name = 'Move Right';
		desc = 'Button to use to move the cursor rightwards.';
		deps = DEPENDENCY;
	};
	keyboardNextWordButton = _{Data.Button('PADDDOWN');
		name = 'Next Word';
		desc = 'Button to select next suggested word.';
		deps = DEPENDENCY;
	};
	keyboardPrevWordButton = _{Data.Button('PADDUP');
		name = 'Previous Word';
		desc = 'Button to select previous suggested word.';
		deps = DEPENDENCY;
	};
	keyboardAutoCorrButton = _{Data.Button('PADRTRIGGER');
		name = 'Insert Suggestion';
		desc = 'Button to insert suggested word.';
		deps = DEPENDENCY;
	};
	keyboardDictPattern = _{Data.String("[%a][%w']*[%w]+");
		name = 'Dictionary Match Pattern';
		desc = 'Lua pattern to match words for dictionary lookups.';
		advd = true;
		deps = DEPENDENCY;
	};
	keyboardDictAlphabet = _{Data.String('abcdefghijklmnopqrstuvwxyz');
		name = 'Dictionary Match Alphabet';
		desc = 'Alphabet to use for dictionary suggestions and word processing.';
		advd = true;
		deps = DEPENDENCY;
	};
	keyboardDictYieldRate = _{Data.Number(4000, 500, true);
		name = 'Autocorrect Yield Rate';
		desc = 'Amount of spell correction mutations to yield per frame.';
		note = 'A higher rate will yield suggestions faster, but may cause stuttering.';
		advd = true;
		deps = DEPENDENCY;
	};
})