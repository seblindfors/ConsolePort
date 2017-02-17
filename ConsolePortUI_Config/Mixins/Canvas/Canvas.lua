local _, L = ...
local Canvas = {}
L.CanvasMixin = Canvas

local CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH = 1
local CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL = 2
local CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE = 3

function Canvas:OnLoad()
	self.targetScrollX = 0.5
	self.targetScrollY = 0.5

	self.defaultMaxScale = 1.25
	self.defaultMinScale = 1

	self.zoomAmountPerMouseWheelDelta = .075

	self.mouseWheelZoomMode = CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL
	self:SetScalingMode('SCALING_MODE_LINEAR')

	self.normalizedZoomLerpAmount = .15
	self.normalizedPanXLerpAmount = .15
	self.normalizedPanYLerpAmount = .15
end

function Canvas:OnMouseDown(button)
	if button == "LeftButton" then
		self.isLeftButtonDown = true

		self.lastCursorX, self.lastCursorY = self:GetCursorPosition()
		self.startCursorX, self.startCursorY = self.lastCursorX, self.lastCursorY

		if self:IsPanning() then
			self.currentScrollX = self:GetNormalizedHorizontalScroll()
			self.currentScrollY = self:GetNormalizedVerticalScroll()

			self.targetScrollX = self.currentScrollX
			self.targetScrollY = self.currentScrollY
		end

		self.accumulatedMouseDeltaX = 0.0
		self.accumulatedMouseDeltaY = 0.0
	end
end

function Canvas:OnMouseUp(button)
	if button == "LeftButton" then
		if self:IsPanning() then
			local deltaX, deltaY = self:GetNormalizedMouseDelta()
			self:AccumulateMouseDeltas(GetTickTime(), deltaX, deltaY)

			self.targetScrollX = Clamp(self.targetScrollX + self.accumulatedMouseDeltaX, self.scrollXExtentsMin, self.scrollXExtentsMax)
			self.targetScrollY = Clamp(self.targetScrollY + self.accumulatedMouseDeltaY, self.scrollYExtentsMin, self.scrollYExtentsMax)
		end
		self.isLeftButtonDown = false
	elseif button == "RightButton" then
		if self:ShouldZoomInOnClick() then
			self:ZoomOut()
		end
	end
end

function Canvas:OnMouseWheel(delta)
	if self.mouseWheelZoomMode == CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE then
		return
	end

	if delta > 0 then
		if self:IsZoomedOut() or self:IsZoomingOut() or self.mouseWheelZoomMode == CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH then
			local cursorX, cursorY = self:GetCursorPosition()
			local normalizedCursorX = self:NormalizeHorizontalSize(cursorX / self:GetCanvasScale() - self.Child:GetLeft())
			local normalizedCursorY = self:NormalizeVerticalSize(self.Child:GetTop() - cursorY / self:GetCanvasScale())

			local minX, maxX, minY, maxY = self:CalculateScrollExtentsAtScale(self.maxScale)
			
			self:SetPanTarget(Clamp(normalizedCursorX, minX, maxX), Clamp(normalizedCursorY, minY, maxY))
		end

		if self.mouseWheelZoomMode == CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH then
			self:SetZoomTarget(self:GetCanvasScale() + self.zoomAmountPerMouseWheelDelta)
		elseif self.mouseWheelZoomMode == CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL then
			self:ZoomIn()
		end
	else
		if self.mouseWheelZoomMode == CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH then
			self:SetZoomTarget(self:GetCanvasScale() - self.zoomAmountPerMouseWheelDelta)
		elseif self.mouseWheelZoomMode == CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL then
			self:ZoomOut()
		end
	end
end

function Canvas:OnHide()
	self.isLeftButtonDown = false

	self.currentScale = nil
	self.currentScrollX = nil
	self.currentScrollY = nil
end

function Canvas:SetCanvasSize(width, height)
	self.Child:SetSize(width, height)
	self:CalculateScaleExtents()
	self:CalculateScrollExtents()
end

function Canvas:CalculateScaleExtents()
	if not self.maxScale then
		self:SetMaxZoom(self.defaultMaxScale)
	end

	if not self.minScale then
		self:SetMinZoom(self.defaultMinScale)
	end

	self.targetScale = Clamp(self.targetScale or self.minScale, self.minScale, self.maxScale)
end

function Canvas:CalculateScrollExtents()
	self.scrollXExtentsMin, self.scrollXExtentsMax, self.scrollYExtentsMin, self.scrollYExtentsMax = self:CalculateScrollExtentsAtScale(self:GetCanvasScale())
