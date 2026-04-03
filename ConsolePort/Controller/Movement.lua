---------------------------------------------------------------
-- Movement
---------------------------------------------------------------
-- Handles movement settings and conditionals.

local _, db = ...;
local Movement = db:Register('Movement', CPAPI.CreateEventHandler({'Frame', '$parentMovementHandler', ConsolePort, 'SecureHandlerAttributeTemplate'}, {
	'UNIT_ENTERING_VEHICLE';
	'UNIT_EXITING_VEHICLE';
	'UNIT_SPELLCAST_CHANNEL_START';
	'UNIT_SPELLCAST_CHANNEL_STOP';
	'UNIT_SPELLCAST_EMPOWER_START';
	'UNIT_SPELLCAST_EMPOWER_STOP';
	'UNIT_SPELLCAST_START';
	'UNIT_SPELLCAST_STOP';
}, {
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

---------------------------------------------------------------
-- Data loading
---------------------------------------------------------------
function Movement:OnDataLoaded()
	self:UpdateAnalogMovement()
	self:UpdateStrafeAngleTravel()
	self:UpdateStrafeAngleCombat()
	self:UpdateStrafeAngleJump()
	self:UpdateRunWalkThreshold()
	self:UpdateTurnWithCamera()
	self:UpdateConditionals()
	self:UnregisterAllEvents()
	CPAPI.RegisterFrameForUnitEvents(self, self.Events, 'player')
	return CPAPI.BurnAfterReading;
end

---------------------------------------------------------------
-- Proxy updates
---------------------------------------------------------------
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

---------------------------------------------------------------
-- Conditionals
---------------------------------------------------------------
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
	value = tonumber(value)
	if ( attribute == self.Attributes.Travel ) then
		return self:UpdateStrafeAngleTravel(value)
	elseif ( attribute == self.Attributes.Combat ) then
		return self:UpdateStrafeAngleCombat(value)
	end
end

Movement:HookScript('OnAttributeChanged', Movement.OnAttributeChanged)

---------------------------------------------------------------
-- Overrides
---------------------------------------------------------------

function Movement:UpdateStrafeAngleJump()
	self.enableStrafeAngleJump = db('mvmtStrafeAngleJumpEnable')
	if self.strafeAngleJumpTicker then
		self.strafeAngleJumpTicker:Cancel()
		self.strafeAngleJumpTicker = nil;
	end
	if not self.enableStrafeAngleJump then return end;
	if not self.strafeAngleJumpStart then
		function self.strafeAngleJumpStop()
			if IsFalling('player') then return end;
			self.strafeAngleJumpTicker:Cancel()
			self.strafeAngleJumpTicker = nil;
			self:UpdateStrafeAngleTravel(tonumber(self:GetAttribute(self.Attributes.Travel)))
			self:UpdateStrafeAngleCombat(tonumber(self:GetAttribute(self.Attributes.Combat)))
		end
		function self.strafeAngleJumpStart()
			if not IsFalling('player') then return end;
			local jumpAngle = db('mvmtStrafeAngleJump')
			self:UpdateStrafeAngleTravel(jumpAngle)
			self:UpdateStrafeAngleCombat(jumpAngle)
			self.strafeAngleJumpTicker = C_Timer.NewTicker(0.1, self.strafeAngleJumpStop)
		end
		hooksecurefunc('JumpOrAscendStart', function()
			if not self.enableStrafeAngleJump then return end;
			if self.strafeAngleJumpTicker then return end;
			RunNextFrame(self.strafeAngleJumpStart)
		end)
	end
end

db:RegisterCallback('Settings/mvmtStrafeAngleJumpEnable', Movement.UpdateStrafeAngleJump, Movement)

---------------------------------------------------------------
-- Cast events
---------------------------------------------------------------
-- Always turn with camera when casting.

local ALWAYS_TURN_CAMERA_VALUE = 2;

function Movement:UNIT_SPELLCAST_START()
	if self.fmVehicleOverride then return end;
	if (self.fmSpellOverride == nil) then
		self.fmSpellOverride = db('mvmtTurnWithCamera')
		self:UpdateTurnWithCamera(ALWAYS_TURN_CAMERA_VALUE)
	end
end

function Movement:UNIT_SPELLCAST_STOP()
	if self.fmVehicleOverride then return end;
	if (self.fmSpellOverride ~= nil) then
		self:UpdateTurnWithCamera(self.fmSpellOverride)
		self.fmSpellOverride = nil;
	end
end

function Movement:UNIT_ENTERING_VEHICLE()
	if (self.fmVehicleOverride == nil) then
		self:UNIT_SPELLCAST_STOP()
		self.fmVehicleOverride = db('mvmtTurnWithCamera')
		self:UpdateTurnWithCamera(ALWAYS_TURN_CAMERA_VALUE)
	end
end

function Movement:UNIT_EXITING_VEHICLE()
	if (self.fmVehicleOverride ~= nil) then
		self:UpdateTurnWithCamera(self.fmVehicleOverride)
		self.fmVehicleOverride = nil;
	end
end

Movement.UNIT_SPELLCAST_CHANNEL_START = Movement.UNIT_SPELLCAST_START;
Movement.UNIT_SPELLCAST_CHANNEL_STOP  = Movement.UNIT_SPELLCAST_STOP;
Movement.UNIT_SPELLCAST_EMPOWER_START = Movement.UNIT_SPELLCAST_START;
Movement.UNIT_SPELLCAST_EMPOWER_STOP  = Movement.UNIT_SPELLCAST_STOP;