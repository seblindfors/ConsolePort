---------------------------------------------------------------
-- Action pager and extended secure API
---------------------------------------------------------------
-- Unifies action page changing on all secure headers and
-- extends the secure API to get arbitrary action data.
-- The following attributes can be modified to load a different
-- driver, in order to replicate functionality in other addons:
--   Settings/actionPageCondition : macro condition
--   Settings/actionPageResponse  : response to condition

local Pager, _, db = CPAPI.EventHandler(ConsolePortPager), ...;
db:Register('Pager', Pager)
Pager:Execute('headers = newtable()')

---------------------------------------------------------------
-- Action page swapper
---------------------------------------------------------------
Pager:RegisterForClicks('AnyUp', 'AnyDown')
Pager:WrapScript(Pager, 'PreClick', [[
	if down then
		self:SetAttribute('action', tonumber(button) or 1)
	else
		self:SetAttribute('action', 1)
	end
]])

---------------------------------------------------------------
-- Action page driver
---------------------------------------------------------------
function Pager:GetDefaultPageCondition()
	-- NOTE: this macro condition does not assume the correct page from the state driver.
	-- The generic values are used to push an update to the handler, which uses a secure
	-- replica of ActionBarController_UpdateAll to set the actual page attribute.
	local conditionFormat = '[%s] %d; '
	local count, cond = 0, ''
	for i, macroCondition in ipairs({
		----------------------------------
		'vehicleui', 'possessbar', 'overridebar', 'shapeshift',
		'bar:2', 'bar:3', 'bar:4', 'bar:5', 'bar:6',
		'bonusbar:1', 'bonusbar:2', 'bonusbar:3', 'bonusbar:4'
		----------------------------------
	}) do cond = cond .. conditionFormat:format(macroCondition, i) count = i end
	-- append the list for the default bar (1) when none of the conditions apply.
	cond = cond .. (count + 1)
	----------------------------------
	return cond
end

function Pager:GetDefaultPageResponse()
	-- Replica of ActionBarController_UpdateAll (FrameXML\ActionBarController.lua)
	return ([[
		if HasVehicleActionBar and HasVehicleActionBar() then
			newstate = GetVehicleBarIndex()
		elseif HasOverrideActionBar and HasOverrideActionBar() then
			newstate = GetOverrideBarIndex()
		elseif HasTempShapeshiftActionBar() then
			newstate = GetTempShapeshiftBarIndex()
		elseif GetBonusBarOffset() > 0 then
			newstate = GetBonusBarOffset() + %s
		else
			newstate = GetActionBarPage()
		end
	]]):format(NUM_ACTIONBAR_PAGES)
end

function Pager:GetHeaderResponse()
	return [[
		for header in pairs(headers) do
			header:SetAttribute('actionpage', newstate)
			local snippet = header:GetAttribute('_childupdate-actionpage')
			if snippet then
				header:Run(snippet, newstate)
			end
		end
	]]
end

function Pager:SetConditionAndResponse(condition, response)
	RegisterStateDriver(self, 'actionpage', condition)
	self:SetAttribute('_onstate-actionpage', response)
end

function Pager:GetPageCondition()
	return db('actionPageCondition') or self:GetDefaultPageCondition()
end

function Pager:GetPageResponse()
	return db('actionPageResponse') or self:GetDefaultPageResponse()
end

function Pager:GetCurrentPage()
	return loadstring(format('local newstate; %s; return newstate;', self:GetPageResponse()))()
end

function Pager:OnDataLoaded()
	local driver, response = self:GetPageCondition(), self:GetPageResponse()
	response = response .. self:GetHeaderResponse()
	return self:SetConditionAndResponse(driver, response)
end

---------------------------------------------------------------
-- Spell headers
---------------------------------------------------------------
-- Mixin API (called by header:RunAttribute(func, ...)):
--  GetActionID        : correct ID for an action slot
--  GetActionInfo      : information about an action slot
--  GetActionSpellInfo : spell information about an action slot
--  IsHarmfulAction    : check if the action slot is harmful
--  IsHelpfulAction    : check if the action slot is helpful
---------------------------------------------------------------
Pager.Env = {
	GetActionID = ([[
		local id = ...
		if id then
			local page = self:GetAttribute('actionpage') or 1
			local btns = %d
			if id >= 1 and id <= btns then
				return ( ( page - 1 ) * btns ) + id
			else
				return id
			end
		end
	]]):format(NUM_ACTIONBAR_BUTTONS);
	GetActionInfo = [[
		local id = self:RunAttribute('GetActionID', ...)
		if id then
			return GetActionInfo(id)
		end
	]];
	GetSpellID = [[
		local actionType, spellID, subType = self:RunAttribute('GetActionInfo', ...)
		if actionType == 'spell' and subType == 'spell' then
			return spellID
		end
	]];
	GetActionSpellInfo = [[
		local type, spellID, subType = self:RunAttribute('GetActionInfo', ...)
		if type == 'spell' and spellID and spellID ~= 0 and subType == 'spell' then
			return FindSpellBookSlotBySpellID(spellID)
		end
	]];
	IsHarmfulAction = [[
		local type, id = self:RunAttribute('GetActionInfo', ...)
		if type == 'spell' then
			local slot = self:RunAttribute('GetActionSpellInfo', ...)
			if slot then
				return IsHarmfulSpell(slot, 'spell')
			end
		elseif type == 'item' and id then
			return IsHarmfulItem(id)
		end
	]];
	IsHelpfulAction = [[
		local type, id = self:RunAttribute('GetActionInfo', ...)
		if type == 'spell' then
			local slot = self:RunAttribute('GetActionSpellInfo', ...)
			if slot then
				return IsHelpfulSpell(slot, 'spell')
			end
		elseif type == 'item' and id then
			return IsHelpfulItem(id)
		end
	]];
}

function Pager:RegisterHeader(header, anonymous)
	assert(not InCombatLockdown(), 'Header cannot be registered in combat.')
	assert(header.CreateEnvironment, 'Header is missing SecureEnvironmentMixin.')
	header:CreateEnvironment(self.Env)
	if not anonymous then
		local page = self:GetCurrentPage()
		header:SetAttribute('actionpage', page)

		-- add references to Blizzard frames
		if MainMenuBarArtFrame then header:SetFrameRef('mainmenubar', MainMenuBarArtFrame) end
		if OverrideActionBar   then header:SetFrameRef('overridebar', OverrideActionBar) end

		self:SetFrameRef('header', header)
		self:Execute('headers[self:GetFrameRef("header")] = true')
	end
	return header
end