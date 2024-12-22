local _, env = ...; local db, L = env.db, env.L;
local Serialize, Deserialize = env.Serialize, env.Deserialize;
local Tabular, Carpenter = LibStub('Tabular'), LibStub('Carpenter')
local CreateDataContainer;

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local BROWSER_HEIGHT        = 500;
local BROWSER_CONTENT_WIDTH = 500;
local BROWSER_FRAME_WIDTH   = 560;
local BROWSER_FRAME_PADDING =
	(BROWSER_FRAME_WIDTH - BROWSER_CONTENT_WIDTH) / 2;

local KEYS_MARK  = BLUE_FONT_COLOR:WrapTextInColorCode(CTRL_KEY_TEXT ..'+A');
local KEYS_COPY  = BLUE_FONT_COLOR:WrapTextInColorCode(CTRL_KEY_TEXT ..'+C');
local KEYS_PASTE = BLUE_FONT_COLOR:WrapTextInColorCode(CTRL_KEY_TEXT ..'+V');

local KEYS_COPY_STRING = ('%s + %s'):format(KEYS_MARK, KEYS_COPY)
local EXPORT_DATA_TEXT = L('EXPORT_DATA_TEXT', KEYS_COPY_STRING)

local IMPORT_DATA_TEXT = L('IMPORT_DATA_TEXT', KEYS_COPY_STRING, KEYS_PASTE)
local IMPORT_FAILED_TEXT = L('IMPORT_FAILED_TEXT');

local PFX = '^ConsolePort'; -- alias path pattern prefix

---------------------------------------------------------------
-- Map of aliases to replace display keys and values
---------------------------------------------------------------
local AliasMap = {
	key = {
		['^$'] = function()
			return ('|cFF757575%s|r'):format(NONE)
		end;
		['^(%u?[^PAD]*)(PAD[%d%u]+)$'] = function(mod, button)
			local buttonSlug = ConsolePort:GetFormattedButtonCombination(button, mod)
			if buttonSlug:match('ALL_MISSING') then
				return ('|cFF757575%s%s|r'):format(mod, button);
			end
			return buttonSlug;
		end;
	};
	path = {
		[PFX..'Bindings$'] = KEY_BINDINGS_MAC;
		[PFX..'Settings$'] = INTERFACE_OPTIONS;
		[PFX..'Utility$'] = L'Rings';
		[PFX..'Configs$'] = L'Device Mappings';
		[PFX..'Cvars$'] = L'Device Settings';
		[PFX..'Devices$'] = L'Device Profiles';
		[PFX..'_BarLayout$'] = L'Action Bar Setup';
		[PFX..'_BarPresets$'] = L'Action Bar Presets';
		[PFX..'_BarLoadout$'] = L'Action Bar Loadout';
		[PFX..'_BarSetup$'] = L'Action Bar Loadout (Deprecated)';
		[PFX..'_Talents$'] = TALENTS;
		[PFX..'Bindings/(%u+%d?)/(.*)$'] = function(button, mod)
			return ConsolePort:GetFormattedButtonCombination(button, mod)
		end;
		[PFX..'Configs/%d+/(%l%a+)$'] = function(variable)
			return variable:gsub('(%u+)', ' %1'):gsub('^%l', string.upper)
		end;
		[PFX..'Cvars/(%a+)/([%a_]+)$'] = function(section, cvar)
			local section = db.Console[section];
			if section then
				for i, data in ipairs(section) do
					if (data.cvar == cvar) then
						return data.name;
					end
				end
			end
			return cvar;
		end;
		[PFX..'Settings/(%w+)$'] = function(variable)
			local var = db('Variables/'..variable);
			if type(var) == 'table' then
				return ('|cFF757575%s|r\n%s'):format(var.head or NOT_APPLICABLE, var.name)
			end
			return variable;
		end;
		[PFX..'Utility/([^/]+)$'] = function(setID)
			if ( tonumber(setID) == 1 ) then
				return BLUE_FONT_COLOR:WrapTextInColorCode(DEFAULT);
			end
			return db.Utility:GetBindingDisplayNameForSet(setID)
		end;
		[PFX..'Utility/%w+/(%d+)$'] = function(buttonID)
			return L('Button |cFF00FFFF%s|r', buttonID)
		end;
	};
	value = {
		['^""$'] = function()
			return ('|cFF757575%s|r'):format(NONE)
		end;
		['^"none"$'] = function()
			return ('|cFF757575%s|r'):format(NONE)
		end;
		['^"([%u%d]+)"$'] = function(binding)
			env.BindingInfo:RefreshDictionary()
			return env.BindingInfo:GetBindingName(binding) or ('%q'):format(binding)
		end;
		['^"(CLICK %w+:%w+)"$'] = function(binding)
			local _, _, name = db.Bindings:GetDescriptionForBinding(binding)
			return name or ('%q'):format(binding)
		end;
		['^"(%u?[^PAD]*)(PAD[%d%u]+)"$'] = function(mod, button)
			local buttonSlug = ConsolePort:GetFormattedButtonCombination(button, mod)
			if buttonSlug:match('ALL_MISSING') then
				return ('|cFF757575%s%s|r'):format(mod, button);
			end
			return buttonSlug;
		end;
	};
};

