local _, db = ...; CPAPI = {};
---------------------------------------------------------------
-- General 
---------------------------------------------------------------
-- return true or nil (nil for dynamic table insertions)
function CPAPI.IsClassicVersion(...)
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return true end
end

function CPAPI.IsRetailVersion(...)
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then return true end
end

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