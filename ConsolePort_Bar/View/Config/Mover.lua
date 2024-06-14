local _, env, Node = ...; Node = LibStub('ConsolePortNode')
---------------------------------------------------------------
local GridLine = { pixelWidth = 1.2 };
---------------------------------------------------------------

function GridLine:SetupLineThickness(linePixelWidth)
	local lineThickness = PixelUtil.GetNearestPixelSize(linePixelWidth, self:GetEffectiveScale(), linePixelWidth)
	self:SetThickness(lineThickness)
end

function GridLine:SetupLine(centerLine, verticalLine, xOffset, yOffset)
	local color = centerLine and RED_FONT_COLOR or LIGHTGRAY_FONT_COLOR;
	self:SetColorTexture(color:GetRGBA())

	self:SetStartPoint(verticalLine and 'TOP' or 'LEFT', self:GetParent(), xOffset, yOffset)
	self:SetEndPoint(verticalLine and 'BOTTOM' or 'RIGHT', self:GetParent(), xOffset, yOffset)

	self:SetupLineThickness(self.pixelWidth)
end

---------------------------------------------------------------
local Grid = {};
---------------------------------------------------------------
function Grid:OnLoad()
	self.linePool = CreateObjectPool(
		function(_) return Mixin(self:CreateLine(), GridLine) end,
		CPAPI.HideAndClearAnchors
	);

	self:RegisterEvent('DISPLAY_SIZE_CHANGED')
	self:RegisterEvent('UI_SCALE_CHANGED')
	self:SetFrameStrata('BACKGROUND')
	self:SetAllPoints(UIParent)
	self:SetAlpha(0.85)
	hooksecurefunc('UpdateUIParentPosition', function() self:UpdateGrid() end)
	CPAPI.Start(self)
end

function Grid:OnHide()
	self.linePool:ReleaseAll();
end

function Grid:OnShow()
	self:UpdateGrid()
end

function Grid:OnEvent()
	self:UpdateGrid()
end

function Grid:SetGridSpacing(spacing)
	self.gridSpacing = spacing;
	self:UpdateGrid()
end

function Grid:UpdateGrid()
	if not self:IsVisible() then return end;
	self.linePool:ReleaseAll()

	local centerLine, centerLineNo = true, false;
	local verticalLine, verticalLineNo = true, false;

	local centerVerticalLine = self.linePool:Acquire()
	centerVerticalLine:SetupLine(centerLine, verticalLine, 0, 0)
	centerVerticalLine:Show()

	local centerHorizontalLine = self.linePool:Acquire()
	centerHorizontalLine:SetupLine(centerLine, verticalLineNo, 0, 0)
	centerHorizontalLine:Show()

	local halfNumVerticalLines = floor((self:GetWidth() / self.gridSpacing) / 2)
	local halfNumHorizontalLines = floor((self:GetHeight() / self.gridSpacing) / 2)

	for i = 1, halfNumVerticalLines do
		local xOffset = i * self.gridSpacing;

		local line = self.linePool:Acquire()
		line:SetupLine(centerLineNo, verticalLine, xOffset, 0)
		line:Show()

		line = self.linePool:Acquire()
		line:SetupLine(centerLineNo, verticalLine, -xOffset, 0)
		line:Show()
	end

	for i = 1, halfNumHorizontalLines do
		local yOffset = i * self.gridSpacing;

		local line = self.linePool:Acquire()
		line:SetupLine(centerLineNo, verticalLineNo, 0, yOffset)
		line:Show()

		line = self.linePool:Acquire()
		line:SetupLine(centerLineNo, verticalLineNo, 0, -yOffset)
		line:Show()
	end
end


