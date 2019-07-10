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
			self:OnEnter()
		elseif IsControlKeyDown() and not InCombatLockdown() then
			Bar:ClearAllPoints()
			Bar:SetPoint('BOTTOM', UIParent, 0, 0)
		end
	end
end

function Eye:OnEnter()
	local texture_esc = '|T%s:24:24:0:0|t'
	self.tooltipText = 	L.EYE_HEADER:format(ab.cfg.lock and L.EYE_LOCKED or L.EYE_UNLOCKED) .. '\n' ..
						L.EYE_LEFTCLICK:format(texture_esc:format(db.ICONS.CP_T_L3)) .. '\n' ..
						L.EYE_RIGHTCLICK:format(texture_esc:format(db.ICONS.CP_T_R3)) .. '\n' ..
						L.EYE_LEFTCLICK_SHIFT:format(texture_esc:format(db.ICONS.CP_M1), texture_esc:format(db.ICONS.CP_T_L3)) .. '\n' ..
						L.EYE_LEFTCLICK_CTRL:format(texture_esc:format(db.ICONS.CP_M2), texture_esc:format(db.ICONS.CP_T_L3))
	if ab.cfg.mousewheel then
		self.tooltipText = self.tooltipText .. '\n' .. L.EYE_SCROLL .. '\n' .. L.EYE_SCROLL_SHIFT
	end
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(self.tooltipText)
	GameTooltip:Show()
end

function Eye:OnLeave()
	GameTooltip:Hide()
end

Eye:SetScript('OnClick', Eye.OnClick)
Eye:SetScript('OnEnter', Eye.OnEnter)
Eye:SetScript('OnLeave', Eye.OnLeave)
Eye:SetScript('OnAttributeChanged', Eye.OnAttributeChanged)

Bar:WrapScript(Eye, 'OnClick', [[
	if button == 'LeftButton' and bar:GetAttribute('state') == '' then
		local showhide = not self:GetAttribute('showbuttons')
		self:SetAttribute('showbuttons', showhide)
		control:ChildUpdate('hover', showhide)
	end
]])

---------------------------------------------------------------
-- Menu button
---------------------------------------------------------------

function Menu:OnClick(button) 
	if not InCombatLockdown() then 
		if button == 'LeftButton' then
			ToggleFrame(GameMenuFrame)
		else
			self:ClearAllPoints()
			self:SetPoint('CENTER', 0, -20)
		end
	end 
end
function Menu:OnShow() Eye:Show() Bag:Show() end
function Menu:OnHide() Eye:Hide() Bag:Hide() end

Menu:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
Menu:HookScript('OnClick', Menu.OnClick)
Menu:HookScript('OnShow', Menu.OnShow)
Menu:HookScript('OnHide', Menu.OnHide)
Menu:RegisterForDrag('LeftButton')
Menu:SetScript('OnDragStart', function(self)
	if not InCombatLockdown() and not ab.cfg.lock then
		self:StartMoving()
	end
end)
Menu:SetScript('OnDragStop', Menu.StopMovingOrSizing)
Menu:SetNormalTexture(ab.data.TEXTURE.CP_X_CENTER)

Menu.timer = 0
Menu.updateInterval = 1
Menu.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, 'TOGGLEGAMEMENU')
Menu.newbieText = NEWBIE_TOOLTIP_MAINMENU

function Menu:ShowPerformance(elapsed)
	self.timer = self.timer + elapsed
	if self.timer > self.updateInterval then
		MainMenuBarPerformanceBarFrame_OnEnter(self)
		self.timer = 0
	end
end

Menu:SetScript('OnEnter', function(self)
	local key, mod = ConsolePort:GetCurrentBindingOwner('TOGGLEGAMEMENU')
	if key and mod then
		local mods = {
			[''] = '',
			['SHIFT-'] = BINDING_NAME_CP_M1,
			['CTRL-'] = BINDING_NAME_CP_M2,
			['CTRL-SHIFT-'] = BINDING_NAME_CP_M1..BINDING_NAME_CP_M2,
		}
		self.tooltipText = 
				mods[mod] .. _G['BINDING_NAME_' .. key] 
				.. '  |c' .. RAID_CLASS_COLORS[select(2, UnitClass('player'))].colorStr
				.. MAINMENU_BUTTON
	else
		self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, 'TOGGLEGAMEMENU')
	end
	MainMenuBarPerformanceBarFrame_OnEnter(self)
	self.timer = 0
	self:SetScript('OnUpdate', self.ShowPerformance)
end)

Menu:SetScript('OnLeave', function(self)
	self:SetScript('OnUpdate', nil)
	GameTooltip:Hide()
end)


-------------------------------------------
--- Bags
-------------------------------------------

Bar.Elements.Bags = {
	MainMenuBarBackpackButton,
	CharacterBag0Slot,
	CharacterBag1Slot,
	CharacterBag2Slot,
	CharacterBag3Slot,
}

for i, bag in ipairs(Bar.Elements.Bags) do
	bag:SetParent(Bag)
	bag:Hide()
	bag:SetSize(36,36)
	bag:ClearAllPoints()
	bag:SetPoint('RIGHT', 40 * (i), 0)
end

Bag:SetScript('OnClick', function(self)
	if IsModifiedClick('OPENALLBAGS') then
		ToggleAllBags()
	else
		for _, bag in pairs(Bar.Elements.Bags) do
			bag:SetShown(not bag:IsShown())
		end
	end
end)

MainMenuBarBackpackButtonCount:SetParent(Bag)
MainMenuBarBackpackButtonCount:ClearAllPoints()
MainMenuBarBackpackButtonCount:SetPoint('BOTTOMRIGHT')