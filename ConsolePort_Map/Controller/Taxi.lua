local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Flight mode
---------------------------------------------------------------
-- On TAXIMAP_OPENED the flight canvas opens on the taxi map. Blizzard's
-- FlightMapFrame stays shown but transparent and mouse-less: its OnHide
-- calls CloseTaxiMap, which would end the session. Our cancel button
-- calls CloseTaxiMap itself; Blizzard's TAXIMAP_CLOSED handler then
-- hides its panel. The legacy TaxiFrame system is left alone.
local Taxi = CPAPI.CreateEventHandler({'Frame', '$parentTaxiHandler', ConsolePort}, {
	'TAXIMAP_OPENED';
	'TAXIMAP_CLOSED';
}); env.Taxi = Taxi;

local function OverlayFlightMapFrame(active)
	if not FlightMapFrame then return end
	FlightMapFrame:SetAlpha(active and 0 or 1)
	FlightMapFrame:EnableMouse(not active)
	FlightMapFrame:EnableMouseWheel(not active)
	if FlightMapFrame.ScrollContainer then
		FlightMapFrame.ScrollContainer:EnableMouse(not active)
		FlightMapFrame.ScrollContainer:EnableMouseWheel(not active)
	end
end

function Taxi:HookFlightMapFrame()
	if self.hooked or not FlightMapFrame then return end
	self.hooked = true;
	FlightMapFrame:HookScript('OnShow', function()
		if self.active then
			OverlayFlightMapFrame(true)
		end
	end)
end

function Taxi:TAXIMAP_OPENED(system)
	if not db('mapFlightMode') or not db('mapEnable') then return end
	if Enum.UIMapSystem and system == Enum.UIMapSystem.Taxi then return end
	if not GetTaxiMapID then return end
	local mapID = GetTaxiMapID()
	if not env.Map:Open('Flight', mapID, true) then return end
	self.active = true;
	self:HookFlightMapFrame()
	OverlayFlightMapFrame(true)
end

function Taxi:TAXIMAP_CLOSED()
	if not self.active then return end
	self.active = nil;
	OverlayFlightMapFrame(false)
	if env.Map:IsShown() and env.Map:GetActiveCanvas() and env.Map:GetActiveCanvas().kind == 'Flight' then
		env.Map:Hide()
	end
end
