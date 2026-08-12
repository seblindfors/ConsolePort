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
do	local EnumerateFrames, Scrub, IsProtected = EnumerateFrames, CPAPI.Scrub, Scan.IsProtected;
	local debugprofilestop = debugprofilestop;
	local SCAN_BUDGET_MS   = 1.5;
	local SCAN_GRANULARITY = 10;

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

	-- Caches
	local Seen, StagedSeen, Discovered, Staging = {}, {}, {}, {};
	for _, typeIndex in pairs(Widgets) do
		Staging[typeIndex] = {};
	end

	local function StageNode(node, widgetType, value)
		Staging[Widgets.Any][node] = false;
		if widgetType then
			Staging[widgetType][node] = value;
		end
	end

	-- Discovery
	local function StageDiscoveredNodes()
		for node in pairs(Discovered) do
			Discovered[node] = nil;
			Seen[node] = true;
			if Scrub(IsProtected(node)) then
				ClassifyNode(StageNode, node)
			end
		end
	end

	-- Commit
	local function CommitGlobalScan(self)
		StageDiscoveredNodes()
		for node in pairs(StagedSeen) do
			StagedSeen[node] = nil;
			Seen[node] = true;
		end
		local newNodes, unitChanges;
		for typeIndex, staged in pairs(Staging) do
			local cache = Cache[typeIndex];
			for node, value in pairs(staged) do
				if ( cache[node] ~= value ) then
					cache[node] = value;
					if ( typeIndex == Widgets.UnitFrames ) then
						HookUnitFrame(node)
						unitChanges = true;
					else
						newNodes = true;
					end
				end
			end
			wipe(staged)
		end
		if newNodes then
			self:FireCallbacks(Widgets.Any)
		elseif unitChanges then
			self:QueueAttributionUpdate()
		end
	end

	-- Sliced global scan
	local function SliceGlobalScan(self)
		local node, count = self.scanCursor, SCAN_GRANULARITY;
		local expires = debugprofilestop() + SCAN_BUDGET_MS;
		while node do
			if not ( Seen[node] or StagedSeen[node] ) then
				StagedSeen[node] = true;
				if Scrub(IsProtected(node)) then
					ClassifyNode(StageNode, node)
				end
			end
			node = EnumerateFrames(node)
			count = count - 1;
			if ( count <= 0 ) then
				if ( debugprofilestop() >= expires ) then
					self.scanCursor = node;
					return
				end
				count = SCAN_GRANULARITY;
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
		wipe(StagedSeen)
		self.scanCursor = EnumerateFrames();
		self:SetScript('OnUpdate', SliceGlobalScan)
	end

	function Scan:StopGlobalScan()
		self.scanCursor = nil;
		self:SetScript('OnUpdate', nil)
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

	-----------------------------------------------------------
	-- Discovery funnels
	-----------------------------------------------------------
	-- Scan passes skip frames they have already seen, so frames
	-- that change role after their first classification are
	-- requeued here.
	--
	-- SecureUnitButton_OnLoad runs on every
	-- CompactUnitFrame_SetUnit and on setup of all non-compact
	-- Blizzard unit frames.
	--
	-- RegisterUnitWatch covers addon frames spawned outside
	-- secure group headers.

	Scan.QueueDiscovery = CPAPI.Debounce(function(self)
		if not next(Discovered) or InCombatLockdown() or self.scanCursor then return end;
		CommitGlobalScan(self)
	end, Scan)

	local function QueueNodeDiscovery(node)
		if not C_Widget.IsFrameWidget(node) or Scrub(node:IsForbidden()) then return end;
		Discovered[node] = true;
		Scan:QueueDiscovery()
	end

	hooksecurefunc('SecureUnitButton_OnLoad', QueueNodeDiscovery)
	hooksecurefunc('RegisterUnitWatch', QueueNodeDiscovery)

	function Scan:HasPendingDiscovery()
		return next(Discovered) ~= nil;
	end
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
	if self.scanCursor then
		self.scanQueued = true;
		self:StopGlobalScan()
	end
end

function Scan:PLAYER_REGEN_ENABLED()
	if self.scanQueued then
		return ScanGlobal()
	end
	if self:HasPendingDiscovery() then
		self:QueueDiscovery()
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