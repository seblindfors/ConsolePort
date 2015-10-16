local addOn, db = ...

local ConsolePort = ConsolePort
local mToggle = ConsolePort:CreateMouseLooker()


local function MouseLookShouldStart()
	if 	not SpellIsTargeting() 			and
		not IsMouseButtonDown(1) 		and
		not GetCursorInfo() 			and
		MouseIsOver(mToggle) 			and
		(GetMouseFocus() == WorldFrame) then
		return true
	end
end

local MouseIsCentered = false
local CursorInfo = false
local function MouseUpdate(self)
	if 	not CursorInfo and GetCursorInfo() then
		self:StopMouse()
	elseif not MouseIsCentered and
		MouseLookShouldStart() then
		self:StartMouse()
		MouseIsCentered = true;
	elseif not MouseIsOver(mToggle) and MouseIsCentered then
		MouseIsCentered = false
	end
end

function ConsolePort:StopMouse()
	CursorInfo = true
	MouselookStop()
end

function ConsolePort:StartMouse()
	CursorInfo = nil
	MouselookStart()
end

function ConsolePort:ToggleMouse()
	if CursorInfo then
		MouselookStart()
		CursorInfo = nil
	else
		MouselookStop()
		CursorInfo = true
	end
end

ConsolePort:AddUpdateSnippet(MouseUpdate)