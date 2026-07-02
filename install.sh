#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="${CODEX_SKILLS_DIR:-$CODEX_HOME/skills}"

mkdir -p "$BIN_DIR" "$SKILLS_DIR"

ln -sf "$REPO_DIR/scripts/codex-history-guard" "$BIN_DIR/codex-history"
ln -sf "$REPO_DIR/scripts/codex-history-guard" "$BIN_DIR/codex-history-guard"

mkdir -p "$SKILLS_DIR/codex-history-picker"
cp "$REPO_DIR/skill/codex-history-picker/SKILL.md" "$SKILLS_DIR/codex-history-picker/SKILL.md"
if [ -d "$REPO_DIR/skill/codex-history-picker/agents" ]; then
  mkdir -p "$SKILLS_DIR/codex-history-picker/agents"
  cp "$REPO_DIR/skill/codex-history-picker/agents/openai.yaml" "$SKILLS_DIR/codex-history-picker/agents/openai.yaml"
fi

"$BIN_DIR/codex-history" snapshot --skip-sqlite >/dev/null || true

cat <<MSG
Installed Codex History Guard.

CLI:
  $BIN_DIR/codex-history
  $BIN_DIR/codex-history-guard

Skill:
  $SKILLS_DIR/codex-history-picker

If $BIN_DIR is not on PATH, add this to your shell profile:
  export PATH="\$HOME/.local/bin:\$PATH"

Try:
  codex-history titles --limit 50
MSG
