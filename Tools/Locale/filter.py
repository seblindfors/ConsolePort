#!/usr/bin/env python3
# Filter noise out of an extracted-string set.
#
# Rules, in order:
#   1. WoW globals exact-match — values from GlobalStrings.lua (which the WoW
#      client already localizes). Drop these; we should never translate them.
#   2. Pure markup — strings whose entire content is |c...|r color codes,
#      |T...|t textures, |A...|a atlases, or whitespace.
#   3. Breadcrumb composites — strings shaped like `A|cff...| | |rB(|cff... | |rC)*`,
#      assembled at runtime from atomic parts. The parts are extracted separately,
#      so the composite would be redundant work.
#   4. All-caps short identifiers (<= 24 chars, ALL_CAPS only) — these are
#      typically API enum values like CENTER, HORIZONTAL, OUTLINE that should
#      not be translated even when they show up as labels.
#
# Each dropped entry is written to a `rejected` map with the rule that caught it,
# so review is auditable.
#
# Usage:
#   python3 filter.py INPUT.json -o KEPT.json --rejected REJECTED.json \
#       --globals GlobalStrings.lua
#
# GlobalStrings.lua is the auto-generated FrameXML file. Drop it next to this
# script (default lookup: Tools/Locale/GlobalStrings.lua) — it is in .gitignore
# since it's Blizzard's, not ours.

import argparse
import json
import re
import sys
from pathlib import Path


# Captures `KEY = "VALUE";` (with optional trailing semicolon) — the standard
# shape of every line in GlobalStrings.lua. We accept both ' and " quoting.
GLOBALSTRING_LINE = re.compile(
    r'^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(?:"((?:\\.|[^"\\])*)"|\'((?:\\.|[^\'\\])*)\')\s*;?\s*$',
    re.MULTILINE,
)

# Embedded fallback values — only the ones I directly observed in this addon's
# runtime collector output. The full list comes from GlobalStrings.lua.
FALLBACK_GLOBALS = {
    # Anchors / orientation
    "CENTER", "TOP", "BOTTOM", "LEFT", "RIGHT",
    "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT",
    "HORIZONTAL", "VERTICAL",
    # Font flags / blend modes
    "OUTLINE", "THICKOUTLINE", "MONOCHROME", "BLEND", "ADD",
    # Modifier keys (SHIFT_KEY_TEXT etc. resolve to these single tokens on enUS)
    "SHIFT", "CTRL", "ALT", "NONE",
    # Magnitude
    "LOW", "MEDIUM", "HIGH",
    # Common labels from FrameXML
    "Interface", "Bindings", "System", "Targeting",
    "Edit", "Dynamic", "Always", "Never",
}

# Pure-markup detection: strip color/texture/atlas markup + whitespace; if
# nothing remains, the string is purely decorative.
MARKUP = re.compile(
    r"(?:"
    r"\|c[fF0-9a-fA-F]{8}|\|r"            # color codes
    r"|\|T[^|]+\|t"                       # textures
    r"|\|A:[^|]+\|a"                      # atlases
    r"|\|H[^|]+\|h|\|h"                   # hyperlinks
    r"|\|n"                               # newline escapes
    r")"
)

# Breadcrumb composite shape: A|cff808080 | |rB(|cff... | |rC)*
# We match the general form: literal text, then one or more separator+text
# segments where the separator uses a |c...|r wrap around " | ".
BREADCRUMB_SEP = re.compile(r"\|c[fF0-9a-fA-F]{8} \| \|r")

ALL_CAPS = re.compile(r"^[A-Z][A-Z0-9_]*$")

# Curated locale key names. L('KEY', ...) is a lookup of a curated entry, not
# a translatable English string. The value lives in Locale/enUS.lua and is
# extracted separately as `L:key`. We parse this lazily from the enUS file.
L_KEY_ASSIGNMENT = re.compile(r"\bL\.([A-Za-z_][A-Za-z0-9_]*)\s*=")


def load_locale_keys(enus_path: Path | None) -> set[str]:
    if enus_path is None or not enus_path.exists():
        return set()
    text = enus_path.read_text(encoding="utf-8", errors="replace")
    return {m.group(1) for m in L_KEY_ASSIGNMENT.finditer(text)}


def load_globals(path: Path | None) -> tuple[set[str], int]:
    if path is None or not path.exists():
        return set(FALLBACK_GLOBALS), 0
    text = path.read_text(encoding="utf-8", errors="replace")
    values: set[str] = set()
    for m in GLOBALSTRING_LINE.finditer(text):
        val = m.group(2) if m.group(2) is not None else m.group(3)
        if val:
            values.add(val)
    return values, len(values)


