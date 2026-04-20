---
name: Notification rule schema and seeding
overview: NotificationRule schema definition aligned with the tech spec, legacy-to-schema field mappings from ALERT_CONFIG / EmailCommands::SETTINGS / call-site code, and the mapping scripts and rake task that seed rules into MongoDB.
todos:
  - id: rule-builders
    content: "Create rule builder modules: CALL_SITE_EMAIL_OPTS, PRIORITY_MAP, build_immediate_rule, build_digest_rule, build_in_app_rule, build_direct_email_rule -- all producing unified schema"
    status: pending
  - id: db-migration
    content: "Create database migration: web/db/migrate/<jira>_seed_notification_rules.rb using DatabaseMigration pattern with insert_many and existing-key filter"
    status: pending
  - id: db-migration-spec
    content: "Create integration spec: web/db/spec/integration/migrate/<jira>_seed_notification_rules_spec.rb -- count + idempotency assertions"
    status: pending
  - id: deploy-script
    content: Append migration line to web/tools/scripts/deployment/apply_data_migration.sh
    status: pending
isProject: false
---

# Notification Rule Schema and Seeding

**Parent:** [Notification rules master plan](notification_rules_master_plan.plan.md)

## Summary

**Total rules to be seeded: ~381**

| Source | Rule type | Count |
|---|---|---|
| ALERT_CONFIG | Immediate rules (email + in_app) | ~291 |
| ALERT_CONFIG | In-app only rules (`no_email: true`) | ~24 |
| System | Digest rule (batches `group_email` kinds) | 1 |
| EMAIL_SETTINGS | Direct email rules | ~65 |
| **Total** | | **~381** |

Note: 2 of the in-app only kinds also have `push_notification: true`, so their channels will be `["in_app", "push"]`.

---

## Problem

The tech spec (`Notifications platform Tech Spec.docx`) defines the canonical forward-looking `NotificationRuleSchema`, but the mapping scripts currently produce a different shape. We need one normalized schema that:

1. Aligns with the tech spec's structure (the target architecture)
2. Captures all legacy decisions from ALERT_CONFIG, EmailCommands::SETTINGS, and call-site code
3. Supports the phased rollout (Phases 0-12) without schema-breaking changes

---

## Design Decisions

**Resolved conflicts across documents:**

