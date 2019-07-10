local _, Help = ...

Help:AddPage('Gameplay', nil, [[<HTML><BODY>
	<H1 align="center">
		Gameplay
	</H1>
	<br/>
	<H2 align="left">
		A note to first time users
	</H2>
	<p align="left">
		If you're using ConsolePort for the first time, you should start out on a completely new or existing low level character.
		Playing the game with a controller is essentially like playing a completely new game, both in how it feels and how it handles.
		<br/><br/>
		Even though you might be a mythic raider with your regular keyboard and mouse, using a controller does not translate those skills as you might expect.
		If your intention is to eventually get to that level, know beforehand that there's an adaptation period for your muscle memory to form around controller gameplay.
		<br/><br/>
		Apart from the time it takes for your muscle memory to form, fully understanding the system along with all its quirks and benefits, will help you excel down the road.
		Please read the article on <a href="page:Common pitfalls">|cff69ccf0common pitfalls|r</a> to identify mistakes and road blocks before you grow accustomed to them.
		This article was specifically written for seasoned players who unknowingly make crucial mistakes that cause bad gameplay performance.
		<br/><br/>
		Do not compare your initial performance with a controller to however many years you've been playing the game on a regular setup.
		You will most likely struggle in the beginning. This is commonplace when you first start playing a new game.
		Starting out a new character makes sure that your spell loadout is slim, your adversaries are easy and you can take your time to get acquainted with
		the system.<br/><br/>
		Using ConsolePort for the first time on your main character may prove daunting and will throw you into the deep end immediately,
		rather than incrementally providing harder challenges. Once you've learned the system on one character however, you've learned it on all your characters.
		You will find that after due time learning the basics first, your skills translate well to your main character(s) as well.
		<br/><br/>- Munk, creator of ConsolePort
	</p><br/>
	<H2 align="left">
		Article index
	</H2>
	<p align="left">
		• Common pitfalls - things to avoid and know about before you get used to them<br/>
		• Cursor &amp; camera - details about the interplay of mouse and camera control<br/>
		• Interacting with the world - how to talk to quest givers and loot enemies<br/>
		• Optimization - how to optimize your gameplay for high-end content<br/>
		• Targeting - how the different targeting systems work and how to use them<br/>
		• Vital bindings - bindings that you can't live without
	</p>
</BODY></HTML>]])




Help:AddPage('Common pitfalls', 'Gameplay', [[<HTML><BODY>
	<H1 align="center">
		Common pitfalls
	</H1>
	<H2 align="left">
		Forgetting the shoulder
	</H2>
	<p align="left">
		The most common mistake among new and seasoned users alike is to forget the shoulder of your controller. This means any and all buttons on the back side.
		This is where your most precious bindings reside, because you can press these buttons even if you're moving both your character and the camera at the same time.
		<br/><br/>
		While it might seem intuitive to place your most used bindings and spells on the face buttons (otherwise known as XYAB buttons),
		they are not as good in crucial situations because you cannot press them while rotating the camera. The same relationship is true for the directional pad and movement.
	</p><br/>
	<H2 align="left">
		Placing casted spells and cooldowns on the face buttons
	</H2>
	<p align="left">
		While the directional pad might seem best suited for abilities rarely used or not at all, consider placing more of your cooldowns and spells with cast time on these bindings.
		Since you're generally not going to be moving while casting a spell, that spell is best suited where it does not interfere with camera control or target swapping.
		<br/><br/>
		While instant cast cooldowns may be triggered on the move, this can usually be bridged by jumping right before you use your ability, maintaining your forward momentum in the interim.
	</p><br/>
	<H2 align="left">
		Circle strafing, backpedaling and clumsy movement
	</H2>
	<p align="left">
		Are you suffering from any of these problems when you're in combat? This is usually an indication of the first and second point in this article being dismissed.
		If you want to test your setup, examine how well you can perform your usual rotation while running around your target in one direction while also panning the camera.
	</p><br/>
	<H2 align="left">
		Avoiding reticle spells and specializations that have them
	</H2>
	<p align="left">
		If you didn't already know, reticle spells can always be placed at their max distance by moving your cursor straight up, which allows you to perform
		near-instant max distance casting by simply flicking the right stick upwards before you place the spell.
		<br/><br/>
		It's also recommended to create macro duplicates of your reticle spells that can be placed under your character, by using the macro conditional [@player].
	</p><br/>
	<H2 align="left">
		Targeting with the mouse cursor
	</H2>
	<p align="left">
		Don't do it unless you absolutely have to. Read the article on <a href="page:Targeting">|cff69ccf0targeting|r</a> to understand how to efficiently target friends and foes alike.
	</p>
</BODY></HTML>]])




