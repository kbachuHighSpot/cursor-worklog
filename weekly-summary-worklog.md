# Weekly Work Log

This log tracks weekly summaries of significant work across all sources (Cursor, GitHub, Jira, Slack, Confluence, Google Drive).

## Running Summary

*Last updated: 2026-04-27*

### Overall Key Accomplishments (Jan-Apr 2026)

**Significant Cursor Activities:**
- **Notification Rules System Implementation (Apr 18-27)**: Built complete Phase 1-3 implementation of unified notifications. Seeded ~382 notification rules from ALERT_CONFIG + EMAIL_SETTINGS (Apr 18). Created NotificationEngine with rules-first routing, NotificationRuleResolver with thread-safe caching and defensive copying (Apr 26). Built Phase 3 REST API (9 endpoints) with operator authorization and audit logging (Apr 27). Implemented Phase 5 magma admin UI consuming the REST API.
- **Nutella MCP for Hackweek (Apr 23-27)**: Created nutella-mcp repo with pitch tools, synthetic data seeding, and integration with ai-services. Submitted PR for sortby value mapping for MCP compatibility.
- **Semantic Email Migration (Feb-Apr)**: Built complete MJML-based rendering system replacing ~450 legacy Velocity templates. Designed EmailContentBuilder module split + auto-derived `_v2` architecture (Mar 12). Migrated all builders to self-registration pattern with `SemanticAlertRenderer.register` (Mar 26). Introduced Hashie::Dash typed data classes across 27 builders (Apr 8-14). Fixed IndifferentAccess mutation bug (94 failures). Wrapped 16 builder files with `Hspt::Intl.t()` for i18n (Apr 8). Created automated preview test coverage for all kinds (Mar 29). Architected 3-PR split strategy for the 71-file PR.
- **Notification Rules System Design (Mar-Apr)**: Developed PM-editable template text plan with i18n tradeoff analysis (Mar 14). Created detailed phase plans (3-12) with architecture diagrams, code snippets, and cross-phase dependencies (Apr 25). Extended to multi-channel scope with phased REST APIs (Mar 29).
- **CDN Infrastructure (Jan-Mar)**: Set up CDN Lambda local dev environment with Python standards and CI pipeline (Feb 17-19). Investigated cache invalidation feasibility (Mar 8). Analyzed CDN caching paths and Lambda memory for cache sizing (Mar 19).
- **Content CDN Alert Redesign (Mar 30)**: Implemented per-status-code CloudFront error rates with distribution-level faceting, Lambda duration alerts with region faceting, and Opsgenie integration in Terraform.
- **Region Settings Bug Fix (Mar 10)**: Fixed high-severity bug where PUT handler for content regions wiped all regions when `regions` key omitted.
- **Feature-Flag Observability (Apr 5)**: Added OTel counter `semantic_email_flag_check_count` and `EventLogger.error` for FF routing visibility after investigating why legacy emails slipped through.
- **Developer Tooling**: Built email preview endpoint, automated comparison script, `SEMANTIC_VS_LEGACY.md` and `ALERT_CONFIG_TO_SEMANTIC_MAPPING.md` reference docs (Mar 29). Planned Admin "Notifications" menu (Mar 17). Built AI-assisted work logging with weekly MCP review skill. Enhanced worklog rules/skills with mid-session logging, end-of-conversation checks, and expanded significance criteria (Apr 6).
- **Execution Plan Document**: Created and shared semantic email migration execution plan with Nathan and Nav (Mar 17), updated and re-shared (Apr 17).

**Significant Proposals:**
- Shared NUTELLA_MCP_PROPOSAL with Nav for review (Google Docs, Apr 13)
- Proposed PR2/PR3 split plan in #crew-app-platform, negotiated scope with Derek and Rohit
- Nutella MCP task list spreadsheet shared with Nav, Neng, Sanket, Ankita (Apr 23-27)

**Significant Documents:**
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
- **Nutella MCP**: nutella-mcp #1 (CONTRIBUTING.md, merged Apr 23), #4 (synthetic data seeds, open), ai-services #2920 (pitch tools, open), nutella #70368 (sortby mapping, open)
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
- **Notification Rules Phase 2+3**: NotificationEngine with rules-first routing (#70320) and REST API (#70329) in code review, addressing Bugbot comments
- **Hackweek - Mission Autonomous**: Nutella MCP pitch tools integration with ai-services
- **Phase 5 Admin UI**: Magma entities view + Hiccup admin controller consuming Phase 3 REST API

### Current Blockers
- GitHub MCP auth broken -- using `gh` CLI as fallback
- HS-151210 (Pinterest font request) remains Blocked

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
