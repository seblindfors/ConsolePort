local env, db, _, L = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local WHITE_FONT_COLOR = WHITE_FONT_COLOR or CreateColor(1, 1, 1)
local ButtonLayout = {
	LEFT = {
		iconPoint   = {'RIGHT', 'LEFT', -4, 0};
		textPoint   = {'LEFT', 'LEFT', 40, 0};
		buttonPoint = {'LEFT', 0, 0};
		startAnchor = {'BOTTOMRIGHT', 0, 0};
		endAnchor   = {'BOTTOMLEFT', 0, 0};
		lineCoords  = CPSplineLineMixin.lineBaseCoord.LEFT;
	};
	RIGHT = {
		iconPoint   = {'LEFT', 'RIGHT', 4, 0};
		textPoint   = {'RIGHT', 'RIGHT', -40, 0};
		buttonPoint = {'RIGHT', 0, 0};
		startAnchor = {'BOTTOMLEFT', 0, 0};
		endAnchor   = {'BOTTOMRIGHT', 0, 0};
		lineCoords  = CPSplineLineMixin.lineBaseCoord.RIGHT;
	};
};

---------------------------------------------------------------
local Button = CreateFromMixins(env.BindingInfoMixin);
---------------------------------------------------------------

function Button:OnLoad()
	self:SetFontString(self.Label)
end

function Button:OnShow()
	self:UpdateState(CPAPI.CreateKeyChord(''))
end

function Button:OnEnter()
	local tooltip = GameTooltip;
	local override = self.reservedData;
	local isClickOverride = self:IsClickReserved(override)
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetPoint('BOTTOM', self.Container, 'BOTTOM', 0, 0)

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
	local set = ButtonLayout[anchor];

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

	self.Bottom:SetStartPoint(unpack(set.startAnchor))
	self.Bottom:SetEndPoint(unpack(set.endAnchor))
	self.Bottom:SetTexCoord(unpack(set.lineCoords))

	self.lineCoords = set.lineCoords;
end

function Button:SetBinding(binding)
	local data = env:GetHotkeyData(binding, '', 64, 32)
	self.baseBinding = binding;
	CPAPI.SetTextureOrAtlas(self.Icon, data.button)
end

function Button:SetReserved(reservedData)
	self.reservedData = reservedData;
	return reservedData;
end

function Button:IsClickReserved(override)
	local reserved = override or self.reservedData;
	return reserved and reserved.cvar:match('Cursor');
end

function Button:GetChordBinding(mod)
	return GetBindingAction(mod..self.baseBinding)
end

function Button:GetBinding()
	return GetBindingAction(self:GetKeyChord());
end

function Button:GetKeyChord()
	return self.mod .. self.baseBinding;
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

function Button:UpdateState(currentModifier) self.mod = currentModifier or '';
	local reserved = self:SetReserved(env:GetCombinationBlocker(self:GetKeyChord()))
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
local MainButton = CreateFromMixins(Button, CPSplineLineMixin)
---------------------------------------------------------------

function MainButton:OnLoad()
	Button.OnLoad(self)
	CPSplineLineMixin.OnLoad(self)
	self:SetLineOrigin('CENTER', self.Container)
end

function MainButton:OnEnter()
	Button.OnEnter(self)
	self:SetLineAlpha(1.0, true)
end

function MainButton:OnLeave()
	Button.OnLeave(self)
	self:SetLineAlpha(nil, false)
end

function MainButton:SetLineAlpha(alpha, reverse)
	self.Bottom:SetAlpha(alpha or 1.0)
	self:PlayLineEffect(0.25, function(bit)
		bit:SetAlpha(alpha or bit.finalAlpha)
	end, reverse)
end

