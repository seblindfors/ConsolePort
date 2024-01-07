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
		if enabled then
			self:SetAttribute('type', 'focus')
			self:SetAttribute('unit', control:GetAttribute('cursorunit'))
		else
			self:SetAttribute('type', 'macro')
			self:SetAttribute('macrotext', '/clearfocus')
		end
	else
		self:SetAttribute('type', nil)
		self:SetAttribute('unit', nil)
		self:SetAttribute('macrotext', nil)
	end
]])

Cursor:Wrap('PreClick', [[
	self::UpdateNodes()
	self::SelectNewNode(button)
	if self:GetAttribute('usefocus') or not self:GetAttribute('useroute') then
		self:SetAttribute('unit', self:GetAttribute('cursorunit'))
	else
		self:SetAttribute('unit', nil)
	end
]])

Cursor:Execute([[
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
]])

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
				if ( ACTIONS[node] == nil ) then
					ACTIONS[node] = unit or false;
				end
			end
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
		modifier = modifier and modifier or '';
		for buttonID, keyID in pairs(BUTTONS) do
			self:SetBindingClick(self:GetAttribute('priorityoverride'), modifier..keyID, self, buttonID)
		end
	]];
	RefreshActions = [[
		HELPFUL = wipe(HELPFUL)
		HARMFUL = wipe(HARMFUL)

		for actionButton in pairs(ACTIONS) do
			local action = actionButton:GetAttribute('action')
			if self::IsHelpfulAction(action) then
				HELPFUL[actionButton] = true;
			elseif self::IsHarmfulAction(action) then
				HARMFUL[actionButton] = true;
			else
				HELPFUL[actionButton] = true;
				HARMFUL[actionButton] = true;
			end
		end
	]];
	ClearFocusUnit = [[
		UnregisterStateDriver(self, 'unitexists')
		Focus:SetAttribute('unit', nil)
		Target:SetAttribute('unit', nil)
	]];
	PrepareReroute = [[
		local reroute = self:GetAttribute('useroute')
		if reroute then
			for action, unit in pairs(ACTIONS) do
				action:SetAttribute('unit', unit)
				if action:GetAttribute('backup-checkselfcast') ~= nil then
					action:SetAttribute('checkselfcast', action:GetAttribute('backup-checkselfcast'))
					action:SetAttribute('backup-checkselfcast', nil)
				end
				if action:GetAttribute('backup-checkfocuscast') ~= nil then
					action:SetAttribute('checkfocuscast', action:GetAttribute('backup-checkfocuscast'))
					action:SetAttribute('backup-checkfocuscast', nil)
				end
			end
		end
		return reroute;
	]];
	RerouteUnit = [[
		local unit = ...;
		local actionset;
		if PlayerCanAttack(unit) then
			self:SetAttribute('relation', 'harm')
			actionset = HARMFUL;
		elseif PlayerCanAssist(unit) then
			self:SetAttribute('relation', 'help')
			actionset = HELPFUL;
		end
		if actionset then
			for action in pairs(actionset) do
				action:SetAttribute('unit', unit)
				action:SetAttribute('backup-checkselfcast', action:GetAttribute('checkselfcast'))
				action:SetAttribute('backup-checkfocuscast', action:GetAttribute('checkfocuscast'))
				action:SetAttribute('checkselfcast', nil)
				action:SetAttribute('checkfocuscast', nil)
			end
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
			self:SetAttribute('cursorunit', unit)

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
			self::RefreshActions()
			self::SelectNewNode(0)
			self:Show()
		else
			self::ClearFocusUnit()
			self::PrepareReroute()
			self:SetAttribute('node', nil)
			self:SetAttribute('cursorunit', nil)
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
			self::RefreshActions()
			self::SelectNewNode(0)
		end
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
	if (attribute == 'cursorunit') and value then
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

do 	local IsHarmfulSpell, IsHelpfulSpell = IsHarmfulSpell, IsHelpfulSpell;
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
			== (IsHarmfulSpell(spell) and 'harm' or IsHelpfulSpell(spell) and 'help');
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
		self.Display.UnitInformation:SetShown(db('raidCursorPortraitShow'))
		self.animationSpeed = db('raidCursorTravelTime');
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
local ScanUI;
do	local EnumerateFrames, GetAttribute, IsProtected = EnumerateFrames, Cursor.GetAttribute, Cursor.IsProtected;
	ScanUI = CPAPI.Debounce(function(self)
		if InCombatLockdown() then
			return CPAPI.Log('Raid cursor scan failed due to combat lockdown. Waiting for combat to end...')
		end
		local node = EnumerateFrames()
		while node do
			if IsProtected(node) then
				local unit, action = GetAttribute(node, 'unit'), GetAttribute(node, 'action')
				if unit and not action then
					self:CacheNode(node)
				elseif action and tonumber(action) then
					self:CacheNode(node)
				end
			end
			node = EnumerateFrames(node)
		end
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
		local name, _, texture = GetSpellInfo(spellID)
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