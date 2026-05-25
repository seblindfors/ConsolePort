#!/usr/bin/env python3
# Emit a Lua locale file from a translation template.
#
# Default behavior: emit ALL entries. Entries with a non-empty `translation`
# go in as-is; entries without a translation use the English source as the
# value AND get a trailing `-- TODO` comment so they're easy to find and
# distinguish from completed translations.
#
# Workflow:
#   1. python3 Tools/Locale/run.py --runtime <ConsolePort_Debug.lua>
#   2. python3 Tools/Locale/emit.py Tools/Locale/out/template_deDE.json \
#          -o ConsolePort/Locale/deDE.lua
#   3. Translate the `-- TODO`-marked entries (in place, by hand or with a
#      translator). Remove the `-- TODO` comment once the entry is translated.
#   4. Re-running step 1+2 preserves your edits: prefill detects `-- TODO`
#      and won't promote English-fallback rows back into the template.
#
# Output shape matches Locale/zhCN.lua:
#   local L = select(2, ...).Locale;
#   L.SHORT_KEY        = 'translation';
#   L.LONG_KEY = [[
#       translation block
#   ]];
#   L['English literal'] = 'translation';
#   L['Untranslated literal'] = 'Untranslated literal'; -- TODO

import argparse
import hashlib
import json
import sys
from pathlib import Path

LOCALE_TITLES = {
    "deDE": "Deutsch German",
    "esES": "Español Spanish",
    "esMX": "Español Latinoamericano",
    "frFR": "Français French",
    "itIT": "Italiano Italian",
    "koKR": "한국어 Korean",
    "ptBR": "Português Brazilian Portuguese",
    "ruRU": "Русский Russian",
    "zhCN": "简体中文 simplified Chinese",
    "zhTW": "繁體中文 traditional Chinese",
}

TODO_MARKER = " -- TODO"


def _en_hash(text: str) -> str:
    """Stable 8-char hash of an English source string. Written as a trailing
    `-- en:XXXX` comment on curated L.KEY lines so stale-check.py can detect
    drift when enUS.lua is reworded but the locale still has the old translation."""
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:8]


def _quote_inline(text: str) -> str:
    """Encode a string as a Lua single-line literal with backslash escapes.
    Used for table-index lookup keys (LHS of L[...] = ...) where block form
    would be ambiguous with the surrounding brackets."""
    text = text.replace("\\", "\\\\")
    text = text.replace("\r", "\\r")
    text = text.replace("\t", "\\t")
    text = text.replace("\n", "\\n")
    if "'" not in text:
        return "'" + text + "'"
    if '"' not in text:
        return '"' + text + '"'
    return "'" + text.replace("'", "\\'") + "'"


def _quote_block(text: str) -> str:
    """Encode a string as a Lua [[ ... ]] block literal. Picks a [=*[ level
    high enough that the content doesn't terminate the bracket early."""
    level = 0
    while f"]{'=' * level}]" in text:
        level += 1
    eq = "=" * level
    return f"[{eq}[{text}]{eq}]"


def _quote_value(text: str) -> str:
    if _is_block_value(text):
        return _quote_block(text)
    return _quote_inline(text)


def _is_block_value(text: str) -> bool:
    return "\n" in text or len(text) > 120


def _value_for(entry: dict) -> tuple[str, bool]:
    """Return (value_to_emit, is_placeholder)."""
    translation = entry.get("translation") or ""
    if translation:
        return translation, False
    return entry["en"], True


def emit_curated_key(entry: dict, align: int) -> str:
    key = entry["key"]
    val, placeholder = _value_for(entry)
    en_marker = f" -- en:{_en_hash(entry['en'])}"
    suffix = (TODO_MARKER + en_marker) if placeholder else en_marker
    if _is_block_value(val):
        return f"L.{key} = {_quote_block(val)};{suffix}"
    pad = " " * max(1, align - len(key))
    return f"L.{key}{pad}= {_quote_inline(val)};{suffix}"


def emit_literal(entry: dict) -> str:
    en = entry["en"]
    val, placeholder = _value_for(entry)
    suffix = TODO_MARKER if placeholder else ""
    return f"L[{_quote_inline(en)}] = {_quote_value(val)};{suffix}"


SECTION_BAR = "-" * 63


def section(title: str) -> str:
    return f"{SECTION_BAR}\n-- {title}\n{SECTION_BAR}"


def emit_file(template: dict, translated_only: bool = False) -> str:
    locale = template["locale"]
    title = LOCALE_TITLES.get(locale, locale)
    entries = list(template["entries"])

    if translated_only:
        entries = [e for e in entries if e.get("translation")]

    # For sectioning, decide block-vs-short based on the value we'd actually
    # emit (the translation, or the English fallback for placeholders).
    def value_of(e: dict) -> str:
        return e.get("translation") or e["en"]

    keys_short = [e for e in entries if e["form"] == "key" and not _is_block_value(value_of(e))]
    keys_block = [e for e in entries if e["form"] == "key" and _is_block_value(value_of(e))]
    literals    = [e for e in entries if e["form"] == "literal"]

    out: list[str] = []
    out.append("local L = select(2, ...).Locale;")
    out.append(section(f"{locale} {title}"))

    if keys_short:
        out.append(section("Short / curated keys"))
        align = max(len(e["key"]) for e in keys_short) + 1
        for e in sorted(keys_short, key=lambda x: x["key"]):
            out.append(emit_curated_key(e, align))

    if keys_block:
        out.append(section("Long / curated block entries"))
        for e in sorted(keys_block, key=lambda x: x["key"]):
            out.append(emit_curated_key(e, 0))

    if literals:
        out.append(section("Literals"))
        short_literals = [e for e in literals
                          if not _is_block_value(value_of(e)) and "\n" not in e["en"]]
        block_literals = [e for e in literals if e not in short_literals]
        for e in sorted(short_literals, key=lambda x: x["en"].lower()):
            out.append(emit_literal(e))
        if block_literals:
            out.append(section("Literal block entries"))
            for e in sorted(block_literals, key=lambda x: x["en"].lower()):
                out.append(emit_literal(e))

    return "\n".join(out) + "\n"


def main():
    ap = argparse.ArgumentParser(
        description="Emit a Lua locale file from a translation template. "
                    "Untranslated entries are emitted with English as a placeholder, "
                    "marked '-- TODO'."
    )
    ap.add_argument("template", help="Path to template JSON (run.py output)")
    ap.add_argument("--output", "-o", default="-", help="Output .lua file (default stdout)")
    ap.add_argument("--translated-only", action="store_true",
                    help="Skip untranslated entries entirely (no English placeholders)")
    args = ap.parse_args()

    template = json.loads(Path(args.template).read_text(encoding="utf-8"))
    text = emit_file(template, translated_only=args.translated_only)

    if args.output == "-":
        sys.stdout.write(text)
    else:
        Path(args.output).write_text(text, encoding="utf-8")
        total = len(template["entries"])
        translated = sum(1 for e in template["entries"] if e.get("translation"))
        todo = total - translated
        print(f"wrote {args.output}: {translated} translated, {todo} TODO ({total} total)",
              file=sys.stderr)


if __name__ == "__main__":
    main()
