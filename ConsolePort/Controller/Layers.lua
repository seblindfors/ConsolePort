---------------------------------------------------------------
-- Input layers
---------------------------------------------------------------
-- Owns the modifier state the rest of the suite binds against.
-- Publishes two values: 'prefix' is the resolved layer, 'chord' the
-- canonical combination the engine looks up. Registrants pick their
-- action by the prefix and key their binding by the chord.
---------------------------------------------------------------

local Layers, _, db = CPAPI.DataHandler(ConsolePortLayers), ...;
local L = db.Locale;
local RegisterAttributeDriver, UnregisterAttributeDriver = RegisterAttributeDriver, UnregisterAttributeDriver;
local RegisterStateDriver, UnregisterStateDriver = RegisterStateDriver, UnregisterStateDriver;
local STORED_BATCH_SIZE = 25;
Mixin(Layers, CPAPI.SecureEnvironmentMixin)
db:Register('Layers', Layers)

Layers.Proxies     = {};
Layers.States      = {};
Layers.StateInfo   = {};
Layers.StateFrames = {};
Layers.StateCount  = 0;
Layers.driverCount = 0;

---------------------------------------------------------------
Layers.Env = {
---------------------------------------------------------------
	UpdatePrefix = [[
		if not ENABLED then return end;
		local chord = '';
		for i = 1, #MODS do
			local mod = MODS[i];
			if HELDSET[mod] then
				chord = chord..mod;
			end
		end

		local prefix = chord;
		if ( #HELD > 0 ) then
			if ORDERED then
				prefix = '';
				for i = 1, #HELD do
					prefix = prefix..HELD[i];
				end
			end
		elseif DOUBLED then
			prefix = DOUBLED..DOUBLED;
		elseif ORDERED then
			prefix = '';
			for i = 1, #LATCH do
				prefix = prefix..LATCH[i];
			end
		else
			-- Canonical order unless ordering is enabled.
			prefix = '';
			for i = 1, #MODS do
				local mod = MODS[i];
				for j = 1, #LATCH do
					if ( LATCH[j] == mod ) then
						prefix = prefix..mod;
						break;
					end
				end
			end
		end
		if ( prefix == PREFIX and chord == CHORD ) then return end;
		PREFIX, CHORD = prefix, chord;
		self::ApplyRow(chord, prefix)
		self::ApplyStates()
		self:SetAttribute('chord', chord)
		self:SetAttribute('prefix', prefix)
		self:ChildUpdate('prefix', prefix)
		self:::OnLayerChanged(prefix, chord)
	]];
	-----------------------------------------------------------
	ClearRow = [[
		for i = #APPLIED, 1, -1 do
			self:ClearBinding(APPLIED[i])
			APPLIED[i] = nil;
		end
	]];
	-----------------------------------------------------------
	-- Only one row is live: the engine looks up the canonical chord of
	-- whatever is held. Written at the low priority tier, so a transient
	-- overlay wins while it is up.
	-- @param chord : key prefix the engine will look up
	-- @param layer : binding set to resolve it against
	ApplyRow = [[
		local chord, layer = ...;
		self::ClearRow()
		wipe(ROW)

		local stored = STORED[layer];
		if stored then
			for button, entry in pairs(stored) do
				ROW[button] = entry;
			end
		end

		local bound = BINDINGS[layer];
		if bound then
			for button, entry in pairs(bound) do
				ROW[button] = entry;
			end
		end

		for button, entry in pairs(ROW) do
			if not CLAIMED[button] then
				-- Stand-ins resolve to whatever the button does in this layer.
				local emulated = EMULATED[button];
				for i = 1, emulated and 2 or 1 do
					local key = chord..( ( i == 1 ) and button or emulated );
					if ( entry[1] == 'click' ) then
						self:SetBindingClick(false, key, entry[2], entry[3])
					else
						self:SetBinding(false, key, entry[2])
					end
					APPLIED[#APPLIED + 1] = key;
				end
			end
		end
	]];
	-----------------------------------------------------------
	-- @param mod : modifier prefix that changed, e.g. 'CTRL-'
	-- @param down : whether it is now held
	OnModifier = [[
		local mod, state = ...;
		local down = ( state and state ~= '0' and state ~= 0 ) and true or false;
		if ( down == ( HELDSET[mod] or false ) ) then return end;
		HELDSET[mod] = down or nil;
		if down then
			HELD[#HELD + 1] = mod;
		else
			for i = #HELD, 1, -1 do
				if ( HELD[i] == mod ) then
					tremove(HELD, i)
				end
			end
		end
		self::UpdatePrefix()
	]];
	-----------------------------------------------------------
	-- @param mod : modifier prefix that was tapped
	OnTap = [[
		local mod = ...;
		if not TAPLATCH then return end;
		if ( DOUBLED == mod ) then return end;
		if DOUBLED then
			DOUBLED = nil;
		end
		for i = #LATCH, 1, -1 do
			if ( LATCH[i] == mod ) then
				tremove(LATCH, i)
				return self::UpdatePrefix()
			end
		end
		LATCH[#LATCH + 1] = mod;
		self::UpdatePrefix()
	]];
	-----------------------------------------------------------
	-- @param mod : modifier prefix that was double tapped
	OnDoubleTap = [[
		local mod = ...;
		if not DOUBLEBAR then return end;
		if ( DOUBLED == mod ) then
			DOUBLED = nil;
		else
			DOUBLED = mod;
			wipe(LATCH)
		end
		self::UpdatePrefix()
	]];
	-----------------------------------------------------------
	-- First match wins, as the macro conditional itself does.
	-- @param index : entry in STATES, { frame, attribute, segments,
	--   last value, body attribute, visibility shorthand }
	EvaluateState = [[
		local index = ...;
		local entry = STATES[index];
		if not entry then return end;

		local value;
		local segments = entry[3];
		for i = 1, #segments do
			local segment, kind = segments[i], segments[i][1];
			if ( kind == 1 ) then
				if SecureCmdOptionParse(segment[2]) then
					value = segment[3];
					break;
				end
			elseif ( kind == 2 ) then
				if segment[2][PREFIX] then
					value = segment[3];
					break;
				end
			else
				value = segment[3];
				break;
			end
		end

		-- An unprotected frame is written outside the environment.
		if entry[7] then
			if ( value ~= entry[4] ) then
				entry[4] = value;
				self:CallMethod('ApplyInsecureState', index, value)
			end
			return;
		end

		-- 'state-visibility' shows or hides and writes no attribute, per the
		-- engine's own resolver. Reasserted every pass rather than guarded.
		if entry[6] then
			if ( value == 'show' ) then
				entry[1]:Show()
				entry[1]:SetAttribute('statehidden', nil)
			elseif ( value == 'hide' ) then
				entry[1]:Hide()
				entry[1]:SetAttribute('statehidden', true)
			end
			return;
		end

		if ( value == 'nil' ) then
			value = nil;
		elseif value then
			value = tonumber(value) or value;
		end

		if ( value ~= entry[4] ) then
			entry[4] = value;
			entry[1]:SetAttribute(entry[2], value)
			if entry[5] then
				entry[1]:RunAttribute(entry[5])
			end
		end
	]];
	-----------------------------------------------------------
	ApplyStates = [[
		for index in pairs(STATES) do
			self::EvaluateState(index)
		end
	]];
	-----------------------------------------------------------
	ClearRegistered = [[
		wipe(BINDINGS)
	]];
	-----------------------------------------------------------
	-- @param layer  : layer prefix the entry belongs to
	-- @param button : button the entry answers for
	-- @param name   : frame name to click
	-- @param click  : mouse button to click with
	SetRegistered = [[
		local layer, button, name, click = ...;
		local set = BINDINGS[layer];
		if not set then set = newtable() BINDINGS[layer] = set end;
		set[button] = newtable('click', name, click or 'LeftButton');
	]];
	-----------------------------------------------------------
	-- The binding table changed, not the layer.
	ReapplyRow = [[
		if not ENABLED then return end;
		self::ApplyRow(CHORD or '', PREFIX or '')
	]];
	-----------------------------------------------------------
	ApplyRegistered = [[
		self::ReapplyRow()
	]];
	-----------------------------------------------------------
	ClearState = [[
		wipe(HELD) wipe(HELDSET) wipe(LATCH)
		DOUBLED = nil;
		self::UpdatePrefix()
	]];
};

---------------------------------------------------------------
-- Secure setup
---------------------------------------------------------------
-- At file scope: a registrant in a later file may arrive first.
function Layers:OnEnvironmentChanged()
	self:Execute([[
		HELD     = HELD     or newtable();
		HELDSET  = HELDSET  or newtable();
		LATCH    = LATCH    or newtable();
		MODS     = MODS     or newtable();
		APPLIED  = APPLIED  or newtable();
		BINDINGS = BINDINGS or newtable();
		STORED   = STORED   or newtable();
		CLAIMED  = CLAIMED  or newtable();
		EMULATED = EMULATED or newtable();
		STATES   = STATES   or newtable();
		ROW      = ROW      or newtable();
	]])
	self:CreateEnvironment()
end

Layers:OnEnvironmentChanged()

function Layers:SetFeatures(tapLatch, doubleBar, ordered)
	self:Execute(([[
		TAPLATCH  = %s;
		DOUBLEBAR = %s;
		ORDERED   = %s;
	]]):format(tostring(not not tapLatch), tostring(not not doubleBar), tostring(not not ordered)))
end

---------------------------------------------------------------
-- Leaves the restricted environment to announce the layer.
-- @param prefix : layer now resolved
-- @param chord  : canonical chord of the modifiers held
function Layers:OnLayerChanged(prefix, chord)
	db:TriggerEvent('OnLayerChanged', prefix, chord)
end

---------------------------------------------------------------
-- @return prefix : layer currently resolved, '' when none
function Layers:GetActiveLayer()
	return self:GetAttribute('prefix') or '';
end

-- @return chord : canonical chord of the modifiers physically held
function Layers:GetActiveChord()
	return self:GetAttribute('chord') or '';
end

function Layers:UsesTapGestures()
	return not not ( db('layersTapLatch') or db('layersDoubleBar') );
end

-- What a gesture has taken a chord for, so a claim can be reported
-- rather than the stored binding it shadows.
-- @param combination : full key combination, e.g. 'CTRL-PADLSHOULDER'
-- @return claim : name of the gesture holding it, or nil
function Layers:GetChordClaim(combination)
	if not self:UsesTapGestures() then return end;
	local prefix, button = combination:match('^(.-)([^%-]+)$');
	local modifier = button and db.Gamepad.Index.Modifier.Owner[button];
	if ( not modifier or prefix:find(modifier, 1, true) ) then return end;

	local latch, doubled = db('layersTapLatch'), db('layersDoubleBar');
	if ( latch and doubled ) then
		return L'Tap to Latch and Doubled Bar';
	end
	return latch and L'Tap to Latch' or L'Doubled Bar';
end

-- @param sequence : modifier prefixes in press order
-- @return layer   : composed prefix, or nil if it forms none
-- @return reason  : why it forms none
function Layers:ComposeLayer(sequence)
	if ( not sequence or #sequence == 0 ) then return '' end;

	local seen, repeated = {}, nil;
	for i = 1, #sequence do
		local mod = sequence[i];
		if seen[mod] then
			repeated = mod;
		end
		seen[mod] = true;
	end

	local layer;
	if repeated then
		if not db('layersDoubleBar') then
			return nil, 'doubled';
		elseif ( #sequence ~= 2 ) then
			return nil, 'exclusive';
		end
		layer = repeated..repeated;
	elseif db('layersOrdered') then
		layer = table.concat(sequence);
	else
		layer = '';
		for prefix in db.table.spairs(db.Gamepad.Index.Modifier.Prefix) do
			if seen[prefix] then
				layer = layer..prefix;
			end
		end
	end
	if not db.Gamepad.Index.Modifier.Active[layer] then
		return nil, 'unknown';
	end
	return layer;
end

---------------------------------------------------------------
-- @param button   : gamepad button absent from the loadout
-- @param emulated : key standing in for it, or nil to stop
function Layers:SetEmulation(button, emulated)
	self:Execute(CPAPI.FormatSecureBody({ button = button; emulated = emulated or false }, [[
		EMULATED[{button}] = {emulated} or nil;
	]])..CPAPI.ConvertSecureBody('self::ReapplyRow()'))
end

---------------------------------------------------------------
-- The player's own bindings, mirrored so the controller can answer
-- for every key it owns. BINDINGS takes precedence over STORED.
-- Rewires the modifiers, the earliest point the device is indexed.
-- @param bindings : bindings[button][prefix] = bindingID
function Layers:OnNewBindings(bindings)
	local blocked, batch = db.Gamepad.Index.Modifier.Blocked, {};
	self:Execute([[ wipe(STORED) ]])
	for button, set in pairs(bindings or db.Gamepad:GetBindings()) do
		for prefix, binding in pairs(set) do
			if ( binding and binding ~= '' and not blocked[prefix..button] ) then
				batch[#batch + 1] = CPAPI.FormatSecureBody({
					layer = prefix; button = button; binding = binding;
				}, [[
					local set = STORED[{layer}];
					if not set then set = newtable() STORED[{layer}] = set end;
					set[{button}] = newtable('bind', {binding});
				]]);
			end
			if ( #batch == STORED_BATCH_SIZE ) then
				self:Execute(table.concat(batch))
				wipe(batch)
			end
		end
	end
	if ( #batch > 0 ) then
		self:Execute(table.concat(batch))
	end
	self:OnSettingsChanged()
end

function Layers:Refresh()
	self:Execute(CPAPI.ConvertSecureBody([[
		PREFIX, CHORD = nil, nil;
		for index, entry in pairs(STATES) do
			entry[4] = nil;
		end
		self::UpdatePrefix()
	]]))
end

---------------------------------------------------------------
-- State registrants
---------------------------------------------------------------
-- A driver containing any modifier condition belongs to the
-- controller; the engine cannot see a latched or doubled layer.
---------------------------------------------------------------

-- @return layers : every prefix the controller can resolve to
function Layers:EnumerateLayers()
	local layers = {};
	for prefix in pairs(db.Gamepad.Index.Modifier.Active) do
		layers[#layers + 1] = prefix;
	end
	return layers;
end

-- @param term  : single macro condition term
-- @param layer : layer prefix to resolve it against
function Layers:MatchTerm(term, layer)
	if ( term == 'nomod' ) then
		return layer == '';
	end
	local subset = term:match('^mod:(.+)$');
	if subset then
		return CPAPI.IsModSubset(subset, layer);
	end
	local complement = term:match('^nomod:(.+)$');
	if complement then
		return not CPAPI.IsModSubset(complement, layer);
	end
	return false;
end

function Layers:MatchClause(clause, layer)
	for term in clause:gmatch('[^,]+') do
		if not self:MatchTerm(term, layer) then
			return false;
		end
	end
	return true;
end

-- @param index : entry in STATES
-- @param value : resolved driver value, as the snippet saw it
function Layers:ApplyInsecureState(index, value)
	local info = self.StateFrames[index];
	if not info then return end;
	local frame = info.frame;
	if info.visibility then
		if ( value == 'show' ) then
			frame:Show()
			frame:SetAttribute('statehidden', nil)
		elseif ( value == 'hide' ) then
			frame:Hide()
			frame:SetAttribute('statehidden', true)
		end
		return;
	end
	if ( value == 'nil' ) then
		value = nil;
	elseif value then
		value = tonumber(value) or value;
	end
	frame:SetAttribute(info.attribute, value)
end

-- Stands in for the engine's registration where it cannot see the
-- whole driver.
-- @param frame      : registrant
-- @param attribute  : attribute to write, e.g. 'modifier'
-- @param driver     : expanded driver string
-- @param body       : snippet to run, reading the value as newstate
-- @param visibility : whether the show/hide shorthand applies
function Layers:RegisterState(frame, attribute, driver, body, visibility)
	if InCombatLockdown() then return end;
	local key   = tostring(frame)..attribute;
	local index = self.States[key] or ( self.StateCount + 1 );
	local bodyKey, refKey = 'layerbody-'..attribute, ('state%d'):format(index);

	-- The restricted environment refuses a handle to an unprotected
	-- frame in combat, so such a frame is written to from insecure Lua
	-- instead, the way the engine's own driver writes to it.
	local insecure = not frame:IsProtected();
	if body then
		assert(not insecure, 'A layer body needs a protected frame.')
		frame:SetAttribute(bodyKey, ('local newstate = self:GetAttribute(%q); %s'):format(attribute, body))
	end
	if not insecure then
		self:SetFrameRef(refKey, frame)
	end
	self.StateFrames[index] = { frame = frame; attribute = attribute; visibility = visibility };
	self:Execute(CPAPI.FormatSecureBody({
		ref = refKey; attribute = attribute; body = body and bodyKey or ''; index = index;
		visibility = not not visibility; insecure = insecure;
	}, [[
		local entry = newtable();
		entry[1] = not {insecure} and self:GetFrameRef({ref}) or false;
		entry[2] = {attribute};
		entry[3] = newtable();
		entry[5] = {body};
		if ( entry[5] == '' ) then entry[5] = nil end;
		entry[6] = {visibility};
		entry[7] = {insecure};
		STATES[{index}] = entry;
	]]))

	local layers, residual, position = self:EnumerateLayers(), {}, 0;

	local function AddNative(clauses, response)
		position = position + 1;
		local joined = table.concat(clauses, '][');
		residual[#residual + 1] = ('[%s] %d'):format(joined, position);
		self:Execute(CPAPI.FormatSecureBody({
			index = index; position = position; response = response;
			condition = ('[%s] 1'):format(joined);
		}, [[
			STATES[{index}][3][{position}] = newtable(1, {condition}, {response});
		]]))
	end

	local function AddLayer(clauses, response)
		position = position + 1;
		local matches = {};
		for _, layer in ipairs(layers) do
			for _, clause in ipairs(clauses) do
				if self:MatchClause(clause, layer) then
					matches[#matches + 1] = ('matched[%q] = true;'):format(layer);
					break;
				end
			end
		end
		self:Execute(CPAPI.FormatSecureBody({ index = index; position = position; response = response }, [[
			local matched = newtable();
			]]..table.concat(matches, '\n\t\t\t')..[[

			STATES[{index}][3][{position}] = newtable(2, matched, {response});
		]]))
	end

	-- Clauses are an OR, so splitting a segment by evaluator is lossless.
	for _, segment in ipairs(CPAPI.ParseDriver(driver)) do
		if ( #segment.clauses == 0 ) then
			position = position + 1;
			self:Execute(CPAPI.FormatSecureBody({ index = index; position = position; response = segment.response }, [[
				STATES[{index}][3][{position}] = newtable(3, false, {response});
			]]))
		else
			local native, layer = {}, {};
			for _, clause in ipairs(segment.clauses) do
				local list = CPAPI.IsLayerClause(clause) and layer or native;
				list[#list + 1] = clause;
			end
			if ( #native > 0 ) then AddNative(native, segment.response) end;
			if ( #layer  > 0 ) then AddLayer(layer, segment.response) end;
		end
	end

	-- Registered to be re-evaluated, not read: its response only changes
	-- when a different native segment starts matching.
	local triggerName = ('layernative%d'):format(index);
	UnregisterStateDriver(self, triggerName)
	if ( #residual > 0 ) then
		self:SetAttribute('_onstate-'..triggerName, CPAPI.ConvertSecureBody(
			([[ self::EvaluateState(%d) ]]):format(index)))
		RegisterStateDriver(self, triggerName, table.concat(residual, '; ')..'; 0')
	end

	self.States[key]    = index;
	self.StateInfo[key] = {
		frame = frame; attribute = attribute; driver = driver; body = body; visibility = visibility;
	};
	self.StateCount     = math.max(self.StateCount, index);
	self:Execute(CPAPI.ConvertSecureBody(([[
		STATES[%d][4] = nil;
		self::EvaluateState(%d)
	]]):format(index, index)))
end

-- Reachable layers depend on which gestures are enabled.
function Layers:RefreshStates()
	if InCombatLockdown() then return end;
	for _, info in pairs(self.StateInfo) do
		self:RegisterState(info.frame, info.attribute, info.driver, info.body, info.visibility)
	end
end

-- Drop-in mirrors of the engine's own registration.
function Layers:RegisterAttributeDriver(frame, attribute, driver)
	local _, layer = CPAPI.ClassifyDriver(driver);
	if layer then
		UnregisterAttributeDriver(frame, attribute)
		return self:RegisterState(frame, attribute, driver)
	end
	self:UnregisterState(frame, attribute)
	return RegisterAttributeDriver(frame, attribute, driver)
end

-- A state driver is an attribute driver on 'state-<name>', which is
-- what makes _onstate-<name> fire.
function Layers:RegisterStateDriver(frame, attribute, driver)
	local _, layer = CPAPI.ClassifyDriver(driver);
	if layer then
		UnregisterStateDriver(frame, attribute)
		return self:RegisterState(frame, 'state-'..attribute, driver, nil, attribute == 'visibility')
	end
	self:UnregisterState(frame, 'state-'..attribute)
	return RegisterStateDriver(frame, attribute, driver)
end

function Layers:UnregisterStateDriver(frame, attribute)
	self:UnregisterState(frame, 'state-'..attribute)
	return UnregisterStateDriver(frame, attribute)
end

function Layers:UnregisterAttributeDriver(frame, attribute)
	self:UnregisterState(frame, attribute)
	return UnregisterAttributeDriver(frame, attribute)
end

function Layers:UnregisterState(frame, attribute)
	if InCombatLockdown() then return end;
	local key = tostring(frame)..attribute;
	local index = self.States[key];
	if not index then return end;
	self.States[key]    = nil;
	self.StateInfo[key] = nil;
	self.StateFrames[index] = nil;
	UnregisterStateDriver(self, ('layernative%d'):format(index))
	self:Execute(('STATES[%d] = nil'):format(index))
end

---------------------------------------------------------------
-- Modifier wiring
---------------------------------------------------------------
-- One state driver per modifier, plus a proxy per modifier while a
-- tap gesture claims its chord.
---------------------------------------------------------------
function Layers:ReleaseModifiers()
	if InCombatLockdown() then return end;
	self.modifierSignature = nil;
	for _, proxy in pairs(self.Proxies) do
		ClearOverrideBindings(proxy)
	end
	for index = 1, self.driverCount do
		UnregisterStateDriver(self, 'layermod'..index)
	end
	self.driverCount = 0;
	ClearOverrideBindings(self)
	self:Execute(CPAPI.ConvertSecureBody([[
		ENABLED = false;
		self::ClearRow()
		wipe(MODS) wipe(CLAIMED)
		PREFIX, CHORD = nil, nil;
		self:SetAttribute('chord', nil)
		self:SetAttribute('prefix', nil)
		self:ChildUpdate('prefix', nil)
	]]))
end

function Layers:AcquireProxy(prefix, index)
	local proxy = self.Proxies[prefix];
	if not proxy then
		proxy = CreateFrame('Button', ('ConsolePortLayerProxy%d'):format(index), self, 'SecureActionButtonTemplate')
		proxy:RegisterForClicks('AnyDown', 'AnyUp')
		proxy:Hide()
		SecureHandlerWrapScript(proxy, 'OnClick', self,
			CPAPI.ConvertSecureBody(([[ if down then control::OnTap(%q) end ]]):format(prefix)))
		SecureHandlerWrapScript(proxy, 'OnDoubleClick', self,
			CPAPI.ConvertSecureBody(([[ control::OnDoubleTap(%q) ]]):format(prefix)))
		self.Proxies[prefix] = proxy;
	end
	return proxy;
end

-- @return signature : what the modifier wiring depends on
function Layers:GetModifierSignature()
	local parts = {};
	for prefix, button in db.table.spairs(db.Gamepad.Index.Modifier.Prefix) do
		parts[#parts + 1] = prefix..button;
	end
	return ('%s|%s|%s|%s'):format(table.concat(parts, ','),
		tostring(db('layersTapLatch')),
		tostring(db('layersDoubleBar')),
		tostring(db('layersOrdered')));
end

function Layers:SetModifiers()
	if InCombatLockdown() then return end;
	local signature = self:GetModifierSignature();
	if ( signature == self.modifierSignature ) then return end;
	self:ReleaseModifiers()
	self.modifierSignature = signature;

	local useEscapes = self:UsesTapGestures();
	local layered    = db.Gamepad.Index.Modifier.Layered;

	local index = 0;
	for prefix, button in db.table.spairs(db.Gamepad.Index.Modifier.Prefix) do
		index = index + 1;
		self:Execute(([[ MODS[#MODS + 1] = %q ]]):format(prefix))

		if useEscapes then
			local proxy = self:AcquireProxy(prefix, index)
			for chord, inputs in pairs(db.Gamepad.Index.Modifier.Active) do
				-- Layer prefixes are never composed by the engine.
				if not ( layered[chord] or tostring(inputs):match(button) ) then
					SetOverrideBindingClick(proxy, false, chord..button, proxy:GetName())
				end
			end
			self:Execute(('CLAIMED[%q] = true'):format(button))
		end

		self:SetAttribute(('_onstate-layermod%d'):format(index), CPAPI.ConvertSecureBody(
			([[ self::OnModifier(%q, newstate) ]]):format(prefix)))
		RegisterStateDriver(self, 'layermod'..index, ('[mod:%s] 1; 0'):format(prefix))
	end
	self.driverCount = index;
	self:Execute(CPAPI.ConvertSecureBody([[
		ENABLED = true;
		self::ClearState()
	]]))
end

---------------------------------------------------------------
function Layers:OnDataLoaded()
	self:OnNewBindings()
	return CPAPI.KeepMeForLater;
end

function Layers:OnSettingsChanged()
	self:SetFeatures(db('layersTapLatch'), db('layersDoubleBar'), db('layersOrdered'))
	self:SetModifiers()
end

db:RegisterSafeCallbacks(Layers.OnSettingsChanged, Layers,
	'Settings/layersTapLatch',
	'Settings/layersDoubleBar',
	'Settings/layersOrdered'
);

db:RegisterSafeCallback('OnNewBindings', Layers.OnNewBindings, Layers)
