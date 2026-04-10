# Nutella API MCP Server — Hackweek Proposal

## Overview

Build a **Model Context Protocol (MCP) server** that exposes Highspot's core nutella API to AI-powered development tools (Cursor, Claude Desktop, and other MCP-compatible clients). This gives every AI tool in the Highspot ecosystem the ability to query, understand, and interact with the nutella API — turning it from a black box into a transparent, queryable system.

## Problem Statement

Nutella is the heart of Highspot's product with **~935 API endpoints** across public, internal, and admin surfaces. Yet today, every AI tool engineers use (Cursor, BugPilot, dev-buddy, triage agents) operates **blind** to the live API:

- **Engineers writing code** cannot ask their AI assistant "what does a pitch object look like?" and get a real answer.
- **BugPilot** can search code but cannot reproduce bugs by checking actual API state.
- **On-call engineers** manually curl endpoints and cross-reference with New Relic logs — the AI can't help because it has no API access.
- **New engineers** spend hours reading controller source files to understand API response shapes instead of querying them directly.

The **admin-agent** proved this concept works — it wraps 16 nutella API endpoints and provides AI-powered admin troubleshooting. But it's a purpose-built service for one use case. A generalized Nutella MCP server extends this value to **every engineer and every AI tool**.

## Goals

1. **Hackweek deliverable**: A working MCP server with 12 read-only tools that plugs into Cursor and can answer developer questions using real nutella API data from dev/staging.
2. **Developer experience**: Any engineer in Cursor can ask "show me user X's groups" or "what fields does the items API return?" and get grounded, real answers.
3. **Foundation layer**: Establish a reusable MCP server that other AI tools (BugPilot, on-call agent, triage agent) can build on.

## Non-Goals (Hackweek)

- Write operations (POST/PUT/DELETE) — v1 is strictly read-only.
- Production deployment — v1 targets dev/staging only.
- Full 935-endpoint coverage — v1 covers 12 high-value tools.
- Replacing admin-agent — complements it for a different audience (engineers vs. admins).

---

## Architecture

```
┌─────────────────────────────────────┐
│  Cursor / Claude Desktop            │
│  (MCP Client)                       │
│                                     │
│  "Get me user X's details"          │
│  "What does a pitch item look like?"│
└──────────┬──────────────────────────┘
           │ stdio (MCP protocol)
           ▼
┌─────────────────────────────────────┐
│  nutella-mcp-server (Python)        │
│                                     │
│  @app.list_tools() → 12 tools       │
│  @app.call_tool()  → HTTP to nutella│
│                                     │
│  Auth: token-based from .env        │
│  Target: dev/staging nutella        │
│  Mode: READ-ONLY (GET requests)     │
└──────────┬──────────────────────────┘
           │ HTTPS
           ▼
┌─────────────────────────────────────┐
│  Nutella Dev/Staging                │
│  https://{dev-domain}/api/v1/...    │
└─────────────────────────────────────┘
```

### Tech Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Language | Python | Fast iteration, `mcp` SDK is mature, matches hack2025-mcp-framework |
| MCP SDK | `mcp` (PyPI) | Official MCP Python SDK, stdio transport for Cursor |
| HTTP Client | `httpx` | Async HTTP for nutella API calls |
| Auth | Token-based (User-Email + User-Secret) | Simplest auth pattern supported by nutella |
| Config | `.env` file | Standard pattern, matches existing MCP servers at Highspot |

---

## V1 Tool Inventory (12 Tools)

### Tier 1 — Core Entity Lookup

| MCP Tool | Nutella Endpoint | Purpose |
|----------|-----------------|---------|
| `get_current_user` | `GET /api/v1/me` | Verify auth, get current user context |
| `get_user` | `GET /api/v1/users/{user}` | Inspect user objects (role, groups, properties) |
| `search_users` | `GET /api/v1/users?email=...` | Find users by email for testing/debugging |
| `get_item` | `GET /api/v1/items/{item}` | Inspect content/item structure (central entity) |
| `get_spot` | `GET /api/v1/spots/{spot}` | Inspect spot config, visibility, policies |
| `get_group` | `GET /api/v1/groups/{group}` | Inspect group structure, membership, permissions |

### Tier 2 — Lists & Search

| MCP Tool | Nutella Endpoint | Purpose |
|----------|-----------------|---------|
| `list_spots` | `GET /api/v1/spots` | Browse available spots, understand data layout |
| `list_groups` | `GET /api/v1/groups` | Browse groups, check permission structures |
| `search_items` | `GET /api/v1/search/items` | Find content by keyword |
| `get_spot_lists` | `GET /api/v1/spots/{spot}/lists` | Understand spot content organization |

### Tier 3 — Meta & Configuration

| MCP Tool | Source | Purpose |
|----------|--------|---------|
| `get_domain_config` | `GET /internal/api/v1/domain_configuration` | Check feature flags, GenAI policy, domain settings |
| `describe_api` | Local OpenAPI bundled YAML | Answer "what endpoints exist for X?" from the spec |

