local addOn, db = ...

function ConsolePort:CreateSlashHandler()
	local SLASH = db.TUTORIAL.SLASH
	local editBox = ScriptErrorsFrame.ScrollFrame.Text


	function editBox:AddMessage(msg) self:Insert((msg or '') .. '\n') end
	local function PrintEditbox(msg) editBox:AddMessage(msg) end

	local function PrepareEditbox()
		editBox:SetText('')
		editBox:SetMaxLetters(0)
		ScriptErrorsFrame:Show()
	end


	local function PrintHeader(msg, inEditBox)
		local output = ([[|TInterface\AddOns\ConsolePort\Textures\Logos\CP:24:24:0:0|t |cffffe00aConsolePort|r: ]] .. ( msg or '' ) )
		if inEditBox then
			PrintEditbox(output)
		else
			print(output)
		end
	end


	local function ShowSplash(controller)
		controller = controller and strupper(controller)
		if db.Controllers[controller] then
			db('type', controller)

			for k, v in pairs(db.Controllers[controller].Settings) do
				db(k, v)
			end

			-- Store this flag to run settings check after reload
			db('newController', true)
			db('forceController', controller)

			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD)
			ReloadUI()
		else
			ConsolePort:SelectController()
		end
	end


	local function ShowActionBarPopup()
		if ConsolePortBar then
			if InCombatLockdown() then
				print('|cffffe00aConsolePort|r:', SLASH.COMBAT)
			else
				ConsolePortBar:ShowLayoutPopup()
			end
		else
			print(SLASH.ACTIONBAR_NOEXISTS)
		end
	end


	local function ShowCalibration() 
		if ConsolePortOldConfig:IsVisible() then
			ConsolePortOldConfig:Hide()
		end
		ConsolePort:CalibrateController(true)
	end


	local function PrintCVar(cvar, original, desc, inEditBox)
		local description = desc or '|cFF757575<none>|r'
		local valToString = tostring(original) or '|cFF757575undefined|r'
		local outputString = (valToString:len() == 0 and '|cFF757575<empty string>|r') or valToString
		local printout = format(SLASH.CVAR_PRINTOUT, cvar, outputString, description)
		if inEditBox then
			PrintEditbox(printout)
		else
			print(printout)
		end
	end


	local function PrintCVars()
		local cvars = ConsolePort:GetCompleteCVarList()
		PrepareEditbox()
		PrintHeader(SLASH.CVAR_PRINTING, true)
		PrintEditbox()
		for k, v in db.table.spairs(cvars) do
			PrintCVar(format('/cp %s |cFF757575<%s>|r', k, type(v[1])), v[1], v[2], true)
			PrintEditbox()
		end
		PrintEditbox(SLASH.CVAR_WARNING)
	end


	local function SetControllerCVar(cvar, value)
		local entry = ConsolePort:GetCompleteCVarList()[cvar]
		local original = entry and entry[1]
		if original ~= nil then
			if value == 'true' then value = true
			elseif value == 'false' then value = false
			elseif tonumber(value) then value = tonumber(value)
			end
			if value == 'nil' then
				db.Settings[cvar] = nil
				PrintHeader()
				print(format(SLASH.CVAR_APPLIED, cvar, 'nullified'))
				print(SLASH.CVAR_WARNING_NULL)
			elseif value == nil then
				PrintHeader()
				PrintCVar(cvar, original, entry[2])
			elseif type(original) ~= type(value) then
				PrintHeader()
				print(format(SLASH.CVAR_MISMATCH, cvar, type(original)))
			else
				db.Settings[cvar] = value
				PrintHeader()
				print(format(SLASH.CVAR_APPLIED, cvar, tostring(value)))
			end
		else
			PrintHeader()
			print(format(SLASH.CVAR_NOEXISTS, cvar or '<empty>'))
		end
	end


	local function Debug(includeMarkdown)
		local loaded, reason = LoadAddOn('Blizzard_DebugTools')
		if not loaded then
			message(format(ADDON_LOAD_FAILED, name, _G['ADDON_'..reason]))
			return
		end

		-- upvalue globals to modify
		local backupChatFrame = DEFAULT_CHAT_FRAME
		local backupCutoff = DEVTOOLS_MAX_ENTRY_CUTOFF

		-- (1) temporarily set chat frame to the editbox for print output
		-- (2) increase max entry cutoff to ensure everything is printed
		DEFAULT_CHAT_FRAME = editBox
		DEVTOOLS_MAX_ENTRY_CUTOFF = 300

		-- prepare editbox
		PrepareEditbox()
		PrintHeader(SLASH.DEBUG_HEADER, true)

		local discordOutput = includeMarkdown and includeMarkdown:lower():match('discord')
		local markdownMarker = ('```')

		if discordOutput then
			editBox:Insert(markdownMarker)
		end

		-- necessary table functions
		local copy, spairs = db.table.copy, db.table.spairs
		local function __tpop(t, key)
			if type(t) == 'table' and key ~= nil then
				local pop = copy(t[key])
				t[key] = nil
				return pop
			end
		end

		local settings = copy(db.Settings)
		local mouse = copy(db.Mouse)
		for header, data in db.table.spairs({
			['Build info'] = {
				GetAddOnMetadata(addOn, 'Version');
				GetBuildInfo();
			}; 
			['Calibration'] = __tpop(settings, 'calibration');
			['Controller'] 	= {
				['Type'] 	= __tpop(settings, 'type');
				['Force'] 	= __tpop(settings, 'forceController'); 
				['GuideFix']= __tpop(settings, 'skipGuideBtn'); 
			};
			['Loadout']		= (not discordOutput) and copy(db.Bindings) or nil;
			['Mouse'] 		= {
				['Camera'] 	= __tpop(mouse, 'Camera');
				['Cursor'] 	= __tpop(mouse, 'Cursor');
			};
			['Modifiers'] 	= {
				['CP_M1']	= __tpop(settings, 'CP_M1');
				['CP_M2']	= __tpop(settings, 'CP_M2');
				['CP_T1']	= __tpop(settings, 'CP_T1');
				['CP_T2']	= __tpop(settings, 'CP_T2');
				['CP_T3']	= __tpop(settings, 'CP_T3');
				['CP_T4']	= __tpop(settings, 'CP_T4');
			};
			['Settings'] 	= settings;
		}) do
			editBox:AddMessage(('\n|cffffe00a%s:|r'):format(header))
			DevTools_Dump(data)
		end

		if discordOutput then
			editBox:AddMessage(markdownMarker)
		end

		-- restore
		DEFAULT_CHAT_FRAME = backupChatFrame
		DEVTOOLS_MAX_ENTRY_CUTOFF = backupCutoff
	end


	local function ResetAll()
		if not InCombatLockdown() then
			ConsolePortBindingSet = nil
			ConsolePortUIFrames = nil
			ConsolePortSettings = nil
			ConsolePortUtility = nil
			ConsolePortMouse = nil
			ConsolePortUIConfig = nil
			ConsolePortBarSetup = nil
			ReloadUI()
		else
			print('|cffffe00aConsolePort|r:', SLASH.COMBAT)
		end
	end


	local function ShowHelp() ConsolePortOldConfig:OpenCategory(HELP_LABEL) end
	local function ShowBinds() ConsolePortOldConfig:OpenCategory(2) end
	local function ShowConfig() ConsolePortOldConfig:Show() end


	local instructions = {
		['actionbar'] = {	
			desc = SLASH.ACTIONBAR_SHOW;
			func = ShowActionBarPopup };
		['debug'] = {
			desc = SLASH.DEBUG_OUTPUT; 
			func = Debug };
		['binds'] = {
			desc = SLASH.BINDS;
			func = ShowBinds };
		['config'] = {
			desc = SLASH.CONFIG;
			func = ShowConfig };
		['cvar'] = {
			desc = SLASH.CVARLIST;
			func = PrintCVars };
		['help'] = {
			desc = HELP_LABEL .. ' & ' .. SHOW_TUTORIALS;
			func = ShowHelp };
		['recalibrate'] = {
			desc = SLASH.RECALIBRATE; 
			func = ShowCalibration };
		['resetall'] = {
			desc = SLASH.RESET; 
			func = ResetAll };
		['type'] = {
			desc = SLASH.TYPE;
			func = ShowSplash };
	}


	SLASH_CONSOLEPORT1, SLASH_CONSOLEPORT2 = '/cp', '/consoleport'
	SlashCmdList['CONSOLEPORT'] = function(msg)
		local inputs = {}
		local cvars = ConsolePort:GetCompleteCVarList()
		if type(msg) == 'string' then
			for word in msg:gmatch('%S+') do
				inputs[#inputs + 1] = word
			end
		end
		local funcName = inputs[1]
		if funcName and instructions[funcName] then
			tremove(inputs, 1)
			instructions[funcName].func(unpack(inputs))
		elseif funcName and cvars[funcName] ~= nil then
			SetControllerCVar(unpack(inputs))
		else
			PrintHeader()
			for k, v in db.table.spairs(instructions) do
				print(format('|cff69ccf0/cp %s|r: %s', k, v.desc))
			end
		end
	end

	self.CreateSlashHandler = nil
end