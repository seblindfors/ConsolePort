---------------------------------------------------------------
-- Assets
---------------------------------------------------------------
function CPAPI.GetAsset(path)
	return ([[Interface\AddOns\ConsolePort\Assets\%s]]):format(path)
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
	[CPAPI.GetAsset([[Textures\Atlas\AnimationsMaskFiligreeActivate.png]])] = {
		['animations-mask-filigree-activate'] = { 1612, 774, 0, 1612/2048, 0, 774/1024, false, false };
	};
	[CPAPI.GetAsset([[Textures\Atlas\ClassAnimations.png]])] = {
		['animations-class-evoker'] = { 461, 461, 0.64013671875, 0.865234375, 0.37939453125, 0.6044921875, false, false };
	};
	[CPAPI.GetAsset([[Textures\Atlas\ClassAnimations2.png]])] = {
		['animations-class-deathknight'] = { 461, 461, 0.50146484375, 0.7265625, 0.00048828125, 0.2255859375, false, false };
		['animations-class-demonhunter'] = { 461, 461, 0.7275390625, 0.95263671875, 0.00048828125, 0.2255859375, false, false };
		['animations-class-druid'] = { 461, 461, 0.50146484375, 0.7265625, 0.2265625, 0.45166015625, false, false };
		['animations-class-hunter'] = { 461, 461, 0.7275390625, 0.95263671875, 0.2265625, 0.45166015625, false, false };
		['animations-class-mage'] = { 461, 461, 0.00048828125, 0.2255859375, 0.50146484375, 0.7265625, false, false };
		['animations-class-monk'] = { 461, 461, 0.00048828125, 0.2255859375, 0.7275390625, 0.95263671875, false, false };
		['animations-class-paladin'] = { 461, 461, 0.2265625, 0.45166015625, 0.50146484375, 0.7265625, false, false };
		['animations-class-priest'] = { 461, 461, 0.2265625, 0.45166015625, 0.7275390625, 0.95263671875, false, false };
		['animations-class-rogue'] = { 461, 461, 0.45263671875, 0.677734375, 0.50146484375, 0.7265625, false, false };
		['animations-class-shaman'] = { 461, 461, 0.45263671875, 0.677734375, 0.7275390625, 0.95263671875, false, false };
		['animations-class-warlock'] = { 461, 461, 0.6787109375, 0.90380859375, 0.50146484375, 0.7265625, false, false };
		['animations-class-warrior'] = { 461, 461, 0.6787109375, 0.90380859375, 0.7275390625, 0.95263671875, false, false };
		['animations-gridburst'] = { 1024, 1024, 0.00048828125, 0.50048828125, 0.00048828125, 0.50048828125, false, false };
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