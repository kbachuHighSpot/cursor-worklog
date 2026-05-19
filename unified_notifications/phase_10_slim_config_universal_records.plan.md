---
name: "Phase 10: Slim Legacy Config and Universal Notification Records"
overview: "Remove legacy ALERT_CONFIG/SETTINGS duplication by having runtime read from rules. Ensure every notification (including direct emails) creates a notification record in MongoDB for audit, analytics, and troubleshooting."
isProject: false
phase: 10
status: not_started
---

# Phase 10: Slim Legacy Config and Universal Notification Records

## Part A: Slim Legacy Config

### Motivation

After Phase 2, the legacy `AlertCommands::ALERT_CONFIG` and `EmailCommands::SETTINGS` hashes are still present in code. When the `notification_rules_enabled` feature flag is on, behavior is driven by rules. This phase removes the duplication so that eventually:
- `ALERT_CONFIG` entries map to rule names (thin config)
- Runtime behavior (channels, priority, templates) comes from rules, not hardcoded hashes

### Approach

This is NOT a big-bang deletion. Instead:

1. **Thin `ALERT_CONFIG` to a mapping table.** Each entry retains only `kind => rule_name` mapping. All behavioral config (channels, priority, level, urgent) is read from the rule at runtime.

2. **Thin `SETTINGS` for non-account email types.** Non-account email types (e.g., `share`, `share_link`) that have corresponding rules stop reading from `SETTINGS` when the flag is on. Account types (`:password_recovery`, `:welcome`, `:new_user`) remain unchanged.

3. **Feature flag guards.** The thinning is behind `notification_rules_enabled`. Legacy path still reads `ALERT_CONFIG`/`SETTINGS` as before.

### Files to Modify

#### 1. `web/common/models/commands/alert_commands.rb`

```ruby
def self.create(domain_id, user_id, attributes, ts)
  if Hspt::Features::Manager.enabled_for_domain?(domain_id, "notification_rules_enabled")
    return NotificationEngine.notify(
      attributes[:kind], domain_id, user_id, attributes, {}
    )
  end

  # Legacy path -- unchanged
  config = ALERT_CONFIG[attributes[:kind]]
  # ... existing legacy code
end
```

No changes to `ALERT_CONFIG` itself in Phase 10 -- it stays as the fallback. But the rules-first path completely ignores it.

#### 2. `web/common/email/email_commands.rb`

For direct emails, Phase 2 already added rule gating. Phase 10 ensures that when the rule path is active, template selection comes from the rule (or content override) rather than `SETTINGS`:

```ruby
def self.send_email(type, to, from, data = {}, referenced = {}, opts = {})
  # ... existing global disable check ...
  # ... existing Phase 2 rule gating for non-alert types ...

  if Hspt::Features::Manager.enabled_for_domain?(domain_id, "notification_rules_enabled")
    rule = NotificationRuleResolver.resolve(type.to_s, domain_id, to_user&.id)
    if rule
      # Use rule-driven template selection
      template_key = rule.delivery_strategy&.dig("email_template") || type.to_s
      # Use content overrides if present
      # ... build email from rule config, not SETTINGS ...
    end
  end

  # Legacy path uses SETTINGS as before
  settings = SETTINGS[type]
  # ...
end
```

### Deprecation Path

After all domains have `notification_rules_enabled` on for a full release cycle:
1. Log warnings when legacy `ALERT_CONFIG` entries are accessed
2. Remove `ALERT_CONFIG` entries that have corresponding rules
3. Remove `SETTINGS` entries for non-account types

## Part B: Universal Notification Records

### Motivation

Currently, only alert-type notifications create a record in the `Alert` collection. Direct emails (`EmailCommands.send_email`) don't create any persistent record. This makes it impossible to audit what notifications were sent, troubleshoot delivery issues, or build a unified notification history.

### Approach