---

## Benefits

### For Individual Engineers

| Workflow | Today | With Nutella MCP |
|----------|-------|-----------------|
| Understanding a data model | Read controller code, grep field names, manually curl | Ask AI "what does a pitch object look like?" → real response |
| Building email builders | Cross-reference multiple source files, set up test data | Ask AI "show me a learning_completed alert payload" → real data |
| Writing tests | Construct mock objects that may not match reality | AI fetches real response shapes, generates accurate fixtures |
| Cross-team feature work | Read unfamiliar controller code for hours | Ask AI to explore the API directly |
| Debugging | Manually curl endpoints, compare with logs | AI queries the API inline while reviewing code |

### For the AI Ecosystem

- **BugPilot** gains the ability to check actual API state when diagnosing bugs (currently code-search only).
- **ecosystems-triage-agent** can verify live state when answering Slack questions.
- **on-call agent** can correlate New Relic alerts with actual application state.
- **Future agents** get a ready-made integration with the core application — no custom API client needed.

### For the Organization

- **Onboarding acceleration**: New engineers ask questions and get live answers instead of reading docs.
- **Knowledge democratization**: The 935-endpoint API surface becomes discoverable by any AI tool.
- **Foundation for production**: Proven pattern (admin-agent) extended to a general-purpose layer.

---

## Existing Highspot Precedent

| Project | Relationship | Status |
|---------|-------------|--------|
| **admin-agent** | Production service wrapping 16 nutella endpoints for admin troubleshooting via Mastra/TypeScript | Active, production |
| **hack2025-mcp-framework** | Generic MCP server framework with server generator, registry, and classifier | Hackweek prototype |
| **hs-new-relic-mcp-server** | MCP server for New Relic (placeholder — README only) | Stub |
| **BugPilot** | Jira MCP server + Cursor agent for automated bug fixing | Active, internal |
| **ecosystems-triage-agent** | Slack triage agent using Cursor Background Agents | Active, internal |

The Nutella MCP server fills the obvious gap: MCP servers exist for Jira, Slack, New Relic, and GitHub — but not for Highspot's own core application.

---

## Hackweek Plan (5 Days)

### Day 1: Scaffold + Auth + First Tool
- Create repository and Python project structure
- Implement auth helper (token-based HTTP calls to nutella dev/staging)
- Build first tool: `get_current_user` (`GET /api/v1/me`)
- Register as Cursor MCP server in `.cursor/mcp.json`
- **Checkpoint**: Open Cursor, ask "who am I?" → get a real nutella response

### Day 2: Core Entity Tools
- Implement `get_user`, `search_users`, `get_item`, `get_spot`, `get_group`
- Add pagination support for list endpoints
- Add error handling (401, 403, 404 → clear error messages for the AI)
- **Checkpoint**: Ask Cursor "show me the details of spot X" → get real data

### Day 3: Search + List Tools
- Implement `list_spots`, `list_groups`, `search_items`, `get_spot_lists`
- Add response formatting (trim large responses to stay within token limits)
- Add optional field filtering (return key fields, not full 50-field objects)
- **Checkpoint**: Ask Cursor "find items about sales training" → get search results

### Day 4: Meta Tool + End-to-End Testing
- Implement `describe_api` (loads OpenAPI bundled YAML, answers questions about available endpoints)
- Implement `get_domain_config`
- Test realistic developer workflows end-to-end:
  - "I'm building an email builder for learning alerts — show me what a learning item looks like"
  - "What fields does the items API accept for search?"
  - "Show me the groups in my test domain"
- **Checkpoint**: Full integrated demo with realistic developer questions

### Day 5: Polish + Demo
- Write README with setup instructions (clone, pip install, configure, register in Cursor)
- Add Cursor rules file (`.cursor/rules/nutella-mcp.mdc`) to guide AI usage of tools
- Handle edge cases (rate limiting, large responses, auth expiry)
- Prepare demo / presentation
- **Present**

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Dev/staging auth doesn't work with token approach | Medium | High | Test auth on Day 1 as first task; fall back to cookie-based auth if needed |
| Large API responses exceed AI token limits | Medium | Medium | Truncate responses to key fields; add a `max_results` parameter to list tools |
| Too many tools for hackweek | Low | Medium | Tier 1 (6 tools) is the minimum viable demo; Tiers 2–3 are stretch goals |
| OpenAPI spec doesn't cover needed endpoints | Low | Low | Fall back to calling raw API; AI interprets the response shape |
| Competing with admin-agent scope | Low | Low | Different audience (developers vs. admins), different transport (MCP vs. HTTP service) |

---

## Production Roadmap (Post-Hackweek)

If the hackweek proves the concept, the path to production is clear:

