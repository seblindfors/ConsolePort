ConsolePortActionButtonMixin = {}

function ConsolePortActionButtonMixin:SetIcon(file)
	local icon = self.icon or self.Icon
	if icon then
		icon:SetDesaturated(not file and true or false)
		icon:SetTexture(file or [[Interface\AddOns\ConsolePort\Textures\Button\EmptyIcon]])
	end
end

function ConsolePortActionButtonMixin:ClearIcon()
	local icon = self.icon or self.Icon
	if icon then
		icon:SetDesaturated(false)
		icon:SetTexture(nil)
	end
end

function ConsolePortActionButtonMixin:SetVertexColor(...)
	local icon = self.icon or self.Icon
	local font = self:GetFontString()
	if icon then icon:SetVertexColor(...) end
	if font then font:SetVertexColor(...) end
end

function ConsolePortActionButtonMixin:ClearVertexColor()
	local icon = self.icon or self.Icon
	local font = self:GetFontString()
	if icon then icon:SetVertexColor(1, 1, 1) end
	if font then icon:SetVertexColor(1, 1, 1) end
end

function ConsolePortActionButtonMixin:ToggleShadow(enabled)
	local shadow = self.shadow or self.Shadow
	if shadow then
		if enabled == nil then
			enabled = not shadow:IsShown()
		end
		shadow:SetShown(enabled)
	end
end

function ConsolePortActionButtonMixin:SetCount(val, forceShow)
	local count = self.count or self.Count
	if count then
		val = tonumber(val)
		count:SetText(((val and val >  1) or forceShow) and val or '')
	end
end