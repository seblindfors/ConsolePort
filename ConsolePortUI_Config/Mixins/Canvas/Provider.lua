local _, L = ...
local Provider = CreateFromMixins(CallbackRegistryBaseMixin)
L.ProviderMixin = Provider

function Provider:OnLoad()
	CallbackRegistryBaseMixin.OnLoad(self)
	self.detailLayerPool = CreateFramePool('FRAME', self:GetCanvas(), nil)
	self.dataProviders = {}
	self.dataProviderEventsCount = {}
	self.pinPools = {}
	self.pinTemplateTypes = {}
	self.activeAreaTriggers = {}
	self.lockReasons = {}
	self.pinsToNudge = {}

	self.debugAreaTriggers = false
end

function Provider:OnUpdate()
	self:UpdatePinNudging()
end

function Provider:SetMapInsetPool(mapInsetPool)
	self.mapInsetPool = mapInsetPool
end

function Provider:GetMapInsetPool()
	return self.mapInsetPool
end

function Provider:OnShow()
	local FROM_ON_SHOW = true
	self:RefreshAll(FROM_ON_SHOW)

	for dataProvider in pairs(self.dataProviders) do
		dataProvider:OnShow()
	end
end

function Provider:OnHide()
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:OnHide()
	end
end

function Provider:OnEvent(event, ...)
	-- Data provider event
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:SignalEvent(event, ...)
	end
end

function Provider:AddDataProvider(dataProvider)
	self.dataProviders[dataProvider] = true
	dataProvider:OnAdded(self)
end

function Provider:RemoveDataProvider(dataProvider)
	dataProvider:RemoveAllData()
	self.dataProviders[dataProvider] = nil
	dataProvider:OnRemoved(self)
end

function Provider:AddDataProviderEvent(event)
	self.dataProviderEventsCount[event] = (self.dataProviderEventsCount[event] or 0) + 1
	self:RegisterEvent(event)
end

function Provider:RemoveDataProviderEvent(event)
	if self.dataProviderEventsCount[event] then
		self.dataProviderEventsCount[event] = self.dataProviderEventsCount[event] - 1
		if self.dataProviderEventsCount[event] == 0 then
			self.dataProviderEventsCount[event] = nil
			self:UnregisterEvent(event)
		end
	end
end

do
	local function OnPinReleased(pinPool, pin)
		FramePool_HideAndClearAnchors(pinPool, pin)
		pin:OnReleased()

		pin.pinTemplate = nil
		pin.owningMap = nil
	end

	local function OnPinMouseUp(pin, button, upInside)
		if upInside then
			pin:OnClick(button)
		end
	end

	function Provider:AcquirePin(pinTemplate, ...)
		if not self.pinPools[pinTemplate] then
			local pinTemplateType = self.pinTemplateTypes[pinTemplate] or 'FRAME'
			self.pinPools[pinTemplate] = CreateFramePool(pinTemplateType, self:GetCanvas(), pinTemplate, OnPinReleased)
		end

		local pin, newPin = self.pinPools[pinTemplate]:Acquire()

		if pin:IsMouseClickEnabled() then
			pin:SetScript('OnMouseUp', OnPinMouseUp)
		end

		if pin:IsMouseMotionEnabled() then
			pin:SetScript('OnEnter', pin.OnMouseEnter)
			pin:SetScript('OnLeave', pin.OnMouseLeave)
		end

		pin.pinTemplate = pinTemplate
		pin.owningMap = self

		if newPin then
			pin:OnLoad()
		end

		self.ScrollContainer:MarkCanvasDirty()

		pin:OnAcquired(...)

		return pin
	end
end

function Provider:SetPinTemplateType(pinTemplate, pinTemplateType)
	self.pinTemplateTypes[pinTemplate] = pinTemplateType
end

function Provider:RemoveAllPinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		self.pinPools[pinTemplate]:ReleaseAll()
		self.ScrollContainer:MarkCanvasDirty()
	end
end

function Provider:RemovePin(pin)
	self.pinPools[pin.pinTemplate]:Release(pin)
	self.ScrollContainer:MarkCanvasDirty()
end

function Provider:EnumeratePinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		return self.pinPools[pinTemplate]:EnumerateActive()
	end
	return nop
end

function Provider:GetNumActivePinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		return self.pinPools[pinTemplate]:GetNumActive()
	end
	return 0
end

function Provider:EnumerateAllPins()
	local currentPoolKey, currentPool = next(self.pinPools, nil)
	local currentPin = nil
	return function()
		if currentPool then
			currentPin = currentPool:GetNextActive(currentPin)
			while not currentPin do
				currentPoolKey, currentPool = next(self.pinPools, currentPoolKey)
				if currentPool then
					currentPin = currentPool:GetNextActive()
				else
					break
				end
			end
		end

		return currentPin
	end, nil
