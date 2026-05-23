#!/usr/bin/env python3
# Extract translatable English strings from the ConsolePort addon suite.
#
# Static sources walked:
#   L:literal     L'foo' / L"foo"                (single/double-quoted call shorthand)
#   L:call        L('foo', ...) / L("foo", ...)   (first arg literal)
#   L:bracket     L['foo'] / L["foo"]
#   vardef:*      name/desc/note/list/head = 'foo'   (settings field labels)
#   vardef:section _('Header', GLOBAL, idx)         (section-header form)
#   L:key         L.KEY = '...' / L.KEY = [[ ... ]] (curated locale entries)
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

# name|desc|note|list|head = 'foo' / "foo"
PAT_VARDEF = re.compile(
    r"(?P<key>\bname|\bdesc|\bnote|\blist|\bhead)\s*=\s*" + QSTR
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


def extract_file(path: Path, repo_root: Path) -> list[tuple[str, dict]]:
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
    for m in PAT_VARDEF.finditer(src):
        text = m.group(2) if m.group(2) is not None else m.group(3)
        add(text, m, f"vardef:{m.group('key')}")

    return entries


def walk_lua_files(root: Path) -> list[Path]:
    out: list[Path] = []
    # Limit to addon source dirs — skip Libs/, Wiki/, Artwork/, GamepadTool/, Tools/.
    addon_dirs = [
        "ConsolePort", "ConsolePort_Bar", "ConsolePort_Config", "ConsolePort_Cursor",
        "ConsolePort_Keyboard", "ConsolePort_Menu", "ConsolePort_Rings", "ConsolePort_World",
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

    aggregated: dict[str, list[dict]] = {}
    for p in files:
        if "Locale" in p.parts and p.name != "Locale.lua":
            # enUS.lua is the canonical source of curated L.KEY entries — always
            # include it. Other locale files are translations, not source text.
            if not args.all_locale_files and p.name != "enUS.lua":
                continue
        for text, info in extract_file(p, root):
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
