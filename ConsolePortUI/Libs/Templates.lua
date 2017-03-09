local _, UI = ...
----------------------------------
local TEMPLATES, MIXINS
----------------------------------
local _, class = UnitClass("player")
local cc = RAID_CLASS_COLORS[class]
local db = UI.Data
local mx = UI.Utils.Mixin
----------------------------------

--- Overwrites the region with a predefined template.
-- @param 	region 	: Type to apply template to.
-- @param 	preset 	: Name of the preset to be applied.
-- @return 	region 	: Returns the altered object.
function UI:ApplyTemplate(region, preset, config)
	local objectType = region.GetObjectType and region:GetObjectType()
	if not objectType then
		error("Usage: UI:ApplyTemplate(region, preset)", 2)
	end
	local presetFunc = TEMPLATES[objectType][preset]
	if not presetFunc then
		error("Usage: UI:ApplyTemplate(region, preset)", 2)
	end
	return presetFunc(region, config)
end


--- Applies mixin(s) either from template or table.
-- @param 	region 	: Region to apply mixin to.
-- @param 	mixer 	: Mixer function to be used.
-- @param 	... 	: Objects to mix in, or template identifier(s).
-- @return 	region 	: Returns the altered object.
function UI:ApplyMixin(region, mixer, ...)
	local mixins = {...}
	local mixer = mixer or mx
	for _, mixin in pairs(mixins) do
		if type(mixin) == "string" then
			mixer(region, MIXINS[mixin] or _G[mixin])
		else
			mixer(region, mixin)
		end
	end
	return region
end

