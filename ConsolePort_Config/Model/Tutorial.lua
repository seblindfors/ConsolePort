local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------

-- NOTE: Do not change the order of these flags.
env.TutorialState = CPAPI.CreateFlags(
	'ControlSchemePreference',
	'ModuleSelection',
	'ExternalSupport'
);