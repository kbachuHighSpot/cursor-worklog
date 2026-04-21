# Cursor Work Log

This log tracks AI-assisted work sessions and changes automatically.

Weekly summaries and YTD running summary are in [weekly-summary-worklog.md](weekly-summary-worklog.md).

---

## BACKFILLED ENTRIES (Jan-Apr 2026)

*The following entries were reconstructed from git commit history (Jan-Feb) and Cursor agent transcripts (Mar-Apr). Added on 2026-04-06.*

---

## 2026-01-20 - CDN Alert Threshold Adjustment (HS-147590)

**Repository:** tf-newrelic-alert

**Summary:**
Increased 4xx warning threshold from 15% to 20% to reduce false positives in CDN alerting.

---

## 2026-02-17 - CDN Lambda Local Dev Setup (HS-157970)

**Repository:** content-cdn-lambda-handler
**Branch:** HS-157970/cdn-video-seek-reset-zscaler

**Summary:**
Set up local development environment for the CDN Lambda handler, added Python styling standards, fixed corporate proxy issues with cache-control headers, and established CI pipeline.

**Changes Made:**
- Local dev setup with proper Python environment configuration
- Fixed Zscaler/corporate proxy interference with cache-control headers
- Added pre-commit hooks and setup script
- Created unit test pipeline file for Buildkite
- Fixed lint failures and formatting issues
- 11 commits over Feb 17-19

---

## 2026-02-19 - CDN Video Seek Fix: Terraform Version Bump (HS-157970)

**Repository:** terraform
**Branch:** HS-157970/cdn-video-seek-reset-zscaler

**Summary:**
Bumped content-cdn-lambda-handler version in Terraform to deploy the video-seeking fix to latest environment.

---

## 2026-03-05 - Unreachable Email Investigation

**Repository:** nutella (regions workspace)

**Summary:**
Investigated why users marked "unreachable" could still receive some notifications but not MFA verification codes. Traced `send_email` / alert paths and found that unreachable filtering is bypassed in several cases (e.g., when `from` is a `User`).

---

## 2026-03-08 - CDN Cache Invalidation Feasibility Study

**Repository:** nutella (regions workspace)

**Summary:**
Investigated whether Nutella has permission to invalidate the CloudFront CDN cache. Concluded there was no existing invalidation path and outlined what would be needed (CloudFront client, IAM role, `create_invalidation` API). This later became PR #68979 (HS-159835).

---

## 2026-03-10 - Fix Region Settings Wipe Bug

**Repository:** nutella (regions workspace)

**Summary:**
Fixed a high-severity review finding where the PUT handler for `update_company_content_regions` always assigned `content_regions["regions"]` even when `regions` was omitted in the request, causing all regions to be cleared. Implemented "omit means unchanged; explicit `[]` clears" semantics.

**Changes Made:**
- Fixed absent-`regions` vs explicit empty list semantics in settings.rb
- Added duplicate `order` validation after full resolution of region list
- Added/updated specs including validation coverage
- Addressed reviewer feedback from Scott Fletcher

---

## 2026-03-10 - Together-Mode Email Privacy Issue Analysis

**Repository:** nutella/magma

**Summary:**
Analyzed a Cursor bot finding in `MailWorker.java`: in together mode, `buildRecipientContext` used the first recipient for shared template context, potentially exposing the first address to all recipients via `$recipient` / join URL variables.

---

## 2026-03-12 - EmailContentBuilder Architecture: Module Split + Auto-Derived _v2

**Repository:** nutella/magma

**Summary:**
Addressed two scaling issues: `EmailContentBuilder` growing unboundedly as notifications migrate, and parallel `_v2` entries diverging from originals. Designed and implemented a category-based module split behind a facade, plus auto-derivation of `_v2` config from base kinds to reduce dual maintenance.

**Changes Made:**
- Designed module split / facade for the builder surface
- Implemented auto-derived `_v2` config pattern
- Touched `EmailContentBuilder`, `alert_commands`, and ALERT_CONFIG structures

---

## 2026-03-14 - PM-Editable Template Text Plan

**Repository:** nutella/magma

**Summary:**
Developed plan for PM-editable notification template text. Walked through the plan covering defaults registry, Mongo-backed overrides, resolver, and admin API. Analyzed i18n implications -- comparing `Hspt::Intl.t()`-based i18n with Mongo-backed overrides and clarified tradeoffs (overrides vs. translations, per-domain language).

**Notes:**
- Plan accepted: `pm_template_text_editing_*.plan.md`

---

## 2026-03-15 - OTel Email Metrics Plan + CI/CODEOWNERS Fixes

**Repository:** nutella/magma

**Summary:**
Reviewed the OTel metrics plan for semantic vs legacy email pipelines. Clarified that the immediate alert path has no semantic-to-legacy fallback (unlike digest). Fixed CI/CODEOWNERS friction and RuboCop cleanup across semantic email and alert files.

**Changes Made:**
- Clarified fallback behavior on immediate vs digest paths
- Addressed `CODEOWNERS` check failures for new spec files
- Fixed RuboCop offenses in email/alert code

---

## 2026-03-16 - Notification Rules Plan: Domain Admin Editing

**Repository:** nutella/magma

**Summary:**
Iterated on the "decision-based notification rules" plan to add PM/domain-admin editable notification text per alert kind, aligned with semantic email builders and standard MJML structure. Explored how `ALERT_CONFIG` splits routing vs content.

