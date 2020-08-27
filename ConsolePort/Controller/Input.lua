---------------------------------------------------------------
-- Input handler
---------------------------------------------------------------
-- Provides widgets and methods for performing secure actions,
-- mapped by various parts of the interface to override the
-- default actions of gamepad inputs.

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

function InputAPI:GetWidget(id, owner)
	assert(not InCombatLockdown(), 'Attempted to get input widget in combat.')
	local widget = self.Widgets[id]
	if not widget then
		widget = CreateFrame('Button', ('CPInput-%s'):format(tostring(id)), self, 'SecureActionButtonTemplate, SecureHandlerBaseTemplate')
		widget:Hide()
		db('table/mixin')(widget, InputMixin)
		widget:OnLoad(id)
		self.Widgets[id] = widget
	end
	widget:SetAttribute('owner', owner)
	return widget
end

function InputAPI:Release(owner)
	for id, widget in pairs(self.Widgets) do
		if ( widget:GetAttribute('owner') == owner ) then
			widget:ClearOverride()
		end
	end
end

function InputAPI:ReleaseAll()
	for id, widget in pairs(self.Widgets) do
		widget:ClearOverride()
	end
end

---------------------------------------------------------------
-- Supported functions 
---------------------------------------------------------------
function InputAPI:Button(id, owner, ...)
	return self:GetWidget(id, owner):Button(...)
end

function InputAPI:Macro(id, owner, ...)
	return self:GetWidget(id, owner):Macro(...)
end

function InputAPI:Global(id, owner, ...)
	return self:GetWidget(id, owner):Global(...)
end

function InputAPI:Command(id, owner, ...)
	return self:GetWidget(id, owner):Command(...)
end

---------------------------------------------------------------
-- Common args:
--  @isPriority : whether this binding should be prioritized
--  @click      : (optional) emulated mouse button
--  @attribute  : attribute value for the configured action

function InputMixin:Button(isPriority, click, attribute)
	self:SetAttribute('type', 'click')
	self:SetAttribute('clickbutton', attribute)
	return self:SetOverride(isPriority, click)
end

function InputMixin:Macro(isPriority, click, attribute)
	self:SetAttribute('type', 'macro')
	self:SetAttribute('macrotext', attribute)
	return self:SetOverride(isPriority, click)
end

function InputMixin:Global(isPriority, click, attribute)
	return self:SetOverride(isPriority, click, attribute)
end

-- Creates a new command:
--  @name : name of the function to add
--  @func : lambda function to call
--  @init : (optional) function to set up properties
--  @args : (optional) properties for initialization
function InputMixin:Command(isPriority, click, name, func, init, ...)
	self[name] = func
	self:SetAttribute('type', name)
	if init then
		init(self, ...)
	end
	self:SetOverride(isPriority, click)
end

---------------------------------------------------------------
-- InputMixin
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

function InputMixin:SetOverride(isPriority, click, target)
	SetOverrideBindingClick(self,
		isPriority,
		self:GetAttribute('id'),
		target or self:GetName(),
		click or 'LeftButton'
	);
	return self
end

function InputMixin:ClearOverride()
	self:SetAttribute('type', nil)
	ClearOverrideBindings(self)
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
		self[func](self, self.state, self:GetAttribute('id'))
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