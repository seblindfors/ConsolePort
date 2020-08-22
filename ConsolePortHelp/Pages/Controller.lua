local _, Help = ...

Help:AddPage('Controller', nil, [[<HTML><BODY>
	<H1 align="center">
		Controller and Calibration
	</H1>
	<IMG src="Interface\Common\spacer" align="center" width="200" height="27"/>
	<p align="left">
		IMPORTANT: ConsolePort requires third-party software for keyboard and mouse emulation.<br/>
		Using third-party software is not prohibited as long as it doesn't automate your gameplay.
		<br/><br/>
		Calibration data is used to convert your controller's input into in-game bindings.<br/>
		|cFFFF6600If your controller does not work properly|r (buttons are incorrectly mapped, perform unexpected actions, etc.) then you'll need to recalibrate your controller.
		<br/><br/>
	</p>
	<H2 align="center">
		<a href="slash:/consoleport recalibrate">Click here to recalibrate your controller.</a>
	</H2><br/>
	<p align="left">
		<a href="page:WoWmapper">|cff69ccf0WoWmapper|r</a> is recommended for any type of Xbox controller and DualShock 4 controllers on Windows.
		The controller layout you choose to use in-game is merely a graphical preference.
	</p>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\CtrlSplash" align="center" width="768" height="384"/>
	<H2 align="center">
		<a href="slash:/consoleport type">Click here to choose controller layout.</a>
	</H2> 
</BODY></HTML>]])




Help:AddPage('Changing modifiers', 'Controller', [[<HTML><BODY>
	<H1 align="center">
		Changing modifiers
	</H1><br/>
	<p align="left">
		In order to change your modifiers, you'll need to swap them both in-game and in your input mapper. The in-game configuration is purely graphical, and has no effect on your bindings.
		<br/><br/>
		If you're using <a href="page:WoWmapper">|cff69ccf0WoWmapper|r</a>, enabling ConsolePort sync will export any changes in your WoWmapper profile automatically and prompt an interface reload to apply the new settings. Sync is recommended to ensure any changes you make match your in-game settings.
	</p><br/>
	<H1 align="center">
		Recommended settings
	</H1><br/>
	<H2 align="center">
		Best ergonomics and speed:
	</H2>
	<p align="center">
		Shift - |TInterface\AddOns\ConsolePort\Controllers\XBOX\Icons64\CP_TL1:24:24:0:-4|t   |TInterface\AddOns\ConsolePort\Controllers\XBOX\Icons64\CP_TL2:24:24:0:-4|t - Ctrl<br/>
		Shift - |TInterface\AddOns\ConsolePort\Controllers\PS4\Icons64\CP_TL1:24:24:0:-6|t   |TInterface\AddOns\ConsolePort\Controllers\PS4\Icons64\CP_TL2:24:24:0:-6|t - Ctrl
		<br/><br/>
	</p>
	<p align="left">
		Explanation: Keeping your modifiers on the left hand side makes it easier to combine multiple buttons on the shoulder and therefore results in slightly more agile gameplay.
		This also frees up the entire right hand side of your controller to individual bindings, instead of having to use multiple fingers on one hand to achieve the same result.
		In general, it's faster to do one thing with each hand than doing two things at once with one hand. 
	</p><br/>
	<H2 align="center">
		FFXIV style:
	</H2>
	<p align="center">
		Shift - |TInterface\AddOns\ConsolePort\Controllers\XBOX\Icons64\CP_TL2:24:24:0:-4|t   |TInterface\AddOns\ConsolePort\Controllers\XBOX\Icons64\CP_TR2:24:24:0:-4|t - Ctrl<br/>
		Shift - |TInterface\AddOns\ConsolePort\Controllers\PS4\Icons64\CP_TL2:24:24:0:-6|t   |TInterface\AddOns\ConsolePort\Controllers\PS4\Icons64\CP_TR2:24:24:0:-6|t - Ctrl
		<br/><br/>
	</p>
	<p align="left">
		Explanation: If you're coming from a background of playing FFXIV with a controller, you probably feel more at home using a split modifier setup.
		This setup is also more intuitive to beginners, but nonetheless contributes to somewhat slower gameplay. 
		If you're only using ConsolePort for casual endeavours, this might be a better choice for you.
	</p><br/>
	<H2 align="center">
		<a href="run:ConsolePortOldConfig:OpenCategory('Controls') ConsolePortOldConfigContainerControlsController:Click()">Click here to change your in-game modifiers.</a>
	</H2>
</BODY></HTML>]])