---

## 2026-03-17 - Admin UI: Notifications Menu + CI Fixes

**Repository:** nutella/magma

**Summary:**
Multiple sessions spanning admin UI planning and CI fixes. Specified Admin "Notifications" section with "Email previews" (and future "Manage rules"), investigated where admin menus are defined (Nutella sidebar vs Magma Clojure admin at 8686). Also resolved CODEOWNERS coverage for new email specs and fixed CI issues.

**Changes Made:**
- Planned navigation entry pointing at `/email_preview` preview flow
- Added `@highspot/app-platform` entries in CODEOWNERS for new spec paths
- Fixed RuboCop offenses (`private` placement, useless assignments, `ALERT_CONFIG.freeze`)
- Fixed `Hspt::Intl` parse error in `expiry_digest_builder.rb` (dynamic i18n key pattern)
- Planned email preview "Send email" button for real test delivery

---

## 2026-03-19 - CDN Caching Paths and Lambda Memory Analysis

**Repository:** content-cdn-lambda-handler

**Summary:**
Deep-dive into CDN caching paths: traced Cache-Control/private behavior, CDN Lambda vs browser-to-Zscaler-to-magma-api flow, investigated magma-api `/thumbnails/*` header behavior. Analyzed CloudWatch/NR log queries and Lambda RSS/cold-start memory measurements for cache sizing decisions.

---

## 2026-03-25 - MJML Migration: Spec Coverage + Preview Kind Inventory

**Repository:** nutella/magma

**Summary:**
Three sessions covering migration reconnaissance. Searched specs for tests touching `TransactionalBuilder#build_welcome`, `semantic_email.mjml.erb`, and `SemanticEmailPreview`. Surveyed Mongo/persistence patterns for preview config. Parsed `semantic_email_preview.rb` to extract all `kind` values from `IMMEDIATE_CATEGORIES`, `DIGEST_CATEGORIES`, and `EMAIL_TYPE_PREVIEWS` with deduplication and counts.

---

## 2026-03-26 - Self-Registration Migration + MRML/Bundler/CODEOWNERS

**Repository:** nutella/magma

**Summary:**
Major implementation day. Executed self-registration migration for all email builders (pattern from `RequestAccessBuilder`/`FeedbackBuilder`): added `SemanticAlertRenderer.register` calls and removed centralized registration. Also resolved MRML gem Bundler platform issues, CODEOWNERS updates, and semgrep hygiene.

**Changes Made:**
- Migrated all builders to self-registration pattern with `SemanticAlertRenderer.register`
- Added `partner_from` handling and aligned registration blocks
- Debugged `Bundler::GemNotFound` / platform resolution (darwin vs linux)
- Updated CODEOWNERS for semantic email spec paths
- Added safe-output documentation and `nosemgrep` for MRML HTML composition
- Extracted full alert-kind list and documented end-to-end checklist for adding new semantic kinds

---

## 2026-03-27 - DynamicConfig Kill-Switch + Spec Load-Order Fixes

**Repository:** nutella/magma

**Summary:**
Extended the `dynamicconfig_kind_kill_switch` plan for all code paths and fixed unit specs where `semantic_kind_disabled?` called `DynamicConfigCache.get` without a backing store. Added `require_project "common/email/semantic_alert_renderer"` to seven builder specs for correct load order with self-registration.

**Changes Made:**
- Updated kill-switch plan for consistent coverage
- Adjusted `semantic_kind_disabled?` to rescue errors in unit tests (mirroring `semantic_email_flag_enabled?`)
- Patched 7 spec files with correct require ordering

---

## 2026-03-28 - Notification Rules Plan Consolidation + ALERT_CONFIG Inventory

**Repository:** nutella/magma

**Summary:**
Merged two duplicate `notification_rules` plan files into `notification_rules_system_7b216d85.plan.md`. Added ALERT_CONFIG `:options` inventory (including `send_immediately` nuances) to support migration/seeding design. Compared `build_result` patterns across semantic email type builders.

---

## 2026-03-29 - Major: Preview Test Coverage + Comparison Tooling + i18n Fixes

**Repository:** nutella/magma

**Summary:**
Largest day of the backfill period. Multiple significant implementations across 7 sessions.

**Changes Made:**
- Updated notification rules plan for multi-channel scope (in-app, push, Slack, MS Teams, email) and phased REST APIs
- Fixed Buildkite failures from duplicate i18n key `oT7qWx9d` in `ownership_transfer_builder.rb`; split/renamed keys
- Updated `LearningBuilder` specs to match actual subject/body_copy output
- Created `semantic_email_preview_all_kinds_spec.rb` to test all immediate/digest preview routes
- Switched preview spec to `min_spec_helper` to avoid `Concurrent.global_io_executor` mock conflicts with MRML
- Created `SEMANTIC_VS_LEGACY.md` and `ALERT_CONFIG_TO_SEMANTIC_MAPPING.md` reference docs
- Built Ruby helpers to parse ALERT_CONFIG/builders for XLSX generation
- Documented repo locations for shared Cursor rules and skills for team use

---

## 2026-03-30 - Content CDN Alert Redesign (HS-158768/HS-147590)

**Repository:** tf-newrelic-alert
**Branch:** HS-147590/cdn-fine-tune-alerts

