---------------------------------------------------------------
-- Input layers
---------------------------------------------------------------
-- Owns the modifier state the rest of the suite binds against.
-- Hold order, tap latches and the doubled bar are all tracked in
-- the restricted environment, so the prefix stays correct under
-- combat lockdown. Two values are published, because they are not
-- the same thing: 'prefix' is the layer the controller resolved,
-- and 'chord' is the canonical modifier combination the engine will
-- actually look up. Registrants pick their action by the prefix and
-- key their binding by the chord.
--
-- Held modifiers arrive one state driver per modifier, so the
-- driver that fired identifies which one changed and the order of
-- firings is the order they were pressed. Latches and the doubled
-- bar arrive from a proxy per modifier, which holds that modifier's
-- tap chord on every chord the device allows, and exist only while
-- a gesture uses them. They are held outside the swapped row,
-- because the row is torn down whenever the chord changes and an
-- escape must never be missing. They are secure because a wrapped
-- script is skipped under lockdown unless its frame is protected,
-- and the tap is taken on the down edge only, since a click
-- reports both.
---------------------------------------------------------------

local Layers, _, db = CPAPI.DataHandler(ConsolePortLayers), ...;
local RegisterAttributeDriver, UnregisterAttributeDriver = RegisterAttributeDriver, UnregisterAttributeDriver;
local RegisterStateDriver, UnregisterStateDriver = RegisterStateDriver, UnregisterStateDriver;
Mixin(Layers, CPAPI.SecureEnvironmentMixin)
db:Register('Layers', Layers)

Layers.Proxies     = {};
Layers.States      = {};
Layers.StateInfo   = {};
Layers.StateCount  = 0;
Layers.driverCount = 0;

