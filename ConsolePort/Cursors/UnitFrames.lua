---------------------------------------------------------------
-- Cursors\UnitFrames.lua: Secure unit frames targeting cursor 
---------------------------------------------------------------
-- Creates a secure cursor that is used to iterate over unit frames
-- and select units based on where the frame is drawn on screen.
-- Gathers all nodes by recursively scanning UIParent for
-- secure frames with the 'unit' attribute assigned.

local 	addOn, db = ...
local 	Flash, FadeIn, FadeOut = db.UIFrameFlash, db.GetFaders()
---------------------------------------------------------------
local 	Cursor = ConsolePortRaidCursor
---------------------------------------------------------------
local 	UnitClass, UnitExists, UnitHealth, UnitHealthMax, SetPortraitTexture, SetPortraitToTexture, RAID_CLASS_COLORS = 
		UnitClass, UnitExists, UnitHealth, UnitHealthMax, SetPortraitTexture, SetPortraitToTexture, RAID_CLASS_COLORS
---------------------------------------------------------------
local 	pi, abs, GetTime = math.pi, abs, GetTime
---------------------------------------------------------------
do 
	local Key = {
		Up 		= ConsolePort:GetUIControlKey('CP_L_UP'),
		Down 	= ConsolePort:GetUIControlKey('CP_L_DOWN'),
		Left 	= ConsolePort:GetUIControlKey('CP_L_LEFT'),
		Right 	= ConsolePort:GetUIControlKey('CP_L_RIGHT'),
	}
	---------------------------------------------------------------
	Cursor:SetFrameRef('SetFocus', Cursor.SetFocus)
	Cursor:SetFrameRef('SetTarget', Cursor.SetTarget)
	Cursor:SetFrameRef('Mouse', ConsolePortMouseHandle)
	---------------------------------------------------------------
	ConsolePort:RegisterSpellHeader(Cursor)
	Cursor:Execute(format([[
		DPAD = newtable()

		Key = newtable()
		Key.Up = %s
		Key.Down = %s
		Key.Left = %s
		Key.Right = %s

		ID = 0

		Units = newtable()
		Actions = newtable()

		Focus = self:GetFrameRef('SetFocus')
		Target = self:GetFrameRef('SetTarget')

		Cache = newtable()

		Cache[self] = true

		Helpful = newtable()
		Harmful = newtable()
	]], Key.Up, Key.Down, Key.Left, Key.Right))

	-- Raid cursor run snippets
	---------------------------------------------------------------
	Cursor:Execute([[
		RefreshActions = [=[
			Helpful = wipe(Helpful)
			Harmful = wipe(Harmful)
			for actionButton in pairs(Actions) do
				local action = actionButton:GetAttribute('action')
				if self:RunAttribute('IsHelpfulAction', action) then
					Helpful[actionButton] = true
				elseif self:RunAttribute('IsHarmfulAction', action) then
					Harmful[actionButton] = true
				else
					Helpful[actionButton] = true
					Harmful[actionButton] = true
				end
			end
		]=]
		GetNodes = [=[
			local node = CurrentNode
			local isProtected = node:IsProtected()
			local unit = isProtected and node:GetAttribute('unit')
			local action = isProtected and node:GetAttribute('action')
			local children = isProtected and newtable(node:GetChildren())
			local childUnit

			if children then
				for i, child in pairs(children) do
					if child:IsProtected() then
						childUnit = child:GetAttribute('unit')
						if childUnit == nil or childUnit ~= unit then
							CurrentNode = child
							self:Run(GetNodes)
						end
					end
				end
			end

			if isProtected then
				if Cache[node] then
					return
				else
					if unit and not action then
						local left, bottom, width, height = node:GetRect()
						if left and bottom then
							Units[node] = true
							Cache[node] = true
						end
					elseif action and tonumber(action) then
						Actions[node] = unit or false
						Cache[node] = true
					end
				end
			end
		]=]
		SetCurrent = [=[
			if old and old:IsVisible() and UnitExists(old:GetAttribute('unit')) then
				current = old
			elseif (not current and next(Units)) or (current and next(Units) and not current:IsVisible()) then
				local thisX, thisY = self:GetRect()

				if thisX and thisY then
					local node, dist

					for Node in pairs(Units) do
						if Node ~= old and Node:IsVisible() then
							local left, bottom, width, height = Node:GetRect()
							local destDistance = abs(thisX - (left + width / 2)) + abs(thisY - (bottom + height / 2))

							if not dist or destDistance < dist then
								node = Node
								dist = destDistance
							end
						end
					end
					if node then
						current = node
					end
				else
					for Node in pairs(Units) do
						if Node:IsVisible() then
							current = Node
							break
						end
					end
				end
			end
		]=]
		FindClosestNode = [=[
			if current and key ~= 0 then
				local left, bottom, width, height = current:GetRect()
				local thisY = bottom+height/2
				local thisX = left+width/2
				local nodeY, nodeX = 10000, 10000
				local destY, destX, diffY, diffX, total, swap
				for destination in pairs(Units) do
					if destination:IsVisible() then
						left, bottom, width, height = destination:GetRect()
						destY = bottom+height/2
						destX = left+width/2
						diffY = abs(thisY-destY)
						diffX = abs(thisX-destX)
						total = diffX + diffY
						if total < nodeX + nodeY then
							if 	key == Key.Up then
								if 	diffY > diffX and 	-- up/down
									destY > thisY then 	-- up
									swap = true
								end
							elseif key == Key.Down then
								if 	diffY > diffX and 	-- up/down
									destY < thisY then 	-- down
									swap = true
								end
							elseif key == Key.Left then
								if 	diffY < diffX and 	-- left/right
									destX < thisX then 	-- left
									swap = true
								end
							elseif key == Key.Right then
								if 	diffY < diffX and 	-- left/right
									destX > thisX then 	-- right
									swap = true
								end
							end
						end
						if swap then
							nodeX = diffX
							nodeY = diffY
							current = destination
							swap = false
						end
					end
				end
			end
		]=]
		SelectNode = [=[
			key = ...
			if current then
				old = current
			end

			self:Run(SetCurrent)
			self:Run(FindClosestNode)
			self:Run(UpdateRouting)
		]=]
		UpdateFrameStack = [=[
			local frames = newtable(self:GetParent():GetChildren())
			for i, frame in pairs(frames) do
				if frame:IsProtected() and not Cache[frame] then
					CurrentNode = frame
					self:Run(GetNodes)
				end
			end
			self:Run(RefreshActions)
			if IsEnabled then
				self:Run(SelectNode, 0)
			end
		]=]
		UpdateRouting = [=[
			local reroute = not self:GetAttribute('noRouting')

			if reroute then
				for action, unit in pairs(Actions) do
					action:SetAttribute('unit', unit)
				end
			end

			local unit = current and current:GetAttribute('unit')

			if unit then
				self:Show()

				Focus:SetAttribute('unit', unit)
				Target:SetAttribute('unit', unit)

				RegisterStateDriver(self, 'unitexists', '[@'..unit..',exists] true; nil')

				self:ClearAllPoints()
				self:SetPoint('TOPLEFT', current, 'CENTER', 0, 0)
				self:SetAttribute('node', current)
				self:SetAttribute('cursorunit', unit)

				if reroute then
					if PlayerCanAttack(unit) then
						self:SetAttribute('relation', 'harm')
						for action in pairs(Harmful) do
							action:SetAttribute('unit', unit)
						end
					elseif PlayerCanAssist(unit) then
						self:SetAttribute('relation', 'help')
						for action in pairs(Helpful) do
							action:SetAttribute('unit', unit)
						end
					end
				end
			else
				UnregisterStateDriver(self, 'unitexists')

				Focus:SetAttribute('unit', nil)
				Target:SetAttribute('unit', nil)

				self:Hide()
			end
		]=]
		ToggleCursor = [=[
			if IsEnabled then
				local modifier, bindingKey = self:GetAttribute('modifier')
				for binding, inputKey in pairs(DPAD) do
					bindingKey = GetBindingKey(binding)
					if bindingKey then
						self:SetBindingClick(true, modifier..bindingKey, self, inputKey)
					end
				end
				self:Run(UpdateFrameStack)
				self:Show()
			else
				UnregisterStateDriver(self, 'unitexists')

				Focus:SetAttribute('unit', nil)
				Target:SetAttribute('unit', nil)

				self:SetAttribute('node', nil)
				self:ClearBindings()

				if not self:GetAttribute('noRouting') then
					for action, unit in pairs(Actions) do
						action:SetAttribute('unit', unit)
					end
				end

				self:Hide()
			end
		]=]
		UpdateUnitExists = [=[
			local exists = ...
			if not exists then
				self:Run(SelectNode, 0)
			end
		]=]

		-- Cache default bars right away
		CurrentNode = self:GetFrameRef('actionBar')
		if CurrentNode then
			self:Run(GetNodes)
		end
		CurrentNode = self:GetFrameRef('overrideBar')
		if CurrentNode then
			self:Run(GetNodes)
		end
	]])
	Cursor:SetAttribute('pageupdate', [[
		if IsEnabled then
			self:Run(RefreshActions)
			self:Run(SelectNode, 0)
		end
	]])
	------------------------------------------------------------------------------------------------------------------------------
	Cursor:WrapScript(Cursor.ToggleButton, 'OnClick', [[
		local Cursor = self:GetParent()
		local MouseHandle =	Cursor:GetFrameRef('Mouse')

		IsEnabled = not IsEnabled
		Cursor:SetAttribute('enabled', IsEnabled)

		Cursor:Run(ToggleCursor)
		MouseHandle:SetAttribute('blockhandle', IsEnabled)
	]])
	------------------------------------------------------------------------------------------------------------------------------
	local buttons = {
		[Key.Up] 	= 'CP_L_UP',
		[Key.Down] 	= 'CP_L_DOWN',
		[Key.Left] 	= 'CP_L_LEFT',
		[Key.Right] = 'CP_L_RIGHT',
	}

	for key, binding in pairs(buttons) do
		Cursor:Execute(format([[
			DPAD.%s = '%s'
		]], binding, key))
	end

	Cursor:WrapScript(Cursor, 'PreClick', [[
		self:Run(SelectNode, tonumber(button))
		if self:GetAttribute('noRouting') then
			self:SetAttribute('unit', self:GetAttribute('cursorunit'))
		else
			self:SetAttribute('unit', nil)
		end
	]])
	---------------------------------------------------------------
