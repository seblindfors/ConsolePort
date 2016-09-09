local _, db = ...

db.PLUGINS["Blizzard_MapCanvas"] = function(self)
	local NodeMixin, pins, maps, nodes = {}, {}, {}, {}
	local Mixin = db.table.mixin

	function NodeMixin:OnLeave() self.pin:OnMouseLeave() end
	function NodeMixin:OnClick() self.pin:OnClick("LeftButton") end
	function NodeMixin:OnEnter()
		local map = self.pin.owningMap
		self.pin:OnMouseEnter()
		if ( GameTooltip:GetOwner() == self.pin ) and
			db.Mouse.Cursor.Special and
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

	local function CreateNode(self)
		if pins[self] then return end

		local node = CreateFrame("Button", "CanvasNode"..#nodes+1, self)
		node.pin = self
		node:SetSize(4, 4)
		node:SetPoint("CENTER")
		node.noAnimation = true
		Mixin(node, NodeMixin)
		nodes[#nodes + 1] = node
		pins[self] = true
	end

	hooksecurefunc(MapCanvasMixin, "AcquirePin", function(self, pinTemplate, ...)
		for pin in self:EnumeratePinsByTemplate(pinTemplate) do
			CreateNode(pin, self, pinTemplate)
		end
		
		if maps[self] then return end
		ConsolePort:AddFrame(self)
		ConsolePort:UpdateFrames()
		maps[self] = true
		self.ScrollContainer.ignoreScroll = true
	end)

end