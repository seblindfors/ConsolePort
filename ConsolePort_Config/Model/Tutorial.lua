local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------

function env.TutorialPredicate(tutorialID)
    return function() return not CPAPI.IsTutorialComplete(tutorialID) end;
end

function env.HasActiveDevice()
    return function() return not not env:GetActiveDeviceAndMap() end;
end