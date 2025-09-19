local _, Data = CPAPI.LinkEnv(...)
---------------------------------------------------------------
ConsolePort:AddVariables({
---------------------------------------------------------------
	_(ACCESSIBILITY_LABEL, INTERFACE_LABEL);
	showAbilityBriefing = _{Data.Bool(true);
		name = 'Show Ability Briefings';
		desc = 'Displays a briefing for newly acquired abilities.';
	};
	useCustomLootFrame = _{Data.Bool(true);
		name = 'Use Custom Loot Frame';
		desc = 'Replaces the default loot frame with a custom version optimized for controller navigation.';
		list = LOOT;
	};
	useGlobalLootTooltip = _{Data.Bool(false);
		name = 'Use Global Loot Tooltip';
		desc = 'Use global game tooltip for loot information, allowing other addons to add information to lootable items.';
		list = LOOT;
	};
})