---------------------------------------------------------------
Layers.Env = {
---------------------------------------------------------------
	-- Recompute the prefix and publish it. A hold borrows the
	-- state for as long as it is held, so held modifiers win
	-- outright and the latched state is simply not consulted;
	-- releasing restores it because nothing was destroyed.
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
		else
			prefix = '';
			for i = 1, #LATCH do
				prefix = prefix..LATCH[i];
			end
		end
		if ( prefix == PREFIX and chord == CHORD ) then return end;
		PREFIX, CHORD = prefix, chord;
		self::ApplyRow(chord, prefix)
		self::ApplyStates()
		self:SetAttribute('chord', chord)
		self:SetAttribute('prefix', prefix)
		self:ChildUpdate('prefix', prefix)
	]];
	-----------------------------------------------------------
	-- Release every binding the controller currently holds.
	ClearRow = [[
		for i = #APPLIED, 1, -1 do
			self:ClearBinding(APPLIED[i])
			APPLIED[i] = nil;
		end
	]];
	-----------------------------------------------------------
	-- Write the row the engine is currently consulting. Only one
	-- row is ever live: the engine looks up the canonical chord of
	-- whatever is physically held, so that is the only key space
	-- worth occupying, and it is rewritten whenever the layer it
	-- should resolve to changes.
	--
	-- Written at the low priority tier, so a transient overlay that
	-- takes the high tier wins while it is up and falls back here
	-- when it releases, instead of the two fighting for the same key.
	--
	-- Two sources compose, resolved here rather than by writing the
	-- same key twice: STORED is the mirror of the player's own binding
	-- table and BINDINGS is what registrants have claimed. Buttons in
	-- CLAIMED are skipped, because a latch gesture owns their tap chord
	-- and holds it outside the row -- the row is torn down on every
	-- chord change, and an escape that comes and goes is one the player
	-- can miss.
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
				-- A button missing from the loadout is stood in for by
				-- a keyboard key, which has to resolve to whatever the
				-- button resolves to in this layer, not to whatever was
				-- stored against it.
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
	-- A tap changes state. Tapping the doubled modifier is part
	-- of the double tap gesture itself and is ignored; tapping a
	-- different one leaves the doubled bar and applies itself.
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
	-- A double tap swaps to that modifier's own bar, which
	-- combines with nothing. Double tapping it again exits.
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
	-- Walk the driver in order and take the first match, which is the
	-- macro conditional's own rule. A native segment goes to the
	-- engine's parser; a layer segment is a lookup, because the layers
	-- it matches were worked out when it was registered.
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

		-- 'state-visibility' is shorthand in the engine's own resolver:
		-- it shows or hides the frame and writes no attribute, and any
		-- response that is neither does nothing at all. Reasserted on
		-- every pass rather than guarded, as the engine does, so the
		-- frame cannot stay hidden after something else hid it.
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
	-- Registrant entry points, called from other environments.
	-- A registrant owns what a button does in a given layer; the
	-- controller owns which layer is live and what key the engine
	-- will look it up under, so the two never touch the same
	-- decision.
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
	ApplyRegistered = [[
		PREFIX, CHORD = nil, nil;
		self::UpdatePrefix()
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
-- Created while the addon is still loading, because a registrant in
-- any later file may reach the controller before OnDataLoaded runs.
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
-- @param button   : gamepad button absent from the loadout
-- @param emulated : key standing in for it, or nil to stop
function Layers:SetEmulation(button, emulated)
	self:Execute(CPAPI.FormatSecureBody({ button = button; emulated = emulated or false }, [[
		EMULATED[{button}] = {emulated} or nil;
	]]))
	self:Refresh()
end

---------------------------------------------------------------
-- The player's own binding table, mirrored into the environment
-- so the controller can answer for every key it owns rather than
-- leaving unclaimed ones to fall through. Registrant entries in
-- BINDINGS take precedence, so a refresh here never clobbers them.
--
-- Rewires the modifiers afterwards, because this is the earliest
-- point at which the device is known to be indexed; at OnDataLoaded
-- the modifier map may still be empty and no driver would register.
-- @param bindings : bindings[button][prefix] = bindingID
function Layers:OnNewBindings(bindings)
	local blocked = db.Gamepad.Index.Modifier.Blocked;
	self:Execute([[ wipe(STORED) ]])
	for button, set in pairs(bindings or db.Gamepad:GetBindings()) do
		for prefix, binding in pairs(set) do
			if ( binding and binding ~= '' and not blocked[prefix..button] ) then
				self:Execute(CPAPI.FormatSecureBody({
					layer = prefix; button = button; binding = binding;
				}, [[
					local set = STORED[{layer}];
					if not set then set = newtable() STORED[{layer}] = set end;
					set[{button}] = newtable('bind', {binding});
				]]))
			end
		end
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
-- controller, because the engine resolves such a condition against
-- the modifiers physically held and a latched or doubled layer is
-- neither. Its segments are classified once, and layer responses
-- resolved for every reachable layer, so the restricted side only
-- ever performs a lookup when the layer changes.
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

-- Stands in for the engine's own registration where it cannot see
-- the whole driver. Each segment is classified once: a native one
-- keeps its clauses for the engine's parser, a layer one is resolved
-- against every reachable layer now so nothing is parsed later.
-- Native segments also get a residual driver registered here purely
-- as a trigger, since the engine re-evaluating on its own is most of
-- what a state driver is for.
-- @param frame     : registrant
-- @param attribute : attribute to write, e.g. 'modifier'
-- @param driver    : expanded driver string
-- @param body      : snippet to run, reading the value as newstate
-- @param visibility : whether the engine's show/hide shorthand applies
function Layers:RegisterState(frame, attribute, driver, body, visibility)
	if InCombatLockdown() then return end;
	local key   = tostring(frame)..attribute;
	local index = self.States[key] or ( self.StateCount + 1 );
	local bodyKey, refKey = 'layerbody-'..attribute, ('state%d'):format(index);

	if body then
		frame:SetAttribute(bodyKey, ('local newstate = self:GetAttribute(%q); %s'):format(attribute, body))
	end
	self:SetFrameRef(refKey, frame)
	self:Execute(CPAPI.FormatSecureBody({
		ref = refKey; attribute = attribute; body = body and bodyKey or ''; index = index;
		visibility = not not visibility;
	}, [[
		local entry = newtable();
		entry[1] = self:GetFrameRef({ref});
		entry[2] = {attribute};
		entry[3] = newtable();
		entry[5] = {body};
		if ( entry[5] == '' ) then entry[5] = nil end;
		entry[6] = {visibility};
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

	-- A segment's clauses are an OR, so splitting it by which evaluator
	-- owns each clause is lossless: both halves carry the same response
	-- and sit at consecutive positions, so whichever matches first still
	-- yields that response before any later segment is reached.
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

	-- The residual exists to be re-evaluated by the engine, not read:
	-- its response only has to change when a different native segment
	-- starts matching, which is exactly when a re-evaluation is due.
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

-- The reachable layers depend on which gestures are enabled, so a
-- settings change invalidates every precomputed response.
function Layers:RefreshStates()
	if InCombatLockdown() then return end;
	for _, info in pairs(self.StateInfo) do
		self:RegisterState(info.frame, info.attribute, info.driver, info.body, info.visibility)
	end
end

-- Drop-in mirrors of the engine's own registration. A driver the
-- engine can resolve is handed straight to it; one made only of
-- modifier conditions is kept here, because the engine cannot see a
-- latched or doubled layer.
function Layers:RegisterAttributeDriver(frame, attribute, driver)
	local _, layer = CPAPI.ClassifyDriver(driver);
	if layer then
		UnregisterAttributeDriver(frame, attribute)
		return self:RegisterState(frame, attribute, driver)
	end
	self:UnregisterState(frame, attribute)
	return RegisterAttributeDriver(frame, attribute, driver)
end

-- The engine's own state driver is an attribute driver on
-- 'state-<name>', which is what makes the frame's _onstate-<name>
-- handler fire, so the mirror writes the same name.
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
	UnregisterStateDriver(self, ('layernative%d'):format(index))
	self:Execute(('STATES[%d] = nil'):format(index))
end

---------------------------------------------------------------
-- Modifier wiring
---------------------------------------------------------------
-- One state driver per modifier so the driver that fires names
-- the modifier, and one proxy per modifier bound to its tap
-- binding. Both feed the same restricted state.
---------------------------------------------------------------
function Layers:ReleaseModifiers()
	if InCombatLockdown() then return end;
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

function Layers:SetModifiers()
	if InCombatLockdown() then return end;
	self:ReleaseModifiers()

	-- The tap chord is only claimed when a gesture actually uses it;
	-- with both off it stays a normal binding, as it is today.
	local useEscapes = db('layersTapLatch') or db('layersDoubleBar');
	local layered    = db.Gamepad.Index.Modifier.Layered;

	local index = 0;
	for prefix, button in db.table.spairs(db.Gamepad.Index.Modifier.Prefix) do
		index = index + 1;
		self:Execute(([[ MODS[#MODS + 1] = %q ]]):format(prefix))

		if useEscapes then
			local proxy = self:AcquireProxy(prefix, index)
			for chord, inputs in pairs(db.Gamepad.Index.Modifier.Active) do
				-- Only chords the engine composes: a tap is dispatched
				-- by the engine, so a layer prefix would never be read.
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
