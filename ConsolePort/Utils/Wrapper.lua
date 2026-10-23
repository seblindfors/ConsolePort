local _, db = ...;

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
	local currentSpecialization = C_SpecializationInfo.GetSpecialization()
	if currentSpecialization then
		return C_SpecializationInfo.GetSpecializationInfo(currentSpecialization)
	end
	-- returns classID on classic
	return GetClassID()
end

function CPAPI.GetCharacterMetadata()
	-- returns specID, specName on retail
	local currentSpecialization = C_SpecializationInfo.GetSpecialization()
	if currentSpecialization then
		return C_SpecializationInfo.GetSpecializationInfo(currentSpecialization)
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
		freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i)
		if ( bagFamily == 0 ) then
			totalFree  = totalFree + freeSlots;
			totalSlots = totalSlots + C_Container.GetContainerNumSlots(i)
		end
	end
	return totalFree, totalSlots;
end

---------------------------------------------------------------
-- Binding wrappers
---------------------------------------------------------------
do
	---------------------------------------------------------------
	-- @brief Save bindings to the active set, if there is one
	-- @param setID : binding set to save to, or the active set
	-- @return saved : whether the bindings were written
	---------------------------------------------------------------
	-- GetCurrentBindingSet answers Default before bindings load, and
	-- saving against it writes to a set the player did not choose.
	function CPAPI.SaveBindings(setID)
		setID = setID or GetCurrentBindingSet();
		if ( setID ~= Enum.BindingSet.Account and setID ~= Enum.BindingSet.Character ) then
			return false;
		end
		SaveBindings(setID)
		return true;
	end

	local function ReportBindingError(keyChord, bindingID)
		if not keyChord or not keyChord:match('PAD.+') then return end;
		---@see https://github.com/Stanzilla/WoWUIBugs/issues/752
		local set = GetCurrentBindingSet();
		CPAPI.Log(table.concat({
				'Failed to set binding %s to %s.';
				'Please report this bug using in-game customer support.';
				'Steps to resolve for now:';
				'1. Backup bindings.';
				'2. Exit the game completely.';
				'3. Remove WTF/Account/%s/bindings-cache.wtf.';
				'4. Restart the game and restore bindings from backup.';
			}, '\n'),
			BLUE_FONT_COLOR:WrapTextInColorCode(tostring(keyChord)),
			BLUE_FONT_COLOR:WrapTextInColorCode(GetBindingName(tostring(bindingID))),
			set == Enum.BindingSet.Character and
				('<AccountName>/%s/%s'):format(GetRealmName(), UnitName('player')) or
			set == Enum.BindingSet.Account and
				'<AccountName>' or '*'
		);
	end

	local function TrySetBinding(keyChord, bindingID, saveAfter, context)
		context = context or (bindingID and C_KeyBindings.GetBindingContextForAction(bindingID))
		if SetBinding(keyChord, bindingID, context) then
			return saveAfter;
		end
		ReportBindingError(keyChord, bindingID);
	end

	function CPAPI.SetBinding(keyChord, bindingID, saveAfter)
		if bindingID and not db('bindingOverlapEnable') then
			CPAPI.ClearBindingsForID(bindingID, false)
		end
		if TrySetBinding(keyChord, bindingID, saveAfter) then
			CPAPI.SaveBindings()
			return true;
		end
		return false;
	end

	function CPAPI.ClearBindingsForID(bindingID, saveAfter)
		local context = C_KeyBindings.GetBindingContextForAction(bindingID)
		for _, binding in ipairs(db.Gamepad:GetBindingKey(bindingID, true)) do
			TrySetBinding(binding, nil, false, context)
		end
		if saveAfter then
			CPAPI.SaveBindings()
		end
		return true;
	end

	if CPAPI.IsModernVersion then
		function CPAPI.GetBindingAction(keyChord, checkOverride, context)
			return GetBindingAction(keyChord, checkOverride, context)
		end
	else
		function CPAPI.GetBindingAction(keyChord, checkOverride)
			return GetBindingAction(keyChord, checkOverride)
		end
	end
end

---------------------------------------------------------------
-- Internal wrappers
---------------------------------------------------------------
function CPAPI.IsButtonValidForBinding(button)
	return db('bindingAllowSticks') or (not button:match('PAD.STICK.+'))
