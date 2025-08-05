local env, db, Container = CPAPI.GetEnv(...); Container = env.Frame;
---------------------------------------------------------------
local DEFAULT_SET = CPAPI.DefaultRingSetID;
local DEFAULT_BTN = env.Attributes.DefaultSetBtn;
local BINDING_FMT = ('CLICK %s:%s'):format(Container:GetName(), '%s');
---------------------------------------------------------------
Container.Data, Container.Shared = { [DEFAULT_SET] = env:GetStarterSet() }, {};
env.BindingFormat = BINDING_FMT;
---------------------------------------------------------------
db:Register('Rings', Container)
db:Save('Rings/Data', 'ConsolePortRings')
db:Save('Rings/Shared', 'ConsolePortRingsShared')

function Container:OnDataLoaded()
	env:LoadModules()
	db:Load('Rings/Data', 'ConsolePortRings')
	db:Load('Rings/Shared', 'ConsolePortRingsShared')
	return CPAPI.BurnAfterReading;
end

---------------------------------------------------------------
-- Set information
---------------------------------------------------------------
function Container:GetBindingForSet(setID)
	return BINDING_FMT:format(self:GetBindingSuffixForSet(setID));
end

function Container:GetBindingSuffixForSet(setID)
	return (tonumber(setID) == DEFAULT_SET and DEFAULT_BTN or tostring(setID));
end

function Container:GetSetForBindingSuffix(suffix)
	return (suffix == DEFAULT_BTN and DEFAULT_SET or tonumber(suffix) or tostring(suffix));
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

function Container:GetSetIcon(setID)
	return db.Bindings:GetIcon(self:GetBindingForSet(setID));
end

---------------------------------------------------------------
-- Set manager
---------------------------------------------------------------
function Container:GetSetID(rawSetID)
	return tonumber(rawSetID) or rawSetID;
end

function Container:AddSavedVar(setID, idx, info)
	setID = setID or DEFAULT_SET;
	local set = env:GetSet(setID, true)
	local maxIndex = #set + 1;
	idx = Clamp(idx or maxIndex, 1, maxIndex)
	tinsert(set, idx, info)
end

function Container:RemoveSavedVar(setID, idx)
	return tremove(env:GetSet(setID, true), idx)
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

function Container:SetIconForSet(setID, icon)
	db.Bindings:SetIcon(self:GetBindingForSet(setID), icon);
end

---------------------------------------------------------------
-- Metadata
---------------------------------------------------------------
function Container:GetMetadata(setID)
	local set = env:GetSet(self:GetSetID(setID), true)
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

function Container:ClearActionByCompare(setID, info)
	local index = self:SearchActionByCompare(setID, info)
	if index then
		return self:RemoveAction(setID, index)
	end
end

function Container:SearchActionByAttribute(setID, key, value)
	local set = env:GetSet(setID, true)
	for i, action in ipairs(set) do
		for attribute, content in pairs(action) do
			if (attribute == key and content == value) then
				return i, set;
			end
		end
	end
end

function Container:SearchActionByKey(setID, key)
	local set = env:GetSet(setID, true)
	for i, action in ipairs(set) do
		for attribute in pairs(action) do
			if (attribute == key) then
				return i, set;
			end
		end
	end
end

function Container:SearchActionByCompare(setID, info)
	local set = env:GetSet(setID, true)
	local cmp = db.table.compare;
	for i, action in ipairs(set) do
		if cmp(action, info) then
			return i, set;
		end
	end
end

function Container:IsUniqueAction(setID, info)
	local i, set = self:SearchActionByCompare(setID, info)
	return not i, i, set;
end