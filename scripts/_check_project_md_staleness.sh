#!/usr/bin/env bash
# _check_project_md_staleness.sh — flag PROJECT.md files that lag behind the
# repo they describe. Compares each PROJECT.md's mtime against the commit
# cadence in its enclosing directory, so a project that's been shipping
# heavily without a corresponding PROJECT.md refresh shows up as 🟡 / 🔴.
#
# Sibling of `_audit_globs.sh` and `_audit_crossrefs.sh` in this directory.
# Same style: Python under a bash wrapper, env-var configurable, --strict
# for CI, --json for tooling.
#
# Usage:
#   bash _check_project_md_staleness.sh                  # human-readable report
#   bash _check_project_md_staleness.sh --strict         # exit 1 if any 🔴 stale
#   bash _check_project_md_staleness.sh --quiet          # only print when stale
#   bash _check_project_md_staleness.sh --json           # machine-readable
#   bash _check_project_md_staleness.sh path/to/PROJECT.md   # check explicit file(s)
#
# Configuration (env vars, all optional):
#   PROJECT_MD_ROOTS     — colon-separated roots to scan. Default: every
#                          direct child of ~/Codebase/ (skipping hidden dirs).
#   FRESH_DAYS           — mtime ≤ N days is 🟢 fresh. Default: 14.
#   LAGGING_DAYS         — mtime ≤ N days is 🟡 lagging. Default: 30.
#                          mtime > LAGGING_DAYS is 🔴 stale.
#   SHIPPING_THRESHOLD   — commits in same dir since PROJECT.md mtime that
#                          downgrades the verdict by one tier. Default: 10.
#                          (≥ 2× threshold downgrades two tiers.)
#
# Verdicts:
#   🟢 fresh    — mtime ≤ FRESH_DAYS AND commits_since < SHIPPING_THRESHOLD
#   🟡 lagging  — mtime ≤ LAGGING_DAYS  OR commits_since ≥ SHIPPING_THRESHOLD
#   🔴 stale    — mtime > LAGGING_DAYS  OR commits_since ≥ 2 × SHIPPING_THRESHOLD
#
# Exit codes:
#   0 — all 🟢 (or --strict not set)
#   1 — at least one 🔴 (only when --strict)

set -euo pipefail

exec python3 - "$@" <<'PY'
import json
import os
import subprocess
import sys
import time
from pathlib import Path

# --- config ------------------------------------------------------------------

FRESH_DAYS = int(os.environ.get("FRESH_DAYS", "14"))
LAGGING_DAYS = int(os.environ.get("LAGGING_DAYS", "30"))
SHIPPING_THRESHOLD = int(os.environ.get("SHIPPING_THRESHOLD", "10"))

roots_env = os.environ.get("PROJECT_MD_ROOTS", "").strip()
if roots_env:
    roots = [Path(p) for p in roots_env.split(":") if p.strip()]
else:
    codebase = Path.home() / "Codebase"
    roots = (
        [p for p in sorted(codebase.iterdir()) if p.is_dir() and not p.name.startswith(".")]
        if codebase.is_dir()
        else []
    )

# CLI flags
args = sys.argv[1:]
strict = "--strict" in args
emit_json = "--json" in args
quiet = "--quiet" in args
explicit_paths = [Path(a).resolve() for a in args if not a.startswith("--")]


# --- helpers -----------------------------------------------------------------

def find_project_mds():
    """Either the explicit paths, or every PROJECT.md under the configured roots."""
    if explicit_paths:
        return [p for p in explicit_paths if p.is_file()]
    found = []
    skip = {"node_modules", ".git", "vendor", "tmp", ".bundle", ".terraform"}
    for root in roots:
        if not root.is_dir():
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames[:] = [d for d in dirnames if d not in skip and not d.startswith(".")]
            if "PROJECT.md" in filenames:
                found.append(Path(dirpath) / "PROJECT.md")
    return found


