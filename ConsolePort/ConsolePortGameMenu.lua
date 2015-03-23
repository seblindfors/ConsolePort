local _
local _, G = ...;
local MenuButton = CreateFrame("BUTTON", "GameMenuButtonController", GameMenuFrame, "GameMenuButtonTemplate");
MenuButton:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -23);
GameMenuButtonOptions:SetPoint("TOP", MenuButton, "BOTTOM", 0, -1);
GameMenuButtonContinue:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -1);
GameMenuButtonHelp:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 20, -20);
MenuButton:SetText("Controller");
MenuButton:SetScript("OnClick", function(self)
	ToggleFrame(GameMenuFrame);
	-- Call twice because of blizzard code bug
	InterfaceOptionsFrame_OpenToCategory(G.binds);
	InterfaceOptionsFrame_OpenToCategory(G.binds);
	MouselookStop();
end);

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
	GameMenuButtonContinue
}

local function AddCustomMenuButtons()
	-- Wrapper functions that are not predefined
	local function ToggleGarrisonReport()
		if GarrisonLandingPageMinimapButton:IsShown() then
			GarrisonLandingPage_Toggle();
		end
	end
	local function ToggleTalentUI()
		if not PlayerTalentFrame then
			LoadAddOn("Blizzard_TalentUI");
		end
		ShowUIPanel(PlayerTalentFrame);
	end
	local customButtons = {
		{name = "Character", 	title = "Character Info", 	ClickFunc = ToggleCharacter, 			arg = "PaperDollFrame"},
		{name = "Spellbook", 	title = "Spellbook", 		ClickFunc = ToggleFrame, 				arg = SpellBookFrame},
		{name = "Talent", 		title = "Specialization", 	ClickFunc = ToggleTalentUI, 			arg = nil},
		{name = "Bag",			title = "Bags",				ClickFunc = ToggleAllBags,				arg = nil},
		{name = "Achievement", 	title = "Achievements", 	ClickFunc = ToggleAchievementFrame, 	arg = nil},
		{name = "QuestLog", 	title = "Quest Log", 		ClickFunc = ToggleQuestLog, 			arg = nil},
		{name = "LFD", 			title = "Group Finder",	 	ClickFunc = PVEFrame_ToggleFrame, 		arg = nil},
		{name = "PvP", 			title = "PvP",	 			ClickFunc = TogglePVPUI, 				arg = nil},
		{name = "Collections", 	title = "Collections", 		ClickFunc = ToggleCollectionsJournal, 	arg = nil},
		{name = "EJ", 			title = "Dungeon Journal", 	ClickFunc = ToggleEncounterJournal, 	arg = nil},
		{name = "Garrison", 	title = "Garrison Report", 	ClickFunc = ToggleGarrisonReport, 		arg = nil},
		{name = "Score", 		title = "Score Screen", 	ClickFunc = ToggleWorldStateScoreFrame, arg = nil},
		{name = "Social", 		title = "Social", 			ClickFunc = ToggleFriendsFrame, 		arg = nil},
		{name = "Guild", 		title = "Guild", 			ClickFunc = ToggleGuildFrame, 			arg = nil},
	}
	for i, btn in pairs(customButtons) do
		local button = CreateFrame("BUTTON", "GameMenuButton"..btn.name, GameMenuFrame, "GameMenuButtonTemplate");
		local anchor = customButtons[i-1] and customButtons[i-1].name or nil;
		button:SetText(btn.title);
		if anchor then
			button:SetPoint("TOP", _G["GameMenuButton"..anchor], "BOTTOM", 0, -1);
		else
			button:SetPoint("TOPRIGHT", GameMenuFrame, "TOPRIGHT", -20, -20);
		end
		button:SetScript("OnClick", function(...)
			ToggleFrame(GameMenuFrame);
			btn.ClickFunc(btn.arg);
		end);
		tinsert(buttons, button);
	end
end

