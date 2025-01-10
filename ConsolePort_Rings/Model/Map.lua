local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
---@see GetCursorInfo Secure handler map for ring actions/LAB
---------------------------------------------------------------
env.SecureHandlerMap = {
	-- Simple types -----------------------------------------------
	action = function(action) return {
		type   = 'action';
		action = action;
	} end;
	---------------------------------------------------------------
	item = function(itemID, itemLink) return {
		type = 'item';
		item = itemLink or itemID;
		link = itemLink;
	} end;
	---------------------------------------------------------------
	macro = function(index) return CreateFromMixins(CPAPI.GetMacroInfo(index), {
		type  = 'macro';
		macro = index;
	}) end;
	---------------------------------------------------------------
	equipmentset = function(name) return {
		type         = 'equipmentset';
		equipmentset = name;
	} end;
	-- Spell conversion -------------------------------------------
	spell = function(spellIndex, bookType, spellID)
		return env.SecureHandlerMap.spellID(spellID)
	end;
	---------------------------------------------------------------
	mount = function(mountID)
		local spellID = select(2, CPAPI.GetMountInfoByID(mountID));
		local spellName = spellID and CPAPI.GetSpellInfo(spellID).name;
		if spellName then
			return env.SecureHandlerMap.spellID(spellName)
		end
	end;
	---------------------------------------------------------------
	petaction = function(spellID, index)
		if index then
			return env.SecureHandlerMap.spellID(spellID)
		end
	end;
	---------------------------------------------------------------
	companion = function(companionID, companionType)
		if ( companionType == 'MOUNT' and CPAPI.GetMountInfoByID(companionID) ) then
			return env.SecureHandlerMap.mount(companionID)
		end
		local _, spellName = GetCompanionInfo(companionType, companionID)
		if spellName then
			return env.SecureHandlerMap.spellID(spellName)
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
-- Mapping from type to usable LAB attributes
---------------------------------------------------------------
local function GetUsableSpellID(data)
	return ( data.link and data.link:match('spell:(%d+)') )
		or CPAPI.GetSpellInfo(data.spell).spellID or data.spell;
end

env.KindAndActionMap = {
	action = function(data) return data.action end;
	item   = function(data) return data.item end;
	pet    = function(data) return data.action end;
	macro  = function(data) return data.macro end;
	spell  = function(data) return GetUsableSpellID(data) end;
	equipmentset = function(data) return data.equipmentset end;
}

function env:GetKindAndAction(info)
	return info.type, self.KindAndActionMap[info.type](info);
end

---------------------------------------------------------------
---@see GetActionInfo Action info link map
---------------------------------------------------------------
env.LinkMap = {
	spell = function(spell, ...)
		local args = select('#', ...)
		if (args > 1) then
			local bookType = ...;
			return CPAPI.GetSpellBookItemLink(spell, bookType)
		end
		return CPAPI.GetSpellLink(spell)
	end;
	item = function(...)
		return select(2, ...)
	end;
}

function env:GetLinkFromActionInfo(type, ...)
	local func = self.LinkMap[type];
	if func then
		return func(...)
	end
end

---------------------------------------------------------------
-- Data validation
---------------------------------------------------------------
env.ValidationMap = {
	macro = function(data)
		local macroID = data.macro;
		local info = CPAPI.GetMacroInfo(macroID)
		if not data.body and info then
			return CreateFromMixins(data, info)
		elseif ( not info or ( data.body ~= info.body) ) then
			local bestMatchID, bestMatchScore = nil, math.huge;
			local test = { body = data.body, name = data.name, icon = data.icon }

			for id, other in pairs(CPAPI.GetAllMacroInfo()) do
				local score = 0;
				if other.body and test.body then
					score = score + CPAPI.MinEditDistance(other.body, test.body)
				end
				if other.name and test.name then
					score = score + CPAPI.MinEditDistance(other.name, test.name)
				end
				if other.icon == test.icon then
					score = score - 1 -- Matching icon reduces the score
				end
				if score < bestMatchScore then
					bestMatchScore, bestMatchID = score, id;
				end
			end

			if bestMatchID then
				return CreateFromMixins(data, CPAPI.GetMacroInfo(bestMatchID), {
					macro = bestMatchID;
				})
			end
		end
		return data;
	end;
	item = function(data, setID, idx)
		local item = data.item;
		local link = data.link;
		if not item and not link then
			return CPAPI.Log('Invalid item removed from %s in slot %d.',
				db.Bindings:ConvertRingSetIDToDisplayName(setID),
				idx
			);
		end
		if ( type(item) == 'number' ) then
			item = CPAPI.GetItemInfo(item).itemLink;
			link = item;
		end
		if not item then
			item = link;
		end
		if not tostring(item):match('item:%d+') then
			-- NOTE: This check is to make sure LAB:getItemId receives a valid item link.
			return CPAPI.Log('Invalid item removed from %s:\nID: %s\nLink: %s',
				db.Bindings:ConvertRingSetIDToDisplayName(setID),
				tostring(item),
				tostring(link)
			);
		end
		return CreateFromMixins(data, { item = item, link = link });
	end;
	--[[spell = function(data, setID, idx)
		local spell = data.spell;
		local link  = data.link;
		if not spell and not link then
			return CPAPI.Log('Invalid spell removed from %s in slot %d.',
				db.Bindings:ConvertRingSetIDToDisplayName(setID),
				idx
			);
		end
		if not spell then
			spell = link;
		end
		local info = CPAPI.GetSpellInfo(spell)
		if not info.spellID and not CPAPI.GetSpellLink(spell) then
			-- NOTE: if the spellID is not found, the spell is invalid,
			-- at least for the current character.
			return CPAPI.Log('Invalid spell removed from %s:\nID: %s\nLink: %s',
				db.Bindings:ConvertRingSetIDToDisplayName(setID),
				tostring(spell),
				tostring(link)
			);
		end
		return data;
	end;]]
};

function env:ValidateAction(action, setID, idx)
	if not action then return end;
	local validator = self.ValidationMap[action.type];
	if validator then
		return validator(action, setID, idx);
	end
	return action;
end

function env:ValidateData(data)
	for setID, set in pairs(data) do
		local validSet = {};
		for i = 1, #set do
			local validAction = self:ValidateAction(set[i], setID, i);
			if validAction then
				tinsert(validSet, validAction)
			end
		end
		wipe(set)
		tAppendAll(set, validSet)
	end
	return data;
end