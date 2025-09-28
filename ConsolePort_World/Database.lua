local _, Data, env, db, name = CPAPI.LinkEnv(...);
---------------------------------------------------------------
LibStub('RelaTable')(name, env, false);
---------------------------------------------------------------

env.QMenuID = CreateCounter();
env.ActionButton  = LibStub('ConsolePortActionButton');

function env:GetTooltipPromptForClick(clickID, text)
	local device = db.Gamepad.Active;
	local btnID = db('QMenu'..clickID)
	if device and btnID then
		return device:GetTooltipButtonPrompt(btnID, text)
	end
end

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
	_('Quick Menu', INTERFACE_LABEL);
	QMenuLeftButton = _{Data.Button('PAD1');
		name = table.concat({ACCEPT, PRIMARY, KEY_BUTTON1}, ' | ');
		desc = 'Primary accept button, to use or confirm a quick menu action.';
	};
	QMenuRightButton = _{Data.Button('PAD2');
		name = table.concat({ACCEPT, SECONDARY, KEY_BUTTON2}, ' | ');
		desc = 'Secondary accept button, to use or confirm a quick menu action.';
	};
	QMenuMiddleButton = _{Data.Button('PAD4');
		name = table.concat({SPECIAL, KEY_BUTTON3}, ' | ');
		desc = 'Button to handle contextual actions, such as adding items to the utility ring or passing on loot.';
	};
	QMenuCancelButton = _{Data.Button('PAD3');
		name = CANCEL;
		desc = 'Button to cancel or exit the quick menu.';
		note = 'The quick menu binding can be used to close the menu as well.';
	};
	QMenuCollectionBuffs = _{Data.Bool(true);
		name = 'Show Buffs';
		desc = 'Show active buffs in the quick menu.';
		list = INTERFACE_LABEL;
	};
	QMenuCollectionDebuffs = _{Data.Bool(true);
		name = 'Show Debuffs';
		desc = 'Show active debuffs in the quick menu.';
		list = INTERFACE_LABEL;
	};
})