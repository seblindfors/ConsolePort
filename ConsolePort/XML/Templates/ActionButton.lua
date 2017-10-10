ConsolePortActionButtonMixin = {}
local Button = ConsolePortActionButtonMixin

function Button:SetIcon(file)
	self.icon:SetDesaturated(not file and true or false)
	self.icon:SetTexture(file or [[Interface\ICONS\Ability_BossFelOrcs_Necromancer_Red]])
end

function Button:SetVertexColor(...)
	self.icon:SetVertexColor(...)
end

function Button:ClearVertexColor()
	self.icon:SetVertexColor(1, 1, 1)
end

function Button:ToggleShadow(enabled)
	if enabled == nil then
		enabled = not self.Shadow:IsShown()
	end
	self.Shadow:SetShown(enabled)
end

function Button:SetCount(count, forceShow)
	count = tonumber(count)
	self.Count:SetText(((count and count >  1) or forceShow) and count or '')
end