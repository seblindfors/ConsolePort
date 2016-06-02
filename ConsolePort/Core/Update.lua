---------------------------------------------------------------
-- Update.lua: Update management
---------------------------------------------------------------
-- Keeps a stack of update snippets to run continuously. 
-- Allows plug-ins to hook/unhook scripts on the main frame.
-- This can also be used to add update snippets that need to
-- run on secure headers outside of combat.

local _, db = ...
local spairs = db.table.spairs
local interval = 0.1
local time = 0
local UpdateSnippets = {}

local function OnUpdate (self, elapsed)
	time = time + elapsed
	while time > interval do
		for Snippet in pairs(UpdateSnippets) do
			Snippet(self, elapsed)
		end
		time = time - interval
	end
end

ConsolePort:SetScript("OnUpdate", OnUpdate);

function ConsolePort:AddUpdateSnippet(snippet, ID)
	if type(snippet) == "function" then
		UpdateSnippets[snippet] = ID or true
	end
end

function ConsolePort:RemoveUpdateSnippet(snippet)
	UpdateSnippets[snippet] = nil
end

function ConsolePort:GetUpdateSnippets()
	return UpdateSnippets
end