**Summary:**
Major Terraform alerting overhaul for Content CDN. Replaced aggregate 4xx/5xx metrics with per-status-code CloudFront error rates faceted by DistributionId. Added Lambda duration alerts with region faceting, timeout detection, and anti-double-fire logic.

**Changes Made:**
- Per-code 5xx thresholds (502/504 vs 503), 4xx threshold maps
- `FACET aws.cloudfront.DistributionId` and `aws.region` for distribution-level alerting
- Lambda `Duration.byFunction` alerts with `FACET aws.region`, ≥30s timeout warning
- Opsgenie resources with `opsgenie_enabled` toggle
- Cleaned up unused NRQL locals and dead code
- Iterated on low-traffic false positive mitigation (`threshold_occurrences`, `min_requests`)

---

## 2026-04-01 - Fix MailWorker Test Ordering (magma PR #8469)

**Repository:** magma

**Summary:**
Fixed JVM test ordering issue between `MailWorkerBulkCallbackTest` and `MailWorkerPreRenderedTest` related to semantic email PR #8469. Made `MailWorkerBulkCallbackTest` extend `WorkflowTestBase` so `Environment.forceTestEnvironment()` runs before mail worker construction.

---

## 2026-04-02 - Semantic Email Cursor Rules/Skills Reorganization

**Repository:** nutella (notifications workspace)

**Summary:**
Reorganized Cursor rules and skills for the legacy-to-semantic email migration. Consolidated many rules into four thematic `.mdc` files, set `alwaysApply: false` with globs, expanded `migrate-notification-kind` skill, documented when unit tests are required (semantic vs legacy/preview), and added automatic "capture learnings" behavior.

---

## 2026-04-05 - MJML Feature-Flag Investigation + Observability

**Repository:** nutella (notifications workspace)

**Summary:**
Investigated why `named_access_grant_expiring` could send legacy email despite `mjml_email_templates` flag targeting. Traced LaunchDarkly rules and silent `rescue` behavior. Added OTel counter `semantic_email_flag_check_count` (kind/result/reason) and `EventLogger.error` on flag-check exceptions.

**Changes Made:**
- Implemented metrics + logging in `email_metrics.rb` and `email_commands.rb` for FF routing visibility
- Refactored `semantic_email_flag_enabled?` and `semantic_email_enabled_for_recipients?` for clearer failure paths

---

## END OF BACKFILLED ENTRIES

---

## 2026-04-05 - Work Log Setup

**Summary:**
Set up automated work logging for Cursor sessions.

**Changes Made:**
- Created `.cursor/rules/work-log.mdc` rule for automatic logging
- Work log location: `~/Codebase/cursor-worklog/WORKLOG.md`

**Notes:**
- Log entries will be appended automatically at end of tasks
- Can manually add notes by asking "log this" or "add to work log"

---

## [2026-04-06] - Created Draft PR3 for Semantic Email Integration Layer

**Repository:** nutella
**Branch:** notifications/semantic-email-integration (based on notifications/semantic-email-builders)
**PR:** https://github.com/highspot/nutella/pull/69595 (draft)
**Files Changed:**
- .semgrepignore
- CODEOWNERS
- web/api/presenters/alert_presenter.rb
- web/common/email/email_commands.rb
- web/common/email/email_metrics.rb
- web/config/development/development0/config.yaml
- web/spec/unit/common/email/email_commands_spec.rb
- web/spec/unit/common/email/email_commands_type_routing_spec.rb
- web/spec/unit/common/models/commands/alerts/alert_commands_spec.rb