local AliasMapExport = db.table.merge({
	path = {
		[PFX..'_BarLoadout/(%d+)/?(%d*)$'] = function(pageID, buttonID)
			local actionID = tonumber(buttonID) and (tonumber(pageID) - 1) * NUM_ACTIONBAR_BUTTONS + tonumber(buttonID);
			if actionID then
				return ('|cFF00FFFF%s|r: %s'):format(buttonID,
					env.BindingInfo:GetActionInfo(actionID) or ('|cFF757575%s|r'):format(NONE))
			end
			return L('Page |cFF00FFFF%s|r', pageID)
		end;
	}
}, AliasMap)


---------------------------------------------------------------
-- Pickup handlers
---------------------------------------------------------------
local ActionPickupHandlers = {
	spell = function(id) return CPAPI.PickupSpell(id) end;
	item = function(id) return CPAPI.PickupItem(id) end;
	summonpet    = C_PetJournal and C_PetJournal.PickupPet;
	equipmentset = function(id)
		local setID = C_EquipmentSet.GetEquipmentSetID(id)
		if setID then
			return C_EquipmentSet.PickupEquipmentSet(setID)
		end
	end;
	summonmount  = function(id)
		local mountInfo = {C_MountJournal.GetMountInfoByID(id)}
		local spellID, isCollected = mountInfo[2], mountInfo[11];
		if not isCollected then return end
		-- HACK: Have to do all this because you can't pickup mount by mount ID.
		C_MountJournal.SetDefaultFilters()
		for i=1, C_MountJournal.GetNumDisplayedMounts() do
			if select(2, C_MountJournal.GetDisplayedMountInfo(i)) == spellID then
				return C_MountJournal.Pickup(i)
			end
		end
	end;
	flyout = function(id)
		local spellBookIndex;
		for i = 1, GetNumSpellTabs() do
			local _, _, offset, numSlots = GetSpellTabInfo(i)
			for j = offset+1, offset+numSlots do
				local spellType, spellID = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
				if (spellType == 'FLYOUT' and spellID == id) then
					return PickupSpellBookItem(j, BOOKTYPE_SPELL)
				end
			end
		end
	end;
	macro = function(id, name, icon, body)
		local function IsEquivalentMacro(mName, mIcon, mBody)
			return ( mName == name and icon == icon and body == body )
		end
		-- Try to find equivalent macro
		if IsEquivalentMacro(GetMacroInfo(id)) then
			return PickupMacro(id)
		end
		local global, perChar = GetNumMacros()
		for i=1, global do
			if IsEquivalentMacro(GetMacroInfo(i)) then
				return PickupMacro(id)
			end
		end
		for i=1, perChar do
			if IsEquivalentMacro(GetMacroInfo(120 + i)) then
				return PickupMacro(id)
			end
		end
		-- Create new macro
		local createOK, macroID = pcall(CreateMacro, name, icon, body, id > 120)
		if createOK and macroID then
			return PickupMacro(macroID)
		end
	end;
};

