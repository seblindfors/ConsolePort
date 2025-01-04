local _, db = ...; CPAPI = {};
---------------------------------------------------------------
-- General
---------------------------------------------------------------
-- return true or nil (nil for dynamic table insertions)
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC or nil;
CPAPI.IsRetailVersion     = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or nil;
CPAPI.IsClassicEraVersion = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or nil;

function CPAPI.Log(...)
	local cc = ChatTypeInfo.SYSTEM;
	DEFAULT_CHAT_FRAME:AddMessage(db.Locale(...), cc.r, cc.g, cc.b, cc.id)
end

---------------------------------------------------------------
-- API Wrappers
---------------------------------------------------------------
local function GetClassInfo() return UnitClass('player') end
local function GetClassID()   return select(3, UnitClass('player')) end

function CPAPI.GetClassFile()
	return db('classFileOverride') or select(2, UnitClass('player'))
end

function CPAPI.GetSpecialization()
	-- returns specializationID on retail
	if GetSpecialization then
		local currentSpecialization = GetSpecialization()
		if currentSpecialization then
			return GetSpecializationInfo(currentSpecialization)
		end
	end
	-- returns classID on classic
	return GetClassID()
end

function CPAPI.GetSpecTextureByID(ID)
	-- returns specTexture on retail
	if GetSpecializationInfoByID then
		return select(4, GetSpecializationInfoByID(ID))
	-- returns classTexture on classic
	elseif C_CreatureInfo and C_CreatureInfo.GetClassInfo then
		local classInfo = C_CreatureInfo.GetClassInfo(ID)
		if classInfo then
			return ([[Interface\ICONS\ClassIcon_%s.blp]]):format(classInfo.classFile)
		end
	end
end

function CPAPI.GetCharacterMetadata()
	-- returns specID, specName on retail
	if GetSpecializationInfo and GetSpecialization then
		return GetSpecializationInfo(GetSpecialization())
	end
	-- returns classID, localized class token on classic
	return GetClassID(), GetClassInfo()
end

function CPAPI.GetItemLevelColor(...)
	if GetItemLevelColor then
		return GetItemLevelColor(...)
	end
	local r, g, b = CPAPI.GetClassColor()
	return r, g, b;
end

function CPAPI.GetAverageItemLevel(...)
	if GetAverageItemLevel then
		return floor(select(2, GetAverageItemLevel(...)))
	end
	-- TODO: Some simple method of calculating average ilvl on Classic
	if GetClassicExpansionLevel and MAX_PLAYER_LEVEL_TABLE then
		return MAX_PLAYER_LEVEL_TABLE[GetClassicExpansionLevel()]
	end
	return MAX_PLAYER_LEVEL
end

function CPAPI.GetContainerTotalSlots()
	local totalFree, totalSlots, freeSlots, bagFamily = 0, 0;
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		freeSlots, bagFamily = CPAPI.GetContainerNumFreeSlots(i)
		if ( bagFamily == 0 ) then
			totalFree  = totalFree + freeSlots;
			totalSlots = totalSlots + CPAPI.GetContainerNumSlots(i)
		end
	end
	return totalFree, totalSlots;
end

---------------------------------------------------------------
-- Button constants
---------------------------------------------------------------
CPAPI.ExtraActionButtonID = ExtraActionButton1 and ExtraActionButton1.action or
	CPAPI.IsRetailVersion and 217 or 169;

CPAPI.ActionTypeRelease  = CPAPI.IsRetailVersion and 'typerelease' or 'type';
CPAPI.ActionTypePress    = 'type';
CPAPI.ActionPressAndHold = 'pressAndHoldAction';

CPAPI.DefaultRingSetID = 1;

CPAPI.SkipHotkeyRender = 'ignoregamepadhotkey';
CPAPI.UseCustomFlyout  = 'usegamepadflyout';

CPAPI.RaidCursorUnit   = 'cursorunit';

---------------------------------------------------------------
-- Internal wrappers
---------------------------------------------------------------
function CPAPI.IsButtonValidForBinding(button)
	return db('bindingAllowSticks') or (not button:match('PAD.STICK.+'))
end

function CPAPI.GetKeyChordParts(keyChord)
	return
	--[[buttonID]] (keyChord:match('PAD.+')),
	--[[modifier]] (keyChord:gsub('PAD.+', ''));
end

