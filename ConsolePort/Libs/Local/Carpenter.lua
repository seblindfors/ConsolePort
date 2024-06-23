----------------------------------------------------------------
-- Carpenter
----------------------------------------------------------------
-- 
-- Author:  Sebastian Lindfors (Munk / MunkDev)
-- Website: https://github.com/seblindfors
-- Licence: GPL version 2 (General Public License)
--
-- Description:
--  Carpenter is a dynamic markup language processor, that provides a simple syntax to create frames.
--  Lua and XML are bridged by allowing dynamic inserts, such as local variables, and merging several
--  templates into one to create inheritance. WoW XML is too rigid to handle dynamic frame creation,
--  and implementing frames in pure Lua is messy, without clear hierarchy. This dynamic markup language
--  works well in any code editor, to expand/collapse items of interest during development.
--  Recursive "blueprints" automatically set name tags on items, and adds keys to the parent.
--  See example at the bottom.
--
-- Usage:
--  Carpenter(type, name, parent, inheritXML, blueprint) -> return Carpenter:CreateFrame(...)
--  Carpenter(frame, blueprint) -> return Carpenter:BuildFrame(...)
--  Carpenter:CreateFrame(type, name, parent, inheritXML, blueprint) -> creates a frame from scratch.
--  Carpenter:BuildFrame(frame, blueprint) -> builds blueprint on top of existing frame.
--  Carpenter:ExtendAPI(name, func, force) -> adds an API function that can be called from blueprints.

local Lib = LibStub:NewLibrary('Carpenter', 3)
if not Lib then return end
--------------------------------------------------------------------------
local   assert, pairs, ipairs, type, unpack, wipe, tconcat, strmatch = 
        assert, pairs, ipairs, type, unpack, wipe, table.concat, strmatch
--------------------------------------------------------------------------
local   Create, IsWidget = CreateFrame, C_Widget.IsWidget
--------------------------------------------------------------------------
local   anchor, onload, constructor, call, callMethodsOnWidget, -- build
        packtbl, getbuildinfo, getrelative, strip -- misc
--------------------------------------------------------------------------
local   SPECIAL, API, RESERVED
local   ANCHOR, ONLOAD = {}, {}


--------------------------------------------------------------------------
API = { -- Syntax: _CallID = value or {value1, ..., valueN};
--------------------------------------------------------------------------
--  [1]        = function(obj, bp)      Lib:BuildFrame(obj, bp, true) end;
    ID         = function(widget, ...)  widget:SetID(...)             end;
    --- Texture ----------------------------------------------------------
    Atlas      = function(texture, ...) texture:SetAtlas(...)         end;
    Blend      = function(texture, ...) texture:SetBlendMode(...)     end;
    Coords     = function(texture, ...) texture:SetTexCoord(...)      end;
    Gradient   = function(texture, ...) Lib:SetGradient(texture, ...) end;
    Texture    = function(texture, ...) texture:SetTexture(...)       end;
    --- FontString -------------------------------------------------------
    AlignH     = function(fontstr, ...) fontstr:SetJustifyH(...)      end;
    AlignV     = function(fontstr, ...) fontstr:SetJustifyV(...)      end;
    Color      = function(fontstr, ...) fontstr:SetTextColor(...)     end;
    Font       = function(fontstr, ...) fontstr:SetFont(...)          end;
    FontH      = function(fontstr, ...) fontstr:SetHeight(...)        end;
    Text       = function(fontstr, ...) fontstr:SetText(...)          end;
    --- LayeredRegion ----------------------------------------------------
    Layer      = function(widget, ...)  widget:SetDrawLayer(...)      end;
    Vertex     = function(widget, ...)  widget:SetVertexColor(...)    end;
    --- Frame packages ---------------------------------------------------
    Attributes = function(frame, attr)  for k, v in pairs(attr)   do frame:SetAttribute(k, v) end end;
    Events     = function(frame, ...)   for _, v in ipairs({...}) do frame:RegisterEvent(v)   end end;
    Hooks      = function(frame, src)   for k, v in pairs(src)    do frame:HookScript(k, v)   end end;
    Scripts    = function(frame, src)   for k, v in pairs(src)    do frame:SetScript(k, v)    end end;
    --- Frame ------------------------------------------------------------
    Backdrop   = function(frame, info)  Lib:SetBackdrop(frame, info)  end;
    Level      = function(frame, ...)   frame:SetFrameLevel(...)      end;
    Strata     = function(frame, ...)   frame:SetFrameStrata(...)     end;
    --- Region -----------------------------------------------------------
    Alpha      = function(widget, ...)  widget:SetAlpha(...)          end;
    Clear      = function(widget)       widget:ClearAllPoints()       end;
    Fill       = function(widget, tar)  widget:SetAllPoints(tar ~= true and getrelative(widget, tar)) end;
    Height     = function(widget, ...)  widget:SetHeight(...)         end;
    Hide       = function(widget, ...)  widget:Hide()                 end;
    Show       = function(widget, ...)  widget:Show()                 end;
    Size       = function(widget, ...)  widget:SetSize(...)           end;
    Scale      = function(widget, ...)  widget:SetScale(...)          end;
    Width      = function(widget, ...)  widget:SetWidth(...)          end;
    --- Button -----------------------------------------------------------
    Click      = function(button, ...)  button:SetAttribute('type', 'click')  button:SetAttribute('clickbutton', ...) end;
    Macro      = function(button, ...)  button:SetAttribute('type', 'macro')  button:SetAttribute('macrotext', ...) end;
    Action     = function(button, ...)  button:SetAttribute('type', 'action') button:SetAttribute('action', ...) end;
    Spell      = function(button, ...)  button:SetAttribute('type', 'spell')  button:SetAttribute('spell', ...) end;
    Unit       = function(button, ...)  button:SetAttribute('type', 'target') button:SetAttribute('unit', ...) end;
    Item       = function(button, ...)  button:SetAttribute('type', 'item')   button:SetAttribute('item', ...) end;
    --- Constructor ------------------------------------------------------
    OnLoad     = function(widget, ...)  packtbl(ONLOAD, widget, ...)  end;
    --- Points -----------------------------------------------------------
    Point      = function(widget, ...)  packtbl(ANCHOR, widget, ...)  end;
    Points     = function(widget, ...)  for _, point in ipairs({...}) do packtbl(ANCHOR, widget, unpack(point)) end end;
    -- Custom handlers ---------------------------------------------------
    Mixin      = function(widget, ...)  Lib:Mixin(widget, ...)        end;
    MixinDry   = function(widget, ...)  Mixin(widget, ...)            end;
    --- Multiple runs of single function ---------------------------------
    ForEach    = function(widget, multiTable)
        for k, v in pairs(multiTable) do k = strip(k)
            for _, args in pairs(v) do
                call(widget, k, args)
            end
        end
    end;
};

