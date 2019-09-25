-- Workaround for the map canvas pins, which behave as buttons
-- using OnMouseDown, making the interface cursor dismiss the objects as
-- regular unclickable frames. 

local _, db = ...

ConsolePort:AddPlugin('Blizzard_MapCanvas', function(self)
	local NodeMixin, pins, maps, nodes = {}, {}, {}, {}
	local Mixin = db.table.mixin

	function NodeMixin:OnLeave() self.pin:OnMouseLeave() end
	function NodeMixin:OnClick() self.pin:OnClick('LeftButton') end
	function NodeMixin:OnEnter()
		local map = self.pin.owningMap
		self.pin:OnMouseEnter()
		if ( GameTooltip:GetOwner() == self.pin ) and
			db.Mouse.Cursor.Special and
			GetMouseFocus() ~= self and
			map:ShouldZoomInOnClick() then
			if map:IsZoomedIn() or map:IsZoomingIn() then
				map:PanTo(self.pin.normalizedX, self.pin.normalizedY)
				GameTooltip:AddLine(db.CLICK.MAP_CANVAS_ZOOM_OUT, 1, 1, 1)
			else
				GameTooltip:AddLine(db.CLICK.MAP_CANVAS_ZOOM_IN, 1, 1, 1)
			end
			GameTooltip:Show()
		end
	end

	function NodeMixin:SpecialClick()
		local map = self.pin.owningMap
		if not map:ShouldZoomInOnClick() then
			return
		end
		if map:IsZoomedIn() or map:IsZoomingIn() then
			map:ZoomOut()
		else
			local normalizedX, normalizedY = self.pin.normalizedX, self.pin.normalizedY
			map:PanAndZoomTo(normalizedX, normalizedY)
		end
	end

	local function CreateNode(pin)
		if pins[pin] then return end
		local index = #nodes + 1
		local node = CreateFrame('Button', 'CanvasNode'..index, pin)
		node.pin = pin
		node:SetSize(4, 4)
		node:SetPoint('CENTER')
		node.noAnimation = false
		Mixin(node, NodeMixin)
		nodes[index] = node
		pins[pin] = true
		pin.includeChildren = true
	end

	local function AddToMixinTracker(self)
		if not maps[self] then
			-- handle this edge case so the cursor doesn't bind to it
			if ( self:GetName() ~= 'BattlefieldMapFrame' ) then
				ConsolePort:AddFrame(self)
				ConsolePort:UpdateFrames()
				self.ScrollContainer.ignoreScroll = true
			end
			maps[self] = true
		end
	end

	local function AcquirePin(self, pinTemplate, ...)
		for pin in self:EnumeratePinsByTemplate(pinTemplate) do
			CreateNode(pin, self, pinTemplate)
		end
		AddToMixinTracker(self)
	end

	hooksecurefunc(MapCanvasMixin, 'AcquirePin', AcquirePin)

	if ( WorldMapFrame and WorldMapFrame.AcquirePin ) then
		hooksecurefunc(WorldMapFrame, 'AcquirePin', AcquirePin)
		AddToMixinTracker(WorldMapFrame)
	end
end)