local _, db = ...
local KEY = db.KEY
local GameMenuControllerButton = CreateFrame("BUTTON", "GameMenuButtonController", GameMenuFrame, "GameMenuButtonTemplate")
GameMenuControllerButton:SetText("Controller")
GameMenuControllerButton:SetScript("OnClick", function(self)
	ToggleFrame(GameMenuFrame)
	-- Need to call it twice
	InterfaceOptionsFrame_OpenToCategory(db.Binds)
	InterfaceOptionsFrame_OpenToCategory(db.Binds)
end)

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

for i, button in pairs(buttons) do
	button:SetSize(167, 21)
end

local function AddCustomMenuButtons()
	-- Wrapper functions that are not predefined
	local function ToggleGarrisonReport()
		if GarrisonLandingPageMinimapButton:IsShown() then
			GarrisonLandingPage_Toggle()
		end
	end
	local function ToggleTalentUI()
		if not PlayerTalentFrame then
			LoadAddOn("Blizzard_TalentUI")
		end
		ShowUIPanel(PlayerTalentFrame)
	end
	local prefix = "Interface\\Buttons\\UI-MicroButton"
	local customButtons = {
		{name = "Character", 	icon = "Character", 	title = "Character Info", 	ClickFunc = ToggleCharacter, 	arg = "PaperDollFrame"},
		{name = "Spellbook", 	icon = "Spellbook", 	title = "Spellbook", 		ClickFunc = ToggleFrame, 		arg = SpellBookFrame},
		{name = "Talent", 		icon = "Talents", 		title = "Specialization", 	ClickFunc = ToggleTalentUI				},
		{name = "Achievement", 	icon = "Achievement", 	title = "Achievements", 	ClickFunc = ToggleAchievementFrame		},
		{name = "QuestLog", 	icon = "Quest", 		title = "Quest Log", 		ClickFunc = ToggleQuestLog				},
		{name = "LFD", 			icon = "LFG", 			title = "Group Finder",	 	ClickFunc = PVEFrame_ToggleFrame		},
		{name = "PvP", 			icon = "Raid", 			title = "PvP",	 			ClickFunc = TogglePVPUI					},
		{name = "Collections", 	icon = "Mounts", 		title = "Collections", 		ClickFunc = ToggleCollectionsJournal	},
		{name = "EJ", 			icon = "EJ", 			title = "Adventure Guide", 	ClickFunc = ToggleEncounterJournal		},
		{name = "Social", 		icon = "World",			title = "Social", 			ClickFunc = ToggleFriendsFrame			},
		{name = "Guild", 		icon = "Socials", 		title = "Guild", 			ClickFunc = ToggleGuildFrame			},
		{name = "Garrison", 	icon = "Abilities", 	title = "Garrison Report", 	ClickFunc = ToggleGarrisonReport		},
	}
	for i, btn in pairs(customButtons) do
		local button = CreateFrame("BUTTON", "GameMenuButton"..btn.name, GameMenuFrame)
		button:SetSize(28, 58)
		button.tooltipText = btn.title
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		if i == 1 then
			button:SetNormalTexture(prefix.."Character-Up")
			button:SetPushedTexture(prefix.."Character-Down")
			button:SetHighlightTexture(prefix.."-Hilight")
			button.Portrait = button:CreateTexture(nil, "OVERLAY")
			button.Portrait:SetSize(18, 25)
			button.Portrait:SetPoint("TOP", button, 0, -28)
			button.Portrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
			SetPortraitTexture(button.Portrait, "player")
			button:RegisterEvent("UNIT_PORTRAIT_UPDATE")
			button:RegisterEvent("PLAYER_ENTERING_WORLD")
			button:SetScript("OnEvent", function(self, event, ...)
				SetPortraitTexture(self.Portrait, "player")
			end)
		else
			button:SetNormalTexture(prefix.."-"..btn.icon.."-Up")
			button:SetPushedTexture(prefix.."-"..btn.icon.."-Down")
			button:SetDisabledTexture(prefix.."-"..btn.icon.."-Disabled")
			button:SetHighlightTexture(prefix.."-Hilight")
		end
		button:SetScript("OnEnter", function(self)
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:AddLine(self.tooltipText)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self)
			if GameTooltip:GetOwner() == self then
				GameTooltip:Hide()
			end
		end)

		local anchor = customButtons[i-1] and customButtons[i-1].name or nil
		if anchor then button:SetPoint("LEFT", _G["GameMenuButton"..anchor], "RIGHT", 0, 0)
		else button:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 16, 4) end

		button:SetScript("OnClick", function(...)
			ToggleFrame(GameMenuFrame)
			btn.ClickFunc(btn.arg)
		end)
		tinsert(buttons, button)
	end
end

local OnLoad = true
GameMenuFrame:HookScript("OnShow", function(self)
	if OnLoad then
		AddCustomMenuButtons()
		OnLoad = false
	end
	GameMenuFrame:SetSize(368, 250);
	GameMenuFrameHeader:SetPoint("TOP", 0, -56)
	GameMenuButtonHelp:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 16, -100)
	GameMenuControllerButton:SetPoint("TOPRIGHT", GameMenuFrame, "TOPRIGHT", -16, -100)
	GameMenuButtonOptions:SetPoint("TOP", GameMenuControllerButton, "BOTTOM", 0, -1)
	GameMenuButtonContinue:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -1)
	GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -1)
end)