local function CreateControllerInstructions()
	local eol = ":24:24:0:0|t";
	local shiftTexture = "|T"..G["TEXTURE_LONE"]..eol;
	local ctrlTexture = "|T"..G["TEXTURE_LTWO"]..eol;
	local type, offsets = ConsolePortSettings.type, {};
	if type == "Xbox" then
		offsets = {
			{462,-116},{490,-90},{518,-116}, -- Right abilities
			{308,-180},{334,-160},{358,-180},{334,-200}, -- D-pad
			{490,-63},{490,-37}, -- Triggers
			{490,-144},{362,-116},{386,-70},{418,-116} -- Option buttons
		}
	else
		offsets = {
			{488,-118},{518,-86},{550,-118}, -- Right abilities
			{229,-118},{254,-95},{276,-118},{254,-140}, -- D-pad
			{518,-60},{518,-34}, -- Triggers
			{518,-148},{300,-80},{386,-176},{470,-80} -- Option buttons
		}
	end
	local bindings = ConsolePort:GetBindingNames();
	local buttons = {};
	for i, binding in pairs(bindings) do
		local xoffset, yoffset = offsets[i][1], offsets[i][2];
		local f = CreateFrame("FRAME", binding.."_INSTRUCTION", GameMenuFrame);
		local texture;
		if binding == "CP_TR1" then 
			texture = G["TEXTURE_RONE"];
		elseif binding == "CP_TR2" then
			texture = G["TEXTURE_RTWO"];
		else
			texture = G["TEXTURE_"..string.upper(G["NAME_"..binding])];
		end
		local bindTexture = "|T"..texture..eol;
		f:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", xoffset, yoffset);
		f:SetSize(30,30);
		f:Show();
		local bindings = {
			{ref = _G[binding.."_NOMOD_CONF"],	text = nil, alpha = 1, icon = bindTexture},
			{ref = _G[binding.."_SHIFT_CONF"],	text = nil, alpha = 1, icon = shiftTexture..bindTexture},
			{ref = _G[binding.."_CTRL_CONF"],	text = nil, alpha = 1, icon = ctrlTexture..bindTexture},
			{ref = _G[binding.."_CTRLSH_CONF"], text = nil, alpha = 1, icon = shiftTexture..ctrlTexture..bindTexture}
		}
		f:SetScript("OnEnter", function(self)
			for i, binding in pairs(bindings) do
				binding.ref.OnShow(binding.ref);
				if binding.ref.background and binding.ref.background.texture:GetTexture() then
					if binding.ref.secure and binding.ref.secure.action and binding.ref.secure.action then
						ActionButton_ShowOverlayGlow(binding.ref.secure.action);
					end
					bindings[i].text = "|T"..binding.ref.background.texture:GetTexture()..eol;
				elseif binding.ref.background then
					bindings[i].alpha = 0.25;
					bindings[i].text = "N/A";
				else
					bindings[i].text = binding.ref:GetText();
				end
			end
			GameTooltip:Hide();
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
			GameTooltip:AddLine("Bindings");
			for i, binding in pairs(bindings) do
				GameTooltip:AddDoubleLine(binding.icon, binding.text, 1,1,1,binding.alpha,binding.alpha,binding.alpha);
			end
			GameTooltip:Show();
		end);
		f:SetScript("OnLeave", function(self)
			for i, binding in pairs(bindings) do
				if binding.ref.secure and binding.ref.secure.action then
					ActionButton_HideOverlayGlow(binding.ref.secure.action);
				end
			end
			if GameTooltip:GetOwner() and GameTooltip:GetOwner() == self then
				GameTooltip:Hide();
			end
		end);
	end
end

local OnLoad = true;
GameMenuFrame:HookScript("OnShow", function(self)
	if OnLoad then
		AddCustomMenuButtons();
		CreateControllerInstructions();
		OnLoad = false;
	end
	GameMenuFrame:SetSize(800, 350);
	GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -23);
end);

local iterator 		= 1;
local NUM_BTNS		= 26;
local STANDARD 		= 12;
local CUSTOM 		= 13;
function ConsolePort:Menu (key, state)
	if key == G.PREPARE then
		iterator = 1;
	elseif 	key == G.CIRCLE then
		ConsolePort:Button(buttons[iterator], state);
		return;
	elseif	key == G.TRIANGLE and state == G.STATE_UP and GameMenuFrame:IsVisible() then
		ToggleFrame(GameMenuFrame);
		return;
	end
	if state == G.STATE_DOWN then
		if 			key == G.UP then
			if iterator == 1 then
				iterator = STANDARD;
			elseif iterator == CUSTOM then
				iterator = NUM_BTNS;
			else
				iterator = iterator - 1;
			end
		elseif 		key == G.DOWN then
			if iterator == STANDARD then
				iterator = 1;
			elseif iterator == NUM_BTNS then
				iterator = CUSTOM;
			else
				iterator = iterator + 1;
			end
		elseif 		key == G.LEFT then
			if iterator > STANDARD then
				if iterator > 22 then
					iterator = iterator - 14;
				elseif iterator > 15 then
					iterator = iterator - 13;
				else
					iterator = iterator - 12;
				end
			end
		elseif 		key == G.RIGHT then
			if iterator < CUSTOM then
				if iterator > 9 then
					iterator = iterator + 14;
				elseif iterator > 3 then
					iterator = iterator + 13;
				else
					iterator = iterator + 12;
				end
			end
		end
	end
	for _, button in pairs(buttons) do
		button:UnlockHighlight();
		button:GetScript("OnLeave")(button);
	end
	buttons[iterator]:LockHighlight();
	buttons[iterator]:GetScript("OnEnter")(buttons[iterator]);
end