--------------------------------------------------------------------------
SPECIAL = { -- Special constructors
--------------------------------------------------------------------------
    AnimationGroup = function(parent, key, setup, anon)
        local name = not anon and '$parent'..key or nil;
        if setup then
            return parent:CreateAnimationGroup(name, unpack(setup))
        end
        return parent:CreateAnimationGroup(name)
    end;
    Animation = function(parent, key, setup, anon)
        return parent:CreateAnimation(setup, not anon and '$parent'..key or nil)
    end;
    FontString = function(parent, key, setup, anon)
        local name = not anon and '$parent'..key or nil;
        if setup then
            return parent:CreateFontString(name, unpack(setup))
        end
        return parent:CreateFontString(name)
    end;
    Texture = function(parent, key, setup, anon)
        local name = not anon and '$parent'..key or nil;
        if setup then
            return parent:CreateTexture(name, unpack(setup))
        end
        return parent:CreateTexture(name)
    end;
    ---
    ScrollFrame = function(parent, key, setup, anon)
        local frame = Create('ScrollFrame', not anon and '$parent'..key or nil, parent, setup and not IsWidget(setup) and unpack(setup))
        local child = IsWidget(setup) and setup or Create('Frame', not anon and '$parentChild' or nil, frame)
        frame.Child = child
        child:SetParent(frame)
        child:SetAllPoints()
        frame:SetScrollChild(child)
        frame:SetToplevel(true)
        return frame
    end;
    ---
    Global = function(parent, key, region, anon)
        if not anon then
            _G[parent:GetName()..key] = region
        end
        parent[key] = region
        region:SetParent(parent)
        return region
    end;
};

--------------------------------------------------------------------------
RESERVED = { -- Reserved keywords in blueprints
--------------------------------------------------------------------------
    [1]        = true, -- don't run blueprints in function stack
    _Type      = true, -- used to determine frame type
    _Mixin     = true, -- specially handled before function calls
    _Setup     = true, -- used to determine inheritance
    _Repeat    = true, -- ignore since it denotes a loop
    _Anonymous = true, -- denotes anonymous parent/children
};

