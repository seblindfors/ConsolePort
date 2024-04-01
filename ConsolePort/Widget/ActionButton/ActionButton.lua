---------------------------------------------------------------
-- Base action button mixin
---------------------------------------------------------------
CPActionButtonMixin = {}

function CPActionButtonMixin:SetIcon(file)
	local icon = self.icon or self.Icon
	if icon then
		icon:SetDesaturated(not file and true or false)
		icon:SetTexture(file or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
	end
end

function CPActionButtonMixin:ClearIcon()
	local icon = self.icon or self.Icon
	if icon then
		icon:SetDesaturated(false)
		icon:SetTexture(nil)
	end
end

function CPActionButtonMixin:SetVertexColor(...)
	local icon = self.icon or self.Icon
	local font = self:GetFontString()
	if icon then icon:SetVertexColor(...) end
	if font then font:SetVertexColor(...) end
end

function CPActionButtonMixin:ClearVertexColor()
	local icon = self.icon or self.Icon
	local font = self:GetFontString()
	if icon then icon:SetVertexColor(1, 1, 1) end
	if font then icon:SetVertexColor(1, 1, 1) end
end

function CPActionButtonMixin:ToggleShadow(enabled)
	local shadow = self.shadow or self.Shadow
	if shadow then
		if enabled == nil then
			enabled = not shadow:IsShown()
		end
		shadow:SetShown(enabled)
	end
end

function CPActionButtonMixin:SetCount(val, forceShow)
	local count = self.count or self.Count
	if count then
		val = tonumber(val)
		count:SetText(((val and val >  1) or forceShow) and val or '')
	end
end

---------------------------------------------------------------
-- Self-handling action button mixin
---------------------------------------------------------------
CPActionButton = CreateFromMixins(CPActionButtonMixin);
CPActionButton.isMainButton = true; -- default

function CPActionButton:IsLargeButton()
	return self.isMainButton;
end

function CPActionButton:SetLargeButton(enabled)
	self.isMainButton = enabled;
	if enabled then
		local cooldown = self.cooldown;
		local r, g, b = CPAPI.GetClassColor()
		cooldown:SetEdgeTexture(CPAPI.GetAsset('Textures\\Cooldown\\Edge'))
		cooldown:SetBlingTexture(CPAPI.GetAsset('Textures\\Cooldown\\Bling'))
		cooldown:SetSwipeTexture(CPAPI.GetAsset('Textures\\Cooldown\\Swipe'))
		cooldown:SetSwipeColor(r, g, b)
	end
end

function CPActionButton:SetRotation(rotation)
	self.rotation = rotation;
end

function CPActionButton:SetPreventSkinning(enabled)
	self.MasqueSkinned = enabled; -- A hack for LAB to not skin this button.
end

function CPActionButton:Initialize()
	self:SetAttribute(CPAPI.SkipHotkeyRender, true)
	self:SetLargeButton(self:IsLargeButton())
end