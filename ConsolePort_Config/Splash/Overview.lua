local _, env = ...; local db, L = env.db, env.L;
local Overview = CreateFromMixins(CPFocusPoolMixin); env.Overview = Overview;
---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local BUTTON_SIZE = 48;
local WHITE_FONT_COLOR = WHITE_FONT_COLOR or CreateColor(1, 1, 1)
local Layout = {
	Anchor = {
		[0x1] = 'LEFT';
		[0x2] = 'RIGHT';
		[0x3] = 'CENTER';
		[0x4] = 'TOP';
	};
	Mask = {
		Anchor = function(v) return bit.rshift(v, 0x4) end;
		Index  = function(v) return bit.band(v, 0xF) end;
	};
	Position = {
		LEFT = {
			anchorPoint = {'LEFT', 50, 210},
			iconPoint = {'RIGHT', 'LEFT', -4, 0},
			textPoint = {'LEFT', 'LEFT', 40, 0},
			buttonPoint = {'LEFT', 0, 0},
		},
		RIGHT = {
			anchorPoint = {'RIGHT', -50, 210},
			iconPoint = {'LEFT', 'RIGHT', 4, 0},
			textPoint = {'RIGHT', 'RIGHT', -40, 0},
			buttonPoint = {'RIGHT', 0, 0},
		},
		CENTER = {
			anchorPoint = {'CENTER', 0, -50},
			iconPoint = {'BOTTOM', 'TOP', 0, 4},
			textPoint = {'TOP', 'BOTTOM', 0, -8},
			buttonPoint = {'CENTER', 0, 0},
		},
		TOP = {
			anchorPoint = {'CENTER', 0, 50 + (BUTTON_SIZE * 4)},
			iconPoint = {'BOTTOM', 'TOP', 0, 4},
			textPoint = {'TOP', 'BOTTOM', 0, -8},
			buttonPoint = {'CENTER', 0, 0},
		};
	};
}

---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
local Button = CreateFromMixins(env.BindingInfoMixin);

function Button:OnLoad()
	local font, _, outline = self.Label:GetFont()
	self.Label:SetFont(font, 12, outline)
	self:SetFontString(self.Label)
	self:SetSize(230, 48)
	CPAPI.Start(self)
end

function Button:OnShow()
	self:UpdateState(CPAPI.CreateKeyChord(''))
end

function Button:OnEnter()
	local tooltip = GameTooltip;
	local override = self.reservedData;
	local isClickOverride = self:IsClickReserved(override)
	tooltip:SetOwner(self, 'ANCHOR_BOTTOM')

	if override then
		tooltip:SetText(override.name)
		tooltip:AddLine(override.desc, 1, 1, 1, 1)
		if override.note then
			tooltip:AddLine('\n'..NOTE_COLON)
			tooltip:AddLine(override.note, 1, 1, 1, 1)
		end
		if isClickOverride then
			tooltip:AddLine('\n'..KEY_BINDINGS_MAC)
		end
	else
		tooltip:SetText(('|cFFFFFFFF%s|r'):format(KEY_BINDINGS_MAC))
	end

	local handler = db('Hotkeys')
	local base = self:GetBaseBinding()
	local mods = env:GetActiveModifiers()

	for mod, keys in db.table.mpairs(mods) do
		if (not override or (isClickOverride and mod ~= '')) then
			local name, texture, actionID = self:GetBindingInfo(self:GetChordBinding(mod))
			local slug = env:GetButtonSlug(base, mod)
			if actionID then
				texture = texture or [[Interface\Buttons\ButtonHilight-Square]]
				name = name:gsub('\n', '\n|T:12:32:0:0|t ') -- offset 2nd line
				tooltip:AddDoubleLine(('|T%s:32:32:0:-12|t %s\n '):format(texture, name), slug)
			else
				tooltip:AddDoubleLine(('%s\n '):format(name), slug)
			end
		end
	end
	tooltip:Show()
end


function Button:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
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

function Button:SetReserved(reservedData)
	self.reservedData = reservedData;
end

function Button:IsClickReserved(override)
	local reserved = override or self.reservedData;
	return reserved and reserved.cvar:match('Cursor');
end

function Button:GetChordBinding(mod)
	return GetBindingAction(mod..self.baseBinding)
end

function Button:GetBinding()
	return GetBindingAction(CPAPI.CreateKeyChord(self.baseBinding));
end

function Button:GetBaseBinding()
	return self.baseBinding;
end

function Button:SetActionIcon(texture)
	self.ActionIcon:SetTexture(texture)
	self.ActionIcon:SetShown(texture)
	self.ActionIcon:SetAlpha(texture and 1 or 0)
	self.Mask:SetShown(texture)
	self.Mask:SetAlpha(texture and 1 or 0)
end

function Button:UpdateState(currentModifier)
	local reserved = self.reservedData;
	local isClickOverride = (self:IsClickReserved(reserved) and currentModifier ~= '')
	if not isClickOverride and reserved then
		self:SetActionIcon(nil)
		self:SetText(WHITE_FONT_COLOR:WrapTextInColorCode(L(reserved.name)))
		return
	end

	local name, texture, actionID = self:GetBindingInfo(self:GetBinding())
	self:SetText(name)
	self:SetActionIcon(texture)
end


---------------------------------------------------------------
-- Gamepad overview (display bindings and info)
---------------------------------------------------------------
function Overview:OnLoad()
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
	local currentModifier = CPAPI.CreateKeyChord('');
	for widget in self:EnumerateActive() do
		widget:UpdateState(currentModifier)
	end
end

function Overview:OnHide()
	self:UnregisterAllEvents()
end

function Overview:PlayIntro()
	local animation = self:GetParent().TintAnimation;
	if animation then
		animation:Play()
	end
end

function Overview:OnShow()
	local device = db('Gamepad/Active')
	if not device then
		return self:UnregisterAllEvents()
	end

	self:PlayIntro()
	self:SetDevice(device)
	self:ReleaseAll()

	local getAnchor = Layout.Mask.Anchor;
	local getIndex  = Layout.Mask.Index;
	local anchors   = Layout.Anchor;
	local positions = Layout.Position;

	local reserved = {};
	for i, data in db:For('Console/Emulation') do
		local currentValue = GetCVar(data.cvar)
		if currentValue then
			reserved[currentValue] = data;
		end
	end

	for button, position in pairs(device.Theme.Layout) do
		local anchor = anchors[getAnchor(position)];
		local index  = getIndex(position)
		local layout = positions[anchor];
		local position = CopyTable(layout.anchorPoint)
		-- adjust yOffset
		position[3] = position[3] - index * BUTTON_SIZE;

		local widget, newObj = self:Acquire(button)
		if newObj then
			widget:OnLoad()
		end

		widget:SetBinding(button)
		widget:SetReserved(reserved[button])
		widget:SetupRegions(anchor)
		widget:SetPoint(unpack(position))
		widget:Show()
	end

	db('Alpha/FadeIn')(self, 1)
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
end