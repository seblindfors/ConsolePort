local _, db = ...;
---------------------------------------------------------------
local Widgets, Cache, Owners = EnumUtil.MakeEnum('Any', 'UnitFrames', 'ActionBars'), {}, {};
local Scan = db:Register('Scan', CPAPI.CreateEventHandler({'Frame', '$parentScanHandler', ConsolePort}, {
---------------------------------------------------------------
	'GROUP_ROSTER_UPDATE';
	'CINEMATIC_STOP';
	'PLAYER_ENTERING_WORLD';
	'PLAYER_REGEN_DISABLED';
	'PLAYER_REGEN_ENABLED';
}, Widgets));

for _, typeIndex in pairs(Widgets) do
	Cache[typeIndex]  = {};
	Owners[typeIndex] = {};
end

---------------------------------------------------------------
-- UI Caching
---------------------------------------------------------------
local GetUnitForFrame, GetActionForFrame;
do	local HasScript, GetScript = Scan.HasScript, Scan.GetScript;
	local Scrub, GetRaw, SecureUnitButton_OnClick, SecureActionButton_OnClick =
		CPAPI.Scrub, Scan.GetAttribute, SecureUnitButton_OnClick, SecureActionButton_OnClick;
	local GetAttribute, GetModifiedUnit, GetModifiedAttribute =
		SecureButton_GetAttribute, SecureButton_GetModifiedUnit, SecureButton_GetModifiedAttribute;

	local function IsUnitButton(frame)
		return Scrub(HasScript(frame, 'OnClick')) and Scrub(GetScript(frame, 'OnClick')) == SecureUnitButton_OnClick;
	end

	local function IsActionButton(frame)
		return Scrub(HasScript(frame, 'OnClick')) and Scrub(GetScript(frame, 'OnClick')) == SecureActionButton_OnClick;
	end

	local function IsClickType(frame, clickType)
		return GetModifiedAttribute(frame, 'type', 'LeftButton') == clickType;
	end

	function GetUnitForFrame(frame)
		if ( GetRaw(frame, 'unit') and ( IsUnitButton(frame) or IsClickType(frame, 'target') )) then
			return GetModifiedUnit(frame)
		end
	end

	function GetActionForFrame(frame)
		local action = tonumber(GetAttribute(frame, 'action'))
		if ( action and ( IsActionButton(frame) or IsClickType(frame, 'action') )) then
			return action;
		end
	end
end

---------------------------------------------------------------
-- Unit frame attribution
---------------------------------------------------------------
-- Keeps the unit frame cache correct when secure headers
-- reassign unit attributes without firing a scanned event.
local HookUnitFrame;
do	local hooked = {};
	local function OnUnitChanged(frame, attribute)
		if ( attribute ~= 'unit' ) then return end;
		local unit = GetUnitForFrame(frame)
		if ( Cache[Widgets.UnitFrames][frame] ~= unit ) then
			Cache[Widgets.UnitFrames][frame] = unit;
			Scan:QueueAttributionUpdate()
		end
	end
	HookUnitFrame = function(frame)
		if not hooked[frame] then
			hooked[frame] = true;
			frame:HookScript('OnAttributeChanged', OnUnitChanged)
		end
	end
end

