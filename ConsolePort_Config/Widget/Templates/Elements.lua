local env, db, Elements = CPAPI.GetEnv(...); Elements = env.Elements;
---------------------------------------------------------------

local function InitializeSetting(self, ...)
	Mixin(self, ...)
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
end

---------------------------------------------------------------
local Header = CPAPI.CreateElement('CPHeader', 304, 40);
---------------------------------------------------------------
Elements.Header = Header;

function Header:OnClick()
	self:OnButtonStateChanged()
	self:Synchronize(self:GetElementData(), self:GetChecked())
end

function Header:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self:SetSize(self.size:GetXY())
	self:Synchronize(elementData)
end

function Header:Synchronize(elementData, newstate)
	local data = elementData:GetData()
	local collapsed;
	if ( newstate == nil ) then
		collapsed = data.collapsed;
	else
		collapsed = newstate;
	end
	self:SetChecked(collapsed)
	data.collapsed = collapsed;
	elementData:SetCollapsed(collapsed)
end

function Header:OnAcquire(new)
	if new then
		Mixin(self, Header)
		self:SetScript('OnClick', Header.OnClick)
	end
end

function Header:OnRelease()
	self:SetChecked(false)
end

function Header:Data(text, collapsed)
	return { text = text, collapsed = collapsed };
end

---------------------------------------------------------------
local Subcat = CPAPI.CreateElement('CPCategoryListButtonTemplate', 304, 34);
---------------------------------------------------------------
Elements.Subcat = Subcat;

function Subcat:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self:SetChecked(data.checked)
end

function Subcat:OnAcquire(new)
	if new then
		Mixin(self, Subcat)
		self:SetScript('OnClick', Subcat.OnClick)
	end
end

function Subcat:OnRelease()
	self:SetChecked(false)
end

function Subcat:OnClick()
	local data = self:GetElementData():GetData()
	env:TriggerEvent('OnSubcatClicked', data.text, data.childData)
end

function Subcat:Data(text, checked, childData)
	return { text = text, checked = checked, childData = childData };
end

---------------------------------------------------------------
local Divider = CPAPI.CreateElement('CPScrollDivider', 0, 10)
---------------------------------------------------------------
Elements.Divider = Divider;

function Divider:Data(extent)
	return { extent = extent };
end

---------------------------------------------------------------
local Title = CPAPI.CreateElement('CPPopupHeaderTemplate', 300, 38)
---------------------------------------------------------------
Elements.Title = Title;

function Title:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
end

function Title:OnAcquire(new)
	if new then
		Mixin(self, Title)
		self.Text:ClearAllPoints()
		self.Text:SetPoint('LEFT', 38, 0)
	end
end

function Title:Data(dpOrText)
	local text = type(dpOrText) == 'string' and dpOrText or dpOrText.text;
	return { text = text };
end

---------------------------------------------------------------
local Setting = CPAPI.CreateElement('CPSetting', 0, 40)
---------------------------------------------------------------
Elements.Setting = Setting;

function Setting:Init(elementData)
	local data = elementData:GetData()
	xpcall(self.Mount, geterrorhandler(), self, {
		name  = data.field.name;
		varID = data.varID;
		field = data.field;
		owner = ConsolePortConfig;
		registry = db;
		newObj = true;
	})
end

function Setting:OnChecked(checked)
	-- nop
end

function Setting:Check()
	self:SetChecked(true)
	self:OnChecked(true)
end

function Setting:Uncheck()
	self:SetChecked(false)
	self:OnChecked(false)
end

function Setting:OnAcquire(new)
	if new then
		InitializeSetting(self, env.Setting, Setting)
	end
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
end

function Setting:OnRelease()
	self:Reset()
	db:UnregisterCallback('OnDependencyChanged', self)
end

function Setting:OnDependencyChanged()
	local isShown = not self.metaData.hide;
	local newExtent = isShown and self.size.y or 0;
	self:GetElementData():GetData().extent = newExtent;
	self:SetHeight(newExtent)
	self:SetShown(isShown)
end

function Setting:Data(datapoint)
	return {
		varID = datapoint.varID;
		field = datapoint.field;
		type  = datapoint.field[1]:GetType();
	};
end

---------------------------------------------------------------
local Cvar = CreateFromMixins(Setting);
---------------------------------------------------------------
Elements.Cvar = Cvar;

function Cvar:Init(elementData)
	local data = elementData:GetData()
	xpcall(self.Mount, geterrorhandler(), self, {
		name       = data.field.name;
		varID      = data.varID;
		field      = data.field;
		owner      = ConsolePortConfig;
		registry   = db;
		newObj     = true;
		callbackID = data.varID;
		callbackFn = function(value)
			self:SetRaw(self.variableID, value, self.variableID)
			self:OnValueChanged(value)
			local device = db('Gamepad/Active')
			if device then
				device.Preset.Variables[self.variableID] = value;
				device:Activate()
			end
			db:TriggerEvent(self.variableID, value)
		end;
	})
