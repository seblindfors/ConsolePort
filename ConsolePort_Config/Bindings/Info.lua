local _, env = ...; local db, L = env.db, env.L;
local BindingInfoMixin, BindingInfo = {}, {
	--------------------------------------------------------------
	BindingPrefix = 'BINDING_NAME_%s';
	HeaderPrefix  = 'BINDING_%s';
	NotBoundColor = '|cFF757575%s|r';
	DisplayFormat = '%s\n|cFF757575%s|r';
	--------------------------------------------------------------
	DictCounter = 0;
	Custom    = {};
	Bindings  = {};
	Headers   = {};
	Actionbar = {};
	--------------------------------------------------------------
	ActionNameHandlers = {
		spell        = function(id) return CPAPI.GetSpellInfo(id).name    or STAT_CATEGORY_SPELL  end; -- Hack fallback: 'Spell'
		item         = function(id) return CPAPI.GetItemInfo(id).itemName or HELPFRAME_ITEM_TITLE end; -- Hack fallback: 'Item'
		macro        = function(id) return GetMacroInfo(id) and GetMacroInfo(id) .. ' ('..MACRO..')' end;
		mount        = function(id) return C_MountJournal.GetMountInfoByID(id) end;
		summonmount  = function(id) return C_MountJournal.GetMountInfoByID(id) end;
		summonpet    = function(id) return (C_PetJournal.GetPetInfoTableByPetID(id) or {}).name or TOOLTIP_BATTLE_PET end;
		flyout       = function(id) return GetFlyoutInfo(id) end;
		equipmentset = function(id) return tostring(id)..' ('..BAG_FILTER_EQUIPMENT..')' end;
		companion    = function() return COMPANIONS end; -- low-prio todo: get some info on whatever this is

	};
	--------------------------------------------------------------
}; env.BindingInfo, env.BindingInfoMixin = BindingInfo, BindingInfoMixin;

---------------------------------------------------------------
-- Action bar handling
---------------------------------------------------------------
function BindingInfo:GetActionButtonID(binding)
	return db(('Actionbar/Binding/%s'):format(binding))
end

function BindingInfo:GetActionInfo(actionID)
	local kind, kindID = GetActionInfo(actionID)
	local getinfo = self.ActionNameHandlers[kind]

	if getinfo then
		return getinfo(kindID)
	end
end

function BindingInfo:GetActionbarBindings()
	self:RefreshDictionary()
	return self.Actionbar;
end

function BindingInfo:AddActionbarBinding(name, bindingID, actionID)
	self.Actionbar[actionID] = {name = name, binding = bindingID};
end

do local customHeader = ' |TInterface\\Store\\category-icon-featured:18:18:0:0:64:64:18:46:18:46|t  ' .. SPECIAL;
	_G[customHeader] = customHeader;
	function BindingInfo:AddCustomBinding(name, bindingID, readonly)
		self:AddBindingToCategory(L(name), bindingID, customHeader, readonly)
		self.Custom[bindingID] = name;
		self.Headers[bindingID] = customHeader;
	end

	function BindingInfo:IsReadonlyBinding(bindingID)
		if self.Custom[bindingID] then
			local info = db.Bindings:GetCustomBindingInfo(bindingID)
			return info and info.readonly and info.readonly();
		end
	end
end

do local primaryHeader = '  |TInterface\\Store\\category-icon-wow:18:18:0:0:64:64:18:46:18:46|t  ' .. PRIMARY;
	function BindingInfo:AddPrimaryBinding(name, bindingID, readonly)
		self:AddBindingToCategory(name, bindingID, primaryHeader, readonly)
		self.Custom[bindingID] = name;
		self.Headers[bindingID] = customHeader;
	end
end


---------------------------------------------------------------
-- Dictionary
---------------------------------------------------------------
function BindingInfo:IsBindingMissingHeader(id)
	-- called for bindings where header could not be found, so check...
	return (id:match('^HEADER') and       -- (1) is it a header?
		not id:match('^HEADER_BLANK') and -- (2) ...that isn't blank?
		not id:match('^CP_')) or          -- (3) ...and doesn't belong to CP?
		not id:match('^HEADER')           -- (4) or is it not a header?
