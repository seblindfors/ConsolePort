local UI, an, L = ConsolePortUI, ...
local db = ConsolePort:GetData()
local ICON = 'Interface\\Icons\\%s'
local Button = L.Button
local IsClassic, IsRetail = CPAPI:IsClassicVersion(), CPAPI:IsRetailVersion()

-- Loot header specifics
local LootButton = L.LootButton
local lootButtonProbeScript = L.lootButtonProbeScript
local lootHeaderOnSetScript = L.lootHeaderOnSetScript

-- Dropdown button templates 
local maskTemplates = {'CPUIMenuButtonBaseTemplate', 'SecureActionButtonTemplate'}
local baseTemplates = {'CPUIMenuButtonMaskTemplate', 'SecureActionButtonTemplate'}

local Menu =  UI:CreateFrame('Frame', an, GameMenuFrame, 'SecureHandlerStateTemplate, CPUIMenuTemplate', {
	{
		Character = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-armor:18:18:-4:0:64:64:14:50:14:50|t' .. CHARACTER,
			ID = 1,
			SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
			{
				Info  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc	= CHARACTER_BUTTON,
					Attrib 	= {hidemenu = true},
					UpdateLevel = function(self, newLevel)
						local level = newLevel or UnitLevel('player')
						if level and level < MAX_PLAYER_LEVEL then
							self.Level:SetTextColor(1, 0.8, 0)
							self.Level:SetText(level)
						else
							self.Level:SetTextColor(GetItemLevelColor())
							self.Level:SetText(floor(select(2, GetAverageItemLevel())))
						end
					end,
					OnClick = function(self) ToggleCharacter('PaperDollFrame') end,
					OnEvent = function(self, event, ...)
						if event == 'UNIT_PORTRAIT_UPDATE' then
							SetPortraitTexture(self.Icon, 'player')
						elseif event == 'PLAYER_LEVEL_UP' then
							self:UpdateLevel(...)
						else
							SetPortraitTexture(self.Icon, 'player')
							self:UpdateLevel()
						end
					end,
					RegisterUnitEvent = {'UNIT_PORTRAIT_UPDATE', 'player'},
					Events = {
						'PLAYER_ENTERING_WORLD',
						'PLAYER_LEVEL_UP',
					},
					{
						Level = {
							Type 	= 'FontString',
							Setup 	= {'OVERLAY'},
							Font 	= {Game12Font:GetFont()},
							AlignH 	= 'RIGHT',
							Point 	= {'RIGHT', -10, 0},
						},
					},
				},
				Inventory  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.Info', 'BOTTOM', 0, 0},
					Desc	= INVENTORY_TOOLTIP,
					Img 	= ICON:format(IsClassic and 'INV_Misc_Bag_08' or 'INV_Misc_Bag_29'),
					Events 	= {'BAG_UPDATE'},
					Attrib 	= {hidemenu = true},
					OnClick = ToggleAllBags,
					OnEvent = function(self, event, ...)
						local totalFree, numSlots, freeSlots, bagFamily = 0, 0
						for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
							freeSlots, bagFamily = GetContainerNumFreeSlots(i)
							if ( bagFamily == 0 ) then
								totalFree = totalFree + freeSlots
								numSlots = numSlots + GetContainerNumSlots(i)
							end
						end
						self.Count:SetFormattedText('%s\n|cFFAAAAAA%s|r', totalFree, numSlots)
					end,
					{
						Count = {
							Type 	= 'FontString',
							Setup 	= {'OVERLAY'},
							Font 	= {Game12Font:GetFont()},
							AlignH 	= 'RIGHT',
							Point 	= {'RIGHT', -10, 0},
						},
					},
				},
				Spec  = {
					Type 	= 'Button',
					Setup 	= maskTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.Inventory', 'BOTTOM', 0, 0},
					Desc	= TALENTS_BUTTON,
					RefTo 	= TalentMicroButton,
					Attrib 	= {hidemenu = true},
					EvaluateAlertVisibility = function(self)
						-- If we just unspecced, and we have unspent talent points, it's probably spec-specific talents that were just wiped.  Show the tutorial box.
						if not AreTalentsLocked() and GetNumUnspentTalents() > 0 and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
							self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_TALENTS
							self:SetPulse(true)
							return
						end
						if GetNumUnspentPvpTalents() > 0 and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
							self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_HONOR_TALENTS
							self:SetPulse(true)
							return
						end
					end,
					OnEnterScript = function(self)
						if self.tooltipText then
							GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
							GameTooltip:SetText(self.tooltipText)
							self.tooltipText = nil
							self.hideTooltipOnLeave = true
						end
					end,
					OnLeaveHook = function(self)
						if self.hideTooltipOnLeave then
							GameTooltip:Hide()
							self.hideTooltipOnLeave = nil
						end
					end,
					OnLoadHook = function(self)
						local iconFile, iconTCoords = CPAPI:GetClassIcon()
						self.Icon:SetTexture(iconFile)
						self.Icon:SetTexCoord(unpack(iconTCoords))
						self.Icon:SetMask([[Interface\AddOns\ConsolePort\Textures\Button\Mask]])
						for _, event in ipairs({
							'PLAYER_LEVEL_UP',
							'UPDATE_BINDINGS',
							'PLAYER_TALENT_UPDATE',
							'PLAYER_SPECIALIZATION_CHANGED',
							'HONOR_LEVEL_UPDATE',
						--	'HONOR_PRESTIGE_UPDATE',
							'PLAYER_PVP_TALENT_UPDATE',
						--	'PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED',
						}) do pcall(self.RegisterEvent, self, event) end
					end,
					OnEvent = function(self, event, ...)
						self.tooltipText = nil
						if ( event == 'PLAYER_LEVEL_UP' ) then
							local level = ...
							if (level == SHOW_SPEC_LEVEL) then
								self.tooltipText = TALENT_MICRO_BUTTON_SPEC_TUTORIAL
								self:SetPulse(true)
							elseif (level == SHOW_TALENT_LEVEL) then
								self.tooltipText = TALENT_MICRO_BUTTON_TALENT_TUTORIAL
								self:SetPulse(true)
							end
						elseif ( event == 'PLAYER_SPECIALIZATION_CHANGED' ) then
							self:EvaluateAlertVisibility()
						elseif ( event == 'PLAYER_TALENT_UPDATE' or event == 'NEUTRAL_FACTION_SELECT_RESULT' or
							event == 'HONOR_LEVEL_UPDATE' or event == 'HONOR_PRESTIGE_UPDATE' or event == 'PLAYER_PVP_TALENT_UPDATE' ) then
							self:EvaluateAlertVisibility()

							-- On the first update from the server, flash the button if there are unspent points
							-- Small hack: GetNumSpecializations should return 0 if talents haven't been initialized yet
							if (not self.receivedUpdate and GetNumSpecializations(false) > 0) then
								self.receivedUpdate = true;
								local shouldPulseForTalents = GetNumUnspentTalents() > 0 or GetNumUnspentPvpTalents() > 0 and not AreTalentsLocked()
								if (UnitLevel('player') >= SHOW_SPEC_LEVEL and (not GetSpecialization() or shouldPulseForTalents)) then
									self:SetPulse(true)
								end
							end
						elseif ( event == 'PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED' ) then
							local prev, current = ...
							if ( prev == 0 and current > 0 ) then
								self.tooltipText = TALENT_MICRO_BUTTON_TALENT_TUTORIAL
								self:SetPulse(true)
							elseif ( prev ~= current ) then
								self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_TALENTS
								self:SetPulse(true)
							end
						end
					end,
				},
				Spellbook  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 4,
					Point 	= {'TOP', 'parent.Spec', 'BOTTOM', 0, 0},
					Desc	= SPELLBOOK_BUTTON,
					Img 	= [[Interface\Spellbook\Spellbook-Icon]],
					RefTo 	= SpellbookMicroButton,
					Attrib 	= {hidemenu = true},
				},
				Collections  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 5,
					Point 	= {'TOP', 'parent.Spellbook', 'BOTTOM', 0, 0},
					Desc	= COLLECTIONS,
					Img 	= ICON:format('MountJournalPortrait'),
					RefTo 	= CollectionsMicroButton,
					Attrib 	= {hidemenu = true},
				},
			},
		},
		Gameplay = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-weapons:18:18:-4:0:64:64:14:50:14:50|t' .. GAME,
			ID 	= 2,
			SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
			{
				QuestLog  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc	= IsRetail and (WORLD_MAP .. ' / ' .. QUEST_LOG) or QUEST_LOG,
					Img 	= IsRetail and ICON:format('INV_Misc_Map02') or [[Interface\QUESTFRAME\UI-QuestLog-BookIcon]],
					RefTo 	= QuestLogMicroButton,
					Attrib 	= {hidemenu = true},
				},
				WorldMap  = IsClassic and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.QuestLog', 'BOTTOM', 0, 0},
					Desc	= WORLD_MAP,
					Img 	= [[Interface\WorldMap\WorldMap-Icon]],
					RefTo 	= WorldMapMicroButton,
					Attrib 	= {hidemenu = true},
				},
				Guide  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.QuestLog', 'BOTTOM', 0, 0},
					Desc	= ADVENTURE_JOURNAL,
					Img 	= [[Interface\ENCOUNTERJOURNAL\UI-EJ-PortraitIcon]],
					RefTo 	= EJMicroButton,
					Attrib 	= {hidemenu = true},
					{
						Notice = {
							Type = 'Frame',
							Size = {28, 28},
							Point = {'RIGHT', -10, 0},
							Hide = not EJMicroButton.NewAdventureNotice:IsShown(),
							{
								Texture = {
									Type = 'Texture',
									Setup = {'OVERLAY'},
									Fill = true,
									Atlas = 'adventureguide-microbutton-alert',
								},
							},
							OnLoad = function(self)
								hooksecurefunc('EJMicroButton_UpdateNewAdventureNotice', function()
									if EJMicroButton.NewAdventureNotice:IsShown() then
										self:Show()
									end
								end)
								hooksecurefunc('EJMicroButton_ClearNewAdventureNotice', function()
									self:Hide()
								end)
							end,
						},
					},
				},
				Finder  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.Guide', 'BOTTOM', 0, 0},
					Desc	= DUNGEONS_BUTTON,
					Img 	= [[Interface\LFGFRAME\UI-LFG-PORTRAIT]],
					RefTo 	= LFDMicroButton,
					Attrib 	= {hidemenu = true},
				},
				Achievements  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 4,
					Point 	= {'TOP', 'parent.Finder', 'BOTTOM', 0, -16},
					Desc	= ACHIEVEMENTS,
					Img 	= ICON:format('ACHIEVEMENT_WIN_WINTERGRASP'),
					RefTo 	= AchievementMicroButton,
					Attrib 	= {hidemenu = true},
				},
				WhatsNew  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 5,
					Point 	= {'TOP', 'parent.Achievements', 'BOTTOM', 0, 0},
					Desc	= GAMEMENU_NEW_BUTTON,
					RefTo 	= GameMenuButtonWhatsNew,
					Img 	= ICON:format('WoW_Token01')
				},
				Shop  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 6,
					Point 	= {'TOP', 'parent.WhatsNew', 'BOTTOM', 0, 0},
					Desc	= BLIZZARD_STORE,
					RefTo 	= GameMenuButtonStore,
					Img 	= ICON:format('WoW_Store'),
				},
				Teleport  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 7,
					Point 	= {'TOP', IsRetail and 'parent.Shop' or 'parent.WorldMap', 'BOTTOM', 0, 0},
					Img 	= ICON:format('Spell_Shadow_Teleport'),
					Attrib 	= {
						hidemenu 	= true,
						condition 	= 'return PlayerInGroup()',
					},
					Hooks = {
						OnShow = function(self)
							local isLFG, inDungeon = IsPartyLFG(), IsInLFGDungeon()
							self:SetText(inDungeon and TELEPORT_OUT_OF_DUNGEON or isLFG and TELEPORT_TO_DUNGEON or '|cFF757575'..TELEPORT_TO_DUNGEON)
						end,
						OnClick = function(self)
							LFGTeleport(IsInLFGDungeon())
						end,
					},
				},
			},
		},
		Social = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-featured:18:18:-4:0:64:64:14:50:14:50|t' .. SOCIAL_BUTTON,
			ID = 3,
			SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
			{	
				Friends  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc 	= FRIENDS_LIST,
					Img 	= [[Interface\FriendsFrame\Battlenet-Portrait]],
					RefTo 	= IsRetail and QuickJoinToastButton or SocialsMicroButton,
					Attrib 	= {hidemenu = true},
					OnEvent = function(self)
						local _, numBNetOnline = BNGetNumFriends()
						local numWoWOnline = C_FriendList.GetNumFriends()
						self.Count:SetText(numBNetOnline + numWoWOnline)
					end,
					Events = {
						'FRIENDLIST_UPDATE',
						'BN_FRIEND_INFO_CHANGED',
						'PLAYER_ENTERING_WORLD',
					},
					{
						Count = {
							Type 	= 'FontString',
							Setup 	= {'OVERLAY'},
							Font 	= {Game12Font:GetFont()},
							AlignH 	= 'RIGHT',
							Point 	= {'RIGHT', -10, 0},
						},
					},
				},
				Guild  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.Friends', 'BOTTOM', 0, 0},
					Desc 	= GUILD,
					Img 	= ICON:format('Achievement_GuildPerk_EverybodysFriend'),
					RefTo 	= IsRetail and GuildMicroButton,
					Attrib 	= IsRetail and {hidemenu = true} or {
						type = 'macro';
						macrotext = '/click GameMenuButtonContinue\n/click SocialsMicroButton\n/click FriendsFrameTab3';
					},
				},
				Calendar  = IsRetail and {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.Guild', 'BOTTOM', 0, 0},
					Desc 	= EVENTS_LABEL,
					Img 	= [[Interface\Calendar\MeetingIcon]],
					Attrib 	= {hidemenu = true},
					RefTo 	= GameTimeFrame,
				},
				Raid  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= IsClassic and 3 or 4,
					Point 	= {'TOP', IsClassic and 'parent.Guild' or 'parent.Calendar', 'BOTTOM', 0, 0},
					Desc 	= RAID,
					Img 	= [[Interface\LFGFRAME\UI-LFR-PORTRAIT]],
					Attrib 	= IsRetail and {hidemenu = true} or {
						type = 'macro';
						macrotext = '/click GameMenuButtonContinue\n/click SocialsMicroButton\n/click FriendsFrameTab4';
					},
					Scripts = IsRetail and {
						OnClick = ToggleRaidFrame,
					},
				},
				Party  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= IsClassic and 4 or 5,
					Point 	= {'TOP', 'parent.Raid', 'BOTTOM', 0, -16},
					Img 	= [[Interface\LFGFRAME\UI-LFG-PORTRAIT]],
					Attrib 	= {
						condition = 'return PlayerInGroup()',
						hidemenu = true,
					},
					Hooks = {
						OnShow = function(self)
							self:SetText(CPAPI:IsPartyLFG() and INSTANCE_PARTY_LEAVE or PARTY_LEAVE)
						end,
						OnClick = function(self)
							if CPAPI:IsPartyLFG() or CPAPI:IsInLFGDungeon() then
								ConfirmOrLeaveLFGParty()
							else
								LeaveParty()
							end
						end,
					},
				},
			},
		},
		System = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-wow:18:18:-4:0:64:64:14:50:14:50|t' .. SYSTEMOPTIONS_MENU,
			ID = 4,
			SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
			{
				Return  = {
					Type 	= 'Button',
					Setup 	= maskTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc	= RETURN_TO_GAME,
					RefTo 	= GameMenuButtonContinue,
					OnLoadHook = function(self)
						local iconFile, iconTCoords = CPAPI:GetClassIcon()
						self.Icon:SetTexture(iconFile)
						self.Icon:SetTexCoord(unpack(iconTCoords))
						self.Icon:SetMask([[Interface\AddOns\ConsolePort\Textures\Button\Mask]])
					end,
				},
				Logout  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.Return', 'BOTTOM', 0, 0},
					Desc	= LOGOUT,
					RefTo 	= GameMenuButtonLogout,
					Img 	= ICON:format(IsRetail and 'RaceChange' or 'Spell_Nature_TimeStop'),
				},
				Exit  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.Logout', 'BOTTOM', 0, 0},
					Desc	= EXIT_GAME,
					RefTo 	= GameMenuButtonQuit,
					Img 	= [[Interface\RAIDFRAME\ReadyCheck-NotReady]],
				},
				Controller  = {
					Type 	= 'Button',
					Setup 	= maskTemplates,
					Mixin 	= Button,
					ID 		= 4,
					Point 	= {'TOP', 'parent.Exit', 'BOTTOM', 0, -16},
					Desc	= CONTROLS_LABEL,
					Img 	= db.TEXTURE.CP_X_CENTER,
					Attrib 	= {hidemenu = true},
					OnClick = function() 
						if InCombatLockdown() then
							ConsolePortOldConfig:OnShow()
						else
							ConsolePortOldConfig:Show()
						end
					end,
				},
				System  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 5,
					Point 	= {'TOP', 'parent.Controller', 'BOTTOM', 0, 0},
					Desc	= SYSTEMOPTIONS_MENU,
					RefTo 	= GameMenuButtonOptions,
					Img 	= ICON:format(IsRetail and 'Pet_Type_Mechanical' or 'Trade_Engineering'),
				},
				Interface  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 6,
					Point 	= {'TOP', 'parent.System', 'BOTTOM', 0, 0},
					Desc	= UIOPTIONS_MENU,
					RefTo 	= GameMenuButtonUIOptions,
					Img 	= [[Interface\TUTORIALFRAME\UI-TutorialFrame-GloveCursor]],
				},
				AddOns  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 7,
					Point 	= {'TOP', 'parent.Interface', 'BOTTOM', 0, 0},
					Desc	= ADDONS,
					RefTo 	= GameMenuButtonAddons,
					Img 	= [[Interface\PaperDollInfoFrame\Character-Plus]],
				},
				Macros  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 8,
					Point 	= {'TOP', 'parent.AddOns', 'BOTTOM', 0, -16},
					Desc	= MACROS,
					RefTo 	= GameMenuButtonMacros,
					Img 	= ICON:format(IsRetail and 'Pet_Type_Magical' or 'Trade_Alchemy'),
				},
				KeyBindings  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 9,
					Point 	= {'TOP', 'parent.Macros', 'BOTTOM', 0, 0},
					Desc	= KEY_BINDINGS,
					RefTo 	= GameMenuButtonKeybindings,
					Img 	= [[Interface\MacroFrame\MacroFrame-Icon]],
				},
				Help  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 10,
					Point 	= {'TOP', 'parent.KeyBindings', 'BOTTOM', 0, 0},
					Desc	= GAMEMENU_HELP,
					RefTo 	= GameMenuButtonHelp,
					Img 	= ICON:format('INV_Misc_QuestionMark'),
				},
			},
		},
	},
})

