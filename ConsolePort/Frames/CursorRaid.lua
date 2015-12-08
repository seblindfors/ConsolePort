---------------------------------------------------------------
-- CursorRaid.lua: Secure unit targeting cursor for combat
---------------------------------------------------------------
-- Creates a cursor inside the secure environment that is used
-- to iterate over unit frames and select units based on where
-- their respective frame is drawn on screen.
-- Gathers all nodes by recursively scanning UIParent for
-- secure frames with the "unit" attribute assigned.

local addOn, db = ...
local FadeIn = db.UIFrameFadeIn
local FadeOut = db.UIFrameFadeOut
local UIHandle, Cursor

function ConsolePort:CreateRaidCursor()
	UIHandle = CreateFrame("Frame", addOn.."UIHandle", UIParent, "SecureHandlerBaseTemplate, SecureHandlerStateTemplate")
	local Key = {
		Up 		= self:GetUIControlKey("CP_L_UP"),
		Down 	= self:GetUIControlKey("CP_L_DOWN"),
		Left 	= self:GetUIControlKey("CP_L_LEFT"),
		Right 	= self:GetUIControlKey("CP_L_RIGHT"),
	}

	UIHandle:Execute(format([[
		ALL = newtable()

		Key = newtable()
		Key.Up = %s
		Key.Down = %s
		Key.Left = %s
		Key.Right = %s
		DPAD = newtable()
		Nodes = newtable()
	]], Key.Up, Key.Down, Key.Left, Key.Right))

	-- Raid cursor run snippets
	------------------------------------------------------------------------------------------------------------------------------
	UIHandle:Execute([[
		GetNodes = [=[
			local node = CurrentNode
			local children = newtable(node:GetChildren())
			if not node:IsObjectType("Slider") then
				for i, child in pairs(children) do
					CurrentNode = child
					self:Run(GetNodes)
				end
			end
			if node:GetAttribute("unit") then
				local left, bottom, width, height = node:GetRect()
				if left and bottom then
					tinsert(Nodes, node)
				end
			end
		]=]
		SetCurrent = [=[
			if old and old:IsVisible() then
				current = old
			elseif (not current and Nodes[1]) or (current and Nodes[1] and not current:IsVisible()) then
				for i, Node in pairs(Nodes) do
					if Node:IsVisible() then
						current = Node
						break
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
				for i, destination in pairs(Nodes) do
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

			if current then
				self:SetAttribute("unit", current:GetAttribute("unit"))
				self:SetAttribute("node", current)
			else
				self:SetAttribute("unit", nil)
			end
		]=]
		UpdateFrameStack = [=[
			Nodes = wipe(Nodes)
			for _, Frame in pairs(newtable(self:GetParent():GetChildren())) do
				if Frame:IsProtected() then
					CurrentNode = Frame
					self:Run(GetNodes)
				end
			end
		]=]
		ToggleCursor = [=[
			if IsEnabled then
				for binding, name in pairs(DPAD) do
					local key = GetBindingKey(binding)
					if key then
						self:SetBindingClick(true, key, "ConsolePortRaidCursorButton"..name)
					end
				end
				self:Run(UpdateFrameStack)
				self:Run(SelectNode, 0)
			else
				self:SetAttribute("node", nil)
				self:ClearBindings()
			end
		]=]
		UpdateMouseOver = [=[

		]=]
	]])

	------------------------------------------------------------------------------------------------------------------------------
	local ToggleCursor = CreateFrame("Button", addOn.."RaidCursorToggle", nil, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
	ToggleCursor:RegisterForClicks("LeftButtonDown")
	ToggleCursor:SetFrameRef("UIHandle", UIHandle)
	ToggleCursor:SetAttribute("type", "target")
	UIHandle:WrapScript(ToggleCursor, "OnClick", [[
		local UIHandle = self:GetFrameRef("UIHandle")
		IsEnabled = not IsEnabled
		UIHandle:Run(ToggleCursor)
		if IsEnabled then
			self:SetAttribute("unit", UIHandle:GetAttribute("unit"))
		else
			self:SetAttribute("unit", nil)
		end
	]])

	local buttons = {
		Up 		= {binding = "CP_L_UP", 	key = Key.Up},
		Down 	= {binding = "CP_L_DOWN", 	key = Key.Down},
		Left 	= {binding = "CP_L_LEFT", 	key = Key.Left},
		Right 	= {binding = "CP_L_RIGHT",	key = Key.Right},
	}

	for name, button in pairs(buttons) do
		local btn = CreateFrame("Button", addOn.."RaidCursorButton"..name, nil, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
		btn:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
		btn:SetAttribute("type", "target")
		btn:SetFrameRef("UIHandle", UIHandle)
		UIHandle:WrapScript(btn, "OnClick", format([[
			local UIHandle = self:GetFrameRef("UIHandle")
			if down then
				UIHandle:Run(SelectNode, %s)
				self:SetAttribute("unit", UIHandle:GetAttribute("unit"))
			else
				self:SetAttribute("unit", nil)
			end
		]], button.key))
		UIHandle:Execute(format([[
			DPAD.%s = "%s"
		]], button.binding, name))
	end

	-- Mouse over state driver
	------------------------------------------------------------------------------------------------------------------------------
	UIHandle:SetAttribute('_onstate-mousestate', [[
		if newstate then
			for binding in pairs(ALL) do
				local key = GetBindingKey(binding)
				if key then
					self:SetBinding(true, key, "INTERACTMOUSEOVER")
				end
			end
		else
			self:ClearBindings()
		end
	]])


	for _, binding in pairs(self:GetBindingNames()) do
		UIHandle:Execute(format([[
			ALL.%s = true
		]], binding, binding))
	end

	------------------------------------------------------------------------------------------------------------------------------

	Cursor.Timer = 0
	Cursor:SetScript("OnUpdate", Cursor.Update)

	self.CreateRaidCursor = nil
end


---------------------------------------------------------------
-- Toggle mouse over driver on/off
---------------------------------------------------------------
function ConsolePort:UpdateStateDriver()
	if ConsolePortSettings.mouseOverMode then
		RegisterStateDriver(UIHandle, "mousestate", "[@mouseover,exists] true; nil")
	else
		UnregisterStateDriver(UIHandle, "mousestate")
	end
end

---------------------------------------------------------------
Cursor = CreateFrame("Frame", addOn.."RaidCursor", UIParent)
Cursor:SetSize(32,32)
Cursor:SetFrameStrata("TOOLTIP")
Cursor:SetPoint("CENTER", 0, 0)
Cursor:SetAlpha(0)
---------------------------------------------------------------
Cursor.BG = Cursor:CreateTexture(nil, "OVERLAY")
Cursor.BG:SetTexture("Interface\\Cursor\\Attack")
Cursor.BG:SetAllPoints(Cursor)
---------------------------------------------------------------
Cursor.Glow = CreateFrame("PlayerModel", nil, Cursor)
Cursor.Glow:SetFrameStrata("FULLSCREEN_DIALOG")
Cursor.Glow:SetSize(300, 300)
Cursor.Glow:SetPoint("CENTER", 0, 0)
Cursor.Glow:SetAlpha(0.5)
Cursor.Glow:SetCamDistanceScale(5)
Cursor.Glow:SetDisplayInfo(41039)
Cursor.Glow:SetRotation(1)
---------------------------------------------------------------
Cursor.Group = Cursor:CreateAnimationGroup()
---------------------------------------------------------------
Cursor.Scale1 = Cursor.Group:CreateAnimation("Scale")
Cursor.Scale1:SetDuration(0.1)
Cursor.Scale1:SetSmoothing("IN")
Cursor.Scale1:SetOrder(1)
Cursor.Scale1:SetOrigin("TOPLEFT", 0, 0)
---------------------------------------------------------------
Cursor.Scale2 = Cursor.Group:CreateAnimation("Scale")
Cursor.Scale2:SetSmoothing("OUT")
Cursor.Scale2:SetOrder(2)
Cursor.Scale2:SetOrigin("TOPLEFT", 0, 0)
---------------------------------------------------------------
function Cursor:Update(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		local node = UIHandle:GetAttribute("node")
		if node then
			local name = node:GetName()
			if ConsolePortCursor:IsVisible() then
				self.node = nil
				self:SetAlpha(0)
			elseif name ~= self.node then
				self.node = name
				local frame = _G[name]
				if frame then
					if self:GetAlpha() == 0 then
						self.Scale1:SetScale(3, 3)
						self.Scale2:SetScale(1/3, 1/3)
						self.Scale2:SetDuration(0.5)
						FadeOut(self.Glow, 0.5, 1, 0.5)
						PlaySound("AchievementMenuOpen")
					else
						self.Scale1:SetScale(1.5, 1.5)
						self.Scale2:SetScale(1/1.5, 1/1.5)
						self.Scale2:SetDuration(0.2)
					end
					local x, y = frame:GetCenter()
					self:ClearAllPoints()
					self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
					self.Group:Play()
					self:SetAlpha(1)
				end
			end
		else
			self.node = nil
			self:SetAlpha(0)
		end
		self.Timer = self.Timer - elapsed
	end
end
