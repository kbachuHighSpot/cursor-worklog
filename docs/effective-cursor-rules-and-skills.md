# Effective Cursor Rules and Skills — A Field Guide Built from Real Failures

**Audience:** Engineers and team leads who author `.cursor/rules/*.mdc` or `.cursor/skills/*/SKILL.md` files in their team's repos — or are about to.

A perfectly correct rule existed. It said exactly the right thing. The Cursor agent never read it. By the time the team noticed, 150 i18n keys had been hand-crafted and shipped on a PR — every one of them violating the rule the rule existed to prevent. **That's one incident. There were eight others in the same project.**

This is a field guide built from nine distinct incidents in a multi-week, multi-PR Cursor-assisted code-migration project — each failure paired with the authoring pattern that prevents the next round. The i18n cascade above is the cleanest single example; the eight surrounding incidents — a doppelgänger source-of-truth confusion, a half-applied multi-step skill recipe, conflicting old-vs-new validators, a missing rule for a framework autoloader pitfall, an asymmetric checker that missed the other direction, a "don't do X" rule that accepted bad substitutes for "do Y", a class of review-feedback bugs with no rule, and a 2,827-line mega-skill whose mandates the agent couldn't reliably parse — are what make the failure modes look systemic instead of isolated. Repo-specific details are anonymized below; the failure modes generalize to any team using Cursor's rules or skills, in any repo, in any language. The next section names all nine at a glance; the body that follows walks each one through to a concrete pattern, and the operational checklist at the end distills the result.

---

## Issues and lessons at a glance

