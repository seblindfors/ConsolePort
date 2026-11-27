#!/usr/bin/env python3
# Extract translatable English strings from the ConsolePort addon suite.
#
# Static sources walked:
#   L:literal     L'foo' / L"foo"                (single/double-quoted call shorthand)
#   L:call        L('foo', ...) / L("foo", ...)   (first arg literal)
#   L:bracket     L['foo'] / L["foo"]
#   L:locale      db.Locale'foo' / db.Locale('foo', ...)
#   L:log         CPAPI.Log('foo', ...)            (Log formats through the locale)
#   vardef:*      name/desc/note/list/head = 'foo'   (settings field labels)
#   vardef:section _('Header', GLOBAL, idx)         (section-header form)
#   vardef:main   _('Header', 'Main')               (second section argument)
#   option        Data.Select(...) / Data.Map(k, {...}) / CPAPI.Enum(...) values
#   doc           MakeMacroDriverDesc(text, outcome, ..., {args}, {states})
#   render:key    Name = Interface.X : Render {...} (loadout tree element names)
#   L:key         L.KEY = '...' / L.KEY = [[ ... ]] (curated locale entries)
#
# Field values and Log formats are evaluated as expressions: a chain of
# literals joined by `..`, color wrappers (BLUE'foo'), `GLOBAL or 'foo'`
# fallbacks and table.concat({...}, sep) resolve to the string the client
# builds. Names passed as arguments resolve to the table or string constant
# they were assigned in the same file, or in any file for dotted names.
#
# Output is JSON: { "<english text>": [ {file, line, kind}, ... ], ... }

import argparse
import json
import os
import re
import sys
from pathlib import Path


# Strip Lua line comments and block comments.
# We replace stripped regions with spaces to preserve line numbers.

LINE_COMMENT = re.compile(r"(?<![\[\=])--[^\n\r\[].*", re.MULTILINE)
BLOCK_COMMENT = re.compile(r"--\[(=*)\[.*?\]\1\]", re.DOTALL)
# Lua block strings: [[ ... ]], [=[ ... ]=], etc. We strip these so that
# their contents don't trigger false matches for our patterns.
BLOCK_STRING = re.compile(r"(?<!--)\[(=*)\[.*?\]\1\]", re.DOTALL)


def _blank(match: re.Match) -> str:
    # Preserve line count by keeping newlines; replace everything else with spaces.
    s = match.group(0)
    return "".join(c if c == "\n" else " " for c in s)


def strip_lua_noise(src: str) -> str:
    # Order matters: block comments first (because they start with --[[ and would
    # otherwise be matched by line comments), then line comments, then block strings.
    src = BLOCK_COMMENT.sub(_blank, src)
    src = LINE_COMMENT.sub(_blank, src)
    src = BLOCK_STRING.sub(_blank, src)
    return src


# A quoted Lua string literal with escape support.
# Captures the inner text (without the quotes).
QSTR = r"""(?:'((?:\\.|[^'\\])*)'|"((?:\\.|[^"\\])*)")"""

# Boundary: the character before our L/_ must NOT be a word character OR a
# quote. The quote exclusion guards against charset tables like {'L','M','N'}
# and inline strings like "L", which would otherwise produce false matches.
NWB = r"(?<![A-Za-z0-9_'\"])"

# Patterns ----------------------------------------------------------------

# L'foo' / L"foo"  — call shorthand. The L is immediately followed by the quote.
PAT_L_LITERAL = re.compile(NWB + r"L" + QSTR)

# L( 'foo' , ... ) / L("foo", ...) — function call with literal first arg.
PAT_L_CALL = re.compile(NWB + r"L\s*\(\s*" + QSTR)

# L['foo'] / L["foo"] — bracket lookup (inline locale reference).
PAT_L_BRACKET = re.compile(NWB + r"L\s*\[\s*" + QSTR + r"\s*\]")

# _( 'Header' , GLOBAL, idx ) — section header form used inside AddVariables.
# Match _ as a function call (not as the discard pattern `local _ =`).
PAT_SECTION = re.compile(NWB + r"_\(\s*" + QSTR)

# Field names whose value is a label the settings UI passes to the locale.
VARDEF_KEYS = {"name", "desc", "note", "list", "head"}

