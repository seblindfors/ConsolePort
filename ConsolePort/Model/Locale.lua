local _, db = ...;
local Locale = db:Register('Locale', setmetatable({}, {
	__index = function(self, k)
		return k;
	end;
	__call = function(self, str, ...)
		if (str == nil) then return end;
		return (self[str]:format(...):gsub('L%b[]', function(str)
			return self[str:sub(3, -2)]
		end))
	end;
}))

function Locale:GetLocale(locale)
	if (GetLocale() == locale) then
		return self;
	end
end