Help:AddPage('Cursor & camera', 'Gameplay', [[<HTML><BODY>
	<H1 align="center">
		Cursor &amp; camera
	</H1><br/>
	<p align="left">
		Having to use the mouse cursor for certain things is an inescapable necessity of the game. While most of your gameplay will be "locked" into camera mode,
		your cursor is still necessary for world interaction, reticle spell placement and the rare cases where you have to click on something in the interface in combat.
		<br/><br/>
		One thing to note right off the bat is that your controller is very much a functioning mouse. Your right stick controls the cursor movement and clicking down on either stick
		simulates the corresponding mouse button. You can even combine these buttons with your modifiers for modified clicks, necessary for things like socketing or linking items in your chat.
		<br/><br/>
		In terms of controlling the interplay between cursor and camera, you have many options to combine and choose between.
	</p><br/>
	<H2 align="left">
		Camera mode
	</H2>
	<p align="left">
		Entering "camera mode" (holding down right click on a regular mouse) can be <a href="run:ConsolePortOldConfig:OpenCategory('Controls') ConsolePort:SetCurrentNode(ConsolePortOldConfigContainerControlsMouseEvent1)">|cff69ccf0toggled by various events that you can set yourself in the general settings|r</a>.
		You can also set a controller specific binding to toggle in and out of camera mode. While unrecommended, you may also disable all these features to simply hold your right stick down to pan the camera.
		<br/><br/>
		You can easily escape the locked camera by pressing down on your right stick, using the double tapped modifier setting, using the "Toggle Mouse Look" binding or using the interact button functionality.
	</p><br/>
	<H2 align="left">
		Cursor mode
	</H2>
	<p align="left">
		The cursor will automatically show up when you're using the interact button functionality, clicking your right stick or when you're placing a reticle spell.
		Note that in the case of reticle spells, you will have to enable the setting to <a href="run:ConsolePortOldConfig:OpenCategory('Controls') ConsolePort:SetCurrentNode(ConsolePortOldConfigContainerControlsMouseEvent3)">|cff69ccf0hide the cursor when casting a spell|r</a> in order for the cursor to disappear again after you've placed your spell.
	</p><br/>
</BODY></HTML>]])




Help:AddPage('Targeting', 'Gameplay', [[<HTML><BODY>
	<H1 align="center">
		Targeting
	</H1><br/>
	<H2 align="left">
		Target Scan Enemy (Hold)
	</H2>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\TargetScan" align="right" width="384" height="192"/>
	<p align="left">
		This targeting binding focuses targets<br/>
		in a narrow cone and excludes all <br/>
		enemies that are not directly in front <br/>
		of you. This is the best targeting<br/>
		binding for all classes and situations,<br/>
		because it depends entirely on where <br/>
		you aim. It's precise and predictable.
		<br/><br/>
		Note that this binding will choose a <br/>
		distant target over a target near you<br/>
		if the distant target is closer to the<br/>
		center of where you are looking.
		<br/><br/><br/>
	</p>
	<H2 align="left">
		Target Nearest Enemy
	</H2>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\TargetTab" align="right" width="384" height="192"/>
	<p align="left">
		Commonly called "tab targeting",<br/>
		this targeting binding will switch<br/>
		between all targets around you.
		<br/><br/>
		Unlike target scanning, it will use<br/>
		a wider selection of possible targets<br/>
		and browse through them in order.<br/><br/>
		This binding works well for casual<br/>
		gameplay, but can behave unreliably<br/>
		in crowded areas or when precision<br/>
		is necessary. It's not recommended<br/>
		to use this binding in group content.
		<br/><br/><br/>
	</p>
	<H2 align="left">
		Targeting friendly players
	</H2>
	<p align="left">
		For friendly targeting and healing in groups or raids, ConsolePort offers two separate systems: the |cFFFF6600raid cursor|r and |cFFFF6600unit hotkeys|r.
		These can be used to easily switch between group members without using any mouse cursor.
	</p><br/>
	<H2 align="left">
		Targeting friendly NPCs, dead enemies and world objects
	</H2>
	<p align="left">
		Targeting any friendly NPC or dead enemy (looting) falls under <a href="page:Interacting with the world">|cff69ccf0interaction|r</a>. 
		There is no specific binding for this purpose, and will require your mouse cursor in most situations.
	</p>
</BODY></HTML>]])




