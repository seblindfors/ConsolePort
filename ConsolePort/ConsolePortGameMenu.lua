local _
local _, G = ...;
local MenuButton = CreateFrame("BUTTON", "GameMenuButtonController", GameMenuFrame, "GameMenuButtonTemplate");
MenuButton:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -10);
GameMenuButtonOptions:SetPoint("TOP", MenuButton, "BOTTOM", 0, -1);
GameMenuButtonContinue:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -1);
MenuButton:SetText("Controller");
MenuButton:SetScript("OnClick", function(self)
	ToggleGameMenu();
	-- Call twice because of blizzard code bug
	InterfaceOptionsFrame_OpenToCategory(G.binds);
	InterfaceOptionsFrame_OpenToCategory(G.binds);
	MouselookStop();
end);

local TOGGLE 		= false;
local iterator 		= 1;

local GAME_MENU 	= 12;
local UTIL_MENU 	= 13;
local NUM_BTNS		= 23;
local buttons 		= {
	GameMenuButtonHelp,
	GameMenuButtonStore,
	GameMenuButtonWhatsNew,
	GameMenuButtonController,
	GameMenuButtonOptions,
	GameMenuButtonUIOptions,
	GameMenuButtonKeybindings,
	GameMenuButtonMacros,
	GameMenuButtonAddons,
	GameMenuButtonLogout,
	GameMenuButtonQuit,
	GameMenuButtonContinue,
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	GuildMicroButton,
	LFDMicroButton,
	CollectionsMicroButton,
	EJMicroButton,
	StoreMicroButton,
	MainMenuMicroButton
}

for _, button in ipairs(buttons) do
	button:HookScript("OnClick", function(self, button, down)
		if not down and not InCombatLockdown() then
			CP_R_RIGHT_NOMOD:SetAttribute("clickbutton", CP_R_RIGHT_NOMOD.action);
		end
	end);
end

function ConsolePort:Menu (key, state)
	if key == G.PREPARE then
		iterator = 1;
	elseif 	key == G.CIRCLE then
		if iterator > GAME_MENU and state == G.STATE_DOWN then
			ToggleFrame(GameMenuFrame);
			buttons[iterator]:UnlockHighlight();
			if not InCombatLockdown() then
				CP_R_RIGHT_NOMOD:SetAttribute("clickbutton", buttons[iterator]);
			end
		else
			ConsolePort:Button(buttons[iterator], state);
		end
		return;
	elseif	key == G.TRIANGLE and state == G.STATE_UP and GameMenuFrame:IsVisible() then
		ToggleFrame(GameMenuFrame);
		return;
	end
	if state == G.STATE_DOWN then
		if 			key == G.UP then
			if 		iterator > GAME_MENU or iterator == 1 	then iterator = GAME_MENU;
			else 	iterator = iterator - 1; end;
		elseif 		key == G.DOWN then
			if 		iterator > GAME_MENU or iterator == GAME_MENU then iterator = 1;
			else 	iterator = iterator + 1; end;
		elseif 		key == G.LEFT then
			if 		iterator < UTIL_MENU 	then iterator = NUM_BTNS;
			elseif 	iterator == UTIL_MENU 	then iterator = NUM_BTNS;
			else 	iterator = iterator - 1; end;
		elseif 		key == G.RIGHT then
			if 		iterator < UTIL_MENU then iterator = UTIL_MENU;
			elseif 	iterator == NUM_BTNS then iterator = UTIL_MENU;
			else 	iterator = iterator + 1; end;
		end
	end
	for _, button in pairs(buttons) do
		button:UnlockHighlight();
		button:GetScript("OnLeave")(button);
	end
	buttons[iterator]:LockHighlight();
	buttons[iterator]:GetScript("OnEnter")(buttons[iterator]);
end