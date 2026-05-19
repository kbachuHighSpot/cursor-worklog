---
name: "Phase 12: Test Automation (Playwright + Mailinator)"
overview: "End-to-end test suite using Playwright for UI flows and Mailinator for email verification. Validates the full notification pipeline from trigger to delivery across all channels."
isProject: false
phase: 12
status: not_started
notes: "highspot/nutella#70903 delivered compare_email_previews.py (parity harness) — related but not in scope here. This plan is specifically Playwright + Mailinator end-to-end coverage."
---

# Phase 12: Test Automation -- Playwright + Mailinator

## Motivation

Verify the complete notification pipeline end-to-end: trigger a notification via the UI or API, confirm it appears in-app, arrives as an email (via Mailinator), and optionally appears in Slack/Teams.

## Repository

**Repo:** `https://github.com/highspot/test_automation_playwright`
**Local clone:** `/Users/kiran.bachu/Codebase/test_automation_playwright`

### Existing Structure

```
playwright/
  tests/                    # Test files
    e2e/
      smoke/
      content/
      notifications/        # New directory for notification tests
  apiHelpers/               # API helper utilities
  pages/                    # Page object models
  fixtures/                 # Test fixtures and setup
  utils/
    MailinatorClient.ts     # Mailinator API client
    mailinatorInboxes.ts    # Inbox registry and helpers
playwright.config.ts        # Config with projects, timeouts, retries
```

### Existing Patterns

**Mailinator Client (`MailinatorClient.ts`)**
- Uses `mailinator-javascript-client` SDK
- Domain: `highspot.testinator.com`
- Methods: `getInbox(inbox)`, `getMessage(inbox, messageId)`, `getMessageBody(inbox, messageId)`, `deleteMessage(inbox, messageId)`
- API token from env: `process.env.MAILINATOR_API_TOKEN`

**Inbox Registry (`mailinatorInboxes.ts`)**
- Named inboxes for each test scenario
- Pattern: `test-{scenario}-{randomSuffix}@highspot.testinator.com`
- Each test gets a unique inbox via `faker` to avoid collisions

**Test Patterns**
- `test.describe` blocks for logical grouping
- `SignIn.as(page, user)` for authentication
- `expect.poll` for async assertions (polling until condition met)
- Page Object Model pattern for UI interactions
- API helpers for setup/teardown

## Test Scenarios

### 1. Share Item Notification (E2E)

```typescript
test.describe("Notification Rules - Share Item", () => {
  let inbox: string;

  test.beforeAll(async () => {
    inbox = generateUniqueInbox("share-item");
    // Ensure test user's email points to Mailinator inbox
    await apiHelper.updateUserEmail(testUser, `${inbox}@highspot.testinator.com`);
    // Ensure notification_rules_enabled flag is on for test domain
    await apiHelper.enableFeatureFlag(testDomain, "notification_rules_enabled");
  });

  test("share triggers in-app alert and email", async ({ page }) => {
    // Trigger: User A shares an item with User B
    await SignIn.as(page, userA);
    await page.goto(`/items/${testItemId}`);
    await page.click('[data-testid="share-button"]');
    await page.fill('[data-testid="share-recipient"]', userB.email);
    await page.click('[data-testid="send-share"]');

    // Verify: In-app notification appears for User B
    await SignIn.as(page, userB);
    await expect.poll(async () => {
      const badge = page.locator('[data-testid="notification-badge"]');
      return badge.isVisible();
    }, { timeout: 30000, intervals: [2000] }).toBeTruthy();

    // Verify: Email arrives in Mailinator
    const mailinator = new MailinatorClient();
    await expect.poll(async () => {
      const messages = await mailinator.getInbox(inbox);
      return messages.msgs.length;
    }, { timeout: 60000, intervals: [5000] }).toBeGreaterThan(0);

    const messages = await mailinator.getInbox(inbox);
    const latestMessage = messages.msgs[0];
    const body = await mailinator.getMessageBody(inbox, latestMessage.id);
    expect(body).toContain(testItemTitle);
    expect(latestMessage.subject).toContain("shared");

    // Cleanup
    await mailinator.deleteMessage(inbox, latestMessage.id);
  });

  test("disabled rule suppresses notification", async ({ page }) => {
    // Deactivate the share_item rule via API
    await apiHelper.deactivateRule("share_item");

    // Trigger share
    await SignIn.as(page, userA);
    await shareTrigger(page, testItemId, userB);

    // Verify: No in-app notification
    await SignIn.as(page, userB);
    await page.waitForTimeout(10000);
    const badge = page.locator('[data-testid="notification-badge"]');
    await expect(badge).not.toBeVisible();

    // Verify: No email
    const mailinator = new MailinatorClient();
    const messages = await mailinator.getInbox(inbox);
    expect(messages.msgs.length).toBe(0);

    // Restore rule
    await apiHelper.activateRule("share_item");
  });
});
```

