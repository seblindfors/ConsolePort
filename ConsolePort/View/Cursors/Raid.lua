---------------------------------------------------------------
-- Secure unit frames targeting cursor
---------------------------------------------------------------
-- Creates a secure cursor that is used to iterate over unit frames
-- and select units based on where the frame is drawn on screen.
-- Gathers all nodes by recursively scanning UIParent for
-- secure frames with the 'unit' attribute assigned.

local _, db = ...;
local Cursor = db:Register('Raid', db.Pager:RegisterHeader(db.Securenav(ConsolePortRaidCursor)))

---------------------------------------------------------------
-- Frame refs, init scripts, click handlers
---------------------------------------------------------------
Cursor.SetTarget:SetAttribute(CPAPI.ActionTypeRelease, 'target')
Cursor.SetFocus:SetAttribute(CPAPI.ActionTypeRelease, 'focus')
Cursor:SetFrameRef('SetFocus', Cursor.SetFocus)
Cursor:SetFrameRef('SetTarget', Cursor.SetTarget)
Cursor:WrapScript(Cursor.Toggle, 'PreClick', [[
	if button == 'ON' then
		if enabled then return end;
		control:RunAttribute('ToggleCursor', true)
	elseif button == 'OFF' then
		if not enabled then return end;
		control:RunAttribute('ToggleCursor', false)
	else
		control:RunAttribute('ToggleCursor', not enabled)
	end
	if control:GetAttribute('usefocus') then
		self:SetAttribute('type', 'focus')
		if enabled then
			self:SetAttribute('unit', control:GetAttribute(CURSOR_UNIT))
		else
			self:SetAttribute('unit', 'none')
		end
	else
		self:SetAttribute('type', nil)
		self:SetAttribute('unit', nil)
	end
]])

Cursor:Wrap('PreClick', [[
	self::UpdateNodes()
	self::SelectNewNode(button)
	if self:GetAttribute('usefocus') or not self:GetAttribute('useroute') then
		self:SetAttribute('unit', self:GetAttribute(CURSOR_UNIT))
	else
		self:SetAttribute('unit', nil)
	end
]])

Cursor:Execute(([[
	---------------------------------------
	ACTIONS = newtable();
	HELPFUL = newtable();
	HARMFUL = newtable();
	BUTTONS = newtable();
	---------------------------------------
	Focus  = self:GetFrameRef('SetFocus')
	Target = self:GetFrameRef('SetTarget')
	---------------------------------------
	CACHE[self] = nil;
	CURSOR_UNIT = %q;
]]):format(CPAPI.RaidCursorUnit))

