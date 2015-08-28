local _, db = ...;
local KEY = db.KEY;
local MenuButton = CreateFrame("BUTTON", "GameMenuButtonController", GameMenuFrame, "GameMenuButtonTemplate");
MenuButton:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -23);
GameMenuButtonOptions:SetPoint("TOP", MenuButton, "BOTTOM", 0, -1);
GameMenuButtonContinue:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -1);
GameMenuButtonHelp:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 20, -20);
MenuButton:SetText("Controller");
MenuButton:SetScript("OnClick", function(self)
	ToggleFrame(GameMenuFrame);
	-- Call twice because of blizzard code bug
	InterfaceOptionsFrame_OpenToCategory(db.Binds);
	InterfaceOptionsFrame_OpenToCategory(db.Binds);
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
		{name = "Character", 	title = "Character Info", 	ClickFunc = ToggleCharacter, 	arg = "PaperDollFrame"},
		{name = "Spellbook", 	title = "Spellbook", 		ClickFunc = ToggleFrame, 		arg = SpellBookFrame},
		{name = "Talent", 		title = "Specialization", 	ClickFunc = ToggleTalentUI				},
		{name = "Bag",			title = "Bags",				ClickFunc = ToggleAllBags				},
		{name = "Achievement", 	title = "Achievements", 	ClickFunc = ToggleAchievementFrame		},
		{name = "QuestLog", 	title = "Quest Log", 		ClickFunc = ToggleQuestLog				},
		{name = "LFD", 			title = "Group Finder",	 	ClickFunc = PVEFrame_ToggleFrame		},
		{name = "PvP", 			title = "PvP",	 			ClickFunc = TogglePVPUI					},
		{name = "Collections", 	title = "Collections", 		ClickFunc = ToggleCollectionsJournal	},
		{name = "EJ", 			title = "Dungeon Journal", 	ClickFunc = ToggleEncounterJournal		},
		{name = "Garrison", 	title = "Garrison Report", 	ClickFunc = ToggleGarrisonReport		},
		{name = "Score", 		title = "Score Screen", 	ClickFunc = ToggleWorldStateScoreFrame	},
		{name = "Social", 		title = "Social", 			ClickFunc = ToggleFriendsFrame			},
		{name = "Guild", 		title = "Guild", 			ClickFunc = ToggleGuildFrame			},
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
	local shiftTexture = "|T"..db.TEXTURE.LONE..eol;
	local ctrlTexture = "|T"..db.TEXTURE.LTWO..eol;
	local type, offsets = ConsolePortSettings.type, {};
	if type == "Xbox" then
		offsets = {
			{462,-116},{490,-90},{518,-116}, 				-- Right abilities
			{308,-180},{334,-160},{358,-180},{334,-200}, 	-- D-pad
			{490,-63},{490,-37}, 							-- Triggers
			{490,-144},{362,-116},{386,-70},{418,-116} 		-- Option buttons
		}
	else
		offsets = {
			{488,-118},{518,-86},{550,-118}, 				-- Right abilities
			{229,-118},{254,-95},{276,-118},{254,-140},		-- D-pad
			{518,-60},{518,-34},							-- Triggers
			{518,-148},{300,-80},{386,-176},{470,-80}		-- Option buttons
		}
	end
	local bindings = ConsolePort:GetBindingNames();
	local buttons = {};
	for i, binding in pairs(bindings) do
		local xoffset, yoffset = offsets[i][1], offsets[i][2];
		local f = CreateFrame("FRAME", binding.."_INSTRUCTION", GameMenuFrame);
		local texture;
		if binding == "CP_TR1" then 
			texture = db.TEXTURE.RONE;
		elseif binding == "CP_TR2" then
			texture = db.TEXTURE.RTWO;
		else
			texture = db.TEXTURE[strupper(db.NAME[binding])];
		end
		local bindTexture = "|T"..texture..eol;
		f.timer = {0,0,0,0};
		f:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", xoffset, yoffset);
		f:SetSize(30,30);
		f:Show();
		local bindings = {
			{ref = _G[binding.."_NOMOD_CONF"],	alpha = 1, icon = bindTexture},
			{ref = _G[binding.."_SHIFT_CONF"],	alpha = 1, icon = shiftTexture..bindTexture},
			{ref = _G[binding.."_CTRL_CONF"],	alpha = 1, icon = ctrlTexture..bindTexture},
			{ref = _G[binding.."_CTRLSH_CONF"],	alpha = 1, icon = shiftTexture..ctrlTexture..bindTexture}
		}
		f:SetScript("OnEnter", function(self)
			for i, binding in pairs(bindings) do
				binding.ref.OnShow(binding.ref);
				if binding.ref.background and binding.ref.background.texture:GetTexture() then
					if binding.ref.secure and binding.ref.secure.action and binding.ref.secure.action then
						self.timer[i] = 0;
						self:HookScript("OnUpdate", function(self, elapsed)
							self.timer[i] = self.timer[i] + elapsed;
							if self.timer[i] > 0.5 and self.timer[i] < 1 then
							--	ActionButton_ShowOverlayGlow(binding.ref.secure.action);
								self.timer[i] = 1;
							end
						end);
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
				GameTooltip:AddDoubleLine(
					binding.icon,
					binding.text,
					1,1,1,
					binding.alpha,
					binding.alpha,
					binding.alpha);
			end
			GameTooltip:Show();
		end);
		f:SetScript("OnLeave", function(self)
			self:SetScript("OnUpdate", nil);
			for i, binding in pairs(bindings) do
				if binding.ref.secure and binding.ref.secure.action then
				--	ActionButton_HideOverlayGlow(binding.ref.secure.action);
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
	if key == KEY.PREPARE then
		iterator = 1;
	elseif 	key == KEY.CIRCLE then
		ConsolePort:Button(buttons[iterator], state);
		return;
	elseif	key == KEY.TRIANGLE and state == KEY.STATE_UP and GameMenuFrame:IsVisible() then
		ToggleFrame(GameMenuFrame);
		return;
	end
	if state == KEY.STATE_DOWN then
		if 			key == KEY.UP then
			if iterator == 1 then
				iterator = STANDARD;
			elseif iterator == CUSTOM then
				iterator = NUM_BTNS;
			else
				iterator = iterator - 1;
			end
		elseif 		key == KEY.DOWN then
			if iterator == STANDARD then
				iterator = 1;
			elseif iterator == NUM_BTNS then
				iterator = CUSTOM;
			else
				iterator = iterator + 1;
			end
		elseif 		key == KEY.LEFT then
			if iterator > STANDARD then
				if iterator > 22 then
					iterator = iterator - 14;
				elseif iterator > 15 then
					iterator = iterator - 13;
				else
					iterator = iterator - 12;
				end
			end
		elseif 		key == KEY.RIGHT then
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
	end
	buttons[iterator]:LockHighlight();
end
