
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
			self:SetBindingClick(owner:GetAttribute('priorityoverride'), 'PAD1', curnode)
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
	self:CallMethod('Chime')
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
local IsGamePadInUse, IsGamePadCursor = IsGamePadFreelookEnabled, IsGamePadCursorControlEnabled;
local BASE_ARROW_ROTATION = rad(45);

function Cursor.Display:OnUpdate(elapsed)
	local divisor = 8 - elapsed; -- 4 is about right, account for FPS
	local parent  = self:GetParent()
	local arrow   = self.Arrow;

	parent.Blocker:SetShown(IsGamePadInUse() and not IsGamePadCursor())

	local cX, cY = self:GetLeft(), self:GetTop()
	local nX, nY = Node.GetCenter(parent)

	self:ClearAllPoints()
	if cX and cY and nX and nY then
		-- TODO: handle scale differences
		local diff = Node.GetDistance(cX, cY, nX, nY)
		if (  diff < 1 ) then
			arrow.rotation = arrow.rotation + ((BASE_ARROW_ROTATION - arrow.rotation) / divisor)
			arrow:SetRotation(arrow.rotation)
		else
			arrow.rotation = rad((math.atan2(nY - cY, nX - cX) * 180 / math.pi) - 90);
			arrow:SetRotation(arrow.rotation)
		end
		self.ArrowHilite:SetRotation(arrow.rotation)
		self.ArrowHilite:SetAlpha(diff)
		self:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT',
			cX + ((nX - cX) / divisor),
			cY + ((nY - cY) / divisor)
		);
	elseif nX and nY then
		self:SetPoint('TOPLEFT', self:GetParent(), 'CENTER', nX, nY)
	end
end

function Cursor.Display:OnHide()
	self:GetParent().Blocker:Hide()
end

function Cursor.Display:OnShow()
	self.Group:Stop()
	self.Group:Play()
end

function Cursor:Chime()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

Cursor.Display.Arrow.rotation = BASE_ARROW_ROTATION;
Cursor.Display.Arrow:SetRotation(BASE_ARROW_ROTATION)
Cursor.Display.ArrowHilite:SetRotation(BASE_ARROW_ROTATION)
Cursor.Display:SetScript('OnUpdate', Cursor.Display.OnUpdate)
Cursor.Display:SetScript('OnHide', Cursor.Display.OnHide)
Cursor.Display:SetScript('OnShow', Cursor.Display.OnShow)