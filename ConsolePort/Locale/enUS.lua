local L = select(2, ...).Locale;
---------------------------------------------------------------
-- enUS
---------------------------------------------------------------
-- NOTE: This file is not intended to be translated,
--       it is purely for the purpose of providing
--       a fallback locale in case the user's locale
--       is not supported.
---------------------------------------------------------------
-- Short
---------------------------------------------------------------
L.DESC_CAMERAZOOMIN           = 'Zooms the camera in. Hold for continuous zoom.';
L.DESC_CAMERAZOOMOUT          = 'Zooms the camera out. Hold for continuous zoom.';
L.DESC_OPENALLBAGS            = 'Opens and closes all bags.';
L.DESC_TOGGLEWORLDMAP_CLASSIC = 'Toggles the world map.';
L.DESC_TOGGLEWORLDMAP_RETAIL  = 'Toggles the combined world map and quest log.';
L.NAME_EASY_MOTION            = 'Target Unit Frames (Hold)';
L.NAME_RAID_CURSOR_FOCUS      = 'Focus Raid Cursor';
L.NAME_RAID_CURSOR_TARGET     = 'Target Raid Cursor';
L.NAME_RAID_CURSOR_TOGGLE     = 'Toggle Raid Cursor';
L.NAME_RING_MENU              = 'Menu Ring';
L.NAME_RING_PET               = 'Pet Ring';
L.NAME_RING_UTILITY           = 'Utility Ring';
L.NAME_UI_CURSOR_TOGGLE       = 'Toggle Interface Cursor';
---------------------------------------------------------------
-- Formats
---------------------------------------------------------------
L.FORMAT_HOLD_BINDING         = '%s (Hold)';
L.FORMAT_RING_NUMERICAL       = 'Ring |cFF00FFFF%s|r';
---------------------------------------------------------------
-- Long
---------------------------------------------------------------
L.DESC_KEY_BUTTON1 = [[
	Used to toggle free cursor, allowing you to use your camera stick as a mouse pointer.

	While one of your buttons is set to emulate left click, this binding cannot be changed.
]];
L.DESC_KEY_BUTTON2 = [[
	Used to toggle center cursor, allowing you to interact with objects and characters
	in the game world, at a center-fixed mouse position.

	While one of your buttons is set to emulate right click, this binding cannot be changed.
]];
L.DESC_INTERACTTARGET = [[
	Allows you to interact with NPCs and objects in the game world.

	Has the same capability as center cursor, but does not require you to
	aim the cursor or crosshair directly on the target.

	Interactables are highlighted when in range.
]];
L.DESC_TARGETSCANENEMY = [[
	Scans for enemies in a narrow cone in front of you.
	Hold down to highlight targets before making the decision
	to switch targets.

	Especially useful for quickly switching targets
	while in combat with high precision.

	The target priority is aim biased, meaning that the
	target closest to the center of the cone will be
	selected first. This may result in prioritizing a
	distant target over a closer one, if the distant
	target is closer to the center of the cone.

	Recommended as main targeting binding for most players.
]];
L.DESC_TARGETNEARESTENEMY = [[
	Switch between the nearest enemy targets in front of you.
	Without a current target, the centermost enemy will be selected.
	Otherwise it will cycle through the nearest targets.

	Hold down to highlight targets before making the decision
	to switch targets.

	Recommended for use as a secondary targeting binding,
	or as main targeting binding in casual gameplay or if
	target scan requires too much precision to be comfortable.

	Not recommended for dungeons or other high precision scenarios.
]];
L.DESC_JUMP = [[
	Can also be used to swim up while under water, ascend with
	flying mounts, and lift off or flap upward while dragonriding.

	Jump is useful to bridge gaps in movement while doing a left-handed
	action that requires your thumb.

	In a regular setup, the left stick controls your movement.
	If you need to press a directional pad combo while on the move,
	jump can be used to maintain your forward momentum, while briefly
	taking your thumb off the stick.
]];
L.DESC_TOGGLEAUTORUN = [[
	Autorun will cause your character to continue moving
	in the direction you're facing without any input from you.

	Autorun is useful to alleviate thumb strain from long
	periods of movement, or to free up your thumb to do other
	things while you're on the move.
]];
L.DESC_TOGGLEGAMEMENU = [[
	The menu binding handles all functionality which occurs by pressing
	the Escape key on a keyboard. It handles different actions based
	on the current state of the game.

	If there are any ongoing actions related to spells or targeting,
	they will be cancelled. Pressing the binding with an active target
	will clear it. Pressing the binding while casting a spell will
	interrupt the spell cast.

	The binding also handles various other cases depending on what
	is currently displayed on the screen. For example, if any panel
	is open, such as the spellbook, the binding will perform the
	necessary action to close or hide it.

	If none of the above cases apply, the game menu will open or
	close when pressed.
]];
L.DESC_EXTRAACTIONBUTTON1 = [[
	The extra action button houses a temporary ability used in
	various quests, scenarios and boss encounters.

	When this binding is unset, the extra action button is always
	available on the utility ring.

	This button appears on your gamepad action bar as a normal
	action button, but you cannot change its content.
]];
L.DESC_EASY_MOTION = [[
	Generates unit hotkeys for your on-screen unit frames,
	allowing you to swap between friendly targets quickly.

	To use, hold the binding down, then tap the prompted
	keys you see on your target of choice, then release
	the binding to change your target.

	This binding is highly recommended for healers in 5-man
	game content, as it provides an extremely fast method of
	targeting in smaller groups.

	In raids, the complexity of necessary input
	to single out your preferred target can be daunting.
	See Toggle Raid Cursor for a different choice.
]];
L.DESC_RAID_CURSOR = [[
	Toggles a cursor that clamps to your on-screen
	unit frames, allowing you to heal friendly players
	while maintaining another target.

	The raid cursor can also be set to target directly,
	where moving the cursor will swap your current target.

	While in use, the raid cursor occupies one set of
	directional pad combinations to control the cursor position.

	When in routing mode, the cursor does not re-route macros or
	ambiguous spells, such as a priest's Penance.

	See Target Unit Frames for a different choice.
]];
L.DESC_RING_CUSTOM = [[
	A ring menu where you can add your items, spells, macros and
	mounts that you do not want to sacrifice action bar space for.

	To use, hold the binding down, tilt your stick in the direction
	of the item you want to select, then release the binding.

	To remove items from the ring, follow the tooltip prompt when you
	have the item in question focused.
]];
L.DESC_RING_UTILITY = [[
	A ring menu where you can add your items, spells, macros and
	mounts that you do not want to sacrifice action bar space for.

	To use, hold the binding down, tilt your stick in the direction
	of the item you want to select, then release the binding.

	To add items to the ring, follow the prompt from the interface
	cursor, or alternatively, pick something up on your mouse cursor,
	and press the binding to drop it in the ring.

	To remove items from the ring, follow the tooltip prompt when you
	have the item in question focused.

	The utility ring automatically adds quest items and temporary
	abilities that you have not placed on your action bar.
]];
L.DESC_RING_PET = [[
	A ring menu that lets you control your current pet.
]];
L.DESC_RING_MENU = [[
	A ring menu that gathers common panels and frequent actions
	in one place for quick access.

	The ring can also be accessed from the game menu without a
	separate binding, by switching page.
]];
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00Import|r

