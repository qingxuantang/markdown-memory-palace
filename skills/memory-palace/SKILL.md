---
name: memory-palace
description: A markdown-native long-term memory system for Claude Code, inspired by MemPalace's wings/rooms/halls/drawers structure but implemented entirely in plain files. Use whenever the user invokes /mp or /memory-palace, or asks to remember/recall/audit long-term knowledge.
---

# Memory Palace

A long-term memory system that gives Claude Code a structured, navigable, **plain-markdown** brain. Inspired by [MemPalace](https://github.com/milla-jovovich/mempalace) but built natively on Claude Code's file conventions:

- ✅ Lives at `~/.claude/projects/<cwd-slug>/memory/` so Claude Code auto-loads the L1 layer at startup
- ✅ Pure markdown + YAML frontmatter — no databases, no MCP servers, no external runtimes
- ✅ Compatible with any other AI client (e.g. another AI client) that can read files
- ✅ Git-friendly — history, diffs, blame, merge all work
- ✅ Zero format lock-in — you can leave at any time

## When to invoke this skill

**CRITICAL — This skill is triggered by natural-language keywords, NOT by typed slash commands.**

The user will almost never type `/mp <subcommand>` literally. Instead, they will say things like "把这个记一下" or "回忆一下 server-a 的部署" in the middle of normal conversation. Your job is to **listen for the trigger phrases below** and silently route to the correct subcommand. Slash commands still work as an explicit fallback, but treat natural-language triggers as the primary interface.

### Routing rules

1. When the user's message contains **any** trigger phrase below (Chinese or English, case-insensitive, partial match counts), route to the matching subcommand.
2. Trigger phrases can appear **anywhere** in the message — beginning, middle, or end. A phrase like "欸，你把刚才那段内容**记忆一下**吧，顺便告诉我还有什么没决定的" should fire BOTH `remember` AND `recall`.
3. When a trigger fires, **do not ask the user "did you mean /mp remember?"** — just execute. Only ask for clarification if the referent is ambiguous (e.g. "记一下" without any nearby content to remember).
4. When multiple subcommands could match, prefer the most specific one. Ties: `remember` > `recall` > `timeline` > others.
5. **Silently infer content from recent conversation.** If the user says "记一下" without specifying what, assume they mean the most recent substantive exchange (the last 1–3 turns of dialogue), extract the memorable points, and proceed. Do not make the user repeat themselves.
6. When in genuine doubt, confirm with the user in **one short sentence** — do not dump the whole subcommand table.

### Trigger phrases (中英双语，支持多关键词)

| Subcommand | English triggers | 中文触发词 |
|---|---|---|
| **`init`** | "init the palace", "set up memory palace", "initialize memory", "create the palace", "bootstrap memory" | "初始化记忆宫殿"、"建一下记忆宫殿"、"搭建记忆宫殿"、"开一个记忆宫殿"、"初始化一下记忆" |
| **`remember`** | "remember this", "remember that", "note this", "note that", "save this", "store this", "log this", "记 it down", "write this down", "add to memory", "keep this in mind" | "记一下"、"记下来"、"记录一下"、"记忆一下"、"记住"、"把这个记一下"、"把这段记一下"、"存一下"、"保存一下"、"归档一下"、"收录一下"、"把刚才的存起来"、"把这个放进记忆宫殿"、"记到记忆里"、"归类一下" |
| **`recall`** | "recall", "what do we know about", "what did we say about", "did we ever", "look up", "search memory", "find in memory", "remind me", "what was that about" | "回忆一下"、"回想一下"、"想一下之前"、"之前说过"、"我们之前"、"查一下记忆"、"找一下之前"、"搜一下记忆"、"记忆宫殿里有没有"、"提醒我一下"、"之前是怎么说的"、"以前我们怎么" |
| **`timeline`** | "show the timeline", "what happened", "timeline", "recent history", "what did we do" | "时间线"、"时间轴"、"最近做了什么"、"最近发生了什么"、"回顾一下最近"、"过去一周"、"最近的事件" |
| **`wake-up`** | "wake up", "reload memory", "refresh context", "re-read the palace", "load palace context" | "唤醒"、"唤醒记忆"、"重新加载记忆"、"刷新记忆"、"把记忆宫殿读一下"、"把上下文读回来"、"重新装载记忆" |
| **`new-drawer`** | "new drawer", "create a drawer", "open a drawer for", "start a drawer" | "新建抽屉"、"开一个抽屉"、"建一个抽屉"、"专门开个抽屉记" |
| **`list-wings`** | "list wings", "what wings", "show wings", "how is the palace organized" | "列出所有侧厅"、"有哪些侧厅"、"记忆宫殿有哪些分区"、"宫殿的结构"、"宫殿有哪几个区" |
| **`status`** | "palace status", "memory stats", "how big is the palace", "show palace stats" | "记忆宫殿的状态"、"记忆宫殿统计"、"宫殿多大了"、"记了多少"、"宫殿情况" |
| **`migrate-from`** | "migrate from", "import from", "bring in from", "ingest from", "pull memories from" | "从...迁移"、"从...导入"、"把...导入记忆宫殿"、"把...搬进来"、"把这个项目的文档导进来"、"批量导入" |
| **`check`** | "audit memory", "check for contradictions", "any conflicts in memory", "cross-check memory" | "审计记忆"、"检查矛盾"、"记忆里有没有冲突"、"对一下记忆"、"查一下有没有矛盾"、"审一下记忆" |
| **`closet`** | "refresh closets", "regenerate summaries", "update closet", "re-summarize the wing" | "刷新摘要"、"重新生成摘要"、"更新壁橱"、"重做一下 closet"、"重新总结一下这个侧厅" |
| **`tunnel`** | "link these rooms", "connect X and Y", "tunnel between", "cross-link" | "把...和...连起来"、"建一个通道"、"打通这两个房间"、"关联一下这两个" |
| **`export`** | "export the palace", "back up memory", "snapshot the palace", "dump the palace" | "导出记忆宫殿"、"备份记忆"、"把宫殿导出来"、"打包记忆宫殿"、"快照一下记忆" |

### Disambiguation examples

- **"把刚才这段讨论记一下"** → `remember`, content = the last few turns.
- **"我们之前是不是讨论过 server-a 的 self-edit guard？"** → `recall`, query = "server-a self-edit guard".
- **"记一下，然后顺便看看有没有矛盾"** → `remember` first, then `check`.
- **"把 D:\git_repo\foo 这个项目搬进来"** → `migrate-from`, path = `D:\git_repo\foo`.
- **"宫殿现在多大了？"** → `status`.
- **"唤醒一下，我们继续"** → `wake-up`.
- **"刚才那个 bug 的原因专门开个抽屉记一下"** → `new-drawer` with title inferred from context, then `remember` into it.

### What NOT to do

- ❌ Do not reply "please type `/mp remember`" — the user has explicitly opted out of typing commands.
- ❌ Do not ignore trigger phrases because they appear mid-sentence.
- ❌ Do not demand the user specify wing/room/hall — that's what `route-new-memory.md` is for.
- ❌ Do not confirm every single action verbosely — only confirm when the permission policy requires it (new wing, delete, etc.).
- ❌ Do not fail silently when a trigger fires — always give a short one-line acknowledgment ("✓ 记到 infrastructure/web-api/discoveries").

---

## Global conventions

### Path resolution

The "palace root" for a session is computed from the current working directory:

```
PALACE_ROOT = ${CLAUDE_HOME}/projects/<cwd-slug>/memory/
```

Where:
- `${CLAUDE_HOME}` is `~/.claude` (`$HOME/.claude` on Unix, `%USERPROFILE%\.claude` on Windows)
- `<cwd-slug>` is the absolute current working directory transformed by:
  1. Lowercase the drive letter on Windows (`D:` → `d:`) — keep it consistent
  2. Replace `\` with `/`
  3. Replace `/` with `-`
  4. Replace `:` with `-`
  5. Strip leading `-`

**Examples**:
- Linux cwd `/home/ubuntu` → slug `home-ubuntu` → `~/.claude/projects/-home-ubuntu/memory/` (Claude Code's existing convention preserves the leading `-`, so use `-home-ubuntu`)
- Windows cwd `D:\git_repo\claude-code-web-api` → slug `d--git_repo-claude-code-web-api`

To get the canonical slug Claude Code itself uses, run `pwd` and apply the transform. If a directory already exists under `~/.claude/projects/` matching the cwd, **prefer that exact name** rather than recomputing.

### Directory layout (the palace)

```
${PALACE_ROOT}/
├── user.md             # L1 醒脑层 - facts about the user (Alex)
├── project.md          # L1 醒脑层 - active project index
├── reference.md        # L1 醒脑层 - tools/servers/manuals index
├── feedback.md         # L1 醒脑层 - recent corrections / agent diary head
├── timeline.md         # global timeline, newest first
├── .palace-config.yaml # skill config
│
├── wings/
│   └── <wing-name>/
│       ├── _closet.md
│       └── <room-name>/
│           ├── _closet.md
│           ├── facts.md
│           ├── events.md
│           ├── discoveries.md
│           ├── preferences.md
│           ├── advice.md
│           └── drawers/
│               └── YYYY-server-c-DD-<slug>.md
│
└── audits/
    └── YYYY-server-c-DD-<scope>.md
```

**Rules**:
1. Never write user-facing content into `.palace-config.yaml` — it's pure metadata.
2. Never delete existing memory without explicit user confirmation; mark superseded content with `valid_until` or `superseded_by` in frontmatter instead.
3. Never write into `audits/` from `remember` — only `check` writes audits.
4. Always update `timeline.md` when adding a new drawer or a new bullet to `facts.md` / `events.md` / `discoveries.md`.

### Default wings

When `init` runs, the palace starts empty (no wings created), but the routing prompt knows about these **canonical wing types**:

| Wing | Purpose |
|---|---|
| `personal` | Things about the user themself: preferences, habits, schedule, health, family |
| `projects` | Active projects (one room per project) |
| `infrastructure` | Servers, deploy pipelines, tools, dotfiles, CLI workflows |
| `people` | Collaborators, clients, contacts the user works with |
| `knowledge` | General reference material that doesn't fit a specific project |

These are **suggestions, not constraints** — `route-new-memory.md` may propose new wings. New wings always require user confirmation (see "Permission policy" below).

### Halls (the five categories within each room)

Every room contains these five files:

| Hall | What goes here | Examples |
|---|---|---|
| `facts.md` | Locked, durable, factual claims | "Production DB is Postgres 16 on AWS RDS" |
| `events.md` | Things that happened at a specific time | "2026-04-07 deployed Telegram bot to server-a" |
| `discoveries.md` | Insights, breakthroughs, debugging knowledge | "`--dangerously-skip-permissions` doesn't bypass channel relay" |
| `preferences.md` | Tastes, habits, opinions | "Alex prefers terse error messages over verbose ones" |
| `advice.md` | Recommendations and warnings for future-self | "Always re-apply the plugin patch after `marketplace update`" |

The detailed judgement rules live in `references/halls-guide.md`. Read it before running `remember` if there's any ambiguity.

### Permission policy (decision B from design)

| Action | Confirmation needed? |
|---|---|
| Append a bullet to an existing hall file | No (silent) |
| Create a new drawer in an existing room | No (silent) |
| Create a new room in an existing wing | No (silent) — but show the user what was created |
| **Create a new wing** | **Yes, ask before creating** |
| Modify an existing drawer's frontmatter | No (silent) |
| Delete or move existing memory | **Yes, always ask** |
| Write an audit report | No (silent — audits are non-destructive) |

### Drawer threshold (decision 6)

When `remember` decides whether content goes into a hall bullet or its own drawer:

| Content length | Storage |
|---|---|
| < 300 characters | Append as bullet to `<hall>.md` |
| 300–800 characters | Add as `## H2` section inside `<hall>.md` |
| > 800 characters **or** spans multiple decisions/code blocks/steps | Create a drawer file under `drawers/` and link from the hall file |

### Frontmatter

Every drawer file MUST have YAML frontmatter. See `references/frontmatter-schema.md` for the full schema. Minimal example:

```yaml
---
valid_from: 2026-04-07
valid_until: null
wing: infrastructure
room: web-api
hall: discoveries
tags: [telegram, plugin, permissions]
source: claude-code-session
---
```

### Source tags

`source` field values:
- `claude-code-session` — recorded during a Claude Code session
- `openclaw-session` — recorded during an another AI client session (when migrated)
- `manual` — user wrote it directly in their editor
- `imported` — brought in via `migrate-from`

---

## Subcommand routing

Detect the subcommand from the user's invocation. Below is the dispatch table — each entry links to the section in this file or to a prompt.

| Command | Section |
|---|---|
| `/mp init` | [§1](#1-init) |
| `/mp remember <text>` | [§2](#2-remember) |
| `/mp recall <query>` | [§3](#3-recall) |
| `/mp timeline [wing]` | [§4](#4-timeline) |
| `/mp wake-up` | [§5](#5-wake-up) |
| `/mp new-drawer <wing>/<room> <title>` | [§6](#6-new-drawer) |
| `/mp list-wings` | [§7](#7-list-wings) |
| `/mp status` | [§8](#8-status) |
| `/mp migrate-from <path>` | [§9](#9-migrate-from) |
| `/mp check <wing>\|all` | [§10](#10-check) — PR2 |
| `/mp closet <wing>[/<room>]` | [§11](#11-closet) — PR2 |
| `/mp tunnel <wing-a>/<room> <wing-b>/<room>` | [§12](#12-tunnel) — PR2 |
| `/mp export <target>` | [§13](#13-export) — PR2 |

If the user invokes a subcommand not listed here, say so and offer the closest matches.

---

## §1. init

**Purpose**: Create the palace skeleton in the current cwd's memory directory.

**Steps**:

1. **Resolve `PALACE_ROOT`** from cwd (see "Path resolution" above). Use `pwd` via Bash.

2. **Check for existing palace**:
   ```bash
   test -f "${PALACE_ROOT}/.palace-config.yaml"
   ```
   - If exists: ask the user `abort / merge / overwrite`. Abort = stop. Merge = leave existing files, only create what's missing. Overwrite = back up old to `${PALACE_ROOT}.bak.YYYYMMDD-HHMMSS` then re-init.

3. **Create directories**:
   ```bash
   mkdir -p "${PALACE_ROOT}/wings" "${PALACE_ROOT}/audits"
   ```

4. **Write `.palace-config.yaml`** at `${PALACE_ROOT}/.palace-config.yaml`:
   ```yaml
   palace_version: 1
   created: <YYYY-server-c-DD>
   created_by: memory-palace skill
   cwd_slug: <slug>
   default_wings: [personal, projects, infrastructure, people, knowledge]
   halls: [facts, events, discoveries, preferences, advice]
   drawer_threshold_chars: 800
   inline_section_threshold_chars: 300
   ```

5. **Write the four index files** (only if they don't exist — never overwrite existing). Use the templates in `references/drawer-template.md` (the index templates section).

6. **Write `timeline.md`** with an empty header.

7. **Print summary**:
   ```
   ✓ Initialized palace at ${PALACE_ROOT}
     - 4 index files (user, project, reference, feedback)
     - 1 timeline
     - 0 wings
   Next: `/mp remember <text>` to store your first memory.
   ```

---

## §2. remember

**Purpose**: Store a new memory. Auto-route to wing/room/hall.

**Steps**:

1. **Resolve `PALACE_ROOT`** and verify it exists (run `init` first if not — ask the user).

2. **Load context**:
   - Read `.palace-config.yaml`
   - Read all four index files (`user.md`, `project.md`, `reference.md`, `feedback.md`)
   - Glob `wings/*/_closet.md` and read them — this is the "topology snapshot" the routing prompt needs

3. **Run the routing prompt** at `prompts/route-new-memory.md`. Pass it:
   - The user's text
   - The topology snapshot
   - The wing list from config

   The prompt returns a JSON-shaped decision:
   ```json
   {
     "wing": "infrastructure",
     "wing_is_new": false,
     "room": "web-api",
     "room_is_new": true,
     "hall": "discoveries",
     "storage": "drawer",   // "bullet" | "section" | "drawer"
     "slug": "channel-permission-relay-bypass",
     "title": "Channel permission relay bypasses --dangerously-skip-permissions",
     "summary": "One-line preview shown to the user",
     "tags": ["telegram", "plugin", "permissions"],
     "valid_from": "2026-04-07"
   }
   ```

4. **Confirmation gate**:
   - If `wing_is_new == true`: **stop and ask the user**:
     ```
     This memory looks like it needs a new wing: `<wing>`.
     Existing wings: <list>.
     Create new wing `<wing>`? [y/n/rename]
     ```
   - Otherwise proceed silently. (Room creation is silent per decision B.)

5. **Apply the decision**:

   **For `storage: "bullet"`** (< 300 chars):
   - Ensure the room exists: `mkdir -p wings/<wing>/<room>/drawers` and create empty hall files if missing
   - Append to `wings/<wing>/<room>/<hall>.md`:
     ```markdown
     - **YYYY-server-c-DD** — <text> [source: claude-code-session]
     ```

   **For `storage: "section"`** (300–800 chars):
   - Append to `wings/<wing>/<room>/<hall>.md`:
     ```markdown
     ## YYYY-server-c-DD — <title>

     <body>

     *source: claude-code-session* · *tags: tag1, tag2*
     ```

   **For `storage: "drawer"`** (> 800 chars):
   - Create `wings/<wing>/<room>/drawers/YYYY-server-c-DD-<slug>.md` using the drawer template (see `references/drawer-template.md`)
   - Append a one-line link to `wings/<wing>/<room>/<hall>.md`:
     ```markdown
     - **YYYY-server-c-DD** — [<title>](./drawers/YYYY-server-c-DD-<slug>.md) — <summary>
     ```

6. **Update `timeline.md`** by prepending (newest first):
   ```markdown
   - **YYYY-server-c-DD** [<wing>/<room>/<hall>] <title> — <summary> ([link](./wings/<wing>/<room>/...))
   ```

7. **Update the relevant index file** if a new wing was just created. Add a row under "## Wings" in the appropriate index (e.g. an `infrastructure` wing usually goes in `reference.md`; the routing prompt should also tell you which index to update).

8. **Print summary**:
   ```
   ✓ Remembered in wings/<wing>/<room>/<hall>.md (storage: <bullet|section|drawer>)
   → Drawer: <path>          (only if drawer was created)
   → Indexed in <index>.md and timeline.md
   ```

**Special cases**:
- If the user says "remember this" without text, ask for the text.
- If the routing prompt is uncertain (returns `confidence < 0.6`), surface the proposal to the user before writing.
- Never store secrets (API keys, tokens, passwords) — refuse and tell the user to use a secrets manager instead.

---

## §3. recall

**Purpose**: Find relevant memories across the palace.

**Steps**:

1. **Parse the query** to detect intent:
   - Time-shaped ("2026 年 4 月 / last week / since X") → use `timeline.md` first
   - Entity-shaped ("about <person/server/project>") → check if a wing/room name matches first
   - Topical → semantic search

2. **Phase 1 — Grep filter**:
   - Use the Grep tool to search `wings/` for the query's keywords (use 2-3 root keywords, not the whole sentence)
   - Collect a candidate file list

3. **Phase 2 — Closet pre-rank**:
   - For each candidate's parent wing and room, read `_closet.md`
   - Discard rooms whose closet clearly doesn't relate

4. **Phase 3 — Detailed read**:
   - Open the surviving hall files and any linked drawers
   - Use `prompts/search-semantic.md` to synthesize an answer

5. **Output format**:
   ```
   Query: "<query>"

   Top match:
     <relative-path>
     Summary: <2-line synthesis from Claude>

   Related (N hits):
     - <path> — <one line>
     - <path> — <one line>

   Timeline context:
     <if applicable, 1-2 lines situating the answer in the broader timeline>

   Confidence: high/medium/low
   ```

6. **If nothing matches**:
   - Say so explicitly. Do NOT make up an answer.
   - Suggest alternative queries the user might try.
   - Offer to remember the query as an open question (write to `feedback.md` as "user asked X, no answer found").

---

## §4. timeline

**Purpose**: Show a chronological view of memories.

**Steps**:

1. **No argument**: read and display `timeline.md` (newest first), most recent 30 entries.

2. **With wing argument** (`/mp timeline infrastructure`):
   - Glob `wings/<wing>/**/drawers/*.md`
   - Read each frontmatter for `valid_from`
   - Also Glob bullets in `wings/<wing>/**/<hall>.md` and parse the `**YYYY-server-c-DD**` prefix
   - Sort newest first
   - Print as a markdown table with columns: Date | Room | Hall | Title | Path

3. **Output cap**: default 50 entries; user can specify `--limit N` or `--since YYYY-server-c-DD`.

---

## §5. wake-up

**Purpose**: Manually re-load the L1 context mid-session (e.g. after a long task that pushed memory out of context).

**Steps**:

1. Read all four index files (`user.md`, `project.md`, `reference.md`, `feedback.md`).
2. Concatenate them into a single output, separated by `---` and labeled.
3. Print the combined output back. This is the same content Claude Code loads at startup, just on demand.
4. Append a one-liner: `[wake-up at HH:server-c, ${PALACE_ROOT}, N wings, M drawers]`.

This subcommand exists because Claude Code only auto-loads at session start. After hours of work, the L1 layer may have aged out of context — `/mp wake-up` brings it back without restarting the session.

---

## §6. new-drawer

**Purpose**: Manually create a drawer (the "escape hatch" when `remember` would route to bullet but the user wants a drawer).

**Usage**: `/mp new-drawer <wing>/<room> <title>`

**Steps**:

1. Validate that `<wing>` exists (refuse if not — tell the user to use `remember` or `init` first).
2. Create `<room>` if missing (silent per decision B).
3. Generate slug from title: lowercase, alphanumeric + dashes, max 60 chars.
4. Create `wings/<wing>/<room>/drawers/YYYY-server-c-DD-<slug>.md` from the drawer template with empty body but pre-filled frontmatter.
5. Print the path and tell the user "open in your editor and fill in the body, then run `/mp remember` referencing this file if you want it routed/indexed".

---

## §7. list-wings

**Purpose**: Show all wings and their summaries.

**Steps**:

1. `ls wings/`
2. For each wing, read the first paragraph of `_closet.md` (or "(empty)" if missing).
3. Count rooms and drawers per wing.
4. Print as a table:
   ```
   Wing             | Rooms | Drawers | Summary
   ─────────────────|───────|─────────|─────────────────────────
   personal         |   3   |    12   | Alex's daily routine, ...
   infrastructure   |   5   |    27   | Server fleet (server-a, server-c, ...
   ```

---

## §8. status

**Purpose**: Quick palace stats.

**Steps**:

1. Compute:
   - `PALACE_ROOT` path
   - Number of wings (`ls wings/ | wc -l`)
   - Number of rooms (`find wings -mindepth 2 -maxdepth 2 -type d | wc -l`)
   - Number of drawers (`find wings -name "*.md" -path "*/drawers/*" | wc -l`)
   - Number of hall files with content (`find wings -name "facts.md" -o -name "events.md" ... | xargs wc -l | grep -v " 0 "`)
   - Total markdown size (`du -sh wings/`)
   - Estimated tokens: `wc -w wings/ | tail -1` × 1.3
   - New memories in the last 7 days (parse `timeline.md` and count entries with date >= now-7d)

2. Print as a compact summary:
   ```
   Palace: ${PALACE_ROOT}
   ────────────────────────────────────
   Wings:           5
   Rooms:           14
   Drawers:         42
   Hall files:      70 (active)
   Total size:      890 KB
   Estimated tokens: ~145,000
   New this week:   12 memories
   Last memory:     2026-04-07 (today)
   ────────────────────────────────────
   ```

---

## §9. migrate-from

**Purpose**: One-time bulk import of existing notes/memory files into the palace.

**Usage**: `/mp migrate-from <path>` where `<path>` can be:
- A single markdown file (e.g. an old `MEMORY.md`)
- A directory of markdown files (e.g. an another AI client `memory/` folder)
- A glob pattern

**Steps**:

1. **Discover sources**:
   - If `<path>` is a file: that's the only source.
   - If a directory: `find <path> -name "*.md" -type f`
   - Also support `.txt` files (treat as plain content).

2. **For each source file**:
   - Read the file
   - Split into "memory units" — heuristic:
     - Each `## H2` heading starts a new unit (heading becomes title)
     - In flat files with no headings, split by blank-line-separated paragraphs
     - Bullet lists become individual units
   - Skip very short units (< 30 chars) unless they look like a fact

3. **Dry-run first** (always — unless user passes `--apply`):
   - For each unit, run the routing prompt and collect the proposed `{wing, room, hall, storage}` decisions
   - Print a table:
     ```
     Source: <path>
     ─────────────────────────────────────────────────────────
     #  | Wing           | Room           | Hall        | Storage | Title (truncated)
     ─────────────────────────────────────────────────────────
     1  | infrastructure | web-api| discoveries | drawer  | Channel permission relay bypass
     2  | personal       | schedule       | preferences | bullet  | Prefers morning workouts
     ...
     ─────────────────────────────────────────────────────────
     New wings to create: [infrastructure, personal]
     Total units: N
     ```
   - Ask the user: `apply / edit / abort`

4. **On `apply`**:
   - Confirm new wing creation as in `remember` — but batch all confirmations into one prompt at the start
   - Then iterate through units, calling the same write logic as `remember` for each
   - Show a progress counter (`Migrating 12/47 ...`)
   - Add a `source: imported` and `imported_from: <original-path>` to every drawer's frontmatter

5. **Output report**:
   - Summary of new wings created, new rooms created, drawers written, bullets appended
   - Path to a migration log file at `audits/migration-YYYY-server-c-DD.md`

**Safety**:
- Never delete the source file
- If routing fails for a unit, write it to `feedback.md` under "## Unrouted on <date>" instead of dropping it

---

## §10. check (PR2)

**Purpose**: Detect contradictions in the palace using LLM semantic reasoning.

**Usage**: `/mp check <wing>` or `/mp check all`

**Steps**:

1. **Determine scope**:
   - `<wing>`: only that wing
   - `all`: every wing

2. **For each room in scope**:
   - Glob all hall files and drawers
   - Sort entries by `valid_from` (drawer frontmatter) or by the bullet date prefix
   - Read everything into memory

3. **Run the contradiction prompt** at `prompts/check-contradictions.md`. Pass it:
   - The room's wing/room name
   - All entries in chronological order
   - The current date

4. **Collect results**: For each room, the prompt returns a list of contradictions:
   ```json
   [
     {
       "type": "factual",            // factual | scope | implicit | superseded
       "record_a": "<excerpt + path:line>",
       "record_b": "<excerpt + path:line>",
       "analysis": "Short explanation",
       "suggestion": "merge | mark_a_superseded | mark_b_superseded | scope_them | manual_review"
     }
   ]
   ```

5. **Write the audit report** to `audits/YYYY-server-c-DD-<scope>.md`:
   - Alexdown table of all findings
   - Group by wing, then by room
   - At the bottom: "Suggested next steps" — a numbered list of fixes the user can apply
   - Frontmatter:
     ```yaml
     ---
     audit_date: 2026-04-07
     scope: all  # or wing name
     contradictions_found: 7
     rooms_audited: 14
     ---
     ```

6. **Never auto-fix**. The audit is read-only — fixes must be done by the user (or by Claude in a follow-up `remember` that explicitly marks records as superseded).

7. **Print summary**: Findings count + audit report path.

---

## §11. closet (PR2)

**Purpose**: (Re)generate `_closet.md` for a wing or room.

**Usage**:
- `/mp closet <wing>/<room>` — room level only
- `/mp closet <wing>` — wing level only
- `/mp closet` — refresh all

**Steps**:

1. **Room level**:
   - Read all hall files and drawers in the room
   - Run `prompts/generate-closet.md` to produce a 3–8 line summary
   - Write to `wings/<wing>/<room>/_closet.md` with frontmatter:
     ```yaml
     ---
     last_generated: 2026-04-07
     scope: room
     wing: <wing>
     room: <room>
     ---
     ```
   - Body: the generated summary, including:
     - 1-line "what this room is about"
     - 3-5 key facts/decisions
     - 2-3 most recent events
     - List of most-referenced drawers
     - Cross-tunnel links (if any)

2. **Wing level**:
   - Read all room `_closet.md` files in the wing (regenerate them first if stale)
   - Run the same prompt with wing scope
   - Write to `wings/<wing>/_closet.md`

3. **Refresh all**:
   - Iterate rooms first (bottom-up), then wings, so wing closets reflect fresh room closets

4. **Print summary**: which closets were updated.

**Trigger criterion** (manual or future cron): regenerate when more than N (default 5) new memories have been added since `last_generated`.

---

## §12. tunnel (PR2)

**Purpose**: Establish a bidirectional cross-wing link between two rooms.

**Usage**: `/mp tunnel <wing-a>/<room-a> <wing-b>/<room-b>`

**Steps**:

1. Verify both rooms exist.
2. In `wings/<wing-a>/<room-a>/_closet.md`, add to (or create) the `## Tunnels` section:
   ```markdown
   ## Tunnels
   - [<wing-b>/<room-b>](../../<wing-b>/<room-b>/_closet.md) — <one-line reason>
   ```
3. Symmetric edit in `wings/<wing-b>/<room-b>/_closet.md`.
4. Ask the user for the "reason" (one line) before writing.

---

## §13. export (PR2)

**Purpose**: Disaster-recovery export of the entire palace.

**Usage**: `/mp export <target-dir>`

**Steps**:

1. Create `<target-dir>` if missing.
2. Copy `${PALACE_ROOT}` recursively, preserving structure.
3. Generate `<target-dir>/INDEX.md` — a flat list of every drawer with title + frontmatter, organized by wing/room.
4. Generate `<target-dir>/INDEX.json` — same data as machine-readable JSON.
5. Generate `<target-dir>/EXPORT-MANIFEST.md`:
   ```markdown
   # Memory Palace Export
   - Source: ${PALACE_ROOT}
   - Exported: 2026-04-07T15:30:00
   - Wings: N
   - Rooms: M
   - Drawers: K
   - Bullets: J
   - Total size: X MB
   ```
6. Print the target path and tell the user to back it up (e.g. `git commit` or rsync).

This export is the **portability guarantee**: any markdown-aware system (including a future non-Claude memory system) can ingest the export. INDEX.json provides machine-readable structure for tooling.

---

## Reference docs (read these when needed)

- `references/architecture.md` — How the palace is organized and why
- `references/halls-guide.md` — How to decide which hall a memory belongs to
- `references/frontmatter-schema.md` — YAML schema for drawer files
- `references/drawer-template.md` — Templates for drawers and the four index files
- `references/writing-style.md` — Tone and formatting rules

## Prompts (use these for LLM-driven steps)

- `prompts/route-new-memory.md` — Used by `remember` and `migrate-from`
- `prompts/search-semantic.md` — Used by `recall`
- `prompts/check-contradictions.md` — Used by `check` (PR2)
- `prompts/generate-closet.md` — Used by `closet` (PR2)

---

## Anti-patterns (don't do these)

1. **Don't infer secrets are memories** — refuse to store API keys, passwords, tokens.
2. **Don't overwrite existing drawers without `superseded_by`** — append a new drawer and mark the old one.
3. **Don't run `check` automatically inside `remember`** — too slow; user must invoke explicitly.
4. **Don't make up wing/room names that don't fit the user's actual mental model** — when uncertain, ask.
5. **Don't bypass the routing prompt for `remember`** even if the input looks "obvious" — consistency matters more than speed.
6. **Don't write into other Claude Code config dirs** — only `${PALACE_ROOT}`.
7. **Don't strip or rewrite user's exact words** when storing as a drawer — paraphrase only in the `summary` field.
8. **Don't use `sed -i` on Windows** — it behaves differently. Read + Write or Edit instead.

---

## Cron / scheduling notes (informational, not auto-installed)

Suggested scheduled tasks for long-term users:

```
# Weekly contradiction audit (Sunday 02:00)
0 2 * * 0  cd ~ && claude -p "/mp check all" >/tmp/mp-audit.log 2>&1

# Monthly closet refresh (1st of month 03:00)
0 3 1 * *  cd ~ && claude -p "/mp closet" >/tmp/mp-closet.log 2>&1

# Weekly export to git
0 4 * * 0  cd ~/brain-backup && claude -p "/mp export ./$(date +%Y-%m-%d)" && git add -A && git commit -m "weekly palace snapshot" && git push
```

These are **suggestions only**; the skill does not install them. The user can wire them up via the `scheduled-tasks` MCP server or system cron.