-- ----------------------------------
-- TEMPLATES = {
-- ----------------------------------
-- 	Texture = {
-- 	------------------------------		
-- 		ClassCrest = function(region)
-- 			UI.Media:SetTexture(region, "CB2_"..class)
-- 			region:SetSize(128, 128)
-- 			region:SetPoint("TOPLEFT", 32, -32)
-- 			return region
-- 		end,
-- 		ClassGradient = function(region)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("TOPLEFT", 16, -16)
-- 			region:SetPoint("BOTTOMRIGHT", -16, 16)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Gradient")
-- 			region:SetGradientAlpha("VERTICAL", cc.r, cc.g, cc.b, 1, cc.r, cc.g, cc.b, 0)
-- 			return region
-- 		end,
-- 		ClassGradient2 = function(region)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("TOPLEFT", 16, -16)
-- 			region:SetPoint("BOTTOMRIGHT", -16, 16)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Gradient")
-- 			region:SetGradientAlpha("HORIZONTAL", cc.r, cc.g, cc.b, 1, cc.r, cc.g, cc.b, 1)
-- 			return region
-- 		end,
-- 		GlassButtonNormal = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 			region:SetSize(128, 128)
-- 			return region
-- 		end,
-- 		LineBottom = function(region)
-- 			region:SetTexture("Interface\\LevelUp\\MinorTalents")
-- 			region:SetTexCoord(0/512, 418/512, 406/512, 408/512)
-- 			region:SetHeight(2)
-- 			region:SetVertTile(false)
-- 			region:SetHorizTile(false)
-- 			return region
-- 		end,		
-- 		LineTop = function(region)
-- 			region:SetTexture("Interface\\LevelUp\\MinorTalents")
-- 			region:SetSize(418, 1)
-- 			region:SetVertTile(false)
-- 			region:SetHorizTile(false)
-- 			region:SetTexCoord(0, 418/512, 341/512, 342/512)
-- 			return region
-- 		end,
-- 		ObjectiveBottom = function(region)
-- 			region:SetTexture("Interface\\QUESTFRAME\\BonusObjectives")
-- 			region:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 1, 1, 1, 0)
-- 			region:SetTexCoord(0/512, 420/512, 217/512, 262/512)
-- 			region:SetSize(420, 46)
-- 			region:SetPoint("BOTTOM", 0, -16)
-- 			return region
-- 		end,
-- 		QuestBG = function(region)
-- 			region:SetTexture("Interface\\\QUESTFRAME\\QuestMapLogAtlas")
-- 			region:SetTexCoord(291/1024, 576/1024, 0/1024, 400/1024)
-- 			region:SetPoint("TOPLEFT", 16, -16)
-- 			region:SetPoint("BOTTOMRIGHT", -16, 16)
-- 			region:SetBlendMode("ADD")
-- 			region:SetAlpha(0.35)
-- 			return region
-- 		end,
-- 		TL = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
-- 			region:SetTexCoord(132/1024, 198/1024, 16/1024, 84/1024)
-- 			region:SetDrawLayer("ARTWORK", nil, -7)
-- 			region:SetSize(66, 68)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("TOPLEFT", 8, -10)
-- 			return region
-- 		end,
-- 		TR = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
-- 			region:SetTexCoord(198/1024, 264/1024, 16/1024, 84/1024)
-- 			region:SetDrawLayer("ARTWORK", nil, -7)
-- 			region:SetSize(66, 68)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("TOPRIGHT", -9, -10)
-- 			return region
-- 		end,
-- 		BL = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
-- 			region:SetTexCoord(0/1024, 66/1024, 16/1024, 84/1024)
-- 			region:SetDrawLayer("ARTWORK", nil, -7)
-- 			region:SetSize(66, 68)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("BOTTOMLEFT", 8, 10)
-- 			return region
-- 		end,
-- 		BR = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
-- 			region:SetTexCoord(66/1024, 132/1024, 16/1024, 84/1024)
-- 			region:SetDrawLayer("ARTWORK", nil, -7)
-- 			region:SetSize(66, 68)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("BOTTOMRIGHT", -9, 10)
-- 			return region
-- 		end,
-- 		LB = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
-- 			region:SetTexCoord(0/1024, 16/1024, 420/1024, 16/1024, 0, 1/1024, 420/1024, 1/1024)
-- 			region:SetSize(15, 420)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("LEFT", 4, 0)
-- 			return region
-- 		end,
-- 		RB = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
-- 			region:SetTexCoord(0, 1/1024, 420/1024, 1/1024, 0/1024, 16/1024, 420/1024, 16/1024)
-- 			region:SetSize(15, 420)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("RIGHT", -4, 0)
-- 			return region
-- 		end,
-- 		Tint = function(region)
-- 			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\BoxTint")
-- 			region:SetPoint("TOPLEFT", 16, -16)
-- 			region:SetPoint("BOTTOMRIGHT", region:GetParent(), "RIGHT", -16, 0)
-- 			region:SetBlendMode("ADD")
-- 			region:SetAlpha(0.75)
-- 			return region
-- 		end,
-- 	},
-- 	------------------------------
-- 	Frame = {
-- 	------------------------------
-- 		Window = function(region, ...)
-- 			region = UI:BuildWireframe(region, {
-- 				Tint = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"BACKGROUND", nil, 3},
-- 					Preset 	= "Tint",
-- 				},
-- 				TopBorder = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "LineTop",
-- 					Point1 	= {"BOTTOMLEFT", region, "TOPLEFT", 0, -16},
-- 					Point2 	= {"BOTTOMRIGHT", region, "TOPRIGHT", 0, -16},
-- 				},
-- 				BottomBorder = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "LineTop",
-- 					Point1 	= {"TOPLEFT", region, "BOTTOMLEFT", 0, 16},
-- 					Point2 	= {"TOPRIGHT", region, "BOTTOMRIGHT", 0, 16},
-- 				},
-- 				TopLeft = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "TL",
-- 				},
-- 				TopRight = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "TR",
-- 				},
-- 				BottomLeft = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "BL",
-- 				},
-- 				BottomRight = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "BR",
-- 				},
-- 				RightBorder = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "RB",
-- 				},
-- 				LeftBorder = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "LB",
-- 				},
-- 			})
-- 			region:SetBackdrop(db.Atlas.Backdrops.Full)
-- 			return region
-- 		end,
-- 		TalentUI = function(region, ...)
-- 			region = TEMPLATES.Frame.Window(region, ...)
-- 			region = UI:BuildWireframe(region, {
-- 				Gradient = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"BACKGROUND", nil, 2},
-- 					Preset 	= "ClassGradient",
-- 				},
-- 				CrestModel = {
-- 					Type 	= "PlayerModel",
-- 					Setup 	= {},
-- 					Preset 	= "ClassCrest",
-- 				},
-- 				CrestFrame = {
-- 					Type 	= "Texture",
-- 					Setup 	= {"ARTWORK"},
-- 					Preset 	= "ClassCrest",
-- 				},
-- 				SmokeBG = {
-- 					Type 	= "PlayerModel",
-- 					Setup 	= {},
-- 					Preset 	= "SmokeBG",
-- 				},
-- 			})
-- 			return region
-- 		end,
-- 		ClassCrest = function(region, ...)
-- 			region:SetSize(128, 128)
-- 			region:SetBackdrop({bgFile = [[Interface\AddOns\ConsolePortUI\Media\Textures\Crests\]] .. class})
-- 			region:SetPoint("TOPLEFT", 16, -16)
-- 			region:SetFrameLevel(region:GetParent():GetFrameLevel() + 2)
-- 			return region
-- 		end,
-- 	},
-- 	------------------------------
-- 	PlayerModel = {
-- 	------------------------------
-- 		SmokeBG = function(region, ...)
-- 			region:SetFrameLevel(2)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("TOPLEFT", 16, -16)
-- 			region:SetPoint("BOTTOMRIGHT", -16, 16)
-- 			region:SetAlpha(0.5)
-- 			region:SetDisplayInfo(43022)
-- 			region:SetCamDistanceScale(8)
-- 			region:SetLight(true, false, 0, 0, 120, 1, cc.r, cc.g, cc.b, 100, cc.r, cc.g, cc.b)
-- 			region:SetScript("OnShow", function(self)
-- 				self:SetCamDistanceScale(20)
-- 			end)
-- 			region:Hide()
-- 			region:Show()
-- 			return region
-- 		end,
-- 		ClassCrest = function(region, ...)
-- 			region:SetFrameLevel(1)
-- 			region:ClearAllPoints()
-- 			region:SetPoint("TOPLEFT", -16, 16)
-- 			region:SetDisplayInfo(9510)
-- 			region:SetSize(350, 350)
-- 			region:SetAlpha(1)
-- 			-- filter out red saturation
-- 			local red, green, blue = (cc.r == 1 and 0.5 or cc.r), cc.g, cc.b
-- 			region:SetLight(true, false, 0, 0, 120, 1, red - (red^2), green, blue, 100, red - (red^2), green, blue)
-- 			region:SetScript("OnShow", function(self)
-- 				self:SetCamDistanceScale(2)
-- 				self:SetPosition(0, -0.25, 1.25)
-- 			end)
-- 			region:Hide()
-- 			region:Show()
-- 			return region
-- 		end,
-- 	},
-- }---------------------------------
MIXINS = {
----------------------------------
	ScaleOnFocus = {
		ScaleUpdate = function(self)
			local scale = self.targetScale
			local current = self:GetScale()
			local delta = scale > current and 0.025 or -0.025
			if abs(current - scale) < 0.05 then
				self:SetScale(scale)
				self:SetScript('OnUpdate', self.oldScript)
			else
				self:SetScale( current + delta )
			end
		end,
		ScaleTo = function(self, scale)
			local oldScript = self:GetScript('OnUpdate')
			self.targetScale = scale
			if oldScript and oldScript ~= self.ScaleUpdate then
				self.oldScript = oldScript
				self:HookScript('OnUpdate', self.ScaleUpdate)
			else
				self.oldScript = nil
				self:SetScript('OnUpdate', self.ScaleUpdate)
			end
		end,
		OnEnter = function(self)
			self:ScaleTo(self.enterScale or 1.1)
			if self.Hilite then
				db.UIFrameFadeIn(self.Hilite, 0.35, self.Hilite:GetAlpha(), 1)
			end
		end,
		OnLeave = function(self)
			self:ScaleTo(self.normalScale or 1)
			if self.Hilite then
				db.UIFrameFadeOut(self.Hilite, 0.2, self.Hilite:GetAlpha(), 0)
			end
		end,
		OnHide = function(self)
			self:SetScript('OnUpdate', nil)
			self:SetScale(self.normalScale or 1)
			if self.Hilite then
				self.Hilite:SetAlpha(0)
			end
		end,
	},
	AdjustToChildren = {
		IterateChildren = function(self)
			local regions = {self:GetChildren()}
			if not self.ignoreRegions then
				for _, v in pairs({self:GetRegions()}) do
					regions[#regions + 1] = v
				end
			end
			return pairs(regions)
		end,
		GetAdjustableChildren = function(self)
			local adjustable = {}
			for _, child in self:IterateChildren() do
				if child.AdjustToChildren then
					adjustable[#adjustable + 1] = child
				end
			end
			return pairs(adjustable)
		end,
		AdjustToChildren = function(self)
			self:SetSize(1, 1)
			for _, child in self:GetAdjustableChildren() do
				child:AdjustToChildren()
			end
			local top, bottom, left, right
			for _, child in self:IterateChildren() do
				if child:IsShown() then
					local childTop, childBottom = child:GetTop(), child:GetBottom()
					local childLeft, childRight = child:GetLeft(), child:GetRight()
					if (childTop) and (not top or childTop > top) then
						top = childTop
					end
					if (childBottom) and (not bottom or childBottom < bottom) then
						bottom = childBottom
					end
					if (childLeft) and (not left or childLeft < left) then
						left = childLeft
					end
					if (childRight) and (not right or childRight > right) then
						right = childRight
					end
				end
			end
			if top and bottom then
				self:SetHeight(abs( top - bottom ))
			end
			if left and right then
				self:SetWidth(abs( right - left ))
			end
			return self:GetSize()
		end,
	},
}
----------------------------------