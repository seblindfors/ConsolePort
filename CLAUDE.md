# ConsolePort Coding Standards

> For AI agents and contributors. ConsolePort: World of Warcraft gamepad addon suite, Lua/XML against the WoW API.

---

## 0. Binding Rules

**Never call the global `RegisterStateDriver` or `RegisterAttributeDriver` for a driver that
could contain `[mod:]`.** The input layer controller owns every modifier condition: the engine
resolves `[mod:]` against modifiers physically held and cannot see a latched or doubled layer.
Route through the controller; it classifies the driver and hands native-only conditions back
to the engine:

```lua
db.Layers:RegisterAttributeDriver(frame, 'alpha', driver)
db.Layers:UnregisterAttributeDriver(frame, 'alpha')
```

Drivers built only from native conditions (`[vehicleui]`, `[combat]`, `[group]`) may use the
global functions. Macro condition vocabulary: `ConsolePort/Utils/Macro.lua` (`CPAPI.ConvertDriver`,
`ParseDriver`, `MapDriver`, `ClassifyDriver`, `IsModSubset`).

**Nothing outside the controller writes an override binding.** Engine keeps one binding per key
per tier, newest writer wins, so two frames on one key fight over recency. Controller holds every
claim and writes the engine. Claimant names itself and a level; highest level holds the key,
newest on tie; release surfaces the next claim:

```lua
-- insecure
db.Layers:Claim(frame, 'NAV', key, 'click', target, mouseButton)
db.Layers:Claim(frame, 'OVERRIDE', key, 'binding', action)
db.Layers:Release(frame, key)
db.Layers:ReleaseAll(frame)

-- restricted, with layers = self:GetFrameRef('Layers')
layers::Claim(OWNER, 'MODAL', key, 'click', OWNER, button)
layers::ReleaseAll(OWNER)
```

| Level | Holds | Engine tier |
|---|---|---|
| `BASE` | the controller's own binding row | low |
| `OVERRIDE` | conditional replacements of the row: interact, unit menu triggers | low |
| `NAV` | cursors: raid, secure, interface | priority |
| `MODAL` | rings, menus, unit hotkeys, quick menu | priority |

Owners and click targets are frame names: frame handles do not survive `RunAttribute`.

---

## 1. Project Architecture

Suite of addons sharing one core. Each sub-addon has its own `.toc`.

| Addon | Loads | Purpose |
|---|---|---|
| `ConsolePort` | Always | Core: API, database, input, controller, widget library |
| `ConsolePort_Bar` | Always | Action bar replacement |
| `ConsolePort_Config` | On Demand (LOD) | Settings UI |
| `ConsolePort_Cursor` | On Demand (LOD) | Interface cursor for gamepad navigation |
| `ConsolePort_Keyboard` | On Demand (LOD) | Virtual keyboard |
| `ConsolePort_Menu` | Always | Game menu replacement |
| `ConsolePort_Rings` | Always | Ring menus / utility rings |
| `ConsolePort_World` | Always | World interaction features |

Three globals:

- **`ConsolePort`** — public API frame, `ConsolePort/API.lua`. External addons call e.g. `ConsolePort:GetBindings()`.
- **`db`** — internal database (`RelaTable`). Every file: `local _, db = ...;`. Path get/set, event callbacks, table utils, subsystem registration.
- **`CPAPI`** — global utility table, available before any addon file loads: `CreateEventHandler`, `LinkEnv`, `Popup`, `Prop`, `Bool`, etc.

Sub-addon layout, loose Model–Controller–View plus optional `Widget/` and `Assets/`:

```
ConsolePort_Bar/
├── Model/          # Data types, database registration, interface definitions
├── Controller/     # Logic, state management, Blizzard hooks
├── View/           # UI frames, layout, display
├── Widget/         # Reusable widget components
└── Assets/         # Textures, atlases
```

Core load order, `ConsolePort.toc`:

```
Libs → XML → API.lua → Utils → Model → Controller → Widget → View
```

Sub-addons list files top-to-bottom in `.toc`. Core directories each declare order in `__manifest.xml`.

---

## 2. File Organization

Core manifests:

