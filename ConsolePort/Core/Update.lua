---------------------------------------------------------------
-- Update.lua: Update management
---------------------------------------------------------------
-- Keeps a stack of update snippets to run continuously. 
-- Allows plug-ins to hook/unhook scripts on the main frame.
-- This can also be used to add update snippets that need to
-- run on secure headers outside of combat.

local _, db = ...
local spairs = db.Table.pairsByKeys
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

---------------------------------------------------------------
-- These functions help with caching spells securely on headers,
-- which is desirable when deciding the outcome of an action or
-- dynamically probing the restricted environment with insecure
-- information about spells. Indexing works by using
-- spell ID as key and spell book slot as value.

-- Attributes headers can use:
-- _spellupdate: a snippet that fires after the spell update.
-- _spellusable: filter out passives/spells that can't be used.
-- _spellsorted: sort spellIDs by bookID, omit bookID.

local Headers = {}

function ConsolePort:RegisterSpellbook(header)
	Headers[header] = true
	self:AddUpdateSnippet(self.UpdateSecureSpellbook, "_spellupdate")
end

function ConsolePort:UnregisterSpellbook(header)
	Headers[header] = nil
end

function ConsolePort:UpdateSecureSpellbook()
	if not InCombatLockdown() then
		local spellsByID = {}
		local spellsByName = {}
		for id=1, MAX_SPELLS do
			local ok, err, _, _, _, _, _, spellID = pcall(GetSpellInfo, id, "spell")
			if ok then
				if spellID and IsSpellKnown(spellID) then
					spellsByID[spellID] = id
					spellsByName[GetSpellInfo(spellID)] = spellID
				end
			else
				break
			end
		end
		for header in pairs(Headers) do
			header:Execute([[
				if SPELLS then
					SPELLS = wipe(SPELLS)
				else
					SPELLS = newtable()
				end
			]])
			local sorted = header:GetAttribute("_spellsorted")
			local usable = header:GetAttribute("_spellusable")
			if sorted then
				for name, spellID in spairs(spellsByName) do
					if (not usable) or (usable and not IsPassiveSpell(spellsByID[spellID], "spell")) then
						header:Execute(format([[
							tinsert(SPELLS, %d)
						]], spellID))
					end
				end
			else
				for spellID, bookID in pairs(spellsByID) do
					if (not usable) or (usable and not IsPassiveSpell(bookID, "spell")) then
						header:Execute(format([[
							SPELLS[%d] = %d
						]], spellID, bookID))
					end
				end
			end
			local postUpdateSnippet = header:GetAttribute("_spellupdate")
			if postUpdateSnippet then
				header:Execute(postUpdateSnippet)
			end
		end
		self:RemoveUpdateSnippet(self.UpdateSecureSpellbook)
	end
end