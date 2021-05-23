local _, env = ...;

CPMenuButtonMixin = CreateFromMixins(CPHintFocusMixin);

function CPMenuButtonMixin:OnLoad()
	self:SetBackdrop({
		bgFile   = CPAPI.GetAsset('Textures\\Frame\\Backdrop_Gossip.blp');
		edgeFile = CPAPI.GetAsset('Textures\\Frame\\Edge_Gossip_BG.blp');
		edgeSize = 8;
		insets   = {left = 2, right = 2, top = 8, bottom = 8};
	})
	self.Overlay:SetBackdrop({
		edgeFile = CPAPI.GetAsset('Textures\\Frame\\Edge_Gossip_Normal.blp');
		edgeSize = 8;
		insets   = {left = 5, right = 5, top = -10, bottom = 7};	
	})
	self.Hilite:SetBackdrop({
		edgeFile = CPAPI.GetAsset('Textures\\Frame\\Edge_Gossip_Hilite.blp');
		edgeSize = 8;
		insets   = {left = 5, right = 5, top = 5, bottom = 6};	
	})
	self.Overlay:SetFrameLevel(self.Overlay:GetFrameLevel() + 1)
	self:SetHintHandle(ConsolePortUIHandle)
	self:SetHintTriggers(true)
--	self:SetHint('CROSS', ACCEPT)
end

function CPMenuButtonMixin:OnHide()
	self:OnLeave()
	env.db.Alpha.FadeOut(self, 0.1, self:GetAlpha(), 0)
end

function CPMenuButtonMixin:OnShow()
	self:Animate()
end

function CPMenuButtonMixin:Animate()
	C_Timer.After((self:GetID() or 1) * 0.01, function()
		env.db.Alpha.FadeIn(self, 0.1, self:GetAlpha(), 1)
	end)
end

function CPMenuButtonMixin:Image(texture)
	self.Icon:SetTexture(('Interface\\Icons\\%s'):format(texture))
end

function CPMenuButtonMixin:CustomImage(texture)
	self.Icon:SetTexture(texture)
end

function CPMenuButtonMixin:OnEnter()
	self:LockHighlight()

	if self:GetAttribute('hintOnEnter') then
		self:ShowHints()
	end
	if self.Hilite.flashTimer then
		env.db.Alpha.Stop(self.Hilite, self.Hilite:GetAlpha())
	end
	env.db.Alpha.FadeIn(self.Hilite, 0.15, self.Hilite:GetAlpha(), 1)
end

function CPMenuButtonMixin:OnLeave()
	self:UnlockHighlight()

	if self:GetAttribute('hintOnLeave') then
		self:HideHints()
	end
	env.db.Alpha.FadeOut(self.Hilite, 0.2, self.Hilite:GetAlpha(), 0)
end

function CPMenuButtonMixin:SetPulse(enabled)
	if enabled then
		env.db.Alpha.Flash(self.Hilite, 0.5, 0.5, -1, true, 0.2, 0.1)
	else
		env.db.Alpha.Stop(self.Hilite, 0)
	end
end