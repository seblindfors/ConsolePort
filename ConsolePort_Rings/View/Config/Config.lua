local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Header = { Template = 'CPHeader', Size = CreateVector2D(304, 40) };
---------------------------------------------------------------

function Header:OnClick()
	self:OnButtonStateChanged()
	self:Synchronize(self:GetElementData(), self:GetChecked())
end

function Header:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self:SetSize(self.Size:GetXY())
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

function Header.New(text, collapsed)
	return {
		text      = text;
		collapsed = collapsed;
		template  = Header.Template;
		factory   = Header.Init;
		acquire   = Header.OnAcquire;
		release   = Header.OnRelease;
		extent    = Header.Size.y;
	};
end

---------------------------------------------------------------
local Divider = { Template = 'CPRingSetDivider' };
---------------------------------------------------------------

function Divider.New(extent)
	return {
		extent   = extent or 10;
		template = Divider.Template;
		factory  = nop;
	};
end

---------------------------------------------------------------
local Search = {};
---------------------------------------------------------------

function Search:OnLoad()
	self:SetScript('OnTextChanged', Search.OnTextChanged)
	self:SetScript('OnEnterPressed', Search.OnEnterPressed)
	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
end

function Search:Debounce()
	self:Cancel()
	self.timer = C_Timer.NewTimer(0.5, function()
		local text = self:GetText()
		if text:len() >= MIN_CHARACTER_SEARCH then
			env:TriggerEvent('OnSearch', text)
		end
	end)
end

function Search:Cancel(dispatch)
	if self.timer then
		self.timer:Cancel()
		self.timer = nil;
		if dispatch then
			env:TriggerEvent('OnSearch', nil)
		end
	end
end

function Search:OnEnterPressed()
	EditBox_ClearFocus(self)
	if self.timer then
		self.timer:Invoke()
		self.timer:Cancel()
		self.timer = nil;
	end
end

function Search:OnTextChanged(userInput)
	SearchBoxTemplate_OnTextChanged(self)
	local text = self:GetText()
	if not userInput or text:len() < MIN_CHARACTER_SEARCH then
		return self:Cancel(true)
	end
	self:Debounce()
end

function Search:OnTabSelected(tabIndex, panels)
	self:SetText('')
	self:SetEnabled(tabIndex == panels.Loadout)
end

---------------------------------------------------------------
local Config = {}; env.SharedConfig = {
---------------------------------------------------------------
	Header  = Header;
	Divider = Divider;
};

function Config:OnLoad()
	self.DefaultTitle = L'Ring Manager';

	FrameUtil.SpecializeFrameWithMixins(self.Display, env.SharedConfig.Display)
	FrameUtil.SpecializeFrameWithMixins(self.Sets, env.SharedConfig.Sets)
	FrameUtil.SpecializeFrameWithMixins(self.Loadout, env.SharedConfig.Loadout)
	FrameUtil.SpecializeFrameWithMixins(self.Search, Search)

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
	self.Portrait.Icon:SetTexture(env:GetSetIcon(isSelected and setID))
	self.Portrait:Play()
	self.Name:SetText(isSelected and Container:GetBindingDisplayNameForSetID(setID) or self.DefaultTitle)
	self.Tabs:SetEnabled(self.Panels.Loadout, isSelected)
	self.Tabs:SetEnabled(self.Panels.Rings, true)
	env:TriggerEvent('OnSelectTab', self.Panels.Rings)
end

function Config:OnAddNewSet(container, node, isAdding)
	self.Portrait.Icon:SetTexture(env:GetSetIcon(nil))
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



function cfg() -- debug
	env:TriggerEvent('ToggleConfig', 1)
end