Help:AddPage('Raid cursor', 'Targeting', [[<HTML><BODY>
	<H1 align="center">
		Raid cursor
	</H1><br/>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\RaidCursor" align="right" width="256" height="256"/>
	<H2 align="left">
		What is the raid cursor?
	</H2>
	<p align="left">
		The raid cursor is a special cursor that operates on your<br/>
		unit frames. When enabled, it overrides your directional pad<br/>
		to snap between your unit frames.
		<br/><br/>
		Depending on how your unit frame layout looks, the cursor <br/>
		will adapt accordingly. You can use this to your advantage<br/>
		by organizing your unit frames in either a horizontal or a<br/>
		vertical pattern depending on which directional buttons<br/>
		you prefer to use.
		<br/><br/>
		If you organize your unit frames in groups of five, you<br/>
		have an easy grid to operate on by using one axis to<br/>
		choose group and the other axis to choose player within<br/>
		that group. Since the placement of your unit frames <br/>
		determines how the cursor will choose the next target,<br/>
		you might have to place your frames strategically to<br/>
		ensure reliable targeting at all times.
	</p><br/>
	<H2 align="left">
		How to use the raid cursor
	</H2>
	<p align="left">
		The raid cursor is toggled by the controller binding |cFFFF6600Toggle Raid Cursor|r. When enabled, your plain directional pad bindings will be temporarily set
		to control the cursor instead. If you plan to use the raid cursor as your primary group targeter, consider evaluating your directional pad bindings so that you don't have
		underlying spells that you want to use in conjunction with the cursor, since these bindings will be unavailable while the cursor is active. Note that modified bindings will still work, so you're only sacrificing four bindings and not sixteen.
	</p><br/>
	<H2 align="left">
		Spell-routing and direct targeting
	</H2>
	<p align="left">
		The cursor itself has two different modes, where spell-routing is the default mode. This mode cleverly evaluates your action bar and remaps applicable spells
		to the cursor target. This mode allows you to essentially have two targets at once; you can maintain an enemy target while also targeting one of your friends, and any spells you use
		will be cast on your friend if they are helpful spells and at your enemy if they are harmful spells. Note that spell-routing completely ignores macros, ambiguous spells and reticle spells.
		<br/><br/>
		The raid cursor can also be used to target units directly. This mode is more like a traditional click simulator, where moving the cursor will change your current target.
	</p>
</BODY></HTML>]])




