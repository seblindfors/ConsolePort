local _, db = ...; CPAPI = {};
---------------------------------------------------------------
-- General 
---------------------------------------------------------------
-- return true or nil (nil for dynamic table insertions)
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC or nil;
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
		return GetSpecialization()
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

---------------------------------------------------------------
-- Action button info
---------------------------------------------------------------
CPAPI.ExtraActionButtonID = ExtraActionButton1 and ExtraActionButton1.action or
	CPAPI.IsRetailVersion and 217 or 169;

CPAPI.ActionTypeRelease = CPAPI.IsRetailVersion and 'typerelease' or 'type';
CPAPI.ActionTypePress   = 'type';

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
-- Classic lua wrappers
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

CPAPI.CreateKeyChord = CreateKeyChordStringUsingMetaKeyState or function(key)
	local function CreateKeyChordStringFromTable(keys, preventSort)
		if not preventSort then
			table.sort(keys, KeyComparator);
		end

		return table.concat(keys, "-");
	end

	local chord = {};
	if IsAltKeyDown() then
		table.insert(chord, "ALT");
	end

	if IsControlKeyDown() then
		table.insert(chord, "CTRL");
	end

	if IsShiftKeyDown() then
		table.insert(chord, "SHIFT");
	end

	if IsMetaKeyDown() then
		table.insert(chord, "META");
	end

	if not IsMetaKey(key) then
		table.insert(chord, key);
	end

	local preventSort = true;
	return CreateKeyChordStringFromTable(chord, preventSort);
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

CPAPI.GetContainerItemInfo = function(...)
	if C_Container and C_Container.GetContainerItemInfo then
		return C_Container.GetContainerItemInfo(...) or {};
	end
	local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID, isBound
		= GetContainerItemInfo(...)
	return {
		hasLoot = lootable;
		hasNoValue = noValue;
		hyperlink = itemLink;
		iconFileID = icon;
		isBound = isBound;
		isFiltered = isFiltered;
		isLocked = locked;
		isReadable = readable;
		itemID = itemID;
		quality = quality;
		stackCount = itemCount;
	}
end

CPAPI.CreateSimpleTextureMarkup = CreateSimpleTextureMarkup or function(file, width, height)
	return ("|T%s:%d:%d|t"):format(
		  file
		, height or width
		, width
	);
end

---------------------------------------------------------------
-- Classic API wrappers
---------------------------------------------------------------
do
local function nopz() return 0  end;
local function nopt() return {} end;

CPAPI.ContainerIDToInventoryID = C_Container and C_Container.ContainerIDToInventoryID or ContainerIDToInventoryID;
CPAPI.GetActiveZoneAbilities = C_ZoneAbility and C_ZoneAbility.GetActiveAbilities or nopt;
CPAPI.GetBonusBarIndexForSlot = C_ActionBar.GetBonusBarIndexForSlot or nop;
CPAPI.GetCollectedDragonridingMounts = C_MountJournal and C_MountJournal.GetCollectedDragonridingMounts or nopt;
CPAPI.GetContainerItemID = C_Container and C_Container.GetContainerItemID or GetContainerItemID;
CPAPI.GetContainerItemQuestInfo = C_Container and C_Container.GetContainerItemQuestInfo or GetContainerItemQuestInfo;
CPAPI.GetContainerNumFreeSlots = C_Container and C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots;
CPAPI.GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots;
CPAPI.GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo or nop;
CPAPI.GetFriendshipReputation = C_GossipInfo and C_GossipInfo.GetFriendshipReputation or GetFriendshipReputation or nop;
CPAPI.GetFriendshipReputationRanks = C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks or nop;
CPAPI.GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData or nop;
CPAPI.GetMountFromSpell = C_MountJournal and C_MountJournal.GetMountFromSpell or nop;
CPAPI.GetMountInfoByID = C_MountJournal and C_MountJournal.GetMountInfoByID or nop;
CPAPI.GetNumQuestWatches = C_QuestLog.GetNumQuestWatches or nopz;
CPAPI.GetOverrideBarSkin = GetOverrideBarSkin or nop;
CPAPI.GetQuestLogIndexForQuestID = C_QuestLog and C_QuestLog.GetLogIndexForQuestID or nop;
CPAPI.GetRenownLevels = C_MajorFactions and C_MajorFactions.GetRenownLevels or nop;
CPAPI.IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon or nop;
CPAPI.IsInLFGDungeon = IsInLFGDungeon or nop;
CPAPI.IsMajorFaction = C_Reputation and C_Reputation.IsMajorFaction or nop;
CPAPI.IsPartyLFG = IsPartyLFG or nop;
CPAPI.IsSpellOverlayed = IsSpellOverlayed or nop;
CPAPI.IsXPUserDisabled = IsXPUserDisabled or nop;
CPAPI.LeaveParty = C_PartyInfo and C_PartyInfo.LeaveParty or LeaveParty;
CPAPI.PickupContainerItem = C_Container and C_Container.PickupContainerItem or PickupContainerItem;
CPAPI.PutActionInSlot = C_ActionBar and C_ActionBar.PutActionInSlot or PlaceAction;
CPAPI.RequestLoadQuestByID = C_QuestLog and C_QuestLog.RequestLoadQuestByID or nop;
CPAPI.UseContainerItem = C_Container and C_Container.UseContainerItem or UseContainerItem;

end

---------------------------------------------------------------
-- Widget wrappers
---------------------------------------------------------------

function CPAPI.SetGradient(...)
	return LibStub('Carpenter'):SetGradient(...)
end
