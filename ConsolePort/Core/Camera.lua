---------------------------------------------------------------
-- Camera.lua: Action camera wrapper
---------------------------------------------------------------

local _, db, cfg = ...
---------------------------------------------------------------
UIParent:UnregisterEvent('EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED')

function ConsolePort:LoadCameraSettings()
	if not IsAddOnLoaded('DynamicCam') then
		cfg = db.Mouse
		if cfg and cfg.Camera then
			for cvar, val in pairs(cfg.Camera) do
				ConsoleExec(cvar .. ' ' .. tostring(val))	
			end
		end
	end
end
