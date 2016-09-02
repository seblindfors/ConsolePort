---- Flight map nodes:
-- The flight map uses plain frame widgets with a calculation process
-- on the container to figure out which data point to click. This
-- process cannot be mimicked by the UI cursor without replacing huge
-- chunks of the official code, which is why button nodes are simply spawned
-- on top of the frame objects within the flight map frame.

local _, db = ...
db.PLUGINS["Blizzard_FlightMap"] = function(self)
	-----------------------------------------
	local Path, flightNodes, FP, Mixin = {}, {}, FlightMapFrame, db.table.mixin
	-----------------------------------------

	function Path:OnEnter() self = self:GetParent()
		if self.taxiNodeData then
			GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 20, 0)

			GameTooltip:AddLine(self.taxiNodeData.name, nil, nil, nil, true)

			if self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_CURRENT then
				GameTooltip:AddLine(TAXINODEYOUAREHERE, 1.0, 1.0, 1.0, true)
			elseif self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
				local cost = TaxiNodeCost(self.taxiNodeData.slotIndex)
				if cost > 0 then
					SetTooltipMoney(GameTooltip, cost)
				end

				self.owner:HighlightRouteToPin(self)
			elseif self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_UNREACHABLE then
				GameTooltip:AddLine(TAXI_PATH_UNREACHABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
			end

			GameTooltip:Show()
		end
	end

	function Path:OnLeave() self = self:GetParent()
		if self.taxiNodeData then
			if self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
				if self.owner.highlightLinePool then
					self.owner:RemoveRoute()
				end
			end
			GameTooltip:Hide()
		end
	end

	function Path:OnClick() self = self:GetParent()
		if self.taxiNodeData then
			TakeTaxiNode(self.taxiNodeData.slotIndex)
		end
		GameTooltip:Hide()
	end

	local function CreateFlightNode(parent)
		local node = CreateFrame("Button", "FlightNode"..#flightNodes+1, parent)
		Mixin(node, Path)
		node:SetSize(4,4)
		flightNodes[#flightNodes + 1] = node
		return node
	end

	-----------------------------------------
	-- Gather all visible flight paths in a table and
	-- create an overlapping click button for each.
	-----------------------------------------
	FP:HookScript("OnShow", function(self)
		for _, node in pairs(flightNodes) do
			node:Hide()
		end
		local paths = {}

		for _, widget in pairs({self.ScrollContainer.Child:GetChildren()}) do
			if widget.taxiNodeData then
				paths[#paths + 1] = widget
			end
		end

		for i, path in pairs(paths) do
			node = flightNodes[i] or CreateFlightNode(path)
			node:SetParent(path)
			node:ClearAllPoints()
			node:SetPoint("CENTER", path, 0, 0)
			node:Show()
		end
	end)

	FP.ScrollContainer.ignoreScroll = true
	
	self:AddFrame(FP)
end