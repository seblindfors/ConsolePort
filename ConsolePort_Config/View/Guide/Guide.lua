local env, db, _, L = CPAPI.GetEnv(...);

---------------------------------------------------------------
local MenuFlyout = {};
---------------------------------------------------------------

function MenuFlyout:OnLoad()
	self:ToggleInversion(true)
	self:OnLeave()
	self:SetScript('OnMouseDown', nil)
	self:SetFrameLevel(10)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
end

function MenuFlyout:OnSearch(text)
	self:SetShown(not text)
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
	name    = L'Guide';
	content = {};
})

function Guide:OnLoad()
	CPAPI.Start(self)
	self.MenuFlyout = CreateFrame('DropdownButton', nil, self, 'CPGuideMenuFlyout')
	self.MenuFlyout:SetPoint('TOP', self.navButton, 'BOTTOM', 0, -4)
	CPAPI.SpecializeOnce(self.MenuFlyout, MenuFlyout)
end

function Guide:OnShow()
	self:Render()
	self.MenuFlyout:Populate(self.content)
	self.MenuFlyout:Show()
end

function Guide:OnHide()
	self:ClearContent()
end

function Guide:OnDefaults()
	self.onDefaults(self.canvas)
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
	self.resetter   = content.resetter;
	self.onDefaults = content.onDefaults;
	content.initializer(self.canvas, self.canvasGetter);
	return true;
end

function Guide:ClearContent()
	if self.resetter then
		self.resetter(self.canvas);
		self.resetter = nil;
	end
end

function Guide:AddContent(name, predicate, initializer, resetter, canShow, onDefaults)
	tinsert(self.content, {
		name        = L(name);
		initializer = initializer;
		predicate   = predicate;
		resetter    = resetter or nop;
		canShow     = canShow or CPAPI.Static(true);
		onDefaults  = onDefaults or nop;
	})
end

---------------------------------------------------------------
-- Common
---------------------------------------------------------------
function Guide.CreateHeader(parent, width)
	local header = CreateFrame('Frame', nil, parent, 'CPPopupHeaderTemplate')
	header.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGBA())
	header.SetText = function(self, text) return self.Text:SetText(text) end;
	header:SetWidth(width)
	return header;
end

function Guide.CreateText(parent, width)
	local text = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormalMed1')
	text:SetJustifyH('LEFT')
	text:SetTextColor(WHITE_FONT_COLOR:GetRGBA())
	text:SetWidth(width)
	return text;
end

function Guide.CreateAtlasMarkup(text, atlas, color, size)
	size = size or 20;
	return ('%s %s'):format(
		CreateAtlasMarkup(atlas, size, size),
		color:WrapTextInColorCode(text))
end

function Guide.CreateInfoMarkup(text, size)
	size = size or 20;
	return ('%s %s'):format(
		CreateTextureMarkup(
		[[Interface\common\help-i]],
		64, 64, size, size, 0.2, 0.8, 0.2, 0.8), text)
end

function Guide.CreateCheckmarkMarkup(text, size)
	return Guide.CreateAtlasMarkup(text, 'common-icon-checkmark', GREEN_FONT_COLOR, size)
end

function Guide.CreateAdvancedMarkup(text, size)
	return Guide.CreateAtlasMarkup(text, 'common-icon-forwardarrow', ORANGE_FONT_COLOR, size)
end