function MainButton:SetData(index, total, data, isLeft)
	self:ClearLinePoints()

	self.index  = index;
	self.data   = data;

    -- Calculate position and constraints
    local w, h = self.Container:GetWidth()

    local entryHeight = 54; -- Height required for each entry
    local totalHeight = entryHeight * total;
    local startY = -totalHeight / 2 + entryHeight / 2;

    local y = PixelUtil.ConvertPixelsToUIForRegion(startY + (index - 1) * entryHeight, self)
    local x = PixelUtil.ConvertPixelsToUIForRegion(isLeft and -w * 0.28 or w * 0.28, self)

	w, h = self:GetSize()

	self:SetPoint('CENTER', x, y)
	local lastX = x + (isLeft and w / 2 or -w / 2) + (isLeft and -3 or 3);
	local lastY = y - (h / 2);

	-- Add points, join the spline points with the edge of the button.
	for _, point in ipairs(self.data.points) do
		self:AddLinePoint(unpack(point))
	end
	self:AddLinePoint(lastX, lastY)

	self:SetLineDrawLayer('ARTWORK', data.level)
	self:SetupRegions(isLeft and 'LEFT' or 'RIGHT')
	self:SetBinding(data.button)
	self:UpdateLines()
end

function MainButton:UpdateLines()
	local r, g, b = self.Container:GetColor()
	local h, s, v = CPAPI.RGB2HSV(r, g, b)
	self.Bottom:SetVertexColor(r, g, b)
	self.Bottom:SetAlpha(1.0)

	local e = (h + 180) % 360;
	self:DrawLine(function(bit, section)
		local hue = Lerp(e, h, section);
		bit.finalAlpha = EasingUtil.InCubic(Lerp(0, 1.0, section));
		bit:SetVertexColor(CPAPI.HSV2RGB(hue, s, v))
		bit:SetAlpha(bit.finalAlpha)
	end)
end

---------------------------------------------------------------
local ModifierTrayButton = {};
---------------------------------------------------------------

function ModifierTrayButton:Init(buttonID, controlCallback, modID)
	Mixin(self, ModifierTrayButton)
	local data = env:GetHotkeyData(buttonID, '', 64, 32)
	self:ToggleInversion(true)
	self:SetSelected(false)
	self:SetAttribute('nodeignore', true)
	self:SetScript('OnClick', controlCallback)
	self.buttonID = buttonID;
	self.modID = modID;
	CPAPI.SetTextureOrAtlas(self.Icon, data.button)
end

function ModifierTrayButton:SetSelected(selected)
	self:SetHeight(selected and 50 or 40)
end

---------------------------------------------------------------
local Overview = {};
---------------------------------------------------------------
function Overview:OnLoad()
	local canvas = self:GetCanvas()
	self:SetSize(canvas:GetSize())
	self:SetPoint('CENTER', 0, 0)

	self.Splash = self:CreateTexture(nil, 'ARTWORK')
	self.Splash:SetSize(450, 450)
	self.Splash:SetPoint('CENTER', 0, 0)

	self.modTapInHibitor = db.Data.Cvar('GamePadEmulateTapWindowMs')
	self.ModifierTray = CreateFrame('Frame', nil, self, 'CPOverviewModifierTray')
	self.ModifierTray:SetPoint('TOP', 0, 0)
	self.ModifierTray.ReleaseAll = GenerateClosure(self.ModifierTray.buttonPool.ReleaseAll, self.ModifierTray.buttonPool)
	self.ModifierTray:SetButtonSetup(ModifierTrayButton.Init)

	self.buttonPool = CreateFramePool('Button', self, 'CPOverviewBindingSplashDisplay')
end

function Overview:AcquireMainButton()
	local button, newObj = self.buttonPool:Acquire()
	if newObj then
		button.Container = self;
		FrameUtil.SpecializeFrameWithMixins(button, MainButton)
	end
	return button, newObj;
end

function Overview:OnShow()
	self:ReindexModifiers()
	self:SetDevice(env:GetActiveDeviceAndMap())
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self.tapBindingValue = self.modTapInHibitor:Get()
	self.modTapInHibitor:Set(0) -- Disable tap bindings while visible
end

function Overview:OnHide()
	self:UnregisterEvent('MODIFIER_STATE_CHANGED')
	self.modTapInHibitor:Set(self.tapBindingValue)
	self.buttonPool:ReleaseAll()
	self.Splash:SetTexture(nil)
	self.Device = nil;
	self.baseColor = nil;
	self.currentMods = nil;
	self.tapBindingValue = nil;
