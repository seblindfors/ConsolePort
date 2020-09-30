---------------------------------------------------------------
local ENV_DPAD = {
	-----------------------------------------------------------
	-- Default filters
	-----------------------------------------------------------
	-- @param node : current node in iteration
	FilterNode = [[
		if self:Run(IsDrawn, node:GetRect()) then
			CACHE[node] = true
			NODES[node] = true
		end
	]];
	-----------------------------------------------------------
	-- @param child : current child in iteration
	FilterChild = [[
		return child and not child:GetAttribute('ignoreNode')
	]];
	-----------------------------------------------------------
	-- @param old : last focused node
	FilterOld = [[
		return true
	]];
	-----------------------------------------------------------
	-- Node recognition and caching
	-----------------------------------------------------------
	UpdateNodes = [[
		for i, object in ipairs(newtable(self:GetParent():GetChildren())) do
			node = object; self:Run(GetNodes);
		end
	]];
	-----------------------------------------------------------
	GetNodes = [[
		if node and node:IsProtected() then
			self:Run(ChildScan)
			self:Run(CacheNode)
		end
	]];
	-----------------------------------------------------------
	ChildScan = [[
		local parent = node
		for i, object in ipairs(newtable(parent:GetChildren())) do
			if object:IsProtected() then
				child = object
				if self:Run(FilterChild) then
					node = child; self:Run(GetNodes)
				end
			end
		end
		node = parent
	]];
	-----------------------------------------------------------
	CacheNode = [[
		if not CACHE[node] then
			self:Run(FilterNode)
		end
	]];
	-----------------------------------------------------------
	-- Rectangle properties
	-----------------------------------------------------------
	GetCenter = [[
		local rL, rB, rW, rH = ...
		return (rL + rW / 2), (rB + rH / 2)
	]];
	-----------------------------------------------------------
	IsDrawn = [[
		local rL, rB, rW, rH = ...
		return rL and rB and rW > 0 and rH > 0
	]];
	-----------------------------------------------------------
	AbsXY = [[
		local x1, x2, y1, y2 = ...
		local x, y = abs(x1 - x2), abs(y1 - y2)
		return x, y, x + y
	]];
	-----------------------------------------------------------
	SumXY = [[
		return select(3, self:Run(AbsXY, ...))
	]];
	-----------------------------------------------------------
	-- Node selection
	-----------------------------------------------------------
	SetNodeByDistance = [[
		local cX, cY = ...
		local targ, dest
		if cX and cY then
			for node in pairs(NODES) do
				if (node ~= old) and node:IsVisible() then
					local nX, nY = self:Run(GetCenter, node:GetRect())
					local dist = self:Run(SumXY, cX, nX, cY, nY)

					if not dest or dist < dest then
						targ = node
						dest = dist
					end
				end
			end
			if targ then
				curnode = targ
				return true
			end
		end
	]];
	-----------------------------------------------------------
	SetNodeByShown = [[
		for node in pairs(NODES) do
			if node:IsVisible() then
				curnode = node
				break
			end
		end
	]];
	-----------------------------------------------------------
	SetAnyNode = [[
		local old = oldnode
		if old and old:IsVisible() and self:Run(FilterOld) then
			curnode = old; return;
		end
		if (not curnode or not curnode:IsVisible()) and next(NODES) then
			local cX, cY = self:Run(GetCenter, self:GetRect())
			if not self:Run(SetNodeByDistance, cX, cY) then
				self:Run(SetNodeByShown)
			end
		end
	]];
	-----------------------------------------------------------
	PADDUP    = [[ local tX, tY, nX, nY, dX, dY = ... return dY > dX and nY > tY ]];
	PADDDOWN  = [[ local tX, tY, nX, nY, dX, dY = ... return dY > dX and nY < tY ]];
	PADDLEFT  = [[ local tX, tY, nX, nY, dX, dY = ... return dY < dX and nX < tX ]];
	PADDRIGHT = [[ local tX, tY, nX, nY, dX, dY = ... return dY < dX and nX > tX ]];
	-----------------------------------------------------------
	SetNodeByKey = [[
		local key = ...
		if curnode and (key ~= 0) then
			local rL, rB, rW, rH = curnode:GetRect()
			local tX, tY = self:Run(GetCenter, curnode:GetRect())
			local cX, cY = math.huge, math.huge
			for node in pairs(NODES) do
				local nX, nY = self:Run(GetCenter, node:GetRect())
				local dX, dY, dist = self:Run(AbsXY, tX, nX, tY, nY)

				if ( dist < cX + cY ) then
					if self:RunAttribute(key, tX, tY, nX, nY, dX, dY) then
						curnode, cX, cY = node, dX, dY;
					end
				end
			end
		end
	]];
	-----------------------------------------------------------
	SelectNewNode = [[
		if curnode then oldnode = curnode; end
		self:Run(SetAnyNode)
		self:Run(SetNodeByKey, ...)

		local postNodeSelect = self:GetAttribute('_postnodeselect') or PostNodeSelect;
		if postNodeSelect then
			self:Run(postNodeSelect)
		end
	]];
}
--------------------------------------------------
