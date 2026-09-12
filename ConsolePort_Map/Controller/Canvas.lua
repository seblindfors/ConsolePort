local env, db, _, L = CPAPI.GetEnv(...);
local InCombatLockdown, secureexecuterange = InCombatLockdown, secureexecuterange;
---------------------------------------------------------------
-- Canvas: a ConsolePort-owned MapCanvas instance
---------------------------------------------------------------
-- Built at runtime from Blizzard_MapCanvas (loaded on demand), never
-- through XML, so the module carries no template dependency. The three
-- lifecycle methods are owned to keep ClearCachedActivitiesForPlayer
-- out of our execution, refresh is deferred in combat because pin
-- acquisition calls the protected SetPassThroughButtons, and every pin
-- passes through the sanitiser below.
local Canvas = {}; env.CanvasMixin = Canvas;

local function nop() end
local function no() return false end

---------------------------------------------------------------
-- Profiler
---------------------------------------------------------------
-- /cpmapperf toggles per-frame timing of the canvas work that runs on
-- every scale or pan change, printed every two seconds with pin count.
local Profile = { enabled = false, buckets = {}, frames = 0 };
env.Profile = Profile;

local debugprofilestop = debugprofilestop;
local function Measure(name, fn, self, ...)
	if not Profile.enabled then return fn(self, ...) end
	local start = debugprofilestop()
	fn(self, ...)
	Profile.buckets[name] = (Profile.buckets[name] or 0) + (debugprofilestop() - start)
end