end

function CPAPI.IsTutorialComplete(tutorialID)
	return CPAPI.Tutorial:IsFlagSet(tutorialID, db('tutorialState'));
end

function CPAPI.SetTutorialComplete(tutorialID, state)
	return db('Settings/tutorialState', CPAPI.Tutorial:Combine(tutorialID, db('tutorialState'), state));
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

CPAPI.IteratePlayerInventory = CPAPI.IsModernVersion and ItemUtil.IteratePlayerInventory or function(callback)
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

CPAPI.GetScaledCursorPositionForFrame = GetScaledCursorPositionForFrame or function(frame)
	local uiScale = frame:GetEffectiveScale();
	local x, y = GetCursorPosition();
	return x / uiScale, y / uiScale;
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
CPAPI.GetActiveZoneAbilities         = C_ZoneAbility   and C_ZoneAbility.GetActiveAbilities              or nopt;
CPAPI.GetBonusBarIndexForSlot        = C_ActionBar     and C_ActionBar.GetBonusBarIndexForSlot           or nop;
CPAPI.GetInventorySlotInfo           = C_PaperDollInfo and C_PaperDollInfo.GetInventorySlotInfo           or GetInventorySlotInfo;
CPAPI.GetMajorFactionData            = C_MajorFactions and C_MajorFactions.GetMajorFactionData           or nop;
CPAPI.GetNumQuestWatches             = C_QuestLog      and C_QuestLog.GetNumQuestWatches                 or nopz;
CPAPI.GetNumSpellTabs                = C_SpellBook     and C_SpellBook.GetNumSpellBookSkillLines         or GetNumSpellTabs;
CPAPI.GetQuestLogIndexForQuestID     = C_QuestLog      and C_QuestLog.GetLogIndexForQuestID              or nop;
CPAPI.GetRenownLevels                = C_MajorFactions and C_MajorFactions.GetRenownLevels               or nop;
CPAPI.GetSpellBookItemLink           = C_SpellBook     and C_SpellBook.GetSpellBookItemLink              or GetSpellLink;
CPAPI.GetSpellBookItemName           = C_SpellBook     and C_SpellBook.GetSpellBookItemName              or GetSpellBookItemName;
CPAPI.GetSpellBookItemTexture        = C_SpellBook     and C_SpellBook.GetSpellBookItemTexture           or GetSpellBookItemTexture;
CPAPI.GetSpellBookItemType           = C_SpellBook     and C_SpellBook.GetSpellBookItemType              or GetSpellBookItemInfo;
CPAPI.IsDressableItemByID            = C_Item          and C_Item.IsDressableItemByID                    or nop;
CPAPI.IsPlayerAtEffectiveMaxLevel    = GameRulesUtil   and GameRulesUtil.IsPlayerAtEffectiveMaxLevel     or IsPlayerAtEffectiveMaxLevel;
CPAPI.IsSpellBookItemPassive         = C_SpellBook     and C_SpellBook.IsSpellBookItemPassive            or IsPassiveSpell;
CPAPI.LeaveParty                     = C_PartyInfo     and C_PartyInfo.LeaveParty                        or LeaveParty;
CPAPI.PickupSpellBookItem            = C_SpellBook     and C_SpellBook.PickupSpellBookItem               or PickupSpellBookItem;
-- Fallthroughs
CPAPI.GetSpecializationInfoByID      = GetSpecializationInfoByID or nop;
CPAPI.IsSecret                       = issecretvalue      or nop;
CPAPI.IsXPUserDisabled               = IsXPUserDisabled   or nop;
CPAPI.PlayerHasToy                   = PlayerHasToy       or nop;
CPAPI.Scrub                          = scrubsecretvalues  or function(...)return...end;

do -- Object accessibility
	local Widget = GetFrameMetatable().__index;
	local Scrub, IsForbidden, HasAccessConstraints, HasAnyForbiddenAspects =
		CPAPI.Scrub, Widget.IsForbidden, Widget.HasAccessConstraints, Widget.HasAnyForbiddenAspects;

	-- Restricted objects may pass an IsForbidden check, but have forbidden
	-- aspects that disallow the use of certain APIs. Accessibility queries
	-- return secrets for objects carrying the ObjectSecurity aspect, which
	-- scrub to nil; only an explicit false means the object is accessible.
	if ( HasAccessConstraints and HasAnyForbiddenAspects ) then
		function CPAPI.IsObjectRestricted(object)
			return Scrub(HasAccessConstraints(object)) ~= false
				or Scrub(HasAnyForbiddenAspects(object)) ~= false;
		end
	else
		function CPAPI.IsObjectRestricted(object)
			return Scrub(IsForbidden(object)) ~= false;
		end
	end
