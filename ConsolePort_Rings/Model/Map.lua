local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
---@see GetCursorInfo Secure handler map for ring actions/LAB
---------------------------------------------------------------
env.SecureHandlerMap = CreateFromMixins(db.Loadout.SecureHandlerMap, {
	-- Custom types -----------------------------------------------
	ring = function(setID) return {
		type = 'custom';
		ring = setID;
		link = env.Frame:GetRingLink(setID);
	} end;
	---------------------------------------------------------------
	binding = function(bindingID) return {
		type    = 'custom';
		binding = bindingID;
	} end;
});

---------------------------------------------------------------
-- Mapping from type to usable LAB attributes
---------------------------------------------------------------
local function GetUsableSpellID(data)
	return ( data.link and data.link:match('spell:(%d+)') )
		or CPAPI.GetSpellInfo(data.spell).spellID or data.spell;
end

local function GetCustomAction(data)
	if data.ring then
		local _, _, name, texture = env:GetDescriptionFromRingLink(data.link)
		local secureEnvData = {
			type = env.Attributes.NestedRing;
			ring = tostring(data.ring);
		};
		return { -- LAB data
			func = function() return secureEnvData end;
			text = name;
			texture = texture;
			tooltip = name;
		}, secureEnvData;
	end
	if data.binding then
		local desc, _, name, texture = db.Bindings:GetDescriptionForBinding(data.binding)
		local secureEnvData = {
			type = 'macro';
			macro = false;
			macrotext = data.binding:gsub('CLICK', '/click'):gsub(':', ' ')
		};
		return { -- LAB data
			func = function() return secureEnvData end;
			text = name;
			texture = texture;
			tooltip = name;
		}, secureEnvData;
	end
end

env.KindAndActionMap = {
	custom       = function(data) return GetCustomAction(data) end;
	spell        = function(data) return GetUsableSpellID(data) end;
	action       = function(data) return data.action end;
	item         = function(data) return data.item end;
	pet          = function(data) return data.action end;
	macro        = function(data) return data.macro end;
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
-- Action data validation
---------------------------------------------------------------
env.ActionValidationMap = {
	macro = function(data)
		local macroID = data.macro;
		local info = CPAPI.GetMacroInfo(macroID)
		data.macrotext = false;
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
	spell = function(data, setID, idx)
		if not env.IsSpellValidationReady then
			return data;
		end
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
		-- NOTE: No inline replacement is safe here, since some spells are not
		-- usable by their IDs. Ideally we'd replace all strings with spellIDs here,
		-- but e.g. mounts (which are mapped as spells) do not work unless invoked
		-- by their spell name.
		return data;
	end;
	custom = function(data, setID)
		if data.ring then
			if not env:GetSet(data.ring, true) then
				return CPAPI.Log('Expired ring %s removed from %s.',
					data.link, db.Bindings:ConvertRingSetIDToDisplayName(setID)
				);
			end
		end
		return data;
	end;
};

function env:ValidateAction(action, setID, idx)
	if not action then return end;
	local validator = self.ActionValidationMap[action.type];
	if validator then
		return validator(action, setID, idx);
	end
	return action;
end

---------------------------------------------------------------
-- Meta data validation
---------------------------------------------------------------
env.MetaValidationMap = {
	sticky = function(set, value)
		return Clamp(value, 1, #set);
	end;
};

function env:ValidateMeta(set, meta)
	local validMeta = {};
	for key, value in pairs(meta) do
		local validator = self.MetaValidationMap[key];
		if validator then
			value = validator(set, value);
		end
		validMeta[key] = value;
	end
	return validMeta;
end

---------------------------------------------------------------
-- Validator
---------------------------------------------------------------
function env:ValidateSet(setID, set)
	local validSet = {};
	local meta = set[env.Attributes.MetadataIndex] or {};
	for i = 1, #set do
		local validAction = self:ValidateAction(set[i], setID, i);
		if validAction then
			tinsert(validSet, validAction)
		end
	end
	wipe(set)
	tAppendAll(set, validSet)
	set[env.Attributes.MetadataIndex] = self:ValidateMeta(set, meta)
	return set;
end

function env:ValidateData(data)
	for setID, set in pairs(data) do
		self:ValidateSet(setID, set);
	end
	return data;
end