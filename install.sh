#!/usr/bin/env bash
# Memory Palace installer
# Usage:
#   ./install.sh              → install to ~/.claude/skills/memory-palace (global)
#   ./install.sh --project    → install to ./.claude/skills/memory-palace (project-local)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills/memory-palace"
HOOKS_DIR="$SCRIPT_DIR/hooks"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

if [ ! -d "$SRC" ]; then
  echo "ERROR: source skill dir not found at $SRC" >&2
  exit 1
fi

if [ "${1:-}" = "--project" ]; then
  DEST="./.claude/skills/memory-palace"
  SCOPE="project-local"
else
  DEST="${HOME}/.claude/skills/memory-palace"
  SCOPE="global"
fi

if [ -d "$DEST" ]; then
  echo "Existing install detected at $DEST"
  read -r -p "Overwrite? [y/N] " ans
  case "$ans" in
    y|Y) rm -rf "$DEST" ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

mkdir -p "$(dirname "$DEST")"
cp -r "$SRC" "$DEST"

echo ""
echo "✓ Installed memory-palace skill ($SCOPE)"
echo "  → $DEST"

# --- Install block-flat-memory hook ---
HOOK_SRC="$HOOKS_DIR/block-flat-memory.sh"
HOOK_DEST="${HOME}/block-flat-memory.sh"

if [ -f "$HOOK_SRC" ]; then
  cp "$HOOK_SRC" "$HOOK_DEST"
  chmod +x "$HOOK_DEST"

  # Register hook in settings.json
  SETTINGS="${HOME}/.claude/settings.json"
  if [ -f "$SETTINGS" ]; then
    python3 - "$HOOK_DEST" "$SETTINGS" << 'PYEOF'
import json, sys
hook_path = sys.argv[1]
settings_path = sys.argv[2]
d = json.load(open(settings_path))
hooks = d.setdefault("hooks", {})
hook_entry = {"matcher":"","hooks":[{"type":"command","command": hook_path}]}
existing = hooks.get("PreToolUse", [])
if not any("block-flat-memory" in str(h) for h in existing):
    existing.append(hook_entry)
    hooks["PreToolUse"] = existing
    json.dump(d, open(settings_path, "w"), indent=4)
    print("  ✓ Registered block-flat-memory hook in settings.json")
else:
    print("  ✓ block-flat-memory hook already registered")
PYEOF
  else
    echo "  ⚠ ~/.claude/settings.json not found — register hook manually"
    echo "    Add to hooks.PreToolUse: {\"matcher\":\"\",\"hooks\":[{\"type\":\"command\",\"command\":\"$HOOK_DEST\"}]}"
  fi
else
  echo "  ⚠ hooks/block-flat-memory.sh not found in source — skipping hook install"
fi

# --- Append CLAUDE.md memory-palace-override rule ---
RULE_SRC="$TEMPLATES_DIR/claude-md-rule.md"

if [ -f "$RULE_SRC" ]; then
  # Compute palace path (best-effort; init will set the real one)
  CWD_SLUG=$(pwd | sed 's|\\|/|g; s|/|-|g; s|:|-|g; s|^-||')
  PALACE_PATH="${HOME}/.claude/projects/-${CWD_SLUG}/memory/"

  install_rule() {
    local target="$1"
    mkdir -p "$(dirname "$target")"
    touch "$target"
    if grep -q 'memory-palace-override' "$target" 2>/dev/null; then
      echo "  ✓ Memory Palace rule already in $target"
      return
    fi
    echo "" >> "$target"
    sed "s|PALACE_PATH_PLACEHOLDER|${PALACE_PATH}|g" "$RULE_SRC" >> "$target"
    echo "  ✓ Appended Memory Palace rule to $target"
  }

  install_rule "${HOME}/CLAUDE.md"
  install_rule "${HOME}/.claude/CLAUDE.md"
else
  echo "  ⚠ templates/claude-md-rule.md not found — skipping CLAUDE.md setup"
fi

echo ""
echo "Next: open Claude Code in any project and say:"
echo "    建一下记忆宫殿"
echo "  or"
echo "    initialize the memory palace"
echo ""
