local _, db = ...;
--@do-not-package@
local SplineLineDebug;
--@end-do-not-package@
---------------------------------------------------------------
local SplineLine = {
---------------------------------------------------------------
	lineTemplate  = 'CPSplineLine';
	lineSegments  = 50;
	lineBaseCoord = {
		LEFT  = { 0, 1, 1, 0 };
		RIGHT = { 0, 1, 0, 1 };
	};
}; db.SplineLine = SplineLine;

function SplineLine:OnLoad()
	self.spline = CreateCatmullRomSpline(2);
	self.spbits = CreateObjectPool(GenerateClosure(function(self)
		local drawLayer, subLayer = self:GetLineDrawLayer()
		return self:GetLineOwner():CreateLine(nil, drawLayer, self.lineTemplate, subLayer)
	end, self), function(_, bit)
		bit:Hide()
		bit:SetParent(self)
		bit:ClearAllPoints()
	end)
end

---------------------------------------------------------------
-- Setters
---------------------------------------------------------------
function SplineLine:SetLineOrigin(point, relTo)
	self.lineRelTo = relTo or self;
	self.linePoint = point;
end

function SplineLine:SetLineOwner(owner)
	self.lineOwner = owner;
end

function SplineLine:SetLineDrawLayer(drawLayer, subLayer)
	self.lineDrawLayer = drawLayer;
	self.lineSubLayer  = tonumber(subLayer) or 0;
	for bit in self.spbits:EnumerateActive() do
		bit:SetDrawLayer(drawLayer, subLayer)
	end
end

function SplineLine:SetLineSegments(segments)
	self.lineSegments = segments;
end

function SplineLine:SetLineCoord(lineCoord)
	self.lineCoord = lineCoord;
end

---------------------------------------------------------------
-- Getters
---------------------------------------------------------------
function SplineLine:GetLineSegments()
	return self.lineSegments;
end

function SplineLine:GetLineOwner()
	return self.lineOwner or self.lineRelTo;
end

function SplineLine:GetLineOrigin()
	return self.lineRelTo, self.linePoint or 'CENTER';
end

function SplineLine:GetLineCoord()
	if self.lineCoord then
		return self.lineCoord;
	end
	local startX, endX = self:CalculatePoint(0), self:CalculatePoint(1);
	return self.lineBaseCoord[startX > endX and 'LEFT' or 'RIGHT'];
end

function SplineLine:GetLineDrawLayer()
	return self.lineDrawLayer, self.lineSubLayer;
end

function SplineLine:GetLineBits()
	local bits = {};
	for bit in self.spbits:EnumerateActive() do
		bits[bit.index] = bit;
	end
	return bits;
end

function SplineLine:EnumerateLineBits()
	return ipairs(self:GetLineBits())
end

function SplineLine:IsLineDrawn()
	return self.lineIsDrawn;
end

---------------------------------------------------------------
-- Points
---------------------------------------------------------------
function SplineLine:AddLinePoint(x, y)
	return self.spline:AddPoint(x, y)
end

function SplineLine:ClearLinePoints()
	self.spline:ClearPoints()
	self:ReleaseLine()
end

function SplineLine:CalculatePoint(t) -- 0.0 to 1.0
	return self.spline:CalculatePointOnGlobalCurve(t)
end

---------------------------------------------------------------
-- Controls
---------------------------------------------------------------
function SplineLine:ReleaseLine()
	local bits = self.spbits;
	self:StopLineEffect()
	self.lineIsDrawn = false;
	bits:ReleaseAll()
	return bits;
end

function SplineLine:DrawLine(postProcess) postProcess = postProcess or nop;
	local numSegments  = self:GetLineSegments()
	local bits, spline = self:ReleaseLine(), self.spline;
	local layer, level = self:GetLineDrawLayer()
	local relTo, point = self:GetLineOrigin()
	local lineOwner    = self:GetLineOwner()

	if spline:GetNumPoints() < 2 then
		return false; -- Not enough points to draw a line
	end

	local lineCoord = self:GetLineCoord();
	local l, r, t, b = unpack(lineCoord);

	--@do-not-package@
	--SplineLineDebug(self, spline, point, relTo)
	--@end-do-not-package@
	for i = 1, numSegments do
		local section = i / numSegments;
		local bit = bits:Acquire();

		bit:SetParent(lineOwner)
		bit:SetDrawLayer(layer, level)
		bit:SetTexCoord(l, r, t, b)
		bit.index, bit.section = i, section;

		bit:SetStartPoint(point, relTo, spline:CalculatePointOnGlobalCurve(section - (2 / numSegments)))
		bit:SetEndPoint(point,   relTo, spline:CalculatePointOnGlobalCurve(section))
		bit:Show()

		postProcess(bit, section, i, numSegments)
	end
	self.lineIsDrawn = true;
	return true;
end

function SplineLine:StopLineEffect()
	if self.lineEffect then
		self.lineEffect:Cancel()
		self.lineEffect = nil;
	end
end

function SplineLine:PlayLineEffect(time, effect, reverse)
	if not self:IsLineDrawn() then return false end;

	self:StopLineEffect()
	local bits      = self:GetLineBits();
	local numBits   = #bits;
	local i, delta  = reverse and numBits or 1, reverse and -1 or 1;
	local iteration = time / self:GetLineSegments();

	local startTime, GetTime, floor, max = GetTime(), GetTime, math.floor, math.max;
	self.lineEffect = C_Timer.NewTicker(iteration, function()
		local currentTime = GetTime()
		local elapsedTime = currentTime - startTime;

		-- Calculate how many bits should be updated based on elapsed time
		local bitsToUpdate = max(1, floor(elapsedTime / iteration))
		startTime = currentTime;

		for _ = 1, bitsToUpdate do
			local bit = bits[i];
			if not bit then
				return self:StopLineEffect()
			end
			effect(bit, i, bits)
			i = i + delta;
		end
	end)
	return true;
end

--@do-not-package@
function SplineLineDebug(self, spline, point, relTo)
	local dr, dg, db = random(), random(), random();
	if not self.debug then self.debug = {
		CreateTexturePool(UIParent, 'ARTWORK', 6),
		CreateFontStringPool(UIParent, 'ARTWORK', 7, 'GameFontNormalTiny')
	} end
	foreach(self.debug, function(_, pool) pool:ReleaseAll() end)
	for i=1, spline:GetNumPoints() - 1 do
		local x, y, dot = spline:GetPoint(i)
		foreach(self.debug, function(t, pool)
			dot = pool:Acquire(); dot:SetParent(relTo); dot:Show()
			dot:SetPoint(point, x + (t == 2 and 4 or 0), y - (t == 2 and 4 or 0))
			if t == 1 then dot:SetSize(4, 4) dot:SetColorTexture(dr, dg, db, 0.5) end;
			if t == 2 then dot:SetText(i + 1) end;
		end)
	end
end
--@end-do-not-package@