---------------------------------------------------------------
-- Generate content for the browser
---------------------------------------------------------------
local Aggregators = {
	ConsolePortUtility  = function() return db.Utility.Data end;
	ConsolePortBindings = function() return db.Gamepad:GetBindings(true) end;
	ConsolePortDevices  = function() return db.Gamepad.Devices end;
	ConsolePortSettings = function()
		local settings = {};
		for varID in db:For('Variables') do
			settings[varID] = db(varID)
		end
		return settings;
	end;
	ConsolePortConfigs  = function()
		local configs;
		for i, config in ipairs(C_GamePad.GetAllConfigIDs()) do
			configs = configs or {};
			configs[i] = C_GamePad.GetConfig(config)
		end
		return configs;
	end;
	ConsolePortCvars = function()
		local vars, var = {};
		for header, set in pairs(db.Console) do
			vars[header] = vars[header] or {};
			for i, data in ipairs(set) do
				var = GetCVar(data.cvar)
				vars[header][data.cvar] = tonumber(var) or var;
			end
		end
		return vars;
	end;
	ConsolePort_BarLayout = function() return ConsolePort_BarLayout end;
	ConsolePort_BarPresets = function() return ConsolePort_BarPresets end;
	ConsolePort_BarLoadout = function()
		local actions = {};
		for page = 1, 10 do
			actions[page] = {};
			for slot = 1, NUM_ACTIONBAR_BUTTONS do
				local actionInfo = {GetActionInfo(((page - 1) * NUM_ACTIONBAR_BUTTONS) + slot)}
				actions[page][slot] = actionInfo;
				if (actionInfo[1] == 'macro') then
					tAppendAll(actionInfo, {GetMacroInfo(actionInfo[2])})
				end
			end
		end
		return actions;
	end;
	ConsolePort_BarSetup = nop;
}

local Evaluators = {
	{'ConsolePortSettings', function(settings)
		for varID, value in pairs(settings) do
			if ( db(varID) ~= value ) then
				db('Settings/'..varID, value)
			end
		end
	end};
	{'ConsolePortCvars', function(vars)
		for header, set in pairs(vars) do
			for cvar, value in pairs(set) do
				SetCVar(cvar, value)
			end
		end
	end};
	{'ConsolePortBindings', function(bindings)
		local bindingSetID = GetCurrentBindingSet()
		for btn, set in pairs(bindings) do
			for mod, binding in pairs(set) do
				SetBinding(mod..btn, binding)
			end
		end
		SaveBindings(bindingSetID)
	end};
	{'ConsolePortUtility', function(data)
		for setID, set in pairs(data) do
			local ring = {};
			for _, buttonData in db.table.spairs(set) do
				tinsert(ring, buttonData)
			end
			db('Utility/Data/'..setID, ring)
		end
		return true;
	end};
	{'ConsolePortDevices', function(devices)
		ConsolePortDevices = devices;
		return true;
	end};
	{'ConsolePortConfigs', function(configs)
		for i, config in pairs(configs) do
			C_GamePad.SetConfig(config)
		end
	end};
	{'ConsolePort_BarLayout', function(setup)
		ConsolePort_BarLayout = setup;
		return true;
	end};
	{'ConsolePort_BarPresets', function(presets)
		ConsolePort_BarPresets = presets;
		return true;
	end};
	{'ConsolePort_BarLoadout', function(actions)
		for page, set in pairs(actions) do
			for slot, actionInfo in pairs(set) do
				local actionID = ((page - 1) * NUM_ACTIONBAR_BUTTONS) + slot;

				local pickup = ActionPickupHandlers[actionInfo[1]];
				if pickup then
					pickup(unpack(actionInfo, 2))
					if GetCursorInfo() then
						PlaceAction(actionID)
					end
					ClearCursor()
				else
					PickupAction(actionID)
					ClearCursor()
				end
			end
		end
	end};
	{'ConsolePort_BarSetup', function(setup)
		ConsolePort_BarSetup  = setup;
		ConsolePort_BarLayout = nil;
		return true;
	end}; -- deprecated
}
---------------------------------------------------------------

local Browser = CreateFromMixins(env.FlexibleMixin)