---------------------------------------------------------------
local Mover = {
---------------------------------------------------------------
	SelectionLayout = {
		TOPRIGHT    = { atlas = '%s-NineSlice-Corner',      x =  8, y =  8, flipX =  true, flipY = false };
		TOPLEFT     = { atlas = '%s-NineSlice-Corner',      x = -8, y =  8, flipX = false, flipY = false };
		BOTTOMLEFT  = { atlas = '%s-NineSlice-Corner',      x = -8, y = -8, flipX = false, flipY =  true };
		BOTTOMRIGHT = { atlas = '%s-NineSlice-Corner',      x =  8, y = -8, flipX =  true, flipY =  true };
		TOP         = { atlas = '_%s-NineSlice-EdgeTop',    x =  0, y =  8 };
		BOTTOM      = { atlas = '_%s-NineSlice-EdgeBottom', x =  0, y = -8 };
		LEFT        = { atlas = '!%s-NineSlice-EdgeLeft',   x = -8, y =  0 };
		RIGHT       = { atlas = '!%s-NineSlice-EdgeRight',  x =  8, y =  0 };
		CENTER      = { atlas = '%s-NineSlice-Center' };
	};
	StatusTexts = {
		Status = { point = 'BOTTOM', relPoint = 'TOP',    x =  0, y =  8, rotation =   0 };
		Snap   = { point = 'LEFT',   relPoint = 'RIGHT',  x = -8, y =  0, rotation = -90 };
		Height = { point = 'RIGHT',  relPoint = 'LEFT',   x =  8, y =  0, rotation =  90 };
		Width  = { point = 'TOP',    relPoint = 'BOTTOM', x =  0, y = -8, rotation =   0 };
	};
	TextureKits = {
		Highlight = 'editmode-actionbar-highlight';
		Selected  = 'editmode-actionbar-selected';
	};
	ButtonCommands = {
		PAD1         = function(self) self:ClearAndHide() end;
		PAD3         = function(self) self:RestorePoint() end;
		PADRSHOULDER = function(self) self:OnMouseWheel(1) end;
		PADLSHOULDER = function(self) self:OnMouseWheel(-1) end;
		PADDLEFT     = function(self) self:SnapXY(-1,  0) end;
		PADDRIGHT    = function(self) self:SnapXY( 1,  0) end;
		PADDUP       = function(self) self:SnapXY( 0,  1) end;
		PADDDOWN     = function(self) self:SnapXY( 0, -1) end;
	};
};

function Mover:OnLoad()
	for anchor, layout in pairs(self.SelectionLayout) do
		local slice = self:CreateTexture(nil, 'BACKGROUND')
		slice:SetPoint(anchor, layout.x or 0, layout.y or 0)
		self[anchor] = slice;
	end

	self.CENTER:SetAllPoints()
	self.CENTER:SetAlpha(0.75)
	self:SetMovable(true)
	self:SetUserPlaced(false)
	self:RegisterForDrag('LeftButton')
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	CPAPI.Start(self)

	self.Omitter = CreateFrame('Frame', nil, self)
	self.Omitter:SetPoint('CENTER')
	self.Omitter:SetClipsChildren(true)
	self.Omitter:SetFrameStrata('BACKGROUND')
	self.Grid = Mixin(CreateFrame('Frame', nil, self.Omitter), Grid)
	self.Grid:OnLoad()

	for name, layout in pairs(self.StatusTexts) do
		local text = self:CreateFontString(nil, 'BACKGROUND', 'GameFontWhiteTiny')
		text:SetPoint(layout.point, self.Omitter, layout.relPoint, layout.x, layout.y)
		text:SetRotation(rad(layout.rotation))
		self[name] = text;
	end

	self:SetSnapPixels(10)
end

function Mover:SetInputEnabled(enable)
	self:EnableMouse(enable)
	self:EnableMouseWheel(enable)
	self:EnableMouseMotion(enable)
	self:EnableGamePadStick(enable)
	self:EnableGamePadButton(enable)
	self:SetClampedToScreen(enable)
	self:SetScript('OnUpdate', enable and self.OnUpdate or nil)
	self:SetKit(enable and self.TextureKits.Highlight or self.TextureKits.Selected)
	for text in pairs(self.StatusTexts) do
		self[text]:SetShown(enable)
	end
end

