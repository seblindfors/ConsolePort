local env, db, L = CPAPI.GetEnv(...); L = db.Locale;
---------------------------------------------------------------
local Setting = {}; env.Setting = Setting;
---------------------------------------------------------------
local DP, Path = 1, function(...) return table.concat({...}, '/') end;
---------------------------------------------------------------

---@class ConsolePortSetting
---@field name       string  @The name of the setting.
---@field varID      string  @The variable ID of the setting.
---@field field      table   @The field data of the setting.
---@field newObj     boolean @Whether the setting is a new object.
---@field registry   table   @The registry object of the setting (RelaTable).
---@field callbackID string  @The callback ID of the setting.
---@field owner      Frame   @The owner widget of the setting.
---@field pathID     string  @The db path of the setting. Defaults to 'Settings'.

---@brief Construct a setting widget on top of a CheckButton widget.
---@param dp ConsolePortSetting @The data point for the setting.
local function MountDatapoint(self, dp)
	assert(dp, 'Setting must have a data point.')
	if ( dp.newObj ) then
		local name       = assert(dp.name,     'Setting must have a name.')
		local varID      = assert(dp.varID,    'Setting must have a variable ID.')
		local field      = assert(dp.field,    'Setting must have a data field.')
		local owner      = assert(dp.owner,    'Setting must have an owner widget.')
		local registry   = assert(dp.registry, 'Setting must have a registry object.')
		local dataObj    = assert(field[DP],   'Setting must have a data object.')
		local pathID     = dp.pathID or 'Settings';
		local callbackFn = dp.callbackFn;
		local callbackID = dp.callbackID;

		self.registry, self.pathID = registry, pathID;
		self:SetText(L(name))
		local initializer = env:GetSettingInitializer(dataObj:GetType(), varID)
		if initializer then
			initializer(self, varID, field, dataObj, L(field.desc), L(field.note), owner)

			callbackID = callbackID or Path(pathID, varID);
			callbackFn = callbackFn or function(...) registry(callbackID, ...) end;

			self:SetDataCallback(callbackFn)
			self:RegisterCallback(callbackID, self.OnValueChanged)

			if (field.deps) then
				self:SetDependencies(field.deps)
			end
		end
	end
end

function Setting:Mount(dpOrName, varID, field, newObj, registry, callbackID, owner, pathID)
	self:Hide()
	if ( type(dpOrName) == 'string' ) then ---@deprecated
		MountDatapoint(self, {
			name       = dpOrName,
			varID      = varID,
			field      = field,
			newObj     = newObj,
			registry   = registry,
			callbackID = callbackID,
			owner      = owner,
			pathID     = pathID,
		})
	else
		MountDatapoint(self, dpOrName)
	end
	self:Show()
end

function Setting:Reset()
	if self.SetDataCallback then self:SetDataCallback(nil) end;
	if self.registry and self.callbacks then
		for callbackID in pairs(self.callbacks) do
			self.registry:UnregisterCallback(callbackID, self)
		end
	end
	self.registry, self.callbacks = nil, nil;
end

function Setting:SetDependencies(deps)
	self.deps = CreateFlags(0);
	local flags, callbacks = {}, {};
	for dep, value in db.table.spairs(deps) do
		tinsert(flags, dep)
		callbacks[dep] = self:RegisterDependency(dep, value)
	end
	self.flags = FlagsUtil.MakeFlags(unpack(flags))
	for dep, callback in pairs(callbacks) do
		callback(nil, self.registry(dep))
	end
end

function Setting:RegisterCallback(callbackID, callback, ...)
	self.callbacks = self.callbacks or {};
	self.registry:RegisterCallback(callbackID, callback, self, ...)
	self.callbacks[callbackID] = callback;
	return callback;
end

function Setting:Get()
	if not self.registry then return end;
	return self.registry(self.variableID)
end

do -- Dependencies
	local Comparator = CPAPI.Proxy({
		['function'] = function (lhs, rhs) return not lhs(rhs) end;
	}, function() return function(lhs, rhs) return lhs ~= rhs end end)

	local TriggerDependencyChanged = CPAPI.Proxy({}, function(self, registry)
		return rawset(self, registry, CPAPI.Debounce(
			registry.TriggerEvent, registry, 'OnDependencyChanged'
		))[registry];
	end)

	local function OnDependencyChanged(self, dep, depValue, _, value)
		self.deps:SetOrClear(self.flags[dep], Comparator[type(depValue)](depValue, value))
		self.metaData.hide = self.deps:IsAnySet();
		TriggerDependencyChanged[self.registry](dep)
	end

	function Setting:RegisterDependency(dep, value)
		local callbackID = dep:match('/') and dep or Path(self.pathID, dep);
		local callback = GenerateClosure(OnDependencyChanged, self, dep, value)
		return self:RegisterCallback(callbackID, callback)
	end
end