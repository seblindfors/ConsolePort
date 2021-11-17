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
Cursor:SetFrameRef('SetFocus', Cursor.SetFocus)
Cursor:SetFrameRef('SetTarget', Cursor.SetTarget)
Cursor:WrapScript(Cursor.Toggle, 'OnClick', [[
	control:RunAttribute('ToggleCursor', not enabled)
]])

Cursor:Wrap('PreClick', [[
	self::SelectNewNode(button)
	if self:GetAttribute('noroute') then
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
	---------------------------------------
	Focus  = self:GetFrameRef('SetFocus')
	Target = self:GetFrameRef('SetTarget')
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
				if node:GetRect() and self:Run(filter) then
					NODES[node] = true;
					CACHE[node] = true;
				end
			elseif action and tonumber(action) then
				ACTIONS[node] = unit or false;
				CACHE[node] = true;
			end
		end
	]];
	FilterOld = [[
		return UnitExists(oldnode:GetAttribute('unit'));
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
		local reroute = not self:GetAttribute('noroute')
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
			self:SetPoint('TOPLEFT', curnode, 'CENTER', 0, 0)
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
})

---------------------------------------------------------------
-- Settings
---------------------------------------------------------------
function Cursor:OnDataLoaded()
	local modifier = db('raidCursorModifier')
	modifier = modifier:match('<none>') and '' or modifier..'-';
	self:SetAttribute('noroute', db('raidCursorDirect'))
	self:SetAttribute('navmodifier', modifier)
	self:SetAttribute('filter', 'return ' .. (db('raidCursorFilter') or 'true') .. ';') 
	self:SetScale(db('raidCursorScale'))
	self:Execute([[filter = self:GetAttribute('filter')]])

	if CPAPI.IsRetailVersion then
		self.Arrow:SetAtlas('Navigation-Tracked-Arrow', true)
	else
		self.Arrow:SetTexture([[Interface\WorldMap\WorldMapArrow]])
		self.Arrow:SetSize(24, 24)
	end
end

function Cursor:OnUpdateOverrides(isPriority)
	if not isPriority then
		self:Execute('self:RunAttribute("ToggleCursor", enabled)')
	end
end

db:RegisterSafeCallback('Settings/raidCursorScale', Cursor.OnDataLoaded, Cursor)
db:RegisterSafeCallback('Settings/raidCursorDirect', Cursor.OnDataLoaded, Cursor)
db:RegisterSafeCallback('Settings/raidCursorModifier', Cursor.OnDataLoaded, Cursor)
db:RegisterSafeCallback('Settings/raidCursorScale', Cursor.OnDataLoaded, Cursor)
db:RegisterSafeCallback('Settings/raidCursorFilter', Cursor.OnDataLoaded, Cursor)
db:RegisterSafeCallback('OnUpdateOverrides', Cursor.OnUpdateOverrides, Cursor)

---------------------------------------------------------------
-- Script handlers
---------------------------------------------------------------
function Cursor:OnHide()
	self:UnregisterAllEvents()
end

function Cursor:OnShow()
	for _, event in ipairs(self.PlayerEvents) do
		self:RegisterUnitEvent(event, 'player')
	end
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
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
					self.UnitPortrait:SetPortrait(self.unit)
				end
			end
			self.timer = 0;
		end
	end
end

CPAPI.Start(Cursor)
Mixin(CPAPI.EventHandler(Cursor), {
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
})

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
local Fade = db.Alpha.Fader;

do 	local IsHarmfulSpell, IsHelpfulSpell = IsHarmfulSpell, IsHelpfulSpell;
	local UnitClass, UnitHealth, UnitHealthMax = UnitClass, UnitHealth, UnitHealthMax;
	local GetClassColorObj, PlaySound, SOUNDKIT = GetClassColorObj, PlaySound, SOUNDKIT;
	local WARNING_LOW_HEALTH = ChatTypeInfo.YELL;

	Cursor.UnitPortrait.SetPortrait  = SetPortraitTexture;
	Cursor.SpellPortrait.SetPortrait = SetPortraitToTexture;

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
			self.CastBar:SetVertexColor(colorObj.r, colorObj.g, colorObj.b)
		end
	end

	function Cursor:UpdateNode(node)
		if node then
			local name = node:GetName()
			if (name ~= self.node) then
				self.node = name;

				if self.animateOnShow then
					self.animateOnShow = false;
					self.ScaleUp:SetScale(1.5, 1.5)
					self.ScaleDown:SetScale(1/1.5, 1/1.5)
					self.ScaleDown:SetDuration(0.5)
					PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN)
				else
					self.ScaleUp:SetScale(1.15, 1.15)
					self.ScaleDown:SetScale(1/1.15, 1/1.15)
					self.ScaleDown:SetDuration(0.2)
				end

				self.Group:Stop()
				self.Group:Play()
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
		local resize = Clamp(80 - (22 * (1 - progress)), 58, 80)
		self.CastBar:SetRotation(-2 * progress * pi)
		self.CastBar:SetSize(resize, resize)
	end

	function Cursor:UpdateCastingState(name, texture, isCasting, isChanneling, startTime, endTime)
		if self:IsApplicableSpell(name) then
			self:UpdateSpinnerColor(self.color)
			self:SetCastingInfo(texture, isCasting, isChanneling, startTime, endTime)
		else
			self.CastBar:Hide()
			self.SpellPortrait:Hide()
		end
	end

	function Cursor:IsApplicableSpell(spell)
		return self:GetAttribute('relation') == (IsHarmfulSpell(spell) and 'harm' or IsHelpfulSpell(spell) and 'help');
	end

	function Cursor:SetCastingInfo(texture, isCasting, isChanneling, startTime, endTime)
		local castBar, spellPortrait = self.CastBar, self.SpellPortrait;
		if isCasting or isChanneling then
			castBar:Show()
			castBar:SetRotation(0)
			spellPortrait:Show()
			if texture then
				spellPortrait:SetPortrait(texture)
			end

			Fade.In(castBar, 0.2, castBar:GetAlpha(), 1)
			Fade.In(spellPortrait, 0.25, spellPortrait:GetAlpha(), 1)
		else
			castBar:Hide()
			spellPortrait:Hide()
		end

		self.isCasting     = isCasting;
		self.isChanneling  = isChanneling;
		self.startTime     = startTime;
		self.endTime       = endTime;
		self.resetPortrait = isCasting or isChanneling;
	end

	Cursor.Arrow:SetRotation(rad(45))
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------

