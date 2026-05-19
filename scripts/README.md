# Audit scripts for Cursor rules and skills

Reference implementations of the audit scripts referenced from
[`docs/effective-cursor-rules-and-skills.md`](../docs/effective-cursor-rules-and-skills.md).

Each script is standalone, MIT-licensed, and configurable via environment
variables — drop it anywhere on `PATH` (or into your team's `.cursor/rules/`
folder) and run it.

| Script | Purpose | Run periodically? |
|---|---|---|
| [`_audit_globs.sh`](_audit_globs.sh) | Verify every `globs:` entry in `~/.cursor/rules/*.mdc` matches at least one real file | Yes — weekly, plus in any PR that renames source directories |
| [`_audit_crossrefs.sh`](_audit_crossrefs.sh) | Verify every sibling-skill markdown link, every plan-file reference, and every `related_skills:` front-matter entry resolves to a real target | Yes — after editing any skill `description:` or `related_skills:` |
| [`_check_project_md_staleness.sh`](_check_project_md_staleness.sh) | Compare every `PROJECT.md`'s mtime against commit cadence in its enclosing dir; flag 🟢 / 🟡 / 🔴 verdicts. Defends against narrative rot at agent velocity. | Yes — weekly (or invoked by the `monthly-review` skill) |

## Quick start

```bash
# Default config: scan ~/.cursor/rules and ~/.cursor/skills and ~/.cursor/plans
bash _audit_globs.sh
bash _audit_crossrefs.sh

# PROJECT.md staleness (scans ~/Codebase/* for PROJECT.md, no config needed)
bash _check_project_md_staleness.sh                # human-readable report
bash _check_project_md_staleness.sh --quiet        # only print when stale
bash _check_project_md_staleness.sh --json         # machine-readable

# Strict mode for CI:
bash _audit_globs.sh --strict                      # exit 1 if any glob is dead
bash _audit_crossrefs.sh --strict                  # exit 1 if any cross-ref is broken
bash _check_project_md_staleness.sh --strict       # exit 1 if any PROJECT.md is 🔴 stale
```

## Configuration

Both scripts honor environment variables so you can point them at non-default
locations:

| Variable | Default | What it controls |
|---|---|---|
| `CURSOR_RULES_DIR` | `~/.cursor/rules` | Where `_audit_globs.sh` finds `*.mdc` files |
| `CURSOR_AUDIT_ROOTS` | `$HOME` + every direct child of `~/Codebase/` | Extra workspace roots `_audit_globs.sh` resolves globs against |
| `CURSOR_SKILL_ROOTS` | `~/.cursor/skills` | Where `_audit_crossrefs.sh` looks for skill directories (each containing one `SKILL.md`) |
| `CURSOR_PLAN_ROOTS` | `~/.cursor/plans` | Where `_audit_crossrefs.sh` looks for `*.plan.md` files |
| `CURSOR_RULE_ROOTS` | `~/.cursor/rules` | Where `_audit_crossrefs.sh` looks for `*.mdc` files |

Multiple paths in any of these are colon-separated, e.g.:

```bash
CURSOR_SKILL_ROOTS="$HOME/.cursor/skills:$HOME/code/our-team-plugins" \
  bash _audit_crossrefs.sh
```

## Requirements

- Bash 4+
- Python 3.8+ (only `_audit_globs.sh` requires it)
- ripgrep (`rg`) is **not** required by these scripts, but is recommended for
  the related ad-hoc snippets in the main doc.

## Why these scripts exist

If you skip the doc context: the rule-and-skill discoverability problem is
that rules with stale globs and skills with broken cross-references look fine
on disk but silently never reach the agent. Both scripts surface that decay
so you can fix it before it leads to a slipped mandate.

See [`docs/effective-cursor-rules-and-skills.md`](../docs/effective-cursor-rules-and-skills.md)
for the full backstory.
