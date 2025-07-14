local env, db, _, L = CPAPI.GetEnv(...);

---------------------------------------------------------------
local MenuFlyout = {};
---------------------------------------------------------------

function MenuFlyout:OnLoad()
	self:ToggleInversion(true)
	self:OnLeave()
	self:SetScript('OnMouseDown', nil)
end

function MenuFlyout:OnEnter()
	for _, line in ipairs(self.Hamburger) do
		line:SetAlpha(1)
	end
	self:SetBackgroundAlpha(1)
end

function MenuFlyout:OnLeave()
	for _, line in ipairs(self.Hamburger) do
		line:SetAlpha(0.75)
	end
	self:SetBackgroundAlpha(0.5)
end

function MenuFlyout:OnClick()
	if ConsolePort:IsCursorNode(self) then
		self:OnMouseDown_Intrinsic()
	end
end

function MenuFlyout:Populate(content)
	self:SetupMenu(function(dropdown, rootDescription)
		for _, item in ipairs(content) do
			if item.canShow() then
				rootDescription:CreateButton(item.name, function()
					dropdown:GetParent():SetContent(item)
				end)
			end
		end
	end)
end

---------------------------------------------------------------
-- Guide Panel
---------------------------------------------------------------
local Guide = env:CreatePanel({
	name    = GUIDE;
	content = {};
})

function Guide:OnLoad()
	CPAPI.Start(self)
	self.MenuFlyout = CreateFrame('DropdownButton', nil, self, 'CPGuideMenuFlyout')
	self.MenuFlyout:SetPoint('TOP', self.navButton, 'BOTTOM', 0, -4)
	FrameUtil.SpecializeFrameWithMixins(self.MenuFlyout, MenuFlyout)
end

function Guide:OnShow()
	self:Render()
	self.MenuFlyout:Populate(self.content)
end

function Guide:OnHide()
	self:ClearContent()
end

function Guide:InitCanvas(canvas)
	self.canvas = canvas;
	self.canvasGetter = CPAPI.Static(canvas);
end

function Guide:Render()
	local canvas, newObj = self:GetCanvas(true)
	if newObj then
		self:InitCanvas(canvas)
	end
	canvas:Show()
	self:AutoSelectContent()
end

function Guide:AutoSelectContent()
	for _, content in ipairs(self.content) do
		if content.predicate() then
			return self:SetContent(content)
		end
	end
	return false;
end

function Guide:SetContent(content)
	self:ClearContent()
	self.resetter = content.resetter;
	content.initializer(self.canvas, self.canvasGetter);
	return true;
end

function Guide:ClearContent()
	if self.resetter then
		self.resetter(self.canvas);
		self.resetter = nil;
	end
end

function Guide:AddContent(name, predicate, initializer, resetter, canShow)
	tinsert(self.content, {
		name        = L(name);
		initializer = initializer;
		predicate   = predicate;
		resetter    = resetter or nop;
		canShow     = canShow or CPAPI.Static(true);
	})
end