end

function Provider:AcquireAreaTrigger(namespace)
	if not self.activeAreaTriggers[namespace] then
		self.activeAreaTriggers[namespace] = {}
	end
	local areaTrigger = CreateRectangle()
	areaTrigger.enclosed = false
	areaTrigger.intersects = false

	areaTrigger.intersectCallback = nil
	areaTrigger.enclosedCallback = nil
	areaTrigger.triggerPredicate = nil

	self.activeAreaTriggers[namespace][areaTrigger] = true
	self.ScrollContainer:MarkAreaTriggersDirty()
	return areaTrigger
end

function Provider:SetAreaTriggerEnclosedCallback(areaTrigger, enclosedCallback)
	areaTrigger.enclosedCallback = enclosedCallback
	self.ScrollContainer:MarkAreaTriggersDirty()
end

function Provider:SetAreaTriggerIntersectsCallback(areaTrigger, intersectCallback)
	areaTrigger.intersectCallback = intersectCallback
	self.ScrollContainer:MarkAreaTriggersDirty()
end

function Provider:SetAreaTriggerPredicate(areaTrigger, triggerPredicate)
	areaTrigger.triggerPredicate = triggerPredicate
	self.ScrollContainer:MarkAreaTriggersDirty()
end

function Provider:UpdateAreaTriggers(scrollRect)
	for namespace, areaTriggers in pairs(self.activeAreaTriggers) do
		for areaTrigger in pairs(areaTriggers) do
			if areaTrigger.intersectCallback then
				local intersects = (not areaTrigger.triggerPredicate or areaTrigger.triggerPredicate(areaTrigger)) and scrollRect:IntersectsRect(areaTrigger)
				if areaTrigger.intersects ~= intersects then
					areaTrigger.intersects = intersects
					areaTrigger.intersectCallback(areaTrigger, intersects)
				end
			end

			if areaTrigger.enclosedCallback then
				local enclosed = (not areaTrigger.triggerPredicate or areaTrigger.triggerPredicate(areaTrigger)) and scrollRect:EnclosesRect(areaTrigger)

				if areaTrigger.enclosed ~= enclosed then
					areaTrigger.enclosed = enclosed
					areaTrigger.enclosedCallback(areaTrigger, enclosed)
				end
			end
		end
	end
end

function SquaredDistanceBetweenPoints(firstX, firstY, secondX, secondY)
	local xDiff = firstX - secondX
	local yDiff = firstY - secondY
	
	return xDiff * xDiff + yDiff * yDiff
end

function Provider:CalculatePinNudging(targetPin)
	if not targetPin:IgnoresNudging() and targetPin:GetNudgeTargetFactor() > 0 then
		local normalizedX, normalizedY = targetPin:GetPosition()
		for sourcePin in self:EnumerateAllPins() do
			if targetPin ~= sourcePin and not sourcePin:IgnoresNudging() and sourcePin:GetNudgeSourceFactor() > 0 then
				local otherNormalizedX, otherNormalizedY = sourcePin:GetPosition()
				local distanceSquared = SquaredDistanceBetweenPoints(normalizedX, normalizedY, otherNormalizedX, otherNormalizedY)
				
				local nudgeFactor = targetPin:GetNudgeTargetFactor() * sourcePin:GetNudgeSourceFactor()
				if distanceSquared < nudgeFactor * nudgeFactor then
					-- Avoid divide by zero: just push it right.
					if distanceSquared == 0 then
						targetPin:SetNudgeVector(1, 0)
					else
						local distance = math.sqrt(distanceSquared)
						targetPin:SetNudgeVector((normalizedX - otherNormalizedX) / distance, (normalizedY - otherNormalizedY) / distance)
					end
					
					targetPin:SetNudgeFactor(nudgeFactor)
					break -- This is non-exact: each target pin only gets pushed by one source pin.
				end
			end
		end
	end
end

function Provider:UpdatePinNudging()
	if not self.pinNudgingDirty and #self.pinsToNudge == 0 then
		return
	end
	
	if self.pinNudgingDirty then
		for targetPin in self:EnumerateAllPins() do
			self:CalculatePinNudging(targetPin)
		end
	else
		for _, targetPin in ipairs(self.pinsToNudge) do
			self:CalculatePinNudging(targetPin)
		end
	end
	
	self.pinNudgingDirty = false
	self.pinsToNudge = {}
end

function Provider:TryRefreshingDebugAreaTriggers()
	if self.debugAreaTriggers then
		self:RefreshDebugAreaTriggers()
	elseif self.debugAreaTriggerPool then
		self.debugAreaTriggerPool:ReleaseAll()
	end
