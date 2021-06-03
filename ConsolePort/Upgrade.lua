local _, db = ...; local UpgradeHandler = CPAPI.CreateEventHandler({'Frame'}, {'UPDATE_BINDINGS'})
local UPGRADE_TEXT = [[|TInterface\AddOns\ConsolePort\Assets\Textures\Logo\CP.blp:128:128:0|t
|cFFFFFF00ConsolePort 2.0|r

Please take a moment to read through the following information:

This version uses |cFF00FF00native gamepad controls|r, which means ConsolePort is fully integrated in the game.

WoWmapper users: |cFFFF0000stop using WoWmapper|r entirely from now on. It's not only unnecessary, but will interfere with your in-game controls.

Steam controller users: please change your controller profile in Steam to a generic Xbox profile, and use the Xbox device preset.

Your bindings have been automatically converted to the new native format. You may need to reconfigure some of them after selecting a device.

If you need help during this transitionary period, please visit our Discord server for further assistance:
]]
---------------------------------------------------------------
-- Upgrade script from Legacy (9.0.1) -> Native (9.0.2+)
---------------------------------------------------------------
DisableAddOn('ConsolePortAdvanced')
DisableAddOn('ConsolePortBar')
DisableAddOn('ConsolePortHelp')
DisableAddOn('ConsolePortLoader')
DisableAddOn('ConsolePortUI_Loot')
DisableAddOn('ConsolePortUI_Menu')

function UpgradeHandler:OnDataLoaded()
	-- Clean out old utility ring information
	local utility = ConsolePortUtility;
	if utility then
		local removalPending;
		for id, ring in pairs(utility) do
			ring.value = nil; ------\
			ring.action = nil; ------> old format detection
			ring.cursorID = nil; ---/
			if not next(ring) then
				removalPending = removalPending or {};
				removalPending[id] = true;
			end
		end
		if removalPending then
			for id in pairs(removalPending) do
				utility[id] = nil;
			end
		end
	end

	-- Cleaning out old settings
	local variables = db.Variables;
	local function isDeprecated(variable)
		if variable == 'tutorialProgress'
			or variable == 'type' -- retain for binding translation
			or variable:match('^CP_') -- retain modifier setup for binding translation
			or variable:match('^keyboard')
			then return false end
		return variables[variable] == nil;
	end

	-- Look for deprecated settings data
	local settings = ConsolePortSettings;
	if not settings then
		self.OnDataLoaded = nil;
		return
	end

	local foundDeprecatedValue;
	local k, v = next(settings)
	while k do
		if isDeprecated(k) then
			--CPAPI.Log('Removing deprecated variable |cFFFFFFFF%s|r...', k)
			foundDeprecatedValue = true;
			settings[k] = nil;
			k, v = next(settings)
		else
			k, v = next(settings, k)
		end
	end

	if foundDeprecatedValue then
		CPAPI.Log('Upgrade from ConsolePort Legacy completed.')
		CPAPI.Popup('ConsolePort_Upgrade_Complete', {
			text = UPGRADE_TEXT;
			button1 = OKAY;
			button2 = CANCEL;
			timeout = 0;
			whileDead = 1;
			hasEditBox = 1;
			fullScreenCover = 1;
			OnShow = function(self)
				self.editBox:SetText('https://discord.gg/AWeHd48')
			end;
		})
	end

	UPGRADE_TEXT = nil;
	self.OnDataLoaded = nil;
end

function UpgradeHandler:UPDATE_BINDINGS()
	if self.mutexLocked then return end
	if not ConsolePortBindingSet or not ConsolePortSettings then
		self:UnregisterEvent('UPDATE_BINDINGS')
		self.UPDATE_BINDINGS = nil;
		return
	end

	local settings = ConsolePortSettings;
	local type = settings.type;
	local spec = GetSpecialization();
	local bindings = ConsolePortBindingSet[spec] or select(2, next(ConsolePortBindingSet));

	if bindings then self.mutexLocked = true;
		local DEFAULT_BINDINGS, ACCOUNT_BINDINGS, CHARACTER_BINDINGS = 0, 1, 2;
		local conversionTable = {
			CP_L_UP     = 'PADDUP';
			CP_L_DOWN   = 'PADDDOWN';
			CP_L_LEFT   = 'PADDLEFT';
			CP_L_RIGHT  = 'PADDRIGHT';
			
			CP_R_UP     = 'PAD4';
			CP_R_DOWN   = 'PAD1';
			CP_R_LEFT   = 'PAD3';
			CP_R_RIGHT  = 'PAD2';

			CP_X_LEFT   = type == 'PS4' and 'PADSOCIAL' or 'PADBACK';
			CP_X_RIGHT  = 'PADFORWARD';
			CP_X_CENTER = 'PADSYSTEM';

			CP_T_R3     = 'PADRSTICK';
			CP_T_L3     = 'PADLSTICK';

			CP_TL1      = 'PADLSHOULDER';
			CP_TL2      = 'PADLTRIGGER';

			CP_TR1      = 'PADRSHOULDER';
			CP_TR2      = 'PADRTRIGGER';
		};

		
		-- convert non-modifiers
		if settings.CP_T1 then conversionTable.CP_T1 = conversionTable[settings.CP_T1] end
		if settings.CP_T2 then conversionTable.CP_T2 = conversionTable[settings.CP_T2] end

		-- force load character-specific bindings
		LoadBindings(CHARACTER_BINDINGS)
		-- convert the current binding set
		local failedConversions = {};
		for key, set in pairs(bindings) do
			local buttonID = conversionTable[key]
			if buttonID then
				for mod, binding in pairs(set) do
					SetBinding(mod..buttonID, binding)
				end
			else
				tinsert(failedConversions, key:gsub('CP_', ''))
			end
		end
		SaveBindings(CHARACTER_BINDINGS)
		ConsolePortBindingSet = nil;
		if #failedConversions < 1 then
			CPAPI.Log('Imported legacy gamepad bindings successfully.')
		else
			CPAPI.Log('Import of legacy gamepad bindings completed. The following buttons could not be converted:')
			CPAPI.Log(table.concat(failedConversions, ', '))
		end
		self.mutexLocked = false;
	end
end