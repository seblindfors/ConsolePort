---------------------------------------------------------------
-- Assets
---------------------------------------------------------------
function CPAPI.GetAsset(path)
	return ([[Interface\AddOns\ConsolePort\Assets\%s]]):format(path)
end

function CPAPI.GetClassIcon(class)
	-- returns concatenated icons file with slicing coords
	return [[Interface\TargetingFrame\UI-Classes-Circles]], CLASS_ICON_TCOORDS[class or CPAPI.GetClassFile()]
end

function CPAPI.GetWebClassIcon(class)
	return CPAPI.GetAsset([[Art\Class\Web_Class_Icons_Grid]]), CLASS_ICON_TCOORDS[class or CPAPI.GetClassFile()]
end

---------------------------------------------------------------
-- Asset atlas
---------------------------------------------------------------
CPAPI.Atlas = {
	[CPAPI.GetAsset([[Textures\Atlas\General_Atlas]])] = {
		['ring-alliance'] = {278, 280, 0.00048828125, 0.13623046875, 0.0009765625, 0.2744140625, false, false};
		['ring-horde'] = {278, 280, 0.00048828125, 0.13623046875, 0.5517578125, 0.8251953125, false, false};
		['ring-metaldark'] = {278, 280, 0.13720703125, 0.27294921875, 0.2763671875, 0.5498046875, false, false};
		['ring-metallight'] = {278, 280, 0.27392578125, 0.40966796875, 0.0009765625, 0.2744140625, false, false};
		['ring-select'] = {236, 236, 0.27392578125, 0.38916015625, 0.5185546875, 0.7490234375, false, false};
		['ring-alliance-disabled'] = {278, 280, 0.00048828125, 0.13623046875, 0.2763671875, 0.5498046875, false, false};
		['ring-metaldark-disabled'] = {278, 280, 0.13720703125, 0.27294921875, 0.5517578125, 0.8251953125, false, false};
		['ring-horde-disabled'] = {278, 280, 0.13720703125, 0.27294921875, 0.0009765625, 0.2744140625, false, false};
		['tooltip-background'] = {1, 1, 0.044921875, 0.04541015625, 0.9833984375, 0.984375, false, false};
		['tooltip-corner'] = {68, 68, 0.07763671875, 0.11083984375, 0.8271484375, 0.8935546875, false, false};
		['tooltip-side'] = {1, 68, 0.21435546875, 0.21484375, 0.9228515625, 0.9892578125, false, false};
		['tooltip-top'] = {1, 68, 0.2158203125, 0.21630859375, 0.9228515625, 0.9892578125, false, false};
		['customize-dropdownbox'] = {300, 76, 0.60400390625, 0.75048828125, 0.0009765625, 0.0751953125, false, false};
		['customize-palette'] = {84, 20, 0.21435546875, 0.25537109375, 0.8271484375, 0.8466796875, false, false};
		['customize-dropdown-linemouseover-middle'] = {1, 40, 0.13525390625, 0.1357421875, 0.8955078125, 0.9345703125, false, false};
		['customize-dropdown-linemouseover-side'] = {12, 40, 0.12841796875, 0.13427734375, 0.8955078125, 0.9345703125, false, false};
		['customize-dropdownbox-hover'] = {300, 76, 0.75146484375, 0.89794921875, 0.0009765625, 0.0751953125, false, false};
		['customize-dropdownbox-open'] = {300, 76, 0.60400390625, 0.75048828125, 0.0771484375, 0.1513671875, false, false};
		['customize-palette-selected'] = {102, 40, 0.07763671875, 0.12744140625, 0.8955078125, 0.9345703125, false, false};
		['customize-palette-glow'] = {84, 20, 0.21435546875, 0.25537109375, 0.8486328125, 0.8681640625, false, false};
		['customize-palette-half'] = {84, 20, 0.21435546875, 0.25537109375, 0.8701171875, 0.8896484375, false, false};
		['reset-button'] = {34, 34, 0.9375, 0.9541015625, 0.94140625, 0.974609375, false, false};
	};
	[CPAPI.GetAsset([[Textures\Atlas\Popup_Atlas.png]])] = {
		['perks-list-active'] = {520, 48, 0.000976562, 0.508789, 0, 50/256, false, false };
		['perks-list-hover'] = {520, 48, 0.000976562, 0.508789, 51/256, 100/256, false, false };
		['perks-list-borderlines'] = {516, 48, 0.000976562, 0.504883, 101/256, 150/256, false, false };
		['perks-divider'] = { 484, 3, 0, 484/1024, 151/256, 154/256, false, false };
	};
	[CPAPI.GetAsset([[Textures\Atlas\ObjectIcons_Atlas.png]])] = {
		['AllianceSymbol'] = { 32, 32, 0.129883, 0.161133, 0.889648, 0.920898, false, false };
		['Auctioneer'] = { 32, 32, 0.2431640625, 0.2744140625, 0.3642578125, 0.3955078125, false, false };
		['Banker'] = { 32, 32, 0.2431640625, 0.2744140625, 0.4638671875, 0.4951171875, false, false };
		['Barbershop-32x32'] = { 24, 24, 0.2431640625, 0.2744140625, 0.4970703125, 0.5283203125, false, false };
		['dragon-rostrum'] = { 32, 32, 0.2431640625, 0.2744140625, 0.9619140625, 0.9931640625, false, false };
		['Dungeon'] = { 22, 22, 0.508789, 0.530273, 0.104492, 0.125977, false, false };
		['Focus'] = { 32, 32, 0.575195, 0.606445, 0.264648, 0.295898, false, false };
		['GreenCross'] = { 32, 32, 0.8076171875, 0.8388671875, 0.2646484375, 0.2958984375, false, false };
		['HordeSymbol'] = { 32, 32, 0.84082, 0.87207, 0.264648, 0.295898, false, false };
		['Islands-MarkedArea'] = { 32, 32, 0.2763671875, 0.3076171875, 0.2978515625, 0.3291015625, false, false };
		['MagePortalAlliance'] = { 32, 32, 0.276367, 0.307617, 0.49707, 0.52832, false, false };
		['MagePortalHorde'] = { 32, 32, 0.276367, 0.307617, 0.530273, 0.561523, false, false };
		['Mailbox'] = { 32, 32, 0.276367, 0.307617, 0.563477, 0.594727, false, false };
		['MiniMap-QuestArrow'] = { 32, 32, 0.2763671875, 0.3076171875, 0.8623046875, 0.8935546875, false, false };
		['None'] = { 32, 32, 0.508789, 0.540039, 0.297852, 0.329102, false, false };
		['Ping_Map_Whole_Attack'] = { 32, 32, 0.6748046875, 0.7060546875, 0.2978515625, 0.3291015625, false, false };
		['Ping_Map_Whole_NonThreat'] = { 32, 32, 0.708008, 0.739258, 0.297852, 0.329102, false, false };
		['Ping_Map_Whole_OnMyWay'] = { 32, 32, 0.741211, 0.772461, 0.297852, 0.329102, false, false };
		['Ping_Map_Whole_Threat'] = { 32, 32, 0.774414, 0.805664, 0.297852, 0.329102, false, false };
		['Ping_Map_Whole_Warning'] = { 32, 32, 0.807617, 0.838867, 0.297852, 0.329102, false, false };
		['poi-door-down'] = { 25, 24, 0.642578, 0.666992, 0.165039, 0.188477, false, false };
		['poi-transmogrifier'] = { 29, 36, 0.6611328125, 0.689453125, 0.0810546875, 0.1162109375, false, false };
		['poi-traveldirections-arrow2'] = { 36, 44, 0.5234375, 0.55859375, 0.1279296875, 0.1708984375, false, false };
		['Raid'] = { 22, 22, 0.532227, 0.553711, 0.104492, 0.125977, false, false };
		['TaxiNode_Neutral'] = { 18, 18, 0.342773, 0.360352, 0.170898, 0.188477, false, false };
		['TorghastDoor-ArrowDown-32x32'] = { 24, 24, 0.7744140625, 0.8056640625, 0.3642578125, 0.3955078125, false, false };
		['UpgradeItem-32x32'] = { 24, 24, 0.9404296875, 0.9716796875, 0.3642578125, 0.3955078125, false, false };
		['VignetteEventElite'] = { 32, 32, 0.641602, 0.672852, 0.397461, 0.428711, false, false };
		['Warfronts-BaseMapIcons-Alliance-Workshop-Minimap-small'] = { 37, 35, 0.1669921875, 0.203125, 0.2646484375, 0.298828125, false, false };
		['Warfronts-BaseMapIcons-Alliance-Workshop-Minimap'] = { 37, 35, 0.1669921875, 0.203125, 0.228515625, 0.2626953125, false, false };
		['Waypoint-MapPin-Minimap-Tracked'] = { 32, 32, 0.5419921875, 0.5732421875, 0.4306640625, 0.4619140625, false, false };
		['Waypoint-MapPin-Minimap-Untracked'] = { 32, 32, 0.5751953125, 0.6064453125, 0.4306640625, 0.4619140625, false, false };
		['WildBattlePet'] = { 32, 32, 0.608398, 0.639648, 0.430664, 0.461914, false, false };
		['XMarksTheSpot'] = { 32, 32, 0.7080078125, 0.7392578125, 0.4306640625, 0.4619140625, false, false };
	};
	[CPAPI.GetAsset([[Textures\Atlas\UIActionBar2x]])] = {
		['_UI-HUD-ActionBar-Frame-Divider-Threeslice-Center'] = { 32, 28, 0, 0.0625, 0.08740234375, 0.10107421875, true, false };
		['_UI-HUD-ActionBar-Frame-NineSlice-EdgeBottom'] = { 32, 46, 0, 0.0625, 0.04736328125, 0.06982421875, true, false };
		['_UI-HUD-ActionBar-Frame-NineSlice-EdgeTop'] = { 32, 32, 0, 0.0625, 0.07080078125, 0.08642578125, true, false };
		['UI-HUD-ActionBar-Flyout'] = { 36, 14, 0.884765625, 0.955078125, 0.43896484375, 0.44580078125, false, false };
		['UI-HUD-ActionBar-Flyout-Down'] = { 38, 16, 0.884765625, 0.958984375, 0.43017578125, 0.43798828125, false, false };
		['UI-HUD-ActionBar-Flyout-Mouseover'] = { 36, 14, 0.884765625, 0.955078125, 0.44677734375, 0.45361328125, false, false };
		['UI-HUD-ActionBar-Frame-Divider-ThreeSlice-EdgeBottom'] = { 24, 30, 0.771484375, 0.818359375, 0.40673828125, 0.42138671875, false, false };
		['UI-HUD-ActionBar-Frame-Divider-Threeslice-EdgeLeft'] = { 24, 28, 0.884765625, 0.931640625, 0.40869140625, 0.42236328125, false, false };
		['UI-HUD-ActionBar-Frame-Divider-Threeslice-EdgeRight'] = { 24, 28, 0.935546875, 0.982421875, 0.40869140625, 0.42236328125, false, false };
		['UI-HUD-ActionBar-Frame-Divider-ThreeSlice-EdgeTop'] = { 24, 28, 0.822265625, 0.869140625, 0.40673828125, 0.42041015625, false, false };
		['UI-HUD-ActionBar-Frame-NineSlice-CornerBottomLeft'] = { 34, 46, 0.908203125, 0.974609375, 0.18701171875, 0.20947265625, false, false };
		['UI-HUD-ActionBar-Frame-NineSlice-CornerBottomRight'] = { 44, 46, 0.908203125, 0.994140625, 0.16357421875, 0.18603515625, false, false };
		['UI-HUD-ActionBar-Frame-NineSlice-CornerTopLeft'] = { 34, 32, 0.904296875, 0.970703125, 0.23193359375, 0.24755859375, false, false };
		['UI-HUD-ActionBar-Frame-NineSlice-CornerTopRight'] = { 44, 32, 0.904296875, 0.990234375, 0.21533203125, 0.23095703125, false, false };
		['UI-HUD-ActionBar-Gryphon-Left'] = { 200, 188, 0.001953125, 0.697265625, 0.10205078125, 0.26513671875, false, false };
		['UI-HUD-ActionBar-Gryphon-Right'] = { 200, 188, 0.001953125, 0.697265625, 0.26611328125, 0.42919921875, false, false };
		['UI-HUD-ActionBar-IconFrame'] = { 92, 90, 0.701171875, 0.880859375, 0.31689453125, 0.36083984375, false, false };
		['UI-HUD-ActionBar-IconFrame-AddRow'] = { 102, 102, 0.701171875, 0.900390625, 0.21533203125, 0.26513671875, false, false };
		['UI-HUD-ActionBar-IconFrame-AddRow-Down'] = { 102, 102, 0.701171875, 0.900390625, 0.26611328125, 0.31591796875, false, false };
		['UI-HUD-ActionBar-IconFrame-Border'] = { 92, 90, 0.701171875, 0.880859375, 0.36181640625, 0.40576171875, false, false };
		['UI-HUD-ActionBar-IconFrame-Down'] = { 92, 90, 0.701171875, 0.880859375, 0.43017578125, 0.47412109375, false, false };
		['UI-HUD-ActionBar-IconFrame-Flash'] = { 92, 90, 0.701171875, 0.880859375, 0.47509765625, 0.51904296875, false, false };
		['UI-HUD-ActionBar-IconFrame-FlyoutBorderShadow'] = { 104, 104, 0.701171875, 0.904296875, 0.16357421875, 0.21435546875, false, false };
		['UI-HUD-ActionBar-IconFrame-FlyoutBottom'] = { 94, 10, 0.701171875, 0.884765625, 0.59423828125, 0.59912109375, false, false };
		['UI-HUD-ActionBar-IconFrame-FlyoutBottomLeft'] = { 10, 94, 0.955078125, 0.974609375, 0.10205078125, 0.14794921875, false, false };
		['UI-HUD-ActionBar-IconFrame-FlyoutButton'] = { 94, 58, 0.701171875, 0.884765625, 0.56494140625, 0.59326171875, false, false };
		['UI-HUD-ActionBar-IconFrame-FlyoutButtonLeft'] = { 58, 94, 0.884765625, 0.998046875, 0.36181640625, 0.40771484375, false, false };
		['UI-HUD-ActionBar-IconFrame-Mouseover'] = { 92, 90, 0.701171875, 0.880859375, 0.52001953125, 0.56396484375, false, false };
		['UI-HUD-ActionBar-IconFrame-Slot'] = { 128, 124, 0.701171875, 0.951171875, 0.10205078125, 0.16259765625, false, false };
		['UI-HUD-ActionBar-PageDownArrow-Disabled'] = { 34, 28, 0.904296875, 0.970703125, 0.24853515625, 0.26220703125, false, false };
		['UI-HUD-ActionBar-PageDownArrow-Down'] = { 34, 28, 0.904296875, 0.970703125, 0.26611328125, 0.27978515625, false, false };
		['UI-HUD-ActionBar-PageDownArrow-Mouseover'] = { 34, 28, 0.904296875, 0.970703125, 0.28076171875, 0.29443359375, false, false };
		['UI-HUD-ActionBar-PageDownArrow-Up'] = { 34, 28, 0.904296875, 0.970703125, 0.29541015625, 0.30908203125, false, false };
		['UI-HUD-ActionBar-PageUpArrow-Disabled'] = { 34, 28, 0.884765625, 0.951171875, 0.31689453125, 0.33056640625, false, false };
		['UI-HUD-ActionBar-PageUpArrow-Down'] = { 34, 28, 0.884765625, 0.951171875, 0.33154296875, 0.34521484375, false, false };
		['UI-HUD-ActionBar-PageUpArrow-Mouseover'] = { 34, 28, 0.884765625, 0.951171875, 0.34619140625, 0.35986328125, false, false };
		['UI-HUD-ActionBar-PageUpArrow-Up'] = { 34, 28, 0.701171875, 0.767578125, 0.40673828125, 0.42041015625, false, false };
		['UI-HUD-ActionBar-Wyvern-Left'] = { 200, 188, 0.001953125, 0.697265625, 0.43017578125, 0.59326171875, false, false };
		['UI-HUD-ActionBar-Wyvern-Right'] = { 200, 188, 0.001953125, 0.697265625, 0.59423828125, 0.75732421875, false, false };
	};
	[CPAPI.GetAsset([[Textures\Atlas\UICharacterSelectGlues2x]])]={
		['glues-characterselect-card-camp-bg-glow']={54,54,0.24365234375,0.29638671875,0.63037109375,0.68310546875,false,false,0,34,34,32,32},
		['glues-characterselect-card-camp-bg']={40,40,0.48291015625,0.52197265625,0.59033203125,0.62939453125,false,false,0,22,22,22,22},
		['glues-characterselect-card-camp-hover']={316,95,0.00048828125,0.30908203125,0.24365234375,0.33642578125,false,false},
		['glues-characterselect-card-camp']={316,95,0.65673828125,0.96533203125,0.12353515625,0.21630859375,false,false},
		['glues-characterselect-icon-minus-disabled']={31,31,0.35400390625,0.38427734375,0.72607421875,0.75634765625,false,false},
		['glues-characterselect-icon-minus-hover']={31,31,0.35400390625,0.38427734375,0.75732421875,0.78759765625,false,false},
		['glues-characterselect-icon-minus-pressed']={31,31,0.35400390625,0.38427734375,0.78857421875,0.81884765625,false,false},
		['glues-characterselect-icon-minus']={31,31,0.35400390625,0.38427734375,0.69482421875,0.72509765625,false,false},
		['glues-characterselect-icon-plus-disabled']={31,31,0.35400390625,0.38427734375,0.85107421875,0.88134765625,false,false},
		['glues-characterselect-icon-plus-hover']={31,31,0.35400390625,0.38427734375,0.88232421875,0.91259765625,false,false},
		['glues-characterselect-icon-plus']={31,31,0.35400390625,0.38427734375,0.81982421875,0.85009765625,false,false},
		['glues-characterselect-plus-pressed']={31,31,0.35400390625,0.38427734375,0.91357421875,0.94384765625,false,false},
		['glues-characterselect-tophud-bg-divider-dis']={2,44,0.99560546875,0.99755859375,0.04443359375,0.08740234375,false,false},
		['glues-characterselect-tophud-bg-divider']={2,44,0.99560546875,0.99755859375,0.00048828125,0.04345703125,false,false},
		['glues-characterselect-tophud-bg']={330,51,0.60791015625,0.93017578125,0.43115234375,0.48095703125,false,false,0,300,300,0,0},
		['glues-characterselect-tophud-left-bg']={212,51,0.37646484375,0.58349609375,0.51904296875,0.56884765625,false,false,0,200,16,0,0},
		['glues-characterselect-tophud-left-dis-bg']={212,51,0.58447265625,0.79150390625,0.51904296875,0.56884765625,false,false,0,200,16,0,0},
		['glues-characterselect-tophud-middle-bg']={30,51,0.15380859375,0.18310546875,0.92138671875,0.97119140625,false,false},
		['glues-characterselect-tophud-middle-dis-bg']={30,51,0.24365234375,0.27294921875,0.93310546875,0.98291015625,false,false},
		['glues-characterselect-tophud-right-bg']={212,51,0.79248046875,0.99951171875,0.51904296875,0.56884765625,false,false,0,16,200,0,0},
		['glues-characterselect-tophud-right-dis-bg']={212,51,0.18603515625,0.39306640625,0.57958984375,0.62939453125,false,false,0,16,200,0,0},
		['glues-characterselect-tophud-selected-left']={181,47,0.00048828125,0.17724609375,0.73681640625,0.78271484375,false,false,0,242,16,0,0},
		['glues-characterselect-tophud-selected-line-left']={175,6,0.67431640625,0.84521484375,0.10595703125,0.11181640625,false,false},
		['glues-characterselect-tophud-selected-line-middle']={174,6,0.33544921875,0.50537109375,0.22900390625,0.23486328125,false,false},
		['glues-characterselect-tophud-selected-line-right']={175,6,0.67431640625,0.84521484375,0.11279296875,0.11865234375,false,false},
		['glues-characterselect-tophud-selected-middle']={24,47,0.29736328125,0.32080078125,0.63037109375,0.67626953125,false,false,0,16,16,0,0},
		['glues-characterselect-tophud-selected-right']={181,47,0.00048828125,0.17724609375,0.78369140625,0.82958984375,false,false,0,16,242,0,0},
		['glues-gamemode-bg']={77,77,0.07763671875,0.15283203125,0.92138671875,0.99658203125,false,false,0,22,22,18,26},
		-- TODO: Everything below this line is not used, remove or move outside code load
		['glues-characterselect-icon-arrowdown']={32,32,0.32177734375,0.35302734375,0.75927734375,0.79052734375,false,false},
		['glues-characterselect-icon-restorecharacter']={58,58,0.18603515625,0.24267578125,0.86083984375,0.91748046875,false,false},
		['glues-characterselect-icon-fx-plus']={125,125,0.00048828125,0.12255859375,0.61376953125,0.73583984375,false,false},
		['glues-characterselect-icon-faction-horde']={36,46,0.24365234375,0.27880859375,0.84130859375,0.88623046875,false,false},
		['glues-characterselect-icon-arrowdown-pressed']={32,32,0.32177734375,0.35302734375,0.82373046875,0.85498046875,false,false},
		['glues-characterselect-icon-notify-mail-hover']={40,40,0.80322265625,0.84228515625,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-icon-faction-horde-hover']={36,46,0.24365234375,0.27880859375,0.88720703125,0.93212890625,false,false},
		['glues-characterselect-icon-addcard']={78,78,0.92138671875,0.99755859375,0.33740234375,0.41357421875,false,false},
		['glues-characterselect-scrollbar']={10,20,0.97998046875,0.98974609375,0.21728515625,0.23681640625,false,false,0,0,0,20,20},
		['glues-characterselect-icon-arrowup-small']={29,29,0.38623046875,0.41455078125,0.80615234375,0.83447265625,false,false},
		['glues-characterselect-icon-notify-mail']={40,40,0.76318359375,0.80224609375,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-icon-appearancechange-hover']={58,58,0.12353515625,0.18017578125,0.67138671875,0.72802734375,false,false},
		['glues-characterselect-card-empty']={316,95,0.61962890625,0.92822265625,0.24365234375,0.33642578125,false,false},
		['glues-characterselect-icon-arrowdown-small-pressed']={29,29,0.38623046875,0.41455078125,0.77685546875,0.80517578125,false,false},
		['glues-characterselect-card-selected']={342,122,0.33935546875,0.67333984375,0.00048828125,0.11962890625,false,false},
		['glues-characterselect-card-all-bg']={60,60,0.92919921875,0.98779296875,0.24365234375,0.30224609375,false,false,0,28,28,22,34},
		['glues-characterselect-icon-notify-lock']={40,40,0.68310546875,0.72216796875,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-card-empty-hover']={316,95,0.00048828125,0.30908203125,0.33740234375,0.43017578125,false,false},
		['glues-characterselect-card-singles-hover']={310,89,0.30419921875,0.60693359375,0.43115234375,0.51806640625,false,false},
		['glues-characterselect-button-collapseexpand-disabled']={34,34,0.96337890625,0.99658203125,0.30322265625,0.33642578125,false,false,0,18,18,0,0},
		['glues-characterselect-icon-faction-alliance-selected']={43,56,0.24365234375,0.28564453125,0.68408203125,0.73876953125,false,false},
		['glues-characterselect-card-fx-spreada']={312,91,0.31005859375,0.61474609375,0.33740234375,0.42626953125,false,false},
		['glues-characterselect-icon-arrowdown-small-hover']={29,29,0.38623046875,0.41455078125,0.74755859375,0.77587890625,false,false},
		['glues-characterselect-listlauncher-bg']={370,37,0.60791015625,0.96923828125,0.48193359375,0.51806640625,false,false},
		['glues-characterselect-icon-notify-lock-hover']={40,40,0.72314453125,0.76220703125,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-button-card-up-disabled-hover']={32,32,0.32177734375,0.35302734375,0.72705078125,0.75830078125,false,false},
		['glues-characterselect-scrollbar-bg']={10,20,0.98876953125,0.99853515625,0.24365234375,0.26318359375,false,false,0,0,0,20,20},
		['glues-characterselect-button-card-pressed']={32,32,0.32177734375,0.35302734375,0.66259765625,0.69384765625,false,false},
		['glues-characterselect-icon-notify-inprogress']={40,40,0.60302734375,0.64208984375,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-searchbar']={24,24,0.93212890625,0.95556640625,0.21728515625,0.24072265625,false,false,0,8,8,0,0},
		['glues-characterselect-icon-search']={14,14,0.92138671875,0.93505859375,0.41455078125,0.42822265625,false,false},
		['glues-characterselect-icon-factionchange']={58,58,0.18603515625,0.24267578125,0.63037109375,0.68701171875,false,false},
		['glues-characterselect-icon-appearancechange']={58,58,0.12353515625,0.18017578125,0.61376953125,0.67041015625,false,false},
		['glues-characterselect-divider']={392,10,0.39404296875,0.77685546875,0.57958984375,0.58935546875,false,false},
		['glues-characterselect-scroll-arrow-up']={16,11,0.95263671875,0.96826171875,0.41455078125,0.42529296875,false,false},
		['glues-characterselect-carddivider']={324.5,2.5,0.33544921875,0.65234375,0.23583984375,0.23828125,false,false},
		['glues-characterselect-icon-notify-inprogress-hover']={40,40,0.64306640625,0.68212890625,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-button-card']={32,32,0.87744140625,0.90869140625,0.59033203125,0.62158203125,false,false},
		['glues-characterselect-listrealm-bg']={281,23,0.65673828125,0.93115234375,0.21728515625,0.23974609375,false,false},
		['glues-characterselect-icon-restorecharacter-hover']={58,58,0.18603515625,0.24267578125,0.91845703125,0.97509765625,false,false},
		['glues-characterselect-button-collapseexpand-small']={29,29,0.35400390625,0.38232421875,0.94482421875,0.97314453125,false,false},
		['glues-characterselect-button-collapseexpand-small-hover']={29,29,0.38623046875,0.41455078125,0.63037109375,0.65869140625,false,false},
		['glues-characterselect-icon-arrowup']={32,32,0.32177734375,0.35302734375,0.88818359375,0.91943359375,false,false},
		['glues-characterselect-icon-arrowdown-hover']={32,32,0.32177734375,0.35302734375,0.79150390625,0.82275390625,false,false},
		['glues-characterselect-icon-arrowdown-small']={29,29,0.38623046875,0.41455078125,0.71826171875,0.74658203125,false,false},
		['glues-characterselect-icon-arrowup-hover']={32,32,0.32177734375,0.35302734375,0.92041015625,0.95166015625,false,false},
		['glues-characterselect-icon-arrowup-small-pressed']={29,29,0.38623046875,0.41455078125,0.86474609375,0.89306640625,false,false},
		['glues-characterselect-button-card-down-disabled']={32,32,0.90966796875,0.94091796875,0.59033203125,0.62158203125,false,false},
		['glues-characterselect-button-collapseexpand-hover']={90,34,0.39404296875,0.48193359375,0.59033203125,0.62353515625,false,false,0,80,80,0,0},
		['glues-characterselect-icon-faction-horde-selected']={43,56,0.24365234375,0.28564453125,0.73974609375,0.79443359375,false,false},
		['glues-characterselect-icon-notify-bg-hover']={40,40,0.56298828125,0.60205078125,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-icon-factionchange-hover']={58,58,0.18603515625,0.24267578125,0.68798828125,0.74462890625,false,false},
		['glues-characterselect-icon-faction-alliance-hover']={36,46,0.24365234375,0.27880859375,0.79541015625,0.84033203125,false,false},
		['glues-characterselect-button-collapseexpand']={34,34,0.92919921875,0.96240234375,0.30322265625,0.33642578125,false,false,0,18,18,0,0},
		['glues-characterselect-button-card-hover']={32,32,0.32177734375,0.35302734375,0.63037109375,0.66162109375,false,false},
		['glues-characterselect-button-collapseexpand-down-small-disabled']={29,29,0.97021484375,0.99853515625,0.48193359375,0.51025390625,false,false},
		['glues-characterselect-card-drag']={316,95,0.31005859375,0.61865234375,0.24365234375,0.33642578125,false,false},
		['glues-characterselect-icon-notify-bg']={40,40,0.52294921875,0.56201171875,0.59033203125,0.62939453125,false,false},
		['glues-characterselect-icon-arrowdown-pressed-hover']={32,32,0.32177734375,0.35302734375,0.85595703125,0.88720703125,false,false},
		['glues-characterselect-icon-racechange-hover']={58,58,0.18603515625,0.24267578125,0.80322265625,0.85986328125,false,false},
		['glues-characterselect-namebg']={194,61,0.18603515625,0.37548828125,0.51904296875,0.57861328125,false,false},
		['glues-characterselect-icon-racechange']={58,58,0.18603515625,0.24267578125,0.74560546875,0.80224609375,false,false},
		['glues-characterselect-iconshop-dis']={23,23,0.16064453125,0.18310546875,0.88330078125,0.90576171875,false,false},
		['glues-characterselect-card-singles']={310,89,0.00048828125,0.30322265625,0.43115234375,0.51806640625,false,false},
		['glues-characterselect-button-card-up-disabled']={32,32,0.32177734375,0.35302734375,0.69482421875,0.72607421875,false,false},
		['glues-characterselect-icon-restorecharacter-pointer']={34,86,0.96630859375,0.99951171875,0.12353515625,0.20751953125,false,false},
		['glues-characterselect-icon-addcard-glow']={78,78,0.00048828125,0.07666015625,0.92138671875,0.99755859375,false,false},
		['glues-gamemode-selectarrow']={50,50,0.93115234375,0.97998046875,0.43115234375,0.47998046875,false,false},
		['glues-characterselect-button-collapseexpand-pressed']={34,34,0.84326171875,0.87646484375,0.59033203125,0.62353515625,false,false,0,24,24,0,0},
		['glues-characterselect-icon-arrowup-small-hover']={29,29,0.38623046875,0.41455078125,0.83544921875,0.86376953125,false,false},
		['glues-characterselect-icon-arrowdown-disabled']={32,32,0.35400390625,0.38525390625,0.66259765625,0.69384765625,false,false},
		['glues-characterselect-card-glow']={328,107,0.67431640625,0.99462890625,0.00048828125,0.10498046875,false,false},
		['glues-characterselect-button-collapseexpand-up-small-disabled']={29,29,0.38623046875,0.41455078125,0.68896484375,0.71728515625,false,false},
		['glues-gamemode-txtbg']={163,38,0.00048828125,0.15966796875,0.88330078125,0.92041015625,false,false},
		['glues-characterselect-icon-faction-alliance']={36,46,0.14892578125,0.18408203125,0.83056640625,0.87548828125,false,false},
		['glues-characterselect-card-glow-swap']={328,107,0.33544921875,0.65576171875,0.12353515625,0.22802734375,false,false},
		['glues-characterselect-scroll-arrow-down']={16,11,0.93603515625,0.95166015625,0.41455078125,0.42529296875,false,false},
		['glues-gamemode-glw-top']={151,53,0.00048828125,0.14794921875,0.83056640625,0.88232421875,false,false},
		['glues-characterselect-card-glow-fx']={346,125,0.00048828125,0.33837890625,0.00048828125,0.12255859375,false,false},
		['glues-characterselect-icon-arrowup-pressed-hover']={32,32,0.35400390625,0.38525390625,0.63037109375,0.66162109375,false,false},
		['glues-characterselect-card-selected-hover']={342,122,0.00048828125,0.33447265625,0.12353515625,0.24267578125,false,false},
		['glues-characterselect-iconshop']={23,23,0.95654296875,0.97900390625,0.21728515625,0.23974609375,false,false},
		['glues-characterselect-button-collapseexpand-small-pressed']={29,29,0.38623046875,0.41455078125,0.65966796875,0.68798828125,false,false},
		['glues-gamemode-glw-bottom']={189,96,0.00048828125,0.18505859375,0.51904296875,0.61279296875,false,false},
		['glues-characterselect-button-card-down-disabled-hover']={32,32,0.94189453125,0.97314453125,0.59033203125,0.62158203125,false,false},
		['glues-characterselect-icon-arrowup-pressed']={32,32,0.32177734375,0.35302734375,0.95263671875,0.98388671875,false,false},
		['glues-characterselect-card-fx-spreadb']={312,91,0.61572265625,0.92041015625,0.33740234375,0.42626953125,false,false},
		['glues-characterselect-iconshop-hover']={23,23,0.15380859375,0.17626953125,0.97216796875,0.99462890625,false,false}
	};
};

---------------------------------------------------------------
-- Backdrops
---------------------------------------------------------------
CPAPI.Backdrops = {
	Header = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Gradient_Alpha_Horizontal]]);
	--	edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
	Opaque = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_Noise]]);
	--	edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		tile     = true;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
	Frame = {
		bgFile   = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\Edgefile.blp]]);
		edgeSize = 8;
		tile     = true;
		insets   = {left = 8, right = 8, top = 8, bottom = 8};
	};
	Simple = {
	--	bgFile   = CPAPI.GetAsset([[Textures\Frame\Gradient_Alpha_Horizontal]]);
		edgeFile = CPAPI.GetAsset([[Textures\Edgefile\EdgeFile_Simple_White_4x32]]);
		edgeSize = 4;
		insets   = {left = 1, right = 1, top = 1, bottom = 1};
	};
}