-- In case we're adding the loot dropdown
tinsert(maskTemplates, 'SecureHandlerBaseTemplate')
local lootWireFrame = {
	Loot = {
		Type 	= 'CheckButton',
		Setup 	= {
			'SecureHandlerBaseTemplate',
			'SecureHandlerShowHideTemplate',
			'SecureHandlerClickTemplate',
			'CPUIListCategoryTemplate',
		},
		Point 	= {'CENTER', 490, 0},
		Text	= [[|TInterface\Buttons\UI-GroupLoot-Dice-Up:24:24:0:-2|t]],
		Width 	= 50,
		ID = 5,
		OnLoad = function(self)
			self:SetShown(
				GroupLootFrame1:IsVisible() or
				GroupLootFrame2:IsVisible() or
				GroupLootFrame3:IsVisible() or
				GroupLootFrame4:IsVisible() or
				BonusRollFrame:IsVisible())
		end,
		Multiple = {
			Probe = {
				{GroupLootFrame1, 'showhide'},
				{GroupLootFrame2, 'showhide'},
				{GroupLootFrame3, 'showhide'},
				{GroupLootFrame4, 'showhide'},
			--	{BonusRollFrame, 'showhide'},
			},
			SetAttribute = {
				{'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
				{'onheaderset', lootHeaderOnSetScript},
			},
		},
		{
			Loot1  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 1,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Obj 	= GroupLootFrame1,
				Probe 	= {GroupLootFrame1, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot2  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 2,
				Obj 	= GroupLootFrame2,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame2, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot3  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 3,
				Obj 	= GroupLootFrame3,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame3, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot4  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 4,
				Obj 	= GroupLootFrame4,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame4, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			-- Bonus  = {
			-- 	Type 	= 'Button',
			-- 	Setup 	= maskTemplates,
			-- 	Mixin 	= LootButton,
			-- 	ID 		= 5,
			-- 	NoMask 	= true,
			-- 	Obj 	= BonusRollFrame,
			-- 	Img 	= ICON:format('INV_Misc_QuestionMark'),
			-- 	Probe 	= {BonusRollFrame, 'probescript', nil, lootButtonProbeScript},
			-- 	RegisterForClicks = {'AnyUp', 'AnyDown'},
			-- 	Multiple = {
			-- 		SetAttribute = {
			-- 			{'pc', 0},
			-- 			{'condition', 'return false'},
			-- 		},
			-- 	},
			-- },
		},
	},
}

do	
	ConsolePortUIConfig.Menu = ConsolePortUIConfig.Menu or {}

	local cfg = ConsolePortUIConfig.Menu

	cfg.lootprobe = cfg.lootprobe and true or false 
	cfg.scale = cfg.scale or 1

	if cfg.lootprobe then
		UI:BuildFrame(Menu, lootWireFrame)
	end

	lootWireFrame = nil
	maskTemplates = nil
	baseTemplates = nil

	Menu:StartEnvironment()
	Menu:Execute('hID, bID = 4, 1')
	Menu:DrawIndex(function(header)
		for i, button in ipairs({header:GetChildren()}) do
			if button:GetAttribute('hidemenu') then
				button:SetAttribute('type', 'macro')
				button:SetAttribute('macrotext', '/click GameMenuButtonContinue')
			end
			if button.RefTo then
				local macrotext = button:GetAttribute('macrotext')
				local prefix = (macrotext and macrotext .. '\n') or ''
				button:SetAttribute('macrotext', prefix .. '/click ' .. button.RefTo:GetName())
				button:SetAttribute('type', 'macro')
			end
			button:Hide()
			header:SetFrameRef(tostring(button:GetID()), button)
		end
	end)

	UI:RegisterFrame(Menu, 'Menu', false, true)
	UI:HideFrame(GameMenuFrame, true)

	Menu:SetScale(cfg.scale)
	Menu:LoadArt()

	L.Menu = Menu
end

--[[

Character
	Character Info
	Backpack (inventory)
	Spec&Talents
	Spell book
	Collections
Gameplay
	Quest/Map
	Adventure Guide
	Group Finder
	Achievements
	What's New
	Shop
+ 	Teleport
Social
	Friends List
	Guild (guild finder)
	Raid
	Events (Calendar)
+	Leave Group
System
	Return to game
	Logout
	Exit Game

	Controller
	System (settings)
	Interface

	AddOns
	Macros

	Key bindings
	Help
]]