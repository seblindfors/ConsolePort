local _, db, L = ...; L = db.Locale;
local LoadoutMixin, LoadoutInfo = db:Register('LoadoutMixin', {}), db:Register('Loadout', {
	--------------------------------------------------------------
	BindingPrefix = 'BINDING_NAME_%s';
	HeaderPrefix  = 'BINDING_%s';
	NotBoundColor = '|cFF757575%s|r';
	DisplayFormat = '%s\n|cFF757575%s|r';
	--------------------------------------------------------------
	DictCounter   = 0;
	Custom        = {};
	Bindings      = {};
	Headers       = {};
	Actionbar     = {};
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
		companion    = CPAPI.Static(COMPANIONS); -- low-prio todo: get some info on whatever this is
	};
});

---------------------------------------------------------------
-- Action bar handling
---------------------------------------------------------------
function LoadoutInfo:GetActionButtonID(binding)
	return db(('Actionbar/Binding/%s'):format(binding))
end

function LoadoutInfo:GetActionInfo(actionID)
	local kind, kindID = GetActionInfo(actionID)
	local getinfo = self.ActionNameHandlers[kind]

	if getinfo then
		return getinfo(kindID)
	end
end

function LoadoutInfo:GetActionbarBindings()
	self:RefreshDictionary()
	return self.Actionbar;
end

function LoadoutInfo:AddActionbarBinding(name, bindingID, actionID)
	self.Actionbar[actionID] = {name = name, binding = bindingID};
end

do local customHeader = ' |TInterface\\Store\\category-icon-featured:18:18:0:0:64:64:18:46:18:46|t  ' .. SPECIAL;
	_G[customHeader] = customHeader;
	function LoadoutInfo:AddCustomBinding(name, bindingID, readonly)
		self:AddBindingToCategory(L(name), bindingID, customHeader, readonly)
		self.Custom[bindingID] = name;
		self.Headers[bindingID] = customHeader;
	end

	function LoadoutInfo:IsReadonlyBinding(bindingID)
		if self.Custom[bindingID] then
			local info = db.Bindings:GetCustomBindingInfo(bindingID)
			return info and info.readonly and info.readonly();
		end
	end
end

do local primaryHeader = '  |TInterface\\Store\\category-icon-wow:18:18:0:0:64:64:18:46:18:46|t  ' .. PRIMARY;
	function LoadoutInfo:AddPrimaryBinding(name, bindingID, readonly)
		self:AddBindingToCategory(name, bindingID, primaryHeader, readonly)
		self.Custom[bindingID] = name;
		self.Headers[bindingID] = customHeader;
	end
end


---------------------------------------------------------------
-- Dictionary
---------------------------------------------------------------
function LoadoutInfo:IsBindingMissingHeader(id)
	-- called for bindings where header could not be found, so check...
	return (id:match('^HEADER') and       -- (1) is it a header?
		not id:match('^HEADER_BLANK') and -- (2) ...that isn't blank?
		not id:match('^CP_')) or          -- (3) ...and doesn't belong to CP?
		not id:match('^HEADER')           -- (4) or is it not a header?
end