# Calls whose string arguments are option values shown through the locale.
OPTION_CALLS = {"Data.Select", "Select", "Data.Map", "Map", "CPAPI.Enum"}
DOC_CALLS = {"MakeMacroDriverDesc", "env.MakeMacroDriverDesc"}
LOG_CALLS = {"CPAPI.Log"}
LOCALE_CALLS = {"db.Locale", "env.L"}

# Text color of the Blizzard color objects used by wrapper closures.
FONT_COLORS = {
    "BLUE_FONT_COLOR": "ff0070dd",
}

# local BLUE = GenerateClosure(ColorMixin.WrapTextInColorCode, BLUE_FONT_COLOR)
PAT_WRAPPER = re.compile(
    r"\blocal\s+([A-Za-z_]\w*)\s*=\s*GenerateClosure\(\s*"
    r"ColorMixin\.WrapTextInColorCode\s*,\s*([A-Za-z_]\w*)\s*\)"
)

# Name = Interface.Type : Render {
PAT_RENDER_KEY = re.compile(
    r"\b([A-Za-z_]\w*)\s*=\s*Interface\.[A-Za-z_]\w*\s*:\s*Render\b"
)

PAT_LOCAL_BEFORE = re.compile(r"\blocal\s+$")

# Name = OtherName;
PAT_ASSIGN_NAME = re.compile(r"\b([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)\s*[;,]")

# Tokens: quoted string, dotted name, a multi-character operator, or one
# other character.
PAT_TOKEN = re.compile(
    QSTR
    + r"|([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)"
    + r"|(\.\.\.|\.\.|==|~=|<=|>=)"
    + r"|(\S)"
)

# L.KEY = '...' / "..." — curated locale entries.
PAT_L_KEY_SINGLE = re.compile(r"\bL\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*" + QSTR)

# L.KEY = [[ ... ]] or [=[ ... ]=] — multi-line curated locale entries.
PAT_L_KEY_BLOCK = re.compile(
    r"\bL\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\[(=*)\[(.*?)\]\2\]",
    re.DOTALL,
)


def _line_of(src: str, offset: int) -> int:
    # 1-based line number for a byte offset in src.
    return src.count("\n", 0, offset) + 1


def _pick(match: re.Match, *group_indices) -> str:
    for i in group_indices:
        v = match.group(i)
        if v is not None:
            return v
    return ""


def _unescape(s: str) -> str:
    # Lua string escapes we care about. Conservative — only the common ones.
    return (
        s.replace("\\n", "\n")
         .replace("\\r", "\r")
         .replace("\\t", "\t")
         .replace("\\'", "'")
         .replace('\\"', '"')
         .replace("\\\\", "\\")
    )


