local _, db = ...;

---------------------------------------------------------------
-- Macro conditions
---------------------------------------------------------------
-- The input layer controller owns every modifier condition, so the
-- vocabulary has to be understood in core rather than in whichever
-- addon happens to need it. A driver is a list of segments split on
-- ';'; each segment is zero or more bracketed clauses in OR, each
-- clause a comma separated list of terms in AND, followed by the
-- response. A segment with no clauses is the unconditional fallback.
---------------------------------------------------------------
do  local ModReplacements = { M0 = ''; M1 = 'SHIFT-'; M2 = 'CTRL-'; M3 = 'ALT-' };

	-- @param driver : driver string, possibly using M0-M3 shorthand
	-- @return driver : with the shorthand expanded and spaces stripped
	function CPAPI.ConvertDriver(driver) driver = driver or '';
		for key, rep in pairs(ModReplacements) do
			driver = driver:gsub(key, rep)
		end
		driver = driver:gsub('%b[]', function(capture)
			return capture:gsub('%s', '')
		end)
		return (driver:gsub('%[mod:%]', '[nomod]'))
	end
end

-- @param driver : expanded driver string
-- @return list  : { { response = string; clauses = { string, ... } }, ... }
function CPAPI.ParseDriver(driver)
	local result = {};
	for segment in (driver or ''):gmatch('[^;]+') do
		local clauses, rest = {}, (segment:gsub('^%s+', ''));
		while true do
			local clause, tail = rest:match('^(%b[])(.*)$')
			if not clause then break end
			clauses[#clauses + 1] = clause:sub(2, -2);
			rest = tail:gsub('^%s+', '');
		end
		result[#result + 1] = { response = rest:trim(); clauses = clauses };
	end
	return result;
end

-- Iterate a driver in order as (response, condition), where condition
-- is the text between the outermost brackets -- 'a][b' for '[a][b]',
-- so it round trips -- and nil for the unconditional fallback.
function CPAPI.MapDriver(driver)
	local segments, i = CPAPI.ParseDriver(driver), 0;
	return function()
		i = i + 1;
		local segment = segments[i];
		if not segment then return end;
		if ( #segment.clauses == 0 ) then
			return segment.response;
		end
		return segment.response, table.concat(segment.clauses, '][');
	end
end

-- A term the controller answers for, rather than the engine.
function CPAPI.IsLayerTerm(term)
	return term == 'nomod' or not not (term:find('^mod:') or term:find('^nomod:'))
end

-- A clause belongs to the controller only if every term in it does,
-- so a clause mixing a layer term with a native one stays native and
-- is never weakened by having terms removed from it.
function CPAPI.IsLayerClause(clause)
	if ( clause == '' ) then return false end;
	for term in clause:gmatch('[^,]+') do
		if not CPAPI.IsLayerTerm(term) then return false end;
	end
	return true;
end

-- @param driver  : expanded driver string
-- @return native : true if any clause is the engine's to evaluate
-- @return layer  : true if any clause is the controller's
function CPAPI.ClassifyDriver(driver)
	local native, layer = false, false;
	for _, segment in ipairs(CPAPI.ParseDriver(driver)) do
		for _, clause in ipairs(segment.clauses) do
			if CPAPI.IsLayerClause(clause) then
				layer = true;
			else
				native = true;
			end
		end
	end
	return native, layer;
end

-- The engine's own semantic: a condition matches when it appears in
-- the active prefix, which is why the convention is most specific
-- first, first match wins.
function CPAPI.IsModSubset(A, B)
	-- The inner gsub is parenthesised to drop its replacement count,
	-- which would otherwise arrive as find's start offset and skip a
	-- match at the very beginning -- 'CTRL-SHIFT-' in itself.
	return not not (B:find((A:gsub('%-', '%%-'))))
end

function CPAPI.ModComplement(A, B)
	return A:gsub((B:gsub('%-', '%%-')), '')
end
