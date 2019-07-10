local UI = {} ConsolePortUI = UI
----------------------------------------------------------------
local 	assert, pairs, ipairs, type, unpack, wipe, tconcat = 
		assert, pairs, ipairs, type, unpack, wipe, table.concat
----------------------------------------------------------------
local 	CreateFrame = CreateFrame
----------------------------------------------------------------
local 	anchor, load, call, callMethodsOnRegion, -- func calls
		addSubTable, err, getBuildInfo, getRelative -- misc
----------------------------------------------------------------
local 	ARGS, ERROR, ERROR_CODES, REGION, SETUP, RESERVED
local 	ANCHORS, CONSTRUCTORS = {}, {}
----------------------------------------------------------------

--- Create a new frame.
-- @param 	object 	: Type of object to be created. Frame or inherited therefrom. 
-- @param 	name 	: Name of the object to be created.
-- @param 	parent 	: Parent of the object.
-- @param 	xml 	: Inherited xml.
-- @param 	blueprint : Table consisting of additional regions to be created.
-- @return 	frame 	: Returns the created object.
function UI:CreateFrame(object, name, parent, xml, blueprint, recursive)
	----------------------------------
	local frame = CreateFrame(object, name, parent, xml)
	----------------------------------
	if blueprint then
		if recursive then
			self:BuildFrame(frame, blueprint, true)
		else
			local children = blueprint[1]
			callMethodsOnRegion(frame, blueprint)
			self:BuildFrame(frame, children, true)
		end
	end
	----------------------------------
	if not recursive then
		self:OnFrameCreated(frame)
		anchor()
		load()
	end
	return frame
end

--- Build frame from blueprint.
-- @param 	frame 	: Parent of the blueprint.
-- @param 	blueprint : Blueprint to be constructed.
-- @param 	recursive : Whether this is a recursive call.
-- @return 	frame 	: Returns the altered frame.	
function UI:BuildFrame(frame, blueprint, recursive)
	assert(type(blueprint) == 'table', err('Blueprint', frame:GetName(), ERROR_CODES.BLUEPRINT))
	for key, config in pairs(blueprint) do
		assert(type(config) == 'table', err(key, frame:GetName(), ERROR_CODES.CONFIGTABLE))
		----------------------------------
		local object, objectType, buildInfo, isLoop = getBuildInfo(config)
		----------------------------------
		for i = 1, ( isLoop or 1 ) do
			local key = ( isLoop and key..i ) or key
			local region = frame[key]
			if not region then
				----------------------------------
				-- Assert object type exists if setup table exists.
				assert((buildInfo and object) or (not buildInfo), err(key, name, ERROR_CODES.REGION))
				----------------------------------
				if object then
					-- Region type has special constructor.
					if REGION[object] then
						region = REGION[object](frame, key, buildInfo)
					-- Region already exists.
					elseif objectType == 'table' then
						region = REGION.Existing(frame, key, object)
					-- Region should be a type of frame.
					elseif objectType == 'string' then
						region = self:CreateFrame(object, '$parent'..key, frame, buildInfo and tconcat(buildInfo, ', '), config[1], true)
					end
				else -- Assume this is a data table.
					region = config
				end
				----------------------------------
				frame[key] = region
			end

			if isLoop and region.SetID then
				region:SetID(i)
			end

			callMethodsOnRegion(region, config)
		end
	end
	-- parse if explicitly called without wrapping (building on top of existing frame)
	if not recursive then
		anchor()
		load()
	end
	return frame
end