---------------------------------------------------------------
-- Lua wrappers
---------------------------------------------------------------
CPAPI.CreateColorFromHexString = CreateColorFromHexString or function(hexColor)
	if #hexColor == 8 then
		local function ExtractColorValueFromHex(str, index)
			return tonumber(str:sub(index, index + 1), 16) / 255;
		end
		local a, r, g, b =
			ExtractColorValueFromHex(hexColor, 1),
			ExtractColorValueFromHex(hexColor, 3),
			ExtractColorValueFromHex(hexColor, 5),
			ExtractColorValueFromHex(hexColor, 7);
		return CreateColor(r, g, b, a);
	end
end

CPAPI.CreateKeyChord = CreateKeyChordStringUsingMetaKeyState or (function()
	local function CreateKeyChordStringFromTable(keys, preventSort)
		if not preventSort then
			table.sort(keys, KeyComparator)
		end
		return table.concat(keys, "-")
	end

	return function(key)
		local chord = {};
		if IsAltKeyDown() then
			table.insert(chord, "ALT")
		end

		if IsControlKeyDown() then
			table.insert(chord, "CTRL")
		end

		if IsShiftKeyDown() then
			table.insert(chord, "SHIFT")
		end

		if IsMetaKeyDown() then
			table.insert(chord, "META")
		end

		if not IsMetaKey(key) then
			table.insert(chord, key)
		end

		local preventSort = true;
		return CreateKeyChordStringFromTable(chord, preventSort)
	end
end)()

CPAPI.MinEditDistance = CalculateStringEditDistance or function(str1, str2)
	-- Wagner–Fischer algorithm
	local len1, len2, min, byte = #str1, #str2, math.min, string.byte;
	local matrix = {}
	for i = 0, len1 do
		matrix[i] = { [0] = i };
	end
	for j = 0, len2 do
		matrix[0][j] = j;
	end
	for i = 1, len1 do
		for j = 1, len2 do
			local cost = (byte(str1, i) == byte(str2, j)) and 0 or 1;
			matrix[i][j] = min(
				matrix[i-1][j] + 1,
				matrix[i][j-1] + 1,
				matrix[i-1][j-1] + cost
			);
		end
	end
	return matrix[len1][len2];
end

CPAPI.IteratePlayerInventory = ContainerFrameUtil_IteratePlayerInventory or function(callback)
	local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS or 36;
	local NUM_BAG_FRAMES = NUM_BAG_FRAMES or 4;

	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, MAX_CONTAINER_ITEMS do
			local bagItem = ItemLocation:CreateFromBagAndSlot(bag, slot);
			if C_Item.DoesItemExist(bagItem) then
				callback(bagItem);
			end
		end
	end
end

CPAPI.OpenStackSplitFrame = OpenStackSplitFrame or function(...)
	return StackSplitFrame:OpenStackSplitFrame(...)
end

CPAPI.CreateSimpleTextureMarkup = CreateSimpleTextureMarkup or function(file, width, height)
	return ("|T%s:%d:%d|t"):format(
		  file
		, height or width
		, width
	);
end

CPAPI.HideAndClearAnchors = FramePool_HideAndClearAnchors or function(framePool, frame)
	frame:Hide()
	frame:ClearAllPoints()
end

CPAPI.HideAndClearAnchorsWithReset = FramePool_HideAndClearAnchorsWithReset or function(framePool, frame)
	frame:Hide()
	frame:ClearAllPoints()
	frame:Reset()
end

---------------------------------------------------------------
do -- API wrappers
---------------------------------------------------------------
local function nopz() return 0  end;
local function nopt() return {} end;