function Cursor:UNIT_HEALTH(unit)
	self:UpdateHealthForUnit(unit)
end

function Cursor:PLAYER_TARGET_CHANGED()
	if self.unit then
		self:UpdateUnit(self.unit)
	end
end

do 	local UnitChannelInfo, UnitCastingInfo = UnitChannelInfo, UnitCastingInfo;
	local Flash = db.Alpha.Flash;

	function Cursor:UNIT_SPELLCAST_CHANNEL_START(unit)
		local name, _, texture, startTime, endTime = UnitChannelInfo(unit)
		self:UpdateCastingState(name, texture, false, true, startTime, endTime)
	end

	function Cursor:UNIT_SPELLCAST_CHANNEL_STOP()
		self.isChanneling = false;
		Fade.Out(self.CastBar, 0.2, self.CastBar:GetAlpha(), 0)
	end

	function Cursor:UNIT_SPELLCAST_START(unit)
		local name, _, texture, startTime, endTime = UnitCastingInfo(unit)
		self:UpdateCastingState(name, texture, true, false, startTime, endTime)
	end

	function Cursor:UNIT_SPELLCAST_STOP()
		self.isCasting = false;
		Fade.Out(self.CastBar, 0.2, self.CastBar:GetAlpha(), 0)
		Fade.Out(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 0)
	end

	function Cursor:UNIT_SPELLCAST_SUCCEEDED(_, _, spellID)
		local name, _, icon = GetSpellInfo(spellID)
		if name and icon then
			if self:IsApplicableSpell(name) then
				local spellPortrait = self.SpellPortrait;
				spellPortrait:SetPortrait(icon)
				-- instant cast spell
				if not self.isCasting and not self.isChanneling then
					Flash(spellPortrait, 0.25, 0.25, 0.75, false, 0.25, 0)
				else
					spellPortrait:Show()
					Fade.Out(spellPortrait, 0.25, spellPortrait:GetAlpha(), 0)
				end
			end
		end
		self.isCasting = false;
	end
end