end

function Overview:GetColor()
	if not self.baseColor then
		self.baseColor = CPAPI.GetClassColorObject()
	end
	return self.baseColor:GetRGB()
end

function Overview:OnEvent(_, modifier, state)
	if (state ~= 0) then return end; -- isUp
	self:UpdateModifier(self:ToggleModifier(modifier))
end

---------------------------------------------------------------
-- Device and modifiers
---------------------------------------------------------------
function Overview:ReindexModifiers()
	self.currentMods = {};
	self.ModifierTray:ReleaseAll()
	for modID, buttonID in db:For('Gamepad/Index/Modifier/Key', true) do
		self.currentMods[modID] = false; -- Initialize active modifiers to false
		self.ModifierTray:AddControl(buttonID, GenerateClosure(self.ToggleAndUpdateModifier, self, modID), modID);
	end
end

function Overview:ToggleAndUpdateModifier(modifier)
	self:UpdateModifier(self:ToggleModifier(modifier))
end

function Overview:ToggleModifier(modifier)
	for tracked in pairs(self.currentMods) do
		if modifier:match(tracked) then
			self.currentMods[tracked] = not self.currentMods[tracked];
			break;
		end
	end
	self.mod = '';
	for mod, isDown in db.table.spairs(self.currentMods) do
		if isDown then
			self.mod = self.mod .. mod .. '-';
		end
	end
	return self.mod;
end

function Overview:UpdateModifier(currentModifier)
	for button in self.buttonPool:EnumerateActive() do
		button:UpdateState(currentModifier)
	end
	for button in self.ModifierTray:EnumerateControls() do
		button:SetSelected(self.currentMods[button.modID])
	end
end

function Overview:SetDevice(device)
	local asset  = device.Name and db('Gamepad/Index/Splash/'..device.Name)
	self.Splash:SetTexture(CPAPI.GetAsset('Splash\\Gamepad\\'..asset))
	self.Device = device;
	self.buttonPool:ReleaseAll()

	if not device.Theme or not device.Theme.Layout then
		return error('Device theme or layout not found for: ' .. (device.Name or 'Unknown Device'))
	end

	-- Position format:
	-- delta (-1 or 1), drawLayer, x1, y1, ..., xN, yN
	local left, right = {}, {};

	local function ExtractTargetAndLevel(position)
		return position[1] < 0 and left or right, position[2];
	end

	local function ExtractPoints(position)
		local delta, points = position[1], {};
		for i = 3, #position, 2 do
			tinsert(points, { delta * position[i], position[i + 1] });
		end
		return points;
	end

	local function SortEntriesByLastY(a, b)
		return a.points[#a.points][2] < b.points[#b.points][2];
	end

	for button, position in pairs(device.Theme.Layout) do
		assert(#position % 2 == 0, 'Invalid position format for button: ' .. button)
		local target, level = ExtractTargetAndLevel(position)
		tinsert(target, {
			button   = button;
			level    = level;
			points   = ExtractPoints(position);
		})
	end

	table.sort(left, SortEntriesByLastY)
	table.sort(right, SortEntriesByLastY)

	self:DrawButtons(left, true)
	self:DrawButtons(right, false)
end

function Overview:DrawButtons(buttons, isLeft)
	local numButtons = #buttons;
	for i, data in ipairs(buttons) do
		local button = self:AcquireMainButton()
		button:SetData(i, numButtons, data, isLeft)
		button:Show()
	end
end

---------------------------------------------------------------
-- Add overview to guide content
---------------------------------------------------------------
Guide:AddContent(CPAPI.Static(true), function(canvas)
	if not canvas.Overview then
		canvas.Overview = CreateFrame('Frame', nil, canvas);
		canvas.Overview.GetCanvas = CPAPI.Static(canvas);
		FrameUtil.SpecializeFrameWithMixins(canvas.Overview, Overview)
	end
	canvas.Overview:Show()
end, function(canvas)
	if not canvas.Overview then return end;
	canvas.Overview:Hide()
end)