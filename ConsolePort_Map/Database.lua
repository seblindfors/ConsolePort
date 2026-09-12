local _, Data, env, db, name = CPAPI.LinkEnv(...);
---------------------------------------------------------------
LibStub('RelaTable')(name, env);
---------------------------------------------------------------
local DEPENDENCY = { mapEnable = true };

env.Attributes = {
	ModuleName = 'World Map';
	HeaderName = INTERFACE_LABEL;
};

---------------------------------------------------------------
-- Add variables to config
---------------------------------------------------------------
env.Variables = {
	_(env.Attributes.ModuleName, env.Attributes.HeaderName, 3);
	mapReplaceBinding = _{Data.Bool(true);
		name = 'Replace Map Binding';
		desc = 'Open the gamepad map instead of the default world map when pressing the world map binding.';
		deps = DEPENDENCY;
	};
	mapRedirectBlizzard = _{Data.Bool(false);
		name = 'Redirect Default Map';
		desc = 'Also open the gamepad map when the game itself opens the default world map, e.g. from the objective tracker.';
		note = 'Not possible in combat; the default map is shown instead.';
		deps = DEPENDENCY;
		advd = true;
	};
	mapFlightMode = _{Data.Bool(true);
		name = 'Flight Map';
		desc = 'Use the gamepad map when talking to a flight master.';
		deps = DEPENDENCY;
	};
	mapShowQuestLog = _{Data.Bool(true);
		name = 'Show Quest Log';
		desc = 'Show the quest log panel next to the map.';
		deps = DEPENDENCY;
	};
	mapScale = _{Data.Range(1.0, 0.05, 0.5, 1.5);
		name = 'Scale';
		desc = 'Scale of the map window.';
		deps = DEPENDENCY;
	};
	mapPanStick = _{Data.Select('Movement', 'Movement', 'Camera');
		name = 'Pan Stick';
		desc = 'Stick used to move the map.';
		deps = DEPENDENCY;
		advd = true;
	};
	mapZoomStick = _{Data.Select('Camera', 'Movement', 'Camera');
		name = 'Zoom Stick';
		desc = 'Stick used to zoom the map. Hold past the zoom limit to switch zones.';
		deps = DEPENDENCY;
		advd = true;
	};
	mapCursorSpeed = _{Data.Range(0.9, 0.1, 0.3, 2.0);
		name = 'Pan Speed';
		desc = 'Map movement speed, in screen widths per second.';
		deps = DEPENDENCY;
		advd = true;
	};
	mapZoomSpeed = _{Data.Range(1.6, 0.1, 0.5, 4.0);
		name = 'Zoom Speed';
		desc = 'Zoom speed at full stick deflection.';
		deps = DEPENDENCY;
		advd = true;
	};
	mapSnapRadius = _{Data.Range(40, 2, 0, 96);
		name = 'Snap Distance';
		desc = 'Distance in pixels within which the cursor settles on a map pin when the stick is released.';
		deps = DEPENDENCY;
		advd = true;
	};
	mapDrillDwell = _{Data.Range(0.35, 0.05, 0.1, 1.0);
		name = 'Zone Switch Delay';
		desc = 'Seconds to hold the zoom stick past the limit before switching to the zone under the cursor or to the parent map.';
		deps = DEPENDENCY;
		advd = true;
	};
	mapAcceptButton = _{Data.Button('PAD1');
		name = 'Accept Button';
		desc = 'Selects the focused pin or zooms into the zone under the cursor.';
		deps = DEPENDENCY;
	};
	mapCancelButton = _{Data.Button('PAD2');
		name = 'Cancel Button';
		desc = 'Returns to the parent map, or closes the map.';
		deps = DEPENDENCY;
	};
	mapWaypointButton = _{Data.Button('PAD4');
		name = 'Waypoint Button';
		desc = 'Places a map pin at the cursor, or clears it.';
		deps = DEPENDENCY;
	};
	mapResetButton = _{Data.Button('PAD3');
		name = 'Reset Button';
		desc = 'Resets the zoom and returns to your position.';
		deps = DEPENDENCY;
	};
	mapQuestLogButton = _{Data.Button('PADRSHOULDER');
		name = 'Quest Log Button';
		desc = 'Moves focus between the map and the quest log.';
		deps = DEPENDENCY;
	};
	mapTrackButton = _{Data.Button('PADLSHOULDER');
		name = 'Track Button';
		desc = 'Tracks or untracks the focused quest.';
		deps = DEPENDENCY;
	};
};

ConsolePort:AddVariables(env.Variables)

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
env.Const = {
	Width         = 1100;
	Height        = 720;
	QuestLogWidth = 320;
	Deadzone      = 0.15;
	DrillTrigger  = 0.6;
	BlizzardAddOns = { 'Blizzard_MapCanvas', 'Blizzard_SharedMapDataProviders' };
};