function Browser:OnLoad()
	self.Child:SetHeight(self:GetHeight())
	self.Child:SetMeasurementOrigin(self.Child, self.Child, BROWSER_CONTENT_WIDTH, 0)
end

function Browser:OnShow()
	self:SetVerticalScroll(0)
	self.LoadingSpinner:Show()
end

function Browser:OnEnter()
	self:Raise()
end

function Browser:OnHide()
	if self.release then
		self.release()
		self.compile, self.release = nil, nil;
	end
end

function Browser:SetData(args, data)
	self:OnHide()
	args.parent = self.Child;
	args.width  = BROWSER_CONTENT_WIDTH;
	args.state  = false;
	self.compile, self.release = Tabular(args, data)
	self.Child:SetHeight(self:GetHeight())
	self.LoadingSpinner:Hide()
	return self.compile, self.release;
end

function Browser:Compile()
	if self.compile then
		return self.compile()
	end
end


---------------------------------------------------------------
local function AdjustBrowserSize(popup, container, browser)
	RunNextFrame(function()
		local offset = -popup:GetBottom()
		if offset < 0 then
			container:SetHeight(BROWSER_HEIGHT)
			return browser:SetHeight(BROWSER_HEIGHT)
		end
		container:SetHeight(BROWSER_HEIGHT - offset)
		browser:SetHeight(BROWSER_HEIGHT - offset)
		popup:SetHeight(popup:GetHeight() - offset)
	end)
end

local function GenerateExportData()
	local data = {};
	for key, aggregator in pairs(Aggregators) do
		data[key] = aggregator();
	end
	return data;
end

local function ValidateImportData(data)
	if type(data) ~= 'table' then return end;
	for k in pairs(data) do
		if not Aggregators[k] then
			return
		end
	end
	return data;
end

local function EvaluateImportData(data)
	if not data then return end

	local reloadWhenDone = false;
	for i, evaluatorMeta in ipairs(Evaluators) do
		local key, evaluator = unpack(evaluatorMeta)
		local set = data[key];
		local result = set and evaluator(set)
		if (type(result) == 'string') then
			return CPAPI.Popup('ConsolePort_Import_Failed', {
				button1 = OKAY;
				showAlert = 1;
				text = IMPORT_FAILED_TEXT..'%s';
			}, result)
		elseif result then
			reloadWhenDone = true;
		end
	end
	if reloadWhenDone then
		ReloadUI();
	end
end

local function CreateAsyncCallback(callback)
	local mutex;
	return function()
		if not mutex then
			mutex = true;
			RunNextFrame(function()
				callback()
				mutex = nil;
			end)
		end
	end
end


local ImportButton, ExportButton = {}, {};

function ImportButton:OnClick()
	if self.popup then return self:Check() end;
	if self:GetParent().Export.popup then return self:Uncheck() end;

	local dataBin = CreateDataContainer()
	local alias = AliasMap;

	local onLoadData = function(popup, editBox, text)
		local data = ValidateImportData(env.Deserialize(text))
		if data then
			dataBin.Browser:SetData({alias = alias}, data)
			editBox:ClearFocus()
		end
		editBox:SetText('')
	end;

	self.popup = CPAPI.Popup('ConsolePort_Import_Data', {
		text = IMPORT_DATA_TEXT;
		hasEditBox = 1;
		maxLetters = 0;
		button1 = APPLY;
		button2 = CANCEL;
		button3 = L'Load';
		noCloseOnAlt = true;
		EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end;
		EditBoxOnTextChanged = function(self)
			self:GetParent().button3:SetEnabled(self:GetText():len() > 0)
		end;
		EditBoxOnEnterPressed = function(self)
			onLoadData(self:GetParent(), self, self:GetText())
		end;
		OnHide = function(popup)
			self.popup = nil;
			self:Uncheck()
		end;
		OnAlt = function(self)
			onLoadData(self, self.editBox, self.editBox:GetText())
		end;
		OnShow = function(self)
			self.button3:SetEnabled(false)
			AdjustBrowserSize(self, dataBin, dataBin.Browser)
		end;
		OnAccept = function(popup)
			db:RunSafe(EvaluateImportData, dataBin.Browser:Compile())
		end;
	}, nil, nil, nil, dataBin)