end

function ConsolePort:SetupRaidCursor()
	Cursor.onShow = true
	Cursor.Timer = 0
	Cursor:SetScript('OnUpdate', Cursor.OnUpdate)
	Cursor:SetScript('OnEvent', Cursor.OnEvent)
end

function ConsolePort:LoadRaidCursor()
	Cursor:SetAttribute('noRouting', db.Settings.raidCursorDirect)
	Cursor:SetAttribute('modifier', db.Settings.raidCursorModifier or '')
end

--------------------------------------------------------------
Cursor.ScaleUp = Cursor.Group.ScaleUp
Cursor.ScaleDown = Cursor.Group.ScaleDown
---------------------------------------------------------------
function Cursor:OnEvent(event, ...)
	local unit, spell, _, _, spellID = ...

	if event == 'UNIT_HEALTH' and unit == self.unit then
		local hp = UnitHealth(unit)
		local max = UnitHealthMax(unit)
		self.Health:SetTexCoord(0, 1, abs(1 - hp / max), 1)
		self.Health:SetHeight(54 * hp / max)
	elseif event == 'PLAYER_TARGET_CHANGED' and self.unit then
		self:UpdateUnit(self.unit)
	elseif event == 'PLAYER_REGEN_DISABLED' then
		self:SetAlpha(1)
	elseif event == 'PLAYER_REGEN_ENABLED' and ConsolePortCursor:IsVisible() then
		self:SetAlpha(0.25)
	end

	if event == 'UNIT_SPELLCAST_CHANNEL_START' then
		local name, _, texture, startTime, endTime = UnitChannelInfo('player')

		local targetRelation = self:GetAttribute('relation')
		local spellRelation = IsHarmfulSpell(name) and 'harm' or IsHelpfulSpell(name) and 'help'

		if targetRelation == spellRelation then
			local color = self.color
			if color then
				self.CastBar:SetVertexColor(color.r, color.g, color.b)
			end
			self.SpellPortrait:Show()
			self.CastBar:Show()
			self.CastBar:SetRotation(0)
			self.isCasting = false
			self.isChanneling = true
			self.resetPortrait = true
			self.spellTexture = texture
			self.startChannel = startTime
			self.endChannel = endTime
			FadeIn(self.CastBar, 0.2, self.CastBar:GetAlpha(), 1)
			FadeIn(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 1)
			SetPortraitToTexture(self.SpellPortrait, self.spellTexture)
		else
			self.CastBar:Hide()
			self.SpellPortrait:Hide()
		end

	elseif event == 'UNIT_SPELLCAST_CHANNEL_STOP' then self.isChanneling = false
		FadeOut(self.CastBar, 0.2, self.CastBar:GetAlpha(), 0)

	elseif event == 'UNIT_SPELLCAST_START' then
		local name, _, texture, startTime, endTime = CPAPI:GetPlayerCastingInfo()

		local targetRelation = self:GetAttribute('relation')
		local spellRelation = IsHarmfulSpell(name) and 'harm' or IsHelpfulSpell(name) and 'help'

		if targetRelation == spellRelation then
			local color = self.color
			if color then
				self.CastBar:SetVertexColor(color.r, color.g, color.b)
			end
			self.SpellPortrait:Show()
			self.CastBar:Show()
			self.CastBar:SetRotation(0)
			self.isCasting = true
			self.isChanneling = false
			self.resetPortrait = true
			self.spellTexture = texture
			self.startCast = startTime
			self.endCast = endTime
			FadeIn(self.CastBar, 0.2, self.CastBar:GetAlpha(), 1)
			FadeIn(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 1)
			SetPortraitToTexture(self.SpellPortrait, self.spellTexture)
		else
			self.CastBar:Hide()
			self.SpellPortrait:Hide()
		end

	elseif event == 'UNIT_SPELLCAST_STOP' then self.isCasting = false
		FadeOut(self.CastBar, 0.2, self.CastBar:GetAlpha(), 0)
		FadeOut(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 0)

	elseif event == 'UNIT_SPELLCAST_SUCCEEDED' then
		local name, _, icon = GetSpellInfo(spell)

		if name and icon then
			local targetRelation = self:GetAttribute('relation')
			local spellRelation = IsHarmfulSpell(name) and 'harm' or IsHelpfulSpell(name) and 'help'

			if targetRelation == spellRelation then
				SetPortraitToTexture(self.SpellPortrait, icon)
				if not self.isCasting and not self.isChanneling then 
					Flash(self.SpellPortrait, 0.25, 0.25, 0.75, false, 0.25, 0) 
				else
					self.SpellPortrait:Show()
					FadeOut(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 0)
				end
			end
		end
		self.isCasting = false
	end
