
local _, db = ...;
local Cursor = db:Register('Secure', db.Securenav(ConsolePortSecureCursor));

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
			self::SetBaseBindings()
			self::UpdateNodes()
			self::SelectNewNode(0)
			self:Show()
		else
			self::ClearHighlight()
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
			local secureOnEnterScript = curnode:GetAttribute('OnEnter')
			if secureOnEnterScript then
				self:RunFor(curnode, secureOnEnterScript)
			end
		else
			self:ClearBinding('PAD1')
		end
	]];
	ClearHighlight = [[
		if curnode then
			self:CallMethod('CallScript', 'OnLeave', curnode:GetName())
			local secureOnLeaveScript = curnode:GetAttribute('OnLeave')
			if secureOnLeaveScript then
				self:RunFor(curnode, secureOnLeaveScript)
			end
		end
	]];
})

Cursor:Wrap('PreClick', [[
	self::ClearHighlight()
	self::SelectNewNode(button)
	self:CallMethod('Chime')
]])

function Cursor:OnDataLoaded()
	self:SetAttribute('wrapDisable', db('UIWrapDisable'))
end

db:RegisterSafeCallbacks(Cursor.OnDataLoaded, Cursor,
	'OnDataLoaded',
	'Settings/UIWrapDisable'
);

db:RegisterSafeCallback('OnUpdateOverrides', function(self, isPriority)
	self:Execute('self:RunAttribute("ToggleCursor", enabled)')
end, Cursor)

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
function Cursor:Chime()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end