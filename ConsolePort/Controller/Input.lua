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

function InputAPI:GetWidget(id, owner) id = tostring(id):upper();
	assert(not InCombatLockdown(), 'Attempted to get input widget in combat.')
	local widget = self.Widgets[id];
	if not widget then
		widget = CreateFrame(
			'Button', ('CP-Input-%s'):format(id),
			self, 'SecureActionButtonTemplate, SecureHandlerBaseTemplate'
		);
		widget:Hide()
		db.table.mixin(widget, InputMixin)
		widget:OnLoad(id)
		self.Widgets[id] = widget;
	end
	widget:SetAttribute('owner', owner)
	return widget;
end

function InputAPI:Release(owner)
	for id, widget in pairs(self.Widgets) do
		if ( widget:HasOwner(owner) ) then
			widget:ClearOverride(owner)
		end
	end
end

function InputAPI:ReleaseAll()
	for id, widget in pairs(self.Widgets) do
		widget:ClearOverride()
	end
end

function InputAPI:GetActiveWidget(id, owner)
	local widget = self.Widgets[id];
	if (widget and widget:GetAttribute('owner') == owner) then
		return widget;
	end
end

function InputAPI:IsOverrideActive(id, isPriority)
	local widget = self.Widgets[id];
	if not widget then
		return false;
	elseif isPriority then
		return widget[1] and true or false;
	end
	return widget[1] or widget[2] and true or false;
end

---------------------------------------------------------------
-- Supported functions 
---------------------------------------------------------------
-- Common args:
-- @id    : id of the input widget
-- @owner : frame that owns the input widget

---------------------------------------------------------------
-- @value : button frame to click on
function InputAPI:SetButton(id, owner, ...)
	return self:GetWidget(id, owner):Button(...)
end

---------------------------------------------------------------
-- @value : macrotext
function InputAPI:SetMacro(id, owner, ...)
	return self:GetWidget(id, owner):Macro(...)
end

---------------------------------------------------------------
-- @value : global button name
function InputAPI:SetGlobal(id, owner, ...)
	return self:GetWidget(id, owner):Global(...)
end

---------------------------------------------------------------
-- @value : name of the function to call
-- @func  : custom function to call
-- @init  : (optional) function to set up properties on attach
-- @clear : (optional) function to run when clearing/detaching
-- @args  : (optional) vararg properties fed to initialization
function InputAPI:SetCommand(id, owner, ...)
	return self:GetWidget(id, owner):Command(...)
end

---------------------------------------------------------------
-- Common args:
--  @value      : value for the configured action
--  @isPriority : whether this binding should be prioritized
--  @click      : (optional) emulated mouse button

function InputMixin:Button(value, isPriority, click)
	return self:SetOverride({
		owner = self:GetAttribute('owner');
		button = click;
		isPriority = isPriority;
		attributes = {
			[CPAPI.ActionTypeRelease] = 'click';
			clickbutton = value;
		}
	})
end

function InputMixin:Macro(value, isPriority, click)
	return self:SetOverride({
		owner = self:GetAttribute('owner');
		button = click;
		isPriority = isPriority;
		attributes = {
			[CPAPI.ActionTypeRelease] = 'macro';
			macrotext = value;
		}
	})
end

function InputMixin:Global(value, isPriority, click)
	return self:SetOverride({
		owner = self:GetAttribute('owner');
		button = click;
		isPriority = isPriority;
		target = value;
		attributes = {
			[CPAPI.ActionTypeRelease] = 'none';
		}
	})
end

function InputMixin:Command(isPriority, click, name, func, init, clear, ...)
	self[name] = func
	if init then
		init(self, ...)
	end
	return self:SetOverride({
		owner = self:GetAttribute('owner');
		clear = clear;
		button = click;
		isPriority = isPriority;
		attributes = {
			[CPAPI.ActionTypeRelease] = name;
		}
	})
end


---------------------------------------------------------------
-- InputMixin override handler, supports 2 layers of overrides
---------------------------------------------------------------
function InputMixin:SetOverride(data)
	self[data.isPriority and 1 or 2] = data
	if data.attributes then
		for attribute, value in pairs(data.attributes) do
			self:SetAttribute(attribute, value)
		end
	end
	self:SetOverrideBinding(
		data.isPriority,
		self:GetAttribute('id'),
		data.target or self:GetName(),
		data.button or 'LeftButton'
	);
	return self
end

function InputMixin:HasOwner(owner)
	for i=1, 2 do
		local data = self[i];
		if ( data and data.owner == owner ) then
			return i, data;
		end
	end
