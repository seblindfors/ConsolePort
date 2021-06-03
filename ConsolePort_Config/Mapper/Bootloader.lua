if (select(5, GetAddOnInfo('ConsolePort_Mapper')) ~= 'DEMAND_LOADED') then
	return
end

local _, env = ...;
env.Mapper = ConsolePortConfig:CreatePanel({
	name = 'Mapper';
	scaleToParent = true;
	forbidRecursiveScale = true;
	mixin = {OnFirstShow = function(self)
		local loaded, reason = LoadAddOn('ConsolePort_Mapper') 
		if not loaded then
			return CPAPI.Log('Could not load mapper module: %s', reason)
		end
		self:OnFirstShow()
	end};
})