function Mover:MimeFrame(frame, delta)
	assert(frame:GetNumPoints() == 1, 'Frame must have only one point')
	local width, height = frame:GetSize()
	self:SetSize(Round(width), Round(height))
	self:SetScale(frame:GetEffectiveScale() / UIParent:GetEffectiveScale())
	self:SetFrameStrata(frame:GetFrameStrata())
	self:SetFrameLevel(frame:GetFrameLevel() + delta)
	self:ClearAllPoints()
	self:CopyPoint(frame)
	self:Show()
end

function Mover:MoveFrame(frame, callback, snapPixels)
	if ( self.frame == frame ) then
		return self:ClearAndHide()
	end
	self.frame = frame;
	self.callback = callback;
	if tonumber(snapPixels) then
		self:SetSnapPixels(snapPixels)
	end
	self:MimeFrame(frame, 100)
	self:StoreCursorNode()
	self:SetInputEnabled(true)
end

function Mover:MarkFrame(frame, show)
	if self.frame then return end;
	if not show and self:IsShown() then return self:Hide() end;
	self:MimeFrame(frame, -1)
	self:SetSnapPixels(1)
	self:SetInputEnabled(false)
	env.db.Alpha.FadeIn(self, 0.2, 0, 1)
end

function Mover:OnShow()
	env:RegisterCallback('OnCombatLockdown', self.RestorePoint, self)
end

function Mover:OnHide()
	env:UnregisterCallback('OnCombatLockdown', self)
end

function Mover:SetKit(kit)
	for anchor, layout in pairs(self.SelectionLayout) do
		local slice = self[anchor];
		local atlas = layout.atlas:format(kit):lower()
		CPAPI.SetAtlas(slice, atlas, true, layout.flipX, layout.flipY)
	end
end

function Mover:SetSnapPixels(snapToPixels)
	self.snapToPixels = snapToPixels;
	self.Snap:SetText(('Snap: %dpx'):format(snapToPixels))
	self.Grid:SetShown(snapToPixels > 5)
	if self.Grid:IsShown() then
		self.Grid:SetGridSpacing(snapToPixels)
	end
end

function Mover:ClearAndHide()
	self:ClearAllPoints()
	self:Hide()
	self:ResetCursorNode()
	if ( self.frame and type(self.callback) == 'function' ) then
		securecallfunction(self.callback, self.frame:GetPoint())
	end
	self.frame, self.show, self.callback, self.relativeTo, self.isMoving, self.origPoint = nil;
end

function Mover:StoreCursorNode()
	if not self.cursorNode then
		self.cursorNode = ConsolePort:IsCursorActive() and ConsolePort:GetCursorNode()
		if self.cursorNode then
			ConsolePortCursor:Click()
		end
	end
end

function Mover:ResetCursorNode()
	if self.cursorNode then
		ConsolePort:SetCursorNode(self.cursorNode)
		self.cursorNode = nil;
	end
end

function Mover:SetOmitterSize(width, height)
	width  = math.floor(1.2 * (math.floor(width  / self.snapToPixels) * self.snapToPixels));
	height = math.floor(1.2 * (math.floor(height / self.snapToPixels) * self.snapToPixels));
	self.Omitter:SetSize(width, height)
end

function Mover:SnapXY(x, y)
	self:SetPoint(self:MoveXY(x * self.snapToPixels, y * self.snapToPixels))
	self:ProcessPoint(self:GetPoint())
end

function Mover:MoveXY(x, y)
	local point, relativeTo, relativePoint, xOfs, yOfs = unpack(self.snapPoint)
	self.snapPoint = { point, relativeTo, relativePoint, xOfs + x, yOfs + y };
	return unpack( self.snapPoint );
end

function Mover:NudgeXY(x, y, len)
	if ( len < 0.05 ) then
		if self.isMoving then
			self.isMoving = false;
			self:ProcessPoint(self:GetPoint())
		end
		return;
	end
	if not self.isMoving then
		self.isMoving = true;
	end
	self:SetPoint(self:MoveXY(x, y))
end

