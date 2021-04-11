local Data, _, env = ConsolePort:DB('Data'), ...;

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

ConsolePort:AddVariables({
	keyboardInsertButton = {Data.Button('PADRSHOULDER');
		head = 'Keyboard';
		sort = 1;
		name = 'Insert';
		desc = 'Button to use to type highlighted characters.';
	};
	keyboardSpaceButton = {Data.Button('PAD1');
		head = 'Keyboard';
		sort = 2;
		name = 'Space';
		desc = 'Button to use to trigger the space command.';
	};
	keyboardEnterButton = {Data.Button('PAD2');
		head = 'Keyboard';
		sort = 3;
		name = 'Enter';
		desc = 'Button to use to trigger the enter command.';
	};
	keyboardEraseButton = {Data.Button('PAD3');
		head = 'Keyboard';
		sort = 4;
		name = 'Erase';
		desc = 'Button to use to erase characters.';
	};
	keyboardEscapeButton = {Data.Button('PAD4');
		head = 'Keyboard';
		sort = 5;
		name = 'Escape';
		desc = 'Button to use to trigger the escape command.';
	};
	keyboardMoveLeftButton = {Data.Button('PADDLEFT');
		head = 'Keyboard';
		sort = 6;
		name = 'Move Left';
		desc = 'Button to use to move the cursor leftwards.';
	};
	keyboardMoveRightButton = {Data.Button('PADDRIGHT');
		head = 'Keyboard';
		sort = 7;
		name = 'Move Right';
		desc = 'Button to use to move the cursor rightwards.';
	};
})