end

function Provider:SetDebugAreaTriggersEnabled(enabled)
	self.debugAreaTriggers = enabled
	self.ScrollContainer:MarkAreaTriggersDirty()
end

function Provider:RefreshDetailLayers()
	if not self.areDetailLayersDirty then return end
	self.detailLayerPool:ReleaseAll()

	for layerIndex = 1, C_MapCanvas.GetNumDetailLayers(self.mapID) do
		if layerIndex == 1 then
			-- Layer 1 is our base layer, set the canvas to that size
			local numDetailTilesCols, numDetailTilesRows = C_MapCanvas.GetNumDetailTiles(self.mapID, layerIndex)
			self.ScrollContainer:SetCanvasSize(MapCanvasDetailLayer_CalculateTotalLayerSize(numDetailTilesCols, numDetailTilesRows))
		end

		local detailLayer = self.detailLayerPool:Acquire()
		detailLayer:SetAllPoints(self:GetCanvas())
		detailLayer:SetMapAndLayer(self.mapID, layerIndex)
		detailLayer:Show()
	end

	self:AdjustDetailLayerAlpha()

	self.areDetailLayersDirty = false
end

function Provider:AdjustDetailLayerAlpha()
	-- For right now we're supporting just two layers, one zoomed out and one fully zoomed in
	local zoomPercent = self:GetCanvasZoomPercent()

	for layer in self.detailLayerPool:EnumerateActive() do
		local layerIndex = layer:GetLayerIndex()
		if layerIndex == 1 then
			layer:SetAlpha(1)
		else
			layer:SetAlpha(zoomPercent)
		end
	end
end

function Provider:RefreshAllDataProviders(fromOnShow)
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:RefreshAllData(fromOnShow)
	end
end

function Provider:ResetInsets()
	if self.mapInsetPool then
		self.mapInsetPool:ReleaseAll()
		self.mapInsetsByIndex = {}
	end
end

function Provider:RefreshInsets()
	self:ResetInsets()
end

function Provider:AddInset(insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY)
	if self.mapInsetPool then
		local mapInset = self.mapInsetPool:Acquire()
		local expanded = self.expandedMapInsetsByMapID[mapID]
		mapInset:Initialize(self, not expanded, insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY)

		self.mapInsetsByIndex[insetIndex] = mapInset
	end
end

function Provider:RefreshAll(fromOnShow)
	self:RefreshDetailLayers()
	self:RefreshInsets()
	self:RefreshAllDataProviders(fromOnShow)
end

function Provider:SetPinPosition(pin, normalizedX, normalizedY, insetIndex)
	self:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex)
	if not pin:IgnoresNudging() then
		if pin:GetNudgeSourceFactor() > 0 then
			-- If we nudge other things we need to recalculate all nudging.
			self.pinNudgingDirty = true
		else
			self.pinsToNudge[#self.pinsToNudge + 1] = pin
		end
	end
end

function Provider:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex)
	if insetIndex then
		if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
			self.mapInsetsByIndex[insetIndex]:SetLocalPinPosition(pin, normalizedX, normalizedY)
		end
	else
		pin:ClearAllPoints()
		if normalizedX and normalizedY then
			local x = normalizedX
			local y = normalizedY
			
			local nudgeVectorX, nudgeVectorY = pin:GetNudgeVector()
			if nudgeVectorX and nudgeVectorY then
				local finalNudgeFactor = pin:GetNudgeFactor() * pin:GetNudgeZoomFactor()
				x = normalizedX + nudgeVectorX * finalNudgeFactor
				y = normalizedY + nudgeVectorY * finalNudgeFactor
			end
			
			local canvas = self:GetCanvas()
			local scale = pin:GetScale()
			pin:SetParent(canvas)
			pin:SetPoint('CENTER', canvas, 'TOPLEFT', (canvas:GetWidth() * x) / scale, -(canvas:GetHeight() * y) / scale)
		end
	end
end

function Provider:GetGlobalPosition(normalizedX, normalizedY, insetIndex)
	if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
		return self.mapInsetsByIndex[insetIndex]:GetGlobalPosition(normalizedX, normalizedY)
	end
	return normalizedX, normalizedY
end

function Provider:GetCanvas()
	return self.ScrollContainer.Child
end

function Provider:CallMethodOnPinsAndDataProviders(methodName, ...)
	for dataProvider in pairs(self.dataProviders) do
		dataProvider[methodName](dataProvider, ...)
	end

	for pin in self:EnumerateAllPins() do
		pin[methodName](pin, ...)
	end
end