- **Primary key**: Use `name` (string) -- tech spec calls it "notification name," all other plans use `name`
- **Priority**: Use tech spec's enum strings: `"critical"`, `"urgent"`, `"actionable"`, `"informational"` -- map legacy `level: :warning` + `urgent: true` to `"urgent"`, `:warning` to `"actionable"`, `:info` to `"informational"`
- **Channels**: Use array of strings (`["email", "in_app"]`) per tech spec -- not a hash of booleans
- **Trigger**: Include per tech spec -- seed with `event_name = name`, `source_system = "nutella-api"`
- **Content resolution via registry**: No `content` block on the base rule. The Content Registry maps rule `name` to its semantic builder. Email rendering is implicit when `channels` includes `"email"`. Content text overrides (subject, preheader, body, CTA) live in `notification_rule_overrides.content_overrides`.
- **Delivery guards grouped**: `throttling`, `deduplication`, `delivery_window` live under `delivery_strategy.guards` -- all seeded with `enabled: false`. `actor_suppression` is a routing concern (not a guard) so it stays at the `delivery_strategy` top level. No `retry_policy` -- retries are handled by the job system.
- **Channel-specific options in delivery_strategy**: Each channel gets its own sub-object within `delivery_strategy` (e.g., `email: { send_from, send_one, ... }`, `in_app: { skip_toast }`). This keeps all delivery behavior in one place, is extensible for new channels, and eliminates separate top-level option blocks.
- **Email delivery mode**: Derive from `delivery_strategy.batching.aggregation_type` -- `"disabled"` = immediate, `"time_based"` = digest. No separate `email_delivery` field needed.
- **Overrides in a separate collection**: Per-domain and per-user customizations live in `notification_rule_overrides`, not on the base rule. This keeps global rules clean, allows N overrides per rule, and enables a clear resolution order (user+domain -> domain -> user -> global rule -> legacy fallback). Overridable: `delivery_strategy` fields (including channel-specific sub-objects) and email content (subject, preheader, body sections). Not overridable: identity fields (`name`, `trigger`, `category`).
- **Digest eligibility is centralized**: Legacy `group_email: true` does NOT map to a flag on per-kind rules. Instead, it feeds the single digest rule's `eligible_alert_kinds` list. The routing layer checks that list to decide whether to suppress immediate email. This avoids redundant state and keeps digest membership in one place.
- **All legacy decisions captured**: The rule schema must be the single source of truth for every routing and delivery decision currently embedded in ALERT_CONFIG, EmailCommands::SETTINGS, and call-site code. No legacy decision should be lost -- if it affects how a notification is routed or delivered, it has a field in the rule. See the [complete seeding mapping table](#complete-legacy-to-rule-seeding-mapping) for the exhaustive list.

---

## Unified NotificationRule Schema

```jsonc
{
  // ── Identity ──────────────────────────────────────────────────────
  "name": "share_item",              // Unique rule identifier; matches the alert kind or email type
  "version": 1,                      // Schema version; bump on breaking changes
  "status": "active",                // "active" | "inactive" -- controls whether rule is evaluated
  "type": "immediate",               // "immediate" | "digest" | "direct" -- rule type for filtering/querying
  "category": "share",               // Logical grouping for UI/filtering (e.g., "share", "admin", "billing")
  "description": "Notification rule for share_item",  // Human-readable summary
  "created_at": "2026-04-08T00:00:00Z", // Creation timestamp (top-level per MongoDB convention)
  "created_by": "system",            // Who created this rule: "system" for seeded, user id for manual

  // ── Trigger ───────────────────────────────────────────────────────
  "trigger": {
    "event_name": "share_item",      // Event that activates this rule (= name for seeded rules)
    "source_system": "nutella-api"   // Originating system; enables multi-system routing later
  },

  // ── Delivery Strategy ─────────────────────────────────────────────
  "delivery_strategy": {

    // ── Routing ───────────────────────────────────────────────────
    "channels": ["email", "in_app"],  // Which channels: "email", "in_app", "push", "slack", "ms_teams"
    "priority": "actionable",         // "critical" | "urgent" | "actionable" | "informational"
    "actor_suppression": false,       // Suppress notification to the user who triggered the event

    // ── Timing ────────────────────────────────────────────────────
    "batching": {
      "aggregation_type": "disabled", // "disabled" = send immediately; "time_based" = batch into digest
      "time_window": null,            // Batch window (e.g., "1d", "6h"); only for time_based
      "min_count": null               // Min alerts before digest is sent; only for time_based
    },

    // ── Delivery Guards (Phase 8) ─────────────────────────────────
    "guards": {
      "throttling": {
        "enabled": false,             // Rate-limit notifications per recipient
        "max_per_window": null,       // Max notifications within the window (e.g., 5)
        "window": null                // Window duration (e.g., "1h", "24h")
      },
      "deduplication": {
        "enabled": false,             // Suppress duplicate notifications
        "key": null,                  // Dedup key (e.g., "kind+recipient+item_id")
        "window": null                // Dedup window (e.g., "10m", "1h")
      },
      "delivery_window": {
        "enabled": false,             // Restrict delivery to specific hours
        "start_hour": null,           // Earliest hour in recipient's timezone (e.g., 8)
        "end_hour": null,             // Latest hour in recipient's timezone (e.g., 20)
        "timezone_source": "recipient"// "recipient" | "org" | "utc"
      }
    },

    // ── Channel Options ───────────────────────────────────────────
    "email": {
      "renderer": "semantic",        // "semantic" (MJML-based) -- all new rules use semantic
      "builder": "share_item",       // Semantic builder name from Content Registry
      "send_from": true,             // Resolve the triggering user as the email "From" sender
      "send_one": false,             // Single email to all recipients (vs one per recipient)
      "bcc_support": false,          // BCC the support address
      "no_to": false,                // Suppress the To header (used with explicit BCC)
      "bcc_mode": null,              // null | "explicit" -- when "explicit", uses a supplied BCC list
      "from_support": false,         // Send from the support address instead of default sender
      "account": false               // Deliver even when user has email notifications disabled
    },
    "in_app": {
      "skip_toast": false            // Suppress toast popup (alert still appears in feed)
    }
  },

  // ── Metadata (migration tracking) ─────────────────────────────────
  "metadata": {
    "source": "ALERT_CONFIG",        // Legacy source this rule was seeded from: "ALERT_CONFIG" | "EMAIL_SETTINGS"
    "legacy_email_type": "alert",    // Legacy email type for migration tracking: "alert", "alerts" (digest), type name, or null
    "has_variations": false,         // Whether ALERT_CONFIG has :variations block
    "legacy_base_template": null     // From EMAIL_SETTINGS :async[:base_template] (direct emails only)
  }
}
```

**Sub-schema notes:**

- **Channel-specific sub-objects** -- each channel gets its own options object within `delivery_strategy`: `email` (send_from, send_one, bcc_support, no_to, bcc_mode, from_support, account), `in_app` (skip_toast). Future channels (push, slack, ms_teams) will add their own sub-objects. Only present when that channel is in `channels`. Note: `group_email` is NOT on per-kind rules -- digest eligibility is determined solely by the single digest rule's `eligible_alert_kinds` list
- **`guards`** -- Phase 8 delivery guards (`throttling`, `deduplication`, `delivery_window`) grouped under one sub-object; all seeded with `enabled: false`. Retries are handled by the job system, not the rule.

---

## NotificationRuleOverride Schema (separate collection)

Per-domain or per-user customizations live in a **separate `notification_rule_overrides` collection**, not on the base rule. This keeps global rules clean and universal while allowing N overrides per rule scoped to a domain, user, or both.

### Override document

```jsonc
{
  // ── Identity ──────────────────────────────────────────────────────
  "_id": "ObjectId",
  "rule_name": "share_item",          // References the base NotificationRule.name
  "scope": {
    "domain_id": "abc123",            // Domain this override applies to; null = not domain-scoped
    "user_id": null                   // User this override applies to; null = not user-scoped
  },

  // ── Overridable: Delivery Strategy (partial) ──────────────────────
  "delivery_strategy": {
    "channels": ["email"],            // Override which channels are active for this scope
    "priority": "urgent",             // Override priority for this scope
    "email": {
      "bcc_support": true             // Override any email channel option
    },
    "in_app": {
      "skip_toast": true              // Override any in_app channel option
    }
  },

  // ── Overridable: Content (email text overrides) ───────────────────
  "content_overrides": {
    "subject": "Custom subject for {{item_name}}",  // Override email subject line
    "preheader": "You have a new share",             // Override email preheader text
    "body_sections": {                               // Override specific text sections in the email body
      "headline": "A colleague shared something",
      "cta_label": "View Now"
    }
  },

  // ── Metadata ──────────────────────────────────────────────────────
  "metadata": {
    "created_by": "admin@example.com", // Who created this override
    "created_at": "2026-04-10T00:00:00Z",
    "updated_at": null,
    "reason": "Domain requires BCC on all share notifications"  // Audit trail
  }
}
```

### Design principles

- **Sparse documents** -- an override only contains the fields being customized; missing fields fall through to the base rule
- **Shallow merge** -- override fields replace base rule fields at the top level of each sub-object (e.g., `delivery_strategy.email.bcc_support: true` overrides just that flag, other `email` fields come from the base rule)
- **Scoping hierarchy** -- a scope can be domain-only, user-only, or domain+user; the resolver picks the most specific match
- **No override for identity fields** -- `name`, `version`, `status`, `trigger`, `category` are NOT overridable; they define the rule itself
- **Content overrides are text only** -- MJML layout and structure remain framework-controlled; overrides only affect string shells (subject, preheader, section text, CTA labels)

### Resolution order (NotificationRuleResolver)

```
1. User + Domain override    (scope.user_id = U, scope.domain_id = D)
2. Domain override           (scope.domain_id = D, scope.user_id = null)
3. User override             (scope.user_id = U, scope.domain_id = null)
4. Global base rule          (NotificationRule document)
5. ALERT_CONFIG fallback     (legacy, until Phase 10 retirement)
```

The resolver performs a shallow merge at each level: start with the base rule, layer domain override on top, then layer user override on top. Most specific wins per field.

### Overridable fields reference

| Category | Fields | Phase |
|---|---|---|
| Delivery strategy | `delivery_strategy.channels`, `.priority`, `.actor_suppression` | Phase 1+ |
| Email channel options | Any field in `delivery_strategy.email` (`send_from`, `send_one`, `bcc_support`, `no_to`, `bcc_mode`, `from_support`, `account`) | Phase 1+ |
| In-app channel options | Any field in `delivery_strategy.in_app` (`skip_toast`) | Phase 1+ |
| Delivery guards | `delivery_strategy.guards.throttling`, `.deduplication`, `.delivery_window` | Phase 8 |
| Email content | `content_overrides.subject`, `.preheader`, `.body_sections.*`, `.cta_label` | Phase 7 |
| Non-email content | In-app text, push text, Slack/Teams message overrides | Phase 9 |

### Indexes

```javascript
// Primary lookup: find overrides for a rule + scope
db.notification_rule_overrides.createIndex(
  { rule_name: 1, "scope.domain_id": 1, "scope.user_id": 1 },
  { unique: true }
)

// Find all overrides for a domain (admin UI listing)
db.notification_rule_overrides.createIndex(
  { "scope.domain_id": 1 }
)
```

### Phase alignment

- **Phase 1**: Collection created, schema defined; no overrides seeded (global rules only)
- **Phase 3**: REST API exposes CRUD for overrides (domain admin creates/edits)
- **Phase 5**: Admin UI surfaces overrides per rule with domain/user scope selector
- **Phase 7**: `content_overrides` fields become active for email (subject, preheader, body sections, CTA)
- **Phase 9**: Content overrides extended to non-email channels

---

## Schema by Rule Type

### Immediate Rule (from ALERT_CONFIG, ~280 kinds with email)

- `trigger.event_name` = alert kind name
- `delivery_strategy.channels` = `["email", "in_app"]`
- `delivery_strategy.batching.aggregation_type` = `"disabled"`
- `delivery_strategy.priority` mapped from legacy:
  - `:info` + `urgent: true` -> `"urgent"`
  - `:warning` -> `"actionable"`
  - `:info` (default) -> `"informational"`
- Semantic builder looked up from Content Registry by `name`
- `delivery_strategy.skip_toast` from ALERT_CONFIG `:options[:skip_toast]`
- `delivery_strategy.email` populated from ALERT_CONFIG `:options` + call-site opts (send_from, send_one, bcc_support, no_to, bcc_mode)
- `metadata.source` = `"ALERT_CONFIG"`
- `metadata.legacy_email_type` = `"alert"`

### Digest Rule (single rule for batched email delivery)

One rule governs the digest email assembly. In the legacy system `EmailCommands.send_alerts` collects unsent alerts across multiple kinds and assembles them into a single `:alerts` email per user per batch window. The ~12 kinds with `group_email: true` in ALERT_CONFIG are listed in this rule's `eligible_alert_kinds`. The per-kind rules for those kinds are normal per-kind rules -- they do NOT carry a `group_email` flag. The routing layer checks the digest rule's `eligible_alert_kinds` to decide whether to suppress immediate email and defer to the digest batch.

```json
{
  "name": "digest",
  "version": 1,
  "status": "active",
  "category": "digest",
  "description": "Batches unsent alerts into a single periodic digest email per user",

  "trigger": {
    "event_name": "digest",
    "source_system": "nutella-api"
  },

  "delivery_strategy": {
    "channels": ["email"],
    "priority": "informational",
    "batching": {
      "aggregation_type": "time_based",
      "time_window": "1d",
      "min_count": 1
    },
    "actor_suppression": false,
    "guards": {
      "throttling": { "enabled": false, "max_per_window": null, "window": null },
      "deduplication": { "enabled": false, "key": null, "window": null },
      "delivery_window": { "enabled": false, "start_hour": null, "end_hour": null, "timezone_source": "recipient" }
    }
  },

  "eligible_alert_kinds": [
    "share_item", "share_spot", "feedback_item", "feedback_spot",
    "item_expiring", "item_expired", "respot", "spot_access_granted",
    "spot_access_revoked", "group_access_granted", "group_access_revoked",
    "request_access_spot"
  ],

  "metadata": {
    "created_by": "system",
    "created_at": "2026-04-08T00:00:00Z",
    "source": "ALERT_CONFIG",
    "legacy_email_type": "alerts"
  }
}
```

**Routing logic:** When a notification is created for a kind, the routing layer checks: is this kind in the digest rule's `eligible_alert_kinds`? If yes, suppress immediate email and mark the alert as `sent: false` for the digest batch job to pick up. If no, send email immediately per the per-kind rule.

### In-App Only Rule (from ALERT_CONFIG, ~23 kinds with `no_email: true`)

Same as immediate except:
- `delivery_strategy.channels` = `["in_app"]`
- No semantic builder in Content Registry (no email rendering)
- `delivery_strategy.email` = absent (no email channel)
- `metadata.legacy_email_type` = `null`

### Direct Email Rule (from EmailCommands::SETTINGS, ~65 types)

- `trigger.event_name` = email type name
- `delivery_strategy.channels` = `["email"]`
- `delivery_strategy.batching.aggregation_type` = `"disabled"`
- `delivery_strategy.priority` = `"informational"` (default)
- Semantic builder looked up from Content Registry by `name`
- `delivery_strategy.email.account` = from SETTINGS `:account` flag
- `delivery_strategy.email.from_support` = from call-site (e.g., `user_email_updated`)
- `metadata.source` = `"EMAIL_SETTINGS"`
- `metadata.legacy_email_type` = email type name
- `metadata.legacy_base_template` = from SETTINGS `:base_template` (migration tracking)

---

## Complete Legacy-to-Rule Seeding Mapping

This table is the single reference for seeding. Every legacy routing and delivery decision is mapped to a rule field. If a legacy field affects how a notification is routed or delivered, it must appear here.

### Identity and classification

| Legacy source | Legacy field | Rule field | Mapping logic | Count |
|---|---|---|---|---|
| ALERT_CONFIG | hash key (e.g., `:share_item`) | `name` | `.to_s` | all ~306 |
| ALERT_CONFIG | hash key | `trigger.event_name` | `.to_s` (same as name) | all ~306 |
| ALERT_CONFIG | `:category` | `category` | `.to_s` | all ~306 |
| EMAIL_SETTINGS | hash key (e.g., `:signup`) | `name`, `trigger.event_name` | `.to_s` | all ~65 |

### Priority

| Legacy source | Legacy field | Rule field | Mapping logic | Count |
|---|---|---|---|---|
| ALERT_CONFIG | `:level => :info` + `:options[:urgent] => true` | `delivery_strategy.priority` | `"urgent"` | ~23 |
| ALERT_CONFIG | `:level => :warning` | `delivery_strategy.priority` | `"actionable"` | varies |
| ALERT_CONFIG | `:level => :info` (default) | `delivery_strategy.priority` | `"informational"` | majority |
| EMAIL_SETTINGS | (none) | `delivery_strategy.priority` | `"informational"` (default) | all ~65 |

### Channels and routing

| Legacy source | Legacy field | Rule field | Mapping logic | Count |
|---|---|---|---|---|
| ALERT_CONFIG | `:options[:no_email] => true` | `delivery_strategy.channels` | `["in_app"]` only | ~23 |
| ALERT_CONFIG | `:options[:push_notification] => true` | `delivery_strategy.channels` | add `"push"` to channels | ~2 |
| ALERT_CONFIG | (default, no `:no_email`) | `delivery_strategy.channels` | `["email", "in_app"]` | ~280 |
| ALERT_CONFIG | `:options[:send_immediately] => true` | `delivery_strategy.batching.aggregation_type` | `"disabled"` (on per-kind rule) | ~145 |
| ALERT_CONFIG | `:options[:group_email] => true` | `digest` rule's `eligible_alert_kinds` | kind added to single digest rule's list; per-kind rule unchanged (no `group_email` flag) | ~12 |
| SLACK_ALERT_KINDS | kind in set | `delivery_strategy.channels` | add `"slack"` | varies |
| MS_TEAMS_ALERT_KINDS | kind in set | `delivery_strategy.channels` | add `"ms_teams"` | varies |
| EMAIL_SETTINGS | (all types) | `delivery_strategy.channels` | `["email"]` | all ~65 |
| EMAIL_SETTINGS | (all types) | `delivery_strategy.batching.aggregation_type` | `"disabled"` | all ~65 |

### In-app channel options (in `delivery_strategy`)

| Legacy source | Legacy field | Rule field | Mapping logic | Count |
|---|---|---|---|---|
| ALERT_CONFIG | `:options[:skip_toast] => true` | `delivery_strategy.in_app.skip_toast` | direct | ~6 |

### Email channel options (`delivery_strategy.email`)

| Legacy source | Legacy field | Rule field | Mapping logic | Count |
|---|---|---|---|---|
| ALERT_CONFIG | `:options[:send_from] => true` | `delivery_strategy.email.send_from` | direct | ~13 |
| Call-site | `send_one: true` | `delivery_strategy.email.send_one` | direct | ~25 |
| Call-site | `bcc_support: true` | `delivery_strategy.email.bcc_support` | direct | 2 (`support_request`, `company_spot_owner_unreachable`) |
| Call-site | `no_to: true` | `delivery_strategy.email.no_to` | direct | 2 (`cloudservice_pitch_receive_failed`, `..._final`) |
| Call-site | explicit `opts[:bcc] = [...]` | `delivery_strategy.email.bcc_mode` | `"explicit"` | 2 (same cloudservice kinds) |
| Call-site | `from_support: true` | `delivery_strategy.email.from_support` | direct | 1 (`user_email_updated`, direct type) |
| EMAIL_SETTINGS | `:account => true` | `delivery_strategy.email.account` | direct | varies |
| EMAIL_SETTINGS | `:async[:multi] => true` | `delivery_strategy.email.send_one` | direct (multi = send_one semantics) | varies |

### Content (stays in builder code / overrides collection)

| Legacy source | Legacy field | Rule field | Mapping logic | Count |
|---|---|---|---|---|
| ALERT_CONFIG | `:subject` present | not on base rule | stays in builder code; overridable via `notification_rule_overrides.content_overrides.subject` | ~188 |
| ALERT_CONFIG | `:action` present | not on base rule | stays in builder code; overridable via `notification_rule_overrides.content_overrides.body_sections.cta_label` | ~213 |
| ALERT_CONFIG | `:variations` present | `metadata.has_variations` | `true` / `false` | ~77 |
| EMAIL_SETTINGS | `:async[:base_template]` | `metadata.legacy_base_template` | string (migration tracking) | varies |

### Metadata (auto-populated during seed)

| Rule field | Value | Notes |
|---|---|---|
| `version` | `1` | All seeded rules start at version 1 |
| `status` | `"active"` | All seeded rules are active |
| `type` | `"immediate"` / `"digest"` / `"direct"` | Rule type for filtering |
| `created_by` | `"system"` | Seeded by automation (top-level field) |
| `created_at` | current timestamp | Seed time (top-level field) |
| `metadata.source` | `"ALERT_CONFIG"` or `"EMAIL_SETTINGS"` | Which legacy source |
| `metadata.legacy_email_type` | `"alert"`, `"alerts"`, type name, or `null` | For migration tracking |
| `metadata.has_variations` | `true` / `false` | Whether ALERT_CONFIG has :variations |
| `metadata.legacy_base_template` | template name or `null` | From EMAIL_SETTINGS (direct emails only) |
| `delivery_strategy.email.renderer` | `"semantic"` | All rules use semantic pipeline |
| `delivery_strategy.email.builder` | rule name | Semantic builder from Content Registry |
| `delivery_strategy.actor_suppression` | `false` | Default; populated in Phase 8 |
| `delivery_strategy.guards.throttling` | `{ enabled: false, max_per_window: null, window: null }` | Disabled by default; configured in Phase 8 |
| `delivery_strategy.guards.deduplication` | `{ enabled: false, key: null, window: null }` | Disabled by default; configured in Phase 8 |
| `delivery_strategy.guards.delivery_window` | `{ enabled: false, start_hour: null, end_hour: null, timezone_source: "recipient" }` | Disabled by default; configured in Phase 8 |
| `delivery_strategy.batching.time_window` | `null` | Only set on the digest rule (`"1d"`) |
| `delivery_strategy.batching.min_count` | `null` | Only set on the digest rule (`1`) |

---

## Seeding

### Seed sources

- **ALERT_CONFIG** (~306 kinds): category, level/urgent -> priority, options -> channels/email_delivery, behavioral flags
- **EmailCommands::SETTINGS** (~65 types): account, multi, base_template
- **Slack/Teams kind sets**: `SLACK_ALERT_KINDS`, `MS_TEAMS_ALERT_KINDS` -> seeded independently (sets differ)
- **Call-site code**: hardcoded opts from `alert_commands.rb` call sites (send_one, bcc_support, no_to, from_support)

The script parses directly from source code (`ALERT_CONFIG`) -- no intermediate JSON files required. JSON files are optional and can be generated for debugging/auditing with `--save-json`.

### Seed behavior

- Re-runnable: filters out keys that already exist before inserting
- `effective send_immediately` extracted from top level or under `:options`
- Content keys embedded in `:options` are not duplicated into the rule document (keep merging from legacy until Phase 10 slimming)
- Short TTL in-memory cache on resolver reads

### Database migration (required pattern)

Seeding uses the standard database migration pattern. All three files must be created:

**1. Migration file:** `web/db/migrate/<jira>_seed_notification_rules.rb`

```ruby
class DatabaseMigration
  def self.change
    collection = DatabaseCommands.get_collection(Constants::NOTIFICATION_RULES_COLLECTION)

    docs = build_all_rules # builds array of rule documents from ALERT_CONFIG + EMAIL_SETTINGS

    existing_names = collection.find({}, projection: { name: 1 }).map { |d| d["name"] }
    new_docs = docs.reject { |d| existing_names.include?(d["name"]) }

    collection.insert_many(new_docs, ordered: false) if new_docs.any?
  end
end
```

Key requirements:
- Use `DatabaseCommands.get_collection(Constants::NOTIFICATION_RULES_COLLECTION)` to get the collection
- Use `insert_many(docs, ordered: false)` for a single bulk insert
- Filter out documents with keys that already exist -- don't rely only on rake task admin-log idempotency
- Re-runnable: second run inserts zero documents

**2. Integration spec:** `web/db/spec/integration/migrate/<jira>_seed_notification_rules_spec.rb`

```ruby
describe "seed notification_rules" do
  it "inserts all rules on first run" do
    DatabaseMigration.change
    count = collection.count_documents({})
    expect(count).to eq(expected_total) # ~306 alert + 1 digest + ~65 direct
  end

  it "is idempotent on second run" do
    DatabaseMigration.change
    DatabaseMigration.change
    count = collection.count_documents({})
    expect(count).to eq(expected_total)
  end
end
```

**3. Deployment script:** append to `web/tools/scripts/deployment/apply_data_migration.sh`

```bash
ruby web/db/migrate/<jira>_seed_notification_rules.rb
```

### Verification

```ruby
collection = DatabaseCommands.get_collection(Constants::NOTIFICATION_RULES_COLLECTION)
collection.count_documents({})
collection.find({ "delivery_strategy.channels" => ["in_app"] }).count
collection.find({ "delivery_strategy.batching.aggregation_type" => "time_based" }).count
```

### Troubleshooting

- **"Database connection not available":** run from `nutella/web`; ensure app environment is loaded
- **"Collection not found":** collection is created automatically on first insert; check MongoDB connection

---

## Implementation

### 1. Create rule builder modules

- `CALL_SITE_EMAIL_OPTS` constant -- maps alert kinds to their call-site email options
- `PRIORITY_MAP` for legacy level/urgent -> tech spec priority enum
- `build_immediate_rule(kind, config)` -- produces the unified schema shape
- `build_digest_rule` -- produces one single digest rule with `eligible_alert_kinds` listing all legacy `group_email: true` kinds
- `build_in_app_rule(kind, config)` -- for kinds with `:no_email`, channels = `["in_app"]`, no `email` sub-object
- `build_direct_email_rule(type, settings)` -- produces direct email rules from EMAIL_SETTINGS

### 2. Create database migration

- `web/db/migrate/<jira>_seed_notification_rules.rb` -- calls rule builders, does `insert_many` with existing-key filter
- `web/db/spec/integration/migrate/<jira>_seed_notification_rules_spec.rb` -- count + idempotency assertions
- Append to `web/tools/scripts/deployment/apply_data_migration.sh`

---

## PR Sync Analysis (PR #69976)

This section documents the discrepancies between this plan and the current PR implementation, and the changes needed on both sides to align them before the seeding PR.

### Current PR Files

- `map_alert_config_to_rules.rb` -- parses ALERT_CONFIG, builds immediate/digest rules
- `map_email_settings_to_templates.rb` -- parses EMAIL_SETTINGS, builds direct email rules
- `web/tasks/seed_notification_rules.rake` -- rake task to seed the collection

### Discrepancy Summary

| Field | Plan | PR Code | Decision |
|-------|------|---------|----------|
| `type` | Not present | `"immediate"` / `"digest"` / `"direct"` | **Keep in PR** -- useful for filtering/querying; add to plan |
| `trigger` | `{ event_name, source_system }` | Not present | **Add to PR** -- needed for multi-system routing |
| `priority` | String enum: `"informational"`, `"actionable"`, `"urgent"`, `"critical"` | Integer: `1` or `2` | **Change PR** -- use string enums per tech spec |
| `created_at` | Under `metadata.created_at` | Top-level | **Keep top-level** -- MongoDB convention; update plan |
| `created_by` | Under `metadata.created_by` | Top-level | **Keep top-level** -- MongoDB convention; update plan |
| `metadata` | `{ source, legacy_email_type, has_variations, legacy_base_template }` | Not present | **Add to PR** -- needed for migration tracking |
| `delivery_strategy.email` | `{ send_from, send_one, bcc_support, no_to, bcc_mode, from_support, account }` | `{ renderer, builder, multi, account }` | **Merge both** -- keep renderer/builder AND add delivery flags |
| `delivery_strategy.in_app` | `{ skip_toast }` | Not present | **Add to PR** -- seed from ALERT_CONFIG `:options[:skip_toast]` |
| `delivery_strategy.actor_suppression` | Present, default `false` | Not present | **Add to PR** -- seed as `false` |
| `delivery_strategy.guards` | `{ throttling, deduplication, delivery_window }` | Not present | **Add to PR** -- seed all as `{ enabled: false, ... }` |
| `delivery_strategy.send_from` | Under `email` sub-object | Top-level in `delivery_strategy` | **Move to `email`** in PR |
| `eligible_alert_kinds` (digest) | Only kinds with `group_email: true` (~12) | All non-no_email kinds (~291) | **Change PR** -- should only include `group_email: true` kinds |

---

### Changes Needed in PR Code

#### 1. `map_alert_config_to_rules.rb`

**Add `trigger` block:**
```ruby
"trigger" => {
  "event_name" => alert_key,
  "source_system" => "nutella-api"
}
```

**Change `priority` to string enum:**
```ruby
# Replace:
priority = level == "warning" ? 2 : 1

# With:
PRIORITY_MAP = {
  "warning" => "actionable",
  "info" => "informational"
}.freeze

priority = PRIORITY_MAP[level] || "informational"
# Note: "urgent" requires checking options[:urgent] when level == "info"
```

**Add `metadata` block:**
```ruby
"metadata" => {
  "source" => "ALERT_CONFIG",
  "legacy_email_type" => options[:no_email] ? nil : "alert",
  "has_variations" => alert_config[:has_variations]
}
```

**Restructure `delivery_strategy.email`:**
```ruby
# Keep renderer/builder, add delivery flags:
"email" => {
  "renderer" => "semantic",
  "builder" => alert_key,
  "send_from" => options[:send_from] || false,
  "send_one" => false,  # populated from call-site opts in seeding PR
  "bcc_support" => false,
  "no_to" => false,
  "bcc_mode" => nil,
  "from_support" => false,
  "account" => false
}
```

**Add `delivery_strategy.in_app`:**
```ruby
"in_app" => {
  "skip_toast" => options[:skip_toast] || false
}
```

**Add `delivery_strategy.actor_suppression`:**
```ruby
"actor_suppression" => false
```

**Add `delivery_strategy.guards`:**
```ruby
"guards" => {
  "throttling" => { "enabled" => false, "max_per_window" => nil, "window" => nil },
  "deduplication" => { "enabled" => false, "key" => nil, "window" => nil },
  "delivery_window" => { "enabled" => false, "start_hour" => nil, "end_hour" => nil, "timezone_source" => "recipient" }
}
```

**Fix `build_digest_rule` eligible_alert_kinds:**
```ruby
# Replace:
eligible_kinds = alert_configs.reject { |_k, v| v[:options][:no_email] }.keys

# With:
eligible_kinds = alert_configs.select { |_k, v| v[:options][:group_email] }.keys
```

#### 2. `map_email_settings_to_templates.rb`

**Add `trigger` block** (same as above)

**Add `metadata` block:**
```ruby
"metadata" => {
  "source" => "EMAIL_SETTINGS",
  "legacy_email_type" => email_type,
  "legacy_base_template" => async["base_template"]
}
```

**Restructure `delivery_strategy.email`** to include all flags.

#### 3. `seed_notification_rules.rake`

**Move `created_at`/`created_by` handling** -- already at top level, which is correct. Plan will be updated.

---

### Changes Needed in Plan

#### 1. Add `type` field to schema

Add to Identity section:
```jsonc
"type": "immediate",  // "immediate" | "digest" | "direct" -- rule type for filtering
```

#### 2. Move `created_at`/`created_by` to top level

Change from `metadata.created_at` / `metadata.created_by` to top-level fields:
```jsonc
"created_at": "2026-04-08T00:00:00Z",
"created_by": "system",
```

Update metadata to only contain migration-tracking fields:
```jsonc
"metadata": {
  "source": "ALERT_CONFIG",
  "legacy_email_type": "alert",
  "has_variations": false,
  "legacy_base_template": null
}
```

#### 3. Add `renderer`/`builder` to email sub-object

The plan's `delivery_strategy.email` should include:
```jsonc
"email": {
  "renderer": "semantic",      // "semantic" | "legacy" (legacy for migration only)
  "builder": "share_item",     // Semantic builder name from Content Registry
  "send_from": true,
  "send_one": false,
  // ... other flags
}
```

#### 4. Update seeding mapping table

Add rows for:
- `type` field mapping
- `renderer`/`builder` fields
- `created_at`/`created_by` at top level

---

### Recommended Execution Order

1. **PR #69976** (current): Merge as-is to create collection and basic structure
2. **Sync PR**: Update mapping scripts to produce plan-aligned schema (changes above)
3. **Seeding PR**: Run migration to seed all ~381 rules with full schema

This allows the collection to exist and be tested before the full seeding migration runs.

---

## Files to Create / Modify

- `web/db/migrate/<jira>_seed_notification_rules.rb` -- database migration (new)
- `web/db/spec/integration/migrate/<jira>_seed_notification_rules_spec.rb` -- integration spec (new)
- `web/tools/scripts/deployment/apply_data_migration.sh` -- append migration line (modify)
