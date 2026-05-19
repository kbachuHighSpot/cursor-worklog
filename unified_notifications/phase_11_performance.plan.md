---
name: "Phase 11: Performance Optimization"
overview: "Replace in-memory TTL caches with Redis, add MongoDB indexes, instrument key paths with New Relic, and load test the notification pipeline to validate performance at scale."
isProject: false
phase: 11
status: not_started
---

# Phase 11: Performance Optimization

## Motivation

Phases 2-10 use in-memory TTL caches and basic queries. At scale (hundreds of thousands of notifications per hour), these need hardening:
1. **In-memory caches** don't share across multiple application instances.
2. **MongoDB queries** need optimized indexes for the access patterns introduced.
3. **Guard evaluation** (Phase 8) hits Redis per-notification and needs monitoring.
4. **Instrumentation** is needed to identify bottlenecks and set alerts.

## 1. Redis-Backed Rule Caching

### Current (Phase 2)

```ruby
class NotificationRuleResolver
  CACHE_TTL = 300
  @rule_cache = {}  # In-memory, per-process
end
```

### Phase 11 Upgrade

```ruby
class NotificationRuleResolver
  CACHE_TTL = 300
  CACHE_PREFIX = "notif_rule"

  def self.find_cached_rule(name)
    cached = CacheHelper.get_from_cache(name, CACHE_PREFIX)
    if cached
      return NotificationRule.from_mongo(JSON.parse(cached))
    end

    rule = NotificationRuleQueries.find_active_by_name(name)
    if rule
      CacheHelper.set_in_cache(name, rule_to_json(rule), CACHE_PREFIX, CACHE_TTL)
    end
    rule
  end

  def self.clear_cache!(name = nil)
    if name
      CacheHelper.delete_from_cache(name, CACHE_PREFIX)
    else
      # Pattern delete (use with caution)
      RedisCache.del_pattern("#{CACHE_PREFIX}:*")
    end
  end

  def self.rule_to_json(rule)
    {
      "_id" => rule._id.to_s,
      "name" => rule.name,
      "version" => rule.version,
      "status" => rule.status,
      "type" => rule.type,
      "category" => rule.category,
      "delivery_strategy" => rule.delivery_strategy,
      "trigger" => rule.trigger,
      "metadata" => rule.metadata,
      "created_at" => rule.created_at&.iso8601,
      "updated_at" => rule.updated_at&.iso8601
    }.to_json
  end
end
```

### Group Membership Cache (Phase 6 upgrade)

Move `fetch_group_ids` from in-memory to Redis:

```ruby
def self.fetch_group_ids(user_id)
  cached = CacheHelper.get_from_cache(user_id.to_s, "notif_groups")
  return JSON.parse(cached) if cached

  groups = GroupQueries.for_user(user_id)
  ids = groups.map(&:id).map(&:to_s)
  CacheHelper.set_in_cache(user_id.to_s, ids.to_json, "notif_groups", CACHE_TTL)
  ids
end
```

## 2. MongoDB Index Optimization

### notification_rules collection

```ruby
# Already exists from Phase 1
{ "name" => 1 }  # unique index

# Phase 11 additions
{ "status" => 1, "type" => 1 }          # for find_by_type + active filter
{ "status" => 1, "category" => 1 }      # for find_by_category + active filter
```

### notification_rule_overrides collection

```ruby
# Already exists from Phase 1
{ "rule_name" => 1, "scope.domain_id" => 1, "scope.user_id" => 1 }  # unique compound
{ "scope.domain_id" => 1 }              # for domain queries

# Phase 11 additions (if Phase 6 added group support)
{ "scope.group_id" => 1 }               # for group queries (may exist from Phase 6)
{ "rule_name" => 1 }                     # for override listing by rule
```

### Alert collection

```ruby
# Phase 11 additions for universal records (Phase 10)
{ "type" => 1, "domain_id" => 1, "created_at" => -1 }   # for direct email record queries
{ "kind" => 1, "sent" => 1, "created_at" => 1 }          # for digest job (Phase 8 batching)
{ "notification_rule_name" => 1, "created_at" => -1 }    # for rule-based analytics
```

