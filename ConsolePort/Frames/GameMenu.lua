---------------------------------------------------------------
-- GameMenu.lua: Custom game menu with convenience buttons
---------------------------------------------------------------
-- Customizes the game menu to provide the normal functionality
-- from the action bar menu buttons. This makes it easy to
-- open UI panels, since no mouse is required to click here.

local _, db = ...

local function ConfigureMenu()
	local class = select(2, UnitClass("player"))
	local cc = RAID_CLASS_COLORS[class]
	local prefix = "Interface\\Buttons\\UI-MicroButton"
	local secureButtons = {}

	local function OnEnter(self)
		GameTooltip:Hide()
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
	--	GameTooltip:AddLine(self.tooltipText)
		GameTooltip:SetText(self.tooltipText)
		GameTooltip:Show()
	end

	local function OnLeave(self)
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end
	end

	local function PreClick(self)
		if IsOptionFrameOpen() then
			ToggleFrame(GameMenuFrame)
		end
		self:SetButtonState("NORMAL")
		self:UnlockHighlight()
	end

	local classIcon = [[Interface\ICONS\ClassIcon_]]..class

	local microButtons = {
		{name = "Character", 	icon = [[]], microButton = CharacterMicroButton, title = CHARACTER_BUTTON},
		{name = "Bags",			icon = [[Interface\ICONS\INV_Misc_Bag_29]], title = BACKPACK_TOOLTIP},
		{name = "Quest", 		icon = [[Interface\QUESTFRAME\UI-QuestLog-BookIcon]], microButton = QuestLogMicroButton, title = QUESTLOG_BUTTON},
		{name = "Spellbook", 	icon = [[Interface\Spellbook\Spellbook-Icon]], microButton = SpellbookMicroButton, title = SPELLBOOK_BUTTON},
		{name = "Talents", 		icon = classIcon, microButton = TalentMicroButton, 	title = TALENTS_BUTTON},
		{name = "Achievement", 	icon = [[Interface\ICONS\ACHIEVEMENT_WIN_WINTERGRASP]], microButton = AchievementMicroButton, title = ACHIEVEMENT_BUTTON},
		{name = "Mounts", 		icon = [[Interface\ICONS\MountJournalPortrait]], microButton = CollectionsMicroButton, title = COLLECTIONS},
		{name = "LFG", 			icon = [[Interface\LFGFRAME\UI-LFG-PORTRAIT]], microButton = LFDMicroButton, title = DUNGEONS_BUTTON},
		{name = "EJ", 			icon = [[Interface\ENCOUNTERJOURNAL\UI-EJ-PortraitIcon]], microButton = EJMicroButton, title = ADVENTURE_JOURNAL},
		{name = "World",		icon = [[Interface\FriendsFrame\Battlenet-Portrait]], microButton = FriendsMicroButton, title = SOCIAL_BUTTON},
		{name = "Socials", 		icon = [[Interface\ICONS\Achievement_GuildPerk_EverybodysFriend]], microButton = GuildMicroButton, title = GUILD},
		{name = "Raid",			icon = [[Interface\LFGFRAME\UI-LFR-PORTRAIT]], title = RAID},
	}

	local microContainer = CreateFrame("Frame", "$parentMicroContainer", GameMenuFrame)

	microContainer:SetPoint("TOP", 0, 0)
	microContainer:SetSize(64 * 6, 170)

	for i, info in pairs(microButtons) do
		local button = db.Atlas.GetRoundActionButton("GameMenuButton"..info.name, false, GameMenuFrame)
		button.HotKey = nil
		button.tooltipText = info.title
		button.ignoreMenu = true
		button:SetAttribute("type", "click")
		button:SetAttribute("clickbutton", info.microButton)
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("PreClick", PreClick)
		button:SetScript("OnEnter", OnEnter)
		button:SetScript("OnLeave", OnLeave)
		button:SetScript("OnHide", OnLeave)

		if 	info.name == "Character" then

			button.icon:ClearAllPoints()
			button.icon:SetSize(60, 60)
			button.icon:SetPoint("CENTER", 0, 0)
			SetPortraitTexture(button.icon, "player")
			button:RegisterEvent("UNIT_PORTRAIT_UPDATE")
			button:RegisterEvent("PLAYER_ENTERING_WORLD")
			button:SetScript("OnEvent", function(self, event, ...)
				SetPortraitTexture(self.icon, "player")
			end)
			button:HookScript("OnClick", function(self)
				ToggleCharacter("PaperDollFrame")
			end)

		elseif info.name == "Raid" then

			button.icon:SetTexture(info.icon)
			button:SetScript("OnClick", function(self)
				ToggleRaidFrame()
			end)

		elseif info.name == "Bags" then

			button.icon:SetTexture(info.icon)
			button:RegisterEvent("BAG_UPDATE")
			button:SetScript("OnEvent", function(self, event, ...)
				local totalFree, numSlots, freeSlots, bagFamily = 0, 0
				for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
					freeSlots, bagFamily = GetContainerNumFreeSlots(i)
					if ( bagFamily == 0 ) then
						totalFree = totalFree + freeSlots
						numSlots = numSlots + GetContainerNumSlots(i)
					end
				end
				self.Count:SetText(format("%s\n|cFFAAAAAA%s|r", totalFree, numSlots))
			end)
			button:SetScript("OnClick", function(self)
				ToggleAllBags()
			end)

		elseif info.name == "EJ" then

			button.icon:SetTexture(info.icon)

			button.NewAdventureNotice = CreateFrame("Frame", nil, button)
			button.NewAdventureNotice:SetSize(28, 28)
			button.NewAdventureNotice:SetPoint("BOTTOMRIGHT")

			button.NewAdventureNotice:Hide()

			EJMicroButton.NewAdventureNotice:HookScript("OnShow", function() button.NewAdventureNotice:Show() end)
			EJMicroButton.NewAdventureNotice:HookScript("OnHide", function() button.NewAdventureNotice:Hide() end)

			button.NewAdventureNotice.Texture = button.NewAdventureNotice:CreateTexture(nil, "OVERLAY")
			button.NewAdventureNotice.Texture:SetAllPoints()
			button.NewAdventureNotice.Texture:SetAtlas("adventureguide-microbutton-alert")

		else
			button.icon:SetTexture(info.icon)
		end
		------------------------
		if #secureButtons == 6 then
			button:SetPoint("BOTTOM", secureButtons[1], "TOP", 0, 8)
		elseif #secureButtons > 0 then
			button:SetPoint("LEFT", secureButtons[i-1], "RIGHT", 0, 0)
		else
			button:SetPoint("BOTTOMLEFT", microContainer, "BOTTOMLEFT", 0, 0)
		end
		secureButtons[i] = button
	end

	-- Create a shortcut menu button to quickly open the binding manager.
	local GameMenuButtonController = CreateFrame("BUTTON", "GameMenuButtonController", GameMenuFrame, "GameMenuButtonTemplate, SecureHandlerBaseTemplate")
	GameMenuButtonController.hasPriority = true
	GameMenuButtonController.ignoreMenu = true
	GameMenuButtonController:SetText(db.TUTORIAL.BIND.MENUHEADER)
	GameMenuButtonController:SetScript("PreClick", PreClick)
	GameMenuButtonController:SetScript("OnClick", function(self)
		ConsolePortConfig:Show()
	end)

	local LFDTeleport =  db.Atlas.GetFutureButton("$parentLFDTeleport", GameMenuFrame, nil, nil, 160, 32, true)
	local LFDJoinLeave =  db.Atlas.GetFutureButton("$parentLFDJoinLeave", GameMenuFrame, nil, nil, 160, 32, true)

	LFDTeleport:SetScript("PreClick", PreClick)
	LFDJoinLeave:SetScript("PreClick", PreClick)
	
	LFDTeleport:SetScript("OnClick", function() LFGTeleport(IsInLFGDungeon()) end)
	LFDJoinLeave:SetScript("OnClick", function() ConfirmOrLeaveLFGParty() end)

	LFDTeleport:SetScript("OnShow", function(self)
		self:SetText(IsInLFGDungeon() and TELEPORT_OUT_OF_DUNGEON or TELEPORT_TO_DUNGEON)
	end)

	LFDJoinLeave:SetScript("OnShow", function(self)
		self:SetText(IsPartyLFG() and INSTANCE_PARTY_LEAVE or ENTER_DUNGEON)
	end)

	local buttons = {
		[GameMenuButtonController] 	= {pos = {"RIGHT", GameMenuFrame, "TOP", -1, -230}, fadeFrom = "LEFT"},
		[GameMenuButtonOptions] 	= {pos = {"TOP", GameMenuButtonController, "BOTTOM", 0, -1}, fadeFrom = "LEFT"},
		[GameMenuButtonUIOptions] 	= {pos = {"TOP", GameMenuButtonOptions, "BOTTOM", 0, -1}, fadeFrom = "LEFT"},
		--
		[GameMenuButtonContinue] 	= {pos = {"LEFT", GameMenuFrame, "TOP", 1, -230}, fadeFrom = "RIGHT"},
		[GameMenuButtonLogout] 		= {pos = {"TOP", GameMenuButtonContinue, "BOTTOM", 0, -1}, fadeFrom = "RIGHT"},
		[GameMenuButtonQuit] 		= {pos = {"TOP", GameMenuButtonLogout, "BOTTOM", 0, -1}, fadeFrom = "RIGHT"},
		--
		[GameMenuButtonAddons] 		= {pos = {"TOP", GameMenuButtonUIOptions, "BOTTOM", 0, -20}, fadeFrom = "LEFT"},
		[GameMenuButtonMacros] 		= {pos = {"TOP", GameMenuButtonAddons, "BOTTOM", 0, -1}, fadeFrom = "LEFT"},
		[GameMenuButtonKeybindings] = {pos = {"TOP", GameMenuButtonMacros, "BOTTOM", 0, -1}, fadeFrom = "LEFT"},
		--
		[GameMenuButtonHelp] 		= {pos = {"TOP", GameMenuButtonQuit, "BOTTOM", 0, -20}, fadeFrom = "RIGHT"},
		[GameMenuButtonStore] 		= {pos = {"TOP", GameMenuButtonHelp, "BOTTOM", 0, -1}, fadeFrom = "RIGHT"},
		[GameMenuButtonWhatsNew] 	= {pos = {"TOP", GameMenuButtonStore, "BOTTOM", 0, -1}, fadeFrom = "RIGHT"},
		--
		[LFDTeleport] 				= {pos = {"BOTTOMRIGHT", GameMenuButtonController, "TOPRIGHT", 0, 1}, fadeFrom = "LEFT"},
		[LFDJoinLeave] 				= {pos = {"BOTTOMLEFT", GameMenuButtonContinue, "TOPLEFT", 0, 1}, fadeFrom = "RIGHT"},
	}

	for button in pairs(buttons) do
		button:ClearAllPoints()
	end

	for button, info in pairs(buttons) do
		db.Atlas.SetFutureButtonStyle(button, nil, nil, true)
		button:SetPoint(unpack(info.pos))

		button.Cover2 = button.Cover2 or button:CreateTexture("$parentCover2", "ARTWORK")
		button.Cover2:SetAtlas("groupfinder-button-cover")
		button.Cover2:SetAllPoints()

		button.Cover3 = button.Cover3 or button:CreateTexture("$parentCover3", "ARTWORK")
		button.Cover3:SetAtlas("groupfinder-button-cover")
		button.Cover3:SetAllPoints()

		if info.fadeFrom == "RIGHT" then
			button.Cover:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, cc.r, cc.g, cc.b, 0)
			button.Cover2:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, cc.r, cc.g, cc.b, 0)
			button.Cover3:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, cc.r, cc.g, cc.b, 0)
		elseif info.fadeFrom == "LEFT" then
			button.Cover:SetGradientAlpha("HORIZONTAL", cc.r, cc.g, cc.b, 0, 1, 1, 1, 1)
			button.Cover2:SetGradientAlpha("HORIZONTAL", cc.r, cc.g, cc.b, 0, 1, 1, 1, 1)
			button.Cover3:SetGradientAlpha("HORIZONTAL", cc.r, cc.g, cc.b, 0, 1, 1, 1, 1)
		end

		if button.Middle then
			button.Middle:Hide()
			button.Left:Hide()
			button.Right:Hide()
		end

		button.Label:SetTextColor(cc.r + 0.75, cc.g + 0.75, cc.b + 0.75)
		button.Label:SetShadowOffset(2, -2)
	end

	LFDTeleport:SetSize(160, 32)
	LFDJoinLeave:SetSize(160, 32)

	local function OnEvent(self, event, ...)
		if event == "PLAYER_REGEN_DISABLED" and self:IsVisible() then
			ConsolePort:ClearCurrentNode()
		end
	end

	local function OnShow(self)
		self.ArtOverlay:SetMask(nil)
		self.ArtOverlay:SetTexture("Interface\\TALENTFRAME\\"..(db.Atlas.GetOverlay() or ""))
		self.ArtOverlay:SetTexCoord(0, 1, 0, 0.64453125)
		self.ArtOverlay:SetSize(550, 400)
		self.ArtOverlay:SetPoint("CENTER", 0, -80)
		self.ArtOverlay:SetMask("Interface\\GLUES\\Models\\UI_Dwarf\\UI_Goblin_GodRaysMask")

		if IsInLFGDungeon() or IsPartyLFG() then
			LFDJoinLeave:Show()
			LFDTeleport:Show()
		else
			LFDJoinLeave:Hide()
			LFDTeleport:Hide()
		end
	end

	local function OnHide(self)
		if not InCombatLockdown() then
			ConsolePort:ClearCurrentNode()
		end
	end

	GameMenuFrame:SetSize(530, 530)
	GameMenuFrame:SetScript("OnEvent", OnEvent)
	GameMenuFrame:SetScript("OnShow", OnShow)
	GameMenuFrame:HookScript("OnHide", OnHide)
	GameMenuFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

	GameMenuFrameHeader:SetHeight(32)
	GameMenuFrameHeader:SetTexCoord(0, 0.640625, 0.3, 1)
	GameMenuFrameHeader:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Highlight")
	GameMenuFrameHeader:SetVertexColor(cc.r, cc.g, cc.b, 1)
	GameMenuFrameHeader:SetBlendMode("ADD")

	GameMenuFrame.ArtOverlay = GameMenuFrame:CreateTexture(nil, "BACKGROUND")

	GameMenuFrame.BG = GameMenuFrame:CreateTexture(nil, "BACKGROUND")
	GameMenuFrame.BG:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 16, -16)
	GameMenuFrame.BG:SetPoint("BOTTOMRIGHT", GameMenuFrame, "BOTTOMRIGHT", -16, 16)
	GameMenuFrame.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	GameMenuFrame.BG:SetBlendMode("ADD")

	GameMenuFrame.BG2 = GameMenuFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
	GameMenuFrame.BG2:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 16, -16)
	GameMenuFrame.BG2:SetPoint("BOTTOMRIGHT", GameMenuFrame, "BOTTOMRIGHT", -16, 16)
	GameMenuFrame.BG2:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-Achievement-StatsBackground")
	GameMenuFrame.BG2:SetMask("Interface\\PetBattles\\PadEffect-HealingRain")

	GameMenuFrame.BG2:SetVertexColor(cc.r, cc.g, cc.b, 0.25)
	GameMenuFrame.BG:SetVertexColor(cc.r, cc.g, cc.b, 0.25)


	GameMenuFrame:SetBackdrop({
		edgeFile 	= "Interface\\AddOns\\ConsolePort\\Textures\\Window\\EdgefileNoSides",
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	})

	ConfigureMenu = nil
end

ConfigureMenu()