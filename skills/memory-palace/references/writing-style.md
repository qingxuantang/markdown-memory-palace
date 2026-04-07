# Writing Style for Memory Palace Entries

These rules apply to anything written into the palace by the `remember`,
`migrate-from`, or `closet` commands. Following them keeps the palace
**searchable**, **reusable**, and **trustworthy**.

## Tone and voice

1. **Third-person past tense** for events and discoveries:
   - ✅ "Alex deployed the bot to server-a on 2026-04-07."
   - ❌ "I deployed the bot." (whose "I"?)
   - ❌ "Today we deployed the bot." ("today" rots — use the date)

2. **Imperative mood** for advice:
   - ✅ "Always re-run the patch after marketplace update."
   - ❌ "You should always..." (who is "you"?)
   - ❌ "I always..." (rot)

3. **Declarative present tense** for facts:
   - ✅ "Production database is Postgres 16 on AWS RDS."
   - ❌ "The production database has been Postgres 16 since..." (use `valid_from` for dates)

4. **No filler words**: skip "basically", "essentially", "actually", "kind of",
   "I think", "maybe". If a memory is uncertain, set `confidence: low` in
   frontmatter — don't hedge in prose.

5. **No emojis** unless quoting the user verbatim (or in `tldr` for visual
   scanning if explicitly useful — default no).

## Specificity

A memory is only useful if a future reader can act on it. Concrete > vague.

| Vague (bad) | Specific (good) |
|---|---|
| "Production has issues sometimes" | "Production crashes ~once/week when DB connection pool exhausts at >500 concurrent users" |
| "Use a faster server" | "Use a server in HK/SG/JP/US/EU; mainland China servers cannot reach Telegram API" |
| "There was a bug" | "Telegram plugin server.ts line 365 declared `claude/channel/permission` capability, causing permission relay to fire" |
| "Alex likes Python" | "Alex prefers Python over JS for backend work; explicit reason: type hints + readability" |

## Length per entry type

| Entry type | Target length |
|---|---|
| Bullet (in `<hall>.md`) | 1-3 sentences, 50-280 chars |
| Section (`## H2` in hall file) | 1-3 short paragraphs, 300-800 chars |
| Drawer | 200+ words, structured into Background / Core / Open Questions / See Also |

**Don't pad** to hit a target. A 50-char bullet is fine. A 1500-word drawer
that has nothing to say is not.

## Date discipline

1. **Always include the date** in the bullet body for hall files:
   ```markdown
   - **2026-04-07** — Alex deployed bot to server-a ...
   ```

2. **`valid_from` in frontmatter** must be the date the memory **became
   true**, not the date you wrote it down. If you're recording a fact from
   last week, `valid_from` should be last week.

3. **Time-of-day** is rarely useful. Skip it unless the timing matters
   (e.g. for an outage timeline).

4. **Relative dates** ("yesterday", "last week") are forbidden in stored
   content. Convert to absolute dates before writing.

## Source attribution

Every entry should be traceable. Convention:

- **Bullets**: `[source: claude-code-session]` suffix or in section's
  italic footer
- **Sections**: italic footer line: `*source: claude-code-session* · *tags: a, b*`
- **Drawers**: `source` and `tags` in frontmatter

If the user said something verbatim, you can add a `quoted: true` tag.

## Linking conventions

1. **Always use relative paths** for cross-references:
   - ✅ `[link](./drawers/2026-04-07-foo.md)`
   - ✅ `[link](../../infrastructure/gali/_closet.md)`
   - ❌ `[link](~/.claude/projects/.../foo.md)` (absolute, breaks on move)

2. **Cross-wing links** go through `_closet.md`, not directly to drawers, so
   that the closet is the canonical "entry point" to a wing.

3. **External links** (URLs) are fine and encouraged where they add context.

## What NOT to write into the palace

1. **Secrets** (API keys, tokens, passwords, OAuth tokens, SSH private keys)
   — refuse and tell the user to use a secrets manager.
2. **Personally identifying info about third parties** that wasn't already
   public.
3. **Speculation presented as fact** — if you don't know, set
   `confidence: low` and say "appears to" or "is likely".
4. **Long verbatim command outputs** unless they're the **point** of the
   memory (e.g. an error message you need to remember). For long outputs,
   summarize and link to a separate file outside the palace.
5. **Throwaway debugging chatter** — only the conclusions are worth
   remembering, not every print statement.
6. **Things Claude inferred without user confirmation** when the user
   didn't say them — when in doubt, ask "should I remember this?"

## Anti-patterns

### "Remember everything" syndrome
The palace is not a transcript. **Most conversation is forgettable.** Only
store things that:
- A future Claude session would want to know
- Cost effort to rediscover
- The user explicitly flagged

### "Mega-drawer" syndrome
A 5000-word drawer covering "everything about web-api" is worse than
20 small drawers covering individual decisions. Atomicity helps both
retrieval and supersession.

### "Living document" syndrome
Drawers should be **point-in-time** records. If something needs constant
updating, it belongs in `_closet.md` (which is regenerated) or in an
external doc (like a CLAUDE.md). Don't keep editing a drawer.

### "Categorical confusion" syndrome
A drawer in `discoveries.md` that's actually three facts mashed together →
split it. The routing prompt should detect this; if it didn't, ask for a
re-route.

### "Decoration" syndrome
Adding emojis, headings, formatting that doesn't carry information. Plain
prose with one or two `## H2` headings beats elaborate structure for almost
every memory.

## Reviewing your own writing

After writing a drawer or hall entry, ask:

1. If I lose context tomorrow, will this entry still make sense alone?
2. Could a different Claude session use this without re-reading the
   conversation that produced it?
3. Are the dates absolute, not relative?
4. Is the source clear?
5. Does the title (or first sentence) tell me what it's about in 8 words?

If any answer is "no", revise before saving.
