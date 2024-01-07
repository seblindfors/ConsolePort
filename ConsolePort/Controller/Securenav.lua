local _, db = ...;
---------------------------------------------------------------
db:Register('Securenav', setmetatable(CreateFromMixins(CPAPI.SecureEnvironmentMixin, {Env = {
	-----------------------------------------------------------
	-- Default filters
	-----------------------------------------------------------
	-- @param node : current node in iteration
	FilterNode = [[
		if self::IsDrawn(node:GetRect()) then
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
	-- @param oldnode : last focused node
	FilterOld = [[
		return true
	]];
	-----------------------------------------------------------
	-- Node recognition and caching
	-----------------------------------------------------------
	UpdateNodes = [[
		for i, object in ipairs({self:GetParent():GetChildren()}) do
			node = object; self::GetNodes();
		end
	]];
	-----------------------------------------------------------
	GetNodes = [[
		if node then
			local isProtected, isProtectedExplicitly = node:IsProtected()
			if isProtected or isProtectedExplicitly then
				self::ChildScan()
				self::CacheNode()
			end
		end
	]];
	-----------------------------------------------------------
	ChildScan = [[
		local parent = node
		for i, object in ipairs({parent:GetChildren()}) do
			local isProtected, isProtectedExplicitly = object:IsProtected()
			if isProtected or isProtectedExplicitly then
				child = object
				if self::FilterChild() then
					node = child; self::GetNodes()
				end
			end
		end
		node = parent
	]];
	-----------------------------------------------------------
	CacheNode = [[
		if not CACHE[node] then
			self::FilterNode()
		end
	]];
	-----------------------------------------------------------
	-- Rectangle properties
	-----------------------------------------------------------
	GetCenter = [[
		local rL, rB, rW, rH = ...
		if rL and rB then
			return (rL + rW / 2), (rB + rH / 2)
		end
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
		return select(3, self::AbsXY(...))
	]];
	-----------------------------------------------------------
	-- Node selection
	-----------------------------------------------------------
	GetBaseBindings = [[
		return 'PADDUP', 'PADDRIGHT', 'PADDDOWN', 'PADDLEFT';
	]];
	-----------------------------------------------------------
	-- @param modifier : (optional) modifier prefix for base
	SetBaseBindings = [[
		local modifier = ...;
		modifier = modifier and modifier or '';
		for _, binding in pairs({self::GetBaseBindings()}) do
			self:SetBindingClick(self:GetAttribute('priorityoverride'), modifier..binding, self, binding)
		end
	]];
	-----------------------------------------------------------
	SetNodeByDistance = [[
		local cX, cY = ...
		local targ, dest
		if cX and cY then
			for node in pairs(NODES) do
				if (node ~= old) and node:IsVisible() then
					local nX, nY = self::GetCenter(node:GetRect())
					if nX and nY then
						local dist = self::SumXY(cX, nX, cY, nY)

						if not dest or dist < dest then
							targ = node
							dest = dist
						end
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
		local highprio, candidate = -1
		for node in pairs(NODES) do
			if node:IsVisible() then
				local targPrio = node:GetAttribute('nodepriority') or 0
				if (targPrio > highprio) then
					candidate, highprio = node, targPrio
				end
			end
		end
		if candidate then
			curnode = candidate
		end
	]];
	-----------------------------------------------------------
	SetAnyNode = [[
		local old = oldnode
		if old and old:IsVisible() and self::FilterOld() then
			curnode = old; return;
		end
		if (not curnode or not curnode:IsVisible()) and next(NODES) then
			local cX, cY = self::GetCenter(self:GetRect())
			if not self::SetNodeByDistance(cX, cY) then
				self::SetNodeByShown()
			end
		end
	]];
	-----------------------------------------------------------
	PADDUP    = [[ local _, tY, _, nY, dX, dY = ... return dY > dX and nY > tY ]];
	PADDDOWN  = [[ local _, tY, _, nY, dX, dY = ... return dY > dX and nY < tY ]];
	PADDLEFT  = [[ local tX, _, nX, _, dX, dY = ... return dY < dX and nX < tX ]];
	PADDRIGHT = [[ local tX, _, nX, _, dX, dY = ... return dY < dX and nX > tX ]];
	-----------------------------------------------------------
	SetNodeByKey = [[
		local key = ...
		if curnode and (key ~= 0) then
			local tX, tY = self::GetCenter(curnode:GetRect())
			local cX, cY = math.huge, math.huge
			local currentNodeChanged = false

			for node in pairs(NODES) do
				if node:IsVisible() then
					local nX, nY = self::GetCenter(node:GetRect())
					local dX, dY, dist = self::AbsXY(tX, nX, tY, nY)

					if ( dist < cX + cY ) then
						if self:RunAttribute(key, tX, tY, nX, nY, dX, dY) then
							curnode, cX, cY = node, dX, dY;
							currentNodeChanged = true
						end
					end
				end
			end

			local wrapDisable = self:GetAttribute('wrapDisable')
			if not currentNodeChanged and not wrapDisable then
				self::SetWrapAroundNode(key, tX, tY)
			end
		end
	]];
	-----------------------------------------------------------
	PADDUP_WRAP    = [[ local cX, cY, nX, nY = ... return nX == cX and nY < cY ]];
	PADDDOWN_WRAP  = [[ local cX, cY, nX, nY = ... return nX == cX and nY > cY ]];
	PADDLEFT_WRAP  = [[ local cX, cY, nX, nY = ... return nY == cY and nX > cX ]];
	PADDRIGHT_WRAP = [[ local cX, cY, nX, nY = ... return nY == cY and nX < cX ]];
	-----------------------------------------------------------
	SetWrapAroundNode = [[
		local key, tX, tY = ...
		local keyWrap = ('%s_WRAP'):format(key)

		local curdist = 0
		for node in pairs(NODES) do
			if node:IsVisible() then
				local nX, nY = self::GetCenter(node:GetRect())
				local _, _, dist = self::AbsXY(tX, nX, tY, nY)

				if ( dist > curdist ) then
					if self:RunAttribute(keyWrap, tX, tY, nX, nY) then
						curnode, curdist = node, dist;
					end
				end
			end
		end
	]];
	-----------------------------------------------------------
	SelectNewNode = [[
		if curnode then oldnode = curnode; end
		self::SetAnyNode()
		self::SetNodeByKey(...)

		local postNodeSelect = self:GetAttribute('_postnodeselect') or PostNodeSelect;
		if postNodeSelect then
			self:Run(postNodeSelect)
		end
	]];
}}), {
	__call = function(self, obj)
		Mixin(obj, self)
		obj:Execute([[
			CACHE = newtable();
			NODES = newtable();
			CACHE[self] = true;
		]])
		return obj;
	end;
}))
--------------------------------------------------