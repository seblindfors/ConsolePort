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
		env.cfg.showbuttons = value;
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
		env:SetArtUnderlay(cfg.showart or cfg.flashart, cfg.flashart)
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

---------------------------------------------------------------
-- Set up micro button bar
---------------------------------------------------------------
local Menu = MicroButtonAndBagsBar;
if not Menu then Bar.MoveMicroButtons = nop; return end
local fadeEnabled;

local function OnEnter(self)
	if fadeEnabled then
		db.Alpha.FadeIn(Menu, .5, Menu:GetAlpha(), 1)
	end
end

local function OnLeave(self)
	if fadeEnabled and not Menu:IsMouseOver() then
		db.Alpha.FadeOut(Menu, .5, Menu:GetAlpha(), 0)
	end
end

Menu:HookScript('OnEnter', OnEnter)
Menu:HookScript('OnLeave', OnLeave)

for _, button in pairs(MICRO_BUTTONS) do
	local widget = _G[button]
	widget:HookScript('OnEnter', OnEnter)
	widget:HookScript('OnLeave', OnLeave)
end

local UpdateMicroButtonsParent = UpdateMicroButtonsParent;
local function MoveMicroButtons(parent)
	if env:Get('disablemicromenu') or (parent and parent:IsShown()) then
		return
	end
	UpdateMicroButtonsParent(Menu)
end

hooksecurefunc('UpdateMicroButtonsParent', MoveMicroButtons)

local oldParent;
function Bar:MoveMicroButtons()
	if env:Get('disablemicromenu') then
		if oldParent then
			Menu:SetParent(oldParent)
			Menu:SetAlpha(1)
			oldParent, fadeEnabled = nil, nil;
		end
		return
	end

	if not oldParent then
		oldParent = Menu:GetParent()
	end
	fadeEnabled = true;
	Menu:SetAlpha(0)
	Menu:SetParent(UIParent)
	UpdateMicroButtonsParent(Menu)
end