```xml
<Ui>
    <Script file="Database.lua"/>
    <Script file="Utils.lua"/>
    <Script file="Const.lua"/>
    <Include file="SubDir/__manifest.xml"/>
</Ui>
```

Sub-addons list files in `.toc`, with nested `.xml` per component directory (e.g. `Widget/Bar/Bar.xml`).

Naming: **PascalCase** files and directories (`Database.lua`, `Templates.xml`, `Controller/`). Locale files by code (`enUS.lua`, `zhCN.lua`). Manifests `__manifest.xml`. Sub-addon directory = TOC name (`ConsolePort_Bar/`).

Preamble, every Lua file:

```lua
local _, db = ...;
```

Or with CPAPI:
```lua
local CPAPI, _, db = CPAPI, ...;
```

Then upvalue caching:
```lua
local getmetatable, setmetatable = getmetatable, setmetatable;
local CreateFrame, Mixin = CreateFrame, Mixin;
```

---

## 3. Naming Conventions

| Context | Convention | Examples |
|---|---|---|
| Local variables | `camelCase` | `activeDevice`, `classColor`, `freeSlots` |
| Local refs to classes/handlers | `PascalCase` | `local Cursor`, `local HotkeyHandler` |
| Constants | `UPPER_SNAKE_CASE` | `MOUSEOVER_THROTTLE`, `LCLICK_BINDING` |
| Hex constants | Hex literals | `0x0`, `0x1`, `0x2` |
| Methods on objects/mixins | `PascalCase` | `SetIcon`, `OnDataLoaded`, `GetBindings` |
| CPAPI functions | `CPAPI.PascalCase` | `CPAPI.CreateEventHandler`, `CPAPI.LinkEnv` |
| WoW event handlers | Match event name | `function Handler:UPDATE_BINDINGS()` |
| Private helpers | `camelCase` / `local function` | `local function clearLockedState()` |
| Global frames | `ConsolePort` prefix | `ConsolePortCursor`, `ConsolePortMenu` |
| Child frames | `$parent` prefix | `$parentHotkeyHandler` |
| Templates | `CP<Name>Template` | `CPFrameTemplate`, `CPUnitHotkeyTemplate` |
| Widget/UI mixins | `CP<Name>Mixin` | `CPGradientMixin`, `CPIndexPoolMixin` |
| Concrete implementations | `CP<Name>` | `CPActionButton` |
| API-level mixins | `CPAPI.<Name>Mixin` | `CPAPI.EventMixin`, `CPAPI.SecureExportMixin` |
| Settings variable IDs | `camelCase`, domain prefix | `UIenableCursor`, `gameMenuScale`, `ringScale`, `keyboardEnable` |

---

## 4. Formatting & Style

**Tabs** indent. Spaces only for alignment after tabs. Related declarations align:

```lua
local MOUSEOVER_THROTTLE = 0.1;
local LCLICK_BINDING     = db.Gamepad.Mouse.Binding.LeftClick;
local RCLICK_BINDING     = db.Gamepad.Mouse.Binding.RightClick;
```

```lua
CPAPI.IsClassicEraVersion = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or nil;
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC or nil;
CPAPI.IsRetailVersion     = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or nil;
```

**Semicolons** are paragraph markers, ending a logical stanza, not every statement:

```lua
-- Semicolons USED:
self.timeLock = true;                  -- end of a logical assignment block
self.showAfterCombat = nil;            -- end of cleanup step
return false;                          -- emphasized returns
if not SpellFlyout then return end;    -- guard clause at file top
```

```lua
-- Semicolons NOT used:
widget:Hide()                          -- standalone method calls
widget:SetAttribute('owner', owner)    -- chained setup calls
db:Register('Input', InputAPI)         -- registration calls
```

Inside table constructors, semicolons separate fields:

```lua
{hide = true; Data.String('Divider')};
{point = 'BOTTOM'; relPoint = 'BOTTOM'; y = 16;};
```

```lua
env.Toplevel = {
    Art     = false;
    Cluster = false;
    Divider = false;
    Group   = false;
};
```

**Conditionals**: parentheses with inner spaces for emphasis; simple conditions may omit:

```lua
if ( type(predicate) == 'number' ) then
if ( widget and widget:GetAttribute('owner') == owner ) then
if ( old == value ) then return end;
```

