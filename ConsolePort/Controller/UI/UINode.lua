---------------------------------------------------------------
-- Interface node calculations and management
---------------------------------------------------------------
-- Accessory driver to scan a given interface hierarchy and
-- calculate distances and travel path between nodes, where a
-- node is any object in the hierarchy that is considered to be
-- interactive, either by clicking or mousing over it.
-- Calling NODE(...) with a list of frames will
-- cache all nodes in the hierarchy for later use.
---------------------------------------------------------------
-- API
---------------------------------------------------------------
--  NODE(frame1, frame2, ..., frameN)
--  NODE.ClearCache()
--  NODE.IsDrawn(node, super)
--  NODE.IsRelevant(node)
--  NODE.GetScrollButtons(node)
--  NODE.NavigateToBestCandidate(cur, key)
--  NODE.NavigateToClosestCandidate(cur, key)
--  NODE.NavigateToArbitraryCandidate([cur, old, origX, origY])
---------------------------------------------------------------
-- Node attributes
---------------------------------------------------------------
--  nodeignore       : (boolean) ignore this node
--  nodepriority     : (number)  priority in arbitrary selection
--  nodesingleton    : (boolean) no recursive scan on this node
--  nodeonlychildren : (boolean) include children, skip node
---------------------------------------------------------------

-- Eligibility
local IsMouseResponsive
local IsUsable
local IsInteractive
local IsRelevant
local IsTree
local IsDrawn
-- Attachments
local GetSuperNode
local GetScrollButtons
-- Recursive scanner
local Scan
local ScanLocal
local ScrubCache
-- Cache control
local CacheItem
local CacheRect
local Insert
local RemoveCacheItem
local ClearCache
local HasItems
local GetNextCacheItem
local GetFirstEligibleCacheItem
local GetRectLevelIndex
local IterateCache
local IterateRects
-- Rect calculations
local GetCenter
local GetCenterPos
local GetCenterScaled
local DoNodesIntersect
local GetFrameLevel
local PointInRange
local CanLevelsIntersect
local DoNodeAndRectIntersect
-- Vector calculations
local GetDistance
local GetDistanceSum
local IsCloser
local GetCandidateVectorForCurrent
local GetCandidatesForVector
local GetPriorityCandidate
-- Navigation
local NavigateToBestCandidate
local NavigateToClosestCandidate
local NavigateToArbitraryCandidate

---------------------------------------------------------------
-- Data handling
---------------------------------------------------------------
-- RECTS  : cache of all interactive rectangles drawn on screen
-- CACHE  : cache of all eligible nodes in order of priority
-- BOUNDS : limit the boundaries of scans/selection to screen
-- SCALAR : scale 2ndary plane to improve intuitive node selection
-- USABLE : what to consider as interactive nodes by default
-- LEVELS : frame level quantifiers (each strata has 10k levels)
---------------------------------------------------------------
local CACHE, RECTS = {}, {};
local BOUNDS  = CreateVector3D(GetScreenWidth(), GetScreenHeight(), UIParent:GetEffectiveScale());
local SCALAR = 3;
local USABLE = {
	Button      = true;
	CheckButton = true;
	EditBox     = true;
	Slider      = true;
};
local LEVELS = {
	BACKGROUND        = 00000;
	LOW               = 10000;
	MEDIUM            = 20000;
	HIGH              = 30000;
	DIALOG            = 40000;
	FULLSCREEN        = 50000;
	FULLSCREEN_DIALOG = 60000;
	TOOLTIP           = 70000;
};

---------------------------------------------------------------
-- Main object
---------------------------------------------------------------
local NODE = setmetatable(CPAPI.CreateEventHandler({'Frame', '$parentNode', ConsolePort}, {
	-- Events to handle
	'UI_SCALE_CHANGED';
	'DISPLAY_SIZE_CHANGED';
}, {
	-- Compares distance between nodes for eligibility when filtering cached nodes
	distance = {
		PADDUP    = function(_, destY, horz, vert, _, thisY) return (vert > horz and destY > thisY) end;
		PADDDOWN  = function(_, destY, horz, vert, _, thisY) return (vert > horz and destY < thisY) end;
		PADDLEFT  = function(destX, _, horz, vert, thisX, _) return (vert < horz and destX < thisX) end;
		PADDRIGHT = function(destX, _, horz, vert, thisX, _) return (vert < horz and destX > thisX) end;
	};
	-- Compares more generally to catch any nodes located in a given direction
	direction = {
		PADDUP    = function(_, destY, _, _, _, thisY) return (destY > thisY) end;
		PADDDOWN  = function(_, destY, _, _, _, thisY) return (destY < thisY) end;
		PADDLEFT  = function(destX, _, _, _, thisX, _) return (destX < thisX) end;
		PADDRIGHT = function(destX, _, _, _, thisX, _) return (destX > thisX) end;
	};
}), {
	-- @param  varargs : list of frames to scan recursively
	-- @return cache   : table of nodes on screen
	__call = function(self, ...)
		ClearCache()
		Scan(nil, ...)
		ScrubCache(GetNextCacheItem(nil))
		return CACHE
	end;
	__index = getmetatable(UIParent).__index;
})

