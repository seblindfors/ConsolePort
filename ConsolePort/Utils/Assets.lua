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
		['perks-divider'] = { 484, 3, 0, 484/1024, 151/256, 154/256, false, false },
	};
	[CPAPI.GetAsset([[Textures\Atlas\ObjectIcons_Atlas.png]])] = {
		['Auctioneer'] = { 32, 32, 0.2431640625, 0.2744140625, 0.3642578125, 0.3955078125, false, false };
		['TorghastDoor-ArrowDown-32x32'] = { 24, 24, 0.7744140625, 0.8056640625, 0.3642578125, 0.3955078125, false, false };
		['UpgradeItem-32x32'] = { 24, 24, 0.9404296875, 0.9716796875, 0.3642578125, 0.3955078125, false, false };
		['Islands-MarkedArea'] = { 32, 32, 0.2763671875, 0.3076171875, 0.2978515625, 0.3291015625, false, false };
		['GreenCross'] = { 32, 32, 0.8076171875, 0.8388671875, 0.2646484375, 0.2958984375, false, false };
		['XMarksTheSpot'] = { 32, 32, 0.7080078125, 0.7392578125, 0.4306640625, 0.4619140625, false, false };
		['MiniMap-QuestArrow'] = { 32, 32, 0.2763671875, 0.3076171875, 0.8623046875, 0.8935546875, false, false };
		['poi-transmogrifier'] = { 29, 36, 0.6611328125, 0.689453125, 0.0810546875, 0.1162109375, false, false };
		['Banker'] = { 32, 32, 0.2431640625, 0.2744140625, 0.4638671875, 0.4951171875, false, false };
		['Waypoint-MapPin-Minimap-Tracked'] = { 32, 32, 0.5419921875, 0.5732421875, 0.4306640625, 0.4619140625, false, false };
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