end

function ExportButton:OnClick()
	if self.popup then return self:Check() end;
	if self:GetParent().Import.popup then return self:Uncheck() end;

	local dataBin, mutex = CreateDataContainer()

	local alias = AliasMapExport;
	local data  = GenerateExportData()
	local callback = CreateAsyncCallback(function()
		local data = dataBin.Browser:Compile()
		if next(data) then
			self.output = env.Serialize(data)
			self.popup.editBox:SetText(self.output)
		else
			self.output = nil;
			self.popup.editBox:SetText('')
		end
	end)

	self.popup = CPAPI.Popup('ConsolePort_Export_Data', {
		text = EXPORT_DATA_TEXT;
		hasEditBox = 1;
		maxLetters = 0;
		button1 = DONE;
		EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end;
		EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end;
		EditBoxOnTextChanged = function(editBox)
			local output = self.output or '';
			if ( editBox:GetText() ~= output ) then
				editBox:SetText(output)
			end
		end;
		OnHide = function(popup)
			self.popup, self.output = nil, nil;
			self:Uncheck()
		end;
		OnShow = function(self, data)
			local browser = dataBin.Browser;
			AdjustBrowserSize(self, dataBin, browser)
			browser:SetData({callback = callback, alias = alias}, data)
		end;
	}, nil, nil, data, dataBin)
end

function CreateDataContainer()
	if not env.DataContainer then
		env.DataContainer = Carpenter('Frame', nil, nil, nil, {
			_Level = 100;
			_Size = {BROWSER_FRAME_WIDTH, BROWSER_HEIGHT};
			{
				Browser = {
					_Mixin = Browser;
					_Type  = 'ScrollFrame';
					_Setup = {'CPSmoothScrollTemplate'};
					_Points = {
						{'TOPLEFT', BROWSER_FRAME_PADDING, -BROWSER_FRAME_PADDING};
						{'BOTTOMRIGHT', -BROWSER_FRAME_PADDING, BROWSER_FRAME_PADDING};
					};
					{
						Child = {
							_Width = BROWSER_CONTENT_WIDTH;
							_Mixin = env.ScaleToContentMixin;
						};
						LoadingSpinner = {
							_Type = 'Texture';
							_Size = {146, 146};
							_Point = {'CENTER', 0, 0};
							_Atlas = {'auctionhouse-ui-loadingspinner'};
						};
						LoadingAnimation = {
							_Type = 'AnimationGroup';
							_OnLoad = function(self)
								self:Play()
								self:SetLooping('REPEAT')
							end;
							{
								SpinnerAnimation = {
									_Type = 'Animation';
									_Setup = 'ROTATION';
									_OnLoad = function(self)
										self:SetChildKey('LoadingSpinner')
										self:SetOrder(1)
										self:SetDuration(1)
										self:SetDegrees(-360);
									end;
								};
							};
						};
					};
				};
			};
		})
	end
	return env.DataContainer;
end

Carpenter:BuildFrame(env.Config, {
	Header = {
		{
			Controls = {
				_Width = 110;
				{
					Export = {
						_Type = 'IndexButton';
						_Size = {26, 26};
						_Mixin = ExportButton;
						_Point = {'RIGHT', '$parent.Close', 'LEFT', -4, 0};
						_SetNormalTexture = CPAPI.GetAsset([[Textures\Frame\Export]]);
						_SetHighlightTexture = CPAPI.GetAsset([[Textures\Frame\Export]]);
						_SetThumbPosition = {'BOTTOM', 0.5};
					};
					Import = {
						_Type = 'IndexButton';
						_Size = {26, 26};
						_Mixin = ImportButton;
						_Point = {'RIGHT', '$parent.Export', 'LEFT', -4, 0};
						_SetNormalTexture = CPAPI.GetAsset([[Textures\Frame\Import]]);
						_SetHighlightTexture = CPAPI.GetAsset([[Textures\Frame\Import]]);
						_SetThumbPosition = {'BOTTOM', 0.5};
					};
				};
			};
		};
	};
})
