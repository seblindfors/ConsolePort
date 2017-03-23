local CP_UI, UI = ...
----------------------------------
_G[CP_UI] = UI
----------------------------------------------------------------
local 	assert, format, pairs, ipairs, next, select, type, unpack, wipe, tconcat = 
		assert, format, pairs, ipairs, next, select, type, unpack, wipe, table.concat
local 	anchor, load, getRelative, callMethod, callMethodSafe, addSubTable, err
----------------------------------------------------------------
local ARGS, ERROR, ERROR_CODES, REGION, SETUP, IGNORE_SETUP, IGNORE_VALUE
local ANCHORS, CONSTRUCTORS = {}, {}
----------------------------------------------------------------

--- Create a new frame.
-- @param 	object 	: Type of object to be created. Frame or inherited therefrom. 
-- @param 	name 	: Name of the object to be created.
-- @param 	parent 	: Parent of the object.
-- @param 	templates : Inherited templates.
-- @param 	blueprint : Table consisting of additional regions to be created.
-- @return 	frame 	: Returns the created object.
function UI:CreateFrame(object, name, parent, templates, blueprint, recursive)
	----------------------------------
	if templates and templates:match('Secure') then
		assert(not InCombatLockdown(), 'Cannot create secure frame in combat!')
	end
	----------------------------------
	local frame = CreateFrame(object, name, parent, templates)
	self:OnFrameCreated(frame)
	----------------------------------
	if blueprint then
		self:BuildFrame(frame, blueprint, true)
	end
	----------------------------------
	if not recursive then
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
		local isLoop = config.Repeat
		for i = 1, ( isLoop or 1 ) do
			local key = ( isLoop and key..i ) or key
			local region = frame[key]
			if not region then
				----------------------------------
				if config.Setup then -- Assert type exists if setup table exists.
					assert(config.Type, err(key, name, ERROR_CODES.REGION))
				end
				----------------------------------
				if config.Type then
					-- Region type has special constructor.
					if REGION[config.Type] then
						region = REGION[config.Type](frame, key, config.Setup or config.Values)
					-- Region already exists.
					elseif type(config.Type) == 'table' then
						region = REGION.Existing(frame, key, config.Type)
					-- Region should be a type of frame.
					elseif type(config.Type) == 'string' then
						region = self:CreateFrame(config.Type, '$parent'..key, frame, config.Setup and tconcat(config.Setup, ', '), config[1], true)
						-- Children have already been added recursively, remove the blueprint.
						config[1] = nil
					end
				else -- Assume this is a data table.
					region = config
				end

				frame[key] = region
			end

			if isLoop and region.SetID then
				region:SetID(i)
			end

			-- apply preset (if present) before everything else
			if config.Preset then
				callMethodSafe(region, 'Preset', config.Preset)
			end

			-- mixin before running the rest of the region func stack,
			-- since mixed in functions may be called from the blueprint
			if config.Mixin then
				callMethodSafe(region, 'Mixin', config.Mixin)
				-- if the mixin has an onload script, add it to the constructor stack.
				-- remove the onload function from the object itself.
				if region.OnLoad and not config.OnLoad then
					-- use :GetScript in case more than one load script was hooked.
					config.OnLoad = region:GetScript('OnLoad')
					region:SetScript('OnLoad', nil)
					region.OnLoad = nil
				end
			end

			for sType, sData in pairs(config) do
				callMethod(region, sType, sData)
			end
		end
	end
	-- parse if function is explicitly called
	if not recursive then
		anchor()
		load()
	end
	return frame
end

function callMethodSafe(region, sType, sData)
	if sData == 'nil' then
		sData = nil
	end
	local func = SETUP[sType] or region[sType]
	if type(func) == 'function' then
		-- if non-associative table, just unpack it.
		if ( type(sData) == 'table' and #sData ~= 0 and sType ~= 1) then
			return func(region, unpack(sData))
		else
			return func(region, sData)
		end
	elseif type(sData) == 'function' and region.HasScript and region:HasScript(sType) then
		if region:GetScript(sType) then
			region:HookScript(sType, sData)
		else
			region:SetScript(sType, sData)
		end 
	elseif not IGNORE_VALUE[sType] then
		region[sType] = sData
	end
end

function callMethod(region, sType, sData)
	if not IGNORE_SETUP[sType] then
		callMethodSafe(region, sType, sData)
	end
end


----------------------------------
function getRelative(region, regionString)
	if type(regionString) == 'table' then 
		return regionString
	elseif type(regionString) == 'string' then 
		local relativeRegion
		for key in regionString:gmatch('%a+') do
			if key == 'parent' then
				relativeRegion = relativeRegion and relativeRegion:GetParent() or region:GetParent()
			elseif relativeRegion then
				relativeRegion = relativeRegion[key]
			else
				relativeRegion = region[key]
			end
		end
		return relativeRegion
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

function addSubTable(tbl, ...) tbl[#tbl + 1] = {...} end

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
		local frame = CreateFrame('ScrollFrame', '$parent'..key, parent)
		local child = setup or CreateFrame('Frame', '$parentChild', frame)
		frame.Child = child
		child:SetParent(frame)
		child:SetAllPoints()
		frame:SetScrollChild(child)
		return frame
	end,
	---
	Table = function(parent, key, setup) parent[key] = setup or {} return parent[key] end,
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
	[1] = function(frame, blueprint) UI:BuildFrame(frame, blueprint, true) end,
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
	Events 	= function(frame, ...) for _, v in pairs({...}) do frame:RegisterEvent(v) end end,
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
	Preset 	= function(region, ...) UI:ApplyTemplate(region, ...) end,
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
	Points  = function(region, ...) for _, point in pairs({...}) do addSubTable(ANCHORS, region, unpack(point)) end end,
	-- Mixin 
	Mixin 	= function(region, ...) UI:ApplyMixin(region, nil, ...) end,
	MixinNormal = function(region, ...) UI:ApplyMixin(region, UI.Utils.MixinNormal, ...) end,
	--- Multiple runs
	Multiple 	= function(region, multiTable)
		for k, v in pairs(multiTable) do
			assert(region[k], err(k, region:GetName(), ERROR_CODES.MULTI_FUNC))
			assert(type(v) == 'table', err(k, region:GetName(), ERROR_CODES.MULTI_TABLE))
			for _, args in pairs(v) do
				callMethod(region, k, args)
			end
		end
	end,
}---------------------------------

----------------------------------
IGNORE_SETUP = {
----------------------------------
	Preset = true,
	Repeat = true,
	Mixin = true,
}---------------------------------

----------------------------------
IGNORE_VALUE = {
----------------------------------
	Type = true,
	Setup = true,
	Values = true,
}---------------------------------

-- Allow other entities to access these objects directly
UI.Functions = SETUP
UI.Region = REGION
-- Shortcut for mixin with scripts, since it's expected to be used frequently.
UI.Mixin = SETUP.Mixin

----------------------------------
UI.FrameRegistry = {}
function UI:OnFrameCreated(frame)
	assert(frame)
	self.FrameRegistry[frame] = true
end