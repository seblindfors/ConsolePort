local addOn, db = ...
local FadeIn = db.UIFrameFadeIn
local FadeOut = db.UIFrameFadeOut
local UIHandle

function ConsolePort:CreateRaidCursor()
	UIHandle = CreateFrame("Frame", addOn.."UIHandle", ConsolePort, "SecureHandlerBaseTemplate")
	local Key = {
		Up 		= self:GetUIControlKey("CP_L_UP"),
		Down 	= self:GetUIControlKey("CP_L_DOWN"),
		Left 	= self:GetUIControlKey("CP_L_LEFT"),
		Right 	= self:GetUIControlKey("CP_L_RIGHT"),
	}

	UIHandle:Execute(format([[
		Key = newtable()
		Key.Up = %s
		Key.Down = %s
		Key.Left = %s
		Key.Right = %s
			FrameStack = newtable()
			Bindings = newtable()
			Nodes = newtable()
	]], Key.Up, Key.Down, Key.Left, Key.Right))

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
	]])
	UIHandle:Execute([[
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
	]])
	UIHandle:Execute([[
		FindClosestNode = [=[
			if current then
				local left, bottom, width, height = current:GetRect()
				local thisY = bottom+height/2
				local thisX = left+width/2
				local nodeY = 10000
				local nodeX = 10000
				local swap 	= false
				local destY, destX, diffY, diffX, total
				for i, destination in ipairs(Nodes) do
					if destination:IsVisible() then
						local left, bottom, width, height = destination:GetRect()
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
	]])
	UIHandle:Execute([[
		SelectNode = [=[
			key = ...
			if current then
				old = current
			end

			self:Run(SetCurrent)
			self:Run(FindClosestNode)

			if current then
				self:SetAttribute("node", current)
			end
		]=]
	]])		
	UIHandle:Execute([[
		UpdateFrameStack = [=[
			Nodes = newtable()
			local children = newtable(self:GetFrameRef("UIParent"):GetChildren())
			for i, Frame in pairs(children) do
				if Frame:IsVisible() or Frame:IsProtected() then
					CurrentNode = Frame
					self:Run(GetNodes)
				end
			end
		]=]
	]])
	UIHandle:Execute([[
		ToggleCursor = [=[
			local state = ...
			if state then
				for binding, name in pairs(Bindings) do
					local key = GetBindingKey(binding)
					self:SetBindingClick(true, key, "ConsolePortRaidCursorButton"..name)
				end
				self:Run(UpdateFrameStack)
				self:Run(SelectNode, 0)
			else
				self:SetAttribute("node", nil)
				self:ClearBindings()
			end
		]=]
	]])

	UIHandle:SetFrameRef("UIParent", UIParent)
	UIHandle:Execute([[
		CurrentNode = self:GetFrameRef("UIParent")
	]])

	local ToggleCursor = CreateFrame("Button", addOn.."RaidCursorToggle", nil, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
	ToggleCursor:RegisterForClicks("LeftButtonDown")
	ToggleCursor:SetFrameRef("UIHandle", UIHandle)
	ToggleCursor:SetAttribute("type", "target")
	ToggleCursor:Execute([[
		IsEnabled = false
	]])
	UIHandle:WrapScript(ToggleCursor, "OnClick", [[
		IsEnabled = not IsEnabled
		local UIHandle = self:GetFrameRef("UIHandle")
		UIHandle:Run(ToggleCursor, IsEnabled)
		if IsEnabled then
			self:SetAttribute("unit", UIHandle:GetAttribute("node") and UIHandle:GetAttribute("node"):GetAttribute("unit"))
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
				self:SetAttribute("unit", UIHandle:GetAttribute("node") and UIHandle:GetAttribute("node"):GetAttribute("unit"))
			else
				self:SetAttribute("unit", nil)
			end
		]], button.key))
		UIHandle:Execute(format([[
			Bindings.%s = "%s"
		]], button.binding, name))
	end
	self.CreateRaidCursor = nil
end

local Indicator = CreateFrame("Frame", addOn.."RaidCursorIndicator", UIParent)
Indicator:SetSize(32,32)
Indicator:SetFrameStrata("TOOLTIP")
Indicator:SetPoint("CENTER", 0, 0)
Indicator:SetAlpha(0)

Indicator.BG = Indicator:CreateTexture(nil, "OVERLAY")
Indicator.BG:SetTexture("Interface\\Cursor\\Attack")
Indicator.BG:SetAllPoints(Indicator)

Indicator.Glow = CreateFrame("PlayerModel", nil, Indicator)
Indicator.Glow:SetSize(300, 300)
Indicator.Glow:SetPoint("CENTER", 0, 0)
Indicator.Glow:SetAlpha(0.5)
Indicator.Glow:SetCamDistanceScale(5)
Indicator.Glow:SetDisplayInfo(41039)
Indicator.Glow:SetRotation(1)

Indicator.Group = Indicator:CreateAnimationGroup()
Indicator.Translation = Indicator.Group:CreateAnimation("Translation")
Indicator.Translation:SetDuration(0.05)
Indicator.Translation:SetSmoothing("NONE")
Indicator.Translation:SetOrder(2)

Indicator.Scale1 = Indicator.Group:CreateAnimation("Scale")
Indicator.Scale1:SetDuration(0.1)
Indicator.Scale1:SetSmoothing("IN")
Indicator.Scale1:SetOrder(1)
Indicator.Scale1:SetOrigin("TOPLEFT", 0, 0)

Indicator.Scale2 = Indicator.Group:CreateAnimation("Scale")
Indicator.Scale2:SetSmoothing("OUT")
Indicator.Scale2:SetOrder(2)
Indicator.Scale2:SetOrigin("TOPLEFT", 0, 0)


function Indicator:Animate()
	local tX, tY = self:GetLeft(), self:GetTop()
	local dX, dY = self.object:GetCenter()
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", self.object, "CENTER", 0, 0)
	self.Group:Play()
end

function Indicator:Update(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		if UIHandle then
			local node = UIHandle:GetAttribute("node")
			if node then
				if ConsolePortCursor:IsVisible() then
					self.node = nil
					self:SetAlpha(0)
				elseif node:GetName() ~= self.node then
					self.node = node:GetName()
					local object = _G[self.node]
					if object then 
						self.object = object
						if self:GetAlpha() == 0 then
							self.Scale1:SetScale(3, 3)
							self.Scale2:SetScale(1/3, 1/3)
							self.Scale2:SetDuration(0.5)
							FadeOut(self.Glow, 0.5, 1, 0.5)
						else
							self.Scale1:SetScale(1.5, 1.5)
							self.Scale2:SetScale(1/1.5, 1/1.5)
							self.Scale2:SetDuration(0.2)
						end
						self:Animate()
						self:SetAlpha(1)
					end
				end
			else
				self.node = nil
				self:SetAlpha(0)
			end
		end
		self.Timer = self.Timer - elapsed
	end
end

Indicator.Timer = 0
Indicator:SetScript("OnUpdate", Indicator.Update)

-- 38262
-- 38327
-- 41039
-- 41110
