#!/usr/bin/env python3
# Convert a filtered string set into an LLM-ready translation template.
#
# Each entry in the output has a stable id, the English source, an empty
# `translation` slot, and metadata flags so the model knows what to preserve.
#
# Two entry forms map to two Lua output shapes:
#   form="key"     → L.KEYNAME      = 'translation';
#   form="literal" → L['english']   = 'translation';
#
# A single English string may appear in both forms when it is both a curated
# L.KEY value AND used as an L'literal' call elsewhere.

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path


# Curated locale entries: L.KEY = '...' (single-line) and L.KEY = [[ ... ]] (block).
PAT_KEY_SINGLE = re.compile(
    r"\bL\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:'((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")"
)
PAT_KEY_BLOCK = re.compile(
    r"\bL\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\[(=*)\[(.*?)\]\2\]",
    re.DOTALL,
)
# Literal form translations: L['...'] = '...' or L["..."] = "..."
PAT_LIT_SINGLE = re.compile(
    r"\bL\[\s*(?:'((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")\s*\]\s*=\s*"
    r"(?:'((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")"
)
PAT_LIT_BLOCK = re.compile(
    r"\bL\[\s*(?:'((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")\s*\]\s*=\s*\[(=*)\[(.*?)\]\3\]",
    re.DOTALL,
)


def _pick(m: re.Match, *idxs) -> str:
    for i in idxs:
        v = m.group(i)
        if v is not None:
            return v
    return ""


def _unescape(s: str) -> str:
    # Lua single-line string escape sequences. The order matters: handle the
    # double-backslash form last so we don't undo earlier replacements.
    return (
        s.replace("\\n", "\n")
         .replace("\\r", "\r")
         .replace("\\t", "\t")
         .replace("\\'", "'")
         .replace('\\"', '"')
         .replace("\\\\", "\\")
    )


def _hash_id(text: str) -> str:
    h = hashlib.sha1(text.encode("utf-8")).hexdigest()
    return "l:" + h[:10]


def _has_format(text: str) -> bool:
    # %s, %d, %1$s, %.2f etc.
    return bool(re.search(r"%(?:\d+\$)?[-+# 0]?\d*\.?\d*[sdifcxXeEgG]", text))


def _has_markup(text: str) -> bool:
    return bool(re.search(r"\|c[0-9a-fA-F]{8}|\|T[^|]+\|t|\|A:[^|]+\|a", text))


def _is_blocky(text: str) -> bool:
    # Block-string form looks better for anything with embedded newlines OR
    # very long single-line strings.
    return "\n" in text or len(text) > 120


def _is_todo_marked(text: str, end_pos: int) -> bool:
    """Check if the line containing position `end_pos` has a `-- TODO` marker
    after that position. Used to detect English-placeholder rows that
    emit.py wrote — those should not be treated as real translations."""
    eol = text.find("\n", end_pos)
    if eol == -1:
        eol = len(text)
    return "-- TODO" in text[end_pos:eol]


def parse_locale_file(path: Path) -> dict[str, dict]:
    """Return prefill entries from a locale .lua file. Entries marked with a
    trailing `-- TODO` comment (English placeholders written by emit.py) are
    skipped, so they won't masquerade as real translations on re-run."""
    out: dict[str, dict] = {}
    if not path.exists():
        return out
    text = path.read_text(encoding="utf-8", errors="replace")
    for m in PAT_KEY_SINGLE.finditer(text):
        if _is_todo_marked(text, m.end()):
            continue
        k = m.group(1)
        val = _unescape(_pick(m, 2, 3))
        out["k:" + k] = {"text": val, "block": False}
    for m in PAT_KEY_BLOCK.finditer(text):
        if _is_todo_marked(text, m.end()):
            continue
        k = m.group(1)
        val = m.group(3)
        out["k:" + k] = {"text": val, "block": True}
    for m in PAT_LIT_SINGLE.finditer(text):
        if _is_todo_marked(text, m.end()):
            continue
        eng = _unescape(_pick(m, 1, 2))
        val = _unescape(_pick(m, 3, 4))
        out[_hash_id(eng)] = {"text": val, "block": False, "en": eng}
    for m in PAT_LIT_BLOCK.finditer(text):
        if _is_todo_marked(text, m.end()):
            continue
        eng = _unescape(_pick(m, 1, 2))
        val = m.group(4)
        out[_hash_id(eng)] = {"text": val, "block": True, "en": eng}
    return out


