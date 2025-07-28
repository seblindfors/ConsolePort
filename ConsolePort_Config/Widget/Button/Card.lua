local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
CPCardBaseMixin = CreateFromMixins(CPStateButtonMixin); do
---------------------------------------------------------------
	local Flags = CPAPI.CreateFlags('Disabled', 'Over', 'Selected')
	local Decor = {
		[Flags.Disabled] = {
			Highlight         = false;
			Selected          = false;
			SelectedHighlight = false;
		};
		[Flags.Over] = {
			Highlight         = true;
			Selected          = false;
			SelectedHighlight = false;
		};
		[Flags.Selected] = {
			Highlight         = false;
			Selected          = true;
			SelectedHighlight = false;
		};
		[Flags.Over + Flags.Selected] = {
			Highlight         = false;
			Selected          = true;
			SelectedHighlight = true;
		};
		{ -- Default
			Highlight         = false;
			Selected          = false;
			SelectedHighlight = false;
		};
	};
	CPCardBaseMixin.Flags, CPCardBaseMixin.Decor = Flags, Decor;
	CPCardBaseMixin:DesaturateIfDisabled()
end

local ToggleVisible = db.Alpha.Fader.Toggle;

function CPCardBaseMixin:OnClick()
	self:OnButtonStateChanged()
end

function CPCardBaseMixin:OnMouseDown()
	ButtonStateBehaviorMixin.OnMouseDown(self)
	ToggleVisible(self.InnerContent.Glow, 0.25, true)
end

function CPCardBaseMixin:OnMouseUp()
	ButtonStateBehaviorMixin.OnMouseUp(self)
	ToggleVisible(self.InnerContent.Glow, 0.25, false)
end

function CPCardBaseMixin:Flash()
	ToggleVisible(self.InnerContent.Glow, 0.25, true)
	C_Timer.After(0.25, function()
		ToggleVisible(self.InnerContent.Glow, 0.25, false)
	end)
end

function CPCardBaseMixin:OnButtonStateChanged(noAnimation)
	local state = self.Flags({
		Disabled = not self:IsEnabled(),
		Over     = self:IsOver(),
		Selected = self:GetChecked(),
	}, self.Decor)
	for texture, show in pairs(state) do
		self.InnerContent[texture]:SetShown(show)
	end
end

---------------------------------------------------------------
CPCardSmallMixin = CreateFromMixins(CPCardBaseMixin);
---------------------------------------------------------------

function CPCardSmallMixin:OnLoad()
	CPCardBaseMixin.OnLoad(self)
	for _, region in ipairs({self.InnerContent:GetRegions()}) do
		if ( region.sliceMode ) then
			region:SetScale(.25)
		end
	end
	self.InnerContent.Selected:SetPoint('TOPLEFT', -18, 20)
	self.InnerContent.Selected:SetPoint('BOTTOMRIGHT', 18, -20)
	self.InnerContent.SelectedHighlight:SetPoint('TOPLEFT', 18, -20)
	self.InnerContent.SelectedHighlight:SetPoint('BOTTOMRIGHT', -18, 20)
end

---------------------------------------------------------------
CPCardIconMixin = CreateFromMixins(CPCardBaseMixin); do
---------------------------------------------------------------
	local Flags = CPCardBaseMixin.Flags;
	local IconAtlas = {
		[Flags.Selected] = 'auctionhouse-itemicon-border-artifact';
		'auctionhouse-itemicon-border-gray'; -- Default
	};

	function CPCardIconMixin:OnButtonStateChanged()
		CPCardBaseMixin.OnButtonStateChanged(self)
		local state = self.Flags({
			Selected = self:GetChecked(),
		}, IconAtlas)
		self.Border:SetAtlas(state)
	end
end

---------------------------------------------------------------
CPCardAddMixin = CreateFromMixins(CPCardBaseMixin);
---------------------------------------------------------------

function CPCardAddMixin:OnLoad()
	for texture, newAtlas in pairs({
		Backdrop  = 'glues-characterselect-card-empty-hover';
		Highlight = 'glues-characterselect-card-empty-hover';
		Selected  = 'glues-characterselect-card-glow-fx';
		Glow      = 'glues-characterselect-card-glow-swap';
		SelectedHighlight = 'glues-characterselect-card-fx-spreadb';
	}) do
		self.InnerContent[texture]:SwapAtlas(newAtlas)
	end
	self.InnerContent.Selected:SetPoint('TOPLEFT', -16, 16)
	self.InnerContent.Selected:SetPoint('BOTTOMRIGHT', 16, -16)
	self.InnerContent.SelectedHighlight:SetPoint('TOPLEFT', 16, -16)
	self.InnerContent.SelectedHighlight:SetPoint('BOTTOMRIGHT', -16, 16)
	self:SetDisplacedRegions(0, -1, self.AddBackground, self.AddHighlight, self.AddIcon)
end

function CPCardAddMixin:OnButtonStateChanged()
	CPCardBaseMixin.OnButtonStateChanged(self)
	local alpha = (self:IsOver() or self:GetChecked()) and 1 or 0;
	self.AddBackground:SetAlpha(alpha)
	self.AddIcon:SetAlpha(alpha)
	self.AddHighlight:SetAlpha(alpha)
end

function CPCardAddMixin:OnSizeChanged(_, height)
	local addBGSize = height / 95 * 78;
	local addHLSize = height / 95 * 125;
	self.AddBackground:SetSize(addBGSize, addBGSize)
	self.AddHighlight:SetSize(addBGSize, addBGSize)
	self.AddIcon:SetSize(addHLSize, addHLSize)
end