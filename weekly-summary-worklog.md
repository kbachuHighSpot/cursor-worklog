# Weekly Work Log

This log tracks weekly summaries of significant work across all sources (Cursor, GitHub, Jira, Slack, Confluence, Google Drive).

## Running Summary

*Last updated: 2026-08-21*

### Overall Key Accomplishments (Jan-Jun 2026)

**Significant Cursor Activities:**
- **Unified-notifications duplicate-email + digest-correctness hardening (Aug 7-21)**: Closed out a run of customer-facing duplicate/inconsistent notification-email bugs on the semantic/unified path. Stopped duplicate alert emails and gated the digest window on the unified flag (HS-195231, PR #75234 + hotfix #75277); keyed the digest idempotency guards off `details.type` and removed the semantic→legacy failure fallback so failed renders drop-and-re-sweep (HS-195424, #75443); added send idempotency + runtime alert/rule-drift validation + account-less direct sends for the batched job (HS-191129, #75459/#75467/#75680); grouped same-type alerts into focused sub-daily emails (HS-195333, #75533) and then card-wrapped text-only alerts + derived focused subjects from section titles with one-title-per-email splitting (HS-196272, #75878). Kicked off the Pinpoint→SES v2 migration with a new SES v2 API sender behind `use_amazon_ses_v2` across magma #9226 + nutella #75498 + LD #797 (recipient de-dup, partial-vs-total failure handling to avoid retry duplicates), all Bugbot comments triaged.
- **Semantic-email regression gates + observability hardening (Jul 7-24)**: NRQL-driven direct-email/digest observability (HS-191017) — comment/reply `email_type`→owning-kind aliasing at rule resolution, domain-scoped FF fallback for User-less dispatchers, a `flag_reason` metric sub-cause axis, and replica-set `OperationFailure` → `transient_mongo` routing — plus correctness fixes (weekly-meeting-digest card links, a `:no_email` hard-suppression bypass, rich item-card metadata + reply-chip subtitles, and a digest BSON-safety fix that was silently dropping every digest send). Landed PR #73589 (Jul 13), #73976 (WGLL-video rule seed), #74047 (ICS/metadata/digest fixes), #74177 (Email Index Review #2 card anchoring). Shipped TWO CI regression gates for semantic email: HS-191718 coverage-**delta** (checks *existence* of rule seed / production builder / preview) and a new in-process RSpec **snapshot-regression** gate (byte-level HTML + `email_data` diff vs a committed fixture catalogue, with a hybrid baseline→HEAD `email-snapshot-drift` Buildkite annotation). Merged the notifications-platform Cursor plugin (ai-plugins #83) documenting the full add-notification workflow including both gates.
- **HS-182399 Semantic Email Text & Styling Fixes (May 6 – May 15)**: Drove a multi-week PM-review-driven cleanup of semantic-email rendering quality. PR #70801 (43 files, +8,052/-815) covering 8 builder families' `[RULE:inlined_card_title]` violations (Pattern A allowlist + Pattern B helper extraction), assessment-family rebuild (7 `assessment_submitted` variations + `amf_assessment_submitted` + `amf_single_assessment_submitted` rich cards via Apollo `meeting_info` plumbing), `share_meeting` enrichment (render-time `engagement_meeting_list_records` Mongo lookup + meeting thumbnail via `ThumbnailPresenter`/`UrlPresenter` chain), `lesson_progress_reset` production entity-reversal fix, plus 153 i18n keys regenerated via `iidgen` after Buildkite caught 22 length violators + 130 descriptive keys + 1 case-collision. Migrated semantic-email gate from DynamicConfig to LaunchDarkly-only controls (LD PR #328 — `unified_notification_system`, `semantic_email_enabled_categories`, `semantic_email_category_overrides`) so PM-batch rollout per-category becomes UI-driven.
- **Notifications-Migration Test Tooling (May 8 – May 15)**: Built out `compare_email_previews.py` from a parity-only checker into a comprehensive PM-rubric tooling. Added 14 new migration rule checks (`[RULE:missing_card]`, `[RULE:body_after_following_reference]`, `[RULE:semantic_card_without_legacy_link]`, `[RULE:noun_entity_type_mismatch]`, `[RULE:reply_completeness]`, `[RULE:card_meta]`, `[RULE:default_avatar]`, `[RULE:cta_presence]`, `[RULE:header_parity]`, `[RULE:footer_parity]`, `[RULE:card_url_type]`, `[RULE:item_count]`, `[RULE:card_count]`, `[RULE:duplicate_sections]`, `[RULE:body_copy_length]`, etc.). Snapshot regression catalogue (186 baseline JSON files). Verdict bucket refactor (`warn_same`/`warn_structured`). Run summary auto-discovery of all reason types with severity icons + per-verdict breakdowns + strict/lenient success rates + `--rule-category` Mongo-backed filter + `--reason-type` matching backlog tags verbatim. PR #70903 (notifications-migration test scripts, 7 files, +7,171) merged May 11. Documented `--semantic-only-rubric` mode + `validate_rule_category.sh` wrapper in README.
- **Nutella MCP Hackweek Build-Out (Apr 23 – May 1)**: Drove the Mission Autonomous Nutella MCP project end-to-end. Created the `nutella-mcp` repo and synthetic-data seeder, shipped pitch tools, then ran a 6-month gap analysis (commits + Jira HISPI + Slack) to prioritize new tools. Closed ~10 of the gaps the same week — admin endpoints for spot + domain notification settings, SMTP relays, item processing status, reprocess polling, unsubscribe lookup, and a full feature-flag suite (`get_feature_flag_status` v2.0 → v2.1 with Mongo+LD+EvaluationReason, `list_enabled_features` `include_launchdarkly` opt-in, new `get_launchdarkly_flag_details` admin tool). Fixed two latent toolkit bugs along the way (array query-param encoding, dropped `static_query`). Tool surface grew from ~50 → ~65 HTTP tools; refreshed architecture docs and proposal so a new reader can land on either and get the correct picture. Added `debug-item-processing` skill packaging the diagnostic playbook from a real "unreadable item" investigation.
- **Notification Rules System Implementation (Apr 18-27)**: Built complete Phase 1-3 implementation of unified notifications. Seeded ~382 notification rules from ALERT_CONFIG + EMAIL_SETTINGS (Apr 18). Created NotificationEngine with rules-first routing, NotificationRuleResolver with thread-safe caching and defensive copying (Apr 26). Built Phase 3 REST API (9 endpoints) with operator authorization and audit logging (Apr 27). Implemented Phase 5 magma admin UI consuming the REST API.
- **Semantic Email Migration (Feb-Apr)**: Built complete MJML-based rendering system replacing ~450 legacy Velocity templates. Designed EmailContentBuilder module split + auto-derived `_v2` architecture (Mar 12). Migrated all builders to self-registration pattern with `SemanticAlertRenderer.register` (Mar 26). Introduced Hashie::Dash typed data classes across 27 builders (Apr 8-14). Fixed IndifferentAccess mutation bug (94 failures). Wrapped 16 builder files with `Hspt::Intl.t()` for i18n (Apr 8). Created automated preview test coverage for all kinds (Mar 29). Architected 3-PR split strategy for the 71-file PR.
- **Notification Rules System Design (Mar-Apr)**: Developed PM-editable template text plan with i18n tradeoff analysis (Mar 14). Created detailed phase plans (3-12) with architecture diagrams, code snippets, and cross-phase dependencies (Apr 25). Extended to multi-channel scope with phased REST APIs (Mar 29).
- **CDN Infrastructure (Jan-Mar)**: Set up CDN Lambda local dev environment with Python standards and CI pipeline (Feb 17-19). Investigated cache invalidation feasibility (Mar 8). Analyzed CDN caching paths and Lambda memory for cache sizing (Mar 19).
- **Content CDN Alert Redesign (Mar 30)**: Implemented per-status-code CloudFront error rates with distribution-level faceting, Lambda duration alerts with region faceting, and Opsgenie integration in Terraform.
- **Region Settings Bug Fix (Mar 10)**: Fixed high-severity bug where PUT handler for content regions wiped all regions when `regions` key omitted.
- **Feature-Flag Observability (Apr 5)**: Added OTel counter `semantic_email_flag_check_count` and `EventLogger.error` for FF routing visibility after investigating why legacy emails slipped through.
- **Developer Tooling**: Built email preview endpoint, automated comparison script, `SEMANTIC_VS_LEGACY.md` and `ALERT_CONFIG_TO_SEMANTIC_MAPPING.md` reference docs (Mar 29). Planned Admin "Notifications" menu (Mar 17). Built AI-assisted work logging with weekly MCP review skill. Enhanced worklog rules/skills with mid-session logging, end-of-conversation checks, and expanded significance criteria (Apr 6).
- **Cursor Skills/Rules Discoverability + Reuse Hardening (May 13 – May 15)**: After today's i18n incident exposed four orthogonal rule/skill discoverability failures (stale globs, invisible repo-local skills, passive cross-references, mandates buried in long files), authored `effective-cursor-rules` user rule + shareable `docs/effective-cursor-rules-and-skills.md` post-mortem with audit one-liners. Created `learn-session-fixes` skill (auto-fires on user acceptance signals, hybrid persistence target with diff-preview + confirmation). Added Patterns I (render-time entity-card enrichment via Mongo lookup) + J (canonical thumbnail presenter chain) to `migrate-semantic-email-body-copy`. Cross-referenced 7 semantic-email-migration skills' front-matter and replaced the divergence-prone copy/overwrite pattern with permanent symlinks pointing into `ai-plugins/nutella-semantic-email-migration/` (via `add-nutella-semantic-email-migration` branch). Worklog skill+rule updated to gate git push on user confirmation via `AskQuestion`. New `concise-code-comments` rule + sweep across HS-182399 PR removed ~3,348 net lines of comment cruft and ~349 lines of opaque `Pattern E`/`[RULE:foo]` taxonomy from in-code docstrings.
- **Execution Plan Document**: Created and shared semantic email migration execution plan with Nathan and Nav (Mar 17), updated and re-shared (Apr 17).
- **Semantic Email Batch-2 / Batch-3 / Batch-4 / Batch-5 ship train (May 27 – Jun 12)**: Five back-to-back batched landings of the unified-notifications semantic email migration. Batch-2/3 (PR #71757, merged May 29) — NR fixes, entity-stub hardening, tracking/preview tooling, mirrored legacy pitch URL, `scan_preview_inline_urls.py` scanner, and the `semantic-email-url-helpers` Cursor rule. tracking_tag plumbing landed for ~120 kinds (PR #72151, merged Jun 4) after two superseded attempts (#71848, #72136) — `?source_alert=<alert.id>` + `?source=email.<tracking_tag>` now wrap every semantic alert URL via the `tracked_url` helper, eliminating the `[RULE:tracking_tag]` informational backlog. Batch-4 direct emails (#72067, closed Jun 9) walked the direct-email surface; signup email custom-message inviter-name bug fixed (HS-187052, PR #72066 merged Jun 3 — `signup_user` was passing recipient as `from`). Batch-5 digest framework + Batch-4/6 direct-email + legacy pitch emails consolidated in PR #72529 (merged Jun 12).
- **Notification rules per-kind batching realignment (HS-182402, Jun 7-8)**: PR #72251 retired the synthetic `digest` rule kind, switched to per-kind `delivery_strategy.batching` so each notification carries its own batching window in the rule, and fixed seed drift uncovered by the migration. Unblocks chrisk1123's actor_suppression + recipient-condition follow-ups (PRs #71961, #72252, #8988) which depend on stable per-kind rule shape.
- **CDN Lambda throttling mitigation campaign (HS-185019, Jun 15-23)**: Five-repo coordinated change against the `prod_content_cdn_lambda_throttling` New Relic alert root cause. magma PR #9024 — graceful shutdown for magma-api so in-flight requests drain on `SIGTERM` instead of being dropped + retried (which previously bursted the account-shared 1000-concurrency lambda limit during pod scaling churn). magma-ops PR #458 — bumped `terminationGracePeriodSeconds` to 100s to give the new shutdown handler time to drain. content-cdn-lambda-handler PR #5 — tightened `urllib3` retry/timeout bounds and memoized `URLCache` entry size to reduce per-retry CPU + memory pressure. terraform PR #5463 — bumped lambda module to v1.9 to consume the handler change. tf-newrelic-alert PR #981 — fine-tuned the CDN alerts now that retry-storm volume should drop. All five merged; ticket Closed Jun 23.
- **Unified-notifications observability chain (HS-186448 + HS-180230 + HS-180221, Jun 18 – Jun 26)**: Closed out the operator-facing observability surface for the unified-notifications work end-to-end. (1) Diagnostic surface: latest-env debug BCC + `EmailReplay` CLI+REST endpoint for re-rendering past semantic alerts on demand (nutella #73129 + magma #9059, merged Jun 25); (2) Seeding completeness: notification rules seed + sheet-driven overlay so PM-maintained rule configs flow into seed without per-row code changes (#73002, merged Jun 22); (3) Digest framework polish: cap enforcement + sampler set + immediate/batched recategorization + cross-builder polish (#72914, merged Jun 24); (4) Metrics normalization Phase 1+2 (nutella #73245 + otel-collector-ops #385, opened Jun 26) — four signal renames (`notification_rules_engine_delivered_total{channel, delivery_mode}`, `email_render_duration_ms`, `email_render_fallback_total`, `email_batch_capped_out_total`), `domain_id` strip on 3 new-engine counters (`notification_rules_alert_count`, `notification_rules_email_count`, `alerts_create_count`) before full rollout would have inflated cardinality ~150×, recipient gauges → `email_dispatch_recipients{type, header}` histogram, and the `email_(.*)` collector exclude deletion that the rename uncovered. Also filed HS-189038 (Jun 18) for the SendGrid 421-max-messages-per-connection failure mode in `SmtpSend.sendWithUnsubscribeLink()` that affects any caller with >100 BCC recipients (pitch, digest, share-with-many).

**Significant Proposals:**
- Per-rule-category PM-batch rollout strategy for semantic emails using LaunchDarkly category allowlist + per-user/per-domain overrides (proposed in `#crew-app-platform-private` and DMs with Nav, May 13). Three-flag composition (`unified_notification_system` + `semantic_email_enabled_categories` + `semantic_email_category_overrides`) with strict per-user precedence so internal-QA can early-access a category their domain has killed off. Drove Nav's category-by-category review batching workflow.
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
- **Semantic Email Text & Styling (HS-182399)**: nutella PR #70801 (43 files, +8,052/-815, opened May 7, ~9 days iterating) — assessment-family rebuild + 8 builder families' card-title fixes + LD migration + i18n key sweep + concise-comments sweep. Still open, multiple "high-risk file" / "Large PR" Github bot warnings under active triage with reviewers.
- **Notifications-Migration Test Tooling (HS-180220)**: nutella PR #70903 (7 files, +7,171, merged May 11) — landed `compare_email_previews.py` + 3 sibling scripts (`export_preview_data.py`, `test_email_previews.py`, `compare.sh`) + comprehensive README documenting all rule checks + snapshot workflow.
- **LaunchDarkly Flag Definitions**: launchdarkly-flags PR #328 (merged May 14) — three new app-platform flags (`unified_notification_system`, `semantic_email_enabled_categories`, `semantic_email_category_overrides`) with full sample-variations + targeting-rule documentation and recommended rollout order. Approved by Jeff Sarmiento (cross-environment variation review path).
- **Notification Rules (4 stacked PRs)**: PR #70041 (seed 382 rules, merged Apr 22) -> PR #70323 (backfill push channel, merged Apr 27) -> PR #70320 (NotificationEngine Phase 2, merged May 5) -> PR #70329 (Phase 3 REST API, merged May 13). Magma PR #8831 (admin UI, merged May 5). Magma PR #8894 (admin pagination follow-up, opened May 14).
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
- HS-179437: Notifications CS1 Foundations (P1, **Closed** May 8) — epic split: 26.4.0-shippable work (8 tickets) closed; 14 open tickets reparented to new beta-targeting epic HS-183484 ("Notifications CS1 - Foundations - [Highspot Beta]") so each epic reflects a single release boundary.
- HS-182399: PM Feedback iteration #1 - Text and Styling changes (P3, In Progress) — driving the PR #70801 work this fortnight.
- HS-185019: Mitigate `prod_content_cdn_lambda_throttling` (P3, To-Do, **created May 15**) — KTLO ticket capturing 3 follow-ups from the New Relic alert thread (magma-api pod scaling tuning, retry reduction on connection failures, graceful shutdown to prevent retry-storm bursting account-shared lambda concurrency).
- HS-183419: Plumb tracking_tag through semantic email builder lambdas (P3, To-Do)
- HS-180217: Seed notification rules collection (P3, Closed)
- HS-180222: NotificationEngine Phase 2 (P3, Closed - merged May 5)
- HS-180223: Phase 3 REST API + Admin UI (P3, Code Review)
- HS-180220: Notifications migration test scripts (P3, Closed - merged May 11)
- HS-181943: Summer Preview Localization (P1, To-Do)
- HCL-10295: Alerts pagination bug (P3, In Test)
- HISPI-12550: Timezone display bug (P2, Deployed)
- HS-155824: email_tracking_details_v1 slow query (P2, In Progress)

### Overall Key Challenges
- **Cursor rule/skill discoverability has 4 orthogonal failure modes** (May 13): stale globs in rules, repo-local skills not surfaced in `<available_skills>`, passive cross-references that don't pull readers in, and critical mandates buried inside long multi-topic rules. Surfaced when 153 i18n keys silently violated `iidgen` mandate despite a sub-skill documenting it. Mitigated via `effective-cursor-rules` user rule + audit one-liners + `i18n-keys.mdc` extraction + symlink-based skill activation. Open follow-up: pre-commit hook / RuboCop cop scanning `Hspt::Intl.t(...)` calls — only commit-time enforcement closes the gap regardless of agent context. Also: `nutella/.cursor/**` is gitignored, so in-repo rule edits don't propagate to teammates without unignoring.
- **Padrino autoloader does NOT re-execute top-level code blocks on file change** (May 13): `LEARNING_KINDS.each { |kind| SemanticAlertRenderer.register(...) }` registration lambdas capture their body at module load time; subsequent edits inside the lambda only take effect after a full server restart. Diagnostic: if Pattern G (method-body change) worked but Pattern E (lambda-body change) didn't, this is the cause. Fix: move dispatch from registration lambda into the method body. Generalizable across SendFailed/PitchRelationship/SpotAccess/Share/etc. families — documented as a Common Gotcha in the skill.
- **Ruby `extend` mixes methods but not constants** (May 15): `share_builder.rb` referenced `THUMBNAIL_WIDTH` / `THUMBNAIL_HEIGHT` directly even though the host module `extend EmailContentBuilder::Base`. The unqualified name resolved fine at parse time but raised `NameError` at first invocation. Fix: always qualify as `EmailContentBuilder::Base::THUMBNAIL_*` in sibling builders. Codified as a regression spec template in Pattern J.
- **Production preview parity bugs hide behind `nil`-tolerant short-circuits**: `share_meeting` lambda computed thumbnail correctly via `get_item_thumbnail_url(FETCH_MEETING_ITEM.call(...))` but the preview branch hardcoded a URL string and skipped both presenters; the constant-qualification gotcha (above) was hidden until a non-nil URL was passed. The diagnostic flow is "audit every entity-card thumbnail path; preview must route through the same chain as production." Documented as Pattern J.
- **Padrino dev-server stale "Could not render" responses**: after fixing a render-time exception, the response cache continues serving the failure page until busted via `?cb=$(date +%s%N)` query param. Wasted ~30 minutes of debugging during share_meeting work; documented in Pattern J + skill gotchas.
- **`AlertPresenter#data_value_to_output` short-circuits on `id.nil?`** (May 9 mock-data drain): mock dicts that pass `{title, url}` but no `{type, id}` silently drop the entity — entire output becomes `{}` because `data_to_output`'s `rescue` catches every exception. Only diagnostic surface is `EventLogger.error` in `~/Codebase/latest/nutella/web/server.out`. Fix: always pass BOTH `type` AND `id` together; seed `Hspt::EntityCache` with the constructed entities under both their direct id and `"alert_<id>"` alias. Phase 2 mock-data drain unlocked 5 missing_card kinds and added "Debugging Preview Failures" section to `semantic-email-previews.mdc` pointing at the log.
- **Production data-shape asymmetries** (May 6 lesson_progress_reset): only lesson kind where `:item => lesson, :assigned_item => course` (reversed from every other lesson kind). Legacy template handled it via key-based interpolation (`[{item}]`/`[{assigned_item_title}]`), but semantic builder reads positionally → renders course title in lesson slot. Production has been shipping the wrong title since this kind was migrated. Fix: per-kind entity swap at registration boundary so direct callers (tests, preview) keep natural shape. Now the second known asymmetry; if a third surfaces it's officially a pattern worth a skill section.
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
- **HS-196272 batched-digest card-wrap + section-title focused subjects (PR #75878, draft)**: Wrap text-only alerts in content-only cards, de-dup section titles within a tier, derive focused sub-daily subjects from section titles, and split focused flushes so each email carries exactly one title. Snapshots re-recorded; awaiting review.
- **HS-195782 Pinpoint→SES v2 migration (magma #9226, nutella #75498, Code Review)**: SES v2 API sender behind `use_amazon_ses_v2`; Bugbot cleared, blocked on required review/test gates.
- **HS-191129 AlertRuntimeValidations framework (Code Review)**: send idempotency + runtime alert/rule-drift validation for the batched-alert send job (consolidated in #75680).
- **HS-183879 Amazon Pinpoint deprecation [Internal GA]**: Dev Ready — email transport migration follow-on.

### Recently Shipped (last fortnight)
- **HS-195333 focused grouped emails (merged Aug 14)** — group same-type alerts into one focused email within sub-daily windows.
- **HS-195424 semantic-path duplicate email fix (merged Aug 12)** — `details.type` idempotency guards + drop-on-failure (no legacy fallback).
- **HS-195231 duplicate alert emails + digest-window gate (merged Aug 7, hotfix #75277)** — engine-routed double-send guard + unified-flag digest-window gate.
- **HS-193844 semantic email header/footer tracking parity (merged Aug 10)** — `?source_alert` / `?source=email.<tag>` wrap now applied to header + footer URLs.
- **HS-191129 send idempotency + runtime validation (merged Aug 18, #75680)**.

### Current Blockers
- HS-189038 (SendGrid 421 max-messages-per-connection) — filed Jun 18; owned by App Platform; magma `SmtpSend.sendWithUnsubscribeLink()` needs transport recycling or 421-retry inside the loop. Related in-flight: HS-195036 (SmtpSend empty-TO failure, magma #9211 under review).
- HS-183419 follow-on: `tracking_tag` wraps semantic alert URLs via `tracked_url`, but a few digest/direct-email paths still bypass it — surface in next backlog sweep
- HS-151210 (Pinterest font request) remains Blocked
- `nutella/.cursor/**` is gitignored, so in-repo rule edits don't propagate to teammates without unignoring `.cursor/rules/`
- Repo-local skills are not surfaced in `<available_skills>` — Cursor product behavior; needs feature request or config investigation

---
## 2026-08-21 - Weekly Review (2026-08-14 to 2026-08-21)

**Summary:**
Focused on unified-notifications digest correctness and the Pinpoint→SES v2 migration. Landed the consolidated HS-191129 send-idempotency + runtime-validation PR, opened the HS-196272 batched-digest card-wrap + focused-subject work, kept the SES v2 sender PRs moving through Bugbot, and reviewed several crewmates' notification PRs.

### Significant Cursor Activities
- **HS-196272 batched-digest card-wrap + focused subject (PR #75878, draft, opened Aug 20)**: Wrap text-only alerts in content-only cards, de-dup section titles within a tier, derive focused sub-daily subjects from section titles, and split focused flushes so each email carries exactly one title. Moved `scheduled_subscription` to an `immediate_spot` preview category (pre-existing drift) and re-recorded snapshots. Created the ticket (App Platform, under HS-183875) and draft PR.
- **HS-191129 send idempotency + runtime validation (PR #75680, merged Aug 18)**: Consolidated send-idempotency, runtime alert/rule-drift validation, account-less direct sends, and subject cleanup for the batched digest job.

### Significant PRs
- **nutella #75680 [HS-191129]** (merged Aug 18) — notification send idempotency + runtime validation + account-less direct sends + subject cleanup.
- **nutella #75878 [HS-196272]** (draft) — batched-digest card-wrap + section-title focused subjects.
- **magma #9226 / nutella #75498 [HS-195782]** (open) — Amazon SES v2 API sender + routing behind `use_amazon_ses_v2`; Bugbot review cleared.
- **launchdarkly-flags #812** (open) — remove semantic-email category + notification dedup flags (flag cleanup).

### Significant Helping Others
- Reviewed Chris K's **#75678** (5-minute unified-notification domain sweep as `alerts_send_v2`, merged Aug 21), **#75799** (domain_id facet on email event metrics, merged Aug 20), and **#75587** (revert `scheduled_subscription` to Immediate, HS-195652, merged Aug 17).

### Significant Jira Tickets
- **HS-196272** (batched digest card-wrap + focused subject, P3, **In Progress**), **HS-191129** (AlertRuntimeValidations, P3, **Code Review**), **HS-195782** (SES v2 PoC behind FF, P3, **Code Review**), **HS-195652** (revert scheduled_subscription to Immediate, P1, **Ready for Test**), **HS-195333** (focused grouped emails, P1, **Code Review**).

### Key Challenges This Week
- A RuboCop cop crash on a multiline method chain in `digest_builder.rb` forced a two-statement refactor of the distinct-titles computation.
- 64 intentional snapshot regressions from the card-wrap + title-dedup changes required re-recording the manifest and disambiguating intentional drift from real bugs.
- Guaranteeing an exact focused subject required splitting flushes by kind+variation signature rather than accepting a generic count.

**Notes:**
- HS-196272 draft PR pending review; SES v2 sender PRs blocked only on required review/test gates.

---
## 2026-08-14 - Weekly Review (2026-08-07 to 2026-08-14)

**Summary:**
Heavy duplicate-email remediation and idempotency-hardening week on the semantic/unified email path, plus kickoff of the Pinpoint→SES v2 migration. Shipped the HS-195231 duplicate-send fix (with a same-day hotfix and revert-churn recovery), the details.type idempotency + drop-on-failure fix, the HS-191129 send-idempotency/validation work, and the HS-195333 focused-grouped-email grouping. Opened the SES v2 sender across magma + nutella + LD flags.

### Significant Cursor Activities
- **Semantic-path duplicate email fixes (HS-195424, PR #75443, merged Aug 12)**: Keyed the two digest idempotency guards off `details.type` (semantic rendering overwrites the top-level `type` to `:semantic_email`) to stop the ~30-min duplicate Content-Expiry digest, and removed the semantic→legacy failure fallback so a failed render drops-and-re-sweeps instead of silently re-sending via legacy.
- **HS-195333 focused grouped emails (PR #75533, merged Aug 14)**: Group same-type alerts into a single focused email within sub-daily batching windows — the foundation the HS-196272 subject work builds on.
- **SES v2 Phase 0 (magma #9226, nutella #75498, LD #797, Aug 13-14)**: New Amazon SES v2 API sender behind `use_amazon_ses_v2` — recipient de-dup, partial-vs-total failure handling (no whole-job retry duplicates), and pitch-modal provider recognition. Triaged all Bugbot review comments across the three PRs.

### Significant PRs
- **nutella #75234 [HS-195231]** (merged Aug 7) + hotfix **#75277** (26-5-2) — stop duplicate alert emails; gate digest window on the unified flag. Recovered from a revert-churn cycle (#75279/#75281).
- **nutella #75443 [HS-195424]** (merged Aug 12) — details.type idempotency + drop-on-failure (no legacy fallback).
- **nutella #75459 / #75467 [HS-191129]** (merged Aug 12-13) — send idempotency + AlertRuleValidator send-time drift drains.
- **nutella #75336 [HS-193844]** (merged Aug 10) — semantic email header/footer tracking parity.

### Significant Helping Others
- Reviewed Chris K's **#74859** (internal email-notification REST API) and **#75434** (post preview data through the notifications API); Murali's **#75290** (speaker tagging semantic) and **#75453** (direct email duplicate send fix); Scott F's **#75514** (scope event duplicate detection by topic+entity); plus magma/nutella empty-recipient guards (#9211 / #75087).

### Significant Jira Tickets
- **HS-195231** (duplicate feedback_spot email, P1, **Closed** Aug 11), **HS-183484** (Notifications CS1 Highspot Beta, P1, **Closed** Aug 10), **HISPI-13360** (course-review digest consolidation, fdx.com, P2, **Closed** Aug 12), **HFX-1628** (hotfix request, Aug 7).

### Key Challenges This Week
- The HS-195231 fix went through a merge→revert→re-merge churn plus a same-day hotfix onto release/26-5-2 before it stuck.
- Distinguishing genuine failure fallbacks (to remove) from intentional mid-rollout routing fallbacks (to keep) when removing the semantic→legacy path.

**Notes:**
- Some HS-195231 hotfix-churn merges reconstructed from GitHub + Jira; the HS-195424 and SES v2 Phase 0 sessions were captured directly in the session worklog.

---
## 2026-08-07 - Weekly Review (2026-08-01 to 2026-08-07)

**Summary:**
High-throughput week closing out the direct-email rules-engine work (HS-191017) and a batch of mongo-flag deprecations, plus two customer-facing notification-email bug fixes. Landed the direct-kind engine routing + classification/dedup-off migration, removed three legacy email mongo flags, fixed a cross-scale-unit admin 403 in magma, and froze the meeting-recap preview clock to stop a calendar-dependent snapshot flake. Opened HS-195231 (duplicate alert emails + digest-window gate) and addressed its Bugbot review.

### Significant Cursor Activities
- **Duplicate alert emails + digest-window gate (HS-195231, PR #75234, opened Aug 7)**: Two related fixes surfaced from customer duplicate-email reports. `AlertCommands.create` now tags engine-routed alerts so legacy per-kind builders skip their bespoke immediate send (eliminating back-to-back and now-plus-digest duplicates), and `SendAlertsJob` only applies per-kind `batching_window_minutes` when the unified flag is on so flag-off domains keep their single previous-day digest. Follow-up in the same session addressed the Bugbot review: preserve the legacy email fallback when the engine's synchronous send fails (`channels_failed`/`email_failed?` on the engine Result), and reject engine-routed alerts per-recipient in `send_emails`/`send_emails_async` so mixed per-user-rollout batches don't blast `alerts.first` to everyone.
- **Meeting-recap preview clock freeze (PR #75095, Aug 5)**: Root-caused a red semantic-email snapshot gate on an unrelated PR to a calendar-dependent flake — the recap block's live-clock date heading shifted the preheader truncation boundary as the calendar advanced past the manifest record date. Froze the clock at the source (`MEETING_DIGEST_PREVIEW_TIME`), aligning the release-branch fix line-for-line with the main fix (#75103, Pankaj) after confirming main was already patched.

### Significant PRs
- **HS-191017 direct-email engine routing (merged Aug 4)**: PR #74933 (route direct email kinds through the notification engine) + PR #74932 (realign `notification_rules` classification + dedup-off migration). Companion docs in ai-plugins #101 (direct-kind engine routing + `externally_managed` taxonomy).
- **HS-194854 admin 403 fix (magma #9202, merged Aug 4)**: `notification_rules` & `email_replay` admin pages 403'd on non-su0 scale units; fixed the authorization path.
- **Mongo-flag deprecations (merged Aug 4)**: PR #74992 (`email_sendgrid_use_email_events`) + PR #75001 (`enable_reply_to_for_notifications`) — dead-code + flag removal (HS-190612, HS-190624; HS-190610 also closed).

### Significant Helping Others
- **HS-194858 SendAlertsJob review (PRs #74972 + #74996, merged Aug 3-4)**: Reviewed Chris K's dispatcher pre-filter, multi-domain batching, and calendar-anchored Daily/Weekly digest windows (main + release/26-5-2 backport).
- **HS-195036 magma SmtpSend review (#9211, open)**: Reviewing the empty-TO-addresses failure in `mail_v2` jobs.
- **HS-194013 review (#75103, merged Aug 5)**: Reviewed the meeting-digest preview-time freeze that fixed the snapshot flake on main.

### Significant Jira Tickets
- **HS-191017** (route direct emails through the rules engine, P3, **Closed**), **HS-190612 / HS-190624 / HS-190610** (mongo-flag deprecations, P1, **Closed**), **HS-194854** (admin 403 on non-su0, P3, **Closed**).
- **HS-195231** (duplicate email for batched `feedback_spot`, P1, **In Progress**) — PR #75234 open, Bugbot review addressed.

**Notes:**
- HS-195231 still open (awaiting test/merge). Carry-over blockers unchanged (HS-193844 verification-code tracking parity; HS-189038 SendGrid 421).
- Session worklog captured only the Aug 5 preview-clock work; the HS-191017 / flag-deprecation merges (Aug 3-4) were reconstructed from GitHub + Jira.

---
## 2026-07-31 - Weekly Review (2026-07-25 to 2026-07-31)

**Summary:**
Focused week hardening the semantic-email snapshot regression gate (HS-194013) and fixing a rules-engine silent-drop bug. Reworked the snapshot gate to manifest-hybrid storage (committed checksums + content-addressed blobs in the build cache), folded the re-warm into the integration runner, and aligned the new-kind guard with record mode. Shipped HS-194271 fixing emails silently dropped for `send_immediately` kinds seeded as batched rules.

### Significant Cursor Activities
- **Snapshot gate → manifest-hybrid storage (HS-194013, PR #74613)**: Replaced the committed ~11 MB / 724-file HTML+JSON fixture catalogue with a committed `snapshots.manifest.json` (kind→sha256, ~92 KB) as the correctness source of truth, moving baseline bytes to content-addressed blobs in the `highspot-build-state` cache. Gate is now `render → normalize → sha256 → compare-to-manifest` with zero S3 dependency; a cache miss degrades the diff annotation to a checksum note but still blocks. Dry-run validated end-to-end against local MinIO.
- **Re-warm wiring + parallel-safe annotations (PR #74613 follow-up)**: Folded the main-only blob re-warm into the integration runner (which already renders every kind) instead of a dedicated ~15-25 min boot; added a render marker so exactly one shard uploads under file-level splitting, a partial-archive guard, and per-shard annotation contexts.
- **New-kind guard aligned with record mode (Jul 26)**: Fixed a dead-end loop where the "manifest covers every renderable kind" guard demanded a manifest entry for kinds that record mode skips (nil/empty render); guard now renders only un-baselined candidates and flags just those that actually render.

### Significant PRs
- **HS-194271 silent-drop fix (PR #74760, merged Jul 30)**: Rules engine was silently dropping emails for `send_immediately` kinds seeded as batched rules; fixed the drop and the associated metrics.
- **Snapshot-gate validation (PR #74651, closed Jul 27)**: Throwaway `[do-not-merge]` PR to exercise the semantic-email snapshot gate end-to-end in CI.

### Significant Helping Others
- **launchdarkly-flags #644 + #632 (reviewed, merged Jul 29)**: `notification_dedup_enabled` (HS-180228) and `notification_throttle_enabled` (HS-191506) per-domain flags.
- **HS-193255 Sorbet gate (PR #74654, Jul 27)** and **HS-0 lint-skip on main builds (PR #74536)** — CI-hygiene reviews.

### Significant Jira Tickets
- **HS-194271** (silent drops for send_immediately-as-batched, P3, **Closed**).
- **HS-194190** (remove credentials logged in a content-cdn S3 bucket, P1, **Closed** Jul 27) — security cleanup.
- **HS-179437** (Notifications CS1 Foundations epic, P1, **Closed** Jul 30).

**Notes:**
- Snapshot-gate hardening was auto-logged to the session worklog (Jul 25-26); the HS-194271 fix and reviews were reconstructed from GitHub + Jira.

---
## 2026-07-24 - Weekly Review (2026-07-21 to 2026-07-24, partial week)

**Summary:**
Short mid-week window centered on a new blocking regression gate for semantic emails and shipping the notifications-platform Cursor plugin. Built an in-process RSpec snapshot-regression gate that renders every previewable email kind and diffs normalized HTML + `email_data` against a committed fixture catalogue, with a hybrid baseline→HEAD Buildkite annotation on failure; validated end-to-end through the integration harness. Merged the notifications-platform plugin into ai-plugins (#83) and extended its `add-notification` skill to cover the new gate. One cross-team review (otel-collector NR include-filter for `notification_rules` metrics).

### Significant Cursor Activities
- **Semantic email snapshot-regression CI gate (session milestone; branch in-flight, PR pending)**: New blocking `spec/integration` RSpec gate that renders every previewable kind through the same `SemanticEmailPreview` methods the controller uses and byte-diffs normalized HTML + `email_data` against a committed fixture catalogue (`spec/integration/common/email/semantic/snapshots/`). Motivation: the builders and the two shared MJML wrappers (`semantic_email.mjml.erb` + `external_recipient_email.mjml.erb`) are shared, so one change can silently regress an unrelated kind — the coverage-delta gate checks *existence*, this checks the *bytes*. Volatile content (timestamps, tracking params, MJML version) is normalized via patterns ported from `compare_email_previews.py`. Record mode (`UPDATE_EMAIL_SNAPSHOTS=1`) regenerates fixtures; check mode drives off the committed set. Added a **hybrid annotation**: on failure the run aggregates a per-kind baseline→HEAD unified diff into one `email-snapshot-drift` Buildkite annotation (the committed fixture IS main's approved baseline — main re-runs the gate — so no second boot of main is needed). Validated end-to-end by perturbing the shared `FOOTER_ADDRESS` constant → 691 kinds drifted into a single aggregated annotation; reverted and confirmed the clean run auto-removes the stale report. Runtime ≈ 29s render + 7s load for 723 examples.
- **notifications-platform plugin merged (ai-plugins #83, merged Jul 22)**: Landed the notifications-platform Cursor plugin (add-notification + digest-framework skills). Extended the `add-notification` skill with a new "Step 8b" documenting the snapshot-regression gate — how to run it locally whenever a notification is added / modified / enhanced, how to record a new kind's fixture, and how to resolve a `Snapshot drift` failure (re-record an intended change vs fix an unexpected regression).

### Significant Helping Others
- **otel-collector-ops #405 (HS-193244) reviewed for Chris K** — Allow `notification_rules` OTEL metrics through the New Relic include filter, so the direct-email `flag_reason` / rules-engine counters shipped the prior fortnight actually reach NR. Closed Jul 22.
- **Slack (#eng-observability, Jul 22)** — flagged the pain of per-scale-unit PR splits to Chris K on the otel include-filter rollout.

### Significant Jira Tickets
- **HS-193844** (Semantic email tracking-parity regression in verification-code email — header + footer links, P3, **Untriaged**, created Jul 23) — new bug: verification-code email URLs miss the `?source_alert` / `?source=email.<tag>` tracking wrap that legacy production applies.
- **HS-193051** (Digital Room activity card shows first DR item instead of the DR name, P3, **Closed** Jul 23) — fixed by PR #74177 the prior week.
- **HS-191718** (coverage-delta CI gate, P3, **Code Review**) — the snapshot gate is its byte-level sibling.

**Notes:**
- Snapshot-gate work is on an in-flight branch; PR to follow. This session was not auto-logged to the session worklog — reconstructed here — so the merge/session trigger gap persists.

---
## 2026-07-20 - Weekly Review (2026-07-14 to 2026-07-20)

**Summary:**
Three semantic-email PRs merged (WGLL-video rule seed, a batch of ICS/metadata/digest fixes, and Email Index Review #2 card-anchoring fixes), plus the HS-191718 coverage-gate polish that wired each per-surface Fix hint to the owning notifications-platform skill step and substantially corrected that skill after a read-only dry run. Reviewed localization-duplication fixes (nutella + magma) and Chris K's throttling-guard removal (+ its deployment script).

### Significant Cursor Activities
- **HS-191718 coverage-gate fix hints + notifications-platform skill overhaul (Jul 20)**: Wired the six per-surface Fix strings in `.buildkite/check_semantic_email_coverage_delta.sh` and the mirrored `FIX_HINTS` in `scan_missing_email_previews.py` to each name the owning notifications-platform skill step (rule seed / production builder / preview). A read-only dry run of a sample kind through every step exposed that the skill covered only 2 of the gate's 3 surfaces (missing the production builder) and pointed at the wrong seed-migration template for alert kinds — corrected both, made email copy a mandatory Step 1 input, and clarified that legacy `.vm` templates are preview-only copies while production renders in magma. A `migrate-notification-kind` plugin was scaffolded then removed at the user's request (no committed trace); digest-framework plugin work remained on the same ai-plugins branch.
- **HS-191129 semantic email fixes (PR #74047, merged Jul 15)**: ICS render-time rebuild, metadata dedupe, digest polish, and missing metrics — a batch of semantic-email correctness fixes.
- **HS-192654 seed WGLL-video notification rules (PR #73976, merged Jul 15)**: Idempotent dated seed migration for `skill_wgll_video_{approved,pending_approval}` so their rule lookup returns a document instead of `:blocked`.
- **HS-193051 Email Index Review #2 (PR #74177, merged Jul 17)**: Fixed pitch / Digital Room activity-card anchoring, section titles, and the external-share CTA.

### Significant PRs
- **PR #74177** (HS-193051, MERGED Jul 17) — pitch/DR activity card anchoring + section titles + external-share CTA.
- **PR #74047** (HS-191129, MERGED Jul 15) — ICS rebuild, metadata dedupe, digest polish, missing metrics.
- **PR #73976** (HS-192654, MERGED Jul 15) — seed WGLL-video notification rules.

### Significant Helping Others
- **nutella #74102 + magma #9144 (HS-192879) reviewed for Scott Fletcher** — localization duplication fixes across both repos (merged Jul 16).
- **nutella #74222 + #74268 (HS-193249) reviewed for Chris K** — remove throttling guard from notification rules + its deployment script (merged Jul 20).
- **launchdarkly-flags #632/#644, nutella #73847/#73901 (HS-180228 / HS-191506) reviewed for Chris K** — dedup + throttle per-domain flags and the dedup-window rename migration.

### Significant Jira Tickets
- **HS-150860** (Welcome/signup email copy, P3, **Deployed** Jul 17).
- **HS-155824** (email_tracking_details_v1 slow query, P2, **Closed** Jul 15).
- **HS-183875** (Notifications CS1 Foundations — UX + Rules Engine, Closed Beta, P1, **In Dev**).
- **HS-188911** (Training video playback aborts mid-stream on enterprise networks, P3, To-Do) — triaged/assigned.

**Notes:**
- Carry-over: circulate HS-191718 for review; the byte-level snapshot-regression gate (next week) is the sibling to this existence gate.

---
## 2026-07-13 - Weekly Review (2026-07-07 to 2026-07-13)

**Summary:**
NRQL-driven observability + correctness hardening of the direct-email and digest paths (HS-191017), landing as PR #73589 (merged Jul 13) plus several in-branch commits. Four Jul 8 commits added metric granularity and routed transient Mongo flaps out of the "real bug" bucket; mid-week fixes covered a weekly-meeting-digest link regression, a `:no_email` hard-suppression bypass, rich item-card metadata + reply-chip subtitles, and a BSON-safety fix that was silently dropping digest sends. Six cross-team reviews (dedup guard + flags, bulk-pitch builder, CDN single-HTML serving).

### Significant Cursor Activities
- **HS-191017 direct-email observability + gating (4 commits, Jul 8)**: All NRQL-driven from latest0/su0. (1) Alias the seven comment/reply render-time `email_type`s onto their four owning alert kinds at rule resolution (`TEMPLATE_TO_OWNING_ALERT_KIND` + `canonical_rule_name`) so the comment family stops reporting `category_disabled` — one Mongo lookup, one cache slot per product event, zero new opt-out surfaces. (2) Domain-scoped FF fallback for direct-email dispatchers that pass bare-String recipients with no `User` (`ops`, `external_share_email_verification_code`) so a 100%-enabled domain flag is actually consulted. (3) Split the direct-email `skipped/flag_disabled` bucket by LD sub-cause via a new `flag_reason` metric attribute, so a terminal `:unsupported` kind is distinguishable from a will-resolve `:ff_off`. (4) Route replica-set state-change `OperationFailure` codes (10107/189/91/11602/13435) to `reason=transient_mongo` so the digest `exception` bucket becomes a genuine page-worthy signal.
- **weekly_meeting_digest meeting-card links (Jul 10)**: Production digest cards were rendering meeting titles as plain text with no "View Meeting" CTA — `enrich_weekly_digest_meetings!` never set `:url`. New `attach_dossier_meeting_urls!` stamps the tenant-scoped `?tracking_metric_name=dossier_meeting_prep` URL so click dashboards keep counting; scoped deliberately to this one kind to avoid breaking five sibling meeting kinds' analytics.
- **`:no_email` hard-suppression fix (Jul 11)**: The `:no_email => true` ALERT_CONFIG signal was only honored on batched-digest branches, so a kind flagged BOTH `:send_immediately` AND `:no_email` (`enrollment_errors_added`) still emailed. Added `return if options[:no_email]` at each `:send_immediately` branch; aligns the legacy dispatch path with the rules pipeline (which already omits `email` from such a kind's channels).
- **Rich item-card metadata + reply-chip subtitle (Jul 11)**: Entity cards gain Owner / Spot / `N lessons` / Session / Due-date segments (all zero-extra-Mongo), and every reply chip gains a job-title / Partner subtitle line — additive across 10 `build_reply` callers.
- **Scorecard enrichment + retention meeting date + digest BSON safety (PR #73589, merged Jul 13)**: BSON fix rewired the `alerts_send_v1` digest hash to carry `:to_user_id` instead of an unserializable raw `User` (which was silently dropping every digest send inside a swallowed rescue); scorecard/report subscription cards now hydrate the Item and reuse `build_item_card`; and a Bugbot-caught fix reads the outer `start_date` key NovaCore ships for retention emails.

### Significant PRs
- **PR #73589** (HS-191429 / HS-191017 branch, MERGED Jul 13) — migrate missing kinds, PM feedback, metrics; carried the retention/bulk-pitch builders + BSON + scorecard + retention-date fixes.

### Significant Helping Others
- **nutella #73490 (HS-180228) reviewed for Chris K** — enforce notification-rule dedup guard (merged Jul 8).
- **nutella #73568 (HS-191533) reviewed for Tanish** — semantic email builder for bulk pitch status report (merged Jul 8).
- **nutella #73672 + terraform #5553 (HS-191818) reviewed for noobmaster** — serve single uploaded HTML files via authenticated CDN.
- **launchdarkly-flags #632/#644 (HS-191506 / HS-180228) reviewed for Chris K** — throttle + dedup per-domain flags (Jul 13).
- **Slack**: #alerts-content-cdn-production (Jul 8) — explained an S3-overload CDN spike is expected/transient (browser-side retries noted as a follow-up to investigate); #eng-qa-ff-request (Jul 13) — coordinated "All categories" FF enablement for su0/su2 with Nathan, Nav, Chris.

### Significant Jira Tickets
- **HS-191017** (Route direct emails through rules engine, P3, **In Progress**) — observability/gating hardening this week.
- **HS-155824** (email_tracking_details_v1 slow query, P2, In Progress) — closed the following week.

**Notes:**
- Much of this week's work landed as in-branch commits on `kbachu-hs-191017-semantic-builders-retention-bulk-pitch` rather than discrete PRs; reconstructed here from the session worklog (which was well-populated this week).

---
## 2026-07-06 - Weekly Review (2026-06-27 to 2026-07-06)

**Summary:**
Ten-day window (Jul weekly cadence resumed after the Jun 26 review). Four semantic-email cleanup PRs merged early in the window (brand-wordmark squish, pitch-footer unsubscribe/left-alignment, welcome-copy PM refresh, bulk-pitch semantic rendering enablement), then a mid-week structural pivot: the HS-191017 stacked-PR series (route direct emails through the rules engine) resolved as **"Working As Designed"** on Jul 6 and all three PRs closed without merge, narrowing the follow-through to a single scoped PR (#73589, add semantic builders for the two kinds that were actually missing them). Closed the week with a new session-milestone piece — the HS-191718 CI delta gate for notification-coverage drift (draft PR #73598 opened Jul 6), and two Jul 1 spec drafts on notification dedup + throttling (HS-180228, HS-191506). Seven cross-team PR reviews (translation-ID fix, dedup guard, welcome copy, brand wordmark, pitch-footer locale, digest per-rule batching, pitch-viewer CSP hotfix).

### Significant Cursor Activities

- **HS-191718 CI delta gate for notification coverage — draft PR #73598 opened Jul 6**: Ended the week with a new gate that blocks any PR adding a notification kind to `AlertCommands::ALERT_CONFIG` or a direct type to `EmailCommands::SETTINGS` unless three companion rows also land: (a) a rule seed in `NotificationRulesShape::SHEET_BACKED_ATTRIBUTES` (or the mongo seed can't hand the kind a `notification_rules` document), (b) a semantic production path (either a `*_KINDS` list under `common/email/semantic/builders/**`, a `SemanticAlertRenderer.register(:<kind>, ...)` call, or a `DIRECT_BUILDERS` entry in `SemanticEmailRegistry`), (c) a preview row in `semantic_email_preview.rb`. Refactored `web/scripts/notifications-migration/scan_missing_email_previews.py` from a preview-only scanner into a unified three-surface coverage scanner (+564/-202) with robustified Ruby parsing (strips whole-line comments before parsing to kill commented-out `:sym => true` false positives; handles both `:sym =>` and `sym:` hash shorthand; handles `%i[]` / `%w[]` bulk-registration patterns inside builders and the registry). New `.buildkite/check_notification_coverage_delta.sh` wraps the scanner in a `git worktree`-based delta comparison — merge-base vs HEAD, JSON subtraction, Buildkite annotation with per-surface breakdown, exit 1 on new misses. Baseline gaps on `main` tolerated so the gate ships without a preflight cleanup PR (same rollout shape as `sorbet_delta_zero.sh`). New Jira ticket HS-191718 created under epic HS-183484 (Notifications CS1 Foundations), assigned to me, Feature Crew = "App Platform". Smoke tests: happy path passes; injected fake kind (no companions) flags on all three surfaces; `:options => { :no_email => true }` skips production + preview checks (rule-seed still applies).
- **HS-191017 stacked-PR series closed as "Working As Designed" (Jul 2 → Jul 6)**: Three PRs authored + closed inside this window without merge — #73512 (Jul 2, retire `type=direct` from EMAIL_SETTINGS-backed notification rules — 16-kind migration to `managed_externally`, 40-kind migration to `immediate`, 2-kind deletion, 40 new shape unit examples + 19 new migration integration examples), #73513 (Jul 3, prepared-alert engine path — `AlertCommands.create_many` with idempotency index on `(kind, user_id, source_event_id)` + `NotificationEngine.route_prepared_alert` — 38 new spec examples), #73543 (Jul 3, route six `managed_externally` kinds through the engine — PR 3 of the series). Ticket HS-191017 resolved as **"Working As Designed"** on Jul 6: current EmailCommands dispatch path for direct emails is correct and does not need engine-path parity. Follow-through narrowed to #73589 (opened Jul 6, add semantic builders for `retention_host_notification` + `bulk_pitch_status_report` — the two kinds that actually needed semantic builders, not the full engine-path rewrite). The design + implementation work is preserved in the closed-PR bodies + this worklog for reference if the direction reverses later.
- **HS-188890 Enable semantic rendering for bulk pitches (nutella PR #73468, merged Jul 2)**: Landed the follow-on to Tanish's HS-188860 (bulk-pitch semantic rendering exclusion, merged Jun 23) that surfaced this feature-flag task. Turns on `unified_notification_system` semantic rendering for the bulk-pitch email path so bulk sends now flow through the same builder + preview surface as single-pitch sends.
- **HS-150860 Update welcome/signup email copy (nutella PR #73459, merged Jul 1)**: PM-driven copy refresh on the welcome + signup email family. Landed together with the sibling translation-ID length fix PR #73508 (reviewed for Sai Krishna) that fixed a 9-char translation ID that violated the 8-char cap.
- **HS-191072 Fix semantic pitch unsubscribe footer + left-layout alignment (nutella PR #73404, merged Jul 1)**: Two-part fix on the pitch family under `unified_notification_system` semantic rendering — restored the unsubscribe footer that was rendering empty and corrected the left-side layout alignment. This closes the ticket surfaced Jun 26 during the HS-186448 metrics work.
- **HS-191365 Brand wordmark horizontally squished in semantic email header (nutella PR #73402, merged Jul 1)**: Header-image aspect-ratio fix — the brand wordmark was being scaled non-proportionally on Gmail iOS + Outlook rendering paths. Straightforward `width: auto` + explicit max-width fix; verified via preview snapshot regression.
- **Notification dedup + throttling spec drafts (HS-180228 + HS-191506, Jul 1)**: Two design docs shared as Jira comments — HS-180228 (Enforce notification rule deduplication guard: preventing duplicate-recipient alert emission across overlapping rules for the same event; enforcement layer that sits between `NotificationEngine.route` and the channel dispatchers) and HS-191506 (Support throttling in the rule definition: per-rule `throttling` block with `max_alerts_per_window` + `throttle_window_seconds` so noisy sources can self-limit without a code deploy). Both drafts documented the migration path from the current best-effort dedup at `AlertCommands.notify_users_of_event` up to a first-class engine-level guard.

### Significant Proposals

- **"Delta-only, baseline-safe" rollout for the notification-coverage CI gate** — proposed and shipped in this session's PR #73598 rather than the alternative "block on any missing entry, land a preflight baseline cleanup PR first." Same shape as `sorbet_delta_zero.sh`. Tradeoff called out in the PR body: the gate is silent on existing gaps until someone touches a kind, but blocks all NEW drift from day one.
- **"Working As Designed" resolution for HS-191017** — after landing three PRs of a stacked series that would have routed direct emails through the rules engine (parity with immediate/batched), the team reassessed and concluded the current EmailCommands dispatch is correct for direct sends. The narrower follow-through (#73589, adding two semantic builders that were actually missing) captures the only concrete gap. Documented so future re-visits know the design work was done, not skipped.

### Significant Documents

- Two Jira comments on HS-180228 + HS-191506 with the notification-dedup + throttling spec drafts (Jul 1). Documented as first-class design notes on the tickets rather than a separate Confluence page so the design lives next to the implementation ticket.
- `cursor-worklog/cursor-ai-assisted-work-sessions-worklog.md` — 5 session entries logged this window (Jul 1 dedup + throttling drafts, Jul 1 HS-188890 bulk pitches, Jul 2 HS-191017 PR 1, Jul 2 HS-191017 PR 2, Jul 6 HS-191718 CI gate). No mid-week merge events auto-logged for #73402 / #73404 / #73459 — the trigger-on-merge gap the Jun 26 review flagged is still present.

### Significant Helping Others

- **PR #73508 (HS-150860) reviewed for Sai Krishna** — Fixed an invalid 9-char translation ID that violated the 8-char `iidgen` cap on the welcome-email family; caught by the CI translation-ID length check landed earlier in the semantic-email migration. Merged Jul 6.
- **PR #73490 (HS-180228) reviewed for a teammate** — Enforce notification rule deduplication guard (the paired PR to the Jul 1 dedup spec draft). Under review; provided design-alignment comments referencing the spec draft posted to HS-180228.
- **PR #73295 (HS-182226) reviewed** — Enhance email pitch footer handling with locale support. Merged Jul 6.
- **PR #73240 (HS-180226) reviewed** — Honor per-rule batching window in alert digest flush; the runtime follow-up to the HS-182402 per-kind batching realignment that landed Jun 8. Merged Jul 1.
- **PR #73211 (HS-191028) reviewed** — Apply custom CSP modifications on unauthenticated pitch viewer routes hotfix. Merged Jun 30 (PR opened prior week; review + merge landed in this window).
- **Slack unblocks**: Told Sai Krishna in `#crew-app-platform` that semantic email path is automatically available for their PR without any specific code changes (Jul 1); coordinated with Derek Kwiatkowski and Mat Sadler in `#eng-foundation` on Buildkite build 270787 test-timeouts blocking my HS-191017 PR merge (Jul 3).

### Significant PRs

- **PR #73598** (HS-191718, DRAFT Jul 6) — CI delta gate for notification coverage. 4 files, +554/-202. Base = `main`. Isolated via scratch `git worktree` so the active branch's in-flight retention_host_notification work stays clean.
- **PR #73589** (HS-191017 follow-through, OPEN Jul 6) — Add semantic builders for `retention_host_notification` + `bulk_pitch_status_report`. In progress on active branch.
- **PR #73543** (HS-191017 PR 3, CLOSED Jul 6, unmerged) — Route six `managed_externally` kinds through the engine. Superseded by "Working As Designed" resolution.
- **PR #73513** (HS-191017 PR 2, CLOSED Jul 6, unmerged) — Prepared-alert engine path: `create_many` + idempotency index. Superseded by "Working As Designed" resolution.
- **PR #73512** (HS-191017 PR 1, CLOSED Jul 6, unmerged) — Retire `type=direct` from EMAIL_SETTINGS-backed notification rules. Superseded by "Working As Designed" resolution.
- **PR #73468** (HS-188890, MERGED Jul 2) — Enable semantic rendering for bulk pitches.
- **PR #73459** (HS-150860, MERGED Jul 1) — Update welcome/signup email copy per PM refresh.
- **PR #73404** (HS-191072, MERGED Jul 1) — Fix semantic pitch unsubscribe footer + left-layout alignment.
- **PR #73402** (HS-191365, MERGED Jul 1) — Brand wordmark horizontally squished in semantic email header.

### Significant Jira Tickets

- **HS-191718** (CI gate for notification coverage, P3, **To-Do**, **created Jul 6**) — This session's new ticket. Draft PR #73598.
- **HS-191017** (Route direct emails through the rules engine — parity with immediate/batched, P3, **Closed Jul 6 — "Working As Designed"**) — Stacked-PR series (#73512, #73513, #73543) closed without merge after resolution.
- **HS-191429** (latest-env email feedback with BCC dynamic config, P3, **In Progress**) — Active this week; follow-on to the HS-186448 debug-BCC surface.
- **HS-191129** (AlertRuntimeValidations framework for batched alert send job, P3, To-Do) — Planning-phase ticket.
- **HS-188890** (Enable semantic rendering for bulk pitches, P3, **Closed**) — PR #73468 merged.
- **HS-191072** (Pitch unsubscribe link + left alignment under semantic rendering, P3, **Closed**) — PR #73404 merged.
- **HS-191365** (Brand wordmark squished in semantic email header, P3, **Closed**) — PR #73402 merged.
- **HS-150860** (Welcome/signup email copy update, P3, **Closed**) — PR #73459 merged.
- **HS-180228** (Notification rule dedup guard, P3, updated Jul 1) — Spec draft posted; PR #73490 (teammate's implementation) under review.
- **HS-191506** (Support throttling in rule definition, P3, updated Jul 1) — Spec draft posted.

### Key Challenges This Week

- **Landing a CI gate in a dirty working tree without polluting the in-flight branch.** My active branch `kbachu-hs-191017-semantic-builders-retention-bulk-pitch` had 6 unrelated in-flight modifications (retention_host_notification builder work — `alert_commands.rb`, `generic_builder.rb`, `semantic_email_preview.rb` + 3 CI-gate files) queued up for a different PR. Rather than stash / cherry-pick / risk mixing scopes, cut a scratch `git worktree` off `origin/main` at `/tmp/nutella-hs-191718-worktree`, copied only my 4 CI-gate files in, committed + pushed + opened the draft PR from there, then removed the worktree. Original branch and working tree are byte-identical to before the session. Documented as a pattern for future PR-splits mid-session.
- **Ruby static-parsing false positives on `SemanticEmailRegistry` shorthand.** Initial scanner run reported half of `TRANSACTIONAL_TYPES` entries as "unregistered production paths" — traced to `TRANSACTIONAL_TYPES` using `sym: val` hash shorthand while the regex only matched `:sym => val`. Also: `settings_direct_email_types` was reporting `:account` and similar as top-level entries; traced to commented-out `:sym => true` lines inside the registry being parsed as hash entries. Both fixed by (a) comment-stripping preprocessing in `_read` and (b) extending `_hash_keys_in_body` to handle both syntax forms.
- **Delta-only fail path smoke test initially reported PASS on an injected fake kind.** The smoke-test Python injection script was writing the fake kind past `ALERT_CONFIG`'s true closing brace because it matched the wrong `}.freeze` marker (there are several). Fix: walk the brace structure from `ALERT_CONFIG = {` forward, counting `{` / `}` depth, to locate the actual close. Underscores why "wrote the test that catches the injection" is a separate discipline from "wrote the check that flags the missing config."
- **HS-191017 "Working As Designed" reversal after 3 PRs of implementation.** The stacked-PR series was 40 shape spec examples + 19 migration examples + 38 engine-path examples + 6 kinds routed through the engine before the ticket was closed as WAD. Non-zero cost to unwind, but the design + implementation work is preserved in the closed-PR bodies + this worklog. Reinforces the value of the "walk the caller path end-to-end before writing the migration" step that the ticket's own kickoff should have included.
- **Heredoc-vs-eval-wrapper interactions in commit/PR helpers keep recurring.** Second week in a row hitting this: today's `gh pr create --body="$(cat <<'EOF' ... EOF)"` failed with `unexpected EOF while looking for matching '` because the body contained apostrophes (`doesn't`, `can't`) that the eval layer re-interpreted despite the quoted heredoc delimiter. Also the git commit message failed on `PR #73598` because `#` was interpreted as a comment token by the eval layer. Fix pattern both times: write body to `/tmp/<name>.md` and use `--body-file` / pass as `-m 'literal string'` without heredoc. Worth graduating this from "note in weekly review" to an entry in the shell skill.

**Notes:**
- **Session worklog vs merge events (still).** The Jun 26 review's carry-over — "trigger the worklog skill on merge events, not just on next-session pre-flight" — did not fire this week either. Four PRs merged (#73402, #73404, #73459, #73468) without an auto-logged session worklog entry at merge time. All four ARE captured in this weekly review via GitHub search, so nothing was lost, but the trigger gap persists. Actionable follow-up: add a `merged` event hook to the worklog skill.
- **Carry-over for next week**: (a) Circulate PR #73598 for review once tests pass; move HS-191718 To-Do → In Progress. (b) Finish PR #73589 for the two semantic builders (`retention_host_notification` + `bulk_pitch_status_report`). (c) Track PR #73490 (HS-180228 dedup guard) through review — paired with the spec draft I posted. (d) Consider whether HS-191429 (BCC dynamic config) is next up or if the dedup PR review takes priority.
- **Data note on the HS-191017 series**: All three stacked PRs (#73512, #73513, #73543) show as `CLOSED` with `mergedAt=nil` in GitHub. Cross-checked against Jira: HS-191017 resolution = "Working As Designed" (resolution id 8). The design + spec content is intentionally NOT re-summarized here — see the two July 2 session-log entries for the shipped-in-code detail, and the closed-PR bodies for the diff-level detail.

---
## 2026-06-26 - Weekly Review (2026-06-18 to 2026-06-26)

**Summary:**
Closed out the unified-notifications observability chain end-to-end this week: from the diagnostic surface (latest-env debug BCC + on-demand EmailReplay) to the seeding completeness sweep (notification rules sheet-driven overlay) to the operator-facing metrics normalization (4 signal renames, `domain_id` strip, recipient gauges → histogram) including the collector unblock that the metrics rename uncovered. Five PRs authored, three merged (#72914 digest framework polish, #73002 rules seed overlay, #73129 + magma #9059 EmailReplay), two open at week's end (#73245 nutella metrics + #385 otel-collector-ops paired unblock). Also closed two structural KTLO items: HS-185019 (CDN lambda throttling, prior-week campaign) and HISPI-12973 (signup-email inviter-name bug, prior-month fix landed in this window). Reviewed cross-team work on pitch-viewer CSP (HS-191028), push notification sender resolution (HS-189544), the meeting-completion mobile padding follow-on (HS-154893), and the bulk-pitch semantic-rendering exclusion (HS-188860) finally landing.

### Significant Cursor Activities

- **HS-186448 unified-notifications metrics normalization (nutella PR #73245 + otel-collector-ops PR #385, both opened Jun 26)**: Combined Phase 1 + Phase 2 of the email-metrics normalization plan, shipped as a multi-repo coordinated change. (a) **Four operator-facing signal renames** (direct rename, no dual-emit): `notification_rules_engine_delivered_count{channels="..."}` → `notification_rules_engine_delivered_total{channel, delivery_mode}` (per-channel emit; caller loops over `channels_delivered` and derives `delivery_mode` from `rule.aggregation_type`); `alert_email_render_latency` → `email_render_duration_ms`; `alert_email_immediate_fallback_count` + `alert_email_digest_fallback_count` → `email_render_fallback_total{reason, delivery_mode, kind?, scope?}` (`scope: "digest"` replaces the `kind="all"` sentinel for batch-envelope failures); `alert_email_digest_capped_out_count` → `email_batch_capped_out_total`. (b) **`domain_id` strip on 3 new-engine counters** (`notification_rules_alert_count`, `notification_rules_email_count`, `alerts_create_count`) — 11 emit sites updated across `notification_engine.rb`, `alert_commands.rb`, `alert_helpers.rb`, plus `EmailCommands.emit_rule_metric` wrapper + 5 call sites. Cardinality audit pre-clearance: 31 distinct domain_id values at su0 today, no NrDashboardWidget exposure, zero log-text matches over 7 days; would have inflated ~150× at full rollout. (c) **Recipient gauges → histogram**: 4 last-write-wins `email_total/to/cc/bcc_recipients` gauges collapsed to 1 `email_dispatch_recipients{type, header}` histogram with buckets `[1, 2, 5, 10, 25, 50, 100, 500, 1000]`. (d) **Collector unblock**: deleted the unanchored `- email_(.*)` exclude line in the `su0` overlay (su0 was the only outlier; all 11 other overlays already let `email_*` flow). The original Prometheus-mirror rationale is obsolete, and the cardinality audit cleared the 7 legacy `email_*` gauges. 250/250 affected specs pass; all pre-commit hooks clean.
- **HS-186448 latest-env debug BCC + EmailReplay (nutella PR #73129 + magma PR #9059, Jun 24 → merged Jun 25)**: Built two paired diagnostic surfaces for the unified-notifications work. (a) Debug-BCC mechanism that mirrors every semantic alert email sent in the `latest` environment to a configured ops mailbox so the rendered HTML is observable end-to-end without needing a recipient mailbox handy. (b) `EmailReplay` — a CLI + REST endpoint (`/api/v1/admin/email_replay`) that takes a past `alert.id` and re-renders + re-sends the semantic alert email through the live pipeline. Replaces the old "find the right alert, then construct a fake event and replay it via console" three-step workflow with a single API call. Magma sibling PR #9059 adds the admin UI page hooked to the new endpoint. Two superseded prior attempts (#73120, #73122) closed in the same window as the design firmed up.
- **HS-180230 Notification rules seed + sheet-driven overlay (nutella PR #73002, Jun 22 → merged Jun 22 same-day)**: Refreshed the `notification_rules` seeding to backfill missing rules surfaced by validation runs after the HS-182402 per-kind batching realignment. Added a sheet-driven overlay path so the PM-maintained spreadsheet of rule configurations (priority, batching_window, recipients) can flow into the seed without a code change per row. The old seed was the single source of truth; the new overlay sits *on top* of the seed so per-PM-tweak adjustments don't require re-running the migration. Locks the registration of immediate vs batched delivery modes for the metrics work that landed later this week.
- **HS-180221 Digest email framework polish (PR #72914, Jun 19 → merged Jun 24)**: Follow-through on the Batch-5 digest framework that shipped Jun 12 (PR #72529). Added cap enforcement on per-section entry counts (so a noisy kind doesn't blow up the digest), a sampler set used by `compare_email_previews.py` for digest-specific snapshot diffing, the immediate-vs-batched recategorization needed by the metrics rename (which surfaced this week via #73245), and cross-builder polish (consistent CTA wording, anchor terminator fixes per the body-copy skills). Long-running PR (Jun 19 → Jun 24) because the recategorization required syncing the legacy↔semantic mapping per kind. Unblocks the digest dashboard work that the HS-186448 metrics rename enables.
- **HS-189038 SendGrid 421 "max messages per connection" investigation (Jun 18, no code change)**: Diagnosed why a pitch `mail_v2` job with ~100+ BCC recipients failed all 3 retries with `SMTPSendFailedException: 421`. Root cause is in `SmtpSend.sendWithUnsubscribeLink()` (magma) — pitches with `unsubscribe_header` are forced down a path that opens **one** `SMTPTransport` and iterates `MAIL FROM` / `RCPT TO` / `DATA` over every recipient on the same connection; SendGrid enforces a per-session message cap (~100). Verdict: email-infrastructure bug, not pitch (the same code path is used by digest, share-with-many, and any future bulk notification). Filed HS-189038 under HS-185127 KTLO epic with two suggested remediation options (transport recycling every ~90 messages, or catch-and-reconnect on 421). Side-finding called out in the ticket: the retry path re-sends to the entire recipient set including ones that already received before the 421, so brokers near the front of the BCC list can receive duplicates today — the 421 fix eliminates that as a side effect.

### Significant Proposals
- "Strip `domain_id` from the 3 new-engine counters now, before full rollout inflates cardinality ~150×" — proposed and executed in PR #73245 after a clean NR audit (no dashboards, no log-text matches, blast radius still `su0`-only). The alternative — leaving `domain_id` in place until 100% rollout — would have required a separate cleanup PR after the cardinality damage was done.
- "Delete the `email_(.*)` collector exclude entirely instead of replacing with an explicit per-name list" — proposed in PR #385 description after an intermediate explicit-list approach was implemented and rolled back once the audit cleared the 7 legacy `email_*` gauges and confirmed the Prometheus-mirror rationale is obsolete. Brings `su0` to parity with the other 11 overlays; no explicit-list maintenance burden going forward.

### Significant Documents
- `cursor-worklog/unified_notifications/email_metrics_normalization_bf839f02.plan.md` — added to the unified-notifications plan corpus. Tracks the 4-signal rename, `domain_id` strip, recipient-histogram conversion (all shipped), plus deferred Phase 3 retirements and Phase 4 direct-builder dispatch instrumentation follow-ups. Cross-links to HS-184923, HS-184956/957, HS-180590, HS-185865, HS-185447.
- `nutella/web/common/email/README_SEMANTIC_EMAIL.md` — refreshed Metrics + Troubleshooting tables to the new metric names and attribute shapes.
- Engineering Demos & Updates page (Confluence ENGDOCS, edited Jun 26) — generic schedule contribution.

### Significant Helping Others
- Reviewed Murali Pottipalli's nutella PR #73175 (HS-191028, Apply custom CSP modifications on unauthenticated pitch viewer routes, opened Jun 25 → merged Jun 26).
- Reviewed Yi Wang's nutella PR #73131 (HS-189544, Resolve push notification `from_user` by sender `domain_id`, opened Jun 24 → merged Jun 26) — push-notification sender resolution alignment with the email side's domain handling.
- Reviewed Tanish Bansal's nutella PR #72785 (HS-188860, bulk-pitch semantic rendering exclusion, prior-week PR finally merged Jun 23) — surfaced HS-188890 follow-on the prior week; this week saw it land.
- Reviewed Murali Pottipalli's paired meeting-completion email mobile-padding fix (nutella PR #72630 + magma PR #9021, HS-154893) — both finally merged Jun 26 after the prior-week review.

### Significant PRs

- **nutella PR #73245** (HS-186448, OPEN Jun 26) — Normalize unified-notifications metrics + strip `domain_id`. 14 files, +182/-182. Paired with otel-collector-ops PR #385.
- **otel-collector-ops PR #385** (HS-186448, OPEN Jun 26) — Remove unanchored `email_(.*)` exclude in `su0`. 1-line diff. Paired with nutella PR #73245.
- **nutella PR #73129** (HS-186448, MERGED Jun 25) — Latest-env debug BCC + EmailReplay (CLI + REST endpoint for semantic alerts).
- **magma PR #9059** (HS-186448, MERGED Jun 25) — Email replay admin page (paired with nutella #73129).
- **nutella PR #73002** (HS-180230, MERGED Jun 22) — Seed missing notification_rules + sheet-driven overlay.
- **nutella PR #72914** (HS-180221, MERGED Jun 24) — Digest email framework polish: capping, sampler set, immediate vs batched recategorization, cross-builder polish.
- (Superseded mid-week: nutella PR #73120 + #73122 — earlier shape attempts for EmailReplay, closed and absorbed into #73129.)

### Significant Jira Tickets

- **HS-186448** (Metrics, logs, dashboards for notification email success/failure monitoring, P3, **In Progress**) — Active this week with 3 PRs (#73129, #73245, magma #9059) plus paired collector PR #385.
- **HS-185019** (Mitigate `prod_content_cdn_lambda_throttling`, P3, **Closed Jun 23**) — Three-week mitigation campaign concluded; final two trailing PRs from prior week (terraform #5463, tf-newrelic-alert #981) merged and ticket closed.
- **HISPI-12973** (Email Invite not including user who has sent invite, P2, **Closed Jun 23**) — HS-187052 fix from prior period deployed; customer-facing ticket closed.
- **HS-191072** (Pitch unsubscribe link missing and email center-aligned when `unified_notification_system` semantic rendering is active, P3, To-Do, **created Jun 26**) — Surfaced this week; affects pitch family under semantic rendering. Queued.
- **HS-191017** (Route direct emails through the rules engine with Alert records — parity with immediate/batched, P3, To-Do, updated Jun 25) — Planning ticket for the next structural piece of the unified-notifications work (today only immediate + batched emails go through the rules engine; direct sends bypass it).
- **HS-183875** (Notifications CS1 Foundations Beta epic, P1, In Dev, updated Jun 24) — Parent epic for ongoing work.
- **HS-188911** (Training video playback aborts mid-stream on enterprise networks, P3, To-Do) — Updated Jun 22; cross-team item parked.

### Key Challenges This Week

- **Multi-repo coordination with deploy ordering**: PR #73245 (nutella) + PR #385 (otel-collector-ops) must land in a specific order — nutella first to start emitting under new metric names, then collector second to unblock the new namespace from the exclude. Reverse order would briefly drop new metrics. Same flavor of cross-repo dependency as the HS-185019 five-repo CDN campaign, but smaller scope. Documented in both PR bodies.
- **Cardinality audit decision: strip now vs. wait until full rollout**: The NR audit signals (no NrDashboardWidget exposure, zero log-text matches) were ambiguous because `NrDashboardWidget` is empty in the relevant account regardless. Made a judgment call to strip now based on (a) `su0`-only blast radius today, (b) the cardinality contract banning `domain_id`, (c) the cost asymmetry — walking back a `domain_id` strip later is harder than landing it now while consumers don't exist. Logged the rationale in PR #73245 so the decision is auditable.
- **Heredoc-vs-backtick interaction in shell commit/PR helpers**: Two commit-message-via-heredoc attempts failed in this session because the body contained backticks and apostrophes that the eval layer mangled. Fixed both times by writing the message to a `/tmp/` file and using `git commit -F` / `gh pr create --body-file`. Worth a note in the shell skill — heredocs are unreliable for prose bodies in this environment.
- **Worklog skill auto-fire confirmed working at session level**: This week the worklog hygiene pre-flight surfaced the 9-day-stale weekly review at the start of the session and auto-prompted for a run; the user accepted. The May 22 → Jun 17 silence pattern is no longer being repeated — the gate is firing on the right cadence.

**Notes:**
- Carry-over for next week: Land both #73245 + #385 in deploy order; verify the 4 new operator-facing signals in NR via the post-deploy NRQL; consider scheduling Phase 4 of the metrics plan (direct-builder dispatch instrumentation) once HS-191017 lands the direct-email-through-rules-engine work. Also: HS-191072 pitch unsub link semantic-rendering bug needs triage.
- Session worklog this week: 2 entries (HS-189038 SendGrid investigation Jun 18, today's metrics normalization milestone Jun 26). The mid-week ships (#72914, #73002, #73129, #9059) weren't logged in the session worklog at the time — the agent didn't auto-fire the worklog skill on the merge events, only on the investigation and today's milestone. Worth tightening the trigger so merge events log automatically without needing the next session's auto-pre-flight to backfill.

---


## 2026-06-17 - Weekly Review (2026-06-12 to 2026-06-17, partial week)

**Summary:**
Week dominated by HS-185019 — the `prod_content_cdn_lambda_throttling` mitigation finally moved out of KTLO into active landings. Five PRs across five repos (magma, magma-ops, content-cdn-lambda-handler, terraform, tf-newrelic-alert) coordinated against the same root cause: magma-api pod-restart-induced retry bursts on the shared account-level lambda concurrency. Three of five merged in 48 hours; two trailing PRs (terraform v1.9 bump + alert tuning) opened and pending review at week's end. Also reviewed two cross-team mobile-padding fixes for the meeting-completion notification email (murali-pottipalli) and a bulk-pitch semantic-rendering exclusion (tanishbansal20) that surfaces HS-188860 / HS-188890.

### Significant Cursor Activities
- **HS-185019 magma-api graceful shutdown (magma PR #9024, Jun 15 → merged Jun 17)**: The most consequential of the five PRs. magma-api previously didn't drain in-flight requests on `SIGTERM` — the pod was killed mid-request, those requests retried via the client, and during pod-scaling churn the retry storm bursted the account-shared lambda concurrency limit (1000), throttling the CDN lambda even though it had its own dedicated quota. Fix: install a `SIGTERM` handler that (a) stops accepting new requests, (b) waits for in-flight requests to complete up to a deadline, (c) only then exits. Combined with the magma-ops grace-period bump (next bullet), in-flight requests now finish cleanly instead of being dropped + retried.
- **HS-185019 magma-ops grace period (magma-ops PR #458, Jun 15 → merged Jun 17)**: Bumped `terminationGracePeriodSeconds` from default to 100s for the magma-api Deployment so the new graceful-shutdown handler has time to drain. 100s chosen as 2× the longest observed in-flight request percentile + buffer.
- **HS-185019 content-cdn-lambda-handler retry/cache tightening (PR #5, Jun 15 → merged Jun 17)**: Two tweaks in the lambda handler to lower per-retry CPU + memory pressure: (a) tightened `urllib3` retry/timeout bounds so a single connection failure doesn't fan out to 4-5 retries with full default timeouts, (b) memoized `URLCache` entry size — the size computation was previously hot in profile data because it re-serialized the cache entries on every access. Both reduce the work done during a retry storm, complementing the upstream fix that should reduce retry storms in the first place.
- **HS-185019 terraform v1.9 bump (terraform PR #5463, opened Jun 17)**: Bumps the `cdn_lambda_handler` module to v1.9 to consume PR #5. Open at week's end pending review (Serdar Akin acknowledged in `#eng-foundation` Slack thread).
- **HS-185019 alert tuning (tf-newrelic-alert PR #981, opened Jun 15)**: Fine-tunes the CDN alerts that surfaced this incident so the new lower-retry-volume baseline doesn't trip them spuriously and so genuine regressions still page. Open at week's end pending review.
- **HS-180221 Batch-5 follow-through (in-flight)**: Ticket transitioned to In Progress on Jun 15; PR #72529 merged Jun 12 but the `validate_rule_category.sh` runs across digest categories are still being walked.

### Significant Proposals
- "Make the magma-api graceful-shutdown handler the canonical shutdown contract for all of our K8s workloads" — proposed in the #9024 PR description and the `#eng-foundation` thread; not yet codified in a runbook but a logical follow-up.

### Significant Documents
- `magma-ops` README addendum on the grace-period decision (alongside #458) — explains the 100s figure and links the magma graceful-shutdown PR.

### Significant Helping Others
- Reviewed tanishbansal20 PR #72785 (HS-188860 enhance semantic rendering logic for email commands to exclude bulk pitches, opened Jun 17) — bulk pitches were going through the semantic path and producing oversized payloads; the PR adds a guard. Spun up follow-up HS-188890 (To-Do, Jun 17) — the long-term fix is to *enable* semantic rendering for bulk pitches (not exclude) by removing the `EmailCommands.send_email` guard once the underlying perf issue is fixed.
- Reviewed murali-pottipalli PRs #72630 (nutella, HS-154893 sync legacy meeting completion email preview padding for mobile, Jun 15) and #9021 (magma, HS-154893 fix narrow mobile layout in meeting completion email, Jun 15) — paired nutella+magma fix for the same mobile-layout bug.
- Reviewed dykwiat PR #72638 (Remove unused react-email package and email-templates, Jun 15 → merged Jun 16) — cleanup of the legacy react-email infrastructure that's been dead since the semantic migration completed.
- Slack `#eng-foundation`: requested review on magma-ops PR #458; thanked Serdar Akin for review on terraform PR #5463.
- Slack `#temp-inc-568` (incident channel) and `#highspot-releases`: cross-team troubleshooting on a CORS-policy issue affecting `content.highspot.com` with kurt.berglund and an S3 intelligent-tiering hypothesis for a deep-archive object recovery.

### Significant PRs
- **magma PR #9024** (HS-185019, MERGED Jun 17): graceful shutdown for magma-api.
- **magma-ops PR #458** (HS-185019, MERGED Jun 17): `terminationGracePeriodSeconds=100`.
- **content-cdn-lambda-handler PR #5** (HS-185019, MERGED Jun 17): urllib3 retry/timeout tightening + URLCache size memoization.
- **terraform PR #5463** (HS-185019, OPEN Jun 17): bump cdn_lambda_handler to v1.9.
- **tf-newrelic-alert PR #981** (HS-185019, OPEN Jun 15): fine-tune CDN alerts.

### Significant Jira Tickets
- **HS-185019** (P3, In Progress → Code Review Jun 17) — three of five PRs merged in 48 hours; trailing two in review.
- **HS-188890** (P3, To-Do, created Jun 17) — Enable semantic rendering for bulk pitches; long-term inverse of the HS-188860 short-term guard.
- **HS-180221** (P3, In Progress, updated Jun 15) — Batch-5 digests; validation across categories still in flight.

### Key Challenges This Week
- **Five-repo coordinated change** — HS-185019 fix touches magma (code), magma-ops (k8s config), content-cdn-lambda-handler (Python code), terraform (module version), tf-newrelic-alert (alert thresholds). Five PRs in five repos with a real ordering dependency (magma + magma-ops must land before terraform bump consumes the lambda change; alert tuning lands last so we don't re-alert on the transient improvement). Walked the chain by-hand; would benefit from a documented "cross-repo change" runbook in the future.
- **Same-day open-and-review on terraform/tf-newrelic-alert** — both PRs opened with limited reviewer context; explicit Slack requests in `#eng-foundation` were needed to get attention.

**Notes:**
- This is the week the Jun 17 worklog backfill happened — the user noticed both worklog files had been silent since May 22 and asked the agent to investigate. Result: 75 lines of pending session entries pushed (commit `b239075`), and this WEEKLY backfill (5 weeks at once) reconstructed from MCP/git data because the session worklog was empty for the post-May-22 window.
- Carry-over: terraform PR #5463 + tf-newrelic-alert PR #981 review/merge; HS-186448 metrics design; HS-188890 semantic-bulk-pitch enable; HS-150860 welcome email copy refresh; consider tightening the worklog skill's significance heuristics or adding an end-of-session auto-prompt to avoid another month-long gap.

---

## 2026-06-12 - Weekly Review (2026-06-05 to 2026-06-12)

**Summary:**
Two structural ship: (1) HS-182402 — realigned `notification_rules` to per-kind batching, retired the synthetic `digest` rule kind, and fixed seed drift uncovered by the migration (PR #72251, merged Jun 8); (2) HS-180221 — Batch-5 digest framework + Batch-4/6 direct-email + legacy pitch emails consolidated landing (PR #72529, opened and merged Jun 12). Reviewed chrisk1123's three follow-ons that depend on the realigned rule shape (#72252 recipient conditions, #8988 condition field on overrides, #9002 event v1 registration removal) and NateHark's prune_alert_sets memory bound (#72013). Surfaced HS-186448 (notification email metrics + dashboards) and HS-187052 closed.

### Significant Cursor Activities
- **HS-182402 per-kind batching realignment (PR #72251, Jun 7 → merged Jun 8)**: The `notification_rules` collection had two batching shapes — per-rule `delivery_strategy.batching` for most kinds, plus a synthetic `digest` rule kind that aggregated several real kinds under one record. The synthetic kind made it impossible to give individual kinds different batching windows (the digest had a single window) and broke the seed/audit story (rule count mismatched the kind count). Fix: (1) move batching window to per-kind `delivery_strategy.batching` for every kind that previously rolled up into the digest, (2) retire the `digest` rule kind entirely, (3) regenerate the seed from `ALERT_CONFIG` + `EMAIL_SETTINGS` with the new shape, (4) data-migration step in the same PR to backfill existing prod records. Unblocks chrisk1123's actor_suppression + recipient-condition follow-ups (which depend on stable per-kind rule shape).
- **HS-180221 Batch-5 digest framework + Batch-4/6 direct-email + legacy pitch emails (PR #72529, opened and merged Jun 12)**: Single consolidated PR shipping: (a) the Batch-5 digest builder framework — `DigestBuilder`, kind `digest`, batches unsent alerts into a single email with one section per `NotificationRule.delivery_strategy.priority` value (Critical / High / Normal); (b) Batch-4 direct-email migrations that survived the #72067 closeout (welcome, password recovery, etc.); (c) Batch-6 first wave; (d) the remaining legacy pitch emails that needed parity coverage before the digest framework could rely on them. PR opened and merged same day, indicating the work was largely staged on the branch over prior sessions and only the merge happened in this window.

### Significant Proposals
- "Retire the synthetic `digest` rule kind in favor of per-kind batching" — proposed in HS-182402 ticket and approved before #72251. Cleaner data model for the rule-condition follow-ons; turns batching window into a normal rule attribute instead of a special-case kind.

### Significant Documents
- `digest-framework/SKILL.md` — refreshed with the `DigestBuilder` shape, the priority-section split, and the contract that each section's body is `NotificationRule.delivery_strategy.priority` for the alerts in it.
- Engineering Demos & Updates (Confluence ENGDOCS, contributed Jun 11).
- How to Deploy / Update Highspot to Windows (Confluence ENGDOCS, contributed Jun 9).
- Windows Worker overview (Confluence ENGDOCS, contributed Jun 9) — Terraform module pointer + Buildkite deployment workflow.

### Significant Helping Others
- Reviewed chrisk1123 PR #72252 (HS-180225 recipient conditions in notification rules, Jun 7 → merged Jun 9) and the magma sibling #8988 (HS-180225 condition field on overrides, Jun 7 → closed Jun 10) — depends on HS-182402's rule shape.
- Reviewed chrisk1123 PR #9002 (HS-179756 remove event v1 registration from Magma, Jun 9 → merged Jun 12) — wsevents v1 retirement, magma-side cleanup.
- Reviewed chrisk1123 PR #72424 (HS-180227 actor_suppression reads alignment to guards path + numeric-prefix migration, Jun 10 → merged Jun 12).
- Reviewed NateHark PR #72013 (HS-185359 bound `prune_alert_sets` memory via entity cache eviction, Jun 1 → merged Jun 10).

### Significant PRs
- **nutella PR #72251** (HS-182402, MERGED Jun 8): per-kind batching realignment + digest rule retirement + seed fix.
- **nutella PR #72529** (HS-180221, MERGED Jun 12): Batch-5 digest framework + Batch-4/6 direct-email + legacy pitch emails.

### Significant Jira Tickets
- **HS-182402** — Closed via #72251.
- **HS-180221** (Batch-5 notifications: email digests, P3, In Progress) — PR #72529 merged, ticket pending closeout pending validation across digest categories.
- **HS-187052** — Closed Jun 8 via the prior week's PR #72066 deploy.
- **HS-186448** (Metrics, logs, dashboards for notification email success/failure monitoring, P3, To-Do, surfaced Jun 11) — design pending.
- **HISPI-12973** (Email Invite not including user who has sent invite, P2, Ready for Test, Jun 11) — covers the HS-187052 fix.
- **HS-150860** (Update copy of new user welcome emails, P3, To-Do, Jun 12) — copy refresh queued.

### Key Challenges This Week
- **Same-day-open-and-merge on PR #72529** — the consolidated Batch-5 + Batch-4/6 PR opened and merged on Jun 12 is large and reviewer-unfriendly. Expectation: future batched landings should split into stacked PRs even if they ship together, so reviewers can comment on individual pieces.
- **Schema migration in same PR as code** (#72251) — the `digest` rule kind retirement included a one-shot data backfill in the same PR. Worked because the change set was small, but the convention for shared-data migrations is two PRs (code + migration runbook). Flagged for next time.

**Notes:**
- Session worklog: no entries this week despite two structural ships. Reaffirms the auto-commit gate is too conservative.
- Carry-over: CDN lambda throttling mitigation campaign (HS-185019) lands next week as a five-repo coordinated change; HS-188860 bulk-pitch semantic rendering ticket surfaces.

---

## 2026-06-05 - Weekly Review (2026-05-29 to 2026-06-05)

**Summary:**
Three landings this week, all in the unified-notifications semantic email migration: (1) HS-187052 fix for the signup-email custom-message inviter-name bug (PR #72066, merged Jun 3), (2) HS-183419 tracking_tag plumbing finally landed via the helper-based pattern (PR #72151, merged Jun 4), and (3) Batch-4 direct-emails first attempt (PR #72067, opened Jun 2, closed Jun 9 superseded). Two intermediate tracking_tag PRs (#71848 from prior week, #72136 mid-week) closed superseded along the way as the helper design firmed up. Reviewed chrisk1123's actor_suppression PR #71961 which depends on the realigned per-kind rule shape that lands the following week.

### Significant Cursor Activities
- **HS-187052 signup email custom-message bug (PR #72066, Jun 2 → merged Jun 3)**: PM-reported issue: signup invitations weren't showing the inviter's name in the custom message. Root cause: `signup_user` was passing the recipient as `from` (so `data.from` was the new-user being invited rather than the existing user who initiated the invite), and the semantic builder rendered `data.from.full_name` verbatim. Fix: thread the actual inviter through `signup_user` and update the semantic builder's `data.from` resolution to be inviter-anchored. Customer-facing bug (HISPI-12973 — "Email Invite not including user who has sent invite"); ticket flipped to Ready for Test on Jun 11.
- **HS-183419 tracking_tag plumbing — final landing (PR #72151, Jun 3 → merged Jun 4)**: Replaced the context-threading approach from #71848 with a `tracked_url` helper that wraps `url_for_email` output with `?source_alert=<alert.id>` + `?source=email.<tracking_tag>`. Builders only need to know about the helper; the alert context flows through the existing render-context object. Touched ~6 builder files vs ~30 in the abandoned attempt. Eliminated the `[RULE:tracking_tag]` informational backlog (~120 kinds were flagged as Pass+WARN); now they pass clean. Intermediate PR #72136 (Jun 3) was closed mid-day after a smaller-scope review prep showed the same diff would fit cleanly in #72151.
- **HS-185881 Batch-4 direct emails — first attempt (PR #72067, Jun 2 → closed Jun 9)**: Walked the direct-email surface (welcome, password recovery, signup, pitch_viewed, etc.) for migration candidates. Closed superseded after the Batch-5 work (next week) absorbed the direct-email portion that was already production-ready and the rest was reparented to a future batch. Useful side product: surfaced HS-187052 (above) by exposing the inviter-name bug during the audit.

### Significant Proposals
- "Helper-based tracked_url over builder-context threading" — landed in #72151 PR description as the chosen pattern; documented in the `tracking-tag-plumbing` skill.

### Significant Documents
- `tracking-tag-plumbing/SKILL.md` — refreshed with the helper-based pattern, two failure modes (host-mismatch, fragment-vs-query collision), and the `[RULE:tracking_tag]` rubric tag flow from `compare_email_previews.py` output → fix in builder.

### Significant Helping Others
- Reviewed chrisk1123 PR #71961 (HS-180227 actor_suppression in notification rules, May 30 → merged Jun 4). This PR depends on the per-kind rule shape that HS-182402 (next week) realigns; reviewed for forward-compat with the in-flight realignment.

### Significant PRs
- **nutella PR #72066** (HS-187052, MERGED Jun 3, 4 files): signup email custom-message inviter-name fix.
- **nutella PR #72151** (HS-183419, MERGED Jun 4, ~10 files / +200 / -50): tracked_url helper landing.
- **nutella PR #72067** (HS-185881, CLOSED Jun 9 superseded): Batch-4 direct emails first attempt.
- **nutella PR #72136** (HS-183419 intermediate, CLOSED Jun 3): merged into #72151.

### Significant Jira Tickets
- **HS-187052** (P3) — flipped to Closed Jun 8 once #72066 deployed.
- **HS-183419** (P3) — tracking_tag plumbing landed; ticket ready for closeout.
- **HS-185881** (P3) — Batch-4 work reabsorbed into Batch-5 (next week).

### Key Challenges This Week
- **Three-PR superseded chain on HS-183419** (#71848 → #72136 → #72151) — three branches over six days converging on the helper pattern. Cleanup was straightforward (close + comment-link to successor) but the PR-list noise is a smell; if the same shape recurs, force-push onto a single branch instead.
- **`[RULE:tracking_tag]` backlog double-count** — before #72151, the rubric counted both Pass+WARN and Fail buckets toward the tag's noise. After landing, ~120 kinds went Pass-clean and the tag dropped out of the run summary's auto-discovered backlog list, which is good signal but also caught a counting bug in `compare_email_previews.py` (duplicate aggregation of WARN under WARN_total and TAG_total). Filed as follow-up.

**Notes:**
- Session worklog: no entries logged this week. Work was significant (3 PRs landed, customer-facing bug fixed, tag backlog drained) but auto-commit didn't fire.
- Carry-over: HS-182402 per-kind batching realignment (next week), Batch-5 digest framework consolidation, HS-180221 Batch-5 ticket transition to In Progress.

---

## 2026-05-29 - Weekly Review (2026-05-22 to 2026-05-29)

**Summary:**
Semantic email migration Batch-2 + Batch-3 landed (HS-185865, PR #71757 merged May 29, 22 files / +1,300+) — notifications NR fixes, entity-stub hardening, tracking/preview tooling, and the `semantic-email-url-helpers` Cursor rule that catches inline-URL drift via the new `scan_preview_inline_urls.py` scanner. Three short-lived sub-PRs (#71834/#71835/#71836) were used as scoped scratch branches to test specific fragments before consolidating into #71757; closed once #71757 absorbed them. tracking_tag plumbing kicked off on a separate branch (PR #71848), the first of three iterations that would land four weeks later as #72151.

### Significant Cursor Activities
- **HS-185865 Batch-2 + Batch-3 (PR #71757, May 27 → merged May 29)**: Consolidated landing of (a) the Batch-2 + Batch-3 NR fixes against the `compare_email_previews.py` rubric backlog (handful each of `[RULE:body_after_following_reference]`, `[RULE:semantic_card_without_legacy_link]`, `[RULE:default_avatar]` resolutions), (b) entity-stub hardening so `AlertPresenter#data_value_to_output` no longer short-circuits on `id.nil?` for the kinds the rubric drain unblocked, (c) preview tooling: mirrored the legacy pitch URL shape so the side-by-side compare doesn't render structurally different URLs even when the route is identical, (d) added `scan_preview_inline_urls.py` — a static scanner that grep-walks builder + mock files for hard-coded inline URLs that should route through `tracked_url`/`url_for_email` (catches the kind of drift PR #71757 itself was patching), (e) the `semantic-email-url-helpers` Cursor rule documenting the canonical helper chain for a builder author so future drift gets caught at authoring time. Three preceding sub-PRs (#71834 mirror legacy pitch URL + scanner, #71835 add `scan_preview_inline_urls.py`, #71836 add the Cursor rule) were used as scoped diff bundles to make pre-review easier; all three closed when #71757 absorbed them.
- **HS-183419 tracking_tag plumbing — first attempt (PR #71848, opened May 29, later closed)**: First branch for wrapping every semantic alert URL with `?source_alert=<alert.id>` + `?source=email.<tracking_tag>` to match legacy `AlertPresenter#tracked_url`. Approach used a thread-through-the-builder-context pattern; abandoned during review for a cleaner helper-based pattern that would land four weeks later as #72151. PR closed Jun 3 superseded.

### Significant Proposals
- "Use a `tracked_url` helper alongside the existing `url_for_email` rather than threading the alert id through every builder context" — proposed during the #71848 review thread; eventual basis for #72151's approach.

### Significant Documents
- `Email notifications migration data` (Google Sheets) — Compare Preview Link column from the May 22 work was used during the Batch-2/3 review pass to spot-check rendering parity for ~50 kinds before #71757 was opened.

### Significant Helping Others
- Reviewed sfletche PR #71775 (`ForkTsCheckerWebPackPlugin` memory limit bump, merged May 27) — quick review, narrow scope.
- Reviewed ruitang-highspot PR #71817 (HS-185866 region-related API moved from APP controller to API controller in nutella, merged May 29) and the magma sibling PR #8947 (HS-185866 content-regions API endpoints, merged May 29) — these consume the region-settings work that was originally landed by Scott Fletcher in March; reviewed for path/auth correctness.
- Reviewed rohitkumbhar PRs in highspot-express #132 (auth + service client lib bump, merged May 26) and highspot-express-python #41 (express-auth middleware sessionId handling, merged May 26).

### Significant PRs
- **nutella PR #71757** (HS-185865, MERGED May 29, 22 files / ~+1,300 / -200): Semantic email Batch-2 + Batch-3 — NR fixes, entity-stub hardening, tracking/preview tooling, scanner, Cursor rule.
- **nutella PR #71848** (HS-183419, CLOSED superseded, May 29 → Jun 3): tracking_tag plumbing first attempt.
- Three short-lived sub-PRs (#71834, #71835, #71836) all closed superseded after #71757 absorbed them.

### Significant Jira Tickets
- **HS-185865** (P3, In Progress → ready for closeout once #71757 ships through promotion): Batch-2 + Batch-3 landing.
- **HS-183419** (P3, To-Do): tracking_tag plumbing — first attempt opened, abandoned.

### Key Challenges This Week
- **PR-shape thrash**: opening three sub-PRs (#71834-#71836) for pre-review scope-checking, then consolidating into #71757, generated noise and superseded-PR cleanup. Future workflow: do the scope-segmentation in a single PR with separate commits + a "review by commit" hint in the body, instead of separate branches.
- **tracking_tag context-threading regret**: first-attempt #71848 wired the alert id through builder context, which polluted ~30 builder signatures for a value that's only needed at URL-emission time. Pivot to a `tracked_url` helper kept the alert context where URLs are actually emitted, dropping the touched-file count from ~30 to ~6 in the eventual #72151.

**Notes:**
- Session worklog had no entries this week — the work was significant (Batch-2+3 ship + scanner + Cursor rule) but the auto-commit gate was tuned conservatively after the May 22 unsent-commit incident, and no explicit "log this" prompt was issued. This is the first full week where the gap appears.
- Carry-over: tracking_tag plumbing v2 (next week), HS-187052 signup email bug surfaced near end of week.

---

## 2026-05-22 - Weekly Review (2026-05-15 to 2026-05-22)

**Summary:**
Foundation week for the unified-notifications email migration push that defined the rest of May/June. Landed HS-155824 (`email_tracking_details_v1` job timeouts) via partial index + windowed loop; opened the follow-up index-cleanup PR. Major skill-bundle normalization: Pattern↔RULE-code index, plan status front-matter, audit scripts, type-tagged worklog, mega-skill split, archived v1 bak files. Rescued 3 orphaned nutella `.cursor/rules/*.mdc` files (i18n-keys, codeowners-update, update-all-references) from untracked working-copy limbo into either the plugin or `~/.cursor/rules/`. Wrapped the week with three Google Sheets milestones for the Email notifications migration tracker (Compare Preview Link column, Notification Prototype Review merge, URL fixes).

### Significant Cursor Activities
- **HS-155824 `email_tracking_details_v1` job timeout fix (PR #71197, May 18, merged May 21)**: Long-running cleanup job was timing out on a full-collection scan. Fix: added a partial Mongo index over `{details: {$exists: true}, created_at: ...}` and switched the worker to a windowed loop with a hard upper bound + cursor checkpointing, so each invocation drains a bounded slice and the next scheduled run picks up where the previous left off. Caught a side-effect bug along the way: the new semantic email path was populating `details` with the full HTML body (much larger than legacy), which would have made the next cleanup window even larger — fixed in the same PR. Follow-up PR #71199 opened May 18 to drop the now-stale `[details, created_at]` indexes once the new partial index is fully populated; left open for a phased rollout.
- **Skill bundle normalization round 1 + round 2 (May 18)**: Round 1 — added the Pattern↔RULE-code index across all body-copy skills so `[RULE:foo]` from the compare-tool output points at the exact skill section that fixes it; status front-matter on all 17 program plans; rollup tooling so plan dashboards regenerate from the front-matter. Round 2 — archived v1 bak files (kept history, removed clutter), split the mega-skill `migrate-semantic-email-body-copy` into focused sibling skills (`body-copy-card-anchor`, `body-copy-link-preservation`, `body-paragraph-ordering`, `entity-card-validity`, `entity-card-thumbnails`, `entity-card-enrichment`, `pluralization-agreement`, `reply-card-completeness`, `tracking-tag-plumbing`, `wrapper-template-parity`, `digest-framework`), added audit scripts (`_audit_globs.sh`, `_audit_crossrefs.sh`), and type-tagged every worklog entry (`milestone` / `mid-session` / `investigation` / `post-mortem`).
- **Rescue 3 orphaned nutella rules (May 18, post-mortem)**: User noticed that nutella's `.cursor/rules/` had 14 rules created mid-session that were never committed because `nutella/.gitignore` blocks `.cursor/**`. Of the 14, 11 were recoverable by re-installing the `ai-plugins/nutella-semantic-email-migration` bundle. Three weren't in any tracked location: `i18n-keys.mdc`, `codeowners-update.mdc`, `update-all-references.mdc`. Fix: i18n-keys.mdc → into the plugin (`commit 80cc1a7`); codeowners-update + update-all-references → user-level `~/.cursor/rules/`. Updated plugin README rule count 11→12. Open follow-up: add `_audit_untracked.sh` (existing audit scripts catch authoring-time decay but not "rule was authored but never committed"); and narrow nutella's `.gitignore: .cursor/**` to `.cursor/_local/**` so future shared rules can be tracked without force-adds.
- **Email notifications migration sheet (3 milestones, May 22)**: (1) Inserted "Compare Preview Link" column at position E with `=HYPERLINK(...,"Compare")` formulas opening the side-by-side legacy-vs-semantic preview for each non-digest kind; (2) Merged Notification Prototype Review data — lookup of source's Product Category / Priority / Batching Window into the destination's M:O columns (210/297 matched, 87 intentionally blank because source covers a narrower scope); (3) Fixed Compare Preview Link URLs — original used wrong host (`https://localhost:8443`) and wrong category source (`rule.category` instead of the semantic `IMMEDIATE_CATEGORIES` map); rewrote 313 rows after parsing the 243-kind semantic-category map out of `semantic_email_preview.rb`. Surfaced two MCP gotchas worth keeping: `update_range_values` trims trailing blank rows (chunk B'-pattern workaround), and JSON arg payloads above ~15K chars hit a parser edge case (split into ~8K chunks).

### Significant Proposals
- "Narrow `nutella/.gitignore: .cursor/**` to `.cursor/_local/**`" — flagged in the orphaned-rules post-mortem so future team-shared rules can be tracked without force-adds. Not actioned this week.

### Significant Documents
- `Email notifications migration data` (Google Sheets, May 22) — three structural improvements above; spreadsheet now covers 313 kinds × 12 columns including Compare links + Product Category/Priority/Batching Window.
- Skill bundle audit scripts (`_audit_globs.sh`, `_audit_crossrefs.sh`) — added to the repo root of the semantic-email-migration plugin (May 18).

### Significant Helping Others
- Slack thread in `#crew-app-platform` with Derek Kwiatkowski + kasey.stonehill on HS-155824 historical context — asked about the `EMAIL_TRACKING_COLLECTION` TTL feasibility before committing to the index+loop approach. Followed up with the side-effect bug callout (semantic email path bloating `details`) for Nav and Nathan.

### Significant PRs
- **nutella PR #71197** (HS-155824, MERGED May 21, 4 files): partial index + windowed loop fix for `email_tracking_details_v1`.
- **nutella PR #71199** (HS-155824 follow-up, OPEN May 18): drop stale `[details, created_at]` indexes once partial index is populated.
- **nutella PR #70801** (HS-182399, MERGED May 22 in this window): Batch-1 semantic email text and styling fixes — finally landed after 9 days of iteration.

### Significant Jira Tickets
- **HS-155824** (P2, In Progress → mostly Closed via #71197) — the timeout fix shipped; index cleanup follow-up tracked separately.
- **HS-185019** (P3, To-Do) — KTLO ticket carried into next week without active work yet.
- **HS-182399** (P3, In Progress) — Batch-1 PR #70801 finally merged this week.

### Key Challenges This Week
- **`.gitignore: .cursor/**` blocking team rules** — 14 nutella rules sat in untracked working-copy limbo; the i18n-keys rule (the explicit prevention added for the 150-bad-keys incident) was effectively never deployed beyond the author's machine. Three rescue paths used (plugin / user-level / accept-as-stale).
- **Google Sheets MCP edge cases** (May 22) — `update_range_values` silently drops trailing blank rows (need to chunk so blanks aren't last); JSON argument payloads >~15K chars hit a parser error even when the JSON is valid (chunk to 8K).
- **Subagents inheriting stale rules** (carry-over from May 13) — subagents spawned earlier in the session still bypassed the new `AskQuestion` push-confirmation gate; 7 fragmented commits had to be consolidated.

**Notes:**
- Session worklog auto-commit gate worked correctly this week — all 3 May 22 sheet milestones got appended to `cursor-ai-assisted-work-sessions-worklog.md` but were not pushed (the user did not confirm during that session). They sat uncommitted in the working tree until this Jun 17 backfill, which exposed the failure mode and motivated the gap analysis below.
- Carry-over: HS-185019 mitigation, HS-182399 follow-on (next batches), Batch-2/3 of the semantic email migration.

---

## 2026-05-15 - Weekly Review (2026-05-12 to 2026-05-15)

**Summary:**
Short week (Mon–Fri) but extremely dense — wrapped up the LaunchDarkly migration of the semantic-email gate, drove HS-182399 PR #70801 deep into PM-batch-rollout-readiness, and shipped a meeting metadata + thumbnail enrichment for `share_meeting`. Big infrastructure unlock: rule/skill discoverability hardening (4 root causes diagnosed → user rule + audit one-liners + symlink-based skill activation), `learn-session-fixes` skill for capturing accepted fixes mid-session, and Patterns I + J added to the body-copy skill so the next agent reuses today's recipes. Also created a KTLO ticket for `prod_content_cdn_lambda_throttling` mitigation off the foundation alert thread.

### Significant Cursor Activities
- **share_meeting card enrichment (May 15)**: Added render-time meeting-metadata enrichment via `engagement_meeting_list_records` Mongo lookup in `EngagementMeetingQueries.find_list_record(domain_id, meeting_id)`. Picked render-time DB lookup over (a) end-to-end plumbing through `MeetingHighlightHandler` + `create_meeting_shared` signature, and (b) preview-only mock enrichment. Trade-off: one extra projection-scoped point read per render, tolerated because of unique index `(domain_id, source_id)` and `rescue nil` graceful degrade. Card now shows Host / Meeting Date / Duration / Opportunity / Account / Attendees rows when populated; omits absent rows (no fallbacks). Meeting thumbnail wired end-to-end via canonical `get_item_thumbnail_url → ThumbnailPresenter#url_for_email → UrlPresenter` chain after fixing two gaps: unqualified `THUMBNAIL_WIDTH` / `THUMBNAIL_HEIGHT` raised `NameError` (Ruby `extend` mixes methods but not constants — must qualify as `EmailContentBuilder::Base::THUMBNAIL_*`), and preview lambdas weren't threading `thumbnail_url:`. Audit then found the preview was hardcoding the URL string and skipping both presenters; rewired through the same chain as production. Codified as Patterns I (render-time enrichment via Mongo lookup) and J (canonical thumbnail presenter chain) in `migrate-semantic-email-body-copy/SKILL.md` (~593 lines).
- **Cursor rule/skill discoverability hardening (May 13–15)**: After a 153-key `iidgen` audit caught 22 length violators + 130 descriptive keys + 1 case-collision (root cause: `iidgen` mandate buried in a multi-topic rule + repo-local skill `nutella-intl-strings` not surfaced in `<available_skills>`), distilled four orthogonal failure modes into (a) `~/.cursor/rules/effective-cursor-rules.mdc` user-level rule with audit one-liners, (b) shareable `docs/effective-cursor-rules-and-skills.md` post-mortem (~285 lines, nine fix patterns A–I + maintenance scripts + "what this doesn't solve" honesty section), (c) `learn-session-fixes` skill (auto-fires on acceptance signals like "perfect"/"merge it"/"lgtm" with mandatory diff-preview + confirmation; 220 lines), (d) extracted `i18n-keys.mdc` as single-topic rule with broad globs (`**/*.rb`, `**/*.haml`, `**/*.erb`), (e) cross-referenced 7 semantic-email-migration skills' front-matter so loading one steers to siblings, (f) replaced copy-and-overwrite skill sync with permanent symlinks pointing into `ai-plugins/nutella-semantic-email-migration/` (`add-nutella-semantic-email-migration` branch pushed, PR ready). The 6 sibling email-migration skills that were previously invisible to Cursor are now active.
- **HS-182399 deep-rev (May 12–15)**: `compare_email_previews.py` gained `--rule-category` Mongo-backed filter (live `/api/v1/notification_rules` taxonomy, 60 categories), zero-count rule-checks visibility in run summary, broadened `[RULE:body_after_following_reference]` regex (matches multi-word predicate phrases + `\s*` post-colon), removed `[RULE:custom_smtp]` (Pattern G now sanctions the colon), `_filter_mock_data_issues_covered_elsewhere` so `[FAIL:mock_data]` only flags true mock divergence (5 → 0 with no regressions). Concise-comments rule + sweep across 22 nutella files (~3,348 net lines of comment cruft removed; ~349 lines of opaque `Pattern E`/`[RULE:foo]` taxonomy stripped from code). Pattern E dispatch fix: moved from registration lambda into method body (Padrino autoloader does NOT re-execute top-level `each` blocks on file change — pattern documented in skill as a Common Gotcha). Force-pushed 153 fresh `iidgen` keys to fix Buildkite. Semgrep `avoid-raw` false-positive fixed by renaming `raw` param → `value`.
- **LaunchDarkly migration of semantic-email gate (May 13)**: Rewired `SemanticEmailCommands.enabled?` to consume three LD flags (`unified_notification_system`, `semantic_email_enabled_categories`, `semantic_email_category_overrides`) instead of `mjml_email_templates` rollout flag + `semantic_email_disabled_kinds` DC kill switch. Category-gated semantic enablement added as third gate on top of per-user/per-domain rollout: per-user override → per-domain override → DC baseline; kinds with no category fall back to legacy. PR #70801 commit `a8ee013a6d0`. Prerequisite for shipping: LD targeting on `unified_notification_system` must mirror `mjml_email_templates`'s current set before reaching production.
- **Worklog skill+rule update (May 13)**: Gated git push on user confirmation via `AskQuestion` (previously auto-pushed). Local file append still happens automatically; the `git add` / `git commit` / `git pull --rebase` / `git push` step now requires explicit confirmation. Both `update-worklog/SKILL.md` and `work-log.mdc` rewritten with the same gate + "Why this gate exists" explanation (revise before public, batch entries, sensitive names).
- **Magma admin pagination (#8894, May 14)**: `/notification_rules` admin page rendered only first 25 of ~300+ rules. Added `default-page-size` 25 → 100, per-page selector (25/50/100/250), and `page-nav` helper showing `« prev / page X of Y / next »` below the table, preserving filters across pages. Pure server-rendered HTML; no data model / API / migrations.
- **`prod_content_cdn_lambda_throttling` KTLO ticket (May 15)**: Created Jira HS-185019 under epic HS-183256 capturing 3 follow-up items from the New Relic alert slack thread — root cause confirmed in-thread as magma-api pod-restart-induced retry bursts on shared account-level lambda concurrency (1000-limit), not the CDN lambda hitting its dedicated limit. Fixes: (1) tune magma-api pod scaling with foundation team, (2) reduce retries on connection/timeout failures, (3) add graceful shutdown on `SIGTERM` so in-flight requests drain instead of being dropped + retried.

### Significant Proposals
- Three-flag LaunchDarkly composition for per-rule-category PM-batch rollout (LD PR #328 documentation): `unified_notification_system` (per-user/per-domain rollout) AND kind has registered category AND (per-user override `true` OR per-domain override `true` OR (in `semantic_email_enabled_categories` AND no override says `false`)). Strict per-user precedence so internal-QA can early-access a category their domain has killed off. Three sample variations per flag + 5 targeting-rule recipes documented in the PR description.
- Per-rule-category PM-batch validation pipeline (`validate_rule_category.sh` 4-step: parity → rubric → snapshot drift → SMTP+mailpit) — proposed in `#crew-app-platform-private` and DMs with Nav, May 14–15. Drove the Batch-1 / Batch-2 column add to the Email notifications migration spreadsheet.

### Significant Documents
- `Email notifications migration data` (Google Sheets, modified May 7 + May 15) — added `rule.category` column, `Batch(deployment)` column for per-category rollout staging, `Good` review-#2 column populated by Nav. Full breakdown by category with Total / Good / Remaining counts shared back to Nav (announcement / amazon_email / assessment / etc., 60 categories total).
- `effective-cursor-rules-and-skills.md` (May 13) — shareable post-mortem doc on rule/skill discoverability with concrete fix patterns + audit scripts.
- Updated `notifications-migration/README.md` (~60 lines added May 15) — PM-rubric mode, `pm_pass`/`pm_fail` verdicts, `--rule-category` + `--semantic-only-rubric` CLI rows, `## PM rubric mode` and `## Per-rule-category PM-batch validation` sections.
- Engineering Demos & Updates (Confluence ENGDOCS, contributed May 14).

### Significant Helping Others
- Active collaboration with Nav on per-rule-category review batching: ran category-by-category Total/Good/Remaining breakdown, set up Batch-1 deployment via the new LD category flag, fixed the previews-vs-production category mismatch ("preview category" vs `ALERT_CONFIG`/Rules category) that was blocking LD setup, lock-down recommendation on shared sheet columns to prevent agent edits to A/B/C.
- Approval coordination with Jeff Sarmiento on LD PR #328 — Nathan couldn't approve due to new variations being global (not per-environment), Jeff approved via the LaunchDarkly approval URL.
- DM thread with Nathan Harkenrider on the variation-control architecture (variations not environment-specific at creation; explicit per-rule enable/disable selection thereafter; new email categories require approval as added).

### Significant PRs
- **nutella PR #70801** (HS-182399, OPEN, ~9 days iterating, 43 files / +8,052 / -815): Semantic email text & styling fixes — 7 PR-tip commits this fortnight covering LD migration, category-gating, i18n key sweep (153 keys), concise-comments sweep (-3,348 lines), Pattern E/G fixes, share_meeting enrichment + thumbnail wiring, Semgrep fix. Multiple "high-risk file" + "Large PR" GitHub bot warnings; reviewer-friendly via the per-commit summary table in the PR body.
- **launchdarkly-flags PR #328** (MERGED May 14): Three new app-platform flags + comprehensive sample-variations + targeting-rule + recommended rollout-order documentation. Approved by Jeff Sarmiento.
- **magma PR #8894** (HS-180223, OPEN May 14): `/notification_rules` admin pagination — 1 file, +49/-6.
- **ai-plugins branch `add-nutella-semantic-email-migration`** (PR pending): 2 commits — cross-reference 7 skills + sync `migrate-semantic-email-body-copy/SKILL.md` from local (1612 lines).

### Significant Jira Tickets
- **HS-182399** (PM Feedback iteration #1, P3, In Progress) — driving PR #70801; "Needs Fix" list still working through.
- **HS-185019** (Mitigate `prod_content_cdn_lambda_throttling`, P3, To-Do, **created May 15**) — KTLO follow-up under HS-183256 epic.
- **HS-180223** (REST API for NotificationRules, P3, Code Review) — Phase 3 REST API merged May 13 (PR #70329, 18 files / +1,636 / -2); admin pagination follow-up (#8894) opened May 14.
- **HS-155824** (`email_tracking_details_v1` slow query, P2, In Progress).

### Key Challenges This Week
- **Padrino autoloader does NOT re-execute top-level code blocks** (rediscovered May 13 via Pattern E custom_smtp_pitch_send_failed): registration lambdas captured at module load time. Pattern G (method-body change) worked but Pattern E (lambda-body change) silently didn't. Fix moved dispatch into method body. Generalizable across SendFailed/PitchRelationship/SpotAccess/Share families. Documented as Common Gotcha + diagnostic ("if G works but E doesn't, this is the cause").
- **Ruby `extend` doesn't bring constants into host module's lookup chain** (May 15 share_meeting): unqualified `THUMBNAIL_WIDTH` raised `NameError` only when a non-nil URL was passed (the `nil` short-circuit in `item_preview` was hiding the bug). Always qualify as `EmailContentBuilder::Base::THUMBNAIL_*`. Pinned with regression spec.
- **Padrino dev-server stale "Could not render" cache** (May 15): after fixing a render-time exception, the response cache continues serving the failure page until busted via `?cb=$(date +%s%N)`. Wasted ~30 minutes of debugging; documented in Pattern J + skill gotchas.
- **Cursor rule/skill discoverability has 4 orthogonal failure modes** (May 13): stale globs, repo-local skills not surfaced, passive cross-references, mandates buried in multi-topic rules. Mitigated via `effective-cursor-rules` user rule + audit scripts + skill activation via symlinks; commit-time enforcement (pre-commit hook on `Hspt::Intl.t(...)` calls) is the highest-leverage open follow-up.
- **`nutella/.cursor/**` is gitignored** — improvements to repo-local rules don't propagate to teammates without unignoring `.cursor/rules/` or moving content into a checked-in directory. Flagged as open follow-up.
- **Subagents inheriting stale rules** (May 13): 7 fragmented worklog commits pushed by subagents that inherited a pre-confirmation version of the work-log rule. The new rule explicitly requires `AskQuestion` before every git op on the worklog repo, but subagents bypassed it. Consolidated into a single entry; flagged for awareness on subagent rule-propagation.

**Notes:**
- All MCPs working except a few transient errors (Atlassian, Workato Drive — retried successfully).
- This is the first week-long span where the worklog automation gate (push only on confirmation) has been in effect; carry-over: monitor for missed pushes during long sessions.
- Carry-over to next week: address GitHub bot warnings on PR #70801 (high-risk files / Large PR), drive PM-batch rollout via the new LD flags, push the ai-plugins symlink PR to merge so 6 sibling skills become discoverable for teammates, magma admin pagination review.

---

## 2026-05-11 - Weekly Review (2026-05-05 to 2026-05-11)

**Summary:**
Two-and-a-half-track week. Track 1: closed out the Notification Rules Phase 2+3+5 merge train (NotificationEngine, REST API, magma admin UI all merged May 5). Track 2: massive PM-driven semantic-email parity push — fixed `[RULE:inlined_card_title]` violations across 8 builder families (Pattern A allowlist + Pattern B helper extraction), resolved a multi-layer `lesson_progress_reset` production entity-reversal bug, rebuilt the assessment family with 7 production-path preview variations + ALERT_CONFIG-derived bodies. Track 3: turned `compare_email_previews.py` into a comprehensive PM-rubric tooling suite (14 new migration rule checks, snapshot regression catalogue, verdict bucket refactor, run summary auto-discovery, success-rate metrics) and shipped it as PR #70903. Closed HS-179437 ("Notifications CS1 - Foundations") epic by reparenting its 14 still-open tickets to a new beta epic (HS-183484) so each release boundary is clean.

### Significant Cursor Activities
- **`[RULE:inlined_card_title]` sweep across 8 families (May 6)**: Walked the rspec.log family-by-family. Pattern B (direct builder method body, replace `body_copy = strip_html_tags(config_defaults[:messages_text])`) for Send-failed (Family #1, prior session), Pitch ownership/collaborator (#2, 9 kinds), Spot access (#3, 4 kinds), Share meeting (#4, 2 kinds), Session proctor unassigned (#6, 2 kinds), Workflow + Generic + Restricted template (#7, 6 kinds). Pattern A (LearningBuilder allowlist, flip precedence so semantic body wins over legacy `messages_text`) extended `KIND_PREFERS_SEMANTIC_BODY` from 24 → 41 kinds (#5, ~17 kinds). Cleaned up two latent inverted-precedence bugs in `workflow_builder.rb` and `generic_builder.rb` where `body_copy = strip_html_tags(config_defaults[:messages_text]) || body_copy` was overwriting the semantic body with the legacy text. Consistent terminology pivot: `noun` → `entity` across code + i18n placeholders. The `migrate-semantic-email-body-copy` skill rewritten in the same session to fully document Pattern A vs B with file-by-file recipes.
- **`lesson_progress_reset` multi-layer bug (May 6)**: PM flagged preview text as wrong. Root cause was production entity-reversal — only lesson kind where `:item => lesson` and `:assigned_item => course` (REVERSED from every other lesson kind). Legacy template handled it via key-based interpolation; semantic builder reads positionally → renders course title in lesson slot. Production semantic emails for this kind have been shipping wrong since migration. Fix: per-kind entity swap immediately after `fetch_item` calls in registration block; added `:lesson_progress_reset` to `NO_CTA_KINDS` (legacy has no `:action`); extended `skip_lesson_card` to it; aligned legacy mock via `inject_kind_specific_data!` override.
- **Assessment family rebuild (May 6–7)**: Added 7 production-path preview entries for `assessment_submitted` (manager_review, manager_review_for_direct_manager, training, meeting, customer_for_user, customer_for_direct_manager, self_for_direct_manager) matching the 7 `create_assessment_submitted_for_*` factories. Plumbed `entry[:variation]` through `build_immediate_single_email` → `legacy_config_defaults` → `inject_kind_specific_data!` so per-sub-path comment overrides flow into both legacy and semantic preview. Eliminated ~70 lines of hardcoded HTML in `build_assessment_body_html` by promoting `defaults[:messages_text]` (already produced from ALERT_CONFIG via `expand_messages` → `flatten_template`) into `messages_html` — semantic preview is now production-faithful and resyncs whenever ALERT_CONFIG strings change.
- **`compare_email_previews.py` major expansion (May 8–11)**: 14 new migration rule checks (`[RULE:missing_card]` strict card-design enforcement, `[RULE:item_count]`/`[RULE:card_count]` parity, `[RULE:reply_completeness]`, `[RULE:card_meta]`, `[RULE:default_avatar]`, `[RULE:cta_presence]`, `[RULE:header_parity]`/`[RULE:footer_parity]`, `[RULE:card_url_type]`, `[RULE:duplicate_sections]`, `[RULE:body_copy_length]`, `[RULE:empty_links]`, `[RULE:url_encoding]`, `[RULE:sensitive_data]`). Tuned each against the full 312-kind sweep until only genuine bugs remained (15 → 2 hits after FP fixes). Snapshot regression catalogue: `--snapshot-update`/`--snapshot-check`/`--snapshot-dir` CLI flags + 186 baseline JSON files committed under `snapshots/<category>/`, structured (subject/preheader/section_titles/body_copy/card_titles/card_urls/cta_text/cta_urls/reply_authors) plus `html_normalized_sha256` tripwire, volatile-text normalization (tracking params, relative timestamps, MSO conditionals stripped). New `warn_same`/`warn_structured` verdict bucket so passing kinds with always-on warnings (HS-183419 tracking_tag, semantic_extra) get visibility instead of being indistinguishable from clean passes; invariant `Pass + Warn + Fail + Preview Missing == Total` holds exactly. Strict `[RULE:newlines]` reworked to compare legacy `$alert.messages` paragraphs against semantic `body_copy` paragraphs via CSS-anchored regex (`font-size:16px;line-height:20px`) — eliminated ~13 false positives across `immediate_feedback_share` and `immediate_send_failed` while still catching the 6 genuine 2-message-collapse cases.
- **`compare_email_previews.py` UX polish (May 8–9)**: Run summary collapsed into single sectioned `─── Run summary ──` block with indented sub-rows; later split into two clearly-separated sections (verdict roll-ups + cross-cutting backlogs) to fix the parent/child math confusion. Added strict + lenient success rates (`Pass / Total` and `(Pass + Warn) / Total`). Auto-discovery of all reason types in Backlogs section (`BACKLOG_DESCRIPTIONS` dict, every `[RULE:*]`/`[FAIL:*]`/`WARN:*` surfaces with severity icon + count + per-verdict breakdown). Improved Backlogs section wording with severity icons (❌/⚠️) + English-prose breakdowns. `--reason-type` filter now matches backlog tags verbatim (was mismatched between `_format_run_summary` expansion and `fail_reason_parts` bare reasons; copy-pasting from backlog produced 0 matches before fix); `--show-checks` opt-in for tick columns; `--reason-type` filter gates per-kind verbose log; `--failed-only` includes warnings; default narrow table fits in normal terminal (~150 chars vs ~240 prior).
- **MJML entity-card text-column wrapping fix (May 8)**: `feedback_item` regression — text column wrapping below thumbnail at desktop 600px width. Root cause traced to original commit `c04945fdc4e`: `text_max_w` formula started from 536px (mj-column inner width after subtracting outer mj-section padding) but forgot another 32px for the inner `<mj-text padding="16px">` wrapper. Real available width is 504px. Fixed formula + added inline comment explaining box-model math. Latent bug since the layout shipped.
- **Mock data parity sweep (May 9)**: Investigated 8 mock-data related failures (`[FAIL:mock_data]` × 7, `[MOCK DATA MISMATCH]` × 1). Categorized into 3 root causes: allowlist gaps in `EXPECTED_MOCK_ENTITIES`, headline-event hyperlink heuristic FP (`pitch_message_opened_html.vm` wraps entire H2 in `<a>`), and one real legacy-mock parity gap. Net backlog drop: -1 `[FAIL]` (124 → 123) plus 8 noise rows eliminated. Phase 2 production-shape mock data unlocked 5 missing_card kinds: `items_published`, `items_unpublished`, `no_valid_content_approval_reviewers`, `item_expiring`, `item_expired`, `smart_feedback_failure`. Pattern: `data["spot"] = data["spot"].merge("type" => Constants::SPOT_ENTITY, "id" => spot_obj.id)` so `AlertPresenter#data_value_to_output` doesn't short-circuit on `id.nil?`.
- **CS1 epic split (May 7)**: Closed HS-179437 ("Notifications CS1 - Foundations (UX + Rules Engine)") with 26.4.0 fix-version on 8 Ready-for-Test tickets (HS-183699, HS-182039, HS-180233, HS-180222, HS-180220, HS-180219, HS-180218, HS-180217); two distinct close transitions used (id 551 for Tasks/Bugs, id 531 for Features); HS-182039 (Bug) required `Root Cause Category Not Applicable`. Reparented 14 remaining open tickets (HS-183419, HS-182399, HS-180232, etc.) to new beta epic HS-183484 ("Notifications CS1 - Foundations - [Highspot Beta]"). Each epic now reflects a single release boundary.

### Significant Proposals
- "Don't fork `semantic_email_enabled_categories` per audience for narrow exceptions; use `semantic_email_category_overrides` instead" — embedded in the LD PR #328 design that landed the following week. Avoids per-audience variation explosion.
- Pattern A vs Pattern B fix-shape decision tree codified in the `migrate-semantic-email-body-copy` skill — Pattern A for kinds where `body_copy_for_kind` already has the right wording but isn't opted into `KIND_PREFERS_SEMANTIC_BODY`, Pattern B for direct builder methods that assign `body_copy` from `config_defaults[:messages_text]`.

### Significant Documents
- `Email notifications migration data` (Google Sheets, created May 7) — new spreadsheet for per-rule-category tracking; shared with Nav, Nathan, Chris Kwok, Davidson Yeap, Abhijeet Saraf.
- `notifications-migration/README.md` (May 9) — added "Work a backlog row from the run summary" subsection: 4-step drill-in → diagnose → fix → verify loop, `Tag → typical fix location` table covering all reason tags, worked example documenting the HS-182399 mock_data drain end-to-end (8 mock_data hits → 0). Forward-pointer from the Output chapter so backlog terminology page → playbook is one hop.

### Significant Helping Others
- Multiple DM threads with Nav Nand on body-copy patterns ("the following X:" anchor convention, `<br>` line-break preservation), preview vs production category routing, and per-batch deployment planning. Negotiated whether to fix specific patterns in current batch vs next batch ("just trying to keep the PR overhead so that it doesn't sit there for months waiting for approval").
- Coordinated with PM review on assessment-family card design (Design A — `New Meeting Assessment` section title + structured `html_content` rows surfacing dynamic `Status` value).
- Self-review iteration on PR #70329 (Phase 3 REST API) addressing all remaining Bugbot comments — merged May 13.

### Significant PRs
- **nutella PR #70320** (HS-180222, MERGED May 5, 22 files / +2,721 / -50): NotificationEngine with rules-first routing.
- **magma PR #8831** (HS-180223, MERGED May 5, 6 files / +709 / -5): Notification rules entities view + admin UI consuming Phase 3 REST API.
- **nutella PR #70329** (HS-180223, MERGED May 13, 18 files / +1,636 / -2): Phase 3 notification rules REST API (operator-only).
- **nutella PR #70903** (HS-180220, MERGED May 11, 7 files / +7,171): notifications-migration test scripts — `compare_email_previews.py` + `export_preview_data.py` + `test_email_previews.py` + `compare.sh` + `.gitignore` + README.
- **nutella PR #70801** (HS-182399, OPENED May 7): semantic email text & styling fixes — drove the Track 2 + Track 3 work; still open at week's end, iterating with reviewers.

### Significant Jira Tickets
- HS-179437 (Notifications CS1 - Foundations, P1, **Closed** May 8) — epic split.
- HS-183484 (Notifications CS1 - Foundations - [Highspot Beta], P1, In Progress) — new epic with 14 reparented tickets.
- HS-180222 (NotificationEngine Phase 2, P3, Closed May 5).
- HS-180223 (REST API + Admin UI, P3, Code Review/Closed May 13).
- HS-180220 (notifications migration test scripts, P3, Closed May 11).
- HS-182399 (PM Feedback iteration #1, P3, In Progress) — driving PR #70801.
- HS-183419 (semantic email tracking_tag plumbing, P3, To-Do) — informational warning surfaced via `WARN:tracking_tag` in compare runs.

### Key Challenges This Week
- **Production data-shape asymmetries** (May 6 lesson_progress_reset): only lesson kind with reversed `:item`/`:assigned_item`. Production semantic emails have been shipping the wrong title since this kind was migrated. Fix: per-kind entity swap at registration boundary so direct callers (tests, preview) keep natural shape. Now the second known asymmetry (LP-link kinds + lesson_progress_reset); if a third surfaces it's officially a pattern.
- **`AlertPresenter#data_value_to_output` short-circuits on `id.nil?`** (May 9): mock dicts with `{title, url}` but no `{type, id}` silently drop the entity — entire output becomes `{}` because `data_to_output`'s `rescue` catches every exception. Only diagnostic surface is `EventLogger.error("Failed to load #{entity_type} entity ...")` in `~/Codebase/latest/nutella/web/server.out`. Added "Debugging Preview Failures" section to `semantic-email-previews.mdc` so future preview triage starts there.
- **Inverted precedence latent bugs** (May 6): `body_copy = strip_html_tags(config_defaults[:messages_text]) || body_copy` in `workflow_builder.rb` and `generic_builder.rb` was overwriting semantic body with legacy text the builder had just rejected. The `|| body_copy` fallback masked the bug whenever legacy returned non-nil. Fix: removed both lines; semantic now wins.
- **Two distinct verdict bucket migrations** (May 8): introduced `warn_same`/`warn_structured` to give visibility to ~285 HS-183419-affected kinds and ~157 semantic-extra kinds that were previously indistinguishable from clean passes; later (May 13, see next week) dropped the demotion path entirely once the per-rule-category review workflow made `WARN:tracking_tag` an inventory item rather than a verdict-modifier. Lesson: verdict-bucket refactors are easier to UNDO than to ADD; resist the urge to add a bucket just to surface an inventory item — a backlog row is enough.
- **`[RULE:newlines]` brittle baseline** (May 8): the previous "extract body region + table-block stripper + chrome-line filter" pipeline was producing ~13 false positives. Replaced with single CSS-anchored regex `font-size:16px;line-height:20px` matching ONLY `$alert.messages` paragraphs. Trade-off: if anyone restyles message paragraphs in `alerts_html.vm`, the rule silently stops firing. Accepted because the template is stable and PM specifically asked for strict semantics.

**Notes:**
- GitHub MCP auth still broken; using `gh` CLI as fallback (carry-over from prior weeks).
- Atlassian MCP working normally throughout the week.
- Snapshot catalogue (`snapshots/`) is intentionally not committed in PR #70903 (per-developer regeneration concern noted in README); PR #70801 commits relevant baselines as the migrating kinds promote to passing.
- Carry-over to next week: address Bugbot comments on PR #70801, finish the LD migration of the semantic-email gate, plumb meeting metadata + thumbnail into `share_meeting`.

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
