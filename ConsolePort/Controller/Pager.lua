---------------------------------------------------------------
-- Action pager and extended secure API
---------------------------------------------------------------
-- Unifies action page changing on all secure headers and
-- extends the secure API to get arbitrary action data.
-- The following attributes can be modified to load a different
-- driver, in order to replicate functionality in other addons:
--   Settings/actionPageCondition : macro condition
--   Settings/actionPageResponse  : response to condition

local Pager, _, db = Mixin(CPAPI.EventHandler(ConsolePortPager, {'UPDATE_BONUS_ACTIONBAR'}), CPAPI.SecureEnvironmentMixin), ...;
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

-- Replica of ActionBarController_UpdateAll (FrameXML\ActionBarController.lua)
local DEFAULT_PAGE_RESPONSE = ([[
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
]]):format(NUM_ACTIONBAR_PAGES);

local HEADER_RESPONSE = [[
	self:SetAttribute('actionpage', newstate)
	for i = #headers, 1, -1 do
		local header = headers[i];
		header:SetAttribute('actionpage', newstate)
		local snippet = header:GetAttribute('ActionPageChanged')
		if snippet then
			header:Run(snippet, newstate)
		end
	end
	self:CallMethod('OnActionPageChanged', newstate)
]];

function Pager:GetDefaultPageResponse()
	return DEFAULT_PAGE_RESPONSE;
end

function Pager:GetHeaderResponse()
	return HEADER_RESPONSE;
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
	return CPAPI.KeepMeForLater;
end

db:RegisterSafeCallback('Settings/actionPageCondition', Pager.OnDataLoaded, Pager)
db:RegisterSafeCallback('Settings/actionPageResponse', Pager.OnDataLoaded, Pager)

---------------------------------------------------------------
-- Spell headers
---------------------------------------------------------------
-- Headers registered with the pager receive continuous action
-- page updates, and a pager upvalue in their restricted
-- environment to access the extended action API, e.g.
-- pager::IsHelpfulAction(action):
--  GetActionID        : correct ID for an action slot
--  GetActionInfo      : information about an action slot
--  GetSpellID         : spell ID for an action slot
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
		local spellID = self::GetSpellID(...)
		if spellID then
			return FindSpellBookSlotBySpellID(spellID)
		end
	]];
	IsHarmfulAction = [[
		local type, id, subType = self::GetActionInfo(...)
		if ( type == 'spell' and subType == 'spell' and id and id ~= 0 ) then
			if FindSpellBookSlotBySpellID(id) then
				return ]]..(function()
					if CPAPI.IsRetailVersion then
						return ('IsSpellHarmful(id, %d)'):format(Enum.SpellBookSpellBank.Player)
					end
					return 'IsSpellHarmful(id)'
				end)()..[[;
			end
		elseif ( type == 'item' and id ) then
			return IsHarmfulItem(id)
		end
	]];
	IsHelpfulAction = [[
		local type, id, subType = self::GetActionInfo(...)
		if ( type == 'spell' and subType == 'spell' and id and id ~= 0 ) then
			if FindSpellBookSlotBySpellID(id) then
				return ]]..(function()
					if CPAPI.IsRetailVersion then
						return ('IsSpellHelpful(id, %d)'):format(Enum.SpellBookSpellBank.Player)
					end
					return 'IsSpellHelpful(id)'
				end)()..[[;
			end
		elseif ( type == 'item' and id ) then
			return IsHelpfulItem(id)
		end
	]];
}

Pager:CreateEnvironment(Pager.Env)

function Pager:RegisterHeader(header)
	assert(not InCombatLockdown(), 'Header cannot be registered in combat.')
	header:SetAttribute('actionpage', self:GetCurrentPage())
	header:SetFrameRef('pager', self)
	header:Execute('pager = self:GetFrameRef("pager")')
	self:SetFrameRef('header', header)
	self:Execute('headers[#headers + 1] = self:GetFrameRef("header")')
	return header
end

---------------------------------------------------------------
-- Cache information dispatch
---------------------------------------------------------------
function Pager:UPDATE_BONUS_ACTIONBAR()
	for i = 1, GetNumShapeshiftForms() do
		local _, isActive, _, spellID = GetShapeshiftFormInfo(i);
		if isActive then
			return db:TriggerEvent('OnUpdateShapeshiftForm', spellID, GetBonusBarIndex(), i)
		end
	end
	return db:TriggerEvent('OnUpdateShapeshiftForm', nil)
end

function Pager:OnActionPageChanged(newstate)
	db:TriggerEvent('OnActionPageChanged', newstate)
end