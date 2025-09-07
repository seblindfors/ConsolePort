local _, db = ...;
---------------------------------------------------------------
local Widgets, Cache, Owners = EnumUtil.MakeEnum('Any', 'UnitFrames', 'ActionBars'), {}, {};
local Scan = db:Register('Scan', CPAPI.CreateEventHandler({'Frame', '$parentScanHandler', ConsolePort}, {
---------------------------------------------------------------
	'GROUP_ROSTER_UPDATE';
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
local GetRaw, GetAttribute, GetModifiedUnit, GetModifiedAttribute =
	Scan.GetAttribute, SecureButton_GetAttribute, SecureButton_GetModifiedUnit, SecureButton_GetModifiedAttribute;

local function GetUnitForFrame(frame)
	if ( GetModifiedAttribute(frame, 'type', 'LeftButton') ~= 'target' )
	or ( not GetRaw(frame, 'unit') ) then
		return nil;
	end
	return GetModifiedUnit(frame)
end

local function GetActionForFrame(frame)
	if ( GetModifiedAttribute(frame, 'type', 'LeftButton') ~= 'action' ) then
		return nil;
	end
	return tonumber(GetAttribute(frame, 'action'))
end

local ScanGlobal, ScanFrames;
do	local EnumerateFrames, IsProtected = EnumerateFrames, Scan.IsProtected;
	ScanFrames = function(collect, node, iterator, includeAll)
		while node do
			if IsProtected(node) then
				if includeAll then
					collect(node)
				else
					local unit, action = GetUnitForFrame(node), GetActionForFrame(node);
					if unit and not action then
						collect(node, Widgets.UnitFrames, unit)
					elseif action then
						collect(node, Widgets.ActionBars, action)
					end
				end
			end
			node = iterator(node)
		end
	end;

	local function ScanLocal(node, widgetType, value)
		Cache[Widgets.Any][node] = false;
		if widgetType then
			Cache[widgetType][node] = value;
		end
	end

	ScanGlobal = CPAPI.Debounce(function(self, collector)
		if InCombatLockdown() then
			return CPAPI.Log('Raid cursor scan failed due to combat lockdown. Waiting for combat to end...')
		end
		for _, typeIndex in pairs(Widgets) do
			wipe(Cache[typeIndex]);
		end
		self:WipeCache()
		ScanFrames(collector, EnumerateFrames(), EnumerateFrames, false)
		self:FireCallbacks(Widgets.Any)
	end, Scan, ScanLocal);
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Scan:GROUP_ROSTER_UPDATE()
	if not InCombatLockdown() then
		ScanGlobal()
	end
end

function Scan:PLAYER_REGEN_DISABLED()
	ScanGlobal.Cancel()
end

function Scan:OnDataLoaded()
	self:RegisterEvent('ADDON_LOADED')
	self.ADDON_LOADED = self.GROUP_ROSTER_UPDATE;
	ScanGlobal()
end

Scan.PLAYER_REGEN_ENABLED  = Scan.GROUP_ROSTER_UPDATE;
Scan.PLAYER_ENTERING_WORLD = Scan.GROUP_ROSTER_UPDATE;

---------------------------------------------------------------
-- API
---------------------------------------------------------------
Scan.Refresh = ScanGlobal;
Scan.Execute = ScanFrames;

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

function Scan:WipeCache()
	for _, typeIndex in pairs(Widgets) do
		wipe(Cache[typeIndex]);
	end
end