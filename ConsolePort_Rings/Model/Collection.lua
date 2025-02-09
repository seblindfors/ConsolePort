local env, db, L = CPAPI.GetEnv(...); L = env.L;
---------------------------------------------------------------

function env:GetCollections(currentSetID, isSharedSet)
	-- NOTE: securecall wrapper, so if one of the collectors fails, the rest can still run
	local collections, collect = {}, securecallfunction;

	local function AddCollection(collection, configuration)
		collections[#collections + 1] = configuration;
		configuration.items = collection;
		return configuration, collections;
	end

	local function IsDataValid(data)
		return (data and next(data) ~= nil);
	end

	local function EnumerateSets()
		-- NOTE: using nested rings is a one-way street; you should
		-- not be able to nest a personal ring inside a shared ring,
		-- (except for the default ring which is always personal but
		-- can be shared because it can't be deleted).
		if isSharedSet then
			local sets = CopyTable(env:GetShared(true))
			local defaultSet = env:GetData(true)[CPAPI.DefaultRingSetID];
			tinsert(sets, 1, defaultSet);
			return pairs(sets);
		end
		return self:EnumerateAvailableSets(true);
	end

	local nestedRings = collect(function()
		local otherRings = {};
		for otherID in EnumerateSets() do
			if otherID ~= currentSetID then
				tinsert(otherRings, otherID);
			end
		end
		return otherRings;
	end)

	if IsDataValid(nestedRings) then
		AddCollection(nestedRings, {
			name    = L'Nested Rings';
			header  = SPECIAL;
			map     = function(map, id) return map.ring(id) end;
			title   = function(id) return env.Frame:GetBindingDisplayNameForSetID(id) end;
			tooltip = function(tooltip, id)
				tooltip:SetText(env.Frame:GetBindingDisplayNameForSetID(id), 1, 1, 1);
				tooltip:AddLine(env:GetDescriptionFromRingLink(env.Frame:GetRingLink(id)));
				tooltip:Show()
			end;
			texture = function(id) return env:GetSetIcon(id) end;
		});
	end

	return collections;
end