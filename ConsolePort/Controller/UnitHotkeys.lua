---------------------------------------------------------------
-- UnitHotkeys.lua: Combo shortcuts for targeting
---------------------------------------------------------------
-- Creates a set of combinations for different pools of units,
-- in order to alleviate targeting. A healer's delight.
-- Thanks to Yoki for original concept! :)

local _, db = ...;
---------------------------------------------------------------
local NUM_COMBO_BUTTONS    = 8;
local UNIT_DRIVER_FORMAT   = '[@%s,exists] 1; %s';
local UNIT_DRIVER_UPDATE   = 'units[%q][%q] = newstate; self:RunAttribute("RefreshUnits")';
local UNIT_DRIVER_CLLBCK   = '_onstate-%s';
local UNIT_POOL_DELIMITER  = '[^;]+';
local UNIT_RANGE_DELIMITER = '-';
local UNIT_TOKEN_GMATCH    = '(%a+)(%d+)%'..UNIT_RANGE_DELIMITER..'?(%d*)(.*)';
local UH_BINDING_NAME      = 'CLICK ConsolePortEasyMotionButton:LeftButton';
local INPUT_SEQ_DELIMITER  = '%d';
local INPUT_SEQ_FILTER     = '^%s';

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local SetEvaluator = {};
SetEvaluator.Left = function() return {
	'PADDDOWN';
	'PADDRIGHT';
	'PADDLEFT';
	'PADDUP';
} end
SetEvaluator.Right = function() return {
	'PAD1';
	'PAD2';
	'PAD3';
	'PAD4';
} end
SetEvaluator.Custom = function()
	local set, colors = {}, {};
	for i=1, NUM_COMBO_BUTTONS do
		local buttonID = db('unitHotkeyButton'..i)
		if buttonID and buttonID:match('^PAD') then
			local index = #set + 1;
			set[index] = buttonID;
			local color = db('unitHotkeyColor'..i)
			colors[tostring(index)] = CPAPI.CreateColorFromHexString(color);
		end
	end
	return set, colors;
end
SetEvaluator.Dynamic = function()
	local left   = SetEvaluator.Left()
	local right  = SetEvaluator.Right()
	local binding = db.Gamepad:GetBindingKey(UH_BINDING_NAME)
	if binding then
		local key = binding:match('[^%-]+$')
		-- Pick the opposite side of the controller to the binding
		-- since most people only have two thumbs.
		if tContains(left, key) then
			return right;
		elseif tContains(right, key) then
			return left;
		end
	end
	return SetEvaluator.Custom();
end

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
local UH    = Mixin(CPAPI.EventHandler(ConsolePortEasyMotionButton, {'PLAYER_ENTERING_WORLD'}), CPAPI.SecureEnvironmentMixin)
local Scan  = db.Scan;
local Input = ConsolePortEasyMotionInput;
UH.UnitDrivers, UH.UnitFrames = {}, {};

UH:Run([[bindRef = %q;
	-- Unit and binding tables
	units, sorted, lookup = newtable(), newtable(), newtable()
]], ConsolePortEasyMotionInput:GetName())

