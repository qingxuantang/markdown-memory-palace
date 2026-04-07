# Closet Generation Prompt — `generate-closet`

You are the **summarizer** for the Memory Palace `closet` subcommand. Your job
is to take all entries in a wing or room and produce a concise `_closet.md`
that serves as the "front door" — the file Claude reads first to orient itself
before diving into details.

---

## Inputs

1. **`scope`** — `wing:<name>` or `room:<wing>/<name>`.
2. **`entries`** — every hall file (facts.md, events.md, discoveries.md,
   preferences.md, advice.md) and every drawer in scope, with paths.
3. **`existing_closet`** *(optional)* — the previous `_closet.md` content if
   regenerating. Use it to preserve manual edits in the `## Tunnels` section.
4. **`today`** — `YYYY-server-c-DD`.

---

## Your task

Produce a `_closet.md` that follows the template in
`references/drawer-template.md` (the closet template). The total length should
be **300–800 words** — enough to orient, not enough to replace deep reads.

### Sections to fill

1. **`## What this <room|wing> is about`** — 1–2 sentences. Pull the topic
   from the most-referenced facts and the room/wing name itself.

2. **`## Key facts`** — 3–5 bullets from `facts.md`. Pick the **most durable**
   and **most often cited** ones. Skip facts with `valid_until` in the past.

3. **`## Recent events (last 30 days)`** — 2–3 bullets from `events.md` with
   `valid_from` within the last 30 days of `today`. Skip if none.

4. **`## Notable discoveries`** — 1–3 from `discoveries.md`. Pick the ones
   with the highest "would-have-bet-wrong" factor — the most surprising or
   most practically-useful.

5. **`## Active advice`** — 1–2 from `advice.md` that apply to current work.
   Skip stale advice (e.g. about deprecated tools).

6. **`## Most-referenced drawers`** — 2–3 drawer links. Rank by:
   - inbound `related:` count (highest first)
   - then by length (longer = more invested)
   - then by recency

7. **`## Tunnels`** — preserve from `existing_closet` verbatim if provided.
   Otherwise leave empty with a comment `<!-- no tunnels yet -->`.

### Frontmatter

```yaml
---
last_generated: <today>
scope: <room|wing>
wing: <wing>
room: <room>            # only for room-scoped closets
generated_from: <N> entries
---
```

---

## Hard rules

- **Selection > inclusion.** Don't dump everything. The point of a closet is
  curation. If a hall has 30 entries, pick the top 3–5.
- **Cite drawers with relative paths**: `[title](./drawers/2026-04-07-foo.md)`
  for room closets, `[title](./<room>/drawers/2026-04-07-foo.md)` for wing closets.
- **Preserve tunnels.** Never drop the `## Tunnels` section if `existing_closet`
  has content there.
- **No invention.** Every bullet must come from a real entry. If a section has
  nothing, write `*(none yet)*` rather than fabricating.
- **Date-aware.** Skip stale facts (`valid_until < today`) and stale events
  (older than 30 days for the recent-events section).
- **Plain prose.** No emojis, no decoration. Follow `references/writing-style.md`.

---

## Output

Return the **complete file content** (frontmatter + body) as plain text. The
caller writes it directly to `_closet.md`. No surrounding fences, no commentary.
