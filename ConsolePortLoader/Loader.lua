-- Toggles ConsolePort on/off with a controller binding.
-- Runs separate from ConsolePort.

local Loader = CreateFrame('Button', 'ConsolePortLoader')

function Loader:OnClick()
	if IsAddOnLoaded('ConsolePort') then
		DisableAddOn('ConsolePort')
	else
		EnableAddOn('ConsolePort')
	end
	ReloadUI()
end

function Loader:SetBinding(binding)
	if not IsAddOnLoaded('ConsolePort') and binding then
		SetOverrideBindingClick(self, false, binding, self:GetName())
	end
	ConsolePortLoaderBinding = binding
end

function Loader:OnNewBindings()
	local bindingID, bindingMod = ConsolePort:GetCurrentBindingOwner('CLICK ConsolePortLoader:LeftButton')
	local key = bindingID and GetBindingKey(bindingID)
	self:SetBinding((bindingMod and key) and (bindingMod .. key))
end

function Loader:OnEvent(_, name)
	if name == 'ConsolePortLoader' then
		if IsAddOnLoaded('ConsolePort') then
			ConsolePort:RegisterCallback('OnNewBindings', self.OnNewBindings, self)
		end
		self:SetBinding(ConsolePortLoaderBinding)
		self:UnregisterEvent('ADDON_LOADED')
	end
end

Loader:RegisterEvent('ADDON_LOADED')
Loader:SetScript('OnClick', Loader.OnClick)
Loader:SetScript('OnEvent', Loader.OnEvent)