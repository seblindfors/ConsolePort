local _, env = ...; local db, L = env.db, env.L;
local Overview = CreateFromMixins(CPFocusPoolMixin); env.Overview = Overview;
---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local Layout = {
	Anchor = {
		[0x1] = 'LEFT';
		[0x2] = 'RIGHT';
		[0x3] = 'CENTER';
	};
	Mask = {
		Anchor = function(v)
			return bit.rshift(v, 0x04)
		end;
		Index  = function(v)
			return bit.rshift(bit.lshift(v, 0x1C), 0x1c)
		end;
	};
	Position = {
		LEFT = {
			anchorPoint = {'LEFT', 50, 210},
			iconPoint = {'RIGHT', 'LEFT', -4, 0},
			textPoint = {'LEFT', 'LEFT', 40, 0},
			buttonPoint = {'LEFT', 0, 0},
			hitRects = {0, -190,  0, 0},
		},
		RIGHT = {
			anchorPoint = {'RIGHT', -50, 210},
			iconPoint = {'LEFT', 'RIGHT', 4, 0},
			textPoint = {'RIGHT', 'RIGHT', -40, 0},
			buttonPoint = {'RIGHT', 0, 0},
			hitRects = {-190, 0, 0, 0},
		},
		CENTER = {
			anchorPoint = {'CENTER', 0, -50},
			iconPoint = {'BOTTOM', 'TOP', 0, 4},
			textPoint = {'TOP', 'BOTTOM', 0, -8},
			buttonPoint = {'CENTER', 0, 0},
			hitRects = {-90, -90, 0, -40},
		},
	};
}

---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
local Button = CreateFromMixins(env.BindingInfoMixin);

function Button:OnLoad( ... )
	local font, _, outline = self.Label:GetFont()
	self.Label:SetFont(font, 12, outline)
	self:SetFontString(self.Label)
	self:SetSize(230, 48)
	CPAPI.Start(self)
end

function Button:OnShow()
	self:UpdateState()
end

function Button:SetupRegions(anchor)
	local set = Layout.Position[anchor];

	local point, relativePoint, xOffset, yOffset = unpack(set.textPoint);
	self.Label:SetJustifyH(anchor)
	self.Label:ClearAllPoints()
	self.Label:SetPoint(point, self, relativePoint, xOffset, yOffset)

	point, relativePoint, xOffset, yOffset = unpack(set.iconPoint)
	self.ActionIcon:ClearAllPoints()
	self.ActionIcon:SetPoint(point, self, relativePoint, xOffset, yOffset)

	point, xOffset, yOffset = unpack(set.buttonPoint)
	self.Icon:ClearAllPoints()
	self.Icon:SetPoint(point, xOffset, yOffset)
end

function Button:SetBinding(binding)
	local data = env:GetHotkeyData(binding, '', 64, 32)
	self.baseBinding = binding;
	self.Icon:SetTexture(data.button)
end

function Button:GetBinding()
	return GetBindingAction(CreateKeyChordStringUsingMetaKeyState(self.baseBinding));
end

function Button:GetBaseBinding()
	return self.baseBinding;
end

function Button:UpdateState()
	local name, texture, actionID = self:GetBindingInfo(self:GetBinding())
	self:SetText(name)
	self.ActionIcon:SetTexture(texture)
	self.ActionIcon:SetShown(texture)
	self.ActionIcon:SetAlpha(texture and 1 or 0)
	self.Mask:SetShown(texture)
	self.Mask:SetAlpha(texture and 1 or 0)
	-- TODO: display modifier info
end


---------------------------------------------------------------
-- Gamepad overview (display bindings and info)
---------------------------------------------------------------
function Overview:OnLoad()
	env.OpaqueMixin.OnLoad(self)
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('Button',
		'CPConfigBindingSplashDisplayTemplate', Button, nil, self)
end

function Overview:SetDevice(device)
	local r, g, b = CPAPI.GetClassColor()
	local asset = device.Name and db('Gamepad/Index/Splash/'..device.Name)
	self.Splash:SetTexture(CPAPI.GetAsset('Splash\\Gamepad\\'..asset))
	self.Lines:SetTexture(CPAPI.GetAsset('Splash\\Blueprint\\'..asset))
	self.Lines:SetVertexColor(r, g, b)
end

function Overview:OnEvent(_, event)
	for widget in self:EnumerateActive() do
		widget:UpdateState()
	end
end

function Overview:OnHide()
	self:UnregisterAllEvents()
end

function Overview:OnShow()
	local device = db('Gamepad/Active')
	if not device then
		return self:UnregisterAllEvents()
	end

	self:SetDevice(device)
	self:ReleaseAll()

	local getAnchor = Layout.Mask.Anchor;
	local getIndex  = Layout.Mask.Index;
	local anchors   = Layout.Anchor;
	local positions = Layout.Position;

	for button, position in pairs(device.Theme.Layout) do
		local anchor = anchors[getAnchor(position)];
		local index  = getIndex(position)
		local layout = positions[anchor];
		local position = CopyTable(layout.anchorPoint)
		position[3] = position[3] - index * 48;

		local widget, newObj = self:Acquire(button)
		if newObj then
			widget:OnLoad()
			widget:SetFontString(widget.Label)
		end
		widget:SetBinding(button)
		widget:SetupRegions(anchor)
		widget:SetText(button)
		widget:SetPoint(unpack(position))
		widget:Show()
	end

	db('Alpha/FadeIn')(self, 1)
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
end