---------------------------------------------------------------
-- Environment
---------------------------------------------------------------
Cursor:CreateEnvironment({
	FilterNode = [[
		if self::IsDrawn(node:GetRect()) then
			local unit = node:GetAttribute('unit')
			local action = node:GetAttribute('action')

			if unit and not action then
				if self::IsValidNode(unit) and node:IsVisible() then
					NODES[node] = true;
				end
			elseif action and tonumber(action) then
				local parent = node:GetParent()
				local owner  = parent and parent:GetName() or 1;
				self::AddOwner(owner)
				if ( ACTIONS[owner][node] == nil ) then
					ACTIONS[owner][node] = unit or false;
				end
			end
		end
	]];
	AddOwner = [[
		local owner = ...;
		if not ACTIONS[owner] then
			ACTIONS[owner] = newtable();
			HELPFUL[owner] = newtable();
			HARMFUL[owner] = newtable();
		end
	]];
	UpdateNodes = [[
		wipe(NODES)
		for object in pairs(CACHE) do
			node = object; self::FilterNode()
		end
	]];
	FilterOld = [[
		return UnitExists(oldnode:GetAttribute('unit'));
	]];
	SetBaseBindings = [[
		local modifier = ...;
		modifier = modifier or '';
		for buttonID, keyID in pairs(BUTTONS) do
			self:SetBindingClick(self:GetAttribute('priorityoverride'), modifier..keyID, self, buttonID)
		end
	]];
	RefreshOwners = [[
		for owner in pairs(ACTIONS) do
			self::RefreshOwner(owner)
		end
	]];
	RefreshOwner = [[
		local owner = ...;
		local buttons, helpful, harmful = ACTIONS[owner], HELPFUL[owner], HARMFUL[owner];

		if not buttons then
			return false;
		end

		wipe(helpful)
		wipe(harmful)

		for actionButton in pairs(buttons) do
			local action = actionButton:GetAttribute('action')
			if self::IsHelpfulAction(action) then
				helpful[actionButton] = true;
			elseif self::IsHarmfulAction(action) then
				harmful[actionButton] = true;
			else
				helpful[actionButton] = true;
				harmful[actionButton] = true;
			end
		end
		return true;
	]];
	ClearFocusUnit = [[
		UnregisterStateDriver(self, 'unitexists')
		Focus:SetAttribute('unit', nil)
		Target:SetAttribute('unit', nil)
	]];
	PrepareReroute = [[
		local reroute = self:GetAttribute('useroute')
		if reroute then
			if widget then
				self::ResetOwnerReroute(widget)
			else
				for owner in pairs(ACTIONS) do
					self::ResetOwnerReroute(owner)
				end
			end
		end
		return reroute;
	]];
	ResetOwnerReroute = [[
		local owner = ...;
		for action, unit in pairs(ACTIONS[owner]) do
			action:SetAttribute('unit', unit or nil)
			if action:GetAttribute('backup-checkselfcast') ~= nil then
				action:SetAttribute('checkselfcast', action:GetAttribute('backup-checkselfcast'))
				action:SetAttribute('backup-checkselfcast', nil)
			end
			if action:GetAttribute('backup-checkfocuscast') ~= nil then
				action:SetAttribute('checkfocuscast', action:GetAttribute('backup-checkfocuscast'))
				action:SetAttribute('backup-checkfocuscast', nil)
			end
		end
	]];
	RerouteUnit = [[
		local unit = ...;
		local relation;
		actionset = nil;

		if PlayerCanAttack(unit) then
			relation, actionset = 'harm', HARMFUL;
		elseif PlayerCanAssist(unit) then
			relation , actionset = 'help', HELPFUL;
		end
		self:SetAttribute('relation', relation)

		if actionset then
			if widget then
				self::RerouteOwner(widget, unit)
			else
				for owner in pairs(ACTIONS) do
					self::RerouteOwner(owner, unit)
				end
			end
		end
	]];
	RerouteOwner = [[
		local owner, unit = ...;
		local buttons = actionset[owner];
		for action in pairs(buttons) do
			action:SetAttribute('unit', unit)
			action:SetAttribute('backup-checkselfcast', action:GetAttribute('checkselfcast'))
			action:SetAttribute('backup-checkfocuscast', action:GetAttribute('checkfocuscast'))
			action:SetAttribute('checkselfcast', nil)
			action:SetAttribute('checkfocuscast', nil)
		end
	]];
	PostNodeSelect = [[
		local unit = curnode and curnode:GetAttribute('unit')
		local reroute = self::PrepareReroute()

		if unit then
			self:Show()

			Focus:SetAttribute('unit', unit)
			Target:SetAttribute('unit', unit)
			RegisterStateDriver(self, 'unitexists', ('[@%s,exists] true; nil'):format(unit))

			self:ClearAllPoints()
			self:SetPoint('CENTER', curnode, 'CENTER', 0, 0)
			self:SetAttribute('node', curnode)
			self:SetAttribute(CURSOR_UNIT, unit)

			if reroute then
				self::RerouteUnit(unit)
			end
		else
			self::ToggleCursor(false)
		end
	]];
	ToggleCursor = [[
		enabled = ...;

		if enabled then
			self::SetBaseBindings(self:GetAttribute('navmodifier'))
			self::UpdateNodes()
			self::RefreshOwners()
			self::SelectNewNode(0)
			self:Show()
		else
			self::ClearFocusUnit()
			self::PrepareReroute()
			self:SetAttribute('node', nil)
			self:SetAttribute(CURSOR_UNIT, nil)
			self:ClearBindings()
			self:Hide()
		end
	]];
	-- State handlers:
	UpdateUnitExists = [[
		local exists = ...;
		if not exists then
			self::UpdateNodes()
			self::SelectNewNode(0)
		end
	]];
	ActionPageChanged = [[
		if enabled then
			self::RefreshOwners()
			self::SelectNewNode(0)
		end
	]];
	OwnerChanged = [[
		widget = ...;
		if enabled then
			self::SetBaseBindings(self:GetAttribute('navmodifier'))
			if self::RefreshOwner(widget) then
				self::PostNodeSelect()
			end
		end
		widget = nil;
	]];
	IsHelpfulMacro = [[
		local body = ...
		if body then
			local condition = body:match('#raidcursor (%[.+%])')
			return condition and condition:match('help')
		end
	]];
	IsHarmfulMacro = [[
		local body = ...
		if body then
			local condition = body:match('#raidcursor (%[.+%])')
			return condition and condition:match('harm')
		end
	]];
})