def is_pure_markup(s: str) -> bool:
    stripped = MARKUP.sub("", s).strip()
    return stripped == ""


def is_breadcrumb(s: str) -> bool:
    # Must have at least one breadcrumb separator AND be otherwise composed of
    # plain text segments (no other color codes embedded inside the segments).
    parts = BREADCRUMB_SEP.split(s)
    if len(parts) < 2:
        return False
    # Every part should be a non-empty piece of plain text (possibly with a
    # leading |T...|t texture, since textures are sometimes wedged in front
    # of the last segment).
    for p in parts:
        if not p:
            return False
        # If a part contains additional color markup of its own, it's not a
        # pure breadcrumb — it's a sentence with breadcrumb-like punctuation.
        if "|c" in p and "|r" not in p:
            return False
        if re.search(r"\|c[fF0-9a-fA-F]{8}.*?\|r", p):
            return False
    return True


def is_all_caps_short(s: str) -> bool:
    return len(s) <= 24 and bool(ALL_CAPS.match(s))


def filter_entries(
    entries: dict[str, list[dict]],
    globals_set: set[str],
    locale_keys: set[str],
) -> tuple[dict[str, list[dict]], dict[str, dict]]:
    kept: dict[str, list[dict]] = {}
    rejected: dict[str, dict] = {}

    for text, occs in entries.items():
        rule = None
        if text in locale_keys:
            # L('KEY', ...) — the translatable value is curated in enUS.lua.
            rule = "locale_key_lookup"
        elif text in globals_set:
            rule = "wow_global"
        elif is_all_caps_short(text):
            rule = "all_caps_enum"
        elif is_pure_markup(text):
            rule = "pure_markup"
        elif is_breadcrumb(text):
            rule = "breadcrumb_composite"

        if rule:
            rejected[text] = {"rule": rule, "sources": occs}
        else:
            kept[text] = occs

    return kept, rejected


def main():
    ap = argparse.ArgumentParser(description="Filter noise from extracted strings.")
    ap.add_argument("input", help="Input JSON (output of extract.py or runtime.py, or a merged file)")
    ap.add_argument("--output", "-o", default="-", help="Output (kept) JSON")
    ap.add_argument("--rejected", help="Optional rejected-entries JSON path")
    default_globals = Path(__file__).resolve().parent / "GlobalStrings.lua"
    ap.add_argument(
        "--globals",
        default=str(default_globals),
        help=f"Path to GlobalStrings.lua (default: {default_globals})",
    )
    default_enus = Path(__file__).resolve().parents[2] / "ConsolePort" / "Locale" / "enUS.lua"
    ap.add_argument(
        "--enus",
        default=str(default_enus),
        help=f"Path to Locale/enUS.lua for curated-key detection (default: {default_enus})",
    )
    args = ap.parse_args()

    data = json.loads(Path(args.input).read_text(encoding="utf-8"))
    entries = data.get("entries", data)

    globals_set, count = load_globals(Path(args.globals))
    if count == 0:
        print(
            f"warning: no GlobalStrings.lua found at {args.globals}; "
            f"using built-in fallback ({len(globals_set)} values).",
            file=sys.stderr,
        )
    else:
        print(f"loaded {count} WoW global values from {args.globals}", file=sys.stderr)

    locale_keys = load_locale_keys(Path(args.enus))
    if locale_keys:
        print(f"loaded {len(locale_keys)} curated L.KEY names from {args.enus}", file=sys.stderr)

    kept, rejected = filter_entries(entries, globals_set, locale_keys)

    out_payload = {
        "schema": 1,
        "kind": data.get("kind", "filtered"),
        "entries": kept,
    }
    out_text = json.dumps(out_payload, indent=2, ensure_ascii=False, sort_keys=True)
    if args.output == "-":
        sys.stdout.write(out_text + "\n")
    else:
        Path(args.output).write_text(out_text + "\n", encoding="utf-8")

    if args.rejected:
        rej_payload = {"schema": 1, "kind": "rejected", "entries": rejected}
        Path(args.rejected).write_text(
            json.dumps(rej_payload, indent=2, ensure_ascii=False, sort_keys=True) + "\n",
            encoding="utf-8",
        )

    summary = {}
    for v in rejected.values():
        summary[v["rule"]] = summary.get(v["rule"], 0) + 1
    print(f"input: {len(entries)}  kept: {len(kept)}  rejected: {len(rejected)}", file=sys.stderr)
    for rule, n in sorted(summary.items()):
        print(f"  rejected/{rule}: {n}", file=sys.stderr)


if __name__ == "__main__":
    main()
