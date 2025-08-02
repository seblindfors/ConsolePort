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
]];
L.DISC_KEY_BUTTON1 = [[
	While one of your buttons is set to emulate left click, this binding cannot be changed.
]];
L.DESC_KEY_BUTTON2 = [[
	Used to toggle center cursor, allowing you to interact with objects and characters
	in the game world, at a center-fixed mouse position.
]];
L.DISC_KEY_BUTTON2 = [[
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
L.SLOT_NO_BINDING = [[
|cFFFFFF00Set Binding|r

%s in %s, does not have a binding assigned to it.

Press a button combination to select a new binding for this slot.

]];
L.SLOT_SET_BINDING = [[
|cFFFFFF00Set Binding|r

Press a button combination to select a new binding for %s.

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
L.CLEAR_RING_TEXT = [[|cFFFFFF00Clear %s|r
Are you sure you want to clear the ring?]];
L.REMOVE_RING_TEXT = [[|cFFFFFF00Remove %s|r
Are you sure you want to remove the ring?]];
L.ACTIONBAR_MAIN_DESC = [[The main action bar is your primary location for rotation abilities and other frequently used actions.

This bar is dynamic and can automatically change to different pages depending on your current situation.

For example, the main action bar will switch to a special set of abilities when you enter a vehicle, participate in a pet battle, shapeshift into a different form, enter a combat stance, or take control of another unit.

This allows you to access context-specific abilities without needing to manually change your action bar setup.

When you return to your normal state, your regular abilities will reappear on the bar.]]
L.ACTIONBAR_FORM_DESC = [[Activating this form will automatically switch your main action bar to display the abilities associated with this form.

The form shares bindings with your main action bar, allowing you to use your regular combos to access the abilities in this form.

When you exit this form, your main action bar will revert to its previous state, displaying your regular abilities.]];
L.ACTIONBAR_FORM_ACTIVE_DESC = [[This form is currently active, and your main action bar is displaying the abilities associated with it.]];
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[The actual page number of an action bar does not always match the displayed name, due to how the action bar system was originally designed.

This discrepancy can be ignored if you're not using a custom action page solution. Both are shown for reference.]];
L.GFX_GENERAL_INFO = [[
	Select the gamepad graphics that are closest to your gamepad's appearance.

	Choosing graphics does not change how your gamepad works, it only changes the appearance of the interface.

	Graphics are used to show you which buttons are currently bound to which actions, and to provide a visual reference for your gamepad's layout.

	Some optional settings recommendations are provided based on your choice.
]];
L.DEVICE_DESC_PLAYSTATION4 = [[
	PlayStation 4 controller, also known as DualShock 4, is the previous generation gamepad from Sony.

	It is a feature-rich gamepad with a touchpad, motion controls, and support for all its buttons in the game.

	To take advantage of all the features, you may need to install PlayStation Accessories (Windows).
]];
L.DEVICE_DESC_PLAYSTATION5 = [[
	PlayStation 5 controller, also known as DualSense, is currently the best gamepad for World of Warcraft.

	It is the most feature-complete gamepad available, with motion controls, touchpad, and in the case of the Edge variant, native back paddles.
	All buttons on the gamepad can be used in the game.

	To take advantage of all the features, you may need to install PlayStation Accessories (Windows).
]];
L.DEVICE_DESC_STEAMDECK = [[
	Steam Decks typically run World of Warcraft through Proton via the Steam client.

	When playing through Steam, the device should use a game profile that covers at least a standard Xbox layout.

	Gamepad with Mouse Trackpad provides a solid foundation.

	Steam Decks cannot use their paddles natively in World of Warcraft.
	The paddles can be mapped using emulation, or with keyboard keys in the Steam Input settings.

	The in-game Steam Deck preset may also be suitable for other handheld computers, due to the similar control layout.
]];
L.DEVICE_DESC_XBOX = [[
	Xbox variants are the most common gamepads, and are well-supported by World of Warcraft.

	The Xbox Elite controller cannot use its paddles natively in the game, but they can be used to simulate other gamepad buttons,
	using the Xbox Accessories app (Windows).

	With external software, such as Steam or reWASD, the paddles can be mapped to keyboard keys, allowing use in game.

	The center button is reserved for the Xbox Guide, and cannot be used in the game.

	Also recommended for Steam Input, consistent with the Xbox 360 controller it emulates.
]];
L.DEVICE_DESC_SWITCHPRO = [[
	Nintendo Switch Pro controller has a similar layout to the Xbox controller, but with inverted button labels.

	The Pro controller has four center buttons, giving it a slight edge over a standard Xbox controller.
]];
L.CONTROLS_GENERAL_INFO = [[
	Select your preferred control scheme.
]];
L.CONTROLS_MODIFIERS_DESC = [[
	Modifiers swap between binding sets, and also emulate keyboard control keys (Shift, Ctrl, Alt).

	Holding a modifier will temporarily swap your bindings to an alternate set, expanding your available actions.

	Modifiers can be tapped - pressed and released quickly - to perform regular bindings.

	They can also be combined with each other; using two modifiers gives you a total of four sets of bindings to access,
	and three modifiers give you eight sets of bindings.

	Two modifiers is enough for most players to have a comfortable set of bindings,
	without adding too much complexity.
]];
L.CONTROLS_MODIFIERS_LEFT = [[
	Use left handed modifiers to keep movement and binding set swapping on the left side of the gamepad.

	Having separate roles for the left and right hands may help with ergonomics and coordination.
]];
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	Use both triggers as modifiers to split your bindings between the left and right side.

	This may be beneficial if you are transitioning from FFXIV, or if you prefer the crossbar mental model.
]];
L.CONTROLS_MODIFIERS_CUSTOM = [[
	Use custom modifier settings.

	It is recommended to set modifiers to the shoulders or triggers, as they are the most accessible buttons on the gamepad.
]];
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	Mouse buttons can be emulated to provide mouse-like functionality.

	These bindings are vital in some cases, such as confirming spell placements on the ground,
	precise targeting in a crowd, and niche interface actions.

	They can be combined with modifiers to further replicate the functionality of a mouse.

	These buttons are also used to toggle the cursor, where it can have three different states:

	- Free; you can use your gamepad to move the cursor around the screen.

	- Centered; the cursor is fixed around the center of the screen, to aim at objects and characters
	and to place spells on the ground.

	- Hidden; the cursor is still centered, but not visible on the screen. Its position is indicated by a crosshair.
]];
L.CONTROLS_MOUSE_INVERTED = [[
	Use inverted mouse button bindings.

	Use the left stick to toggle between the centered and hidden cursor mode, and to right click.

	Use the right stick to toggle the free cursor mode, and to left click.
]];
L.CONTROLS_MOUSE_REGULAR = [[
	Use regular mouse button bindings.

	Use the left stick to toggle the free cursor mode, and to left click.

	Use the right stick to toggle between the centered and hidden cursor mode, and to right click.
]];
L.CONTROLS_MOUSE_CUSTOM = [[
	Use custom mouse button settings.

	World of Warcraft treats mouse buttons in two separate, mostly hidden ways.

	- When you click on the game's interface (like buttons or menus), the interface only reacts
	to mouse clicks, which can be emulated by a gamepad.

	- When you click on things in the game world (like targeting or interacting), it uses regular bindings.

	It's highly recommended to keep these actions together to fill the same role as a mouse.
]];
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	Use the testing tool to verify that your gamepad is working correctly.

	The test will ask you to press buttons and move axes on your gamepad,
	to ensure that all buttons and sensors are functioning as expected.

	Troubleshooting:

	- Ensure that your gamepad is connected and recognized by the operating system.

	- Check for any conflicting software that may interfere with your device,
	such as Steam running in the background on Windows.

	- If using a handheld computer, ensure that the device is set to game mode
	in the control center. Desktop mode will not work correctly.

	- Update drivers and install any necessary software for your gamepad.
]];
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	The tests will automatically expire after a few seconds if no input is detected.
]];
L.DEFAULTS_GENERAL_INFO = [[
	Finalize the setup by applying recommended settings and bindings for your gamepad.
]];
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	Your gamepad type (%s) does not have any recommended settings to apply.
]];
L.DEFAULTS_SETTINGS_DESC = [[
	Apply recommended settings for your gamepad type (%s):
]];
L.DEFAULTS_SETTINGS_APPLIED = [[
	Recommended settings for your gamepad type (%s) have been applied.
]];
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	Apply recommended bindings.

	These bindings are based on your previous choices, and should give you a good starting point
	for your gamepad setup. You can always change them later.

	This action does not overwrite or interfere with any existing keyboard bindings,
	but keep in mind that action bars are shared between them.

	If you plan to switch between keyboard and gamepad, it's recommended to change your
	gamepad bindings rather than moving abilities around on your action bars, when adjusting your setup.
]];
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	Start from a blank slate.

	This action will clear all your current gamepad bindings, including the Blizzard defaults,
	to allow you to set up your bindings from scratch.

	This action does not overwrite or interfere with any existing keyboard bindings,
	but keep in mind that action bars are shared between them.

	If you plan to switch between keyboard and gamepad, it's recommended to change your
	gamepad bindings rather than moving abilities around on your action bars, when adjusting your setup.
]];
L.LINK_DISCORD_TEXT = [[
	The community where you can find support, discuss gameplay, share ideas, and find like-minded players.

	Click here to join the server.
]];
L.LINK_PATREON_TEXT = [[
	The development and maintenance of this addon takes a lot of time and effort,
	but ConsolePort will always be completely free to use.

	Become a supporter on Patreon to unlock your Discord flair, and in turn support the future of the project.

	Click here to become a patron.
]];
L.LINK_PAYPAL_TEXT = [[
	Donations are invested right back into the development and maintenance of the addon.

	Any contribution, big or small, is highly appreciated.

	Click here to donate via PayPal.
]];
L.LINK_COPY = [[
	Link to %s.
	
	Ctrl+A to select and Ctrl+C to copy.
	
	Paste (Ctrl+V) the link in your web browser.
]];