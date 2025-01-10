local _, db = ...;
---------------------------------------------------------------
-- Mixins
---------------------------------------------------------------
-- Event handler mixin
CPAPI.EventMixin = {
	OnEvent = function(self, event, ...)
		if self[event] then
			self[event](self, ...)
		end
	end;
	ADDON_LOADED = function(self, ...)
		if self.UnregisterEvent then
			self:UnregisterEvent('ADDON_LOADED')
		end
		if self.OnDataLoaded then
			self:OnDataLoaded(...)
		end
	end;
}

CPAPI.SecureExportMixin = {
	Export = function(self, body, ...)
		assert(not InCombatLockdown())
		local signature, args = '', {...};
		for i, arg in ipairs(args) do
			local isN = tonumber(arg) or (arg == true or arg == false)
			signature = signature .. (isN and arg or ('"%s"'):format(tostring(arg)));
			if i < #args then
				signature = signature .. ',';
			end
		end
		self:Execute(([[
			local returns = newtable(self:RunAttribute("%s", %s))
			for i, v in ipairs(returns) do
				self:SetAttribute(tostring(i), v)
			end
			self:SetAttribute('n', #returns)
		]]):format(body, signature))
		local values = {}
		for i=1, self:GetAttribute('n') do
			values[i] = self:GetAttribute(tostring(i))
			self:SetAttribute(tostring(i), nil)
		end
		self:SetAttribute('n', nil)
		return unpack(values)
	end;
}

CPAPI.SecureEnvironmentMixin = {
	CreateEnvironment = function(self, newEnv, skipUpvalues)
		if newEnv then
			self.Env = CreateFromMixins(self.Env or {}, newEnv)
		end
		local useUpvalues = not skipUpvalues and self.Execute;
		for func, body in pairs(self.Env) do
			body = CPAPI.ConvertSecureBody(body);
			self:SetAttribute(func, body)
			if useUpvalues then
				self:Execute(('%s = self:GetAttribute("%s")'):format(func, func))
			end
		end
	end;
	Run = function(self, body, ...)
		return self:Execute(CPAPI.ConvertSecureBody(body:format(...)))
	end;
	Wrap = function(self, scriptHandler, body)
		return self:WrapScript(self, scriptHandler, CPAPI.ConvertSecureBody(body))
	end;
	Hook = function(self, target, scriptHandler, body)
		return self:WrapScript(target, scriptHandler, CPAPI.ConvertSecureBody(body))
	end;
}

CPAPI.AdvancedSecureMixin = CreateFromMixins(CPAPI.SecureExportMixin, CPAPI.SecureEnvironmentMixin, {
	Parse = function(self, body, args)
		local backup = {};
		for key, value in pairs(args) do
			backup[key] = self:GetAttribute(key)
			self:SetAttribute(tostring(key), value)
			body = body:gsub(
				('{%s}'):format(key),
				([[self:GetAttribute('%s')]]):format(key)
			);
		end
		self:Execute(body)
		for key in pairs(args) do
			self:SetAttribute(key, backup[key])
		end
		return body;
	end;
})

---------------------------------------------------------------
-- Tools
---------------------------------------------------------------
function CPAPI.DisableFrame(frame, ignoreAlpha)
	frame:SetSize(1, 1)
	frame:EnableMouse(false)
	frame:EnableKeyboard(false)
	frame:SetAlpha(ignoreAlpha and frame:GetAlpha() or 0)
	frame:ClearAllPoints()
	CPAPI.Purge(frame, 'isShownExternal')
	ConsolePort:ForbidInterfaceCursorFrame(frame)
end

function CPAPI.LockPoints(frame)
	frame.SetPoint,
	frame.SetAllPoints,
	frame.ClearAllPoints,
	frame.SetParent
	= nop, nop, nop, nop;
end

function CPAPI.CreateDataHandler(...)
	local handler = CreateFromMixins(...)
	return CPAPI.DataHandler(handler)
end

function CPAPI.DataHandler(handler)
	db:RegisterCallback('OnDataLoaded', CPAPI.EventMixin.ADDON_LOADED, handler)
	return handler;
end

function CPAPI.Start(handler)
	for k, v in pairs(handler) do
		if handler:HasScript(k) then
			local currentScript = handler:GetScript(k)
			if ( currentScript and currentScript ~= v ) then
				handler:HookScript(k, v)
			else
				handler:SetScript(k, v)
			end
		end
	end
end

function CPAPI.Popup(id, settings, ...)
	if (settings and settings.whileDead == nil) then
		settings.whileDead = true; -- popup enabled while dead by default
	end
	StaticPopupDialogs[id:upper()] = settings;
	local dialog = StaticPopup_Show(id:upper(), ...)
	if dialog then
		local icon = _G[dialog:GetName() .. 'AlertIcon']
		local original = icon:GetTexture()
		local onHide = settings.OnHide;
		icon:SetTexture(CPAPI.GetAsset('Textures\\Logo\\CP'))
		settings.OnHide = function(...)
			icon:SetTexture(original)
			if onHide then
				return onHide(...)
			end
		end;
		return dialog;
	end
end

do local function ModifyMetatable(owner, key, value)
		local mt = getmetatable(owner) or {};
		mt[key] = value;
		return setmetatable(owner, mt)
	end

	local function Enumerator(self, asTable)
		if asTable then
			return tInvert(self);
		end
		return unpack(tInvert(self))
	end

	function CPAPI.Proxy(owner, proxy)
		if (type(proxy) ~= 'table' and type(proxy) ~= 'function') then
			proxy = function() return proxy end;
		end
		return ModifyMetatable(owner, '__index', proxy)
	end

	function CPAPI.Inject(owner, inject)
		return ModifyMetatable(owner, '__newindex', inject)
	end

	function CPAPI.Callable(owner, func)
		return ModifyMetatable(owner, '__call', func)
	end

	function CPAPI.Enum(...)
		return CPAPI.Callable(EnumUtil.MakeEnum(...), Enumerator)
	end
end

function CPAPI.Purge(t, k)
	t[k] = nil;
	local c = 42;
	repeat -- credit: foxlit
		if t[c] == nil then t[c] = nil end;
		c = c + 1;
	until issecurevariable(t, k)
end

do local sort, head = 0;
	function CPAPI.Define(value, startIndex)
		if ( type(value) == 'string' ) then
			head, sort = value, startIndex or 0;
		else
			assert(type(value) == 'table', 'Invalid value type.')
			sort = sort + 1;
			value.sort = sort;
			value.head = head;
			return value;
		end
	end

	function CPAPI.GetEnv(name, env)
		assert(env.db, 'Environment not linked.')
		return env, env.db, name;
	end

	function CPAPI.LinkEnv(name, env)
		env.db = db;
		return CPAPI.Define, db.Data, CPAPI.GetEnv(name, env);
	end
end

function CPAPI.OnAddonLoaded(addOn, script)
	EventUtil.ContinueOnAddOnLoaded(addOn, GenerateClosure(pcall, script))
end

---------------------------------------------------------------
-- Debounce
---------------------------------------------------------------
do local __tCount, __tID, __tTime = 0, 'task', '__time_';
	local function Execute(self, task, callback)
		if not self[task] then
			self[task] = true;
			RunNextFrame(callback)
		end
	end
	local function Handler(self, task, timer, callback, args)
		self[task] = nil;
		local updateTime = GetTime()
		if self[timer] and self[timer] >= updateTime then
			return; -- task was already executed this frame
		end
		self[timer] = updateTime;
		callback(self, unpack(args))
	end
	local function Cancel(self, _, timer, timeout)
		self[timer] = GetTime() + (timeout or 1);
	end

	function CPAPI.Debounce(callback, owner, ...) __tCount = __tCount + 1;
		local task    = __tID .. __tCount;
		local timer   = task  .. __tTime;
		local handler = GenerateClosure(Handler, owner, task, timer, callback, {...})
		local execute = GenerateClosure(Execute, owner, task, handler)
		local cancel  = GenerateClosure(Cancel,  owner, task, timer)
		return setmetatable({
			Execute = execute;
			Cancel  = cancel;
		}, {__call = execute})
	end
end

---------------------------------------------------------------
-- Event handlers
---------------------------------------------------------------
function CPAPI.CreateEventHandler(args, events, ...)
	local handler = db.table.mixin(CreateFrame(unpack(args)), ...)
	return CPAPI.EventHandler(handler, events)
end

function CPAPI.EventHandler(handler, events)
	db.table.mixin(handler, CPAPI.EventMixin)
	if events then
		for _, event in pairs(events) do
			if CPAPI.IsEventValid(event) then
				handler:RegisterEvent(event)
			end
		end
		handler.Events = events;
	end
	handler:RegisterEvent('ADDON_LOADED')
	return handler;
end

CPAPI.IsEventValid = C_EventUtils and (function(event)
	return type(event) == 'string' and C_EventUtils.IsEventValid(event)
end) or (function()
	local tester = CreateFrame('Frame')
	return function(event)
		local isEventValid = pcall(tester.RegisterEvent, tester, event)
		tester:UnregisterAllEvents()
		return isEventValid;
	end
end)()

 function CPAPI.RegisterFrameForEvents(frame, events)
	for _, event in pairs(events) do
		if CPAPI.IsEventValid(event) then
			frame:RegisterEvent(event)
		end
	end
	return frame;
end

function CPAPI.RegisterFrameForUnitEvents(frame, events, ...)
	for _, event in pairs(events) do
		if CPAPI.IsEventValid(event) then
			frame:RegisterUnitEvent(event, ...)
		end
	end
	return frame;
end

---------------------------------------------------------------
-- Secure environment translation
---------------------------------------------------------------
do	local ConvertSecureBody, GetSecureBodySignature, GetNewtableSignature;
	function GetSecureBodySignature(obj, func, args)
		return ConvertSecureBody(
			('%s:RunAttribute(\'%s\'%s%s)'):format(
				obj, func, args:trim():len() > 0 and ', ' or '', args));
	end

	function GetNewtableSignature(contents)
		return ('newtable(%s)'):format(contents:sub(2, -2))
	end

	function ConvertSecureBody(body)
		return (body
			:gsub('(%w+)::(%w+)%((.-)%)', GetSecureBodySignature)
			:gsub('%b{}', GetNewtableSignature)
		);
	end

	CPAPI.ConvertSecureBody = ConvertSecureBody;
	CPAPI.FormatSecureBody  = function(args, body)
		for key, value in pairs(args) do
			body = body:gsub(
				('{%s}'):format(key),
				(type(value) == 'string' and ('%q'):format(value) or tostring(value))
			);
		end
		return ConvertSecureBody(body);
	end
end

---------------------------------------------------------------
-- Text
---------------------------------------------------------------
function CPAPI.FormatLongText(text, linelength) text = text
	:gsub('\t+', '')    -- (1) replace tabs
	:gsub('\n\n', '\t') -- (2) replace double newline with tabs
	:gsub('\n', ' ')    -- (3) replace newline with space
	:gsub('\t', '\n\n') -- (4) replace tab with double newline

    return linelength and CPAPI.FormatLineLength(text, linelength) or text;
end

function CPAPI.FormatLineLength(text, linelength)
	local function split(line)
		local lines, currentLine = {}, '';
		for word in line:gmatch('%S+') do
			if #currentLine + #word > linelength then
				tinsert(lines, currentLine)
				currentLine = word;
			else
				currentLine = #currentLine ~= 0 and (currentLine .. ' ' .. word) or word;
			end
		end
		tinsert(lines, currentLine)
		return table.concat(lines, '\n')
	end

	local lines = {('\n\n'):split(text)}
	for i, line in ipairs(lines) do
		if ( #line == 0 ) then
			if i > 1 and #lines[i - 1] ~= 0 then
				lines[i] = '\n\n';
			end
		else
			lines[i] = split(line)
		end
	end
	return table.concat(lines, '')
end