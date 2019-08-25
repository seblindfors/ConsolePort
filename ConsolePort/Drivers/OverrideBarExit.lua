if CPAPI:IsClassicVersion() then return end
---------------------------------------------------------------
-- OverrideBarExit.lua: Exit vehicle/override/possess bar.
---------------------------------------------------------------
local ExitButton = OverrideActionBarLeaveFrameLeaveButton
---------------------------------------------------------------
local _, db = ...
local OBExit = ConsolePortOBExit
local EXIT_VEHICLE_BINDING = ('ACTIONBUTTON' .. ((NUM_OVERRIDE_BUTTONS or 6) + 1))

function OBExit:SetExitBinding(name, mod)
	RegisterStateDriver(self, 'override', '[vehicleui][overridebar][possessbar] true; nil')
	self:SetAttribute('_onstate-override', ([[
		if newstate then
			local key = GetBindingKey('%s')
			local mod = '%s'
			if key then
				self:SetBinding(true, mod..key, 'VEHICLEEXIT')
			end
		else
			self:ClearBindings()
		end
	]]):format(name, mod))
end

function OBExit:RemoveExitBinding()
	UnregisterStateDriver(self, 'override')
	self:SetAttribute('_onstate-override', nil)
	self:Execute([[self:ClearBindings()]])
end

function OBExit:SetHotkey(name, mod)
	if ( name and mod ) then
		if not self.HotKey and ExitButton then
			-- hack: use ctrl+shift here to spawn two mod icons
			self.HotKey = db.CreateHotkey(ExitButton, nil, 'CTRL-SHIFT-', name)
			self.HotKey:SetPoint('TOPRIGHT', ExitButton, 0, 0)
		end
		if 	self.HotKey then
			self.HotKey:Show()
			self.HotKey:SetBindingCombination(name, mod)
		end
	elseif self.HotKey then
		self.HotKey:Hide()
	end
end

function OBExit:OnNewBinding()
	-- wait until out of combat.
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:SetScript('OnEvent', function(self)
			self:UnregisterAllEvents()
			self:SetScript('OnEvent', nil)
			self:OnNewBinding()
		end)
		return
	end

	-- check if user has bound this explicitly first.
	local name, mod = ConsolePort:GetCurrentBindingOwner('VEHICLEEXIT')
	if name and mod then
		self:SetHotkey(name, mod)
		self:RemoveExitBinding()
		return
	end

	-- if there's no explicit binding, use cvar binding or a binding that isn't going to be in conflict.
	-- need to consider the cvar can be invalid (not nil), which allows user to disable this functionality.
	local cvarBinding, exitVehicleBinding = db('exitVehicleBinding')
	exitVehicleBinding = (cvarBinding ~= nil) and cvarBinding or EXIT_VEHICLE_BINDING
	name, mod = ConsolePort:GetCurrentBindingOwner(exitVehicleBinding)

	-- no eligible bindings found at this point, bail out.
	if not name or not mod then
		self:SetHotkey(nil, nil)
		self:RemoveExitBinding()
		return
	end

	-- there's a match for a non-conflict binding, set up state driver.
	self:SetHotkey(name, mod)
	self:SetExitBinding(name, mod)
end

ConsolePort:RegisterCallback('OnNewBindings', OBExit.OnNewBinding, OBExit)