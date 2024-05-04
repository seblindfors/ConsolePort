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
		function(pool) return Mixin(self:CreateLine(), GridLine) end,
		FramePool_HideAndClearAnchors
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

	self.linePool:ReleaseAll();

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
        PAD1     = function(self) self:ClearAndHide() end;
        PAD3     = function(self) self:RestorePoint() end;
        PADDUP   = function(self) self:SetSnapPixels(Clamp(self.snapToPixels + 1, 1, 50)) self:SetSize(self:GetSize()) end;
        PADDDOWN = function(self) self:SetSnapPixels(Clamp(self.snapToPixels - 1, 1, 50)) self:SetSize(self:GetSize()) end;
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
    self:SetHighlighted()
    self:SetMovable(true)
    self:SetUserPlaced(false)
    self:SetClampedToScreen(true)
    self:RegisterForDrag('LeftButton')
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

function Mover:SetKit(kit)
    for anchor, layout in pairs(self.SelectionLayout) do
        local slice = self[anchor];
        local atlas = layout.atlas:format(kit):lower()
        CPAPI.SetAtlas(slice, atlas, true, layout.flipX, layout.flipY)
    end
end

function Mover:SetSelected()
    self:SetKit(self.TextureKits.Selected)
end

function Mover:SetHighlighted()
    self:SetKit(self.TextureKits.Highlight)
end

function Mover:SetSnapPixels(snapToPixels)
    self.snapToPixels = snapToPixels;
    self.Snap:SetText(('Snap: %dpx'):format(snapToPixels))
    self.Grid:SetGridSpacing(snapToPixels)
    self.Grid:SetShown(snapToPixels > 1)
end

function Mover:SetWidget(frame)
    if C_Widget.IsFrameWidget(frame) then
        self:SetFrame(frame)
    else
        self:SetHandle(frame)
    end
end

function Mover:ClearAndHide()
    self.frame, self.relativeTo, self.isMoving, self.origPoint = nil;
    self:ClearAllPoints()
    self:Hide()
    self:ResetCursorNode()
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

function Mover:SetFrame(frame)
    if ( self.frame == frame ) then
        return self:ClearAndHide()
    end
    assert(frame:GetNumPoints() == 1, 'Frame must have only one point')
    self:SetSize(frame:GetSize())
    self:SetFrameStrata(frame:GetFrameStrata())
    self:SetFrameLevel(frame:GetFrameLevel() + 100)
    self:ClearAllPoints()
    self:CopyPoint(frame)
    self:Show()
    self:StoreCursorNode()
end

function Mover:SetOmitterSize(width, height)
    width  = 1.2 * (math.floor(width  / self.snapToPixels) * self.snapToPixels);
    height = 1.2 * (math.floor(height / self.snapToPixels) * self.snapToPixels);
    self.Omitter:SetSize(width, height)
end

function Mover:NudgeFrame(x, y, len)
    if ( len < 0.1 ) then
        if self.isMoving then
            self.isMoving = false;
            self:StopMovingOrSizing()
            self:ProcessPoint(self:GetPoint())
        end
        return;
    end
    if not self.isMoving then
        self.isMoving = true;
        self:StartMoving()
    end
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    self:SetPoint(point, relativeTo, relativePoint, xOfs + x, yOfs + y)
end

function Mover:CopyPoint(frame)
    local point, relativeTo, relativePoint, x, y = frame:GetPoint()
    self:SetPoint(point, relativeTo, relativePoint, x, y)
    self.frame, self.relativeTo = frame, relativeTo;
    self.origPoint = { point, relativeTo, relativePoint, x, y };
end

function Mover:RestorePoint()
    self.frame:ClearAllPoints()
    self.frame:SetPoint(unpack(self.origPoint))
    self:ClearAndHide()
end

function Mover:ProcessPoint(point, relativeTo, relativePoint, x, y)
    x = math.floor(x / self.snapToPixels) * self.snapToPixels;
    y = math.floor(y / self.snapToPixels) * self.snapToPixels;
    relativeTo = relativeTo or self.relativeTo;
    self:ClearAllPoints()
    self:SetPoint(point, relativeTo, relativePoint, x, y)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(point, relativeTo, relativePoint, x, y)
end

function Mover:OnGamePadStick(stick, x, y, len)
    if (stick == 'Right') then
        self:NudgeFrame(x * 4, y * 4, len)
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
    self:StartMoving()
end

function Mover:OnDragStop()
    self.isMoving = false;
    self:StopMovingOrSizing()
    self:ProcessPoint(self:GetPoint())
end

function Mover:OnClick()
    self:ClearAndHide()
end

function Mover:OnUpdate()
    if not self.frame or not self.frame:IsVisible() then self:ClearAndHide() end;
end

function Mover:SetPoint(point, relativeTo, relativePoint, x, y)
    self.Status:SetText(('%s: %d, %d'):format(point, x, y))
    getmetatable(self).__index.SetPoint(self, point, relativeTo, relativePoint, x, y)
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
env:RegisterSafeCallback('OnMoveFrame', function(frame)
    if not env.Mover then
        env.Mover = Mixin(CreateFrame('Button', nil, UIParent), Mover)
        env.Mover:OnLoad()
    end
    env.Mover:SetWidget(frame)
end)