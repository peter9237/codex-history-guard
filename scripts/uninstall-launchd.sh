#!/usr/bin/env bash
set -euo pipefail

LABEL="com.codexhistoryguard.sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
rm -f "$PLIST"

echo "Uninstalled $LABEL"
echo "Data vault was not removed. Default vault: $HOME/.codex-history-vault"
