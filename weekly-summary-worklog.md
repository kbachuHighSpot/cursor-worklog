# Weekly Work Log

This log tracks weekly summaries of significant work across all sources (Cursor, GitHub, Jira, Slack, Confluence, Google Drive).

## Running Summary

*Last updated: 2026-05-04*

### Overall Key Accomplishments (Jan-May 2026)

**Significant Cursor Activities:**
- **Nutella MCP Hackweek Build-Out (Apr 23 – May 1)**: Drove the Mission Autonomous Nutella MCP project end-to-end. Created the `nutella-mcp` repo and synthetic-data seeder, shipped pitch tools, then ran a 6-month gap analysis (commits + Jira HISPI + Slack) to prioritize new tools. Closed ~10 of the gaps the same week — admin endpoints for spot + domain notification settings, SMTP relays, item processing status, reprocess polling, unsubscribe lookup, and a full feature-flag suite (`get_feature_flag_status` v2.0 → v2.1 with Mongo+LD+EvaluationReason, `list_enabled_features` `include_launchdarkly` opt-in, new `get_launchdarkly_flag_details` admin tool). Fixed two latent toolkit bugs along the way (array query-param encoding, dropped `static_query`). Tool surface grew from ~50 → ~65 HTTP tools; refreshed architecture docs and proposal so a new reader can land on either and get the correct picture. Added `debug-item-processing` skill packaging the diagnostic playbook from a real "unreadable item" investigation.
- **Notification Rules System Implementation (Apr 18-27)**: Built complete Phase 1-3 implementation of unified notifications. Seeded ~382 notification rules from ALERT_CONFIG + EMAIL_SETTINGS (Apr 18). Created NotificationEngine with rules-first routing, NotificationRuleResolver with thread-safe caching and defensive copying (Apr 26). Built Phase 3 REST API (9 endpoints) with operator authorization and audit logging (Apr 27). Implemented Phase 5 magma admin UI consuming the REST API.
- **Semantic Email Migration (Feb-Apr)**: Built complete MJML-based rendering system replacing ~450 legacy Velocity templates. Designed EmailContentBuilder module split + auto-derived `_v2` architecture (Mar 12). Migrated all builders to self-registration pattern with `SemanticAlertRenderer.register` (Mar 26). Introduced Hashie::Dash typed data classes across 27 builders (Apr 8-14). Fixed IndifferentAccess mutation bug (94 failures). Wrapped 16 builder files with `Hspt::Intl.t()` for i18n (Apr 8). Created automated preview test coverage for all kinds (Mar 29). Architected 3-PR split strategy for the 71-file PR.
- **Notification Rules System Design (Mar-Apr)**: Developed PM-editable template text plan with i18n tradeoff analysis (Mar 14). Created detailed phase plans (3-12) with architecture diagrams, code snippets, and cross-phase dependencies (Apr 25). Extended to multi-channel scope with phased REST APIs (Mar 29).
- **CDN Infrastructure (Jan-Mar)**: Set up CDN Lambda local dev environment with Python standards and CI pipeline (Feb 17-19). Investigated cache invalidation feasibility (Mar 8). Analyzed CDN caching paths and Lambda memory for cache sizing (Mar 19).
- **Content CDN Alert Redesign (Mar 30)**: Implemented per-status-code CloudFront error rates with distribution-level faceting, Lambda duration alerts with region faceting, and Opsgenie integration in Terraform.
- **Region Settings Bug Fix (Mar 10)**: Fixed high-severity bug where PUT handler for content regions wiped all regions when `regions` key omitted.
- **Feature-Flag Observability (Apr 5)**: Added OTel counter `semantic_email_flag_check_count` and `EventLogger.error` for FF routing visibility after investigating why legacy emails slipped through.
- **Developer Tooling**: Built email preview endpoint, automated comparison script, `SEMANTIC_VS_LEGACY.md` and `ALERT_CONFIG_TO_SEMANTIC_MAPPING.md` reference docs (Mar 29). Planned Admin "Notifications" menu (Mar 17). Built AI-assisted work logging with weekly MCP review skill. Enhanced worklog rules/skills with mid-session logging, end-of-conversation checks, and expanded significance criteria (Apr 6).
- **Execution Plan Document**: Created and shared semantic email migration execution plan with Nathan and Nav (Mar 17), updated and re-shared (Apr 17).

**Significant Proposals:**
- Nutella-MCP gap-analysis canvas (Apr 28): top 10 issue themes ranked by ticket-volume × commit-volume × MCP-coverage gap, plus 8-card recommended build order (P0–P3). Used to drive the hackweek tool build-out.
- Recommended adding a dedicated LD admin-API tool (`get_launchdarkly_flag_details`) instead of fanning out `get_feature_flag_status` across all 168 LD flags (Apr 29) — saved ~84k tokens of MCP responses for thin data and surfaced rules/targets that Path A genuinely cannot expose.
- Shared NUTELLA_MCP_PROPOSAL with Nav for review (Google Docs, Apr 13)
- Proposed PR2/PR3 split plan in #crew-app-platform, negotiated scope with Derek and Rohit
- Nutella MCP task list spreadsheet shared with Nav, Neng, Sanket, Ankita (Apr 23-27)