-- Namespace wrappers
CPAPI.ContainerIDToInventoryID       = C_Container     and C_Container.ContainerIDToInventoryID          or ContainerIDToInventoryID;
CPAPI.DisableAddOn                   = C_AddOns        and C_AddOns.DisableAddOn                         or DisableAddOn;
CPAPI.EnableAddOn                    = C_AddOns        and C_AddOns.EnableAddOn                          or EnableAddOn;
CPAPI.GetActiveZoneAbilities         = C_ZoneAbility   and C_ZoneAbility.GetActiveAbilities              or nopt;
CPAPI.GetAddOnInfo                   = C_AddOns        and C_AddOns.GetAddOnInfo                         or GetAddOnInfo;
CPAPI.GetBonusBarIndexForSlot        = C_ActionBar     and C_ActionBar.GetBonusBarIndexForSlot           or nop;
CPAPI.GetCollectedDragonridingMounts = C_MountJournal  and C_MountJournal.GetCollectedDragonridingMounts or nopt;
CPAPI.GetContainerItemID             = C_Container     and C_Container.GetContainerItemID                or GetContainerItemID;
CPAPI.GetContainerItemQuestInfo      = C_Container     and C_Container.GetContainerItemQuestInfo         or GetContainerItemQuestInfo;
CPAPI.GetContainerNumFreeSlots       = C_Container     and C_Container.GetContainerNumFreeSlots          or GetContainerNumFreeSlots;
CPAPI.GetContainerNumSlots           = C_Container     and C_Container.GetContainerNumSlots              or GetContainerNumSlots;
CPAPI.GetFactionParagonInfo          = C_Reputation    and C_Reputation.GetFactionParagonInfo            or nop;
CPAPI.GetFriendshipReputation        = C_GossipInfo    and C_GossipInfo.GetFriendshipReputation          or GetFriendshipReputation or nopt;
CPAPI.GetFriendshipReputationRanks   = C_GossipInfo    and C_GossipInfo.GetFriendshipReputationRanks     or nop;
CPAPI.GetItemCount                   = C_Item          and C_Item.GetItemCount                           or GetItemCount;
CPAPI.GetItemLink                    = C_Item          and C_Item.GetItemLink                            or nop;
CPAPI.GetItemQuality                 = C_Item          and C_Item.GetItemQuality                         or nop;
CPAPI.GetItemSpell                   = C_Item          and C_Item.GetItemSpell                           or GetItemSpell;
CPAPI.GetMajorFactionData            = C_MajorFactions and C_MajorFactions.GetMajorFactionData           or nop;
CPAPI.GetMountFromItem               = C_MountJournal  and C_MountJournal.GetMountFromItem               or nop;
CPAPI.GetMountFromSpell              = C_MountJournal  and C_MountJournal.GetMountFromSpell              or nop;
CPAPI.GetMountInfoByID               = C_MountJournal  and C_MountJournal.GetMountInfoByID               or nop;
CPAPI.GetNumQuestWatches             = C_QuestLog      and C_QuestLog.GetNumQuestWatches                 or nopz;
CPAPI.GetNumSpellTabs                = C_SpellBook     and C_SpellBook.GetNumSpellBookSkillLines         or GetNumSpellTabs;
CPAPI.GetQuestLogIndexForQuestID     = C_QuestLog      and C_QuestLog.GetLogIndexForQuestID              or nop;
CPAPI.GetRenownLevels                = C_MajorFactions and C_MajorFactions.GetRenownLevels               or nop;
CPAPI.GetSpellBookItemLink           = C_SpellBook     and C_SpellBook.GetSpellBookItemLink              or GetSpellLink;
CPAPI.GetSpellBookItemTexture        = C_SpellBook     and C_SpellBook.GetSpellBookItemTexture           or GetSpellBookItemTexture;
CPAPI.GetSpellBookItemType           = C_SpellBook     and C_SpellBook.GetSpellBookItemType              or GetSpellBookItemInfo;
CPAPI.GetSpellLink                   = C_Spell         and C_Spell.GetSpellLink                          or GetSpellLink;
CPAPI.GetSpellName                   = C_Spell         and C_Spell.GetSpellName                          or GetSpellName;
CPAPI.GetSpellSubtext                = C_Spell         and C_Spell.GetSpellSubtext                       or GetSpellSubtext;
CPAPI.GetSpellTexture                = C_Spell         and C_Spell.GetSpellTexture                       or GetSpellTexture;
CPAPI.HasPetSpells                   = C_SpellBook     and C_SpellBook.HasPetSpells                      or HasPetSpells;
CPAPI.IsAccountWideReputation        = C_Reputation    and C_Reputation.IsAccountWideReputation          or nop;
CPAPI.IsAddOnLoaded                  = C_AddOns        and C_AddOns.IsAddOnLoaded                        or IsAddOnLoaded;
CPAPI.IsDressableItemByID            = C_Item          and C_Item.IsDressableItemByID                    or nop;
CPAPI.IsEquippableItem               = C_Item          and C_Item.IsEquippableItem                       or IsEquippableItem;
CPAPI.IsEquippedItem                 = C_Item          and C_Item.IsEquippedItem                         or IsEquippedItem;
CPAPI.IsFactionParagon               = C_Reputation    and C_Reputation.IsFactionParagon                 or nop;
CPAPI.IsMajorFaction                 = C_Reputation    and C_Reputation.IsMajorFaction                   or nop;
CPAPI.IsPassiveSpell                 = C_Spell         and C_Spell.IsSpellPassive                        or IsPassiveSpell;
CPAPI.IsSpellHarmful                 = C_Spell         and C_Spell.IsSpellHarmful                        or IsHarmfulSpell;
CPAPI.IsSpellHelpful                 = C_Spell         and C_Spell.IsSpellHelpful                        or IsHelpfulSpell;
CPAPI.IsUsableItem                   = C_Item          and C_Item.IsUsableItem                           or IsUsableItem;
CPAPI.LeaveParty                     = C_PartyInfo     and C_PartyInfo.LeaveParty                        or LeaveParty;
CPAPI.LoadAddOn                      = C_AddOns        and C_AddOns.LoadAddOn                            or LoadAddOn;
CPAPI.PickupContainerItem            = C_Container     and C_Container.PickupContainerItem               or PickupContainerItem;
CPAPI.PickupItem                     = C_Item          and C_Item.PickupItem                             or PickupItem;
CPAPI.PickupSpell                    = C_Spell         and C_Spell.PickupSpell                           or PickupSpell;
CPAPI.PickupSpellBookItem            = C_SpellBook     and C_SpellBook.PickupSpellBookItem               or PickupSpellBookItem;
CPAPI.PutActionInSlot                = C_ActionBar     and C_ActionBar.PutActionInSlot                   or PlaceAction;
CPAPI.RequestLoadQuestByID           = C_QuestLog      and C_QuestLog.RequestLoadQuestByID               or nop;
CPAPI.RunMacroText                   = C_Macro         and C_Macro.RunMacroText                          or RunMacroText;
CPAPI.SplitContainerItem             = C_Container     and C_Container.SplitContainerItem                or SplitContainerItem;
CPAPI.UseContainerItem               = C_Container     and C_Container.UseContainerItem                  or UseContainerItem;
-- Fallthroughs
CPAPI.ClearCursor                    = ClearCursor        or nop;
CPAPI.GetOverrideBarSkin             = GetOverrideBarSkin or nop;
CPAPI.GetSpecializationInfoByID      = GetSpecializationInfoByID or nop;
CPAPI.IsInLFDBattlefield             = IsInLFDBattlefield or nop;
CPAPI.IsInLFGDungeon                 = IsInLFGDungeon     or nop;
CPAPI.IsPartyLFG                     = IsPartyLFG         or nop;
CPAPI.IsSpellOverlayed               = IsSpellOverlayed   or nop;
CPAPI.IsXPUserDisabled               = IsXPUserDisabled   or nop;
CPAPI.PlayerHasToy                   = PlayerHasToy       or nop;

