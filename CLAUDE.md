# ConsolePort Coding Standards

> Reference document for AI agents and contributors working on the ConsolePort addon suite.
> ConsolePort is a World of Warcraft gamepad addon written in Lua/XML against the WoW API.

---

## Table of Contents

1. [Project Architecture](#1-project-architecture)
2. [File Organization](#2-file-organization)
3. [Naming Conventions](#3-naming-conventions)
4. [Formatting & Style](#4-formatting--style)
5. [The `db` Object & Data Access](#5-the-db-object--data-access)
6. [Event System](#6-event-system)
7. [Mixin & OOP Patterns](#7-mixin--oop-patterns)
8. [Variable / Settings Definitions](#8-variable--settings-definitions)
9. [Secure Environment Code](#9-secure-environment-code)
10. [Error Handling](#10-error-handling)
11. [Idioms & Patterns](#11-idioms--patterns)
12. [Localization](#12-localization)
13. [XML Templates](#13-xml-templates)
14. [Multi-Version Support](#14-multi-version-support)

---

## 1. Project Architecture

### Addon Suite Structure

ConsolePort is a **suite of addons** sharing a single core. Each sub-addon is a separate WoW addon with its own `.toc` file.

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

### Three Global Entry Points

All code communicates through three globals:

- **`ConsolePort`** — The public API frame. External addons call methods on this object (e.g. `ConsolePort:GetBindings()`). Defined in `ConsolePort/API.lua`.
- **`db`** — The internal database (a `RelaTable` instance). Accessed in every file via `local _, db = ...;`. Provides path-based get/set, event callbacks, table utilities, and subsystem registration.
- **`CPAPI`** — Global utility table of functions, mixins, and constants. Available before any addon file loads. Contains helpers like `CreateEventHandler`, `LinkEnv`, `Popup`, `Prop`, `Bool`, etc.

### MVC-ish Sub-Addon Layout

Each sub-addon follows a loose Model–Controller–View structure, plus optional `Widget/` and `Assets/` directories:

```
ConsolePort_Bar/
├── Model/          # Data types, database registration, interface definitions
├── Controller/     # Logic, state management, Blizzard hooks
├── View/           # UI frames, layout, display
├── Widget/         # Reusable widget components
└── Assets/         # Textures, atlases
```

### Core Addon Load Order

Defined in `ConsolePort.toc` — order matters:

```
Libs → XML → API.lua → Utils → Model → Controller → Widget → View
```

Sub-addon internal order is declared directly in the `.toc` file (files listed top-to-bottom). Within the core addon, each directory uses a `__manifest.xml` to declare its own load order.

---

## 2. File Organization

### Manifests

The core addon uses `__manifest.xml` files (double-underscore prefix) in each directory to declare load order:

```xml
<Ui>
    <Script file="Database.lua"/>
    <Script file="Utils.lua"/>
    <Script file="Const.lua"/>
    <Include file="SubDir/__manifest.xml"/>
</Ui>
```

Sub-addons list files directly in their `.toc`, sometimes with nested `.xml` files for component subdirectories (e.g. `Widget/Button/Button.xml`).

### File Naming

- **PascalCase** for Lua and XML files: `Database.lua`, `Button.lua`, `Templates.xml`
- **PascalCase** for directories: `Controller/`, `Model/`, `View/`, `Widget/`
- **Locale files** use locale codes: `enUS.lua`, `zhCN.lua`
- **Manifest files** use `__manifest.xml` (double underscore)
- **Sub-addon directories** match their TOC name: `ConsolePort_Bar/`, `ConsolePort_Cursor/`

### File Preamble

Every Lua file begins by destructuring the addon varargs:

```lua
local _, db = ...;
```

Or with CPAPI:
```lua
local CPAPI, _, db = CPAPI, ...;
```

Frequently followed by upvalue caching of globals:
```lua
local getmetatable, setmetatable = getmetatable, setmetatable;
local CreateFrame, Mixin = CreateFrame, Mixin;
```

---

## 3. Naming Conventions

### Variables

| Context | Convention | Examples |
|---|---|---|
| Local variables | `camelCase` | `activeDevice`, `classColor`, `totalFree`, `freeSlots` |
| Local references to classes/handlers | `PascalCase` | `local Cursor`, `local HotkeyHandler`, `local PowerLevel` |
| Constants | `UPPER_SNAKE_CASE` | `MOUSEOVER_THROTTLE`, `LCLICK_BINDING` |
| Hex constants | Hex literals | `0x0`, `0x1`, `0x2` |

### Functions

| Context | Convention | Examples |
|---|---|---|
| Methods on objects/mixins | `PascalCase` | `SetIcon`, `OnDataLoaded`, `GetBindings` |
| CPAPI functions | `CPAPI.PascalCase` | `CPAPI.CreateEventHandler`, `CPAPI.LinkEnv` |
| WoW event handlers | Match event name | `function Handler:UPDATE_BINDINGS()` |
| Private/internal helpers | `camelCase` or `local function` | `local function clearLockedState()` |

### Frames

| Context | Convention | Examples |
|---|---|---|
| Global frames | `ConsolePort` prefix | `ConsolePortCursor`, `ConsolePortMenu` |
| Child frames | `$parent` prefix | `$parentHotkeyHandler`, `$parentDataHandler` |
| Templates | `CP<Name>Template` | `CPFrameTemplate`, `CPUnitHotkeyTemplate` |

### Mixins

| Context | Convention | Examples |
|---|---|---|
| Widget/UI mixins | `CP<Name>Mixin` | `CPGradientMixin`, `CPButtonCatcherMixin`, `CPIndexPoolMixin` |
| Concrete implementations | `CP<Name>` (no Mixin suffix) | `CPActionButton` |
| API-level mixins | `CPAPI.<Name>Mixin` | `CPAPI.EventMixin`, `CPAPI.SecureExportMixin` |

### Settings Variable IDs

`camelCase` identifiers, often domain-prefixed:

- `UIpointerAnimation`, `UIenableCursor`, `UIleaveCombatDelay` — Cursor module
- `gameMenuScale`, `gameMenuShowMenu` — Menu module
- `ringAutoExtra`, `ringScale` — Rings module
- `keyboardScale`, `keyboardEnable` — Keyboard module

---

## 4. Formatting & Style

### Indentation

**Tabs** for indentation. Spaces only for alignment after tabs (e.g. aligning `=` signs across multiple declarations).

### Aligned Assignments

Multiple related declarations are visually aligned:

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

### Semicolons

Semicolons are used **selectively**, not after every statement. They serve as **paragraph markers** — signaling the end of a logical stanza:

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

**Inside table constructors**, semicolons are used as field separators (instead of commas) for inline table literals:

```lua
{hide = true; Data.String('Divider')};
{point = 'BOTTOM'; relPoint = 'BOTTOM'; y = 16;};
```

Multiline table fields also use trailing semicolons:

```lua
env.Toplevel = {
    Art     = false;
    Cluster = false;
    Divider = false;
    Group   = false;
};
```

### Parentheses in Conditionals

Conditions often use parentheses with **inner spaces** for emphasis:

```lua
if ( type(predicate) == 'number' ) then
if ( widget and widget:GetAttribute('owner') == owner ) then
if ( old == value ) then return end;
```

Simple conditions may omit them:

```lua
if not widget then return false; end
if self[callback] then
```

### Whitespace

- Spaces around binary operators: `=`, `==`, `~=`, `+`, `-`, `*`, `/`, `..`, `and`, `or`
- No spaces inside function call parentheses: `SetSize(64, 64)`
- Spaces inside conditional parentheses: `( expr )`

### Comments

**Section headers** use exactly 63 dashes:

```lua
---------------------------------------------------------------
-- Section Title
---------------------------------------------------------------
```

**Function documentation** uses informal `@param` / `@return` inside block comments:

```lua
---------------------------------------------------------------
-- @brief Get the button bound to a given binding ID
-- @param bindingID: binding ID (string)
-- @return key: button ID (string)
-- @return mod: modifier (string)
```

**Inline comments** are short, trailing:

```lua
'PLAYER_REGEN_DISABLED'; -- enter combat
'PLAYER_REGEN_ENABLED';  -- leave combat
```

**Lua annotations** are minimal — occasional `---@class` for type hinting, but not systematic.

---

## 5. The `db` Object & Data Access

### Path-Based Access

The database uses `__call` metamethod for path traversal (via RelaTable):

```lua
db('Settings/useCharacterSettings')           -- getter (explicit path)
db('Settings/useCharacterSettings', true)      -- setter (2 args = set)
db('Actionbar/Action/'..index)                 -- dynamic path traversal
```

### Settings Shorthand: `db('varName')`

The most common usage is `db('varName')` **without** a path prefix. This is a shorthand getter for settings:

```lua
local delay = db('UIleaveCombatDelay')          -- returns user setting or default
if db('mouseHandlingEnabled') then              -- boolean setting check
header:SetScale(db('radialScale'))              -- numeric setting
local color = db('radialNormalColor')           -- string setting
```

**How it works:** When `db('varName')` is called with a single key (no `/` path separator), `Database:Get` looks up `db['varName']` directly. Since settings aren't stored as top-level keys on `db`, this returns `nil`, which triggers the fallback to `db:GetDefault('varName')`. The `GetDefault` method reads from `db.default`, which is set to a proxy chain:

```
CharacterSettings → GlobalSettings → Defaults
```

This chain (built with `CPAPI.Proxy`) means:
1. If the user has a **per-character override**, that's returned
2. Otherwise, if there's a **global saved setting**, that's returned
3. Otherwise, the **registered default** from `Data.Bool(true)` / `Data.Range(1.0, ...)` etc. is returned (via `Field:Get()`)

**The shorthand is idiomatic and preferred** — always use `db('varName')` to read settings, never manually traverse `db.Settings.varName`. The full path form `db('Settings/varName')` is reserved for **writes** (setters):

```lua
-- GETTER: shorthand (reads through proxy chain with defaults)
local enabled = db('UIenableCursor')

-- SETTER: full path (writes to the active settings source)
db('Settings/UIenableCursor', true)
```

### Subsystem Registration

Handlers register themselves on `db` to become accessible by path:

```lua
db:Register('Hotkeys', HotkeyHandler)
db:Register('Stack', StackHandler)
db:Register('Input', InputAPI)
```

After registration, they're accessible as `db.Hotkeys`, `db.Stack`, `db.Input`.

### Table Utilities

`db.table` provides extended table operations:

- `db.table.copy(t)` — shallow copy
- `db.table.merge(dst, src)` — deep merge
- `db.table.spairs(t, comp)` — sorted pairs
- `db.table.mpairs(t)` — modifier-ordered pairs
- `db.table.mixin(obj, ...)` — mixin with script hooking
- `db.table.ripairs(t)` — reverse ipairs
- `db.table.map(t, fn)` — map transform

### Sub-Addon Database Bootstrapping

Sub-addons use `CPAPI.LinkEnv(...)` to get their environment:

```lua
local _, Data, env, db, name = CPAPI.LinkEnv(...);
```

This provides:
- `_` — the `CPAPI.Define` function (dual-purpose: section header or settings wrapper)
- `Data` — the field type factories (`Data.Bool`, `Data.Range`, etc.)
- `env` — scoped environment table with `env.db` and `env.L`
- `db` — the global database reference
- `name` — addon name string

---

## 6. Event System

### Three Layers

**Layer 1 — WoW Events:** Standard frame event registration via `EventMixin`:

```lua
local Handler = CPAPI.CreateEventHandler({'Frame', '$parentName', parent}, {
    'UPDATE_BINDINGS';
    'MODIFIER_STATE_CHANGED';
})

function Handler:UPDATE_BINDINGS()
    -- self-dispatched from EventMixin.OnEvent
end
```

`EventMixin` auto-dispatches events to same-named methods on `self`.

**Layer 2 — DB Callbacks:** Path-based custom events via RelaTable:

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

**Layer 3 — Local Environment Events:** Sub-addons scope events to their `env`:

```lua
LibStub('RelaTable')(name, env, false);  -- false = don't hook EventRegistry
env:TriggerEvent('OnButtonFocus', self, true)
```

### Common Event Names

- `OnDataLoaded` — settings ready
- `OnVariablesChanged` — variables table modified
- `OnNewBindings` — gamepad bindings updated
- `OnIconsChanged` — icon style changed
- `Settings/<varName>` — automatic per-variable change events
- `Gamepad/Active` — active device changed

### OnDataLoaded Convention

Handlers that need settings implement `OnDataLoaded`. Return `CPAPI.BurnAfterReading` to self-destruct (one-time init):

```lua
function DataAPI:OnDataLoaded()
    -- one-time initialization
    return CPAPI.BurnAfterReading;
end
```

Return `CPAPI.KeepMeForLater` when the handler should persist for re-invocation.

---

## 7. Mixin & OOP Patterns

### Mixin Definition

Global mixins are defined as plain tables, then methods are added:

```lua
CPActionButtonMixin = {}

function CPActionButtonMixin:SetIcon(file)
    self.Icon:SetTexture(file)
end

function CPActionButtonMixin:OnLoad()
    -- initialization
end
```

### Mixin Composition

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

### Event Handler Creation

**Frame-based event handler** (most common):

```lua
local Handler = CPAPI.CreateEventHandler({'Frame', '$parentName', parent}, {
    'EVENT_1';
    'EVENT_2';
})
db:Register('Handler', Handler)
```

**Data-only handler** (no frame, just `OnDataLoaded`):

```lua
local Handler = CPAPI.CreateDataHandler()
db:Register('Handler', Handler)
```

### Property Auto-Generation

```lua
CPAPI.Prop(owner, 'Scale', 1.0)   -- creates owner:GetScale() / owner:SetScale(v)
CPAPI.Bool(owner, 'Enabled', true) -- creates owner:IsEnabled() / owner:SetEnabled(v)
```

### Callable Tables

Tables with `__call` metamethods are used for factory patterns:

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

### Declaration Pattern

Each sub-addon registers its settings in `Database.lua`:

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

### Field Types

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

### Variable Metadata

| Key | Type | Purpose |
|---|---|---|
| `name` | string | Display name in config UI |
| `desc` | string | Description text |
| `note` | string | Additional notes |
| `deps` | table | Dependency conditions (`{ otherVar = expectedValue }`) |
| `advd` | bool | Advanced option flag |
| `hide` | bool | Hidden option flag |
| `list` | string | Grouping label |

---

## 9. Secure Environment Code

### Overview

WoW's secure/restricted environment requires special handling. ConsolePort uses a pattern where secure body strings are stored in an `Env` table and injected via `CreateEnvironment`:

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

### Conventions

- Secure bodies use `[[ ]]` multiline strings exclusively
- The `self::FunctionName()` syntax is a custom dispatch convention (calls `self:RunAttribute("FunctionName", ...)`)
- Constants are injected via `:format()` or `:gsub()`:

```lua
ClearAndHide = ([[
    self:SetAttribute(%q, nil)
]]):format(CPAPI.ActionTypeRelease);
```

- Sub-headers precede each secure body definition:

```lua
    -----------------------------------------------------------
    -- @param node : current node in iteration
    FilterNode = [[
        if self::IsDrawn(node:GetRect()) then
            CACHE[node] = true;
        end
    ]];
```

### Scoped Blocks for Helpers

Use `do...end` blocks to create lexical scopes for local variables and helper functions that support secure handlers:

```lua
do  local HasScript, GetScript = Scan.HasScript, Scan.GetScript;
    local Scrub, GetRaw = CPAPI.Scrub, rawget;

    local function IsUnitButton(frame) ... end
    function GetUnitForFrame(frame) ... end
end
```

---

## 10. Error Handling

### `assert` — Precondition Validation

Used with descriptive messages for programmer errors:

```lua
assert(not self.ObjectPool, 'Frame pool already exists.')
assert(not InCombatLockdown())
assert(direction == 'VERTICAL' or direction == 'HORIZONTAL', 'Valid: VERTICAL, HORIZONTAL')
assert(activeDevice, ('Device %s does not exist in registry.'):format(name or '<nil>'))
```

### `pcall` — Recoverable Failures

Used where failure is expected (e.g. Blizzard API inconsistencies):

```lua
local isEventValid = pcall(tester.RegisterEvent, tester, event)
if (pcall(self.SetLight, self, enabled, lightValues)) then
EventUtil.ContinueOnAddOnLoaded(addOn, GenerateClosure(pcall, script))
```

### `error()` — Malformed Data

Reserved for data integrity violations:

```lua
error('Malformed table: field "'..child..'" does not exist in definition.')
```

### Safe Callback Pattern

Combat lockdown protection through `db:RegisterSafeCallback`:

```lua
-- Automatically queued during combat, executed on PLAYER_REGEN_ENABLED
db:RegisterSafeCallback('Settings/interactButton', handler.OnDataLoaded, handler)
```

---

## 11. Idioms & Patterns

### Ternary via `and`/`or`

The dominant pattern for conditional expressions:

```lua
local delay = db('UIleaveCombatDelay') * (UnitIsDead('player') and 2 or 1)
icon:SetDesaturated(not file and true or false)
```

Multi-level:

```lua
script =
    ((down == true)  and 'OnMouseDown') or
    ((down == false) and 'OnMouseUp');
```

### `GenerateClosure` — Partial Application

Preferred over inline anonymous functions when partially applying arguments:

```lua
GenerateClosure(InputProxy, 'PADDUP')
GenerateClosure(SpellMenu.Hide, SpellMenu)
GenerateClosure(pcall, script)
GenerateClosure(ColorMixin.WrapTextInColorCode, BLUE_FONT_COLOR)
```

### Upvalue Caching

Frequently used globals/API calls are cached as locals at file top:

```lua
local CreateFrame, Mixin = CreateFrame, Mixin;
local getmetatable, setmetatable = getmetatable, setmetatable;
local InCombatLockdown = InCombatLockdown;
```

### Guard Clauses

Files that require optional APIs use early returns:

```lua
if not SpellFlyout then return end;
```

### `C_Timer.After` for Deferred Execution

```lua
C_Timer.After(delay, function()
    self.onEnableCallback()
    self.showAfterCombat = nil;
end)
```

### String Construction

- `:format()` preferred for parameterized strings: `('CP-Input-%s'):format(id)`
- `..` for simple concatenation: `'Settings/'..varID`
- `[[ ]]` reserved for secure bodies and file paths with backslashes

### Version-Conditional Feature Detection

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

The `or nil` pattern ensures the value is `nil` (not `false`) so it can be used in dynamic table insertions where `false` would create an entry.

---

## 12. Localization

### Locale Table

Strings live in `ConsolePort/Locale/enUS.lua` (fallback) with optional overrides per-locale. The Locale object is registered on `db` and accessible as `db.Locale` or `env.L`:

```lua
-- In locale definition files (enUS.lua, zhCN.lua, etc.)
local L = select(2, ...).Locale;

L.DESC_TOGGLE_BINDINGS   = 'Toggle the binding display.';
L.NAME_TOGGLE_BINDINGS   = 'Toggle Bindings';
L.FORMAT_BINDING_CURRENT = '%s is currently bound to %s.';
```

### Naming Convention

- `L.DESC_*` — Descriptions
- `L.NAME_*` — Display names
- `L.FORMAT_*` — Format strings with `%s` placeholders
- `L.DISC_*` — Disclaimers

### Locale Literals: `L'text'`

The most distinctive localization pattern in ConsolePort is the **locale literal** syntax using Lua's single-argument function call shorthand:

```lua
self:AddCommand(L'Place on action bar', 'MapActionBar')
self:AddCommand(L'Pick up', 'Pickup')
self:AddCommand(L'Sell', 'Sell')
self:AddCommand(L'Split stack' .. countText, 'Split')
description = L'Select a slot to place this spell.';
handle:AddHint(leftClick, L'Place in slot')
handle:AddHint(rightClick, keyChord and L'Cancel and clear cursor' or L'Clear slot or binding')
```

**How it works:** `L` is the Locale table, which has a `__call` metamethod and an `__index` fallback. When you write `L'text'`, Lua treats it as `L('text')` (function call with a string literal argument). The `__call` metamethod:

1. Looks up the key in the locale table: `self['text']`
2. If the key exists (was defined in a locale file like `zhCN.lua`), returns the translated string
3. If the key **doesn't** exist, `__index` returns the key itself — so `L'Pick up'` returns `'Pick up'` in English, acting as a **no-op passthrough**
4. Supports `:format(...)` for parameterized strings: `L('Format string %s', arg)`
5. Supports nested locale references via `L[inner]` syntax within format strings

This pattern means:
- **All user-facing string literals should be wrapped in `L'...'`** to mark them as localizable
- The English text IS the lookup key — no separate key management needed
- Untranslated strings gracefully fall back to their English text
- The `L'literal'` form (single quotes, no parentheses) is preferred for simple strings
- Use `L('format %s', arg)` with parentheses only when format arguments are needed

### Usage in Code

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

### Template Naming

- `CP<Purpose>Template` for virtual templates: `CPFrameTemplate`
- `CP<Purpose>` for single-use types: `CPAtlas`

### Template Structure

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

### Patterns

- `virtual="true"` — all templates are virtual
- `mixin="..."` — associates a Lua mixin
- `KeyValues` — declarative default configuration
- `parentKey` / `parentArray` — automatic child-to-parent attachment
- `inherit="prepend"` — on `OnLoad` when mixin should run before children
- Inheritance chains for complex chrome: base → extension → final specialization

---

## 14. Multi-Version Support

### Version Flags

```lua
CPAPI.IsRetailVersion     = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or nil;
CPAPI.IsClassicVersion    = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC or nil;
CPAPI.IsClassicEraVersion = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or nil;
```

The `or nil` ensures these evaluate to `true` or `nil` (never `false`), enabling use in conditional table construction.

### Wrapper Functions

CPAPI wrappers abstract version-specific APIs:

```lua
function CPAPI.GetSpecialization()
    if GetSpecialization then  -- retail
        local spec = GetSpecialization()
        if spec then return GetSpecializationInfo(spec) end
    end
    return GetClassID()  -- classic fallback
end
```

### Conditional Settings

```lua
hide = CPAPI.IsRetailVersion;  -- hide on retail, show on classic
note = CPAPI.IsRetailVersion and 'Only available in Classic.';
```
