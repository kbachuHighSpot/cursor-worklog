# Weekly Work Log

This log tracks weekly summaries of significant work across all sources (Cursor, GitHub, Jira, Slack, Confluence, Google Drive).

## Running Summary

*Last updated: 2026-04-17*

### Overall Key Accomplishments (Jan-Apr 2026)

**Significant Cursor Activities:**
- **Semantic Email Migration (Feb-Apr)**: Built complete MJML-based rendering system replacing ~450 legacy Velocity templates. Designed EmailContentBuilder module split + auto-derived `_v2` architecture (Mar 12). Migrated all builders to self-registration pattern with `SemanticAlertRenderer.register` (Mar 26). Introduced Hashie::Dash typed data classes across 27 builders (Apr 8-14). Fixed IndifferentAccess mutation bug (94 failures). Wrapped 16 builder files with `Hspt::Intl.t()` for i18n (Apr 8). Created automated preview test coverage for all kinds (Mar 29). Architected 3-PR split strategy for the 71-file PR.
- **Notification Rules System Design (Mar-Apr)**: Developed PM-editable template text plan with i18n tradeoff analysis (Mar 14). Iterated notification rules plan for domain admin editing aligned with MJML (Mar 16). Consolidated plans and enriched ALERT_CONFIG inventory (Mar 28). Extended to multi-channel scope with phased REST APIs (Mar 29).
- **CDN Infrastructure (Jan-Mar)**: Set up CDN Lambda local dev environment with Python standards and CI pipeline (Feb 17-19). Investigated cache invalidation feasibility (Mar 8). Analyzed CDN caching paths and Lambda memory for cache sizing (Mar 19).
- **Content CDN Alert Redesign (Mar 30)**: Implemented per-status-code CloudFront error rates with distribution-level faceting, Lambda duration alerts with region faceting, and Opsgenie integration in Terraform.
- **Region Settings Bug Fix (Mar 10)**: Fixed high-severity bug where PUT handler for content regions wiped all regions when `regions` key omitted.
- **Feature-Flag Observability (Apr 5)**: Added OTel counter `semantic_email_flag_check_count` and `EventLogger.error` for FF routing visibility after investigating why legacy emails slipped through.
- **Developer Tooling**: Built email preview endpoint, automated comparison script, `SEMANTIC_VS_LEGACY.md` and `ALERT_CONFIG_TO_SEMANTIC_MAPPING.md` reference docs (Mar 29). Planned Admin "Notifications" menu (Mar 17). Built AI-assisted work logging with weekly MCP review skill. Enhanced worklog rules/skills with mid-session logging, end-of-conversation checks, and expanded significance criteria (Apr 6).
- **Plan: Strip inline entity titles** from semantic email body copy across all builders (Category A: 8 builders, Category B: base.rb) -- accepted, pending execution.
- **Execution Plan Document**: Created and shared semantic email migration execution plan with Nathan and Nav (Mar 17), updated and re-shared (Apr 17).

**Significant Proposals:**
- Shared NUTELLA_MCP_PROPOSAL with Nav for review (Google Docs, Apr 13)
- Proposed PR2/PR3 split plan in #crew-app-platform, negotiated scope with Derek and Rohit