end

function BindingInfo:AddBindingToCategory(name, id, category, readonly)
	local bindings = self.Bindings;
	bindings[category] = bindings[category] or {};
	
	local category = bindings[category];
	category[#category+1] = {name = name, binding = id, readonly = readonly};
	return category;
end

function BindingInfo:GetBindingName(binding)
	return self.Custom[binding] or _G[self.BindingPrefix:format(binding)]
end

function BindingInfo:GetCategoryName(header)
	if not header then return end
	local name = _G[header];
	if type(name) ~= 'string' then
		name = tostring(header)
	end
	return name;
end

function BindingInfo:RefreshDictionary()
	local numBindings = GetNumBindings()
	local isUpdatedDict = ( numBindings ~= self.DictCounter )
	-- only run refresh when bindings have been added
	if ( isUpdatedDict ) then
		local bindings, headers = wipe(self.Bindings), wipe(self.Headers);

		-- wipe custom handlers
		wipe(self.Actionbar)
		wipe(self.Custom)

		-- custom
		for i, data in db:For('Bindings/Special') do
			self:AddCustomBinding(data.name, data.binding, data.readonly)
		end

		-- primary
		for i, data in db:For('Bindings/Primary') do
			self:AddPrimaryBinding(data.name, data.binding, data.readonly)
		end

		-- XML-registered bindings
		for i=1, numBindings do
			local id, header = GetBinding(i)

			if not id:match('^HEADER') then
				-- link binding IDs to their headers
				headers[id] = header;

				-- NOTE: GetBindingName() is not reliable, use global
				-- Some bindings are actually subheaders or separators, and
				-- GetBindingName() can't be verified since it returns the
				-- original string if it doesn't find a match.
				local global = self:GetBindingName(id)
				local name   = global or _G[self.HeaderPrefix:format(id)]
				local action = self:GetActionButtonID(id)

				if action then
					self:AddActionbarBinding(name, id, action)
				elseif header then
					-- add binding to its designated category table, omit binding index if not an actual binding
					local title = self:GetCategoryName(header)
					self:AddBindingToCategory(name, id, title)
				elseif self:IsBindingMissingHeader(id) then
					-- at this point, the binding definitely belongs in the "Other" category
					self:AddBindingToCategory(name, id, BINDING_HEADER_OTHER)
				end
			end
		end
		self.DictCounter = numBindings;
		self:RenameActionbarCategory(bindings)
		self:AssertBindings(bindings)
	end
	return self.Bindings, self.Headers, isUpdatedDict;
end

---------------------------------------------------------------
-- Hacks
---------------------------------------------------------------
function BindingInfo:AssertBindings(bindings)
	-- HACK: trash any tables that don't have actual bindings, handling
	-- the quirk of the game's binding system listing separators
	-- in the UI as actual, legit bindings.
	for category, set in next, bindings do
		local gc = true;
		for i, data in ipairs(set) do
			if not data.binding:match('^HEADER_BLANK') then
				gc = false; break;
			end
		end
		if gc then
			bindings[category] = nil;
			category = nil;	
		end
	end
end

function BindingInfo:RenameActionbarCategory(bindings)
	-- HACK: rename misc action bar to "Action Bar (Miscellaneous)",
	-- so action bar can be handled separately in the binding manager.
	local newName = ('%s (%s)'):format(BINDING_HEADER_ACTIONBAR, MISCELLANEOUS)
	bindings[newName] = bindings[BINDING_HEADER_ACTIONBAR];
	bindings[BINDING_HEADER_ACTIONBAR] = nil;
end

function BindingInfo:ConvertTextToBonusBar(text, page, actionID)
	if (CPAPI.GetBonusBarIndexForSlot(actionID) == page) then
		for i=1, GetNumShapeshiftForms() do
			local _, isActive, _, spellID = GetShapeshiftFormInfo(i)
			if isActive and spellID then
				return ('%s (%s)'):format(text, CPAPI.GetSpellInfo(spellID).name)
			end
		end
	end
	return text
end

---------------------------------------------------------------
-- Mixin for things that need formatted binding info
---------------------------------------------------------------
function BindingInfoMixin:GetBindingName(binding)
	return BindingInfo:GetBindingName(binding)
end

function BindingInfoMixin:GetActionInfo(actionID)
	return BindingInfo:GetActionInfo(actionID)
end

function BindingInfoMixin:IsReadonlyBinding(binding)
	return BindingInfo:IsReadonlyBinding(binding)
end

-- @param binding        : bindingID
-- @param skipActionInfo : format action as binding ID
-- @return name          : internal name of the binding
-- @return texture       : binding or action texture
-- @return actionID      : formatted action ID
function BindingInfoMixin:GetBindingInfo(binding, skipActionInfo)
	if (not binding or binding == '') then return BindingInfo.NotBoundColor:format(NOT_BOUND) end;
	local bindings, headers = BindingInfo:RefreshDictionary()

	local text, name = BindingInfo:GetBindingName(binding)
	local header = headers[binding];

	-- check if this is an action bar binding
	local actionID = BindingInfo:GetActionButtonID(binding)
	if actionID and not skipActionInfo then
		-- swap the info for current bar if offset
		local page = db.Pager:GetCurrentPage()
		actionID = actionID <= NUM_ACTIONBAR_BUTTONS and
			actionID + ((page - 1) * 12) or actionID;

		local texture = GetActionTexture(actionID)

		name = self:GetActionInfo(actionID)

		if name then
			-- if action has a name, suffix the binding, omit the header,
			-- return the concatenated string and the action texture
			text = BindingInfo:ConvertTextToBonusBar(text, page, actionID)
			return BindingInfo.DisplayFormat:format(name, text), texture, actionID;
		elseif texture then
			-- no name found, but there's a texture.
			if text then
				name = header and _G[header]
				name = name and BindingInfo.DisplayFormat:format(text, name) or text;
			end
			return name, texture, actionID;
		end
	end
	if text then
		-- this binding may have an action ID, but the slot is empty, or it's just a normal binding.
		name = BindingInfo:GetCategoryName(header)
		name = name and BindingInfo.DisplayFormat:format(text, name) or text;
		return name, db.Bindings:GetIcon(binding), actionID;
	end

	-- check if this is a ring binding
	name = db.Utility:ConvertBindingToDisplayName(binding)
	if name then
		return name, db.Bindings:GetIcon(binding), actionID;
	end
	-- at this point, this is not an usual binding. this is most likely a click binding.
	name = gsub(binding, '(.* ([^:]+).*)', '%2') -- upvalue so it doesn't return more than 1 arg
	name = name or self:WrapAsNotBound(NOT_BOUND);
	return name, db.Bindings:GetIcon(binding), actionID;
end

function BindingInfoMixin:WrapAsNotBound(text)
	return BindingInfo.NotBoundColor:format(text)
end

---------------------------------------------------------------
-- Collections
---------------------------------------------------------------
function BindingInfo:AddCollection(collection, configuration)
	local collections = self.Collections;
	collections[#collections + 1] = configuration;
	configuration.items = collection;
	return configuration, collections;
end

function BindingInfo:RefreshCollections()
	self.Collections = self.Collections and wipe(self.Collections) or {};

	local BOOKTYPE_PET     = not CPAPI.IsRetailVersion and BOOKTYPE_PET   or Enum.SpellBookSpellBank.Pet;
	local BOOKTYPE_SPELL   = not CPAPI.IsRetailVersion and BOOKTYPE_SPELL or Enum.SpellBookSpellBank.Player;
	local SKILLTYPE_PET    = not CPAPI.IsRetailVersion and 'PETACTION'    or Enum.SpellBookItemType.Pet;
	local SKILLTYPE_SPELL  = not CPAPI.IsRetailVersion and 'SPELL'        or Enum.SpellBookItemType.Spell;
	local SKILLTYPE_FLYOUT = not CPAPI.IsRetailVersion and 'FLYOUT'       or Enum.SpellBookItemType.Flyout;

	-- Spells
	do  local spellBook, flyout, flyoutName = {}, {};

		for tab=1, CPAPI.GetNumSpellTabs() do
			local spellTabInfo = CPAPI.GetSpellTabInfo(tab)
			-- NOTE: this means it's an active spell tab, lmao
			if ((spellTabInfo.offSpecID == 0 or not spellTabInfo.offSpecID) and not spellTabInfo.shouldHide) then
				local spells = {};
				spellBook[#spellBook + 1] = spells;

				local slots, offset = spellTabInfo.numSpellBookItems, spellTabInfo.itemIndexOffset;
				for i = (offset+1), (slots+offset) do
					local skillType, typeID = CPAPI.GetSpellBookItemType(i, BOOKTYPE_SPELL)
					if ( skillType == SKILLTYPE_FLYOUT or not CPAPI.IsPassiveSpell(i, BOOKTYPE_SPELL) ) then

						if (skillType == SKILLTYPE_SPELL) then
							spells[#spells + 1] = i;
						elseif (skillType == SKILLTYPE_FLYOUT) then
							spells[#spells + 1] = i;

							local name, _, numFlyoutSlots = GetFlyoutInfo(typeID)
							flyoutName = flyoutName and ('%s / %s'):format(flyoutName, name) or name;
							for f = 1, numFlyoutSlots do
								flyout[#flyout+1] = GetFlyoutSlotInfo(typeID, f);
							end
						end
					end
				end
				spells.tabName = spellTabInfo.name;
			end
		end

		-- Pet spells
		local pet, numPetSpells = {}, CPAPI.HasPetSpells()
		if numPetSpells then
			for i=1, numPetSpells do
				local skillType = CPAPI.GetSpellBookItemType(i, BOOKTYPE_PET)
				if (skillType == SKILLTYPE_PET) then
					pet[#pet + 1] = i;
				end
			end
		end

		for _, spells in ipairs(spellBook) do
			local name = spells.tabName;
			spells.tabName = nil;

			self:AddCollection(spells, {
				name    = name;
				match   = C_ActionBar.FindSpellActionButtons;
				pickup  = function(id) CPAPI.PickupSpellBookItem(id, BOOKTYPE_SPELL) end;
				tooltip = function(tooltip, id) tooltip:SetSpellBookItem(id, BOOKTYPE_SPELL) end;
				texture = function(id) return CPAPI.GetSpellBookItemTexture(id, BOOKTYPE_SPELL) end;
			})
		end

		if next(flyout) then
			self:AddCollection(flyout, {
				name    = flyoutName;
				match   = C_ActionBar.FindSpellActionButtons;
				pickup  = CPAPI.PickupSpell;
				tooltip = GameTooltip.SetSpellByID;
				texture = CPAPI.GetSpellTexture;
			})
		end

		if next(pet) then
			self:AddCollection(pet, {
				name    = PET;
				match   = C_ActionBar.FindPetActionButtons;
				pickup  = function(id) CPAPI.PickupSpellBookItem(id, BOOKTYPE_PET) end;
				tooltip = function(tooltip, id) tooltip:SetSpellBookItem(id, BOOKTYPE_PET) end;
				texture = function(id) return CPAPI.GetSpellBookItemTexture(id, BOOKTYPE_PET) end;
			})
		end
	end

	-- Bags
	do  local items, omit = {}, {};
		for bag=0, NUM_BAG_SLOTS do
			for slot=1, CPAPI.GetContainerNumSlots(bag) do
				local itemID = CPAPI.GetContainerItemInfo(bag, slot).itemID;
				if itemID and CPAPI.IsUsableItem(itemID) and not omit[itemID] then
					items[#items + 1] = {bag, slot}
					omit[itemID] = true;
				end
			end
		end

		if next(items) then
			self:AddCollection(items, {
				name    = ITEMS;
				pickup  = CPAPI.PickupContainerItem;
				tooltip = GameTooltip.SetBagItem;
				texture = function(...) return CPAPI.GetContainerItemInfo(...).iconFileID end;
			})
		end
	end

	-- Mounts
	if C_MountJournal and C_MountJournal.GetNumDisplayedMounts then
		local mounts = {};
		for i=1, C_MountJournal.GetNumDisplayedMounts() do
			if (select(11, C_MountJournal.GetDisplayedMountInfo(i))) then -- isCollected
				mounts[#mounts+1] = i;
			end
		end

		local ConvertHalfAssedCompanionAPI = not CPAPI.IsRetailVersion and function(...)
			return db.Utility.SecureHandlerMap.spell(nil, nil, C_MountJournal.GetDisplayedMountInfo(...))
		end;

		if next(mounts) then
			self:AddCollection(mounts, {
				name    = MOUNTS;
				match   = C_ActionBar.FindSpellActionButtons;
				pickup  = CPAPI.IsRetailVersion and C_MountJournal.Pickup;
				append  = ConvertHalfAssedCompanionAPI;
				tooltip = function(self, id) GameTooltip.SetSpellByID(self, (select(2, C_MountJournal.GetDisplayedMountInfo(id)))) end;
				texture = function(id) return (select(3, C_MountJournal.GetDisplayedMountInfo(id))) end;
			})
		end
	elseif GetNumCompanions and GetNumCompanions('MOUNT') > 0 then
		local mounts = {};
		for i=1, GetNumCompanions('MOUNT') do
			mounts[#mounts+1] = i;
		end
		if next(mounts) then
			local getMountSpellID = function(id)
				return (select(3, GetCompanionInfo('MOUNT', id)))
			end

			self:AddCollection(mounts, {
				name    = MOUNTS;
				pickup  = function(id) return CPAPI.PickupSpell(getMountSpellID(id)) end;
				tooltip = function(self, id) GameTooltip.SetSpellByID(self, getMountSpellID(id)) end;
				texture = function(id) return (select(4, GetCompanionInfo('MOUNT', id))) end;
			})
		end
	end

	-- Macros
	do  local macros, numMacros, numCharMacros = {}, GetNumMacros()
		for i=MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + numCharMacros do
			macros[#macros+1] = i;
		end
		for i=1, numMacros do
			macros[#macros+1] = i;
		end

		if next(macros) then
			local tooltipFunc = function(self, id)
				local name, texture, text = GetMacroInfo(id)
				self:SetText(('%s'):format(name:trim():len()>0 and name or NOT_APPLICABLE))
				self:AddLine(text, 1, 1, 1)
			end

			self:AddCollection(macros, {
				name    = MACROS;
				text    = GetMacroInfo;
				pickup  = PickupMacro;
				tooltip = tooltipFunc;
				texture = function(id) return select(2, GetMacroInfo(id)) end;
			})
		end
	end

	-- Toys
	if CPAPI.IsRetailVersion then
		local toys = {};
		for i=1, C_ToyBox.GetNumToys() do
			local itemID = C_ToyBox.GetToyInfo(C_ToyBox.GetToyFromIndex(i))
			if itemID and CPAPI.PlayerHasToy(itemID) then
				toys[#toys+1] = itemID;
			end
		end

		if next(toys) then
			self:AddCollection(toys, {
				name    = TOY_BOX;
				pickup  = C_ToyBox.PickupToyBoxItem;
				tooltip = function(self, id) GameTooltip.SetToyByItemID(self, id) end;
				texture = function(id) return select(3, C_ToyBox.GetToyInfo(id)) end;
			})
		end
	end

	return self.Collections;
end

function BindingInfoMixin:GetCollections()
	return BindingInfo:RefreshCollections()
end