| # | Symptom | Root cause | Lesson | Deep-link |
|---|---|---|---|---|
| 1 | ~150 hand-crafted i18n keys shipped on a PR despite a rule that forbade them | **Four stacked failures:** stale globs (rule attached to only ~10% of edits) + repo-local skill invisible to agent + passive `see X.mdc` cross-refs + the mandate buried in part 2 of a 230-line multi-topic rule | Even a perfectly-written rule does nothing if four orthogonal mechanisms each silently disable it. Audit the *mechanisms*, not just the prose. | [Anatomy of a silent failure](#anatomy-of-a-silent-failure) · Patterns [A](#a-treat-glob-lists-as-production-code), [B](#b-cross-reference-repo-local-skills-from-skills-the-agent-already-sees), [C](#c-use-imperative-voice-and-put-the-command-in-the-description), [D](#d-one-topic-per-rule-file) |
| 2 | Agent reasoned about the production feature-flag gate from a preview-only Ruby constant | Same word ("category") referred to two things — an in-memory constant and a database column. Agent grepped, hit the constant first (more grep-visible), reasoned from there | When the same noun refers to two things in your codebase, name the winner explicitly — at kickoff or in a `sources_of_truth:` front-matter block. The cost of not doing it is the entire debugging round-trip every new session | [Same word, two referents](#same-word-two-referents-the-canonical-source-ambiguity) · Pattern [L](#l-name-canonical-sources-for-ambiguous-terms-at-kickoff-or-in-a-rule) |
| 3 | Sequential migration recipe was applied half-way — step 1 done, step 2 ignored even though the recipe demanded it | Skill's pattern descriptions were written as **prose narrative** ("if X happens, do Y"). Agent treated each named pattern as a standalone option and stopped at the first match | Decision trees beat narratives for agent compliance. Each named step needs an explicit imperative "after applying me, check for X next" pointer, not buried in prose | [Skill failure: a multi-step recipe was applied half-way](#skill-failure-a-multi-step-recipe-was-applied-half-way) |
| 4 | A sanctioned copy improvement was flagged by a validator as a regression — false alarm on every fix | Two rules with opposite signals coexisted: one enforcing "match legacy verbatim", one enforcing "use the new pattern" | When migrating, retire negative same-as-legacy rules as positive use-new-pattern rules come online. Leaving both means every improvement trips a false alarm | [Conflicting rules: a sanctioned fix was flagged as a regression](#conflicting-rules-a-sanctioned-fix-was-flagged-as-a-regression) |
| 5 | Hours of "the fix isn't taking effect" debugging — framework autoloader didn't re-execute top-level registration blocks | **No rule existed at all.** Team's skill examples happened to put dispatch in method bodies (where reload works) and never warned about side-effecting top-level blocks | Framework-specific reload behaviors are exactly the kind of footgun an `alwaysApply: true` one-line MUST should capture. Add a rule the moment you discover a non-obvious reload pitfall; future-you should not have to discover it twice | [Missing rule entirely: framework autoloader pitfall](#missing-rule-entirely-framework-autoloader-pitfall) |
| 6 | A specific case slipped past a paragraph-count validation rule that fired correctly in many others | Three flaws stacked: **asymmetric** directionality (only checked one direction), a **word-floor exception** that exempted short content, and counting "newline boundaries" instead of paragraph blocks (fragile to whitespace) | Default to symmetric equality and zero exceptions when authoring validation rules. False positives are cheap (a PR comment); false negatives ship regressions | [Rule existed but was insufficient: asymmetric checks](#rule-existed-but-was-insufficient-asymmetric-checks-miss-the-other-direction) |
| 7 | "Concise comments" rule worked — but produced opaque internal-taxonomy comments like `# Pattern E for custom_smtp_pitch_send_failed` that were useless without the project's skill open in another tab | Rule taught the agent **what to compress**, not **what to compress to**. The agent found a literal way to satisfy "don't elaborate" that violated the spirit | When a rule says "don't do X", model "do Y instead" with at least one concrete example. Forbid the bad-substitute classes explicitly (pattern letters, naked `[RULE:foo]` tags, internal skill names as the primary explanation) | [Rule existed but accepted bad substitutes](#rule-existed-but-accepted-bad-substitutes) |
| 8 | "Sentence ending in 'following …' should end with a colon" — no rule, recurring slip-throughs, only caught in PM review after the fact | Recurring PM review feedback hadn't been audited as a source for new validation rules | Recurring review feedback is rule-shaped. After a review pass, sweep the threads: which categories of feedback have rules? Which don't? The ones that don't are next session's slipped-through bugs | [Rule space hadn't been audited against review feedback](#rule-space-hadnt-been-audited-against-review-feedback) |
| 9 | A single skill grew to **2,827 lines** covering 10 sub-recipes (A–J). Even when it auto-attached, review-driven fixes sometimes routed to the wrong recipe | Mega-skill exceeded the agent's attention budget; mixed-topic prose made it unreliable to route a specific symptom to the correct named recipe | Split mega-skills into sibling bundles — one trigger per skill, imperative `description:` naming the validator code or symptom verbatim. ~300–600 lines of single-topic prose beats 2,827 lines of mixed-topic prose | Pattern [J](#j-skill-bundles-instead-of-mega-skills) |

The body below tells each story in full. The "Patterns that work" section turns each lesson into a concrete recipe; the authoring checklist at the end is the operational distillation of all 9 lessons.

---

## TL;DR — the failure modes

1. **Stale `globs` are silent decay.** A glob list that pointed at a directory renamed during a past refactor matches nothing today. The rule still parses fine; it just never auto-attaches.
2. **Repo-local skills are not surfaced in agent context.** Skills under `<repo>/.cursor/skills/` do not appear in the agent's `<available_skills>` block. Only user-level (`~/.cursor/skills/`) and plugin skills are advertised. The agent has no way to discover a repo-local skill exists.
3. **Passive cross-references don't fire.** "See `X.mdc` for full rules" in another rule's prose does not cause the agent to read X.
4. **Critical mandates buried in long files get skipped.** Part 2 of a 4-part 230-line rule is read less attentively than a focused 80-line file. The same is true for a 2,800-line skill with 10 sub-recipes.
5. **Without commit-time enforcement, rules are advisory.** Runtime validators at app boot catch problems too late. A pre-commit hook or lint cop is the actual safety net.
6. **Doppelgänger terms route the agent to the wrong source of truth.** When the same noun refers to two different things in the codebase (e.g. two `category` fields, two `tenant` concepts), the agent grep-matches the first one and reasons from there — silently, plausibly, and 30 minutes deep into a fix. A one-line canonical-source declaration up front (or a `sources_of_truth:` block in the relevant rule) replaces multiple correction round-trips.

The rest of this document walks through one incident that hit failure modes 1–4 simultaneously, several follow-on incidents that exhibited variants of all five, and the concrete patterns that prevent each failure mode in turn.

---

## Rules vs skills — a 60-second primer

The rest of this document uses both terms heavily. They are related but mechanically distinct, and the failure modes attach to them differently. If you only remember one thing: **rules attach by file path; skills attach by conversation topic.**

### Mechanical differences

| Dimension | Rule (`.cursor/rules/*.mdc`) | Skill (`.cursor/skills/<name>/SKILL.md`) |
|---|---|---|
| **Trigger** | `globs:` match the file the agent is editing — or `alwaysApply: true` | `description:` semantically matches the agent's current conversation context |
| **Where it can live and still work** | `~/.cursor/rules/` (user) **and** `<repo>/.cursor/rules/` (repo-local) — **both auto-attach** | `~/.cursor/skills/` (user) or plugin-bundled. **Repo-local `<repo>/.cursor/skills/` is not surfaced to the agent** — this is failure mode #2 |
| **How the agent sees it** | Injected inline into the agent's context when the trigger fires; agent has no choice | Listed in the agent's `<available_skills>` system block as a one-line description; the agent decides whether to read the body |
| **Length budget** | Short — ~50-100 lines, single topic (Pattern D) | Longer — but split into sibling bundles past ~300-600 lines (Pattern J) |
| **Authoring discipline** | `description:` names the *constraint*; `globs:` name the *files where the constraint applies* | `description:` names the *task or workflow* in imperative voice, with verbatim keywords the agent will actually see in conversation |
| **Failure modes that bite hardest** | Stale globs (#1) · cross-refs that don't fire (#3) · mandate buried (#4) | Repo-local invisibility (#2) · description that doesn't trigger · mega-skill exceeding attention budget (Pattern J) |

### When to write which

| If the thing you're authoring is… | Use a… |
|---|---|
| A constraint on how code is written ("every X must Y") | **Rule** |
| A constraint that applies only to a specific class of files | **Rule** with narrow `globs:` |
| A constraint that applies everywhere (logging, secrets, i18n keys, comment style) | **Rule** with `alwaysApply: true` or `globs: ["**/*.<lang>"]` |
| A footgun about how a specific framework behaves at runtime | **Rule** with `alwaysApply: true` and the symptom verbatim in the description |
| A multi-step recipe for a task ("how to migrate Z from legacy to new") | **Skill** |
| A diagnostic playbook ("when validator emits `[RULE:foo]`, do X then Y then Z") | **Skill** with the validator code verbatim in the description |
| A workflow that wires multiple constraints together | **Skill** that *cites the rules* it depends on inline (not via passive cross-reference — see Pattern C) |
| Project status, decisions, source-of-truth maps | Neither — that's what a `PROJECT.md` is for |

### When the lines blur

A single concern often needs both. The i18n incident is the canonical example: a *rule* enforces "every key must come from `./iidgen`" (file-shaped constraint that auto-attaches whenever a Ruby file with an `i18n.t` call is edited), and a *skill* documents the full workflow including translation-file updates and key-reuse policies (a multi-step recipe the agent invokes when the conversation is about adding or changing copy).

The right pattern when both apply:

1. **Rule states the MUST** in imperative voice with the command verbatim.
2. **Skill walks the workflow** end-to-end including the steps the rule doesn't see (translation files, reuse search, post-merge follow-up).
3. **Rule's description cites the skill name verbatim** so the agent's skill-selection step picks it up when the rule fires.

If you skip step 3, the rule and skill drift apart — the rule fires on file edit but the agent doesn't read the skill because the conversation never names the skill's trigger keywords.

### Why this distinction sharpens the failure-mode analysis

Knowing which lever you're pulling tells you which failure modes are even possible:

- **A stale glob** breaks a *rule* — the rule silently never attaches. Skills don't have globs; they cannot fail this way.
- **An invisible repo-local file** breaks a *skill* — the agent never knows it exists. Rules don't have this problem; both `~/.cursor/rules/` and `<repo>/.cursor/rules/` are read.
- **A buried mandate in a long file** is mainly a *rule* problem at >80 lines and a *skill* problem at >300 lines. Different thresholds, same shape — and the fix (split into focused single-topic files) is the same shape too.
- **Passive cross-references that don't fire** affect both equally — a "see `X.mdc`" in a skill's prose is just as inert as a "see `Y.SKILL.md`" in a rule's prose.

Patterns A and J are the rule-specific and skill-specific recovery patterns respectively; Patterns B, C, F, G, K, and L apply to both.

---

## Anatomy of a silent failure

A routine code-migration task in a Ruby monorepo. Over ~2 weeks of agent-assisted PR work, ~200 new calls to the project's i18n helper (`i18n.t("KEY", "English fallback text", …)`) were added across 10 files. The team's i18n rule was clear:

> Always use the project's key generator (a small binary at `web/iidgen`) to mint new i18n keys.
> Keys must be opaque 8-character alphanumeric identifiers, not descriptive strings.
> Never type a key by hand.

There was also a repo-local skill that knew the full workflow — including translation-file updates and key-reuse rules.

What the agent actually did:

- Hand-crafted ~140 descriptive 8-character keys (`aSbCt001`, `pwExBdN0`, `tEcTtl01`, …) that satisfied the runtime length check but encoded meaning — violating the "opaque identifiers" mandate.
- Generated 22 length-violating keys (5 at length 7, 17 at length 9) that the runtime parser rejected at app boot.
- Typo'd an existing key (`HBBd6qii` → `hBBd6qii`) which, being case-sensitive, became a brand-new untranslated key.
- After a teammate ran the app and saw the parser's "Invalid key 'X'" log lines, the agent's first fix was to **pad** `aSbCt01 → aSbCt001` to satisfy the length check — preserving the hand-crafted descriptive naming and doubling down on the rule violation.

When asked directly *"did you generate the key the way the rule says?"*, the agent admitted it had not, and a proper sweep regenerated all 149 problematic keys via the actual generator.

The rule existed. The skill existed. Neither fired.

---

## Why the rule didn't fire — four stacked failures

Four independent failure modes lined up. None of them is the rule itself — it's everything around the rule.

### 1. The rule's globs were stale

The front matter looked like this:

```yaml
---
description: Content rules for project emails (no soft fallbacks, i18n conventions, body structure)
globs:
  - "**/email_content_builder/**/*.rb"
  - "**/direct_email_builder/**/*.rb"
  - "**/alert_commands.rb"
  - "**/generic_builder.rb"
alwaysApply: false
---
```

The first two globs pointed at directories that no longer existed — renamed in a past refactor. Cursor auto-attaches a rule when the agent edits a file matching one of the globs; with two of four globs broken, the rule attached to only ~10% of relevant edits. The remaining 90% of i18n keys were authored in a context where the rule never appeared.

**Sibling rules went stale the same way.** Two other rules written at the same time had identical broken glob lists. Stale globs cluster — if you find one, search for siblings written by the same author in the same week.

### 2. Repo-local skills are invisible to the agent

Skills live in two places:

- `~/.cursor/skills/<name>/SKILL.md` — user-level. Surfaced in the agent's `<available_skills>` system block.
- `<repo>/.cursor/skills/<name>/SKILL.md` — repo-local. **Not surfaced.**

The agent learns about user-level and plugin skills via a system prompt section that looks roughly like:

```xml
<available_skills description="Skills the agent can use...">
  <agent_skill fullPath="/Users/me/.cursor/skills/update-worklog/SKILL.md">...</agent_skill>
  <agent_skill fullPath="/Users/me/.cursor/skills/some-other-skill/SKILL.md">...</agent_skill>
  ...
</available_skills>
```

Repo-local skills are not enumerated there. The project's repo had five repo-local skills, every one of them invisible. The i18n-strings skill was a perfect match for the task and would have fired on its own description trigger — if the agent had any way to know it existed.

This is a Cursor product behavior, not a rule-authoring mistake. The mitigation has to happen at a different layer (see Pattern B below).

> **Heads-up: rules don't have this problem.** Cursor reads both `~/.cursor/rules/` **and** `<repo>/.cursor/rules/` and auto-attaches any `.mdc` whose `globs:` match the currently-open file. Repo-local placement is the *correct* location for rules that are codebase-specific (a rule about your Rails app's content security policy doesn't belong in `~/.cursor/rules/` where it would be evaluated against every other project). The discoverability gap above is specific to skills.

### 3. Cross-references between rules and skills are passive

A user-level skill that the agent *did* have in context cross-referenced the i18n rule twice in its prose:

- Inside a "Related Rules" table: `<rule-name>.mdc | Writing the new copy; i18n key generation; avoiding soft fallbacks`
- Inside a long pattern recipe: `See <rule-name>.mdc for full i18n key generation rules.`

Both are prose mentions. Neither triggered the agent to actually read the cross-referenced rule. The mental model "follow links you encounter" is not how language-model-driven agents work — they need imperative instructions ("Before you write any `Foo.bar(...)` call, run `./baz-gen`") with the actual command inline. A link is a passive suggestion.

### 4. The mandate was buried inside a long multi-topic rule

The content rule was a 232-line file with four `## Part N:` sections:

- Part 1: No soft fallbacks (lines 17–55)
- **Part 2: i18n key conventions (lines 58–98)** ← where the mandate lived
- Part 3: Body structure (lines 102–188)
- Part 4: Hard line breaks (lines 192–end)

The front-matter description ("Content rules — no soft fallbacks, i18n conventions, body structure") is a flat list that doesn't single out Part 2 as critical. When the rule did attach (the 10% of files where the globs worked), the i18n section was one of four roughly-equal topics, two screens down.

---

## More failure modes from the same project

The i18n incident is the cleanest example, but the same failure modes hit several other rules and skills over the course of the project. Each item below is a real incident; together they show the failure modes are systemic, not isolated.

### Skill failure: a multi-step recipe was applied half-way

The team's largest skill defined a sequential migration recipe with several named patterns. For one kind of edit, the agent applied the first step correctly but stopped — even though the recipe explicitly said "if there is a follow-up sentence after the entity reference, move it below the card". The agent treated each step as a standalone option and stopped at the first match.

Root cause: the skill's pattern descriptions were written as **prose narrative** ("if X happens, do Y"). Decision trees beat narratives for agent compliance. Each named step needs an explicit "after applying me, check for X next" pointer, written as imperative — not buried in prose.

### Conflicting rules: a sanctioned fix was flagged as a regression

A validation rule existed to flag any output that diverged from the legacy template's wording. When a sanctioned copy improvement was applied (changing `"…could not be sent."` to `"…could not be sent:"` per a style update), this rule fired against the now-correct output.

Two rules with opposite signals — one enforcing "match legacy verbatim", one enforcing "use improved pattern" — will eventually conflict. **General lesson:** when migrating, retire negative "same-as-legacy" rules as positive "use new pattern" rules come online. Leaving both means every improvement trips a false alarm.

### Missing rule entirely: framework autoloader pitfall

The agent put dispatch logic inside a top-level lambda registered at file load time. In development mode, the framework's autoloader reloaded *method bodies* when the file changed but did **not** re-execute top-level registration blocks. The live preview kept using the lambda from the first boot — completely independent of any later edits. Hours of "the fix isn't taking effect" debugging followed.

This wasn't a discoverability failure — it was a **missing rule entirely**. The team's skills demonstrated working examples, but the examples happened to put dispatch inside a method body where reloading works. Nothing in any rule or skill warned: "side-effecting registration in top-level blocks doesn't reload; put dispatch in method bodies."

**General lesson:** framework-specific reload behaviors are exactly the kind of footgun that an `alwaysApply: true` rule with a one-line MUST should capture. Add a rule the moment you discover a non-obvious reload pitfall; future-you should not have to discover it twice. Every Rails / Padrino / Spring / Vite / Next codebase has its own version of this; few teams have written it down.

### Rule existed but was insufficient: asymmetric checks miss the other direction

A validation rule existed to check that two versions of a piece of content had the same paragraph breaks. The check fired in many cases — and then a specific case slipped through where the rule had three flaws stacked on each other:

1. **Asymmetric directionality** — it only checked when version A had *more* breaks than version B, never the reverse.
2. **A word floor** that exempted short messages, even though short content is exactly where formatting regressions are most visible.
3. **Counted "newline boundaries" instead of paragraph blocks** — fragile to whitespace variation.

The rewrite is a strict paragraph-count equality check in both directions with no length floor.

**General lesson:** when authoring a validation rule, default to symmetric equality and zero exceptions. Asymmetric thinking misses regressions in the other direction. False positives are cheap (a comment in a PR); false negatives ship a regression.

### Rule existed but accepted bad substitutes

A code-comment style rule was authored mid-project to forbid elaborate code comments. It worked — the next sweep collapsed a 749-line comment diff to 398. But the resulting comments included gems like `# Pattern E for custom_smtp_pitch_send_failed (mirrors digital_room sibling)`. These satisfied the rule's "single line, why-not-what" criterion but were useless without the project's internal skill open in another tab.

The rule had taught the agent **what to compress**, not **what to compress to**. The fix amended the rule with explicit BAD / STILL-BAD / GOOD examples and forbade opaque internal taxonomy (pattern letters, naked `[RULE:foo]` tags, internal skill names) as the primary explanation in a comment.

**General lesson:** when you write a rule that says "don't do X", you must also model "do Y instead" with at least one concrete example. The agent will find a literal way to satisfy "don't X" that violates the spirit. This is a specific instance of the imperative-voice pattern: show the target state, not just the constraint.

### Same word, two referents: the canonical-source ambiguity

The module had two distinct things called **"category"**:

| Referent | Where it lives | Used by |
|---|---|---|
| `KIND_CATEGORY` constant | in-memory Ruby map under the email registry | the email preview page only |
| `<Entity>.category` column | the relational database, hydrated via the rules resolver | the production feature-flag gate |

The agent grepped for `category`, hit `KIND_CATEGORY` first (it's the most grep-visible occurrence in the semantic email tree), and reasoned about the production gate from there. Several rounds of "why is this kind still rendering legacy?" debugging followed, until the user corrected: "the constant is preview-only; the database column is what the gate reads."

The pattern generalizes anywhere a noun has a doppelgänger: `user.id` vs `user_id`; `tenant` (URL slug) vs `tenant` (DB document); `enabled?` (feature flag wrapper) vs `enabled?` (model attribute); the same column name appearing on two different tables. The agent has no way to know which referent you mean unless you name it.

**General lesson:** when the same noun refers to two things in your codebase, name the winner explicitly — at kickoff or, better, in a `sources_of_truth:` block in the relevant rule. The fix is one sentence. The cost of not doing it is the entire debugging round-trip every time a new session touches the term.

### Rule space hadn't been audited against review feedback

Mid-project, a whole class of bugs — "sentence ending in 'following …' should end with a colon, with the entity card immediately below" — had no validation rule. Multiple changes had been merged with inline periods instead of colons, and the issue surfaced only during PM review, after the fact.

A nearby rule did exist but had a regex narrow enough that variant phrasings slipped through. Both got authored or broadened mid-project in reaction to specific review threads.

**General lesson:** recurring review feedback is rule-shaped. "We always say colons before reference lists" or "we never inline the entity title in the body" are candidates for validation rules. After a review pass, do an audit: which categories of feedback have rules? Which don't? The ones that don't are next session's slipped-through bugs.

---

## Patterns that work

Each failure has a corresponding pattern. None is hard; they just have to be deliberate.

### A. Treat glob lists as production code

When directories get renamed, grep `.cursor/rules/*.mdc` for the old path before merging the rename:

```bash
# Before merging a rename like `git mv old_dir new_dir`:
rg -l 'old_dir' .cursor/rules .cursor/skills

# After a rename has already shipped, find stale globs:
for f in .cursor/rules/*.mdc; do
  globs=$(awk '/^globs:/,/^alwaysApply:|^---/' "$f" | grep -oE '"[^"]+"' | tr -d '"')
  for g in $globs; do
    count=$(rg --files -g "$g" 2>/dev/null | head -1 | wc -l)
    [ "$count" -eq 0 ] && echo "DEAD-GLOB $f -> $g"
  done
done
```

Fix in the same PR as the rename, not as a follow-up. Stale globs feel like cosmetic debt; they're actually rule decommissioning.

### B. Cross-reference repo-local skills from skills the agent already sees

Since repo-local skills aren't surfaced, the mitigation is to have a user-level (or plugin-surfaced) skill *quote the mandate inline* with a pointer to the repo-local skill for deeper workflow:

```markdown
## MANDATORY: i18n key generation

Before you write or edit any `i18n.t("KEY", "...")` call as part of this skill:

1. **Run `cd web && ./iidgen`** to get a random 8-char key.
2. **Never type a key by hand.** Patterns like `aSbCt001`, `share_item_subject`,
   or any structured/decipherable identifier are forbidden.
3. **Never pad a too-short key.** Regenerate via `./iidgen`.
4. **Never reuse an existing key with different fallback text.**
5. **Search for an existing key with the same English text first.**

Repo-local skill (deeper workflow including translation files):
`<repo>/.cursor/skills/i18n-strings/SKILL.md`.
```

The visible skill carries the critical action. The repo-local skill carries the depth. The agent gets the mandate even if it never reads the repo-local file.

### C. Use imperative voice and put the command in the description

The description field is the agent's gatekeeper — it decides whether to read the rule based on this text. Compare:

| Weak | Strong |
|---|---|
| `Content rules — no soft fallbacks, i18n conventions, body structure` | `MUST use ./iidgen to generate every new i18n.t key; keys must be exactly 8 alphanumeric chars; never hand-craft. Read this whenever you are about to add, rename, or modify an i18n.t call in any Ruby file.` |

The strong version (a) names the command verbatim, (b) uses "MUST", (c) describes the triggering action so the agent recognizes when it applies.

### D. One topic per rule file

A 230-line rule with `## Part N:` headings is a smell — split each part into its own file with its own front matter. The version of `i18n-keys.mdc` extracted from Part 2 of the original rule is ~80 lines, has its own imperative description, can be auto-attached to `**/*.rb` everywhere instead of a narrow builder-only glob, and stops competing for attention with the other three parts.

### E. Ship a verification command inside the rule

A rule that hands the agent the command to self-check is far stronger than a rule that only describes the desired state. The i18n rule now includes:

```bash
# Audit keys you just added on a branch:
git diff origin/main...HEAD -- '*.rb' \
  | grep -E '^\+[^+]' \
  | grep -oE 'i18n\.t\(\s*"[^"]+"' \
  | grep -oE '"[^"]+"' | tr -d '"' | sort -u \
  | awk '{ if (length($0) != 8) print "BAD-LEN " length($0) " " $0 }'
```

Now the agent can verify compliance before committing. Empty output = pass.

### F. Anchor the mandate to source files

Don't describe a constraint abstractly — point at the file that enforces it:

> `web/iidgen` is the generator. `web/<lib>/default_string_reader.rb#build_string` is the validator that enforces 8-char alphanumeric at runtime.

When the agent reads the rule, it can verify the constraint by reading the validator's source directly — no ambiguity about *why* keys must be exactly 8 chars. This also gives the agent a way to learn the constraint's edges (e.g., "validator only checks length+alphanumeric; doesn't catch descriptiveness").

### G. Document the cost of violating the rule

"Reusing a key with changed text ships stale translations" is dramatically more compelling than "do not reuse keys". State the consequence inline so the agent can weigh it against any incentive to take a shortcut.

### H. Treat rules as the backstop, not the primary defense

The strongest defense is a commit-time check. For the i18n case, a ~30-line pre-commit hook (or RuboCop cop) that scans added `i18n.t(...)` calls in the staged diff and rejects:

- Keys whose length ≠ 8
- Keys matching descriptive patterns (lowercase prefix + UpperCase abbreviation + digit suffix)
- Reuse of an existing key with changed fallback text

…would have blocked all 150 bad keys at commit time, regardless of whether the agent saw the rule. Rules backstop the check; they don't replace it. If a check doesn't exist, the rule should say so explicitly so future authors know not to rely on it.

### I. Runtime validators ≠ commit-time validators

The project's i18n validator logged `Invalid key 'X'` at app boot. By then, the bad code is already merged. Validators that fire at the wrong point in the pipeline create false confidence: "there's a validator" makes hand-crafting keys feel safe until you read what the validator actually checks (length + alphanumeric only — nothing about descriptiveness, reuse, or text changes).

State precisely what each validator does and does not catch.

### J. Skill bundles instead of mega-skills

When a single skill grows past ~300 lines or covers more than one symptom/topic, split it into a **bundle** — sibling skills under the same parent directory, each owning one trigger.

The project's largest skill grew to **2,827 lines** covering ten sub-recipes (A through J). Even when it auto-attached, the agent's attention budget couldn't reliably parse all ten; review-driven fixes that should have routed to one recipe sometimes hit a different one. The split replaced the mega-skill with six focused siblings, each one owning a specific symptom or validator code:

| Sibling skill | Trigger |
|---|---|
| `body-copy-card-anchor` | Two related validator codes — `[RULE:body_after_following_reference]` and `[RULE:following_missing_colon]` |
| `entity-card-validity` | `[RULE:semantic_card_without_legacy_link]` |
| `body-copy-link-preservation` | `[RULE:secondary_link_lost]` |
| `entity-card-enrichment` | Cosmetic card rows via DB lookup |
| `entity-card-thumbnails` | Canonical presenter chain + a Ruby `extend`/constant-lookup gotcha |
| `migrate-semantic-email-body-copy` (slim) | Location classification A–D |

Each new skill's `description:` is **imperative** and names the validator code or trigger verbatim, so Cursor surfaces it as soon as the conversation mentions that code. The original mega-skill was relocated to an archive directory outside Cursor's auto-load path, kept for reference until each new skill has been independently validated.

The cost was one afternoon of mechanical extraction. The benefit: each agent invocation now reads ~300–600 lines of single-topic prose instead of 2,827 lines of mixed-topic prose.

### K. Build source-of-truth indexes for evolving taxonomies

A skill called "Pattern H" is meaningful to humans; a validator code like `[RULE:secondary_link_lost]` is meaningful to a script. When both vocabularies exist for the same concept, drift is guaranteed unless one file commits to mapping them.

Two indexes worth building:

1. **Pattern ↔ validator-code index.** Maps every `[RULE:*]` code emitted by your validator to the pattern letter that owns the fix, plus the sibling skill where the fix recipe lives. When a new code is added to the validator, it goes in this index in the same commit. When a sibling skill claims a code, the claim is checked against this index.
2. **Plan / phase status rollup.** Aggregates `status:`, `phase:`, `prs:`, and `related_skills:` from the front-matter of every plan file into a single `STATUS.md` (summary, sortable table, Mermaid Gantt). The plans hold the prose; the rollup holds the state. Regenerate on demand with a small script.

The point is **one file says what means what**. Without it, every consumer (a skill, a validator, a status dashboard) re-derives the mapping ad hoc and they drift apart. With it, there's a single failure point to update — and a single file to grep when you need to know whether a code / pattern / phase still applies.

### L. Name canonical sources for ambiguous terms at kickoff (or in a rule)

When the same noun refers to two different things in your codebase, the agent will pick the wrong one — silently, plausibly, and 30 minutes deep into a fix. The cheapest defense is one sentence at kickoff, or one block in a rule's front matter:

> **`<X>` is the canonical source for `<concept>`, not `<Y>`.**

A real example from this project: the word **"category"** referred to two distinct things in the same module (in-memory Ruby constant vs database column). See the "Same word, two referents" failure mode above for the full story. The kickoff statement "the database column is the canonical source for the LD gate; the in-memory constant is preview-only" would have saved the entire round-trip.

This generalizes to any term with a doppelgänger: `user.id` vs `user_id`; `tenant` (URL slug) vs `tenant` (DB document); `enabled?` (feature flag wrapper) vs `enabled?` (model attribute); the same column name appearing on two different tables. The agent has no way to know which one you mean without being told.

**How to operationalize it** (so you don't have to remember to say it every session):

1. **In the front matter of the rule that governs the topic, add a `sources_of_truth:` block** listing `<concept>: <file-or-symbol>` pairs:

   ```yaml
   ---
   description: MUST consult <Entity>.category (database column) — NOT KIND_CATEGORY (preview-only Ruby map) — when reasoning about the semantic_email_enabled_categories LD gate. Read whenever editing semantic email gating logic.
   globs:
     - "**/semantic_email_commands.rb"
     - "**/semantic_email_preview.rb"
   sources_of_truth:
     category_for_ld_gate: web/common/notifications/rules/notification_rule.rb (column `category`)
     category_for_preview_only: web/common/email/semantic/core/semantic_email_registry.rb (KIND_CATEGORY constant)
   alwaysApply: false
   ---
   ```

2. **If the ambiguity is system-wide, add a top-level `AGENTS.md` (or repo-level rule) with a "Canonical sources" table** listing every doppelgänger in the codebase. This file becomes the single place to grep when the agent confuses terms — and the front-matter `sources_of_truth:` blocks in individual rules can cross-reference it.

3. **At kickoff for any session that touches an ambiguous concept, paste the canonical-source statement directly into the chat:** "Reminder: `<X>` is the canonical source for `<concept>`, not `<Y>`." This is cheap insurance for terms that aren't yet captured in any rule, and it lets you ratchet the rule library forward — each new doppelgänger you have to name in chat is a candidate for a permanent `sources_of_truth:` entry.

**Why a one-liner beats prose:** the agent reads grep results first and rule prose second. If the wrong source is more grep-visible, you lose by default. A single declarative line — at kickoff or in front matter — names the winner before the search even happens.

**Relationship to Pattern F.** Pattern F ("Anchor the mandate to source files") tells you to cite the file that *enforces* a constraint. Pattern L tells you to name the file that *defines* a concept when more than one file claims to. They compose: a rule with both points at the validator (F) and the source of truth (L), so the agent can't confuse "where the constraint lives" with "what the constraint is about".

---

## Authoring checklist

Before saving a new `.cursor/rules/*.mdc` or `.cursor/skills/*/SKILL.md`:

- [ ] **Description is imperative.** Names the critical action verbatim. Uses MUST / MUST NOT, not "should".
- [ ] **Globs point at paths that exist** in the current tree. Verified with `rg --files -g '<glob>' | head -1` or via an audit script (see Maintenance below).
- [ ] **Scope matches the topic.** If the topic applies broadly (e.g. i18n keys, secrets, logging), use `alwaysApply: true` or `globs: ["**/*.<lang>"]`. Narrow globs are for genuinely file-shaped concerns.
- [ ] **Single topic.** No `## Part N:` headings. If you have more than one topic, split into multiple files. If a skill grows past ~300 lines or covers more than one symptom, split into a sibling bundle (Pattern J).
- [ ] **Cross-references resolve.** `related_skills:` front-matter and markdown links to other skills/plans must name real targets.
- [ ] **Mandates are anchored to source files.** Cite the validator, the generator, the existing call sites.
- [ ] **At least one verification command** is included inline.
- [ ] **Cost of violation is documented** inline so the consequence is impossible to miss.
- [ ] **Commit-time enforcement is referenced if it exists.** If not, the rule notes the gap explicitly.
- [ ] **Cross-references use imperative voice.** "MUST read X before writing Y" with the actual command inline, not passive prose ("for more, see X").
- [ ] **Critical mandates are above the fold** — first 100 lines for skills, first section for rules.
- [ ] **Evolving taxonomies have a source-of-truth index** (Pattern K). If your skill claims a `[RULE:*]` code or a phase letter, the mapping lives in one indexed file, not re-derived by each consumer.
- [ ] **Doppelgänger terms named** (Pattern L). If the topic involves a noun that means two things in the codebase (e.g. two `category` fields, two `tenant` concepts, an attribute that shadows a method), the rule's front matter has a `sources_of_truth:` block naming which file is canonical for each.

---

## Maintenance

A small set of periodic hygiene checks keeps rules and skills from rotting. The snippets below work as-is in any repo; if you want them to survive turnover, promote them into named, committed scripts in your `.cursor/rules/` folder.

### 1. Dead globs

```bash
for f in .cursor/rules/*.mdc; do
  globs=$(awk '/^globs:/,/^alwaysApply:|^---/' "$f" | grep -oE '"[^"]+"' | tr -d '"')
  for g in $globs; do
    count=$(rg --files -g "$g" 2>/dev/null | head -1 | wc -l)
    [ "$count" -eq 0 ] && echo "DEAD-GLOB $f -> $g"
  done
done
```

If you run this from `$HOME` and your rules use `**/.cursor/...` patterns, prefer a Python-backed implementation that short-circuits `**/.cursor/` directly against `$HOME/.cursor/`; otherwise bash's `globstar` will recurse through every repo's `node_modules` and `.git`. A reference implementation is in this repo at [`../scripts/_audit_globs.sh`](../scripts/_audit_globs.sh).

### 2. Inert rules (no globs + `alwaysApply: false`)

```bash
for f in .cursor/rules/*.mdc; do
  has_globs=$(grep -c '^globs:' "$f")
  apply=$(grep -E '^alwaysApply:' "$f" | grep -oE 'true|false')
  [ "$has_globs" -eq 0 ] && [ "$apply" = "false" ] \
    && echo "INERT-RULE $f"
done
```

These rules will never auto-attach. Either give them globs, flip `alwaysApply: true`, or delete them.

### 3. Broken cross-references

For each skill, check that every `related_skills:` entry and every markdown link to another skill or plan file resolves to a real target. A simple Python or bash audit catalogs all skills and plans, scans every `*.md` and `*.mdc` for references, and reports anything that doesn't resolve. A reference implementation is in this repo at [`../scripts/_audit_crossrefs.sh`](../scripts/_audit_crossrefs.sh).

### 4. When to run

- **After renaming a source directory:** run check 1 in the same PR as the rename.
- **After editing `related_skills:` or adding a markdown skill link:** run check 3.
- **Weekly hygiene:** run all three.

The point is to move from advisory ("here's a snippet you could run") to **named, committed, easy-to-invoke** tools that survive turnover. A snippet pasted in a doc doesn't run by itself; a script with a one-line invocation gets run.

---

## Worklog entry types

If your team keeps an AI-assisted-work log (recommended — see "Adoption guide" below), tag every entry with a `**Type:**` field so future readers and any automated weekly-summary tooling can parse them:

| Type | Use when | Required fields beyond the basics |
|---|---|---|
| `milestone` | Shipping a discrete unit of work — PR opened, plan accepted, feature complete | Repo, Branch, Files Changed (or PR link) |
| `mid-session` | Capturing in-flight progress during a long session in case it gets interrupted | Status: in_progress; Pending list |
| `investigation` | A diagnosis / spike that produced findings but no code change | Question being answered; Findings; Next steps |
| `post-mortem` | After-action analysis of a bug, incident, or cascade — typically follows a `milestone` | Timeline; Root cause; Fix; Prevention added |

A `post-mortem` entry's **Prevention added** field is the most important line in the entry — it names the rule, skill, validator code, pre-commit hook, or CI job that would have caught the issue. `(none — accepted residual risk)` is a valid value but must be documented. Without it, the post-mortem is just storytelling; with it, the team's defenses ratchet forward one increment at a time.

The incidents narrated in this document would all have been `post-mortem` entries under this scheme. The i18n incident's **Prevention added** lines, after the fact, were: (a) extract `i18n-keys.mdc` with imperative description and broad globs, (b) add inline verification command, (c) flag the lack of a commit-time hook as an open item.

---

## Adoption guide

If you're starting a `.cursor/rules/` or `.cursor/skills/` discipline on a new team, here's the minimum viable setup:

1. **One topic per rule.** No `## Part N:` headings. Resist the urge to bundle.
2. **Description first.** Spend more time on the front-matter `description:` than the rule body. The description is the gatekeeper that decides whether the agent reads the rule at all.
3. **Imperative voice.** MUST / MUST NOT. Name the command. Describe the trigger.
4. **Verify the globs.** A 5-line audit script is cheap insurance.
5. **Anchor to source.** Every mandate cites a file path.
6. **Name canonical sources.** Whenever a noun in your codebase has two referents (two `category` fields, two `tenant` concepts, an attribute that shadows a method), declare the winner in a `sources_of_truth:` front-matter block on the relevant rule, or in a top-level `AGENTS.md` canonical-sources table (Pattern L). If you don't, the agent will grep, land on the wrong one, and reason from there.
7. **Verification inline.** Every rule ships a self-check command.
8. **Commit-time hook for the load-bearing rules.** Audit scripts catch authoring-time decay; pre-commit hooks catch use-time violations. You need both.
9. **Worklog with typed entries.** When something goes wrong, log a `post-mortem` entry with the *Prevention added* field naming the rule, hook, or test that would have caught it.

The compounding return: every `post-mortem` entry's *Prevention added* line is a small ratchet forward in the team's safety net. Six months in, you'll have a body of rules and audit scripts shaped by your actual failure modes — not by a generic checklist a vendor handed you.

---

## What this document does not solve

- **Cursor product behavior around repo-local skill surfacing.** That's a feature-request / config-investigation question, not something a rule or doc can fix on its own. If your repo-local skill is critical, lift it (or its critical mandate) into a user-level rule or a published plugin.
- **Commit-time enforcement at the language layer.** The audit scripts in this doc catch authoring-time decay (dead globs, broken references). Catching a violation at commit time still needs a language-aware pre-commit hook or lint cop. The rules will continue to be advisory at the git layer until then.
- **A community-maintained framework-reload rule library.** Every Rails / Padrino / Spring / Vite / Next codebase has a "this looks like normal code but doesn't reload" footgun. A shared list of one-line MUSTs per framework would save many hours across many teams. Pull requests welcome.
- **PM-or-lead-feedback-to-rule audits.** Recurring style feedback ("we always X", "we never Y") is rule-shaped. A proactive sweep of past review threads would surface the next few rules before they're needed. No tooling exists for this today.
- **Mock-data / fixture drift.** When validation logic and runtime logic depend on the same constant or fixture, drift is just a matter of time unless something — a shared source-of-truth file, or a rule mandating co-update — enforces alignment.

---

## References

- The author's user-level companion rule for rule authoring: `~/.cursor/rules/effective-cursor-rules.mdc`. Auto-attaches when editing any `.cursor/rules/*.mdc` or `.cursor/skills/*/SKILL.md` on the author's machine.
- Cursor's official documentation: <https://docs.cursor.com>.
- For a worked example of how Patterns J and K were applied in practice — including the artifact catalog (~20 plans, 19 rules, 18 skills) that the migration project relies on — see this repo's [`semantic-email-migration-artifacts.md`](semantic-email-migration-artifacts.md).

---

*Feedback, corrections, and additional failure modes welcome — open an issue or PR on this repo.*