UH:CreateEnvironment({
	[CPAPI.ActionTypeRelease] = 'macro';
	-- Parse the input
	Input = [[
		key = ...;
		input = math.min(0xFFFF, input and tonumber( input .. key ) or tonumber(key));
		self:::Filter(tostring(input))
		if useInstant then
			return self::GetCommand()
		end
	]];

	GenerateSequences = [[
		-- Sequences used to assign units to bindings (cap at 3 keys)
		local keys = {};
		for i = self:GetAttribute('numkeys'), 1, -1 do
			tinsert(keys, i)
		end
		sequence = newtable();
		local current = 1;
		for _, k1 in ipairs(keys) do
			sequence[current] = tonumber(k1)
			current = current + 1
			for _, k2 in ipairs(keys) do
				sequence[current] = tonumber(k2 .. k1)
				current = current + 1
				for _, k3 in ipairs(keys) do
					sequence[current] = tonumber(k3 .. k2 .. k1)
					current = current + 1
				end
			end
		end
		table.sort(sequence)
	]];

	RefreshUnits = [[
		self::SortUnits()
		self::AssignUnits()
		if isActive then
			self::ClearInput()
			self:::SecureRefreshDisplayBindings()
		end
	]];

	SortUnits = ([[
		local pool, c = self:GetAttribute('unitpool'), 0;
		local hasBeenInserted = {};
		sorted = wipe(sorted)

		if ( not pool or pool:len() == 0 ) then
			for group in pairs(units) do
				for unit in pairs(group) do
					if not hasBeenInserted[unit] then
						hasBeenInserted[unit] = true;
						table.insert(sorted, unit)
					end
				end
			end
			return table.sort(sorted)
		end

		for group in pool:gmatch(%q) do
			local set = {};
			for unit in pairs(units[group]) do
				if not hasBeenInserted[unit] then
					hasBeenInserted[unit] = true;
					table.insert(set, unit)
				end
			end
			table.sort(set)
			for i, unit in ipairs(set) do
				sorted[c + i] = unit;
			end
			c = #sorted;
		end
	]]):format(UNIT_POOL_DELIMITER);

	AssignUnits = [[
		lookup = wipe(lookup)
		for i, unit in ipairs(sorted) do
			local binding = sequence[i];
			if binding then
				lookup[binding] = unit;
				if UnitExists(unit) then
					self:::AssignUnit(binding, unit)
				end
			end
		end
	]];

	GetCommand = [[
		local unit, macrotext = lookup[input];
		if unit then
			local prefix = useFocus and '/focus' or '/target';
			macrotext = prefix..' '..unit;
		elseif defaultToScan then
			macrotext = '/targetenemy';
		else
			macrotext = useFocus and '/clearfocus' or nil;
		end
		return macrotext, unit;
	]];

	SetTarget = [[
		local macrotext, unit = self::GetCommand()
		if not useInstant then
			self:SetAttribute('macrotext', macrotext)
		end
		self:::FinalizeBindings(unit)
		self::Clear()
	]];

	Clear = [[
		self::ClearInput()
		self:ClearBindings()
	]];

	ClearInput = [[
		input = nil;
	]];

	SetBindings = [[
		local modifier = self:GetAttribute('modifier')
		for i=1, self:GetAttribute('numkeys') do
			local binding = self:GetAttribute(tostring(i))
			if binding then
				self:SetBindingClick(true, modifier..binding, bindRef, tostring(i))
			end
		end
	]];
})

UH:Wrap('PreClick', [[
	isActive = down;
	self:SetAttribute('macrotext', nil)
	if not down then
		if defaultToScan then
			self:::EndTargetScan()
		end
		return self::SetTarget()
	elseif defaultToScan then
		self:::StartTargetScan()
		self:SetAttribute('macrotext', '/targetenemy')
	end

	self::SetBindings()
	self:::DisplayBindings()
]])

UH:Hook(Input, 'PreClick', [[
	self:SetAttribute('macrotext', nil)
	if down then
		local command = owner::Input(button)
		if command then
			self:SetAttribute('macrotext', command)
		end
	end
]])

---------------------------------------------------------------
-- Target scanning
---------------------------------------------------------------
function UH:StartTargetScan()
	TargetPriorityHighlightStart(false)
end

function UH:EndTargetScan()
	TargetPriorityHighlightEnd()
end

---------------------------------------------------------------
-- Data handling
---------------------------------------------------------------
function UH:OnDataLoaded()
	self:OnDisplaySettingsChanged()
	self:OnTargetSettingsChanged()
	return CPAPI.BurnAfterReading;
end

function UH:PLAYER_ENTERING_WORLD()
	self:OnUnitPoolChanged()
end