class Tokens:
    # A flat token stream over comment-stripped Lua source.
    #   kind 's' = string literal (value unescaped), 'n' = name, 'p' = punctuation

    def __init__(self, src: str):
        self.kind: list[str] = []
        self.val: list[str] = []
        self.pos: list[int] = []
        for m in PAT_TOKEN.finditer(src):
            if m.group(1) is not None or m.group(2) is not None:
                self.kind.append("s")
                self.val.append(_unescape(_pick(m, 1, 2)))
            elif m.group(3) is not None:
                self.kind.append("n")
                self.val.append(m.group(3))
            else:
                self.kind.append("p")
                self.val.append(m.group(4) or m.group(5))
            self.pos.append(m.start())
        self.wrappers: dict[str, str] = {}
        self.strings: dict[str, tuple[str, int]] = {}
        self.fallbacks: dict[str, str] = {}
        self.tables: dict[str, list[tuple[str, int]]] = {}

    def __len__(self) -> int:
        return len(self.kind)

    def is_s(self, i: int) -> bool:
        return 0 <= i < len(self) and self.kind[i] == "s"

    def is_p(self, i: int, val: str) -> bool:
        return 0 <= i < len(self) and self.kind[i] == "p" and self.val[i] == val

    def is_n(self, i: int, val: str | None = None) -> bool:
        return 0 <= i < len(self) and self.kind[i] == "n" and (val is None or self.val[i] == val)

    def close(self, i: int) -> int:
        # Index of the bracket matching the opener at i.
        depth = 0
        for j in range(i, len(self)):
            if self.kind[j] != "p":
                continue
            if self.val[j] in ("(", "{", "["):
                depth += 1
            elif self.val[j] in (")", "}", "]"):
                depth -= 1
                if depth == 0:
                    return j
        return len(self) - 1

    def args(self, i: int) -> list[tuple[int, int]]:
        # Token ranges of the top-level arguments of the call or table opened at i.
        end = self.close(i)
        out, start, depth = [], i + 1, 0
        for j in range(i + 1, end):
            if self.kind[j] != "p":
                continue
            if self.val[j] in ("(", "{", "["):
                depth += 1
            elif self.val[j] in (")", "}", "]"):
                depth -= 1
            elif self.val[j] in (",", ";") and depth == 0:
                out.append((start, j))
                start = j + 1
        if start < end:
            out.append((start, end))
        return out

    def values(self, a: int, b: int) -> list[tuple[str, int]]:
        # String literals in [a, b) that are values, with ['key'] indices left out.
        out = []
        for j in range(a, b):
            if self.is_s(j) and not (self.is_p(j - 1, "[") and self.is_p(j + 1, "]")):
                out.append((self.val[j], self.pos[j]))
        return out

    def term(self, i: int):
        if self.is_s(i):
            return self.val[i], i + 1
        if not self.is_n(i):
            return None
        name = self.val[i]
        if name in self.wrappers:
            color = self.wrappers[name]
            if self.is_s(i + 1):
                return "|c%s%s|r" % (color, self.val[i + 1]), i + 2
            if self.is_p(i + 1, "(") and self.is_s(i + 2) and self.is_p(i + 3, ")"):
                return "|c%s%s|r" % (color, self.val[i + 2]), i + 4
            return None
        if name == "table.concat" and self.is_p(i + 1, "(") and self.is_p(i + 2, "{"):
            end = self.close(i + 2)
            parts = [self.val[j] for j in range(i + 3, end) if self.kind[j] == "s"]
            if self.is_p(end + 1, ",") and self.is_s(end + 2) and self.is_p(end + 3, ")"):
                return self.val[end + 2].join(parts), end + 4
        return None

    def expr(self, i: int):
        # Evaluate `term (.. term)*` at i. Returns (text, next index), or None
        # when the expression is not built from literals alone.
        got = self.term(i)
        if got is None:
            return None
        text, i = got
        while self.is_p(i, ".."):
            got = self.term(i + 1)
            if got is None:
                return None
            text, i = text + got[0], got[1]
        if self.is_p(i, ":") or self.is_p(i, "("):
            return None
        return text, i


def scan_definitions(toks: Tokens, src: str) -> None:
    # Record color wrappers, and the string and table constants assigned to names.
    for m in PAT_WRAPPER.finditer(src):
        color = FONT_COLORS.get(m.group(2))
        if color:
            toks.wrappers[m.group(1)] = color
        else:
            print(f"warning: unknown color {m.group(2)} for wrapper {m.group(1)}", file=sys.stderr)
    for i in range(len(toks) - 2):
        if not toks.is_n(i) or not toks.is_p(i + 1, "="):
            continue
        if toks.is_p(i + 2, "{"):
            toks.tables[toks.val[i]] = toks.values(i + 3, toks.close(i + 2))
        else:
            # `local A = GLOBAL or 'x'` falls back to the literal.
            k = i + 4 if toks.is_n(i + 2) and toks.is_n(i + 3, "or") else i + 2
            got = toks.expr(k) if toks.is_s(k) else None
            if got:
                # `local A, B = 'x'` assigns the first name.
                j = i
                while toks.is_p(j - 1, ",") and toks.is_n(j - 2):
                    j -= 2
                toks.strings.setdefault(toks.val[j], (got[0], toks.pos[k]))
                if k != i + 2:
                    toks.fallbacks.setdefault(toks.val[j], got[0])


