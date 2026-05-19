---
name: "Phase 5: Admin UI (Magma Entities Page)"
overview: "Enhance the existing Magma admin entities page for notification rules browsing. Collections already registered; this phase adds richer filtering, cross-collection navigation, and optionally edit capabilities."
isProject: false
phase: 5
status: in_progress
prs:
  - highspot/magma#8831
  - highspot/magma#8894
---

# Phase 5: Admin UI -- Magma Entities Page

> Implementation detail for **Phase 5 / Step 1** of [Notification Rules Master Plan](../../Codebase/cursor-worklog/unified_notifications/notification_rules_master_plan.plan.md). The master plan owns release criteria and sequencing; this document owns the field-level magma changes and verified syntax against `magma/api/src/main/clojure/api/controllers/entities.clj`.

## Current State

The Magma entities page (`/entities`) is a server-rendered (Hiccup) read-only entity browser in `api/controllers/entities.clj`. Both collections are already registered:

```clojure
"notification_rules"
{:find ["_id" "name" "version" "status" "type" "category" "created_at" "updated_at"]
 :dates #{"created_at" "updated_at"}
 :links {}
 :relations {}}

"notification_rule_overrides"
{:find ["_id" "rule_name" "scope.domain_id" "scope.user_id" "created_at" "updated_at"]
 :dates #{"created_at" "updated_at"}
 :links {"scope.domain_id" "domains" "scope.user_id" "users"}
 :relations {}}
```

**Access:** `backend_engineer` role (and other operator roles with `:entities` right) via `wrap-authorize-operator` with `operators/right-entities`.

**Capabilities:** List collections with counts, browse documents with simple (per-field) and advanced (EDN Mongo filter) query modes, view individual documents as JSON, async download of query results.

## What Phase 5 Adds

### 1. Richer `:find` fields for notification_rules

Add filterable fields that operators commonly need:

```clojure
"notification_rules"
{:find ["_id" "name" "version" "status" "type" "category"
        "delivery_strategy.channels" "delivery_strategy.priority"
        "created_at" "updated_at"]
 :dates #{"created_at" "updated_at"}
 :links {}
 :relations {"notification_rule_overrides" {"name" "rule_name"}}}
```

Notes on field choices, verified against the seeded schema (`web/db/migrate/180217_seed_notification_rules.rb`):

- `trigger.event_name` is intentionally omitted -- for every seeded rule it equals `name`, so it adds no filtering signal.
- `updated_at` will render blank for all currently seeded docs because the seed migration sets only `created_at`. The column is forward-looking: it will populate once the Phase 3 REST API or any admin write path starts updating rules.
- `delivery_strategy.channels` is an array; expect to use the advanced (EDN) query mode for set-membership filters like `{:delivery_strategy.channels "push"}`.

`:relations` syntax verified against `entity-relation` in `entities.clj` (line ~1531). The map form `{"source_field_on_current_entity" "target_field_on_relation"}` builds a URL like `/entities/notification_rule_overrides?rule_name=<rule.name>`.

### 2. Cross-collection `:links` and `:relations`

- **notification_rules -> overrides:** Add `:relations` so viewing a rule shows a link to its overrides (filtered by `rule_name`). Implemented in section 1 above.
- **notification_rule_overrides -> domain/user:** Already has `:links` for `scope.domain_id` and `scope.user_id`.
- **notification_rule_overrides -> rule (deferred):** A direct `:link` from `rule_name` to `notification_rules` is **not supported** by the existing `entity-link` -> `entity-simple-link` path (line ~1510 of `entities.clj`), which always builds `/entities/<collection>/<value>` and looks up the target by `_id`. Since `notification_rules._id` is an `ObjectId`, not the rule's `name`, such a link would 404. See "Risks and Mitigations" for follow-up options.

```clojure
"notification_rule_overrides"
{:find ["_id" "rule_name" "scope.domain_id" "scope.user_id"
        "delivery_strategy.channels" "delivery_strategy.priority"
        "created_at" "updated_at"]
 :dates #{"created_at" "updated_at"}
 :links {"scope.domain_id" "domains" "scope.user_id" "users"}
 :relations {}}
```

Operators can manually navigate from an override row to its rule by typing `name=<rule_name>` into the `notification_rules` form-query view.

### 3. Edit capability (optional)

The entities page is currently read-only (GET routes only). If admin rule editing is needed:
- Add `POST /entities/:collection/:entity_id` route for updates
- Requires additional authorization check
- JSON body with field updates
- Audit log via `AuditEvents.audit`

This is optional for Phase 5 -- operators can use the Phase 3 REST API or direct MongoDB access for mutations.

## Files to Modify

### `magma/api/src/main/clojure/api/controllers/entities.clj`

Update the `collections` map entries for both `notification_rules` and `notification_rule_overrides` with enhanced `:find`, `:links`, and `:relations`.

## Spec Files

- Manual testing via the entities page in staging (server-rendered HTML, no unit test framework for Hiccup views)
- Verify: browsing, filtering by new fields, cross-collection navigation

## Cross-Phase Dependencies

- **Phase 1 (prerequisite):** Collections exist and are seeded.
- **Phase 3 (independent):** REST API provides programmatic access; entities page is for operator browsing. Neither depends on the other. Once Phase 3 lands, `updated_at` will start populating in this view.
- **Master plan:** [Notification Rules Master Plan -> Phase 5 / Step 1](../../Codebase/cursor-worklog/unified_notifications/notification_rules_master_plan.plan.md). Keep both documents in sync when fields or relations change.

## Risks and Mitigations

- **Risk:** Nested-array field queries (e.g., `delivery_strategy.channels`) may not match in simple query mode. **Mitigation:** `entity-search-form` builds equality matchers, so `delivery_strategy.channels=push` will match documents whose array contains `"push"` via Mongo's array-element semantics. If operators need richer set predicates (e.g., `$all`), use advanced mode with raw EDN.
- **Risk (deferred):** Direct navigation from `notification_rule_overrides.rule_name` to the parent rule via `:links`. **Cause:** `entity-simple-link` (entities.clj ~line 1510) routes to `/entities/<collection>/<value>` and the document lookup is by `_id`. Because `notification_rules._id` is an ObjectId (not the rule name), a `:links {"rule_name" "notification_rules"}` entry would render but 404 on click. **Mitigation options:** (1) For now, rely on the manual `name=<rule_name>` form-query workflow noted in section 2. (2) If we want first-class navigation, follow up with a small Magma change -- either extend `entity-simple-link` to accept a target-field hint, or add a thin `:relations`-style hop (`{"notification_rules" {"rule_name" "name"}}`) that builds a list URL like `/entities/notification_rules?name=<value>`. This is intentionally out of scope for the initial Phase 5 / Step 1 ship.
- **Risk:** Empty `updated_at` column confuses operators on existing rows. **Mitigation:** Document in the rollout note that `updated_at` is forward-looking until any write path (Phase 3 API, override editor, backfill) starts updating rules.
