---------------------------------------------------------------
-- Cursors\Nameplates.lua: Secure nameplate targeting cursor
---------------------------------------------------------------
-- Creates a secure cursor that is used to iterate over nameplates
-- and select a target based on where the plate is drawn on screen.
-- Scans WorldFrame for active nameplates, scales them up to
-- cover the entire screen, then uses a mouseover macro to target.
-- Based loosely on semlar's LazyPlates concept. 

local _, db = ...
local WorldFrame = WorldFrame
local GetCVarBool = GetCVarBool
local IsMouselooking = IsMouselooking
local InCombatLockdown = InCombatLockdown

---------------------------------------------------------------
-- This is just a convenience button for cycling
-- active nameplates, instead of occupying several bindings to
-- achieve the same result.

local PlateCycle = CreateFrame("Button", "ConsolePortNameplateCycle", nil, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")

PlateCycle:SetAttribute("type", "macro")
PlateCycle:Execute([[
	Scripts = newtable()

	Scripts[1] = "/click InterfaceOptionsNamesPanelUnitNameplatesEnemies"
	Scripts[2] = "/click InterfaceOptionsNamesPanelUnitNameplatesFriends"
]])
PlateCycle:WrapScript(PlateCycle, "PreClick", [[
	Index = Index == 1 and 2 or 1
	self:SetAttribute("macrotext", Scripts[Index])
]])

---------------------------------------------------------------
---------------------------------------------------------------

local Cursor = CreateFrame("Button", "ConsolePortWorldCursor", WorldFrame, "SecureActionButtonTemplate, SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate")

Cursor:RegisterForClicks("AnyUp", "AnyDown")
Cursor:SetAttribute("type", "target")
Cursor:SetAttribute("_onstate-modifier", "Mod = newstate")

RegisterStateDriver(Cursor, "modifier", "[mod:ctrl,mod:shift] CTRL-SHIFT-; [mod:ctrl] CTRL-; [mod:shift] SHIFT-; ")

Cursor:SetSize(32, 32)
Cursor:Hide()

Cursor:HookScript("OnShow", function(self) PlaySound("INTERFACESOUND_LOSTTARGETUNIT") end)

---------------------------------------------------------------
local Key = {
	Up 		= ConsolePort:GetUIControlKey("CP_L_UP"),
	Down 	= ConsolePort:GetUIControlKey("CP_L_DOWN"),
	Left 	= ConsolePort:GetUIControlKey("CP_L_LEFT"),
	Right 	= ConsolePort:GetUIControlKey("CP_L_RIGHT"),
}
---------------------------------------------------------------

Cursor:SetFrameRef("WorldFrame", WorldFrame)
Cursor:SetFrameRef("MouseHandle", ConsolePortMouseHandle)

Cursor:Execute(format([[	
	---------------------------------------------------------------
	Plates = newtable()
	Visible = 0
	---------------------------------------------------------------
	DPAD = newtable()
	---------------------------------------------------------------
	Key = newtable()
	---------------------------------------------------------------
	Key.Up = %s
	Key.Down = %s
	Key.Left = %s
	Key.Right = %s
	---------------------------------------------------------------
	Cancel = newtable()
	Cancel.CP_X_CENTER = true
	Cancel.CP_X_LEFT = true
	Cancel.CP_X_RIGHT = true
	---------------------------------------------------------------
	Target = newtable()
	Target.CP_TR1 = true
	Target.CP_TR2 = true
	Target.CP_R_UP = true
	Target.CP_R_LEFT = true
	Target.CP_R_RIGHT = true
	---------------------------------------------------------------

	WorldFrame = self:GetFrameRef("WorldFrame")
	MouseHandle = self:GetFrameRef("MouseHandle")

	---------------------------------------------------------------

	GetPlates = [=[

		Plates = wipe(Plates)
		Visible = 0

		for i, frame in pairs(newtable(WorldFrame:GetChildren())) do
			local name = frame:GetName()
			if name and strmatch(name, "NamePlate") and frame:IsShown() then
				local unitFrame = frame:GetChildren()
				local unit = unitFrame and unitFrame:GetAttribute("unit")
				if unitFrame and unit and PlayerCanAttack(unit) then
					Plates[unitFrame] = true
				end
				Visible = Visible + 1
			end
		end
	]=]

	SetCurrent = [=[
		if old and old:IsShown() then
			current = old
		elseif (not current and next(Plates)) or (current and next(Plates) and not current:IsVisible()) then
			local thisX, thisY = self:GetRect()

			if not thisX or not thisY then
				local _, _, wfWidth, wfHeight = WorldFrame:GetRect()
				thisX, thisY = wfWidth / 2, wfHeight / 2
			end

			local plate, dist

			for Plate in pairs(Plates) do
				if Plate ~= old then
					local left, bottom, width, height = Plate:GetRect()

					if left and bottom and width and height then
						local destDistance = abs(thisX - (left + width / 2)) + abs(thisY - (bottom + height / 2))

						if not dist or destDistance < dist then
							plate = Plate
							dist = destDistance
						end
					end
				end
			end
			if plate then
				current = plate
			end
		end
		self:SetAttribute("plate", current)
	]=]

	FindClosestPlate = [=[
		if current and key ~= 0 then
			local left, bottom, width, height = current:GetRect()
			local thisY = bottom+height/2
			local thisX = left+width/2
			local nodeY, nodeX = 10000, 10000
			local destY, destX, diffY, diffX, total, swap
			local newTarget
			for destination in pairs(Plates) do
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
					newTarget = destination
					swap = false
				end
			end
			if not newTarget then
				for destination in pairs(Plates) do
					if destination ~= current then
						left, bottom, width, height = destination:GetRect()
						destY = bottom+height/2
						destX = left+width/2
						diffY = abs(thisY-destY)
						diffX = abs(thisX-destX)
						total = diffX + diffY
						if total < nodeX + nodeY then
							nodeX = diffX
							nodeY = diffY
							newTarget = destination
						end
					end
				end
			end
			current = newTarget or current
		end
	]=]

	Disable = [=[
		local wipeOld = ...
		if wipeOld then
			old = nil
		end
		IsEnabled = false
		self:SetParent(WorldFrame)
		self:ClearAllPoints()
		self:ClearBindings()
		self:Hide()
		current = nil
	]=]

	SelectPlate = [=[
		key, onHide = ...
		if current then
			old = current
		end

		self:Run(GetPlates)
		self:Run(SetCurrent)
		self:Run(FindClosestPlate)

		if Visible == 1 then
			print("vis1")
			self:SetAttribute("type", "target")
			self:SetAttribute("unit", current and current:GetAttribute("unit"))
			self:Run(Disable, onHide)
		elseif current and current:IsShown() then
			print(current, current:GetName())
			self:Show()
			self:ClearAllPoints()
			self:SetAttribute("type", "target")
			self:SetAttribute("unit", current:GetAttribute("unit"))
		else
			print("none")
			self:SetAttribute("type", "macro")
			self:SetAttribute("macrotext1", "/targetenemy")
			self:Run(Disable, onHide)
		end
	]=]
]], Key.Up, Key.Down, Key.Left, Key.Right))


Cursor:SetAttribute("_onhide", [[
	if IsEnabled then
		self:Run(SelectPlate, 0, true)
	end
]])

Cursor:WrapScript(Cursor, "OnClick", [[
	if button == "RightButton" then
		self:Run(Disable, true)
	elseif button == "LeftButton" then
		if down then 
			IsEnabled = not IsEnabled
		end
		if IsEnabled then
			if down then
				for binding, name in pairs(DPAD) do
					local key = GetBindingKey(binding)
					if key then
						self:SetBindingClick(true, key, self, name)
					end
				end
				for button in pairs(Cancel) do
					local key = GetBindingKey(button)
					if key then
						self:SetBindingClick(true, key, self, "RightButton")
					end
				end
				for button in pairs(Target) do
					local key = GetBindingKey(button)
					if key then
						self:SetBindingClick(true, key, self, "LeftButton")
					end
				end
				self:Run(SelectPlate, 0)
			end
		else
			self:Hide()
			if not down then
				self:ClearBindings()
			end
		end
	elseif down then
		self:Run(SelectPlate, Key[button])
	end
	MouseHandle:SetAttribute("override", not IsEnabled and not down)
]])

Cursor:WrapScript(Cursor, "PostClick", [[
	if not IsEnabled and not down and current then
		current:SetScale(1)
	end
]])


---------------------------------------------------------------
local wasMouseLooking

Cursor:HookScript("PreClick", function(self, button, down)
	if self:IsVisible() and button == "LeftButton" then
		wasMouseLooking = IsMouselooking()
		ConsolePort:StopCamera()
	end
end)

Cursor:HookScript("PostClick", function(self, button, down)
	if wasMouseLooking and not down then
		ConsolePort:StartCamera()
	end
end)

---------------------------------------------------------------
local buttons = {
	["Up"] 		= "CP_L_UP",
	["Down"] 	= "CP_L_DOWN",
	["Left"] 	= "CP_L_LEFT",
	["Right"] 	= "CP_L_RIGHT",
}
---------------------------------------------------------------
for name, binding in pairs(buttons) do
	Cursor:Execute(format("DPAD.%s = \"%s\"", binding, name))
end

---------------------------------------------------------------
-- Crosshairs are drawn on top of the current nameplate.
-- This frame updates smoothly to look more similar to
-- an actual mouse instead of instantly jumping between plates.

-- local Crosshairs = CreateFrame("Frame", "ConsolePortWorldCursorCrosshairs", WorldFrame)
-- Crosshairs:SetBackdrop({bgFile = "Interface\\Cursor\\Crosshairs"})
-- Crosshairs:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", 0, 0)
-- Crosshairs:SetSize(32, 32)
-- Crosshairs:Lower()
-- Crosshairs:Hide()

-- function Crosshairs:Update(elapsed)
-- 	local targetX, targetY = Cursor:GetCenter()
-- 	local currX, currY = self:GetCenter()
-- 	if targetX and targetY then
-- 		local horz, vert = (targetX - currX), (targetY - currY)
-- 		local distX, distY = abs(horz), abs(vert)
-- 		if distX < 10 and distY < 42 then
-- 			self:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", targetX, targetY)
-- 		else
-- 			self:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", currX + horz * 0.25, currY + vert * 0.25)
-- 		end
-- 	end
-- end

-- Cursor:HookScript("OnShow", function(self)
-- 	Crosshairs:Show()
-- 	for i, child in pairs({self:GetChildren()}) do
-- 		if child.mod then
-- 			child:SetParent(Crosshairs)
-- 			local point, _, relativePoint, xOffset, yOffset = child:GetPoint()
-- 			child:ClearAllPoints()
-- 			child:SetPoint(point, Crosshairs, relativePoint, xOffset, yOffset)
-- 			break
-- 		end
-- 	end
-- end)

-- Cursor:HookScript("OnHide", function(self)
-- 	Crosshairs:Hide()
-- end)


-- Crosshairs:SetScript("OnUpdate", Crosshairs.Update)