function Mover:CopyPoint(frame)
	local point, relativeTo, relativePoint, x, y = frame:GetPoint()
	self:SetPoint(point, relativeTo, relativePoint, x, y)
	self.relativeTo, self.show = relativeTo, frame:IsShown();
	self.origPoint = { point, relativeTo, relativePoint, x, y };
	self.snapPoint = { point, relativeTo, relativePoint, x, y };
end

function Mover:RestorePoint()
	if not self.frame then return end;
	self.frame:ClearAllPoints()
	self.frame:SetPoint(unpack(self.origPoint))
	self:ClearAndHide()
end


local function Snap(value, bias)
	return Round(value / bias) * bias;
end

function Mover:ProcessPoint(point, relativeTo, relativePoint, x, y)
    x = Snap(x, self.snapToPixels)
    y = Snap(y, self.snapToPixels)
    relativeTo = relativeTo or self.relativeTo;

    self:ClearAllPoints()
    self:SetPoint(point, relativeTo, relativePoint, x, y)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(point, relativeTo, relativePoint, x, y)
end

function Mover:OnGamePadStick(stick, x, y, len)
	if (stick == 'Right') then
		self:NudgeXY(x * 2, y * 2, len)
	elseif (stick == 'Left') then
		self:NudgeXY(x * 1, y * 1, len)
	end
end

function Mover:OnGamePadButtonDown(button)
	local command = self.ButtonCommands[button]
	if command then
		command(self)
	end
end

function Mover:OnDragStart()
	self.isMoving = true;
	self.startX, self.startY = GetScaledCursorPosition()
end

function Mover:OnDragStop()
	self.isMoving = false;
	self.startX, self.startY = nil, nil;
	self:ProcessPoint(self:GetPoint())
end

function Mover:OnClick(button)
	if ( button == 'RightButton' ) then
		return self:RestorePoint()
	end
	self:ClearAndHide()
end

function Mover:OnUpdate()
	if not self.frame or ( self.show ~= self.frame:IsShown() ) then self:ClearAndHide() end;
	if self.startX and self.startY then
		local x, y = GetScaledCursorPosition()
		local dx, dy = x - self.startX, y - self.startY;
		self:SetPoint(self:MoveXY(dx, dy))
		self.startX, self.startY = x, y;
	end
end

function Mover:OnMouseWheel(delta)
	self:SetSnapPixels(Clamp(self.snapToPixels + delta, 1, 50))
	self:SetSize(self:GetSize())
end

function Mover:SetPoint(point, relativeTo, relativePoint, x, y)
	self.Status:SetText(('%s -> %s: %d, %d'):format(point, relativePoint, x, y))
	getmetatable(self).__index.SetPoint(self, point, relativeTo, relativePoint, x, y)
	for anchor in pairs(self.SelectionLayout) do
		local slice = self[anchor];
		if ( anchor == point and anchor == relativePoint ) then
			slice:SetVertexColor(0, 1, 0)
		elseif ( anchor == point ) then
			slice:SetVertexColor(1, 0, 0)
		elseif ( anchor == relativePoint ) then
			slice:SetVertexColor(0, 0, 1)
		else
			slice:SetVertexColor(1, 1, 1)
		end
	end
end

function Mover:SetSize(width, height)
	self:SetOmitterSize(width, height)
	self.Width:SetText(('Width: %d'):format(width))
	self.Height:SetText(('Height: %d'):format(height))
	getmetatable(self).__index.SetSize(self, width, height)
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
do local function CreateMover()
		if not env.Mover then
			env.Mover = Mixin(CreateFrame('Button', nil, UIParent), Mover)
			env.Mover:OnLoad()
			env.Mover:Hide()
		end
		return env.Mover;
	end

	env:RegisterSafeCallback('OnMoveFrame', function(frame, callback, snapPixels)
		CreateMover():MoveFrame(frame, callback, snapPixels)
	end)

	env:RegisterSafeCallback('OnHighlightFrame', function(frame, show)
		CreateMover():MarkFrame(frame, show)
	end)
end