```lua
if not widget then return false; end
if self[callback] then
```

**Whitespace**: spaces around binary operators (`=`, `==`, `~=`, `+`, `..`, `and`, `or`); none inside call parentheses `SetSize(64, 64)`; spaces inside conditional parentheses `( expr )`.

**Comments**: section headers exactly 63 dashes; informal `@param` / `@return`; short trailing inline comments; `---@class` occasional, not systematic.

```lua
---------------------------------------------------------------
-- Section Title
---------------------------------------------------------------
```

```lua
---------------------------------------------------------------
-- @brief Get the button bound to a given binding ID
-- @param bindingID: binding ID (string)
-- @return key: button ID (string)
-- @return mod: modifier (string)
```

```lua
'PLAYER_REGEN_DISABLED'; -- enter combat
'PLAYER_REGEN_ENABLED';  -- leave combat
```

---

## 5. The `db` Object & Data Access

`__call` path traversal via RelaTable:

```lua
db('Settings/useCharacterSettings')           -- getter (explicit path)
db('Settings/useCharacterSettings', true)      -- setter (2 args = set)
db('Actionbar/Action/'..index)                 -- dynamic path traversal
```

**Settings shorthand `db('varName')`**, no path prefix, is the idiomatic read:

```lua
local delay = db('UIleaveCombatDelay')          -- returns user setting or default
if db('mouseHandlingEnabled') then              -- boolean setting check
header:SetScale(db('radialScale'))              -- numeric setting
local color = db('radialNormalColor')           -- string setting
```

Single key without `/`: `Database:Get` reads `db['varName']`, finds nil, falls back to `db:GetDefault('varName')`, which reads `db.default`, a `CPAPI.Proxy` chain:

```
CharacterSettings → GlobalSettings → Defaults
```

Per-character override, else global saved setting, else registered default from `Data.Bool(true)` / `Data.Range(1.0, ...)` via `Field:Get()`.

Always read with `db('varName')`, never `db.Settings.varName`. Full path form is for writes:

```lua
-- GETTER: shorthand (reads through proxy chain with defaults)
local enabled = db('UIenableCursor')

-- SETTER: full path (writes to the active settings source)
db('Settings/UIenableCursor', true)
```

**Subsystem registration** makes handlers reachable by path (`db.Hotkeys`, `db.Stack`, `db.Input`):

```lua
db:Register('Hotkeys', HotkeyHandler)
db:Register('Stack', StackHandler)
db:Register('Input', InputAPI)
```

**`db.table`**: `copy(t)` shallow copy · `merge(dst, src)` deep merge · `spairs(t, comp)` sorted pairs · `mpairs(t)` modifier-ordered pairs · `mixin(obj, ...)` mixin with script hooking · `ripairs(t)` reverse ipairs · `map(t, fn)` map.

**Sub-addon bootstrap**:

```lua
local _, Data, env, db, name = CPAPI.LinkEnv(...);
```

`_` = `CPAPI.Define` (section header or settings wrapper) · `Data` = field type factories · `env` = scoped env with `env.db` and `env.L` · `db` = global database · `name` = addon name.

---

## 6. Event System

**Layer 1, WoW events** via `EventMixin`; auto-dispatches to same-named methods on `self`:

```lua
local Handler = CPAPI.CreateEventHandler({'Frame', '$parentName', parent}, {
    'UPDATE_BINDINGS';
    'MODIFIER_STATE_CHANGED';
})

function Handler:UPDATE_BINDINGS()
    -- self-dispatched from EventMixin.OnEvent
end
```

**Layer 2, DB callbacks**, path-based via RelaTable:

```lua
-- Register
db:RegisterCallback('Settings/UIscale', self.SetScale, self)
db:RegisterCallback('OnNewBindings', handler.OnDataLoaded, handler)

-- Register multiple events to one callback
db:RegisterCallbacks(handler.OnDataLoaded, handler,
    'OnDataLoaded',
    'Settings/cursorSetting',
)

-- Safe callbacks (queued during combat, fired on PLAYER_REGEN_ENABLED)
db:RegisterSafeCallback('Settings/interactButton', handler.OnDataLoaded, handler)

-- Trigger
db:TriggerEvent('OnDataLoaded')
db:TriggerEvent('Settings/'..varID, db(varID))

-- Unregister
db:UnregisterCallback('OnNewBindings', self)
```

