local _, env = ...;
---------------------------------------------------------------
local ICON = GenerateClosure(format, [[Interface\ICONS\%s]]);
local IsRetailVersion      = CPAPI.IsRetailVersion or nil;
local IsClassicGameVersion = CPAPI.IsClassicVersion or CPAPI.IsClassicEraVersion or nil;

local GenerateFlatClosure = GenerateFlatClosure or function(...)
	local closure = GenerateClosure(...)
	return function() return closure() end;
end;

local GetMaxLevelForLatestExpansion = GetMaxLevelForLatestExpansion or function()
	return MAX_PLAYER_LEVEL;
end;

---------------------------------------------------------------
env.Buttons = {}; _ = function(data) tinsert(env.Buttons, data) end;
---------------------------------------------------------------
-- Button definition:
---@param text  string   The text displayed on the button.
---@param icon  string   The path to the icon texture.
---@param ref   Button   Optional reference to the button to proxy clicks to.
---@param click function Optional function to call when the button is clicked.


---------------------------------------------------------------
--[[ ConsolePort ]] do _{
---------------------------------------------------------------
	img   = CPAPI.GetAsset([[Textures\Logo\CP]]);
	hint  = 'Open Config';
	click = function() ConsolePort() end;
	OnLoad = function(self)
		local size = IsRetailVersion and 64 or 48;
		local tlX, tlY = -7 / 64 * size, 3 / 64 * size;
		local brX, brY = 7 / 64 * size, -11 / 64 * size;
		self.Logo = self:CreateTexture(nil, 'OVERLAY', nil, 7)
		self.Logo:SetTexture(self.img)
		self.Logo:SetPoint('TOPLEFT', tlX, tlY)
		self.Logo:SetPoint('BOTTOMRIGHT', brX, brY)
	end;
} end;

---------------------------------------------------------------
--[[ Character ]] do _{
---------------------------------------------------------------
	text  = CHARACTER_BUTTON;
	ref   = IsRetailVersion and CharacterMicroButton;
	click = IsClassicGameVersion and GenerateFlatClosure(ToggleCharacter, 'PaperDollFrame');
	OnLoad = function(self)
		self:RegisterEvent('PLAYER_ENTERING_WORLD')
		self:RegisterEvent('PLAYER_LEVEL_UP')
		self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', 'player')
	end;
	UpdateLevel = function(self, newLevel)
		local level = newLevel or UnitLevel('player')
		if ( level and level < GetMaxLevelForLatestExpansion() ) then
			local color = CreateColor(1, 0.8, 0)
			self.subtitle = color:WrapTextInColorCode(level)
		else
			local color = CreateColor(CPAPI.GetItemLevelColor())
			self.subtitle = color:WrapTextInColorCode(CPAPI.GetAverageItemLevel())
		end
		self:Update()
	end;
	OnEvent = function(self, event, ...)
		if event == 'UNIT_PORTRAIT_UPDATE' then
			SetPortraitTexture(self.icon, 'player')
		elseif event == 'PLAYER_LEVEL_UP' then
			self:UpdateLevel(...)
		else
			SetPortraitTexture(self.icon, 'player')
			self:UpdateLevel()
		end
	end;
} end;

---------------------------------------------------------------
--[[ Inventory ]] do _{
---------------------------------------------------------------
	text  = INVENTORY_TOOLTIP;
	img   = ICON(IsRetailVersion and 'INV_Misc_Bag_29' or 'INV_Misc_Bag_08');
	ref   = IsRetailVersion and MainMenuBarBackpackButton;
	click = IsClassicGameVersion and ToggleAllBags;
	OnLoad = function(self)
		self:RegisterEvent('BAG_UPDATE_DELAYED')
	end;
	OnEvent = function(self)
		local totalFree, totalSlots = CPAPI.GetContainerTotalSlots()
		local percentageFree = totalFree / totalSlots;
		local color = percentageFree > .5 and GREEN_FONT_COLOR
			or percentageFree > .25 and YELLOW_FONT_COLOR
			or percentageFree > .10 and ORANGE_FONT_COLOR
			or RED_FONT_COLOR;
		self.subtitle = ('%s / %s'):format(
			color:WrapTextInColorCode(totalFree),
			GRAY_FONT_COLOR:WrapTextInColorCode(totalSlots)
		);
		self:Update()
	end;
} end;

