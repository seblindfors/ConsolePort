local Dictionary, _, env = {}, ...; env.DictHandler = Dictionary;
---------------------------------------------------------------
-- Local resources
---------------------------------------------------------------
local ESCAPES = {
	"|c%x%x%x%x%x%x%x%x",
	"[0-9]+",
	"\124T.-\124t",
	"|T.-|t",
	"|H.-|h",
	"|n",
	"|r",
	"/[%w]+",
	"{Atlas|.-}",
}

local function Unescape(str)
	if str then
		for _, esc in pairs(ESCAPES) do
			str = str:gsub(esc, ' ')
		end
		return str;
	end
end

---------------------------------------------------------------
-- Dictionary operations
---------------------------------------------------------------
function Dictionary:Generate()
	-- generates a localized game-oriented dictionary (5000+ words on enUS clients)
	-- scan the global environment for strings
	local genv = getfenv(0)
	local dictionary, pattern = {}, env.DictMatchPattern;
	for index, object in pairs(genv) do
		if type(object) == 'string' then
			-- remove escape sequences
			object = Unescape(object)
			-- scan each string for individual words
			for word in object:gmatch(pattern) do
				word = word:lower()
				dictionary[word] = (dictionary[word] or 0) + 1;
			end
		end
	end
	return self:Normalize(dictionary);
end

function Dictionary:GenerateTree(dictionary)
	local tree = {};
	for word, weight in pairs(dictionary) do
		local pointer = tree;
		for c in word:gmatch('.') do
			if not pointer[c] then pointer[c] = {}; end
			pointer = pointer[c];
		end
		pointer[1] = word;
	end
	return tree;
end

function Dictionary:Update(dictionary, src)
	-- store new words from the current input and update frequency of others
	for word in src:gmatch(env.DictMatchPattern) do
		word = word:lower()
		dictionary[word] = (dictionary[word] or 0) + 1;
	end
	return dictionary;
end

function Dictionary:Normalize(dictionary)
	local weight, ceiling, weights = 0, 0, {};

	-- find the highest frequency
	for word, freq in pairs(dictionary) do
		if freq > ceiling then
			ceiling = freq;
		end
	end

	-- generate empty weight tables (expensive when dictionary has never been normalized)
	for i=1, ceiling do
		weights[i] = {};
	end

	-- store words in their respective weight table
	for word, freq in pairs(dictionary) do
		tinsert(weights[freq], word)
	end

	-- wipe the old dictionary
	wipe(dictionary)

	-- generate a normalized dictionary by incrementally counting weight classes
	for _, words in ipairs(weights) do
		if next(words) then
			weight = weight + 1;
			for _, word in pairs(words) do
				dictionary[word] = weight;
			end
		end
	end

	return dictionary;
end