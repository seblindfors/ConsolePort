local env, db, _, L = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local SWITCH_SPLASH_TIME = 0.5;
local SPLASH_DEVICE_SIZE = 450;
local SPLASH_DEVICE_NONE = 128;
local LAYOUT_FRAME_WIDTH = 325;

local function GetFirstDeviceStyle()
	for _, i in ipairs(C_GamePad.GetAllDeviceIDs()) do
		local state = C_GamePad.GetDeviceMappedState(i)
		if (state and state.labelStyle and state.labelStyle ~= 'Generic') then
			return state.labelStyle, state.name;
		end
	end
end

---------------------------------------------------------------
local DeviceProfile = {};
---------------------------------------------------------------

function DeviceProfile:OnAcquire(new)
	if new then
		Mixin(self, env.Setting, DeviceProfile)
		self:SetScript('OnEnter', self.OnEnter)
		self:SetScript('OnLeave', self.OnLeave)
		self:HookScript('OnEnter', self.LockHighlight)
		self:HookScript('OnLeave', self.UnlockHighlight)
	end
	db:RegisterCallback('Gamepad/Active', self.OnActiveChanged, self)
end

function DeviceProfile:OnEnter()
	local device = self:GetDevice()
	if not device then return end;
	env:TriggerEvent('Graphics.FocusDevice', device)
end

function DeviceProfile:OnLeave()
	env:TriggerEvent('Graphics.FocusDevice', nil)
end

function DeviceProfile:Update()
	local device = self:GetDevice()
	if not device then return end;
	self:SetText(device.Name)
	if not device.StyleNameSubStrs then return end;

	local connectedStyle, connectedName = GetFirstDeviceStyle()
	if not connectedStyle or device.LabelStyle ~= connectedStyle then return end;

	local isRecommended = not device.StyleNameSubStrs;
	if not isRecommended then
		for _, subStr in ipairs(device.StyleNameSubStrs) do
			if connectedName:find(subStr) then
				isRecommended = true;
				break
			end
		end
	end
	if not isRecommended then return end;
	self:SetText(('%s |cFF757575(%s)|r'):format(device.Name, RECOMMENDED))
end

---------------------------------------------------------------
local DeviceInfo = {};
---------------------------------------------------------------

function DeviceInfo:OnLoad()
	self.Header = Guide.CreateHeader(self, LAYOUT_FRAME_WIDTH)
	self.Header.layoutIndex = 1;

	self.Body = Guide.CreateText(self, LAYOUT_FRAME_WIDTH)
	self.Body.layoutIndex = 2;
end

function DeviceInfo:SetDevice(device)
	if not device or not device.Description then
		return self:Hide()
	end
	self.Header.Text:SetText(device.Name)
	self.Body:SetText(CPAPI.FormatLongText(device.Description))
	self:Show()
	self:Layout()
end

---------------------------------------------------------------
local Icons = {};
---------------------------------------------------------------

function Icons:OnLoad()
	self.Header = Guide.CreateHeader(self, LAYOUT_FRAME_WIDTH)
	self.Header.Text:SetText(self.text)
	self.Header.layoutIndex = 1;
	self.iconPool = CreateTexturePool(self.Grid, 'ARTWORK')
	self.Grid.stride = self.stride;
end

function Icons:SetDevice(device)
	self.iconPool:ReleaseAll()
	if not device then return self:Hide() end;

	local layoutIndex = CreateCounter()
	for btnID in env.table.spairs(device.Assets) do
		local path, isAtlas = device:GetIconForButton(btnID, self.iconStyle)
		if path then
			local icon = self.iconPool:Acquire()
			if isAtlas then
				icon:SetAtlas(path, true)
			else
				icon:SetTexture(path)
			end
			icon:SetSize(self.iconSize, self.iconSize)
			icon.layoutIndex = layoutIndex();
			icon:Show()
			icon:SetPoint('TOPLEFT', self.Grid, 'TOPLEFT', 0, 0)
		end
	end
	self.Grid:Layout()
	self:Layout()
	self:Show()