----------------------------------------------------------------
-- Create a new frame.
----------------------------------------------------------------
-- @param   object    : Type of object to be created.
-- @param   name      : Name of the object to be created.
-- @param   parent    : Parent of the object.
-- @param   xml       : Inherited xml.
-- @param   blueprint : Table consisting of additional regions to be created.
-- @return  frame     : Returns the created object.
----------------------------------------------------------------
function Lib:CreateFrame(object, name, parent, xml, blueprint, recursive, anonymous)
    ----------------------------------
    local frame = Create(object, name, parent, xml)
    ----------------------------------
    if blueprint then
        if recursive then
            self:BuildFrame(frame, blueprint, true, anonymous)
        else
            local children = blueprint[1]
            callMethodsOnWidget(frame, blueprint)
            self:BuildFrame(frame, children, true)
        end
    end
    ----------------------------------
    if not recursive then
        anchor()
        onload()
    end
    return frame
end

----------------------------------------------------------------
-- Build frame from blueprint.
----------------------------------------------------------------
-- @param   frame     : Parent of the blueprint.
-- @param   blueprint : Blueprint to be constructed.
-- @param   recursive : Whether this is a recursive call.
-- @param   anonframe : Whether tree is anonymous.
-- @return  frame     : Returns the altered frame.
----------------------------------------------------------------
function Lib:BuildFrame(frame, blueprint, recursive, anonframe)
    for key, config in pairs(blueprint) do
        ----------------------------------
        local object, objectType, buildInfo, isLoop, anonobj = getbuildinfo(config)
        ----------------------------------
        for i = 1, ( isLoop or 1 ) do
            local key    = isLoop and key..i or key
            local anon   = anonframe or anonobj
            local name   = not anon and '$parent'..key
            local widget = IsWidget(frame[key]) and frame[key]
            if not widget then
                ----------------------------------
                if object then
                    -- Region type has special constructor.
                    if SPECIAL[object] then
                        local bp  = config[1]
                        widget = SPECIAL[object](frame, key, buildInfo, anon)
                        if bp then
                            widget = self:BuildFrame(widget, bp, true, anon)
                        end
                    -- Region already exists.
                    elseif (objectType == 'table') and IsWidget(object) then
                        widget = SPECIAL.Global(frame, key, object, anon)
                    -- Region should be a type of frame.
                    elseif (objectType == 'string') then
                        local xml = type(buildInfo) == 'table' and tconcat(buildInfo, ', ') or buildInfo
                        local bp  = config[1]
                        widget = self:CreateFrame(object, name, frame, xml, bp, true, anon);
                    end
                else -- Assume this is a data table.
                    widget = config
                end
                ----------------------------------
                frame[key] = widget
            else
                local bp = config[1]
                if bp then
                    widget = self:BuildFrame(widget, bp, true, anon)
                end
            end

            if isLoop and widget.SetID then widget:SetID(i) end
            callMethodsOnWidget(widget, config)
        end
    end
    -- parse if explicitly called without wrapping (building on top of existing frame)
    if not recursive then
        anchor()
        onload()
    end
    return frame
end

----------------------------------------------------------------
-- Extend API
----------------------------------------------------------------
-- @param   name    : Name of the API function to add.
-- @param   func    : Function to add.
-- @param   force   : Forcefully replace existing function.
-- @return  success : Returns true when successful.
----------------------------------------------------------------
function Lib:ExtendAPI(name, func, force)
    assert(type(name) == 'string',   format("bad argument #1 to 'ExtendAPI' (string expected, got %s)", type(name)))
    assert(type(func) == 'function', format("bad argument #2 to 'ExtendAPI' (function expected, got %s)", type(func)))
    assert(not API[name] or force,   format('%s is already registered in the API.', tostring(name)))
    API[name] = func
    return true
end

