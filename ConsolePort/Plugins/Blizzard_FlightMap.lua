---- Flight map nodes:
-- The flight map uses plain frame widgets with a calculation process
-- on the container to figure out which data point to click. This
-- process cannot be mimicked by the UI cursor without replacing huge
-- chunks of the official code, which is why button nodes are simply spawned
-- on top of the frame objects within the flight map frame.

local _, db = ...
db.PLUGINS["Blizzard_FlightMap"] = function(self)
	-----------------------------------------
	local flightNodes = {}
	-----------------------------------------
	local FP = FlightMapFrame
	-----------------------------------------

	local function EnterFlightNode(self)
		local path = self:GetParent()

		if path.taxiNodeData then
			GameTooltip:SetOwner(path, "ANCHOR_PRESERVE")
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPLEFT", path, "TOPRIGHT", 20, 0)

			GameTooltip:AddLine(path.taxiNodeData.name, nil, nil, nil, true)

			if path.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_CURRENT then
				GameTooltip:AddLine(TAXINODEYOUAREHERE, 1.0, 1.0, 1.0, true)
			elseif path.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
				local cost = TaxiNodeCost(path.taxiNodeData.slotIndex)
				if cost > 0 then
					SetTooltipMoney(GameTooltip, cost)
				end

				path.owner:HighlightRouteToPin(path)
			elseif path.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_UNREACHABLE then
				GameTooltip:AddLine(TAXI_PATH_UNREACHABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
			end

			GameTooltip:Show()
		end
	end

	local function LeaveFlightNode(self)
		local path = self:GetParent()

		if path.taxiNodeData then
			if path.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
				path.owner:RemoveRoute()
			end
			GameTooltip:Hide()
		end
	end	

	local function ClickFlightNode(self)
		local path = self:GetParent()
		if path.taxiNodeData then
			TakeTaxiNode(path.taxiNodeData.slotIndex)
		end
		GameTooltip:Hide()
	end

	local function CreateFlightNode(parent)
		local node = CreateFrame("Button", "FlightNode"..#flightNodes+1, parent)
		node:SetScript("OnEnter", EnterFlightNode)
		node:SetScript("OnLeave", LeaveFlightNode)
		node:SetScript("OnClick", ClickFlightNode)
		node:SetSize(4,4)
		flightNodes[#flightNodes + 1] = node
		return node
	end


	-----------------------------------------
	-----------------------------------------

	local function GetFlightNodes(self)
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
	end

	FP:HookScript("OnShow", GetFlightNodes)

	self:AddFrame(FP)
end