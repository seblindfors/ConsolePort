---------------------------------------------------------------
CPSplineLineMixin = {
---------------------------------------------------------------
	lineTemplate  = 'CPSplineLine';
	lineSegments  = 50;
	lineBaseCoord = {
		LEFT  = { 0, 1, 1, 0 };
		RIGHT = { 0, 1, 0, 1 };
	};
};

function CPSplineLineMixin:OnLoad()
	self.spline = CreateCatmullRomSpline(2);
	self.spbits = CreateObjectPool(GenerateClosure(function(self)
		local drawLayer, subLayer = self:GetLineDrawLayer()
		return self:GetLineOrigin():CreateLine(nil, drawLayer, self.lineTemplate, subLayer)
	end, self), function(_, bit)
		bit:Hide()
		bit:SetParent(self)
		bit:ClearAllPoints()
	end)
end

---------------------------------------------------------------
-- Setters
---------------------------------------------------------------
function CPSplineLineMixin:SetLineOrigin(point, relTo)
	self.lineRelTo = relTo or self;
	self.linePoint = point;
end

function CPSplineLineMixin:SetLineDrawLayer(drawLayer, subLayer)
	self.lineDrawLayer = drawLayer;
	self.lineSubLayer  = tonumber(subLayer) or 0;
	for bit in self.spbits:EnumerateActive() do
		bit:SetDrawLayer(drawLayer, subLayer)
	end
end

function CPSplineLineMixin:SetLineSegments(segments)
	self.lineSegments = segments;
end

function CPSplineLineMixin:SetLineCoord(lineCoord)
	self.lineCoord = lineCoord;
end

---------------------------------------------------------------
-- Getters
---------------------------------------------------------------
function CPSplineLineMixin:GetLineSegments()
	return self.lineSegments;
end

function CPSplineLineMixin:GetLineOrigin()
	return self.lineRelTo, self.linePoint or 'CENTER';
end

function CPSplineLineMixin:GetLineCoord()
	if self.lineCoord then
		return self.lineCoord;
	end
	local numPoints = self.spline:GetNumPoints()
	local startX, endX = self.spline:GetPoint(1), self.spline:GetPoint(numPoints);
	return self.lineBaseCoord[startX > endX and 'LEFT' or 'RIGHT'];
end

function CPSplineLineMixin:GetLineDrawLayer()
	return self.lineDrawLayer, self.lineSubLayer;
end

function CPSplineLineMixin:GetLineBits()
	local bits = {};
	for bit in self.spbits:EnumerateActive() do
		bits[bit.index] = bit;
	end
	return bits;
end

function CPSplineLineMixin:EnumerateLineBits()
	return ipairs(self:GetLineBits())
end

---------------------------------------------------------------
-- Points
---------------------------------------------------------------
function CPSplineLineMixin:AddLinePoint(x, y)
	return self.spline:AddPoint(x, y)
end

function CPSplineLineMixin:ClearLinePoints()
	self.spline:ClearPoints()
	self:ReleaseLine()
end

function CPSplineLineMixin:CalculatePoint(t) -- 0.0 to 1.0
	return self.spline:CalculatePointOnGlobalCurve(t)
end

---------------------------------------------------------------
-- Controls
---------------------------------------------------------------
function CPSplineLineMixin:ReleaseLine()
	local bits = self.spbits;
	self:StopLineEffect()
	bits:ReleaseAll()
	return bits;
end

function CPSplineLineMixin:DrawLine(postProcess) postProcess = postProcess or nop;
	local numSegments  = self:GetLineSegments()
	local bits, spline = self:ReleaseLine(), self.spline;
	local layer, level = self:GetLineDrawLayer()
	local relTo, point = self:GetLineOrigin()

	local lineCoord = self:GetLineCoord();
	local l, r, t, b = unpack(lineCoord);

	for i = 1, numSegments do
		local section = i / numSegments;
		local bit = bits:Acquire();

		bit:SetParent(relTo)
		bit:SetDrawLayer(layer, level)
		bit:SetTexCoord(l, r, t, b)
		bit.index, bit.section = i, section;

		bit:SetStartPoint(point, spline:CalculatePointOnGlobalCurve(section - (2 / numSegments)))
		bit:SetEndPoint(point,   spline:CalculatePointOnGlobalCurve(section))
		bit:Show()

		postProcess(bit, section, i, numSegments)
	end
end

function CPSplineLineMixin:StopLineEffect()
	if self.lineEffect then
		self.lineEffect:Cancel()
		self.lineEffect = nil;
	end
end

function CPSplineLineMixin:PlayLineEffect(time, effect, reverse)
	self:StopLineEffect()
	local bits      = self:GetLineBits();
	local numBits   = #bits;
	local i, delta  = reverse and numBits or 1, reverse and -1 or 1;
	local iteration = time / self:GetLineSegments();

	local startTime, GetTime, floor = GetTime(), GetTime, math.floor;
	self.lineEffect = C_Timer.NewTicker(iteration, function()
		local currentTime = GetTime()
		local elapsedTime = currentTime - startTime;

		-- Calculate how many bits should be updated based on elapsed time
		local bitsToUpdate = floor(elapsedTime / iteration)
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
end