---------------------------------------------------------------
--[[ Spec & Talents ]] do _{
---------------------------------------------------------------
	text  = PLAYERSPELLS_BUTTON or TALENTS_BUTTON;
	ref   = PlayerSpellsMicroButton or TalentMicroButton;
	OnLoad = function(self)
		local iconFile, iconTCoords = CPAPI.GetClassIcon(CPAPI.GetClassFile())
		self.icon:SetTexture(iconFile)
		self.icon:SetTexCoord(unpack(iconTCoords))
		CPAPI.RegisterFrameForEvents(self, {
			'PLAYER_ENTERING_WORLD';
			'UPDATE_BINDINGS';
			'NEUTRAL_FACTION_SELECT_RESULT';
			'PLAYER_TALENT_UPDATE';
			'PLAYER_SPECIALIZATION_CHANGED';
			'UPDATE_BATTLEFIELD_STATUS';
			'HONOR_LEVEL_UPDATE';
			'PLAYER_LEVEL_CHANGED';
		})
	end;
	OnEvent = PlayerSpellsMicroButtonMixin and function(self)
		local alert = PlayerSpellsMicroButtonMixin:GetHighestPriorityAlert()
		self.subtitle = alert and YELLOW_FONT_COLOR:WrapTextInColorCode(alert.text);
	end or nop; -- TODO: is there a Cataclysm version of this?
} end;

---------------------------------------------------------------
--[[ Professions ]] if ProfessionMicroButton then _{
---------------------------------------------------------------
	text = TRADE_SKILLS;
	img   = ICON('INV_Misc_Wrench_01');
	ref   = ProfessionMicroButton;
} end;

---------------------------------------------------------------
--[[ Spellbook ]] if SpellbookMicroButton then _{
---------------------------------------------------------------
	text  = SPELLBOOK_BUTTON;
	img   = [[Interface\Spellbook\Spellbook-Icon]];
	ref   = SpellbookMicroButton;
} end;

---------------------------------------------------------------
--[[ Collections ]] if CollectionsMicroButton then _{
---------------------------------------------------------------
	text  = COLLECTIONS;
	img   = ICON('inv_misc_enggizmos_19');
	ref   = CollectionsMicroButton;
	OnLoad = function(self)
		CPAPI.RegisterFrameForEvents(self, {
			'COMPANION_LEARNED';
			'PLAYER_ENTERING_WORLD';
			'PET_JOURNAL_LIST_UPDATE';
		})
	end;
	OnEvent = function(self)
		local numMountsNeedingFanfare = C_MountJournal.GetNumMountsNeedingFanfare()
		local numPetsNeedingFanfare = C_PetJournal.GetNumPetsNeedingFanfare()
		local hasFanfare  = numMountsNeedingFanfare + numPetsNeedingFanfare > 0;
		local hasFanfares = numMountsNeedingFanfare + numPetsNeedingFanfare > 1;
		local subtitle = ( hasFanfares and COLLECTION_UNOPENED_PLURAL ) or ( hasFanfare and COLLECTION_UNOPENED_SINGULAR ) or nil;
		self.subtitle = subtitle and YELLOW_FONT_COLOR:WrapTextInColorCode(subtitle);
	end;
} end;

---------------------------------------------------------------
--[[ Keyring ]] if KeyRingButton then _{
---------------------------------------------------------------
	text  = KEYRING;
	img   = [[Interface\ContainerFrame\KeyRing-Bag-Icon]];
	ref   = KeyRingButton;
} end;

---------------------------------------------------------------
--[[ Quest Log ]] do _{
---------------------------------------------------------------
	text  = IsRetailVersion and ('%s / %s'):format(WORLD_MAP, QUEST_LOG) or QUEST_LOG;
	img   = IsRetailVersion and ICON('INV_Misc_Map02') or [[Interface\QUESTFRAME\UI-QuestLog-BookIcon]];
	ref   = QuestLogMicroButton;
} end;

---------------------------------------------------------------
--[[ World Map ]] if MiniMapWorldMapButton or WorldMapMicroButton then _{
---------------------------------------------------------------
	text  = WORLD_MAP;
	img   = [[Interface\WorldMap\WorldMap-Icon]];
	ref   = MiniMapWorldMapButton or WorldMapMicroButton;
} end;

---------------------------------------------------------------
--[[ Guide ]] if EJMicroButton then _{
---------------------------------------------------------------
	text  = ADVENTURE_JOURNAL;
	img   = [[Interface\ENCOUNTERJOURNAL\UI-EJ-PortraitIcon]];
	ref   = EJMicroButton;
	-- TODO: UpdateNewAdventureNotice/ClearNewAdventureNotice
} end;

