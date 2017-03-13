---------------------------------------------------------------
-- Cursors\UnitFrames.lua: Secure unit frames targeting cursor 
---------------------------------------------------------------
-- Creates a secure cursor that is used to iterate over unit frames
-- and select units based on where the frame is drawn on screen.
-- Gathers all nodes by recursively scanning UIParent for
-- secure frames with the "unit" attribute assigned.

local 	addOn, db = ...
local 	Flash, FadeIn, FadeOut = db.UIFrameFlash, db.UIFrameFadeIn, db.UIFrameFadeOut
---------------------------------------------------------------
local 	Cursor = CreateFrame("Frame", "ConsolePortRaidCursor", UIParent, "SecureHandlerBaseTemplate, SecureHandlerStateTemplate")
---------------------------------------------------------------
local 	UnitClass, UnitExists, UnitHealth, UnitHealthMax, SetPortraitTexture, SetPortraitToTexture, RAID_CLASS_COLORS = 
		UnitClass, UnitExists, UnitHealth, UnitHealthMax, SetPortraitTexture, SetPortraitToTexture, RAID_CLASS_COLORS
---------------------------------------------------------------
local 	pi, abs, GetTime = math.pi, abs, GetTime
---------------------------------------------------------------
do 
	local Key = {
		Up 		= ConsolePort:GetUIControlKey("CP_L_UP"),
		Down 	= ConsolePort:GetUIControlKey("CP_L_DOWN"),
		Left 	= ConsolePort:GetUIControlKey("CP_L_LEFT"),
		Right 	= ConsolePort:GetUIControlKey("CP_L_RIGHT"),
	}
	---------------------------------------------------------------
	local SetFocus = CreateFrame("Button", "$parentFocus", Cursor, "SecureActionButtonTemplate")
	SetFocus:SetAttribute("type", "focus")
	Cursor:SetFrameRef("SetFocus", SetFocus)
	---------------------------------------------------------------
	local SetTarget = CreateFrame("Button", "$parentTarget", Cursor, "SecureActionButtonTemplate")
	SetTarget:SetAttribute("type", "target")
	Cursor:SetFrameRef("SetTarget", SetTarget)
	---------------------------------------------------------------
	Cursor:SetFrameRef("actionBar", MainMenuBarArtFrame)
	Cursor:SetFrameRef("overrideBar", OverrideActionBar)
	---------------------------------------------------------------
	ConsolePort:RegisterSpellHeader(Cursor)
	Cursor:Execute(format([[
		ALL = newtable()
		DPAD = newtable()

		Key = newtable()
		Key.Up = %s
		Key.Down = %s
		Key.Left = %s
		Key.Right = %s

		ID = 0

		Units = newtable()
		Actions = newtable()

		Focus = self:GetFrameRef("SetFocus")
		Target = self:GetFrameRef("SetTarget")

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
				local action = actionButton:GetAttribute("action")
				if self:RunAttribute("IsHelpfulAction", action) then
					Helpful[actionButton] = true
				elseif self:RunAttribute("IsHarmfulAction", action) then
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
			local children = isProtected and newtable(node:GetChildren())
			local unit = isProtected and node:GetAttribute("unit")
			local action = isProtected and node:GetAttribute("action")
			local childUnit
			if children then
				for i, child in pairs(children) do
					if child:IsProtected() then
						childUnit = child:GetAttribute("unit")
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
			if old and old:IsVisible() and UnitExists(old:GetAttribute("unit")) then
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
		UpdateRouting = [=[
			local reroute = not self:GetAttribute("noRouting")

			if reroute then
				for action, unit in pairs(Actions) do
					action:SetAttribute("unit", unit)
				end
			end

			local unit = current and current:GetAttribute("unit")

			if unit then
				self:Show()

				Focus:SetAttribute("unit", unit)
				Target:SetAttribute("unit", unit)

				RegisterStateDriver(self, "unitexists", "[@"..unit..",exists] true; nil")

				self:ClearAllPoints()
				self:SetPoint("TOPLEFT", current, "CENTER", 0, 0)
				self:SetAttribute("node", current)
				self:SetAttribute("unit", unit)

				if reroute then
					if PlayerCanAttack(unit) then
						self:SetAttribute("relation", "harm")
						for action in pairs(Harmful) do
							action:SetAttribute("unit", unit)
						end
					elseif PlayerCanAssist(unit) then
						self:SetAttribute("relation", "help")
						for action in pairs(Helpful) do
							action:SetAttribute("unit", unit)
						end
					end
				end
			else
				UnregisterStateDriver(self, "unitexists")

				Focus:SetAttribute("unit", nil)
				Target:SetAttribute("unit", nil)

				self:Hide()
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
		ToggleCursor = [=[
			if IsEnabled then
				local modifier = self:GetAttribute("modifier")
				for binding, name in pairs(DPAD) do
					local key = GetBindingKey(binding)
					if key then
						self:SetBindingClick(true, modifier..key, "ConsolePortRaidCursorButton"..name)
					end
				end
				self:Run(UpdateFrameStack)
				self:Show()
			else
				UnregisterStateDriver(self, "unitexists")

				Focus:SetAttribute("unit", nil)
				Target:SetAttribute("unit", nil)

				self:SetAttribute("node", nil)
				self:ClearBindings()

				if not self:GetAttribute("noRouting") then
					for action, unit in pairs(Actions) do
						action:SetAttribute("unit", unit)
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
		CurrentNode = self:GetFrameRef("actionBar")
		self:Run(GetNodes)
		CurrentNode = self:GetFrameRef("overrideBar")
		self:Run(GetNodes)
	]])
	Cursor:SetAttribute("pageupdate", [[
		if IsEnabled then
			self:Run(RefreshActions)
			self:Run(SelectNode, 0)
		end
	]])
	------------------------------------------------------------------------------------------------------------------------------
	local ToggleCursor = CreateFrame("Button", "$parentToggle", Cursor, "SecureActionButtonTemplate")
	ToggleCursor:RegisterForClicks("LeftButtonDown")
	Cursor:SetFrameRef("Mouse", ConsolePortMouseHandle)
	Cursor:WrapScript(ToggleCursor, "OnClick", [[
		local Cursor = self:GetParent()
		local MouseHandle =	Cursor:GetFrameRef("Mouse")

		IsEnabled = not IsEnabled
		Cursor:SetAttribute("enabled", IsEnabled)

		Cursor:Run(ToggleCursor)
		MouseHandle:SetAttribute("override", not IsEnabled)
	]])
	------------------------------------------------------------------------------------------------------------------------------
	local buttons = {
		Up 		= {binding = "CP_L_UP", 	key = Key.Up},
		Down 	= {binding = "CP_L_DOWN", 	key = Key.Down},
		Left 	= {binding = "CP_L_LEFT", 	key = Key.Left},
		Right 	= {binding = "CP_L_RIGHT",	key = Key.Right},
	}

	for name, button in pairs(buttons) do
		local btn = CreateFrame("Button", "$parentButton"..name, Cursor, "SecureActionButtonTemplate")
		btn:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
		btn:SetAttribute("type", "target")
		Cursor:WrapScript(btn, "PreClick", format([[
			local Cursor = self:GetParent()
			if down then
				Cursor:Run(SelectNode, %s)
				if Cursor:GetAttribute("noRouting") then
					self:SetAttribute("unit", Cursor:GetAttribute("unit"))
				else
					self:SetAttribute("unit", nil)
				end
			end
		]], button.key))
		Cursor:Execute(format([[
			DPAD.%s = "%s"
		]], button.binding, name))
	end
	---------------------------------------------------------------
	Cursor:SetAttribute("_onstate-unitexists", "self:Run(UpdateUnitExists, newstate)")
	---------------------------------------------------------------
end

function ConsolePort:SetupRaidCursor()
	Cursor.onShow = true
	Cursor.Timer = 0
	Cursor:SetScript("OnUpdate", Cursor.Update)
	Cursor:SetScript("OnEvent", Cursor.Event)

	currentPage = nil
	buttons = nil
	Key = nil

end

function ConsolePort:LoadRaidCursor()
	Cursor:SetAttribute("noRouting", db.Settings.raidCursorDirect)
	Cursor:SetAttribute("modifier", db.Settings.raidCursorModifier or "")
end

---------------------------------------------------------------
Cursor:SetSize(32,32)
Cursor:SetFrameStrata("TOOLTIP")
Cursor:SetPoint("CENTER", 0, 0)
Cursor:Hide()
---------------------------------------------------------------
Cursor.BG = Cursor:CreateTexture(nil, "BACKGROUND")
Cursor.BG:SetTexture("Interface\\Cursor\\Item")
Cursor.BG:SetAllPoints(Cursor)
---------------------------------------------------------------
Cursor.UnitPortrait = Cursor:CreateTexture(nil, "ARTWORK", nil, 6)
Cursor.UnitPortrait:SetSize(38, 38)
Cursor.UnitPortrait:SetPoint("TOPLEFT", Cursor, "CENTER", 0, 0)
---------------------------------------------------------------
Cursor.SpellPortrait = Cursor:CreateTexture(nil, "ARTWORK", nil, 7)
Cursor.SpellPortrait:SetSize(38, 38)
Cursor.SpellPortrait:SetPoint("TOPLEFT", Cursor, "CENTER", 0, 0)
---------------------------------------------------------------
Cursor.Border = Cursor:CreateTexture(nil, "OVERLAY", nil, 6)
Cursor.Border:SetSize(54, 54)
Cursor.Border:SetPoint("CENTER", Cursor.UnitPortrait, 0, 0)
Cursor.Border:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UtilityBorder")
---------------------------------------------------------------
Cursor.Health = Cursor:CreateTexture(nil, "OVERLAY", nil, 7)
Cursor.Health:SetSize(54, 54)
Cursor.Health:SetPoint("BOTTOM", Cursor.Border, 0, 0)
Cursor.Health:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UtilityBorderHighlight")
---------------------------------------------------------------
Cursor.Spell = CreateFrame("PlayerModel", nil, Cursor)
Cursor.Spell:SetAlpha(1)
Cursor.Spell:SetDisplayInfo(42486)
---------------------------------------------------------------
Cursor.Group = Cursor:CreateAnimationGroup()
---------------------------------------------------------------
Cursor.Scale1 = Cursor.Group:CreateAnimation("Scale")
Cursor.Scale1:SetDuration(0.1)
Cursor.Scale1:SetSmoothing("IN")
Cursor.Scale1:SetOrder(1)
Cursor.Scale1:SetOrigin("CENTER", 0, 0)
---------------------------------------------------------------
Cursor.Scale2 = Cursor.Group:CreateAnimation("Scale")
Cursor.Scale2:SetSmoothing("OUT")
Cursor.Scale2:SetOrder(2)
Cursor.Scale2:SetOrigin("CENTER", 0, 0)
---------------------------------------------------------------
Cursor.CastBar = Cursor:CreateTexture(nil, "OVERLAY")
Cursor.CastBar:SetSize(54, 54)
Cursor.CastBar:SetPoint("CENTER", Cursor.UnitPortrait, 0, 0)
Cursor.CastBar:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Castbar\\CastBarShadow")
---------------------------------------------------------------
-- Player specific
Cursor:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
Cursor:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
Cursor:RegisterEvent("UNIT_SPELLCAST_START")
Cursor:RegisterEvent("UNIT_SPELLCAST_STOP")
Cursor:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
---------------------------------------------------------------
Cursor:RegisterEvent("UNIT_HEALTH")
Cursor:RegisterEvent("PLAYER_TARGET_CHANGED")
---------------------------------------------------------------
function Cursor:Event(event, ...)
	local unit, spell, _, _, spellID = ...

	if self:IsVisible() then

		if event == "UNIT_HEALTH" and unit == self.unit then
			local hp = UnitHealth(unit)
			local max = UnitHealthMax(unit)
			self.Health:SetTexCoord(0, 1, abs(1 - hp / max), 1)
			self.Health:SetHeight(54 * hp / max)
		elseif event == "PLAYER_TARGET_CHANGED" and self.unit then
			self:UpdateUnit(self.unit)
		elseif event == "PLAYER_REGEN_DISABLED" then
			self:SetAlpha(1)
		elseif event == "PLAYER_REGEN_ENABLED" and ConsolePortCursor:IsVisible() then
			self:SetAlpha(0.25)
		end

		if unit == "player" then
			if event == "UNIT_SPELLCAST_CHANNEL_START" then
				local name, _, _, texture, startTime, endTime, _, _, _ = UnitChannelInfo("player")

				local targetRelation = self:GetAttribute("relation")
				local spellRelation = IsHarmfulSpell(name) and "harm" or IsHelpfulSpell(name) and "help"

				if targetRelation == spellRelation then
					local color = self.color
					if color then
						self.CastBar:SetVertexColor(color.r, color.g, color.b)
					end
					self.SpellPortrait:Show()
					self.Castbar:Show()
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

			elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then self.isChanneling = false
				FadeOut(self.CastBar, 0.2, self.CastBar:GetAlpha(), 0)

			elseif event == "UNIT_SPELLCAST_START" then
				local name, _, _, texture, startTime, endTime, _, _, _ = UnitCastingInfo("player")

				local targetRelation = self:GetAttribute("relation")
				local spellRelation = IsHarmfulSpell(name) and "harm" or IsHelpfulSpell(name) and "help"

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

			elseif event == "UNIT_SPELLCAST_STOP" then self.isCasting = false
				FadeOut(self.CastBar, 0.2, self.CastBar:GetAlpha(), 0)
				FadeOut(self.SpellPortrait, 0.25, self.SpellPortrait:GetAlpha(), 0)

			elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
				local name, _, icon = GetSpellInfo(spell)

				if name and icon then
					local targetRelation = self:GetAttribute("relation")
					local spellRelation = IsHarmfulSpell(name) and "harm" or IsHelpfulSpell(name) and "help"

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
			self.Spell:SetLight(true, false, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
		else
			self.Health:SetVertexColor(0.5, 0.5, 0.5)
			self.Spell:SetLight(true, false, 0, 0, 120, 1, 1, 1, 1, 100, 1, 1, 1)
		end
	end
	SetPortraitTexture(self.UnitPortrait, self.unit)
end

function Cursor:UpdateNode(node)
	if node then
		local name = node:GetName()
		if name ~= self.node then
			local unit = node:GetAttribute("unit")

			self.unit = unit
			self.node = name
			--- FIX!!!!!
			-------
			if self.onShow then
				self.onShow = nil
				self.Scale1:SetScale(1.5, 1.5)
				self.Scale2:SetScale(1/1.5, 1/1.5)
				self.Scale2:SetDuration(0.5)
				FadeOut(self.Spell, 1, 1, 0.1)
				PlaySound("AchievementMenuOpen")
			else
				self.Scale1:SetScale(1.15, 1.15)
				self.Scale2:SetScale(1/1.15, 1/1.15)
				self.Scale2:SetDuration(0.2)
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

function Cursor:AttributeChanged(attribute, value)
	if attribute == "unit" and value then
		self:UpdateUnit(value)
	elseif attribute == "node" then
		self:UpdateNode(value)
	end
end

function Cursor:Update(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		if self.unit and UnitExists(self.unit) then
			if self.isCasting then
				local time = GetTime() * 1000
				local progress = (time - self.startCast) / (self.endCast - self.startCast)
				local resize = 128 - (40 * (1 - progress))
				self.CastBar:SetRotation(-2 * progress * pi)
				self.CastBar:SetSize(resize, resize)
			elseif self.isChanneling then
				local time = GetTime() * 1000
				local progress = (time - self.startChannel) / (self.endChannel - self.startChannel)
				local resize = 128 - (40 * (1 - progress))
				self.CastBar:SetRotation(-2 * progress * pi)
				self.CastBar:SetSize(resize, resize)
			elseif self.resetPortrait then
				self.resetPortrait = false
				SetPortraitTexture(self.UnitPortrait, self.unit)
			end
		end
		self.Timer = self.Timer - elapsed
	end
end

Cursor:HookScript("OnAttributeChanged", Cursor.AttributeChanged)

ConsolePortCursor:HookScript("OnShow", function(self)
	Cursor:RegisterEvent("PLAYER_REGEN_ENABLED")
	Cursor:RegisterEvent("PLAYER_REGEN_DISABLED")
	if not InCombatLockdown() then
		Cursor:SetAlpha(0.25)
	end
end)

ConsolePortCursor:HookScript("OnHide", function(self)
	Cursor:UnregisterEvent("PLAYER_REGEN_ENABLED")
	Cursor:UnregisterEvent("PLAYER_REGEN_DISABLED")
	Cursor:SetAlpha(1)
end)