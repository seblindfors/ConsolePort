#!/usr/bin/env python3
# Orchestrator: run the full pipeline and write artifacts to an output dir.
#
# Steps:
#   1. extract     — static scan of .lua sources                → static.json
#   2. filter      — apply noise rules                          → kept.json, rejected.json
#   3. template    — build per-locale LLM template              → template_<code>.json
#
# Hand template_<code>.json to a translator, fill the `translation` field on
# each entry, then run emit.py to produce ConsolePort/Locale/<code>.lua.
#
# NOTE: The runtime collector (ConsolePort_Debug.lua SavedVariable) is NOT
# used here by default. It captures every string that flows through L() at
# play time, including runtime-assembled composites like
#   "|A:icon|a Sensors\nDetected 6 out of 8 possible sensors.\n• Gyro\n• ..."
# which should never be translated as a single unit — the atomic parts are
# in source and get translated separately. Use `--runtime` only for
# diagnostics; do not include its output in shipped locale files.

import argparse
import json
import subprocess
import sys
from pathlib import Path

# All sub-tools live next to this script.
HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent

DEFAULT_LOCALES = ["zhCN", "zhTW", "deDE", "frFR", "esES", "esMX", "itIT", "koKR", "ptBR", "ruRU"]


def _run(cmd: list[str]) -> None:
    print("$", " ".join(cmd), file=sys.stderr)
    res = subprocess.run(cmd, check=False)
    if res.returncode != 0:
        sys.exit(res.returncode)


def main():
    ap = argparse.ArgumentParser(description="Run the full locale extraction pipeline.")
    ap.add_argument(
        "--runtime",
        help="Path to ConsolePort_Debug.lua. DIAGNOSTIC ONLY — captures "
             "runtime-assembled composite strings that should not be translated. "
             "Use to spot UI paths missed by the static extractor; do not ship "
             "translations derived from it.",
    )
    ap.add_argument("--out", default=str(HERE / "out"), help="Output directory (default: Tools/Locale/out)")
    ap.add_argument("--locales", nargs="+", default=DEFAULT_LOCALES,
                    help=f"Locales to produce templates for (default: {' '.join(DEFAULT_LOCALES)})")
    ap.add_argument("--globals", default=str(HERE / "GlobalStrings.lua"),
                    help="Path to GlobalStrings.lua for the noise filter")
    args = ap.parse_args()

    out = Path(args.out).resolve()
    out.mkdir(parents=True, exist_ok=True)

    static_json = out / "static.json"
    runtime_json = out / "runtime.json"
    merged_json = out / "merged.json"
    kept_json = out / "kept.json"
    rejected_json = out / "rejected.json"

    # 1. Static extraction
    _run([sys.executable, str(HERE / "extract.py"), "-o", str(static_json)])

    # 2. Runtime (optional)
    merge_inputs = [str(static_json)]
    if args.runtime:
        _run([sys.executable, str(HERE / "runtime.py"), args.runtime, "-o", str(runtime_json)])
        merge_inputs.append(str(runtime_json))
    else:
        print("(skipping runtime parse — no --runtime given)", file=sys.stderr)

    # 3. Merge
    _run([sys.executable, str(HERE / "merge.py"), *merge_inputs, "-o", str(merged_json)])

    # 4. Filter
    _run([
        sys.executable, str(HERE / "filter.py"), str(merged_json),
        "-o", str(kept_json),
        "--rejected", str(rejected_json),
        "--globals", args.globals,
    ])

    # 5. Templates per locale
    locale_dir = REPO_ROOT / "ConsolePort" / "Locale"
    for code in args.locales:
        prefill = locale_dir / f"{code}.lua"
        template_json = out / f"template_{code}.json"
        cmd = [
            sys.executable, str(HERE / "template.py"), str(kept_json),
            "--locale", code,
            "-o", str(template_json),
        ]
        if prefill.exists():
            cmd.extend(["--prefill", str(prefill)])
        _run(cmd)

    print(file=sys.stderr)
    print(f"pipeline complete. Output → {out}", file=sys.stderr)
    print(f"  static:    {static_json.name}", file=sys.stderr)
    if args.runtime:
        print(f"  runtime:   {runtime_json.name}", file=sys.stderr)
    print(f"  merged:    {merged_json.name}", file=sys.stderr)
    print(f"  kept:      {kept_json.name}", file=sys.stderr)
    print(f"  rejected:  {rejected_json.name}", file=sys.stderr)
    for code in args.locales:
        print(f"  template:  template_{code}.json", file=sys.stderr)
    print(file=sys.stderr)
    print("Next: fill `translation` fields in template_<code>.json (via LLM),", file=sys.stderr)
    print("then run: <python> Tools/Locale/emit.py <template> -o ConsolePort/Locale/<code>.lua",
          file=sys.stderr)


if __name__ == "__main__":
    main()
