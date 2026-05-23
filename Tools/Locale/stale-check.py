#!/usr/bin/env python3
# Detect curated L.KEY translations that have gone stale because the enUS
# source was reworded after the translation was emitted.
#
# Mechanism: emit.py writes a `-- en:XXXXXXXX` provenance comment on each
# curated L.KEY line, recording the SHA-1[:8] hash of the English source at
# emit time. This script reads enUS.lua's current values, hashes them, and
# compares against the recorded hash in each target locale.
#
# Three classes of entry are reported:
#   STALE       — hash mismatch: enUS source has changed since translation.
#                 Re-translate or re-emit.
#   UNVERIFIED  — no `-- en:` marker (legacy file, predates this mechanism).
#                 Re-emit the locale once to add provenance.
#   MISSING     — key exists in enUS but not in the locale file. May or may
#                 not matter depending on whether the locale's owner wants
#                 partial translation.
#
# Exit code: 1 if any STALE entries found; 0 otherwise.
#
# Usage:
#   python3 Tools/Locale/stale-check.py ConsolePort/Locale/deDE.lua
#   python3 Tools/Locale/stale-check.py ConsolePort/Locale/{de,fr,zh}*.lua

import argparse
import hashlib
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


PAT_KEY_SINGLE = re.compile(
    r"\bL\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:'((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")"
)
PAT_KEY_BLOCK = re.compile(
    r"\bL\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\[(=*)\[(.*?)\]\2\]",
    re.DOTALL,
)
PAT_HASH = re.compile(r"--\s*en:([0-9a-fA-F]+)")


def _en_hash(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:8]


def _unescape(s: str) -> str:
    return (
        s.replace("\\n", "\n").replace("\\r", "\r").replace("\\t", "\t")
         .replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\")
    )


def _hash_on_line(text: str, end_pos: int) -> str | None:
    eol = text.find("\n", end_pos)
    if eol == -1:
        eol = len(text)
    m = PAT_HASH.search(text[end_pos:eol])
    return m.group(1) if m else None


def parse_keys(path: Path) -> dict[str, dict]:
    """Return {KEY: {"value": <translation/source>, "hash": <recorded hash or None>}}."""
    out: dict[str, dict] = {}
    if not path.exists():
        return out
    text = path.read_text(encoding="utf-8", errors="replace")
    for m in PAT_KEY_SINGLE.finditer(text):
        key = m.group(1)
        val = _unescape(m.group(2) if m.group(2) is not None else m.group(3))
        out[key] = {"value": val, "hash": _hash_on_line(text, m.end())}
    for m in PAT_KEY_BLOCK.finditer(text):
        key = m.group(1)
        out[key] = {"value": m.group(3), "hash": _hash_on_line(text, m.end())}
    return out


def main():
    ap = argparse.ArgumentParser(
        description="Detect curated L.KEY translations whose enUS source was reworded after emit."
    )
    default_enus = HERE.parent.parent / "ConsolePort" / "Locale" / "enUS.lua"
    ap.add_argument("--enus", default=str(default_enus),
                    help=f"Path to enUS.lua (default: {default_enus})")
    ap.add_argument("locales", nargs="+", help="Locale .lua files to check")
    ap.add_argument("--quiet", action="store_true", help="Only print summary lines")
    args = ap.parse_args()

    enus = parse_keys(Path(args.enus))
    if not enus:
        print(f"error: no L.KEY entries found in {args.enus}", file=sys.stderr)
        sys.exit(2)
    print(f"loaded {len(enus)} curated keys from {Path(args.enus).name}", file=sys.stderr)

    total_stale = 0
    for locale_path in args.locales:
        p = Path(locale_path)
        if not p.exists():
            print(f"  SKIP: {p} does not exist", file=sys.stderr)
            continue
        loc = parse_keys(p)
        stale: list[tuple[str, str, str]] = []
        unverified: list[str] = []
        missing: list[str] = []
        for key, source in enus.items():
            target = loc.get(key)
            if not target:
                missing.append(key)
                continue
            if not target["hash"]:
                unverified.append(key)
                continue
            current = _en_hash(source["value"])
            if target["hash"].lower() != current.lower():
                stale.append((key, target["hash"], current))

        print(f"\n=== {p.name} ===")
        present = len(loc) - sum(1 for k in loc if k not in enus)
        print(f"  curated keys: {len(loc)} present, {len(missing)} missing-from-locale")
        print(f"  STALE:      {len(stale)}")
        print(f"  unverified: {len(unverified)} (no -- en: marker; re-emit to add)")
        if not args.quiet:
            for k, prev, cur in stale:
                src = enus[k]["value"]
                preview = src.replace("\n", " ").strip()[:80]
                print(f"    STALE  {k}  (was en:{prev}, now en:{cur})")
                print(f"           current enUS → {preview!r}")
            if unverified and len(unverified) <= 10:
                print(f"  unverified keys: {unverified}")
            elif unverified:
                print(f"  unverified keys (first 10): {unverified[:10]}")

        total_stale += len(stale)

    print()
    if total_stale > 0:
        print(f"FAIL: {total_stale} stale curated entries across all checked locales.",
              file=sys.stderr)
        sys.exit(1)
    print("OK: no stale curated entries.", file=sys.stderr)


if __name__ == "__main__":
    main()