end

function InputMixin:GetOverride(isPriority)
	if isPriority then
		return self[1];
	end
	return self[2];
end

function InputMixin:ClearOverride(owner)
	if owner then
		local i = self:HasOwner(owner)
		if i then
			self:ClearDataAndBinding(i)
			local other = self[i % 2 + 1];
			if other then -- reinstate other
				return self:SetOverride(other)
			end
		end
		return -- do nothing if owner is faulty
	end
	self:ClearDataAndBinding(1, 2)
end

function InputMixin:ClearDataAndBinding(...)
	for i=1, select('#', ...) do
		local idx = select(i, ...)
		local data = self[idx]
		if data and data.clear then
			data.clear(self)
		end
		self[idx] = nil;
	end
	self:ClearOverrideBinding()
end

---------------------------------------------------------------
-- InputMixin
---------------------------------------------------------------
InputMixin.timer = 0;

function InputMixin:OnLoad(id)
	if CPAPI.IsRetailVersion then
		self:RegisterForClicks('AnyUp', 'AnyDown')
		self:SetAttribute(CPAPI.ActionPressAndHold, true)
	end
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
	local func  = self:GetAttribute(CPAPI.ActionTypeRelease)
	local click = self:GetAttribute('clickbutton')
	self.state, self.timer = true, self:GetAttribute('timer') or 0;

	if self:IsSecureAction(func, click) then
		return self:EmulateFrontend(click, 'PUSHED', 'OnMouseDown')
	end
	return self:CallFunc(func)
end

function InputMixin:OnMouseUp()
	local func  = self:GetAttribute(CPAPI.ActionTypeRelease)
	local click = self:GetAttribute('clickbutton')
	self.state = false;

	if self:IsSecureAction(func, click) then
		return self:EmulateFrontend(click, 'NORMAL', 'OnMouseUp')
	end
	return self:CallFunc(func)
end

function InputMixin:IsSecureAction(func, click)
	return (func == 'click' or func == 'action') and click;
end

function InputMixin:EmulateFrontend(click, state, script)
	if click:IsEnabled() then
		if ConsolePort:ProcessInterfaceClickEvent(script, click, state) then
			self.postreset = self:GetAttribute(CPAPI.ActionTypeRelease)
			self:SetAttribute(CPAPI.ActionTypeRelease, nil)
		end
		ExecuteFrameScript(click, script)
		return click:SetButtonState(state)
	end
end

function InputMixin:PostClick(...)
	if self.postreset then
		self:SetAttribute(CPAPI.ActionTypeRelease, self.postreset)
		self.postreset = nil;
	end
end

function InputMixin:CallFunc(func)
	if not self[func] then return end
	return self[func](self, self.state, self:GetAttribute('id'))
end

function InputMixin:ClearClickButton()
	assert(not InCombatLockdown(), 'Attempted to insecurely clear click action in combat.')
	self:SetAttribute('clickbutton', nil)
end

function InputMixin:HasClickButton()
	return self:GetAttribute('clickbutton')
end

function InputMixin:Clear(manual)
	self.timer, self.state = 0, false;
	if manual then
		self:ClearClickButton()
	end
end

---------------------------------------------------------------
-- Conflict handler
---------------------------------------------------------------
-- Handles a specific case when external overrides knock input
-- handling into a lower priority, because of the chronological
-- stack. Might need a var for this assertion if other addons
-- leverage custom gamepad controls outside combat.

InputMixin.SetOverrideBinding = SetOverrideBindingClick;
InputMixin.ClearOverrideBinding = ClearOverrideBindings;

do local function HandleConflict(owner, isPriority, key)
		local formattedKey = tostring(key):upper()
		if IsBindingForGamePad(formattedKey) then
			local widget = InputAPI.Widgets[formattedKey];
			local override = widget and widget:GetOverride(isPriority)
			if override then
				widget:SetOverride(override)
			end
		end
	end

	hooksecurefunc('SetOverrideBinding',      HandleConflict)
	hooksecurefunc('SetOverrideBindingClick', HandleConflict)
	hooksecurefunc('SetOverrideBindingItem',  HandleConflict)
	hooksecurefunc('SetOverrideBindingMacro', HandleConflict)
	hooksecurefunc('SetOverrideBindingSpell', HandleConflict)

	function InputAPI:HandleConflict(...)
		if not InCombatLockdown() then
			HandleConflict(...)
		end
	end
end