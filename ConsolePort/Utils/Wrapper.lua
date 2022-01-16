local _, db = ...; CPAPI = {};
---------------------------------------------------------------
-- General 
---------------------------------------------------------------
-- return true or nil (nil for dynamic table insertions)
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC or nil;
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
	return CPAPI.GetClassColor()
end

function CPAPI.GetAverageItemLevel(...)
	if GetAverageItemLevel then
		return floor(select(2, GetAverageItemLevel(...)))
	end
	return MAX_PLAYER_LEVEL
end

---------------------------------------------------------------
-- Internal wrappers
---------------------------------------------------------------
function CPAPI.IsButtonValidForBinding(button)
	return db('bindingAllowSticks') or (not button:match('PAD.STICK.+'))
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

---------------------------------------------------------------
-- Classic API wrappers
---------------------------------------------------------------
local function nopz() return 0  end;
local function nopt() return {} end;

CPAPI.GetActiveZoneAbilities = C_ZoneAbility and C_ZoneAbility.GetActiveAbilities or nopt;
CPAPI.GetBonusBarIndexForSlot = C_ActionBar.GetBonusBarIndexForSlot or nop;
CPAPI.GetFriendshipReputation = GetFriendshipReputation or nop;
CPAPI.GetMountFromSpell = C_MountJournal and C_MountJournal.GetMountFromSpell or nop;
CPAPI.GetMountInfoByID = C_MountJournal and C_MountJournal.GetMountInfoByID or nop;
CPAPI.GetNumQuestWatches = C_QuestLog.GetNumQuestWatches or nopz;
CPAPI.GetOverrideBarSkin = GetOverrideBarSkin or nop;
CPAPI.GetQuestLogIndexForQuestID = C_QuestLog and C_QuestLog.GetLogIndexForQuestID or nop;
CPAPI.IsInLFGDungeon = IsInLFGDungeon or nop;
CPAPI.IsPartyLFG = IsPartyLFG or nop;
CPAPI.IsSpellOverlayed = IsSpellOverlayed or nop;
CPAPI.IsXPUserDisabled = IsXPUserDisabled or nop;
CPAPI.LeaveParty = C_PartyInfo and C_PartyInfo.LeaveParty or LeaveParty;
CPAPI.PutActionInSlot = C_ActionBar and C_ActionBar.PutActionInSlot or PlaceAction;