def extract_tokens(toks: Tokens, shared: dict, rel: str, add) -> None:
    def resolve(name: str) -> list[tuple[str, int]]:
        if name in toks.strings:
            return [toks.strings[name]]
        if name in toks.tables:
            return toks.tables[name]
        return shared.get(name, [])

    def spread(a: int, b: int, kind: str) -> None:
        # Literal values in [a, b), following names to the constants they hold.
        for text, pos in toks.values(a, b):
            add(text, pos, kind)
        for j in range(a, b):
            if toks.is_n(j) and not toks.is_p(j + 1, "="):
                for text, _ in resolve(toks.val[j]):
                    add(text, toks.pos[j], kind)

    for i in range(len(toks)):
        if not toks.is_n(i):
            continue
        name = toks.val[i]
        field = name.rsplit(".", 1)[-1]

        if field in VARDEF_KEYS and toks.is_p(i + 1, "="):
            j = i + 2
            if toks.is_n(j) and toks.is_n(j + 1, "or"):
                j += 2
            got = toks.expr(j)
            if got:
                add(got[0], toks.pos[j], "vardef:" + field)
            elif toks.is_n(j) and toks.val[j] in toks.fallbacks:
                add(toks.fallbacks[toks.val[j]], toks.pos[j], "vardef:" + field)
            elif toks.is_s(j) and toks.is_p(j + 1, ".."):
                print(f"warning: {rel}: unresolved expression starting {toks.val[j][:40]!r}",
                      file=sys.stderr)
            continue

        if not toks.is_p(i + 1, "("):
            if name in LOCALE_CALLS and toks.is_s(i + 1):
                add(toks.val[i + 1], toks.pos[i + 1], "L:locale")
            continue
        args = toks.args(i + 1)
        if not args:
            continue

        if name == "_" and len(args) > 1:
            a, b = args[1]
            if b - a == 1 and toks.is_s(a):
                add(toks.val[a], toks.pos[a], "vardef:main")
        elif name in LOCALE_CALLS or name in LOG_CALLS:
            kind = "L:log" if name in LOG_CALLS else "L:locale"
            a, b = args[0]
            got = toks.expr(a)
            if got:
                add(got[0], toks.pos[a], kind)
            else:
                # A constant passed by name: CPAPI.Log(HELP_STRING, ...)
                for j in range(a, b):
                    if toks.is_n(j):
                        for text, _ in resolve(toks.val[j]):
                            add(text, toks.pos[j], kind)
        elif name in OPTION_CALLS and len(args) > 1:
            # A Map leads with its default key, the options follow.
            for a, b in (args[1:] if name.endswith("Map") else args):
                spread(a, b, "option")
        elif name in DOC_CALLS:
            for n, (a, b) in enumerate(args):
                if n < 2:
                    got = toks.expr(a)
                    if got:
                        add(got[0], toks.pos[a], "doc")
                elif toks.is_p(a, "{") or (b - a == 1 and toks.is_n(a)):
                    spread(a, b, "doc")


def extract_file(path: Path, repo_root: Path, shared: dict | None = None) -> list[tuple[str, dict]]:
    raw = path.read_text(encoding="utf-8", errors="replace")
    rel = str(path.relative_to(repo_root))

    is_locale_file = "Locale" in path.parts and path.name not in ("Locale.lua",)
    entries: list[tuple[str, dict]] = []

    # Curated locale entries: parsed BEFORE comment/block stripping so we keep
    # the L.KEY = [[ ... ]] form. Limit to files inside Locale/ directories.
    if is_locale_file:
        for m in PAT_L_KEY_SINGLE.finditer(raw):
            key, text = m.group(1), _pick(m, 2, 3)
            entries.append((_unescape(text), {
                "file": rel,
                "line": _line_of(raw, m.start()),
                "kind": "L:key",
                "key": key,
            }))
        for m in PAT_L_KEY_BLOCK.finditer(raw):
            key, text = m.group(1), m.group(3)
            entries.append((text, {
                "file": rel,
                "line": _line_of(raw, m.start()),
                "kind": "L:key",
                "key": key,
            }))
        # Locale files exist purely to define translations — don't double-extract
        # via the L'foo' style patterns.
        return entries

    src = strip_lua_noise(raw)

    def add(text: str, m: re.Match, kind: str, **extra):
        entries.append((_unescape(text), {
            "file": rel,
            "line": _line_of(src, m.start()),
            "kind": kind,
            **extra,
        }))

    for m in PAT_L_LITERAL.finditer(src):
        add(_pick(m, 1, 2), m, "L:literal")
    for m in PAT_L_CALL.finditer(src):
        add(_pick(m, 1, 2), m, "L:call")
    for m in PAT_L_BRACKET.finditer(src):
        add(_pick(m, 1, 2), m, "L:bracket")
    for m in PAT_SECTION.finditer(src):
        add(_pick(m, 1, 2), m, "vardef:section")
    # A render held in a local is a value; the key it is assigned to names it.
    renders = set()
    for m in PAT_RENDER_KEY.finditer(src):
        if PAT_LOCAL_BEFORE.search(src, 0, m.start()):
            renders.add(m.group(1))
        else:
            add(m.group(1), m, "render:key")
    for m in PAT_ASSIGN_NAME.finditer(src):
        if m.group(2) in renders:
            add(m.group(1), m, "render:key")

    toks = Tokens(src)
    scan_definitions(toks, src)
    extract_tokens(toks, shared or {}, rel, lambda text, pos, kind: entries.append((text, {
        "file": rel,
        "line": _line_of(src, pos),
        "kind": kind,
    })))

    return entries


