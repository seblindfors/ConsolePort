---------------------------------------------------------------
-- Target ring
---------------------------------------------------------------
-- Displays the watched unit pool in a sliced pie, allowing
-- targeting with the radial stick while the binding is held.
-- Each unit renders a health slice, which shrinks radially
-- with the unit's remaining health.

local env, db = CPAPI.GetEnv(...);
local Ring, Unitbutton = db:Register('TargetRing', CPAPI.EventHandler(ConsolePortTargetRing)), {};
local TR_BINDING_NAME = 'CLICK ConsolePortTargetRing:LeftButton';

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Mixin(Ring, CPAPI.SecureEnvironmentMixin)
Ring.Units, Ring.Slices = {}, {};

Ring:SetAttribute(CPAPI.ActionPressAndHold, true)
Ring:SetAttribute('size', 0)
Ring:Run([[
	UNITS = newtable();
	TYPE  = %q;
]], CPAPI.ActionTypeRelease)

Ring:CreateEnvironment({
	GetHoveredUnit = [[
		if not self:IsShown() then return end;
		local index = self::GetIndex()
		return index and UNITS[index] or nil;
	]];
	OnUnitPoolChanged = [[
		local list = ...;
		UNITS = wipe(UNITS)
		for unit in list:gmatch('[^;]+') do
			UNITS[#UNITS + 1] = unit;
		end
		self::UpdateSize()
		self::SetDynamicRadius(#UNITS)
		self:CallMethod('OnUnitsChanged', list)
	]];
	SetAcceptBinding = [[
		local enabled = ...;
		local button = self:GetAttribute('acceptButton')
		for _, binding in ipairs({ self::GetBindingsForButton(button) }) do
			if enabled then
				self:SetBindingClick(true, binding, self, 'accept')
			else
				self:ClearBinding(binding)
			end
		end
	]];
	Open = [[
		self:SetAttribute('unit', nil)
		self::UpdateSize()
		self:Show()
		if not self:GetAttribute('pressAndHold') then
			self::SetAcceptBinding(true)
		end
	]];
	Commit = [[
		local index = self::GetIndex()
		local unit = index and UNITS[index] or nil;
		self:SetAttribute('unit', unit)
		self:SetAttribute(TYPE, unit and 'target' or nil)
		self::SetAcceptBinding(false)
		self:Hide()
	]];
})

Ring:Wrap('PreClick', [[
	self:SetAttribute(TYPE, nil)
	if ( button == 'accept' ) then
		if not down then self::Commit() end
	elseif self:GetAttribute('pressAndHold') then
		if down then self::Open() else self::Commit() end
	elseif not down then
		if self:IsShown() then self::Commit() else self::Open() end
	end
]])

---------------------------------------------------------------
-- Health display
---------------------------------------------------------------
local HOLE_FRACTION = 0.72;
local RIM_FRACTION  = 1.25;
local COMPACT_THRESHOLD = 32;
local CAST_SLICE_ALPHA  = 0.35;
local FLASH_SLICE_ALPHA = 0.5;
local MIN_HEALTH_FRACTION = 0.05;
local HEALTH_CURVE_SAMPLES = {0, 0.25, 0.4, 0.6, 0.8, 1};
local BG_SLICE_COLOR = CreateColor(0.3, 0.3, 0.3, 1);
local HOSTILE_COLOR  = CreateColor(0.7, 0.1, 0.1);
local NEUTRAL_COLOR  = CreateColor(0.5, 0.5, 0.5);
local GetHealthColor, GetDrainColor, UpdateSliceHealth;

local function IsHostileUnit(unit)
	return unit:match('^boss') ~= nil or unit:match('^arena') ~= nil;
end

-- Health is secret on retail and can only be transformed; the
-- slice shrinks through texture coordinates while a static hole
-- mask clips the inner spill. The rim of the art extends beyond
-- the ring frame, hence the separate rim calibration.
local function GetZoomForFraction(fraction)
	fraction = math.max(fraction, MIN_HEALTH_FRACTION);
	local outer = HOLE_FRACTION + (RIM_FRACTION - HOLE_FRACTION) * fraction;
	return 0.5 * RIM_FRACTION / outer;
end

if CPAPI.IsRetailVersion then
	local healthCurve = C_CurveUtil.CreateColorCurve();
	healthCurve:SetType(Enum.LuaCurveType.Step);
	healthCurve:AddPoint(0.0, CreateColor(0.9, 0.2, 0.2));
	healthCurve:AddPoint(0.3, CreateColor(0.9, 0.9, 0.2));
	healthCurve:AddPoint(0.7, CreateColor(0.2, 0.9, 0.2));

	function GetHealthColor(unit)
		return UnitHealthPercent(unit, false, healthCurve)
	end

	local drainCurve = C_CurveUtil.CreateColorCurve();
	drainCurve:SetType(Enum.LuaCurveType.Linear);
	drainCurve:AddPoint(0.0, CreateColor(0.5, 0.12, 0.12));
	drainCurve:AddPoint(1.0, BG_SLICE_COLOR);

	function GetDrainColor(unit)
		return UnitHealthPercent(unit, false, drainCurve)
	end

	local coordMin = C_CurveUtil.CreateCurve();
	local coordMax = C_CurveUtil.CreateCurve();
	coordMin:SetType(Enum.LuaCurveType.Linear);
	coordMax:SetType(Enum.LuaCurveType.Linear);
	for _, fraction in ipairs(HEALTH_CURVE_SAMPLES) do
		local zoom = GetZoomForFraction(fraction)
		coordMin:AddPoint(fraction, 0.5 - zoom)
		coordMax:AddPoint(fraction, 0.5 + zoom)
	end

	function UpdateSliceHealth(slice, unit)
		local min = UnitHealthPercent(unit, false, coordMin)
		local max = UnitHealthPercent(unit, false, coordMax)
		slice.Slice:SetTexCoord(min, max, min, max)
	end
else
	local function GetHealthFraction(unit)
		return UnitHealth(unit) / math.max(UnitHealthMax(unit), 1)
	end

	function GetHealthColor(unit)
		local fraction = GetHealthFraction(unit)
		return CreateColor(
			fraction < 0.7 and 0.9 or 0.2,
			fraction < 0.3 and 0.2 or 0.9,
			0.2
		);
	end

	function GetDrainColor(unit)
		local fraction = GetHealthFraction(unit)
		return CreateColor(
			0.5 - 0.2 * fraction,
			0.12 + 0.18 * fraction,
			0.12 + 0.18 * fraction
		);
	end

	function UpdateSliceHealth(slice, unit)
		local zoom = GetZoomForFraction(GetHealthFraction(unit))
		slice.Slice:SetTexCoord(0.5 - zoom, 0.5 + zoom, 0.5 - zoom, 0.5 + zoom)
	end
end

function Ring:GetUnitColor(unit)
	return IsHostileUnit(unit) and HOSTILE_COLOR
		or GetClassColorObj(CPAPI.Scrub(select(2, UnitClass(unit))))
		or NEUTRAL_COLOR;
end

function Ring:GetHealthBarColor(unit)
	return IsHostileUnit(unit) and HOSTILE_COLOR
		or db('targetRingClassColor') and GetClassColorObj(CPAPI.Scrub(select(2, UnitClass(unit))))
		or GetHealthColor(unit);
end

---------------------------------------------------------------
-- Unit button
---------------------------------------------------------------
function Unitbutton:OnAcquire()
	if not self.Portrait then
		self:SetFrameLevel(5)
		self.Portrait = self:CreateTexture(nil, 'ARTWORK')
		self.Portrait:SetAllPoints()
		self.Border = self:CreateTexture(nil, 'OVERLAY')
		self.Border:SetPoint('CENTER', -1, 0)
		CPAPI.SetAtlas(self.Border, 'ring-metallight')
		self.Role = self:CreateTexture(nil, 'OVERLAY', nil, 1)
		self:SetScript('OnEvent', self.OnEvent)
	end
end

function Unitbutton:SetButtonSize(size)
	local compact    = size < COMPACT_THRESHOLD;
	local borderSize = size * (110 / 64);
	local roleSize   = math.max(size * (compact and 0.7 or 0.3), 10);
	self:SetSize(size, size)
	self.Border:SetSize(borderSize, borderSize)
	self.Border:SetShown(not compact)
	self.Portrait:SetShown(not compact)
	self.Role:SetSize(roleSize, roleSize)
	self.Role:ClearAllPoints()
	if compact then
		self.Role:SetPoint('CENTER')
	else
		self.Role:SetPoint('BOTTOM', self, 'BOTTOM', 0, -4)
	end
end

function Unitbutton:UpdateRole()
	local role = CPAPI.Scrub(UnitGroupRolesAssigned(self.unit))
	local hasRole = role == 'TANK' or role == 'HEALER' or role == 'DAMAGER';
	self.Role:SetShown(hasRole)
	if not hasRole then return end;
	if CPAPI.IsRetailVersion then
		self.Role:SetAtlas(('roleicon-tiny-%s'):format(role == 'DAMAGER' and 'dps' or role:lower()), false)
	else
		self.Role:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])
		self.Role:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
	end