### 2. Digest Email Verification

```typescript
test.describe("Notification Rules - Digest Email", () => {
  test("multiple alerts batched into single digest", async ({ page }) => {
    const inbox = generateUniqueInbox("digest");
    await apiHelper.updateUserEmail(testUser, `${inbox}@highspot.testinator.com`);

    // Trigger multiple notifications
    for (let i = 0; i < 3; i++) {
      await apiHelper.triggerNotification("content_added", {
        domain_id: testDomain,
        user_id: testUser.id,
        data: { item_id: `item-${i}` }
      });
    }

    // Wait for digest job to run (configured interval)
    await page.waitForTimeout(90000);

    // Verify single digest email with all 3 items
    const mailinator = new MailinatorClient();
    const messages = await mailinator.getInbox(inbox);
    expect(messages.msgs.length).toBe(1);

    const body = await mailinator.getMessageBody(inbox, messages.msgs[0].id);
    expect(body).toContain("item-0");
    expect(body).toContain("item-1");
    expect(body).toContain("item-2");
  });
});
```

### 3. Content Override Verification

```typescript
test.describe("Notification Rules - Content Overrides", () => {
  test("domain override customizes email subject", async ({ page }) => {
    const inbox = generateUniqueInbox("override");
    const customSubject = "Custom: Content was shared with you";

    // Create domain override with custom subject
    await apiHelper.createRuleOverride("share_item", {
      scope: { domain_id: testDomain },
      content_overrides: {
        email: { subject_template: customSubject }
      }
    });

    // Trigger notification
    await apiHelper.triggerShare(userA, userB, testItemId);

    // Verify custom subject
    const mailinator = new MailinatorClient();
    await expect.poll(async () => {
      const messages = await mailinator.getInbox(inbox);
      return messages.msgs.length;
    }, { timeout: 60000 }).toBeGreaterThan(0);

    const messages = await mailinator.getInbox(inbox);
    expect(messages.msgs[0].subject).toContain("Custom:");

    // Cleanup override
    await apiHelper.deleteRuleOverride("share_item", testDomain);
  });
});
```

### 4. Guard Verification (Throttle)

```typescript
test.describe("Notification Rules - Guards", () => {
  test("throttle suppresses excess notifications", async () => {
    const inbox = generateUniqueInbox("throttle");

    // Configure rule with throttle: max 2 per hour
    await apiHelper.updateRule("share_item", {
      delivery_strategy: {
        guards: { throttle: { max_per_window: 2, window_seconds: 3600 } }
      }
    });

    // Send 3 notifications
    for (let i = 0; i < 3; i++) {
      await apiHelper.triggerShare(userA, userB, `item-${i}`);
    }

    await page.waitForTimeout(15000);

    // Verify only 2 emails received
    const mailinator = new MailinatorClient();
    const messages = await mailinator.getInbox(inbox);
    expect(messages.msgs.length).toBe(2);

    // Cleanup
    await apiHelper.updateRule("share_item", {
      delivery_strategy: { guards: null }
    });
  });
});
```

