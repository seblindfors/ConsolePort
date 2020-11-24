local name, env = ...;
local Bar, db = env.bar, env.db;
---------------------------------------------------------------

Bar.CoverArt.Flash = function(self)
	if self.flashOnProc and not self:IsShown() then
		self:Show()

		db.Alpha.FadeIn(self, 0.2, 0, 1, {
			finishedFunc = function()
				db.Alpha.FadeOut(self, 1.5, 1, 0, {
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
-- Set up eye button
---------------------------------------------------------------
local Eye = Bar.Eye
---------------------------------------------------------------

Eye:RegisterForClicks('AnyUp')
Eye:SetAttribute('showbuttons', false)
Eye.Texture = Eye:CreateTexture(nil, 'OVERLAY')
Eye.Texture:SetPoint('CENTER', 0, 0)
Eye.Texture:SetSize((46 * 0.9), (24 * 0.9))
Eye.Texture:SetTexture('Interface\\AddOns\\'..name..'\\Textures\\Hide')


function Eye:OnAttributeChanged(attribute, value)
	if attribute == 'showbuttons' then
		env.cfg.showbuttons = value
		if value == true then
			self.Texture:SetTexture('Interface\\AddOns\\'..name..'\\Textures\\Show')
		else
			self.Texture:SetTexture('Interface\\AddOns\\'..name..'\\Textures\\Hide')
		end
	end
end

function Eye:OnClick(button)
	local cfg = env.cfg
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

local Menu = MicroButtonAndBagsBar;
if not Menu then
	Bar.MoveMicroButtons = nop;
	return
end
---------------------------------------------------------------
-- Set up micro button bar
---------------------------------------------------------------
local MicroButtons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	GuildMicroButton,
	LFDMicroButton,
	CollectionsMicroButton,
	EJMicroButton,
	StoreMicroButton,
	MainMenuMicroButton,
	HelpMicroButton,
}
---------------------------------------------------------------
Menu:SetParent(UIParent)

local function OnEnter(self)
	db.Alpha.FadeIn(Menu, .5, Menu:GetAlpha(), 1)
end

local function OnLeave(self)
	if not Menu:IsMouseOver() then
		db.Alpha.FadeOut(Menu, .5, Menu:GetAlpha(), 0)
	end
end

function Bar:MoveMicroButtons()
	for _, button in pairs(MicroButtons) do
		button:SetParent(MicroButtonAndBagsBar)
	end
end

Menu:HookScript('OnEnter', OnEnter)
Menu:HookScript('OnLeave', OnLeave)
for _, button in pairs(MicroButtons) do
	button:HookScript('OnEnter', OnEnter)
	button:HookScript('OnLeave', OnLeave)
end

Menu:SetAlpha(0)
Bar:MoveMicroButtons()