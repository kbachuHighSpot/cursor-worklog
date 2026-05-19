#!/usr/bin/env bash
# _audit_crossrefs.sh — verify cross-references inside Cursor skill / rule /
# plan files resolve to real targets. Reports broken refs you can fix before
# they silently confuse the agent.
#
# This is the reference implementation referenced from
# `docs/effective-cursor-rules-and-skills.md` (Maintenance section).
#
# Reference shapes checked:
#   1. Sibling-skill markdown links:   [...](../skill-name/SKILL.md)
#   2. Plan-file references in body:   <plan-name>.plan.md
#   3. `related_skills:` front-matter list values inside skill or plan files
#
# Usage:
#   bash _audit_crossrefs.sh           # human-readable report
#   bash _audit_crossrefs.sh --strict  # exit 1 if any broken (CI-friendly)
#
# Configuration (env vars, all optional, colon-separated lists):
#   CURSOR_SKILL_ROOTS — where skill directories live. Each entry should
#                        contain one subdirectory per skill, with a SKILL.md
#                        inside.
#                        Default: ~/.cursor/skills
#                        Example: ~/.cursor/skills:~/code/our-team-plugins
#   CURSOR_PLAN_ROOTS  — where *.plan.md files live (flat directories).
#                        Default: ~/.cursor/plans
#   CURSOR_RULE_ROOTS  — where *.mdc rule files live (flat directories).
#                        Default: ~/.cursor/rules

set -euo pipefail

STRICT=0
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    -h|--help)
      sed -n '2,28p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Discover the universe
# ---------------------------------------------------------------------------

IFS=':' read -r -a SKILL_ROOTS <<< "${CURSOR_SKILL_ROOTS:-$HOME/.cursor/skills}"
IFS=':' read -r -a PLAN_ROOTS  <<< "${CURSOR_PLAN_ROOTS:-$HOME/.cursor/plans}"
IFS=':' read -r -a RULE_ROOTS  <<< "${CURSOR_RULE_ROOTS:-$HOME/.cursor/rules}"

# Build skill-name and plan-name catalogs (these are what refs must resolve to)
declare -A SKILL_NAMES=()
declare -A PLAN_NAMES=()

for root in "${SKILL_ROOTS[@]}"; do
  [ -d "$root" ] || continue
  for entry in "$root"/*; do
    [ -d "$entry" ] || continue
    name=$(basename "$entry")
    [[ "$name" == .* ]] && continue   # skip hidden/archive dirs
    SKILL_NAMES["$name"]=1
  done
done

for root in "${PLAN_ROOTS[@]}"; do
  [ -d "$root" ] || continue
  for entry in "$root"/*.plan.md; do
    [ -e "$entry" ] || continue
    name=$(basename "$entry" .plan.md)
    PLAN_NAMES["$name"]=1
  done
done

# Files to scan (where refs might live)
SCAN_FILES=()
for root in "${SKILL_ROOTS[@]}"; do
  [ -d "$root" ] || continue
  while IFS= read -r f; do SCAN_FILES+=("$f"); done < <(find "$root" -maxdepth 3 -name '*.md' -type f 2>/dev/null)
done
for root in "${PLAN_ROOTS[@]}"; do
  [ -d "$root" ] || continue
  while IFS= read -r f; do SCAN_FILES+=("$f"); done < <(find "$root" -maxdepth 1 -name '*.md' -type f 2>/dev/null)
done
for root in "${RULE_ROOTS[@]}"; do
  [ -d "$root" ] || continue
  while IFS= read -r f; do SCAN_FILES+=("$f"); done < <(find "$root" -maxdepth 1 -name '*.mdc' -type f 2>/dev/null)
done

# ---------------------------------------------------------------------------
# Scan for refs
# ---------------------------------------------------------------------------

broken_count=0
files_scanned=0
declare -a broken_lines

for f in "${SCAN_FILES[@]:-}"; do
  [ -z "$f" ] && continue
  files_scanned=$((files_scanned + 1))
  basef=$(basename "$f")

  # Sibling-skill links: ../<name>/SKILL.md
  while IFS= read -r match; do
    target=$(echo "$match" | grep -oE '\.\./[a-z0-9_-]+/SKILL\.md' | head -1)
    [ -z "$target" ] && continue
    target_name=$(echo "$target" | sed -E 's|^\.\./([^/]+)/SKILL\.md$|\1|')
    if [ -z "${SKILL_NAMES[$target_name]:-}" ]; then
      broken_lines+=("$basef -> sibling skill link: ../${target_name}/SKILL.md  (no such skill)")
      broken_count=$((broken_count + 1))
    fi
  done < <(grep -oE '\.\./[a-z0-9_-]+/SKILL\.md' "$f" 2>/dev/null || true)

  # Plan refs in body: <plan-name>.plan.md (excluding self-references).
  while IFS= read -r match; do
    plan_name=$(printf '%s' "$match" | sed -E 's|^.*/||; s|\.plan\.md$||')
    [ -z "$plan_name" ] && continue
    [[ "$basef" == "${plan_name}.plan.md" ]] && continue
    if [ -z "${PLAN_NAMES[$plan_name]:-}" ]; then
      broken_lines+=("$basef -> plan ref: ${plan_name}.plan.md  (no such plan)")
      broken_count=$((broken_count + 1))
    fi
  done < <(grep -oE '[a-z0-9_-]+\.plan\.md' "$f" 2>/dev/null || true)

  # related_skills front-matter list values
  awk '
    /^---$/ { c++; if (c == 2) exit; next }
    c != 1 { next }
    /^related_skills:[[:space:]]*$/ { capture = 1; next }
    capture && /^  - / { sub(/^  - /, ""); print; next }
    capture && !/^  / { capture = 0 }
  ' "$f" | while IFS= read -r skill_name; do
    [ -z "$skill_name" ] && continue
    skill_name=$(echo "$skill_name" | sed -E 's/^"(.*)"$/\1/')
    if [ -z "${SKILL_NAMES[$skill_name]:-}" ]; then
      echo "$basef -> related_skills front-matter: ${skill_name}  (no such skill)" >> /tmp/_audit_crossrefs_broken.tmp
    fi
  done
done

if [ -s /tmp/_audit_crossrefs_broken.tmp ]; then
  while IFS= read -r line; do
    broken_lines+=("$line")
    broken_count=$((broken_count + 1))
  done < /tmp/_audit_crossrefs_broken.tmp
fi
rm -f /tmp/_audit_crossrefs_broken.tmp

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

printf 'Cross-reference audit — %s\n' "$(date -u +'%Y-%m-%d %H:%M:%S UTC')"
printf '%s\n' '----------------------------------------------------------------'
printf 'Catalog:  %d skills · %d plans\n' "${#SKILL_NAMES[@]}" "${#PLAN_NAMES[@]}"
printf 'Scanned:  %d files\n\n' "$files_scanned"

if [ "$broken_count" -eq 0 ]; then
  printf 'Broken references: 0  OK\n'
else
  printf 'Broken references: %d  FAIL\n\n' "$broken_count"
  printf 'BROKEN REFERENCES:\n'
  printf '%s\n' "${broken_lines[@]}" | sort -u | sed 's/^/  /'
  printf '\nTo fix: open each file and either correct the target name or remove\n'
  printf 'the dangling reference.\n'
fi

if [ "$STRICT" -eq 1 ] && [ "$broken_count" -gt 0 ]; then
  exit 1
fi
exit 0
