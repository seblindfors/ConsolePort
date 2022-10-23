local db = select(2, ...);
db('Gamepad/Index/Icons', {
	Path = CPAPI.GetAsset([[Icons\%d\%s]]);
	All = {
		LG       = 'ALL_G_LEFT';
		RG       = 'ALL_G_RIGHT';
		Up       = 'ALL_L_UP';
		Down     = 'ALL_L_DOWN';
		Left     = 'ALL_L_LEFT';
		Right    = 'ALL_L_RIGHT';
	};
	Dpad = {
		Up       = 'DPAD_UP';
		Down     = 'DPAD_DOWN';
		Left     = 'DPAD_LEFT';
		Right    = 'DPAD_RIGHT';
	};
	PlayStation = {
		L1       = 'PS_S_L1';
		L2       = 'PS_S_L2';
		L3       = 'PS_S_L3';
		R1       = 'PS_S_R1';
		R2       = 'PS_S_R2';
		R3       = 'PS_S_R3';
		Cross    = 'PS_R_CROSS';
		Square   = 'PS_R_SQUARE';
		Circle   = 'PS_R_CIRCLE';
		Triangle = 'PS_R_TRIANGLE';
		Back     = 'PS_C_BACK';
		Back2    = 'PS_C_BACK2';
		Share    = 'PS_C_SHARE';
		System   = 'PS_C_SYSTEM';
		Options  = 'PS_C_OPTIONS';
	};
	Steam = {
		System   = 'STEAM_C_SYSTEM';
	};
	Xbox = {
		A        = 'XBOX_R_A';
		B        = 'XBOX_R_B';
		X        = 'XBOX_R_X';
		Y        = 'XBOX_R_Y';
		LB       = 'XBOX_S_LB';
		LT       = 'XBOX_S_LT';
		RB       = 'XBOX_S_RB';
		RT       = 'XBOX_S_RT';
		LSB      = 'XBOX_S_LSB';
		RSB      = 'XBOX_S_RSB';
		Back     = 'XBOX_C_BACK';
		Share    = 'XBOX_C_SHARE';
		System   = 'XBOX_C_SYSTEM';
		Options  = 'XBOX_C_OPTIONS';
		Forward  = 'XBOX_C_FORWARD';
	};
})

db('Gamepad/Index/Splash', {
	['PlayStation 4'] = 'DS4';
	['PlayStation 5'] = 'DS5';
	['Steam Deck'] = 'Deck';
	['Xbox'] = 'Xbox';
})