end

---------------------------------------------------------------
local Continue = {};
---------------------------------------------------------------

function Continue:OnShow()
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
	self:OnActiveDeviceChanged()
end

function Continue:OnHide()
	db:UnregisterCallback('Gamepad/Active', self)
end

function Continue:OnActiveDeviceChanged()
	local hasActiveDevice = not not db.Gamepad.Active;
	self:SetEnabled(hasActiveDevice)
	if hasActiveDevice then
		ConsolePort:SetCursorNodeIfActive(self)
	end
end

function Continue:OnClick()
	self:SetChecked(false)
	CPAPI.SetTutorialComplete('GamepadGraphics')
	Guide:AutoSelectContent()
end

---------------------------------------------------------------
local Graphics = CreateFromMixins(env.Mixin.UpdateStateTimer)
---------------------------------------------------------------

function Graphics:OnLoad()
	local canvas = self:GetCanvas();

	self:SetAllPoints(canvas)
	self:SetUpdateStateDuration(SWITCH_SPLASH_TIME)

	self.Settings:Show()
	self.Settings:InitDefault()
	DeviceProfile = CreateFromMixins(env.Elements.DeviceProfile, DeviceProfile);

	env:RegisterCallback('Graphics.FocusDevice', self.OnFocusDevice, self)

	CPAPI.SpecializeOnce(self.DeviceInfo, DeviceInfo)
	CPAPI.SpecializeOnce(self.Continue, Continue)
	CPAPI.Specialize(self.SmallIcons, Icons)
	CPAPI.Specialize(self.LargeIcons, Icons)

	-- Setup animations
	self.deviceFocusedAnim  = CPAPI.CreateAnimationQueue()
	self.noDeviceActiveAnim = CPAPI.CreateAnimationQueue()

	local GeneralInfoSpline = CreateCatmullRomSpline(2)
	GeneralInfoSpline:AddPoint(20, -50)
	GeneralInfoSpline:AddPoint(150, -150)
	GeneralInfoSpline:AddPoint(468, -160)

	local SplashSpline = CreateCatmullRomSpline(2)
	SplashSpline:AddPoint(0, 150)
	SplashSpline:AddPoint(0, 250)

	local MoveInfoToLeft = self.deviceFocusedAnim:CreateAnimation(0.5, function(self, fraction)
		self:SetPoint('TOPLEFT', GeneralInfoSpline:CalculatePointOnGlobalCurve(1 - fraction))
	end, self.deviceFocusedAnim.Fraction, EasingUtil.OutCubic)

	local MoveSplashDown = self.deviceFocusedAnim:CreateAnimation(1, function(self, fraction)
		self:SetPoint('CENTER', SplashSpline:CalculatePointOnGlobalCurve(1 - fraction))
	end, self.deviceFocusedAnim.Fraction, EasingUtil.OutCubic)

	local MoveInfoToCenter = self.noDeviceActiveAnim:CreateAnimation(0.5, function(self, fraction)
		self:SetPoint('TOPLEFT', GeneralInfoSpline:CalculatePointOnGlobalCurve(fraction))
	end, self.noDeviceActiveAnim.Fraction, EasingUtil.OutCubic)

	local MoveSplashUp = self.noDeviceActiveAnim:CreateAnimation(1, function(self, fraction)
		self:SetPoint('CENTER', SplashSpline:CalculatePointOnGlobalCurve(fraction))
	end, self.noDeviceActiveAnim.Fraction, EasingUtil.OutCubic)

	self.deviceFocusedAnim:AddAnimations(
		{self.GeneralInfo, MoveInfoToLeft},
		{self.Splash, MoveSplashDown}
	);
	self.noDeviceActiveAnim:AddAnimations(
		{self.GeneralInfo, MoveInfoToCenter},
		{self.Splash, MoveSplashUp}
	);

	-- Setup general info
	local info = self.GeneralInfo;
	local texts, layoutIndex = {
		{
			text = Guide.CreateInfoMarkup(INFO);
			element = Guide.CreateHeader(info, LAYOUT_FRAME_WIDTH);
		};
		{
			text = CPAPI.FormatLongText(L.GFX_GENERAL_INFO);
			element = Guide.CreateText(info, LAYOUT_FRAME_WIDTH);
		};
	}, CreateCounter();

	for _, setup in ipairs(texts) do
		local element = setup.element;
		local string = element.Text or element;
		element:Show()
		element.layoutIndex = layoutIndex();
		string:SetText(setup.text)
	end
	info:Layout()