---------------------------------------------------------------
-- Events (update boundaries)
---------------------------------------------------------------
local function UIScaleChanged()
	BOUNDS:SetXYZ(GetScreenWidth(), GetScreenHeight(), UIParent:GetEffectiveScale())
end

NODE.UI_SCALE_CHANGED = UIScaleChanged;
NODE.DISPLAY_SIZE_CHANGED = UIScaleChanged;
hooksecurefunc(UIParent, 'SetScale', UIScaleChanged)
UIParent:HookScript('OnSizeChanged', UIScaleChanged)

---------------------------------------------------------------
-- Eligibility
---------------------------------------------------------------

function IsMouseResponsive(node)
	return node.GetScript and ( node:GetScript('OnEnter') or node:GetScript('OnMouseDown') ) and true
end

function IsUsable(object)
	return USABLE[object]
end

function IsInteractive(node, object)
	return 	not node:IsObjectType('ScrollFrame')
			and node:IsMouseEnabled()
			and ( IsUsable(object) or IsMouseResponsive(node) )
end

function IsRelevant(node)
	return node and not node:IsForbidden() and not node:GetAttribute('nodeignore') and node:IsVisible()
end

function IsTree(node)
	return not node:GetAttribute('nodesingleton')
end

function IsDrawn(node, super)
	local nX, nY = GetCenterScaled(node)
	local mX, mY = BOUNDS:GetXYZ()
	if ( PointInRange(nX, 0, mX) and PointInRange(nY, 0, mY) ) then
		-- assert node isn't clipped inside a scroll child
		if super and not node:IsObjectType('Slider') then
			return DoNodesIntersect(node, super) --or UIDoFramesIntersect(node, scrollChild)
		else
			return true
		end
	end
end

---------------------------------------------------------------
-- Attachments
---------------------------------------------------------------
function GetSuperNode(super, node)
	return (node:IsObjectType('ScrollFrame') or node:DoesClipChildren()) and node or super
end

function GetScrollButtons(node)
	if node then
		if node:IsMouseWheelEnabled() then
			for _, frame in pairs({node:GetChildren()}) do
				if frame:IsObjectType('Slider') then
					return frame:GetChildren()
				end
			end
		elseif node:IsObjectType('Slider') then
			return node:GetChildren()
		else
			return GetScrollButtons(node:GetParent())
		end
	end
end

---------------------------------------------------------------
-- Recursive scanner
---------------------------------------------------------------
function Scan(super, node, sibling, ...)
	if IsRelevant(node) then
		local object, level = node:GetObjectType(), GetFrameLevel(node)
		if IsDrawn(node, super) then
			if IsInteractive(node, object) then
				CacheItem(node, object, super, level)
			elseif node:IsMouseEnabled() then
				CacheRect(node, level)
			end
		end
		if IsTree(node) then
			Scan(GetSuperNode(super, node), node:GetChildren())
		end
	end
	if sibling then
		Scan(super, sibling, ...)
	end
end

function ScanLocal(node)
	if IsRelevant(node) then
		local parent, super = node
		while parent do
			if GetSuperNode(nil, parent) then
				super = parent
				break
			end
			parent = parent:GetParent()
		end
		ClearCache()
		Scan(super, node)
		local object = node:GetObjectType()
		if IsInteractive(node, object) then
			CacheItem(node, object, super, GetFrameLevel(node))
		end
		ScrubCache(GetNextCacheItem(nil))
	end
	return CACHE
end

function ScrubCache(i, item)
	while item do
		local node, level = item.node, item.level
		for l, rect in IterateRects() do
			if not CanLevelsIntersect(level, rect.level) then
				break
			end
			if DoNodeAndRectIntersect(node, rect.node) then
				i = RemoveCacheItem(i)
				break
			end
		end
		i, item = GetNextCacheItem(i)
	end
end

---------------------------------------------------------------
-- Cache control
---------------------------------------------------------------
local tinsert, tremove, ipairs, next = tinsert, tremove, ipairs, next
---------------------------------------------------------------

