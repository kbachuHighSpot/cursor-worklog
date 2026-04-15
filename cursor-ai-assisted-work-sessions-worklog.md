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

