# Weekly Work Log

This log tracks weekly summaries of significant work across all sources (Cursor, GitHub, Jira, Slack, Confluence, Google Drive).

## Running Summary

*Last updated: 2026-05-15*

### Overall Key Accomplishments (Jan-May 2026)

**Significant Cursor Activities:**
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
- **HS-182399 PR #70801 ship**: Land the semantic email text & styling fixes — meeting thumbnail wiring done May 15, share_meeting metadata enrichment done; addressing high-risk-file warnings on `web/common/email/email_commands.rb` and the "Large PR" label. PM-batch rollout via the new LD category flags is the gating shippable.
- **Per-rule-category PM-batch validation**: `validate_rule_category.sh` 4-step pipeline (parity → rubric → snapshot drift → SMTP+mailpit) just landed in README; ready to drive Nav's per-category review batches with `--rule-category share`, `--rule-category training`, etc.
- **Magma admin pagination follow-up (#8894)**: Page selector + prev/next pagination on `/notification_rules` admin page, opened May 14, in review.
- **CDN lambda throttling mitigation (HS-185019)**: 3 follow-ups from the New Relic alert thread — magma-api pod scaling tuning, retry reduction on connection failures, graceful shutdown on SIGTERM. KTLO ticket created May 15; coordination with foundation team pending.
- **Skill bundle activation**: `add-nutella-semantic-email-migration` ai-plugins branch open with 7 cross-referenced skills + symlinks set up locally; PR pending review/merge.

### Current Blockers
- HS-151210 (Pinterest font request) remains Blocked
- HS-183419 (semantic email tracking_tag plumbing) — informational WARN only, ~120 kinds in Pass + 81 in Fail; needs separate plumbing pass through builder lambdas
- `nutella/.cursor/**` is gitignored, so in-repo rule edits don't propagate to teammates without unignoring `.cursor/rules/`
- Repo-local skills are not surfaced in `<available_skills>` — Cursor product behavior; needs feature request or config investigation

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