---------------------------------------------------------------
--[[ Finder ]] do _{
---------------------------------------------------------------
	text  = DUNGEONS_BUTTON;
	img   = [[Interface\LFGFRAME\UI-LFG-PORTRAIT]];
	ref   = LFDMicroButton or LFGMicroButton;
	click = CPAPI.IsClassicVersion and GenerateFlatClosure(PVEFrame_ToggleFrame);
	OnLoad = CPAPI.IsClassicEraVersion and function(self)
		self.OnLoad = nil;
		EventUtil.ContinueOnAddOnLoaded('Blizzard_GroupFinder_VanillaStyle', function()
			env.db:RunSafe(function()
				self:SetData({ ref = LFGMinimapFrame });
			end);
		end)
	end;
} end;

---------------------------------------------------------------
--[[ PvP ]] if IsClassicGameVersion and (PVPFrame or PVPParentFrame) then _{
---------------------------------------------------------------
	text  = PLAYER_V_PLAYER;
	img   = ICON(('Achievement_PVP_%1$s_%1$s'):format(UnitFactionGroup('player'):sub(1,1)));
	click = GenerateFlatClosure(ShowUIPanel, PVPFrame or PVPParentFrame);
} end;

---------------------------------------------------------------
--[[ Achievements ]]  if AchievementMicroButton then _{
---------------------------------------------------------------
	text  = ACHIEVEMENTS;
	img   = ICON('ACHIEVEMENT_WIN_WINTERGRASP');
	ref   = AchievementMicroButton;
} end;

---------------------------------------------------------------
--[[ Shop ]] if StoreMicroButton then _{
---------------------------------------------------------------
	text  = BLIZZARD_STORE;
	img   = IsRetailVersion and ICON('WoW_Store') or [[Interface\MERCHANTFRAME\UI-BuyBack-Icon]];
	ref   = StoreMicroButton;
} end;

---------------------------------------------------------------
--[[ Calendar ]] if GameTimeFrame and GameTimeFrame:IsObjectType('Button') then _{
---------------------------------------------------------------
	text  = EVENTS_LABEL;
	img   = [[Interface\Calendar\MeetingIcon]];
	ref   = GameTimeFrame;
} end;

---------------------------------------------------------------
--[[ Leave Scenarios ]] do _{
---------------------------------------------------------------
	states = {
		{
			text      = TAXI_CANCEL;
			subtitle  = TAXI_CANCEL_DESCRIPTION;
			predicate = GenerateFlatClosure(UnitOnTaxi, 'player');
			command   = TaxiRequestEarlyLanding;
			image     = [[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]];
		};
		{
			text      = BINDING_NAME_VEHICLEEXIT;
			predicate = CanExitVehicle;
			command   = VehicleExit;
			image     = [[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]];
		};
		{
			text      = TELEPORT_OUT_OF_DUNGEON;
			predicate = IsInLFGDungeon;
			command   = GenerateFlatClosure(LFGTeleport, true);
			image     = ICON('Spell_Shadow_Teleport');
		};
		{
			text      = TELEPORT_TO_DUNGEON;
			predicate = IsPartyLFG;
			command   = GenerateFlatClosure(LFGTeleport, false);
			image     = ICON('Spell_Shadow_Teleport');
		};
		{
			text      = PARTY_LEAVE;
			predicate = IsInGroup;
			command   = CPAPI.LeaveParty;
			image     = ICON('Spell_Shadow_Teleport');
		};
		{
			text      = LEAVE_ALL;
			predicate = function() return true end;
			command   = nop;
			image     = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
		};
	};
	OnLoad = function(self)
		CPAPI.RegisterFrameForEvents(self, {
			'UPDATE_BONUS_ACTIONBAR';
			'UPDATE_MULTI_CAST_ACTIONBAR';
			'UNIT_ENTERED_VEHICLE';
			'UNIT_EXITED_VEHICLE';
			'VEHICLE_UPDATE';
		})
		self.click = function()
			for _, state in ipairs(self.states) do
				if state.predicate() then
					return state.command()
				end
			end
		end
	end;
	OnShow = function(self)
		self:OnEvent()
	end;
	OnEvent = function(self)
		for _, state in ipairs(self.states) do
			if state.predicate() then
				self.text     = state.text;
				self.subtitle = state.subtitle and YELLOW_FONT_COLOR:WrapTextInColorCode(state.subtitle) or nil;
				self.img      = state.image;
				return self.icon:SetTexture(self.img)
			end
		end
	end;
} end;