end

function Cvar:OnAcquire(new)
	if new then
		InitializeSetting(self, env.Setting, Cvar)
	end
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
end

function Cvar:Get()
	local controller = self.controller;
	if controller:IsType('Bool') then
		return self:GetRawBool(self.variableID)
	elseif controller:IsType('Number') or controller:IsType('Range') then
		return tonumber(self:GetRaw(self.variableID))
	end
	return self:GetRaw(self.variableID)
end

function Cvar:SetRaw(...)
	return SetCVar(...)
end

function Cvar:GetRaw(...)
	return GetCVar(...)
end

function Cvar:GetRawBool(...)
	return GetCVarBool(...)
end

function Cvar:Data(datapoint)
	return {
		varID = datapoint.varID;
		field = datapoint.field;
		type  = 'Cvar'..datapoint.field[1]:GetType();
	};
end

---------------------------------------------------------------
local Mapper = CreateFromMixins(Cvar);
---------------------------------------------------------------
Elements.Mapper = Mapper;

function Mapper:OnAcquire(new)
	if new then
		InitializeSetting(self, env.Setting, Mapper)
	end
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
	db:RegisterCallback('OnMapperConfigLoaded', self.OnMapperConfigLoaded, self)
end

function Mapper:OnRelease()
	self:Reset()
	db:UnregisterCallback('OnDependencyChanged', self)
	db:UnregisterCallback('OnMapperConfigLoaded', self)
end

function Mapper:OnMapperConfigLoaded()
	self:OnValueChanged(self:GetRaw())
end

function Mapper:SetRaw(_, ...)
	return db.Mapper:SetValue(self.variableID, ...)
end

function Mapper:GetRaw(...)
	return db.Mapper:GetValue(self.variableID, self.controller:Get())
end

function Mapper:GetRawBool(...)
	return db.Mapper:GetValue(self.variableID, self.controller:Get())
end

function Mapper:Data(datapoint)
	return {
		varID = datapoint.varID;
		field = datapoint.field;
		type  = 'Mapper'..datapoint.field[1]:GetType();
	};
end

---------------------------------------------------------------
local Binding = CPAPI.CreateElement('CPBinding', 0, 32)
---------------------------------------------------------------
Elements.Binding = Binding;

local function OnIconChangedCallback(self, result)
	self.NormalTexture:SetAlpha(not result and 0.25 or 1)
	self.NormalTexture:SetTexture(result or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
end

local function OnIconClick(self, button)
	local isClearEvent = button == 'RightButton';
	env:TriggerEvent('OnBindingIconClicked',
		self:GetParent():GetElementData():GetData().bindingID,
		isClearEvent,
		self,
		OnIconChangedCallback
	);
end

function Binding:OnClick(button)
	local data = self:GetElementData():GetData()
	local isClearEvent = button == 'RightButton';
	env:TriggerEvent('OnBindingClicked',
		data.bindingID,  -- the bindingID to be set or cleared
		isClearEvent,    -- if the binding is to be cleared
		data.readonly(), -- if the binding is readonly
		self             -- the element that was clicked
	);
end

function Binding:Init(elementData)
	local data = elementData:GetData()
	self:SetText(data.name)
	self.Slug:SetBinding(data.bindingID)
	OnIconChangedCallback(self.Icon, db.Bindings:GetIcon(data.bindingID))
end

function Binding:OnAcquire(new)
	if new then
		InitializeSetting(self, Binding)
		self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		self:SetScript('OnClick', Binding.OnClick)
		self:HookScript('OnEnter', self.UpdateInfo)

		self.Icon:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		self.Icon:SetScript('OnClick', OnIconClick)

		local base = env.Settings.Base;
		self:HookScript('OnEnter', base.OnEnter)
		self:HookScript('OnLeave', base.OnLeave)
		self.UpdateTooltip = base.UpdateTooltip;
	end
end

function Binding:UpdateInfo()
	local data = self:GetElementData():GetData()
	local desc, image = db.Bindings:GetDescriptionForBinding(data.bindingID, true)
	local readOnlyText = data.readonly();
	self.disableTooltipHints = not not readOnlyText;

	local lines = { data.list };
	if desc then
		tinsert(lines, desc);
	end
	if readOnlyText then
		tinsert(lines, RED_FONT_COLOR:WrapTextInColorCode(readOnlyText:trim()));
	end

	local useMouseHints = not ConsolePort:IsCursorNode(self);

	self.tooltipText = table.concat(lines, '\n\n');
	self.tooltipImage = image;
	self.tooltipHints = not self.disableTooltipHints and {
		env:GetTooltipPromptForClick('LeftClick', EDIT, useMouseHints),
		env:GetTooltipPromptForClick('RightClick', REMOVE, useMouseHints),
	};
end

function Binding:Data(datapoint)
	return {
		name      = datapoint.name;
		list      = datapoint.field.list;
		bindingID = datapoint.binding;
		readonly  = datapoint.readonly;
	}
end