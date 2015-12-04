---------------------------------------------------------------
-- GameMenu.lua: Custom game menu with convenience buttons
---------------------------------------------------------------
-- Customizes the game menu to provide the normal functionality
-- from the action bar menu buttons. This makes it easy to
-- open UI panels, since no mouse is required to click here.

local _, db = ...

local function ConfigureMenu()

	local prefix = "Interface\\Buttons\\UI-MicroButton"
	local secureButtons = {}

	local function PreClick(self)
		ToggleFrame(GameMenuFrame)
	end

	local function OnEnter(self)
		GameTooltip:Hide()
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end

	local function OnLeave(self)
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end
	end

	local microButtons = {
		{icon = "Character", 	microButton = CharacterMicroButton, 		title = CHARACTER_BUTTON},
		{icon = "Spellbook", 	microButton = SpellbookMicroButton, 		title = SPELLBOOK_BUTTON},
		{icon = "Talents", 		microButton = TalentMicroButton, 			title = TALENTS_BUTTON},
		{icon = "Achievement", 	microButton = AchievementMicroButton, 		title = ACHIEVEMENT_BUTTON},
		{icon = "Quest", 		microButton = QuestLogMicroButton, 			title = QUESTLOG_BUTTON},
		{icon = "LFG", 			microButton = LFDMicroButton, 				title = DUNGEONS_BUTTON},
		{icon = "Mounts", 		microButton = CollectionsMicroButton, 		title = COLLECTIONS},
		{icon = "EJ", 			microButton = EJMicroButton, 				title = ADVENTURE_JOURNAL},
		{icon = "World",		microButton = FriendsMicroButton, 			title = SOCIAL_BUTTON},
		{icon = "Socials", 		microButton = GuildMicroButton, 			title = GUILD},
		{icon = "Abilities", 	microButton = GarrisonLandingPageMinimapButton, title = GARRISON_LANDING_PAGE_TITLE},
		{icon = "Help", 		microButton = GameMenuButtonHelp, 			title = GAMEMENU_HELP},
	}

	for i, info in pairs(microButtons) do
		local button = CreateFrame("Button", "GameMenuButton"..info.icon, GameMenuFrame, "SecureActionButtonTemplate")
		button:SetSize(28, 58)
		button.tooltipText = info.title
		button:SetAttribute("type", "click")
		button:SetAttribute("clickbutton", info.microButton)
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("PreClick", PreClick)
		button:SetScript("OnEnter", OnEnter)
		button:SetScript("OnLeave", OnLeave)
		if 	i == 1 then
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
			button:HookScript("OnClick", function(self)
				ToggleCharacter("PaperDollFrame")
			end)
		else
			button:SetNormalTexture(prefix.."-"..info.icon.."-Up")
			button:SetPushedTexture(prefix.."-"..info.icon.."-Down")
			button:SetDisabledTexture(prefix.."-"..info.icon.."-Disabled")
			button:SetHighlightTexture(prefix.."-Hilight")
		end
		if #secureButtons == 6 then
			button:SetPoint("BOTTOM", secureButtons[1], "TOP", 0, -20)
		elseif #secureButtons > 0 then
			button:SetPoint("LEFT", secureButtons[i-1], "RIGHT", 0, 0)
		else
			button:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 14, -46)
		end
		tinsert(secureButtons, button)
	end

	-- Create a shortcut menu button to quickly open the binding manager.
	local GameMenuButtonController = CreateFrame("BUTTON", "GameMenuButtonController", GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButtonController.hasPriority = true
	GameMenuButtonController:SetText(db.TUTORIAL.BIND.MENUHEADER)
	GameMenuButtonController:SetScript("PreClick", PreClick)
	GameMenuButtonController:SetScript("OnClick", function(self)
		ConsolePortConfig:Show()
	end)

	local buttons = {
		GameMenuButtonController,
		GameMenuButtonStore,
		GameMenuButtonWhatsNew,
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

	GameMenuFrame:SetSize(196, 410)
	GameMenuFrame:SetScript("OnShow", nil)
	GameMenuButtonHelp:Hide()
	GameMenuButtonController:SetPoint("CENTER", GameMenuFrame, "TOP", 0, -120)
	GameMenuButtonStore:ClearAllPoints()
	GameMenuButtonStore:SetPoint("TOP", GameMenuButtonController, "BOTTOM", 0, -1)

	local cc = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
	GameMenuFrame:SetBackdrop(db.Atlas.Backdrops.Tooltip)
	GameMenuFrame:SetBackdropColor(cc.r*0.1, cc.g*0.1, cc.b*0.1, 1)

	ConfigureMenu = nil
end

ConfigureMenu()