function UH:OnDisplaySettingsChanged()
	self.display = {
		alpha   = db('unitHotkeyGhostAlpha') or 0.5;
		anchor  = db('unitHotkeyAnchor')     or 'CENTER';
		offsetX = db('unitHotkeyOffsetX')    or 0;
		offsetY = db('unitHotkeyOffsetY')    or 0;
		redraw  = db('unitHotkeyGhostMode')  or false;
		size    = db('unitHotkeySize')       or 32;
		level   = db('unitHotkeyOffsetFL')   or 10;
		plates  = db('unitHotkeyNamePlates') or false;
	};
	for hotkey in self.Hotkeys:EnumerateActive() do
		hotkey:OnDisplayUpdated()
	end
end

function UH:OnModifiersChanged()
	UnregisterAttributeDriver(self, 'modifier')
	RegisterAttributeDriver(self, 'modifier', db('Gamepad/Index/Modifier/Driver'))
end

function UH:OnTargetSettingsChanged()
	for key, varID in pairs({
		useFocus      = 'unitHotkeyFocusMode';
		useInstant    = 'unitHotkeyInstantMode';
		defaultToScan = 'unitHotkeyDefaultMode';
	}) do
		self:SetAttribute(key, db(varID))
		self:Run([[%s = self:GetAttribute(%q)]], key, key)
	end
end

