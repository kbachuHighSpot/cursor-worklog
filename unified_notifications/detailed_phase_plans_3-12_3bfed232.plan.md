---
name: Detailed Phase Plans 3-12
overview: Create detailed implementation plans for Phases 3-12 of the notification rules master plan, each at the same depth as Phase 2 (code snippets, file lists, risks, cross-phase foundations), and update the master plan to reference each.
todos:
  - id: phase-3
    content: "Create detailed plan for Phase 3 (REST API: manage rules)"
    status: completed
  - id: phase-4
    content: "Create detailed plan for Phase 4 (REST API: send notifications)"
    status: completed
  - id: phase-5
    content: Create detailed plan for Phase 5 (Admin UI)
    status: completed
  - id: phase-6
    content: Create detailed plan for Phase 6 (Groups)
    status: completed
  - id: phase-7
    content: Create detailed plan for Phase 7 (Email content overrides)
    status: completed
  - id: phase-8
    content: Create detailed plan for Phase 8 (Delivery guards + batching windows)
    status: completed
  - id: phase-9
    content: Create detailed plan for Phase 9 (Non-email content overrides)
    status: completed
  - id: phase-10
    content: Create detailed plan for Phase 10 (Slim config + universal records)
    status: completed
  - id: phase-11
    content: Create detailed plan for Phase 11 (Performance)
    status: completed
  - id: phase-12
    content: Create detailed plan for Phase 12 (Test automation)
    status: completed
  - id: update-master
    content: Update master plan to reference all detailed plans and fill cross-phase gaps
    status: completed
isProject: false
status: complete
---

# Detailed Phase Plans (3-12)

Each plan follows the same structure as Phase 2: architecture, code snippets, file lists, specs, risks, and cross-phase considerations. Below is what each plan will cover, informed by codebase research.

## Phase 3 -- REST API: Manage Notification Rules

- Padrino controller patterns: `Api.controllers :notification_rules, provides: :json`
- CRUD routes: `map: "v1/notification-rules"` and `"v1/notification-rules/:name/overrides"`
- Auth: `validate_user`, `validate_domain(user, :manage)`, `halt 403`
- Presenter: `NotificationRulePresenter` with `to_list_output` / `to_detail_output`
- Validation: `parse_json_body`, field validation helpers
- Audit: `Logging::ActivityLog.record_input` + `AuditEvents.audit` for mutations
- Pagination: `page`/`per_page` params
- Files: controller, presenter, validation helpers, spec
- Cross-phase: This API is consumed by Phase 4 (send endpoint) and any future external integrations. Phase 5 (admin UI) uses the Magma entities page directly, not this API.

## Phase 4 -- REST API: Send Notifications

- Single endpoint: `POST v1/notifications/send`
- Delegates to `NotificationEngine.notify` (from Phase 2)
- Multi-recipient support: loop over `to` array
- Idempotency: Redis key with 24h TTL using `CacheHelper.set_in_cache`
- Auth: service account / API key only (S2S via `Hspt::Kubernetes::ServiceIdentityAuth`)
- Rate limiting: `Hspt::Http::RateLimiter` pattern (Redis INCR+EXPIRE)
- Async: `Pipeline::Client.enqueue_job` for async delivery, return 202
- Files: controller, `NotificationApiService`, spec

## Phase 5 -- Admin UI (Magma Entities Page)

Phase 5 is NOT a new React UI. It uses the existing Magma admin entities page (`/entities`) which is:
- Server-rendered Hiccup HTML in `api/controllers/entities.clj`
- Read-only: list collections, view/filter documents, download results (no edit/delete in UI)
- Access: `backend_engineer` role (and other operator roles with `:entities` right)
- Collections already registered: `notification_rules` and `notification_rule_overrides` entries already exist in the `collections` map with `:find`, `:dates`, `:links`, `:relations`
- Search: simple mode (per-field text input) + advanced mode (raw EDN Mongo filter)