Help:AddPage('Custom profiles', 'Controller', [[<HTML><BODY>
	<H1 align="center">
		Creating custom profiles
	</H1><br/>
	<p align="left">
		• |cff69ccf0Shift|r and |cff69ccf0Ctrl|r need to be mapped to any of the buttons on the shoulder of the controller. You may choose which two of the four (six) buttons to use.
		<br/><br/>
		• Assign your sticks to |cff69ccf0WASD|r and mouse control. Assign the click action of each stick to the corresponding mouse button.
		<br/><br/>
		• Use regular keys for the rest of the buttons. It doesn’t matter which buttons you use, but it’s recommended to avoid |cff69ccf0Enter|r, |cff69ccf0Tab|r, |cff69ccf0Escape|r and keys that can conflict with the game client or your operating system in combination with |cff69ccf0Shift|r and |cff69ccf0Ctrl|r. The bindings these buttons represent on a normal keyboard and mouse setup can be bound via this config later on.
		<br/><br/>
		• Choosing buttons for your profile doesn’t affect your regular key bindings. The controller map is only used for calibration purposes and you may then configure your controller bindings separately in-game.
	</p>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\CustomMap" align="center" width="768" height="384"/>
</BODY></HTML>]])




Help:AddPage('Steam controller', 'Controller', [[<HTML><BODY>
	<H1 align="center">
		Steam controller setup
	</H1><br/>
	<p align="left">
		1. <a href="website:https://cdn.discordapp.com/attachments/221698189567197184/379927518603378709/ConsolePort_Official.vdf">|cff69ccf0Download the Steam controller profile for ConsolePort.|r</a>
	</p>
	<p align="left">
		2. Place the downloaded file in |cffffccf0[steam folder]/controller_base/template|r.<br/>
		3. Start Steam and open big picture mode.<br/>
		4. Go to Settings, Controller, Base Configurations, Desktop Configuration.<br/>
		5. Click on Browse Configs and then go to Templates.<br/>
		6. Import |cffffccf0ConsolePort Official|r from the list.<br/>
		7. Go back to Settings, Features, Steam Overlay.<br/>
		8. Disable Steam overlay to avoid conflicting key bindings.<br/>
		9. Exit big picture mode and start WoW using the regular launcher.<br/><br/>
		Note: You can also add WoW64.exe (or WoW.exe on 32-bit operating systems) as a non-steam game and use the profile specifically for WoW. 
		However, this requires you to start WoW separately from your Battle.net launcher and log in to the game manually every time you use your controller. 
	</p><br/>
	<IMG src="Interface\AddOns\ConsolePortHelp\Textures\Steam" align="center" width="686" height="343"/>
</BODY></HTML>]])




if IsMacClient() then -- Show options on Mac clients
Help:AddPage('Mac OS options', 'Controller', [[<HTML><BODY>
	<H1 align="center">
		Mac OS options
	</H1><br/>
	<p align="left">
		Unfortunately, there are currently no tailored solutions to map your controller on macOS, but there is software to achieve similar results.
		By following the instructions on <a href="page:Custom profiles">|cff69ccf0how to create custom profiles|r</a>, you can still use ConsolePort on your system.
		<br/><br/>
		Note that installing and setting up an input mapper on macOS can be a rather technical endeavour. Using Boot Camp to install Windows on your computer might be the best option if you want full compatibility.
	</p><br/>
	<H2 align="left">
		Steam controller:
	</H2>
	<p align="left">
		1. Follow the instructions on the <a href="page:Steam controller">|cff69ccf0Steam controller instructions page|r</a>.<br/>
		2. Change the modifier bindings in the profile to generic keys, since the modifiers in the Steam client do not work in WoW on macOS.<br/>
		3. Use Karabiner or Karabiner-Elements to remap the generic keys on your Steam controller to output Shift and Ctrl respectively.
	</p><br/>
	<H2 align="left">
		Other controllers:
	</H2>
	<p align="left">
		For any other controller, it's recommended to use either Joystick Mapper or ControllerMate.
		<br/><br/>
		Joystick Mapper is free and provides a rudimentary interface to remap your controller. It's the most convenient choice to use if it supports your controller.
		<br/><br/>
		ControllerMate is a verbose piece of software that allows you to program your controller by linking together logic structures and keyboard bindings.
		If you're looking for a powerful solution that can be tailored to your own needs, ControllerMate is your best option.
		<br/><br/>
		Even though ControllerMate is very flexible, it's also technically challenging to set up. Since it's also not free, it's not recommended to use this solution unless you have the technical skill to do so.
	</p>
</BODY></HTML>]])
end




