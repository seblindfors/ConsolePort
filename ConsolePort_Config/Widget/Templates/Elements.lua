local env, db, Elements = CPAPI.GetEnv(...); Elements = env.Elements;
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

function Title:Data(text)
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
		Mixin(self, env.Setting, Setting)
		self:HookScript('OnEnter', self.LockHighlight)
		self:HookScript('OnLeave', self.UnlockHighlight)
	end
end

function Setting:OnRelease()
	self:Reset()
end

function Setting:Data(datapoint)
	return {
		varID = datapoint.varID;
		field = datapoint.field;
		type  = datapoint.field[1]:GetType();
	};
end