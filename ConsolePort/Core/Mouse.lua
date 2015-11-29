---------------------------------------------------------------
-- Mouse.lua: Smart camera control and mouse function wrappers
---------------------------------------------------------------
-- Removes the need of holding right click to control camera.
-- Allows user to mouseover their character to control camera.
-- Toggles off on targeted spells, InteractUnit and pickups. 

local MouseIsOver = MouseIsOver
local HasCursorItem = GetCursorInfo
local GetMouseFocus = GetMouseFocus
local SpellIsTargeting = SpellIsTargeting
local IsMouseButtonDown = IsMouseButtonDown

local IsCentered, IsVisible
local Locker = CreateFrame("Frame", "ConsolePortMouseLook", UIParent)
Locker:SetPoint("CENTER", 0, 0)
Locker:SetSize(70, 180)
Locker:Hide()

local function MouseLookShouldStart()
	if 	not SpellIsTargeting() 			and
		not IsMouseButtonDown(1) 		and
		not HasCursorItem() 			and
		MouseIsOver(Locker) 			and
		(GetMouseFocus() == WorldFrame) then
		return true
	end
end

local function MouseUpdate(self)
	if 	not IsVisible and HasCursorItem() then
		self:StopMouse()
	elseif not IsCentered and
		MouseLookShouldStart() then
		self:StartMouse()
		IsCentered = true
	elseif not MouseIsOver(Locker) and IsCentered then
		IsCentered = false
	end
end

---------------------------------------------------------------
-- Mouse function wrappers
---------------------------------------------------------------
function ConsolePort:StopMouse()
	IsVisible = true
	MouselookStop()
end

function ConsolePort:StartMouse()
	IsVisible = nil
	MouselookStart()
end

function ConsolePort:ToggleMouse()
	if IsVisible then
		MouselookStart()
		IsVisible = nil
	else
		MouselookStop()
		IsVisible = true
	end
end

---------------------------------------------------------------
-- Toggle smart mouse behaviour on/off
---------------------------------------------------------------
function ConsolePort:UpdateSmartMouse()
	if ConsolePortSettings.disableSmartMouse then
		self:RemoveUpdateSnippet(MouseUpdate)
	else
		self:AddUpdateSnippet(MouseUpdate)
	end
end

-- Get rid of mouselook when trying to interact with mouse
hooksecurefunc("InteractUnit", ConsolePort.StopMouse)