---------------------------------------------------------------
--[[ Player Options ]] do _{
---------------------------------------------------------------
	text  = PLAYER_OPTIONS_LABEL;
	ref   = env.db.UnitMenuSecure;
	OnEvent = function(self, event, ...)
		if event == 'UNIT_PORTRAIT_UPDATE' then
			SetPortraitTexture(self.icon, ...)
		elseif event == 'PLAYER_TARGET_CHANGED' then
			self:UpdateUnit()
		end
	end;
	OnShow = function(self)
		self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', self.unit)
		self:RegisterEvent('PLAYER_TARGET_CHANGED')
		self:UpdateUnit()
	end;
	OnHide = function(self)
		self:UnregisterAllEvents()
	end;
	UpdateUnit = function(self)
		self.unit = env.db.UnitMenuSecure:GetPreferredUnit()
		self.text = UnitIsPlayer(self.unit) and PLAYER_OPTIONS_LABEL or TARGET;
		self.subtitle = CPAPI.GetPlayerName(true, self.unit)
		self:OnEvent('UNIT_PORTRAIT_UPDATE', self.unit)
		self:Update()
	end;
} end;

---------------------------------------------------------------
--[[ Friends ]] do _{
---------------------------------------------------------------
	text  = FRIENDS_LIST;
	img   = [[Interface\FriendsFrame\Battlenet-Portrait]];
	ref   = IsRetailVersion and QuickJoinToastButton or SocialsMicroButton or FriendsMicroButton;
	OnLoad = function(self)
		self:RegisterEvent('FRIENDLIST_UPDATE')
		self:RegisterEvent('BN_FRIEND_INFO_CHANGED')
		self:RegisterEvent('PLAYER_ENTERING_WORLD')
	end;
	OnEvent = function(self)
		local numBNetOnline, numBNetFavoriteOnline, _;
		if IsRetailVersion then
			_, numBNetOnline, _, numBNetFavoriteOnline = BNGetNumFriends()
		else
			numBNetFavoriteOnline, _, numBNetOnline = 0, BNGetNumFriends();
		end
		local numWoWOnline = C_FriendList.GetNumFriends()
		local counters = {};
		if numBNetFavoriteOnline > 0 then tinsert(counters, YELLOW_FONT_COLOR:WrapTextInColorCode(numBNetFavoriteOnline)) end;
		if numWoWOnline          > 0 then tinsert(counters, GREEN_FONT_COLOR:WrapTextInColorCode(numWoWOnline)) end;
		if numBNetOnline         > 0 then tinsert(counters, BLUE_FONT_COLOR:WrapTextInColorCode(numBNetOnline)) end;
		self.subtitle = (#counters > 0) and table.concat(counters, ' | ') or nil;
	end;
} end;

---------------------------------------------------------------
--[[ Guild ]] do _{
---------------------------------------------------------------
	text  = IsRetailVersion and GUILD_AND_COMMUNITIES or GUILD;
	img   = ICON('Achievement_GuildPerk_EverybodysFriend');
	ref   = GuildMicroButton;
	OnLoad = function(self)
		CPAPI.RegisterFrameForEvents(self, {
			'BN_CONNECTED';
			'BN_DISCONNECTED';
			'CHAT_DISABLED_CHANGE_FAILED';
			'CHAT_DISABLED_CHANGED';
			'CLUB_FINDER_COMMUNITY_OFFLINE_JOIN';
			'CLUB_INVITATION_ADDED_FOR_SELF';
			'CLUB_INVITATION_REMOVED_FOR_SELF';
			'INITIAL_CLUBS_LOADED';
			'NEUTRAL_FACTION_SELECT_RESULT';
			'PLAYER_ENTERING_WORLD';
			'PLAYER_GUILD_UPDATE';
			'STREAM_VIEW_MARKER_UPDATED';
		})
	end;
	OnEvent = function(self)
		if CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages() then
			self.subtitle = COMMUNITIES_CHAT_FRAME_UNREAD_MESSAGES_NOTIFICATION;
			return;
		end

		local numTotalGuildMembers, numOnlineGuildMembers = GetNumGuildMembers()
		if ( numTotalGuildMembers == 0 ) then
			self.subtitle = nil;
			return;
		end
		self.subtitle = ('%s / %s'):format(
			GREEN_FONT_COLOR:WrapTextInColorCode(numOnlineGuildMembers),
			GRAY_FONT_COLOR:WrapTextInColorCode(numTotalGuildMembers)
		);
	end;
} end;

---------------------------------------------------------------
--[[ Raid ]] do _{
---------------------------------------------------------------
	text  = RAID;
	img   = [[Interface\LFGFRAME\UI-LFR-PORTRAIT]];
	click = ToggleRaidFrame;
} end;