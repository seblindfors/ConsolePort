local db, Data, _, env = ConsolePort:DB(), ConsolePort:DB('Data'), ...; _, env.db = CPAPI.Define, db;

-- TODO: there are going to be options here, trust me.
-- Just waiting for player feedback on what they want to see.

ConsolePort:AddVariables({
	_(MAINMENU_BUTTON, 2);
	gameMenuScale = _{Data.Range(1, 0.05, 0.5, 2);
		name = 'Scale';
		desc = 'Scale of the Game Menu.';
		advd = true;
	};
})