Paste an exported string below, then load and select the data you want to import. Imported data will overwrite your current data when applicable.

Use %s to copy the string from the source, and %s to paste the string below.
]];
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00Export|r

Select which data you want to export. A string will be generated below, which you can then paste into another client, or share with others.

Use %s to copy the string.
]];
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00Import|r

Import failed:
]];
L.SELECTED_RING_TEXT = [[This is your currently selected ring.
When you press and hold the key binding, all your selected abilities will appear in a ring on the screen.

Tilt your radial stick in the direction of the ability or item you want to use, then release the key binding to commit.]];
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00Create New Ring|r
Please choose a name for your new ring:]];
L.SET_RING_BINDING_TEXT = [[ 
|cFFFFFF00Set Binding|r

Press a button combination to select a new binding for this ring.

]];
L.RING_MENU_DESC = [[Create your own ring menus where you can add your items, spells, macros and mounts that you do not want to sacrifice action bar space for.

To use, hold the selected binding down, tilt your stick in the direction of the item you want to select, then release the binding.

The default ring, or the |CFF00FF00Utility Ring|r, has special properties to alleviate questing and world interaction, and is not static. It will automatically add and remove items as necessary.

If you want to create a ring to use in your rotation and not just for utility, it's highly recommended to use a custom ring for this purpose.]];
L.RING_EMPTY_DESC = [[You do not have any abilities in this ring yet.]];
L.CLEAR_RING_TEXT = [[|cFFFFFF00Clear Utility Ring|r
Are you sure you want to clear your utility ring?]];
L.REMOVE_RING_TEXT = L[[|cFFFFFF00Remove Ring|r
Are you sure you want to remove the current ring?]];