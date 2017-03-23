local _, UI = ...
UI.Data = ConsolePort:GetData()
UI.Utils = {}

function UI.Utils.MixinNormal(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...)
		for k, v in pairs(mixin) do
			object[k] = v
		end
	end

	return object
end

function UI.Utils.Mixin(t, ...)
	t = UI.Utils.MixinNormal(t, ...)
	if t.HasScript then
		for k, v in pairs(t) do
			if t:HasScript(k) then
				if t:GetScript(k) then
					t:HookScript(k, v)
				else
					t:SetScript(k, v)
				end
			end
		end
	end
end

function UI.Utils.Copy(src)
	local srcType, t = type(src)
	if srcType == "table" then
		t = {}
		for key, value in next, src, nil do
			t[UI.Utils.Copy(key)] = UI.Utils.Copy(value)
		end
		setmetatable(t, UI.Utils.Copy(getmetatable(src)))
	else
		t = src
	end
	return t
end

---------------------------------------------------------------
-- spairs: Sort by non-numeric key, handy for string keys
---------------------------------------------------------------
function UI.Utils.spairs(t, order)
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end