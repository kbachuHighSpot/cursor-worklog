# PROJECT pointer (not the canonical PROJECT.md)

The canonical narrative anchor for the semantic-email + notification-rules
effort lives **in the nutella repo** (so it's discoverable to all engineers
working in `web/common/email/`, can be updated in the same PR as code, and
participates in normal PR review).

**Canonical:**
[`highspot/nutella` → `web/common/email/PROJECT.md`](https://github.com/highspot/nutella/blob/main/web/common/email/PROJECT.md)
(local: `/Users/kiran.bachu/Codebase/latest/nutella/web/common/email/PROJECT.md`)

**This directory's role.** `cursor-worklog/unified_notifications/` holds:

- Live, machine-generated phase status: [`STATUS.md`](STATUS.md)
- The master plan and per-phase plan docs: `*.plan.md`
- This pointer

The canonical `PROJECT.md` *links to* these plan docs and to `STATUS.md`,
not the other way around. If you add a new sub-plan here, link it from
`PROJECT.md` §6 (Pointers).

**Staleness check** (run weekly or wire to cron):

```bash
bash /Users/kiran.bachu/Codebase/cursor-worklog/scripts/check_project_md_staleness.sh
```
