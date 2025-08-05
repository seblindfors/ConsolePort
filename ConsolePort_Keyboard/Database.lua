local _, Data, env = CPAPI.LinkEnv(...)

---------------------------------------------------------------
-- Attributes
---------------------------------------------------------------

env.Attributes = {
	HideKeyboard = 'hidekeyboard';    -- The keyboard does not show for this frame.
	ModuleName   = 'Keyboard';        -- The name of the module in the listing (unlocalized).
	HeaderName   = INTERFACE_LABEL;   -- The name of the header in the listing (localized).
};

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local DEPENDENCY = { keyboardEnable = true };
ConsolePort:AddVariables({
	_(env.Attributes.ModuleName, env.Attributes.HeaderName, 2);
	keyboardSpaceButton = _{Data.Button('PAD1');
		name = 'Space';
		desc = 'Button to use to trigger the space command.';
		deps = DEPENDENCY;
	};
	keyboardEnterButton = _{Data.Button('PAD2');
		name = 'Enter';
		desc = 'Button to use to trigger the enter command.';
		deps = DEPENDENCY;
	};
	keyboardEraseButton = _{Data.Button('PAD3');
		name = 'Erase';
		desc = 'Button to use to erase characters.';
		deps = DEPENDENCY;
	};
	keyboardEscapeButton = _{Data.Button('PAD4');
		name = 'Escape';
		desc = 'Button to use to trigger the escape command.';
		deps = DEPENDENCY;
	};
	keyboardMoveLeftButton = _{Data.Button('PADDLEFT');
		name = 'Move Left';
		desc = 'Button to use to move the cursor leftwards.';
		deps = DEPENDENCY;
	};
	keyboardMoveRightButton = _{Data.Button('PADDRIGHT');
		name = 'Move Right';
		desc = 'Button to use to move the cursor rightwards.';
		deps = DEPENDENCY;
	};
	keyboardNextWordButton = _{Data.Button('PADDDOWN');
		name = 'Next Word';
		desc = 'Button to select next suggested word.';
		deps = DEPENDENCY;
	};
	keyboardPrevWordButton = _{Data.Button('PADDUP');
		name = 'Previous Word';
		desc = 'Button to select previous suggested word.';
		deps = DEPENDENCY;
	};
	keyboardAutoCorrButton = _{Data.Button('PADRTRIGGER');
		name = 'Insert Suggestion';
		desc = 'Button to insert suggested word.';
		deps = DEPENDENCY;
	};
	keyboardDictPattern = _{Data.String("[%a][%w']*[%w]+");
		name = 'Dictionary Match Pattern';
		desc = 'Lua pattern to match words for dictionary lookups.';
		advd = true;
		deps = DEPENDENCY;
	};
	keyboardDictAlphabet = _{Data.String('abcdefghijklmnopqrstuvwxyz');
		name = 'Dictionary Match Alphabet';
		desc = 'Alphabet to use for dictionary suggestions and word processing.';
		advd = true;
		deps = DEPENDENCY;
	};
})

---------------------------------------------------------------
-- Default data
---------------------------------------------------------------
function _(t) return ([[|TInterface\%s:0|t]]):format(t) end;

env.DefaultLayout = {
	{
		{"a", "A", "1", "/s "},
		{"b", "B", "2", "/p "},
		{"c", "C", "3", "/i "},
		{"d", "D", "4", "/g "},
	};
	{
		{"e", "E", "5", "/y "},
		{"f", "F", "6", "/w "},
		{"g", "G", "7", "/e "},
		{"h", "H", "8", "/r "},
	};
	{
		{"i", "I", "9", "/raid "},
		{"j", "J", "<", "/readycheck "},
		{"k", "K", "0", "/rw "},
		{"l", "L", ">", "%T "},
	};
	{
		{"m", "M", "@", "^"},
		{"n", "N", "&", "#"},
		{"o", "O", "$", "€"},
		{"p", "P", "%", "£"},
	};
	{
		{"q", "Q", "/", "½"},
		{"r", "R", "(", "["},
		{"s", "S", "\\", "\|"},
		{"t", "T", ")", "]"},
	};
	{
		{"u", "U", "+", "§"},
		{"v", "V", "*", "{"},
		{"w", "W", "=", "¿"},
		{"x", "X", "/", "}"},
	};
	{
		{"y", "Y", "{rt1}", "{rt1}"},
		{"z", "Z", "{rt2}", "{rt2}"},
		{"\"", "'", "{rt3}", "{rt3}"},
		{"-", "_", "{rt4}", "{rt4}"},
	};
	{
		{"!", "!", "{rt5}", "{rt5}"},
		{".", ":", "{rt6}", "{rt6}"},
		{",", ";", "{rt7}", "{rt7}"},
		{"?", "?", "{rt8}", "{rt8}"},
	};
};

env.Cmd = {
	Space  = '{cmd1}';
	Enter  = '{cmd2}';
	Erase  = '{cmd3}';
	Escape = '{cmd4}';
};

env.DefaultMarkers = {
	['{rt1}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_1]];
	['{rt2}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_2]];
	['{rt3}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_3]];
	['{rt4}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_4]];
	['{rt5}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_5]];
	['{rt6}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_6]];
	['{rt7}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_7]];
	['{rt8}']          = _ [[TARGETINGFRAME\UI-RaidTargetingIcon_8]];

	[env.Cmd.Space]    = _ [[AddOns\ConsolePort_Keyboard\Assets\IconSpace.tga]];
	[env.Cmd.Erase]    = _ [[AddOns\ConsolePort_Keyboard\Assets\IconEraser.tga]];
	[env.Cmd.Enter]    = _ [[RAIDFRAME\ReadyCheck-Ready]];
	[env.Cmd.Escape]   = _ [[RAIDFRAME\ReadyCheck-NotReady]];

	['/rw ']           = _ [[DialogFrame\UI-Dialog-Icon-AlertNew]];
	['/raid ']         = _ [[Scenarios\ScenarioIcon-Boss]];
	['/readycheck ']   = _ [[RAIDFRAME\ReadyCheck-Waiting]];
	['/attacktarget '] = _ [[CURSOR\Attack]];

	['%T ']            = _ [[MINIMAP\TRACKING\Target]];
	['%T']             = _ [[MINIMAP\TRACKING\Target]];
	['%F ']            = _ [[MINIMAP\TRACKING\Focus]];
	['%F']             = _ [[MINIMAP\TRACKING\Focus]];

	['/s ']            = '/s';
	['/p ']            = '/p';
	['/i ']            = '/i';
	['/g ']            = '/g';
	['/y ']            = '/y';
	['/w ']            = '/w';
	['/e ']            = '/e';
	['/r ']            = '/r';
};

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local NUM_STATES = 8;

function env:GetDefaultLayout()
	local layout = {};
	for i, set in ipairs(self.DefaultLayout) do
		layout[i] = {};
		for j, keys in ipairs(set) do
			layout[i][j] = {};
			for k = 1, NUM_STATES do
				layout[i][j][k] = keys[k] or '';
			end
		end
	end
	return layout;
end

function env:ValidateLayout(layout, default)
	default = default or self:GetDefaultLayout();
	-- Dynamically composed sets are not supported anymore,
	-- so if a user has customized their layout to have more
	-- sets (8+) or variable keys (not 4) then reset the layout.
	if #layout > #default then
		return false;
	end
	for i, set in ipairs(layout) do
		if #set ~= #default[i] then
			return false;
		end
		for j, keys in ipairs(set) do
			if #keys ~= #default[i][j] then
				return false;
			end
		end
	end
	return true;
end

function env:GetText(text)
	return self.Markers[text] or text;
end