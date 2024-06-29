local db, Data, _, env = ConsolePort:DB(), ConsolePort:DB('Data'), ...; _, env.db = CPAPI.Define, db;
------------------------------------------------------------------------------------------------------------
ConsolePort:AddVariables({
------------------------------------------------------------------------------------------------------------
	_(MAINMENU_BUTTON, 2);
	gameMenuScale = _{Data.Range(0.85, 0.05, 0.5, 2);
		name = 'Scale';
		desc = 'Scale of the game menu and radial companion.';
	};
	gameMenuFontSize = _{Data.Range(15, 1, 8, 20);
		name = 'Font Size';
		desc = 'Font size of the ring slice buttons.';
	};
	gameMenuCustomSet = _{Data.Bool(false);
		name = 'Use Custom Button Set';
		desc = 'Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.';
	};
	gameMenuAccept = _{Data.Button('PAD1');
		name = 'Primary Button';
		desc = 'Performs an action and closes the menu.';
		deps = { gameMenuCustomSet = true };
	};
	gameMenuPlural = _{Data.Button('PAD2');
		name = 'Plural Button';
		desc = 'Performs an action without closing the menu.';
		deps = { gameMenuCustomSet = true };
	};
	gameMenuReturn = _{Data.Button('PADLSHOULDER');
		name = 'Return Button';
		desc = 'Returns to the previous menu.';
		deps = { gameMenuCustomSet = true };
	};
	gameMenuSwitch = _{Data.Button('PADRSHOULDER');
		name = 'Switch Button';
		desc = 'Switches between the main menu and the radial companion.';
		deps = { gameMenuCustomSet = true };
	};
})