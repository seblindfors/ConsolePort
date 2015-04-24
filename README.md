# ConsolePort
<h2>Game Controller Addon for World of Warcraft</h2>
<h6>DualShock 4, DualShock 3, Xbox 360, Xbox One, Logitech Rumblepad, Razer Sabertooth</h6>
<a href="http://imgur.com/a/MdfK3" target="_blank">Screenshots</a><br>
<a href="https://youtu.be/lreNDsA1HP4" target="_blank">Video (NEW! Setup wizard)</a>    
<a href="http://youtu.be/PZgP5wq5Jag" target="_blank">Video (Basic in-game setup)</a>   
<a href="http://youtu.be/6EDvD2HfYJI" target="_blank">Video (Proving Grounds Gold)</a>

ConsolePort is a lightweight interface add-on for World of Warcraft that will give you a handful of nifty features
in order to let you play the game on a controller - without inconvenience. There are a lot of tutorials and videos on
how to set up your controller for World of Warcraft, but the most game-breaking part about all of them is how they in no way
contribute to an easy game experience. It's a hassle just to sell a few items or turn in a quest. This addon will change all that.

The main goal here is to turn an experience that was designed for mouse and keyboard into one that is equally fitting for
a game controller, without losing gameplay quality in return. Using the addon, you should be able to effortlessly
do the same tasks with a controller as you would with a mouse and keyboard. On top of this, it will NOT interfere with your
normal keyboard and mouse setup, leaving you to choose which way you want to play the game without having to rebind and
reconfigure every time you change peripherals.

<h2>1. Controller support</h2>

  ConsolePort is not restricted to any one controller, however, it is somewhat restricted to conventional controller layouts.
It requires a set of 14-15 buttons, which is what you'll find on any version of the PlayStation, Xbox or Logitech controllers.
If you have a DS4 controller, the files provided in this git will save you the pain of mapping keys or setting up confusing third-party software. Download DS4Windows from http://ds4windows.com and simply drop the files into the same directory. Run DS4Windows.exe, connect your controller and jump into the game.