**Significant Documents:**
- Hackweek Nutella MCP demo video + presentation deck delivered to Mission Autonomous Showcase (Google Drive, May 1).
- Nutella-MCP Gap Analysis — Top 10 Issues (Apr 2026) Google Doc (Apr 29), companion to the canvas.
- Nutella MCP task list + Hackweek Team Sync doc shared with Nav, Sanket, Neng, Ankita (Apr 23 – Apr 30).
- Refreshed `docs/agent-toolkit-plan.md` and `docs/proposal.md` in nutella-mcp (Apr 29) — now reflect the shipped ~65 HTTP tool surface, both LD auth paths (SDK key vs admin token), and the recent toolkit fixes.
- `GAP_ANALYSIS.md` synced into nutella-mcp from the gap-analysis canvas (Apr 29) with a sync rule so the markdown stays in lockstep with the canvas.
- Content CDN Alerts Runbook (Confluence ENGDOCS, Nov 2025)
- CDN local dev setup guide (Confluence ENGDOCS, Feb 2026)
- Notifications System tech spec (Confluence ENGDOCS)
- `SEMANTIC_VS_LEGACY.md` and `ALERT_CONFIG_TO_SEMANTIC_MAPPING.md` reference docs (Mar 29)
- Email notifications migration data spreadsheet (Google Sheets, Apr 14-22)
- Notifications Platform CS1 Foundations PLT presentation (Google Slides, updated Apr 15)
- [Semantic Email Migration Execution Plan](https://docs.google.com/document/d/1pjUIO1WUq2x64tFf60U7FnO-r5Zhb7O5MPrOUKOQDqE/edit) (created Mar 17, updated Apr 20)
- NUTELLA_MCP_PROPOSAL (Google Doc, shared with Nav, Apr 10-23)
- Notification Rules - Legacy to Rules Migration Mapping (Google Sheets, Apr 18-20)
- Contributed to Mission Autonomous Spring 2026 sign-up and Engineering Demos & Updates pages (Confluence, Apr 23-27)

**Significant Helping Others:**
- Reviewed Nathan Wang's nutella-mcp #6 (feature-flag and domain-config MCP tools, merged Apr 29) — coordinated handoff with my parallel `get_feature_flag_status` extension to avoid scope overlap.
- 23+ PRs reviewed across crews: Scott Fletcher (6 PRs, region settings), Dylan Kwiatkowski (3 PRs, Buildkite config), Prateek Singhal (2 PRs, VPC S3 access), Mike Coulson (2 PRs, ItemHistory), AMoo-Miki (1 PR, AWS SSO)
- Reviewed nutella-mcp initial setup PR #3 (merged Apr 23)
- Reviewed magma Tiltfile setup PRs #8771 and nutella #70226 (Apr 23)
- **CDN/S3/KMS Key Mismatch Investigation (Apr 21-27)**: Extensive cross-crew troubleshooting in #crew-content-ingestion-consumption and #crew-meeting-intelligence. Identified regression where meetings objects using aws:kms encryption fail CDN path. Proposed fix (reprocess + stop using aws:kms), shared old Ruby script for detecting affected objects, escalated to Akhil Gudipally and Jyothi Muddala.
- Asked Anudeep to review notification rules PRs #69976 and #70041 in #eng-foundation
- Flagged BSON `NilClass` error in MeetingDeliveryFeedback processing to MI crew
- Together-mode email privacy analysis -- identified first-recipient context leak in `MailWorker.java` (Mar 10)
- Asked in #eng-launchdarkly about DynamicConfig + LaunchDarkly integration patterns

**Significant PRs:**
- **Notification Rules (4 stacked PRs)**: PR #70041 (seed 382 rules, merged Apr 22) -> PR #70323 (backfill push channel, merged Apr 27) -> PR #70320 (NotificationEngine Phase 2, open) -> PR #70329 (Phase 3 REST API, open). Magma PR #8831 (admin UI).
- **Nutella MCP — Hackweek build-out**: nutella-mcp #1 (CONTRIBUTING.md, merged Apr 23), #4 (synthetic data seeds), nutella #70368 (sortby mapping), ai-services #2920 (pitch tools); plus ~10 direct commits to `hackweek/nutella-mcp` (ai-services) and `hackweek-nutella-mcp` (nutella) shipping notification-settings endpoints, feature-flag suite, GatewayInvoker bug fixes, MCP seeder defaults to `local@highspot.com` domain with auto-grant, and `static_query` fix for `list_spots`.
- **Semantic Email Migration (3 stacked PRs)**: PR1 #69502 (legacy templates, merged) -> PR2 #69507 (27 builders + preview, 65 files, merged Apr 16) -> PR3 #69595 (integration layer: routing/metrics/FF, merged Apr 17). Original PR #67262 was 71 files spanning 3 months.
- **CDN Cache Invalidation (HS-159835)**: nutella #68979 (reprocess invalidation, merged Mar 31), terraform #5171 (latest su0 policy, merged Apr 7), tf-scale-unit-base #182 (base policy, merged Apr 7), terraform #5200 (all SUs rollout, merged Apr 7)
- **CDN Lambda Mem Optimization**: PR #3 (content-cdn-lambda-handler, 99.6% cache reduction, merged Mar 10) + PR #4 (retry logging, merged Mar 13) + terraform version bumps
- **CDN Lambda Local Dev Setup (HS-157970)**: 11 commits (Feb 17-19), precommit hooks, CI pipeline, Python styling, Zscaler proxy fix
- **Region & Language Settings**: 4 nutella PRs merged Mar 4-6, designed API contracts with Scott Fletcher
- **CDN Alerts Redesign**: 4 tf-newrelic-alert PRs (granular per-code alerts, distribution faceting, Opsgenie, false positive reduction, Jan-Apr) -- including #891 (false positive reduction, merged Apr 2)
- **Magma MailWorker (PR #8469)**: Pre-rendered HTML support for semantic emails, merged Apr 2
- **Bug Fixes**: HCL-10295 (alerts pagination #70005, merged Apr 21), HISPI-12550 (timezone display #69639, Deployed Apr 27), #70111 (email logo centering, merged Apr 22)

**Significant Jira Tickets:**
- HS-180217: Seed notification rules collection (P3, Code Review -> merged)
- HS-180222: NotificationEngine Phase 2 (P3, Code Review)
- HS-180223: Phase 3 REST API + Admin UI (P3, Code Review)
- HS-179437: Notifications CS1 Foundations (P1, In Dev) -- epic-level work
- HS-181943: Summer Preview Localization (P1, To-Do)
- HCL-10295: Alerts pagination bug (P3, In Test)
- HISPI-12550: Timezone display bug (P2, Deployed)
- HS-155824: email_tracking_details_v1 slow query (P2, To-Do)

### Overall Key Challenges
- Hackweek tool-surface expansion exposed several latent toolkit bugs: array query params silently encoded as Python list repr (`?ids=['a']`); `static_query` field declared in specs but missing from `GatewayConfig` model so values were dropped; `list_spots` consequently returned only owner-scope spots even when the seed data was correct.
- LD admin REST API vs SDK conflation: built `get_launchdarkly_flag_details` (admin token) before realizing the LD SDK already exposes `EvaluationReason` per-context — the right default for "why is X off for me?" is the cheaper SDK path. Both tools kept; documented when to use each.
- MCP seed silent-failure: seeder ran in `local.test` but `local@highspot.com` lives in `highspot.com`, so every MCP `list_*` call returned nothing despite "successful" seed runs. Fixed by defaulting to the target user's actual domain and auto-granting access at the end of the orchestrator.
- Semantic email migration touches deeply interconnected systems (AlertPresenter, EntityCache, ALERT_CONFIG, i18n) -- broad changes like fallback removal cascade into 90+ failures requiring iterative debugging
- PR size management -- the original 71-file PR couldn't be reviewed effectively; splitting into 3 PRs required careful dependency analysis of cross-file references
- Mock data vs production code tension -- preview mock data format must exactly match what AlertPresenter expects for entity resolution, discovered through multiple rounds of breakage
- Hashie::Dash `IndifferentAccess` silently mutates caller's hashes, requiring `deep_dup` workaround (94 failures before fix)
- NotificationRuleResolver cache pollution: returning cached rule by reference allowed callers to mutate shared state -- fixed with `dup_rule` deep-copying delivery_strategy, trigger, eligible_alert_kinds, metadata (Apr 27)
- Ruby 3 RSpec argument matching: `expect(...).to receive(...).with(:key => val)` interpreted as keyword args instead of positional hash -- fixed with explicit braces `.with({ :key => val })` (Apr 27)
- MRML gem cross-platform (darwin/linux) Bundler resolution issues slowed CI (Mar 26)
- `Hspt::Intl` static string reader rejects dynamic i18n key patterns -- required workarounds for `expiry_digest_builder` (Mar 17)
- Buildkite failures from duplicate i18n keys across builders (Mar 29)
- Self-registration load ordering required explicit `require_project` in 7 spec files (Mar 27)
- `Concurrent.global_io_executor` mocks incompatible with MRML rendering in specs -- required `min_spec_helper` switch (Mar 29)
- LaunchDarkly silent `rescue` allowed legacy email fallback to slip through undetected -- required OTel metrics for visibility (Apr 5)
- Alerts pagination regression: `collapsed: true` (PR #69640) activated Solr grouping on a non-existent field, returning only 1 result; original `collapse: true` was always a no-op due to key typo (Apr 16)
- Worklog automation gap: migration scripts and investigations weren't auto-logged because rules lacked specific significance criteria and mid-session logging instructions (Apr 6)

### Current Focus (This Week)
- **Nutella MCP polish post-hackweek**: Wrap up follow-ups from the gap-fill week — restart the running MCP server to pick up `static_query` and feature-flag-suite changes, investigate why `Private Test Spot` isn't returned by `with_right(user, "view")`, add regression test in `test_invoke_gateway.py` for `static_query` merge precedence.
- **Notification Rules Phase 2+3**: NotificationEngine with rules-first routing (#70320) and REST API (#70329) still in code review, addressing Bugbot comments.
- **Phase 5 Admin UI**: Magma entities view + Hiccup admin controller consuming Phase 3 REST API.

### Current Blockers
- GitHub MCP auth broken -- using `gh` CLI as fallback
- Slack `slack_search_public` doesn't surface messages from private channels (e.g. `#temp-hackwk-nutella-mcp`); use `slack_search_public_and_private` for hackweek/team channels
- HS-151210 (Pinterest font request) remains Blocked

---

## 2026-05-04 - Weekly Review (2026-04-27 to 2026-05-04)

**Summary:**
Mission Autonomous hackweek dominated the week — used the nutella MCP gap analysis from Apr 28 to drive a tightly-scoped tool build-out: ~10 new specs/tools shipped, two latent agent-toolkit bugs fixed, a much smarter feature-flag suite (Mongo + LaunchDarkly + EvaluationReason in one MCP call), and a fixed seeder + `list_spots` behavior so `local@highspot.com` actually sees the synthetic data. Architecture docs and proposal refreshed to match. Notification rules work continued in the background — Phase 3 REST API PR #70329 still iterating on Bugbot, plus a new task ticket for channel routing in the rule definition (HS-180222).

### Significant Cursor Activities
- **Nutella-MCP gap analysis (Apr 28)**: Triangulated 6 months of nutella commits (~6.4k), ai-services commits (~1.6k), Jira HISPI escalations (50 most recent), and Slack support/triage channels. Built a Cursor canvas with a 5-stat header, top-10 ranked theme table, 8-card recommended build order (P0–P3), and explicit "where MCP doesn't help" callout. Top gaps: content/item processing, email delivery/SMTP relays, analytics/scorecards (zero coverage). Strongest area: permissions/access.
- **Notification settings endpoints + specs (Apr 28)**: Closed two persona gaps with `GET /api/v1/admin/spots/:spot_id/notification_settings` and `/admin/domains/:domain_id/notification_settings`. Both follow the existing admin-agent service-identity auth pattern; `domain_id` endpoint includes a `present` flag per `NotificationsConfig::Type` so callers can distinguish "unset / defaults applied at runtime" from "explicitly stored config".
- **4 quick-win MCP specs (Apr 29)**: `get_smtp_relays`, `get_item_processing_status`, `check_reprocess_done`, `check_unsubscribes`. All wrapped existing nutella endpoints; documented HTTP 202 polling semantics for reprocess and the "POST is a read-only batch lookup" caveat for unsubscribes. MCP-exposed tool count moved 50 → 54.
- **Extended `get_feature_flag_status` to v2.0.0 (Apr 29)**: Now answers "is feature X actually on right now?" by consulting MongoDB (`FeatureCache`) and LaunchDarkly (`Hspt::Features::FlagService` + `Manager`), not just `features.yaml`. Backwards-compatible — top-level `status` field preserved; new optional `userId`/`domainId` params with conditional auth (self-lookup needs only auth; lookups for others require `Operator::RIGHT_FEATURES`).
- **Array query-param encoding fix in agent-toolkit (Apr 29)**: Root-caused `list_enabled_features({ids:[...]})` always returning `400 "Invalid feature IDs supplied."`. `GatewayInvoker._build_request` was calling `urlencode()` without `doseq=True`, so `["a", "b"]` became `?ids=['a','b']`. Fixed with Rails/Rack bracket notation (`ids[]=a&ids[]=b`); 171 tests still pass with two new regression tests.
- **`list_enabled_features` `include_launchdarkly` opt-in (Apr 29)**: Without it, `:off_only_mongo` evaluation mode (current default for `highspot.com`) hides LD-only flags like `mjml_email_templates`. New optional bool unions `FlagService.for_user(user)` into the response so the MCP can reflect the true enabled set.
- **New `get_launchdarkly_flag_details` MCP tool (Apr 29)**: Wraps `Hspt::Features::LaunchDarklyApi::FlagManagement.get_flag_details` and normalizes the per-environment block into `variations`, `fallthrough`, `off_variation`, `individual_targets`, `rules` (with clauses + percentage rollouts), and `prerequisites`. Auth: `Operator::RIGHT_FEATURES` (read-only but exposes individual targets so it's strictly more sensitive than `get_feature_flag_status`).
- **Architecture docs refresh (Apr 29)**: Rewrote `docs/agent-toolkit-plan.md` end-to-end and added a "Status as of Apr 2026" banner to `docs/proposal.md`. Documents both LD auth paths (SDK key for runtime evaluation vs `LAUNCHDARKLY_API_TOKEN` admin-API token), the now-shipped tool surface, and the recent toolkit fixes.
- **`debug-item-processing` skill (Apr 29)**: After diagnosing a real `unparseable` PDF (`PDFRepairer` exit 1), packaged the playbook as a Cursor skill. 6-phase workflow with decision trees and remediation guardrails (never reprocess `virus`/`drm`/`encrypted`, never reprocess `unparseable` without source replacement). Companion `domain-knowledge.md` covers the pipeline, terminal flag matrix, common `Caused by:` causes, and 5 worked patterns.
- **MCP seeder default-domain + auto-grant (May 1)**: Fixed silent-failure case where the seeder ran in `local.test` but `local@highspot.com` lives in `highspot.com`. New resolution order: `MCP_SEED_DOMAIN` env var → domain of `local@highspot.com` → `highspot.com`/`local.test`/`bedrock.com`/`localhost`. New `step_auto_grant_target_user` step makes the seeded user manager on all spots, member of all groups, collaborator on all pitches, follower of all users, with bookmarks on key items.
- **LaunchDarkly `EvaluationReason` in `get_feature_flag_status` v2.1.0 (May 1)**: While debugging "why is `platform_cdn_public_thumbnails` off for me?" realized the LD SDK already exposes the answer via `LDClient#variation_detail` — no admin token needed. Wired `EvaluationDetail` through `Hspt::Features::FlagService` → handler → MCP response; added `variation_index`, `reason: { kind, rule_index, rule_id, in_experiment, prerequisite_key, error_kind }` plus made `enabled_in_context` the resolved variation *value* (so multivariate flags surface correctly). Diagnostic flow validated against `platform_cdn_public_thumbnails`: `kind: FALLTHROUGH` clearly explains "not in any include rule".
- **`list_spots` static_query fix (May 1)**: Diagnosed why MCP `list_spots` returned only 1 spot for `local@highspot.com` despite seed creating 3. Root cause was a latent toolkit bug — `static_query` field declared in specs was silently dropped because it wasn't on `GatewayConfig` Pydantic model. Added the field to the model, merged into `query_params` before `query_from_input` (so input always wins), and set `"right": "view"` in `list_spots.json` so the controller routes to `with_right(user, "view", ...)` and returns owner + member + public spots.

### Significant Proposals
- Recommended `new_tool` path over fanning out `get_feature_flag_status` across 168 LD flags (Apr 29) — saved ~84k tokens of MCP responses for thin data.
- 8-card recommended build order from the gap-analysis canvas (Apr 28) drove the tool prioritization for the rest of the week.

### Significant Documents
- **Hackweek demo deliverables (Apr 29–May 1)**: "Hackweek project - Nutella MCP" video and presentation (Google Drive, owned by me, shared with Nav, Sanket, Neng, Ankita); "hackweek - nutella-mcp item processing demo" video (Apr 30); final video uploaded to Drive folder Apr 30 with thanks to Nav for polishing.
- **Nutella-MCP Gap Analysis — Top 10 Issues (Apr 2026)** (Google Doc, Apr 29) — companion doc to the canvas, shared with the hackweek team.
- **Nutella MCP task list** spreadsheet (Google Sheets, updated Apr 29) — tracks tool implementation across the team.
- **Nutella MCP Hackweek Team Sync** doc (Apr 30, contributor) — daily sync notes with Nav, Sanket, Neng, Ankita.
- `docs/agent-toolkit-plan.md` (full rewrite) and `docs/proposal.md` (status banner) in nutella-mcp — reflect shipped state + LaunchDarkly support.
- `GAP_ANALYSIS.md` synced from canvas with a sync rule to keep them in lockstep.
- Engineering Demos & Updates (Confluence ENGDOCS, contributed May 4)
- Mission Autonomous (Spring 2026) - Project Ideas & Team Sign-up (Confluence ENGDOCS, contributed May 1)

### Significant Helping Others
- **Hackweek presentation prep with Nav (Apr 29–May 1)**: Active collaboration in `#temp-hackwk-nutella-mcp` and DMs — video editing, narrative tuning, last-minute audio fixes, voiceover recording. Final demo delivered May 1 at the Showcase. Self-noted miss: insufficient end-to-end re-testing after late edits caused volume issue in the final video.
- Reviewed Nathan Wang's nutella-mcp PR #6 — feature-flag and domain-config MCP tools (merged Apr 29). Coordinated handoff with my parallel `get_feature_flag_status` extension to avoid scope overlap.
- Self-review iteration on PR #70329 (Phase 3 REST API) addressing Bugbot comments — `deep_dup` to prevent caller hash mutation in override commands, scope-type validation, Semgrep `nosemgrep` justifications, generic error messages.

### Significant PRs
- **ai-services #2920** (closed Apr 28, replaces #2919): Add MCP pitch tools for nutella-mcp.
- **nutella #70368** (closed Apr 28): Map public API sortby values to internal Apollo values for MCP compatibility.
- **nutella #70329** (HS-180223, still open): Phase 3 notification rules REST API (operator-only) — actively iterating on Bugbot.
- **Direct commits (no PR) to hackweek branches**: ~14 nutella commits + ~14 ai-services commits + 6 nutella-mcp commits + 1 ai-plugins commit shipping the gap-fill tool surface, toolkit fixes, MCP seeder fixes, architecture docs, and debug-item-processing skill. Per user choice — each will land via a real PR before merging out of `hackweek/nutella-mcp`.

### Significant Jira Tickets
- **HS-179437**: Notifications CS1 Foundations (P1, In Dev) — epic-level work continues.
- **HS-180222**: Support channel routing in the Rule definition (Task, P3, In Progress, updated Apr 28) — new task scoped this week.
- **HS-180223**: REST API and Admin Task for NotificationRules (Task, P3, In Progress, updated Apr 28) — PR #70329 still in code review.
- **HISPI-12550**: Email alerts not aligning with users' configured time zones (Bug, P2, **Deployed** Apr 27).

### Key Challenges This Week
- **`urllib.parse.urlencode` without `doseq=True`** silently corrupted any MCP tool with array query params — invisible until you hit a strict `Dry::Schema.Params` controller. Once caught, the fix was small but it had been lying in wait.
- **Conflating LD admin REST API with SDK evaluation**: built `get_launchdarkly_flag_details` (admin token) first, then on day 2 the user's architectural question "why can't Path B take Path A's approach?" surfaced that `LDClient#variation_detail` already returns `EvaluationReason` for free. The admin tool stayed (it answers configuration questions Path A can't), but the SDK path is now the right default for per-context "why?" questions.
- **`static_query` was silently dropped** by `GatewayInvoker` because the field was declared in tool specs but never defined on `GatewayConfig`. Made `list_spots` look like a SpotQueries scoping bug when it was actually an agent-toolkit Pydantic-model gap.
- **MCP seed silent-failure**: seeder defaulted to `local.test` while the MCP server authenticates as `local@highspot.com` (which lives in `highspot.com`), so synthetic data was unreachable. Fixed by detecting the target user's actual domain and auto-granting at the end of the orchestrator. Confirmed live: `list_spots` was returning only "Highspot's Content" (the user's pre-existing real spot) before the fix.
- **RSpec couldn't run locally** all week (bundler env missing gems on this machine); validated via `ruby -c` and JSON-schema checks, used `--no-verify` for hackweek-branch commits per user's call — CI enforcement caught everything I missed.

**Notes:**
- GitHub MCP auth still broken (401 Bad credentials) — used `gh` CLI as fallback for PR data.
- Slack: `slack_search_public` returned 0 results (the `#temp-hackwk-nutella-mcp` channel is private); `slack_search_public_and_private` worked and surfaced the hackweek presentation-prep thread on retry.
- Workato Google Drive: initial call returned `Unauthorized` (transient); retried successfully and pulled the full hackweek deliverable set (video, presentation, task list, gap-analysis doc, team sync doc).
- Atlassian MCP working normally — Jira and Confluence pulled cleanly.
- Carry-over: restart the running MCP server to pick up the new code + spec from the May 1 fixes; investigate why `Private Test Spot` (visibility=private, user is manager) isn't returned by `with_right(user, "view")`; add regression test in `test_invoke_gateway.py` for `static_query` merge precedence.

---

## 2026-04-27 - Weekly Review (2026-04-20 to 2026-04-27)

**Summary:**
Major week for notification rules implementation (Phases 2-3) and Hackweek Nutella MCP project. Landed the seeding migration with push channel backfill, built NotificationEngine with rules-first routing, created the Phase 3 REST API (9 endpoints), and the magma admin UI. Also shipped multiple bug fixes and kicked off Nutella MCP for Mission Autonomous hackweek.

### Significant Cursor Activities
- **NotificationEngine Phase 2 (Apr 26-27)**: Built rules-first routing in NotificationEngine with thread-safe NotificationRuleResolver caching, defensive copying to prevent cache pollution, and NotificationChannelRouter per-channel delivery with isolation. Added `resolve_with_outcome` to distinguish "no rule" from "user opted out" for metrics. Fixed multiple Bugbot findings: extra DB read in update_channels_delivered, raw `from` vs safe `from_user` variable.
- **Phase 3 REST API (Apr 27)**: Created 9-endpoint Padrino controller for notification rules CRUD and overrides management. Introduced `Operator::RIGHT_NOTIFICATION_RULES` for authorization, audit logging, soft/hard delete semantics, pagination with `coerce_limit`/`coerce_offset`, and JSON-bodied form field handling.
- **Phase 5 Admin UI (Apr 26-27)**: Registered notification_rules and notification_rule_overrides in magma admin Entities view. Built full Hiccup admin controller consuming the Phase 3 REST API with rule list, detail editor, override management, confirm prompts for destructive actions.
- **Detailed Phase Plans (Apr 25)**: Created 10 detailed phase plans (3-12) at same depth as Phase 2 plan -- each with architecture diagrams, code snippets, file lists, spec files, cross-phase dependencies, and risks/mitigations. Updated master plan with Mermaid dependency graph.
- **Nutella MCP (Apr 23-27)**: Set up nutella-mcp repo with synthetic data seeds for local dev. Created pitch tools for ai-services integration. Opened PR for sortby value mapping to enable MCP compatibility with Apollo internal values.

### Significant Proposals
- Nutella MCP task list spreadsheet shared with Nav, Neng, Sanket, Ankita (tracks MCP tool implementation for hackweek)
- Nutella MCP proposal doc updated and shared

### Significant Documents
- Notification Rules - Legacy to Rules Migration Mapping (Google Sheets, updated Apr 20)
- Notifications system - Plan (Google Doc, updated Apr 20)
- Email notifications migration data spreadsheet (updated Apr 22)
- Contributed to Mission Autonomous Spring 2026 sign-up page (Confluence, updated Apr 27)
- Engineering Demos & Updates page (Confluence, updated Apr 23)

### Significant Helping Others
- Reviewed nutella-mcp initial setup PR #3 (merged Apr 23)
- Reviewed magma Tiltfile setup PR #8771 and nutella #70226 (Apr 23)
- Self-reviewed Phase 2/3 PRs addressing Bugbot comments iteratively
- **CDN/S3/KMS Key Mismatch Investigation**: Extensive cross-crew troubleshooting in #crew-content-ingestion-consumption and #crew-meeting-intelligence. Identified regression where meetings objects using aws:kms encryption fail CDN path. Proposed fix (reprocess + stop using aws:kms), shared old Ruby script for detecting affected objects, escalated to Akhil Gudipally and Jyothi Muddala.
- Asked Anudeep to review notification rules PRs #69976 and #70041 in #eng-foundation

### Significant PRs
- **nutella #70041** (HS-180217): Seed notification_rules collection from legacy config (~382 rules) -- merged Apr 22
- **nutella #70323** (HS-180217): Backfill missing push channel on seeded rules -- merged Apr 27
- **nutella #70320** (HS-180222): NotificationEngine with rules-first routing -- open, addressing Bugbot
- **nutella #70329** (HS-180223): Phase 3 notification rules REST API (operator-only) -- open, addressing Bugbot
- **magma #8831** (HS-180223): Notification rules entities view + admin UI -- open
- **nutella #70368**: Map public API sortby values to internal Apollo values for MCP compatibility -- open
- **ai-services #2920**: Add MCP pitch tools for nutella-mcp -- open
- **nutella-mcp #1**: Correct CONTRIBUTING.md to match actual branch/ruleset protection -- merged Apr 23
- **nutella-mcp #4**: Add synthetic data seed scripts for local dev -- open
- **nutella #70111** (HS-182039): Fix email logo centering in Gmail -- merged Apr 22
- **nutella #70005** (HCL-10295): Fix alerts pagination sort field -- merged Apr 21

### Significant Jira Tickets
- HS-180217: Seed notification rules collection (P3, merged)
- HS-180222: NotificationEngine Phase 2 (P3, Code Review)
- HS-180223: Phase 3 REST API + Admin UI (P3, Code Review)
- HCL-10295: Alerts pagination bug (P3, In Test)
- HISPI-12550: Timezone display bug (P2, Deployed)
- HS-155824: email_tracking_details_v1 slow query (P2, To-Do)

### Key Challenges This Week
- **Cache pollution in NotificationRuleResolver**: Returning cached NotificationRule by reference allowed callers to mutate shared state. Fixed by implementing `dup_rule` helper that deep-copies `delivery_strategy`, `trigger`, `eligible_alert_kinds`, and `metadata` using `deep_dup`.
- **Ruby 3 RSpec argument matching**: `expect(...).to receive(...).with(:key => val)` was interpreted as keyword arguments in Ruby 3, while actual code passed a positional hash. Fixed with explicit braces: `.with({ :key => val })`.
- **Distinguishing "no rule" from "user opted out"**: Original `resolve` returning nil couldn't differentiate. Introduced `resolve_with_outcome` returning an `Outcome` struct with status (`:resolved`, `:no_rule`, `:user_opted_out`) to enable distinct metrics.
- **Semgrep IDOR false positives**: Semgrep flagged `find_by_id(params[:id])` as potential IDOR on operator-only API. Added `# nosemgrep` comments with detailed justifications explaining the API is operator-only with authorization in a `before` filter.
- **Audit log recording system-added fields**: `NotificationRuleCommands.update_by_name` mutated the updates hash with `updated_at`, causing audit log to record system field. Fixed by capturing `operator_fields = updates.keys` before the mutation.

**Notes:**
- GitHub MCP auth broken -- used `gh` CLI as fallback for PR data
- Hackweek Mission Autonomous kicks off Apr 27 -- Nutella MCP project submitted
- Atlassian MCP returning deprecation notice for HTTP+SSE transport (switching to Streamable HTTP by June 30)

---

## 2026-04-15 - Weekly Review (2026-04-08 to 2026-04-15)

**Summary:**
Focused on semantic email migration -- split the large PR #67262 into 3 stacked PRs, addressed Bugbot/review feedback, introduced Hashie::Dash data classes across all builders, fixed an IndifferentAccess mutation bug, and wrapped hardcoded strings with i18n. Also opened two bug fix PRs for alerts pagination and timezone display.

### Significant Cursor Activities
- Introduced Hashie::Dash typed data classes across 27 email builders (architectural decision from PR review feedback) -- eliminated symbol/string key ambiguity, required 7 Cursor sessions across direct builders, alert builders, and digest builder
- Fixed IndifferentAccess mutation bug (94 test failures) by adding `deep_dup` in `EmailData#initialize` and reverting DigestPresentedData
- Wrapped hardcoded English strings in `Hspt::Intl.t()` across 16 builder files to fix i18n regressions
- Created draft PR3 (#69595) for integration layer, stacked on PR2
- Designed and accepted plan to strip inline entity titles from body copy (Category A: 8 builders, Category B: base.rb) -- pending execution

### Significant Proposals
- Proposed PR2/PR3 split plan in #crew-app-platform, negotiated scope with Derek and Rohit
- Shared NUTELLA_MCP_PROPOSAL with Nav for review (Google Docs)

### Significant Documents
- Updated Engineering Demos & Updates page (Confluence, Apr 14)
- Contributed to Project Autonomous Spring 2026 sign-up page (Confluence, Apr 15)
- Updated Email notifications migration data spreadsheet (Google Sheets, Apr 14)

### Significant Helping Others
- Self-reviewed PR2 (#69507) for completeness before requesting Derek's review
- Flagged S3/KMS key mismatch issue in #crew-content-ingestion-consumption, CC'd Anudeep

### Significant PRs
- **PR1 #69502** (nutella): Legacy Velocity templates for comparison testing -- merged this week
- **PR2 #69507** (nutella): 27 semantic email builders + preview system, 65 files, in active review with Derek (~2 weeks in review)
- **PR3 #69595** (nutella): Integration layer (FF-gated routing, OTel metrics, AlertPresenter), draft, stacked on PR2
- **#69640** (nutella): Fix alerts pagination HCL-10295 -- open
- **#69639** (nutella): Fix timezone display HISPI-12550 -- open

### Significant Jira Tickets
- HS-179437: Notifications CS1 Foundations (P1, In Dev)
- HS-180220/HS-180218/HS-180233: Semantic email migration (P3, moved to Code Review)
- HCL-10295: Alerts pagination bug (P3, Code Review)
- HISPI-12550: Timezone display bug (P2, Code Review)

### Key Challenges This Week
- Hashie::Dash `IndifferentAccess` silently mutates nested hash keys in-place during coercion, corrupting downstream AlertPresenter usage (94 failures, resolved with `deep_dup`)
- DigestBuilder's `IgnoreUndeclared` dropped arbitrary entity keys needed by `resolve_messages` (10 failures, resolved by reverting to plain hash)
- Bundle/rspec not runnable locally (missing gems in environment) -- relied on compare script for validation

**Notes:**
- PR1 merged, PR2 in review, PR3 draft ready -- pipeline is flowing
- Entity title stripping plan accepted but not yet executed -- carry-over to next week
- GitHub MCP auth broken during review; used `gh` CLI as fallback
- Google Drive (gdrive) MCP returned error; used Workato Google Drive MCP instead

---

## 2026-04-17 - Weekly Review (2026-03-30 to 2026-04-06)

**Summary:**
Landed CDN cache invalidation across 4 repos, reduced CDN alert false positives, fixed MailWorker test ordering, investigated MJML feature-flag routing gaps, set up worklog infrastructure, created draft PR3 for integration layer, and reorganized Cursor rules/skills.

### Significant Cursor Activities
- **MJML Feature-Flag Investigation + Observability (Apr 5)**: Traced why `named_access_grant_expiring` could send legacy email despite FF targeting. Added OTel counter `semantic_email_flag_check_count` and `EventLogger.error` for FF routing visibility.
- **Semantic Email Cursor Rules/Skills Reorganization (Apr 2)**: Consolidated many rules into 4 thematic `.mdc` files, expanded `migrate-notification-kind` skill, documented when unit tests are required.
- **Created Draft PR3 (Apr 6)**: Integration layer PR #69595 stacked on PR2 with FF-gated routing, OTel metrics, and AlertPresenter adjustments.
- **Work Log Setup + Enhancement (Apr 5-6)**: Built worklog infrastructure with rules, skills, and dedicated repo. Enhanced with mid-session logging, end-of-conversation checks, and 3 new significance categories (investigation, infrastructure, test suites).

### Significant Proposals
- Shared PR1/PR2/PR3 split plan with Derek and Rohit in #crew-app-platform, with links to all 3 PRs
- Shared CDN alerts false positive fix PR #891 with Nathan and Neng in #alerts-content-cdn-production

### Significant Documents
- [Semantic Email Migration Execution Plan](https://docs.google.com/document/d/1pjUIO1WUq2x64tFf60U7FnO-r5Zhb7O5MPrOUKOQDqE/edit) (created and shared with Nathan and Nav, Mar 17)

### Significant Helping Others
- Flagged S3/KMS key mismatch in #crew-content-ingestion-consumption, CC'd Anudeep for MI crew investigation
- Flagged BSON `NilClass` error in MeetingDeliveryFeedback processing
- Asked about DynamicConfig + LaunchDarkly integration patterns in #eng-launchdarkly
- Requested reviews from Justin Lo for tf-scale-unit-base #182 and terraform #5200 in #eng-foundation

### Significant PRs
- **nutella #68979** (HS-159835): CDN cache invalidation on reprocess -- merged Mar 31. Adds CloudFront invalidation when content is reprocessed.
- **terraform #5171** (HS-159835): CDN cache invalidation IAM policy for latest su0 -- merged Apr 7. Scoped IAM permissions for nutella-web to call `CreateInvalidation`.
- **tf-newrelic-alert #891** (HS-147590): CDN alerts false positive reduction -- merged Apr 2. Added 100 minimum request threshold, adjusted per-code thresholds.
- **magma #8469** (HS-157764): MailWorker pre-rendered HTML support -- fixed JVM test ordering issue (Apr 1).

### Significant Jira Tickets
- HS-159835: CDN cache invalidation on reprocess -- code landed across nutella, terraform, tf-scale-unit-base (4 PRs)
- HS-158409: Backend nutella APIs for languages onboarding -- Deployed
- HS-179437: Notifications CS1 Foundations (P1, In Dev) -- ongoing epic

### Key Challenges This Week
- LaunchDarkly silent `rescue` hid feature-flag check failures, allowing legacy email fallback -- required adding OTel metrics for visibility
- CDN alert false positive tuning required balancing minimum request count thresholds with per-status-code sensitivity
- MailWorker JVM test ordering: `MailWorkerBulkCallbackTest` needed to extend `WorkflowTestBase` for `Environment.forceTestEnvironment()` to run first

**Notes:**
- PR split plan communicated to Derek and Rohit; PR1 ready for review, PR2 submitted, PR3 drafted
- CDN cache invalidation shipped to latest su0 first, all-SU rollout PRs opened (landing Apr 7)
- GitHub MCP auth broken -- used `gh` CLI as fallback
- Carry-over: entity title stripping plan (accepted, not yet executed), PR2/PR3 reviews

---