Help:AddPage('Unit hotkeys', 'Targeting', [[<HTML><BODY>
	<H1 align="center">
		Unit hotkeys
	</H1><br/>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\UnitHotkey" align="right" width="256" height="256"/>
	<H2 align="left">
		What are unit hotkeys?
	</H2>
	<p align="left">
		Unit hotkeys are dynamically generated hotkeys that<br/>
		allow you to target your group members almost instantly.
		<br/><br/>
		They are generated and applied by each unit's unique<br/>
		identifier and sorted by name. This system is truly dynamic<br/>
		and adapts to however many units you currently have to<br/>
		choose between.
		<br/><br/>
		Unit hotkeys are recommended for all players, since they<br/>
		allow you to target your friends with ease. They are<br/>
		particularly useful for healers and in 5-man content.
		<br/><br/>
		The complexity of this system grows with your unit pool,<br/>
		and produces input chains up to three consecutive key<br/>
		strokes per unit. While it's viable to use in full<br/>
		raid groups, the trade-off for a fast targeting system<br/>
		is the growing complexity of input needed per unit.
	</p><br/>
	<H2 align="left">
		How to use unit hotkeys
	</H2>
	<p align="left">
		The hotkeys are generated when the binding |cFFFF6600Target Unit Frames (Hold)|r is pressed. While the binding is held down,
		either your left or right set of face buttons are temporarily set to choose between targets in your current pool.
		When the binding is released, the selected unit will be chosen as your new target. Hold the binding, choose unit, and release to target.
		<br/><br/>
		Consecutive key strokes after an applicable unit has been found will stop your target change if there are no more applicable units. The hotkeys are filtered out with each step to show you
		which buttons to hit next in order to filter the unit pool further.
	</p><br/>
	<H2 align="left">
		Advanced settings and filtering
	</H2>
	<p align="left">
		The unit pool can be narrowed down or expanded with a string match criteria that looks for specific patterns in unit IDs. The default pattern matches yourself,
		your party and your raid members, but not bosses, your focus target or pets.
		<br/><br/>
		In the case of large unit pools, a custom mode can be set to leave semi-transparent hotkey icons on your unit frames after you've used the targeting system.
		While only guaranteed to match perfectly if your group composition doesn't change, this still gives you some idea of which input sequence will be generated for each group member.
	</p>
</BODY></HTML>]])




Help:AddPage('Interacting with the world', 'Gameplay', [[<HTML><BODY>
	<H1 align="center">
		Interacting with the world
	</H1><br/>
	<p align="left">
		Interacting with the world in the most general sense is only possible through using your mouse cursor. This entails looting, talking to NPCs and clicking world objects
		such as herbs, ore deposits and other items that you find on the ground.
		<br/><br/>
		Having that said, ConsolePort has a special system in place to alleviate some of these tasks, called the <a href="page:Interact button">|cff69ccf0interact button|r</a>.
		This system does not encompass everything, but the most common things like looting and talking to NPCs are much easier with this functionality enabled.
		<br/><br/>
		This article will focus on all the other ways to interact with the world, but the interact button is the recommended solution once you know how it works.
	</p><br/>
	<H2 align="left">
		Pressing |TInterface\AddOns\ConsolePort\Controllers\PS4\Icons64\CP_T_R3:24:24:0:0|t or |TInterface\AddOns\ConsolePort\Controllers\XBOX\Icons64\CP_T_R3:24:24:0:0|t
	</H2>
	<p align="left">
		Pressing your right stick is the most straight-forward and applicable way of getting your mouse cursor out for interaction.
		This is the most commonly used way to interact because of its simplicity, but it requires you to always aim at whatever you want to interact with.<br/>
		This solution also has ergonomical problems, as most controller sticks are not designed to be pressed as often as you'll need to in this game.
		If your thumbs feel strained or stiff after or during your game session, consider other options to interact.
	</p><br/>
	<H2 align="left">
		Using the |cFFFF6600Right Mouse Button|r simulation binding
	</H2>
	<p align="left">
		If you prefer to interact with another binding than pressing your right stick, the |cFFFF6600controller|r binding category has a binding that
		allows any of your input combinations to behave as a right click. Note that this binding only works with world interaction and cannot be used to click anything in your interface.
	</p><br/>
	<H2 align="left">
		Interact With Mouseover
	</H2>
	<p align="left">
		You can also bind an arbitrary combination to |cFFFF6600Interact With Mouseover|r, which is almost the same as a right click. Unlike using a right click simulation,
		interacting with mouseover will also interact with your current target without aiming at it. This can be useful for interaction with things you're already targeting,
		without having to aim directly at them a second time. Without a target, this binding behaves exactly as a right click.
	</p>
</BODY></HTML>]])




