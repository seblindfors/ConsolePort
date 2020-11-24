local addOn, ab = ...
local db = ConsolePort:GetData()
local L = db.ACTIONBAR
local Bar = ab.bar
---------------------------------------------------------------

Bar.CoverArt.Flash = function(self)
	if self.flashOnProc and not self:IsShown() then
		self:Show()

		db.UIFrameFadeIn(self, 0.2, 0, 1, {
			finishedFunc = function()
				db.UIFrameFadeOut(self, 1.5, 1, 0, {
					finishedFunc = function()
						self:SetAlpha(1)
						self:Hide()
					end
				})
			end
		})
	end
end

---------------------------------------------------------------
-- Set up buttons on the bar.
---------------------------------------------------------------
local Eye, Menu, Bag = Bar.Eye, Bar.Menu, Bar.Bag
---------------------------------------------------------------

Eye:RegisterForClicks('AnyUp')
Eye:SetAttribute('showbuttons', false)
Eye.Texture = Eye:CreateTexture(nil, 'OVERLAY')
Eye.Texture:SetPoint('CENTER', 0, 0)
Eye.Texture:SetSize((46 * 0.9), (24 * 0.9))
Eye.Texture:SetTexture('Interface\\AddOns\\'..addOn..'\\Textures\\Hide')


function Eye:OnAttributeChanged(attribute, value)
	if attribute == 'showbuttons' then
		ab.cfg.showbuttons = value
		if value == true then
			self.Texture:SetTexture('Interface\\AddOns\\'..addOn..'\\Textures\\Show')
		else
			self.Texture:SetTexture('Interface\\AddOns\\'..addOn..'\\Textures\\Hide')
		end
	end
end

function Eye:OnClick(button)
	local cfg = ab.cfg
	if button == 'RightButton' then
		cfg.showart = not cfg.showart
		ab:SetArtUnderlay(cfg.showart or cfg.flashart, cfg.flashart)
	elseif button == 'LeftButton' then
		if IsShiftKeyDown() and not InCombatLockdown() then
			cfg.lock = not cfg.lock
			Bar:ToggleMovable(not cfg.lock, cfg.mousewheel)
		elseif IsControlKeyDown() and not InCombatLockdown() then
			Bar:ClearAllPoints()
			Bar:SetPoint('BOTTOM', UIParent, 0, 0)
		end
	end
end

Eye:SetScript('OnClick', Eye.OnClick)
Eye:SetScript('OnAttributeChanged', Eye.OnAttributeChanged)

Bar:WrapScript(Eye, 'OnClick', [[
	if button == 'LeftButton' and bar:GetAttribute('state') == '' then
		local showhide = not self:GetAttribute('showbuttons')
		self:SetAttribute('showbuttons', showhide)
		control:ChildUpdate('hover', showhide)
	end
]])