end

function Cursor:UpdateUnit(unit)
	self.unit = unit
	if UnitExists(unit) then
		self.color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
		local hp = UnitHealth(unit)
		local max = UnitHealthMax(unit)
		self.Health:SetTexCoord(0, 1, abs(1 - hp / max), 1)
		self.Health:SetHeight(54 * hp / max)
		if self.color then
			local red, green, blue = self.color.r, self.color.g, self.color.b
			self.Health:SetVertexColor(red, green, blue)
		else
			self.Health:SetVertexColor(0.5, 0.5, 0.5)
		end
	end
	SetPortraitTexture(self.UnitPortrait, self.unit)
end

function Cursor:UpdateNode(node)
	if node then
		local name = node:GetName()
		if name ~= self.node then
			local unit = node:GetAttribute('cursorunit')

			self.unit = unit
			self.node = name
			if self.onShow then
				self.onShow = false
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
		self.onShow = true
		self.node = nil
		self.unit = nil
	end
end

function Cursor:OnAttributeChanged(attribute, value)
	if attribute == 'cursorunit' and value then
		self:UpdateUnit(value)
	elseif attribute == 'node' then
		self:UpdateNode(value)
	end
end


function Cursor:UpdateCastbar(startCast, endCast)
	local time = GetTime() * 1000
	local progress = (time - startCast) / (endCast - startCast)
	local resize = 86 - (22 * (1 - progress))
	self.CastBar:SetRotation(-2 * progress * pi)
	self.CastBar:SetSize(resize, resize)