end

function Unitbutton:OnEvent(event)
	if ( event == 'UNIT_PORTRAIT_UPDATE' ) then
		SetPortraitTexture(self.Portrait, self.unit)
	else
		Ring:UpdateHealthSlice(self:GetID())
	end
end

function Unitbutton:SetUnit(unit)
	self.unit = unit;
	self:UnregisterAllEvents()
	self:RegisterUnitEvent('UNIT_HEALTH', unit)
	self:RegisterUnitEvent('UNIT_MAXHEALTH', unit)
	self:RegisterUnitEvent('UNIT_CONNECTION', unit)
	self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', unit)
	SetPortraitTexture(self.Portrait, unit)
	self.Border:SetVertexColor(Ring:GetUnitColor(unit):GetRGB())
	self:UpdateRole()
end

function Unitbutton:OnFocus()
	Ring:SetActiveSliceText(self.unit and UnitName(self.unit) or nil)
	if self.unit then
		Ring.Unitframe:SetUnit(self.unit)
	else
		Ring.Unitframe:ClearUnit()
	end
end

function Unitbutton:OnClear()
	Ring:SetActiveSliceText(nil)
	Ring.Unitframe:ClearUnit()
end

---------------------------------------------------------------
-- Ring management
---------------------------------------------------------------
local function AddHoleMask(slice)
	slice.HoleMask = slice:CreateMaskTexture()
	slice.HoleMask:SetTexture(CPAPI.GetAsset([[Textures\Pie\Pie_RingMask]]), 'CLAMPTOWHITE', 'CLAMPTOWHITE')
	slice.HoleMask:SetPoint('CENTER')
	slice.Slice:AddMaskTexture(slice.HoleMask)