-- Attempt to move the cursor to another unit frame when the current unit expires.
-- This may only work for unit frames loaded before the cursor is created,
-- since they are otherwise likely to be on screen when the state handler runs.
Cursor:SetAttribute('_onstate-unitexists', CPAPI.ConvertSecureBody([[
	self::UpdateUnitExists(newstate)
]]))

---------------------------------------------------------------
-- Settings
---------------------------------------------------------------
Cursor.Modes = {
	Redirect = 1;
	Focus    = 2;
	Target   = 3;
}

Cursor.Directions = {
	PADDUP    = 'raidCursorUp';
	PADDDOWN  = 'raidCursorDown';
	PADDLEFT  = 'raidCursorLeft';
	PADDRIGHT = 'raidCursorRight';
};

function Cursor:OnDataLoaded()
	local modifier = db('raidCursorModifier')
	modifier = modifier:match('<none>') and '' or modifier..'-';
	self:SetAttribute('navmodifier', modifier)

	local mode = db('raidCursorMode')
	self:SetAttribute('useroute', mode ~= self.Modes.Target)
	self:SetAttribute('usefocus', mode == self.Modes.Focus)
	self:SetAttribute('type', mode == self.Modes.Focus and 'focus' or 'target')

	self:SetFilter(db('raidCursorFilter'))
	self:SetAttribute('wrapDisable', db('raidCursorWrapDisable'))
	self:SetScale(db('raidCursorScale'))
	self:UpdatePointer()

	self:Execute('wipe(BUTTONS)')
	for direction, varID in pairs(self.Directions) do
		self:Execute(('BUTTONS[%q] = %q'):format(direction, db(varID)))
	end

	self:RegisterEvent('ADDON_LOADED')
	self.ADDON_LOADED = self.GROUP_ROSTER_UPDATE;
end

function Cursor:OnUpdateOverrides(isPriority)
	if not isPriority then
		self:Run('self::ToggleCursor(enabled)')
	end
end

db:RegisterSafeCallbacks(Cursor.OnDataLoaded, Cursor,
	'Settings/raidCursorScale',
	'Settings/raidCursorMode',
	'Settings/raidCursorAutoFocus',
	'Settings/raidCursorModifier',
	'Settings/raidCursorScale',
	'Settings/raidCursorFilter',
	'Settings/raidCursorUp',
	'Settings/raidCursorDown',
	'Settings/raidCursorLeft',
	'Settings/raidCursorRight',
	'Settings/raidCursorWrapDisable'
);
db:RegisterSafeCallback('OnUpdateOverrides', Cursor.OnUpdateOverrides, Cursor)

---------------------------------------------------------------
-- Script handlers
---------------------------------------------------------------
function Cursor:OnHide()
	for _, event in ipairs(self.PlayerEvents) do self:UnregisterEvent(event) end
	for _, event in ipairs(self.ActiveEvents) do self:UnregisterEvent(event) end
end

function Cursor:OnShow()
	for _, event in ipairs(self.PlayerEvents) do self:RegisterUnitEvent(event, 'player') end
	for _, event in ipairs(self.ActiveEvents) do self:RegisterEvent(event) end
end

function Cursor:OnAttributeChanged(attribute, value)
	if (attribute == CPAPI.RaidCursorUnit) and value then
		self:UpdateUnit(value)
	elseif (attribute == 'node') then
		self:UpdateNode(value)
	end
end

do 	local UnitExists = UnitExists;
	function Cursor:OnUpdate(elapsed)
		self.timer = self.timer + elapsed;
		if self.timer > self.throttle then
			if (self.unit and UnitExists(self.unit)) then
				if (self.isCasting or self.isChanneling) then
					self:UpdateCastbar(self.startTime, self.endTime)
				elseif (self.resetPortrait) then
					self.resetPortrait = false;
					self.LineSheen:Hide()
					self.UnitPortrait:SetPortrait(self.unit)
				end
			end
			self.timer = 0;
		end
	end
end