end

function Canvas:CalculateScrollExtentsAtScale(scale)
	local xOffset = self:NormalizeHorizontalSize((self:GetWidth() * .5) / scale)
	local yOffset = self:NormalizeVerticalSize((self:GetHeight() * .5) / scale)
	return 0.0 + xOffset, 1.0 - xOffset, 0.0 + yOffset, 1.0 - yOffset
end

do
	local MOUSE_DELTA_SAMPLES = 100
	local MOUSE_DELTA_FACTOR = 250
	function Canvas:AccumulateMouseDeltas(elapsed, deltaX, deltaY)
		-- If the mouse changes direction then clear out the old values so it doesn't slide the wrong direction
		if deltaX > 0 and self.accumulatedMouseDeltaX < 0 or deltaX < 0 and self.accumulatedMouseDeltaX > 0 then
			self.accumulatedMouseDeltaX = 0.0
		end

		if deltaY > 0 and self.accumulatedMouseDeltaY < 0 or deltaY < 0 and self.accumulatedMouseDeltaY > 0 then
			self.accumulatedMouseDeltaY = 0.0
		end
			
		local normalizedSamples = MOUSE_DELTA_SAMPLES * elapsed * 60
		self.accumulatedMouseDeltaX = (self.accumulatedMouseDeltaX / normalizedSamples) + (deltaX * MOUSE_DELTA_FACTOR) / normalizedSamples
		self.accumulatedMouseDeltaY = (self.accumulatedMouseDeltaY / normalizedSamples) + (deltaY * MOUSE_DELTA_FACTOR) / normalizedSamples
	end
end

function Canvas:CalculateLerpScaling()
	if self:ScalingMode() == "SCALING_MODE_TRANSLATE_FASTER_THAN_SCALE" then
		-- Because of the way zooming in + isLeftButtonDown is perceived, we want to reduce the zoom weight so that panning completes first
		-- However, for zooming out we want to prefer the zoom then pan
		local SCALE_DELTA_FACTOR = self:IsZoomingOut() and 1.5 or .01 
		local scaleDelta = (math.abs(self:GetCanvasScale() - self.targetScale) / (self.maxScale - self.minScale)) * SCALE_DELTA_FACTOR
		local scrollXDelta = math.abs(self:GetCurrentScrollX() - self.targetScrollX)
		local scrollYDelta = math.abs(self:GetCurrentScrollY() - self.targetScrollY)

		local largestDelta = math.max(math.max(scaleDelta, scrollXDelta), scrollYDelta)
		if largestDelta ~= 0.0 then
			return scaleDelta / largestDelta, scrollXDelta / largestDelta, scrollYDelta / largestDelta
		end
		return 1.0, 1.0, 1.0
	elseif self:ScalingMode() == "SCALING_MODE_LINEAR" then
		return 1.0, 1.0, 1.0
	end
end

function Canvas:SetScalingMode(mode)
	self.scalingMode = mode
end

function Canvas:ScalingMode()
	return self.scalingMode
end

