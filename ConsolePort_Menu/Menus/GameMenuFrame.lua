local name, env = ...;
local Menu, Cursor = CreateFrame('Frame', 'ConsolePortGameMenu', GameMenuFrame, 'CPFullscreenMenuTemplate'), ConsolePortSecureCursor;

do	-- Initiate frame
	local headerTemplates = {'SecureHandlerBaseTemplate', 'SecureHandlerClickTemplate', 'CPMenuListCategoryTemplate'}; 
	local baseTemplates   = {'CPMenuButtonBaseTemplate', 'SecureActionButtonTemplate'};
	local hideMenuHook    = {hidemenu = true};
	local PLAYER_CLASS    = select(2, UnitClass('player'))
	local IsRetailVersion = CPAPI.IsRetailVersion;
	local IsClassicVersion = not CPAPI.IsRetailVersion or nil;

	LibStub('Carpenter')(Menu, {
		Character = {
			_ID    = 1;
			_Type  = 'CheckButton';
			_Setup = headerTemplates;
			_Text  = '|TInterface\\Store\\category-icon-armor:18:18:-4:0:64:64:14:50:14:50|t' .. CHARACTER;
			{
				Info = {
					_ID    = 1;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent', 'BOTTOM', 0, -16};
					_Text  = CHARACTER_BUTTON;
					_Attributes = hideMenuHook;
					_UpdateLevel = function(self, newLevel)
						local level = newLevel or UnitLevel('player')
						if ( level and level < MAX_PLAYER_LEVEL ) then
							self.Level:SetTextColor(1, 0.8, 0)
							self.Level:SetText(level)
						else
							self.Level:SetTextColor(CPAPI.GetItemLevelColor())
							self.Level:SetText(CPAPI.GetAverageItemLevel())
						end
					end;
					_OnClick = function(self) ToggleCharacter('PaperDollFrame') end;
					_OnEvent = function(self, event, ...)
						if event == 'UNIT_PORTRAIT_UPDATE' then
							SetPortraitTexture(self.Icon, 'player')
						elseif event == 'PLAYER_LEVEL_UP' then
							self:UpdateLevel(...)
						else
							SetPortraitTexture(self.Icon, 'player')
							self:UpdateLevel()
						end
					end;
					_RegisterUnitEvent = {'UNIT_PORTRAIT_UPDATE', 'player'};
					_Events = {'PLAYER_ENTERING_WORLD', 'PLAYER_LEVEL_UP'};
					{
						Level = {
							_Type   = 'FontString';
							_Setup  = {'OVERLAY'};
							_Font   = {Game12Font:GetFont()};
							_AlignH = 'RIGHT';
							_Point  = {'RIGHT', -10, 0},
						};
					};
				};
				Inventory = {
					_ID    = 2;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Info', 'BOTTOM', 0, 0};
					_Text  = INVENTORY_TOOLTIP;
					_Image = IsRetailVersion and 'INV_Misc_Bag_29' or 'INV_Misc_Bag_08';
					_Events = {'BAG_UPDATE'};
					_Attributes = hideMenuHook;
					_OnClick = ToggleAllBags;
					_OnEvent = function(self, event, ...)
						local totalFree, numSlots, freeSlots, bagFamily = 0, 0
						for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
							freeSlots, bagFamily = GetContainerNumFreeSlots(i)
							if ( bagFamily == 0 ) then
								totalFree = totalFree + freeSlots
								numSlots = numSlots + GetContainerNumSlots(i)
							end
						end
						self.Count:SetFormattedText('%s\n|cFFAAAAAA%s|r', totalFree, numSlots)
					end;
					{
						Count = {
							_Type   = 'FontString';
							_Setup  = {'OVERLAY'};
							_Font   = {Game12Font:GetFont()};
							_AlignH = 'RIGHT';
							_Point  = {'RIGHT', -10, 0};
						};
					};
				};
				Spec = {
					_ID    = 3;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Inventory', 'BOTTOM', 0, 0};
					_Text  = TALENTS_BUTTON;
					_RefTo = TalentMicroButton;
					_Attributes = hideMenuHook;
					_EvaluateAlertVisibility = function(self)
						local alertText, alertPriority = TalentMicroButtonMixin.HasTalentAlertToShow(self);
						local pvpAlertText, pvpAlertPriority = TalentMicroButtonMixin.HasPvpTalentAlertToShow(self);

						if not alertText or pvpAlertPriority < alertPriority then
							-- pvpAlert is higher priority, use that instead
							alertText = pvpAlertText;
						end

						if not alertText then
							return self:SetPulse(false)
						end

						if not PlayerTalentFrame or not PlayerTalentFrame:IsShown() then
							self.tooltipText = alertText;
							self:SetPulse(true);
							return true;
						end
					end;
					_OnEnter = function(self)
						CPMenuButtonMixin.OnEnter(self)

						if self.tooltipText then
							GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
							GameTooltip:SetText(self.tooltipText)
							self.tooltipText = nil;
							self.hideTooltipOnLeave = true;
						end
					end;
					_OnLeave = function(self)
						CPMenuButtonMixin.OnLeave(self)

						if self.hideTooltipOnLeave then
							GameTooltip:Hide()
							self.hideTooltipOnLeave = nil;
						end
					end;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)

						local iconFile, iconTCoords = CPAPI.GetClassIcon(PLAYER_CLASS)
						self.Icon:SetTexture(iconFile)
						self.Icon:SetTexCoord(unpack(iconTCoords))
						for _, event in ipairs({
							IsRetailVersion and 'HONOR_LEVEL_UPDATE',
							'NEUTRAL_FACTION_SELECT_RESULT',
							'PLAYER_LEVEL_CHANGED',
							'PLAYER_SPECIALIZATION_CHANGED',
							'PLAYER_TALENT_UPDATE',
						}) do self:RegisterEvent(event) end
					end;
					_OnEvent = function(self, event, ...)
						self.tooltipText = nil;
						self:EvaluateAlertVisibility()
					end;
				};
				Spellbook = {
					_ID    = 4;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Spec', 'BOTTOM', 0, 0};
					_Text  = SPELLBOOK_BUTTON;
					_RefTo = SpellbookMicroButton;
					_Attributes = hideMenuHook;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\Spellbook\Spellbook-Icon]])
					end;
				};
				Collections = IsRetailVersion and {
					_ID    = 5;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Spellbook', 'BOTTOM', 0, 0};
					_Text  = COLLECTIONS;
					_RefTo = CollectionsMicroButton;
					_Image = 'MountJournalPortrait';
					_Attributes = hideMenuHook;
				};
				Keyring = IsClassicVersion and {
					_ID    = 5;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Spellbook', 'BOTTOM', 0, 0};
					_Text  = KEYRING;
					_RefTo = KeyRingButton;
					_Attributes = hideMenuHook;
					_CustomImage = [[Interface\ContainerFrame\KeyRing-Bag-Icon]];
				};
			};
		};
		Gameplay = {
			_ID    = 2;
			_Type  = 'CheckButton';
			_Setup = headerTemplates;
			_Text  = '|TInterface\\Store\\category-icon-weapons:18:18:-4:0:64:64:14:50:14:50|t' .. GAME;
			{
				QuestLog = {
					_ID    = 1;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent', 'BOTTOM', 0, -16};
					_Text  = IsRetailVersion and ('%s / %s'):format(WORLD_MAP, QUEST_LOG) or QUEST_LOG;
					_Image = IsRetailVersion and 'INV_Misc_Map02';
					_RefTo = QuestLogMicroButton;
					_Attributes = hideMenuHook;
					_CustomImage = IsClassicVersion and [[Interface\QUESTFRAME\UI-QuestLog-BookIcon]];
				};
				WorldMap = IsClassicVersion and {
					_ID    = 2;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.QuestLog', 'BOTTOM', 0, 0};
					_Text  = WORLD_MAP;
					_RefTo = MiniMapWorldMapButton;
					_Attributes = hideMenuHook;
					_CustomImage = [[Interface\WorldMap\WorldMap-Icon]];
				};
				Guide = IsRetailVersion and {
					_ID    = 2;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.QuestLog', 'BOTTOM', 0, 0};
					_Text  = ADVENTURE_JOURNAL;
					_RefTo = EJMicroButton;
					_Attributes = hideMenuHook;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\ENCOUNTERJOURNAL\UI-EJ-PortraitIcon]]);
					end;
					{
						Notice = {
							_Type  = 'Frame';
							_Size  = {28, 28};
							_Point = {'RIGHT', -10, 0};
							_Hide  = not EJMicroButton.NewAdventureNotice:IsShown();
							_OnLoad = function(self)
								hooksecurefunc(EJMicroButton, 'UpdateNewAdventureNotice', function()
									if EJMicroButton.NewAdventureNotice:IsShown() then
										self:Show()
									end
								end)
								hooksecurefunc(EJMicroButton, 'ClearNewAdventureNotice', function()
									self:Hide()
								end)
							end;
							{
								Texture = {
									_Type  = 'Texture';
									_Setup = {'OVERLAY'};
									_Fill  = true;
									_Atlas = 'adventureguide-microbutton-alert';
								};
							};
						};
					};
				};
				Finder = IsRetailVersion and {
					_ID    = 3;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', IsRetailVersion and '$parent.Guide' or '$parent.WorldMap', 'BOTTOM', 0, 0};
					_Text  = DUNGEONS_BUTTON;
					_RefTo = LFDMicroButton;
					_Attributes = hideMenuHook;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\LFGFRAME\UI-LFG-PORTRAIT]])
					end;
				};
				Achievements = IsRetailVersion and {
					_ID    = 4,
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Finder', 'BOTTOM', 0, -16};
					_Text  = ACHIEVEMENTS;
					_Image = 'ACHIEVEMENT_WIN_WINTERGRASP';
					_RefTo = AchievementMicroButton;
					_Attributes = hideMenuHook;
				},
				WhatsNew = IsRetailVersion and {
					_ID    = 5;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Achievements', 'BOTTOM', 0, 0};
					_Text  = GAMEMENU_NEW_BUTTON;
					_RefTo = GameMenuButtonWhatsNew;
					_Image = 'WoW_Token01';
				};
				Shop = {
					_ID    = IsRetailVersion and 6 or 3;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', IsRetailVersion and '$parent.WhatsNew' or '$parent.WorldMap', 'BOTTOM', 0, 0};
					_Text  = BLIZZARD_STORE;
					_RefTo = GameMenuButtonStore;
					_Image = IsRetailVersion and 'WoW_Store';
					_CustomImage = IsClassicVersion and [[Interface\MERCHANTFRAME\UI-BuyBack-Icon]];
				};
				Teleport = IsRetailVersion and {
					_ID    = 7;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Shop', 'BOTTOM', 0, 0};
					_Image = 'Spell_Shadow_Teleport';
					_Attributes = {
						hidemenu  = true;
						condition = 'return PlayerInGroup()';
					};
					_Hooks = {
						OnShow = function(self)
							local isLFG, inDungeon = IsPartyLFG(), IsInLFGDungeon()
							self:SetText(inDungeon and TELEPORT_OUT_OF_DUNGEON or isLFG and TELEPORT_TO_DUNGEON or '|cFF757575'..TELEPORT_TO_DUNGEON)
						end;
						OnClick = function(self)
							LFGTeleport(IsInLFGDungeon())
						end;
					};
				};
			};
		};
		Social = {
			_ID    = 4;
			_Type  = 'CheckButton';
			_Setup = headerTemplates;
			_Text  = '|TInterface\\Store\\category-icon-featured:18:18:-4:0:64:64:14:50:14:50|t' .. SOCIAL_BUTTON;
			{
				Friends = {
					_ID    = 1;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent', 'BOTTOM', 0, -16};
					_Text  = FRIENDS_LIST;
					_RefTo = IsRetailVersion and QuickJoinToastButton or SocialsMicroButton;
					_Attributes = hideMenuHook;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\FriendsFrame\Battlenet-Portrait]])
					end;
					_OnEvent = function(self)
						local _, numBNetOnline = BNGetNumFriends()
						local numWoWOnline = C_FriendList.GetNumFriends()
						self.Count:SetText(numBNetOnline + numWoWOnline)
					end;
					_Events = {
						'FRIENDLIST_UPDATE';
						'BN_FRIEND_INFO_CHANGED';
						'PLAYER_ENTERING_WORLD';
					};
					{
						Count = {
							_Type   = 'FontString';
							_Setup  = {'OVERLAY'};
							_Font   = {Game12Font:GetFont()};
							_AlignH = 'RIGHT';
							_Point  = {'RIGHT', -10, 0};
						};
					};
				};
				Guild = {
					_ID    = 2;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Friends', 'BOTTOM', 0, 0};
					_Text  = IsRetailVersion and GUILD_AND_COMMUNITIES or GUILD;
					_Image = 'Achievement_GuildPerk_EverybodysFriend';
					_RefTo = IsRetailVersion and GuildMicroButton;
					_Attributes = hideMenuHook;
					_OnClick = IsClassicVersion and ToggleGuildFrame;
				};
				Calendar = IsRetailVersion and {
					_ID    = 3;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Guild', 'BOTTOM', 0, 0};
					_Text  = EVENTS_LABEL;
					_RefTo = GameTimeFrame;
					_Attributes = hideMenuHook;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\Calendar\MeetingIcon]])
					end;
				};
				Raid = {
					_ID    = IsRetailVersion and 4 or 2;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', IsRetailVersion and '$parent.Calendar' or '$parent.Guild', 'BOTTOM', 0, 0};
					_Text  = RAID;
					_Attributes = hideMenuHook;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\LFGFRAME\UI-LFR-PORTRAIT]])
					end;
					_OnClick = ToggleRaidFrame;
				};
				Party = {
					_ID    = IsRetailVersion and 5 or 3;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Raid', 'BOTTOM', 0, -16};
					_Image = 'Spell_Shadow_Teleport';
					_Attributes = {
						hidemenu  = true;
						condition = 'return PlayerInGroup()';
					};
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\LFGFRAME\UI-LFG-PORTRAIT]])
					end;
					_Hooks = {
						OnShow = function(self)
							self:SetText(CPAPI.IsPartyLFG() and INSTANCE_PARTY_LEAVE or PARTY_LEAVE)
						end;
						OnClick = function(self)
							if CPAPI.IsPartyLFG() or CPAPI.IsInLFGDungeon() then
								ConfirmOrLeaveLFGParty()
							else
								CPAPI.LeaveParty()
							end
						end;
					};
				};
			};
		};
		System = {
			_ID    = 5;
			_Type  = 'CheckButton';
			_Setup = headerTemplates;
			_Text  = '|TInterface\\Store\\category-icon-wow:18:18:-4:0:64:64:14:50:14:50|t' .. SYSTEMOPTIONS_MENU;
			{
				Return = {
					_ID    = 1;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent', 'BOTTOM', 0, -16};
					_Text  = RETURN_TO_GAME;
					_RefTo = GameMenuButtonContinue;
					_OnLoad = function(self)
						local iconFile, iconTCoords = CPAPI.GetClassIcon(PLAYER_CLASS)
						self.Icon:SetTexture(iconFile)
						self.Icon:SetTexCoord(unpack(iconTCoords))
					end;
				};
				Logout = {
					_ID    = 2;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Return', 'BOTTOM', 0, 0};
					_Text  = LOGOUT;
					_RefTo = GameMenuButtonLogout;
					_Image = IsRetailVersion and 'RaceChange' or 'Spell_Nature_TimeStop';
				};
				Exit = {
					_ID    = 3;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Logout', 'BOTTOM', 0, 0};
					_Text  = EXIT_GAME;
					_RefTo = GameMenuButtonQuit;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\RAIDFRAME\ReadyCheck-NotReady]])
					end;
				};
				Controller  = {
					_ID    = 4;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Exit', 'BOTTOM', 0, -16};
					_Text  = CONTROLS_LABEL;
					_RefTo = GameMenuFrameConsolePort;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture(CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]))
						self.Icon:SetTexCoord(0.03125, 0.96875, 0, 0.9375)
					end;
				};
				System  = {
					_ID    = 5;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', 'parent.Controller', 'BOTTOM', 0, 0};
					_Text  = SYSTEMOPTIONS_MENU;
					_RefTo = GameMenuButtonOptions;
					_Image = IsRetailVersion and 'Pet_Type_Mechanical' or 'Trade_Engineering';
				};
				Interface  = {
					_ID    = 6;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', 'parent.System', 'BOTTOM', 0, 0};
					_Text  = UIOPTIONS_MENU;
					_RefTo = GameMenuButtonUIOptions;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\TUTORIALFRAME\UI-TutorialFrame-GloveCursor]])
					end;
				};
				AddOns  = {
					_ID    = 7;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', 'parent.Interface', 'BOTTOM', 0, 0};
					_Text  = ADDONS;
					_RefTo = GameMenuButtonAddons;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\PaperDollInfoFrame\Character-Plus]])
					end;
				};
				Macros  = {
					_ID    = 8;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', 'parent.AddOns', 'BOTTOM', 0, -16};
					_Text  = MACROS;
					_RefTo = GameMenuButtonMacros;
					_Image = IsRetailVersion and 'Pet_Type_Magical' or 'Trade_Alchemy';
				};
				KeyBindings  = {
					_ID    = 9;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', 'parent.Macros', 'BOTTOM', 0, 0};
					_Text  = KEY_BINDINGS;
					_RefTo = GameMenuButtonKeybindings;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\MacroFrame\MacroFrame-Icon]])
					end;
				};
				Help  = {
					_ID    = 10;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', 'parent.KeyBindings', 'BOTTOM', 0, 0};
					_Text  = GAMEMENU_HELP;
					_RefTo = GameMenuButtonHelp;
					_Image = 'INV_Misc_QuestionMark';
				};
			};
		};
		Splash = {
			_ID = 3;
			_Type = 'CheckButton';
			_Size = {54, 54};
			_Setup = {'CPButtonTemplate', 'SecureHandlerClickTemplate'};
			_Attributes = {_onclick = 'self:GetParent():RunAttribute("ChangeHeader", self:GetID())'};
			{
				ClassIcon = {
					_Type = 'Texture';
					_Setup = {'ARTWORK'};
					_Point = {'CENTER', 0, 0};
					_Size = {42, 42};
					_OnLoad = function(self)
						local iconFile, iconTCoords = CPAPI.GetWebClassIcon()
						self:SetTexture(iconFile)
						self:SetTexCoord(unpack(iconTCoords))
					end;
				};
				ClassIconShadow = {
					_Type = 'Texture';
					_Setup = {'Background'};
					_Point = {'CENTER', 0, -2};
					_Size = {42, 42};
					_OnLoad = function(self)
						local iconFile, iconTCoords = CPAPI.GetWebClassIcon()
						self:SetTexture(iconFile)
						self:SetTexCoord(unpack(iconTCoords))
						self:SetVertexColor(0, 0, 0)
					end;
				};
				BackgroundFrame = {
					_Type = 'Frame';
					_Hide = true;
					_Level = 1;
					_Alpha = 0;
					_Points = {
						{'TOPLEFT', '$parent.$parent', 'BOTTOMLEFT', 0, 0};
						{'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', 0, 0};
					};
					_OnShow = function(self)
						env.db.Alpha.FadeIn(self, 0.5, self:GetAlpha(), 1)
					end;
					_OnHide = function(self)
						env.db.Alpha.FadeOut(self, 0.5, self:GetAlpha(), 0)
					end;
					{
						Rollover1 = {
							_Type = 'Texture';
							_Fill = true;
							_Texture = CPAPI.GetAsset([[Textures\Menu\Gradient]]);
							_OnLoad = function(self)
								local r, g, b = CPAPI.GetClassColor()
								self:SetGradientAlpha('VERTICAL', r, g, b, 0.75, r, g, b, 1)
							end;
						};
						Rollover2 = {
							_Type = 'Texture';
							_Fill = true;
							_Texture = CPAPI.GetAsset([[Textures\Menu\Gradient]]);
							_OnLoad = function(self)
								local r, g, b = CPAPI.GetClassColor()
								self:SetGradientAlpha('VERTICAL', r, g, b, 0, r, g, b, 1)
							end;
						};
					};
				};
				OverviewFrame = {
					_Type = 'Frame';
					_Hide = true;
					_Width = 1000;
					_Level = 2;
					_Scale = 1.2;
					_Points = {
						{'TOP', '$parent.$parent', 'BOTTOM', 0, 0};
						{'BOTTOM', UIParent, 'BOTTOM', 0, 0};
					};
					{
						Splash = {
							_Type  = 'Texture';
							_Setup = {'ARTWORK'};
							_Size  = {450, 450};
							_Point = {'CENTER', 0, 0};
						};
						Lines = {
							_Type  = 'Texture';
							_Setup = {'OVERLAY'};
							_Size  = {1024, 512};
							_Point = {'CENTER', 0, 0};
						};
					};
				};
				GridFrame = {
					_Type  = 'ScrollFrame';
					_Setup = {'CPSmoothScrollTemplate'};
					_Hide  = true;
					_Width = 1200;
					_Level = 2;
					_Points = {
						{'TOP', '$parent.$parent', 'BOTTOM', 0, 0};
						{'BOTTOM', UIParent, 'BOTTOM', 0, 0};
					};
				};
				EscapeButton = {
					_Type = 'Button';
					_Hide = true;
					_Fill = true;
					_OnClick = function(self)
						local parent = self:GetParent()
						parent.GridFrame:Hide()
						parent.OverviewFrame:Hide()
						parent.BackgroundFrame:Hide()
					end;
				};
			};
		};
	})

	---------------------------------------------------------------
	-- Configure the headers and dropdowns
	---------------------------------------------------------------
	Mixin(Menu, env.MenuMixin)
	Menu:LoadArt()
	Menu:StartEnvironment()
	Menu:Execute('hID = 5; self:RunAttribute("SetHeader", hID)')
	Menu:SetAttribute('priorityoverride', true)
	Menu:DrawIndex(function(header)
		for i, button in ipairs({header:GetChildren()}) do
			if button:IsObjectType('Button') then
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
		end

		if not header.soundScriptAdded then
			header.soundScriptAdded = true;
			if IsRetailVersion then
				header:HookScript('OnClick', function()
					PlaySound(SOUNDKIT.UI_COVENANT_ANIMA_DIVERSION_CLOSE, 'Master', false, false)
				end)
			end
		end
		if (header:GetID() ~= 3) then
			local point, relativeTo, relativePoint, x = header:GetPoint()
			header:ClearAllPoints()
			header:SetPoint(point, relativeTo, relativePoint, x > 0 and x -40 or x +40, 0)
		end
	end)

	---------------------------------------------------------------
	-- Extend environment
	---------------------------------------------------------------
	for name, script in pairs({
		ShowHeader = [[
			local hID = ...
			local header = headers[hID]
			for _, child in ipairs(newtable(header:GetChildren())) do
				if child:IsProtected() then
					local condition = child:GetAttribute('condition')
					if condition then
						local show = self:Run(condition)
						if show then
							child:Show()
						else
							child:Hide()
						end
					else
						child:Show()
					end
				end
			end
		]],
		ClearHeader = [[
			for _, child in ipairs(newtable(header:GetChildren())) do
				child:Hide()
			end
		]],
	}) do Menu:AppendSecureScript(name, script) end

	---------------------------------------------------------------
	-- Display properties
	---------------------------------------------------------------
	local db = env.db;
	Menu:SetIgnoreParentAlpha(true)
	Menu:HookScript('OnShow', function(self)
		if ConsolePortCursor:IsShown() then
			ConsolePortCursor:Click()
		end

		db.UIHandle:SetHintFocus(self)
		db.Alpha.FadeIn(self, 0.1, self:GetAlpha(), 1)
		db.Alpha.FadeOut(UIParent, 0.1, UIParent:GetAlpha(), 0)

		if UIDoFramesIntersect(self, Minimap) and Minimap:IsShown() then
			self.minimapHidden = true
			if not Minimap:IsProtected() then Minimap:Hide() end
			if not MinimapCluster:IsProtected() then MinimapCluster:Hide() end
		end

		self.tooltipIgnoringAlpha = GameTooltip:IsIgnoringParentAlpha()
		GameTooltip:SetIgnoreParentAlpha(true)
	end)
	
	Menu:HookScript('OnHide', function(self)
		if db.UIHandle:IsHintFocus(self) then
			db.UIHandle:HideHintBar()
		end
		db.UIHandle:ClearHintsForFrame(self)
		db.Alpha.FadeIn(UIParent, 0.1, UIParent:GetAlpha(), 1)
		db.Alpha.FadeOut(self, 0.1, self:GetAlpha(), 0)

		if self.minimapHidden then
			self.minimapHidden = false
			if not Minimap:IsProtected() then Minimap:Show() end
			if not MinimapCluster:IsProtected() then MinimapCluster:Show() end
		end

		GameTooltip:SetIgnoreParentAlpha(self.tooltipIgnoringAlpha)
		self.tooltipIgnoringAlpha = nil;
	end)

	local r, g, b = CPAPI.GetClassColor()
	Mixin(Menu, CPBackgroundMixin)
	CPBackgroundMixin.OnLoad(Menu)
	Menu.Background:SetAllPoints()
	Menu.Background:SetVertexColor(r/5, g/5, b/5, 0.5)
	r, g, b = r / 10, g / 10, b / 10;
	Menu.Rollover:SetGradientAlpha('VERTICAL', r, g, b, 1, r, g, b, 0)

	---------------------------------------------------------------
	-- Initialize splash button
	---------------------------------------------------------------
	Mixin(Menu.Splash, env.SplashButtonMixin)
	Menu.Splash:Initialize(Menu)

	---------------------------------------------------------------
	-- Register frame
	---------------------------------------------------------------
	db.Stack:HideFrame(GameMenuFrame, true)
	db.Secure:RegisterUser(Menu)

	---------------------------------------------------------------
	-- Scale/overflow handling
	---------------------------------------------------------------
	function Menu:OnUIScaleChanged()
		self:SetScale(db('UIscale'))
	end
	Menu:SetScale(db('UIscale'))
	db:RegisterSafeCallback('Settings/UIscale', Menu.OnUIScaleChanged, Menu)
end