def build_entries(
    kept_entries: dict[str, list[dict]],
    prefill: dict[str, dict],
) -> list[dict]:
    """Build the entry list. One entry per (English text × form). Curated keys
    get one entry per unique L.KEY name; literals collapse to a single entry
    per English text."""
    entries: list[dict] = []
    seen_ids: set[str] = set()

    # Sort English texts for stable output, but within each text keep curated
    # entries grouped before literal entries.
    for text in sorted(kept_entries.keys()):
        occs = kept_entries[text]
        key_names = sorted({occ.get("key") for occ in occs if occ.get("kind") == "L:key" and occ.get("key")})
        non_key_kinds = [occ for occ in occs if occ.get("kind") != "L:key"]

        flags = []
        if _has_format(text):
            flags.append("format")
        if _has_markup(text):
            flags.append("markup")

        # Curated-key form(s)
        for key in key_names:
            entry_id = "k:" + key
            if entry_id in seen_ids:
                continue
            seen_ids.add(entry_id)
            entries.append({
                "id": entry_id,
                "form": "key",
                "key": key,
                "en": text,
                "translation": prefill.get(entry_id, {}).get("text", ""),
                "block": _is_blocky(text),
                "flags": flags,
            })

        # Literal form (only if there's a non-key use, or no curated key at all)
        if non_key_kinds or not key_names:
            entry_id = _hash_id(text)
            if entry_id in seen_ids:
                continue
            seen_ids.add(entry_id)
            sources = sorted({f"{o['file']}:{o['line']}" for o in non_key_kinds if "file" in o})[:5]
            entries.append({
                "id": entry_id,
                "form": "literal",
                "en": text,
                "translation": prefill.get(entry_id, {}).get("text", ""),
                "block": _is_blocky(text),
                "flags": flags,
                "sources": sources,
            })

    return entries


INSTRUCTIONS = """\
You are translating UI strings for ConsolePort, a World of Warcraft gamepad
addon. Translate each `en` field into the target locale and write it into the
`translation` field, returning the same JSON structure.

RULES — non-negotiable:
1. Preserve `%s`, `%d`, `%1$s`, `%.2f`, etc. format placeholders verbatim.
   The order may be rearranged for grammar, but every placeholder in `en`
   must appear in `translation`.
2. Preserve markup verbatim where it appears:
   - `|cffXXXXXX...|r` color codes (8 hex digits after `|c`)
   - `|T...|t` texture markup
   - `|A:...|a` atlas markup
   The text inside these markers IS translatable.
3. Preserve newlines exactly. If `en` is a block-form entry (block=true),
   keep the same paragraph structure in `translation`.
4. Do NOT translate WoW-API enum values that may appear inline (CENTER,
   HORIZONTAL, OUTLINE, etc.) — leave them in English.
5. Gamepad terminology: keep button names (e.g. "PADDUP", "L1", "RT")
   in English. WoW ability names follow Blizzard's official localization.
6. Tone: friendly and explanatory, matching the existing translations in
   zhCN.lua / zhTW.lua. Use the player-addressing style ("you", "your")
   typical for in-game help text.

DO NOT modify the `id`, `form`, `key`, `en`, `block`, or `flags` fields.
Only write to the `translation` field.
"""


def main():
    ap = argparse.ArgumentParser(description="Build LLM translation template from filtered string set.")
    ap.add_argument("input", help="Path to kept.json (filter.py output)")
    ap.add_argument("--locale", required=True, help="Target locale code (e.g. zhCN, deDE, frFR)")
    ap.add_argument("--prefill", help="Existing Locale/<code>.lua to seed translations from")
    ap.add_argument("--output", "-o", default="-", help="Output template JSON (default stdout)")
    args = ap.parse_args()

    data = json.loads(Path(args.input).read_text(encoding="utf-8"))
    entries = data.get("entries", data)

    prefill = {}
    if args.prefill:
        prefill = parse_locale_file(Path(args.prefill))
        print(f"prefilled {sum(1 for v in prefill.values() if v.get('text'))} translations from {args.prefill}",
              file=sys.stderr)

    built = build_entries(entries, prefill)

    stats = {
        "total": len(built),
        "curated_keys": sum(1 for e in built if e["form"] == "key"),
        "literals": sum(1 for e in built if e["form"] == "literal"),
        "with_format": sum(1 for e in built if "format" in e["flags"]),
        "with_markup": sum(1 for e in built if "markup" in e["flags"]),
        "block_form": sum(1 for e in built if e["block"]),
        "prefilled": sum(1 for e in built if e["translation"]),
        "untranslated": sum(1 for e in built if not e["translation"]),
    }

    payload = {
        "schema": 1,
        "locale": args.locale,
        "instructions": INSTRUCTIONS,
        "stats": stats,
        "entries": built,
    }
    out_text = json.dumps(payload, indent=2, ensure_ascii=False)
    if args.output == "-":
        sys.stdout.write(out_text + "\n")
    else:
        Path(args.output).write_text(out_text + "\n", encoding="utf-8")
        print(f"wrote template for locale={args.locale}: {stats}", file=sys.stderr)


if __name__ == "__main__":
    main()