end

function Cursor:OnUpdate(elapsed)
	self.Timer = self.Timer + elapsed
	if self.Timer > 0.025 then
		if self.unit and UnitExists(self.unit) then
			if self.isCasting then
				self:UpdateCastbar(self.startCast, self.endCast)
			elseif self.isChanneling then
				self:UpdateCastbar(self.startChannel, self.endChannel)
			elseif self.resetPortrait then
				self.resetPortrait = false
				SetPortraitTexture(self.UnitPortrait, self.unit)
			end
		end
		self.Timer = 0
	end
end

---------------------------------------------------------------
-- Events to handle
---------------------------------------------------------------
local playerEvents = {
	'UNIT_SPELLCAST_CHANNEL_START',
	'UNIT_SPELLCAST_CHANNEL_STOP',
	'UNIT_SPELLCAST_START',
	'UNIT_SPELLCAST_STOP',
	'UNIT_SPELLCAST_SUCCEEDED',
}

local targetEvents = {
	'UNIT_HEALTH',
	'PLAYER_TARGET_CHANGED',
}
---------------------------------------------------------------

Cursor:HookScript('OnAttributeChanged', Cursor.OnAttributeChanged)
Cursor:SetScript('OnHide', Cursor.UnregisterAllEvents)
Cursor:SetScript('OnShow', function(self)
	for _, event in ipairs(playerEvents) do
		self:RegisterUnitEvent(event, 'player')
	end
	for _, event in ipairs(targetEvents) do
		self:RegisterEvent(event)
	end
end)

ConsolePortCursor:HookScript('OnShow', function(self)
	Cursor:RegisterEvent('PLAYER_REGEN_ENABLED')
	Cursor:RegisterEvent('PLAYER_REGEN_DISABLED')
	if not InCombatLockdown() then
		Cursor:SetAlpha(0.25)
	end
end)

ConsolePortCursor:HookScript('OnHide', function(self)
	Cursor:UnregisterEvent('PLAYER_REGEN_ENABLED')
	Cursor:UnregisterEvent('PLAYER_REGEN_DISABLED')
	Cursor:SetAlpha(1)
end)