end

function Ring:LayoutSlice(slice)
	local width, height = self:GetSize()
	slice:SetPoint('CENTER')
	slice:UpdateSize(width, height)
	slice:SynchronizeAnimation(self.ActiveSlice)
	if slice.HoleMask then
		slice.HoleMask:SetSize(width * HOLE_FRACTION, height * HOLE_FRACTION)
	end
end

function Ring:OnUnitsChanged(list)
	local units = wipe(self.Units)
	for unit in list:gmatch('[^;]+') do
		units[#units + 1] = unit;
	end
	self:UpdateButtons()
end

function Ring:UpdateButtons()
	if not self.radialLoaded then return end;
	self:ReleaseAll()
	self.HealthPool:ReleaseAll()
	wipe(self.Slices)

	local num = #self.Units;
	local buttonSize = self:GetItemSizeForCount(num, 56)
	self:LayoutSlice(self.CastSlice)
	self:LayoutSlice(self.FlashSlice)
	for i, unit in ipairs(self.Units) do
		local button = self:Acquire(i)
		local p, x, y = self:GetPointForIndex(i, num)
		button:OnAcquire()
		button:SetButtonSize(buttonSize)
		button:SetPoint(p, x, self.axisInversion * y)
		button:SetID(i)
		button:SetUnit(unit)
		button:Show()

		local slice = self.HealthPool:Acquire()
		slice:SetFrameLevel(2)
		if not slice.HoleMask then
			AddHoleMask(slice)
		end
		self:LayoutSlice(slice)
		slice:Show()
		self.Slices[i] = slice;
	end
	if self:IsShown() then
		self:UpdatePieSlices(true)
		for slice in self.SlicePool:EnumerateActive() do
			slice:SetColor(BG_SLICE_COLOR)
		end
	end
	for index in ipairs(self.Units) do
		self:UpdateHealthSlice(index)
	end
	self:ReseatCastSlices()
end

function Ring:ReseatCastSlices()
	if self.FlashAnim then
		self.FlashAnim:Stop()
		self.FlashSlice:Hide()
	end
	local cast = self.castInfo;
	if not cast then return end;
	local index = tIndexOf(self.Units, cast.unit)
	if index then
		cast.index = index;
		self:SeatCastSlice(self.CastSlice, index, CAST_SLICE_ALPHA)
	else
		self:EndCast()
	end
end

function Ring:UpdateHealthSlice(index)
	local slice, unit = self.Slices[index], self.Units[index];
	if not ( slice and unit ) then return end;

	slice:SetIndex(index, #self.Units)
	UpdateSliceHealth(slice, unit)

	local color = self:GetHealthBarColor(unit)
	if color then
		slice:SetVertexColor(color:GetRGB())
	end

	local drain = self:GetSlice(index)
	if drain then
		drain:SetVertexColor((IsHostileUnit(unit) and BG_SLICE_COLOR or GetDrainColor(unit)):GetRGB())
	end
end

function Ring:UpdateHealthSlices()
	for index in ipairs(self.Units) do
		self:UpdateHealthSlice(index)
	end
end

local REFRESH_INTERVAL = 0.25;
Ring:HookScript('OnUpdate', function(self, elapsed)
	local cast = self.castInfo;
	if cast then
		local progress = Clamp((GetTime() - cast.start) / cast.duration, 0, 1)
		local zoom = GetZoomForFraction(cast.channel and 1 - progress or progress)
		self.CastSlice.Slice:SetTexCoord(0.5 - zoom, 0.5 + zoom, 0.5 - zoom, 0.5 + zoom)
	end
	self.refreshTimer = (self.refreshTimer or 0) + elapsed;
	if ( self.refreshTimer < REFRESH_INTERVAL ) then return end;
	self.refreshTimer = 0;
	self:UpdateHealthSlices()
end)

---------------------------------------------------------------
-- Cast slice
---------------------------------------------------------------
function Ring:CreateCastSlice()
	local slice = CreateFrame('PieSlice', nil, self)
	slice:SetPoint('CENTER')
	slice:SetFrameLevel(3)
	slice:SetVertexColor(1, 1, 1)
	slice.Slice:SetBlendMode('ADD')
	slice:Hide()
	return slice;
end

function Ring:SeatCastSlice(slice, index, alpha)
	slice:SetAlpha(alpha)
	slice:SetIndex(index, #self.Units)
	slice:SetSeparatorColor(1, 1, 1, 0)
	slice:Show()
end

function Ring:BeginCast(isChannel)
	if not self:IsShown() then return end;
	local index = self:GetFocusIndex()
	if not ( index and self.Units[index] ) then return end;
	local name, _, _, startTimeMS, endTimeMS = (isChannel and UnitChannelInfo or UnitCastingInfo)('player')
	startTimeMS, endTimeMS = CPAPI.Scrub(startTimeMS), CPAPI.Scrub(endTimeMS)
	if not ( name and startTimeMS and endTimeMS and endTimeMS > startTimeMS ) then return end;

	local zoom = GetZoomForFraction(isChannel and 1 or 0)
	self.CastSlice.Slice:SetTexCoord(0.5 - zoom, 0.5 + zoom, 0.5 - zoom, 0.5 + zoom)
	self:SeatCastSlice(self.CastSlice, index, CAST_SLICE_ALPHA)
	self.castInfo = {
		start    = startTimeMS / 1000;
		duration = (endTimeMS - startTimeMS) / 1000;
		channel  = isChannel;
		index    = index;
		unit     = self.Units[index];
	};
end

function Ring:EndCast()
	if self.castInfo then
		self.castInfo = nil;
		self.CastSlice:Hide()
	end
end

function Ring:Flash(index)
	local slice = self.FlashSlice;
	if not self.FlashAnim then
		self.FlashAnim = slice:CreateAnimationGroup()
		local fade = self.FlashAnim:CreateAnimation('Alpha')
		fade:SetFromAlpha(FLASH_SLICE_ALPHA)
		fade:SetToAlpha(0)
		fade:SetDuration(0.4)
		fade:SetSmoothing('OUT')
		self.FlashAnim:SetScript('OnFinished', GenerateClosure(slice.Hide, slice))
	end
	self.FlashAnim:Stop()
	self:SeatCastSlice(slice, index, FLASH_SLICE_ALPHA)
	self.FlashAnim:Play()
end

function Ring:UNIT_SPELLCAST_SUCCEEDED()
	if not self:IsShown() then return end;
	local index = self.castInfo and self.castInfo.index or self:GetFocusIndex()
	self:EndCast()
	if index and self.Units[index] then
		self:Flash(index)
	end
end

function Ring:UNIT_SPELLCAST_START()         self:BeginCast(false) end
function Ring:UNIT_SPELLCAST_CHANNEL_START() self:BeginCast(true)  end
function Ring:UNIT_SPELLCAST_STOP()          self:EndCast() end
function Ring:UNIT_SPELLCAST_CHANNEL_STOP()  self:EndCast() end
function Ring:UNIT_SPELLCAST_INTERRUPTED()   self:EndCast() end

Ring:HookScript('OnHide', GenerateClosure(Ring.EndCast, Ring))

function Ring:PLAYER_ROLES_ASSIGNED()
	for button in self:EnumerateActive() do
		button:UpdateRole()
	end
end

function Ring:OnInput(x, y, len)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, #self.Units))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, self:IsValidThreshold(len))
end

function Ring:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
	if self.radialLoaded then
		self:UpdateButtons()
	end
end

function Ring:OnPrimaryStickChanged()
	if not self.radialLoaded then return end;
	self:SetSticks(db.Radial:GetStickStruct(db('targetRingPrimaryStick')))
end

function Ring:OnPressAndHoldChanged()
	self:SetAttribute('pressAndHold', db('targetRingPressAndHold'))
end

function Ring:OnAcceptButtonChanged()
	self:SetAttribute('acceptButton', db('targetRingAcceptButton'))
end

function Ring:OnPositionChanged()
	local pos = db('targetRingPosition')
	self:ClearAllPoints()
	self:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
end

function Ring:RegisterEvents()
	for _, event in ipairs({
		'UNIT_SPELLCAST_START',
		'UNIT_SPELLCAST_STOP',
		'UNIT_SPELLCAST_SUCCEEDED',
		'UNIT_SPELLCAST_INTERRUPTED',
		'UNIT_SPELLCAST_CHANNEL_START',
		'UNIT_SPELLCAST_CHANNEL_STOP',
	}) do self:RegisterUnitEvent(event, 'player') end
	self:RegisterEvent('PLAYER_ROLES_ASSIGNED')
end

function Ring:UpdateActiveState()
	local active = not db('lazyLoadingEnable') or not not db.Gamepad:GetBindingKey(TR_BINDING_NAME)
	if ( active == self.isActiveComponent ) then return end;
	self.isActiveComponent = active;
	if active then
		if not self.radialLoaded then
			self.radialLoaded = true;
			local sticks = db.Radial:GetStickStruct(db('targetRingPrimaryStick'))
			db.Radial:Register(self, 'TargetRing', {
				sticks = sticks;
				sizer  = [[
					local size = #UNITS;
				]];
			});
			self:CreateFramePool(nil, Unitbutton)
			self.HealthPool = CreateFramePool('PieSlice', self)
			self.CastSlice  = self:CreateCastSlice()
			self.FlashSlice = self:CreateCastSlice()
			self.Unitframe  = self:CreateUnitframe()
			AddHoleMask(self.CastSlice)
			self:OnAxisInversionChanged()
			self:OnPressAndHoldChanged()
			self:OnAcceptButtonChanged()
			self:OnPositionChanged()
		end
		self:RegisterEvents()
		env.UnitPool:RegisterConsumer(self, 'TargetRing')
	else
		env.UnitPool:UnregisterConsumer('TargetRing')
		self:UnregisterAllEvents()
		for button in self:EnumerateActive() do
			button:UnregisterAllEvents()
		end
		self:ReleaseAll()
		if self.HealthPool then
			self.HealthPool:ReleaseAll()
			self.Unitframe:ClearUnit()
		end
		wipe(self.Slices)
		wipe(self.Units)
	end
end

---------------------------------------------------------------
-- Events and callbacks
---------------------------------------------------------------
db:RegisterSafeCallbacks(Ring.UpdateActiveState, Ring,
	'OnNewBindings',
	'Settings/lazyLoadingEnable'
);
db:RegisterSafeCallback('Settings/radialCosineDelta', Ring.OnAxisInversionChanged, Ring)
db:RegisterSafeCallbacks(Ring.OnPrimaryStickChanged, Ring,
	'Settings/radialPrimaryStick',
	'Settings/targetRingPrimaryStick'
);
db:RegisterCallback('Settings/targetRingClassColor', Ring.UpdateHealthSlices, Ring)
db:RegisterSafeCallback('Settings/targetRingPressAndHold', Ring.OnPressAndHoldChanged, Ring)
db:RegisterSafeCallback('Settings/targetRingAcceptButton', Ring.OnAcceptButtonChanged, Ring)
db:RegisterSafeCallback('Settings/targetRingPosition', Ring.OnPositionChanged, Ring)

Ring:HookScript('OnShow', GenerateClosure(Ring.UpdateButtons, Ring))
Ring:HookScript('PreClick', function(self)
	if not self.isActiveComponent then
		db('Settings/lazyLoadingEnable', false)
		CPAPI.Log('Lazy loading has been disabled to activate the target ring.')
	end
end)