local DELTA_SCALE_BEFORE_SNAP = .0001
local DELTA_POSITION_BEFORE_SNAP = .0001
function Canvas:OnUpdate(elapsed)
	if self:IsPanning() then
		local deltaX, deltaY = self:GetNormalizedMouseDelta()

		self.targetScrollX = Clamp(self.targetScrollX + deltaX, self.scrollXExtentsMin, self.scrollXExtentsMax)
		self.targetScrollY = Clamp(self.targetScrollY + deltaY, self.scrollYExtentsMin, self.scrollYExtentsMax)

		self.lastCursorX, self.lastCursorY = self:GetCursorPosition()

		self:AccumulateMouseDeltas(elapsed, deltaX, deltaY)
	end

	local scaleScaling, scrollXScaling, scrollYScaling = self:CalculateLerpScaling()

	if self.currentScale ~= self.targetScale then
		local oldScrollX = self:GetNormalizedHorizontalScroll()
		local oldScrollY = self:GetNormalizedVerticalScroll()

		if not self.currentScale or math.abs(self.currentScale - self.targetScale) < DELTA_SCALE_BEFORE_SNAP then
			self.currentScale = self.targetScale
		else
			self.currentScale = FrameDeltaLerp(self.currentScale, self.targetScale, self.normalizedZoomLerpAmount * scaleScaling)
		end

		self.Child:SetScale(self.currentScale)
		self:CalculateScrollExtents()

		self:SetNormalizedHorizontalScroll(oldScrollX)
		self:SetNormalizedVerticalScroll(oldScrollY)

		self:GetParent():OnCanvasScaleChanged()
		self:MarkAreaTriggersDirty()
		self:MarkViewRectDirty()
	end

	local panChanged = false
	if not self.currentScrollX or self.currentScrollX ~= self.targetScrollX then
		if not self.currentScrollX or self:IsPanning() or math.abs(self.currentScrollX - self.targetScrollX) < DELTA_POSITION_BEFORE_SNAP then
			self.currentScrollX = self.targetScrollX
		else
			self.currentScrollX = FrameDeltaLerp(self.currentScrollX, self.targetScrollX, self.normalizedPanXLerpAmount * scrollXScaling)
		end

		self:SetNormalizedHorizontalScroll(self.currentScrollX)
		self:MarkAreaTriggersDirty()
		self:MarkViewRectDirty()

		panChanged = true
	end

	if not self.currentScrollY or self.currentScrollY ~= self.targetScrollY then
		if not self.currentScrollY or self:IsPanning() or math.abs(self.currentScrollY - self.targetScrollY) < DELTA_POSITION_BEFORE_SNAP then
			self.currentScrollY = self.targetScrollY
		else
			self.currentScrollY = FrameDeltaLerp(self.currentScrollY, self.targetScrollY, self.normalizedPanYLerpAmount * scrollYScaling)
		end
		self:SetNormalizedVerticalScroll(self.currentScrollY)
		self:MarkAreaTriggersDirty()
		self:MarkViewRectDirty()

		panChanged = true
	end
	
	if panChanged then
		self:GetParent():OnCanvasPanChanged()
	end

	if self.areaTriggersDirty then
		self.areaTriggersDirty = false
		local viewRect = self:GetViewRect()
		self:GetParent():UpdateAreaTriggers(viewRect)
	end
end

function Canvas:MarkAreaTriggersDirty()
	self.areaTriggersDirty = true
end

function Canvas:MarkViewRectDirty()
	self.viewRect = nil
end

function Canvas:MarkCanvasDirty()
	-- Force an update unless an update is already going to occur
	if self.currentScale == self.targetScale then
		self.currentScale = nil
	end
	if self.currentScrollX == self.targetScrollX then
		self.currentScrollX = nil
	end
	if self.currentScrollY == self.targetScrollY then
		self.currentScrollY = nil
	end
end

function Canvas:GetViewRect()
	if not self.viewRect then
		self.viewRect = self:CalculateViewRect(self:GetCanvasScale())
	end
	return self.viewRect
end

function Canvas:SetMapID(mapID)
	self.mapID = mapID
end

function Canvas:SetShouldZoomInOnClick(shouldZoomInOnClick)
	self.shouldZoomInOnClick = shouldZoomInOnClick
end

function Canvas:ShouldZoomInOnClick()
	return not not self.shouldZoomInOnClick
end

function Canvas:SetShouldPanOnClick(shouldPanOnClick)
	self.shouldPanOnClick = shouldPanOnClick
end

function Canvas:ShouldPanOnClick()
	return not not self.shouldPanOnClick
end

function Canvas:SetMaxZoom(scale)
	self.maxScale = scale
end

function Canvas:SetMinZoom(scale)
	self.minScale = scale
end

function Canvas:GetMaxZoomViewRect()
	return self:CalculateViewRect(self.maxScale)
end

function Canvas:GetMinZoomViewRect()
	return self:CalculateViewRect(self.minScale)
end

function Canvas:CalculateViewRect(scale)
	local childWidth, childHeight = self.Child:GetSize()
	local left = self:GetHorizontalScroll() / childWidth
	local right = left + (self:GetWidth() / scale) / childWidth
	local top = self:GetVerticalScroll() / childHeight
	local bottom = top + (self:GetHeight() / scale) / childHeight
	return CreateRectangle(left, right, top, bottom)
end

function Canvas:CalculateZoomScaleAndPositionForAreaInViewRect(left, right, top, bottom, subViewLeft, subViewRight, subViewTop, subViewBottom)
	local childWidth, childHeight = self.Child:GetSize()
	local viewWidth, viewHeight = self:GetSize()

	-- this is the desired width/height of the full view given the desired positions for the subview
	local fullWidth = (right - left) / (subViewRight - subViewLeft)
	local fullHeight = (bottom - top) / (subViewTop - subViewBottom)

	local scale = ( viewWidth / fullWidth ) / childWidth

	-- translate from the upper-left of the subview to the center of the view.
	local fullLeft = left - (fullWidth * subViewLeft)
	local fullBottom = (1.0 - bottom) - (fullHeight * subViewBottom)

	local fullCenterX = fullLeft + (fullWidth / 2)
	local fullCenterY = 1.0 - (fullBottom + (fullHeight / 2))

	return scale, fullCenterX, fullCenterY
