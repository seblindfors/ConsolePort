local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
-- Upgrade script - TODO: Remove this in a future update
---------------------------------------------------------------

env:AddLoader(function()
	for oldVariable, newVariable in pairs({
		-------------------------------------------------------
		autoExtra          = 'ringAutoExtra';
		radialStickySelect = 'ringStickySelect';
		radialRemoveButton = 'ringRemoveButton';
		-------------------------------------------------------
	}) do local oldValue = db(oldVariable);
		if ( oldValue ~= nil ) then
			db('Settings/'..oldVariable, nil);
			db('Settings/'..newVariable, oldValue);
		end
	end

	if ConsolePortUtility and not ConsolePortUtilityDeprecated then
		ConsolePortRings = CopyTable(ConsolePortUtility);
		ConsolePortUtilityDeprecated = true;
	end
end)