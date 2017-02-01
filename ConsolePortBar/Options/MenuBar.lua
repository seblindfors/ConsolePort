local addOn, ab = ...
local db = ConsolePort:GetData()
local L = db.ACTIONBAR
local Bar = ab.bar
---------------------------------------------------------------
-- Set up buttons on the bar.
---------------------------------------------------------------
local Eye = CreateFrame('Button', '$parentShowHideButtons', Bar, 'SecureActionButtonTemplate')
local Menu = CreateFrame('Button', '$parentShowHideMenu', Bar, 'SecureActionButtonTemplate')
local Bag = CreateFrame('Button', '$parentShowHideBags', Bar, 'SecureActionButtonTemplate')

Bar.Eye = Eye
Bar.Menu = Menu
Bar.Bag = Bag

Bar:SetBackdrop(backdrop)

for _, btn in pairs({Eye, Menu, Bag}) do
	btn:SetSize(40, 40)
	btn:SetHighlightTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\BigHilite')

	btn.Shadow = btn:CreateTexture('$parentShadow', 'OVERLAY', nil, 7)
	btn.Shadow:SetPoint('CENTER', 0, -5)
	btn.Shadow:SetSize((82/64) * 40, (82/64) * 40)
	btn.Shadow:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\BigShadow')
	btn.Shadow:SetAlpha(0.5)
end

---------------------------------------------------------------
---------------------------------------------------------------
Bar.BG = Bar:CreateTexture(nil, 'BACKGROUND')
Bar.BG:SetPoint('TOPLEFT', Bar, 'TOPLEFT', 16, -16)
Bar.BG:SetPoint('BOTTOMRIGHT', Bar, 'BOTTOMRIGHT', -16, 16)
Bar.BG:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight')
Bar.BG:SetBlendMode('ADD')

Bar.BottomLine = Bar:CreateTexture(nil, 'BORDER')
Bar.BottomLine:SetTexture('Interface\\LevelUp\\LevelUpTex')
Bar.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.013671875, 0.017578125)
Bar.BottomLine:SetHeight(1)
Bar.BottomLine:SetPoint('BOTTOMLEFT', 0, 16)
Bar.BottomLine:SetPoint('BOTTOMRIGHT', 0, 16)

Bar.CoverArt = Bar:CreateTexture(nil, 'BACKGROUND')
Bar.CoverArt:SetPoint('CENTER', 0, 74)
Bar.CoverArt:SetSize(768, 192)

---------------------------------------------------------------
---------------------------------------------------------------

---------------------------------------------------------------
-- Toggler for buttons and art
---------------------------------------------------------------

Eye:RegisterForClicks('AnyUp')
Eye:SetAttribute('showbuttons', false)
Eye:SetPoint('RIGHT', Menu, 'LEFT', -4, 0)
Eye.Texture = Eye:CreateTexture(nil, 'OVERLAY')
Eye.Texture:SetPoint('CENTER', 0, 0)
Eye.Texture:SetSize((46 * 0.9), (24 * 0.9))
Eye.Texture:SetTexture('Interface\\AddOns\\'..addOn..'\\Textures\\Hide') 
Eye:SetNormalTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Blank64')


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

function Eye:OnClick(button, down)
	if button == 'RightButton' then
		ab.cfg.showart = not ab.cfg.showart
		if ab.cfg.showart then
			local art, coords = ab:GetCover()
			if art and coords then
				Bar.CoverArt:SetTexture(art)
				Bar.CoverArt:SetTexCoord(unpack(coords))
			end
		end
		Bar.CoverArt:SetShown(ab.cfg.showart)
	elseif button == 'LeftButton' then
		if IsShiftKeyDown() then
			ab.cfg.lock = not ab.cfg.lock
			if ab.cfg.lock then
				Bar:SetMovable(false)
				Bar:SetScript('OnMouseDown', nil)
				Bar:SetScript('OnMouseUp', nil)
			else
				Bar:SetMovable(true)
				Bar:SetScript('OnMouseDown', Bar.StartMoving)
				Bar:SetScript('OnMouseUp', Bar.StopMovingOrSizing)
			end
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
						L.EYE_LEFTCLICK_CTRL:format(texture_esc:format(db.ICONS.CP_M2), texture_esc:format(db.ICONS.CP_T_L3)) .. '\n' ..
						L.EYE_SCROLL .. '\n' ..
						L.EYE_SCROLL_SHIFT
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
Menu:SetPoint('CENTER', 0, -20)
Menu:SetMovable(true)
Menu:SetClampedToScreen(true)
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

for i, bag in pairs(Bar.Elements.Bags) do
	bag:SetParent(Bag)
	bag:Hide()
	bag:SetSize(32,32)
	bag:ClearAllPoints()
	bag:SetPoint('RIGHT', 4 + ( 32 * (i)), 0)
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

Bag:SetPoint('LEFT', Menu, 'RIGHT', 4, 0)
Bag:SetSize(40, 40)
Bag:SetNormalTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Bag64')