end

function Canvas:SetPanTarget(normalizedX, normalizedY)
	self.targetScrollX = normalizedX
	self.targetScrollY = normalizedY
end

function Canvas:SetZoomTarget(zoomTarget)
	self.targetScale = Clamp(zoomTarget, self.minScale, self.maxScale)
end

function Canvas:ZoomIn()
	self:SetZoomTarget(self.maxScale)
end

function Canvas:ZoomOut()
	self:SetZoomTarget(self.minScale)
	self:SetPanTarget(.5, .5)
end

function Canvas:IsZoomingIn()
	return self:GetCanvasScale() < self.targetScale
end

function Canvas:IsZoomingOut()
	return self.targetScale < self:GetCanvasScale()
end

function Canvas:IsZoomedIn()
	return self:GetCanvasScale() == self.maxScale
end

function Canvas:IsZoomedOut()
	return self:GetCanvasScale() == self.minScale
end

function Canvas:GetScaleForMaxZoom()
	return self.maxScale
end

function Canvas:GetScaleForMinZoom()
	return self.minScale
end

function Canvas:IsPanning()
	return self.isLeftButtonDown and not self:IsZoomingOut() and not self:IsZoomedOut()
end

function Canvas:GetCanvasScale()
	return self.currentScale or self.targetScale
end

function Canvas:GetCurrentScrollX()
	return self.currentScrollX or self.targetScrollX
end

function Canvas:GetCurrentScrollY()
	return self.currentScrollY or self.targetScrollY
end

function Canvas:GetCanvasZoomPercent()
	return PercentageBetween(self:GetCanvasScale(), self.minScale, self.maxScale)
end

function Canvas:SetNormalizedHorizontalScroll(scrollAmount)
	local offset = self:DenormalizeHorizontalSize(scrollAmount)
	self:SetHorizontalScroll(offset - (self:GetWidth() * .5) / self:GetCanvasScale())
end

function Canvas:GetNormalizedHorizontalScroll()
	return (2.0 * self:GetHorizontalScroll() * self:GetCanvasScale() + self:GetWidth()) / (2.0 * self.Child:GetWidth() * self:GetCanvasScale())
end

function Canvas:SetNormalizedVerticalScroll(scrollAmount)
	local offset = self:DenormalizeVerticalSize(scrollAmount)
	self:SetVerticalScroll(offset - (self:GetHeight() * .5) / self:GetCanvasScale())
end

function Canvas:GetNormalizedVerticalScroll()
	return (2.0 * self:GetVerticalScroll() * self:GetCanvasScale() + self:GetHeight()) / (2.0 * self.Child:GetHeight() * self:GetCanvasScale())
end

function Canvas:NormalizeHorizontalSize(size)
	return size / self.Child:GetWidth()
end

function Canvas:DenormalizeHorizontalSize(size)
	return size * self.Child:GetWidth()
end

function Canvas:NormalizeVerticalSize(size)
	return size / self.Child:GetHeight()
end

function Canvas:DenormalizeVerticalSize(size)
	return size * self.Child:GetHeight()
end

function Canvas:GetCursorPosition()
	local currentX, currentY = GetCursorPosition()
	local effectiveScale = UIParent:GetEffectiveScale()
	return currentX / effectiveScale, currentY / effectiveScale
end

function Canvas:GetNormalizedMouseDelta()
	if self.lastCursorX and self.lastCursorY then
		local currentX, currentY = self:GetCursorPosition()
		return self:NormalizeHorizontalSize(self.lastCursorX - currentX) / self:GetCanvasScale(), self:NormalizeVerticalSize(currentY - self.lastCursorY) / self:GetCanvasScale()
	end
	return 0.0, 0.0
end

-- Normalizes a global UI position to the map canvas
function Canvas:NormalizeUIPosition(x, y)
	return Saturate(self:NormalizeHorizontalSize(x / self:GetCanvasScale() - self.Child:GetLeft())),
		   Saturate(self:NormalizeVerticalSize(self.Child:GetTop() - y / self:GetCanvasScale()))
end

function Canvas:GetNormalizedCursorPosition()
	local x, y = self:GetCursorPosition()
	return self:NormalizeUIPosition(x, y)
end