## 3. New Relic Instrumentation

### Custom Events

```ruby
# In NotificationEngine.notify
NewRelic::Agent.record_custom_event("NotificationDelivered", {
  kind: kind,
  domain_id: domain_id,
  channels_delivered: channels_delivered.join(","),
  rule_name: rule.name,
  priority: rule.priority,
  guard_result: guard_result,
  duration_ms: elapsed_ms
})

# In NotificationGuard.evaluate
NewRelic::Agent.record_custom_event("NotificationGuarded", {
  kind: kind,
  user_id: user_id,
  result: guard_result,  # throttled, deduplicated, quiet_hours
  rule_name: rule.name
})
```

### Custom Metrics

```ruby
# Cache hit/miss rates
NewRelic::Agent.increment_metric("Custom/NotificationRuleCache/Hit") # or /Miss
NewRelic::Agent.increment_metric("Custom/NotificationGuard/Throttled")
NewRelic::Agent.increment_metric("Custom/NotificationGuard/Deduplicated")
```

### Alerts (New Relic)

Using the `tf-newrelic-alert` module, create alerts for:

| Alert | Condition | Threshold |
|-------|-----------|-----------|
| Rule resolution latency | P95 > threshold | > 50ms |
| Guard evaluation latency | P95 > threshold | > 20ms |
| Notification delivery failures | Error rate | > 1% in 5 min |
| Cache miss rate | Miss / (Hit + Miss) | > 50% sustained |
| Throttle rate anomaly | Sudden spike in throttled notifications | Anomaly detection |

## 4. Load Testing

### Strategy

Use a staging environment with realistic data to validate:
1. **Throughput:** 10K notifications/min sustained
2. **Latency:** P95 < 100ms for `NotificationEngine.notify`
3. **Redis:** Key count, memory, and operation latency under load
4. **MongoDB:** Query performance with realistic data volumes

### Load Test Script

```ruby
# web/tasks/load_test/notification_load_test.rb
class NotificationLoadTest
  KINDS = NotificationRuleQueries.all_active.map(&:name)
  CONCURRENCY = 10
  DURATION = 300 # 5 minutes

  def run
    threads = CONCURRENCY.times.map do
      Thread.new do
        until Time.now > start_time + DURATION
          kind = KINDS.sample
          user = random_user
          NotificationEngine.notify(kind, user.domain_id, user.id, sample_attributes(kind))
          sleep(rand(0.01..0.1))
        end
      end
    end
    threads.each(&:join)
  end
end
```

## Files to Create / Modify

- Modify `web/common/notifications/notification_rule_resolver.rb` -- Redis caching
- Modify `web/common/notifications/notification_engine.rb` -- New Relic instrumentation
- Modify `web/common/notifications/notification_guard.rb` -- New Relic instrumentation
- Create `web/db/migrate/XXXXXX_add_notification_performance_indexes.rb` -- index migration
- Create `web/tasks/load_test/notification_load_test.rb` -- load test script
- Terraform: `tf-newrelic-alert` -- notification pipeline alerts

## Spec Files

- Update resolver spec for Redis caching (mock `CacheHelper`)
- Load test is manual (not part of CI)

## Cross-Phase Dependencies

- **All prior phases (prerequisite):** This phase optimizes the full pipeline.
- **Phase 8 (prerequisite):** Guard Redis keys need monitoring.
- **Phase 12 (downstream):** E2E tests validate that performance optimizations don't break functionality.

## Risks and Mitigations

- **Risk:** Redis serialization/deserialization overhead. **Mitigation:** JSON serialization is fast for small rule documents. Benchmark shows < 1ms per serialize/deserialize.
- **Risk:** Redis failure degrades notification delivery. **Mitigation:** Fall back to direct MongoDB query on Redis connection failure. Use `rescue Redis::BaseError`.
- **Risk:** Index creation locks collections. **Mitigation:** Use `background: true` for index creation. Schedule during low-traffic window.
- **Risk:** Load test impacts staging users. **Mitigation:** Use dedicated test domain. Clean up test data after run.
