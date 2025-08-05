local env, db, _, L = CPAPI.GetEnv(...);
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

	local bindings = collect(function()
		local bindings = {};
		for bindingID in env.table.spairs(db.Bindings.Macroable) do
			tinsert(bindings, db.Bindings.Custom[bindingID]);
		end
		return bindings;
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

	if IsDataValid(bindings) then
		AddCollection(bindings, {
			name    = KEY_BINDINGS;
			header  = SPECIAL;
			map = function(map, id)
				return map.binding(id)
			end;
			title = function(id)
				return select(3, db.Bindings:GetDescriptionForBinding(id))
			end;
			tooltip = function(tooltip, id)
				local desc, _, name = db.Bindings:GetDescriptionForBinding(id, true, 50);
				tooltip:SetText(name, 1, 1, 1);
				tooltip:AddLine(desc or SPECIAL);
				tooltip:Show()
			end;
			texture = function(id)
				return (select(4, db.Bindings:GetDescriptionForBinding(id)))
			end;
		});
	end

	collect(function() -- Action bar slots
		local function GetActionSlotName(id)
			return BINDING_NAME_ACTIONBUTTON1:gsub('%d', id);
		end

		local configuration = {
			header  = ACTIONBARS_LABEL;
			map     = function(map, id) return map.action(id) end;
			texture = function(id)
				local texture = GetActionTexture(id);
				if texture then
					return texture;
				end
				return CPAPI.GetAsset([[Textures\Button\NotBound]])
			end;
			title   = function(id)
				local name = db.Loadout:GetActionInfo(id) or EMPTY;
				return ('%s |cFF757575(%d)|r'):format(name, id);
			end;
			tooltip = function(tooltip, id)
				tooltip:SetAction(id);
				tooltip:AddLine(GetActionSlotName(id), 1, 1, 1);
				tooltip:Show()
			end;
		};

		local bars = {};
		for groupID, container in db:For('Actionbar/Pages') do
			for barIndex, barID in ipairs(container) do
				local stanceBarInfo = db.Actionbar.Lookup.Stances[barID];
				local stanceBarName = stanceBarInfo and stanceBarInfo.name;

				local items = {};
				local pageOffset = (barID - 1) * NUM_ACTIONBAR_BUTTONS;
				for i = 1, NUM_ACTIONBAR_BUTTONS do
					tinsert(items, pageOffset + i);
				end
				local barConfig = CPAPI.Proxy({
					name     = stanceBarName or db.Actionbar.Names[barID];
					priority = (stanceBarName and 0 or groupID) * 100 + barIndex;
				}, configuration)
				bars[barConfig] = items;
			end
		end

		local function SortBarsByPriority(_, a, b)
			return a.priority < b.priority;
		end

		for barConfig, items in env.table.spairs(bars, SortBarsByPriority) do
			AddCollection(items, barConfig);
		end
	end) -- Action bar slots

	return collections;
end