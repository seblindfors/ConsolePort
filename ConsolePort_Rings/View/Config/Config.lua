local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Header = { Template = 'CPHeader', Size = CreateVector2D(304, 40) };
---------------------------------------------------------------

function Header:OnClick()
	self:OnButtonStateChanged()
	self:GetElementData():SetCollapsed(self:GetChecked())
end

function Header:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self:SetSize(self.Size:GetXY())
	self:SetScript('OnClick', Header.OnClick)
	RunNextFrame(function()
		self:SetChecked(elementData:IsCollapsed())
	end)
end

function Header:OnAcquire(new)
	if new then
		Mixin(self, Header)
	end
end

function Header:OnRelease()
	self:SetChecked(false)
end

function Header.New(text)
	return {
		text     = text;
		template = Header.Template;
		factory  = Header.Init;
		acquire  = Header.OnAcquire;
		release  = Header.OnRelease;
		extent   = Header.Size.y;
	};
end

---------------------------------------------------------------
local Config = {}; env.SharedConfig = { Header = Header };
---------------------------------------------------------------

function Config:OnLoad()
	self.DefaultTitle = L'Ring Manager';

	Container.Config = self; -- debug
	FrameUtil.SpecializeFrameWithMixins(self.Display, env.SharedConfig.Display)
	FrameUtil.SpecializeFrameWithMixins(self.Sets, env.SharedConfig.Sets)
	FrameUtil.SpecializeFrameWithMixins(self.Loadout, env.SharedConfig.Loadout)

	self.Panels = EnumUtil.MakeEnum('Rings', 'Loadout', 'Options');
	self.Tabs:AddTabs({
		[self.Panels.Rings]   = { text = L'Rings'   },
		[self.Panels.Loadout] = { text = L'Loadout' },
		[self.Panels.Options] = { text = OPTIONS,   },
	})
	self.Tabs:RegisterCallback(self.Tabs.Event.Selected, self.OnTabSelected, self)
	self.Tabs:SelectAtIndex(self.Panels.Rings)

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNewSet', self.OnAddNewSet, self)
	env:RegisterCallback('OnSelectTab', self.OnSelectTab, self)
end

function Config:OnTabSelected(button, tabIndex)
	self.Sets:SetShown(tabIndex ~= self.Panels.Loadout)
	self.Loadout:SetShown(tabIndex == self.Panels.Loadout)
	env:TriggerEvent('OnTabSelected', tabIndex, self.Panels)
end

function Config:OnSelectTab(tabIndex)
	self.Tabs:SelectAtIndex(tabIndex)
end

function Config:OnSelectSet(elementData, setID, isSelected)
	self.Name:SetText(isSelected and Container:GetBindingDisplayNameForSetID(setID) or self.DefaultTitle)
	self.Tabs:SetEnabled(self.Panels.Loadout, isSelected)
	self.Tabs:SetEnabled(self.Panels.Rings, true)
	env:TriggerEvent('OnSelectTab', self.Panels.Rings)
end

function Config:OnAddNewSet(container, node, isAdding)
	self.Name:SetText(isAdding and PAPERDOLL_NEWEQUIPMENTSET or self.DefaultTitle)
	self.Tabs:SetEnabled(self.Panels.Loadout, false)
	self.Tabs:SetEnabled(self.Panels.Rings, not isAdding)
	env:TriggerEvent('OnSelectTab', isAdding and self.Panels.Options or self.Panels.Rings)
end

function Config:SelectSet(setID)
	self.Sets:SetData(env:GetData(), env:GetShared(), setID)
	env:TriggerEvent('OnSelectSet', nil, setID, true)
end

env:RegisterCallback('ToggleConfig', function(self, setID)
	if not self.Config then
		self.Config, env.SharedConfig.Env = CPAPI.InitConfigFrame(
			Config, 'Frame', 'ConsolePortRingsConfig', UIParent, 'CPRingsConfig');
	end
	self.Config:Show()
	self.Config:SelectSet(setID)
end, env)



function cfg()
	env:TriggerEvent('ToggleConfig', 1)
end