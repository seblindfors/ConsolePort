#!/usr/bin/env python3
# Merge any number of extracted-string JSON files into one set,
# concatenating provenance entries for each unique English string.

import argparse
import json
import sys
from pathlib import Path


def main():
    ap = argparse.ArgumentParser(description="Merge string-extraction JSON files.")
    ap.add_argument("inputs", nargs="+", help="Input JSON files")
    ap.add_argument("--output", "-o", default="-", help="Output JSON (default stdout)")
    args = ap.parse_args()

    merged: dict[str, list[dict]] = {}
    for p in args.inputs:
        data = json.loads(Path(p).read_text(encoding="utf-8"))
        entries = data.get("entries", data)
        for k, occs in entries.items():
            merged.setdefault(k, []).extend(occs)

    payload = {"schema": 1, "kind": "merged", "entries": merged}
    out = json.dumps(payload, indent=2, ensure_ascii=False, sort_keys=True)
    if args.output == "-":
        sys.stdout.write(out + "\n")
    else:
        Path(args.output).write_text(out + "\n", encoding="utf-8")
        print(f"merged {len(args.inputs)} files → {len(merged)} unique strings", file=sys.stderr)


if __name__ == "__main__":
    main()