function UH:OnUnitPoolChanged()
	self:ClearWatchedUnits()

	-- Reparse the unit pool and rebuild the unit drivers
	local tokens = db('unitHotkeyTokens')
	local static = db('unitHotkeyStaticMode')
	self.driverFallback = static and '0' or 'nil';
	self:SetAttribute('unitpool', tokens)
	self:SetAttribute('useStatic', static)
	self:Execute('units = wipe(units)')
	for token in tokens:gmatch(UNIT_POOL_DELIMITER) do
		self:ParseToken(token, token)
	end

	-- Reparse the hotkey set and rebuild the hotkey buttons
	local evaluator = SetEvaluator[db('unitHotkeySet')]
	assert(evaluator, 'Invalid hotkey set: '..tostring(db('unitHotkeySet')))
	local keys, colors = evaluator()
	for i, key in ipairs(keys) do
		self:SetAttribute(tostring(i), key)
	end
	self.colors = colors or {};
	self:SetAttribute('numkeys', #keys)

	-- Refresh active units
	self:Run([[
		self::GenerateSequences()
		self::RefreshUnits()
	]])
end

function UH:ParseToken(token, group)
	local hasRangeToResolve = token:find(UNIT_RANGE_DELIMITER)
	if hasRangeToResolve then
		for unitID, n, range, rest in token:gmatch(UNIT_TOKEN_GMATCH) do
			hasRangeToResolve, n, range = true, tonumber(n), tonumber(range);
			for i = n, range or n do
				self:ParseToken(unitID..i..rest, group)
			end
		end
	end
	if not hasRangeToResolve then
		self:AddUnitToWatch(token, group)
	end
end

function UH:ClearWatchedUnits()
	for unitID in pairs(self.UnitDrivers) do
		UnregisterStateDriver(self, unitID)
		self:SetAttribute(UNIT_DRIVER_CLLBCK:format(unitID), nil)
	end
	wipe(self.UnitDrivers)
end

function UH:AddUnitToWatch(unitID, group) unitID = unitID:trim();
	if self.UnitDrivers[unitID] then
		return false;
	end
	local driver = UNIT_DRIVER_FORMAT:format(unitID, self.driverFallback)
	self.UnitDrivers[unitID] = true;
	self:Run([[
		local unitID, group, driver = %q, %q, %q;
		units[group] = units[group] or {};
		units[group][unitID] = tonumber((SecureCmdOptionParse(driver)));
	]], unitID, group, driver)
	RegisterStateDriver(self, unitID, driver)
	self:SetAttribute(UNIT_DRIVER_CLLBCK:format(unitID), UNIT_DRIVER_UPDATE:format(group, unitID))
	return true;
end

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------
db:RegisterSafeCallbacks(UH.OnTargetSettingsChanged, UH,
	'Settings/unitHotkeyFocusMode',
	'Settings/unitHotkeyDefaultMode',
	'Settings/unitHotkeyInstantMode'
);
db:RegisterSafeCallbacks(UH.OnModifiersChanged, UH,
	'Gamepad/Active',
	'OnModifierChanged'
);
db:RegisterSafeCallbacks(UH.OnUnitPoolChanged, UH,
	'OnNewBindings',
	'Settings/unitHotkeySet',
	'Settings/unitHotkeyTokens',
	'Settings/unitHotkeyStaticMode',
	(function(n)
		local res = {};
		for i=1, n do
			res[#res+1] = 'Settings/unitHotkeyButton'..i
			res[#res+1] = 'Settings/unitHotkeyColor'..i
		end
		return unpack(res)
	end)(NUM_COMBO_BUTTONS)
);

db:RegisterCallbacks(UH.OnDisplaySettingsChanged, UH,
	'Settings/unitHotkeySize',
	'Settings/unitHotkeyOffsetX',
	'Settings/unitHotkeyOffsetY',
	'Settings/unitHotkeyOffsetFL',
	'Settings/unitHotkeyAnchor',
	'Settings/unitHotkeyGhostMode',
	'Settings/unitHotkeyGhostAlpha',
	'Settings/unitHotkeyNamePlates'
);

---------------------------------------------------------------
-- Frontend frame tracking
---------------------------------------------------------------
function UH:AssignUnit(binding, unitID)
	self.UnitDrivers[unitID] = binding;
	self:QueueUnitFrameRefresh()
end

function UH:RefreshUnitFrames()
	local cache = Scan:GetCache(Scan.UnitFrames)
	for frame, unitID in pairs(cache) do
		if self.UnitDrivers[unitID] then
			self:AddTrackedUnitFrame(unitID, frame)
		end
	end
end

function UH:ClearUnitFrames()
	self.Hotkeys:ReleaseAll()
	wipe(self.UnitFrames)
end

function UH:ReleaseHotkey(hotkey)
	self.UnitFrames[hotkey.unitID][hotkey.frame] = nil;
	self.Hotkeys:Release(hotkey)
end

function UH:AddTrackedUnitFrame(unitID, frame)
	local frames = self.UnitFrames;
	local hotkey = self.Hotkeys:Acquire()
	frames[unitID] = frames[unitID] or {};
	frames[unitID][frame] = hotkey;
	hotkey.frame  = frame;
	hotkey.unitID = unitID;
end

function UH:TryAddNamePlateForUnit(unitID)
	if not self.display.plates then return end;

	local plate = self:GetNamePlateForUnit(unitID)
	local frame = plate and plate.UnitFrame;
	if frame and CPAPI.Scrub(UnitIsUnit(frame:GetAttribute('unit'), unitID)) then
		self:AddTrackedUnitFrame(unitID, frame)
	end
end

function UH:GetUnitFramesForUnit(unitID)
	return pairs(self.UnitFrames[unitID] or {})
end

function UH:GetActiveUnitIDs()
	return pairs(tFilter(self.UnitDrivers, tonumber))
end

function UH:GetNamePlateForUnit(unitID)
	local retOK, plate = pcall(C_NamePlate.GetNamePlateForUnit, unitID)
	if retOK then
		return plate;
	end
end

---------------------------------------------------------------
-- Frontend display
---------------------------------------------------------------
function UH:RefreshAll()
	self:ClearUnitFrames()
	self:RefreshUnitFrames()
	self:RedrawBindings()
end

function UH:DisplayBindings()
	for unitID, binding in self:GetActiveUnitIDs() do
		self:TryAddNamePlateForUnit(unitID)
		for frame, hotkey in self:GetUnitFramesForUnit(unitID) do
			hotkey:SetBinding(binding)
			hotkey:SetUnitFrame(frame)
			hotkey:SetAlpha(1)
		end
	end
end

function UH:FinalizeBindings(matchedUnitID)
	local redrawOnFinish, redrawAlpha = self.display.redraw, self.display.alpha;
	for unitID, binding in self:GetActiveUnitIDs() do
		if ( unitID == matchedUnitID ) then
			for frame, hotkey in self:GetUnitFramesForUnit(unitID) do
				hotkey:AnimateFullMatch(redrawOnFinish)
			end
		else
			for frame, hotkey in self:GetUnitFramesForUnit(unitID) do
				hotkey:Clear()
				if redrawOnFinish then
					hotkey:SetBinding(binding)
					hotkey:SetUnitFrame(frame)
					hotkey:SetAlpha(redrawAlpha)
				end
			end
		end
	end
end

function UH:RedrawBindings()
	if not self.display.redraw then return end;
	for unitID, binding in self:GetActiveUnitIDs() do
		for frame, hotkey in self:GetUnitFramesForUnit(unitID) do
			hotkey:SetBinding(binding)
			hotkey:SetUnitFrame(frame)
			hotkey:SetAlpha(self.display.alpha)
		end
	end
end

function UH:Filter(input)
	local filter = INPUT_SEQ_FILTER:format(input)
	for hotkey in self.Hotkeys:EnumerateActive() do
		if hotkey:Match(filter) then
			hotkey:Filter(input)
		else
			hotkey:Clear()
		end
	end
end

---------------------------------------------------------------
-- Frontend async updates
---------------------------------------------------------------
UH.QueueDisplayBindings = CPAPI.Debounce(UH.DisplayBindings, UH)
UH.QueueUnitFrameRefresh = CPAPI.Debounce(UH.RefreshAll, UH)
db:RegisterCallback('OnScanUpdate', UH.RefreshAll, UH)

function UH:SecureRefreshDisplayBindings()
	self:QueueDisplayBindings()
end

---------------------------------------------------------------
-- Hotkey display
---------------------------------------------------------------
local HotkeyMixin = {};

function HotkeyMixin:Init()
	Mixin(self, HotkeyMixin)
	self.textures = {};
end

function HotkeyMixin:Clear()
	self:ReleaseTextures()
	self:SetParent(UH)
	self:SetFrameLevel(1)
	self:SetScale(1)
	self:ClearAllPoints()
	self:Hide()
end

function HotkeyMixin:Adjust(depth)
	local offset = depth and #self.textures + depth or #self.textures;
	self:SetWidth( offset * UH.display.size * 0.75 )
end

function HotkeyMixin:Match(filter)
	return tostring(self.binding):match(filter)
end

function HotkeyMixin:Filter(input)
	for i=1, Clamp(#input, 0, #self.textures) do
		self.textures[i]:SetAlpha(0.5)
	end
	self:AnimatePartialMatch(#input)
end

function HotkeyMixin:ReleaseTextures()
	for _, texture in pairs(self.textures) do
		UH.Textures:Release(texture)
	end
	wipe(self.textures)
end

local SetIconToTexture = db.Gamepad.SetIconToTexture;
function HotkeyMixin:AcquireTexture(id, size)
	local texture = UH.Textures:Acquire()
	tinsert(self.textures, texture)
	texture.id = id;
	texture:Show()
	texture:SetAlpha(1)
	texture:SetParent(self)
	texture:SetSize(size, size)
	SetIconToTexture(texture, UH:GetAttribute(id), 32, {size, size}, {size * 0.75, size * 0.75})

	local color = UH.colors[id];
	if color then
		texture:SetVertexColor(color:GetRGB())
	else
		texture:SetVertexColor(1, 1, 1)
	end
	return texture;
end

function HotkeyMixin:SetBinding(binding)
	self.binding = binding;
	self:DrawIconsForBinding(binding)
end

function HotkeyMixin:DrawIconsForBinding(binding)
	binding = binding or self.binding;
	if not binding then return end;
	self:StopAnimations()
	self:ReleaseTextures()

	local shownIcons, size, texture = 0, UH.display.size;
	for id in tostring(binding):gmatch(INPUT_SEQ_DELIMITER) do
		texture, shownIcons = self:AcquireTexture(id, size), shownIcons + 1;
		texture:SetPoint('LEFT', (shownIcons - 1) * (size * 0.75), 0)
	end
	self:Adjust()
end

do	-- Need this strata translation to ensure hotkeys are always above the unit frame,
	-- which in the case of compact unit frames requires to be a strata above.
	local strataMap = CPAPI.Enum(
		'BACKGROUND', 'LOW', 'MEDIUM', 'HIGH', 'DIALOG',
		'FULLSCREEN', 'FULLSCREEN_DIALOG', 'TOOLTIP'
	);
	local strataIndex = CPAPI.Proxy({strataMap()}, CPAPI.Static('TOOLTIP'));

	local function GetHigherStrata(strata)
		return strataIndex[strataMap[strata] + 1];
	end

	function HotkeyMixin:SetUnitFrame(frame)
		if frame and frame:IsVisible() then
			self:SetParent(UIParent)
			self:SetPoint(UH.display.anchor, frame, UH.display.anchor, UH.display.offsetX, UH.display.offsetY)
			self:SetFrameStrata(GetHigherStrata(frame:GetFrameStrata()))
			self:SetFrameLevel(Clamp(frame:GetFrameLevel() + UH.display.level, 0, 10000))
			self:SetScale(1)
			self:Show()
		end
	end
end

---------------------------------------------------------------
-- Hotkey pools
---------------------------------------------------------------
UH.Textures = CreateTexturePool(UH, 'OVERLAY')
UH.Hotkeys = CreateFramePool('Frame', UH, 'CPUnitHotkeyTemplate',
	function(pool, hotkey) hotkey:Clear() end, false, HotkeyMixin.Init)

-- Periodically clear hotkeys for frames that are no longer visible
C_Timer.NewTicker(1, GenerateClosure(function(self)
	local hotkeysToRelease = {};
	for hotkey in self.Hotkeys:EnumerateActive() do
		if ( hotkey.unitID and hotkey.frame and not hotkey.frame:IsVisible() ) then
			tinsert(hotkeysToRelease, hotkey)
		end
	end
	for i, hotkey in ipairs(hotkeysToRelease) do
		self:ReleaseHotkey(hotkey)
	end
end, UH))

---------------------------------------------------------------
-- Hotkey animations
---------------------------------------------------------------
local AnimationScriptMixin = {};

function HotkeyMixin:AnimatePartialMatch(showOnIndex)
	local target = self.textures[showOnIndex];
	if not target then return end;

	if not self.PartialMatch then
		self.PartialMatch = self:CreateAnimationGroup(nil, 'CPUnitHotkeyFilterAnimTemplate')
	end
	self.PartialMatch.Enlarge:SetTarget(target)
	self.PartialMatch.Alpha:SetTarget(target)
	self:StopAnimations()
	self.PartialMatch:Play()
end

function HotkeyMixin:AnimateFullMatch(redrawOnFinish)
	if not self.FullMatch then
		self.FullMatch = self:CreateAnimationGroup(nil, 'CPUnitHotkeyMatchAnimTemplate')
		Mixin(self.FullMatch, AnimationScriptMixin)
	end
	local script = redrawOnFinish and self.FullMatch.OnFinishRedraw or self.FullMatch.OnFinishClear;
	self.FullMatch:SetScript('OnFinished', script)
	self:StopAnimations()
	self.FullMatch:Play()
end

function HotkeyMixin:StopAnimations()
	if self.PartialMatch then
		self.PartialMatch:Stop()
		self.PartialMatch:Finish()
	end
	if self.FullMatch then
		self.FullMatch:Stop()
		self.FullMatch:Finish()
	end
end

function HotkeyMixin:OnDisplayUpdated()
	self:Clear()
	if self.frame and self.binding then
		self:SetBinding(self.binding)
		self:SetUnitFrame(self.frame)
	end
end

function AnimationScriptMixin:OnFinishClear()
	self:GetParent():Clear()
end

function AnimationScriptMixin:OnFinishRedraw()
	local parent = self:GetParent();
	parent:OnDisplayUpdated()
	parent:SetAlpha(UH.display.alpha)
end