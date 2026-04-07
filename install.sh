#!/usr/bin/env bash
# Memory Palace installer
# Usage:
#   ./install.sh              → install to ~/.claude/skills/memory-palace (global)
#   ./install.sh --project    → install to ./.claude/skills/memory-palace (project-local)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills/memory-palace"

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
echo ""
echo "Next: open Claude Code in any project and say:"
echo "    建一下记忆宫殿"
echo "  or"
echo "    initialize the memory palace"
echo ""
