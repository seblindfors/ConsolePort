local _, db = ...;
local InputMixin, InputAPI = {}, CPAPI.CreateEventHandler({'Frame', '$parentInputHandler', ConsolePort, 'SecureHandlerStateTemplate'}, {
	'PLAYER_REGEN_DISABLED'; -- enter combat
	'PLAYER_REGEN_ENABLED';  -- leave combat
}, {
	Widgets = {};
});
---------------------------------------------------------------
db:Register('Input', InputAPI)
RegisterStateDriver(InputAPI, 'combat', '[combat] true; nil')
InputAPI:SetAttribute('_onstate-combat', [[
	control:ChildUpdate('combat', newstate)
]])
---------------------------------------------------------------

function InputAPI:GetWidget(id)
	assert(not InCombatLockdown(), 'Attempted to get input widget in combat.')
	local widget = self.Widgets[id]
	if not widget then
		widget = CreateFrame('Button', nil, self, 'SecureActionButtonTemplate, SecureHandlerBaseTemplate')
		widget:Hide()
		db('table/mixin')(widget, InputMixin)
		widget:OnLoad(id)
		self.Widgets[id] = widget
	end
	return widget
end

---------------------------------------------------------------
function InputMixin:OnLoad(id)
	self:SetAttribute('id', id)
	self:SetAttribute('_childupdate-combat', [[
		if message then
			self:SetAttribute('clickbutton', nil)
			self:Hide()
			self:CallMethod('Clear')
		end
	]])
end

function InputMixin:OnMouseDown()
	local func  = self:GetAttribute('type')
	local click = self:GetAttribute('clickbutton')
	self.state = true
	self.timer = 0
	-- secure function call, just show the state on UI
	if (func == 'click' or func == 'action') and click then
		return click:SetButtonState('PUSHED')
	end
	-- insecure function call
	if self[func] then
		self[func](self.state, self:GetAttribute('id'))
	end
end

function InputMixin:OnMouseUp()
	local func  = self:GetAttribute('type')
	local click = self:GetAttribute('clickbutton')
	self.state = false
	if (func == 'click' or func == 'action') and click then
		click:SetButtonState('NORMAL')
	end
end

function InputMixin:PostClick()
	local click = self:GetAttribute('clickbutton')
	if click and not click:IsEnabled() then
		self:ClearClickButton()
	end
end

function InputMixin:ClearClickButton()
	assert(not InCombatLockdown(), 'Attempted to insecurely clear click action in combat.')
	self:SetAttribute('clickbutton', nil)
end

function InputMixin:Clear(manual)
	self.timer = 0
	self.state = false
	if manual then
		self:ClearClickButton()
	end
end