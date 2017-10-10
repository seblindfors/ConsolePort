local UI, Tooltip, framePool, _, db = ConsolePortUI, {}, {}, ...

function Tooltip:OnShow()
	db.UIFrameFadeIn(self, 0.2, 0, 1)
	self:SetFrameLevel(6)
	self:SetScale(self.normalScale or 1)
	self.isActive = true
	self.Button:Show()
	self:SetCheckable(false)
end

function Tooltip:OnHide()
	self:SetCheckable(false)
	self:SetScale(self.normalScale or 1)
	self:ClearAllPoints()
	self:SetParent(UIParent)
	self.isActive = false
	self:OnLeave()
end

function Tooltip:Enter()
	self:SetFrameLevel(100)
--	self:SetScale(self.enterScale or 1)
	self:OnEnter()
end

function Tooltip:Leave()
	self:OnLeave()
--	self:SetScale(self.normalScale or 1)
	self:SetFrameLevel(6)
end

function Tooltip:Click()
	self.Button:Click()
	if self.isCheckable then
		self.Button:SetChecked(true)
	end
end

function Tooltip:SetChecked(checked)
	if self.isCheckable then
		self.Button:SetChecked(checked)
	end
end

function Tooltip:IsCheckable()
	return self.isCheckable
end

function Tooltip:SetCheckable(isCheckable)
	self.isCheckable = isCheckable
	self.Button:SetChecked(false)
	if isCheckable then
		self.Button.Normal:Show()
	else
		self.Button.Normal:Hide()
	end
end

function UI:GetTooltipFramePool() return pairs(framePool) end

function UI:GetTooltip()
	local tooltip
	for id, frame in self:GetTooltipFramePool() do
		if not frame.isActive then
			tooltip = frame
			break
		end
	end
	if not tooltip then
		local id = #framePool + 1
		tooltip = UI:CreateFrame('GameTooltip', 'ConsolePortUITooltip'..id, UIParent, 'GameTooltipTemplate', {
			shoppingTooltips = GameTooltip.shoppingTooltips,
			Mixin = {Tooltip, 'ScaleOnFocus'},
			{
				Hilite = {
					Type = 'Frame',
					Alpha = 0,
					Level = 1,
					Background = 'GOSSIP_HILITE',
					Fill = true,
				},
				Icon = {
					Type = 'Frame',
					Point = {'TOPRIGHT', 16, 10},
					Size = {70, 65},
					Level = 3,
					Scale = 0.75,
					{
						Border = {
							Type = 'Texture',
							Setup = {'OVERLAY'},
							Texture = 'Interface\\Spellbook\\Spellbook-Parts',
							Coords = {0.27734375, 0.00390625, 0.44140625, 0.69531250},
							Fill = true,
						},
						Texture = {
							Type = 'Texture',
							Setup = {'BACKGROUND'},
							Size = {34, 34},
							Point = {'CENTER', 2, 0},
						},
					},
				},
				Button = {
					Type = 'CheckButton',
					Fill = true,
					OnEnter = function(self) self:GetParent():Enter() end,
					OnLeave = function(self) self:GetParent():Leave() end,
					OnLoad = function(self)
						self:SetHighlightTexture(self.HilightTexture)
						self:SetNormalTexture(self.Normal)
						self:SetCheckedTexture(self.Checked)
						self.OnEnter = self:GetScript('OnEnter')
						self.OnLeave = self:GetScript('OnLeave')
					end,
					{
						HilightTexture = {
							Type = 'Texture',
							Texture = 'Interface\\PVPFrame\\PvPMegaQueue',
							Coords = {0.00195313, 0.63867188, 0.70703125, 0.76757813},
							Alpha = 0.25,
							Points = {
								{'TOPLEFT', 0, -4},
								{'BOTTOMRIGHT', 0, 4},
							},
						},
						Normal = {
							Type = 'Texture',
							Size = {12, 12},
							Texture = 'Interface\\Buttons\\UI-RadioButton',
							Coords = {0, 0.25, 0, 1},
							Point = {'BOTTOMRIGHT', -12, 12},
							Hide = true,
						},
						Checked = {
							Type = 'Texture',
							Texture = 'Interface\\Buttons\\UI-RadioButton',
							Coords = {0.25, 0.5, 0, 1},
							Size = {12, 12},
							Point = {'BOTTOMRIGHT', -12, 12},
							Vertex = {0, 1, 0},
						},
					},
				},
			},
		})
		UI:RemoveRegisteredFrame(tooltip)
		framePool[id] = tooltip
	end
	return tooltip
end