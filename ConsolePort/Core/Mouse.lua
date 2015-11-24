local addOn, db = ...

local ConsolePort = ConsolePort
local IsCentered, IsVisible
local Locker = CreateFrame("Frame", addOn.."MouseLook", UIParent)
Locker:SetPoint("CENTER", 0, 0)
Locker:SetSize(70, 180)
Locker:Hide()

local function MouseLookShouldStart()
	if 	not SpellIsTargeting() 			and
		not IsMouseButtonDown(1) 		and
		not GetCursorInfo() 			and
		MouseIsOver(Locker) 			and
		(GetMouseFocus() == WorldFrame) then
		return true
	end
end

local function MouseUpdate(self)
	if 	not IsVisible and GetCursorInfo() then
		self:StopMouse()
	elseif not IsCentered and
		MouseLookShouldStart() then
		self:StartMouse()
		IsCentered = true
	elseif not MouseIsOver(Locker) and IsCentered then
		IsCentered = false
	end
end

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

ConsolePort:AddUpdateSnippet(MouseUpdate)