Help:AddPage('Interact button', 'Interacting with the world', [[<HTML><BODY>
	<H1 align="center">
		Interact button
	</H1><br/>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\InteractExample" align="right" width="256" height="256"/>
	<p align="left">
		The <a href="run:ConsolePortOldConfig:OpenCategory('Controls') ConsolePort:SetCurrentNode(ConsolePortOldConfigContainerControls.InteractModule.Enable)">|cff69ccf0interact button|r</a> allows you to use one of your <br/>primary bindings to interact in certain cases where <br/>the original action of that binding isn't useful.
		<br/><br/>
		Instead of having to press a right click binding <br/>
		to target a nearby quest giver, loot your last enemy <br/>
		and interact with the world in general, <br/>
		you can use the interact button instead.
		<br/><br/>
		If configured properly, the interact button doesn't <br/>
		disrupt your combat abilities. This depends on how the<br/>
		original action relates to your current target.
		<br/><br/>
		The interact button is the only way to loot enemies <br/>without using your mouse cursor. There's also a <br/>separate option for looting in case you don't<br/>
		want the full functionality of the system.
		<br/><br/>
		Since this is based on your primary action, the interact button behaves differently depending on what you bind it to.
		For general use, it's recommended to have your interact button set to one of the shoulder bindings and the underlying action to be a direct damage spell.
		<br/><br/>
		Because reticle spells are loosely defined as neither harmful nor helpful spells, and healing spells will require a friendly target to cast, a direct damage spell is your best choice.
		In the case where your target is hostile, your direct damage spell will be used, but in all other cases you will be able to interact with the world around you.
	</p>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\InteractButton" align="center" width="460" height="230"/>
</BODY></HTML>]])




Help:AddPage('Optimization tips', 'Gameplay', [[<HTML><BODY>
	<H1 align="center">
		Optimization tips
	</H1><br/>
	<H2 align="left">
		Striving for agility and dexterity
	</H2>
	<p align="left">
		It's recommended to play with high stick sensitivity. Even though this game has a lock-on targeting system, it's still crucial for efficient gameplay to have good control over your camera movement.
		WoWmapper comes with rather high default settings compared to most console games, but these settings are not even high enough if you're dabbling in PvP.
		<br/><br/>
		If you're doing any content that requires a decent amount of precision, you should consider training your dexterity by increasing the sensitivity to where it's almost uncomfortable.
		Using a proper mouse curve for your right stick, you're able to do very small camera adjustments, while also allowing yourself to spin around in a split second.
	</p><br/>
	<H2 align="left">
		Things to consider when setting up your profile
	</H2>
	<p align="left">
		While it might feel intuitive to approach your spell and binding placement from the perspective of a role-playing game, instead consider the philosophy of a first-person shooter. For fluidity, proper aiming and fast-paced combat, you need to maximize the time you have your thumbs on the sticks of your controller. In World of Warcraft, where you have a large amount of bindings at your disposal, you should focus your most crucial and frequently used bindings in places where they do not require you to take your thumbs off the sticks.
		<br/><br/>
		|cff69ccf0•|r Focus your builders, spenders and speed-boosting spells, along with your targeting binding of choice, on the shoulder and back of the controller. Since the binding capacity of the shoulder is limited compared to the controller as a whole, choose carefully which bindings and spells you consider to be most valuable and place them here.<br/>
		|cff69ccf0•|r Put your less frequent rotational abilities on the face buttons. While still fairly easy to reach, this makes sure you're not taking your thumbs off the sticks too often.<br/>
		|cff69ccf0•|r Healers and casters should focus their casted spells on the directional pad. Generally speaking though, the directional pad is best suited for cooldowns, mounts and gimmicks.
		<br/><br/>
		Always consider the scenario in which you will be using a spell or binding before placing it. Are you on the move or stationary when using it? Does it require proper aiming? Does your choice reflect how often you will be using it? Think before you choose.
	</p><br/>
	<H2 align="left">
		Don't forget to jump
	</H2>
	<p align="left">
		Jumping normally serves few purposes beyond overcoming obstacles in your path, but on a controller it can provide the small window you need to do something that requires you to stop controlling your movement. Jumping as part of your rotation helps you perform more consistently in different scenarios. It's highly recommended to keep it close at hand.
	</p>
</BODY></HTML>]])




