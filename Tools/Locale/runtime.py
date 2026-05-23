#!/usr/bin/env python3
# Parse the ConsolePort_Debug SavedVariable file (ConsolePortLocale)
# into a normalized JSON shape matching the static extractor's output.
#
# The saved file looks like:
#
#   ConsolePortLocale = {
#   ["Camera speed for pitch - moving up/down."] = true,
#   ["Some other string"] = true,
#   ...
#   }
#
# Some keys span multiple lines (newlines embedded as literal \n).
# The format is line-based and regular enough to parse with a regex.

import argparse
import json
import re
import sys
from pathlib import Path

# Matches a key line: ["..."] = true,
# The bracketed Lua string allows escaped quotes (\") and newlines (\n).
ENTRY = re.compile(r'^\["((?:\\.|[^"\\])*)"\]\s*=\s*(true|false)\s*,?\s*$', re.MULTILINE)


def _unescape(s: str) -> str:
    return (
        s.replace("\\n", "\n")
         .replace("\\r", "\r")
         .replace("\\t", "\t")
         .replace("\\\"", "\"")
         .replace("\\\\", "\\")
    )


def parse(text: str) -> dict[str, list[dict]]:
    out: dict[str, list[dict]] = {}
    for m in ENTRY.finditer(text):
        raw, flag = m.group(1), m.group(2)
        if flag != "true":
            continue
        key = _unescape(raw)
        out.setdefault(key, []).append({
            "file": "<runtime>",
            "line": text.count("\n", 0, m.start()) + 1,
            "kind": "runtime",
        })
    return out


def main():
    ap = argparse.ArgumentParser(
        description="Parse ConsolePort_Debug.lua (ConsolePortLocale SavedVariable)."
    )
    ap.add_argument("input", help="Path to ConsolePort_Debug.lua saved-variables file")
    ap.add_argument("--output", "-o", default="-", help="Output JSON (default stdout)")
    args = ap.parse_args()

    text = Path(args.input).read_text(encoding="utf-8", errors="replace")
    entries = parse(text)

    payload = {
        "schema": 1,
        "kind": "runtime",
        "source": args.input,
        "entries": entries,
    }
    out = json.dumps(payload, indent=2, ensure_ascii=False, sort_keys=True)
    if args.output == "-":
        sys.stdout.write(out + "\n")
    else:
        Path(args.output).write_text(out + "\n", encoding="utf-8")
        print(f"wrote {len(entries)} unique strings to {args.output}", file=sys.stderr)


if __name__ == "__main__":
    main()