CPAPI.Start(Cursor)
Mixin(CPAPI.EventHandler(Cursor, {
	'GROUP_ROSTER_UPDATE';
	'PLAYER_ENTERING_WORLD';
	'PLAYER_REGEN_DISABLED';
	'PLAYER_REGEN_ENABLED';
}), {
	-----------------
	timer    = 0;
	throttle = 0.025;
	-----------------
	ScaleUp   = Cursor.Group.ScaleUp;
	ScaleDown = Cursor.Group.ScaleDown;
	-----------------
	PlayerEvents = {
		'UNIT_SPELLCAST_CHANNEL_START';
		'UNIT_SPELLCAST_CHANNEL_STOP';
		'UNIT_SPELLCAST_START';
		'UNIT_SPELLCAST_STOP';
		'UNIT_SPELLCAST_SUCCEEDED';
	};
	ActiveEvents = {
		'PLAYER_TARGET_CHANGED';
	};
})

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
local Fade, Flash = db.Alpha.Fader, db.Alpha.Flash;
local PORTRAIT_TEXTURE_SIZE = 46;

do 	local IsSpellHarmful, IsSpellHelpful = CPAPI.IsSpellHarmful, CPAPI.IsSpellHelpful;
	local UnitClass, UnitHealth, UnitHealthMax = UnitClass, UnitHealth, UnitHealthMax;
	local GetClassColorObj, PlaySound, SOUNDKIT = GetClassColorObj, PlaySound, SOUNDKIT;
	local WARNING_LOW_HEALTH = ChatTypeInfo.YELL;

	for _, region in ipairs({Cursor.Display.UnitInformation:GetRegions()}) do
		Cursor[region:GetParentKey()] = region;
	end
	Cursor.UnitPortrait.SetPortrait  = SetPortraitTexture;

	function Cursor:UpdateUnit(unit)
		self.unit = unit;
		if UnitExists(unit) then
			self:UpdateHealthForUnit(unit)
			self:UpdateColor(GetClassColorObj(select(2, UnitClass(unit))))
		end
		self.UnitPortrait:SetPortrait(unit)
		if unit then
			self:RegisterUnitEvent('UNIT_HEALTH', unit)
		else
			self:UnregisterEvent('UNIT_HEALTH')
		end
	end

	function Cursor:UpdateHealthForUnit(unit)
		local fraction = UnitHealth(unit) / UnitHealthMax(unit);
		self.Health:SetTexCoord(0, 1, abs(1 - fraction), 1)
		self.Health:SetHeight(54 * fraction)
		if (fraction < 0.35) then
			local color = WARNING_LOW_HEALTH;
			self.Border:SetVertexColor(color.r, color.g, color.b)
		else
			self.Border:SetVertexColor(1, 1, 1)
		end
	end

	function Cursor:UpdateColor(colorObj)
		self.color = colorObj;
		if colorObj then
			self.Health:SetVertexColor(colorObj.r, colorObj.g, colorObj.b)
		else
			self.Health:SetVertexColor(.5, .5, .5)
		end
	end

	function Cursor:UpdateSpinnerColor(colorObj)
		if colorObj then
			self.Spinner:SetVertexColor(colorObj.r, colorObj.g, colorObj.b)
		end
	end

	function Cursor:UpdateNode(node)
		if node then
			local name = node:GetName()
			if (name ~= self.node) then
				self.node = name;

				if self.animateOnShow then
					self.animateOnShow = false;
					PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN)
				end
				if self.animationEnabled then
					self.Group:Stop()
					self.Group:Play()
				end
				self:SetAlpha(1)
			end
		else
			self.animateOnShow, self.node = true, nil;
		end
	end

	local GetTime, Clamp, pi = GetTime, Clamp, math.pi;
	function Cursor:UpdateCastbar(startCast, endCast)
		local time = GetTime() * 1000;
		local progress = (time - startCast) / (endCast - startCast)
		progress = self.isChanneling and 1 - progress or progress;
		self:SetSpinnerProgress(progress)
		self:SetSpellProgress(progress)
	end

	function Cursor:UpdateCastingState(name, texture, isCasting, isChanneling, startTime, endTime)
		if self:IsApplicableSpell(name) then
			self:UpdateSpinnerColor(self.color)
			self:SetCastingInfo(texture, isCasting, isChanneling, startTime, endTime)
		else
			self:HideCastingInfo()
		end
	end

	function Cursor:IsApplicableSpell(spell)
		return self:GetAttribute('relation')
			== (IsSpellHarmful(spell) and 'harm' or IsSpellHelpful(spell) and 'help');
	end

	function Cursor:SetSpellTexture(texture)
		self.SpellPortrait:SetTexture(texture)
		self.SpellPortrait:SetShown(not not texture)
	end

	function Cursor:SetSpellProgress(progress)
		self.SpellPortrait:SetWidth(PORTRAIT_TEXTURE_SIZE * progress)
		self.SpellPortrait:SetTexCoord(0, progress, 0, 1)
		self.LineSheen:SetShown(progress < 1)
	end

	function Cursor:SetSpinnerProgress(progress)
		local spinner, size = self.Spinner, Clamp(72 - (14 * (1 - progress)), 58, 72)
		spinner:SetShown(true)
		spinner:SetSize(size, size)
		spinner:SetRotation(-2 * progress * pi)
	end

	function Cursor:SetCastInfoAlpha(isCasting, isChanneling, isInstantCast)
		if isCasting or isChanneling then
			Fade.In(self.Spinner, 0.2, self.Spinner:GetAlpha(), 1)
			Fade.In(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 1)
		elseif isInstantCast then
			Flash(self.SpellPortrait, 0.25, 0.25, 0.75, false, 0.25, 0)
		else
			Fade.Out(self.Spinner, 0.2, self.Spinner:GetAlpha(), 0)
			Fade.Out(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 0)
		end
	end

	function Cursor:SetCastingInfo(texture, isCasting, isChanneling, startTime, endTime)
		if isCasting or isChanneling then
			self:SetSpinnerProgress(0)
			self:SetSpellTexture(texture)
		else
			self:HideCastingInfo()
		end
		self:SetCastInfoAlpha(isCasting, isChanneling)

		self.isCasting     = isCasting;
		self.isChanneling  = isChanneling;
		self.startTime     = startTime;
		self.endTime       = endTime;
		self.resetPortrait = isCasting or isChanneling;
	end

	function Cursor:HideCastingInfo()
		self.Spinner:Hide()
		self:SetSpellTexture(nil)
	end

	function Cursor:UpdatePointer()
		local animationEnabled = db('raidCursorPointerAnimation')
		self.Display:SetSize(db('raidCursorPointerSize'))
		self.Display:SetOffset(db('raidCursorPointerOffset'))
		self.Display:SetRotationEnabled(animationEnabled)
		self.Display:SetAnimationEnabled(animationEnabled)
		self.Display:SetAnimationSpeed(db('raidCursorTravelTime'))
		self.Display.UnitInformation:SetShown(db('raidCursorPortraitShow'))
		self.animationEnabled = animationEnabled;
	end