### Phase 1: Internal Adoption (Weeks 1–4)
- Share with other teams for feedback
- Add more tools based on demand (pitches, learning, analytics)
- Harden auth and error handling

### Phase 2: Production Deployment (Months 1–2)
- Deploy as a service (not local stdio) using service identity auth
- Enforce read-only at the server level (reject POST/PUT/DELETE)
- Add PII filtering before returning responses
- Add audit logging for every MCP tool call
- Add rate limiting (e.g., 10 req/min per caller)

### Phase 3: Ecosystem Integration (Months 2–3)
- BugPilot, on-call agent, and triage agent consume the MCP server
- admin-agent migrates to use Nutella MCP as its data layer (shared tool code)
- Nutella MCP becomes the standard way AI tools interact with the core application

### Production Architecture

```
Dev/Staging (Hackweek)                 Production (Post-Hackweek)
─────────────────────                  ──────────────────────────
Cursor IDE                             admin-agent / BugPilot /
  │                                    triage-agent / on-call-agent
  │ stdio                                 │
  ▼                                       │ HTTP (authenticated)
nutella-mcp-server                        ▼
  (local Python process)              nutella-mcp-server
  │                                     (deployed service, k8s)
  │ HTTPS + personal token              │
  ▼                                     │ HTTPS + ServiceIdentity
nutella dev/staging                     │ Read-only, PII-filtered
                                        │ Rate-limited, audit-logged
                                        ▼
                                      nutella production
```

### Production Safeguards

| Concern | Safeguard |
|---------|-----------|
| PII exposure | Strip user PII (emails, names) before returning to AI; return IDs + metadata only |
| Write operations | GET-only enforcement at server level — architectural constraint, not policy |
| Rate limiting | Max requests per minute per caller, same as any API consumer |
| Audit trail | Log every tool call: timestamp, caller, tool name, arguments, response size |
| Blast radius | MCP server is a client of nutella (like the web UI); if it misbehaves, rate limiting kicks in |

---

## Success Metrics

### Hackweek
- Working MCP server with 12 tools registered in Cursor
- End-to-end demo: developer asks AI a question → AI calls nutella API → returns real data
- At least 3 realistic developer workflow demos

### Post-Hackweek (if adopted)
- Number of engineers who add the MCP server to their Cursor config
- Number of daily MCP tool calls
- Time saved per developer interaction (qualitative feedback)
- Number of other AI agents that consume the MCP server

---

## Appendix: Nutella API Surface

### API Mounts (from `web/config/apps.rb`)

| App | Mount Path | Description |
|-----|-----------|-------------|
| `Api` | `/api` | Main JSON API (~874 routes) |
| `InternalApi` | `/internal/api` | Service-to-service API (~36 routes) |
| `AdminApi::App` | `/adminapi` | Admin API (~25 routes) |
| `Scim::App` | `/scim` | SCIM provisioning (~11 routes) |
| `Auth` | `/auth` | OAuth authentication |
| `Highspot` | `/` | Web application |

### OpenAPI Specs Available

| Spec | Location | Paths |
|------|----------|-------|
| Public v1.0 | `web/common/open-api-specification/open-api-public-v1.0.bundled.yaml` | ~70 |
| Public v0.5 | `web/common/open-api-specification/open-api-public-v0.5.bundled.yaml` | ~60 |
| Internal | `web/common/open-api-specification/open-api-internal.bundled.yaml` | ~6 |
| Admin | `web/common/open-api-specification/open-api-admin.bundled.yaml` | ~17 |

### Public API v1.0 Resources

- `/me` — Current user
- `/users`, `/users/{user}` — User management
- `/users/{user}/properties` — User properties
- `/items`, `/items/{item}` — Content/items
- `/items/{item}/content`, `/items/{item}/versions` — Item content and versions
- `/groups`, `/groups/{group}` — Group management
- `/groups/{group}/members`, `/groups/{group}/settings` — Group membership and settings
- `/spots`, `/spots/{spot}` — Spot management
- `/spots/{spot}/lists`, `/spots/{spot}/users` — Spot content and users
- `/global-lists`, `/global-lists/{list}` — Global lists
- `/pitches`, `/pitches/link` — Pitch management
- `/digital-rooms/{id}/content-blocks` — Digital sales rooms
- `/subscriptions` — Webhook subscriptions
- `/domain/*` — Domain configuration
- `/search/items`, `/search/instant-answer` — Search
- `/skills` — Skills
- `/assessments/external-survey` — Assessments
- `/audit-events` — Audit trail
- `/privacy/data-subject` — Privacy/GDPR

### Authentication Patterns

| Surface | Auth Method |
|---------|------------|
| Public API | Token (User-Email + User-Secret), OAuth session + CSRF, HTTP Basic |
| Internal API | Service Identity (`Hspt::Kubernetes::ServiceIdentityAuth`) |
| Admin API | OAuth + admin role check |
| SCIM | OAuth with SCIM scopes |