end

-- Complex wrappers
CPAPI.GetContainerItemInfo = function(...)
	return C_Container.GetContainerItemInfo(...) or {};
end

CPAPI.GetItemInfo = function(...)
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
	itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
	expacID, setID, isCraftingReagent = C_Item.GetItemInfo(...)

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

CPAPI.GetItemInfoInstant = function(...)
	local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = C_Item.GetItemInfoInstant(...)
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

CPAPI.GetSpellInfo = function(...)
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

CPAPI.GetSpellBookItemInfo = function(...)
	if GetSpellBookItemInfo then
		local itemType, id = GetSpellBookItemInfo(...)
		local iconID = GetSpellBookItemTexture(...)
		local name = GetSpellBookItemName(...)
		local isPassive = IsPassiveSpell(...)
		local spellID = select(7, GetSpellInfo(...))
		return {
			--[[ SpellBookItemInfo  ]]
			--[[ Enum.SpellBookType ]] itemType = itemType;
			--[[ number             ]] actionID = spellID or id;
			--[[ number             ]] spellID = spellID;
			--[[ string             ]] name = name;
			--[[ FileID             ]] iconID = iconID;
			--[[ boolean            ]] isPassive = isPassive;
		}
	end
	return C_SpellBook.GetSpellBookItemInfo(...) or {};
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
	for i = 1, CPAPI.MAX_ACCOUNT_MACROS + CPAPI.MAX_CHARACTER_MACROS do
		info[i] = CPAPI.GetMacroInfo(i);
	end
	return info;
end

end -- API wrappers

---------------------------------------------------------------
-- Enum wrappers
---------------------------------------------------------------
CPAPI.BOOKTYPE_PET     = not CPAPI.IsModernVersion and BOOKTYPE_PET   or Enum.SpellBookSpellBank.Pet;
CPAPI.BOOKTYPE_SPELL   = not CPAPI.IsModernVersion and BOOKTYPE_SPELL or Enum.SpellBookSpellBank.Player;
CPAPI.SKILLTYPE_PET    = not CPAPI.IsModernVersion and 'PETACTION'    or Enum.SpellBookItemType.Pet;
CPAPI.SKILLTYPE_SPELL  = not CPAPI.IsModernVersion and 'SPELL'        or Enum.SpellBookItemType.Spell;
CPAPI.SKILLTYPE_FLYOUT = not CPAPI.IsModernVersion and 'FLYOUT'       or Enum.SpellBookItemType.Flyout;

---------------------------------------------------------------
-- Widget wrappers
---------------------------------------------------------------

function CPAPI.SetGradient(...)
	return LibStub('Carpenter'):SetGradient(...)
end

do	local Lib = LibStub('ConsolePortActionButton');

	function CPAPI.AutoCastStart(self, autoCastAllowed, ...)
		if (self.Shine or self.AutoCastShine) and AutoCastShine_AutoCastStart then
			return AutoCastShine_AutoCastStart(self.Shine or self.AutoCastShine, ...)
		end
		if self.AutoCastOverlay and self.AutoCastOverlay.ShowAutoCastEnabled then
			self.AutoCastOverlay:SetShown(autoCastAllowed)
			return Lib.ShowAutoCastEnabled(self.AutoCastOverlay, true)
		end
	end

	function CPAPI.AutoCastStop(self, autoCastAllowed)
		if (self.Shine or self.AutoCastShine) and AutoCastShine_AutoCastStop then
			return AutoCastShine_AutoCastStop(self.Shine or self.AutoCastShine)
		end
		if self.AutoCastOverlay and self.AutoCastOverlay.ShowAutoCastEnabled then
			self.AutoCastOverlay:SetShown(autoCastAllowed)
			return Lib.ShowAutoCastEnabled(self.AutoCastOverlay, false)
		end
	end
end