local UI, _, L = ConsolePortUI, ...
local db = ConsolePort:GetData()
local Button, Header  = {}, {}
L.Button = Button
L.Header = Header

function Button:OnEnter()
	self:LockHighlight()
	db.UIFrameFadeIn(self.Hilite, 0.15, self.Hilite:GetAlpha(), 1)
end

function Button:OnLeave()
	self:UnlockHighlight()
	db.UIFrameFadeOut(self.Hilite, 0.2, self.Hilite:GetAlpha(), 0)
end

function Button:OnHide()
	self:OnLeave()
	db.UIFrameFadeOut(self, 0.1, self.Hilite:GetAlpha(), 0)
end

function Button:OnShow()
	self:OnLeave()
	self:Animate()
end

function Button:Animate()
	local id = self:GetID() or 1
	C_Timer.After(id * 0.01, function()
		db.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end)
end


function Button:OnLoad()
	self.Overlay = CreateFrame('Frame', '$parentOverlay', self)
	self.Hilite = CreateFrame('Frame', '$parentHilite', self)
	self.Label = self:CreateFontString('$parentLabel', 'ARTWORK', 'Game12Font')
	self.Icon = self:CreateTexture('$parentIcon', 'ARTWORK')
	self.Mask = self:CreateTexture('$parentIconMask', 'OVERLAY')
	self.HighlightTexture = self:CreateTexture('$parentHighlightTexture', 'BORDER', nil, 7)
	self.HighlightTexture:SetTexture('Interface\\PVPFrame\\PvPMegaQueue')
	self.HighlightTexture:SetPoint('TOPLEFT', 0, -4)
	self.HighlightTexture:SetPoint('BOTTOMRIGHT', 0, 4)
	self.HighlightTexture:SetTexCoord(0.00195313, 0.63867188, 0.70703125, 0.76757813)
	self:SetHighlightTexture(self.HighlightTexture)
	self.Icon:SetSize(36, 36)
	self.Icon:SetPoint('LEFT', 12, 0)
	if not self.NoMask then
		self.Icon:SetMask('Interface\\Minimap\\UI-Minimap-Background')
	end
	self.Icon:SetTexture(self.Img)
	self.Mask:SetTexture()
	self.Mask:SetAllPoints(self.Icon)
	self.Mask:SetTexture('Interface\\AddOns\\ConsolePortUI\\Media\\Textures\\Button\\Icon_Mask32')
	self.Label:SetJustifyH('LEFT')
	self:SetFontString(self.Label)
	self.Overlay:SetAllPoints()
	self.Hilite:SetAllPoints()
	self.Hilite:SetAlpha(0)
	self.Label:SetPoint('LEFT', 54, 0)
	self.Label:SetWidth(250)
	self:SetSize(230, 54)
	UI.Media:SetBackdrop(self.Overlay, 'GOSSIP_NORMAL')
	UI.Media:SetBackdrop(self.Hilite, 'GOSSIP_HILITE')
	UI.Media:SetBackdrop(self, 'GOSSIP_BG')
	self:SetText(self.Desc)
end