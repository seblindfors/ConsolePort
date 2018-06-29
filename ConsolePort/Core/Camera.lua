---------------------------------------------------------------
-- Action camera wrapper
---------------------------------------------------------------
local _, db, cfg = ...
---------------------------------------------------------------
UIParent:UnregisterEvent('EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED')

function ConsolePort:LoadCameraSettings()
	if not IsAddOnLoaded('DynamicCam') then
		cfg = db.Mouse
		if cfg and cfg.Camera then
			for cvar, val in pairs(cfg.Camera) do
				if GetCVar(cvar) ~= nil then
					local success = pcall(ConsoleExec, (cvar .. ' ' .. tostring(val)))
					if not success then
						print('Attempted to modify missing cvar:', cvar)
					end
				end
			end
		end
	end
end

---------------------------------------------------------------
-- Zoom wrapper
---------------------------------------------------------------
local ZoomHandler = CreateFrame('Frame')
local delta, iteration, modReduction = 0, 1, 1
ZoomHandler:Hide()
ZoomHandler:SetScript('OnUpdate', function(self)
	if (modReduction % 7) == 1 then 
		if delta > 0 then
			CameraZoomIn(iteration)
		else
			CameraZoomOut(iteration)
		end
		iteration = iteration + 1
	end
	modReduction = modReduction + 1
end)

function ConsolePort:CameraZoom(isZooming, zoomDelta)
	if isZooming then
		delta = zoomDelta
		ZoomHandler:Show()
	else
		ZoomHandler:Hide()
		delta, iteration, modReduction = 0, 1, 1
	end
end