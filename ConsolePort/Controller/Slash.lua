local _, db = ...;
local HELP_STRING, SLASH_FUNCTIONS = 'Usage: |cFFFFFFFF/consoleport|r |cFF00FFFF%s|r |cFF00FF00%s|r';
local CONFIG_ADDON_NAME = 'ConsolePort_Config';
---------------------------------------------------------------
-- Process slash command
---------------------------------------------------------------
local function ProcessSlash(command, ...)
	local func = SLASH_FUNCTIONS[command];
	if func then
		func(...)
		return true
	end
end

local function ProcessVarUpdate(var, ...)
	if (db(var) ~= nil) then
		local args = table.concat({...}, ' ')
		local func, errorMsg = loadstring(('return %s'):format(args))
		if not func then
			CPAPI.Log('Error while compiling:\n%s', errorMsg)
			return true;
		end
		local value = func()
		if (args == 'nil') then
			db('Settings/'..var, nil)
			CPAPI.Log('Variable |cFFFFFFFF%s|r reset to default.')
			return true;
		elseif value then
			db('Settings/'..var, value)
			CPAPI.Log('Variable |cFFFFFFFF%s|r updated to:', var)
			DevTools_Dump(value)
			return true;
		end
	end
end

local function HandleSlashCommand(self, msg)
	if ProcessSlash((' '):split(msg or '')) then
		return
	elseif ProcessVarUpdate((' '):split(msg or '')) then
		return
	end
	if not IsAddOnLoaded(CONFIG_ADDON_NAME) then
		EnableAddOn(CONFIG_ADDON_NAME)
		LoadAddOn(CONFIG_ADDON_NAME)
	end
	ConsolePortConfig:SetShown(not ConsolePortConfig:IsShown())
end

local function Uninstall()
	for _, var in ipairs({
		-- Saved variables
		'ConsolePortSettings',
		'ConsolePortDevices',
		'ConsolePortUIStack',
		-- Saved variables per character
		'ConsolePortUtility'
	}) do _G[var] = nil; end
	ReloadUI()
end

---------------------------------------------------------------
-- Slash functions
---------------------------------------------------------------
SLASH_FUNCTIONS = {
	addframe = function(owner, frame)
		if owner and frame then
			local loadable, reason = select(4, GetAddOnInfo(owner))
			if loadable then
				local stack = db.Stack;
				if stack:TryRegisterFrame(owner, frame, true) then
					stack:AddFrame(frame)
					stack:UpdateFrames()
					return CPAPI.Log('Frame %s was added under %s.', frame, owner)
				end
			else
				return CPAPI.Log('Addon %s is not eligble. Reason: %s', owner, _G['ADDON_'..reason])
			end
		end
		CPAPI.Log(HELP_STRING, 'addframe', 'addonName frameName')
	end;
	removeframe = function(owner, frame)
		if owner and frame then
			local loadable, reason = select(4, GetAddOnInfo(owner))
			if loadable then
				local stack = db.Stack;
				if stack:TryRemoveFrame(owner, frame) then
					stack:RemoveFrame(_G[frame])
					stack:UpdateFrames()
					return CPAPI.Log('Frame %s was removed from %s.', frame, owner)
				end
			else
				return CPAPI.Log('Addon is not eligble. Reason: %s', reason)
			end
		end
		CPAPI.Log(HELP_STRING, 'removeframe', 'addonName frameName')
	end;
	-- resets the entire addon
	resetall = function()
		CPAPI.Popup('ConsolePort_Uninstall_Settings', {
			text = 'This action will remove all your saved settings and reload your interface.';
			button1 = OKAY;
			button2 = CANCEL;
			timeout = 0;
			whileDead = 1;
			showAlert = 1;
			OnAccept = Uninstall;
		})
	end;
	uninstall = function()
		CPAPI.Popup('ConsolePort_Uninstall_Addon', {
			text = 'This action will remove all your saved settings and reload your interface.';
			button1 = OKAY;
			button2 = CANCEL;
			timeout = 0;
			whileDead = 1;
			showAlert = 1;
			OnAccept = function()
				DisableAddOn('ConsolePort')
				Uninstall()
			end;
		})
	end;
}

---------------------------------------------------------------
-- Set up slash handler
---------------------------------------------------------------
setmetatable(ConsolePort, {
	__index = getmetatable(ConsolePort).__index;
	__call  = HandleSlashCommand;
})

_G['SLASH_' .. _:upper() .. '1'] = '/' .. _:lower()
_G['SLASH_' .. _:upper() .. '2'] = '/cp'
SlashCmdList[_:upper()] = ConsolePort;

---------------------------------------------------------------
-- Temp?: add a game menu button to access config
---------------------------------------------------------------
LibStub('Carpenter'):BuildFrame(GameMenuFrame, {
	[_] = {
		_Type  = 'Button';
		_Setup = 'InsecureActionButtonTemplate';
		_Size  = {58, 58};
		_Point = {'TOP', 0, 70};
		_Macro = '/click GameMenuButtonContinue\n/consoleport';
		_OnLoad = function(self)
			self:SetNormalTexture(CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]))
			self:SetPushedTexture(CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]))
			local pushed = self:GetPushedTexture()
			pushed:ClearAllPoints()
			pushed:SetSize(self:GetSize())
			pushed:SetPoint('CENTER', 0, -2)
			-- Protect against ElvUI shenanigans
			self.SetNormalTexture = nop;
			self.SetPushedTexture = nop;
			self.GetNormalTexture = nop;
			self.GetPushedTexture = nop;
		end;
	};
}, false, true)