Help:AddPage('Advanced variables', 'Optimization tips', [[<HTML><BODY>
	<H1 align="center">
		List of documented advanced variables
	</H1><br/>
	<p align="left">
		You can change any of the following variables by using the advanced module to insert or modify the general settings table, or you can use slash commands with this format:<br/>
		|cff00ff10/consoleport|r |cff69ccf0variable|r |cffcc69f0value|r
		<br/><br/>
		You can print the complete list of available variables and their current values by using:<br/>
		|cff00ff10/consoleport|r cvar
		<br/><br/>
	</p>
	<H2 align="left">
		Advanced variables
	</H2>
	<p align="left">
		• alwaysHighlight   |cffff269b1|r/|cffff269b2|r/|cffff269bnil|r |cff757575 Always highlight tab target. |r<br/> 
		• centerLockRangeX   |cff87ffffpixels|r |cff757575 Center mouse look area width. |r<br/> 
		• centerLockRangeY   |cff87ffffpixels|r |cff757575 Center mouse look area height. |r<br/> 
		• centerLockDeadzoneX   |cff87ffffpixels|r |cff757575 Center mouse look area dead zone width. |r<br/> 
		• centerLockDeadzoneY   |cff87ffffpixels|r |cff757575 Center mouse look area dead zone height. |r<br/> 

		• disableSmartBind   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Disables spell placement helper. |r<br/>
		• disableSmartMouse   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Disables smart mouse behaviour and event handling. |r<br/>
		• disableStickMouse  |cffff269btrue|r/|cffff269bfalse|r |cff757575 Disables mouse simulation bindings. |r
		<br/><br/>

		• doubleModTap   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Toggles double mod tap camera control. |r<br/>
		• doubleModTapWindow   |cff87ffffseconds|r |cff757575 Controls how fast you have to double tap. |r<br/>
		• interactPushback   |cff87ffffseconds|r |cff757575 Controls how long after a spell cast until you can interact. |r
		<br/><br/>

		• raidCursorDirect   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Sets the raid cursor to direct targeting. |r<br/>
		• raidCursorModifier   |cffffff78SHIFT-|r/|cffffff78CTRL-|r/|cffffff78CTRL-SHIFT-|r/|cffffff78nil|r |cff757575 Set raid cursor modifier. Default is nil.|r
		<br/><br/>

		• UIleaveCombatDelay  |cff87ffffseconds|r |cff757575 Delay until interface cursor appears after combat.|r<br/>
		• UIholdRepeatDelay   |cff87ffffseconds|r |cff757575 Delay until a D-pad input is repeated while held down.|r<br/>
		• UIdisableHoldRepeat   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Disables D-pad input repeater.|r<br/>
		• UIdropDownFix   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Fixes cursor interaction with dropdown menus.|r
		<br/><br/>

		• unitHotkeySize   |cff87ffffpixels|r |cff757575 Changes the size of unit hotkey icons.|r<br/>
		• unitHotkeyOffsetX   |cff87ffffpixels|r |cff757575 Changes the x-axis offset of unit hotkey icons.|r<br/>
		• unitHotkeyOffsetY   |cff87ffffpixels|r |cff757575 Changes the y-axis offset of unit hotkey icons.|r<br/>
		• unitHotkeyAnchor  |cffffff78(anchor string)|r |cff757575 Changes the anchor point of unit hotkey icons.|r<br/>
		• unitHotkeyGhostMode   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Toggles ghost icons to remain on unit frames.|r<br/>
		• unitHotkeyIgnorePlayer   |cffff269btrue|r/|cffff269bfalse|r |cff757575 Toggles unit hotkeys to always ignore the player.|r<br/>
		• unitHotkeyPool   |cffffff78(string match criteria)|r |cff757575 Units to match for, separated by a semi-colon. |r<br/>
		• unitHotkeySet   |cffffff78left|r/|cffffff78right|r/|cffffff78nil|r |cff757575 Forces the button set to use for unit hotkey input.|r<br/>
	</p>
</BODY></HTML>]])