## API Helper Extensions

```typescript
// playwright/apiHelpers/notificationApiHelper.ts
export class NotificationApiHelper {
  async enableFeatureFlag(domainId: string, flag: string): Promise<void> { /* ... */ }
  async triggerNotification(kind: string, params: object): Promise<void> { /* POST v1/notifications/send */ }
  async createRuleOverride(ruleName: string, override: object): Promise<void> { /* POST v1/notification-rules/:name/overrides */ }
  async deleteRuleOverride(ruleName: string, domainId: string): Promise<void> { /* DELETE */ }
  async updateRule(ruleName: string, updates: object): Promise<void> { /* PUT v1/notification-rules/:name */ }
  async deactivateRule(ruleName: string): Promise<void> { /* DELETE v1/notification-rules/:name */ }
  async activateRule(ruleName: string): Promise<void> { /* PUT with status: active */ }
  async updateUserEmail(user: TestUser, email: string): Promise<void> { /* ... */ }
}
```

## CI Integration (Buildkite)

### Pipeline Step

```yaml
- label: ":bell: Notification E2E Tests"
  command: |
    cd playwright
    npm ci
    npx playwright test tests/e2e/notifications/ --project=chromium
  env:
    MAILINATOR_API_TOKEN: "{{env.MAILINATOR_API_TOKEN}}"
    TEST_DOMAIN: "{{env.E2E_TEST_DOMAIN}}"
    BASE_URL: "{{env.STAGING_BASE_URL}}"
  artifact_paths:
    - "playwright/test-results/**/*"
    - "playwright/playwright-report/**/*"
  retry:
    automatic:
      - exit_status: 1
        limit: 2
  soft_fail: true
```

### Environment Setup

- `MAILINATOR_API_TOKEN` stored in Buildkite secrets
- Test domain with `notification_rules_enabled` flag always on
- Dedicated test users with Mailinator email addresses
- Test data seeded in `test.beforeAll` hooks

## Files to Create

All files in the `test_automation_playwright` repo:

- `playwright/tests/e2e/notifications/share_notification.spec.ts`
- `playwright/tests/e2e/notifications/digest_email.spec.ts`
- `playwright/tests/e2e/notifications/content_overrides.spec.ts`
- `playwright/tests/e2e/notifications/guard_throttle.spec.ts`
- `playwright/tests/e2e/notifications/rule_disabled.spec.ts`
- `playwright/apiHelpers/notificationApiHelper.ts`
- `playwright/fixtures/notificationFixtures.ts`

## Cross-Phase Dependencies

- **Phase 2 (prerequisite):** NotificationEngine must be deployed and active.
- **Phase 3 (prerequisite):** REST API for rule management (create/update/deactivate rules in tests).
- **Phase 4 (prerequisite):** REST API for triggering notifications programmatically.
- **Phase 7 (prerequisite):** Content overrides for override verification tests.
- **Phase 8 (prerequisite):** Guards for throttle/dedup tests.

## Risks and Mitigations

- **Risk:** Mailinator rate limits. **Mitigation:** Use `expect.poll` with generous intervals (5s). Each test uses a unique inbox. Clean up messages in `afterEach`.
- **Risk:** Flaky tests due to timing (email delivery delay, digest job interval). **Mitigation:** `expect.poll` with 60s timeout. Digest tests use longer timeouts. Mark as `soft_fail` in CI initially.
- **Risk:** Test user email changes affect other tests. **Mitigation:** Each test scenario gets a dedicated test user + unique Mailinator inbox. Restore original email in `afterAll`.
- **Risk:** Feature flag state leaks between tests. **Mitigation:** `beforeAll`/`afterAll` set and restore flag state. Use test-specific domains when possible.