end

db:RegisterCallbacks(Cursor.UpdatePointer, Cursor,
	'Settings/raidCursorTravelTime',
	'Settings/raidCursorPointerSize',
	'Settings/raidCursorPointerOffset',
	'Settings/raidCursorPointerAnimation',
	'Settings/raidCursorPortraitShow'
);

---------------------------------------------------------------
-- UI Caching
---------------------------------------------------------------
local ScanUI, ScanFrames;
do	local EnumerateFrames, GetAttribute, IsProtected = EnumerateFrames, Cursor.GetAttribute, Cursor.IsProtected;
	ScanFrames = function(self, node, iterator, includeAll)
		while node do
			if IsProtected(node) then
				if includeAll then
					self:CacheNode(node)
				else
					local unit, action = GetAttribute(node, 'unit'), GetAttribute(node, 'action')
					if unit and not action then
						self:CacheNode(node)
					elseif action and tonumber(action) then
						self:CacheNode(node)
					end
				end
			end
			node = iterator(node)
		end
	end;

	ScanUI = CPAPI.Debounce(function(self)
		if InCombatLockdown() then
			return CPAPI.Log('Raid cursor scan failed due to combat lockdown. Waiting for combat to end...')
		end
		ScanFrames(self, EnumerateFrames(), EnumerateFrames, false)
	end, Cursor)
end

function Cursor:AddFrame(frame)
	self:SetFrameRef('cachenode', frame)
	self:Execute([[
		CACHE[self:GetFrameRef('cachenode')] = true;
	]])
end

Cursor.CachedFrames = {[Cursor] = true; [Cursor.Toggle] = true};
function Cursor:CacheNode(node)
	if not self.CachedFrames[node] then
		self.CachedFrames[node] = true;
		self:AddFrame(node)
		return true;
	end
