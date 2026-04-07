# Halls Guide — Which Hall Does This Memory Belong To?

A memory always belongs to **exactly one** hall. This document gives the judgement rules.

## The five halls

| Hall | Asks | Mood |
|---|---|---|
| `facts.md` | What is true? | Static, declarative |
| `events.md` | What happened? | Dynamic, dated |
| `discoveries.md` | What did I learn? | Insight, surprise |
| `preferences.md` | What do I/we want? | Subjective, taste |
| `advice.md` | What should be done (next time)? | Prescriptive, future-oriented |

## Detailed definitions

### `facts.md` — durable factual claims

**What goes here**: Things that are true *now* and expected to remain true for a long time. Architecture decisions, configuration details, ownership, structural reality.

**Positive examples**:
- "Production database is Postgres 16 on AWS RDS"
- "Alex uses NVM with Node 22 by default"
- "The Telegram bot for server-b is `@my_appship_bot`"
- "server-a server runs as root, server-c and server-b run as `ubuntu`"

**Negative examples** (don't put these in facts):
- ❌ "I deployed the bot today" → that's an **event**
- ❌ "Alex prefers terse error messages" → that's a **preference**
- ❌ "Bypass mode doesn't bypass channel relay" → that's a **discovery**

**Tiebreakers**:
- If a fact has a clear "as of date" and might change: still a fact, but include the date in the body
- If you can't say it without using a verb in past tense ("we did X"): probably an event, not a fact

### `events.md` — things that happened on a specific date

**What goes here**: Time-anchored occurrences. Deployments, meetings, milestones, debugging sessions, important user interactions.

**Positive examples**:
- "2026-04-07 — deployed Telegram bot to server-a server"
- "2026-04-06 — Alex and Claude discussed memory architecture, settled on markdown-native"
- "2026-04-05 — Anthropic blocked another AI client from Claude Pro/Max"
- "2026-04-07 14:30 — first end-to-end test of memory-palace skill"

**Negative examples**:
- ❌ "Alex goes to the gym 3x/week" → that's a recurring **preference/habit**, not an event
- ❌ "Claude Code 2.1.92 was released" → that's a **fact** (the release happened, but the fact is the version number)

**Tiebreakers**:
- If you wouldn't write the date in the bullet, it's not an event
- Recurring activities go in `preferences.md`, individual occurrences go in `events.md`
- "Decided X on date Y" is borderline: write the **decision** in `facts.md` and the **act of deciding** in `events.md` if both matter

### `discoveries.md` — insights, hidden knowledge, debugging finds

**What goes here**: Things that **surprised** you. Counterintuitive behaviors, undocumented quirks, debugging conclusions, "aha" moments. The kind of thing you'd want to put in a blog post called "Things I learned the hard way".

**Positive examples**:
- "`--dangerously-skip-permissions` does NOT bypass the Telegram channel permission relay because the plugin opts in via `'claude/channel/permission': {}`"
- "Claude Code's tmux session inherits env vars from start-claude.sh, but only on first launch — restart needed for changes"
- "AAAK compression is just clever shorthand, no special parsing — any LLM reads it natively"
- "another AI client stores memory in `MEMORY.md`, not in a database"

**Negative examples**:
- ❌ "We use Postgres" → that's just a **fact**, no surprise
- ❌ "Alex wants tabs not spaces" → that's a **preference**
- ❌ "Always re-run the patch after marketplace update" → that's **advice**

**Tiebreakers**:
- The litmus test: would you have **bet wrong** on this before learning it? If yes → discovery
- If the discovery has a "what to do about it" component, **split** it: the surprising thing → discovery, the action item → advice

### `preferences.md` — tastes, habits, opinions

**What goes here**: Subjective choices. The user's (or team's) preferred way of doing things. Recurring habits. Aesthetics. "We always do X because we like it that way."

**Positive examples**:
- "Alex prefers terse error messages over verbose ones"
- "Alex goes to the gym 3 times per week, mornings"
- "Alex wants commit messages in English, not Chinese"
- "Alex dislikes emoji in code comments unless explicitly requested"
- "We use 4-space indentation in Python, 2 in JS"

**Negative examples**:
- ❌ "Production uses Postgres" → that's a **fact**, not a taste
- ❌ "Alex drank coffee at 9 AM today" → that's an **event** (or just noise)

**Tiebreakers**:
- Subjective vs objective: if reasonable people could disagree, it's a preference
- If the preference has a hard reason ("we use Postgres because of jsonb columns"), the **why** is a fact and the **choice** is a preference — record both

### `advice.md` — recommendations and warnings for future-self

**What goes here**: Prescriptive guidance. "Next time you do X, remember Y." Postmortem lessons. Don't-do-this warnings. Procedure refinements.

**Positive examples**:
- "Always re-apply the Telegram plugin patch after `claude plugin marketplace update`, since updates overwrite `server.ts`"
- "Before deploying to a new server, test ssh + tmux + nvm independently first to isolate failures"
- "Don't reuse another AI client's bot token for Claude Code — it causes 409 conflicts"
- "When debugging silent Telegram failures, check `pendingPermissions` before checking the network"

**Negative examples**:
- ❌ "We had a 409 conflict last week" → that's an **event**
- ❌ "Bot tokens should be unique per process" → that's a **fact** (true regardless of context)

**Tiebreakers**:
- Advice is **always future-oriented** — if you're describing what happened, it's an event/discovery; if you're describing what *to do*, it's advice
- A discovery + an action item = two separate entries, one in discoveries, one in advice (cross-link them via frontmatter `related:`)

---

## When in doubt: the order of preference

If a memory genuinely fits multiple halls, use this priority:

1. **`advice`** — prescriptive content beats descriptive content for future utility
2. **`discoveries`** — surprises beat plain facts
3. **`preferences`** — subjective beats objective if both apply
4. **`events`** — dated beats undated
5. **`facts`** — the catch-all default

Why? Because the most actionable / hardest-to-recover memory types should win. Facts are easy to rediscover; advice is born from pain.

## Splitting rule

If a single user input contains multiple kinds of content, **split it** into multiple memories before routing. Example:

> "Today I deployed the bot to server-a (`./deploy.sh gali`). I discovered that the script doesn't include a `--channels` flag by default, which means the Bun MCP server never starts. I should add that flag to the default template, and I should also write a sanity check in the script that errors out if `--channels` is missing."

This is **three** memories:
1. **Event** → `events.md`: "2026-04-07 deployed bot to server-a"
2. **Discovery** → `discoveries.md`: "deploy.sh's default doesn't include `--channels` flag → Bun MCP server never starts"
3. **Advice** → `advice.md`: "Add `--channels` to default template; add sanity check that errors if missing"

The routing prompt should detect this and call `remember` three times. Don't merge multi-flavor input into one bullet.

## Anti-patterns

- **The "miscellaneous" hall** — there isn't one. If something doesn't fit, it's probably **not memorable** and should be skipped, OR it indicates a missing wing/room.
- **Stuffing facts into discoveries** — if you can't say it surprised someone, it's not a discovery.
- **Advice without a context** — "always be careful" is useless. Advice must specify when/where it applies.
- **Events without dates** — if you can't put a date on it, it's not an event.
- **Preferences as facts** — "the database is Postgres" is a fact; "I like Postgres" is a preference. Don't blur them.
