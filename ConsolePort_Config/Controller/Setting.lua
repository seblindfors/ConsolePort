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

	---@brief Test if a datapoint should be shown, evaluating its
	---       dependencies against the current values in its registry.
	function Setting.IsDatapointShown(dp)
		local field = dp.field;
		if field.hide then
			return false;
		end
		if field.deps then
			local registry = dp.registry or db;
			for dep, value in pairs(field.deps) do
				if Comparator[type(value)](value, registry(dep)) then
					return false;
				end
			end
		end
		return true;
	end
end