---------------------------------------------------------------
-- Action pager and extended secure API
---------------------------------------------------------------
-- Unifies action page changing on all secure headers and
-- extends the secure API to get arbitrary action data.
-- The following attributes can be modified to load a different
-- driver, in order to replicate functionality in other addons:
--   Settings/actionPageCondition : macro condition
--   Settings/actionPageResponse  : response to condition

local Pager, _, db = CPAPI.EventHandler(ConsolePortPager, {'UPDATE_MACROS'}), ...;
db:Register('Pager', Pager)
Pager:Execute('headers = newtable()')

---------------------------------------------------------------
-- Action page swapper
---------------------------------------------------------------
Pager:RegisterForClicks('AnyUp', 'AnyDown')
Pager:WrapScript(Pager, 'PreClick', (([[
	if down then
		self:SetAttribute('action', tonumber(button) or 1)
		self:SetAttribute('release', nil)
		self:SetAttribute('press', 'actionbar')
	else
		self:SetAttribute('action', 1)
		self:SetAttribute('press', nil)
		self:SetAttribute('release', 'actionbar')
	end
]]):gsub('press', CPAPI.ActionTypePress):gsub('release', CPAPI.ActionTypeRelease)))

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
		'possessbar', 'overridebar', 'shapeshift',
		'bar:2', 'bar:3', 'bar:4', 'bar:5', 'bar:6',
		'bonusbar:1', 'bonusbar:2', 'bonusbar:3', 'bonusbar:4', 'bonusbar:5'
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
		for i = #headers, 1, -1 do
			local header = headers[i];
			header:SetAttribute('actionpage', newstate)
			local snippet = header:GetAttribute('ActionPageChanged')
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
	return loadstring(format('local newstate = %d; %s; return newstate;',
		tonumber(SecureCmdOptionParse(self:GetPageCondition())) or 1,
		self:GetPageResponse()))()
end

function Pager:OnDataLoaded()
	local driver, response = self:GetPageCondition(), self:GetPageResponse()
	response = response .. self:GetHeaderResponse()
	self:SetConditionAndResponse(driver, response)
end

db:RegisterSafeCallback('Settings/actionPageCondition', Pager.OnDataLoaded, Pager)
db:RegisterSafeCallback('Settings/actionPageResponse', Pager.OnDataLoaded, Pager)

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
		local id = self::GetActionID(...)
		if id then
			return GetActionInfo(id)
		end
	]];
	GetSpellID = [[
		local actionType, spellID, subType = self::GetActionInfo(...)
		if actionType == 'spell' and subType == 'spell' then
			return spellID
		end
	]];
	GetActionSpellInfo = [[
		local type, spellID, subType = self::GetActionInfo(...)
		if type == 'spell' and spellID and spellID ~= 0 and subType == 'spell' then
			return FindSpellBookSlotBySpellID(spellID)
		end
	]];
	IsHelpfulMacro = [[
		return false -- default, override in header
	]];
	IsHarmfulMacro = [[
		return false -- default, override in header
	]];
	IsHarmfulAction = [[
		local type, id = self::GetActionInfo(...)
		if type == 'spell' then
			local slot = self::GetActionSpellInfo(...)
			if slot then
				return ]]..(function()
					if CPAPI.IsRetailVersion then
						return ('IsSpellHarmful(id, %d)'):format(Enum.SpellBookSpellBank.Player)
					end
					return 'IsSpellHarmful(id)'
				end)()..[[;
			end
		elseif type == 'item' and id then
			return IsHarmfulItem(id)
		elseif type == 'macro' and id then
			local pager = self:GetFrameRef('pager')
			if pager then
				local body = pager:GetAttribute(tostring(id))
				return self::IsHarmfulMacro(body)
			end
		end
	]];
	IsHelpfulAction = [[
		local type, id = self::GetActionInfo(...)
		if type == 'spell' then
			local slot = self::GetActionSpellInfo(...)
			if slot then
				return ]]..(function()
					if CPAPI.IsRetailVersion then
						return ('IsSpellHelpful(id, %d)'):format(Enum.SpellBookSpellBank.Player)
					end
					return 'IsSpellHelpful(id)'
				end)()..[[;
			end
		elseif type == 'item' and id then
			return IsHelpfulItem(id)
		elseif type == 'macro' and id then
			local pager = self:GetFrameRef('pager')
			if pager then
				local body = pager:GetAttribute(tostring(id))
				return self::IsHelpfulMacro(body)
			end
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
		header:SetFrameRef('pager', self)
		self:SetFrameRef('header', header)
		self:Execute('headers[#headers + 1] = self:GetFrameRef("header")')
	end
	return header
end

---------------------------------------------------------------
-- Macro body indexing
---------------------------------------------------------------
function Pager:OnUpdateMacros(macroInfo)
	for id, info in pairs(macroInfo) do
		self:SetAttribute(tostring(id), info.body)
	end
end

function Pager:UPDATE_MACROS()
	db:TriggerEvent('OnUpdateMacros', CPAPI.GetAllMacroInfo())
end

db:RegisterSafeCallback('OnUpdateMacros', Pager.OnUpdateMacros, Pager)