function CacheItem(node, object, super, level)
	CacheRect(node, level)
	Insert(CACHE, node:GetAttribute('nodepriority'), {
		node   = node;
		object = object;
		super  = super;
		level  = level;
	})
end

function CacheRect(node, level)
	Insert(RECTS, GetRectLevelIndex(level), {
		node  = node;
		level = level;
	})
end

function Insert(t, k, v)
	if k then
		return tinsert(t, k, v)
	end
	t[#t+1] = v
end

function RemoveCacheItem(cacheIndex)
	tremove(CACHE, cacheIndex)
	return cacheIndex - 1
end

function ClearCache()
	wipe(CACHE)
	wipe(RECTS)
end

function HasItems()
	return #CACHE > 0
end

function GetNextCacheItem(i)
	return next(CACHE, i and i > 0 and i or nil)
end

function GetFirstEligibleCacheItem()
	for _, item in IterateCache() do
		local node = item.node
		if node:IsVisible() and IsDrawn(node, item.super) then
			return item
		end
	end
end

function GetRectLevelIndex(level)
	for index, item in IterateRects() do
		if (item.level < level) then
			return index
		end 		
	end
	return #RECTS+1
end

function IterateCache()
	return ipairs(CACHE)
end

function IterateRects()
	return ipairs(RECTS)
end

---------------------------------------------------------------
-- Rect calculations
---------------------------------------------------------------
local function div2(arg, ...)
	if arg then return arg * 0.5, div2(...) end
end
local function nrmlz(node, effScale, cmpScale, func, ...)
	if func then
		return func(node) * (effScale/cmpScale),
			nrmlz(node, effScale, cmpScale, ...)
	end
end
---------------------------------------------------------------

function GetCenter(node)
	local x, y, w, h = node:GetRect()
	if not x then return end
	local l, r, t, b = div2(node:GetHitRectInsets())
	return (x+l) + div2(w-r), (y+b) + div2(h-t)
end

function GetCenterScaled(node)
	local x, y = GetCenter(node)
	if not x then return end
	local scale = node:GetEffectiveScale() / BOUNDS.z;
	return x * scale, y * scale
end

function GetCenterPos(node)
	local x, y = node:GetCenter()
	if not x then return end
	local l, b = GetCenter(node)
	return (l-x), (b-y)
end

function DoNodesIntersect(n1, n2)
	local left1, right1, top1, bottom1 = nrmlz(
		n1, n1:GetEffectiveScale(), BOUNDS.z,
		n1.GetLeft, n1.GetRight, n1.GetTop, n1.GetBottom);
	local left2, right2, top2, bottom2 = nrmlz(
		n2, n2:GetEffectiveScale(), BOUNDS.z,
		n2.GetLeft, n2.GetRight, n2.GetTop, n2.GetBottom);
	return  (left1   <  right2)
		and (right1  >   left2)
		and (bottom1 <    top2)
		and (top1    > bottom2)
end

function GetFrameLevel(node)
	return LEVELS[node:GetFrameStrata()] + node:GetFrameLevel()
end

function PointInRange(pt, min, max)
	return pt and pt >= min and pt <= max
end

function CanLevelsIntersect(level1, level2)
	return level1 < level2
end

function DoNodeAndRectIntersect(node, rect)
	local x, y = GetCenterScaled(node)
	local scale, limit = rect:GetEffectiveScale(), BOUNDS.z;
	return PointInRange(x, nrmlz(rect, scale, limit, rect.GetLeft, rect.GetRight)) and
		   PointInRange(y, nrmlz(rect, scale, limit, rect.GetBottom, rect.GetTop))
end

---------------------------------------------------------------
-- Vector calculations
---------------------------------------------------------------
local vlen, abs, huge = Vector2D_GetLength, math.abs, math.huge
---------------------------------------------------------------

function GetDistance(x1, y1, x2, y2)
	return abs(x1 - x2), abs(y1 - y2)
end

function GetDistanceSum(...)
	local x, y = GetDistance(...)
	return x + y
end

function IsCloser(hz1, vt1, hz2, vt2)
	return vlen(hz1, vt1) < vlen(hz2, vt2)
end

function GetCandidateVectorForCurrent(cur)
	local x, y = GetCenterScaled(cur.node)
	return {x = x; y = y; h = huge; v = huge}
end 

function GetCandidatesForVector(vector, comparator, candidates)
	local thisX, thisY = vector.x, vector.y
	for i, destination in IterateCache() do
		local candidate = destination.node
		local destX, destY = GetCenterScaled(candidate)
		local distX, distY = GetDistance(thisX, thisY, destX, destY)

		if comparator(destX, destY, distX, distY, thisX, thisY) then
			candidates[destination] = { 
				x = destX; y = destY; h = distX; v = distY;
			}
		end
	end 
	return candidates
end

---------------------------------------------------------------
-- Get the best candidate to a given origin and direction
---------------------------------------------------------------
-- This method uses vectors over manhattan distance, stretching 
-- from an origin node to new candidate nodes, using direction.
-- The vectors are artificially inflated in the secondary plane
-- to the travel direction (X for up/down, Y for left/right),
-- prioritizing candidates more linearly aligned to the origin.
-- Comparing Euclidean distance on vectors yields the best node.

function NavigateToBestCandidate(cur, key, curNodeChanged)
	if cur and NODE.distance[key] then
		local this = GetCandidateVectorForCurrent(cur)
		local candidates = GetCandidatesForVector(this, NODE.distance[key], {})

		local hMult = (key == 'PADDUP' or key == 'PADDDOWN') and SCALAR or 1
		local vMult = (key == 'PADDLEFT' or key == 'PADDRIGHT') and SCALAR or 1

		for candidate, vector in pairs(candidates) do
			if IsCloser(vector.h * hMult, vector.v * vMult, this.h, this.v) then
				this = vector; this.h = (this.h * hMult); this.v = (this.v * vMult);
				cur = candidate
				curNodeChanged = true
			end
		end
		return cur, curNodeChanged
	end
end

---------------------------------------------------------------
-- Set the closest candidate to a given origin
---------------------------------------------------------------
-- Used as a fallback method when a proper candidate can't be
-- located using both direction and distance-based vectors,
-- instead using only shortest path as the metric for movement.

function NavigateToClosestCandidate(cur, key, curNodeChanged)
	if cur and NODE.direction[key] then
		local this = GetCandidateVectorForCurrent(cur)
		local candidates = GetCandidatesForVector(this, NODE.direction[key], {})

		for candidate, vector in pairs(candidates) do
			if IsCloser(vector.h, vector.v, this.h, this.v) then
				this = vector; cur = candidate
			end
		end
		return cur, curNodeChanged
	end
end

---------------------------------------------------------------
-- Get an arbitrary candidate based on priority mapping
---------------------------------------------------------------
function NavigateToArbitraryCandidate(cur, old, x, y)
	-- (1) attempt to return the last node before the cache was wiped
	-- (2) attempt to return the current node if it's still drawn
	-- (3) return the first item in the cache if there are no origin coordinates
	-- (4) return any node that's close to the origin coordinates or has priority
	return 	( cur and IsRelevant(cur.node) and IsDrawn(cur.node) ) and cur or
			( old and IsRelevant(old.node) and IsDrawn(old.node) ) and old or
			( not x or not y ) and GetFirstEligibleCacheItem() or
			( HasItems() ) and GetPriorityCandidate(x, y)
end

function GetPriorityCandidate(x, y)
	local targNode, targDist, targPrio
	for _, this in IterateCache() do
		local thisDist = GetDistanceSum(x, y, GetCenterScaled(this.node))
		local thisPrio = this.node:GetAttribute('nodepriority')

		if thisPrio and not targPrio then
			targNode = this
			break
		elseif not targNode or ( not targPrio and thisDist < targDist ) then
			targNode = this
			targDist = thisDist
			targPrio = thisPrio
		end
	end
	return targNode
end

---------------------------------------------------------------
-- Interface access
---------------------------------------------------------------
NODE.IsDrawn = IsDrawn;
NODE.ScanLocal = ScanLocal;
NODE.GetCenter = GetCenterScaled;
NODE.GetCenterPos = GetCenterPos;
NODE.GetCenterScaled = GetCenterScaled;
NODE.GetDistance = GetDistance;
NODE.IsRelevant = IsRelevant;
NODE.ClearCache = ClearCache;
NODE.GetScrollButtons = GetScrollButtons;
NODE.NavigateToBestCandidate = NavigateToBestCandidate;
NODE.NavigateToClosestCandidate = NavigateToClosestCandidate;
NODE.NavigateToArbitraryCandidate = NavigateToArbitraryCandidate;


---------------------------------------------------------------
-- Extend Carpenter API
---------------------------------------------------------------
do local Lib = LibStub:GetLibrary('Carpenter')
	Lib:ExtendAPI('IgnoreNode', function(self, ...) self:SetAttribute('nodeignore', ...) end)
	Lib:ExtendAPI('PriorityNode', function(self, ...) self:SetAttribute('nodepriority', ...) end)
	Lib:ExtendAPI('SingletonNode', function(self, ...) self:SetAttribute('nodesingleton', ...) end)
end