function Provider:OnMapInsetSizeChanged(mapID, mapInsetIndex, expanded)
	self.expandedMapInsetsByMapID[mapID] = expanded
	self:CallMethodOnPinsAndDataProviders('OnMapInsetSizeChanged', mapInsetIndex, expanded)
end

function Provider:OnMapInsetMouseEnter(mapInsetIndex)
	self:CallMethodOnPinsAndDataProviders('OnMapInsetMouseEnter', mapInsetIndex)
end

function Provider:OnMapInsetMouseLeave(mapInsetIndex)
	self:CallMethodOnPinsAndDataProviders('OnMapInsetMouseLeave', mapInsetIndex)
end

function Provider:OnCanvasScaleChanged()
	self:AdjustDetailLayerAlpha()

	if self.mapInsetsByIndex then
		for insetIndex, mapInset in pairs(self.mapInsetsByIndex) do
			mapInset:OnCanvasScaleChanged()
		end
	end

	self:CallMethodOnPinsAndDataProviders('OnCanvasScaleChanged')
end

function Provider:OnCanvasPanChanged()
	self:CallMethodOnPinsAndDataProviders('OnCanvasPanChanged')
end

function Provider:GetCanvasScale()
	return self.ScrollContainer:GetCanvasScale()
end

function Provider:GetCanvasZoomPercent()
	return self.ScrollContainer:GetCanvasZoomPercent()
end

function Provider:IsZoomingIn()
	return self.ScrollContainer:IsZoomingIn()
end

function Provider:IsZoomingOut()
	return self.ScrollContainer:IsZoomingOut()
end

function Provider:ZoomIn()
	self.ScrollContainer:ZoomIn()
end

function Provider:ZoomOut()
	self.ScrollContainer:ZoomOut()
end

function Provider:IsZoomedIn()
	return self.ScrollContainer:IsZoomedIn()
end

function Provider:IsZoomedOut()
	return self.ScrollContainer:IsZoomedOut()
end

function Provider:PanTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY)
end

function Provider:PanAndZoomTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY)
	self.ScrollContainer:ZoomIn()
end

function Provider:SetShouldZoomInOnClick(shouldZoomInOnClick)
	self.ScrollContainer:SetShouldZoomInOnClick(shouldZoomInOnClick)
end

function Provider:ShouldZoomInOnClick()
	return self.ScrollContainer:ShouldZoomInOnClick()
end

function Provider:SetShouldPanOnClick(shouldPanOnClick)
	self.ScrollContainer:SetShouldPanOnClick(shouldPanOnClick)
end

function Provider:ShouldPanOnClick()
	return self.ScrollContainer:ShouldPanOnClick()
end

function Provider:SetDefaultMaxZoom()
	self.ScrollContainer:SetMaxZoom(self.ScrollContainer.defaultMaxScale)
end

function Provider:SetDefaultMinZoom()
	self.ScrollContainer:SetMinZoom(self.ScrollContainer.defaultMinScale)
end

function Provider:SetMaxZoom(scale)
	self.ScrollContainer:SetMaxZoom(scale)
end

function Provider:SetMinZoom(scale)
	self.ScrollContainer:SetMinZoom(scale)
end

function Provider:GetViewRect()
	return self.ScrollContainer:GetViewRect()
end

function Provider:GetMaxZoomViewRect()
	return self.ScrollContainer:GetMaxZoomViewRect()
end

function Provider:GetMinZoomViewRect()
	return self.ScrollContainer:GetMinZoomViewRect()
end

function Provider:GetScaleForMaxZoom()
	return self.ScrollContainer:GetScaleForMaxZoom()
end

function Provider:GetScaleForMinZoom()
	return self.ScrollContainer:GetScaleForMinZoom()
end

function Provider:CalculateZoomScaleAndPositionForAreaInViewRect(...)
	return self.ScrollContainer:CalculateZoomScaleAndPositionForAreaInViewRect(...)
end

function Provider:NormalizeHorizontalSize(size)
	return self.ScrollContainer:NormalizeHorizontalSize(size)
end

function Provider:DenormalizeHorizontalSize(size)
	return self.ScrollContainer:DenormalizeHorizontalSize(size)
end

function Provider:NormalizeVerticalSize(size)
	return self.ScrollContainer:NormalizeVerticalSize(size)
end

function Provider:DenormalizeVerticalSize(size)
	return self.ScrollContainer:DenormalizeVerticalSize(size)
end

function Provider:GetNormalizedCursorPosition()
	return self.ScrollContainer:GetNormalizedCursorPosition()
end

function Provider:IsCanvasMouseFocus()
	return self.ScrollContainer == GetMouseFocus()
end