-- Complex wrappers
CPAPI.GetContainerItemInfo = function(...)
	if C_Container and C_Container.GetContainerItemInfo then
		return C_Container.GetContainerItemInfo(...) or {};
	end
	if GetContainerItemInfo then
		local icon, itemCount, locked, quality, readable, lootable, itemLink,
			isFiltered, noValue, itemID, isBound = GetContainerItemInfo(...)
		return {
			--[[ ContainerItemInfo ]]
			--[[ boolean          ]] hasLoot = lootable;
			--[[ boolean          ]] hasNoValue = noValue;
			--[[ itemLink         ]] hyperlink = itemLink;
			--[[ FileID           ]] iconFileID = icon;
			--[[ boolean          ]] isBound = isBound;
			--[[ boolean          ]] isFiltered = isFiltered;
			--[[ boolean          ]] isLocked = locked;
			--[[ boolean          ]] isReadable = readable;
			--[[ number           ]] itemID = itemID;
			--[[ Enum.ItemQuality ]] quality = quality;
			--[[ number           ]] stackCount = itemCount;
		};
	end
	return {};
end

CPAPI.GetItemInfo = function(...)
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
	itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
	expacID, setID, isCraftingReagent = (GetItemInfo or C_Item.GetItemInfo)(...)

	return {
		--[[ ItemInfo ]]
		--[[ string           ]] itemName = itemName;
		--[[ itemLink         ]] itemLink = itemLink;
		--[[ Enum.ItemQuality ]] itemQuality = itemQuality;
		--[[ number           ]] itemLevel = itemLevel;
		--[[ number           ]] itemMinLevel = itemMinLevel;
		--[[ ItemType         ]] itemType = itemType;
		--[[ ItemType         ]] itemSubType = itemSubType;
		--[[ number           ]] itemStackCount = itemStackCount;
		--[[ ItemEquipLoc     ]] itemEquipLoc = itemEquipLoc;
		--[[ number           ]] itemTexture = itemTexture;
		--[[ number           ]] sellPrice = sellPrice;
		--[[ ItemType         ]] classID = classID;
		--[[ ItemType         ]] subclassID = subclassID;
		--[[ Enum.ItemBind    ]] bindType = bindType;
		--[[ LE_EXPANSION     ]] expacID = expacID;
		--[[ ItemSetID        ]] setID = setID;
		--[[ boolean          ]] isCraftingReagent = isCraftingReagent;
	};
