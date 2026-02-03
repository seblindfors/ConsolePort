local INNER_LOCALE_CAPTURE = 'L%b[]';
local InnerLocaleLookup;

local Locale = select(2, ...):Register('Locale', setmetatable({}, {
	__index = function(_, k)
		return k;
	end;
	__call = function(self, str, ...)
		return str and self[str]:format(...):gsub(INNER_LOCALE_CAPTURE, InnerLocaleLookup) or str;
	end;
}))

function Locale:GetLocale(locale)
	if (GetLocale() == locale) then
		return self;
	end
end

InnerLocaleLookup = GenerateClosure(function(self, str)
	return self(str:sub(3, -2))
end, Locale)