end

function Graphics:OnShow()
	self:OnFocusDevice(nil)

	local dataProvider = self.Settings:GetDataProvider()
	dataProvider:Flush()
	dataProvider:Insert(env.Elements.Title:New(GRAPHICS_LABEL))

	local numAddedDevices = 0;
	for name, device in db.Gamepad:EnumerateDevices() do
		if device.Layout then
			numAddedDevices = numAddedDevices + 1;
			dataProvider:Insert(DeviceProfile:New({
				device = device;
				varID  = ('Gamepad/Template/Gamepads/%s'):format(name);
			}));
		end
	end
end

function Graphics:SetCurrentAnimation(animToPlay, animToStop)
	if self.animToPlay == animToPlay then return end;
	self.animToPlay = animToPlay;
	animToStop:Cancel()
	animToPlay:Play()
end

function Graphics:OnFocusDevice(device)
	device = device or db.Gamepad.Active;
	if self.currentDevice == device then return end;

	db.Alpha.FadeOut(self.Splash, SWITCH_SPLASH_TIME, self.Splash:GetAlpha(), 0)
	self:SetUpdateStateTimer(function()
		db.Alpha.FadeIn(self.Splash, SWITCH_SPLASH_TIME, self.Splash:GetAlpha(), 1)

		self.DeviceInfo:SetDevice(device)
		self.SmallIcons:SetDevice(device)
		self.LargeIcons:SetDevice(device)

		local animToPlay = device and self.deviceFocusedAnim or self.noDeviceActiveAnim;
		local animToStop = device and self.noDeviceActiveAnim or self.deviceFocusedAnim;
		self:SetCurrentAnimation(animToPlay, animToStop)

		if not device then
			self.Splash:SetSize(SPLASH_DEVICE_NONE, SPLASH_DEVICE_NONE)
			return self.Splash:SetTexture(CPAPI.GetAsset([[Textures\Logo\CP]]))
		end
		self.Splash:SetSize(SPLASH_DEVICE_SIZE, SPLASH_DEVICE_SIZE)
		self.Splash:SetTexture(env:GetSplashTexture(device))
	end)
	self.currentDevice = device;
end

function Graphics:OnActiveDeviceChanged()
	local hasActiveDevice = not not db.Gamepad.Active;
	self.Continue:SetEnabled(hasActiveDevice)
	if hasActiveDevice then
		ConsolePort:SetCursorNodeIfActive(self.Continue)
	end
end

---------------------------------------------------------------
-- Add graphics to guide content
---------------------------------------------------------------
do local TutorialIncomplete, HasActiveDevice = env.TutorialPredicate('GamepadGraphics'), env.HasActiveDevice();

	local function ShowGraphicsPredicate()
		return not HasActiveDevice() or TutorialIncomplete();
	end

	Guide:AddContent('Graphics', ShowGraphicsPredicate,
	function(canvas, GetCanvas)
		if not canvas.Graphics then
			canvas.Graphics = CreateFrame('Frame', nil, canvas, 'CPGraphicsPanel')
			canvas.Graphics.GetCanvas = GetCanvas;
			CPAPI.SpecializeOnce(canvas.Graphics, Graphics)
		end
		canvas.Graphics:Show()
	end, function(canvas)
		if not canvas.Graphics then return end;
		canvas.Graphics:Hide()
	end)
end