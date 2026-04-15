<!-- BEGIN: memory-palace-override -->
## Memory System Rules (Memory Palace as sole memory backend)

This environment has **Memory Palace** installed as the only long-term memory system, fully replacing Claude Code's built-in flat memory.

### Write rules
**All memory writes must go through Memory Palace. The built-in flat system is disabled:**
- **DO NOT** create or modify `MEMORY.md`
- **DO NOT** create flat `.md` files in the `memory/` root directory (e.g. `user_role.md`, `feedback_testing.md`)
- **DO NOT** use the built-in auto-memory frontmatter format (`---\nname:\ndescription:\ntype:\n---`)
- **MUST** use Memory Palace's wings/rooms/halls/drawers structure

This applies to all scenarios:
- User says "remember this", "note this", "save this" etc. -> write to Palace wing/room
- User says "this is important" -> categorize and write to Palace
- **You decide something is worth remembering** -> also write to Palace, never use built-in auto-memory
- Learning user preferences, project info, feedback -> write to Palace L1 layer or wing/room

### Read rules
**All memory retrieval reads from Palace first:**
- User asks "what did we say about...", "recall", "remind me" -> search Palace
- L1 layer files (user.md, project.md, reference.md, feedback.md, timeline.md) are the fast index
- wings/ contains detailed memories organized by topic

### Palace management
Use the memory-palace skill (`/memory-palace`) for:
- Audit, migrate, create wings/rooms, restructure
- Clean up, merge, consolidate memories
- View palace overview and stats

### Path
Memory Palace root: `PALACE_PATH_PLACEHOLDER`
<!-- END: memory-palace-override -->
