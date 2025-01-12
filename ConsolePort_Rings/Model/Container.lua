local env, db, Container = CPAPI.GetEnv(...); Container = env.Frame;
---------------------------------------------------------------
local DEFAULT_SET = CPAPI.DefaultRingSetID;
local BINDING_FMT = ('CLICK %s:%s'):format(Container:GetName(), '%s');
---------------------------------------------------------------
Container.Data = { [DEFAULT_SET] = {} }; env.BindingFormat = BINDING_FMT;
---------------------------------------------------------------
db:Register('Rings', Container)
db:Save('Rings/Data', 'ConsolePortUtility')

function Container:OnDataLoaded()
	db:Load('Rings/Data', 'ConsolePortUtility')
	env:LoadModules(self.Data)
end

---------------------------------------------------------------
-- Set information
---------------------------------------------------------------
function Container:GetBindingForSet(setID)
	return BINDING_FMT:format(self:GetBindingSuffixForSet(setID));
end

function Container:GetBindingSuffixForSet(setID)
	return (tonumber(setID) == DEFAULT_SET and 'LeftButton' or tostring(setID));
end

function Container:GetSetForBindingSuffix(suffix)
	return (suffix == 'LeftButton' and DEFAULT_SET or tonumber(suffix) or tostring(suffix));
end

function Container:GetButtonSlugForSet(setID)
	return db.Hotkeys:GetButtonSlugForBinding(self:GetBindingForSet(setID));
end

function Container:GetBindingDisplayNameForSet(setID)
	return db.Bindings:ConvertRingBindingToDisplayName(self:GetBindingForSet(setID));
end

function Container:GetBindingDisplayNameForSetID(setID)
	return db.Bindings:ConvertRingSetIDToDisplayName(setID);
end

function Container:GetRingLink(setID)
	return env:GetRingLink(self:GetBindingSuffixForSet(setID), self:GetBindingDisplayNameForSetID(setID));
end

---------------------------------------------------------------
-- Set manager
---------------------------------------------------------------
function Container:GetSetID(rawSetID)
	return tonumber(rawSetID) or rawSetID;
end

function Container:AddSavedVar(setID, idx, info)
	setID = setID or DEFAULT_SET;
	local set = self.Data[setID];
	local maxIndex = #set + 1;
	idx = Clamp(idx or maxIndex, 1, maxIndex)
	tinsert(set, idx, info)
end

function Container:RemoveSavedVar(setID, idx)
	return tremove(self.Data[setID], idx)
end

function Container:AddAction(setID, idx, info)
	self:AddSavedVar(setID, idx, info)
	self:RefreshAll()
	return true;
end

function Container:RemoveAction(setID, idx)
	local action = self:RemoveSavedVar(setID, idx)
	self:RefreshAll()
	return action;
end

function Container:SafeAddAction(setID, idx, ...)
	local info = {};
	for i=1, select('#', ...), 2 do
		info[select(i, ...)] = select(i + 1, ...);
	end
	self:AddSavedVar(self:GetSetID(setID), tonumber(idx), info)
end

function Container:SafeRemoveAction(setID, idx)
	if not InCombatLockdown() then
		self:RemoveAction(self:GetSetID(setID), tonumber(idx))
	end
end

function Container:AddUniqueAction(setID, preferredIndex, info)
	if self:IsUniqueAction(setID, info) then
		return self:AddAction(setID, preferredIndex, info)
	end
end

---------------------------------------------------------------
-- Metadata
---------------------------------------------------------------
function Container:GetMetadata(setID)
	local set = rawget(self.Data, self:GetSetID(setID));
	return set and set[env.Attributes.MetadataIndex] or nil;
end

function Container:GetMetadataValue(setID, key)
	local data = self:GetMetadata(setID);
	if data then
		return data[key];
	end
end

function Container:SafeSetMetadata(setID, key, value)
	local data = self:GetMetadata(setID);
	if data then
		data[key] = value;
		return true;
	end
	return false;
end

function Container:GetCurrentMetadata()
	local set = self:GetAttribute('state')
	return self:GetMetadata(set)
end

function Container:GetCurrentMetadataValue(key)
	local data = self:GetCurrentMetadata();
	if data then
		return data[key];
	end
end

---------------------------------------------------------------
-- Search
---------------------------------------------------------------
function Container:GetKindAndAction(info)
	return env:GetKindAndAction(info);
end

function Container:ClearActionByAttribute(setID, key, value)
	local index = self:SearchActionByAttribute(setID, key, value)
	if index then
		return self:RemoveAction(setID, index)
	end
end

function Container:ClearActionByKey(setID, key)
	local index = self:SearchActionByKey(setID, key)
	if index then
		return self:RemoveAction(setID, index)
	end
end

function Container:SearchActionByAttribute(setID, key, value)
	local set = self.Data[setID];
	for i, action in ipairs(set) do
		for attribute, content in pairs(action) do
			if (attribute == key and content == value) then
				return i, set;
			end
		end
	end
end

function Container:SearchActionByKey(setID, key)
	local set = self.Data[setID];
	for i, action in ipairs(set) do
		for attribute in pairs(action) do
			if (attribute == key) then
				return i, set;
			end
		end
	end
end

function Container:IsUniqueAction(setID, info)
	local set = self.Data[setID];
	local cmp = db.table.compare;
	-- check if already existing on ring
	for i, action in ipairs(set) do
		if cmp(action, info) then
			return false, i;
		end
	end
	return true;
end