end

CPAPI.GetSpellInfo = function(...)
	if GetSpellInfo then
		local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(...)
		return {
			--[[ SpellInfo ]]
			--[[ string           ]] name = name;
			--[[ string           ]] rank = rank;
			--[[ FileID           ]] iconID = icon;
			--[[ number           ]] castTime = castTime;
			--[[ number           ]] minRange = minRange;
			--[[ number           ]] maxRange = maxRange;
			--[[ number           ]] spellID = spellID;
			--[[ FileID           ]] originalIconID = originalIcon;
		};
	end
	return C_Spell.GetSpellInfo(...) or {};
end

CPAPI.GetSpellTabInfo = function(...)
	if GetSpellTabInfo then
		local name, texture, offset, numSlots, isGuild, offSpecID, shouldHide, specID = GetSpellTabInfo(...)
		return {
			--[[ SpellBookSkillLineInfo ]]
			--[[ string           ]] name = name;
			--[[ FileID           ]] iconID = texture;
			--[[ number           ]] itemIndexOffset = offset;
			--[[ number           ]] numSpellBookItems = numSlots;
			--[[ boolean          ]] isGuild = isGuild;
			--[[ number           ]] offSpecID = offSpecID;
			--[[ boolean          ]] shouldHide = shouldHide;
			--[[ number           ]] specID = specID;
		};
	end
	return C_SpellBook.GetSpellBookSkillLineInfo(...) or {};
end

CPAPI.GetItemInfoInstant = function(...)
	if GetItemInfoInstant then
		local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(...)
		return {
			--[[ ItemInfo ]]
			--[[ number           ]] itemID = itemID;
			--[[ ItemType         ]] itemType = itemType;
			--[[ ItemType         ]] itemSubType = itemSubType;
			--[[ ItemEquipLoc     ]] itemEquipLoc = itemEquipLoc;
			--[[ FileID           ]] icon = icon;
			--[[ ItemType         ]] classID = classID;
			--[[ ItemType         ]] subclassID = subclassID;
		};
	end
	return {};
end

CPAPI.GetLootSlotInfo = function(...)
	local lootIcon, lootName, lootQuantity, currencyID, lootQuality,
	locked, isQuestItem, questID, isActive = GetLootSlotInfo(...)

	return {
		--[[ LootSlotInfo ]]
		--[[ string           ]] lootIcon = lootIcon;
		--[[ string           ]] lootName = lootName;
		--[[ number           ]] lootQuantity = lootQuantity;
		--[[ number           ]] currencyID = currencyID;
		--[[ Enum.ItemQuality ]] lootQuality = lootQuality;
		--[[ boolean          ]] locked = locked;
		--[[ boolean          ]] isQuestItem = isQuestItem;
		--[[ number           ]] questID = questID;
		--[[ boolean          ]] isActive = isActive;
		--[[ itemLink         ]] lootLink = GetLootSlotLink(...);
	}
end