**Significant Documents:**
- Content CDN Alerts Runbook (Confluence ENGDOCS, Nov 2025)
- CDN local dev setup guide (Confluence ENGDOCS, Feb 2026)
- Notifications System tech spec (Confluence ENGDOCS)
- `SEMANTIC_VS_LEGACY.md` and `ALERT_CONFIG_TO_SEMANTIC_MAPPING.md` reference docs (Mar 29)
- Email notifications migration data spreadsheet (Google Sheets, Apr 14-16)
- Notifications Platform CS1 Foundations PLT presentation (Google Slides, updated Apr 15)
- [Semantic Email Migration Execution Plan](https://docs.google.com/document/d/1pjUIO1WUq2x64tFf60U7FnO-r5Zhb7O5MPrOUKOQDqE/edit) (created Mar 17, updated Apr 17)
- NUTELLA_MCP_PROPOSAL (Google Doc, shared with Nav, Apr 10-17)
- Contributed to Project Autonomous Spring 2026 sign-up and Engineering Demos & Updates pages (Confluence)

**Significant Helping Others:**
- 23+ PRs reviewed across crews: Scott Fletcher (6 PRs, region settings), Dylan Kwiatkowski (3 PRs, Buildkite config), Prateek Singhal (2 PRs, VPC S3 access), Mike Coulson (2 PRs, ItemHistory), AMoo-Miki (1 PR, AWS SSO)
- Reviewed HS-179653 separate feature flag for regions onboarding (#69080, merged)
- Flagged S3/KMS key mismatch issue in #crew-content-ingestion-consumption, CC'd Anudeep for MI crew investigation
- Flagged BSON `NilClass` error in MeetingDeliveryFeedback processing to MI crew
- Together-mode email privacy analysis -- identified first-recipient context leak in `MailWorker.java` (Mar 10)
- Asked in #eng-launchdarkly about DynamicConfig + LaunchDarkly integration patterns

**Significant PRs:**
- **Semantic Email Migration (3 stacked PRs)**: PR1 #69502 (legacy templates, merged) -> PR2 #69507 (27 builders + preview, 65 files, merged Apr 16) -> PR3 #69595 (integration layer: routing/metrics/FF, merged Apr 17). Original PR #67262 was 71 files spanning 3 months.
- **CDN Cache Invalidation (HS-159835)**: nutella #68979 (reprocess invalidation, merged Mar 31), terraform #5171 (latest su0 policy, merged Apr 7), tf-scale-unit-base #182 (base policy, merged Apr 7), terraform #5200 (all SUs rollout, merged Apr 7)
- **CDN Lambda Mem Optimization**: PR #3 (content-cdn-lambda-handler, 99.6% cache reduction, merged Mar 10) + PR #4 (retry logging, merged Mar 13) + terraform version bumps
- **CDN Lambda Local Dev Setup (HS-157970)**: 11 commits (Feb 17-19), precommit hooks, CI pipeline, Python styling, Zscaler proxy fix
- **Region & Language Settings**: 4 nutella PRs merged Mar 4-6, designed API contracts with Scott Fletcher
- **CDN Alerts Redesign**: 4 tf-newrelic-alert PRs (granular per-code alerts, distribution faceting, Opsgenie, false positive reduction, Jan-Apr) -- including #891 (false positive reduction, merged Apr 2)
- **Magma MailWorker (PR #8469)**: Pre-rendered HTML support for semantic emails, merged Apr 2
- **Bug Fixes**: HCL-10295 (alerts pagination #69898, merged Apr 16), HISPI-12550 (timezone display #69639, merged Apr 15)

**Significant Jira Tickets:**
- HS-179437: Notifications CS1 Foundations (P1, In Dev) -- epic-level work
- HS-181943: Summer Preview Localization (P1, To-Do) -- new
- HS-180220/HS-180218/HS-180233: Semantic email migration trilogy (P3, Code Review)
- HS-152606: Technical design review - pillar-level (P1, Closed)
- HS-157970: CDN video seeking reset (P1, Closed -- fixed, Feb)
- HS-159180/HS-158408/HS-158409: Region & Language backend APIs (Deployed)
- HS-158767/HS-158768: CDN lambda + alert tickets (Closed)
- HS-156495/HS-156496/HS-156497: Tech Design Doc / Review / Test Plan (Closed/In Progress)

### Overall Key Challenges
- Semantic email migration touches deeply interconnected systems (AlertPresenter, EntityCache, ALERT_CONFIG, i18n) -- broad changes like fallback removal cascade into 90+ failures requiring iterative debugging
- PR size management -- the original 71-file PR couldn't be reviewed effectively; splitting into 3 PRs required careful dependency analysis of cross-file references
- Mock data vs production code tension -- preview mock data format must exactly match what AlertPresenter expects for entity resolution, discovered through multiple rounds of breakage
- Hashie::Dash `IndifferentAccess` silently mutates caller's hashes, requiring `deep_dup` workaround (94 failures before fix)
- MRML gem cross-platform (darwin/linux) Bundler resolution issues slowed CI (Mar 26)
- `Hspt::Intl` static string reader rejects dynamic i18n key patterns -- required workarounds for `expiry_digest_builder` (Mar 17)
- Buildkite failures from duplicate i18n keys across builders (Mar 29)
- Self-registration load ordering required explicit `require_project` in 7 spec files (Mar 27)
- `Concurrent.global_io_executor` mocks incompatible with MRML rendering in specs -- required `min_spec_helper` switch (Mar 29)
- LaunchDarkly silent `rescue` allowed legacy email fallback to slip through undetected -- required OTel metrics for visibility (Apr 5)
- Alerts pagination regression: `collapsed: true` (PR #69640) activated Solr grouping on a non-existent field, returning only 1 result; original `collapse: true` was always a no-op due to key typo (Apr 16)
- Worklog automation gap: migration scripts and investigations weren't auto-logged because rules lacked specific significance criteria and mid-session logging instructions (Apr 6)

### Current Focus (This Week)
- **Semantic Email Migration**: All 3 stacked PRs merged (PR1 #69502, PR2 #69507, PR3 #69595) -- pipeline fully landed
- **Execution Plan**: Updated and re-shared with Nathan and Nav for review (Apr 17)
- **Summer Preview Localization (HS-181943)**: New P1 ticket, To-Do status
- **Planned**: Strip inline entity titles from body copy across all builders (plan accepted, pending execution)

### Current Blockers
- GitHub MCP auth broken -- using `gh` CLI as fallback
- HS-151210 (Pinterest font request) remains Blocked

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
