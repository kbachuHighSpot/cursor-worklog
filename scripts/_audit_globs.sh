#!/usr/bin/env bash
# _audit_globs.sh — verify every glob in ~/.cursor/rules/*.mdc resolves to at
# least one file. A glob that matches no files is "dead" — the rule will never
# auto-attach, creating false confidence (rule exists but is never seen).
#
# This is the reference implementation referenced from
# `docs/effective-cursor-rules-and-skills.md` (Maintenance section). Drop it
# into your team's `.cursor/rules/` folder or anywhere on PATH and run it
# periodically.
#
# Usage:
#   bash _audit_globs.sh                 # human-readable report
#   bash _audit_globs.sh --strict        # exit 1 if any dead (CI-friendly)
#   bash _audit_globs.sh --json          # machine-readable
#
# Configuration (env vars, all optional):
#   CURSOR_RULES_DIR   — directory of .mdc rule files. Default: ~/.cursor/rules
#   CURSOR_AUDIT_ROOTS — colon-separated list of additional workspace roots a
#                        glob may be resolved against. Default: every direct
#                        child of ~/Codebase/ (if it exists) plus $HOME itself.
#
# Implementation note: we shell out to Python because bash's `**` expansion
# from $HOME recurses into every repo's node_modules / .git trees. Python's
# glob.glob(..., recursive=True) with a fixed-list of roots is bounded and
# fast — and we short-circuit `**/.cursor/...` patterns directly against
# $HOME/.cursor/ since that's where they're meant to resolve anyway.

set -euo pipefail

exec python3 - "$@" <<'PY'
import glob as glob_mod
import json
import os
import re
import sys
from pathlib import Path

RULES_DIR = Path(os.environ.get("CURSOR_RULES_DIR", str(Path.home() / ".cursor" / "rules")))

# Search roots a glob is evaluated against. Cursor evaluates rule globs
# against open workspace roots; we approximate that with $HOME (where .cursor
# lives) + every repo under ~/Codebase/ + any roots from CURSOR_AUDIT_ROOTS.
roots = [str(Path.home())]
codebase = Path.home() / "Codebase"
if codebase.is_dir():
    for entry in sorted(codebase.iterdir()):
        if entry.is_dir() and not entry.name.startswith("."):
            roots.append(str(entry))
extra = os.environ.get("CURSOR_AUDIT_ROOTS", "")
for r in extra.split(":"):
    r = r.strip()
    if r and r not in roots:
        roots.append(r)

strict = "--strict" in sys.argv
emit_json = "--json" in sys.argv


def extract_globs(mdc_path: Path):
    """Pull comma-joined globs out of the front-matter `globs:` line."""
    in_fm = False
    fm_seen = 0
    with mdc_path.open() as f:
        for line in f:
            if line.strip() == "---":
                fm_seen += 1
                if fm_seen == 2:
                    break
                in_fm = True
                continue
            if not in_fm:
                continue
            m = re.match(r"^globs:\s*(.*)$", line)
            if not m:
                continue
            raw = m.group(1).strip()
            if raw.startswith('"') and raw.endswith('"'):
                raw = raw[1:-1]
            return [g.strip() for g in raw.split(",") if g.strip()]
    return []


def glob_has_match(pattern: str) -> bool:
    """Return True if `pattern` matches at least one file.

    Optimizations to avoid recursing through every repo's node_modules:
      - `**/.cursor/...`  → check $HOME/.cursor/... directly
      - `**/<rest>`       → try the literal <rest> in each root (no deep recursion)
      - absolute path     → glob directly
      - other             → join with each root + recursive glob
    """
    if pattern.startswith("/"):
        return bool(glob_mod.glob(pattern, recursive=True))

    if pattern.startswith("**/.cursor/"):
        rest = pattern[len("**/"):]
        return bool(glob_mod.glob(os.path.join(str(Path.home()), rest), recursive=True))

    if pattern.startswith("**/"):
        rest = pattern[len("**/"):]
        for root in roots:
            if glob_mod.glob(os.path.join(root, rest)):
                return True
        return False

    for root in roots:
        full = os.path.join(root, pattern)
        try:
            if glob_mod.glob(full, recursive=True):
                return True
        except OSError:
            continue
    return False


total_rules = 0
total_globs = 0
dead = []

if not RULES_DIR.is_dir():
    print(f"error: rules directory does not exist: {RULES_DIR}", file=sys.stderr)
    print("hint: set CURSOR_RULES_DIR if your rules live elsewhere", file=sys.stderr)
    sys.exit(2)

for f in sorted(RULES_DIR.glob("*.mdc")):
    total_rules += 1
    for g in extract_globs(f):
        total_globs += 1
        if not glob_has_match(g):
            dead.append((f.name, g))

if emit_json:
    print(json.dumps({
        "total_rules": total_rules,
        "total_globs": total_globs,
        "dead_globs": len(dead),
        "dead": [{"rule": r, "glob": g} for r, g in dead],
    }))
else:
    import datetime as _dt
    now = _dt.datetime.now(_dt.timezone.utc)
    print(f"Glob freshness audit — {now.strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print("-" * 64)
    print(f"Rules dir: {RULES_DIR}")
    print(f"Scanned {total_rules} rules · {total_globs} globs")
    if not dead:
        print("Dead globs: 0  OK")
    else:
        print(f"Dead globs: {len(dead)}  FAIL")
        print()
        print("DEAD GLOBS (these rules never auto-attach):")
        for rule, g in dead:
            print(f"  {rule}  ->  {g}")
        print()
        print("To fix: open each rule, either correct the path or remove the")
        print('stale glob. See effective-cursor-rules-and-skills.md "Maintenance".')

if strict and dead:
    sys.exit(1)
PY