CPAPI.GetQuestInfo = function(...)
	if C_QuestLog and C_QuestLog.GetInfo then
		return C_QuestLog.GetInfo(...) or {};
	end
	if GetQuestLogTitle then
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
		frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
		isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(...)
		return {
			--[[ QuestInfo ]]
			--[[ string           ]] title = title;
			--[[ number           ]] level = level;
			--[[ number           ]] suggestedGroup = suggestedGroup;
			--[[ boolean          ]] isHeader = isHeader;
			--[[ boolean          ]] isCollapsed = isCollapsed;
			--[[ boolean          ]] isComplete = isComplete;
			--[[ Enum.QuestFrequency ]] frequency = frequency;
			--[[ number           ]] questID = questID;
			--[[ number           ]] startEvent = startEvent;
			--[[ number           ]] displayQuestID = displayQuestID;
			--[[ boolean          ]] isOnMap = isOnMap;
			--[[ boolean          ]] hasLocalPOI = hasLocalPOI;
			--[[ boolean          ]] isTask = isTask;
			--[[ boolean          ]] isBounty = isBounty;
			--[[ boolean          ]] isStory = isStory;
			--[[ boolean          ]] isHidden = isHidden;
			--[[ boolean          ]] isScaling = isScaling;
		};
	end
	return {};
end

CPAPI.GetWatchedFactionData = function(...)
	if C_Reputation and C_Reputation.GetWatchedFactionData then
		return C_Reputation.GetWatchedFactionData(...)
	end
	if GetWatchedFactionInfo then
		local name, standingID, min, max, value, factionID = GetWatchedFactionInfo(...)
		return {
			--[[ FactionData ]]
			--[[ string           ]] name = name;
			--[[ number           ]] reaction = standingID;
			--[[ number           ]] currentReactionThreshold = min;
			--[[ number           ]] nextReactionThreshold = max;
			--[[ number           ]] currentStanding = value;
			--[[ number           ]] factionID = factionID;
		};
	end
end

CPAPI.CanPlayerDisenchantItem = function(itemID)
	local spellID = CPAPI.GetSpellInfo('Disenchant').spellID;
	if spellID and IsPlayerSpell(spellID) then
		local info = CPAPI.GetItemInfo(itemID)
		local class, quality = info.classID, info.itemQuality;
		if class and quality then
			return
				(class == Enum.ItemClass.Weapon or class == Enum.ItemClass.Armor)
				and quality >= (Enum.ItemQuality.Good or Enum.ItemQuality.Uncommon)
				and quality <= (Enum.ItemQuality.Epic);
		end
	end
	return false;
end

CPAPI.GetMacroInfo = function(macroID)
	local name, icon, body = GetMacroInfo(macroID)
	if name then
		return {
			--[[ MacroInfo ]]
			--[[ string    ]] name = name;
			--[[ FileID    ]] icon = icon;
			--[[ string    ]] body = body;
		};
	end
end

CPAPI.GetAllMacroInfo = function()
	local info = {};
	for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
		info[i] = CPAPI.GetMacroInfo(i);
	end
	return info;
end

end -- API wrappers

---------------------------------------------------------------
-- Widget wrappers
---------------------------------------------------------------

function CPAPI.SetGradient(...)
	return LibStub('Carpenter'):SetGradient(...)
end

function CPAPI.SetModelLight(self, enabled, lightValues)
	if (pcall(self.SetLight, self, enabled, lightValues)) then
		return
	end

	local dirX, dirY, dirZ = lightValues.point:GetXYZ()
	local ambR, ambG, ambB = lightValues.ambientColor:GetRGB()
	local difR, difG, difB = lightValues.diffuseColor:GetRGB()

	return (pcall(self.SetLight, self, enabled,
		lightValues.omnidirectional,
		dirX, dirY, dirZ,
		lightValues.diffuseIntensity,
		difR, difG, difB,
		lightValues.ambientIntensity,
		ambR, ambG, ambB
	))
end

function CPAPI.AutoCastStart(self, autoCastAllowed, ...)
	if (self.Shine or self.AutoCastShine) and AutoCastShine_AutoCastStart then
		return AutoCastShine_AutoCastStart(self.Shine or self.AutoCastShine, ...)
	end
	if self.AutoCastOverlay and self.AutoCastOverlay.ShowAutoCastEnabled then
		self.AutoCastOverlay:SetShown(autoCastAllowed)
		return self.AutoCastOverlay:ShowAutoCastEnabled(true)
	end
end

function CPAPI.AutoCastStop(self, autoCastAllowed)
	if (self.Shine or self.AutoCastShine) and AutoCastShine_AutoCastStop then
		return AutoCastShine_AutoCastStop(self.Shine or self.AutoCastShine)
	end
	if self.AutoCastOverlay and self.AutoCastOverlay.ShowAutoCastEnabled then
		self.AutoCastOverlay:SetShown(autoCastAllowed)
		return self.AutoCastOverlay:ShowAutoCastEnabled(false)
	end
end