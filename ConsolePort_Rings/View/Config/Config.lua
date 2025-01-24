local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Config = {}; env.SharedConfig = {};
---------------------------------------------------------------

function Config:OnLoad()
	self.Ring = env:CreateMockRing('$parentRing', self)
	self.Ring:SetPoint('CENTER', self.Display, 'CENTER', 0, 0)
	self.Ring:SetSize(400, 400)
	self.Ring:SetFrameLevel(5)

	FrameUtil.SpecializeFrameWithMixins(self.Display, CPBackgroundMixin)
	self.Display:SetBackgroundInsets(4, -4, 4, 4)
	self.Display:AddBackgroundMaskTexture(self.Display.BorderArt.BgMask)
	self.Display:SetBackgroundAlpha(0.25)

	print('self.display', self.Display:DoesClipChildren())

	FrameUtil.SpecializeFrameWithMixins(self.Sets, env.SharedConfig.Sets)

	self.Tabs:AddTabs({
		{ text = L'Rings',   data = 'Rings'   },
		{ text = L'Loadout', data = 'Loadout' },
		{ text = OPTIONS,    data = 'Options' },
	})
	self.Tabs:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnTabSelected, self)
	self.Tabs:SelectAtIndex(1)

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNew', self.OnAddNew, self)
end

function Config:OnTabSelected(button, tabIndex)
	print('Selected tab', button, tabIndex)
end

function Config:OnSelectSet(setID, isSelected)
	self.Name:SetText(isSelected and Container:GetBindingDisplayNameForSetID(setID) or L'Ring Manager')
	self.Ring:SetShown(isSelected)
	if isSelected then
		self.Ring:Mock(Container.Data[setID])
	end
end

function Config:OnAddNew(container, node)
	self.Ring:SetShown(false)
end

function Config:SelectSet(setID)
	self.Sets:SetData(Container.Data, {}, setID)
	self:OnSelectSet(setID, true)
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