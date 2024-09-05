local db, Data, _, env = ConsolePort:DB(), ConsolePort:DB('Data'), ...; _, env.db = CPAPI.Define, db;
local MODID_SELECT = {'SHIFT', 'CTRL', 'ALT'};
local DEPENDENCY = { UIenableCursor = true };

---------------------------------------------------------------
-- Add variables to config
---------------------------------------------------------------
ConsolePort:AddVariables({
	_('Interface Cursor', 2);
	UIpointerAnimation = _{Data.Bool(true);
		name = 'Enable Animation';
		desc = 'Pointer arrow rotates in the direction of travel.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIpointerSound = _{Data.Bool(true);
		name = 'Enable Sound';
		desc = 'Play a sound when the pointer arrow reaches its destination.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIpointerDefaultIcon = _{Data.Bool(true);
		name = 'Show Default Button';
		desc = 'Show the default mouse action button.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIaccessUnlimited = _{Data.Bool(false);
		name = 'Unlimited Navigation';
		desc = 'Allow cursor to interact with the entire interface, not only panels.';
		note = 'Combine with use on demand for full cursor control.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIalgoOptimize = _{Data.Bool(true);
		name = 'Optimize Algorithm';
		desc = 'Use optimized pathfinding algorithm for cursor movement.';
		note = 'Disabling this may cause worse performance with many panels open.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIshowOnDemand = _{Data.Bool(false);
		name = 'Use On Demand';
		desc = 'Cursor appears on demand, instead of in response to a panel showing up.';
		note = 'Requires Toggle Interface Cursor binding to use the cursor.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIholdRepeatDisable = _{Data.Bool(false);
		name = 'Disable Repeated Movement';
		desc = 'Disable repeated cursor movements - each click will only move the cursor once.';
		deps = DEPENDENCY;
	};
	UIholdRepeatDelay = _{Data.Number(.125, 0.025);
		name = 'Repeated Movement Delay';
		desc = 'Delay until a movement is repeated, when holding down a direction, in seconds.';
		deps = { UIenableCursor = true, UIholdRepeatDisable = false };
		advd = true;
	};
	UIholdRepeatDelayFirst = _{Data.Number(.125, 0.025);
		name = 'Repeated Movement First Delay';
		desc = 'Delay until the first movement is repeated, when holding down a direction, in seconds.';
		deps = { UIenableCursor = true, UIholdRepeatDisable = false };
		advd = true;
	};
	UIleaveCombatDelay = _{Data.Number(0.5, 0.1);
		name = 'Reactivation Delay';
		desc = 'Delay before reactivating interface cursor after leaving combat, in seconds.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIpointerSize = _{Data.Number(22, 2, true);
		name = 'Pointer Size';
		desc = 'Size of pointer arrow, in pixels.';
		deps = DEPENDENCY;
		advd = true;
	};
	UIpointerOffset = _{Data.Number(-2, 1);
		name = 'Pointer Offset';
		desc = 'Offset of pointer arrow, from the selected node center, in pixels.';
		deps = DEPENDENCY;
		advd = true;
	};
	UItravelTime = _{Data.Range(4, 1, 1, 10);
		name = 'Travel Time';
		desc = 'How long the cursor should take to transition from one node to another.';
		note = 'Higher is slower.';
		deps = DEPENDENCY;
		advd = true;
	};
	UICursorLeftClick = _{Data.Button('PAD1');
		name = KEY_BUTTON1;
		desc = 'Button to replicate left click. This is the primary interface action.';
		note = 'While held down, can simulate dragging by clicking on the directional pad.';
		deps = DEPENDENCY;
	};
	UICursorRightClick = _{Data.Button('PAD2');
		name = KEY_BUTTON2;
		desc = 'Button to replicate right click. This is the secondary interface action.';
		note = 'This button is necessary to use or sell an item directly from your bags.';
		deps = DEPENDENCY;
	};
	UICursorSpecial = _{Data.Button('PAD4');
		name = 'Context Button';
		desc = 'Button to handle contextual actions, such as adding items to the utility ring.';
		deps = DEPENDENCY;
	};
	UICursorCancel = _{Data.Button('PAD3');
		name = 'Cancel Button';
		desc = 'Button to handle cancel actions, such as exiting menus.';
		deps = DEPENDENCY;
	};
	UImodifierCommands = _{Data.Select('SHIFT', unpack(MODID_SELECT));
		name = 'Modifier';
		desc = 'Which modifier to use for modified commands.';
		note = 'The modifier can be used to scroll together with the directional pad.';
		opts = MODID_SELECT;
		deps = DEPENDENCY;
	};
})