function LoadoutInfo:AddBindingToCategory(name, id, category, readonly)
	local bindings = self.Bindings;
	bindings[category] = bindings[category] or {};

	local category = bindings[category];
	category[#category+1] = {name = name, binding = id, readonly = readonly};
	return category;
end

function LoadoutInfo:GetBindingName(binding)
	return self.Custom[binding] or _G[self.BindingPrefix:format(binding)]
end

function LoadoutInfo:GetCategoryName(header)
	if not header then return end
	local name = _G[header];
	if type(name) ~= 'string' then
		name = tostring(header)
	end
	return name;
end

function LoadoutInfo:RefreshDictionary()
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
function LoadoutInfo:AssertBindings(bindings)
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

function LoadoutInfo:RenameActionbarCategory(bindings)
	-- HACK: rename misc action bar to "Bindings",
	-- so action bar can be handled separately in the binding manager.
	bindings[KEY_BINDINGS_MAC] = bindings[BINDING_HEADER_ACTIONBAR];
	bindings[BINDING_HEADER_ACTIONBAR] = nil;
end

function LoadoutInfo:ConvertTextToBonusBar(text, page, actionID)
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
function LoadoutMixin:GetBindingName(binding)
	return LoadoutInfo:GetBindingName(binding)
end

function LoadoutMixin:GetActionInfo(actionID)
	return LoadoutInfo:GetActionInfo(actionID)
end

function LoadoutMixin:IsReadonlyBinding(binding)
	return LoadoutInfo:IsReadonlyBinding(binding)
end

-- @param binding        : binding ID
-- @param skipActionInfo : format action as binding ID
-- @return name          : internal name of the binding
-- @return texture       : binding or action texture
-- @return actionID      : formatted action ID
-- @return bindingID     : binding ID
function LoadoutMixin:GetBindingInfo(binding, skipActionInfo)
	if (not binding or binding == '') then return LoadoutInfo.NotBoundColor:format(NOT_BOUND) end;
	local _, headers = LoadoutInfo:RefreshDictionary()

	local text, name = LoadoutInfo:GetBindingName(binding)
	local header = headers[binding];

	-- check if this is an action bar binding
	local actionID = LoadoutInfo:GetActionButtonID(binding)
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
			text = LoadoutInfo:ConvertTextToBonusBar(text, page, actionID)
			return LoadoutInfo.DisplayFormat:format(name, text or ''), texture, actionID, binding;
		elseif texture then
			-- no name found, but there's a texture.
			if text then
				name = header and _G[header]
				name = name and LoadoutInfo.DisplayFormat:format(text, name) or text;
			end
			return name, texture, actionID, binding;
		end
	end
	if text then
		-- this binding may have an action ID, but the slot is empty, or it's just a normal binding.
		name = LoadoutInfo:GetCategoryName(header)
		name = name and LoadoutInfo.DisplayFormat:format(text, name) or text;
		return name, db.Bindings:GetIcon(binding), actionID, binding;
	end

	-- check if this is a ring binding
	name = db.Bindings:ConvertRingBindingToDisplayName(binding)
	if name then
		return name, db.Bindings:GetIcon(binding), actionID, binding;
	end
	-- at this point, this is not an usual binding. this is most likely a click binding.
	name = gsub(binding, '(.* ([^:]+).*)', '%2') -- upvalue so it doesn't return more than 1 arg
	name = name or self:WrapAsNotBound(NOT_BOUND);
	return name, db.Bindings:GetIcon(binding), actionID, binding;
end

function LoadoutMixin:WrapAsNotBound(text)
	return LoadoutInfo.NotBoundColor:format(text)
end

---------------------------------------------------------------
-- Collections
---------------------------------------------------------------
LoadoutInfo.SecureHandlerMap = {
	-- Simple types -------------------------------------------
	action = function(action) return {
		type   = 'action';
		action = action;
	} end;
	-----------------------------------------------------------
	item = function(itemID, itemLink) return {
		type = 'item';
		item = itemLink or itemID;
		link = itemLink;
	} end;
	-----------------------------------------------------------
	macro = function(index) return CreateFromMixins(CPAPI.GetMacroInfo(index), {
		type  = 'macro';
		macro = index;
		macrotext = false;
	}) end;
	-----------------------------------------------------------
	equipmentset = function(name) return {
		type         = 'equipmentset';
		equipmentset = name;
	} end;
	-- Spell conversion ---------------------------------------
	spell = function(spellIndex, bookType, spellID)
		return LoadoutInfo.SecureHandlerMap.spellID(spellID)
	end;
	-----------------------------------------------------------
	mount = function(mountID)
		local spellID = select(2, CPAPI.GetMountInfoByID(mountID));
		local spellName = spellID and CPAPI.GetSpellInfo(spellID).name;
		if spellName then
			return LoadoutInfo.SecureHandlerMap.spellID(spellName)
		end
	end;
	-----------------------------------------------------------
	petaction = function(spellID, index)
		if index then
			return LoadoutInfo.SecureHandlerMap.spellID(spellID)
		end
	end;
	---------------------------------------------------------------
	companion = function(companionID, companionType)
		if ( companionType == 'MOUNT' and CPAPI.GetMountInfoByID(companionID) ) then
			return LoadoutInfo.SecureHandlerMap.mount(companionID)
		end
		local _, spellName = GetCompanionInfo(companionType, companionID)
		if spellName then
			return LoadoutInfo.SecureHandlerMap.spellID(spellName)
		end
	end;
	---------------------------------------------------------------
	spellID = function(spellID) return {
		type  = 'spell';
		spell = spellID;
		link  = CPAPI.GetSpellLink(spellID)
	} end;
};

---------------------------------------------------------------
LoadoutInfo.Collectors = {
	-----------------------------------------------------------
	SpellBook = function(flatten, BOOKTYPE_SPELL, SKILLTYPE_SPELL, SKILLTYPE_FLYOUT)
	-----------------------------------------------------------
		local spellBook, flyouts, flyoutNames = {}, {}, {};
		for tab=1, CPAPI.GetNumSpellTabs() do
			local spellTabInfo = CPAPI.GetSpellTabInfo(tab)
			-- NOTE: this means it's an active spell tab, lmao
			if ((spellTabInfo.offSpecID == 0 or not spellTabInfo.offSpecID) and not spellTabInfo.shouldHide) then
				local spells = {};
				spellBook[#spellBook + 1] = spells;

				local slots, offset = spellTabInfo.numSpellBookItems, spellTabInfo.itemIndexOffset;
				for i = (offset+1), (slots+offset) do
					local skillType, typeID = CPAPI.GetSpellBookItemType(i, BOOKTYPE_SPELL)
					if ( skillType == SKILLTYPE_FLYOUT or not CPAPI.IsSpellBookItemPassive(i, BOOKTYPE_SPELL) ) then

						if (skillType == SKILLTYPE_SPELL) then
							spells[#spells + 1] = i;
						elseif (skillType == SKILLTYPE_FLYOUT) then
							if not flatten then
								spells[#spells + 1] = i;
							end

							local name, _, numFlyoutSlots = GetFlyoutInfo(typeID)
							local flyout, flyoutID = {}, #flyouts + 1;
							flyouts[flyoutID] = flyout;
							flyoutNames[flyoutID] = name;
							for f = 1, numFlyoutSlots do
								local _, overrideSpellID, isKnown = GetFlyoutSlotInfo(typeID, f)
								if isKnown and not CPAPI.IsPassiveSpell(overrideSpellID) then
									flyout[#flyout+1] = overrideSpellID;
								end
							end
						end
					end
				end
				spells.tabName = spellTabInfo.name;
			end
		end
		return spellBook, flyouts, flyoutNames;
	end;
	-----------------------------------------------------------
	PetSpells = function(BOOKTYPE_PET, SKILLTYPE_PET)
	-----------------------------------------------------------
		local pet, numPetSpells = {}, CPAPI.HasPetSpells()
		if numPetSpells then
			for i=1, numPetSpells do
				local skillType, _, spellID = CPAPI.GetSpellBookItemType(i, BOOKTYPE_PET)
				if (skillType == SKILLTYPE_PET) or spellID and not CPAPI.IsSpellBookItemPassive(i, BOOKTYPE_PET) then
					pet[#pet + 1] = i;
				end
			end
		end
		return pet;
	end;
	-----------------------------------------------------------
	Bags = function(NUM_BAG_SLOTS)
	-----------------------------------------------------------
		local items, omit = {}, {};
		for bag=0, NUM_BAG_SLOTS do
			for slot=1, CPAPI.GetContainerNumSlots(bag) do
				local itemID = CPAPI.GetContainerItemInfo(bag, slot).itemID;
				if itemID and CPAPI.IsUsableItem(itemID) and not omit[itemID] then
					items[#items + 1] = {bag, slot}
					omit[itemID] = true;
				end
			end
		end
		return items;
	end;
	-----------------------------------------------------------
	Mounts = C_MountJournal and C_MountJournal.GetNumDisplayedMounts and (function()
	-----------------------------------------------------------
		local mounts = {};
		for i=1, C_MountJournal.GetNumDisplayedMounts() do
			if (select(11, C_MountJournal.GetDisplayedMountInfo(i))) then -- isCollected
				mounts[#mounts+1] = i;
			end
		end
		return mounts, true;
	end) or (function(COMPANION_MOUNT)
		if GetNumCompanions and GetNumCompanions(COMPANION_MOUNT) > 0 then
			local mounts = {};
			for i=1, GetNumCompanions(COMPANION_MOUNT) do
				mounts[#mounts+1] = i;
			end
			return mounts, false;
		end
	end);
	-----------------------------------------------------------
	Macros = function()
	-----------------------------------------------------------
		local macros, numMacros, numCharMacros = {{}, {}}, GetNumMacros()
		-- Character macros
		for i=MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + numCharMacros do
			macros[1][#macros[1]+1] = i;
		end
		-- Account macros
		for i=1, numMacros do
			macros[2][#macros[2]+1] = i;
		end
		return macros;
	end;
	-----------------------------------------------------------
	Toys = C_ToyBox and C_ToyBox.GetNumToys and (function()
	-----------------------------------------------------------
		local toys = {};
		for i=1, C_ToyBox.GetNumToys() do
			local itemID = C_ToyBox.GetToyInfo(C_ToyBox.GetToyFromIndex(i))
			if itemID and CPAPI.PlayerHasToy(itemID) then
				toys[#toys+1] = itemID;
			end
		end
		return toys;
	end) or nop;
};

function LoadoutInfo:RefreshCollections(flatten)
	-- securecall wrapper, so if one of the collectors fails, the rest can still run
	local collections, collect = {}, securecallfunction;

	local function AddCollection(collection, configuration)
		collections[#collections + 1] = configuration;
		configuration.items = collection;
		return configuration, collections;
	end

	local function IsDataValid(data)
		-- check if data is a table and has at least one entry
		return (data and next(data) ~= nil);
	end

	local BOOKTYPE_PET     = CPAPI.BOOKTYPE_PET;
	local BOOKTYPE_SPELL   = CPAPI.BOOKTYPE_SPELL;
	local SKILLTYPE_PET    = CPAPI.SKILLTYPE_PET;
	local SKILLTYPE_SPELL  = CPAPI.SKILLTYPE_SPELL;
	local SKILLTYPE_FLYOUT = CPAPI.SKILLTYPE_FLYOUT;
	local COMPANION_MOUNT  = 'MOUNT';

	-- Spells
	do  local spellBook, flyouts, flyoutNames = collect(self.Collectors.SpellBook,
			flatten, BOOKTYPE_SPELL, SKILLTYPE_SPELL, SKILLTYPE_FLYOUT
		);

		if IsDataValid(spellBook) then
			for _, spells in ipairs(spellBook) do
				local name = spells.tabName;
				spells.tabName = nil;

				local FindSpellBookActionButtons = C_ActionBar.FindSpellActionButtons and function(id)
					return C_ActionBar.FindSpellActionButtons(CPAPI.GetSpellBookItemInfo(id, BOOKTYPE_SPELL).spellID or -1)
				end;

				AddCollection(spells, {
					name    = name;
					match   = FindSpellBookActionButtons;
					pickup  = function(id) CPAPI.PickupSpellBookItem(id, BOOKTYPE_SPELL) end;
					tooltip = function(tooltip, id) tooltip:SetSpellBookItem(id, BOOKTYPE_SPELL) end;
					texture = function(id) return CPAPI.GetSpellBookItemTexture(id, BOOKTYPE_SPELL) end;
					title   = function(id) return CPAPI.GetSpellBookItemName(id, BOOKTYPE_SPELL) end;
					map     = function(map, id) return map.spellID(CPAPI.GetSpellBookItemInfo(id, BOOKTYPE_SPELL).spellID) end;
					header  = ABILITIES;
				})
			end
		end

		if IsDataValid(flyouts) then
			-- Use reverse because class tabs are enumerated after the general tab, and usually class spells
			-- are more important than general flyout spells (e.g. rogue poisons vs. skyriding)
			for i, flyout in ipairs_reverse(flyouts) do
				local name = flyoutNames[i];
				AddCollection(flyout, {
					name    = name;
					match   = C_ActionBar.FindSpellActionButtons;
					pickup  = CPAPI.PickupSpell;
					tooltip = GameTooltip.SetSpellByID;
					texture = CPAPI.GetSpellTexture;
					title   = CPAPI.GetSpellName;
					map     = function(map, id) return map.spellID(id) end;
					header  = ABILITIES;
				})
			end
		end
	end

	-- Pet spells
	do  local pet = collect(self.Collectors.PetSpells, BOOKTYPE_PET, SKILLTYPE_PET)
		if IsDataValid(pet) then
			AddCollection(pet, {
				name    = PET;
				match   = C_ActionBar.FindPetActionButtons;
				pickup  = function(id) CPAPI.PickupSpellBookItem(id, BOOKTYPE_PET) end;
				tooltip = function(tooltip, id) tooltip:SetSpellBookItem(id, BOOKTYPE_PET) end;
				texture = function(id) return CPAPI.GetSpellBookItemTexture(id, BOOKTYPE_PET) end;
				title   = function(id) return CPAPI.GetSpellBookItemName(id, BOOKTYPE_PET) end;
				map     = function(map, id) return map.spellID(CPAPI.GetSpellBookItemInfo(id, BOOKTYPE_PET).spellID) end;
				header  = ABILITIES;
			})
		end
	end

	-- Bags
	do  local items = collect(self.Collectors.Bags, NUM_BAG_SLOTS or 4)
		if IsDataValid(items) then
			AddCollection(items, {
				name    = BAG_NAME_BACKPACK or INVENTORY_TOOLTIP;
				pickup  = CPAPI.PickupContainerItem;
				tooltip = GameTooltip.SetBagItem;
				texture = function(...) return CPAPI.GetContainerItemInfo(...).iconFileID end;
				title   = function(...) return CPAPI.GetContainerItemInfo(...).hyperlink end;
				map     = function(map, ...) return map.item(nil, CPAPI.GetContainerItemInfo(...).hyperlink) end;
				header  = ITEMS;
			})
		end
	end

	-- Mounts
	do  local mounts, isNewAPI = collect(self.Collectors.Mounts, COMPANION_MOUNT)
		if IsDataValid(mounts) then
			if isNewAPI then
				local ConvertHalfAssedCompanionAPI = not CPAPI.IsRetailVersion and function(...)
					return self.SecureHandlerMap.spell(nil, nil, C_MountJournal.GetDisplayedMountInfo(...))
				end;

				AddCollection(mounts, {
					name    = MOUNTS;
					match   = C_ActionBar.FindSpellActionButtons;
					pickup  = CPAPI.IsRetailVersion and C_MountJournal.Pickup;
					append  = ConvertHalfAssedCompanionAPI;
					tooltip = function(self, id) GameTooltip.SetSpellByID(self, (select(2, C_MountJournal.GetDisplayedMountInfo(id)))) end;
					texture = function(id) return (select(3, C_MountJournal.GetDisplayedMountInfo(id))) end;
					title   = function(id) return (select(1, C_MountJournal.GetDisplayedMountInfo(id))) end;
					map     = function(map, id) return map.spellID(C_MountJournal.GetDisplayedMountInfo(id)) end;
					header  = ITEMS;
				})
			else
				local getMountSpellID = function(id)
					return (select(3, GetCompanionInfo(COMPANION_MOUNT, id)))
				end;

				AddCollection(mounts, {
					name    = MOUNTS;
					pickup  = function(id) return CPAPI.PickupSpell(getMountSpellID(id)) end;
					tooltip = function(self, id) GameTooltip.SetSpellByID(self, getMountSpellID(id)) end;
					texture = function(id) return (select(4, GetCompanionInfo(COMPANION_MOUNT, id))) end;
					title   = function(id) return (select(2, GetCompanionInfo(COMPANION_MOUNT, id))) end;
					map     = function(map, id) return map.spellID(getMountSpellID(id)) end;
					header  = ITEMS;
				})
			end
		end
	end

	-- Macros
	do local macros = collect(self.Collectors.Macros)
		if IsDataValid(macros) then
			for i, macroSet in ipairs(macros) do
				if IsDataValid(macroSet) then
					local tooltipFunc = function(self, id)
						local name, _, text = GetMacroInfo(id)
						self:SetText(('%s'):format(name:trim():len()>0 and name or NOT_APPLICABLE))
						self:AddLine(text, 1, 1, 1)
						self:Show()
					end;

					local titleFunc = function(id)
						local name = GetMacroInfo(id)
						return name:trim():len()>0 and name
							or GRAY_FONT_COLOR:WrapTextInColorCode(('%s %d'):format(MACRO, id))
					end;

					AddCollection(macroSet, {
						name    = i == 2 and GENERAL_MACROS or CHARACTER_SPECIFIC_MACROS:format(UnitName('player'));
						text    = GetMacroInfo;
						pickup  = PickupMacro;
						tooltip = tooltipFunc;
						texture = function(id) return select(2, GetMacroInfo(id)) end;
						title   = titleFunc;
						map     = function(map, id) return map.macro(id) end;
						header  = MACROS;
					})
				end
			end
		end
	end

	-- Toys
	do local toys = collect(self.Collectors.Toys)
		if IsDataValid(toys) then
			AddCollection(toys, {
				name    = TOY_BOX;
				pickup  = C_ToyBox.PickupToyBoxItem;
				tooltip = function(self, id) GameTooltip.SetToyByItemID(self, id) end;
				texture = function(id) return select(3, C_ToyBox.GetToyInfo(id)) end;
				title   = function(id) return select(2, C_ToyBox.GetToyInfo(id)) end;
				map     = function(map, id) return map.item(nil, CPAPI.GetItemInfo(id).itemLink) end;
				header  = ITEMS;
			})
		end
	end

	return collections;
end

function LoadoutMixin:GetCollections(flatten)
	if not self.Collections then
		self.Collections = LoadoutInfo:RefreshCollections(flatten);
	end
	return self.Collections;
end

function LoadoutMixin:ClearCollections()
	self.Collections = nil;
end