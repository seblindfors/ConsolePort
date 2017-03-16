---------------------------------------------------------------
-- Update management
---------------------------------------------------------------
-- Keeps a stack of update snippets to run continuously. 
-- Allows plug-ins to hook/unhook scripts on the main frame.
-- This can also be used to add update snippets that need to
-- run on secure headers outside of combat.

local _, db = ...
local interval, time, scripts = 0.1, 0, {}

local function OnUpdate (self, elapsed)
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

function ConsolePort:RegisterCallback(functionName, func, owner, orderIndex)
	assert(type(functionName) == 'string', 'First argument is not a valid string. Arguments (RegisterCallback): \'functionName\', function')
	assert(type(func) == 'function', 'Second argument is not a function. Arguments (RegisterCallback): \'functionName\', function')
	assert(self[functionName], 'Named function does not exist. Arguments (RegisterCallback): \'functionName\', function')

	-- Store the owner
	if owner then
		if not owners[functionName] then
			owners[functionName] = {}
		end
		owners[functionName][func] = owner
	end

	-- Add hook if it doesn't exist
	if not callBacks[functionName] then
		local functions = {}
		local subOwners = owners[functionName]
		callBacks[functionName] = functions
		hooksecurefunc(self, functionName, function(self, ...)
			for i, func in pairs(functions) do
				local owner = subOwners and subOwners[func]
				func(owner or self, ...)
			end
		end)
	end

	if orderIndex then
		tinsert(callBacks[functionName], func, orderIndex)
	else
		tinsert(callBacks[functionName], func)
	end
end

function ConsolePort:UnregisterCallback(functionName, func)
	assert(callBacks[functionName], 'No callbacks are registered for this function.')
	local index, poppedFunc
	for i, storedFunc in pairs(callBacks[functionName]) do
		if func == storedFunc then
			index = i
			poppedFunc = storedFunc
			break
		end
	end
	if poppedFunc and owners[functionName] then
		owners[functionName][poppedFunc] = nil
	end
	if index then
		tremove(callBacks[functionName], index)
		return true
	end
end