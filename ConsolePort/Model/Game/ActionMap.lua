local _, db = ...;
---------------------------------------------------------------
-- Secure handler map for cursor info types
---------------------------------------------------------------
-- Maps an action info type to the attribute table a secure action
-- button needs. Read at runtime by the rings, and by the loadout
-- editor in the config module.
---------------------------------------------------------------
local ActionMap = db:Register('ActionMap', {
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
		return ActionMap.spellID(spellID)
	end;
	-----------------------------------------------------------
	mount = function(mountID)
		local spellID = select(2, CPAPI.GetMountInfoByID(mountID));
		local spellName = spellID and CPAPI.GetSpellInfo(spellID).name;
		if spellName then
			return ActionMap.spellID(spellName)
		end
	end;
	-----------------------------------------------------------
	petaction = function(spellID, index)
		if index then
			return ActionMap.spellID(spellID)
		end
	end;
	---------------------------------------------------------------
	companion = function(companionID, companionType)
		if ( companionType == 'MOUNT' and CPAPI.GetMountInfoByID(companionID) ) then
			return ActionMap.mount(companionID)
		end
		local _, spellName = GetCompanionInfo(companionType, companionID)
		if spellName then
			return ActionMap.spellID(spellName)
		end
	end;
	---------------------------------------------------------------
	spellID = function(spellID) return {
		type  = 'spell';
		spell = spellID;
		link  = CPAPI.GetSpellLink(spellID)
	} end;
});