-- WoWmapper description page
Help:AddPage('WoWmapper', 'Controller', [[<HTML><BODY>
	<IMG src="Interface\AddOns\ConsolePort\Textures\Logos\WM" align="center" width="128" height="128"/>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/>
	<H1 align="center">
		What is WoWmapper?
	</H1><br/>
	<p align="left">
		WoWmapper is an input mapper for ConsolePort, aimed at bringing true controller functionality to World of Warcraft.
		Its primary purpose is to handle DualShock 4 or Xbox/Xinput controller input and convert it into button presses and mouse movements which are then sent to WoW and processed by ConsolePort.
	</p>
	<br/>
	<H1 align="center">
		What do I need?
	</H1><br/>
	<p align="left">
		|cff69ccf0•|r A system running Windows 7, 8, 10 or higher<br/>
		|cff69ccf0•|r DirectX 9 or DirectX 10<br/>
		|cff69ccf0•|r Microsoft .NET Framework 4.5.2<br/>
		|cff69ccf0•|r A DualShock 4 or Xbox/Xinput compatible controller<br/>
		|cff69ccf0•|r World of Warcraft retail edition (WoWmapper does not support unofficial clients)
	</p><br/>
	<H3 align="left">
		Before you download WoWmapper, please ensure that you have updated DirectX to the latest version available for your system, and that you meet the other requirements for running the application.
	</H3><br/>
	<H2 align="center">
		<a href="website:https://github.com/topher-au/WoWmapper/releases/latest">Click here to get a link to the latest release of WoWmapper.</a>
	</H2> 
</BODY></HTML>]])




Help:AddPage('Supported devices', 'WoWmapper', [[<HTML><BODY>
	<IMG src="Interface\AddOns\ConsolePort\Textures\Logos\WM" align="center" width="128" height="128"/>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/>
	<H1 align="center">
		Supported devices
	</H1><br/>
	<p align="left">
		WoWmapper supports a range of different devices, although some will require an extra layer of abstraction to be recognized. For this purpose, another software called X360CE can be used in conjunction with WoWmapper to mimic an Xbox 360 device, so you'll still be able to enjoy WoWmapper's easy configuration and rich extra features.
	</p><br/>
	<H2 align="left">
		Natively supported:
	</H2>
	<p align="left">
		|cff69ccf0•|r DualShock 4 Pro |TInterface\AddOns\ConsolePortHelp\Textures\Bluetooth:16:16:0:0|t<br/>
		|cff69ccf0•|r DualShock 4 Standard |TInterface\AddOns\ConsolePortHelp\Textures\Bluetooth:16:16:0:0|t<br/>
		|cff69ccf0•|r Xbox One Controller |TInterface\AddOns\ConsolePortHelp\Textures\Bluetooth:16:16:0:0|t<br/>
		|cff69ccf0•|r Xbox One Elite Controller |TInterface\AddOns\ConsolePortHelp\Textures\Bluetooth:16:16:0:0|t<br/>
		|cff69ccf0•|r Xbox 360 Wireless Controller |TInterface\AddOns\ConsolePortHelp\Textures\Bluetooth:16:16:0:0|t<br/>
		|cff69ccf0•|r Xbox 360 Wired Controller<br/>
	</p><br/>
	<H2 align="left">
		Confirmed working with X360CE:
	</H2>
	<p align="left">
		|cff69ccf0•|r DualShock 3<br/>
		|cff69ccf0•|r Logitech RumblePad 2<br/>
		|cff69ccf0•|r Logitech Dual Action<br/>
		|cff69ccf0•|r Generic DirectInput USB Controllers<br/>
		|cff69ccf0•|r Aftermarket Xbox controllers (Afterglow, Razer Wildcat, etc.)
	</p><br/><br/>
	<H2 align="center">
		<a href="website:https://github.com/seblindfors/ConsolePort/wiki">Click here to get a link to the support article on how to setup X360CE with WoWmapper.</a>
	</H2> 
</BODY></HTML>]])