---------------------------------------------------------------
-- Standalone frame stack
---------------------------------------------------------------
-- This list aims to contain all the frames, popups, panels
-- that are not caught by frame managers (e.g. UIPanelWindows),
-- and exist within the FrameXML code in some shape or form. 

env.StandaloneFrameStack = {
	'ContainerFrameCombinedBags';
	'CovenantPreviewFrame';
	'EngravingFrame';
	'LFGDungeonReadyPopup';
	'OpenMailFrame';
	'PetBattleFrame';
	'ReadyCheckFrame';
	'SplashFrame';
	'StackSplitFrame';
	'UIWidgetCenterDisplayFrame';
};
for i=1, (NUM_CONTAINER_FRAMES   or 13) do tinsert(env.StandaloneFrameStack, 'ContainerFrame'..i) end
for i=1, (NUM_GROUP_LOOT_FRAMES  or 4)  do tinsert(env.StandaloneFrameStack, 'GroupLootFrame'..i) end
for i=1, (STATICPOPUP_NUMDIALOGS or 4)  do tinsert(env.StandaloneFrameStack, 'StaticPopup'..i)    end

env.UnlimitedFrameStack = {
	UIParent;
	DropDownList1;
	DropDownList2;
};


---------------------------------------------------------------
-- Frame management resources
---------------------------------------------------------------

-- Managers are periodically scanned by the frame stack handler
-- to add new frames to the registry. The table is associative
-- if the value is true, and indexed if the value is false.
env.FrameManagers = { -- table, isAssociative
	[UIPanelWindows]  = true;
	[UISpecialFrames] = false;
	[UIMenus]         = false;
};

-- Pipelines are hooked by the frame stack handler to add new
-- frames to the registry as they pass through the pipeline.
-- Global references are hooked by name, and methods are hooked
-- by name and method name.
env.FramePipelines = { -- global ref, bool or method
	ShowUIPanel             = true;
	StaticPopupSpecial_Show = true;
	HelpTipTemplateMixin    = 'Init';
};

---------------------------------------------------------------
-- Node management resources
---------------------------------------------------------------
env.IsClickableType = {
	Button      = true;
	CheckButton = true;
	EditBox     = true;
};

env.DropdownReplacementMacro = {
	SET_FOCUS   = '/focus %s';
	CLEAR_FOCUS = '/clearfocus';
	PET_DISMISS = '/petdismiss';
};

env.Attributes = {
	IgnoreNode   = 'nodeignore';
	IgnoreScroll = 'nodeignorescroll';
	PassThrough  = 'nodepass';
	Priority     = 'nodepriority';
	Singleton    = 'nodesingleton';
	SpecialClick = 'nodespecialclick';
	CancelClick  = 'nodecancelclick';
	IgnoreMime   = 'nodeignoremime';
};

---------------------------------------------------------------
-- Unavoidable taint error messages
---------------------------------------------------------------
env.ForbiddenActions = CPAPI.Proxy({
	['FocusUnit()'] = ([[
		While the interface cursor is active, focus cannot reliably be set from unit dropdown menus.

		Please use another method to set focus, such as the %s binding, a /focus macro or the raid cursor.
	]]):format(BLUE_FONT_COLOR:WrapTextInColorCode(BINDING_NAME_FOCUSTARGET));
	['ClearFocus()'] = ([[
		While the interface cursor is active, focus cannot reliably be cleared from unit dropdown menus.

		Please use another method to clear focus, such as the %s binding, a /focus macro or the raid cursor.
	]]):format(BLUE_FONT_COLOR:WrapTextInColorCode(BINDING_NAME_FOCUSTARGET));
	['CastSpellByID()'] = [[
		While the interface cursor is active, a few actions are not possible to perform reliably.
		It appears you tried to cast a spell from a source that has been tainted by the
		interface cursor.

		Please use another method to cast this spell, such as using a macro or your action bars.
	]];
}, function()
	return [[
		While the interface cursor is active, a few actions are not possible to perform reliably.
		It appears you tried to perform an action that has been blocked due to taint from the cursor.

		You can most likely ignore this message, but a reload may be required if your UI is not working properly.
	]];
end);