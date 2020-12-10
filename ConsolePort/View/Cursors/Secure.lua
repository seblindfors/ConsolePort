
local _, db = ...;
local Cursor, Node = db:Register('Secure', db.Securenav(ConsolePortSecureCursor)), ConsolePortNode;

---------------------------------------------------------------
-- Registration of a secure cursor user frame
---------------------------------------------------------------
function Cursor:RegisterUser(user)
	self:WrapScript(user, 'OnShow', [[
		local parent = owner:GetParent();
		if (parent ~= self) then
			prevowner = parent;
			prevpoint = newtable(owner:GetPoint())
		end
		owner:ClearAllPoints()
		owner:SetParent(self)
		owner:SetFrameLevel(10000)
		owner:Run(ToggleCursor, true)
	]])
	self:WrapScript(user, 'OnHide', [[
		if prevowner then
			owner:ClearAllPoints()
			owner:SetParent(prevowner)
			if next(prevpoint) then
				owner:SetPoint(unpack(prevpoint))
			end
			prevowner, prevpoint = nil, nil;
			owner:Run(ToggleCursor, true)
		end
		owner:Run(ToggleCursor, false)
	]])
end

---------------------------------------------------------------
-- Navigation and input
---------------------------------------------------------------
Cursor:CreateEnvironment({
	ToggleCursor = [[
		enabled = ...;

		if enabled then
			self:Run(SetBaseBindings)
			self:Run(UpdateNodes)
			self:Run(SelectNewNode, 0)
			self:Show()
		else
			self:Run(ClearHighlight)
			self:ClearBindings()
			self:Hide()
		end
	]];
	PostNodeSelect = [[
		if curnode then
			self:ClearAllPoints()
			self:SetPoint('TOPLEFT', curnode, 'CENTER', 0, 0)
			self:SetBindingClick(false, 'PAD1', curnode)
			self:CallMethod('CallScript', 'OnEnter', curnode:GetName())
		else
			self:ClearBinding('PAD1')
		end
	]];
	ClearHighlight = [[
		if curnode then
			self:CallMethod('CallScript', 'OnLeave', curnode:GetName())
		end
	]];
})

Cursor:WrapScript(Cursor, 'PreClick', [[
	self:Run(ClearHighlight)
	self:Run(SelectNewNode, button)
]])

function Cursor:CallScript(scriptID, name)
	local widget = _G[name];
	local script = widget and widget:GetScript(scriptID)
	if script then
		script(widget)
	end
end

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
function Cursor.Display:OnUpdate(elapsed)
	local divisor = 4 - elapsed; -- 4 is about right, account for FPS
	local parent  = self:GetParent()
	local cX, cY = self:GetLeft(), self:GetTop()
	local nX, nY = parent:GetLeft(), parent:GetTop()  --Node.GetCenter()
	self:ClearAllPoints()
	if cX and cY and nX and nY then
		self:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT',
			cX + ((nX - cX) / divisor),
			cY + ((nY - cY) / divisor)
		);
	elseif nX and nY then
		self:SetPoint('TOPLEFT', self:GetParent(), 'TOPLEFT', nX, nY)
	end
end

Cursor.Display.Arrow:SetRotation(rad(45))
Cursor.Display:SetScript('OnUpdate', Cursor.Display.OnUpdate)