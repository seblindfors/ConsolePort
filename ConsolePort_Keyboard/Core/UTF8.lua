local utf8, _, env = {len = strlenutf8}, ...; env.utf8 = utf8;

function utf8.size(char)
	return not char and 0 or 
		char > 240 and 4 or
		char > 225 and 3 or
		char > 192 and 2 or 1;
end

function utf8.sub(str, startChar, numChars)
	local startIndex = 1;
	while startChar > 1 do
		local char = string.byte(str, startIndex)
		startIndex = startIndex + utf8.size(char)
		startChar = startChar - 1;
	end
 
	local currentIndex = startIndex;
 
	while numChars > 0 and currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		currentIndex = currentIndex + utf8.size(char)
		numChars = numChars -1;
	end
	return str:sub(startIndex, currentIndex - 1)
end

function utf8.pos(text, position)
	local startIndex = 1;
	local curIndex = 0;
	while curIndex < position do
		local char = string.byte(text, startIndex)
		startIndex = startIndex + utf8.size(char)
		curIndex = curIndex + 1;
	end
	return startIndex - 1;
end

function utf8.getword(text, position)
	local altText = text:sub(1, position) .. ('\t') .. text:sub(position + 1);
	local startPos, endPos = altText:find("[%a']*\t[%a']*");
	return (altText:sub(startPos, endPos):gsub('\t', '')), startPos, endPos - 1;
end