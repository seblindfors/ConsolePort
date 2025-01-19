local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Config = {};
---------------------------------------------------------------
-- test
function Config:OnLoad()
	self.Ring = env:CreateMockRing('$parentRing', self)
	self.Ring:SetPoint('CENTER', self.Display, 'CENTER', 0, 0)
	self.Ring:SetSize(400, 400)
	self.Ring:SetFrameLevel(5)
	self.Name:SetText('Ring Manager')

	FrameUtil.SpecializeFrameWithMixins(self.Display, CPBackgroundMixin)
	self.Display:SetBackgroundInsets(4, -4, 4, 4)
	self.Display:AddBackgroundMaskTexture(self.Display.BorderArt.BgMask)
	self.Display:SetBackgroundAlpha(0.25)

	local button = CreateFrame('Button', nil, self.Sets, 'CPHeader')
	button:SetPoint('TOPLEFT', 4, -8)
	button:SetSize(300, 34)
	button.Text:SetText('General')


	self.Tabs:AddTabs({
		{ text = L'Rings',   data = 'Rings'   },
		{ text = L'Loadout', data = 'Loadout' },
		{ text = OPTIONS,    data = 'Options' },
	})
	self.Tabs:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnTabSelected, self)
	self.Tabs:SelectAtIndex(1)
end

function Config:OnTabSelected(button, tabIndex)
	print('Selected', button, tabIndex)
end


env:RegisterCallback('ToggleConfig', function(_, setID)
	if not env.Config then
		env.Config = CPAPI.InitConfigFrame(Config, 'Frame', 'ConsolePortRingsConfig', UIParent, 'CPRingsConfig');
	end
	env.Config:Show()
	env.Config.Ring:Mock(Container.Data[setID])
	env.Config.Ring:Show()
end)



function cfg()
	env:TriggerEvent('ToggleConfig', 1)
end