def days_since(epoch_seconds: float) -> int:
    return int((time.time() - epoch_seconds) // 86400)


def git_repo_root(path: Path):
    """Return the enclosing git repo root, or None if not in a git repo."""
    try:
        out = subprocess.run(
            ["git", "-C", str(path.parent), "rev-parse", "--show-toplevel"],
            check=True, capture_output=True, text=True,
        )
        return Path(out.stdout.strip())
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def commits_in_dir_since(repo_root: Path, dir_path: Path, since_epoch: float) -> int:
    """Count commits in `dir_path` (relative to repo_root) since since_epoch."""
    try:
        rel = dir_path.relative_to(repo_root)
    except ValueError:
        rel = Path(".")
    since_iso = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(since_epoch))
    try:
        out = subprocess.run(
            ["git", "-C", str(repo_root), "log",
             f"--since={since_iso}", "--pretty=oneline", "--", str(rel)],
            check=True, capture_output=True, text=True,
        )
        return sum(1 for line in out.stdout.splitlines() if line.strip())
    except subprocess.CalledProcessError:
        return -1  # unknown


def verdict(days: int, commits: int) -> tuple[str, str]:
    """Return (emoji, label). Mtime sets the baseline; shipping volume downgrades."""
    if days <= FRESH_DAYS:
        base = ("🟢", "fresh")
    elif days <= LAGGING_DAYS:
        base = ("🟡", "lagging")
    else:
        base = ("🔴", "stale")
    if commits >= 0 and commits >= 2 * SHIPPING_THRESHOLD:
        return ("🔴", "stale")
    if commits >= 0 and commits >= SHIPPING_THRESHOLD and base[0] == "🟢":
        return ("🟡", "lagging")
    return base


# --- main --------------------------------------------------------------------

records = []
for project_md in find_project_mds():
    st = project_md.stat()
    days = days_since(st.st_mtime)
    repo = git_repo_root(project_md)
    commits = commits_in_dir_since(repo, project_md.parent, st.st_mtime) if repo else -1
    emoji, label = verdict(days, commits)
    records.append({
        "path": str(project_md),
        "days_since_mtime": days,
        "commits_in_dir_since_mtime": commits,
        "verdict": label,
        "emoji": emoji,
        "repo": str(repo) if repo else None,
    })


# --- output ------------------------------------------------------------------

if emit_json:
    print(json.dumps({
        "config": {
            "FRESH_DAYS": FRESH_DAYS,
            "LAGGING_DAYS": LAGGING_DAYS,
            "SHIPPING_THRESHOLD": SHIPPING_THRESHOLD,
        },
        "records": records,
    }, indent=2))
else:
    stale_only = [r for r in records if r["emoji"] in ("🟡", "🔴")]
    show = stale_only if quiet else records
    if not records:
        if not quiet:
            print(f"# PROJECT.md staleness check\n\nNo PROJECT.md files found under: {', '.join(str(r) for r in roots) or '(no roots configured)'}")
    elif quiet and not stale_only:
        pass  # silent when nothing to flag
    else:
        title = "# PROJECT.md staleness check"
        if quiet:
            title += " (stale only)"
        print(title)
        print()
        print(f"Thresholds: FRESH ≤ {FRESH_DAYS}d · LAGGING ≤ {LAGGING_DAYS}d · SHIPPING ≥ {SHIPPING_THRESHOLD} commits.")
        print()
        print("| Verdict | Days since mtime | Commits in dir since mtime | File |")
        print("|---|---|---|---|")
        for r in show:
            commits = r["commits_in_dir_since_mtime"]
            commits_cell = "—" if commits < 0 else str(commits)
            print(f"| {r['emoji']} {r['verdict']} | {r['days_since_mtime']}d | {commits_cell} | `{r['path']}` |")
        print()

if strict and any(r["emoji"] == "🔴" for r in records):
    sys.exit(1)
PY