**Layer 3, local env events**, scoped to the sub-addon `env`:

```lua
LibStub('RelaTable')(name, env);
env:TriggerEvent('OnButtonFocus', self, true)
```

Common events: `OnDataLoaded` settings ready · `OnVariablesChanged` · `OnNewBindings` · `OnIconsChanged` · `Settings/<varName>` per-variable change · `Gamepad/Active` device changed.

**OnDataLoaded**: handlers needing settings implement it. Return `CPAPI.BurnAfterReading` for one-time init, `CPAPI.KeepMeForLater` to persist:

```lua
function DataAPI:OnDataLoaded()
    -- one-time initialization
    return CPAPI.BurnAfterReading;
end
```

---

## 7. Mixin & OOP Patterns

Global mixins are plain tables with methods added:

```lua
CPActionButtonMixin = {}

function CPActionButtonMixin:SetIcon(file)
    self.Icon:SetTexture(file)
end

function CPActionButtonMixin:OnLoad()
    -- initialization
end
```

Composition:

```lua
-- Blizzard's CreateFromMixins for inheritance
CPFocusPoolMixin = CreateFromMixins(CPIndexPoolMixin);

-- Blizzard's Mixin for application
Mixin(frame, CPActionButtonMixin)

-- CPAPI.Specialize for frame specialization
CPAPI.Specialize(frame, CPActionButtonMixin)

-- db.table.mixin for script-aware application
db.table.mixin(widget, InputMixin)  -- also hooks OnClick, OnEnter, etc.
```

Frame-based event handler (most common):

```lua
local Handler = CPAPI.CreateEventHandler({'Frame', '$parentName', parent}, {
    'EVENT_1';
    'EVENT_2';
})
db:Register('Handler', Handler)
```

Data-only handler (no frame, just `OnDataLoaded`):

```lua
local Handler = CPAPI.DataHandler({})
db:Register('Handler', Handler)
```

Property generation:

```lua
CPAPI.Prop(owner, 'Scale', 1.0)   -- creates owner:GetScale() / owner:SetScale(v)
CPAPI.Bool(owner, 'Enabled', true) -- creates owner:IsEnabled() / owner:SetEnabled(v)
```

Callable tables (`__call`) for factories:

```lua
db:Register('Nav', setmetatable(CreateFromMixins(CPAPI.SecureEnvironmentMixin, {
    Env = { ... }
}), {
    __call = function(self, obj)
        Mixin(obj, self)
        obj:Execute([[ ... ]])
        return obj;
    end;
}))
```

---

## 8. Variable / Settings Definitions

Each sub-addon registers settings in `Database.lua`:

```lua
local _, Data, env = CPAPI.LinkEnv(...)

ConsolePort:AddVariables({
    -- Section header
    _('Section Name', HEADER_GLOBAL, sortIndex);

    -- Boolean setting
    variableName = _{Data.Bool(true);
        name = 'Display Name';
        desc = 'Description of what this does.';
    };

    -- Range setting with dependencies
    someRange = _{Data.Range(1.0, 0.05, 0.5, 2.0);
        name = 'Scale';
        desc = 'Adjust the scale.';
        deps = { parentSetting = true };  -- only shown when parentSetting is true
        advd = true;                       -- advanced option
    };
})
```

| Factory | Creates | Parameters |
|---|---|---|
| `Data.Bool(default)` | Boolean toggle | `default` |
| `Data.Number(default, step, signed)` | Numeric input | `default`, `step`, `signed` |
| `Data.Range(default, step, min, max)` | Clamped slider | `default`, `step`, `min`, `max` |
| `Data.Button(default)` | Gamepad button picker | `default` binding |
| `Data.Color(r, g, b, a)` | Color picker | RGBA values |
| `Data.Select(default, ...)` | Dropdown select | `default`, `...options` |
| `Data.Map(default, opts)` | Key-value select | `default`, `options table` |
| `Data.String(default)` | Text input | `default` |
| `Data.Table(default)` | Nested table | `default table` |
| `Data.Interface(default)` | Complex UI data | `default table` |
| `Data.Mutable(type, values)` | Dynamic key-value | `type factory`, `values` |
| `Data.Point(default)` | Anchor point | `{ point, relPoint, x, y }` |

