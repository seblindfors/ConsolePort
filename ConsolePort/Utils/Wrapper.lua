local _, db = ...; CPAPI = {};
---------------------------------------------------------------
-- General 
---------------------------------------------------------------
-- return true or nil (nil for dynamic table insertions)
function CPAPI:IsClassicVersion(...)
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return true end
end

function CPAPI:IsRetailVersion(...)
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then return true end
end

---------------------------------------------------------------
-- API Wrappers
---------------------------------------------------------------
local function GetClassInfo()	return UnitClass('player') end
local function GetClassID() 	return select(3, UnitClass('player')) end


function CPAPI.GetClassFile()
	return select(2, UnitClass('player'))
end

function CPAPI.GetAsset(path)
	return ([[Interface\AddOns\ConsolePort\Assets\%s]]):format(path)
end

function CPAPI.GetClassIcon(class)
	-- returns concatenated icons file with slicing coords
	return [[Interface\TargetingFrame\UI-Classes-Circles]], CLASS_ICON_TCOORDS[class or CPAPI.GetClassFile()]
end

function CPAPI.GetWebClassIcon(class)
	return CPAPI.GetAsset([[Art\Class\Web_Class_Icons_Grid]]), CLASS_ICON_TCOORDS[class or CPAPI.GetClassFile()]
end

function CPAPI.GetPlayerCastingInfo()
	-- use UnitCastingInfo on retail
	if UnitCastingInfo then
		return UnitCastingInfo('player')
	end
	-- use CastingInfo on classic
	return CastingInfo()
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

function CPAPI.GetNumQuestWatches(...)
	return GetNumQuestWatches and GetNumQuestWatches(...) or 0
end

function CPAPI.GetNumWorldQuestWatches(...)
	return GetNumWorldQuestWatches and GetNumWorldQuestWatches(...) or 0
end

function CPAPI.GetQuestLogSpecialItemInfo(...)
	return GetQuestLogSpecialItemInfo and GetQuestLogSpecialItemInfo(...)
end

function CPAPI.UnitIsBattlePet(...)
	return UnitIsBattlePet and UnitIsBattlePet(...)
end

function CPAPI.UnitThreatSituation(...)
	return UnitThreatSituation and UnitThreatSituation(...)
end

function CPAPI.IsXPUserDisabled(...)
	return IsXPUserDisabled and IsXPUserDisabled(...)
end

function CPAPI.IsSpellOverlayed(...)
	return IsSpellOverlayed and IsSpellOverlayed(...)
end

function CPAPI.GetFriendshipReputation(...)
	return GetFriendshipReputation and GetFriendshipReputation(...)
end

function CPAPI.IsPartyLFG(...)
	return IsPartyLFG and IsPartyLFG(...)
end

function CPAPI.IsInLFGDungeon(...)
	return IsInLFGDungeon and IsInLFGDungeon(...)
end

function CPAPI.OpenStackSplitFrame(...)
	if OpenStackSplitFrame then
		return OpenStackSplitFrame(...)
	end
	return StackSplitFrame:OpenStackSplitFrame(...)
end