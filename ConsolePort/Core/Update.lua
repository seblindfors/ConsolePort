local addOn, db = ...
local ConsolePort = ConsolePort

local interval = 0.1
local time = 0
local UpdateSnippets = {}
local function OnUpdate (self, elapsed)
	time = time + elapsed
	while time > interval do
		for i, Snippet in pairs(UpdateSnippets) do
			Snippet(self)
		end
		time = time - interval
	end
end

ConsolePort:SetScript("OnUpdate", OnUpdate);

function ConsolePort:AddUpdateSnippet(snippet)
	if type(snippet) == "function" then
		tinsert(UpdateSnippets, snippet)
		return #UpdateSnippets
	end
end

function ConsolePort:RemoveUpdateSnippet(index)
	UpdateSnippets[index] = nil
end

function ConsolePort:GetUpdateSnippets()
	return UpdateSnippets
end