end

function Cursor:CacheActionBar(bar)
	local iterator = GenerateClosure(next, tInvert { bar:GetChildren() })
	ScanFrames(self, iterator(), iterator, true)
end

do 	local FILTER_SIGNATURE, DEFAULT_NODE_PREDICATE = 'local unit = unit or ...; return %s;', 'true';
	-----------------------------------------------------------
	-- @brief ConsolePortRaidCursor:IsValidNode(node)
	-- @param node The node to test
	-- @param unit The unit that the node represents
	-- @return true if the node is valid, falsy otherwise
	-----------------------------------------------------------
	function Cursor:SetFilter(filter)
		-- Format potential error message to remove the filter signature
		local function FormatError(error)
			return WHITE_FONT_COLOR:WrapTextInColorCode(
				error:gsub(FILTER_SIGNATURE:sub(1, #FILTER_SIGNATURE - 3), ''))
		end
		-- Create the script body for the filter
		local filterPredicate = FILTER_SIGNATURE:format(filter or DEFAULT_NODE_PREDICATE)
		-- Check if the filter compiles and is a function
		local test, error = loadstring(filterPredicate)
		if ( type(test) ~= 'function' ) then
			filterPredicate = FILTER_SIGNATURE:format(DEFAULT_NODE_PREDICATE)
			CPAPI.Log('Invalid raid cursor filter:\n%s\nThe default filter has been applied.', FormatError(error))
		end
		-- Check if the filter runs without errors
		test = loadstring(filterPredicate)
		test, error = pcallwithenv(test, CPAPI.Proxy({
			owner = self;
			self  = self;
			unit  = 'player';
			node  = PlayerFrame;
		}, _G))
		if not test then
			CPAPI.Log('Raid cursor filter failed a test:\n%s\nThe default filter has been applied.', FormatError(error))
			filterPredicate = FILTER_SIGNATURE:format(DEFAULT_NODE_PREDICATE)
		end
		-- Create the filter function
		self.IsValidNode = loadstring(('return function(self, node, ...) %s end'):format(filterPredicate))()
		self:SetAttribute('IsValidNode', filterPredicate)
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Cursor:GROUP_ROSTER_UPDATE()
	if not InCombatLockdown() then
		ScanUI()
	end
end

function Cursor:PLAYER_REGEN_DISABLED()
	ScanUI.Cancel()
end

Cursor.PLAYER_REGEN_ENABLED  = Cursor.GROUP_ROSTER_UPDATE;
Cursor.PLAYER_ENTERING_WORLD = Cursor.GROUP_ROSTER_UPDATE;

function Cursor:UNIT_HEALTH(unit)
	self:UpdateHealthForUnit(unit)
end

function Cursor:PLAYER_TARGET_CHANGED()
	if self.unit then
		self:UpdateUnit(self.unit)
	end
end

-- Casting and channeling events
do 	local UnitChannelInfo, UnitCastingInfo = UnitChannelInfo, UnitCastingInfo;

	function Cursor:UNIT_SPELLCAST_CHANNEL_START(unit)
		local name, _, texture, startTime, endTime = UnitChannelInfo(unit)
		self:UpdateCastingState(name, texture, false, true, startTime, endTime)
	end

	function Cursor:UNIT_SPELLCAST_CHANNEL_STOP()
		self.isChanneling = false;
		self:SetCastInfoAlpha(self.isCasting, self.isChanneling)
	end

	function Cursor:UNIT_SPELLCAST_START(unit)
		local name, _, texture, startTime, endTime = UnitCastingInfo(unit)
		self:UpdateCastingState(name, texture, true, false, startTime, endTime)
	end

	function Cursor:UNIT_SPELLCAST_STOP()
		self.isCasting = false;
		self:SetCastInfoAlpha(self.isCasting, self.isChanneling)
	end

	function Cursor:UNIT_SPELLCAST_SUCCEEDED(_, _, spellID)
		local info = CPAPI.GetSpellInfo(spellID)
		local name, texture = info.name, info.iconID;
		if name and texture then
			if self:IsApplicableSpell(name) then
				self:SetSpellTexture(texture)
				-- instant cast spell
				if not self.isCasting and not self.isChanneling then
					self:SetSpellProgress(1)
					self:SetCastInfoAlpha(false, false, true)
				end
			end
		end
		self.isCasting = false;
	end
end