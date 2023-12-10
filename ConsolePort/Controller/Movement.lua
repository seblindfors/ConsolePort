---------------------------------------------------------------
-- Movement
---------------------------------------------------------------
-- Handles movement settings and conditionals.

local _, db = ...;
local Movement = db:Register('Movement', CPAPI.CreateEventHandler({'Frame', '$parentMovementHandler', ConsolePort, 'SecureHandlerAttributeTemplate'}, nil, {
	Proxy = {
		AnalogMovement    = db.Data.Cvar('GamePadAnalogMovement');
		StrafeAngleTravel = db.Data.Cvar('GamePadFaceMovementMaxAngle');
		StrafeAngleCombat = db.Data.Cvar('GamePadFaceMovementMaxAngleCombat');
		RunWalkThreshold  = db.Data.Cvar('GamePadRunThreshold');
		TurnWithCamera    = db.Data.Cvar('GamePadTurnWithCamera');
	};
	Attributes = {
		Travel = 'strafetravel';
		Combat = 'strafecombat';
	};
}));

function Movement:OnDataLoaded()
	self:UpdateAnalogMovement()
	self:UpdateStrafeAngleTravel()
	self:UpdateStrafeAngleCombat()
	self:UpdateRunWalkThreshold()
	self:UpdateTurnWithCamera()
	self:UpdateConditionals()
end

function Movement:UpdateAnalogMovement()
	self.Proxy.AnalogMovement:Set(db('mvmtAnalog'))
end

function Movement:UpdateStrafeAngleTravel(value)
	self.Proxy.StrafeAngleTravel:Set(value or db('mvmtStrafeAngleTravel'))
end

function Movement:UpdateStrafeAngleCombat(value)
	self.Proxy.StrafeAngleCombat:Set(value or db('mvmtStrafeAngleCombat'))
end

function Movement:UpdateRunWalkThreshold(value)
	self.Proxy.RunWalkThreshold:Set(value or db('mvmtRunThreshold'))
end

function Movement:UpdateTurnWithCamera(value)
	self.Proxy.TurnWithCamera:Set(value or db('mvmtTurnWithCamera'))
end

db:RegisterCallback('Settings/mvmtAnalog',            Movement.UpdateAnalogMovement,    Movement)
db:RegisterCallback('Settings/mvmtStrafeAngleTravel', Movement.UpdateStrafeAngleTravel, Movement)
db:RegisterCallback('Settings/mvmtStrafeAngleCombat', Movement.UpdateStrafeAngleCombat, Movement)
db:RegisterCallback('Settings/mvmtRunThreshold',      Movement.UpdateRunWalkThreshold,  Movement)
db:RegisterCallback('Settings/mvmtTurnWithCamera',    Movement.UpdateTurnWithCamera,    Movement)

function Movement:UpdateConditionals()
	local strafeAngleTravelMacro = db('mvmtStrafeAngleTravelMacro')
	local strafeAngleCombatMacro = db('mvmtStrafeAngleCombatMacro')
	if strafeAngleTravelMacro then
		RegisterAttributeDriver(self, self.Attributes.Travel, strafeAngleTravelMacro)
	else
		UnregisterAttributeDriver(self, self.Attributes.Travel)
	end
	if strafeAngleCombatMacro then
		RegisterAttributeDriver(self, self.Attributes.Combat, strafeAngleCombatMacro)
	else
		UnregisterAttributeDriver(self, self.Attributes.Combat)
	end
end

db:RegisterSafeCallback('Settings/mvmtStrafeAngleTravelMacro', Movement.UpdateConditionals, Movement)
db:RegisterSafeCallback('Settings/mvmtStrafeAngleCombatMacro', Movement.UpdateConditionals, Movement)

function Movement:OnAttributeChanged(attribute, value)
	local value = tonumber(value)
	if ( attribute == self.Attributes.Travel ) then
		return self:UpdateStrafeAngleTravel(value)
	elseif ( attribute == self.Attributes.Combat ) then
		return self:UpdateStrafeAngleCombat(value)
	end
end

CPAPI.Start(Movement)