#!/bin/bash
# PreToolUse hook: block writes to MEMORY.md and flat memory files
# Forces Claude to use Memory Palace wings/rooms structure instead of
# Claude Code's built-in auto-memory system.
#
# What it blocks:
#   - Writing/editing MEMORY.md (the built-in memory index)
#   - Creating flat .md files directly in memory/ root
#     (e.g. user_role.md, feedback_testing.md)
#
# What it allows:
#   - L1 layer files: user.md, project.md, reference.md, feedback.md, timeline.md
#   - .palace-config.yaml, _closet.md
#   - Everything under wings/ (the Palace structure)
#   - Everything under audits/
#
# Install: register in ~/.claude/settings.json under hooks.PreToolUse
# See install.sh for automated setup.

input=$(cat)
HOOK_HOME="$HOME" python3 - "$input" << 'PY'
import sys, json, os, re
try:
    d = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)
event = d.get("hook_event_name", "")
if event != "PreToolUse":
    sys.exit(0)
tool = d.get("tool_name", "")
ti = d.get("tool_input", {}) or {}
home = os.environ.get("HOOK_HOME", "")

# Only intercept Write/Edit tools
if tool not in ("Write", "Edit"):
    sys.exit(0)

path = ti.get("file_path", "")
if not path:
    sys.exit(0)

# Expand ~
if path.startswith("~/"):
    path = home + path[1:]

# Block patterns:
# 1. MEMORY.md in any .claude/projects/*/memory/ directory
# 2. Flat files directly in memory/ root (not in wings/ or audits/)
memory_dir_pattern = re.escape(home) + r"/\.claude/projects/[^/]+/memory/"
is_memory_md = bool(re.match(memory_dir_pattern + r"MEMORY\.md$", path))
is_flat_in_root = bool(re.match(memory_dir_pattern + r"[^/]+\.md$", path)) and "/wings/" not in path and not any(
    path.endswith(f) for f in [
        "user.md", "project.md", "reference.md", "feedback.md", "timeline.md",
        ".palace-config.yaml", "_closet.md"
    ]
)

if is_memory_md or is_flat_in_root:
    result = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": "BLOCKED: Do not use Claude Code built-in flat memory. Use Memory Palace wings/rooms structure instead. Write to wings/<wing>/<room>/facts.md or similar Palace paths."
        }
    }
    print(json.dumps(result))
PY