function Lib:Mixin(obj, ...)
    local scriptObject = (type(obj.HasScript) == 'function')
    for i = 1, select('#', ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            if scriptObject and obj:HasScript(k) then
                if obj:GetScript(k) then
                    obj:HookScript(k, v)
                else
                    obj:SetScript(k, v)
                end
            end
            obj[k] = v
        end
    end
    return obj
end

function Lib:SetBackdrop(frame, ...)
    if BackdropTemplateMixin then
        if not frame.OnBackdropLoaded then 
            Mixin(frame, BackdropTemplateMixin)
            frame:HookScript('OnSizeChanged', frame.OnBackdropSizeChanged)
        end
        BackdropTemplateMixin.SetBackdrop(frame, ...)
    else
        getmetatable(frame).__index.SetBackdrop(frame, ...)
    end
end

function Lib:SetGradient(texture, orientation, ...)
    local isOldFormat = (select('#', ...) == 8)
    if texture.SetGradientAlpha then
        if isOldFormat then 
            return texture:SetGradientAlpha(orientation, ...)
        end
        local min, max = ...;
        local minR, minG, minB, minA = ColorMixin.GetRGBA(min)
        local maxR, maxG, maxB, maxA = ColorMixin.GetRGBA(max)
        return texture:SetGradientAlpha(orientation, minR, minG, minB, minA, maxR, maxG, maxB, maxA)
    end
    if texture.SetGradient then
        if isOldFormat then
            local minColor = CreateColor(...)
            local maxColor = CreateColor(select(5, ...))
            return texture:SetGradient(orientation, minColor, maxColor)
        end
        return texture:SetGradient(orientation, ...)
    end
end

setmetatable(Lib, {
    __index = API;
    __call = function(self, arg1, ...)
        if IsWidget(arg1) then
            return self:BuildFrame(arg1, ...)
        end
        return self:CreateFrame(arg1, ...)
    end;
})

--------------------------------------------------------------------------
-- Internal circuit
--------------------------------------------------------------------------
function call(widget, method, data)
    if data == 'nil' then data = nil end
    local func = API[method] or widget[method]
    if type(func) == 'function' then
        -- if sequential array, just unpack it.
        if ( type(data) == 'table' and #data ~= 0 ) then
            return func(widget, unpack(data))
        else
            return func(widget, data)
        end
    elseif type(data) == 'function' and widget.HasScript and widget:HasScript(method) then
        if widget:GetScript(method) then
            widget:HookScript(method, data)
        else
            widget:SetScript(method, data)
        end 
    else
        widget[method] = data
    end
end

function callMethodsOnWidget(widget, methods)
    -- mixin before running the rest of the widget method stack,
    -- since mixed in functions may be called from the blueprint
    local mixin = methods._Mixin
    if mixin then
        call(widget, 'Mixin', mixin)
        -- if the mixin has an onload script, add it to the constructor stack.
        -- remove the onload function from the object itself.
        if widget.OnLoad and not methods._OnLoad then
            -- use :GetScript in case more than one load script was hooked.
            methods._OnLoad = widget:GetScript('OnLoad')
            widget:SetScript('OnLoad', nil)
            widget.OnLoad = nil
        end
    end

    for method, data in pairs(methods) do
        if not RESERVED[method] then
            local func = strip(method)
            if func then
                call(widget, func, data)
            else
                widget[method] = data
            end
        end
    end
end

function getrelative(region, query)
    if IsWidget(query) then 
        return query
    elseif type(query) == 'string' then 
        local relative
        for key in query:gmatch('%w+') do
            if ( key == 'parent' ) then
                relative = relative and relative:GetParent() or region:GetParent()
            elseif relative then
                relative = relative[key]
            else
                relative = region[key]
            end
        end
        return relative
    end
end

function anchor()
    for _, setup in ipairs(ANCHOR) do
        local numArgs = #setup
        if numArgs == 2 then
            local region, point = unpack(setup)
            region:SetPoint(point)
        elseif numArgs == 4 then
            local region, point, x, y = unpack(setup)
            region:SetPoint(point, x, y)
        elseif numArgs == 6 then
            local region, point, relativeRegion, relativePoint, x, y = unpack(setup)
            region:SetPoint(point, getrelative(region, relativeRegion), relativePoint, x, y)
        elseif numArgs == 8 then
            local region, point, relativeRegion, relativePoint, x, y, xIncr, yIncr = unpack(setup)
            region:SetPoint(point, getrelative(region, relativeRegion), relativePoint,
                x + (xIncr * ((region:GetID() or 1) - 1)),
                y + (yIncr * ((region:GetID() or 1) - 1))
            );
        end
    end
    wipe(ANCHOR)
end

function constructor(region, load, ...)
    if not load then return end
    load(region)
    return constructor(region, ...)
end

function onload()
    for _, setup in ipairs(ONLOAD) do
        local region, load = unpack(setup)
        if ( type(load) == 'table' ) then
            constructor(region, unpack(load))
        else
            constructor(region, load)
        end
    end
    wipe(ONLOAD)
end

function getbuildinfo(bp) return 
    bp._Type,
    type(bp._Type),
    bp._Setup,
    bp._Repeat,
    bp._Anonymous
end

function packtbl(tbl, ...) tbl[#tbl + 1] = {...} end;
function strip(key) return strmatch(key, '_(%w+)') end;

---------------------------------------------------------------
-- Extend API
---------------------------------------------------------------
if not LibStub:GetLibrary('ConsolePortNode') then return end
Lib:ExtendAPI('IgnoreNode', function(self, ...) self:SetAttribute('nodeignore', ...) end)
Lib:ExtendAPI('PriorityNode', function(self, ...) self:SetAttribute('nodepriority', ...) end)
Lib:ExtendAPI('SingletonNode', function(self, ...) self:SetAttribute('nodesingleton', ...) end)