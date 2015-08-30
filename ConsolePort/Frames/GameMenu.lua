local _, db = ...;
local KEY = db.KEY;
local MenuButton = CreateFrame("BUTTON", "GameMenuButtonController", GameMenuFrame, "GameMenuButtonTemplate");
MenuButton:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -23);
GameMenuButtonOptions:SetPoint("TOP", MenuButton, "BOTTOM", 0, -1);
GameMenuButtonContinue:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -1);
GameMenuButtonHelp:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 20, -24);
MenuButton:SetText("Controller");
MenuButton:SetScript("OnClick", function(self)
	ToggleFrame(GameMenuFrame);
	-- Call twice because of blizzard code bug
	InterfaceOptionsFrame_OpenToCategory(db.Binds);
	InterfaceOptionsFrame_OpenToCategory(db.Binds);
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
			button:SetPoint("TOPRIGHT", GameMenuFrame, "TOPRIGHT", -20, -24);
		end
		button:SetScript("OnClick", function(...)
			ToggleFrame(GameMenuFrame);
			btn.ClickFunc(btn.arg);
		end);
		tinsert(buttons, button);
	end
end

local OnLoad = true;
GameMenuFrame:HookScript("OnShow", function(self)
	if OnLoad then
		AddCustomMenuButtons();
		OnLoad = false;
	end
	GameMenuFrame:SetSize(335, 350);
	GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -23);
end);