**What Phase 5 adds:**
- Enhance the `:find` fields if needed (e.g., add `delivery_strategy.channels`, `delivery_strategy.priority` as filterable fields)
- Add `:links` for cross-collection navigation (e.g., from override's `rule_name` to the rule)
- Add `:relations` so viewing a rule shows its overrides
- Consider adding edit/update capability to the entities controller if admin rule editing is needed (currently read-only)
- Files: modify `entities.clj` collections map, potentially add update routes

## Phase 6 -- Groups (Recipient Scoping)

- Schema: `recipient_groups` on `NotificationRule` (`mode: "none"|"intersect"|"expand"`, `group_ids: []`)
- Router integration: group filtering before channel dispatch
- Uses `UserQueries.active_users_for_group(domain, group_id)` and virtual groups
- Engine modification: resolve recipients per group before per-user notify calls
- Files: modify rule entity, resolver, router, engine; add spec

## Phase 7 -- Email Content Overrides

- Leverages `resolved_content_overrides` from Phase 2's resolver (foundation already laid)
- Merge flow: builder produces defaults -> override fields replace subject/preheader/body_sections
- `{{variable}}` interpolation with per-kind allowlists
- Preview endpoint for Phase 5 Admin UI
- Builder modification: `build_email_data` accepts override hash
- Files: modify resolver, `SemanticEmailRenderer`, builders, preview endpoint; add spec

## Phase 8 -- Delivery Guards + Batching Windows

- Guard evaluator pipeline: actor suppression -> dedup -> throttle -> delivery window -> dispatch
- Redis patterns: `CacheHelper` for dedup keys (SET+TTL), `RateLimiter`-style INCR+EXPIRE for throttle
- Delivery window: check recipient timezone, defer via `Pipeline::Client.enqueue_job` with `queue_delay`
- Batching windows: `aggregation_window` field on digest rule, update `send_alerts_job` cutoff logic
- Files: `NotificationGuardEvaluator`, per-guard classes, modify router + send_alerts_job; specs

## Phase 9 -- Non-Email Content Overrides

- Extends Phase 7 pattern to push, Slack, MS Teams
- Push: override `PushNotificationAlertPresenter` title/body from `content_overrides.push`
- Slack: override `SlackAlertPresenter` text/blocks from `content_overrides.slack`
- MS Teams: override `MsteamsAlertPresenter` title/message from `content_overrides.ms_teams`
- In-app: override `AlertPresenter` message from `content_overrides.in_app`
- Files: modify each presenter, extend override schema, update resolver; specs

## Phase 10 -- Slim Legacy Config + Universal Records

- Remove routing fields from `ALERT_CONFIG` (145 `send_immediately`, 27 `no_email`, 12 `group_email`, etc.)
- Remove `AlertPublisher` + channel listeners (replaced by `NotificationChannelRouter`)
- Remove Velocity `.vm` templates (replaced by semantic MJML)
- Migrate direct email `send_*` methods to `NotificationEngine.notify` (universal records)
- CI lint: prevent new routing fields in `ALERT_CONFIG`
- Files: modify alert_commands, email_commands, remove listeners/templates; add lint rule

## Phase 11 -- Performance and Scalability

- Replace Phase 2's in-memory TTL cache with Redis-backed rule cache
- Load test scripts (k6): immediate burst, digest batch, API send, mixed workload
- SLO targets: `NotificationEngine.notify` p99 < 200ms, resolver p99 < 10ms (cache hit)
- Pipeline worker sizing for notification dispatch
- Redis capacity planning for guard state
- Files: k6 scripts, benchmark specs, cache upgrade, SRE runbook

## Phase 12 -- Test Automation (Playwright + Mailinator)

Tests are added to the existing **[test_automation_playwright](https://github.com/highspot/test_automation_playwright)** repo (local: `/Users/kiran.bachu/Codebase/test_automation_playwright`). Not a new test framework.

**Repo structure (key paths):**
- `playwright/` -- Node project root (package.json, playwright.config.ts)
- `playwright/tests/` -- test specs organized by crew/feature
- `playwright/pages/` -- page objects
- `playwright/helpers/` -- auth (SignIn.as), feature flags, inbox registry
- `playwright/apiHelpers/` -- Nutella API, Mailinator API clients
- `.buildkite/playwright/` -- CI pipeline configs

**Mailinator client (already exists):**
- `playwright/apiHelpers/mailinatorApis/MailinatorClient.ts` -- wraps `mailinator-client` npm package
- Key methods: `getLatestEmail(inbox, maxRetries, delay)`, `getLatestEmailBody(inbox, msgId)`, `getEmailLinks(inbox, msgId)`, `deleteInboxMessages(inbox)`
- Domain: `highspot.testinator.com`
- API key: env var `MAILINATOR_API_KEY` (1Password "E2E testing" vault; Buildkite reads from SSM)
- Polling: `getLatestEmail` retries up to 5x with 30s delay, OR `expect.poll` with 60s timeout (preferred)

**Inbox registry:**
- `playwright/helpers/mailinatorInboxes.ts` -- static class with named inboxes per crew (IAM, TAndC, BUYE)
- Add `NotificationRules` section with dedicated inboxes for notification tests

**Existing patterns to follow:**
- `playwright/tests/buyersEngagement/Alllowlist/Allowlist.spec.ts` -- `expect.poll` + `getLatestEmail` + `getLatestEmailBody` + regex code extraction (best polling pattern)
- `playwright/tests/iam/emailVerificationTests/signupE2Etest.spec.ts` -- `SignupPageObject.retrieveDataFromSignupEmail` + link extraction + `deleteInboxMessages` cleanup
- `playwright/tests/tim/course/courseNotificationsEnabled.spec.ts` -- course notification email verification
- Confluence: [Email Verification Tests](https://highspot.atlassian.net/wiki/spaces/ENGDOCS/pages/3494739978/Email+Verification+Tests)

**Test structure patterns:**
- `test.describe` with `{ tag: TestTags.<CREW>_LATEST_SU1_BATCHn }`
- `test.beforeEach` -> `SignIn.as(UserRoles.admin, browser)`
- Unique inbox per test: `inboxName + faker.number.int(100000)`
- `test.afterEach` / `finally` -> `Mailinator.deleteInboxMessages(inbox)`
- Auth: `SignIn.as(role, browser)` loads storageState + initializes feature flags
- Test data: `NutellaApi.*` helpers for creating test entities

**Notification rules test scenarios:**
- Immediate alert email (share item with rules FF on, verify subject + body + links via Mailinator)
- Digest email (trigger multiple alerts for digest-eligible kind, wait for batch, verify single digest email)
- Direct email (welcome/invite with rules FF on, verify rule gating)
- Channel suppression (rule with email removed from channels -- verify NO email within timeout)
- Override email (domain override changes delivery strategy, verify effect)
- Negative test: push-only kind -- verify no email delivered within timeout

**Files to create/modify:**
- `playwright/helpers/mailinatorInboxes.ts` -- add `NotificationRules` inbox entries
- `playwright/tests/notifications/` -- new test directory for notification rules specs
- Buildkite pipeline YAML for notification rules batch (must include `MAILINATOR_API_KEY` from SSM)
- Tag tests appropriately for crew + batch (e.g., `@Crew.AppPlatform`, `@Batch.Batch2`)

**CI integration:**
- Buildkite pipeline step injects `MAILINATOR_API_KEY` from SSM (pattern: `buyer-engagement-nightly.yml`)
- Tests tagged for correct batch that has Mailinator access
- Nightly schedule recommended (not on every PR -- Mailinator rate limits)

**Existing local E2E tools (in nutella, complement not replace):**
- `scripts/notifications-migration/test_email_previews.py` (preview + send + mailpit)
- `tasks/semantic_email_test.rake` (send_alert, send_alerts, send_email)
- Existing E2E plan: `/Users/kiran.bachu/Codebase/cursor-worklog/unified_notifications/semantic_email_e2e_plan_057e0eb7.plan.md`

## Cross-Phase Gap Analysis

During plan creation, I'll check each phase for:
- Dependencies on earlier phases (are the foundations already laid?)
- Schema changes that affect multiple phases
- API contracts that later phases consume
- Test infrastructure that spans phases