<h2>2. Basic setup</h2>
<h4>2.1. Mapping keys to the controller</h4>
  The addon is designed with a few restrictions in mind; you will need to map both mouse buttons and you will need to assign
  two buttons to modifiers. These modfiers have to be Shift and Ctrl. You also have to assign one of the sticks to your
  WASD or arrow keys and the other stick to move your mouse. If you're not sure how to do this, download DS4Windows
  (even if you don't have a DS4 controller) and load the example profile provided in this git. My personal preference is:
  - L1: Shift
  - L2: Ctrl
  - L3 (Left stick button): Left mouse button
  - LS (Left stick): WASD/arrows
  - R3 (Right stick button): Right mouse button (if possible, macro it to fire twice)
  - RS (Right stick): Mouse
 
Apart from this, you are free to map the buttons however you want. My suggestion is using buttons that you don't already use
  in game. Personally, I don't use the functional buttons, which is why I have F1-F12 mapped to the controller in the example profile.
  You will need to assign these buttons in the game, which is why it's preferable to have buttons that don't interfere with
  your standard keyboard and mouse setup.
  <h4>2.2. Mapping action buttons</h4>
  
  If you do not like the default profile or wish to map your buttons differently, open the provided <b>Bindings</b> palette
  by opening the <b>Game Menu</b> and then pressing <b>Controller</b>. Once the palette is open, you will notice a list of
  assigned action buttons and their corresponding controller buttons. If you press a key on your controller, it should light
  up in the list. To remap a button combination, simply drag your mouse cursor over the action button on your action bars and
  press the key combination you want for that button. The icon in the palette will now change to your new assignment.

  The last four buttons in the list are static and will remain unmodified by the addon at all times. This is to circumvent     the protected API restrictions and allow you to map actions such as jumping or targeting enemies. To change these bindings,   click on the corresponding button with the virtual mouse and choose the action you want from the dropdown list.<br>
  Press <b>Okay</b> when you are done. (This process will eventually be more straightforward.)
  
  <h2>3. Using the addon</h2>
  <h4>3.1. A few notes about mouse look</h4>
  Mouse look is a feature within the game where you lock your mouse cursor in order to control the camera in 3D-space.
  This state is usually triggered by holding down the right mouse button, but it can also be done programmatically.
  ConsolePort utilizes this feature to a great extent, to get rid of that mouse/keyboard feeling and keep you from having to
  hold down a button on the controller in order to control your character and camera. Having that said, this mode can be
  toggled off by pressing your assigned Right mouse button (R3). Mouse look will also trigger on a few events, such as
  casting a direct spell (e.g. Arcane Shot), changing targets, looting or closing quest and gossip windows.<br><br>
  <b>Mouse look will also be triggered by moving your mouse cursor over your own character!</b><br>
  This means you will almost always have your mouse cursor in the middle of the screen, ready to loot stuff on the ground,
  target NPCs effortlessly or pick up quest items. The mouse look feature will, however, be disabled whenever a frame is blocking
  your character, when you're using non-direct spells (e.g. Trap Launcher, Rain of Fire, Mass Dispel) or when you have
  an item, glyph, spell or macro picked up on your cursor.
  
  <h4>3.2. Using the interface</h4>
  Note: Due to Blizzard API restrictions, you cannot use the interface with the controller while in combat.
  Affected frames will fade out when you enter combat, and fade back in when you exit combat.
  You can always use the mouse mode on the controller to click and use the frames, if absolutely necessary.<br><br>
  Where guides and indicators have not yet been implemented, the general setup of the buttons are:
  - Circle - using, accepting and confirming
  - Square - pick up items, crucial options (learning talents, abandoning quests, assigning glyphs)
  - Triangle - cancel, decline, change mode (e.g. quest mode to map mode), switch tabs

A few exceptions here for security purposes: Popups are accepted by clicking "Square", since popups normally mean you have to
  make a choice. "Circle" is exclusively used for mundane tasks, whereas "Square" is used for important decisions.
The arrows on the controller are self-explanatory in most cases and are used to iterate through frames.
Triggers will be added to the setup shortly to accomodate the double tab system on a handful of frames. 

<h4>3.3. World interaction</h4>
Interacting with the game world can only be done the conventional way; by clicking with the virtual mouse setup on your
controller. All API functions for looting and clicking items on the ground are blocked and cannot be called from unsecure code. Use R3 (right stick button) to click items in 3D-space, loot mobs and interact with NPCs. If you don't have a double right mouse button click macroed to your R3 button, looting can be quite cumbersome, since you have to click the button twice. If you think this is a hassle, get the item <b>Findle's Loot-A-Rang</b>, an item which will loot all nearby corpses.

<h2>4. Suggested driver software</h2>
- Mac OSX
  - <a href="http://www.orderedbytes.com/controllermate/">ControllerMate</a> (highly recommended for Mac users) 
  - <a href="http://joystickmapper.com/">Joystick Mapper</a>
- Windows 7/8/8.1
  - <a href="http://keysticks.net">Keysticks</a> (Xbox)
  - <a href="http://ds4windows.com">DS4Windows</a> (DualShock 4)
  - <a href="http://xpadder.com">Xpadder</a> (all game pads)

Warning: I strongly recommend you do not use MotioninJoy!

<h2>5. Known issues</h2>
- Using menu to click microbuttons will cause taint.
- Map iteration skips certain zones, Stormwind is one of them.
- Map iteration doesn't work while flying over the Twisting Nether.
- Map highlighting does not work for the planet map (arrow buttons are used to enter the planets directly).
- The Maelstrom zone and subzones are not targetable with arrow buttons. Maelstrom will open the Pandaria map.
- Entering combat while the glyph frame is open will lock out the Up and Down buttons on the controller.
- Unless overridden, old button combinations will appear on action buttons until the UI is reloaded.
- Downwards glyph list iteration will sometimes stop working when the scrollbar reaches the bottom.
