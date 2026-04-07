# Templates

This file holds the templates for: drawers, the four index files, and `_closet.md` files.

---

## Drawer template (used by `remember` and `new-drawer`)

```markdown
---
valid_from: {{DATE}}
valid_until: null
wing: {{WING}}
room: {{ROOM}}
hall: {{HALL}}
tags: [{{TAGS}}]
source: {{SOURCE}}
related: []
confidence: {{CONFIDENCE}}
tldr: "{{TLDR}}"
palace_version: 1
routed_by: {{ROUTED_BY}}
---

# {{TITLE}}

## Background
{{Why does this matter? What was the situation that produced this knowledge?}}

## Core content
{{The main content. Verbatim from the user where possible. Use full sentences,
not fragments. If there's code, embed it as fenced blocks. If there's a
decision, state the decision and the reasoning. If there's a discovery,
explain what was expected vs what was found.}}

## Open questions
{{Anything still uncertain or pending. Use a bulleted list. Leave the section
out if there's nothing.}}

## See also
{{Links to related drawers, manuals, or external URLs. Use markdown link
syntax. Leave the section out if there's nothing.}}
```

When using this template:
1. Fill in `{{...}}` placeholders
2. Remove any sections that are empty (don't leave a blank "## Open questions" header)
3. The `# {{TITLE}}` H1 should match (or summarize) the `tldr` in the frontmatter

---

## Index file: `user.md` (L1 — about the user)

```markdown
# User Memory — {{USER_NAME}}

> **L1 wake-up layer.** This file is auto-loaded by Claude Code at session
> start. Keep it short (target < 1500 tokens). It is an INDEX, not content —
> it lists wings and points into `wings/<name>/_closet.md` for detail.

## About

{{1-3 sentences about the user, their role, location, working style. Keep it
factual and current.}}

## Wings indexed here

{{Each wing that lives "in the user's world" gets a row here. Updated by
the routing prompt when a new wing is created.}}

| Wing | Description | Closet |
|---|---|---|
| `personal` | Habits, schedule, health, family | [link](./wings/personal/_closet.md) |
| `people` | Collaborators and contacts | [link](./wings/people/_closet.md) |

## Navigation
- All wings: [`wings/`](./wings/)
- Global timeline: [`timeline.md`](./timeline.md)
- Recent audits: [`audits/`](./audits/)
- Active project index: [`project.md`](./project.md)
- Reference index: [`reference.md`](./reference.md)
- Recent corrections / agent diary: [`feedback.md`](./feedback.md)

## Latest top-of-mind

{{1-5 bullets the user wants Claude to remember at every session start.
This is the "current state" snapshot, kept short. Updated manually or by
explicit /mp remember --to-top.}}

---
*This file is auto-managed by the memory-palace skill. Edit with care; the
routing prompt may overwrite the wing table.*
```

---

## Index file: `project.md` (L1 — active projects)

```markdown
# Project Memory

> **L1 wake-up layer.** Lists active projects (one wing per major project,
> one room per sub-project). Auto-loaded by Claude Code at session start.

## Active project: {{CURRENT_PROJECT}}

{{2-4 sentences about the current project: what it is, what stage, what
the user is working on right now.}}

## Wings indexed here

| Wing | Description | Closet |
|---|---|---|
| `projects` | All active projects | [link](./wings/projects/_closet.md) |

## Project rooms

{{Each room under wings/projects/ is listed here. Format:
- **<room>** — one-line description ([closet](./wings/projects/<room>/_closet.md))
}}

## Recently touched

{{The 5 most recently updated drawers across all project rooms. Auto-updated
by the timeline command.}}

---
*Auto-managed by the memory-palace skill.*
```

---

## Index file: `reference.md` (L1 — tools, servers, manuals)

```markdown
# Reference Memory

> **L1 wake-up layer.** Indexes wings of reference material — servers, tools,
> infrastructure, knowledge bases. Auto-loaded by Claude Code at session start.

## Wings indexed here

| Wing | Description | Closet |
|---|---|---|
| `infrastructure` | Servers, deploy pipelines, CLI tools | [link](./wings/infrastructure/_closet.md) |
| `knowledge` | General reference material and docs | [link](./wings/knowledge/_closet.md) |

## Quick lookup

{{Compact list of the most-accessed reference items. Format:
- **<topic>** → [drawer or room link]
}}

## Servers

{{If there are server rooms under infrastructure, list them here as a quick
table:
| Server | User | Port | Notes |
|---|---|---|---|
}}

---
*Auto-managed by the memory-palace skill.*
```

---

## Index file: `feedback.md` (L1 — recent corrections / diary head)

```markdown
# Feedback & Recent Corrections

> **L1 wake-up layer.** Append-only log of corrections, course-changes, and
> recent learnings the user wants Claude to keep top-of-mind. Auto-loaded
> at session start. Trim to last 30 entries periodically.

## Recent corrections

{{Each entry is a bullet with date prefix. Newest at top.}}

- **{{DATE}}** — {{Correction or course-change. 1-3 lines max.}}

## Recent discoveries promoted to top-of-mind

{{Discoveries from /mp remember that the user explicitly flags as "important
enough to keep in wake-up". Format:
- **DATE** — TLDR ([drawer link](./wings/.../drawer.md))
}}

## Open questions

{{Things the user asked that we couldn't answer, kept here so the next
session can pick them up. Auto-added by /mp recall when no result is found.}}

---
*Auto-managed by the memory-palace skill. Trim manually or via the trim
command (TBD).*
```

---

## `_closet.md` template (for wings and rooms)

```markdown
---
last_generated: {{DATE}}
scope: {{room|wing}}
wing: {{WING}}
room: {{ROOM}}            # only present for room-scoped closets
generated_from: {{N}} entries
---

# {{WING}}{{/ROOM}} — Closet

## What this {{room|wing}} is about

{{1-2 sentences describing the topic.}}

## Key facts

{{3-5 bulleted facts pulled from facts.md. The most durable, most often
referenced ones.}}

## Recent events (last 30 days)

{{2-3 events from events.md.}}

## Notable discoveries

{{1-3 discoveries from discoveries.md, the most surprising or
practically-useful ones.}}

## Active advice

{{1-2 advice items from advice.md, the ones that apply to current work.}}

## Most-referenced drawers

{{2-3 drawer links — the ones with the most inbound `related:` references,
or the longest, or the most cited in conversations.}}

## Tunnels

{{Cross-wing links, if any. Empty section if none.}}

---
*Generated by `/mp closet`. Re-run when content drifts.*
```

---

## `timeline.md` template (initial state)

```markdown
# Palace Timeline

> Newest first. Auto-updated by `remember`, `migrate-from`, and other
> write commands.

## Latest entries

{{Format per entry:
- **YYYY-server-c-DD** [wing/room/hall] **Title** — short summary ([link](./wings/...))
}}

---
*Auto-managed. Use `/mp timeline` to query.*
```