**Summary:**
Created draft PR3 (#69595) as the final piece of the 3-PR split from the original PR #67262. PR3 contains the integration layer: FF-gated routing in email_commands.rb, OpenTelemetry metrics in email_metrics.rb, AlertPresenter adjustments, and corresponding tests. Stacked on PR2's branch (notifications/semantic-email-builders).

**Changes Made:**
- Created branch notifications/semantic-email-integration from PR2's branch
- Checked out 8 integration files from the original PR branch (notifications/email-templates-framework)
- Added CODEOWNERS entry for new email_commands_type_routing_spec.rb
- Committed and pushed
- Created draft PR #69595 targeting PR2's branch

**Notes:**
- PR chain: PR1 #69502 (legacy templates) -> PR2 #69507 (builders) -> PR3 #69595 (integration)
- PR3 targets PR2's branch (stacked PR pattern)
- Switched back to PR2 branch (notifications/semantic-email-builders) after creating PR3

---

## [2026-04-08] - i18n Regression Fix: Semantic Email Builders

**Repository:** nutella
**Files Changed:**
- 16 semantic builder files across builders/direct/, builders/alert/, and builders/base.rb

**Summary:**
Wrapped all hardcoded English strings in Hspt::Intl.t() calls across 16 semantic email builder files to fix i18n regressions where legacy templates had proper internationalization but semantic builders used raw English strings.

**Changes Made:**
- meeting_email_builder: i18n'd Date/Time/Host/Account/Deal labels, Meeting/Attendee/Host fallbacks, date formatting
- pitch_activity_builder: Converted ACTIVITY_LABELS to lazy-loaded i18n method, i18n'd entity labels
- marketplace_builder: i18n'd User's Email/Email labels, browser note, Publisher fallbacks
- analytics_builder: i18n'd scheduled message sentence, schedule metadata, defaults
- transactional_builder: i18n'd Spark Community, Highspot University, Digital Room link texts
- ops_builder: i18n'd Operations Notification, Skipped Objects, admin task, click here, A user
- pitch_email_builder: i18n'd "and X more items", pages, Updated, Content/Sender/Pitch fallbacks
- digest_email_builder: i18n'd Activity/Recommended/Other labels, "and X more", User fallback
- comment_notification_builder: i18n'd all "{user} commented/replied" patterns
- security_builder: i18n'd "When and where this happened" block and detail labels
- bulk_nudge_builder: i18n'd Nudge/Action fallbacks
- generic_builder: i18n'd "wrote:" pattern
- base.rb: i18n'd duration units, footer copyright, Notification/pitch_label fallbacks

---

## 2026-04-14 - Direct email builders Hashie::Dash data classes

**Repository:** latest (nutella)
**Branch:** (workspace)
**Files Changed:**
- nutella/web/common/email/semantic/builders/direct/pitch_email_builder.rb
- nutella/web/common/email/semantic/builders/direct/digest_email_builder.rb
- nutella/web/common/email/semantic/builders/direct/meeting_email_builder.rb
- nutella/web/common/email/semantic/builders/direct/transactional_builder.rb

**Summary:**
Converted four direct semantic email builders to wrap payloads in `EmailContentBuilder::EmailData` (Hashie::Dash) subclasses with `require_relative "../data_classes"`, property declarations for all `data[:key]` uses, `default:` where prior `||` fallbacks applied, `brand` coerced with `Hashie::Mash` on transactional builder, and `TransactionalData.new(data)` at the start of each `build_*` entry point.

**Notes:**
- Preserved dynamic fallbacks (e.g. `solution_name || domain_name`, `week_of || {}`, `|| 0` counts) where a single Dash `default:` would change behavior.
- `build_user_unlocked` keeps `solution_name || solution_short || "Highspot"`; `build_user_reactivation` keeps `domain_name || "Highspot"` in the i18n call.

---

## 2026-04-14 - Direct email builders Dash (expiry, ops, marketplace, pitch activity)

**Repository:** latest (nutella)
**Branch:** (workspace)
**Files Changed:**
- nutella/web/common/email/semantic/builders/direct/expiry_digest_builder.rb
- nutella/web/common/email/semantic/builders/direct/ops_builder.rb
- nutella/web/common/email/semantic/builders/direct/marketplace_builder.rb
- nutella/web/common/email/semantic/builders/direct/pitch_activity_builder.rb

**Summary:**
Wrapped each builder's payload in a module-local `EmailData` subclass (`ExpiryDigestData`, `OpsData`, `MarketplaceData`, `PitchActivityData`), added `require_relative "../data_classes"`, and instantiated at the `build` entry point. Moved `||` fallbacks to `default:` on declared properties where they matched static fallbacks; left dynamic fallbacks (e.g. `preheader || subject`, `manage_submissions_url || item_url`, `dig(...) || "#0D75D2"`).

**Notes:**
- RSpec for `direct_email_builder_spec.rb` not run locally (bundle gems missing in environment).

---

## 2026-04-14 - Immediate alert email builders AlertEmailData

**Repository:** latest (nutella)
**Branch:** (workspace)
**Files Changed:**
- nutella/web/common/email/semantic/builders/alert/immediate/learning_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/workflow_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/send_failed_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/pitch_relationship_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/scheduled_subscription_builder.rb

**Summary:**
Converted immediate alert email builders to wrap `alert.data` in Hashie::Dash classes via `require_relative "../../data_classes"`. Added `LearningAlertEmailData` (extra learning/assessment/session keys + `assigned_item`), `WorkflowAlertEmailData` (`workflow_item_ids`, `step_aware`), `SendFailedAlertEmailData` (`pitch`, `cause`, `smtp_relays`), and `PitchRelationshipAlertEmailData` (`pitch`). Simplified `data[:key] || data["key"]` and dual `.dig` branches in `learning_builder.rb`. Used `AlertEmailData` for scheduled subscription. Subclasses declare keys so `IgnoreUndeclared` does not drop payload fields needed by `fetch_*` / `get_data_field`.

**Notes:**
- `extract_external_comment(alert.data)` in learning registration unchanged (raw alert). RSpec not run (bundle incomplete in environment).

---

## 2026-04-14 - Alert immediate builders AlertEmailData

**Repository:** latest (nutella)
**Branch:** (workspace)
**Files Changed:**
- nutella/web/common/email/semantic/builders/alert/immediate/generic_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/share_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/spot_access_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/restricted_template_updated_builder.rb
- nutella/web/common/email/semantic/builders/alert/immediate/session_proctor_builder.rb

**Summary:**
Wrapped alert payloads in `EmailContentBuilder::AlertEmailData` (or module subclasses for extra keys: `SpotAccessAlertEmailData` with `spot_access`, `RestrictedTemplateUpdatedAlertEmailData` with `restricted_template`, `SessionProctorAlertEmailData` with `training_session`/`training_event` as `Hashie::Mash`). Added `require_relative "../../data_classes"`. Replaced direct `alert.data` / dual string-symbol access in these builders with wrapped `data`; renamed `stripped_body_for_kind` second arg from `alert` to `data` for `group_access`. Left `base.rb` helpers unchanged (Phase 4).

**Notes:**
- Bundle/rspec not runnable locally (missing gems).

---

## 2026-04-14 - DigestBuilder DigestPresentedData (Hashie::Dash)

**Repository:** latest (nutella)
**Branch:** (workspace)
**Files Changed:**
- nutella/web/common/email/semantic/builders/alert/digests/digest_builder.rb
- nutella/web/common/email/semantic/builders/data_classes.rb

**Summary:**
Wrapped `presented["data"]` in `DigestPresentedData < AlertEmailData` with extra properties (`group`, `assigned_item`, `expiration`, `spot_access`, `admin_message`) and permissive `[]` so unknown template keys resolve like a Hash (nil / dig). Added `comment_url` to `EntityRef` for presenter item dig paths (e.g. review action href).

**Notes:**
- `bundle exec rspec` not run (Bundler gem resolution failed in environment).

---

## 2026-04-14 - Email builder dual-access audit (Dash vs sub-hashes)

**Repository:** latest (nutella)
**Branch:** (workspace)
**Files Changed:**
- (none -- audit only)

**Summary:**
Reviewed five semantic email builders for `data[:key] || data["key"]` cleanup after `EmailData` / `AlertEmailData` (Hashie::Dash + IndifferentAccess). No top-level `data` dual-access patterns remain in those files; remaining `[:x] || ["x"]` are on nested plain hashes (`timeframe_data`, `item`, `presented["action"]`, `msg_ref` for undeclared `admin_message`, digest entries, etc.) or are intentionally kept per coercion rules.

**Notes:**
- `AlertEmailData` does not declare `admin_message`; `summary` is `Hashie::Mash`. `ExpiryDigestData` timeframe properties are not Mash-coerced.

---

## 2026-04-08 - Hashie::Dash Data Classes for Email Builders

**Repository:** nutella
**Branch:** HS-158767/cdn-lambda-mem-optimizations
**Files Changed:** 27 files (1 new + 26 modified)

**Summary:**
Introduced Hashie::Dash typed data classes per PR review feedback. Eliminates symbol/string key ambiguity and adds schema documentation for each builder.

**Changes Made:**
- Created EmailData/EntityRef/AlertEmailData base classes in data_classes.rb
- Converted all 13 direct builders and 11 alert builders to use Dash data classes
- Simplified base.rb fetch/get helpers to remove dual-access patterns
- Used Hashie::Mash for variable-schema fields (summary, brand, etc.)

---

## [2026-04-08] - Fix Hashie::Dash IndifferentAccess mutation bug in email builders

**Repository:** nutella
**Branch:** (current working branch)
**Files Changed:**
- web/common/email/semantic/builders/data_classes.rb
- web/common/email/semantic/builders/alert/digests/digest_builder.rb

**Summary:**
Fixed compare script regression (94 failures) caused by Hashie::Dash with IndifferentAccess mutating the original alert.data hash during coercion, corrupting it for downstream AlertPresenter usage.

**Changes Made:**
- Added `deep_dup` override in `EmailData#initialize` to prevent IndifferentAccess from converting symbol keys to strings in the caller's original hash (fixed 84 of 94 failures)
- Reverted `DigestBuilder.build_section_group` from `DigestPresentedData.new(...)` back to plain hash -- the Dash's `IgnoreUndeclared` was dropping arbitrary entity keys needed by `resolve_messages` (fixed remaining 10 failures)
- Removed the `DigestPresentedData` class and its unused `require_relative`

**Notes:**
- Root cause: `Hashie::Extensions::IndifferentAccess` mutates nested hash keys in-place during coercion (converts `:id` symbol to `"id"` string). This caused `AlertPresenter.format_field` -> `data_to_output` to find `id` fields in hashes that previously only had symbol keys, triggering "unexpected entity type nil" errors.
- The 2 remaining "SEMANTIC MISSING" entries (admin_message, meeting_account_consolidated_template) are pre-existing and unrelated to the Hashie changes.
- Final result: Pass 311, Fail 0, Missing 2 (pre-existing)

---

## 2026-04-16 - Fix alerts pagination regression and original bug (HCL-10295)

**Repository:** nutella
**Branch:** HCL-10295/fix-alerts-pagination-stable
**PR:** https://github.com/highspot/nutella/pull/69898
**Files Changed:**
- web/api/controllers/users.rb
- web/spec/magma-integration/api/controllers/users_controller_spec.rb

**Summary:**
Fixed a regression from PR #69640 that broke alerts pagination (returning only 1 result) and also fixed the original bug (duplicate notifications when paginating on mobile).

**Changes Made:**
- Removed `collapsed: true` from alerts endpoint. Alert documents don't index a `group_id` field in Solr, so enabling collapse grouped all alerts into a single null group, returning only 1 result.
- Added `created_before` timestamp anchor to stabilize offset-based pagination. On first page request, server snapshots current time and adds Solr filter `timestamp_created_at:[* TO <snapshot>]`. The value propagates into the `next` link URL so subsequent pages use the same anchor, preventing offset drift when new alerts arrive between requests.
- Updated integration tests to verify both the `created_before` filter and the absence of `collapsed`.

**Notes:**
- The original `collapse: true` (before PR #69640) was always a no-op because the Query class reads `options[:collapsed]`, not `options[:collapse]`. Fixing the key name accidentally activated Solr grouping on a field that doesn't exist for alerts.
- The `created_before` approach is backward-compatible: clients that don't pass it get a fresh snapshot each request.

---

## 2026-03-25 - compare_email_previews.py: Legacy vs Semantic Comparison Script

**Repository:** nutella
**Files Changed:**
- web/scripts/notifications-migration/compare_email_previews.py (2,409 lines)
- web/scripts/notifications-migration/compare.sh

**Summary:**
Built an automated comparison tool that fetches both legacy (Velocity) and semantic (MJML) email previews, extracts visible text and structural components (section title, body copy, CTA, preheader, cards), computes similarity, and runs migration rule checks. Generates a report highlighting meaningful differences. Uses only Python standard library (no external dependencies).

**Changes Made:**
- HTML parsing to extract structured email components from both rendering pipelines
- Migration rule enforcement: provider omission, custom SMTP handling, entity duplication detection, structural completeness, variation kind naming validation
- Content coverage checks: section title, body copy, CTA, preheader presence; entity matching (links vs cards); legacy content representation in semantic output
- Entity title stripping tolerance: recognizes "the following [entity type]:" pattern as a valid match when entity cards are present
- Mock data consistency check: verifies both previews use the same entity names from PreviewMockData
- CLI with cookie-based auth, verbose mode, failed-only filtering, category/kind targeting
- Wrapper script `compare.sh` for quick full-suite runs with log output

---

## 2026-03-29 - test_email_previews.py: E2E Preview Render + Send + Verify Script

**Repository:** nutella
**Files Changed:**
- web/scripts/notifications-migration/test_email_previews.py (535 lines)

**Summary:**
Built an E2E test script that renders, sends, and verifies delivery of all semantic email previews via mailpit. For each preview link on the email preview index page: GET the preview page (verify render), POST to send_test (trigger delivery), and poll mailpit API (verify arrival).

**Changes Made:**
- Supports both semantic and legacy preview modes
- Cookie-based auth (file or inline)
- Render-only mode (no send, no mailpit check) for quick smoke tests
- Full send+verify mode with configurable mailpit URL
- Category and kind filtering for targeted testing
- Parallel-friendly with clear pass/fail reporting

---

## 2026-03-25 - export_preview_data.py: Email Preview Data Export to Excel

**Repository:** nutella
**Files Changed:**
- web/scripts/notifications-migration/export_preview_data.py (354 lines)

**Summary:**
Built an Excel export tool for semantic email preview data. Generates a spreadsheet with three tabs: Email Index (category, kind, type, digest item kinds), JSON Data (full email data payload per kind), and Kind Descriptions. Used for migration tracking and gap analysis across ~450 email types.

**Changes Made:**
- Parses preview index page to extract all categories and kinds
- Fetches JSON data for each preview kind
- Generates formatted Excel with openpyxl (headers, column widths, filters)
- Cookie-based auth matching the other migration scripts

---

## 2026-04-06 - Worklog Rules & Skills Enhancement

**Repository:** cursor-worklog, .cursor/rules, .cursor/skills
**Files Changed:**
- .cursor/rules/work-log.mdc
- .cursor/skills/update-worklog/SKILL.md

**Summary:**
Enhanced worklog rules and skills with mid-session logging, end-of-conversation checks, and three new significance categories.

**Changes Made:**
- Added mid-session logging instruction: log after each major milestone in long conversations instead of batching at the end
- Added end-of-conversation check: before responding to what looks like a final message, verify no unlogged significant changes exist
- Added explicit "significant" trigger examples to replace ambiguous criteria
- Added three new loggable categories: investigation/root-cause analysis (even without code changes), infrastructure/Terraform changes, and test suites created or expanded

**Notes:**
- These changes address the gap where scripts and investigations were not being auto-logged because the rules were too passive and vague about what qualifies as "significant"

---

## 2026-03-17 - Semantic Email Migration Execution Plan (Created)

**Summary:**
Created the execution plan for semantic email migration and sent it to Nathan and Nav for review.

**Document:** [Execution Plan](https://docs.google.com/document/d/1pjUIO1WUq2x64tFf60U7FnO-r5Zhb7O5MPrOUKOQDqE/edit?usp=sharing)

**Notes:**
- Shared with Nathan and Nav for feedback

---

## 2026-04-17 - Semantic Email Migration Execution Plan (Updated)

**Summary:**
Updated the execution plan for semantic email migration and sent the revised version to Nathan and Nav for review.

**Document:** [Execution Plan](https://docs.google.com/document/d/1pjUIO1WUq2x64tFf60U7FnO-r5Zhb7O5MPrOUKOQDqE/edit?usp=sharing)

**Notes:**
- Revised and re-shared with Nathan and Nav for feedback

---

## 2026-04-18 - Notification Rules Schema Refinement and PM Mapping Spreadsheet

**Repository:** N/A (Cursor plans + Google Sheets)
**Files Changed:**
- .cursor/plans/notification_rule_schema_and_seeding.plan.md
- .cursor/plans/notification_rules_master_plan.plan.md

**Summary:**
Major schema refinement session for the NotificationRule schema, eliminating redundant fields, reorganizing delivery_strategy, adding override collection schema, updating seeding to use database migration pattern, and creating a Google Sheets mapping spreadsheet for PM review.

**Changes Made:**
- Removed `group_email` from per-kind rules; digest eligibility centralized in single digest rule's `eligible_alert_kinds`
- Added inline field descriptions to the entire schema (jsonc with comments)
- Added `NotificationRuleOverride` schema section -- separate MongoDB collection for per-domain/user overrides with resolution order, overridable fields reference, indexes, and phase alignment
- Removed `conditions` field (overrides live in separate collection, not on base rule)
- Removed `content` block (template lookup via Content Registry by rule name; text overrides via overrides collection)
- Removed `push_notification` from options (covered by `channels` including `"push"`)
- Moved `send_from` from cross-channel options to email-specific (it's email From header only)
- Moved `skip_toast` into `delivery_strategy` as in-app channel option
- Eliminated `options` top-level block entirely
- Removed `retry_policy` (job system handles retries)
- Restructured `delivery_strategy` into channel-specific sub-objects: `email: {...}`, `in_app: {...}`
- Organized delivery_strategy into 4 sections: Routing, Timing, Guards (under `guards` sub-object), Channel Options
- Expanded Phase 8 guards (throttling, deduplication, delivery_window) with default structures
- Updated seeding instructions to use team's DatabaseMigration pattern (insert_many, idempotent spec, apply_data_migration.sh)
- Created Google Sheets spreadsheet "Notification Rules - Legacy to Rules Migration Mapping" with 3 tabs: Rule Mapping, Summary Counts, Field Mapping Reference
  - URL: https://docs.google.com/spreadsheets/d/1wPyr_ronzlBVub42FNvj4y2AgFOScJD-9OyPCFAbuXM/edit

**Notes:**
- Schema is now very lean: identity, trigger, delivery_strategy (with routing, timing, guards, channel options), and metadata
- Override collection supports domain/user scoping with sparse documents and shallow merge
- Spreadsheet needs to be populated with full ALERT_CONFIG data (~306 kinds) by running the rule builder scripts against the actual codebase

---

## 2026-04-18 - Complete Legacy-to-Rules Migration Mapping in Google Sheet

**Repository:** N/A (Google Sheets + source code analysis)
**Branch:** N/A

**Summary:**
Fully populated the "Notification Rules - Legacy to Rules Migration Mapping" Google Sheet with all 377 rules extracted from source code: 310 ALERT_CONFIG kinds + 1 digest rule + 66 EMAIL_SETTINGS types. This replaces the previous representative examples with the complete production mapping.

**Changes Made:**
- Extracted all ~310 kinds from ALERT_CONFIG in alert_commands.rb with their options (send_immediately, group_email, send_from, skip_toast, push_notification, no_email, urgent)
- Extracted all 66 email types from EmailCommands::SETTINGS in email_commands.rb
- Cross-referenced SLACK_ALERT_KINDS (8 kinds) and MS_TEAMS_ALERT_KINDS (13 kinds)
- Classified every kind into rule types: Immediate (144), Digest Only (4), In-App Only (21), In-App default (139), Push Only (2), Direct Email (60), System email infra (6), plus 1 Digest aggregator rule
- Populated Rule Mapping tab (A1:S378) with 19 columns: Rule Name, Rule Type, Legacy Source, Legacy Kind, Category, Priority, Channels, send_from, send_immediately, group_email, skip_toast, push_notification, urgent, no_email, has_subject, has_action, Slack, MS Teams, Notes
- Updated Summary Counts tab with accurate breakdowns including channel/options counts, digest-eligible kinds list (12), Slack kinds (8), MS Teams kinds (13), push notification kinds (2)
- Spreadsheet URL: https://docs.google.com/spreadsheets/d/1wPyr_ronzlBVub42FNvj4y2AgFOScJD-9OyPCFAbuXM/edit

**Notes:**
- Digest-eligible kinds (group_email: true): request_access_spot, request_access_spot_with_item, request_access_spot_without_email, support_request, bulk_items_feedback, bulk_items_feedback_1_item, feedback_item, feedback_spot, item_expiring, item_expired, pitch_expired, digital_room_expired
- Push-only kinds (no_email + push_notification): meeting_ended_deal_notification, pre_meeting_notification
- 3 deprecated kinds identified: content_distribution_complete, content_distribution_failed, review_followed
- Sheet is now ready for PM review and can be used as direct input for the seeding migration script

---

## 2026-04-18 - Master Plan Phases 1-12 Detailed

**Repository:** N/A (Cursor plans)
**Files Changed:**
- /Users/kiran.bachu/.cursor/plans/notification_rules_master_plan.plan.md

**Summary:**
Updated the notification rules master plan with specific implementation details for all phases (1-12).

**Changes Made:**
- Phase 1: Added seeding breakdown table (377 rules: 144 immediate, 4 digest-only, 1 digest aggregator, 21 in-app only, 139 in-app default, 2 push only, 60 direct email, 6 system), cross-channel seeding from Slack/MS Teams/Push constants, MongoDB indexes for both collections, file list, NotificationRuleResolver pseudocode
- Phase 2: Added component table (NotificationEngine, NotificationChannelRouter, NotificationContentRegistry), routing flow pseudocode, dual-read mode details, digest routing logic, per-kind rollout via scoped feature flag, backward compatibility notes
- Phase 3: Added REST endpoint table (CRUD for rules and overrides), authorization matrix (global admin, domain admin, service account, end user), audit requirements
- Phase 4: Added send endpoint with request schema, safeguards (rate limiting, idempotency keys, async processing)
- Phase 5: Added admin UI views table (rule list, detail with tabbed editor, override list/editor, email preview)
- Phase 6: Added recipient_groups schema addition with mode (none/intersect/expand) and router logic pseudocode
- Phase 7: Added override fields example, merge flow, interpolation syntax
- Phase 8: Added guard evaluation order pseudocode, Redis state backends for throttle/dedup, observability metrics, file list for guard modules
- Phase 9: Added non-email content override schema, channel-by-channel approach
- Phase 10: Added detailed removal table (what gets removed from ALERT_CONFIG, what stays), CI lint rule to prevent routing in legacy config
- Phase 11: Added hot path SLO targets table, load testing scenarios, infrastructure validation checklist
- Phase 12: Added test matrix table covering 6 representative kinds, test flow pseudocode, Mailinator infrastructure setup
- Updated Phase Ordering table with Key Deliverable and Collections/APIs columns
- Updated Context section with accurate counts (377 types)

**Notes:**
- Each phase now has: Goals, specific technical details (schemas/endpoints/pseudocode/tables), files to create/modify, and release criteria
- The master plan references the schema/seeding plan and Google Sheet for detailed mapping data
- Phases are designed for independent rollout with feature flags gating behavior changes

---

## 2026-04-18 - Notification Rules Seeding Migration Implementation

**Repository:** nutella
**Branch:** HS-180217/notification-rules-collection
**Files Changed:**
- web/db/migrate/180217_seed_notification_rules.rb (new)
- web/db/spec/integration/migrate/180217_seed_notification_rules_spec.rb (new)
- web/tools/scripts/deployment/apply_data_migration.sh (modified)

**Summary:**
Implemented the notification rules seeding migration per the schema and seeding plan. The migration reads from ALERT_CONFIG (316 kinds), builds 1 digest aggregation rule, and reads from EmailCommands::SETTINGS (65 types, skipping :digest to avoid name collision), producing ~382 total rules.

**Changes Made:**
- Created `DatabaseMigration` class with rule builder methods: `build_alert_config_rule`, `build_digest_rule`, `build_direct_email_rule`, `build_all_rules`
- Defined `CALL_SITE_EMAIL_OPTS` constant mapping 26 alert kinds to their call-site email options (send_one, bcc_support, no_to, bcc_mode)
- Defined `PRIORITY_MAP` for legacy level/urgent -> tech spec priority enum
- Defined `ELIGIBLE_DIGEST_KINDS` (12 kinds with group_email: true)
- Cross-references `SLACK_ALERT_KINDS` (8 kinds) and `MS_TEAMS_ALERT_KINDS` (13 kinds) for channel population
- Idempotent: filters out existing names before insert_many
- Integration spec covers: total count, idempotency (double run), per-kind ALERT_CONFIG rules, digest rule, EMAIL_SETTINGS rules, no_email channel correctness, priority mapping, Slack/Teams channel inclusion, call-site email options, pre-existing rule handling, guards disabled by default
- Appended migration line to apply_data_migration.sh

**Notes:**
- Also pushed `notification_rule_overrides` collection to the PR in a separate commit earlier in this session
- PR: https://github.com/highspot/nutella/pull/69976

---

## 2026-04-18 - Add entity, queries, and commands classes for notification_rules and notification_rule_overrides

**Repository:** highspot/nutella
**Branch:** HS-180217/seed-notification-rules
**Files Changed:**
- web/common/models/entities/notification_rule.rb (NEW)
- web/common/models/entities/notification_rule_override.rb (NEW)
- web/common/models/queries/notification_rule_queries.rb (NEW)
- web/common/models/queries/notification_rule_override_queries.rb (NEW)
- web/common/models/commands/notification_rules/notification_rule_commands.rb (NEW)
- web/common/models/commands/notification_rule_overrides/notification_rule_override_commands.rb (NEW)
- CODEOWNERS

**Summary:**
Scaffolded the data-access layer (entity, queries, commands) for both notification_rules and notification_rule_overrides collections, completing the create-mongo-collection skill requirements identified during the PR #69976 audit.

**Changes Made:**
- Created NotificationRule entity with attr_accessors for all schema fields, from_mongo, and convenience methods (active?, channels, priority)
- Created NotificationRuleOverride entity with scope accessor helpers (domain_id, user_id)
- Created NotificationRuleQueries with find_by_name, find_by_names, find_active_by_name, all_active, find_by_type, find_by_category, count
- Created NotificationRuleOverrideQueries with find_for_resolution (scope hierarchy query), find_by_rule_name, find_for_domain, find_one
- Created NotificationRuleCommands with create, update_by_name, deactivate, activate, delete_by_name
- Created NotificationRuleOverrideCommands with upsert (scope-aware with $setOnInsert), delete, delete_all_for_rule, delete_all_for_domain
- Updated CODEOWNERS with @highspot/app-platform ownership for all new files

**Notes:**
- Follows existing codebase patterns (SlackWorkspaceBotToken entity, AiGatewayDomainConfigQueries) for consistency
- NotificationRuleOverrideQueries.find_for_resolution implements the 3-tier scope hierarchy ($or query for user+domain, domain-only, user-only)
- NotificationRuleOverrideCommands.upsert uses $setOnInsert for immutable fields and $set for mutable ones
- These classes complete the create-mongo-collection skill requirements that were missing from PR #69976

---

