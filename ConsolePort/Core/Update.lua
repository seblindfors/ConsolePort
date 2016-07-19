---------------------------------------------------------------
-- Update.lua: Update management
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
		for Snippet in pairs(scripts) do
			Snippet(self, elapsed)
		end
		time = time - interval
	end
end

ConsolePort:SetScript("OnUpdate", OnUpdate)

function ConsolePort:AddUpdateSnippet(snippet, ID)
	if type(snippet) == "function" then
		scripts[snippet] = ID or true
	end
end

function ConsolePort:RemoveUpdateSnippet(snippet)
	scripts[snippet] = nil
end

function ConsolePort:GetUpdateSnippets()
	return scripts
end