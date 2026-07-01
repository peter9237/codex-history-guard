#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD_SRC="$SCRIPT_DIR/codex-history-guard"
APP_DIR="$HOME/Library/Application Support/CodexHistoryGuard"
VAULT="${CODEX_HISTORY_VAULT:-$HOME/.codex-history-vault}"
BIN_DIR="$APP_DIR/bin"
LOG_DIR="$APP_DIR/logs"
PLIST="$HOME/Library/LaunchAgents/com.codexhistoryguard.sync.plist"
LABEL="com.codexhistoryguard.sync"
INTERVAL="${CODEX_HISTORY_INTERVAL_SECONDS:-300}"

mkdir -p "$BIN_DIR" "$LOG_DIR" "$HOME/Library/LaunchAgents"
cp "$GUARD_SRC" "$BIN_DIR/codex-history-guard"
chmod +x "$BIN_DIR/codex-history-guard"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$BIN_DIR/codex-history-guard</string>
    <string>mirror</string>
    <string>--skip-sqlite</string>
    <string>--sync-state-db</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>$INTERVAL</integer>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/launchd.err.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>CODEX_HISTORY_VAULT</key>
    <string>$VAULT</string>
  </dict>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/$LABEL"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo "Installed $LABEL"
echo "Vault: $VAULT"
echo "Command: $BIN_DIR/codex-history-guard"
echo "Logs: $LOG_DIR"
echo "Interval: ${INTERVAL}s"
