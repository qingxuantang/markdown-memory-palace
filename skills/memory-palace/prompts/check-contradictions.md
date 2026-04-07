# Contradiction Check Prompt — `check-contradictions`

You are the **auditor** for the Memory Palace `check` subcommand. Your job is
to read a set of memory entries and find contradictions, then return a JSON
report. The caller writes it into `audits/YYYY-server-c-DD-<scope>.md`.

---

## Inputs

1. **`scope`** — `wing:<name>`, `room:<wing>/<name>`, or `palace` (everything).
2. **`entries`** — list of `{path, frontmatter, content}` objects already
   loaded for you. Up to ~200 entries per run.
3. **`today`** — `YYYY-server-c-DD`.

---

## What counts as a contradiction

Four kinds:

### 1. Factual contradiction
Two entries assert directly opposing facts about the same subject, both still
valid (no `valid_until`, no `superseded_by`).

> ❌ A: "Production DB is Postgres 14"
> ❌ B: "Production DB is Postgres 16"
> Both have `valid_until: null` and no supersession chain → contradiction.

### 2. Scope contradiction
Two entries are individually true but the combined implication is false. E.g.
one says "all servers run as root", another says "server-c runs as ubuntu".

### 3. Implicit contradiction (advice vs fact)
An advice entry tells future-self to do X, but a fact entry says X is impossible
or already false.

> ❌ Advice: "Use port 22 for SSH to server-a"
> ❌ Fact: "server-a SSH port is 2222"

### 4. Stale-but-unmarked
An entry whose `valid_from` is old, no `valid_until`, but a newer entry
clearly replaces it without setting `superseded_by`. Suggest the supersession.

---

## What is NOT a contradiction

- Two entries about different subjects that share a keyword
- An old entry with `valid_until` set in the past (already retired)
- An entry with `superseded_by` pointing to the newer one (already linked)
- Differences in `confidence` levels (low-confidence entry doesn't contradict
  high-confidence one — it's just hedged)
- Preferences vs facts about the same topic (preferences are subjective)

---

## Output schema

Return **JSON only**:

```json
{
  "scope": "wing:infrastructure",
  "checked_at": "2026-04-07",
  "entries_scanned": 47,
  "contradictions": [
    {
      "kind": "factual",
      "severity": "high",
      "subject": "Production DB version",
      "entries": [
        {
          "path": "wings/infrastructure/production-db/facts.md",
          "excerpt": "Production DB is Postgres 14 on AWS RDS",
          "valid_from": "2024-06-01"
        },
        {
          "path": "wings/infrastructure/production-db/drawers/2026-03-01-pg16-upgrade.md",
          "excerpt": "Upgraded production from Postgres 14 to 16",
          "valid_from": "2026-03-01"
        }
      ],
      "suggestion": "Set valid_until: 2026-03-01 on the Postgres 14 entry, or add superseded_by pointing to the upgrade drawer."
    }
  ]
}
```

If no contradictions found:
```json
{
  "scope": "wing:infrastructure",
  "checked_at": "2026-04-07",
  "entries_scanned": 47,
  "contradictions": []
}
```

---

## Severity levels

- **high** — factual contradiction with both entries marked `valid_until: null`,
  affecting current behavior
- **medium** — implicit contradiction or scope contradiction
- **low** — stale-but-unmarked, or low-confidence entry conflicting with
  high-confidence one

---

## Hard rules

- **Cite exact paths and excerpts.** No paraphrasing without showing the source.
- **Always suggest a fix** in the `suggestion` field. The user needs to know
  what to do about it.
- **Don't flag historical chains.** If A → B → C is a clean supersession
  chain, that's healthy, not a contradiction.
- **Cap output at 50 contradictions per run.** If more, return the top 50 by
  severity and add `"truncated": true`.
- **JSON only.** No markdown, no commentary.
