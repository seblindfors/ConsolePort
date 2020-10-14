local _, db = ...;
local Locale = db:Register('Locale', setmetatable({}, {
	__index = function(self, k)
		return k;
	end;
	__call = function(self, str, ...)
		return self[str]:format(...)
	end;
}))

function Locale:GetLocale(locale)
	if (GetLocale() == locale) then
		return self;
	end
end