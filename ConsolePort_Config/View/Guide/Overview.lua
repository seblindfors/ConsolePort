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
		lineCoords  = {0, 1, 1, 0};
	};
	RIGHT = {
		iconPoint   = {'LEFT', 'RIGHT', 4, 0};
		textPoint   = {'RIGHT', 'RIGHT', -40, 0};
		buttonPoint = {'RIGHT', 0, 0};
		startAnchor = {'BOTTOMLEFT', 0, 0};
		endAnchor   = {'BOTTOMRIGHT', 0, 0};
		lineCoords  = {0, 1, 0, 1};
	};
};

local function CreateLinePool(ownerFrame, template)
	return CreateObjectPool(
		function(_)
			return ownerFrame:CreateLine(nil, 'ARTWORK', template);
		end,
		function(_, line)
			line:Hide();
			line:ClearAllPoints();
		end
	);
end

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
local MainButton = CreateFromMixins(Button);
---------------------------------------------------------------

function MainButton:OnLoad()
	Button.OnLoad(self)
	self.lines  = CreateLinePool(self.Container, 'CPOverviewLine')
	self.spline = CreateCatmullRomSpline(2)
end

function MainButton:OnEnter()
	Button.OnEnter(self)
	self:SetLineAlpha(1.0)
end

function MainButton:OnLeave()
	Button.OnLeave(self)
	self:SetLineAlpha(nil)
end

function MainButton:SetLineAlpha(alpha)
	self.Bottom:SetAlpha(alpha or 1.0)
	for line in self.lines:EnumerateActive() do
		line:SetAlpha(alpha or line.finalAlpha)
	end
end

function MainButton:SetData(index, total, data, isLeft)
	self.lines:ReleaseAll()
	self.spline:ClearPoints()

	self.index  = index;
	self.data   = data;

    -- Create the final point for the button, which is based
    -- on the index, the total, and the size of the container.
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

	-- Add the final point to the data, calculate the spline
	tinsert(self.data.points, { lastX, lastY })
	print('Adding points for button:', self.data.button, 'at', lastX, lastY)
	for _, point in ipairs(self.data.points) do
		self.spline:AddPoint(unpack(point))
	end

	self:SetupRegions(isLeft and 'LEFT' or 'RIGHT')
	self:SetBinding(data.button)
	self:UpdateLines()
end

function MainButton:UpdateLines()
	local numSegments, level, coords = 50, self.data.level, self.lineCoords;
	local lines, spline = self.lines, self.spline;

	local r, g, b = self.Container:GetColor()
	local h, s, v = CPAPI.RGB2HSV(r, g, b)
	self.Bottom:SetVertexColor(r, g, b)
	self.Bottom:SetAlpha(1.0)

	local e = (h + 180) % 360;
	for i = 1, numSegments do
		local section = i / numSegments;
		local line = lines:Acquire();

		line:SetStartPoint('CENTER', spline:CalculatePointOnGlobalCurve(section - (2 / numSegments)))
		line:SetEndPoint('CENTER',   spline:CalculatePointOnGlobalCurve(section))

		local hue = Lerp(e, h, section);
		line.finalAlpha = EasingUtil.InCubic(Lerp(0, 1.0, section));
		line:SetVertexColor(CPAPI.HSV2RGB(hue, s, v))
		line:SetDrawLayer('ARTWORK', level)
		line:SetTexCoord(unpack(coords))
		line:SetAlpha(line.finalAlpha)

		line:Show()
	end
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

	self.buttonPool = CreateFramePool('Button', self, 'CPOverviewBindingSplashDisplay')
end

function Overview:Acquire()
	local button, newObj = self.buttonPool:Acquire()
	if newObj then
		button.Container = self;
		FrameUtil.SpecializeFrameWithMixins(button, MainButton)
	end
	return button, newObj;
end

function Overview:OnShow()
	self:SetDevice(env:GetActiveDeviceAndMap())
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
end

function Overview:OnHide()
	self:UnregisterEvent('MODIFIER_STATE_CHANGED')
	self.buttonPool:ReleaseAll()
	self.Splash:SetTexture(nil)
	self.Device = nil;
	self.baseColor = nil;
end

function Overview:GetColor()
	if not self.baseColor then
		self.baseColor = CPAPI.GetClassColorObject()
	end
	return self.baseColor:GetRGB()
end

function Overview:OnEvent()
	local currentModifier = CPAPI.CreateKeyChord('');
	for button in self.buttonPool:EnumerateActive() do
		button:UpdateState(currentModifier)
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
		local button = self:Acquire()
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