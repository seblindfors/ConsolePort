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

---------------------------------------------------------------
-- Callback management
---------------------------------------------------------------
-- If information needs to be updated when a native function
-- is called, this snippet will run stored functions in response. 

local callBacks, owners = {}, {}

function ConsolePort:RegisterCallback(name, func, owner, orderIndex)
	assert(type(name) == 'string', 'First argument is not a valid string. Arguments (RegisterCallback): \'name\', function')
	assert(type(func) == 'function', 'Second argument is not a function. Arguments (RegisterCallback): \'name\', function')
	assert(type(self[name]) == 'function', 'Named function does not exist. Arguments (RegisterCallback): \'name\', function')

	-- Store the owner
	if owner then
		owners[name] = owners[name] or {}
		owners[name][func] = owner
	end

	-- Add hook if it doesn't exist
	if not callBacks[name] then
		local functionsToRun = {}
		local callBackOwners = owners[name]
		callBacks[name] = functionsToRun
		hooksecurefunc(self, name, function(self, ...)
			for _, callback in ipairs(functionsToRun) do
				callback(callBackOwners and callBackOwners[callback] or self, ...)
			end
		end)
	end

	if orderIndex then
		tinsert(callBacks[name], func, orderIndex)
	else
		tinsert(callBacks[name], func)
	end
end

function ConsolePort:UnregisterCallback(name, func)
	assert(callBacks[name], 'No callbacks are registered for this function.')
	local index, poppedFunc
	for i, storedFunc in ipairs(callBacks[name]) do
		if func == storedFunc then
			index = i
			poppedFunc = storedFunc
			break
		end
	end
	if poppedFunc and owners[name] then
		owners[name][poppedFunc] = nil
	end
	if index then
		tremove(callBacks[name], index)
		return true
	end
end