---------------------------------------------------------------
-- Global scanning
---------------------------------------------------------------
local ScanGlobal, ScanFrames;
do	local Scrub, IsProtected, IsRestricted, GetChildren =
		CPAPI.Scrub, Scan.IsProtected, CPAPI.IsObjectRestricted, Scan.GetChildren;
	local debugprofilestop = debugprofilestop;
	local SCAN_BUDGET_MS = 1.5; -- max processing time per frame

	-- Classification
	local function ClassifyNode(collect, node)
		local action = GetActionForFrame(node)
		if action then
			collect(node, Widgets.ActionBars, action)
		else
			local unit = GetUnitForFrame(node)
			if unit then
				collect(node, Widgets.UnitFrames, unit)
			end
		end
	end

	ScanFrames = function(collect, node, iterator, includeAll)
		while node do
			if Scrub(IsProtected(node)) then
				if includeAll then
					collect(node)
				else
					ClassifyNode(collect, node)
				end
			end
			node = iterator(node)
		end
	end;

	-- Staging
	local Staging = {};
	for _, typeIndex in pairs(Widgets) do
		Staging[typeIndex] = {};
	end

	local function StageNode(node, widgetType, value)
		Staging[Widgets.Any][node] = false;
		if widgetType then
			Staging[widgetType][node] = value;
		end
	end

	-- Commit
	local function CommitGlobalScan(self)
		for typeIndex, staged in pairs(Staging) do
			local cache = wipe(Cache[typeIndex]);
			for node, value in pairs(staged) do
				cache[node] = value;
			end
			wipe(staged)
		end
		for node in pairs(Cache[Widgets.UnitFrames]) do
			HookUnitFrame(node)
		end
		self:FireCallbacks(Widgets.Any)
	end

	-- Depth-first walk of the configured container trees,
	-- resumable across frames when the time budget runs out.
	local ScanStack, scanDepth = {}, 0;

	local function PushChildren(...)
		for i = 1, select('#', ...) do
			local child = select(i, ...);
			if child then
				scanDepth = scanDepth + 1;
				ScanStack[scanDepth] = child;
			end
		end
	end

	local function SliceGlobalScan(self)
		local expires = debugprofilestop() + SCAN_BUDGET_MS;
		while ( scanDepth > 0 ) do
			local node = ScanStack[scanDepth];
			ScanStack[scanDepth] = nil;
			scanDepth = scanDepth - 1;
			if not IsRestricted(node) then
				if Scrub(IsProtected(node)) then
					ClassifyNode(StageNode, node)
				end
				PushChildren(Scrub(GetChildren(node)))
			end
			if ( debugprofilestop() > expires ) then
				return -- over budget; nodes are never processed partially
			end
		end
		self:StopGlobalScan()
		if InCombatLockdown() then
			self.scanQueued = true;
		else
			CommitGlobalScan(self)
		end
	end

	-- Start / stop
	function Scan:StartGlobalScan()
		for _, staged in pairs(Staging) do
			wipe(staged)
		end
		wipe(ScanStack)
		scanDepth = 0;
		for name in db('scanContainers'):gmatch('[^,%s]+') do
			local container = _G[name];
			if C_Widget.IsFrameWidget(container) then
				scanDepth = scanDepth + 1;
				ScanStack[scanDepth] = container;
			end
		end
		if ( scanDepth == 0 ) then
			scanDepth = 1;
			ScanStack[1] = UIParent;
		end
		self:SetScript('OnUpdate', SliceGlobalScan)
	end

	function Scan:StopGlobalScan()
		self:SetScript('OnUpdate', nil)
	end

	function Scan:IsScanActive()
		return self:GetScript('OnUpdate') ~= nil;
	end

	-- Global scan request
	ScanGlobal = CPAPI.Debounce(function(self)
		if InCombatLockdown() then
			self.scanQueued = true;
			return CPAPI.Log('Raid cursor scan failed due to combat lockdown. Waiting for combat to end...')
		end
		self.scanQueued = nil;
		self:StartGlobalScan()
	end, Scan);

	db:RegisterSafeCallback('Settings/scanContainers', function() ScanGlobal() end)
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Scan:GROUP_ROSTER_UPDATE()
	if InCombatLockdown() then
		self.scanQueued = true;
	else
		ScanGlobal()
	end
end

function Scan:PLAYER_REGEN_DISABLED()
	ScanGlobal.Cancel()
	if self:IsScanActive() then
		self.scanQueued = true;
		self:StopGlobalScan()
	end
end

function Scan:PLAYER_REGEN_ENABLED()
	if self.scanQueued then
		ScanGlobal()
	end
end

function Scan:OnDataLoaded()
	self:RegisterEvent('ADDON_LOADED')
	self.ADDON_LOADED = self.GROUP_ROSTER_UPDATE;
	ScanGlobal()
end

Scan.PLAYER_ENTERING_WORLD = Scan.GROUP_ROSTER_UPDATE;
Scan.CINEMATIC_STOP        = Scan.GROUP_ROSTER_UPDATE;

---------------------------------------------------------------
-- API
---------------------------------------------------------------
Scan.Refresh = ScanGlobal;
Scan.Execute = ScanFrames;

Scan.QueueAttributionUpdate = CPAPI.Debounce(function(self)
	db:TriggerEvent('OnScanUpdate', Widgets.UnitFrames, Cache[Widgets.UnitFrames])
end, Scan)

function Scan:RegisterCallback(widgetType, callback, owner)
	widgetType = widgetType or Widgets.Any;
	callback   = owner and GenerateClosure(callback, owner) or callback;
	Owners[widgetType][callback] = true;
end

function Scan:FireCallbacks(widgetType)
	local owners = Owners[widgetType];
	local nodes  = Cache[widgetType];
	for callback in pairs(owners) do
		for node in pairs(nodes) do
			callback(node, widgetType)
		end
	end
	db:TriggerEvent('OnScanUpdate', widgetType, nodes);
end

function Scan:GetCache(widgetType)
	return Cache[widgetType or Widgets.Any];
end