----------------------------------
function call(region, method, data)
	if data == 'nil' then
		data = nil
	end
	local func = SETUP[method] or region[method]
	if type(func) == 'function' then
		-- if sequential array, just unpack it.
		if ( type(data) == 'table' and #data ~= 0 ) then
			return func(region, unpack(data))
		else
			return func(region, data)
		end
	elseif type(data) == 'function' and region.HasScript and region:HasScript(method) then
		if region:GetScript(method) then
			region:HookScript(method, data)
		else
			region:SetScript(method, data)
		end 
	else
		region[method] = data
	end
end

function callMethodsOnRegion(region, methods)
	-- mixin before running the rest of the region method stack,
	-- since mixed in functions may be called from the blueprint
	local mixin = methods.Mixin
	if mixin then
		call(region, 'Mixin', mixin)
		-- if the mixin has an onload script, add it to the constructor stack.
		-- remove the onload function from the object itself.
		if region.OnLoad and not methods.OnLoad then
			-- use :GetScript in case more than one load script was hooked.
			methods.OnLoad = region:GetScript('OnLoad')
			region:SetScript('OnLoad', nil)
			region.OnLoad = nil
		end
	end

	for method, data in pairs(methods) do
		if not RESERVED[method] then
			call(region, method, data)
		end
	end
end

----------------------------------
function getRelative(region, relative)
	if type(relative) == 'table' then 
		return relative
	elseif type(relative) == 'string' then 
		local searchResult
		for key in relative:gmatch('%a+') do
			if key == 'parent' then
				searchResult = searchResult and searchResult:GetParent() or region:GetParent()
			elseif searchResult then
				searchResult = searchResult[key]
			else
				searchResult = region[key]
			end
		end
		return searchResult
	else
		err('Relative region', region:GetName(), ERROR.CODES.RELATIVEREGION)
	end
end

function anchor()
	for _, setup in pairs(ANCHORS) do
		local numArgs = #setup
		if numArgs == 2 then
			local region, point = unpack(setup)
			region:SetPoint(point)
		elseif numArgs == 4 then
			local region, point, xOffset, yOffset = unpack(setup)
			region:SetPoint(point, xOffset, yOffset)
		elseif numArgs == 6 then
			local region, point, relativeRegion, relativePoint, xOffset, yOffset = unpack(setup)
			region:SetPoint(point, getRelative(region, relativeRegion), relativePoint, xOffset, yOffset)
		end
	end
	wipe(ANCHORS)
end

function load()
	for _, setup in pairs(CONSTRUCTORS) do
		local region, constructor = unpack(setup)
		assert(type(constructor) == 'function', err('Constructor', region:GetName(), ERROR_CODES.CONSTRUCTOR))
		constructor(region)
	end
	wipe(CONSTRUCTORS)
end

----------------------------------
function getBuildInfo(bp) return bp.Type, type(bp.Type), bp.Setup, bp.Repeat end
----------------------------------
function addSubTable(tbl, ...) tbl[#tbl + 1] = {...} end

----------------------------------
RESERVED = {
----------------------------------
	[1] 	= true, -- don't run blueprints in function stack
	Type 	= true, -- used to determine frame type
	Mixin 	= true, -- specially handled before function calls
	Setup 	= true, -- used to determine inheritance, should not be mixed in.
	Repeat 	= true, -- ignore since it denotes a loop
}

----------------------------------
ARGS = {
----------------------------------
	MULTI_RUN = 'function name on object as key, table of values to be unpacked into key function. Nesting allowed.',
	REGION = 'Region key should be of type string and refer to a valid widget type.',
	BLUEPRINT = '(frame, blueprint); blueprint = { child1 = {}, child2 = {}, ..., childN = {} }',
	RELATIVEREGION = '(frame or string). Example of string: $parent.Sibling',
}---------------------------------

----------------------------------
ERROR = '%s in %s %s.'
----------------------------------
ERROR_CODES = {
----------------------------------
	MULTI_FUNC 	= 'does not exist. Loop table should contain: '..ARGS.MULTI_RUN,
	MULTI_TABLE = 'has an invalid loop table. Loop table should contain: '..ARGS.MULTI_RUN,
	REGION 	= 'missing region type. '..ARGS.REGION,
	RELATIVEREGION = 'is invalid. Type should be a parsable string or existing frame. Arguments: '..ARGS.RELATIVEREGION,
	CONSTRUCTOR = 'is invalid. Constructor must be a function.',
	BLUEPRINT = 'is invalid. Blueprint should be a nested table. Arguments: '..ARGS.BLUEPRINT,
	CONFIGTABLE = 'is not a valid config table or existing region.',
}---------------------------------

function err(key, name, code) return ERROR:format(key, name or 'unnamed region', code) end

-- Special constructors
----------------------------------
REGION = {
----------------------------------
	AnimationGroup = function(parent, key, setup) return parent:CreateAnimationGroup('$parent'..key, setup and unpack(setup)) end,
	Animation = function(parent, key, setup) return parent:CreateAnimation(setup, '$parent'..key) end,
	FontString = function(parent, key, setup) return parent:CreateFontString('$parent'..key, setup and unpack(setup)) end,
	Texture = function(parent, key, setup) return parent:CreateTexture('$parent'..key, setup and unpack(setup)) end,
	---
	ScrollFrame = function(parent, key, setup)
		local frame = CreateFrame('ScrollFrame', '$parent'..key, parent, 'CPUIPanelScrollFrameTemplate')
		local child = setup or CreateFrame('Frame', '$parentChild', frame)
		frame.Child = child
		child:SetParent(frame)
		child:SetAllPoints()
		frame:SetScrollChild(child)
		frame:SetToplevel(true)
		return frame
	end,
	---
	Existing = function(parent, key, region)
		_G[parent:GetName()..key] = region
		region:SetParent(parent)
		return region
	end
}---------------------------------

-- API listing
----------------------------------
SETUP = {
----------------------------------
--	[1] = function(frame, blueprint) UI:BuildFrame(frame, blueprint, true) end,
	ID 	= function(region, ...) region:SetID(...) end,
	--- Texture
	Atlas 	= function(texture, ...) texture:SetAtlas(...) end,
	Blend 	= function(texture, ...) texture:SetBlendMode(...) end,
	Coords 	= function(texture, ...) texture:SetTexCoord(...) end,
	Gradient = function(texture, ...) texture:SetGradientAlpha(...) end,
	Texture = function(texture, ...) texture:SetTexture(...) end,
	--- FontString
	AlignH 	= function(fontString, ...) fontString:SetJustifyH(...) end,
	AlignV 	= function(fontString, ...) fontString:SetJustifyV(...) end,
	Color 	= function(fontString, ...) fontString:SetTextColor(...) end,
	Font 	= function(fontString, ...) fontString:SetFont(...) end,
	FontH 	= function(fontString, ...) fontString:SetHeight(...) end,
	Text 	= function(fontString, ...) fontString:SetText(...) end,
	--- LayeredRegion
	Layer 	= function(region, ...) region:SetDrawLayer(...) end,
	Vertex 	= function(region, ...) region:SetVertexColor(...) end,
	--- Frame
	Attrib 	= function(frame, attributes) for k, v in pairs(attributes) do frame:SetAttribute(k, v) end end,
	Backdrop = function(frame, backdrop) frame:SetBackdrop(backdrop) end,
	Background = function(frame, backdrop) UI.Media:SetBackdrop(frame, backdrop) end,
	Events 	= function(frame, ...) for _, v in ipairs({...}) do frame:RegisterEvent(v) end end,
	Hooks 	= function(frame, scripts) for k, v in pairs(scripts) do frame:HookScript(k, v) end end,
	Level 	= function(frame, ...) frame:SetFrameLevel(...) end,
	Strata 	= function(frame, ...) frame:SetFrameStrata(...) end,
	Scripts = function(frame, scripts) for k, v in pairs(scripts) do frame:SetScript(k, v) end end,
	--- Region
	Alpha 	= function(region, ...) region:SetAlpha(...) end,
	Clear 	= function(region) region:ClearAllPoints() end,
	Fill 	= function(region, target) region:SetAllPoints(target ~= true and getRelative(region, target)) end,
	Height 	= function(region, ...) region:SetHeight(...) end,
	Hide 	= function(region, ...) region:Hide() end,
	Probe 	= function(region, ...) region.probe = UI:CreateProbe(region, ...) end,
	Show 	= function(region, ...) region:Show() end,
	Size 	= function(region, ...) region:SetSize(...) end,
	Scale 	= function(region, ...) region:SetScale(...) end,
	Width 	= function(region, ...) region:SetWidth(...) end,
	--- Button
	Click 	= function(button, ...) button:SetAttribute('type', 'click') button:SetAttribute('clickbutton', ...) end,
	Macro 	= function(button, ...) button:SetAttribute('type', 'macro') button:SetAttribute('macrotext', ...) end,
	Action 	= function(button, ...) button:SetAttribute('type', 'action') button:SetAttribute('action', ...) end,
	Spell 	= function(button, ...) button:SetAttribute('type', 'spell') button:SetAttribute('spell', ...) end,
	Unit 	= function(button, ...) button:SetAttribute('type', 'target') button:SetAttribute('unit', ...) end,
	Item 	= function(button, ...) button:SetAttribute('type', 'item') button:SetAttribute('item', ...) end,
	--- Constructor
	OnLoad 	= function(region, ...) addSubTable(CONSTRUCTORS, region, ...) end,
	--- Points
	Point 	= function(region, ...) addSubTable(ANCHORS, region, ...) end,
	Points  = function(region, ...) for _, point in ipairs({...}) do addSubTable(ANCHORS, region, unpack(point)) end end,
	-- Mixin 
	Mixin 	= function(region, ...) UI:ApplyMixin(region, nil, ...) end,
	--- Multiple runs
	Multiple 	= function(region, multiTable)
		for k, v in pairs(multiTable) do
			assert(region[k] or SETUP[k], err(k, region:GetName(), ERROR_CODES.MULTI_FUNC))
			assert(type(v) == 'table', err(k, region:GetName(), ERROR_CODES.MULTI_TABLE))
			for _, args in pairs(v) do
				call(region, k, args)
			end
		end
	end,
}---------------------------------

----------------------------------
UI.FrameRegistry = {}
function UI:OnFrameCreated(frame)
	assert(frame)
	self.FrameRegistry[frame] = true
end

function UI:RemoveRegisteredFrame(frame)
	assert(frame and self.FrameRegistry[frame], 'The supplied frame is not registered.')
	self.FrameRegistry[frame] = nil
end

----------------------------------
--- Creates a frame that automatically sets scripts and dispatches events.
-- @param 	type 	: Type of frame
-- @param	name 	: Global frame name
-- @param	parent 	: Parent of frame
-- @param	inherit : Templates to inherit from
-- @return 	frame 	: Returns the created frame.
function UI:CreateScriptFrame(...)
	local frame = CreateFrame(...)
	local index = getmetatable(frame).__index

	function index:Hook(name, func)
		hooksecurefunc(name, function(...)
			func(self, ...)
		end)
	end

	function index:HookObject(object, name, func)
		hooksecurefunc(object, name, function(...)
			func(self, ...)
		end)
	end

	setmetatable(frame, {
		__index = index;
		__newindex = function(t, k, v)
			if t:HasScript(k) then
				if t:GetScript(k) then
					t:HookScript(k, v)
				else
					t:SetScript(k, v)
				end
			else
				pcall(t.RegisterEvent, t, k)
				rawset(t, k, v)
			end
		end;
	})

	function frame:OnEvent(event, ...)
		if self[event] then
			self[event](self, ...)
		end
	end
	return frame
end

----------------------------------
-- TODO: Remove
-- Force disable outdated modules (for now)
DisableAddOn('ConsolePortUI')
DisableAddOn('ConsolePortUI_NPC')
----------------------------------