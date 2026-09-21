local _, Data = CPAPI.LinkEnv(...)
---------------------------------------------------------------
ConsolePort:AddVariables({
---------------------------------------------------------------
	_(MAINMENU_BUTTON, INTERFACE_LABEL);
	gameMenuEnable = _{Data.Bool(true);
		name = 'Game Menu';
		desc = 'Replaces the game menu with a controller-friendly menu and a quick access ring.';
	};
	gameMenuScale = _{Data.Range(0.85, 0.05, 0.5, 2);
		name = 'Scale';
		desc = 'Scale of the game menu and radial companion.';
		deps = { gameMenuEnable = true };
	};
	gameMenuFontSize = _{Data.Range(15, 1, 8, 20);
		name = 'Font Size';
		desc = 'Font size of the ring slice buttons.';
		deps = { gameMenuEnable = true };
	};
	gameMenuCustomSet = _{Data.Bool(false);
		name = 'Use Custom Button Set';
		desc = 'Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.';
		deps = { gameMenuEnable = true };
	};
	gameMenuAccept = _{Data.Button('PAD1');
		name = 'Primary Button';
		desc = 'Performs an action and closes the menu.';
		deps = { gameMenuEnable = true, gameMenuCustomSet = true };
	};
	gameMenuPlural = _{Data.Button('PAD2');
		name = 'Plural Button';
		desc = 'Performs an action without closing the menu.';
		deps = { gameMenuEnable = true, gameMenuCustomSet = true };
	};
	gameMenuReturn = _{Data.Button('PADLSHOULDER');
		name = 'Return Button';
		desc = 'Returns to the previous menu.';
		deps = { gameMenuEnable = true, gameMenuCustomSet = true };
	};
	gameMenuSwitch = _{Data.Button('PADRSHOULDER');
		name = 'Switch Button';
		desc = 'Switches between the main menu and the radial companion.';
		deps = { gameMenuEnable = true, gameMenuCustomSet = true };
	};
})