def shared_tables(files: list[Path]) -> dict:
    # Tables assigned to a dotted name (env.Const.PageDescription) are visible
    # from every file of the addon, so they resolve across files.
    shared: dict[str, list] = {}
    for p in files:
        if "Locale" in p.parts:
            continue
        src = strip_lua_noise(p.read_text(encoding="utf-8", errors="replace"))
        toks = Tokens(src)
        scan_definitions(toks, src)
        for name, values in toks.tables.items():
            if "." in name:
                shared.setdefault(name, values)
    return shared


def walk_lua_files(root: Path) -> list[Path]:
    out: list[Path] = []
    # Limit to addon source dirs — skip Libs/, Wiki/, Artwork/, GamepadTool/, Tools/.
    addon_dirs = [
        "ConsolePort", "ConsolePort_Bar", "ConsolePort_Config", "ConsolePort_Cursor",
        "ConsolePort_Keyboard", "ConsolePort_Menu", "ConsolePort_Rings", "ConsolePort_World",
        "ConsolePort_Target",
    ]
    for d in addon_dirs:
        base = root / d
        if not base.exists():
            continue
        for p in base.rglob("*.lua"):
            # Skip Libs/ (third-party) and Tools/ (this tooling).
            parts = set(p.relative_to(root).parts)
            if "Libs" in parts or "Tools" in parts:
                continue
            out.append(p)
    return sorted(out)


def main():
    ap = argparse.ArgumentParser(
        description="Extract translatable English strings from ConsolePort .lua sources."
    )
    ap.add_argument("--root", default=str(Path(__file__).resolve().parents[2]),
                    help="Repository root (default: derived from script path)")
    ap.add_argument("--output", "-o", default="-",
                    help="Output JSON file (default: stdout)")
    ap.add_argument("--all-locale-files", action="store_true",
                    help="Include L.KEY entries from all Locale/*.lua files (default: only enUS.lua)")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    files = walk_lua_files(root)

    shared = shared_tables(files)

    aggregated: dict[str, list[dict]] = {}
    for p in files:
        if "Locale" in p.parts and p.name != "Locale.lua":
            # enUS.lua is the canonical source of curated L.KEY entries — always
            # include it. Other locale files are translations, not source text.
            if not args.all_locale_files and p.name != "enUS.lua":
                continue
        for text, info in extract_file(p, root, shared):
            if not text:
                continue
            aggregated.setdefault(text, []).append(info)

    payload = {
        "schema": 1,
        "kind": "static",
        "root": str(root),
        "file_count": len(files),
        "entries": aggregated,
    }
    out = json.dumps(payload, indent=2, ensure_ascii=False, sort_keys=True)
    if args.output == "-":
        sys.stdout.write(out + "\n")
    else:
        Path(args.output).write_text(out + "\n", encoding="utf-8")
        print(f"wrote {len(aggregated)} unique strings to {args.output}", file=sys.stderr)


if __name__ == "__main__":
    main()
