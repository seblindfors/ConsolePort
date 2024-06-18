local db, Data, _, env = ConsolePort:DB(), ConsolePort:DB('Data'), ...; _, env.db = CPAPI.Define, db;
------------------------------------------------------------------------------------------------------------
ConsolePort:AddVariables({
------------------------------------------------------------------------------------------------------------
	_(MAINMENU_BUTTON, 2);
	gameMenuScale = _{Data.Range(1, 0.05, 0.5, 2);
		name = 'Scale';
		desc = 'Scale of the game menu and radial companion.';
		advd = true;
	};
	gameMenuCustomSet = _{Data.Bool(false);
		name = 'Use Custom Button Set';
		desc = 'Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.';
		advd = true;
	};
	gameMenuButton1 = _{Data.Button('PAD1');
		name = 'Primary Button';
		desc = 'Binds a game menu action of choice, and finalizes the other selections.';
		advd = true;
		deps = { gameMenuCustomSet = true };
	};
	gameMenuButton2 = _{Data.Button('PAD2');
		name = 'Cancel Button';
		desc = 'Cancel the ring menu selections.';
		advd = true;
		deps = { gameMenuCustomSet = true };
	};
	gameMenuButton3 = _{Data.Button('PAD3');
		name = 'Extra Button 1';
		desc = 'Binds an extra game menu action of choice.';
		advd = true;
		deps = { gameMenuCustomSet = true };
	};
	gameMenuButton4 = _{Data.Button('PAD4');
		name = 'Extra Button 2';
		desc = 'Binds an extra game menu action of choice.';
		advd = true;
		deps = { gameMenuCustomSet = true };
	};
})