Metadata keys: `name` display name · `desc` description · `note` extra note · `deps` `{ otherVar = expectedValue }` · `advd` advanced flag · `hide` hidden flag · `list` grouping label.

---

## 9. Secure Environment Code

Secure bodies live in an `Env` table, injected via `CreateEnvironment`:

```lua
Handler.Env = {
    _onshow = [[ self::ApplyBindings() ]];
    _onhide = [[ self:ClearBindings() ]];
    RefreshBindings = [[
        local bindings = self:GetAttribute('bindings')
        -- restricted environment Lua
    ]];
};

Handler:CreateEnvironment()
```

- Secure bodies: `[[ ]]` only.
- `self::FunctionName()` = custom dispatch, calls `self:RunAttribute("FunctionName", ...)`.
- Constants injected via `:format()` or `:gsub()`:

```lua
ClearAndHide = ([[
    self:SetAttribute(%q, nil)
]]):format(CPAPI.ActionTypeRelease);
```

- Sub-header before each secure body:

```lua
    -----------------------------------------------------------
    -- @param node : current node in iteration
    FilterNode = [[
        if self::IsDrawn(node:GetRect()) then
            CACHE[node] = true;
        end
    ]];
```

`do...end` blocks scope helpers that support secure handlers:

```lua
do  local HasScript, GetScript = Scan.HasScript, Scan.GetScript;
    local Scrub, GetRaw = CPAPI.Scrub, rawget;

    local function IsUnitButton(frame) ... end
    function GetUnitForFrame(frame) ... end
end
```

---

## 10. Error Handling

`assert` for programmer errors, with message:

```lua
assert(not self.ObjectPool, 'Frame pool already exists.')
assert(not InCombatLockdown())
assert(direction == 'VERTICAL' or direction == 'HORIZONTAL', 'Valid: VERTICAL, HORIZONTAL')
assert(activeDevice, ('Device %s does not exist in registry.'):format(name or '<nil>'))
```

`pcall` where failure is expected (Blizzard API inconsistencies):

```lua
local isEventValid = pcall(tester.RegisterEvent, tester, event)
if (pcall(self.SetLight, self, enabled, lightValues)) then
EventUtil.ContinueOnAddOnLoaded(addOn, GenerateClosure(pcall, script))
```

`error()` for data integrity violations:

```lua
error('Malformed table: field "'..child..'" does not exist in definition.')
```

Combat lockdown: `db:RegisterSafeCallback` queues during combat, runs on `PLAYER_REGEN_ENABLED`:

```lua
-- Automatically queued during combat, executed on PLAYER_REGEN_ENABLED
db:RegisterSafeCallback('Settings/interactButton', handler.OnDataLoaded, handler)
```

---

## 11. Idioms & Patterns

Ternary via `and`/`or`:

```lua
local delay = db('UIleaveCombatDelay') * (UnitIsDead('player') and 2 or 1)
icon:SetDesaturated(not file and true or false)
```

```lua
script =
    ((down == true)  and 'OnMouseDown') or
    ((down == false) and 'OnMouseUp');
```

`GenerateClosure` over inline closures for partial application:

```lua
GenerateClosure(InputProxy, 'PADDUP')
GenerateClosure(SpellMenu.Hide, SpellMenu)
GenerateClosure(pcall, script)
GenerateClosure(ColorMixin.WrapTextInColorCode, BLUE_FONT_COLOR)
```

Upvalue caching at file top:

```lua
local CreateFrame, Mixin = CreateFrame, Mixin;
local getmetatable, setmetatable = getmetatable, setmetatable;
local InCombatLockdown = InCombatLockdown;
```

Guard clause for optional APIs:

```lua
if not SpellFlyout then return end;
```

Deferred execution:

```lua
C_Timer.After(delay, function()
    self.onEnableCallback()
    self.showAfterCombat = nil;
end)
```