When `notification_rules_enabled` is on, every notification -- whether alert, digest, or direct email -- creates a record in a new or existing collection.

### Design Decision: Reuse `Alert` collection vs. new `notifications` collection

**Recommendation:** Reuse the `Alert` collection with an extended schema. Reasons:
- The `Alert` entity already has `kind`, `domain_id`, `user_id`, `created_at`, `sent`, `channels_delivered` (from Phase 2).
- Direct emails simply create an alert document with `type: "direct_email"` and `channels_delivered: ["email"]`.
- Avoids a second collection and double queries for notification history.

### Schema Extension

```json
{
  "_id": "ObjectId",
  "kind": "password_recovery",
  "type": "direct_email",
  "domain_id": "domain123",
  "user_id": "user456",
  "notification_rule_name": "password_recovery",
  "notification_priority": "critical",
  "channels_delivered": ["email"],
  "metadata": {
    "email_type": "password_recovery",
    "template_used": "password_recovery_html"
  },
  "created_at": "2026-04-25T00:00:00Z",
  "sent": true
}
```

### Files to Modify

#### 1. `web/common/email/email_commands.rb`

After sending a direct email (when rules are enabled), create an alert record:

```ruby
def self.send_email(type, to, from, data = {}, referenced = {}, opts = {})
  # ... existing logic ...

  # After successful send, create notification record
  if Hspt::Features::Manager.enabled_for_domain?(domain_id, "notification_rules_enabled")
    AlertCommands.create_direct_email_record(
      domain_id: domain_id,
      user_id: to_user&.id,
      kind: type.to_s,
      channels_delivered: ["email"],
      metadata: { email_type: type.to_s, template_used: settings[:async][:body_template] }
    )
  end
end
```

#### 2. `web/common/models/commands/alert_commands.rb`

```ruby
def self.create_direct_email_record(domain_id:, user_id:, kind:, channels_delivered:, metadata: {})
  doc = {
    "kind" => kind,
    "type" => "direct_email",
    "domain_id" => domain_id,
    "user_id" => Plucky.to_object_id(user_id),
    "notification_rule_name" => kind,
    "channels_delivered" => channels_delivered,
    "metadata" => metadata,
    "created_at" => Time.now.utc,
    "sent" => true
  }
  collection.insert_one(doc)
end
```

### New Index

```ruby
collection.indexes.create_one(
  { "type" => 1, "domain_id" => 1, "created_at" => -1 },
  { name: "idx_type_domain_created" }
)
```

## Spec Files

### Part A
- Update `web/spec/unit/common/models/commands/alert_commands_spec.rb` -- verify rules-first path ignores ALERT_CONFIG
- Update `web/spec/unit/common/email/email_commands_spec.rb` -- verify rule-driven template selection

### Part B
- `web/spec/unit/common/models/commands/alert_commands_spec.rb` -- test `create_direct_email_record`
- Integration test: send a direct email with rules enabled, verify alert document created

## Cross-Phase Dependencies

- **Phase 2 (prerequisite):** Feature flag gating, `channels_delivered` on Alert entity.
- **Phase 7 (prerequisite):** Content overrides for email template selection.
- **Phase 8 (prerequisite):** Batching windows for digest records.
- **Phase 11 (downstream):** Performance considerations for universal record writes.

## Risks and Mitigations

- **Risk:** Increased write volume to Alert collection from direct emails. **Mitigation:** Direct emails are lower volume than alerts. Monitor collection size. Add TTL index for direct_email records if cleanup is needed.
- **Risk:** Breaking existing Alert queries that don't expect `type: "direct_email"`. **Mitigation:** Existing queries filter by `kind` which is different for direct emails. Add `type` filter to any aggregate queries.
- **Risk:** Removing ALERT_CONFIG too aggressively. **Mitigation:** Phase 10 does NOT remove ALERT_CONFIG. It makes the rules path ignore it. Removal is a follow-up cleanup after full rollout validation.
