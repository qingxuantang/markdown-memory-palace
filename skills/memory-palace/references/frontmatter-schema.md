# Frontmatter Schema

Every drawer file MUST start with YAML frontmatter. This document defines the schema.

## Required fields

| Field | Type | Description |
|---|---|---|
| `valid_from` | date (`YYYY-server-c-DD`) | When this fact / event / decision started being true |
| `wing` | string | Which wing the drawer lives in (must match the directory) |
| `room` | string | Which room the drawer lives in (must match the directory) |
| `hall` | enum | One of `facts`, `events`, `discoveries`, `preferences`, `advice` |
| `source` | enum | One of `claude-code-session`, `openclaw-session`, `manual`, `imported` |

## Optional fields

| Field | Type | Description |
|---|---|---|
| `valid_until` | date or `null` | When the fact stopped being true; `null` means still valid |
| `tags` | list of strings | Free-form tags for cross-cutting search |
| `related` | list of relative paths | Other drawers that are related (manual or via tunnels) |
| `superseded_by` | relative path | Points to a newer drawer that replaces this one |
| `imported_from` | string (path) | Original file path if `source: imported` |
| `confidence` | enum (`high`/`medium`/`low`) | How sure are we? Low-confidence drawers are candidates for `check` to verify |
| `aliases` | list of strings | Alternative titles to help search |
| `tldr` | string | One-line summary (used in `recall` previews and timeline) |

## Reserved (skill-internal)

| Field | Type | Description |
|---|---|---|
| `palace_version` | int | Schema version (currently 1) |
| `routed_by` | string | `route-new-memory` if auto-routed; `manual` if user-created |

## Full example

```yaml
---
valid_from: 2026-04-07
valid_until: null
wing: infrastructure
room: web-api
hall: discoveries
tags: [telegram, plugin, permissions, channel-relay]
source: claude-code-session
related:
  - ../../../infrastructure/gali/drawers/2026-04-07-permission-spam.md
superseded_by: null
confidence: high
tldr: "Telegram plugin opts in to permission relay via 'claude/channel/permission' capability, bypassing --dangerously-skip-permissions"
palace_version: 1
routed_by: route-new-memory
---
```

## Validation rules

When writing a drawer:

1. **`valid_from` must not be in the future**. If the user says "remember that next month X will happen", it's an `event` to be added later, not now.
2. **`hall` must match the parent directory's hall structure**. If the drawer lives under a `facts/`-implied location, hall must be `facts`. The skill enforces this by writing the file in the correct folder.
3. **`wing` and `room` must match the file path**. Don't write conflicting metadata.
4. **`source` must be set**. Never leave it blank.
5. **`tldr` should be ≤ 120 characters**. It's shown in compact contexts.

## When to update frontmatter

- **Alexing superseded**: When a new drawer overrides an old one, add `superseded_by: <new-path>` to the **old** drawer. Don't delete it. The contradiction check will use this to disambiguate.
- **Closing validity**: When a fact stops being true, set `valid_until: <date>` on the old drawer. Then create a new drawer with the new fact.
- **Adding tags retroactively**: Allowed; it's non-destructive.
- **Changing `wing` or `room`**: Requires moving the file. Don't do this without a `/mp move` operation (which doesn't exist yet — for now, do it manually + commit).

## Hall files (facts.md, events.md etc.) — no frontmatter

Hall files do NOT have frontmatter. They're append-only logs of bullets and `## H2` sections. Each entry should have an inline date prefix:

```markdown
- **2026-04-07** — Production DB migrated from Postgres 14 to 16 [source: claude-code-session]
```

For section-style entries:

```markdown
## 2026-04-07 — DB migration to Postgres 16

We upgraded the production database from Postgres 14 to 16 to get the new
JSON path syntax. Migration took 22 minutes with no downtime, using
pg_upgrade in link mode.

*source: claude-code-session* · *tags: postgres, migration, db*
```

## Closet files (`_closet.md`) — light frontmatter

Closets DO have a small frontmatter block, used by the `closet` command to track when they were last regenerated:

```yaml
---
last_generated: 2026-04-07
scope: room                # or "wing"
wing: infrastructure
room: web-api
generated_from: 47 entries
---
```
