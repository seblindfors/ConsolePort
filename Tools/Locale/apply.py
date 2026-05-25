#!/usr/bin/env python3
# Apply a translations JSON ({id: translation}) to a template, then write
# the result back AND produce the .lua locale file.
#
# Usage:
#   python3 apply.py \
#       --template Tools/Locale/out/template_deDE.json \
#       --translations Tools/Locale/out/translations_deDE.json \
#       --output ConsolePort/Locale/deDE.lua

import argparse
import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def main():
    ap = argparse.ArgumentParser(description="Merge translations into a template and emit .lua.")
    ap.add_argument("--template", required=True, help="Template JSON (run.py output)")
    ap.add_argument("--translations", required=True,
                    help='Translations JSON: {"id": "translation", ...}')
    ap.add_argument("--output", required=True, help="Output .lua file path")
    ap.add_argument("--save-template", action="store_true",
                    help="Write the merged template back over the input")
    args = ap.parse_args()

    template = json.loads(Path(args.template).read_text(encoding="utf-8"))
    translations = json.loads(Path(args.translations).read_text(encoding="utf-8"))

    applied = 0
    skipped_missing_id = []
    for entry in template["entries"]:
        eid = entry["id"]
        if eid in translations:
            entry["translation"] = translations[eid]
            applied += 1
    for tid in translations:
        if not any(e["id"] == tid for e in template["entries"]):
            skipped_missing_id.append(tid)

    print(f"applied {applied}/{len(translations)} translations to template", file=sys.stderr)
    if skipped_missing_id:
        print(f"warning: {len(skipped_missing_id)} ids in translations file not present in template",
              file=sys.stderr)
        for x in skipped_missing_id[:5]:
            print(f"  - {x}", file=sys.stderr)

    if args.save_template:
        Path(args.template).write_text(
            json.dumps(template, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    # Re-emit by piping the in-memory template through emit.py via a temp file.
    tmp = Path(args.template).with_suffix(".merged.json")
    tmp.write_text(json.dumps(template, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    try:
        res = subprocess.run(
            [sys.executable, str(HERE / "emit.py"), str(tmp), "-o", args.output],
            check=False,
        )
        sys.exit(res.returncode)
    finally:
        tmp.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
