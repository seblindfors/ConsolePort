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
-- spellupdate: a snippet that fires after the spell update.
-- spellusable: filter out passives/spells that can't be used.
-- spellsorted: sort spellIDs by bookID, omit bookID.

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
				if spellID and IsPlayerSpell(spellID) then
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
			local sorted = header:GetAttribute("spellsorted")
			local usable = header:GetAttribute("spellusable")
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
			local postUpdateSnippet = header:GetAttribute("spellupdate")
			if postUpdateSnippet then
				header:Execute(postUpdateSnippet)
			end
		end
		self:RemoveUpdateSnippet(self.UpdateSecureSpellbook)
	end
end

---------------------------------------------------------------
-- This is a wrapper for securely changing action page on 
-- multiple headers, instead of repeating the page update for
-- each of the individual and specialized headers.

-- Attributes headers can use:
-- pageupdate: a snippet that fires after the page update.
-- force-pageupdate: a snippet that forces a page update.

-- Value changed:
-- PAGE: global variable available inside each registered header.

function ConsolePort:RegisterActionPage(header)
	if not InCombatLockdown() then
		local currentPage, actionpage = self:GetActionPageState()
		RegisterStateDriver(header, "actionpage", actionpage)
		header:SetFrameRef("ActionBar", MainMenuBarArtFrame)
		header:SetFrameRef("OverrideBar", OverrideActionBar)
		header:SetAttribute("pagedriver", actionpage)
		header:SetAttribute("force-pageupdate", [[
			self:RunAttribute("updateactionpage", SecureCmdOptionParse(self:GetAttribute("pagedriver")))
		]])
		header:SetAttribute("_onstate-actionpage", [[
			self:RunAttribute("updateactionpage", newstate)
		]])
		header:SetAttribute("updateactionpage", [[
			PAGE = ...
			if PAGE == "temp" then
				if HasTempShapeshiftActionBar() then
					PAGE = GetTempShapeshiftBarIndex()
				else
					PAGE = 1
				end
			elseif PAGE and PAGE == "possess" then
				PAGE = self:GetFrameRef("ActionBar"):GetAttribute("actionpage") or 1
				if PAGE <= 10 then
					PAGE = self:GetFrameRef("OverrideBar"):GetAttribute("actionpage") or 12
				end
				if PAGE <= 10 then
					PAGE = 12
				end
			end
			if self:GetAttribute("pageupdate") then
				self:RunAttribute("pageupdate", PAGE)
			end
		]])
		header:Execute(header:GetAttribute("force-pageupdate"))
	end
end

function ConsolePort:UnregisterActionPage(header)
	-- scrub the header from action page updating
	if not InCombatLockdown() then
		UnregisterStateDriver(header, "actionpage")
		header:SetAttribute("pagedriver", nil)
		header:SetAttribute("force-pageupdate", nil)
		header:SetAttribute("updateactionpage", nil)
		header:SetAttribute("_onstate-actionpage", nil)
	end
end