function Profile:Report(canvas)
	if self.frames == 0 then return end
	local pins = 0;
	for _ in canvas:EnumeratePins() do pins = pins + 1 end
	local lines, total = {}, 0;
	for name, ms in pairs(self.buckets) do
		total = total + ms;
		lines[#lines + 1] = ('%s %.2f'):format(name, ms / self.frames)
	end
	table.sort(lines)
	CPAPI.Log('Map perf: %d pins, %d frames, %.2f ms/frame total | %s', pins, self.frames, total / self.frames, table.concat(lines, ', '))
	wipe(self.buckets)
	self.frames = 0;
end

function env:ToggleProfiler()
	Profile.enabled = not Profile.enabled;
	wipe(Profile.buckets)
	Profile.frames = 0;
	if Profile.ticker then Profile.ticker = Profile.ticker:Cancel() end
	if Profile.enabled then
		Profile.ticker = C_Timer.NewTicker(2, function()
			local canvas = env.Map and env.Map:GetActiveCanvas()
			if canvas and canvas:IsShown() then Profile:Report(canvas) end
		end)
	end
	CPAPI.Log('Map profiler %s.', Profile.enabled and 'enabled' or 'disabled')
end

---------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------
function Canvas:OnUpdate(elapsed)
	if Profile.enabled then Profile.frames = Profile.frames + 1 end
	if self.UpdatePinSuppression then
		Measure('suppression', self.UpdatePinSuppression, self)
	end
	Measure('nudging', self.UpdatePinNudging, self)
	if self.RunDataProviderOnUpdate and not InCombatLockdown() then
		Measure('providerUpdate', self.RunDataProviderOnUpdate, self)
	end
	if self.OnInputUpdate then
		Measure('input', self.OnInputUpdate, self, elapsed)
	end
end

function Canvas:OnCanvasScaleChanged()
	Measure('scaleChanged', MapCanvasMixin.OnCanvasScaleChanged, self)
end

if MapCanvasMixin.OnCanvasPanChanged then
	function Canvas:OnCanvasPanChanged()
		Measure('panChanged', MapCanvasMixin.OnCanvasPanChanged, self)
	end
end

local function CallOnProviders(method)
	return function(dataProvider) dataProvider[method](dataProvider) end
end

function Canvas:OnShow()
	if InCombatLockdown() then
		self.pendingRefresh = true;
	else
		self:RefreshAll(true)
	end
	secureexecuterange(self.dataProviders, CallOnProviders('OnShow'))
	self:RegisterEvent('HANDLE_UI_ACTION')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	if self.OnInputShow then self:OnInputShow() end
end

function Canvas:OnHide()
	self:UnregisterEvent('HANDLE_UI_ACTION')
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	secureexecuterange(self.dataProviders, CallOnProviders('OnHide'))
	if self.OnInputHide then self:OnInputHide() end
end

function Canvas:OnMapChanged()
	if InCombatLockdown() then
		self.pendingRefresh = true;
		return
	end
	secureexecuterange(self.dataProviders, CallOnProviders('OnMapChanged'))
end

function Canvas:OnEvent(event, ...)
	if event == 'PLAYER_REGEN_ENABLED' then
		if self.pendingRefresh and self:IsShown() then
			self.pendingRefresh = nil;
			self:RefreshAll()
		end
		return
	end
	if InCombatLockdown() then
		self.pendingRefresh = true;
		return
	end
	MapCanvasMixin.OnEvent(self, event, ...)
end

function Canvas:RefreshAllDataProviders(fromOnShow)
	for dataProvider in pairs(self.dataProviders) do
		local ok, err = pcall(dataProvider.RefreshAllData, dataProvider, fromOnShow)
		if not ok and not self.reportedErrors[dataProvider] then
			self.reportedErrors[dataProvider] = true;
			CPAPI.Log('Map provider failed to refresh: %s', tostring(err))
		end
	end
end

---------------------------------------------------------------
-- Pin sanitiser
---------------------------------------------------------------
local PinOverrides = {
	UseMapLegend          = no;
	OnLegendPinMouseEnter = nop;
	OnLegendPinMouseLeave = nop;
	GetPingWorldMap       = no;
};

local POIButtonOverrides = {
	GetQuestClassification = function(self)
		local questID = self:GetQuestID()
		return questID and C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification(questID) or nil;
	end;
};

local function SanitizePin(pin, template)
	if pin.cpSanitized then return end
	local capturedHandler = pin.UpdateTooltip ~= nil and pin.UpdateTooltip == pin.OnMouseEnter;
	Mixin(pin, PinOverrides)
	if pin.UpdateButtonStyle and pin.GetQuestID then
		Mixin(pin, POIButtonOverrides)
	end
	pin:SetScript('OnEnter', nil)
	pin:SetScript('OnLeave', nil)
	pin:SetMouseMotionEnabled(false)
	pin:SetMouseClickEnabled(false)
	if capturedHandler then
		pin.UpdateTooltip = nil;
	end
	pin.cpUpdateTooltip = pin.UpdateTooltip;
	pin.cpSanitized = true;
end

function Canvas:AcquirePin(template, ...)
	local pin = MapCanvasMixin.AcquirePin(self, template, ...)
	if pin then SanitizePin(pin, template) end
	return pin;
end

---------------------------------------------------------------
-- Pin enumeration
---------------------------------------------------------------
local NOT_FOCUSABLE = {
	QuestBlobPinTemplate      = true;
	ScenarioBlobPinTemplate   = true;
	FogOfWarPinTemplate       = true;
	MapExplorationPinTemplate = true;
	GroupMembersPinTemplate   = true;
	MapHighlightPinTemplate   = true;
	ZoneLabelPinTemplate      = true;
};

function Canvas:EnumeratePins()
	local pools = self.pinPools;
	local template, pool = next(pools)
	local iter, state, pin;
	if pool then iter, state, pin = pool:EnumerateActive() end
	return function()
		while pool do
			pin = iter(state, pin)
			if pin then return pin end
			template, pool = next(pools, template)
			if pool then iter, state, pin = pool:EnumerateActive() end
		end
	end
end

function Canvas:IsPinFocusable(pin)
	return pin:IsShown() and pin.normalizedX ~= nil and not NOT_FOCUSABLE[pin.pinTemplate];
end

---------------------------------------------------------------
-- Construction
---------------------------------------------------------------
function env:LoadBlizzardMap()
	for _, addon in ipairs(env.Const.BlizzardAddOns) do
		local loaded, reason = CPAPI.LoadAddOn(addon)
		if not loaded then
			CPAPI.Log('Failed to load %s. Reason: %s', addon, tostring(_G['ADDON_'..tostring(reason)] or reason))
			return false;
		end
	end
	return true;
end

function env:CreateCanvas(frameName, parent, providers, ...)
	local canvas = CreateFrame('Frame', frameName, parent)
	canvas:SetAllPoints(parent)
	canvas:EnableMouse(false)
	canvas:Hide()
	Mixin(canvas, MapCanvasMixin, Canvas, ...)
	canvas.debugInspectionSystem = 'MapCanvas';
	canvas.reportedErrors = {};

	canvas.ScrollContainer = CreateFrame('ScrollFrame', nil, canvas, 'MapCanvasFrameScrollContainerTemplate')
	canvas.ScrollContainer:ClearAllPoints()
	canvas.ScrollContainer:SetAllPoints(canvas)
	canvas.ScrollContainer:EnableMouse(false)
	canvas.ScrollContainer:EnableMouseWheel(false)
	canvas.BorderFrame = CreateFrame('Frame', nil, canvas)
	canvas.BorderFrame:SetAllPoints()

	canvas:SetScript('OnEvent', canvas.OnEvent)
	canvas:SetScript('OnShow', canvas.OnShow)
	canvas:SetScript('OnHide', canvas.OnHide)
	canvas:SetScript('OnUpdate', canvas.OnUpdate)
	MapCanvasMixin.OnLoad(canvas)

	-- 'scroll' is the controller's lerp step and includes the nested
	-- scaleChanged/panChanged buckets it triggers.
	local scrollUpdate = canvas.ScrollContainer:GetScript('OnUpdate')
	canvas.ScrollContainer:SetScript('OnUpdate', function(scrollContainer, elapsed)
		Measure('scroll', scrollUpdate, scrollContainer, elapsed)
	end)

	canvas:SetShouldZoomInOnClick(false)
	canvas:SetShouldPanOnClick(false)
	canvas:SetShouldNavigateOnClick(false)
	canvas:SetMouseWheelZoomMode(MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE)

	local own = env.Providers:GetOwnMixins()
	canvas.attached = {};
	for _, entry in ipairs(providers) do
		local mixinName, setup = entry, nil;
		if type(entry) == 'table' then mixinName, setup = entry[1], entry[2] end
		local mixin = own[mixinName] or _G[mixinName];
		if mixin then
			local provider = CreateFromMixins(mixin)
			if setup then setup(provider) end
			canvas:AddDataProvider(provider)
			canvas.attached[#canvas.attached + 1] = mixinName;
		end
	end

	local levels = canvas:GetPinFrameLevelsManager()
	for _, level in ipairs(env.Providers.FrameLevels) do
		if type(level) == 'table' then
			levels:AddFrameLevel(level[1], level[2])
		else
			levels:AddFrameLevel(level)
		end
	end
	return canvas;
end

---------------------------------------------------------------
-- Diagnostics
---------------------------------------------------------------
-- issecurevariable scan of the shared state a leaking canvas would
-- taint. Zero is the bar; the output is meant for bug reports.
local function ScanTable(label, tbl, depth, seen, found)
	if type(tbl) ~= 'table' or seen[tbl] then return found end
	seen[tbl] = true;
	for key, value in pairs(tbl) do
		local ok, secure, source = pcall(issecurevariable, tbl, key)
		if ok and not secure then
			found = found + 1;
			print(('|cffff6060[TAINT]|r %s.%s tainted by %s'):format(label, tostring(key), tostring(source)))
		end
		if depth > 0 and type(value) == 'table' and type(key) == 'string' and not key:match('^__') then
			found = ScanTable(label..'.'..key, value, depth - 1, seen, found)
		end
	end
	return found;
end

function env:TaintProbe()
	local seen, found = {}, 0;
	if WorldMapFrame then
		found = ScanTable('WorldMapFrame', WorldMapFrame, 1, seen, found)
		if WorldMapFrame.dataProviders then
			for provider in pairs(WorldMapFrame.dataProviders) do
				found = ScanTable('WorldMapFrame.provider', provider, 0, seen, found)
			end
		end
	end
	if POIButtonHighlightManager then
		found = ScanTable('POIButtonHighlightManager', POIButtonHighlightManager, 0, seen, found)
	end
	if QuestCache and QuestCache.objects then
		found = ScanTable('QuestCache.objects', QuestCache.objects, 1, seen, found)
	end
	CPAPI.Log('Map taint probe: %d insecure fields.', found)
	return found;
end
