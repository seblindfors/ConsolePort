local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
local CreateDataContainer, ActivePopup, Compile;

local function HandleCompilation(data)
	if not env:ValidateLayout(data) then
		return CPAPI.Log('Invalid layout data, ignoring changes.');
	end
	env.Layout, ConsolePort_KeyboardLayout = data, data;
	ConsolePortKeyboard:OnLayoutChanged()
	CPAPI.Log('Keyboard layout has been updated.');
end

local function ResetLayout()
	CPAPI.Popup('ConsolePort_Keyboard_Layout_Reset', {
		text    = L'Are you sure you want to reset the keyboard layout?';
		button1 = YES;
		button2 = NO;
		OnAccept = function()
			HandleCompilation(env:GetDefaultLayout())
		end;
	})
end

local function WipeDictionary()
	local count = CountTable(env.Dictionary);
	CPAPI.Popup('ConsolePort_Keyboard_Dictionary_Wipe', {
		text    = L('Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.', count);
		button1 = YES;
		button2 = NO;
		OnAccept = function()
			wipe(env.Dictionary);
			CPAPI.Log('Keyboard dictionary has been wiped.');
		end;
	})
end

local function RegenerateDictionary()
	CPAPI.Popup('ConsolePort_Keyboard_Dictionary_Regen', {
		text    = L'Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.';
		button1 = YES;
		button2 = NO;
		OnAccept = function()
			local newDict = env.DictHandler:Generate()
			env.Dictionary, ConsolePort_KeyboardDictionary = newDict, newDict;
			CPAPI.Log('Keyboard dictionary has been reset to default.');
		end;
	})
end

local function ShowDataContainer()
	if ActivePopup then return end;
	local active  = db.Gamepad.Active;
	local dataBin = CreateDataContainer()

	local modOrder, setOrder, dirOrder = {}, {
		'keyboardEscapeButton';
		'keyboardEnterButton';
		'keyboardSpaceButton';
		'keyboardEraseButton';
	}, { 'NN', 'NE', 'EE', 'SE', 'SS', 'SW', 'WW', 'NW'};

	for mod in db.table.mpairs(db.Gamepad.Index.Modifier.Active) do
		tinsert(modOrder, mod);
	end

	local function GetButtonID(value)
		local varID = setOrder[tonumber(value)];
		if varID then
			return db(varID);
		end
		return nil;
	end

	local function GetModifier(value)
		return modOrder[tonumber(value)];
	end

	ActivePopup = dataBin:Popup('ConsolePort_Keyboard_Layout', {
		text    = L'Keyboard Layout Editor';
		button1 = SAVE;
		button2 = CANCEL;
		OnAccept = function()
			HandleCompilation(Compile());
		end;
		OnHide = function()
			ActivePopup, Compile = nil, nil;
		end;
		OnShow = function(popup, data)
			dataBin:AdjustSize(popup)
			Compile, Release = dataBin:SetData({
				fixed = true;
				alias = {
					value = {
						['^""$'] = function()
							return ('|cFF757575%s|r'):format(NONE)
						end;
						['"[^"]+"$'] = function(value)
							return env:GetText(value:sub(2, -2))
						end;
					};
					path = {
						['^(%d+)$'] = function(setIndex)
							return L('Set %d |cFF757575(%s)|r', setIndex, dirOrder[tonumber(setIndex)] or NOT_APPLICABLE);
						end;
						['^%d+/(%d+)$'] = function(buttonIndex)
							local buttonID = GetButtonID(buttonIndex);
							if active and buttonID then
								return active:GetTooltipButtonPrompt(buttonID, buttonIndex);
							end
							return L('Button %d', value);
						end;
						['^%d+/(%d+)/(%d+)$'] = function(buttonIndex, keyIndex)
							local modID = GetModifier(keyIndex);
							local btnID = GetButtonID(buttonIndex);
							if btnID and modID then
								return db.Hotkeys:GetButtonSlugForChord(modID..btnID, false, true);
							end
							return L('Key %d', keyIndex);
						end;
					};
				};
			}, env.Layout)
		end;
	})

end

---------------------------------------------------------------
local ConfigButtons = {
---------------------------------------------------------------
	{
		text     = EDIT;
		atlas    = 'RedButton-Expand';
		callback = ShowDataContainer;
	};
	{
		text     = RESET;
		atlas    = 'common-icon-undo';
		callback = ResetLayout;
	};
	{
		text     = L'Regenerate Dictionary';
		atlas    = 'common-icon-undo';
		advd     = true;
		callback = RegenerateDictionary;
	};
	{
		text     = L'Wipe Dictionary';
		atlas    = 'common-icon-redx';
		advd     = true;
		callback = WipeDictionary;
	};
};

ConsolePort:RegisterConfigCallback(function(self, configEnv)
	CreateDataContainer = configEnv.CreateDataContainer;

	local settingsPanelID = 2;
	local Settings = configEnv:GetPanelByID(settingsPanelID)

	local main, head = env.Attributes.HeaderName, env.Attributes.ModuleName;
	local button = configEnv.Elements.Button;

	Settings:AddProvider(function(AddSetting)
		for i, setup in ipairs(ConfigButtons) do
			AddSetting(main, head, CreateFromMixins(setup, {
				sort  = i;
				type  = button;
				field = {
					before = not setup.advd;
					advd   = setup.advd;
				};
			}))
		end
	end)

	Settings:OnIndexChanged()
end, env)