---------------------------------------------------------------
-- Atlas tools
---------------------------------------------------------------
do local function InfoToAtlas(f, i)
		local atlas = { file = f,
			width             = i[1], leftTexCoord      = i[3],
			height            = i[2], rightTexCoord     = i[4],
			tilesHorizontally = i[7], topTexCoord       = i[5],
			tilesVertically   = i[8], bottomTexCoord    = i[6],
		};
		if i[9] then atlas.sliceData = {
			sliceMode  = i[9],
			marginLeft = i[10], marginRight  = i[11],
			marginTop  = i[12], marginBottom = i[13],
		} end
		return atlas;
	end

	function CPAPI.GetAtlasInfo(id)
		for file, atlasData in pairs(CPAPI.Atlas) do
			local atlasInfo = atlasData[id];
			if atlasInfo then
				return InfoToAtlas(file, atlasInfo), true;
			end
		end
		return C_Texture.GetAtlasInfo(id), false;
	end
end

function CPAPI.SetAtlas(object, id, useAtlasSize, flipHorz, flipVert, hWrapMode, vWrapMode, sData)
	---@class AtlasInfo
	local info, isCustom = CPAPI.GetAtlasInfo(id);
	if not info then
		return false, false;
	end
	if not ( isCustom or flipHorz or flipVert or hWrapMode or vWrapMode or sData ) then
		object:SetAtlas(id, useAtlasSize);
		return true, false;
	end
	if useAtlasSize then
		object:SetSize(info.width, info.height);
	end
	object:SetTexture(info.file or info.filename, hWrapMode, vWrapMode);
	object:SetTexCoord(
		flipHorz and info.rightTexCoord or info.leftTexCoord,
		flipHorz and info.leftTexCoord or info.rightTexCoord,
		flipVert and info.bottomTexCoord or info.topTexCoord,
		flipVert and info.topTexCoord or info.bottomTexCoord
	);
	object:SetHorizTile(info.tilesHorizontally);
	object:SetVertTile(info.tilesVertically);
	---@class UITextureSliceData
	sData = sData or info.sliceData or {};
	object:SetTextureSliceMargins(
		sData.marginLeft   or 0,
		sData.marginTop    or 0,
		sData.marginRight  or 0,
		sData.marginBottom or 0
	);
	object:SetTextureSliceMode(sData.sliceMode or 0);
	return true, true;
end

function CPAPI.SetTextureOrAtlas(object, info, sizeTexture, sizeAtlas)
	local textureOrAtlas, isAtlas, useAtlasSize = unpack(info)
	if isAtlas then
		object:SetAtlas(textureOrAtlas, useAtlasSize)
		if sizeAtlas then
			object:SetSize(unpack(sizeAtlas))
		end
		return
	end
	object:SetTexture(textureOrAtlas)
	if sizeTexture then
		object:SetSize(unpack(sizeTexture))
	end
end