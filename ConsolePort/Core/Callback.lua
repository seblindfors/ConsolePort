---------------------------------------------------------------
-- Update management
---------------------------------------------------------------
-- Keeps a stack of update snippets to run continuously. 
-- Allows plug-ins to hook/unhook scripts on the main frame.
-- This can also be used to add update snippets that need to
-- run on secure headers outside of combat.

local interval, time, scripts = 0.1, 0, {}

local function OnUpdate(self, elapsed)
	time = time + elapsed
	while time > interval do
		for snippet, snippetData in pairs(scripts) do
			snippet(self, unpack(snippetData))
		end
		time = time - interval
	end
end

function ConsolePort:AddUpdateSnippet(snippet, ...)
	if type(snippet) == 'function' then
		scripts[snippet] = {...}
		self:SetScript('OnUpdate', OnUpdate)
	end
end

function ConsolePort:RemoveUpdateSnippet(snippet)
	scripts[snippet] = nil
	if not next(scripts) then
		time = 0
		self:SetScript('OnUpdate', nil)
	end
end

function ConsolePort:RunOOC(snippet, ...)
	if InCombatLockdown() then
		self:AddUpdateSnippet(snippet, ...)
	else
		snippet(self, ...)
	end
end

---------------------------------------------------------------
-- Callback management
---------------------------------------------------------------
-- If information needs to be updated when a native function
-- is called, this snippet will run stored functions in response. 

local callbacks, cvarCallbacks, owners = {}, {}, {}

function ConsolePort:RegisterCallback(method, func, owner, orderIndex)
	assert(type(method) == 'string', 'First argument is not a valid string. Arguments (RegisterCallback): \'method\', callback')
	assert(type(func) == 'function', 'Second argument is not a function. Arguments (RegisterCallback): \'method\', callback')
	assert(type(self[method]) == 'function', 'Named method does not exist. Arguments (RegisterCallback): \'method\', callback')

	-- Store the owner
	if owner then
		owners[method] = owners[method] or {}
		owners[method][func] = owner
	end

	-- Add hook if it doesn't exist
	if not callbacks[method] then
		local functionsToRun = {}
		local callBackOwners = owners[method]
		callbacks[method] = functionsToRun
		hooksecurefunc(self, method, function(self, ...)
			for _, callback in ipairs(functionsToRun) do
				callback(callBackOwners and callBackOwners[callback] or self, ...)
			end
		end)
	end

	if orderIndex then
		tinsert(callbacks[method], func, orderIndex)
	else
		tinsert(callbacks[method], func)
	end
end

function ConsolePort:UnregisterCallback(method, func)
	assert(callbacks[method], ('No callbacks are registered for %s.'):format(method))
	local index, poppedFunc
	for i, storedFunc in ipairs(callbacks[method]) do
		if func == storedFunc then
			index = i
			poppedFunc = storedFunc
			break
		end
	end
	if poppedFunc and owners[method] then
		owners[method][poppedFunc] = nil
	end
	if index then
		tremove(callbacks[method], index)
		return true
	end
end

function ConsolePort:RegisterVarCallback(cvar, func, owner, ...)
	cvarCallbacks[cvar] = cvarCallbacks[cvar] or {}
	for i, data in ipairs(cvarCallbacks[cvar]) do
		if data[1] == func then
			cvarCallbacks[cvar][i] = {func, owner, ...}
			return
		end
	end
	tinsert(cvarCallbacks[cvar], {func, owner, ...})
end


function ConsolePort:FireVarCallback(cvar, newvalue)
	local cvarCallbacks = cvarCallbacks[cvar]
	if cvarCallbacks then
		for i, data in ipairs(cvarCallbacks) do
			local callback, owner = data[1], data[2]
			-- create lambda wrapper to fire OOC
			local function cb(caller, lambda, callback, ...)
				if not InCombatLockdown() then
					caller:RemoveUpdateSnippet(lambda)
					callback(...)
				end
			end
			if C_Widget.IsFrameWidget(owner) then
				self:RunOOC(cb, cb, callback, owner, newvalue, unpack(data, 3))
			else
				self:RunOOC(cb, cb, callback, newvalue, owner, unpack(data, 3))
			end
		end
	end
end