Help:AddPage('Tutorial', 'Gameplay', [[<HTML><BODY>
	<H1 align="center">
		Interactive tutorial
	</H1><br/>
	<H2 align="left">
		New player experience
	</H2>
	<IMG src="Interface\TUTORIALFRAME\UI-TutorialFrame-QuestComplete" align="right" width="200" height="200"/>
	<p align="left">
		If you are below level 10, you can enable the |cFFFF6600new player experience|r,<br/>
		which is an interactive tutorial that guides you through the basics<br/>
		of controller gameplay as you're questing through your starting area.
		<br/><br/>
		This tutorial walks you through interaction with questgivers,<br/>
		how to loot your dead enemies, and basic controls that you simply<br/>
		need to know to play the game properly.
		<br/><br/><br/>
	</p>
	<H2 align="left">
		Show, don't tell
	</H2>
	<p align="left">
		You can find most of the information available in the tutorial<br/>
		in these help pages, but it's much easier to just follow this guide,<br/>
		rooted in what you're currently doing on your current quest.
		<br/><br/><br/>
	</p>
	<H2 align="left">
		Learn controller gameplay on a fresh character
	</H2>
	<p align="left">
		If you're using ConsolePort for the first time, you should start out on a completely new or existing low level character.
		Playing the game with a controller is essentially like playing a completely new game, both in how it feels and how it handles.
		<br/><br/>
		Apart from the time it takes for your muscle memory to form, fully understanding the system along with all its quirks and benefits, will help you excel down the road.
		<br/><br/>
		The most efficient way to learn is incrementally. Starting out a new character makes sure that your spell loadout is slim,
		your adversaries are easy and you can take your time to get acquainted with the system.
		<br/><br/>
	</p>
	<H2 align="center">
		<a href="run:InterfaceOptionsDisplayPanelResetTutorials:Click() ConsolePortOldConfig:Hide()">Click here to enable the tutorial.</a>
	</H2>
</BODY></HTML>]])




Help:AddPage('Vital bindings', 'Gameplay', [[<HTML><BODY>
	<H1 align="center">
		Vital bindings
	</H1><br/>
	<H2 align="left">
		Toggle Game Menu
	</H2>
	<p align="left">
		This binding has a confusing name for the vast amount of actions it performs in different scenarios. This binding is usually bound to
		Escape on a regular keyboard, and while it can be used to toggle the game menu, it's also your main cancellation binding.
		It stops your current spell cast, clears your target, stops interaction with NPCs/loot and closes interface panels.<br/>
		It ultimately opens the game menu, which is your hub to accessing everything in game.
	</p><br/>
	<H2 align="left">
		Utility Ring
	</H2>
	<p align="left">
		The utility ring is an 8-slot radial action bar that can host almost any item, spell or mount in the game.
		While useful for storing items like Hearthstones and other trinkets or gimmicks, it also automatically maps your current
		quest items to empty slots on the ring. Particularly in later expansions, the extra action button is frequently used in world content.
		The extra action button will also, if there's available space, be mapped to the utility ring while it can be used.
		When leveling up, it's difficult to live without this extra action bar.
	</p><br/>
	<H2 align="left">
		Zoom In (Hold) and Zoom Out (Hold)
	</H2>
	<p align="left">
		Since you generally won't have a mouse wheel to control your camera zoom when using your controller, ConsolePort provides custom
		camera bindings that can either be held down or tapped to adjust the current camera zoom. If you're not using DynamicCam to automate your
		camera, these bindings are highly recommended over the regular zoom bindings.
	</p><br/>
	<H2 align="left">
		Toggle Autorun
	</H2>
	<p align="left">
		When covering distances in the game, this binding is essential. It provides ergonomical relief and keeps your controller sticks from wearing out.
	</p><br/>
	<H2 align="left">
		Open All Bags
	</H2>
	<p align="left">
		While the inventory can be accessed from the game menu, having a binding to open all your bags at once comes in handy both in the world and when you're
		interacting with vendors.
	</p><br/>
	<H2 align="left">
		Toggle World Map
	</H2>
	<p align="left">
		The world map is your hub for all your quests and zone information.
	</p><br/>
</BODY></HTML>]])