Strings: `:format()` for parameters `('CP-Input-%s'):format(id)` · `..` for simple concat `'Settings/'..varID` · `[[ ]]` only for secure bodies and backslash paths.

Version-conditional detection:

```lua
-- Guard clause for missing API
if not SpellFlyout then return end;

-- Feature detection
if C_Container and C_Container.GetContainerItemInfo then
    return C_Container.GetContainerItemInfo(...) or {};
end

-- Conditional inclusion via nil trick
CPAPI.IsRetailVersion = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or nil;
```

`or nil` yields `nil`, never `false`, so dynamic table insertion skips the entry.

---

## 12. Localization

Strings in `ConsolePort/Locale/enUS.lua` (fallback), per-locale overrides. Locale object: `db.Locale` or `env.L`:

```lua
-- In locale definition files (enUS.lua, zhCN.lua, etc.)
local L = select(2, ...).Locale;

L.DESC_TOGGLE_BINDINGS   = 'Toggle the binding display.';
L.NAME_TOGGLE_BINDINGS   = 'Toggle Bindings';
L.FORMAT_BINDING_CURRENT = '%s is currently bound to %s.';
```

Keys: `L.DESC_*` descriptions · `L.NAME_*` display names · `L.FORMAT_*` format strings · `L.DISC_*` disclaimers.

**Locale literal `L'text'`**:

```lua
self:AddCommand(L'Place on action bar', 'MapActionBar')
self:AddCommand(L'Pick up', 'Pickup')
self:AddCommand(L'Sell', 'Sell')
self:AddCommand(L'Split stack' .. countText, 'Split')
description = L'Select a slot to place this spell.';
handle:AddHint(leftClick, L'Place in slot')
handle:AddHint(rightClick, keyChord and L'Cancel and clear cursor' or L'Clear slot or binding')
```

`L` has `__call` and `__index`. `L'text'` = `L('text')`: looks up `self['text']`; translated string if a locale file defined it, else `__index` returns the key itself, so English passes through. Supports `:format(...)` via `L('Format string %s', arg)` and nested `L[inner]` refs inside format strings.

Rules: wrap every user-facing literal in `L'...'`. English text is the key. `L'literal'` for plain strings; `L('format %s', arg)` only with format args.

```lua
-- Simple literal (preferred for plain text)
L'Place on action bar'

-- With format arguments (use parentheses)
L('Format string %s', arg)

-- In CPAPI.Log (formatted output)
CPAPI.Log(...)  -- calls db.Locale(...)

-- Direct key access (in locale definition files)
local text = env.L.NAME_TOGGLE_BINDINGS;
```

---

## 13. XML Templates

`CP<Purpose>Template` for virtual templates (`CPFrameTemplate`); `CP<Purpose>` for single-use types (`CPAtlas`).

```xml
<Frame name="CPFrameTemplate" virtual="true" mixin="CPFrameMixin">
    <KeyValues>
        <KeyValue key="layoutAtlas" value="glues-gamemode-bg" type="string"/>
        <KeyValue key="layoutScale" value="0.5" type="number"/>
    </KeyValues>
    <Scripts>
        <OnLoad method="OnLoad"/>
    </Scripts>
</Frame>
```

All templates `virtual="true"` · `mixin="..."` binds the Lua mixin · `KeyValues` declarative defaults · `parentKey` / `parentArray` child-to-parent attachment · `inherit="prepend"` on `OnLoad` when mixin runs before children · inheritance chains base → extension → specialization.

---

## 14. Multi-Version Support

```lua
CPAPI.IsRetailVersion     = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or nil;
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC or nil;
CPAPI.IsClassicEraVersion = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or nil;
```

`true` or `nil`, never `false`, for conditional table construction. CPAPI wrappers abstract version APIs:

```lua
function CPAPI.GetSpecialization()
    if GetSpecialization then  -- retail
        local spec = GetSpecialization()
        if spec then return GetSpecializationInfo(spec) end
    end
    return GetClassID()  -- classic fallback
end
```

```lua
hide = CPAPI.IsRetailVersion;  -- hide on retail, show on classic
note = CPAPI.IsRetailVersion and 'Only available in Classic.';
```
